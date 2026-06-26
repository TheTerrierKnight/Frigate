--[[
	Special Internal types.
	The functionality of this module is reserved for internal use.
]]

--[[
	Acts as a feature flag with a optional scope.
]]
export type LxAttribute = {
	scope: string?,
	state: any,
}
