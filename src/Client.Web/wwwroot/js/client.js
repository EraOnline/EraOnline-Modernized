/**
 * Era Online Client
 *
 * Handles the full startup sequence matching the original VB6 client:
 *   Phase 1: Intro slideshow (intro.frm) - 3 images, Undead.mp3
 *   Phase 2: Main menu (Form2) - menu1.jpg, Mus6.mid music
 *   Phase 3: Select screen (frmSelect) - Log In / Start New
 *   Phase 4: Login/Create form (frmConnect / Form3)
 *   Phase 5: In-game
 *
 * Also manages SignalR connection, chat, and bridges server messages to renderer.
 */
const EraClient = (() => {
    let connection = null;
    let myCharIndex = null;
    let isCreatingNewChar = false;
    let musicEnabled = true;

    // Audio elements
    let introAudio = null;
    let menuMusic = null;

    // --- Audio helpers ---

    function playSound(url) {
        try {
            const snd = new Audio(url);
            snd.play().catch(() => {}); // ignore autoplay restrictions
            return snd;
        } catch (e) { return null; }
    }

    function playClick() {
        playSound('/data/sfx/snd58.wav');
    }

    function playMusic(url, loop = true) {
        stopMusic();
        console.log(`[Audio] playMusic: ${url} (loop=${loop})`);
        menuMusic = new Audio(url);
        menuMusic.loop = loop;
        menuMusic.addEventListener('error', (e) => {
            console.error(`[Audio] Music error for ${url}:`, menuMusic.error);
        });
        menuMusic.addEventListener('playing', () => {
            console.log(`[Audio] Music playing: ${url}`);
        });
        menuMusic.play().then(() => {
            console.log(`[Audio] Music play() resolved: ${url}`);
        }).catch((err) => {
            console.error(`[Audio] Music play() rejected for ${url}:`, err);
        });
        return menuMusic;
    }

    function stopMusic() {
        if (menuMusic) {
            console.log('[Audio] stopMusic');
            menuMusic.pause();
            menuMusic.currentTime = 0;
            menuMusic = null;
        }
    }

    // --- Phase 1: Intro slideshow (VB6: intro.frm) ---

    let introSlide = 1;
    let introTimer = null;

    let introEnded = false;

    function startIntro() {
        const overlay = document.getElementById('intro-overlay');
        const img = document.getElementById('intro-img');

        // Play Undead.mp3 (VB6: MP3Player.FileName = "Music\Undead.mp3")
        introAudio = new Audio('/data/voice/undead.mp3');
        introAudio.play().catch(() => {});

        // Advance slides every 2.2 seconds (VB6: Timer1.Interval = 2200)
        introTimer = setInterval(() => {
            introSlide++;
            if (introSlide > 3) {
                endIntro();
            } else {
                img.src = `/ui/intro/${introSlide}.jpg`;
            }
        }, 2200);

        // Click or key skips intro (VB6: Image1_Click / Form_KeyDown ESC)
        overlay.addEventListener('click', endIntro);
        document.addEventListener('keydown', endIntro);
    }

    function endIntro() {
        if (introEnded) return;
        introEnded = true;
        if (introTimer) { clearInterval(introTimer); introTimer = null; }
        if (introAudio) { introAudio.pause(); introAudio = null; }
        document.getElementById('intro-overlay').removeEventListener('click', endIntro);
        document.removeEventListener('keydown', endIntro);
        document.getElementById('intro-overlay').classList.add('hidden');
        startMainMenu();
    }

    // --- Phase 2: Main menu (VB6: Form2) ---

    function startMainMenu() {
        const overlay = document.getElementById('menu-overlay');
        overlay.classList.remove('hidden');

        // VB6: PlayMidi(Mus6.mid) + PlayWaveDS(Snd41.wav)
        if (musicEnabled) playMusic('/data/music/mus6.mp3');
        playSound('/data/sfx/snd41.wav');

        document.getElementById('btn-enter-menath').addEventListener('click', () => {
            playClick();
            overlay.classList.add('hidden');
            startSelectScreen();
        });

        document.getElementById('btn-music-toggle').addEventListener('click', () => {
            playClick();
            musicEnabled = !musicEnabled;
            if (musicEnabled) {
                playMusic('/data/music/mus6.mp3');
            } else {
                stopMusic();
            }
        });

        document.getElementById('btn-credits').addEventListener('click', () => {
            playClick();
            // TODO: credits screen
        });

        document.getElementById('btn-menu-quit').addEventListener('click', () => {
            playClick();
            // In browser, just show a message
            alert('Thanks for visiting Menath!');
        });
    }

    // --- Phase 3: Select screen (VB6: frmSelect) ---

    function startSelectScreen() {
        const overlay = document.getElementById('select-overlay');
        overlay.classList.remove('hidden');

        document.getElementById('btn-select-login').addEventListener('click', () => {
            playClick();
            isCreatingNewChar = false;
            overlay.classList.add('hidden');
            startLoginForm();
        });

        document.getElementById('btn-select-create').addEventListener('click', () => {
            playClick();
            isCreatingNewChar = true;
            overlay.classList.add('hidden');
            startLoginForm();
        });
    }

    // --- Phase 4: Login / Create form ---

    function startLoginForm() {
        const overlay = document.getElementById('login-overlay');
        overlay.classList.remove('hidden');

        const title = document.getElementById('login-title');
        const createFields = document.getElementById('create-fields');
        const btn = document.getElementById('btn-login');

        if (isCreatingNewChar) {
            title.textContent = 'Start New Character';
            createFields.classList.add('active');
            btn.textContent = 'Create & Enter Menath';
        } else {
            title.textContent = 'Log Into Character';
            createFields.classList.remove('active');
            btn.textContent = 'Enter Menath';
        }

        document.getElementById('login-name').focus();
    }

    function showError(msg) {
        document.getElementById('login-error').textContent = msg;
    }

    async function doLogin() {
        const name = document.getElementById('login-name').value.trim();
        const pass = document.getElementById('login-pass').value;
        if (!name || !pass) { showError('Enter name and password.'); return; }
        showError('');

        // Ensure SignalR is connected
        if (!connection || connection.state !== signalR.HubConnectionState.Connected) {
            showError('Connecting to server...');
            try {
                await connection.start();
            } catch (err) {
                showError('Failed to connect: ' + err.message);
                return;
            }
        }

        try {
            let result;
            if (isCreatingNewChar) {
                const race = document.getElementById('create-race').value;
                const gender = document.getElementById('create-gender').value;
                result = await connection.invoke('CreateCharacter', { name, password: pass, race, gender });
            } else {
                result = await connection.invoke('Login', { name, password: pass });
            }

            if (result.success) {
                enterGame();
            } else {
                showError(result.errorMessage || 'Failed.');
                // VB6: WR1 = wrong password (mp13), WR2 = wrong name (mp8)
                if (result.errorMessage && result.errorMessage.includes('password')) {
                    playSound('/data/voice/mp13.mp3');
                } else if (result.errorMessage && result.errorMessage.includes('does not exist')) {
                    playSound('/data/voice/mp8.mp3');
                }
            }
        } catch (err) {
            showError('Error: ' + err.message);
        }
    }

    function enterGame() {
        // Hide all pre-game overlays — zone music is already playing
        // (PlayMusic message arrives during Login before this runs)
        document.querySelectorAll('.overlay').forEach(el => el.classList.add('hidden'));
    }

    // --- Chat ---

    function sendChat() {
        const input = document.getElementById('chat-input');
        const text = input.value.trim();
        if (!text) return;
        input.value = '';

        if (connection && connection.state === signalR.HubConnectionState.Connected) {
            connection.invoke('Say', text).catch(err => {
                addChatMessage('Error sending message: ' + err.message, 'chat-warning');
            });
        }
    }

    function addChatMessage(text, className) {
        const log = document.getElementById('chat-log');
        const line = document.createElement('div');
        line.className = className || 'chat-info';
        line.textContent = text;
        log.appendChild(line);
        log.scrollTop = log.scrollHeight;
    }

    // --- Server -> Client handlers ---

    function onSetCharIndex(msg) {
        myCharIndex = msg.charIndex;
        EraRenderer.setMyCharIndex(myCharIndex);
    }

    function onMapLoad(msg) {
        EraRenderer.loadMapFromServer(msg.mapId);
    }

    function onMakeChar(msg) {
        EraRenderer.addCharacter(msg.charIndex, msg.name, msg.body, msg.head,
            msg.heading, msg.x, msg.y, msg.weaponAnim, msg.shieldAnim);
    }

    function onEraseChar(msg) {
        EraRenderer.removeCharacter(msg.charIndex);
    }

    function onMoveChar(msg) {
        EraRenderer.moveCharacter(msg.charIndex, msg.x, msg.y, msg.heading);
    }

    function onSetPosition(msg) {
        EraRenderer.setPlayerPosition(msg.x, msg.y);
    }

    function onChat(msg) {
        const fontClass = {
            0: 'chat-talk',
            1: 'chat-fight',
            2: 'chat-warning',
            3: 'chat-info',
            4: 'chat-skill'
        };
        addChatMessage(msg.text, fontClass[msg.font] || 'chat-info');
    }

    function onPlayVoice(msg) {
        // VB6: PL3 protocol message — play mp{n}.mp3
        playSound(`/data/voice/mp${msg.id}.mp3`);
    }

    function onStats(msg) {
        // VB6: SST — update stat bars and gold display
        // Bars are 150px tall, fill from bottom as percentage of max
        const hpPct = msg.maxHp > 0 ? (msg.hp / msg.maxHp) * 100 : 0;
        const staPct = msg.maxSta > 0 ? (msg.sta / msg.maxSta) * 100 : 0;
        const manPct = msg.maxMan > 0 ? (msg.man / msg.maxMan) * 100 : 0;

        document.getElementById('hp-bar').style.height = hpPct + '%';
        document.getElementById('sta-bar').style.height = staPct + '%';
        document.getElementById('man-bar').style.height = manPct + '%';
        document.getElementById('gold-value').textContent = msg.gold;

        // EXP progress — show in status bar area
        const expPct = msg.elu > 0 ? Math.floor((msg.exp / msg.elu) * 100) : 0;
        const expEl = document.getElementById('exp-label');
        if (expEl) expEl.textContent = `EXP: ${expPct}%`;
    }

    function onPlayMusic(msg) {
        // VB6: PLM protocol message — play zone music
        console.log(`[Audio] onPlayMusic received: musicNumber=${msg.musicNumber}, loop=${msg.loop}, musicEnabled=${musicEnabled}`);
        if (!musicEnabled) return;
        playMusic(`/data/music/mus${msg.musicNumber}.mp3`, msg.loop);
    }

    function onPlaySound(msg) {
        // VB6: PLW protocol message — play sound effect
        playSound(`/data/sfx/snd${msg.soundId}.wav`);
    }

    // --- Client -> Server ---

    function onPlayerMove(direction) {
        if (connection && connection.state === signalR.HubConnectionState.Connected) {
            connection.invoke('Move', direction).catch(err => {
                console.error('[EraClient] Move failed:', err);
            });
        }
    }

    function setStatusBar(msg) {
        document.getElementById('status-bar').textContent = msg;
    }

    function setMapName(name) {
        document.getElementById('map-name').textContent = name || '';
    }

    // --- Initialization ---

    async function init() {
        // Login button and enter key
        document.getElementById('btn-login').addEventListener('click', () => {
            playClick();
            doLogin();
        });
        document.getElementById('login-name').addEventListener('keydown', e => {
            if (e.key === 'Enter') doLogin();
        });
        document.getElementById('login-pass').addEventListener('keydown', e => {
            if (e.key === 'Enter') doLogin();
        });

        // Chat input
        document.getElementById('chat-input').addEventListener('keydown', e => {
            if (e.key === 'Enter') {
                sendChat();
                e.preventDefault();
            }
            e.stopPropagation();
        });

        // Build SignalR connection
        connection = new signalR.HubConnectionBuilder()
            .withUrl('/gamehub')
            .withAutomaticReconnect()
            .build();

        connection.on('MakeChar', onMakeChar);
        connection.on('EraseChar', onEraseChar);
        connection.on('MoveChar', onMoveChar);
        connection.on('SetCharIndex', onSetCharIndex);
        connection.on('SetPosition', onSetPosition);
        connection.on('MapLoad', onMapLoad);
        connection.on('Chat', onChat);
        connection.on('Stats', onStats);
        connection.on('PlayMusic', onPlayMusic);
        connection.on('PlaySound', onPlaySound);
        connection.on('PlayVoice', onPlayVoice);

        connection.onreconnecting(() => setStatusBar('Reconnecting...'));
        connection.onreconnected(() => setStatusBar('Reconnected'));

        // Initialize renderer (loads sprite data while pre-game screens show)
        await EraRenderer.init('game-viewport', '/data');
        EraRenderer.setMoveCallback(onPlayerMove);
        EraRenderer.setStatusCallback(setStatusBar);
        EraRenderer.setMapNameCallback(setMapName);

        // Pre-connect to server in the background (don't wait)
        connection.start().catch(() => {});

        // Start the intro sequence!
        startIntro();
    }

    init();
})();
