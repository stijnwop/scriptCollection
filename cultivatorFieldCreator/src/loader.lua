---
-- loader
--
-- loader script for the mod
--
-- Copyright (c) Wopster, 2019

local directory = g_currentModDirectory
local modName = g_currentModName

source(Utils.getFilename("src/LimitToFieldEvent.lua", directory))

function init()
    VehicleTypeManager.validateVehicleTypes = Utils.prependedFunction(VehicleTypeManager.validateVehicleTypes, initSpecialization)
end

function initSpecialization()
    g_specializationManager:addSpecialization("cultivatorFieldCreator", "CultivatorFieldCreator", Utils.getFilename("src/CultivatorFieldCreator.lua", directory), nil) -- Nil is important here

    for typeName, typeEntry in pairs(g_vehicleTypeManager:getVehicleTypes()) do
        if SpecializationUtil.hasSpecialization(Cultivator, typeEntry.specializations) then
            g_vehicleTypeManager:addSpecialization(typeName, modName .. ".cultivatorFieldCreator")
        end
    end
end

init()
