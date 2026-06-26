--[[
	API to interact with NeoShift Services.

	Due to NeoShift being a private platform with strict data ingress, many methods will require you to have a local "cookie" or a scoped API key.
	Most methods are also read-only.
]]

local NeoShift = {
	Volatile = {},
	Platform = {},
	Roblox = {},
	Guild = {},
}

--[[
	API Catagories, based off on public/private docs.

    Volatile is reserved for experimental/private/unknown API's.
]]
local NVolatile = NeoShift.Volatile
local NPlatform = NeoShift.Platform
local NGuild = NeoShift.Guild

local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local Root = script.Parent.Parent.Parent
local InternalPackages = Root._Internal

local JsonHttpClient = require(InternalPackages.Network.JsonHttpClient)

local ApiUrls = {
	Auth = "https://neo-shift.xyz/auth",
	General = "https://neo-shift.xyz/api",
	PlatformAdmin = "https://neo-shift.xyz/api/admin",
	Guild = "https://neo-shift.xyz/api/guilds",
}

--[[
    Type for NeoShiftAuthResponse
]]
export type NeoShiftAuthGuilds = {
	id: string,
	name: string,
	icon: string,
	owner: boolean,
	hasWorkspace: boolean,
}

--[[
    Type for NeoShiftAuthResponse
]]
export type NeoShiftAuthUser = {
	id: string,
	username: string,
	avatar: string,
	discriminator: string,
}

--[[
   User authorization object, represents a active user session.
]]
export type NeoShiftAuthResponse = {
	error: string?,
	user: NeoShiftAuthUser?,
	guilds: { NeoShiftAuthGuilds }?,
}

--[[
   Guild authorization object, represents a active user session within a certain guild.
]]
export type NeoShiftGuildAuthResponse = {
	error: string?,
	verified: boolean,
	robloxId: string,
	robloxUsername: string,
	method: string,
}

--[[
   More generalized response object that allows for error handling while respecting different response structures.
]]
export type NeoShiftResponse = {
	error: string?,
} & { [any]: any }

--[[
	Fetches your current authentication session and returns data about you and your guilds. This method is server only.
    For security, this method only allows Secret objects to be provided for authorization.
    This method will contain a status boolean as the first argument with all following arguments relating to the response.

    If failed: false, string (error code)
    If successful: true, table ("user". may contain the following fields: "id", "username", "avatar", "discriminator", these fields contain strings),
    table ("guilds". Contains tables that may contain the following fields: "id", "name", "icon", "owner", "hasWorkspace", these fields contain strings or booleans)
]]
function NVolatile.V1_Me(local_auth: Secret)
	if not RunService:IsServer() then
		return false, "This method is server only."
	end

	local Headers = {
		["Cookie"] = local_auth,
	}

	local Success, Response: JsonHttpClient.HttpResponse? =
		JsonHttpClient.SendRequestAsync(ApiUrls.Auth .. "/me", "GET", nil, Headers):await()

	if Success then
		local Body: NeoShiftAuthResponse = HttpService:JSONDecode(Response.Body)

		if Body.error == nil then
			return true, Body.user, Body.guilds
		else
			return false, Body.error
		end
	else
		return false, Response
	end
end

--[[
	Fetches the current public platform configuration. This method is server only.
    This method will contain a status boolean as the first argument with all following arguments relating to the response.

    If failed: false, string (error code)
    If successful: true, table (may contain any valid JSON)
]]
function NPlatform.V1_GetPublicPlatform()
	if not RunService:IsServer() then
		return false, "This method is server only."
	end

	local Success, Response: JsonHttpClient.HttpResponse? =
		JsonHttpClient.SendRequestAsync(ApiUrls.General .. "/platform/public", "GET", nil, {}):await()

	if Success then
		local Body: NeoShiftResponse = HttpService:JSONDecode(Response.Body)

		if Body.error == nil then
			return true, Body
		else
			return false, Body.error
		end
	else
		return false, Response
	end
end

--[[
	Fetches the current internal platform configuration. This method is server only.
    For security, this method only allows Secret objects to be provided for authorization.
    This method will contain a status boolean as the first argument with all following arguments relating to the response.

    If failed: false, string (error code)
    If successful: true, table (may contain any valid JSON)
]]
function NPlatform.V1_GetAdminInternalPlatformConfiguration(local_auth: Secret)
	if not RunService:IsServer() then
		return false, "This method is server only."
	end

	local Headers = {
		["Cookie"] = local_auth,
	}

	local Success, Response: JsonHttpClient.HttpResponse? =
		JsonHttpClient.SendRequestAsync(ApiUrls.PlatformAdmin .. "/platform", "GET", local_auth, {}):await()

	if Success then
		local Body: NeoShiftResponse = HttpService:JSONDecode(Response.Body)

		if Body.error == nil then
			return true, Body
		else
			return false, Body.error
		end
	else
		return false, Response
	end
end

--[[
	Checks if your session is a platform admin session. This method is server only.
    For security, this method only allows Secret objects to be provided for authorization.
    This method will contain a status boolean as the first argument with all following arguments relating to the response.

    If failed: false, string (error code)
    If successful: true, boolean ("isAdmin")
]]
function NPlatform.V1_CheckAdmin(local_auth: Secret)
	if not RunService:IsServer() then
		return false, "This method is server only."
	end

	local Headers = {
		["Cookie"] = local_auth,
	}

	local Success, Response: JsonHttpClient.HttpResponse? =
		JsonHttpClient.SendRequestAsync(ApiUrls.PlatformAdmin .. "/check", "GET", nil, Headers):await()

	if Success then
		local Body: NeoShiftResponse = HttpService:JSONDecode(Response.Body)

		if Body.error == nil then
			return true, Body["isAdmin"]
		else
			return false, Body.error
		end
	else
		return false, Response
	end
end

--[[
	Returns all changelog patch objects that are set as private. This method is server only.
    For security, this method only allows Secret objects to be provided for authorization.
    This method will contain a status boolean as the first argument with all following arguments relating to the response.

    If failed: false, string (error code)
    If successful: true, table (may contain any valid JSON)
]]
function NPlatform.V1_GetAdminPatchObjects(local_auth: Secret)
	if not RunService:IsServer() then
		return false, "This method is server only."
	end

	local Headers = {
		["Cookie"] = local_auth,
	}

	local Success, Response: JsonHttpClient.HttpResponse? =
		JsonHttpClient.SendRequestAsync(ApiUrls.PlatformAdmin .. "/private-changelog", "GET", nil, Headers):await()

	if Success then
		local Body: NeoShiftResponse = HttpService:JSONDecode(Response.Body)

		if Body.error == nil then
			return true, Body
		else
			return false, Body.error
		end
	else
		return false, Response
	end
end

--[[
	Returns global statistics about NeoShift. This method is server only.
    For security, this method only allows Secret objects to be provided for authorization.
    This method will contain a status boolean as the first argument with all following arguments relating to the response.

    If failed: false, string (error code)
    If successful: true, table (may contain any valid JSON)
]]
function NPlatform.V1_GetGlobalStats(local_auth: Secret)
	if not RunService:IsServer() then
		return false, "This method is server only."
	end

	local Headers = {
		["Cookie"] = local_auth,
	}

	local Success, Response: JsonHttpClient.HttpResponse? =
		JsonHttpClient.SendRequestAsync(ApiUrls.PlatformAdmin .. "/stats", "GET", nil, Headers):await()

	if Success then
		local Body: NeoShiftResponse = HttpService:JSONDecode(Response.Body)

		if Body.error == nil then
			return true, Body
		else
			return false, Body.error
		end
	else
		return false, Response
	end
end

--[[
	Returns all active Guilds in Neoshift. This method is server only.
    For security, this method only allows Secret objects to be provided for authorization.
    This method will contain a status boolean as the first argument with all following arguments relating to the response.

    If failed: false, string (error code)
    If successful: true, table (may contain any valid JSON)
]]
function NPlatform.V1_GetGuilds(local_auth: Secret)
	if not RunService:IsServer() then
		return false, "This method is server only."
	end

	local Headers = {
		["Cookie"] = local_auth,
	}

	local Success, Response: JsonHttpClient.HttpResponse? =
		JsonHttpClient.SendRequestAsync(ApiUrls.PlatformAdmin .. "/guilds", "GET", nil, Headers):await()

	if Success then
		local Body: NeoShiftResponse = HttpService:JSONDecode(Response.Body)

		if Body.error == nil then
			return true, Body
		else
			return false, Body.error
		end
	else
		return false, Response
	end
end

--[[
	Returns all active Blacklists in Neoshift. This method is server only.
    For security, this method only allows Secret objects to be provided for authorization.
    This method will contain a status boolean as the first argument with all following arguments relating to the response.

    If failed: false, string (error code)
    If successful: true, table (may contain any valid JSON)
]]
function NPlatform.V1_GetBlacklists(local_auth: Secret)
	if not RunService:IsServer() then
		return false, "This method is server only."
	end

	local Headers = {
		["Cookie"] = local_auth,
	}

	local Success, Response: JsonHttpClient.HttpResponse? =
		JsonHttpClient.SendRequestAsync(ApiUrls.PlatformAdmin .. "/blacklist", "GET", nil, Headers):await()

	if Success then
		local Body: NeoShiftResponse = HttpService:JSONDecode(Response.Body)

		if Body.error == nil then
			return true, Body
		else
			return false, Body.error
		end
	else
		return false, Response
	end
end

--[[
	Returns recent activity logs in Neoshift. This method is server only.
    For security, this method only allows Secret objects to be provided for authorization.
    This method will contain a status boolean as the first argument with all following arguments relating to the response.

    If failed: false, string (error code)
    If successful: true, table (may contain any valid JSON)
]]
function NPlatform.V1_GetActivityTelemetry(local_auth: Secret)
	if not RunService:IsServer() then
		return false, "This method is server only."
	end

	local Headers = {
		["Cookie"] = local_auth,
	}

	local Success, Response: JsonHttpClient.HttpResponse? =
		JsonHttpClient.SendRequestAsync(ApiUrls.PlatformAdmin .. "/recent-activity", "GET", nil, Headers):await()

	if Success then
		local Body: NeoShiftResponse = HttpService:JSONDecode(Response.Body)

		if Body.error == nil then
			return true, Body
		else
			return false, Body.error
		end
	else
		return false, Response
	end
end

--[[
	Returns private-approved guilds in Neoshift. This method is server only.
    For security, this method only allows Secret objects to be provided for authorization.
    This method will contain a status boolean as the first argument with all following arguments relating to the response.

    If failed: false, string (error code)
    If successful: true, table (may contain any valid JSON)
]]
function NPlatform.V1_GetApprovedGuilds(local_auth: Secret)
	if not RunService:IsServer() then
		return false, "This method is server only."
	end

	local Headers = {
		["Cookie"] = local_auth,
	}

	local Success, Response: JsonHttpClient.HttpResponse? =
		JsonHttpClient.SendRequestAsync(ApiUrls.PlatformAdmin .. "/approved-guilds", "GET", nil, Headers):await()

	if Success then
		local Body: NeoShiftResponse = HttpService:JSONDecode(Response.Body)

		if Body.error == nil then
			return true, Body
		else
			return false, Body.error
		end
	else
		return false, Response
	end
end

--[[
	Returns all global badges in Neoshift. This method is server only.
    For security, this method only allows Secret objects to be provided for authorization.
    This method will contain a status boolean as the first argument with all following arguments relating to the response.

    If failed: false, string (error code)
    If successful: true, table (may contain any valid JSON)
]]
function NPlatform.V1_GetBadges(local_auth: Secret)
	if not RunService:IsServer() then
		return false, "This method is server only."
	end

	local Headers = {
		["Cookie"] = local_auth,
	}

	local Success, Response: JsonHttpClient.HttpResponse? =
		JsonHttpClient.SendRequestAsync(ApiUrls.PlatformAdmin .. "/neo-badges", "GET", nil, Headers):await()

	if Success then
		local Body: NeoShiftResponse = HttpService:JSONDecode(Response.Body)

		if Body.error == nil then
			return true, Body
		else
			return false, Body.error
		end
	else
		return false, Response
	end
end

--[[
	Returns the layout configuration of a Guild. This method is server only.
    For security, this method only allows Secret objects to be provided for authorization.
    This method will contain a status boolean as the first argument with all following arguments relating to the response.

    If failed: false, string (error code)
    If successful: true, table (may contain any valid JSON)
]]
function NGuild.V1_GetLayout(local_auth: Secret, guild_id: string)
	if not RunService:IsServer() then
		return false, "This method is server only."
	end

	local Headers = {
		["Cookie"] = local_auth,
	}

	local Success, Response: JsonHttpClient.HttpResponse? =
		JsonHttpClient.SendRequestAsync(ApiUrls.Guild .. guild_id .. "/overview-layout", "GET", nil, Headers):await()

	if Success then
		local Body: NeoShiftResponse = HttpService:JSONDecode(Response.Body)

		if Body.error == nil then
			return true, Body
		else
			return false, Body.error
		end
	else
		return false, Response
	end
end

--[[
	Returns the authorization object for the local user within a Guild. This method is server only.
    For security, this method only allows Secret objects to be provided for authorization.
    This method will contain a status boolean as the first argument with all following arguments relating to the response.

    If failed: false, string (error code)
    If successful: true, table (may contain the following fields: "verified", "robloxId", "robloxUsername", "method", these fields contain strings or booleans)
]]
function NVolatile.V1_GuildAuth(local_auth: Secret, guild_id: string)
	if not RunService:IsServer() then
		return false, "This method is server only."
	end

	local Headers = {
		["Cookie"] = local_auth,
	}

	local Success, Response: JsonHttpClient.HttpResponse? =
		JsonHttpClient.SendRequestAsync(ApiUrls.Auth .. "/roblox/status?guildId=" .. guild_id, "GET", nil, Headers)
			:await()

	if Success then
		local Body: NeoShiftGuildAuthResponse = HttpService:JSONDecode(Response.Body)

		if Body.error == nil then
			return true, Body
		else
			return false, Body.error
		end
	else
		return false, Response
	end
end

--[[
	Returns the configuration object for a Guild. This method is server only.
    For security, this method only allows Secret objects to be provided for authorization.
    This method will contain a status boolean as the first argument with all following arguments relating to the response.

    If failed: false, string (error code)
    If successful: true, table (may contain any valid JSON)
]]
function NGuild.V1_GuildInfomation(local_auth: Secret, guild_id: string)
	if not RunService:IsServer() then
		return false, "This method is server only."
	end

	local Headers = {
		["Cookie"] = local_auth,
	}

	local Success, Response: JsonHttpClient.HttpResponse? =
		JsonHttpClient.SendRequestAsync(ApiUrls.Guild .. "/" .. guild_id, "GET", nil, Headers):await()

	if Success then
		local Body: NeoShiftGuildAuthResponse = HttpService:JSONDecode(Response.Body)

		if Body.error == nil then
			return true, Body
		else
			return false, Body.error
		end
	else
		return false, Response
	end
end

--[[
	Returns the configuration object for a Guild's ranks. This method is server only.
    For security, this method only allows Secret objects to be provided for authorization.
    This method will contain a status boolean as the first argument with all following arguments relating to the response.

    If failed: false, string (error code)
    If successful: true, table (may contain any valid JSON)
]]
function NGuild.V1_GuildRanks(local_auth: Secret, guild_id: string)
	if not RunService:IsServer() then
		return false, "This method is server only."
	end

	local Headers = {
		["Cookie"] = local_auth,
	}

	local Success, Response: JsonHttpClient.HttpResponse? =
		JsonHttpClient.SendRequestAsync(ApiUrls.Guild .. "/" .. guild_id .. "/ranks", "GET", nil, Headers):await()

	if Success then
		local Body: NeoShiftGuildAuthResponse = HttpService:JSONDecode(Response.Body)

		if Body.error == nil then
			return true, Body
		else
			return false, Body.error
		end
	else
		return false, Response
	end
end

--[[
	Returns the configuration object for the local user in a Guild. This method is server only.
    For security, this method only allows Secret objects to be provided for authorization.
    This method will contain a status boolean as the first argument with all following arguments relating to the response.

    If failed: false, string (error code)
    If successful: true, table (may contain any valid JSON)
]]
function NGuild.V1_GuildStaff(local_auth: Secret, guild_id: string)
	if not RunService:IsServer() then
		return false, "This method is server only."
	end

	local Headers = {
		["Cookie"] = local_auth,
	}

	local Success, Response: JsonHttpClient.HttpResponse? =
		JsonHttpClient.SendRequestAsync(ApiUrls.Guild .. "/" .. guild_id .. "/staff/me", "GET", nil, Headers):await()

	if Success then
		local Body: NeoShiftGuildAuthResponse = HttpService:JSONDecode(Response.Body)

		if Body.error == nil then
			return true, Body
		else
			return false, Body.error
		end
	else
		return false, Response
	end
end

--[[
	Returns all shifts from a Guild. This method is server only.
    For security, this method only allows Secret objects to be provided for authorization.
    This method will contain a status boolean as the first argument with all following arguments relating to the response.

    If failed: false, string (error code)
    If successful: true, table (may contain any valid JSON)
]]
function NGuild.V1_GuildShifts(local_auth: Secret, guild_id: string, active_only: boolean)
	if not RunService:IsServer() then
		return false, "This method is server only."
	end

	local Headers = {
		["Cookie"] = local_auth,
	}

	local Success, Response: JsonHttpClient.HttpResponse? = JsonHttpClient.SendRequestAsync(
		ApiUrls.Guild .. "/" .. guild_id .. "/shifts?live=" .. tostring(active_only),
		"GET",
		nil,
		Headers
	):await()

	if Success then
		local Body: NeoShiftGuildAuthResponse = HttpService:JSONDecode(Response.Body)

		if Body.error == nil then
			return true, Body
		else
			return false, Body.error
		end
	else
		return false, Response
	end
end

--[[
	Returns all modlogs from a Guild. This method is server only.
    For security, this method only allows Secret objects to be provided for authorization.
    This method will contain a status boolean as the first argument with all following arguments relating to the response.

    If failed: false, string (error code)
    If successful: true, table (may contain any valid JSON)
]]
function NGuild.V1_GuildModlogs(local_auth: Secret, guild_id: string)
	if not RunService:IsServer() then
		return false, "This method is server only."
	end

	local Headers = {
		["Cookie"] = local_auth,
	}

	local Success, Response: JsonHttpClient.HttpResponse? =
		JsonHttpClient.SendRequestAsync(ApiUrls.Guild .. "/" .. guild_id .. "/modlogs", "GET", nil, Headers):await()

	if Success then
		local Body: NeoShiftGuildAuthResponse = HttpService:JSONDecode(Response.Body)

		if Body.error == nil then
			return true, Body
		else
			return false, Body.error
		end
	else
		return false, Response
	end
end

--[[
	Returns staff quota data from a Guild. This method is server only.
    For security, this method only allows Secret objects to be provided for authorization.
    This method will contain a status boolean as the first argument with all following arguments relating to the response.

    If failed: false, string (error code)
    If successful: true, table (may contain any valid JSON)
]]
function NGuild.V1_StaffQuota(local_auth: Secret, guild_id: string)
	if not RunService:IsServer() then
		return false, "This method is server only."
	end

	local Headers = {
		["Cookie"] = local_auth,
	}

	local Success, Response: JsonHttpClient.HttpResponse? =
		JsonHttpClient.SendRequestAsync(ApiUrls.Guild .. "/" .. guild_id .. "/quota", "GET", nil, Headers):await()

	if Success then
		local Body: NeoShiftGuildAuthResponse = HttpService:JSONDecode(Response.Body)

		if Body.error == nil then
			return true, Body
		else
			return false, Body.error
		end
	else
		return false, Response
	end
end

--[[
	Returns audit data from a Guild. This method is server only.
    For security, this method only allows Secret objects to be provided for authorization.
    This method will contain a status boolean as the first argument with all following arguments relating to the response.

    If failed: false, string (error code)
    If successful: true, table (may contain any valid JSON)
]]
function NGuild.V1_GuildAudit(local_auth: Secret, guild_id: string, page: number)
	if not RunService:IsServer() then
		return false, "This method is server only."
	end

	local Headers = {
		["Cookie"] = local_auth,
	}

	local Success, Response: JsonHttpClient.HttpResponse? =
		JsonHttpClient.SendRequestAsync(ApiUrls.Guild .. "/" .. guild_id .. "/audit?page=" .. page, "GET", nil, Headers)
			:await()

	if Success then
		local Body: NeoShiftGuildAuthResponse = HttpService:JSONDecode(Response.Body)

		if Body.error == nil then
			return true, Body
		else
			return false, Body.error
		end
	else
		return false, Response
	end
end

return NeoShift
