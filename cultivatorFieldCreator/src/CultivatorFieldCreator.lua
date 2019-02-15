--
-- CultivatorFieldCreator
--
-- Spec that allows field creation for cultivators.
--
-- Copyright (c) Wopster, 2019

CultivatorFieldCreator = {}

local function getSpecName()
    return "spec_FS19_createFieldsWithCultivator.cultivatorFieldCreator"
end

function CultivatorFieldCreator.prerequisitesPresent(specializations)
    return SpecializationUtil.hasSpecialization(Cultivator, specializations)
end

function CultivatorFieldCreator.registerFunctions(vehicleType)
    SpecializationUtil.registerFunction(vehicleType, "setLimitToField", CultivatorFieldCreator.setLimitToField)
end

function CultivatorFieldCreator.registerEventListeners(vehicleType)
    SpecializationUtil.registerEventListener(vehicleType, "onPostLoad", CultivatorFieldCreator)
    SpecializationUtil.registerEventListener(vehicleType, "onUpdate", CultivatorFieldCreator)
    SpecializationUtil.registerEventListener(vehicleType, "onRegisterActionEvents", CultivatorFieldCreator)
end

function CultivatorFieldCreator:onRegisterActionEvents(isActiveForInput, isActiveForInputIgnoreSelection)
    if self.isClient then
        local spec = self[getSpecName()]
        self:clearActionEventsTable(spec.actionEvents)
        if isActiveForInputIgnoreSelection then
            local _, actionEventId = self:addActionEvent(spec.actionEvents, InputAction.IMPLEMENT_EXTRA3, self, CultivatorFieldCreator.actionEventLimitToField, false, true, false, true, nil)
            g_inputBinding:setActionEventTextPriority(actionEventId, GS_PRIO_NORMAL)
        end
    end
end

---Triggered after the vehicle is loaded
---@param savegame table
function CultivatorFieldCreator:onPostLoad(savegame)
    local spec = self.spec_cultivator
    spec.limitToField = true
    spec.forceLimitToField = false
end

---onUpdate
function CultivatorFieldCreator:onUpdate()
    if self.isClient then
        local spec = self[getSpecName()]
        local actionEvent = spec.actionEvents[InputAction.IMPLEMENT_EXTRA3]
        if actionEvent ~= nil then
            local spec_cultivator = self.spec_cultivator
            if not spec_cultivator.forceLimitToField and g_currentMission:getHasPlayerPermission("createFields", self:getOwner()) then
                g_inputBinding:setActionEventActive(actionEvent.actionEventId, true)

                local text = "action_limitToFields"
                if spec_cultivator.limitToField then
                    text = "action_allowCreateFields"
                end

                g_inputBinding:setActionEventText(actionEvent.actionEventId, g_i18n:getText(text))
            else
                g_inputBinding:setActionEventActive(actionEvent.actionEventId, false)
            end
        end
    end
end

---Toggles the cultivator to limit to the field
---@param limitToField boolean
---@param noEventSend boolean
function CultivatorFieldCreator:setLimitToField(limitToField, noEventSend)
    local spec_cultivator = self.spec_cultivator

    if spec_cultivator.limitToField ~= limitToField then
        if noEventSend == nil or noEventSend == false then
            if g_server ~= nil then
                g_server:broadcastEvent(LimitToFieldEvent:new(self, limitToField), nil, nil, self)
            else
                g_client:getServerConnection():sendEvent(LimitToFieldEvent:new(self, limitToField))
            end
        end

        spec_cultivator.limitToField = limitToField

        local spec = self[getSpecName()]
        local actionEvent = spec.actionEvents[InputAction.IMPLEMENT_EXTRA3]
        if actionEvent ~= nil then
            local text = "action_limitToFields"
            if spec_cultivator.limitToField then
                text = "action_allowCreateFields"
            end
            g_inputBinding:setActionEventText(actionEvent.actionEventId, g_i18n:getText(text))
        end
    end
end

---actionEventLimitToField
---@param self table
---@param actionName string
---@param inputValue number
---@param callbackState function
---@param isAnalog boolean
function CultivatorFieldCreator.actionEventLimitToField(self, actionName, inputValue, callbackState, isAnalog)
    local spec = self.spec_cultivator
    if not spec.forceLimitToField then
        self:setLimitToField(not spec.limitToField)
    end
end
