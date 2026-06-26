--[[
	Frigate, Network Processing Library. (Licensed under Apache-2.0)
	Developed by @TheTerrierKnight

	You should place the package folder in a replicated container that both the client/server can access. ReplicatedStorage is the recommended place for Frigate.
]]

local Root = script
local FrigatePackages = Root.FrigatePackages

-- Return the library methods/packages.
return {
	Net = require(FrigatePackages.Net),
	WebAPIs = {
		Technified = require(FrigatePackages.WebAPI.TechnifiedAPI),
		NeoShift = require(FrigatePackages.WebAPI.NeoShiftAPI),
	},
}
