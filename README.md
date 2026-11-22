# Neon District — FiveM live-ped lobby menu

A standalone FiveM resource inspired by the supplied lobby screenshot. Type **`/menu`** (or press **F7**) to open a full-screen neon lobby. On open, a local preview ped is cloned directly from the player's current ped and shown through a scripted camera. This copies the exact in-game model, head blend, clothing and props without changing the real player's inventory or appearance.

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
- `Config.PreviewAmmo` — ammo used only if a preview weapon has to be given to the clone.
- `Config.GivePreviewWeaponIfMissing` — give the configured weapon to the local clone if it does not already have it.
- `Config.PreviewLighting` — enable subtle preview lights so dark outfits remain visible.
- `Config.Camera` — adjust camera distance, height, framing and field of view.

The weapon is only placed on the local preview clone; it never changes the real player's inventory, ammo or selected weapon. The clone is deleted when the menu closes. Set `Config.PreviewWeapon = nil` to disable the weapon preview. Inventory resources can take control of client weapons; if yours blocks temporary client weapons, set `GivePreviewWeaponIfMissing = false` and use a weapon the clone already inherited.

## Notes

- No ESX, QBCore, or other framework dependency is required for the menu/camera.
- The cyberpunk city backdrop is a bundled image. Its transparent player-stage opening reveals the game camera and the local preview clone copied from the current player ped at menu-open time; no clothing or model is hard-coded.
- The lobby tabs, friend list, team slots and chat area are front-end presentation only. Connect them to your server's party/friends/chat systems if you want those features to perform server actions.
