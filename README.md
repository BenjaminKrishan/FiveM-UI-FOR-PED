# Neon District — FiveM live-ped lobby menu

A standalone FiveM resource inspired by the supplied lobby screenshot. Type **`/menu`** (or press **F7**) to open a full-screen neon lobby. The scripted camera points directly at `PlayerPedId()`, so the exact active in-game model, head blend, clothing and props are shown without a replacement ped.

## Install

1. Copy this resource folder into your server's resources directory, for example `resources/[local]/neon_lobby`.
2. Add this to `server.cfg`:

   ```cfg
   ensure neon_lobby
   ```

3. Restart the resource/server, then type `/menu` in game. Press Escape or the close button to exit. The key can also be changed from FiveM's Key Bindings settings.

## Configure

Edit `config.lua`:

- `Config.PreviewWeapon` — weapon hash/name, for example `WEAPON_CARBINERIFLE` or `WEAPON_ASSAULTRIFLE`.
- `Config.PreviewWeaponLabel` — label shown on the player card.
- `Config.PreviewAmmo` — ammo given if a temporary preview weapon is needed.
- `Config.GivePreviewWeaponIfMissing` — temporarily give the configured weapon if the player does not already own it.
- `Config.RemovePreviewWeaponOnClose` — remove that temporary weapon when the menu closes.
- `Config.PreviewLighting` — enable subtle preview lights so dark outfits remain visible.
- `Config.Camera` — adjust model-based camera distance, height, framing and field of view.

The current selected weapon is restored on close. A weapon already owned by the player is not removed or given extra ammo. Set `Config.PreviewWeapon = nil` to disable weapon preview. Inventory resources can override client weapon calls; if yours blocks temporary weapons, set `GivePreviewWeaponIfMissing = false` and use a weapon the player already owns.

## Notes

- No ESX, QBCore, or other framework dependency is required for the menu/camera.
- The cyberpunk city backdrop includes a transparent player-stage opening, revealing the actual in-game player ped through the scripted camera. The camera does not clone or hard-code a model.
- F8 prints the source and preview model hashes for diagnostics; direct-player mode reports `cloned=false`.
- The lobby tabs, friend list, team slots and chat area are front-end presentation only. Connect them to your server's party/friends/chat systems if you want those features to perform server actions.
