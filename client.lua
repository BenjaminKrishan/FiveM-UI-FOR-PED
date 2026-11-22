local menuOpen = false
local lobbyCam = nil
local previewPed = nil
local savedPlayerState = nil

local function getCameraPoint(ped, offset)
    local coords = GetEntityCoords(ped)
    local forward = GetEntityForwardVector(ped)
    local right = vector3(forward.y, -forward.x, 0.0)

    return vector3(
        coords.x + right.x * (offset.right or 0.0) + forward.x * (offset.forward or 0.0),
        coords.y + right.y * (offset.right or 0.0) + forward.y * (offset.forward or 0.0),
        coords.z + (offset.up or 0.0)
    )
end

local function createPreviewPed(sourcePed)
    -- ClonePed copies the player's current model, head blend, clothing, props,
    -- and appearance. It is local-only and is deleted when the menu closes.
    local clone = ClonePed(sourcePed, false, true, true)
    if not clone or clone == 0 or not DoesEntityExist(clone) then
        return nil
    end

    local coords = GetEntityCoords(sourcePed)
    SetEntityAsMissionEntity(clone, true, true)
    SetEntityCoordsNoOffset(clone, coords.x, coords.y, coords.z, false, false, false)
    SetEntityHeading(clone, GetEntityHeading(sourcePed))
    SetEntityVisible(clone, true, false)
    ResetEntityAlpha(clone)
    SetEntityCollision(clone, false, false)
    SetEntityInvincible(clone, true)
    SetEntityCanBeDamaged(clone, false)
    SetBlockingOfNonTemporaryEvents(clone, true)
    SetPedCanRagdoll(clone, false)
    ClearPedTasksImmediately(clone)
    FreezeEntityPosition(clone, true)

    return clone
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
        return
    end

    local weaponHash = GetHashKey(weaponName)
    if not HasPedGotWeapon(ped, weaponHash, false) and Config.GivePreviewWeaponIfMissing then
        GiveWeaponToPed(ped, weaponHash, Config.PreviewAmmo or 0, false, true)
    end

    if HasPedGotWeapon(ped, weaponHash, false) then
        SetCurrentPedWeapon(ped, weaponHash, true)
    end
end

local function drawPreviewLighting(ped)
    if not Config.PreviewLighting or not DoesEntityExist(ped) then
        return
    end

    local coords = GetEntityCoords(ped)
    local forward = GetEntityForwardVector(ped)
    local right = vector3(forward.y, -forward.x, 0.0)

    -- A soft key light plus subtle cyan/magenta fills keep dark outfits and
    -- custom character models readable while preserving the live 3D ped.
    DrawLightWithRange(
        coords.x + forward.x * 1.75,
        coords.y + forward.y * 1.75,
        coords.z + 1.25,
        245, 244, 255,
        8.0, 2.0
    )
    DrawLightWithRange(
        coords.x + right.x * 1.15 - forward.x * 0.2,
        coords.y + right.y * 1.15 - forward.y * 0.2,
        coords.z + 1.45,
        60, 220, 255,
        5.0, 0.75
    )
    DrawLightWithRange(
        coords.x - right.x * 1.15 - forward.x * 0.2,
        coords.y - right.y * 1.15 - forward.y * 0.2,
        coords.z + 1.35,
        255, 65, 130,
        5.0, 0.65
    )
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
        if Config.FreezePlayerWhileOpen then
            FreezeEntityPosition(savedPlayerState.ped, savedPlayerState.wasFrozen or false)
        end
    end

    if previewPed and previewPed ~= (savedPlayerState and savedPlayerState.ped) and DoesEntityExist(previewPed) then
        DeleteEntity(previewPed)
    end
    previewPed = nil

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
        wasFrozen = IsEntityPositionFrozen(ped)
    }

    if Config.FreezePlayerWhileOpen then
        FreezeEntityPosition(ped, true)
    end

    previewPed = createPreviewPed(ped) or ped
    equipPreviewWeapon(previewPed)
    createLobbyCamera(previewPed)

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

            -- Hide only the original ped locally; other players still see the
            -- real player. The cloned preview model is what the camera renders.
            if savedPlayerState and previewPed ~= savedPlayerState.ped and DoesEntityExist(savedPlayerState.ped) then
                SetEntityLocallyInvisible(savedPlayerState.ped)
            end

            if previewPed and DoesEntityExist(previewPed) then
                drawPreviewLighting(previewPed)
            end

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
