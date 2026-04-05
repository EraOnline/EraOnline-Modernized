/**
 * Era Online Renderer
 *
 * Faithful port of the VB6 DirectDraw rendering pipeline (Graphics.bas).
 * 3-pass rendering: ground tiles -> fringe/objects/characters -> (weather).
 * Sprite system based on the Grh (Graphic) atlas from Grh.dat.
 *
 * VB6 reference functions:
 *   RenderScreen (Graphics.bas:336)      - main 3-pass render
 *   DDrawGrhtoSurface (Graphics.bas:76)  - opaque sprite blit with animation
 *   DDrawTransGrhtoSurface (Graphics.bas:151) - transparent blit with animation
 *   InitGrh (General.bas:614)            - animation setup
 *   MakeChar (General.bas:341)           - character compositing setup
 *   CheckMoveKeys (General.bas:395)      - keyboard movement input
 *   MoveScreen (General.bas:701)         - start screen scrolling
 *   MoveCharbyHead (General.bas:649)     - start character move interpolation
 *   Main game loop (General.bas:1121)    - 8px/frame offset interpolation
 */
const EraRenderer = (() => {
    // Constants matching VB6 Declarations.bas
    const TILE_SIZE = 32;
    const VIEWPORT_W = 20; // tiles
    const VIEWPORT_H = 11; // tiles
    const MOVE_SPEED = 8;  // pixels per frame for movement interpolation
    const TARGET_FPS = 30; // VB6 original capped at 30fps (General.bas:1136)
    const FRAME_TIME = 1000 / TARGET_FPS; // ~33.3ms per frame

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
    let lastFrameTime = 0;  // timestamp of last game tick
    let frameCount = 0;     // frames rendered since last FPS update
    let lastFpsUpdate = 0;  // timestamp of last FPS display update
    let currentFps = 0;     // displayed FPS value

    // --- Animation State ---
    // Per-tile animation instances: key = grhIndex, value = { frameCounter, speedCounter }
    // VB6 stores these per-tile in MapData(x,y).graphic(n) as Grh structs.
    // We share animation state per unique grhIndex since all tiles with the same
    // animation should tick in sync (matching VB6 behavior where they all tick each frame).
    let tileAnimState = {};

    // --- Characters ---
    let characters = []; // { x, y, bodyId, headId, heading, weaponAnim, shieldAnim, moveOffsetX, moveOffsetY, moving, walkAnims }

    // --- Player ---
    let player = null;  // The local test player character
    let keysDown = {};  // Currently held keys

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
        // Castlefall spawn from config: (59, 41)
        let spawnX = 59, spawnY = 41;
        if (configData && configData.startingCities) {
            const castlefall = configData.startingCities.find(c => c.map === 81);
            if (castlefall) {
                spawnX = castlefall.x;
                spawnY = castlefall.y;
            }
        }

        // Human male: body 1, random head 6-15, facing south
        const headId = 6 + Math.floor(Math.random() * 10);
        player = makeCharacter(spawnX, spawnY, 1, headId, SOUTH, 2, 2);

        // Add to characters list so they render
        characters.push(player);

        setStatus(`Test player created at (${spawnX}, ${spawnY})`);
    }

    function makeCharacter(x, y, bodyId, headId, heading, weaponAnim, shieldAnim) {
        // VB6: MakeChar (General.bas:341) + InitGrh for each walk animation
        const ch = {
            x, y,
            bodyId, headId, heading,
            weaponAnim, shieldAnim,
            moveOffsetX: 0,
            moveOffsetY: 0,
            moving: false,
            // Per-character walk animation state for body/weapon/shield
            // Each direction has { frameCounter, speedCounter, started }
            walkAnims: {}
        };
        initCharAnims(ch);
        return ch;
    }

    function initCharAnims(ch) {
        // Initialize walk animation state for each direction
        // VB6: InitGrh sets FrameCounter=1, SpeedCounter=Speed, Started based on NumFrames
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

        // Prevent scrolling
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
     * Only allow new movement when not already moving (interpolation complete).
     */
    function processPlayerInput() {
        if (!player || player.moving) return;

        let heading = 0;
        let dx = 0, dy = 0;

        if (keysDown['ArrowUp']) { heading = NORTH; dy = -1; }
        else if (keysDown['ArrowDown']) { heading = SOUTH; dy = 1; }
        else if (keysDown['ArrowLeft']) { heading = WEST; dx = -1; }
        else if (keysDown['ArrowRight']) { heading = EAST; dx = 1; }

        if (heading === 0) return;

        // Always update facing direction
        player.heading = heading;

        // Check if target tile is legal
        const newX = player.x + dx;
        const newY = player.y + dy;

        if (!isLegalPos(newX, newY)) return;

        // VB6: MoveCharbyHead - update position immediately, set MoveOffset to interpolate FROM
        // The character is logically at the new tile, but visually slides from the old one
        player.x = newX;
        player.y = newY;
        player.moveOffsetX = -dx * TILE_SIZE; // negative because we interpolate toward 0
        player.moveOffsetY = -dy * TILE_SIZE;
        player.moving = true;

        updateStatus();
    }

    /**
     * Check if a tile position is walkable.
     * VB6: LegalPos (General.bas:1299)
     */
    function isLegalPos(x, y) {
        if (x < 1 || x > 100 || y < 1 || y > 100) return false;

        // Check blocked
        if (mapData) {
            const idx = (y - 1) * 100 + (x - 1);
            if (mapData.tiles.blocked[idx] === 1) return false;
        }

        // Check for NPC/character on tile (skip player's own tile)
        for (const ch of characters) {
            if (ch === player) continue;
            if (ch.x === x && ch.y === y) return false;
        }

        return true;
    }

    /**
     * Update character movement interpolation.
     * VB6: Main game loop (General.bas:1139-1164) for player,
     *      RenderScreen (Graphics.bas:441-471) for all characters.
     *
     * Each frame, move 8px toward the target (offset -> 0).
     * When offset reaches 0, movement is complete.
     */
    function updateMovement(ch) {
        if (!ch.moving) return;

        let stillMoving = false;

        // Interpolate X: reduce offset toward 0 by MOVE_SPEED per frame
        if (ch.moveOffsetX !== 0) {
            if (Math.abs(ch.moveOffsetX) <= MOVE_SPEED) {
                ch.moveOffsetX = 0;
            } else {
                ch.moveOffsetX -= MOVE_SPEED * Math.sign(ch.moveOffsetX);
            }
            if (ch.moveOffsetX !== 0) stillMoving = true;
        }

        // Interpolate Y
        if (ch.moveOffsetY !== 0) {
            if (Math.abs(ch.moveOffsetY) <= MOVE_SPEED) {
                ch.moveOffsetY = 0;
            } else {
                ch.moveOffsetY -= MOVE_SPEED * Math.sign(ch.moveOffsetY);
            }
            if (ch.moveOffsetY !== 0) stillMoving = true;
        }

        if (!stillMoving) {
            // Movement complete
            ch.moving = false;
            ch.moveOffsetX = 0;
            ch.moveOffsetY = 0;

            // VB6: Reset walk animation to frame 1, stop it
            const hi = (ch.heading || SOUTH) - 1;
            if (ch.walkAnims[hi]) {
                ch.walkAnims[hi].frameCounter = 0;
                ch.walkAnims[hi].started = false;
            }
        } else {
            // Still moving - enable walk animation
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

        // Reset tile animation state for new map
        tileAnimState = {};

        // Place NPCs from spawn data
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
                    2, 2 // no weapon/shield
                ));
            }
        }

        // Re-add player if they exist
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

    /**
     * Get or create tile animation state for a given GRH index.
     * VB6: Each MapData(x,y).graphic(n) is a Grh struct with its own counters.
     * We share state per GRH index so all tiles of the same type animate in sync.
     */
    function getTileAnimState(grhIndex) {
        if (!tileAnimState[grhIndex]) {
            const entry = grhEntries[grhIndex];
            tileAnimState[grhIndex] = {
                frameCounter: 0, // 0-based (VB6 is 1-based, we adjust)
                speedCounter: entry ? (entry.speed || 1) : 1
            };
        }
        return tileAnimState[grhIndex];
    }

    /**
     * Advance tile animation by one tick.
     * VB6: DDrawGrhtoSurface lines 96-108
     * SpeedCounter counts down each render frame. When it hits 0,
     * advance to next frame and reset counter.
     */
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

    /**
     * Advance character walk animation by one tick.
     * Same counter logic as tile animations.
     */
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

    /**
     * Resolve a GRH index to the concrete sprite to draw.
     * For static sprites, returns the entry directly.
     * For animations, returns the current frame based on animation state.
     *
     * @param grhIndex - The GRH index to resolve
     * @param animState - Animation state object { frameCounter }, or null for tile lookup
     */
    function resolveGrh(grhIndex, animState) {
        const entry = grhEntries[grhIndex];
        if (!entry) return null;

        if (entry.frames && entry.frames.length > 0) {
            // Animated - pick current frame
            let frameIdx;
            if (animState) {
                frameIdx = animState.frameCounter % entry.frames.length;
            } else {
                // Use shared tile animation state
                const tState = getTileAnimState(grhIndex);
                frameIdx = tState.frameCounter % entry.frames.length;
            }
            return grhEntries[entry.frames[frameIdx]] || null;
        }
        return entry;
    }

    /**
     * Draw a sprite at pixel position (px, py).
     * VB6: DDrawGrhtoSurface / DDrawTransGrhtoSurface
     */
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

        // Center multi-tile sprites over their tile position
        // VB6: x = x - Int(TileWidth * 16) + 16, y = y - Int(TileHeight * 32) + 32
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
     * Camera follows the player with pixel-level interpolation.
     * VB6: RenderScreen(UserPos.x - AddtoUserPos.x, UserPos.y - AddtoUserPos.y, OffsetCounterX, OffsetCounterY)
     */
    function render() {
        if (!mapData || !dataLoaded) return;

        ctx.fillStyle = '#000';
        ctx.fillRect(0, 0, canvas.width, canvas.height);

        // Camera centers on player position
        let camTileX, camTileY, pixelOffsetX, pixelOffsetY;
        if (player) {
            camTileX = player.x;
            camTileY = player.y;
            pixelOffsetX = player.moveOffsetX;
            pixelOffsetY = player.moveOffsetY;
        } else {
            camTileX = 50;
            camTileY = 50;
            pixelOffsetX = 0;
            pixelOffsetY = 0;
        }

        const halfW = Math.floor(VIEWPORT_W / 2);
        const halfH = Math.floor(VIEWPORT_H / 2);
        const minX = camTileX - halfW;
        const minY = camTileY - halfH;
        const maxX = camTileX + halfW;
        const maxY = camTileY + halfH;

        // Track which tile animations we've ticked this frame (tick once per frame, not per tile instance)
        const tickedAnims = new Set();

        // Pass 1: Ground layer (opaque)
        // VB6: DDrawGrhtoSurface with Animate=1
        for (let y = minY; y <= maxY; y++) {
            for (let x = minX; x <= maxX; x++) {
                if (x < 1 || x > 100 || y < 1 || y > 100) continue;
                const idx = (y - 1) * 100 + (x - 1);
                const grhIndex = mapData.tiles.layer1[idx];
                if (grhIndex > 0) {
                    const screenX = (x - minX) * TILE_SIZE + pixelOffsetX;
                    const screenY = (y - minY) * TILE_SIZE + pixelOffsetY;
                    drawGrh(grhIndex, screenX, screenY, false, null);

                    // Tick animation once per unique grhIndex per frame
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
                const screenX = (x - minX) * TILE_SIZE + pixelOffsetX;
                const screenY = (y - minY) * TILE_SIZE + pixelOffsetY;

                // Layer 2 (fringe - trees, buildings, walls)
                const grh2 = mapData.tiles.layer2[idx];
                if (grh2 > 0) {
                    drawGrh(grh2, screenX, screenY, true, null);

                    if (!tickedAnims.has(grh2)) {
                        tickTileAnim(grh2);
                        tickedAnims.add(grh2);
                    }
                }

                // Characters at this tile position
                for (const ch of characters) {
                    if (ch.x === x && ch.y === y) {
                        // Character screen position includes their own move offset
                        // but NOT the camera offset (that's already in screenX/Y via pixelOffsetX/Y)
                        // However, the player's own move offset IS the camera offset,
                        // so for the player we don't add it again.
                        let chOffX = 0, chOffY = 0;
                        if (ch !== player) {
                            chOffX = ch.moveOffsetX;
                            chOffY = ch.moveOffsetY;
                        }
                        drawCharacter(ch, screenX + chOffX, screenY + chOffY);
                    }
                }
            }
        }
    }

    /**
     * Draw a character composited from head + body + shield + weapon.
     * VB6: RenderScreen character layer (Graphics.bas:432-484)
     *
     * Head: drawn with Animate=0 (heads don't animate)
     * Body/Shield/Weapon: drawn with Animate=1 (walk cycles)
     */
    function drawCharacter(ch, screenX, screenY) {
        const body = bodyDefs[ch.bodyId];
        const head = headDefs[ch.headId];
        const weapon = weaponAnimDefs[ch.weaponAnim];
        const shield = shieldAnimDefs[ch.shieldAnim];

        // heading index: VB6 uses 1-4 (N,E,S,W), our arrays are 0-3
        const hi = (ch.heading || SOUTH) - 1;

        // Get walk animation state for current heading
        const walkAnim = ch.walkAnims ? ch.walkAnims[hi] : null;

        // Draw head (not animated - VB6 passes Animate=0 for heads)
        if (head && head.grh && head.grh[hi]) {
            const headOffX = body ? body.headOffsetX : 0;
            const headOffY = body ? body.headOffsetY : 0;
            // Pass null animState for head (static, always first frame)
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
     * Frame-limited to TARGET_FPS. The VB6 original caps at 30fps:
     *   If FramesPerSec <= 30 Then  (General.bas:1136)
     * All animation counters and movement speeds are calibrated for this rate.
     */
    function renderLoop(timestamp) {
        requestAnimationFrame(renderLoop);

        // Frame limiter: skip if not enough time has elapsed
        const elapsed = timestamp - lastFrameTime;
        if (elapsed < FRAME_TIME) return;
        lastFrameTime = timestamp - (elapsed % FRAME_TIME); // preserve remainder for accuracy

        // Process input
        processPlayerInput();

        // Update movement interpolation for all characters
        for (const ch of characters) {
            updateMovement(ch);
            tickCharAnim(ch);
        }

        // Render
        render();

        // FPS counter - update once per second
        // VB6: FPSTimer with Interval=1000
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
