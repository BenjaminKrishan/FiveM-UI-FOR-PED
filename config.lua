Config = {}

-- Type /menu in chat to open or close the lobby. The key mapping can be changed
-- in FiveM's Settings > Key Bindings > FiveM.
Config.Command = 'menu'
Config.EnableKeyMapping = true
Config.DefaultKey = 'F7'

Config.MenuTitle = 'NEON DISTRICT'
Config.ServerLabel = 'LOS SANTOS  /  US-01'

-- A local preview clone is copied from the current player ped when /menu opens,
-- preserving the model, head blend, clothing, and props. This weapon is equipped
-- only on that clone, so the player's real inventory/selected weapon is untouched.
Config.PreviewWeapon = 'WEAPON_CARBINERIFLE'
Config.PreviewWeaponLabel = 'CARBINE RIFLE'
Config.PreviewAmmo = 90
Config.GivePreviewWeaponIfMissing = true
Config.PreviewLighting = true

-- Camera offsets are relative to the player's facing direction.
-- Increase forward for a wider/full-body view; raise lookAt.up to aim higher.
Config.Camera = {
    offset = {
        right = 0.0,
        forward = 4.25,
        up = 1.15
    },
    lookAt = {
        right = -0.48,
        forward = 0.0,
        up = 0.93
    },
    fov = 38.0,
    transitionMs = 650
}

Config.FreezePlayerWhileOpen = true
