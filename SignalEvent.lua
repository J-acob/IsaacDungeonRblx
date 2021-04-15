local SignalEvent = {}

SignalEvent.__index = SignalEvent

function SignalEvent.new(object)
	
	local newSignalEvent = {}
	
	local self = setmetatable(newSignalEvent, SignalEvent)
	
	
	--This is meant to hold all the connections associated with this Signal Event
	self.EventConnectionTable = {}

	self.Event = Instance.new("BindableEvent")
	
	self.Object = object
	
	self.ObjectConnectionTable = self.Object.ConnectionTable
	--We need to store a reference to our object since we can't pass it via remote functions

	
	return self
	
end


function SignalEvent:AddNewSignal(functionToAdd)
	
	local newFunctionConnection = self.Event.Event:Connect(functionToAdd)
		
	table.insert(self.EventConnectionTable, newFunctionConnection)
	
	
end


--Unsure if this has a ton of functional usage... 
function SignalEvent:RemoveSignal(signalToRemove)
	
	
end


function SignalEvent:Fire()
	
	self.Event:Fire(function() return self.Object end)
	
end


function SignalEvent:ClearConnectionTable()
	
	for i, connection in ipairs(self.EventConnectionTable) do
		
		connection:Disconnect()
		
		self.EventConnectionTable[i] = nil
		
	end
	
end

function SignalEvent:ReturnSignalObject()
	
	return self.Object
	
end

return SignalEvent
