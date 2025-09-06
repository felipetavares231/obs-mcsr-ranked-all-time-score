local rankedScores = require("obs-ranked-score")

obs = obslua

hotkey_id = obs.OBS_INVALID_HOTKEY_ID
hotkey_saved_array = nil

local selfName = ""

function getRankedScoresOnHotkey(pressed)
	if not pressed then
		return
	end

	rankedScores(script_path(), selfName)
end

function script_description()
	return "Example script that triggers an action when a hotkey is pressed."
end

function script_update(settings)
	selfName = obs.obs_data_get_string(settings, "username_input")
end

function script_properties()
	local props = obs.obs_properties_create()

	-- Add a text input field
	obs.obs_properties_add_text(props, "username_input", "Your Minecraft Username", obs.OBS_TEXT_DEFAULT)

	return props
end

function script_load(settings)
	hotkey_id =
		obs.obs_hotkey_register_frontend("get_ranked_scores_hotkey_id", "Get Ranked Scores", getRankedScoresOnHotkey)
	hotkey_saved_array = obs.obs_data_get_array(settings, "get_ranked_scores_hotkey")
	obs.obs_hotkey_load(hotkey_id, hotkey_saved_array)
	obs.obs_data_array_release(hotkey_saved_array)
end

function script_save(settings)
	hotkey_saved_array = obs.obs_hotkey_save(hotkey_id)
	obs.obs_data_set_array(settings, "get_ranked_scores_hotkey", hotkey_saved_array)
	obs.obs_data_array_release(hotkey_saved_array)
end
