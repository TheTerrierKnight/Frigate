--[[
	Frigate, Network Processing Library. (Licensed under Apache-2.0)
	Developed by @TheTerrierKnight

	You should place the package folder in a replicated container that both the client/server can access. ReplicatedStorage is the recommended place for Frigate.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Root = script
local FrigatePackages = Root.FrigatePackages

-- Set up a Container for storing generated objects in.
if ReplicatedStorage:FindFirstChild("__FRIGATE__") == nil and RunService:IsServer() then
	local StoreFolder = Instance.new("Folder")
	StoreFolder.Name = "__FRIGATE__"
	StoreFolder.Parent = ReplicatedStorage
end

-- Return the library methods/packages.
return {
	Net = require(FrigatePackages.Net),
	WebAPIs = {
		Technified = require(FrigatePackages.WebAPI.TechnifiedAPI),
		NeoShift = require(FrigatePackages.WebAPI.NeoShiftAPI),
	},
}
