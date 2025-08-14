local utils = require("mp.utils")
local start_timestamp = nil
local timer = nil
local timer_duration = 2
local mp = mp

local function seconds_to_time_string(seconds, full)
	local ret =
		string.format("%02d:%02d.%03d", math.floor(seconds / 60) % 60, math.floor(seconds) % 60, seconds * 1000 % 1000)
	if full or seconds > 3600 then
		ret = string.format("%d:%s", math.floor(seconds / 3600), ret)
	end
	return ret
end

local function get_extension(path)
	local candidate = string.match(path, "%.([^.]+)$")
	if candidate then
		for _, ext in ipairs({ "mkv", "webm", "mp4", "avi" }) do
			if candidate == ext then
				return candidate
			end
		end
	end
	return "mkv"
end

local function save_slice(from, to)
	local path = mp.get_property("path")
	local input_name = mp.get_property("filename/no-ext") or "slice"
	local extension = get_extension(path)

	local start_time = seconds_to_time_string(from, true):gsub(":", "-")
	local end_time = seconds_to_time_string(to, true):gsub(":", "-")
	local output_name = string.format("%s_slice_%s_to_%s.%s", input_name, start_time, end_time, extension)

	-- Get currently selected audio track
	local audio_track = mp.get_property("aid") or "1"

	local args = {
		"ffmpeg",
		"-ss",
		tostring(from),
		"-i",
		path,
		"-to",
		tostring(to - from),
		"-map",
		"0:v:0", -- First video stream
		"-map",
		string.format("0:a:%s", audio_track - 1), -- Currently selected audio
		"-c",
		"copy",
		"-avoid_negative_ts",
		"make_zero",
		output_name,
	}

	mp.osd_message("Saving slice: " .. output_name, 2)

	local res = utils.subprocess({ args = args })
	if res.status == 0 then
		mp.osd_message("Slice saved: " .. output_name, 3)
	else
		mp.osd_message("Failed to save slice", 3)
	end
end

local function clear_timestamp()
	if timer then
		timer:kill()
	end
	start_timestamp = nil
	mp.remove_key_binding("slice-ESC")
	mp.osd_message("", 0)
end

local function set_timestamp()
	if not mp.get_property("path") then
		mp.osd_message("No file currently playing")
		return
	end
	if not mp.get_property_bool("seekable") then
		mp.osd_message("Cannot slice non-seekable media")
		return
	end

	if not start_timestamp then
		start_timestamp = mp.get_property_number("time-pos")
		local msg_func = function()
			mp.osd_message(
				string.format("slice: waiting for end [%s]", seconds_to_time_string(start_timestamp, false)),
				timer_duration
			)
		end
		msg_func()
		timer = mp.add_periodic_timer(timer_duration, msg_func)
		mp.add_forced_key_binding("ESC", "slice-ESC", clear_timestamp)
	else
		local from = start_timestamp
		local to = mp.get_property_number("time-pos")
		if to <= from then
			mp.osd_message("End cannot be before start", timer_duration)
			if timer then
				timer:kill()
				timer:resume()
			end
			return
		end
		clear_timestamp()
		save_slice(from, to)
	end
end

mp.add_key_binding("s", "set-timestamp", set_timestamp)
