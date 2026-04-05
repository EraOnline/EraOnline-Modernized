/**
 * Era Online Renderer
 *
 * Faithful port of the VB6 DirectDraw rendering pipeline (Graphics.bas).
 * 3-pass rendering: ground tiles -> fringe/objects/characters -> (weather).
 * Sprite system based on the Grh (Graphic) atlas from Grh.dat.
 *
 * VB6 reference functions:
 *   RenderScreen (Graphics.bas:336)           - main 3-pass render with screenbuffer overdraw
 *   DrawBackBufferSurface (Graphics.bas:228)  - crop overdraw to viewport
 *   DDrawGrhtoSurface (Graphics.bas:76)       - opaque sprite blit with animation
 *   DDrawTransGrhtoSurface (Graphics.bas:151) - transparent blit with animation
 *   InitGrh (General.bas:614)                 - animation setup
 *   MakeChar (General.bas:341)                - character compositing setup
 *   CheckMoveKeys (General.bas:395)           - keyboard movement input
 *   MoveScreen (General.bas:701)              - start screen scrolling
 *   MoveCharbyHead (General.bas:649)          - start character move interpolation
 *   Main game loop (General.bas:1121)         - 8px/frame offset interpolation
 */
const EraRenderer = (() => {
    // Constants matching VB6 Declarations.bas
    const TILE_SIZE = 32;
    const VIEWPORT_W = 20; // tiles (XWindow)
    const VIEWPORT_H = 11; // tiles (YWindow)
    const MOVE_SPEED = 8;  // pixels per frame for movement interpolation
    const TARGET_FPS = 30; // VB6 original capped at 30fps (General.bas:1136)
    const FRAME_TIME = 1000 / TARGET_FPS; // ~33.3ms per frame

    // Screen buffer: extra tiles drawn beyond viewport to prevent black edges during scrolling.
    // VB6 uses screenbuffer=10 with a large back buffer and a crop blit (DrawBackBufferSurface).
    // We use 2 tiles (enough to cover the max 32px offset) and clip via canvas.
    const SCREEN_BUFFER = 2;

    // Direction constants matching VB6: NORTH=1, EAST=2, SOUTH=3, WEST=4
    const NORTH = 1, EAST = 2, SOUTH = 3, WEST = 4;

    // State
    let canvas, ctx;
    let dataBasePath = '/data';
    let grhEntries = {};   // grhIndex -> { file, x, y, w, h } or { frames, speed }
    let spriteSheets = {}; // fileNum -> Image (loaded on demand)
    let loadingSheets = new Set();
    let mapData = null;    // current map JSON
    let npcDefs = [];      // NPC definitions for sprite lookup
    let bodyDefs = {};     // bodyId -> { walk: [N,E,S,W], headOffsetX, headOffsetY }
    let headDefs = {};     // headId -> { grh: [N,E,S,W] }
    let weaponAnimDefs = {}; // animId -> { walk: [N,E,S,W] }
    let shieldAnimDefs = {}; // animId -> { walk: [N,E,S,W] }
    let configData = null; // server config (starting cities etc.)
    let dataLoaded = false;
    let statusEl = null;
    let fpsEl = null;

    // --- Frame Timing ---
    // VB6: FPSTimer (1000ms interval) counts frames per second.
    // VB6: Main loop caps at 30fps (If FramesPerSec <= 30 Then).
    let lastFrameTime = 0;
    let frameCount = 0;
    let lastFpsUpdate = 0;
    let currentFps = 0;

    // --- Camera State ---
    // VB6 model: camera tile stays at the OLD position during movement.
    // OffsetCounter accumulates from 0 toward ±32 (8px per frame).
    // On the final frame, camera tile snaps to the new position and offset resets.
    // VB6: AddtoUserPos, OffsetCounterX/Y, UserPos (General.bas:1139-1179)
    let camTileX = 50;        // camera center tile (the tile RenderScreen receives)
    let camTileY = 50;
    let screenOffsetX = 0;    // pixel offset accumulating during movement (VB6: OffsetCounterX)
    let screenOffsetY = 0;    // pixel offset accumulating during movement (VB6: OffsetCounterY)
    let addToUserPosX = 0;    // movement direction: -1, 0, or 1 (VB6: AddtoUserPos.x)
    let addToUserPosY = 0;    // movement direction: -1, 0, or 1 (VB6: AddtoUserPos.y)
    let userMoving = false;   // true while the screen is scrolling (VB6: UserMoving)

    // --- Animation State ---
    let tileAnimState = {};

    // --- Characters ---
    let characters = [];

    // --- Player ---
    let player = null;
    let keysDown = {};

    function setStatus(msg) {
        if (statusEl) statusEl.textContent = msg;
        console.log('[EraRenderer] ' + msg);
    }

    async function init(canvasId, basePath) {
        canvas = document.getElementById(canvasId);
        ctx = canvas.getContext('2d');
        dataBasePath = basePath || '/data';
        statusEl = document.getElementById('loading');

        canvas.width = VIEWPORT_W * TILE_SIZE;
        canvas.height = VIEWPORT_H * TILE_SIZE;
        ctx.imageSmoothingEnabled = false;
        fpsEl = document.getElementById('fps');

        setStatus('Loading sprite definitions...');
        await loadGrhData();

        setStatus('Loading sprite data...');
        await loadSpriteDefs();

        setStatus('Loading map...');
        await loadMap(81); // Castlefall

        setStatus('Loading sprite sheets...');
        await preloadVisibleSheets();

        // Create the test player at Castlefall spawn
        createTestPlayer();

        // Create a patrolling NPC for movement animation testing
        createPatrolNpc();

        dataLoaded = true;
        updateStatus();

        // Keyboard input
        document.addEventListener('keydown', onKeyDown);
        document.addEventListener('keyup', onKeyUp);

        // Start render loop
        requestAnimationFrame(renderLoop);
    }

    // --- Test Player ---

    function createTestPlayer() {
        let spawnX = 59, spawnY = 41;
        if (configData && configData.startingCities) {
            const castlefall = configData.startingCities.find(c => c.map === 81);
            if (castlefall) {
                spawnX = castlefall.x;
                spawnY = castlefall.y;
            }
        }

        const headId = 6 + Math.floor(Math.random() * 10);
        player = makeCharacter(spawnX, spawnY, 1, headId, SOUTH, 2, 2);
        characters.push(player);

        // Initialize camera on player
        camTileX = spawnX;
        camTileY = spawnY;

        setStatus(`Test player created at (${spawnX}, ${spawnY})`);
    }

    // --- Patrol NPC (test) ---

    let patrolNpc = null;
    let patrolPath = [];
    let patrolLegIndex = 0;
    let patrolStepsRemaining = 0;

    function createPatrolNpc() {
        patrolNpc = makeCharacter(61, 31, 3, 26, SOUTH, 2, 2);
        characters.push(patrolNpc);

        patrolPath = [
            { dx:  0, dy:  1, heading: SOUTH, steps: 6 },
            { dx: -1, dy:  0, heading: WEST,  steps: 5 },
            { dx:  0, dy: -1, heading: NORTH, steps: 6 },
            { dx:  1, dy:  0, heading: EAST,  steps: 5 },
        ];
        patrolLegIndex = 0;
        patrolStepsRemaining = patrolPath[0].steps;
    }

    function updatePatrolNpc() {
        if (!patrolNpc || patrolNpc.moving) return;

        const leg = patrolPath[patrolLegIndex];
        if (patrolStepsRemaining <= 0) {
            patrolLegIndex = (patrolLegIndex + 1) % patrolPath.length;
            patrolStepsRemaining = patrolPath[patrolLegIndex].steps;
            return;
        }

        patrolNpc.heading = leg.heading;
        patrolNpc.x += leg.dx;
        patrolNpc.y += leg.dy;
        patrolNpc.moveOffsetX = -leg.dx * TILE_SIZE;
        patrolNpc.moveOffsetY = -leg.dy * TILE_SIZE;
        patrolNpc.moving = true;
        patrolStepsRemaining--;
    }

    function makeCharacter(x, y, bodyId, headId, heading, weaponAnim, shieldAnim) {
        const ch = {
            x, y,
            bodyId, headId, heading,
            weaponAnim, shieldAnim,
            moveOffsetX: 0,
            moveOffsetY: 0,
            moving: false,
            walkAnims: {}
        };
        initCharAnims(ch);
        return ch;
    }

    function initCharAnims(ch) {
        ch.walkAnims = {};
        const body = bodyDefs[ch.bodyId];
        if (body && body.walk) {
            for (let dir = 0; dir < 4; dir++) {
                const grhIdx = body.walk[dir];
                const entry = grhEntries[grhIdx];
                if (entry && entry.frames) {
                    ch.walkAnims[dir] = {
                        frameCounter: 0,
                        speedCounter: entry.speed || 1,
                        started: false
                    };
                }
            }
        }
    }

    function onKeyDown(e) {
        keysDown[e.key] = true;
        if (['ArrowUp', 'ArrowDown', 'ArrowLeft', 'ArrowRight'].includes(e.key)) {
            e.preventDefault();
        }
    }

    function onKeyUp(e) {
        delete keysDown[e.key];
    }

    /**
     * Process player movement input.
     * VB6: CheckMoveKeys (General.bas:395)
     *
     * Matches the VB6 model:
     * 1. CheckMoveKeys checks LegalPos and calls MoveCharbyHead + MoveScreen
     * 2. MoveScreen sets AddtoUserPos and updates UserPos immediately
     * 3. The main loop interpolates OffsetCounter from 0 toward ±32
     * 4. RenderScreen receives (UserPos - AddtoUserPos) = OLD tile position
     */
    function processPlayerInput() {
        if (!player || userMoving) return;

        let heading = 0;
        let dx = 0, dy = 0;

        if (keysDown['ArrowUp']) { heading = NORTH; dy = -1; }
        else if (keysDown['ArrowDown']) { heading = SOUTH; dy = 1; }
        else if (keysDown['ArrowLeft']) { heading = WEST; dx = -1; }
        else if (keysDown['ArrowRight']) { heading = EAST; dx = 1; }

        if (heading === 0) return;

        player.heading = heading;

        const newX = player.x + dx;
        const newY = player.y + dy;

        if (!isLegalPos(newX, newY)) return;

        // VB6 MoveCharbyHead: update character position, set MoveOffset for walk interpolation
        player.x = newX;
        player.y = newY;
        player.moveOffsetX = -dx * TILE_SIZE;
        player.moveOffsetY = -dy * TILE_SIZE;
        player.moving = true;

        // VB6 MoveScreen: set AddtoUserPos and update UserPos (already done above via player.x/y)
        // Camera tile stays where it is - AddtoUserPos tells the main loop which direction to scroll
        addToUserPosX = dx;
        addToUserPosY = dy;
        screenOffsetX = 0;
        screenOffsetY = 0;
        userMoving = true;

        updateStatus();
    }

    /**
     * Update screen scrolling (camera movement).
     * VB6: Main game loop (General.bas:1139-1164)
     *
     * Each frame, accumulate 8px of offset in the movement direction.
     * When offset reaches a full tile (32px), snap camera to new position and reset.
     */
    function updateScreenScroll() {
        if (!userMoving) return;

        let done = true;

        if (addToUserPosX !== 0) {
            // VB6: OffsetCounterX = OffsetCounterX - (8 * Sgn(AddtoUserPos.x))
            screenOffsetX -= MOVE_SPEED * Math.sign(addToUserPosX);
            if (Math.abs(screenOffsetX) >= TILE_SIZE) {
                // Snap: camera tile moves to new position, offset resets
                camTileX += addToUserPosX;
                screenOffsetX = 0;
                addToUserPosX = 0;
            } else {
                done = false;
            }
        }

        if (addToUserPosY !== 0) {
            screenOffsetY -= MOVE_SPEED * Math.sign(addToUserPosY);
            if (Math.abs(screenOffsetY) >= TILE_SIZE) {
                camTileY += addToUserPosY;
                screenOffsetY = 0;
                addToUserPosY = 0;
            } else {
                done = false;
            }
        }

        if (done) {
            userMoving = false;
        }
    }

    function isLegalPos(x, y) {
        if (x < 1 || x > 100 || y < 1 || y > 100) return false;
        if (mapData) {
            const idx = (y - 1) * 100 + (x - 1);
            if (mapData.tiles.blocked[idx] === 1) return false;
        }
        for (const ch of characters) {
            if (ch === player) continue;
            if (ch.x === x && ch.y === y) return false;
        }
        return true;
    }

    /**
     * Update character movement interpolation (for NPCs and the player's walk animation).
     * VB6: RenderScreen (Graphics.bas:441-471)
     */
    function updateMovement(ch) {
        if (!ch.moving) return;

        let stillMoving = false;

        if (ch.moveOffsetX !== 0) {
            if (Math.abs(ch.moveOffsetX) <= MOVE_SPEED) {
                ch.moveOffsetX = 0;
            } else {
                ch.moveOffsetX -= MOVE_SPEED * Math.sign(ch.moveOffsetX);
            }
            if (ch.moveOffsetX !== 0) stillMoving = true;
        }

        if (ch.moveOffsetY !== 0) {
            if (Math.abs(ch.moveOffsetY) <= MOVE_SPEED) {
                ch.moveOffsetY = 0;
            } else {
                ch.moveOffsetY -= MOVE_SPEED * Math.sign(ch.moveOffsetY);
            }
            if (ch.moveOffsetY !== 0) stillMoving = true;
        }

        if (!stillMoving) {
            ch.moving = false;
            ch.moveOffsetX = 0;
            ch.moveOffsetY = 0;
            const hi = (ch.heading || SOUTH) - 1;
            if (ch.walkAnims[hi]) {
                ch.walkAnims[hi].frameCounter = 0;
                ch.walkAnims[hi].started = false;
            }
        } else {
            const hi = (ch.heading || SOUTH) - 1;
            if (ch.walkAnims[hi]) {
                ch.walkAnims[hi].started = true;
            }
        }
    }

    function updateStatus() {
        if (!player || !mapData) return;
        setStatus(`Map ${mapData.id} | Player: (${player.x}, ${player.y}) | Arrow keys to move`);
    }

    // --- Data Loading ---

    async function loadGrhData() {
        const resp = await fetch(`${dataBasePath}/grh.json`);
        const data = await resp.json();
        for (const [key, entry] of Object.entries(data.entries)) {
            grhEntries[parseInt(key)] = entry;
        }
        setStatus(`Loaded ${Object.keys(grhEntries).length} sprite definitions`);
    }

    async function loadSpriteDefs() {
        const [heads, bodies, weapons, shields, npcs, config] = await Promise.all([
            fetch(`${dataBasePath}/heads.json`).then(r => r.json()),
            fetch(`${dataBasePath}/bodies.json`).then(r => r.json()),
            fetch(`${dataBasePath}/weapon-anims.json`).then(r => r.json()),
            fetch(`${dataBasePath}/shield-anims.json`).then(r => r.json()),
            fetch(`${dataBasePath}/npcs.json`).then(r => r.json()),
            fetch(`${dataBasePath}/config.json`).then(r => r.json()),
        ]);

        for (const h of heads) headDefs[h.id] = h;
        for (const b of bodies) bodyDefs[b.id] = b;
        for (const w of weapons) weaponAnimDefs[w.id] = w;
        for (const s of shields) shieldAnimDefs[s.id] = s;
        npcDefs = npcs;
        configData = config;

        setStatus(`Loaded ${heads.length} heads, ${bodies.length} bodies, ${weapons.length} weapon anims, ${shields.length} shield anims, ${npcs.length} NPCs`);
    }

    async function loadMap(mapId) {
        const padded = String(mapId).padStart(3, '0');
        const resp = await fetch(`${dataBasePath}/maps/map-${padded}.json`);
        mapData = await resp.json();

        tileAnimState = {};

        characters = [];
        for (const spawn of mapData.npcSpawns) {
            const [x, y, npcTemplate] = spawn;
            const npc = npcDefs.find(n => n.id === npcTemplate);
            if (npc) {
                characters.push(makeCharacter(
                    x, y,
                    npc.body || 1,
                    npc.head || 1,
                    npc.heading || SOUTH,
                    2, 2
                ));
            }
        }

        if (player) {
            characters.push(player);
        }

        setStatus(`Loaded map ${mapId}: ${characters.length} characters placed`);
    }

    function loadSpriteSheet(fileNum) {
        if (spriteSheets[fileNum] || loadingSheets.has(fileNum)) return;
        loadingSheets.add(fileNum);

        const img = new Image();
        img.onload = () => {
            spriteSheets[fileNum] = img;
            loadingSheets.delete(fileNum);
        };
        img.onerror = () => {
            loadingSheets.delete(fileNum);
        };
        img.src = `${dataBasePath}/grh/grh${fileNum}.png`;
    }

    async function preloadVisibleSheets() {
        const sheetsNeeded = new Set();
        if (!mapData) return;

        const layers = [mapData.tiles.layer1, mapData.tiles.layer2, mapData.tiles.layer3];
        for (const layer of layers) {
            for (const grhIndex of layer) {
                if (grhIndex > 0) {
                    collectSheetFiles(grhIndex, sheetsNeeded);
                }
            }
        }

        for (const ch of characters) {
            collectCharSheets(ch, sheetsNeeded);
        }

        setStatus(`Preloading ${sheetsNeeded.size} sprite sheets...`);

        const promises = [];
        for (const fileNum of sheetsNeeded) {
            if (!spriteSheets[fileNum]) {
                promises.push(new Promise(resolve => {
                    const img = new Image();
                    img.onload = () => { spriteSheets[fileNum] = img; resolve(); };
                    img.onerror = () => resolve();
                    img.src = `${dataBasePath}/grh/grh${fileNum}.png`;
                }));
            }
        }
        await Promise.all(promises);
        setStatus(`${Object.keys(spriteSheets).length} sprite sheets loaded`);
    }

    function collectSheetFiles(grhIndex, sheetsSet) {
        const entry = grhEntries[grhIndex];
        if (!entry) return;
        if (entry.frames) {
            for (const frameIdx of entry.frames) {
                const frame = grhEntries[frameIdx];
                if (frame && frame.file) sheetsSet.add(frame.file);
            }
        } else if (entry.file) {
            sheetsSet.add(entry.file);
        }
    }

    function collectCharSheets(ch, sheetsSet) {
        const body = bodyDefs[ch.bodyId];
        const head = headDefs[ch.headId];
        if (body && body.walk) {
            for (const grhIdx of body.walk) collectSheetFiles(grhIdx, sheetsSet);
        }
        if (head && head.grh) {
            for (const grhIdx of head.grh) collectSheetFiles(grhIdx, sheetsSet);
        }
    }

    // --- Animation ---

    function getTileAnimState(grhIndex) {
        if (!tileAnimState[grhIndex]) {
            const entry = grhEntries[grhIndex];
            tileAnimState[grhIndex] = {
                frameCounter: 0,
                speedCounter: entry ? (entry.speed || 1) : 1
            };
        }
        return tileAnimState[grhIndex];
    }

    function tickTileAnim(grhIndex) {
        const entry = grhEntries[grhIndex];
        if (!entry || !entry.frames || entry.frames.length <= 1) return;

        const state = getTileAnimState(grhIndex);
        state.speedCounter--;
        if (state.speedCounter <= 0) {
            state.speedCounter = entry.speed || 1;
            state.frameCounter = (state.frameCounter + 1) % entry.frames.length;
        }
    }

    function tickCharAnim(ch) {
        const hi = (ch.heading || SOUTH) - 1;
        const animState = ch.walkAnims[hi];
        if (!animState || !animState.started) return;

        const body = bodyDefs[ch.bodyId];
        if (!body || !body.walk) return;
        const grhIdx = body.walk[hi];
        const entry = grhEntries[grhIdx];
        if (!entry || !entry.frames) return;

        animState.speedCounter--;
        if (animState.speedCounter <= 0) {
            animState.speedCounter = entry.speed || 1;
            animState.frameCounter = (animState.frameCounter + 1) % entry.frames.length;
        }
    }

    // --- Rendering ---

    function resolveGrh(grhIndex, animState) {
        const entry = grhEntries[grhIndex];
        if (!entry) return null;

        if (entry.frames && entry.frames.length > 0) {
            let frameIdx;
            if (animState) {
                frameIdx = animState.frameCounter % entry.frames.length;
            } else {
                const tState = getTileAnimState(grhIndex);
                frameIdx = tState.frameCounter % entry.frames.length;
            }
            return grhEntries[entry.frames[frameIdx]] || null;
        }
        return entry;
    }

    function drawGrh(grhIndex, px, py, center, animState) {
        const sprite = resolveGrh(grhIndex, animState || null);
        if (!sprite || !sprite.file) return;

        const sheet = spriteSheets[sprite.file];
        if (!sheet) {
            loadSpriteSheet(sprite.file);
            return;
        }

        let dx = px;
        let dy = py;

        if (center) {
            const tw = sprite.w / TILE_SIZE;
            const th = sprite.h / TILE_SIZE;
            if (tw !== 1) dx -= (tw * 16) - 16;
            if (th !== 1) dy -= (th * 32) - 32;
        }

        ctx.drawImage(
            sheet,
            sprite.x, sprite.y, sprite.w, sprite.h,
            dx, dy, sprite.w, sprite.h
        );
    }

    /**
     * Main render function - 3-pass rendering matching VB6 RenderScreen.
     * VB6: Graphics.bas:336
     *
     * Renders (VIEWPORT + 2*SCREEN_BUFFER) tiles in each dimension into the canvas,
     * offset by the screen buffer amount so the viewport region is centered.
     * Canvas clipping restricts visible output to the viewport rectangle,
     * matching VB6's DrawBackBufferSurface crop blit (Graphics.bas:228).
     *
     * Camera model (VB6):
     *   TileX/Y = UserPos - AddtoUserPos = OLD tile position during movement
     *   PixelOffsetX/Y = OffsetCounter = accumulates from 0 toward ±32
     *   All tiles rendered at PixelPos(ScreenX) + PixelOffsetX
     *   The screen buffer overdraw ensures no black edges during scrolling
     */
    function render() {
        if (!mapData || !dataLoaded) return;

        // Clip to viewport - everything outside is overdraw buffer
        // VB6: DrawBackBufferSurface crops the back buffer to the viewport rect
        ctx.save();
        ctx.beginPath();
        ctx.rect(0, 0, VIEWPORT_W * TILE_SIZE, VIEWPORT_H * TILE_SIZE);
        ctx.clip();

        ctx.fillStyle = '#000';
        ctx.fillRect(0, 0, canvas.width, canvas.height);

        // Camera tile and pixel offset
        // VB6: RenderScreen(UserPos.x - AddtoUserPos.x, UserPos.y - AddtoUserPos.y, OffsetCounterX, OffsetCounterY)
        const tileX = camTileX;
        const tileY = camTileY;
        const pixOffX = screenOffsetX;
        const pixOffY = screenOffsetY;

        // Tile range with screen buffer overdraw
        // VB6: minX = (TileX - (XWindow \ 2)) - screenbuffer
        const halfW = Math.floor(VIEWPORT_W / 2);
        const halfH = Math.floor(VIEWPORT_H / 2);
        const minX = tileX - halfW - SCREEN_BUFFER;
        const maxX = tileX + halfW + SCREEN_BUFFER;
        const minY = tileY - halfH - SCREEN_BUFFER;
        const maxY = tileY + halfH + SCREEN_BUFFER;

        // ScreenX/Y: counter from 0..(range). PixelPos(s) = s * TILE_SIZE - TILE_SIZE
        // Offset so that the screen buffer region draws at negative coords (off-viewport).
        // VB6: PixelPos(ScreenX) = TileSizeX * ScreenX - TileSizeX
        // VB6: DrawBackBufferSurface source rect starts at (screenbuffer * TileSize - TileSize)
        // Net effect: tile at ScreenX=SCREEN_BUFFER draws at pixel 0 minus one tile width,
        // and the crop starts one tile before the buffer edge.
        //
        // We replicate this by computing screen position as:
        //   px = (screenX - SCREEN_BUFFER) * TILE_SIZE + pixOffX
        // where screenX=SCREEN_BUFFER corresponds to the left edge of the viewport (pixel 0).

        const tickedAnims = new Set();

        // Pass 1: Ground layer (opaque)
        for (let y = minY; y <= maxY; y++) {
            for (let x = minX; x <= maxX; x++) {
                if (x < 1 || x > 100 || y < 1 || y > 100) continue;
                const idx = (y - 1) * 100 + (x - 1);
                const grhIndex = mapData.tiles.layer1[idx];
                if (grhIndex > 0) {
                    const sx = x - (tileX - halfW);
                    const sy = y - (tileY - halfH);
                    const px = sx * TILE_SIZE + pixOffX;
                    const py = sy * TILE_SIZE + pixOffY;
                    drawGrh(grhIndex, px, py, false, null);

                    if (!tickedAnims.has(grhIndex)) {
                        tickTileAnim(grhIndex);
                        tickedAnims.add(grhIndex);
                    }
                }
            }
        }

        // Pass 2: Fringe layer + characters (transparent, centered)
        for (let y = minY; y <= maxY; y++) {
            for (let x = minX; x <= maxX; x++) {
                if (x < 1 || x > 100 || y < 1 || y > 100) continue;
                const idx = (y - 1) * 100 + (x - 1);

                const sx = x - (tileX - halfW);
                const sy = y - (tileY - halfH);
                const px = sx * TILE_SIZE + pixOffX;
                const py = sy * TILE_SIZE + pixOffY;

                // Layer 2 (fringe)
                const grh2 = mapData.tiles.layer2[idx];
                if (grh2 > 0) {
                    drawGrh(grh2, px, py, true, null);

                    if (!tickedAnims.has(grh2)) {
                        tickTileAnim(grh2);
                        tickedAnims.add(grh2);
                    }
                }

                // Characters at this tile position
                for (const ch of characters) {
                    if (ch.x === x && ch.y === y) {
                        // Character pixel offset from their own movement interpolation
                        // VB6: PixelOffsetXTemp = PixelOffsetX + TempChar.MoveOffset.x
                        // The camera pixel offset (pixOffX/Y) is already baked into px/py.
                        // For the player, MoveOffset mirrors the camera scroll, so they cancel
                        // and the player stays centered. For NPCs, MoveOffset slides them
                        // independently of the camera.
                        const chPx = px + ch.moveOffsetX;
                        const chPy = py + ch.moveOffsetY;
                        drawCharacter(ch, chPx, chPy);
                    }
                }
            }
        }

        ctx.restore(); // remove clipping
    }

    /**
     * Draw a character composited from head + body + shield + weapon.
     * VB6: RenderScreen character layer (Graphics.bas:432-484)
     */
    function drawCharacter(ch, screenX, screenY) {
        const body = bodyDefs[ch.bodyId];
        const head = headDefs[ch.headId];
        const weapon = weaponAnimDefs[ch.weaponAnim];
        const shield = shieldAnimDefs[ch.shieldAnim];

        const hi = (ch.heading || SOUTH) - 1;
        const walkAnim = ch.walkAnims ? ch.walkAnims[hi] : null;

        // Draw head (not animated)
        if (head && head.grh && head.grh[hi]) {
            const headOffX = body ? body.headOffsetX : 0;
            const headOffY = body ? body.headOffsetY : 0;
            drawGrh(head.grh[hi], screenX + headOffX, screenY + headOffY, true, null);
        }

        // Draw body (animated during walk)
        if (body && body.walk && body.walk[hi]) {
            drawGrh(body.walk[hi], screenX, screenY, true, walkAnim);
        }

        // Draw shield (animated during walk)
        if (shield && shield.walk && shield.walk[hi]) {
            drawGrh(shield.walk[hi], screenX, screenY, true, walkAnim);
        }

        // Draw weapon (animated during walk)
        if (weapon && weapon.walk && weapon.walk[hi]) {
            drawGrh(weapon.walk[hi], screenX, screenY, true, walkAnim);
        }
    }

    /**
     * Main loop: process input, update state, render.
     * VB6: Main game loop (General.bas:1121-1193)
     *
     * Frame-limited to TARGET_FPS (30fps).
     */
    function renderLoop(timestamp) {
        requestAnimationFrame(renderLoop);

        // Frame limiter
        const elapsed = timestamp - lastFrameTime;
        if (elapsed < FRAME_TIME) return;
        lastFrameTime = timestamp - (elapsed % FRAME_TIME);

        // Process input
        processPlayerInput();

        // Update patrol NPC AI
        updatePatrolNpc();

        // Update screen scrolling (camera)
        // VB6: main loop OffsetCounter interpolation (General.bas:1139-1164)
        updateScreenScroll();

        // Update character movement interpolation
        for (const ch of characters) {
            updateMovement(ch);
            tickCharAnim(ch);
        }

        // Render
        render();

        // FPS counter
        frameCount++;
        if (timestamp - lastFpsUpdate >= 1000) {
            currentFps = frameCount;
            frameCount = 0;
            lastFpsUpdate = timestamp;
            if (fpsEl) fpsEl.textContent = `${currentFps} FPS`;
        }
    }

    // Public API
    return { init };
})();
