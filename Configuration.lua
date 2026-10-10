local Configuration = {}


Configuration.EventType = {
	RemoteEvent = 1,
	UnReliableRemoteEvent = 2,
	RemoteFunction = 3,

	BindableEvent = 4,
	BindableFunction = 5,
} :: {[string]:number}


Configuration._init = {
	TestID = {
		Type = Configuration.EventType.RemoteEvent,
		Keys = {
			Hello = 1
		}
	}
}

return Configuration
