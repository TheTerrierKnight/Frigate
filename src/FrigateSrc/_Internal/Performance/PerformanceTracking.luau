--[[
	Internal utils for debugging/tracking package code.
	The functionality of this module is reserved for internal use.
]]

local PerformanceTracking = {}

function PerformanceTracking.ApplyCallTag(tag: string, func: (...any) -> ()): ()
	debug.profilebegin(tag)
	local capture = table.pack(func())
	debug.profileend()
	return table.unpack(capture, 1, #capture)
end

return PerformanceTracking
