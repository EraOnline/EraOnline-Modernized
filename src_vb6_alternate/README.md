# Alternate VB6 Source

This directory contains what appears to be a later version of the Era Online VB6 source code, maintained by someone other than Erling Ellingsen. The GM list has a single GM "Rolph" instead of the original 33 headed by "Emperor" (Erling). It represents a cleanup and feature expansion pass on the original codebase.

**Decision (2026-04-07):** Kyle reviewed the comparison and decided not to reference this source for implementation details during the v1 port. The rewrite will be based exclusively on the original source in `src_vb6/` (Erling's freeware release). This alternate source will be kept for future reference after the v1 port is complete.

---

## Comparison with Original (`src_vb6/`)

### Structural Changes
- All client forms renamed from generic (Form3, Form5) to descriptive (frmCreation_Part1, frmCreation_Part2)
- All client modules got `mod` prefix (General.bas -> modGeneral.bas, TCP.bas -> modTCP.bas)
- Duplicate server files removed (ServerLogic.bas, Networking.bas, FileHandler.bas, Checks.bas gone)
- `Declarations.bas` renamed to `Declares.bas`

### New Features
- **GM hierarchy system**: 10 levels from "God" (power 10) down to "Suspended" (power -1), with `/ADDGM`, `/REMOVEGM`, `/CHANLEV` commands
- **~30 new GM commands**: `/KICK`, `/BAN`, `/JAIL`, `/SUSPEND`, `/WARP`, `/SUMMON`, `/SUMMONNPC`, `/WHEREIS`, `/APPROACH`, `/BROADCAST`, `/ALERT`, `/EXP`, `/GOLD`, `/HEAD`, `/BODY`, `/CRIMINAL`, `/INFO`, `/NEWHEAD`, `/GIVELOCK`, `/CC`, etc.
- **Consider (TAB)**: Shows target HP and hit power -- fully implemented
- **Animal combat**: `AnimalAttack`/`AnimalSettle` -- tamed animals can attack targets (movement types 9, 10 added)
- **/UNSTUCK**: Teleports player to safety (kills them as ghost), blocked in jail (map 142)
- **/BUG reporting**: Saves to bugs.txt with description and reporter name
- **Private messaging**: `/MSG name message` with new FONTTYPE_PRIVMSG color
- **/OOC**: Out-of-character chat
- **MOTD system**: Message of the Day saved to Server.ini
- **IP banning**: ipban.txt
- **Auto-save timer**: ServerBot timer (60s interval), SaveAtMinute constant
- **frmGameOptions**: Game options form (includes MSDXM.OCX media player control)
- **Minimized.frm**: Minimized state form
- **frmBook.frm**: Book reading form
- **frmSignup.frm**: Signup/registration form
- **frmMessage.frm**: Message display form

### Gameplay/Balance Changes
- **Death behavior changed**: HP/MAN/STA set to 1 instead of full heal (original set them to max on death)
- **Home city auto-assigned by race**: Haaki->Denc, Human->CastleFall, Dark Elf->Ug, Wood Elf->Valen (homeselect form removed as a separate step)
- **Race descriptions rewritten**: Better English, slightly different lore framing (e.g., "Dark Elf's hails from the mountains in the north" -> "Dark Elves hail from the rocky south of the Elfin continent")
- **Title changed**: "-Character Creation" -> "Character Creation" (no leading dash)
- **Font changed**: Times New Roman -> Verdana throughout creation forms
- **PKFREEZONE removed** from MapInfo
- **SaveGameini commented out** -- no longer saves passwords to game.ini (security fix)
- **DrawingType** field added to ObjData
- **Power** field added to UserFlags (for GM levels)
- **LastBody** added to Char type

### Data Changes
- **1 new map** (Map212)
- OBJ.dat slightly smaller (3548->3529 lines) -- minor edits
- NPC.dat smaller (5021->4806 lines) -- some NPCs removed/consolidated
- Port changed from 7777 to 6669
- Client version "11" -> "1.5.5"

### Potentially Useful for Post-v1
- Consider (TAB) implementation -- clean working code
- GM hierarchy -- good reference for GM tools
- Animal combat system -- reference for animal taming
- /UNSTUCK -- useful quality-of-life feature
- Death behavior (HP=1 not max) -- the original full-heal-on-death may have been unintentional

### Caution Areas
- Race descriptions have lore changes that may diverge from Erling's original vision
- PKFREEZONE removal could affect game balance
- NPC data has ~215 fewer lines (possible missing NPCs)
