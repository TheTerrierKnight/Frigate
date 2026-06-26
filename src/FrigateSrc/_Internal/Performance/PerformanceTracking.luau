--[[
	Internal utils for debugging/tracking package code.
	The functionality of this module is reserved for internal use.
]]

local PerformanceTracking = {}

function PerformanceTracking.ApplyCallTag(tag: string, func: (...any) -> ()): ()
	debug.profilebegin(tag)
	func()
	debug.profileend()
end

return PerformanceTracking
