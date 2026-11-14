local ui = loadstring(game:HttpGet("https://raw.githubusercontent.com/sh5sui/tickrate.wip/main/source.lua"))()

local win = ui.create("tickrate.wip", Vector2.new(530, 445))
ui.watermark("tickrate.wip | private")
ui.notify("Normal", "Press RightShift to toggle menu!", 5)

-- Create top tabs
local visuals = ui.tab("visuals", {"players", "world"})
local misc    = ui.tab("misc", {"general"})
local fontTab = ui.tab("font", {"typography"})

ui.section("player esp", "Left", "players")

ui.toggle({
	Title = "enabled",
	Flag = "esp_enabled",
	Default = true,
	Callback = function(v)
		print("ESP:", v)
	end
}):Keybind({
	Flag = "esp_key",
	Key = Enum.UserInputType.MouseButton2
})

ui.toggle({
	Title = "box",
	Flag = "esp_box",
	Default = true
}):Colorpicker({
	Color = ui.Theme.Accent[1],
	Flag = "box_color"
})

ui.dropdown({
	Title = "box type",
	List = {"cornered", "full", "three-dimensional"},
	Default = "cornered",
	Flag = "box_type"
})

ui.colorpicker({
	Title = "not visible colour",
	Color = ui.Theme.Accent[2],
	Flag = "not_visible_color"
})

ui.colorpicker({
	Title = "knocked colour",
	Color = ui.Theme.Accent[3],
	Flag = "knocked_color"
})

ui.toggle({
	Title = "skeleton",
	Flag = "esp_skeleton",
	Default = false
})

ui.dropdown({
	Title = "skeleton type",
	List = {"straight", "jointed"},
	Default = "straight",
	Flag = "skeleton_type"
})

ui.toggle({
	Title = "head circle",
	Flag = "esp_head_circle",
	Default = false
})

ui.toggle({
	Title = "snaplines",
	Flag = "esp_snaplines",
	Default = false
}):Colorpicker({
	Color = ui.Theme.Accent[1],
	Flag = "snaplines_color"
})

ui.slider({
	Title = "max distance",
	Flag = "esp_max_distance",
	Symbol = " m",
	Default = 500,
	Min = 0,
	Max = 500,
	Decimals = 0
})

ui.section("info", "Right", "players")

ui.toggle({
	Title = "name",
	Flag = "info_name",
	Default = true
}):Colorpicker({
	Color = Color3.fromRGB(255, 255, 255),
	Flag = "name_color"
})

ui.toggle({ Title = "platform", Flag = "info_platform", Default = true })
ui.toggle({ Title = "rank", Flag = "info_rank", Default = true })

ui.dropdown({
	Title = "rank & platform as",
	List = {"icons", "text", "both"},
	Default = "icons",
	Flag = "rank_platform_mode"
})

ui.toggle({ Title = "kills", Flag = "info_kills", Default = false })

ui.toggle({
	Title = "distance",
	Flag = "info_distance",
	Default = false
}):Colorpicker({
	Color = ui.Theme.Accent[4],
	Flag = "distance_color"
})

ui.toggle({
	Title = "weapon",
	Flag = "info_weapon",
	Default = false
}):Colorpicker({
	Color = Color3.fromRGB(255, 255, 255),
	Flag = "weapon_color"
})

ui.toggle({ Title = "ammo", Flag = "info_ammo", Default = false })
ui.toggle({ Title = "bot label", Flag = "info_bot_label", Default = false })

ui.section("filters", "Right", "players")

ui.toggle({ Title = "visible only", Flag = "filter_visible", Default = false })
ui.toggle({ Title = "ignore bots", Flag = "filter_ignore_bots", Default = false })

ui.section("world esp", "Left", "world")

ui.toggle({
	Title = "dropped items",
	Flag = "world_items",
	Default = true
}):Colorpicker({
	Color = ui.Theme.Accent[1],
	Flag = "world_items_color"
})

ui.textbox({
	Title = "item filter",
	Placeholder = "e.g. rifle, medkit...",
	Default = "",
	Flag = "world_item_filter",
	Callback = function(text)
		print("Filtering items by:", text)
	end
})

ui.slider({
	Title = "render distance",
	Flag = "world_distance",
	Symbol = " m",
	Default = 250,
	Min = 0,
	Max = 1000
})

-- Add settings tab & switch back to visuals
win:AddSettingsTab()
win:SwitchTab(visuals)