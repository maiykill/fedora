local utils = require("mp.utils")
local start_timestamp = nil
local timer = nil
local timer_duration = 1 -- update OSD every 1 second
local mp = mp

-- Format seconds to HH:MM:SS.mmm
local function seconds_to_time_string_ms(seconds)
	local h = math.floor(seconds / 3600)
	local m = math.floor((seconds % 3600) / 60)
	local s = math.floor(seconds % 60)
	local ms = math.floor((seconds - math.floor(seconds)) * 1000)
	return string.format("%02d:%02d:%02d.%03d", h, m, s, ms)
end

-- Always use first audio stream: Stream #0:0 in ffmpeg mapping
local function get_audio_index()
	return 0 -- ffmpeg index for first audio stream is 0
end

-- Save using HEVC VAAPI
local function save_slice(from, to)
	local path = mp.get_property("path")
	if not path then
		return
	end

	local input_name = mp.get_property("filename/no-ext") or "output"
	local extension = string.match(path, "%.([^.]+)$") or "mp4"

	local start_str = seconds_to_time_string_ms(from)
	local end_str = seconds_to_time_string_ms(to)
	local duration = to - from
	local duration_str = seconds_to_time_string_ms(duration)

	-- Filename: filename_starttime_to_endtime.extension
	local output_name =
		string.format("%s_%s_to_%s.%s", input_name, start_str:gsub("[:%.]", "-"), end_str:gsub("[:%.]", "-"), extension)

	local args = {
		"ffmpeg",
		"-y",
		"-vaapi_device",
		"/dev/dri/renderD128",
		"-ss",
		tostring(from),
		"-i",
		path,
		"-t",
		tostring(duration),
		"-map",
		"0:v:0",
		"-map",
		"0:a:" .. tostring(get_audio_index()),
		"-vf",
		"format=nv12,hwupload",
		"-c:v",
		"hevc_vaapi",
		"-qp",
		"18",
		"-g", -- gives frame refresh every 1 second on v=25
		"25",
		"-bf",
		"2",
		"-profile:v",
		"main",
		"-c:a",
		"copy",
		"-avoid_negative_ts",
		"make_zero",
		output_name,
	}

	local res = utils.subprocess({ args = args })
	if res and res.status == 0 then
		mp.osd_message(
			string.format("Clip Saved... from: %s till %s Duration: %s", start_str, end_str, duration_str),
			5
		)
	else
		mp.osd_message("Failed to save slice", 3)
	end
end

-- Clear state
local function clear_timestamp()
	if timer then
		timer:kill()
	end
	start_timestamp = nil
	mp.remove_key_binding("slice-ESC")
	mp.osd_message("", 0)
end

-- Main toggle function
local function set_timestamp()
	if not mp.get_property("path") or not mp.get_property_bool("seekable") then
		mp.osd_message("Cannot slice this media")
		return
	end

	if not start_timestamp then
		-- First activation
		start_timestamp = mp.get_property_number("time-pos")

		local function update_osd()
			local now = mp.get_property_number("time-pos")
			local elapsed = now - start_timestamp
			mp.osd_message(
				string.format(
					"Slicing started at: %s  \nDuration: %s",
					seconds_to_time_string_ms(start_timestamp),
					seconds_to_time_string_ms(elapsed)
				)
			)
		end

		update_osd()
		timer = mp.add_periodic_timer(timer_duration, update_osd)
		mp.add_forced_key_binding("ESC", "slice-ESC", clear_timestamp)
	else
		-- Second activation: stop + save
		local from = start_timestamp
		local to = mp.get_property_number("time-pos")
		if to <= from then
			mp.osd_message("End timestamp cannot be before start", 2)
			return
		end
		clear_timestamp()
		save_slice(from, to)
	end
end

-- Bind to Ctrl+S
mp.add_key_binding("Ctrl+s", "set-timestamp", set_timestamp)
