--[[
    Handles sending Json Web Requests safely.
	The functionality of this module is reserved for internal use.
]]

local HttpClient = {}

local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local Root = script.Parent.Parent.Parent
local Packages = Root.Parent.Packages

local Logger = require(Root.Utilites.Logger)
local promise = require(Packages.promise)

local VERSION = "VersonMicro/2.1"

export type HttpResponse = {
	Success: boolean,
	StatusCode: number,
	StatusMessage: string,
	Headers: { [string]: any },
	Body: any,
}

--[[
    Checks if HttpService is enabled or not.
]]
local function CheckHttpAvailability()
	return HttpService.HttpEnabled
end

--[[
    Send a remote http request to the specified server. This method is server-only.
    This method yields and returns a non-cancelable promise that will contain either the http response (if sucessful) or an error code (if failed).
]]
function HttpClient.SendRequestAsync(
	url: string,
	request_type: string,
	authorization: Secret | string | nil,
	extra_headers: { [string]: any },
	json: any
)
	return promise.new(function(reslove, reject)
		if not RunService:IsServer() then
			reject("SendRequestAsync must be called by the server.")
		end

		local Res: HttpResponse?
		local Headers = {
			["Content-Type"] = "application/json",
			["X-FrigateJsonHttp"] = VERSION,
			["X-Identifier"] = "Frigate OSS Network Processing Library",
			["X-RbxServerStatus"] = if not RunService:IsStudio()
				then "PRODUCTION_" .. tostring(game.GameId)
				else "STUDIO/UNKNOWN",
		}

		if authorization ~= nil then
			Headers["Authorization"] = "Bearer " .. authorization
		end
		if extra_headers ~= nil then
			for header_name, header_value in extra_headers do
				Headers[header_name] = header_value
			end
		end

		if not CheckHttpAvailability() then
			reject("Http is not enabled.")
			Logger.LogToConsole({
				prefix = "JSON_HTTP",
				message = "Http is not enabled and JsonHttpClient cannot make requests. Enable http under your game settings.",
				mode = Enum.MessageType.MessageError,
			})
		end

		local http_ok, http_result = pcall(function()
			Res = HttpService:RequestAsync({
				["Url"] = url,
				["Headers"] = Headers,
				["Method"] = request_type:upper(),
				["Body"] = if json then HttpService:JSONEncode(json) else nil,
			})
		end)

		if http_ok then
			reslove(Res)
		else
			reject(http_result)
			Logger.LogToConsole({
				prefix = "JSON_HTTP",
				message = "JsonHttpClient error: " .. http_result,
				mode = Enum.MessageType.MessageError,
			})
		end
	end)
end

--[[
    Attaches a "Metadata" object to identify the JsonHttpClient.
	Mainly used for the Technified Plugin API but can be used for virtually any purpose needing to identiify JSON from the JsonHttpClient.
]]
function HttpClient.AttachJSONMetadata(json: { [any]: any })
	json["metadata"] = {
		["source"] = "Frigate_JsonHttpClient",
		["client_version"] = VERSION,
	}
	return json
end

return HttpClient
