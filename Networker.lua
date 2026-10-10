--!strict
local Initialized = false
local Initializing = false

local RunService = game:GetService("RunService")
local NetworkingInstances = require("./Networking Instances Configuration")


local Client = RunService:IsClient()
local Server = RunService:IsServer()

local MyNetworkTypes = require("./MyNetworkerTypes")
local Configuration = require("./Configuration")

local Networker = {} :: {
	init: () -> (),
	Get: MyNetworkTypes.GetFunction,
	SetStaticHandler: MyNetworkTypes.SetStaticHandlerFunction,

}
function Networker.init()
	if Initialized then
		return
	end	

	if Initializing == true then
		while not Initialized do
			task.wait(1)
		end
	else
		print("[NETWORKING] Module is being initialized...")
	end

	Initializing = true

	if Server then

		NetworkingInstances.init()
		script:SetAttribute("InitializationComplete", true)

	elseif Client then
		-- Wait for the server initialization to be complete
		while not script:GetAttribute("InitializationComplete") do
			task.wait(.1)
		end
		NetworkingInstances.init()
	end

	Initialized = true
	Initializing = false

	print("[NETWORKING] Module has been initialized!")
end

function Networker.Get<T>(Event:string, EventType: MyNetworkTypes.EventIds): any
	assert(Initializing == false, "Networking is still being initialized.")
	assert(Initialized == true, "Networker is not initialized yet.")

	local ID = Configuration.EventType[EventType]

	assert(ID ~= nil, "Could not find id on: " .. EventType)

	local self:any = NetworkingInstances.CompiledEvents[ID] and NetworkingInstances.CompiledEvents[ID][Event]

	assert(self ~= nil, "Could not recall the specified object" .. ID .. Event)

	return self, Configuration._init
end


function Networker.SetStaticHandler(debuggingMode, tableofCallbacksbyID, key, ...)

end


return Networker