# 🦇 Vampire Rig Kit

A two-part toolset for **Roblox avatar rig creation**:

1. **Studio Plugin** — Imports JSON rig data and recreates avatar rigs on pedestals in Roblox Studio
2. **Scanner Script** — Scans players and NPCs in-game, exports their avatar data as JSON

---

## Plugin (Roblox Studio)

### Installation

1. Go to [**Releases**](https://github.com/IaG0D/vampire-rig-kit/releases) and download `vampire-rig-kit.rbxm`
2. Place it in your Roblox Studio plugins folder:
   ```
   %LOCALAPPDATA%/Roblox/Plugins/
   ```
3. Restart Roblox Studio — the plugin will appear in the **Plugins** tab

### Features

- **Rig Alignment** — Automatically aligns avatar rigs on top of pedestals (BaseParts)
- **JSON Import** — Paste JSON from the Scanner to recreate rigs with full accessories, body colors, scales, and clothing
- **Outfit Builder** — Customize rigs with a visual editor (colors, accessories, adjustments)
- **Shop Panel** — Browse and apply items by category

### How to Use

1. Open the plugin from the **Plugins** tab in Studio
2. Select the pedestals (BaseParts) where you want rigs placed
3. Use **JSON Import** to paste scanned rig data — the plugin recreates each avatar on a pedestal
4. Use the **Align** button to reposition rigs if needed

---

## Scanner Script (Executor)

The Scanner runs in-game via a script executor (e.g. Xeno) and captures avatar data from players and NPCs.

### How to Run

Execute the following in your script executor:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/IaG0D/vampire-rig-kit/main/vampire-rigs/dist/VampireRigScript.luau"))()
```

### What It Does

- **Scans** all players and NPCs in the server
- **Previews** each rig in a 3D viewport with rotation
- **Exports** full avatar data as JSON (accessories, body parts, colors, scales, layered clothing)
- **Teleport** to any scanned character
- **Save Instance** — Save the game file with configurable options (powered by [UniversalSynSaveInstance](https://github.com/luau/UniversalSynSaveInstance))

### Controls

| Action | Control |
|--------|---------|
| Open/Close Scanner | `Ctrl + G` |
| Scan Players & NPCs | Click **SCAN** button |
| Export Single Rig | Click **JSON** on any card |
| Export All Rigs | Click **EXPORT ALL JSON** |

---

## Building from Source

### Plugin

Requires [Rojo](https://rojo.space/):

```bash
rojo build default.project.json --output vampire-rig-kit.rbxm
```

### Scanner

The scanner is split into 12 modules in `vampire-rigs/src/`. A bundler script concatenates them into a single file:

```bash
bash vampire-rigs/build.sh
```

Output: `vampire-rigs/dist/VampireRigScript.luau`

---

## Acknowledgments

- **[UniversalSynSaveInstance](https://github.com/luau/UniversalSynSaveInstance)** by [luau](https://github.com/luau) — Save Instance functionality used in the Scanner's game export feature

---

## Author

Created by **VampireSonata** ([@IaG0D](https://github.com/IaG0D))
