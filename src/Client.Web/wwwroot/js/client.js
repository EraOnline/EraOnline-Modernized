/**
 * Era Online Client
 *
 * Handles SignalR connection, login/character creation, and bridges
 * server messages to the renderer.
 *
 * VB6: TCP.bas (client-side) handles the Winsock connection and message parsing.
 * We use SignalR hub methods instead of raw TCP message prefixes.
 */
const EraClient = (() => {
    let connection = null;
    let myCharIndex = null;

    async function init() {
        // Login form toggle
        document.getElementById('show-create').addEventListener('click', () => {
            document.getElementById('login-form').style.display = 'none';
            document.getElementById('create-form').style.display = '';
            document.getElementById('login-error').textContent = '';
        });
        document.getElementById('show-login').addEventListener('click', () => {
            document.getElementById('create-form').style.display = 'none';
            document.getElementById('login-form').style.display = '';
            document.getElementById('login-error').textContent = '';
        });

        // Login button
        document.getElementById('btn-login').addEventListener('click', doLogin);
        document.getElementById('login-name').addEventListener('keydown', e => { if (e.key === 'Enter') doLogin(); });
        document.getElementById('login-pass').addEventListener('keydown', e => { if (e.key === 'Enter') doLogin(); });

        // Create button
        document.getElementById('btn-create').addEventListener('click', doCreate);
        document.getElementById('create-name').addEventListener('keydown', e => { if (e.key === 'Enter') doCreate(); });
        document.getElementById('create-pass').addEventListener('keydown', e => { if (e.key === 'Enter') doCreate(); });

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
            document.getElementById('loading').textContent = 'Reconnecting...';
        });

        connection.onreconnected(() => {
            document.getElementById('loading').textContent = 'Reconnected!';
        });

        // Connect
        try {
            await connection.start();
            console.log('[EraClient] Connected to server');
        } catch (err) {
            showError('Failed to connect to server: ' + err.message);
        }
    }

    function showError(msg) {
        document.getElementById('login-error').textContent = msg;
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
        const name = document.getElementById('create-name').value.trim();
        const pass = document.getElementById('create-pass').value;
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

    async function enterGame() {
        document.getElementById('login-screen').style.display = 'none';
        document.getElementById('game-screen').style.display = '';

        // Initialize the renderer (loads sprite data, etc.)
        await EraRenderer.init('game-viewport', '/data');

        // Tell the renderer to send movement through us
        EraRenderer.setMoveCallback(onPlayerMove);
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
        // Server correction of our position
        EraRenderer.setPlayerPosition(msg.x, msg.y);
    }

    function onChat(msg) {
        console.log('[Chat]', msg.text);
        // TODO: render in a chat UI
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
