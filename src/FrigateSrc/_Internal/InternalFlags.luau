--[[
    Used to configure package/experimental behavior.
	The functionality of this module is reserved for internal use.
]]

local InternalTypes = script.Parent.InternalTypes

local flags: { [string]: InternalTypes.LxAttribute } = {
	["FF_SetUnreliableBehavior"] = {
		scope = "NET",
		state = false,
	},
	["FF_ForceNameOverride"] = {
		scope = "NET",
		state = nil,
	},
}

return flags
