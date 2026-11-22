Config = {}

-- Type /menu in chat to open or close the lobby. The key mapping can be changed
-- in FiveM's Settings > Key Bindings > FiveM.
Config.Command = 'menu'
Config.EnableKeyMapping = true
Config.DefaultKey = 'F7'

Config.MenuTitle = 'NEON DISTRICT'
Config.ServerLabel = 'LOS SANTOS  /  US-01'

-- The live player ped is used for the preview, so the player's current model and
-- clothing are kept exactly as they are. This weapon is only equipped for the
-- lobby preview. If the player does not own it, a temporary copy can be given.
Config.PreviewWeapon = 'WEAPON_CARBINERIFLE'
Config.PreviewWeaponLabel = 'CARBINE RIFLE'
Config.PreviewAmmo = 90
Config.GivePreviewWeaponIfMissing = true
Config.RemovePreviewWeaponOnClose = true

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
