local logger = {}

local LogService = game:GetService("LogService")

export type LoggerData = {
	prefix: string,
	message: string,
	mode: Enum.MessageType,
}

function logger.LogToConsole(log: LoggerData): ()
	local formatted_message = `[FRIGATE][{log.prefix:upper()}]: {log.message}`
	LogService:Log(log.mode, formatted_message)
end

return logger
