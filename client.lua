local menuOpen = false
local lobbyCam = nil
local previewPed = nil
local savedPlayerState = nil

local function getPedBounds(ped)
    local coords = GetEntityCoords(ped)
    local head = GetPedBoneCoords(ped, 31086, 0.0, 0.0, 0.0)
    local leftFoot = GetPedBoneCoords(ped, 14201, 0.0, 0.0, 0.0)
    local rightFoot = GetPedBoneCoords(ped, 52301, 0.0, 0.0, 0.0)
    local footZ = math.min(leftFoot.z, rightFoot.z)
    local height = head.z - footZ
    local centerOffsetZ = ((head.z + footZ) * 0.5) - coords.z

    if height < 0.75 or height > 4.0 then
        local minDimensions, maxDimensions = GetModelDimensions(GetEntityModel(ped))
        height = maxDimensions.z - minDimensions.z
        centerOffsetZ = (minDimensions.z + maxDimensions.z) * 0.5
    end

    if height < 0.75 or height > 4.0 then
        height = 1.8
        centerOffsetZ = 0.9
    end

    return height, centerOffsetZ
end

local function getCameraPoint(ped, rightOffset, forwardOffset, upOffset)
    local coords = GetEntityCoords(ped)
    local forward = GetEntityForwardVector(ped)
    local right = vector3(forward.y, -forward.x, 0.0)

    return vector3(
        coords.x + right.x * rightOffset + forward.x * forwardOffset,
        coords.y + right.y * rightOffset + forward.y * forwardOffset,
        coords.z + upOffset
    )
end

local function createPreviewPed(sourcePed)
    -- ClonePed copies the player's current model, head blend, clothing, props,
    -- and appearance. This local-only clone is removed when the menu closes.
    local clone = ClonePed(sourcePed, false, false, true)
    if not clone or clone == 0 or not DoesEntityExist(clone) then
        return nil
    end

    local sourceCoords = GetEntityCoords(sourcePed)
    local sourceForward = GetEntityForwardVector(sourcePed)
    local previewOffset = (Config.Camera and Config.Camera.previewOffset) or {}
    local previewForward = previewOffset.forward or 1.5
    local previewRight = previewOffset.right or 0.0
    local right = vector3(sourceForward.y, -sourceForward.x, 0.0)

    SetEntityAsMissionEntity(clone, true, true)
    SetEntityCoordsNoOffset(
        clone,
        sourceCoords.x + sourceForward.x * previewForward + right.x * previewRight,
        sourceCoords.y + sourceForward.y * previewForward + right.y * previewRight,
        sourceCoords.z,
        false, false, false
    )
    SetEntityHeading(clone, GetEntityHeading(sourcePed))
    SetEntityVisible(clone, true, false)
    ResetEntityAlpha(clone)
    SetEntityInvincible(clone, true)
    SetEntityCanBeDamaged(clone, false)
    SetBlockingOfNonTemporaryEvents(clone, true)
    SetPedCanRagdoll(clone, false)
    ClearPedTasksImmediately(clone)
    FreezeEntityPosition(clone, true)
    SetEntityLodDist(clone, 1000)

    return clone
end

local function createLobbyCamera(ped)
    local cameraConfig = Config.Camera or {}
    local height, centerOffsetZ = getPedBounds(ped)
    local distance = height * (cameraConfig.distanceMultiplier or 2.35)
    local cameraHeight = centerOffsetZ + height * (cameraConfig.cameraHeightRatio or 0.12)
    local targetHeight = centerOffsetZ + height * (cameraConfig.lookAtHeightRatio or 0.0)
    local cameraRight = cameraConfig.cameraRight or 0.0
    local targetRight = cameraConfig.targetRight or 0.0

    local camPosition = getCameraPoint(ped, cameraRight, distance, cameraHeight)
    local lookAt = getCameraPoint(ped, targetRight, 0.0, targetHeight)

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

    if savedPlayerState and DoesEntityExist(savedPlayerState.ped) and Config.FreezePlayerWhileOpen then
        FreezeEntityPosition(savedPlayerState.ped, savedPlayerState.wasFrozen or false)
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

    -- Let the clone finish its first world update before calculating camera
    -- coordinates. This also supports streamed/custom player models.
    if previewPed ~= ped then
        Wait(0)
        if DoesEntityExist(previewPed) then
            SetEntityVisible(previewPed, true, false)
            ResetEntityAlpha(previewPed)
        end
    end

    createLobbyCamera(previewPed)
    print(('[neon_lobby] Player preview model: source=%s preview=%s cloned=%s'):format(
        GetEntityModel(ped),
        GetEntityModel(previewPed),
        tostring(previewPed ~= ped)
    ))

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

            if previewPed and DoesEntityExist(previewPed) then
                SetEntityVisible(previewPed, true, false)
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
