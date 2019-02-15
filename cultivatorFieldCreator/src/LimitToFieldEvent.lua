--
-- LimitToFieldEvent
--
-- Limit to field event to handle field creation for other clients.
--
-- Copyright (c) Wopster, 2019

LimitToFieldEvent = {}

local LimitToFieldEvent_mt = Class(LimitToFieldEvent, Event)

InitEventClass(LimitToFieldEvent, "LimitToFieldEvent")

function LimitToFieldEvent:emptyNew()
    local self = Event:new(LimitToFieldEvent_mt)

    return self
end

function LimitToFieldEvent:new(object, limitToField)
    local self = LimitToFieldEvent:emptyNew()

    self.object = object
    self.limitToField = limitToField

    return self
end

function LimitToFieldEvent:writeStream(streamId, connection)
    NetworkUtil.writeNodeObject(streamId, self.object)
    streamWriteBool(streamId, self.limitToField)
end

function LimitToFieldEvent:readStream(streamId, connection)
    self.object = NetworkUtil.readNodeObject(streamId)
    self.limitToField = streamReadBool(streamId)
    self:run(connection)
end

function LimitToFieldEvent:run(connection)
    self.object:setLimitToField(self.limitToField, true)

    if not connection:getIsServer() then
        g_server:broadcastEvent(LimitToFieldEvent:new(self.object, self.limitToField), nil, connection, self.object)
    end
end
