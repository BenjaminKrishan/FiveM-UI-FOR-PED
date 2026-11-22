Config = {}

-- Type /menu in chat to open or close the lobby. The key mapping can be changed
-- in FiveM's Settings > Key Bindings > FiveM.
Config.Command = 'menu'
Config.EnableKeyMapping = true
Config.DefaultKey = 'F7'

Config.MenuTitle = 'NEON DISTRICT'
Config.ServerLabel = 'LOS SANTOS  /  US-01'

-- The camera displays PlayerPedId() directly, preserving the exact active model,
-- head blend, clothing, props, and live appearance without spawning another ped.
Config.PreviewWeapon = 'WEAPON_CARBINERIFLE'
Config.PreviewWeaponLabel = 'CARBINE RIFLE'
Config.PreviewAmmo = 90
Config.GivePreviewWeaponIfMissing = true
Config.PreviewLighting = true
Config.RemovePreviewWeaponOnClose = true

-- Camera framing scales with the current ped's measured height, including addon
-- models, so the full character fits the transparent player-stage window.
Config.Camera = {
    distanceMultiplier = 2.35,
    cameraHeightRatio = 0.12,
    lookAtHeightRatio = 0.0,
    cameraRight = 0.0,
    targetRight = 0.0,
    fov = 38.0,
    transitionMs = 650
}

Config.FreezePlayerWhileOpen = true
