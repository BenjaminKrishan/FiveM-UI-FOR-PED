local menuOpen = false
local lobbyCam = nil
local savedPlayerState = nil

local function getCameraPoint(ped, offset)
    local coords = GetEntityCoords(ped)
    local forward = GetEntityForwardVector(ped)
    -- Local right vector, perpendicular to the ped's forward direction.
    local right = vector3(forward.y, -forward.x, 0.0)

    return vector3(
        coords.x + right.x * (offset.right or 0.0) + forward.x * (offset.forward or 0.0),
        coords.y + right.y * (offset.right or 0.0) + forward.y * (offset.forward or 0.0),
        coords.z + (offset.up or 0.0)
    )
end

local function createLobbyCamera(ped)
    local cameraConfig = Config.Camera or {}
    local camPosition = getCameraPoint(ped, cameraConfig.offset or {})
    local lookAt = getCameraPoint(ped, cameraConfig.lookAt or { up = 0.9 })

    lobbyCam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    SetCamCoord(lobbyCam, camPosition.x, camPosition.y, camPosition.z)
    PointCamAtCoord(lobbyCam, lookAt.x, lookAt.y, lookAt.z)
    SetCamFov(lobbyCam, cameraConfig.fov or 38.0)
    SetCamActive(lobbyCam, true)
    RenderScriptCams(true, true, cameraConfig.transitionMs or 650, true, true)
end

local function equipPreviewWeapon(ped)
    local weaponName = Config.PreviewWeapon
    if type(weaponName) ~= 'string' or weaponName == '' then
        return nil, false
    end

    local weaponHash = GetHashKey(weaponName)
    local alreadyOwned = HasPedGotWeapon(ped, weaponHash, false)
    local addedForPreview = false

    if not alreadyOwned and Config.GivePreviewWeaponIfMissing then
        GiveWeaponToPed(ped, weaponHash, Config.PreviewAmmo or 0, false, true)
        addedForPreview = HasPedGotWeapon(ped, weaponHash, false)
    end

    if HasPedGotWeapon(ped, weaponHash, false) then
        SetCurrentPedWeapon(ped, weaponHash, true)
    end

    return weaponHash, addedForPreview
end

local function closeMenu(silent)
    if not menuOpen then
        return
    end

    menuOpen = false
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)

    if not silent then
        SendNUIMessage({ action = 'close' })
    end

    if savedPlayerState and DoesEntityExist(savedPlayerState.ped) then
        local ped = savedPlayerState.ped

        if savedPlayerState.addedPreviewWeapon
            and Config.RemovePreviewWeaponOnClose
            and savedPlayerState.previewWeaponHash then
            RemoveWeaponFromPed(ped, savedPlayerState.previewWeaponHash)
        end

        if savedPlayerState.selectedWeapon then
            SetCurrentPedWeapon(ped, savedPlayerState.selectedWeapon, true)
        end

        if Config.FreezePlayerWhileOpen then
            FreezeEntityPosition(ped, savedPlayerState.wasFrozen or false)
        end
    end

    local transitionMs = (Config.Camera and Config.Camera.transitionMs) or 650
    RenderScriptCams(false, true, transitionMs, true, true)

    if lobbyCam and DoesCamExist(lobbyCam) then
        SetCamActive(lobbyCam, false)
        DestroyCam(lobbyCam, false)
    end

    lobbyCam = nil
    savedPlayerState = nil
end

local function openMenu()
    if menuOpen then
        closeMenu(false)
        return
    end

    local playerId = PlayerId()
    local ped = PlayerPedId()
    if ped == 0 or not DoesEntityExist(ped) or IsEntityDead(ped) then
        return
    end

    menuOpen = true
    savedPlayerState = {
        ped = ped,
        selectedWeapon = GetSelectedPedWeapon(ped),
        wasFrozen = IsEntityPositionFrozen(ped),
        addedPreviewWeapon = false,
        previewWeaponHash = nil
    }

    if Config.FreezePlayerWhileOpen then
        FreezeEntityPosition(ped, true)
    end

    local weaponHash, addedPreviewWeapon = equipPreviewWeapon(ped)
    savedPlayerState.previewWeaponHash = weaponHash
    savedPlayerState.addedPreviewWeapon = addedPreviewWeapon

    createLobbyCamera(ped)
    SetNuiFocus(true, true)
    SetNuiFocusKeepInput(false)

    SendNUIMessage({
        action = 'open',
        playerName = GetPlayerName(playerId) or 'Player',
        serverId = GetPlayerServerId(playerId),
        menuTitle = Config.MenuTitle or 'NEON DISTRICT',
        serverLabel = Config.ServerLabel or 'LOS SANTOS',
        weaponLabel = Config.PreviewWeapon and (Config.PreviewWeaponLabel or Config.PreviewWeapon) or 'NO WEAPON'
    })
end

RegisterCommand(Config.Command or 'menu', function()
    openMenu()
end, false)

if Config.EnableKeyMapping then
    RegisterKeyMapping(Config.Command or 'menu', 'Open / close the Neon District lobby', 'keyboard', Config.DefaultKey or 'F7')
end

RegisterNUICallback('close', function(_, callback)
    closeMenu(false)
    callback({ ok = true })
end)

CreateThread(function()
    while true do
        if menuOpen then
            Wait(0)
            HideHudAndRadarThisFrame()
            DisablePlayerFiring(PlayerId(), true)

            if IsEntityDead(PlayerPedId()) then
                closeMenu(false)
            end
        else
            Wait(300)
        end
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        closeMenu(true)
    end
end)
