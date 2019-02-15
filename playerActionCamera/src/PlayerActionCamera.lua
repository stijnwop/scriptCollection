--
-- PlayerActionCamera
--
-- Authors: Wopster
-- Description: controls the player camera ingame, inspired from the PlayerCamera mod from Planet-LS
--
-- Copyright (c) Wopster, 2018

PlayerActionCamera = {}

PlayerActionCamera.VANILLA_FOV_ANGLE = nil
PlayerActionCamera.FOV_ANGLE = PlayerActionCamera.VANILLA_FOV_ANGLE
PlayerActionCamera.FOV_ANGLE_STEP = math.rad(1)
PlayerActionCamera.FOV_ANGLE_MIN_DEG = math.rad(1)
PlayerActionCamera.FOV_ANGLE_MAX_DEG = math.rad(179)
PlayerActionCamera.VANILLA_PLAYER_CAM_Y_HEIGHT = nil
PlayerActionCamera.PLAYER_CAM_Y_HEIGHT = PlayerActionCamera.VANILLA_PLAYER_CAM_Y_HEIGHT
PlayerActionCamera.PLAYER_CAM_Y_STEP = .25

---
-- Handles the camera field of view Y radian
-- @param camera
--
function PlayerActionCamera.handleCameraFovY(camera)
    if PlayerActionCamera.VANILLA_FOV_ANGLE == nil then
        PlayerActionCamera.VANILLA_FOV_ANGLE = getFovY(camera)
        PlayerActionCamera.FOV_ANGLE = PlayerActionCamera.VANILLA_FOV_ANGLE
    end

    local fovAngle = PlayerActionCamera.FOV_ANGLE

    if Input.isMouseButtonPressed(Input.MOUSE_BUTTON_WHEEL_UP) then
        fovAngle = math.max(fovAngle - PlayerActionCamera.FOV_ANGLE_STEP, PlayerActionCamera.FOV_ANGLE_MIN_DEG)
    elseif Input.isMouseButtonPressed(Input.MOUSE_BUTTON_WHEEL_DOWN) then
        fovAngle = math.min(fovAngle + PlayerActionCamera.FOV_ANGLE_STEP, PlayerActionCamera.FOV_ANGLE_MAX_DEG)
    elseif Input.isMouseButtonPressed(Input.MOUSE_BUTTON_MIDDLE) then
        fovAngle = PlayerActionCamera.VANILLA_FOV_ANGLE
    end

    if fovAngle ~= PlayerActionCamera.FOV_ANGLE then
        setFovY(camera, fovAngle)
        PlayerActionCamera.FOV_ANGLE = fovAngle
    end
end

---
-- Handles the player Y translation
-- @param player
--
function PlayerActionCamera.handleCameraY(player)
    if PlayerActionCamera.VANILLA_PLAYER_CAM_Y_HEIGHT == nil then
        PlayerActionCamera.VANILLA_PLAYER_CAM_Y_HEIGHT = player.camY
        PlayerActionCamera.PLAYER_CAM_Y_HEIGHT = PlayerActionCamera.VANILLA_PLAYER_CAM_Y_HEIGHT
    end

    local camY = PlayerActionCamera.PLAYER_CAM_Y_HEIGHT

    if Input.isMouseButtonPressed(Input.MOUSE_BUTTON_WHEEL_UP) then
        camY = math.max(camY - PlayerActionCamera.PLAYER_CAM_Y_STEP, -PlayerActionCamera.VANILLA_PLAYER_CAM_Y_HEIGHT)
    elseif Input.isMouseButtonPressed(Input.MOUSE_BUTTON_WHEEL_DOWN) then
        camY = camY + PlayerActionCamera.PLAYER_CAM_Y_STEP
    elseif Input.isMouseButtonPressed(Input.MOUSE_BUTTON_MIDDLE) then
        camY = PlayerActionCamera.VANILLA_PLAYER_CAM_Y_HEIGHT
    end

    if camY ~= PlayerActionCamera.PLAYER_CAM_Y_HEIGHT then
        player.camY = camY
        PlayerActionCamera.PLAYER_CAM_Y_HEIGHT = camY
    end
end

---
--
function PlayerActionCamera:update()
    if not g_currentMission:getIsClient()
            or not g_currentMission.controlPlayer
            or g_gui:getIsGuiVisible() then
        return
    end

    local player = g_currentMission.player
    if player ~= nil then
        if Input.isMouseButtonPressed(Input.MOUSE_BUTTON_RIGHT) then
            PlayerActionCamera.handleCameraFovY(player.cameraNode)
        else
            PlayerActionCamera.handleCameraY(player)
        end
    end
end

addModEventListener(PlayerActionCamera)
