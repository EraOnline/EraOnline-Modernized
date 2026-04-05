/**
 * Era Online Client
 *
 * Handles SignalR connection, login/character creation, chat, and bridges
 * server messages to the renderer.
 */
const EraClient = (() => {
    let connection = null;
    let myCharIndex = null;

    async function init() {
        // Toggle create character fields
        document.getElementById('toggle-create').addEventListener('click', () => {
            const fields = document.getElementById('create-fields');
            const toggle = document.getElementById('toggle-create');
            const isActive = fields.classList.toggle('active');
            toggle.textContent = isActive ? 'Hide character options' : 'New character? Show options';
        });

        // Login button
        document.getElementById('btn-login').addEventListener('click', doLogin);

        // Create button
        document.getElementById('btn-create').addEventListener('click', doCreate);

        // Enter key on inputs
        document.getElementById('login-name').addEventListener('keydown', e => {
            if (e.key === 'Enter') doLogin();
        });
        document.getElementById('login-pass').addEventListener('keydown', e => {
            if (e.key === 'Enter') {
                const createActive = document.getElementById('create-fields').classList.contains('active');
                if (createActive) doCreate(); else doLogin();
            }
        });

        // Chat input
        document.getElementById('chat-input').addEventListener('keydown', e => {
            if (e.key === 'Enter') {
                sendChat();
                e.preventDefault();
            }
            // Stop arrow keys from moving player when typing
            e.stopPropagation();
        });

        // Build SignalR connection
        connection = new signalR.HubConnectionBuilder()
            .withUrl('/gamehub')
            .withAutomaticReconnect()
            .build();

        // Register server -> client message handlers
        connection.on('MakeChar', onMakeChar);
        connection.on('EraseChar', onEraseChar);
        connection.on('MoveChar', onMoveChar);
        connection.on('SetCharIndex', onSetCharIndex);
        connection.on('SetPosition', onSetPosition);
        connection.on('MapLoad', onMapLoad);
        connection.on('Chat', onChat);

        connection.onreconnecting(() => {
            setStatusBar('Reconnecting...');
        });
        connection.onreconnected(() => {
            setStatusBar('Reconnected');
        });

        // Initialize renderer (loads sprite data while login screen shows)
        await EraRenderer.init('game-viewport', '/data');
        EraRenderer.setMoveCallback(onPlayerMove);
        EraRenderer.setStatusCallback(setStatusBar);
        EraRenderer.setMapNameCallback(setMapName);

        // Connect to server
        try {
            await connection.start();
            console.log('[EraClient] Connected to server');
        } catch (err) {
            showError('Failed to connect: ' + err.message);
        }

        // Focus the name input
        document.getElementById('login-name').focus();
    }

    function showError(msg) {
        document.getElementById('login-error').textContent = msg;
    }

    function setStatusBar(msg) {
        document.getElementById('status-bar').textContent = msg;
    }

    function setMapName(name) {
        document.getElementById('map-name').textContent = name || '';
    }

    async function doLogin() {
        const name = document.getElementById('login-name').value.trim();
        const pass = document.getElementById('login-pass').value;
        if (!name || !pass) { showError('Enter name and password.'); return; }

        showError('');
        try {
            const result = await connection.invoke('Login', { name, password: pass });
            if (result.success) {
                enterGame();
            } else {
                showError(result.errorMessage || 'Login failed.');
            }
        } catch (err) {
            showError('Error: ' + err.message);
        }
    }

    async function doCreate() {
        const name = document.getElementById('login-name').value.trim();
        const pass = document.getElementById('login-pass').value;
        const race = document.getElementById('create-race').value;
        const gender = document.getElementById('create-gender').value;
        if (!name || !pass) { showError('Enter name and password.'); return; }

        showError('');
        try {
            const result = await connection.invoke('CreateCharacter', { name, password: pass, race, gender });
            if (result.success) {
                enterGame();
            } else {
                showError(result.errorMessage || 'Creation failed.');
            }
        } catch (err) {
            showError('Error: ' + err.message);
        }
    }

    function enterGame() {
        // Hide the login overlay to reveal the game underneath
        document.getElementById('login-overlay').classList.add('hidden');
    }

    // --- Chat ---

    function sendChat() {
        const input = document.getElementById('chat-input');
        const text = input.value.trim();
        if (!text) return;
        input.value = '';

        // TODO: send to server when chat hub method is implemented
        // For now, local echo
        addChatMessage(`You say: ${text}`, 'chat-talk');
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
        console.log('[EraClient] My char index:', myCharIndex);
    }

    function onMapLoad(msg) {
        console.log('[EraClient] Load map:', msg.mapId);
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
        // Map FontType enum to CSS class
        const fontClass = {
            0: 'chat-talk',    // Talk
            1: 'chat-fight',   // Fight
            2: 'chat-warning', // Warning
            3: 'chat-info',    // Info
            4: 'chat-skill'    // SkillInfo
        };
        addChatMessage(msg.text, fontClass[msg.font] || 'chat-info');
    }

    // --- Client -> Server ---

    function onPlayerMove(direction) {
        if (connection && connection.state === signalR.HubConnectionState.Connected) {
            connection.invoke('Move', direction).catch(err => {
                console.error('[EraClient] Move failed:', err);
            });
        }
    }

    // Auto-init
    init();
})();
