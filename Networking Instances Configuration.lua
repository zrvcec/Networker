--!strict
--!nolint LocalShadow

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Instance = Instance

local Server = RunService:IsServer()
local Client = RunService:IsClient()

local MyNetworkTypes = require("././MyNetworkerTypes")
local Configuration = require("././Configuration")

local RemoteEventHandler = {}
RemoteEventHandler.__index = RemoteEventHandler

function RemoteEventHandler:FireClient(...)
	local self = self :: MyNetworkTypes.RemoteEventHandler
	local Event = self.Event

	assert(Server, "Firing to Client must be sent from Server " .. self.DestinedName)
	assert(Event::any ~= nil, "RemoteEvent is nil: ".. self.DestinedName) 
	Event:FireClient(...)
end

function RemoteEventHandler:FireAllClients(...)
	local self = self :: MyNetworkTypes.RemoteEventHandler
	local Event = self.Event

	assert(Server, "Firing to Client must be sent from Client " .. self.DestinedName)
	assert(Event::any ~= nil, "RemoteEvent is nil: ".. self.DestinedName) 
	Event:FireAllClients(...)
end

function RemoteEventHandler:FireServer(...)
	local self = self :: MyNetworkTypes.RemoteEventHandler
	local Event = self.Event

	assert(Client == true, "Firing to Server must be sent from Client " .. self.DestinedName)
	assert(Event::any ~= nil, "RemoteEvent is nil: ".. self.DestinedName)
	Event:FireServer(...)
end


local UnreliableRemoteEventHandler = {}
UnreliableRemoteEventHandler.__index = UnreliableRemoteEventHandler

function UnreliableRemoteEventHandler:FireClient(...)
	local self = self :: MyNetworkTypes.UnreliableRemoteEventHandler
	local Event = self.Event

	assert(Client == false, "Firing to Client must be sent from Client " .. self.DestinedName)
	assert(Event::any ~= nil, "UnreliableRemoteEvent is nil: ".. self.DestinedName) 
	Event:FireClient(...)	
end

function UnreliableRemoteEventHandler:FireAllClients(...)
	local self = self :: MyNetworkTypes.UnreliableRemoteEventHandler
	local Event = self.Event

	assert(Client == false, "Firing to Client must be sent from Client " .. self.DestinedName)
	assert(Event::any ~= nil, "UnreliableRemoteEvent is nil: ".. self.DestinedName) 
	Event:FireAllClients(...)
end

function UnreliableRemoteEventHandler:FireServer(...)
	local self = self :: MyNetworkTypes.UnreliableRemoteEventHandler
	local Event = self.Event

	assert(Client == true, "Firing to Server must be sent from Client " .. self.DestinedName)
	assert(Event::any ~= nil, "UnreliableRemoteEvent is nil: ".. self.DestinedName)

	Event:FireServer(...)
end


local RemoteFunctionHandler = {}
RemoteFunctionHandler.__index = RemoteFunctionHandler

function RemoteFunctionHandler:InvokeServer(...)
	local self = self :: MyNetworkTypes.RemoteFunctionHandler
	local Event = self.Event

	assert(Client == true, "Invoke requests to the Server can only done via client! " .. self.DestinedName)
	assert(Event::any ~= nil, "RemoteFunction is nil: ".. self.DestinedName)
	local result 

	local success, error = pcall(function(...)
		result = Event:InvokeServer(...)
	end, ...)

	if not success then
		warn(error)
	end

	return result
end

function RemoteFunctionHandler:InvokeClient(...)
	local self = self :: MyNetworkTypes.RemoteFunctionHandler
	local Event = self.Event

	assert(Client == false, "Invoke requests to the Client can only done via Server! " .. self.DestinedName)
	assert(Event::any ~= nil, "RemoteFunction is nil: ".. self.DestinedName)
	local result 

	local success, error = pcall(function(...)
		result = Event:InvokeClient(...)
	end, ...)

	if not success then
		warn(error)
	end

	return result
end


local BindableEventHandler = {}
BindableEventHandler.__index = BindableEventHandler

function BindableEventHandler:Fire(...)
	local self = self :: MyNetworkTypes.BindableEventHandler
	local Event = self.Event

	assert(Event::any ~= nil, "BindableEvent is nil: ".. self.DestinedName)

	Event:Fire(...)
end



local BindableFunctionHandler = {}
BindableFunctionHandler.__index = BindableFunctionHandler

function BindableFunctionHandler:Invoke(...)
	local self = self :: MyNetworkTypes.BindableFunctionHandler
	local Event = self.Event

	assert(Event::any ~= nil, "BindableEvent is nil: ".. self.DestinedName)

	local result 

	local success, error = pcall(function(...)
		result = Event:Invoke(...)
	end, ...)

	if not success then
		warn(error)
	end

	return result
end

local Events = {}
Events.CompiledEvents = {}

Events.EventTypeToEvent = {
	[1] = Instance.new("RemoteEvent"),
	[2] = Instance.new("UnreliableRemoteEvent"),
	[3] = Instance.new("RemoteFunction"),
	[4] = Instance.new("BindableEvent"),
	[5] = Instance.new("BindableFunction"),
}:: {[number]: Instance}


Events.EventTypeSortedLocations = {
	[1] = ReplicatedStorage:FindFirstChild("Networks"),
	[2] = ReplicatedStorage:FindFirstChild("Networks"),
	[3] = ReplicatedStorage:FindFirstChild("Networks"),
	[4] = ReplicatedStorage:FindFirstChild("Networks"),
	[5] = ReplicatedStorage:FindFirstChild("Networks"),
} 

local ListSelectorByType = {
	[1] = RemoteEventHandler,
	[2] = UnreliableRemoteEventHandler,
	[3] = RemoteFunctionHandler,
	[4] = BindableEventHandler,
	[5] = BindableFunctionHandler,
}:: {[number]: any}

local AllowedClasses = {
	RemoteEvent = true,
	UnreliableRemoteEvent = true,
	RemoteFunction = true,
	BindableEvent = true,
	BindableFunction = true,
}

Events.EventType = Configuration.EventType
Events._init = Configuration._init :: {[string]: typeof(Configuration._init.TestID)}

local function CompilePackage(EventName: string, package: typeof(Events._init.TestID)): TypeOfCompilePackage 
	local List = ListSelectorByType[package.Type]
	local Event = Events.EventTypeToEvent[package.Type]
	local EventParent = Events.EventTypeSortedLocations[package.Type] ::Instance

	assert(List ~= nil, "List type could not be found by type: ".. package.Type)
	assert(Event~=nil::any, "Event could not be found by event type")
	assert(EventParent ~= nil::any, "Event Parent could not be found")


	local self = setmetatable({}, List)

	local NewEvent = Instance.fromExisting(Event)

	if Client then

		NewEvent = EventParent:WaitForChild(EventName, 30) :: Instance

		assert(NewEvent ~= nil::any, "Could not find event")

		local Allowed = AllowedClasses[NewEvent.ClassName] or false

		assert(Allowed, "This event is not allowed. ".. NewEvent.ClassName)

	else
		NewEvent.Name = EventName
		NewEvent.Parent = EventParent
	end

	self.Event = NewEvent
	self.Type = package.Type	
	self.DestinedName = EventName
	self.Keys = package.Keys

	return self
end

type TypeOfCompilePackage = typeof(CompilePackage(nil :: any, nil :: any))

function Events.init()

	for eventName: string, package: typeof(Events._init.TestID) in pairs(Events._init) do
		local compiledPackage = CompilePackage(eventName, package)

		Events.CompiledEvents[package.Type] = Events.CompiledEvents[package.Type] or {}

		assert(Events.CompiledEvents[package.Type][eventName] == nil, "DuplicateEventNameFound for event: ".. eventName)


		Events.CompiledEvents[package.Type][eventName] = compiledPackage
	end
end


return Events