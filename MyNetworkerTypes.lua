local Configuration = require("././Configuration")
type ConfigHandler = typeof(Configuration._init)

export type RemoteEventHandler = {
	Type: typeof(1),
	Event: RemoteEvent,
	DestinedName: string,


	FireClient: (self: RemoteEventHandler, player: Player, ...any) -> (),
	FireAllClients: (self: RemoteEventHandler, ...any) -> (),
	FireServer: (self: RemoteEventHandler, ...any) -> (),
}

export type UnreliableRemoteEventHandler = {
	Type: typeof(2),
	Event: UnreliableRemoteEvent,
	DestinedName: string,

	FireClient: (self: UnreliableRemoteEventHandler, player: Player, ...any) -> (),
	FireAllClients: (self: UnreliableRemoteEventHandler, ...any) -> (),
	FireServer: (self: UnreliableRemoteEventHandler, ...any) -> (),
}

export type RemoteFunctionHandler = {
	Type: typeof(3),
	Event: RemoteFunction,
	DestinedName: string,

	OnServerInvoke: ((player: Player, ...any) -> ...any)?,
	OnClientInvoke: ((...any) -> ...any)?,

	InvokeServer: (self: RemoteFunctionHandler, ...any) -> ...any,
	InvokeClient: (self: RemoteFunctionHandler, player: Player, ...any) -> ...any,
}

export type BindableEventHandler = {
	Type: typeof(4),
	Event: BindableEvent,
	DestinedName: string,


	Fire: (self: BindableEventHandler, ...any) -> (),
}

export type BindableFunctionHandler = {
	Type: typeof(5),
	Event: BindableFunction,
	DestinedName: string,

	OnInvoke: ((...any) -> ...any)?,
	Invoke: (self: BindableFunctionHandler, ...any) -> ...any,
}


export type EventIds = "RemoteEvent" | "UnreliableRemoteEvent" | "RemoteFunction" | "BindableEvent" | "BindableFunction"



export type GetFunction =
	((Event: string, EventType: "RemoteEvent") -> (RemoteEventHandler, ConfigHandler))
& ((Event: string, EventType: "UnreliableRemoteEvent") -> (UnreliableRemoteEventHandler, ConfigHandler))
& ((Event: string, EventType: "RemoteFunction") -> (RemoteFunctionHandler, ConfigHandler))
& ((Event: string, EventType: "BindableEvent") -> (BindableEventHandler, ConfigHandler))
& ((Event: string, EventType: "BindableFunction") -> (BindableFunctionHandler, ConfigHandler))

export type StaticCallback = (...any) -> ...any
export type CallbackMap = { [number]: StaticCallback }

export type SetStaticHandlerFunction = (debuggingMode:boolean, callbacksByID: CallbackMap, key: number, ...any) -> ...any

return {}