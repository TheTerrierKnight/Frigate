--[[
	API to interact with Technified Services.
]]

local Technified = {
	Lookups = {},
	Bindings = {},
	Shield = {},
	Moderation = {},
	ServerManagement = {},
	Local_Plugin = {},
	Local_Identity = {},
}

--[[
	API Catagories, based off on the Technifed Docs.
]]
local TLookups = Technified["Lookups"]
local TBindings = Technified["Bindings"]
local TShield = Technified["Shield"]
local TModeration = Technified["Moderation"]
local TServerManagement = Technified["ServerManagement"]
local TLocalPlugin = Technified["Local_Plugin"]
local TLocalIdentity = Technified["Local_Identity"]

local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local Root = script.Parent.Parent.Parent
local InternalPackages = Root._Internal

local JsonHttpClient = require(InternalPackages.Network.JsonHttpClient)

local ApiUrls = {
	V1 = "https://api.technified.xyz/api/v1",
}

--[[
	Represents a standard response structure from Technified.
]]
export type TechnifiedResponse = {
	status: string,
	code: number,
	message: string?,
	data: any?,
}

--[[
	Data object for Binding related API's.
	Not every argument is required for a sucessful call and some can be omitted entirely for certain endpoints.
]]
export type Binding = {
	roblox_group_id: number?,
	discord_role_id: number?,
	discord_role_name: number?,
	roblox_gamepass_id: number?,
	roblox_asset_id: number?,
	roblox_badge_id: number?,
	min_rank: number?,
	max_rank: number?,
	guild_id: string?,
	priority: number?,
	account_age_min_days: number,
	id: number?,
	type: string,
	group_id: number?,
	role_id: string?,
	discord_id: string?,
	binding_id: number?,
}

--[[
	Data object for Moderation related API's.
	Not every argument is required for a sucessful call and some can be omitted entirely for certain endpoints.
]]
export type PunishmentData = {
	guild_id: string?,
	roblox_id: string?,
	is_global: boolean?,
	reason: string?,
	duration: number?,
	moderator_username: string?,
	moderator_roblox_id: number?,
	source_server_id: string?,
}

--[[
	Child object for Moderation related API's.
	Not every argument is required for a sucessful call and some can be omitted entirely for certain endpoints.
]]
export type ServerCommandPlayer = {
	robloxId: string?,
	username: string?,
	displayName: string?,
	joinTime: number?,
	team: string?,
}

--[[
	Data object for Server Manager related API's.
	Not every argument is required for a sucessful call and some can be omitted entirely for certain endpoints.
]]
export type ServerCommand = {
	guildId: string?,
	serverId: string?,
	placeId: string?,
	universeId: string?,
	gameName: string?,
	playerCount: number?,
	maxPlayers: number?,
	serverAge: number?,
	fps: number?,
	commandId: number?,
	success: boolean?,
	result: string?,
	error: string?,
	players: { ServerCommandPlayer },
}

--[[
	Data object for Plugin related API's.
	Not every argument is required for a sucessful call and some can be omitted entirely for certain endpoints.
]]
export type PluginSerialObject = {
	guildId: string?,
	placeId: string?,
	universeId: string?,
	gameName: string?,
	creatorId: string?,
} & { [string]: any }

--[[
	Looks up a discord/roblox user within a guild. This method is server-only.
    This method will contain a status boolean as the first argument with all following arguments relating to the response.

    If failed: false, string (error code)
    If successful: true, string (discord_id), number (roblox_id), string (roblox_username), boolean (verified)
]]
function TLookups.V1_LookupUser(authorization: Secret | string, roblox_or_discord_id: string, guild_id: string)
	if not RunService:IsServer() then
		return false, "This method is server only."
	end

	local Headers = {
		["X-Guild-ID"] = guild_id,
	}

	local Success, Response: JsonHttpClient.HttpResponse? = JsonHttpClient.SendRequestAsync(
		ApiUrls.V1 .. "/lookup/discord/" .. roblox_or_discord_id,
		"GET",
		authorization,
		Headers
	):await()

	if Success then
		local Body: TechnifiedResponse = HttpService:JSONDecode(Response.Body)

		if Body.status == "success" then
			return true,
				Body.data["discord_id"],
				Body.data["roblox_id"],
				Body.data["roblox_username"],
				Body.data["verified"]
		else
			return false, Body.message
		end
	else
		return false, Response
	end
end

--[[
	Looks up a batch of discord/roblox user within a guild that will contain a maximum of 25 users. This method is server-only.
    This method will contain a status boolean as the first argument with all following arguments relating to the response.

    If failed: false, string (error code)
    If successful: true, table ("results", may contain string-key tables that contain the following fields: "discord_id", "roblox_id" "roblox_username", "verified", these fields contain strings or booleans)
]]
function TLookups.V1_Batch(
	authorization: Secret | string,
	guild_id: string,
	roblox_ids: { string },
	discord_ids: { string }
)
	if not RunService:IsServer() then
		return false, "This method is server only."
	end

	local Success, Response: JsonHttpClient.HttpResponse? = JsonHttpClient.SendRequestAsync(
		ApiUrls.V1 .. "/lookup/status",
		"POST",
		authorization,
		{},
		{
			["guild_id"] = guild_id,
			["discord_ids"] = discord_ids or {},
			["roblox_ids"] = roblox_ids or {},
		}
	):await()

	if Success then
		local Body: TechnifiedResponse = HttpService:JSONDecode(Response.Body)

		if Body.status == "success" then
			return true, Body.data["results"]
		else
			return false, Body.message
		end
	else
		return false, Response
	end
end

--[[
	Returns all registered bindings. This method is server-only.
    This method will contain a status boolean as the first argument with all following arguments relating to the response.

    If failed: false, string (error code)
    If successful: true, table (can contain Binding Type objects with/without omitted values)
]]
function TBindings.V1_GetBindings(authorization: Secret | string, guild_id: string)
	if not RunService:IsServer() then
		return false, "This method is server only."
	end

	local Headers = {
		["X-Guild-ID"] = guild_id,
	}

	local Success, Response: JsonHttpClient.HttpResponse? =
		JsonHttpClient.SendRequestAsync(ApiUrls.V1 .. "/bindings/list", "GET", authorization, Headers):await()

	if Success then
		local Body: TechnifiedResponse = HttpService:JSONDecode(Response.Body)

		if Body.status == "success" then
			return true, Body.data
		else
			return false, Body.message
		end
	else
		return false, Response
	end
end

--[[
	Registers a Binding. This method is server-only.
    This method will contain a status boolean as the first argument with all following arguments relating to the response.

    If failed: false, string (error code)
    If successful: true, string (message)
]]
function TBindings.V1_CreateBind(authorization: Secret | string, bind_data: Binding)
	if not RunService:IsServer() then
		return false, "This method is server only."
	end

	local Success, Response: JsonHttpClient.HttpResponse? =
		JsonHttpClient.SendRequestAsync(ApiUrls.V1 .. "/bindings/add", "POST", authorization, {}, bind_data):await()

	if Success then
		local Body: TechnifiedResponse = HttpService:JSONDecode(Response.Body)

		if Body.status == "success" then
			return true, Body.data
		else
			return false, Body.message
		end
	else
		return false, Response
	end
end

--[[
	Updates a Binding. This method is server-only.
    This method will contain a status boolean as the first argument with all following arguments relating to the response.

    If failed: false, string (error code)
    If successful: true, string (message)
]]
function TBindings.V1_UpdateBind(authorization: Secret | string, bind_data: Binding)
	if not RunService:IsServer() then
		return false, "This method is server only."
	end

	local Success, Response: JsonHttpClient.HttpResponse? =
		JsonHttpClient.SendRequestAsync(ApiUrls.V1 .. "/bindings/update", "PATCH", authorization, {}, bind_data):await()

	if Success then
		local Body: TechnifiedResponse = HttpService:JSONDecode(Response.Body)

		if Body.status == "success" then
			return true, Body.data
		else
			return false, Body.message
		end
	else
		return false, Response
	end
end

--[[
	Deletes a Binding. This method is server-only.
    This method will contain a status boolean as the first argument with all following arguments relating to the response.

    If failed: false, string (error code)
    If successful: true, string (message)
]]
function TBindings.V1_DeleteBind(authorization: Secret | string, bind_id: number)
	if not RunService:IsServer() then
		return false, "This method is server only."
	end

	local Success, Response: JsonHttpClient.HttpResponse? =
		JsonHttpClient.SendRequestAsync(ApiUrls.V1 .. "/bindings/remove/" .. bind_id, "DELETE", authorization):await()

	if Success then
		local Body: TechnifiedResponse = HttpService:JSONDecode(Response.Body)

		if Body.status == "success" then
			return true, Body.data
		else
			return false, Body.message
		end
	else
		return false, Response
	end
end

--[[
	Dry-Tests a Binding. This method is server-only.
    This method will contain a status boolean as the first argument with all following arguments relating to the response.

    If failed: false, string (error code)
    If successful: true, boolean (matches), string (reason)
]]
function TBindings.V1_TestBind(authorization: Secret | string, bind_data: Binding)
	if not RunService:IsServer() then
		return false, "This method is server only."
	end

	local Success, Response: JsonHttpClient.HttpResponse? =
		JsonHttpClient.SendRequestAsync(ApiUrls.V1 .. "/bindings/test", "POST", authorization, {}, bind_data):await()

	if Success then
		local Body: TechnifiedResponse = HttpService:JSONDecode(Response.Body)

		if Body.status == "success" then
			return true, Body.data["matches"], Body.data["reason"]
		else
			return false, Body.message
		end
	else
		return false, Response
	end
end

--[[
	Checks if a Bind is valid. This method is server-only.
    This method will contain a status boolean as the first argument with all following arguments relating to the response.

    If failed: false, string (error code)
    If successful: true, string (message)
]]
function TBindings.V1_ValidateBind(authorization: Secret | string, bind_data: Binding)
	if not RunService:IsServer() then
		return false, "This method is server only."
	end

	local Success, Response: JsonHttpClient.HttpResponse? =
		JsonHttpClient.SendRequestAsync(ApiUrls.V1 .. "/bindings/validate", "POST", authorization, {}, bind_data)
			:await()

	if Success then
		local Body: TechnifiedResponse = HttpService:JSONDecode(Response.Body)

		if Body.status == "success" then
			return true, Body.message
		else
			return false, Body.message
		end
	else
		return false, Response
	end
end

--[[
	Checks if a user is flagged within Technified Shield. This method is server-only.
    This method will contain a status boolean as the first argument with all following arguments relating to the response.

    If failed: false, string (error code)
    If successful: true, boolean (flagged), table ("flag", may contain the following fields: "roblox_id", "roblox_username", "reason", "flagged_by", "source", "catagory", "flagged_at", these fields contain strings or numbers)
]]
function TShield.V1_Check(authorization: Secret | string, roblox_id: number)
	if not RunService:IsServer() then
		return false, "This method is server only."
	end

	local Success, Response: JsonHttpClient.HttpResponse? =
		JsonHttpClient.SendRequestAsync(ApiUrls.V1 .. "/shield/check/" .. roblox_id, "GET", authorization):await()

	if Success then
		local Body: TechnifiedResponse = HttpService:JSONDecode(Response.Body)

		if Body.status == "success" then
			return true, Body.data["flagged"], Body.data["flag"] or {}
		else
			return false, Body.message
		end
	else
		return false, Response
	end
end

--[[
	Bulk checks multiple users and returns all flagged users. This method is server-only.
    This method will contain a status boolean as the first argument with all following arguments relating to the response.

    If failed: false, string (error code)
    If successful: true, table ("flagged", may contain string-key tables that have the following fields: "roblox_id", "roblox_username", "reason", "source", "catagory", these fields contain strings or numbers)
]]
function TShield.V1_Bulk(authorization: Secret | string, roblox_ids: { number })
	if not RunService:IsServer() then
		return false, "This method is server only."
	end

	local Success, Response: JsonHttpClient.HttpResponse? =
		JsonHttpClient.SendRequestAsync(ApiUrls.V1 .. "/shield/batch", "POST", authorization, {}, roblox_ids):await()

	if Success then
		local Body: TechnifiedResponse = HttpService:JSONDecode(Response.Body)

		if Body.status == "success" then
			return true, Body.data["flagged"]
		else
			return false, Body.message
		end
	else
		return false, Response
	end
end

--[[
	Gets all active mutes. This method is server-only.
    This method will contain a status boolean as the first argument with all following arguments relating to the response.

    If failed: false, string (error code)
    If successful: true, table (may contain any valid JSON), number (total)
]]
function TModeration.V1_GetMutes(authorization: Secret | string, guild_id: number)
	if not RunService:IsServer() then
		return false, "This method is server only."
	end

	local Success, Response: JsonHttpClient.HttpResponse? = JsonHttpClient.SendRequestAsync(
		ApiUrls.V1 .. "/moderation/" .. guild_id .. "/roblox/mutes/active",
		"GET",
		authorization
	):await()

	if Success then
		local Body: TechnifiedResponse = HttpService:JSONDecode(Response.Body)

		if Body.status == "success" then
			return true, Body.data["mutes"], Body.data["total"]
		else
			return false, Body.message
		end
	else
		return false, Response
	end
end

--[[
	Gets all active bans. This method is server-only.
    This method will contain a status boolean as the first argument with all following arguments relating to the response.

    If failed: false, string (error code)
    If successful: true, table (may contain any valid JSON), number (total)
]]
function TModeration.V1_GetBans(authorization: Secret | string, guild_id: number)
	if not RunService:IsServer() then
		return false, "This method is server only."
	end

	local Success, Response: JsonHttpClient.HttpResponse? = JsonHttpClient.SendRequestAsync(
		ApiUrls.V1 .. "/moderation/" .. guild_id .. "/roblox/bans/active",
		"GET",
		authorization
	):await()

	if Success then
		local Body: TechnifiedResponse = HttpService:JSONDecode(Response.Body)

		if Body.status == "success" then
			return true, Body.data["bans"], Body.data["total"]
		else
			return false, Body.message
		end
	else
		return false, Response
	end
end

--[[
	Creates a ban within a guild. This method is server-only.
    This method will contain a status boolean as the first argument with all following arguments relating to the response.

    If failed: false, string (error code)
    If successful: true, string (message)
]]
function TModeration.V1_CreateBan(authorization: Secret | string, ban_data: PunishmentData)
	if not RunService:IsServer() then
		return false, "This method is server only."
	end

	local Success, Response: JsonHttpClient.HttpResponse? = JsonHttpClient.SendRequestAsync(
		ApiUrls.V1 .. "/moderation/" .. ban_data.guild_id or "FRIGATE_GUILD_ID_DEFAULTPLACEHOLDER" .. "/roblox/ban",
		"POST",
		authorization,
		{},
		ban_data
	):await()

	if Success then
		local Body: TechnifiedResponse = HttpService:JSONDecode(Response.Body)

		if Body.status == "success" then
			return true, Body.message
		else
			return false, Body.message
		end
	else
		return false, Response
	end
end

--[[
	Removes a ban within a guild. This method is server-only.
    This method will contain a status boolean as the first argument with all following arguments relating to the response.

    If failed: false, string (error code)
    If successful: true, string (message)
]]
function TModeration.V1_RemoveBan(authorization: Secret | string, ban_data: PunishmentData)
	if not RunService:IsServer() then
		return false, "This method is server only."
	end

	local Success, Response: JsonHttpClient.HttpResponse? = JsonHttpClient.SendRequestAsync(
		ApiUrls.V1 .. "/moderation/" .. ban_data.guild_id or "FRIGATE_GUILD_ID_DEFAULTPLACEHOLDER" .. "/roblox/unban",
		"POST",
		authorization,
		{},
		ban_data
	):await()

	if Success then
		local Body: TechnifiedResponse = HttpService:JSONDecode(Response.Body)

		if Body.status == "success" then
			return true, Body.message
		else
			return false, Body.message
		end
	else
		return false, Response
	end
end

--[[
	Creates a mute within a guild. This method is server-only.
    This method will contain a status boolean as the first argument with all following arguments relating to the response.

    If failed: false, string (error code)
    If successful: true, string (message)
]]
function TModeration.V1_CreateMute(authorization: Secret | string, mute_data: PunishmentData)
	if not RunService:IsServer() then
		return false, "This method is server only."
	end

	local Success, Response: JsonHttpClient.HttpResponse? = JsonHttpClient.SendRequestAsync(
		ApiUrls.V1 .. "/moderation/" .. mute_data.guild_id or "FRIGATE_GUILD_ID_DEFAULTPLACEHOLDER" .. "/roblox/mute",
		"POST",
		authorization,
		{},
		mute_data
	):await()

	if Success then
		local Body: TechnifiedResponse = HttpService:JSONDecode(Response.Body)

		if Body.status == "success" then
			return true, Body.message
		else
			return false, Body.message
		end
	else
		return false, Response
	end
end

--[[
	Removes a mute within a guild. This method is server-only.
    This method will contain a status boolean as the first argument with all following arguments relating to the response.

    If failed: false, string (error code)
    If successful: true, string (message)
]]
function TModeration.V1_RemoveMute(authorization: Secret | string, mute_data: PunishmentData)
	if not RunService:IsServer() then
		return false, "This method is server only."
	end

	local Success, Response: JsonHttpClient.HttpResponse? = JsonHttpClient.SendRequestAsync(
		ApiUrls.V1 .. "/moderation/" .. mute_data.guild_id or "FRIGATE_GUILD_ID_DEFAULTPLACEHOLDER" .. "/roblox/unmute",
		"POST",
		authorization,
		{},
		mute_data
	):await()

	if Success then
		local Body: TechnifiedResponse = HttpService:JSONDecode(Response.Body)

		if Body.status == "success" then
			return true, Body.message
		else
			return false, Body.message
		end
	else
		return false, Response
	end
end

--[[
	Sends a server heartbeat. This method is server-only.
    This method will contain a status boolean as the first argument with all following arguments relating to the response.

    If failed: false, string (error code)
    If successful: true, string (message)
]]
function TServerManagement.V1_Heartbeat(authorization: Secret | string, command_data: ServerCommand)
	if not RunService:IsServer() then
		return false, "This method is server only."
	end

	local Success, Response: JsonHttpClient.HttpResponse? = JsonHttpClient.SendRequestAsync(
		ApiUrls.V1 .. "/roblox/servers/heartbeat",
		"POST",
		authorization,
		{},
		command_data
	):await()

	if Success then
		local Body: TechnifiedResponse = HttpService:JSONDecode(Response.Body)

		if Body.status == "success" then
			return true, Body.message
		else
			return false, Body.message
		end
	else
		return false, Response
	end
end

--[[
	Polls for Issued Commands. This method is server-only.
    This method will contain a status boolean as the first argument with all following arguments relating to the response.

    If failed: false, string (error code)
    If successful: true, table ("commands", may contain string-key tables that contain the following fields: "id", "type" "targetRobloxId", "targetUsername", "parameters", "issuedByDiscordId", "issuedByUsername", these fields contain strings, booleans or variadic tables)
]]
function TServerManagement.V1_PollCommands(authorization: Secret | string, command_data: ServerCommand)
	if not RunService:IsServer() then
		return false, "This method is server only."
	end

	local Success, Response: JsonHttpClient.HttpResponse? = JsonHttpClient.SendRequestAsync(
		ApiUrls.V1 .. "/roblox/servers/" .. command_data.serverId or "NA" .. "/commands",
		"GET",
		authorization
	):await()

	if Success then
		local Body: TechnifiedResponse = HttpService:JSONDecode(Response.Body)

		if Body.status == "success" then
			return true, Body.data["commands"]
		else
			return false, Body.message
		end
	else
		return false, Response
	end
end

--[[
	Marks a command as acknowleged. This method is server-only.
    This method will contain a status boolean as the first argument with all following arguments relating to the response.

    If failed: false, string (error code)
    If successful: true, string (message)
]]
function TServerManagement.V1_CommitCommand(authorization: Secret | string, command_data: ServerCommand)
	if not RunService:IsServer() then
		return false, "This method is server only."
	end

	local Success, Response: JsonHttpClient.HttpResponse? = JsonHttpClient.SendRequestAsync(
		ApiUrls.V1 .. "/roblox/servers/" .. command_data.serverId
			or "NA" .. "/commands" .. command_data.commandId
			or -1 .. "/ack",
		"POST",
		authorization
	):await()

	if Success then
		local Body: TechnifiedResponse = HttpService:JSONDecode(Response.Body)

		if Body.status == "success" then
			return true, Body.message
		else
			return false, Body.message
		end
	else
		return false, Response
	end
end

--[[
	Registers a game with Technified. This method is server-only.
    This method will contain a status boolean as the first argument with all following arguments relating to the response.

    If failed: false, string (error code)
    If successful: true, string (message)
]]
function TLocalPlugin.V1_Register(authorization: Secret | string, plugin_data: PluginSerialObject)
	if not RunService:IsServer() then
		return false, "This method is server only."
	end

	local Success, Response: JsonHttpClient.HttpResponse? = JsonHttpClient.SendRequestAsync(
		ApiUrls.V1 .. "/roblox/games/register",
		"POST",
		authorization,
		{},
		JsonHttpClient.AttachJSONMetadata(plugin_data)
	):await()

	if Success then
		local Body: TechnifiedResponse = HttpService:JSONDecode(Response.Body)

		if Body.status == "success" then
			return true, Body.message
		else
			return false, Body.message
		end
	else
		return false, Response
	end
end

--[[
	Checks if the associated local user is blacklisted. This method is server-only.
	For security, this method only allows Secret objects to be provided for authorization.
    This method will contain a status boolean as the first argument with all following arguments relating to the response.

    If failed: false, string (error code)
    If successful: true, boolean (blacklisted)
]]
function TLocalIdentity.V1_IsBlacklisted(local_auth: Secret)
	if not RunService:IsServer() then
		return false, "This method is server only."
	end

	local Headers = {
		["Cookie"] = local_auth,
	}

	local Success, Response: JsonHttpClient.HttpResponse? =
		JsonHttpClient.SendRequestAsync(ApiUrls.V1 .. "/user/blacklist-status", "GET", nil, Headers):await()

	if Success then
		local Body: TechnifiedResponse = HttpService:JSONDecode(Response.Body)

		if Body.status == "success" then
			return true, Body.data["blacklisted"]
		else
			return false, Body.message
		end
	else
		return false, Response
	end
end

--[[
	Fetches all platform announcements. This method is server-only.
	For security, this method only allows Secret objects to be provided for authorization.
    This method will contain a status boolean as the first argument with all following arguments relating to the response.

    If failed: false, string (error code)
    If successful: true, table (may contain any valid JSON)
]]
function TLocalIdentity.V1_PlatformAnnouncements(local_auth: Secret)
	if not RunService:IsServer() then
		return false, "This method is server only."
	end

	local Headers = {
		["Cookie"] = local_auth,
	}

	local Success, Response: JsonHttpClient.HttpResponse? =
		JsonHttpClient.SendRequestAsync(ApiUrls.V1 .. "/announcements", "GET", nil, Headers):await()

	if Success then
		local Body: TechnifiedResponse = HttpService:JSONDecode(Response.Body)

		if Body.status == "success" then
			return true, Body.data
		else
			return false, Body.message
		end
	else
		return false, Response
	end
end

--[[
	Fetches your current authentication session and returns data about you. This method is server-only.
	For security, this method only allows Secret objects to be provided for authorization.
    This method will contain a status boolean as the first argument with all following arguments relating to the response.

    If failed: false, string (error code)
    If successful: true, table (may contain any valid JSON)
]]
function TLocalIdentity.V1_Me(local_auth: Secret)
	if not RunService:IsServer() then
		return false, "This method is server only."
	end

	local Headers = {
		["Cookie"] = local_auth,
	}

	local Success, Response: JsonHttpClient.HttpResponse? =
		JsonHttpClient.SendRequestAsync(ApiUrls.Auth .. "/auth/me", "GET", nil, Headers):await()

	if Success then
		local Body: TechnifiedResponse = HttpService:JSONDecode(Response.Body)

		if Body.status == "success" then
			return true, Body.data
		else
			return false, Body.message
		end
	else
		return false, Response
	end
end

return Technified
