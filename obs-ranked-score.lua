local json = require("dkjson") -- make sure dkjson.lua is in your path

local function winrate(scoreA, scoreB)
	local total = scoreA + scoreB
	if total == 0 then
		return "0%"
	end
	local rate = (scoreA / total) * 100
	return tostring(math.floor(rate + 0.5)) .. "%" -- round like Math.round
end

local function writeScoreToFile(script_path, fileName, dataToWrite)
	local file_path = script_path .. fileName
	local file = io.open(file_path, "w+")
	if file then
		file:write(dataToWrite)
		file:close()
	else
		print("Failed to write scores to " .. fileName)
	end
end

local function curlGet(url)
	local command
	if package.config:sub(1, 1) == "\\" then
		command = 'cmd /c curl -s "' .. url .. '"'
	else
		command = 'curl -s "' .. url .. '"'
	end
	local f = assert(io.popen(command, "r"))
	local content = f:read("*all")
	f:close()
	return content
end

local function rankedScores(script_path, selfName)
	print("Received path: " .. script_path)

	local rankedUrl = "https://mcsrranked.com/api/live/"
	local selfUuid = ""
	local opponentUuid = ""

	local content = curlGet(rankedUrl)
	local rankedLive, pos, err = json.decode(content, 1, nil)
	if err then
		error("Failed to decode JSON: " .. err)
	end

	for _, match in ipairs(rankedLive.data.liveMatches) do
		for _, player in ipairs(match.players) do
			if player.nickname == selfName then
				selfUuid = player.uuid
			end
		end
	end

	if selfUuid == "" then
		print("Could not find UUID for user:", selfName)
		return
	end

	for _, match in ipairs(rankedLive.data.liveMatches) do
		if match.data[selfUuid] then
			for uuid, _ in pairs(match.data) do
				if uuid ~= selfUuid then
					opponentUuid = uuid
				end
			end
		end
	end

	if opponentUuid == "" then
		print("Could not find opponent UUID")
		return
	end

	local versusUrl = "https://ranked-score.vercel.app/api/getScoresFromVersusScores/"
		.. selfUuid
		.. "/"
		.. opponentUuid
	--TODO: have a sessionScores variable that's gonna store the data from each match, then check if it exists before doing this call, that should save a lot of api requests

	local content2 = curlGet(versusUrl)
	local scoresData, pos, err = json.decode(content2, 1, nil)
	if err then
		error("Failed to decode JSON: " .. err)
	end

	writeScoreToFile(script_path, "score.txt", scoresData.scores[selfUuid] .. " - " .. scoresData.scores[opponentUuid])
	writeScoreToFile(script_path, "winrate.txt", winrate(scoresData.scores[selfUuid], scoresData.scores[opponentUuid]))
end

return rankedScores
