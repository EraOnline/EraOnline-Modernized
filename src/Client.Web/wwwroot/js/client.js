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
    let charName = '';
    let charRace = '';

    // Inventory state (20 slots)
    const inventory = new Array(20).fill(null).map(() => ({
        objIndex: 0, name: '(None)', amount: 0, equipped: false, grhIndex: 0, value: 0
    }));
    let contextSlot = -1;

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

        document.getElementById('btn-select-login').onclick = () => {
            playClick();
            isCreatingNewChar = false;
            overlay.classList.add('hidden');
            startLoginForm();
        };

        document.getElementById('btn-select-create').onclick = () => {
            playClick();
            isCreatingNewChar = true;
            overlay.classList.add('hidden');
            startLoginForm();
        };
    }

    // --- Phase 4: Login / Create form ---

    // VB6 class lists per race (from Form5.frx)
    const classesByRace = {
        'Human': ['Warrior','Healer','Thief','Paladin','Bandit','Woodworker','BlackSmith','Tailor','Fisher','Animal Tamer','Merchant','Bard','Pirate','Miner','Cook','Cleric','Wizard','Druid','Enchanter'],
        'Haaki': ['Warrior','Thief','Bandit','BlackSmith','Tailor','Animal Tamer','Merchant','Bard','Miner','Cook','Cleric','Wizard','Druid'],
        'Wood Elf': ['Warrior','Healer','Thief','Paladin','Bandit','Woodworker','BlackSmith','Tailor','Fisher','Animal Tamer','Merchant','Bard','Miner','Cook','Cleric','Druid','Enchanter'],
        'Dark Elf': ['Warrior','Thief','Bandit','Woodworker','BlackSmith','Tailor','Merchant','Miner','Cook','Assasin','Wizard','Enchanter'],
    };

    // VB6 skill names (from Form5.frx — all 28 skills)
    const skillNames = [
        'Cooking','Musicanship','Tailoring','Carpenting','Lumberjacking','Tactics',
        'Disguise','Merchant','Blacksmithing','Hiding','Magery','Lockpicking',
        'Pickpocket','Stealth','Poisoning','Swordmanship','Parrying','Animal Taming',
        'Religion Lore','Fishing','Mining','Backstabbing','Healing','Surviving',
        'Etiquette','Streetwise','Meditating','Archery'
    ];

    // VB6 class descriptions (from Form5.frm Combo1_Change)
    const classDescs = {
        'Warrior': 'Warriors specialize in the art of battle. They are fighters by proffession and always carry their sword and lance ready to fight for gold and for glory.',
        'Druid': 'Druids dedicate their life to the study of magic of the nature. These are general do gooders and only uses destructive magic when provoked. Druids are a member of the nature school of magic.',
        'Healer': 'Healers are mainly against fighting and know how to make a nice pile of gold by healing less successful adventurers coming from home from advenures. Healers are a member of the nature school of magic.',
        'Cleric': 'Clerics are also against fighting and are very much alike the healers in any ways. But clerics also has a very high religion lore and can easily communicate with the gods. Clerics are a member of the nature school of magic.',
        'Thief': 'Thieves dedicate their life to the roaming the streets and pickpocket any person they think may carry a nice gold pile.',
        'Paladin': 'Knights are the noble fighters. Their good manners and figthing skills are a good mix. Paladins are a member of the enchanting school of magic.',
        'Bandit': 'Bandits are the pirates on land. They often attacks people on the roads and take everything they got and dissapear.',
        'Woodworker': 'This is the classic lumberjacker and carpenter professions in one. They cut woods and make nice wooden items of it like furniture and so on.',
        'BlackSmith': 'Blacksmiths process ore and make nice weapons out of it. Quite simple. Quite profitable.',
        'Tailor': 'Tailors take hides, clothes or fur and make nice clothing out of it to nobles or peasants or whoever.',
        'Fisher': 'Fishers do exactly what your thinking. They fish and sell their fish.',
        'Animal Tamer': 'Animal Tamers dedicate their life to the wildlife. As an animal tamer you are specialized in taming animals of all kinds!',
        'Merchant': 'Merchants can be very charming and dangerous in the way that they can fool you to buy anything from them.',
        'Bard': 'The musicians and entertainers of Menath. These people can play any instrument and make any dark place bright happy.',
        'Miner': 'Miners spend most of their lives in the mountains mining out ore to sell to the blacksmiths.',
        'Pirate': 'Pirates are also sailors but they use their sailing skills for the evil. They sail the seas and plunder and lives a drunk mans life.',
        'Cook': 'Hard to live without cooks. With a little food resources they can cook any kind of food ready to be served!',
        'Assasin': 'Assasin is very much alike the merchants only that their commodity is death. A assasin can have quite a long and lucrative career.',
        'Wizard': 'Wizards focus sorely on hate and destruction magic. They can be a horrible foe when all comes to all. Wizards are a member of the destruction school of magic.',
        'Enchanter': 'Enchanters uses magic like summonings and creating items. Enchanters are a member of the enchanting school of magic.',
    };

    // VB6 race descriptions (from Form3.frm)
    const raceDescs = {
        'Human': 'Humans hails from whole Menath. They are the superior race and very flexible in all skills. However they are not that specialized in any skills but they are very charismatic and excellent diplomats and bards.',
        'Haaki': 'Haakis hails from the deserts in the south in Menath. They are very primitive but are excellent hunters and their culture is richer than you can imagine. Haakis are excellent warriors.',
        'Wood Elf': "Wood Elf's hails from the woods of Menath. Their skills in surviving in wilderness is perfect and they are therefor specialized in hunting, fishing and other skills of nature survival.",
        'Dark Elf': "Dark Elf's hails from the mountains in the north in Menath. They are good fighters but specialize most in the art of the thief.",
    };

    let createStep = 0; // 0=name+race, 1=class+skills, 2=gender

    function startLoginForm() {
        if (isCreatingNewChar) {
            startCreateForm();
            return;
        }
        const overlay = document.getElementById('login-overlay');
        overlay.classList.remove('hidden');
        document.getElementById('login-name').focus();
    }

    // --- Character creation: fullscreen menu2.jpg overlay (VB6: Form3/Form5/Form4) ---

    function startCreateForm() {
        const overlay = document.getElementById('create-overlay');
        overlay.classList.remove('hidden');
        createStep = 0;
        showCreateStep(0);

        // Populate spec skill dropdowns
        ['create-spec1', 'create-spec2', 'create-spec3'].forEach(id => {
            const sel = document.getElementById(id);
            sel.innerHTML = '<option value="">-- Select --</option>';
            skillNames.forEach(s => {
                const opt = document.createElement('option');
                opt.value = s; opt.textContent = s;
                sel.appendChild(opt);
            });
        });

        document.getElementById('create-race').onchange = onRaceChange;
        document.getElementById('create-class').onchange = onClassChange;
        document.getElementById('btn-create-next').onclick = handleCreateNext;
        document.getElementById('btn-create-back').onclick = handleCreateBack;
        onRaceChange();
        document.getElementById('create-name').focus();
    }

    function onRaceChange() {
        const race = document.getElementById('create-race').value;
        document.getElementById('race-desc').textContent = raceDescs[race] || '';
        const classSel = document.getElementById('create-class');
        classSel.innerHTML = '<option value="">-- Select Class --</option>';
        (classesByRace[race] || []).forEach(c => {
            const opt = document.createElement('option');
            opt.value = c; opt.textContent = c;
            classSel.appendChild(opt);
        });
        document.getElementById('class-desc').textContent = '';
    }

    function onClassChange() {
        const cls = document.getElementById('create-class').value;
        document.getElementById('class-desc').textContent = classDescs[cls] || '';
    }

    function showCreateStep(step) {
        createStep = step;
        document.getElementById('create-step-name').classList.toggle('hidden', step !== 0);
        document.getElementById('create-step-race').classList.toggle('hidden', step !== 0);
        document.getElementById('create-step-class').classList.toggle('hidden', step !== 1);
        document.getElementById('create-step-gender').classList.toggle('hidden', step !== 2);
        document.getElementById('btn-create-back').classList.toggle('hidden', step === 0);
        document.getElementById('btn-create-next').textContent = step === 2 ? 'Create & Enter Menath' : 'Continue';
    }

    function showCreateError(msg) {
        document.getElementById('create-error').textContent = msg;
    }

    async function handleCreateNext() {
        playClick();
        showCreateError('');

        if (createStep === 0) {
            const name = document.getElementById('create-name').value.trim();
            const pass = document.getElementById('create-pass').value;
            const race = document.getElementById('create-race').value;
            if (!name || !pass) { showCreateError('Enter name and password.'); return; }
            if (!race) { showCreateError('Select a race.'); return; }
            showCreateStep(1);
        } else if (createStep === 1) {
            const cls = document.getElementById('create-class').value;
            if (!cls) { showCreateError('Select a class.'); return; }
            showCreateStep(2);
        } else if (createStep === 2) {
            await doCreateCharacter();
        }
    }

    function handleCreateBack() {
        playClick();
        showCreateError('');
        if (createStep > 0) {
            showCreateStep(createStep - 1);
        } else {
            // Back to select screen
            document.getElementById('create-overlay').classList.add('hidden');
            isCreatingNewChar = false;
            startSelectScreen();
        }
    }

    async function doCreateCharacter() {
        const name = document.getElementById('create-name').value.trim();
        const pass = document.getElementById('create-pass').value;
        const race = document.getElementById('create-race').value;
        const gender = document.getElementById('create-gender').value;
        const cls = document.getElementById('create-class').value;
        const specSkill1 = document.getElementById('create-spec1').value;
        const specSkill2 = document.getElementById('create-spec2').value;
        const specSkill3 = document.getElementById('create-spec3').value;

        if (!connection || connection.state !== signalR.HubConnectionState.Connected) {
            showCreateError('Connecting to server...');
            try { await connection.start(); } catch (err) {
                showCreateError('Failed to connect: ' + err.message); return;
            }
        }

        try {
            const result = await connection.invoke('CreateCharacter', {
                name, password: pass, race, gender,
                class: cls, specSkill1, specSkill2, specSkill3
            });
            if (result.success) {
                charName = name;
                charRace = race;
                document.getElementById('create-overlay').classList.add('hidden');
                enterGame();
            } else {
                showCreateError(result.errorMessage || 'Failed.');
            }
        } catch (err) {
            showCreateError('Error: ' + err.message);
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
            const result = await connection.invoke('Login', { name, password: pass });

            if (result.success) {
                charName = name;
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

        // VB6: class/rep display in character sheet
        const classEl = document.getElementById('charsheet-class');
        if (classEl && msg.class) {
            const repStr = msg.repRank && msg.repRank !== 'Unknown' ? ` ${msg.repRank}` : '';
            classEl.textContent = `${msg.class}${repStr}`;
        }
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

    function onDeath(isDead) {
        // VB6: DEA message — player has died, become a ghost
        if (isDead) {
            battleMode = false;
            const status = document.getElementById('status-bar');
            if (status) status.textContent = 'You are dead... Find a Priest of Life and type /RESSURECT';
        } else {
            // Resurrection
            const status = document.getElementById('status-bar');
            if (status) status.textContent = '';
        }
    }

    // --- Trade Window ---

    function onTradeOpen(msg) {
        // Remove existing trade window if any
        let existing = document.getElementById('trade-overlay');
        if (existing) existing.remove();

        const overlay = document.createElement('div');
        overlay.id = 'trade-overlay';
        overlay.style.cssText = 'position:absolute;top:50%;left:50%;transform:translate(-50%,-50%);' +
            'width:500px;background:#2a2a3a;border:2px solid #665544;color:#fff;font-family:Verdana,Arial,sans-serif;' +
            'font-size:11px;padding:10px;z-index:50;';

        const title = document.createElement('div');
        title.style.cssText = 'text-align:center;font-weight:bold;margin-bottom:8px;font-size:13px;';
        title.textContent = `Trading with ${msg.npcName}`;
        overlay.appendChild(title);

        const cols = document.createElement('div');
        cols.style.cssText = 'display:flex;gap:10px;';

        // NPC inventory (left)
        const npcCol = document.createElement('div');
        npcCol.style.cssText = 'flex:1;';
        const npcTitle = document.createElement('div');
        npcTitle.style.cssText = 'text-align:center;margin-bottom:4px;color:#aaa;';
        npcTitle.textContent = 'NPC Inventory';
        npcCol.appendChild(npcTitle);

        const npcList = document.createElement('div');
        npcList.style.cssText = 'background:#1a1a2a;border:1px solid #555;height:200px;overflow-y:auto;padding:2px;';
        (msg.npcInventory || []).forEach(item => {
            const row = document.createElement('div');
            row.style.cssText = 'padding:2px 4px;cursor:pointer;';
            row.textContent = item.name + (item.value > 0 ? ` (${item.value}g)` : '');
            row.dataset.slot = item.slot;
            row.addEventListener('click', () => {
                npcList.querySelectorAll('div').forEach(r => r.style.background = '');
                row.style.background = '#444';
                npcList.dataset.selectedSlot = item.slot;
            });
            npcList.appendChild(row);
        });
        npcCol.appendChild(npcList);

        const buyBtn = document.createElement('button');
        buyBtn.textContent = 'Buy';
        buyBtn.style.cssText = 'margin-top:4px;width:100%;padding:4px;cursor:pointer;';
        buyBtn.addEventListener('click', () => {
            const sel = npcList.dataset.selectedSlot;
            if (sel !== undefined) connection.invoke('BuyFromNpc', parseInt(sel)).catch(() => {});
        });
        npcCol.appendChild(buyBtn);

        // Player inventory (right)
        const plrCol = document.createElement('div');
        plrCol.style.cssText = 'flex:1;';
        const plrTitle = document.createElement('div');
        plrTitle.style.cssText = 'text-align:center;margin-bottom:4px;color:#aaa;';
        plrTitle.textContent = 'Your Inventory';
        plrCol.appendChild(plrTitle);

        const plrList = document.createElement('div');
        plrList.id = 'trade-player-inv';
        plrList.style.cssText = 'background:#1a1a2a;border:1px solid #555;height:200px;overflow-y:auto;padding:2px;';
        // Populate from current inventory state
        for (let i = 0; i < 20; i++) {
            const inv = inventory[i];
            if (inv && inv.objIndex > 0 && !inv.equipped) {
                const row = document.createElement('div');
                row.style.cssText = 'padding:2px 4px;cursor:pointer;';
                row.textContent = inv.name + (inv.amount > 1 ? ` x${inv.amount}` : '');
                row.dataset.slot = i;
                row.addEventListener('click', () => {
                    plrList.querySelectorAll('div').forEach(r => r.style.background = '');
                    row.style.background = '#444';
                    plrList.dataset.selectedSlot = i;
                });
                plrList.appendChild(row);
            }
        }
        plrCol.appendChild(plrList);

        const sellBtn = document.createElement('button');
        sellBtn.textContent = 'Sell';
        sellBtn.style.cssText = 'margin-top:4px;width:100%;padding:4px;cursor:pointer;';
        sellBtn.addEventListener('click', () => {
            const sel = plrList.dataset.selectedSlot;
            if (sel !== undefined) connection.invoke('SellToNpc', parseInt(sel)).catch(() => {});
        });
        plrCol.appendChild(sellBtn);

        cols.appendChild(npcCol);
        cols.appendChild(plrCol);
        overlay.appendChild(cols);

        // Close button
        const closeBtn = document.createElement('button');
        closeBtn.textContent = 'Close';
        closeBtn.style.cssText = 'margin-top:8px;width:100%;padding:4px;cursor:pointer;';
        closeBtn.addEventListener('click', () => overlay.remove());
        overlay.appendChild(closeBtn);

        document.getElementById('game-frame').appendChild(overlay);
    }

    // --- Training Window ---

    const skillNames = [
        '', 'Cooking', 'Musicanship', 'Tailoring', 'Carpenting', 'Lumberjacking',
        'Tactics', 'Disguise', 'Merchant', 'Blacksmithing', 'Hiding',
        'Magery', 'Lockpicking', 'Pickpocket', 'Stealth', 'Poisoning',
        'Swordmanship', 'Parrying', 'Animal Taming', 'Religion Lore', 'Fishing',
        'Mining', 'Backstabbing', 'Healing', 'Surviving', 'Etiquette',
        'Streetwise', 'Meditating', 'Archery'
    ];

    function onTrainOpen(skills) {
        let existing = document.getElementById('train-overlay');
        if (existing) existing.remove();

        const overlay = document.createElement('div');
        overlay.id = 'train-overlay';
        overlay.style.cssText = 'position:absolute;top:50%;left:50%;transform:translate(-50%,-50%);' +
            'width:350px;max-height:500px;background:#2a2a3a;border:2px solid #665544;color:#fff;' +
            'font-family:Verdana,Arial,sans-serif;font-size:11px;padding:10px;z-index:50;overflow-y:auto;';

        const title = document.createElement('div');
        title.style.cssText = 'text-align:center;font-weight:bold;margin-bottom:8px;font-size:13px;';
        title.textContent = 'Training';
        overlay.appendChild(title);

        for (let i = 1; i <= 28; i++) {
            const row = document.createElement('div');
            row.style.cssText = 'display:flex;justify-content:space-between;align-items:center;padding:2px 4px;';

            const label = document.createElement('span');
            label.textContent = `${skillNames[i] || 'Skill'+i}: ${skills[i] || 0}`;
            row.appendChild(label);

            const btn = document.createElement('button');
            btn.textContent = '+';
            btn.style.cssText = 'width:24px;height:20px;cursor:pointer;font-size:12px;';
            const skillIdx = i;
            btn.addEventListener('click', () => {
                connection.invoke('TrainSkill', skillIdx).catch(() => {});
                // Update display optimistically
                skills[skillIdx] = (skills[skillIdx] || 0) + 1;
                label.textContent = `${skillNames[skillIdx] || 'Skill'+skillIdx}: ${skills[skillIdx]}`;
            });
            row.appendChild(btn);

            overlay.appendChild(row);
        }

        const closeBtn = document.createElement('button');
        closeBtn.textContent = 'Close';
        closeBtn.style.cssText = 'margin-top:8px;width:100%;padding:4px;cursor:pointer;';
        closeBtn.addEventListener('click', () => overlay.remove());
        overlay.appendChild(closeBtn);

        document.getElementById('game-frame').appendChild(overlay);
    }

    // --- Client -> Server ---

    function onPlayerMove(direction) {
        if (connection && connection.state === signalR.HubConnectionState.Connected) {
            connection.invoke('Move', direction).catch(err => {
                console.error('[EraClient] Move failed:', err);
            });
        }
    }

    function onPlayerRotate(clockwise) {
        // VB6: Shift+Right sends ">", Shift+Left sends "<"
        if (connection && connection.state === signalR.HubConnectionState.Connected) {
            connection.invoke('Rotate', clockwise).catch(err => {
                console.error('[EraClient] Rotate failed:', err);
            });
        }
    }

    function onGetItem() {
        // VB6: Label7_Click / Image2_Click — pick up item at feet
        if (connection && connection.state === signalR.HubConnectionState.Connected) {
            playClick();
            connection.invoke('GetItem').catch(err => {
                console.error('[EraClient] GetItem failed:', err);
            });
        }
    }

    function onPlayerClick(tileX, tileY) {
        // VB6: Form_MouseUp -> SendData("LC" & tX & "," & tY)
        if (connection && connection.state === signalR.HubConnectionState.Connected) {
            connection.invoke('LeftClick', tileX, tileY).catch(err => {
                console.error('[EraClient] LeftClick failed:', err);
            });
        }
    }

    function onTargetMessage(msg) {
        // VB6: TGT — set the target name bar above the chat panel
        document.getElementById('target-message').textContent = msg.text || '';
    }

    function onInventorySlot(msg) {
        // VB6: SIS — update one inventory slot
        const slot = msg.slot;
        if (slot < 0 || slot >= 20) return;
        inventory[slot] = {
            objIndex: msg.objIndex, name: msg.name, amount: msg.amount,
            equipped: msg.equipped, grhIndex: msg.grhIndex, value: msg.value
        };
        renderInventoryList();
    }

    function onChangeChar(msg) {
        // VB6: CHC — character appearance changed (equip/unequip)
        EraRenderer.addCharacter(msg.charIndex, msg.name, msg.body, msg.head,
            msg.heading, msg.x, msg.y, msg.weaponAnim, msg.shieldAnim);
    }

    function onMakeObj(msg) {
        // VB6: MOB — place an item sprite on the ground
        EraRenderer.makeGroundObj(msg.grhIndex, msg.x, msg.y);
    }

    function onEraseObj(msg) {
        // VB6: EOB — remove an item from the ground
        EraRenderer.eraseGroundObj(msg.x, msg.y);
    }

    // --- Character sheet UI ---

    let selectedSlot = -1;

    function renderInventoryList() {
        const list = document.getElementById('inv-list');
        list.innerHTML = '';
        for (let i = 0; i < 20; i++) {
            const item = inventory[i];
            if (item.objIndex <= 0) continue;
            const div = document.createElement('div');
            let cls = 'inv-item';
            if (item.equipped) cls += ' equipped';
            if (i === selectedSlot) cls += ' selected';
            div.className = cls;
            let text = '';
            if (item.equipped) text += '(Eqp) ';
            if (item.amount > 1) text += `(${item.amount}) `;
            text += item.name;
            div.textContent = text;
            div.dataset.slot = i;
            // VB6: Left-click selects item (ObjLst_Click shows sprite in ShowPic)
            div.addEventListener('click', () => {
                playClick();
                selectedSlot = i;
                renderInventoryList();
            });
            // VB6: Right-click opens popup menu (ObjLst_MouseDown Button=2)
            div.addEventListener('contextmenu', (e) => {
                e.preventDefault();
                playClick();
                selectedSlot = i;
                renderInventoryList();
                showContextMenu(e, i);
            });
            list.appendChild(div);
        }
    }

    function showContextMenu(e, slot) {
        contextSlot = slot;
        const menu = document.getElementById('inv-context-menu');
        // Position relative to #game-frame (menu's offset parent)
        const frame = document.getElementById('game-frame');
        const frameRect = frame.getBoundingClientRect();
        menu.style.display = 'block';
        menu.style.left = (e.clientX - frameRect.left) + 'px';
        menu.style.top = (e.clientY - frameRect.top) + 'px';
        // Show/hide unequip based on equipped state
        document.getElementById('ctx-unequip').style.display =
            inventory[slot].equipped ? 'block' : 'none';
    }

    function hideContextMenu() {
        document.getElementById('inv-context-menu').style.display = 'none';
        contextSlot = -1;
    }

    function toggleCharSheet() {
        const panel = document.getElementById('charsheet-panel');
        panel.classList.toggle('visible');
        if (panel.classList.contains('visible')) {
            document.getElementById('charsheet-name').textContent = charName;
            document.getElementById('charsheet-class').textContent = charRace;
            renderInventoryList();
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
        connection.on('Target', onTargetMessage);
        connection.on('InventorySlot', onInventorySlot);
        connection.on('ChangeChar', onChangeChar);
        connection.on('MakeObj', onMakeObj);
        connection.on('EraseObj', onEraseObj);
        connection.on('PlayMusic', onPlayMusic);
        connection.on('PlaySound', onPlaySound);
        connection.on('PlayVoice', onPlayVoice);
        connection.on('Death', onDeath);
        connection.on('TradeOpen', onTradeOpen);
        connection.on('TrainOpen', onTrainOpen);

        connection.onreconnecting(() => setStatusBar('Reconnecting...'));
        connection.onreconnected(() => setStatusBar('Reconnected'));

        // Initialize renderer (loads sprite data while pre-game screens show)
        await EraRenderer.init('game-viewport', '/data');
        EraRenderer.setMoveCallback(onPlayerMove);
        EraRenderer.setRotateCallback(onPlayerRotate);
        EraRenderer.setClickCallback(onPlayerClick);
        EraRenderer.setStatusCallback(setStatusBar);
        EraRenderer.setMapNameCallback(setMapName);

        // Character sheet toggle — clicking on the "Character" area of the interface chrome
        // VB6: Label6_Click opens inventory.frm
        // The button is baked into interface.jpg at roughly right:7px top:84px
        document.getElementById('interface-bg').style.pointerEvents = 'auto';
        document.getElementById('interface-bg').addEventListener('click', (e) => {
            const rect = e.target.getBoundingClientRect();
            const x = e.clientX - rect.left;
            const y = e.clientY - rect.top;
            // Character button area: approximately right side, 80-140px from top
            if (x > 725 && y > 80 && y < 140) { playClick(); toggleCharSheet(); }
            // Spells button area
            else if (x > 725 && y > 140 && y < 200) { playClick(); /* TODO: spellbook */ }
            // Skills button area
            else if (x > 725 && y > 200 && y < 260) { playClick(); /* TODO: skills */ }
        });

        // Character sheet close button
        document.getElementById('charsheet-close').addEventListener('click', () => {
            playClick();
            document.getElementById('charsheet-panel').classList.remove('visible');
        });

        // Context menu actions
        document.getElementById('ctx-use').addEventListener('click', () => {
            if (contextSlot >= 0 && connection) connection.invoke('UseItem', contextSlot).catch(() => {});
            hideContextMenu();
        });
        document.getElementById('ctx-drop').addEventListener('click', () => {
            if (contextSlot >= 0 && connection) connection.invoke('DropItem', contextSlot, 1).catch(() => {});
            hideContextMenu();
        });
        document.getElementById('ctx-unequip').addEventListener('click', () => {
            // Unequip = use again when equipped (VB6 toggle behavior)
            if (contextSlot >= 0 && connection) connection.invoke('UseItem', contextSlot).catch(() => {});
            hideContextMenu();
        });
        // Hide context menu on click elsewhere
        document.addEventListener('mousedown', (e) => {
            if (!e.target.closest('#inv-context-menu') && contextSlot >= 0) hideContextMenu();
        });

        // 'G' key to pick up items (VB6: Label7 "Get" button)
        document.addEventListener('keydown', (e) => {
            // Don't trigger when typing in inputs
            if (e.target.tagName === 'INPUT' || e.target.tagName === 'TEXTAREA') return;
            if (e.key === 'g' || e.key === 'G') {
                onGetItem();
            }
        });

        // CTRL = toggle battle mode (VB6: KeyCode = vbKeyControl → SendData "BTL")
        // ALT = attack (VB6: KeyCode = 18 → SendData "ATT")
        let battleMode = false;
        document.addEventListener('keydown', (e) => {
            if (e.target.tagName === 'INPUT' || e.target.tagName === 'TEXTAREA') return;
            if (e.key === 'Control') {
                e.preventDefault();
                connection.invoke('ToggleBattleMode').catch(() => {});
                battleMode = !battleMode;
                // Update status display
                const status = document.getElementById('status-bar');
                if (status) status.textContent = battleMode ? '⚔ Battle Mode' : '';
            }
            if (e.key === 'Alt') {
                e.preventDefault();
                connection.invoke('Attack').catch(() => {});
            }
            // TAB = consider target (VB6: KeyCode = vbKeyTab → SendData "COO")
            if (e.key === 'Tab') {
                e.preventDefault();
                connection.invoke('Consider').catch(() => {});
            }
        });

        // Pre-connect to server in the background (don't wait)
        connection.start().catch(() => {});

        // Start the intro sequence!
        startIntro();
    }

    init();
})();
