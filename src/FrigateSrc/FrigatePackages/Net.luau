--[[
	General purpose networking implementation alongside additional gadgets/utils.
]]

local net = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Root = script.Parent.Parent
local Packages = Root.Parent.Packages
local InternalPackages = Root._Internal

local InternalFlags = require(InternalPackages.InternalFlags)
local Logger = require(Root.Utilites.Logger)
local Promise = require(Packages.promise)

local _NETWORK_FOLDER = ReplicatedStorage:WaitForChild("_FRIGATE_NET", 2) or nil
local _LOGGER_PREFIX = "NET"

if _NETWORK_FOLDER == nil and RunService:IsServer() then
	local Folder = Instance.new("Folder")
	Folder.Name = "_FRIGATE_NET"
	Folder.Parent = ReplicatedStorage
	_NETWORK_FOLDER = Folder
end

--[[
	Creates a Network Unit to store network objects under. This method is server-only.
	This method yields and returns a non-cancelable promise that will contain either the object (if sucessful) or an error code (if failed).
]]
function net.CreateNetworkUnitAsync(UnitName: string)
	return Promise.new(function(resolve, reject)
		if not RunService:IsServer() then
			reject("CreateNetworkUnitAsync must be called by the server.")
		end

		if _NETWORK_FOLDER:FindFirstChild(UnitName) ~= nil then
			reject("The provided name is reserved.")
			Logger.LogToConsole({
				prefix = _LOGGER_PREFIX,
				message = UnitName .. " Is reserved and cannot be created due to conflict.",
				mode = Enum.MessageType.MessageWarning,
			})
		end

		local Unit = Instance.new("Folder")
		Unit.Parent = _NETWORK_FOLDER
		Unit.Name = UnitName

		resolve(Unit)
	end)
end

--[[
	Returns the NetworkUnit with the associated name.
	This method yields and returns a non-cancelable promise that will contain either the object (if sucessful) or an error code (if failed).
]]
function net.GetNetworkUnitAsync(UnitName: string)
	return Promise.new(function(resolve, reject)
		if _NETWORK_FOLDER:FindFirstChild(UnitName) == nil then
			reject("The Unit provided does not exist.")
		else
			resolve(_NETWORK_FOLDER[UnitName])
		end
	end)
end

--[[
	Creates a RemoteEvent under the provided NetworkUnit. This method is server-only.
]]
function net.CreateRemote(NetworkUnit: string, RemoteName: string)
	if not RunService:IsServer() then
		Logger.LogToConsole({
			prefix = _LOGGER_PREFIX,
			message = "CreateRemote must be called by the server.",
			mode = Enum.MessageType.MessageError,
		})
		return
	end

	local Success, Result = net.GetNetworkUnitAsync(NetworkUnit):await()

	if Success then
		local Remote

		if InternalFlags["FF_SetUnreliableBehavior"] and InternalFlags["FF_SetUnreliableBehavior"].state == true then
			Remote = Instance.new("UnreliableRemoteEvent")
		else
			Remote = Instance.new("RemoteEvent")
		end

		if InternalFlags["FF_ForceNameOverride"] and InternalFlags["FF_ForceNameOverride"].state then
			Remote.Name = InternalFlags["FF_ForceNameOverride"].state
		else
			Remote.Name = RemoteName
		end

		Remote:SetAttribute("_FRIGATE_GEN", 1)
		Remote.Parent = Result
	else
		Logger.LogToConsole({
			prefix = _LOGGER_PREFIX,
			message = "An error while getting NetworkUnit " .. NetworkUnit .. " occured: " .. Result,
			mode = Enum.MessageType.MessageError,
		})
		return
	end
end

--[[
	Returns the Remote with the associated name.
	This method yields and returns a non-cancelable promise that will contain either the object (if sucessful) or an error code (if failed).
]]
function net.GetRemoteAsync(UnitName: string, RemoteName: string)
	return Promise.new(function(resolve, reject)
		if _NETWORK_FOLDER:FindFirstChild(UnitName) == nil then
			reject("The Unit provided does not exist.")
		else
			if _NETWORK_FOLDER[UnitName]:FindFirstChild(RemoteName) then
				if
					_NETWORK_FOLDER[UnitName][RemoteName]:IsA("RemoteEvent")
					or _NETWORK_FOLDER[UnitName][RemoteName]:IsA("UnreliableRemoteEvent")
				then
					resolve(_NETWORK_FOLDER[UnitName][RemoteName])
				else
					reject("The requested object is not a Remote.")
				end
			else
				reject("The Remote provided does not exist.")
			end
		end
	end)
end

--[[
	Creates a RemoteFunction under the provided NetworkUnit. This method is server-only.
]]
function net.CreateFunction(NetworkUnit: string, FunctionName: string)
	if not RunService:IsServer() then
		Logger.LogToConsole({
			prefix = _LOGGER_PREFIX,
			message = "CreateFunction must be called by the server.",
			mode = Enum.MessageType.MessageError,
		})
		return
	end

	local Success, Result = net.GetNetworkUnitAsync(NetworkUnit):await()

	if Success then
		local Function = Instance.new("RemoteFunction")

		Function.Name = FunctionName
		Function:SetAttribute("_FRIGATE_GEN", 1)
		Function.Parent = Result
	else
		Logger.LogToConsole({
			prefix = _LOGGER_PREFIX,
			message = "An error while getting NetworkUnit " .. NetworkUnit .. " occured: " .. Result,
			mode = Enum.MessageType.MessageError,
		})
		return
	end
end

--[[
	Returns the Function with the associated name.
	This method yields and returns a non-cancelable promise that will contain either the object (if sucessful) or an error code (if failed).
]]
function net.GetFunctionAsync(UnitName: string, FunctionName: string)
	return Promise.new(function(resolve, reject)
		if _NETWORK_FOLDER:FindFirstChild(UnitName) == nil then
			reject("The Unit provided does not exist.")
		else
			if _NETWORK_FOLDER[UnitName]:FindFirstChild(FunctionName) then
				if _NETWORK_FOLDER[UnitName][FunctionName]:IsA("RemoteFunction") then
					resolve(_NETWORK_FOLDER[UnitName][FunctionName])
				else
					reject("The requested object is not a Function.")
				end
			else
				reject("The Remote provided does not exist.")
			end
		end
	end)
end

--[[
	Binds the provided function to a RemoteEvent/UnreliableRemoteEvent/RemoteFunction. This method is server-only.
	This method yields and returns a non-cancelable promise that will contain an empty string (if sucessful) or an error code (if failed).
]]
function net.BindCallAsync(RemoteObject: RemoteFunction | RemoteEvent | UnreliableRemoteEvent, func: (...any) -> ())
	return Promise.new(function(resolve, reject)
		if not RunService:IsServer() then
			reject("BindCallAsync must be called by the server.")
		end

		if RemoteObject:GetAttribute("_FRIGATE_GEN") == nil then
			reject("RemoteObject was not created by Frigate and cannot be safely binded to.")
		end

		if RemoteObject:IsA("RemoteEvent") or RemoteObject:IsA("UnreliableRemoteEvent") then
			RemoteObject.OnServerEvent:Connect(func)
		elseif RemoteObject:IsA("RemoteFunction") then
			RemoteObject.OnServerInvoke = func
		else
			reject("RemoteObject is invalid.")
		end
		resolve("")
	end)
end

--[[
	Binds the provided function soo that will be called if the associated RemoteEvent/UnreliableRemoteEvent/RemoteFunction is invoked by the server. This method is client-only.
	This method yields and returns a non-cancelable promise that will contain an empty string (if sucessful) or an error code (if failed).
]]
function net.BindReceiveAsync(RemoteObject: RemoteFunction | RemoteEvent | UnreliableRemoteEvent, func: (...any) -> ())
	return Promise.new(function(resolve, reject)
		if not RunService:IsClient() then
			reject("BindReceiveAsync must be called by the client.")
		end

		if RemoteObject:GetAttribute("_FRIGATE_GEN") == nil then
			reject("RemoteObject was not created by Frigate and cannot be safely binded to.")
		end

		if RemoteObject:IsA("RemoteEvent") or RemoteObject:IsA("UnreliableRemoteEvent") then
			RemoteObject.OnClientEvent:Connect(func)
		elseif RemoteObject:IsA("RemoteFunction") then
			RemoteObject.OnClientInvoke = func
		else
			reject("RemoteObject is invalid.")
		end
		resolve("")
	end)
end

return net
