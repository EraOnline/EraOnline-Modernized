/**
 * Era Online Renderer
 *
 * Faithful port of the VB6 DirectDraw rendering pipeline (Graphics.bas).
 * 3-pass rendering: ground tiles -> fringe/objects -> characters.
 * Sprite system based on the Grh (Graphic) atlas from Grh.dat.
 *
 * VB6 reference functions:
 *   RenderScreen (Graphics.bas:336)      - main 3-pass render
 *   DDrawGrhtoSurface (Graphics.bas:76)  - opaque sprite blit
 *   DDrawTransGrhtoSurface (Graphics.bas:151) - transparent sprite blit
 *   InitGrh (General.bas:614)            - animation setup
 *   MakeChar (General.bas:341)           - character compositing setup
 */
const EraRenderer = (() => {
    // Constants matching VB6 Declarations.bas
    const TILE_SIZE = 32;
    const VIEWPORT_W = 20; // tiles
    const VIEWPORT_H = 11; // tiles
    const SCREEN_BUFFER = 10; // extra tiles drawn around viewport

    // State
    let canvas, ctx;
    let dataBasePath = '/data';
    let grhEntries = {};   // grhIndex -> { file, x, y, w, h } or { frames, speed }
    let spriteSheets = {}; // fileNum -> Image (loaded on demand)
    let loadingSheets = new Set(); // fileNums currently being loaded
    let mapData = null;    // current map JSON
    let npcDefs = [];      // NPC definitions for sprite lookup
    let bodyDefs = {};     // bodyId -> { walk: [N,E,S,W], headOffsetX, headOffsetY }
    let headDefs = {};     // headId -> { grh: [N,E,S,W] }
    let weaponAnimDefs = {}; // animId -> { walk: [N,E,S,W] }
    let shieldAnimDefs = {}; // animId -> { walk: [N,E,S,W] }
    let cameraX = 50;      // tile position of camera center
    let cameraY = 50;
    let dataLoaded = false;
    let statusEl = null;

    // Characters on the map (NPCs placed from spawn data)
    let characters = []; // { x, y, bodyId, headId, heading, weaponAnim, shieldAnim }

    function setStatus(msg) {
        if (statusEl) statusEl.textContent = msg;
        console.log('[EraRenderer] ' + msg);
    }

    async function init(canvasId, basePath) {
        canvas = document.getElementById(canvasId);
        ctx = canvas.getContext('2d');
        dataBasePath = basePath || '/data';
        statusEl = document.getElementById('loading');

        // Canvas size = viewport in pixels (no offset for Phase 2, keep it simple)
        canvas.width = VIEWPORT_W * TILE_SIZE;
        canvas.height = VIEWPORT_H * TILE_SIZE;

        ctx.imageSmoothingEnabled = false; // pixelated rendering

        setStatus('Loading sprite definitions...');
        await loadGrhData();

        setStatus('Loading sprite data...');
        await loadSpriteDefs();

        setStatus('Loading map...');
        await loadMap(81); // Castlefall

        setStatus('Loading sprite sheets...');
        await preloadVisibleSheets();

        dataLoaded = true;
        setStatus('Rendering...');

        // Start render loop
        requestAnimationFrame(renderLoop);
    }

    // --- Data Loading ---

    async function loadGrhData() {
        const resp = await fetch(`${dataBasePath}/grh.json`);
        const data = await resp.json();
        // Convert string keys to int
        for (const [key, entry] of Object.entries(data.entries)) {
            grhEntries[parseInt(key)] = entry;
        }
        setStatus(`Loaded ${Object.keys(grhEntries).length} sprite definitions`);
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

        setStatus(`Loaded ${heads.length} heads, ${bodies.length} bodies, ${weapons.length} weapon anims, ${shields.length} shield anims, ${npcs.length} NPCs`);
    }

    async function loadMap(mapId) {
        const padded = String(mapId).padStart(3, '0');
        const resp = await fetch(`${dataBasePath}/maps/map-${padded}.json`);
        mapData = await resp.json();

        // Place NPCs from spawn data
        characters = [];
        for (const spawn of mapData.npcSpawns) {
            const [x, y, npcTemplate] = spawn;
            const npc = npcDefs.find(n => n.id === npcTemplate);
            if (npc) {
                characters.push({
                    x, y,
                    bodyId: npc.body || 1,
                    headId: npc.head || 1,
                    heading: npc.heading || 3, // default south
                    weaponAnim: 2, // 2 = "no weapon" in the VB6 data
                    shieldAnim: 2  // 2 = "no shield"
                });
            }
        }

        // Set camera to Castlefall start position
        if (mapData.startPos) {
            cameraX = mapData.startPos[1];
            cameraY = mapData.startPos[2];
        }

        setStatus(`Loaded map ${mapId}: ${characters.length} NPCs placed`);
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
        // Find all sprite sheet files referenced by visible tiles
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

        // Also collect sheets for NPC body/head sprites
        for (const ch of characters) {
            collectCharSheets(ch, sheetsNeeded);
        }

        setStatus(`Preloading ${sheetsNeeded.size} sprite sheets...`);

        // Load all needed sheets
        const promises = [];
        for (const fileNum of sheetsNeeded) {
            if (!spriteSheets[fileNum]) {
                promises.push(new Promise(resolve => {
                    const img = new Image();
                    img.onload = () => { spriteSheets[fileNum] = img; resolve(); };
                    img.onerror = () => resolve(); // skip missing
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
            // Animation - collect sheets for all frames
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

    // --- Rendering ---

    /**
     * Resolve a GRH index to the concrete sprite to draw.
     * For single sprites, returns the entry directly.
     * For animations, returns the first frame (static rendering for Phase 2).
     */
    function resolveGrh(grhIndex) {
        const entry = grhEntries[grhIndex];
        if (!entry) return null;
        if (entry.frames && entry.frames.length > 0) {
            // Return first frame for static rendering
            return grhEntries[entry.frames[0]] || null;
        }
        return entry;
    }

    /**
     * Draw a sprite at pixel position (px, py).
     * center=true: offset multi-tile sprites to center over their tile.
     * VB6: DDrawGrhtoSurface / DDrawTransGrhtoSurface
     */
    function drawGrh(grhIndex, px, py, center) {
        const sprite = resolveGrh(grhIndex);
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
            sprite.x, sprite.y, sprite.w, sprite.h, // source rect
            dx, dy, sprite.w, sprite.h                // dest rect
        );
    }

    /**
     * Main render function - 3-pass rendering matching VB6 RenderScreen.
     * VB6: Graphics.bas:336
     */
    function render() {
        if (!mapData || !dataLoaded) return;

        // Clear
        ctx.fillStyle = '#000';
        ctx.fillRect(0, 0, canvas.width, canvas.height);

        const halfW = Math.floor(VIEWPORT_W / 2);
        const halfH = Math.floor(VIEWPORT_H / 2);
        const minX = cameraX - halfW;
        const minY = cameraY - halfH;
        const maxX = cameraX + halfW;
        const maxY = cameraY + halfH;

        // Pass 1: Ground layer (opaque)
        for (let y = minY; y <= maxY; y++) {
            for (let x = minX; x <= maxX; x++) {
                if (x < 1 || x > 100 || y < 1 || y > 100) continue;
                const idx = (y - 1) * 100 + (x - 1);
                const grhIndex = mapData.tiles.layer1[idx];
                if (grhIndex > 0) {
                    const screenX = (x - minX) * TILE_SIZE;
                    const screenY = (y - minY) * TILE_SIZE;
                    drawGrh(grhIndex, screenX, screenY, false);
                }
            }
        }

        // Pass 2: Fringe layer (transparent, centered)
        for (let y = minY; y <= maxY; y++) {
            for (let x = minX; x <= maxX; x++) {
                if (x < 1 || x > 100 || y < 1 || y > 100) continue;
                const idx = (y - 1) * 100 + (x - 1);
                const screenX = (x - minX) * TILE_SIZE;
                const screenY = (y - minY) * TILE_SIZE;

                // Layer 2 (fringe - trees, buildings, walls)
                const grh2 = mapData.tiles.layer2[idx];
                if (grh2 > 0) {
                    drawGrh(grh2, screenX, screenY, true);
                }

                // Characters at this position
                for (const ch of characters) {
                    if (ch.x === x && ch.y === y) {
                        drawCharacter(ch, screenX, screenY);
                    }
                }
            }
        }
    }

    /**
     * Draw a character (NPC) composited from head + body + shield + weapon.
     * VB6: RenderScreen character layer (Graphics.bas:432-484)
     * Compositing order: Head (offset), Body, Shield, Weapon
     */
    function drawCharacter(ch, screenX, screenY) {
        const body = bodyDefs[ch.bodyId];
        const head = headDefs[ch.headId];
        const weapon = weaponAnimDefs[ch.weaponAnim];
        const shield = shieldAnimDefs[ch.shieldAnim];

        // heading index: VB6 uses 1-4 (N,E,S,W), our arrays are 0-3
        const hi = (ch.heading || 3) - 1;

        // Draw head (offset by body's HeadOffset)
        if (head && head.grh && head.grh[hi]) {
            const headOffX = body ? body.headOffsetX : 0;
            const headOffY = body ? body.headOffsetY : 0;
            drawGrh(head.grh[hi], screenX + headOffX, screenY + headOffY, true);
        }

        // Draw body
        if (body && body.walk && body.walk[hi]) {
            drawGrh(body.walk[hi], screenX, screenY, true);
        }

        // Draw shield
        if (shield && shield.walk && shield.walk[hi]) {
            drawGrh(shield.walk[hi], screenX, screenY, true);
        }

        // Draw weapon
        if (weapon && weapon.walk && weapon.walk[hi]) {
            drawGrh(weapon.walk[hi], screenX, screenY, true);
        }
    }

    function renderLoop() {
        render();
        requestAnimationFrame(renderLoop);
    }

    // Public API
    return { init };
})();
