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

-- Camera framing scales with the current ped's measured height (including addon
-- models). The clone is moved forward of the real player so both do not overlap.
Config.Camera = {
    previewOffset = {
        right = 0.0,
        forward = 1.5
    },
    distanceMultiplier = 2.35,
    cameraHeightRatio = 0.12,
    lookAtHeightRatio = 0.0,
    cameraRight = 0.0,
    targetRight = 0.0,
    fov = 38.0,
    transitionMs = 650
}

Config.FreezePlayerWhileOpen = true
