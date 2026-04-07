/**
 * Era Online Renderer
 *
 * Faithful port of the VB6 DirectDraw rendering pipeline (Graphics.bas).
 * 3-pass rendering: ground tiles -> fringe/objects/characters -> (weather).
 * Sprite system based on the Grh (Graphic) atlas from Grh.dat.
 *
 * The renderer is "dumb" about networking - it receives character state from
 * client.js and renders it. Movement input is forwarded via a callback.
 */
const EraRenderer = (() => {
    // Constants matching VB6 Declarations.bas
    const TILE_SIZE = 32;
    const VIEWPORT_W = 20;
    const VIEWPORT_H = 11;
    const MOVE_SPEED = 8;
    const TARGET_FPS = 30;
    const FRAME_TIME = 1000 / TARGET_FPS;
    const SCREEN_BUFFER = 2;

    const NORTH = 1, EAST = 2, SOUTH = 3, WEST = 4;

    // State
    let canvas, ctx;
    let dataBasePath = '/data';
    let grhEntries = {};
    let spriteSheets = {};
    let loadingSheets = new Set();
    let mapData = null;
    let npcDefs = [];
    let bodyDefs = {};
    let headDefs = {};
    let weaponAnimDefs = {};
    let shieldAnimDefs = {};
    let dataLoaded = false;
    let fpsEl = null;

    // Dynamic ground objects: { "x,y": grhIndex } — set by MakeObj, cleared by EraseObj
    let groundObjects = {};

    // Frame timing
    let lastFrameTime = 0;
    let frameCount = 0;
    let lastFpsUpdate = 0;
    let currentFps = 0;

    // Camera (VB6 model)
    let camTileX = 50;
    let camTileY = 50;
    let screenOffsetX = 0;
    let screenOffsetY = 0;
    let addToUserPosX = 0;
    let addToUserPosY = 0;
    let userMoving = false;

    // Tile animations
    let tileAnimState = {};

    // Characters indexed by charIndex
    let characters = {};  // charIndex -> character object
    let myCharIndex = null;
    let moveCallback = null;   // function(direction)
    let statusCallback = null; // function(msg)
    let mapNameCallback = null; // function(name)

    let keysDown = {};

    function setStatus(msg) {
        if (statusCallback) statusCallback(msg);
        console.log('[EraRenderer] ' + msg);
    }

    async function init(canvasId, basePath) {
        canvas = document.getElementById(canvasId);
        ctx = canvas.getContext('2d');
        dataBasePath = basePath || '/data';

        canvas.width = VIEWPORT_W * TILE_SIZE;
        canvas.height = VIEWPORT_H * TILE_SIZE;
        ctx.imageSmoothingEnabled = false;
        fpsEl = document.getElementById('fps');

        setStatus('Loading sprite definitions...');
        await loadGrhData();

        setStatus('Loading sprite data...');
        await loadSpriteDefs();

        setStatus('Loading sprite sheets...');
        // Sheets will be loaded on demand as maps load

        dataLoaded = true;
        setStatus('Connected');

        document.addEventListener('keydown', onKeyDown);
        document.addEventListener('keyup', onKeyUp);
        canvas.addEventListener('click', onCanvasClick);

        requestAnimationFrame(renderLoop);
    }

    // --- Public API (called by client.js) ---

    function setMoveCallback(cb) { moveCallback = cb; }
    function setStatusCallback(cb) { statusCallback = cb; }
    function setMapNameCallback(cb) { mapNameCallback = cb; }
    let clickCallback = null;
    function setClickCallback(cb) { clickCallback = cb; }

    function setMyCharIndex(idx) { myCharIndex = idx; }

    async function loadMapFromServer(mapId) {
        setStatus('Loading map ' + mapId + '...');
        // Clear old map's characters and ground objects — new ones will arrive via MakeChar/MakeObj
        characters = {};
        groundObjects = {};
        const padded = String(mapId).padStart(3, '0');
        const resp = await fetch(`${dataBasePath}/maps/map-${padded}.json`);
        mapData = await resp.json();
        tileAnimState = {};
        await preloadVisibleSheets();
        if (mapNameCallback) mapNameCallback(mapData.name || `Map ${mapId}`);
        setStatus(`Map ${mapId} loaded`);
    }

    function addCharacter(charIndex, name, bodyId, headId, heading, x, y, weaponAnim, shieldAnim) {
        const ch = makeCharacter(x, y, bodyId, headId, heading, weaponAnim, shieldAnim);
        ch.charIndex = charIndex;
        ch.name = name;
        characters[charIndex] = ch;

        // If this is us, center camera
        if (charIndex === myCharIndex) {
            camTileX = x;
            camTileY = y;
            screenOffsetX = 0;
            screenOffsetY = 0;
            userMoving = false;
            addToUserPosX = 0;
            addToUserPosY = 0;
            updateStatus();
        }

        // Preload sprite sheets for this character
        const sheetsNeeded = new Set();
        collectCharSheets(ch, sheetsNeeded);
        for (const fileNum of sheetsNeeded) {
            loadSpriteSheet(fileNum);
        }
    }

    function removeCharacter(charIndex) {
        delete characters[charIndex];
    }

    // VB6: MOB — place an object sprite on a tile
    function makeGroundObj(grhIndex, x, y) {
        if (grhIndex > 0) {
            groundObjects[`${x},${y}`] = grhIndex;
        }
    }

    // VB6: EOB — remove an object sprite from a tile
    function eraseGroundObj(x, y) {
        delete groundObjects[`${x},${y}`];
    }

    function moveCharacter(charIndex, newX, newY, heading) {
        const ch = characters[charIndex];
        if (!ch) return;

        const dx = newX - ch.x;
        const dy = newY - ch.y;

        ch.x = newX;
        ch.y = newY;
        ch.heading = heading;
        ch.moveOffsetX = -dx * TILE_SIZE;
        ch.moveOffsetY = -dy * TILE_SIZE;
        ch.moving = true;

        // If this is us, start camera scroll
        if (charIndex === myCharIndex) {
            addToUserPosX = dx;
            addToUserPosY = dy;
            screenOffsetX = 0;
            screenOffsetY = 0;
            userMoving = true;
        }
    }

    function setPlayerPosition(x, y) {
        // Server position correction
        const ch = characters[myCharIndex];
        if (!ch) return;
        ch.x = x;
        ch.y = y;
        ch.moveOffsetX = 0;
        ch.moveOffsetY = 0;
        ch.moving = false;
        camTileX = x;
        camTileY = y;
        screenOffsetX = 0;
        screenOffsetY = 0;
        userMoving = false;
        addToUserPosX = 0;
        addToUserPosY = 0;
        updateStatus();
    }

    // --- Character helpers ---

    function makeCharacter(x, y, bodyId, headId, heading, weaponAnim, shieldAnim) {
        const ch = {
            x, y,
            bodyId, headId, heading,
            weaponAnim, shieldAnim,
            moveOffsetX: 0,
            moveOffsetY: 0,
            moving: false,
            walkAnims: {},
            charIndex: 0,
            name: ''
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

    // --- Input ---

    function onKeyDown(e) {
        keysDown[e.key] = true;
        if (['ArrowUp', 'ArrowDown', 'ArrowLeft', 'ArrowRight'].includes(e.key)) {
            e.preventDefault();
        }
    }

    function onKeyUp(e) {
        delete keysDown[e.key];
    }

    function onCanvasClick(e) {
        // VB6: ConvertCPtoTP — convert canvas pixel coords to map tile coords
        if (!mapData || !myCharIndex) return;
        const rect = canvas.getBoundingClientRect();
        const px = e.clientX - rect.left;
        const py = e.clientY - rect.top;

        const halfW = Math.floor(VIEWPORT_W / 2);
        const halfH = Math.floor(VIEWPORT_H / 2);
        const tileX = Math.floor((px - screenOffsetX) / TILE_SIZE) + (camTileX - halfW);
        const tileY = Math.floor((py - screenOffsetY) / TILE_SIZE) + (camTileY - halfH);

        if (tileX >= 1 && tileX <= 100 && tileY >= 1 && tileY <= 100) {
            if (clickCallback) clickCallback(tileX, tileY);
        }
    }

    function processPlayerInput() {
        if (!myCharIndex || userMoving) return;
        const me = characters[myCharIndex];
        if (!me || me.moving) return;

        let direction = 0;
        if (keysDown['ArrowUp']) direction = NORTH;
        else if (keysDown['ArrowDown']) direction = SOUTH;
        else if (keysDown['ArrowLeft']) direction = WEST;
        else if (keysDown['ArrowRight']) direction = EAST;

        if (direction === 0) return;

        // Send to server via callback - server will validate and send MoveChar back
        if (moveCallback) moveCallback(direction);
    }

    // --- Camera scroll ---

    function updateScreenScroll() {
        if (!userMoving) return;

        let done = true;

        if (addToUserPosX !== 0) {
            screenOffsetX -= MOVE_SPEED * Math.sign(addToUserPosX);
            if (Math.abs(screenOffsetX) >= TILE_SIZE) {
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
            updateStatus();
        }
    }

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
        if (!myCharIndex || !mapData) return;
        const me = characters[myCharIndex];
        if (!me) return;
        setStatus(`Map ${mapData.id} | ${me.name} (${me.x}, ${me.y})`);
    }

    // --- Data Loading ---

    async function loadGrhData() {
        const resp = await fetch(`${dataBasePath}/grh.json`);
        const data = await resp.json();
        for (const [key, entry] of Object.entries(data.entries)) {
            grhEntries[parseInt(key)] = entry;
        }
    }

    async function loadSpriteDefs() {
        const [heads, bodies, weapons, shields, npcs] = await Promise.all([
            fetch(`${dataBasePath}/heads.json`).then(r => r.json()),
            fetch(`${dataBasePath}/bodies.json`).then(r => r.json()),
            fetch(`${dataBasePath}/weapon-anims.json`).then(r => r.json()),
            fetch(`${dataBasePath}/shield-anims.json`).then(r => r.json()),
            fetch(`${dataBasePath}/npcs.json`).then(r => r.json()),
        ]);

        for (const h of heads) headDefs[h.id] = h;
        for (const b of bodies) bodyDefs[b.id] = b;
        for (const w of weapons) weaponAnimDefs[w.id] = w;
        for (const s of shields) shieldAnimDefs[s.id] = s;
        npcDefs = npcs;
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
                if (grhIndex > 0) collectSheetFiles(grhIndex, sheetsNeeded);
            }
        }

        for (const ch of Object.values(characters)) {
            collectCharSheets(ch, sheetsNeeded);
        }

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
        if (!sheet) { loadSpriteSheet(sprite.file); return; }
        let dx = px, dy = py;
        if (center) {
            const tw = sprite.w / TILE_SIZE;
            const th = sprite.h / TILE_SIZE;
            if (tw !== 1) dx -= (tw * 16) - 16;
            if (th !== 1) dy -= (th * 32) - 32;
        }
        ctx.drawImage(sheet, sprite.x, sprite.y, sprite.w, sprite.h, dx, dy, sprite.w, sprite.h);
    }

    function render() {
        if (!mapData || !dataLoaded) return;

        ctx.save();
        ctx.beginPath();
        ctx.rect(0, 0, VIEWPORT_W * TILE_SIZE, VIEWPORT_H * TILE_SIZE);
        ctx.clip();

        ctx.fillStyle = '#000';
        ctx.fillRect(0, 0, canvas.width, canvas.height);

        const tileX = camTileX;
        const tileY = camTileY;
        const pixOffX = screenOffsetX;
        const pixOffY = screenOffsetY;

        const halfW = Math.floor(VIEWPORT_W / 2);
        const halfH = Math.floor(VIEWPORT_H / 2);
        const minX = tileX - halfW - SCREEN_BUFFER;
        const maxX = tileX + halfW + SCREEN_BUFFER;
        const minY = tileY - halfH - SCREEN_BUFFER;
        const maxY = tileY + halfH + SCREEN_BUFFER;

        const tickedAnims = new Set();

        // Pass 1: Ground layer
        for (let y = minY; y <= maxY; y++) {
            for (let x = minX; x <= maxX; x++) {
                if (x < 1 || x > 100 || y < 1 || y > 100) continue;
                const idx = (y - 1) * 100 + (x - 1);
                const grhIndex = mapData.tiles.layer1[idx];
                if (grhIndex > 0) {
                    const sx = x - (tileX - halfW);
                    const sy = y - (tileY - halfH);
                    drawGrh(grhIndex, sx * TILE_SIZE + pixOffX, sy * TILE_SIZE + pixOffY, false, null);
                    if (!tickedAnims.has(grhIndex)) {
                        tickTileAnim(grhIndex);
                        tickedAnims.add(grhIndex);
                    }
                }
            }
        }

        // Pass 2: Fringe + characters
        for (let y = minY; y <= maxY; y++) {
            for (let x = minX; x <= maxX; x++) {
                if (x < 1 || x > 100 || y < 1 || y > 100) continue;
                const idx = (y - 1) * 100 + (x - 1);
                const sx = x - (tileX - halfW);
                const sy = y - (tileY - halfH);
                const px = sx * TILE_SIZE + pixOffX;
                const py = sy * TILE_SIZE + pixOffY;

                const grh2 = mapData.tiles.layer2[idx];
                if (grh2 > 0) {
                    drawGrh(grh2, px, py, true, null);
                    if (!tickedAnims.has(grh2)) {
                        tickTileAnim(grh2);
                        tickedAnims.add(grh2);
                    }
                }

                // VB6: Object layer — dynamic ground items between fringe and characters
                const objGrh = groundObjects[`${x},${y}`];
                if (objGrh > 0) {
                    drawGrh(objGrh, px, py, true, null);
                }

                // Characters at this tile
                for (const ch of Object.values(characters)) {
                    if (ch.x === x && ch.y === y) {
                        drawCharacter(ch, px + ch.moveOffsetX, py + ch.moveOffsetY);
                    }
                }
            }
        }

        ctx.restore();
    }

    function drawCharacter(ch, screenX, screenY) {
        const body = bodyDefs[ch.bodyId];
        const head = headDefs[ch.headId];
        const weapon = weaponAnimDefs[ch.weaponAnim];
        const shield = shieldAnimDefs[ch.shieldAnim];
        const hi = (ch.heading || SOUTH) - 1;
        const walkAnim = ch.walkAnims ? ch.walkAnims[hi] : null;

        if (head && head.grh && head.grh[hi]) {
            const headOffX = body ? body.headOffsetX : 0;
            const headOffY = body ? body.headOffsetY : 0;
            drawGrh(head.grh[hi], screenX + headOffX, screenY + headOffY, true, null);
        }
        if (body && body.walk && body.walk[hi]) {
            drawGrh(body.walk[hi], screenX, screenY, true, walkAnim);
        }
        if (shield && shield.walk && shield.walk[hi]) {
            drawGrh(shield.walk[hi], screenX, screenY, true, walkAnim);
        }
        if (weapon && weapon.walk && weapon.walk[hi]) {
            drawGrh(weapon.walk[hi], screenX, screenY, true, walkAnim);
        }
    }

    function renderLoop(timestamp) {
        requestAnimationFrame(renderLoop);

        const elapsed = timestamp - lastFrameTime;
        if (elapsed < FRAME_TIME) return;
        lastFrameTime = timestamp - (elapsed % FRAME_TIME);

        processPlayerInput();
        updateScreenScroll();

        for (const ch of Object.values(characters)) {
            updateMovement(ch);
            tickCharAnim(ch);
        }

        render();

        frameCount++;
        if (timestamp - lastFpsUpdate >= 1000) {
            currentFps = frameCount;
            frameCount = 0;
            lastFpsUpdate = timestamp;
            if (fpsEl) fpsEl.textContent = `${currentFps} FPS`;
        }
    }

    return {
        init,
        setMoveCallback,
        setStatusCallback,
        setMapNameCallback,
        setClickCallback,
        setMyCharIndex,
        loadMapFromServer,
        addCharacter,
        removeCharacter,
        moveCharacter,
        setPlayerPosition,
        makeGroundObj,
        eraseGroundObj
    };
})();
