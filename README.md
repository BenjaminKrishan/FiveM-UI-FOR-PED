# Neon District — FiveM live-ped lobby menu

A standalone FiveM resource inspired by the supplied lobby screenshot. Type **`/menu`** (or press **F7**) to open a full-screen neon lobby. It uses the **actual player ped** in a scripted camera, rather than spawning a replacement ped, so the current freemode/model and clothing are visible in real time.

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
- `Config.PreviewAmmo` — ammo used only if a temporary preview weapon has to be given.
- `Config.GivePreviewWeaponIfMissing` — temporarily give the configured weapon if the player does not already own it.
- `Config.RemovePreviewWeaponOnClose` — remove that temporary weapon when the menu closes.
- `Config.Camera` — adjust camera distance, height, framing and field of view.

The selected weapon is restored on close. If the configured weapon was already in the player's inventory, this script does not remove it or change its ammo. Set `Config.PreviewWeapon = nil` to disable the weapon preview. Inventory resources can take control of client weapons; if yours blocks temporary client weapons, set `GivePreviewWeaponIfMissing = false` and use a weapon your inventory already provides.

## Notes

- No ESX, QBCore, or other framework dependency is required for the menu/camera.
- The cyberpunk city backdrop is a bundled image. A transparent opening reveals the live game camera and player ped; clothing changes made by your appearance resource remain visible because the menu does not clone or restyle the ped.
- The lobby tabs, friend list, team slots and chat area are front-end presentation only. Connect them to your server's party/friends/chat systems if you want those features to perform server actions.
