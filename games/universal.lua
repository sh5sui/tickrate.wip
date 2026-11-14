local ui = loadstring(game:HttpGet("https://raw.githubusercontent.com/sh5sui/tickrate.wip/refs/heads/main/uisrc.lua"))()

local window = ui.create("tickrate.wip", Vector2.new(530, 445))
ui.watermark("tickrate.wip | private")
ui.notify("Normal", "welcome to tickrate.wip", 5)
ui.ToggleKey = Enum.KeyCode.Insert

local config = ui.tab("config", {"general"})
local player = ui.tab("player", {"local", "team", "enemy"})
local world = ui.tab("world", {"skybox", "lighting"})
local misc = ui.tab("misc", {"general"})

player:Section("player esp", "Left", "local")

ui.toggle({
    Title="enabled",
    Flag="esp-enabled-local",
    Default=false,
    Callback=function(v)
        print("esp-enbaled-local", v)
    end
}):Keybind({
    Flag="esp-enabled-bind-local",
    Key=Enum.UserInputType.None
})

ui.toggle({
    Title="box",
    Flag="boxes-enabled-local",
    Default=false,
    Callback=function (v)
        print("boxes-enabled-local", v)
    end
}):Colorpicker({
    Color=ui.Theme.Accent[1],
    Flag="boxes-color-local"
})

ui.dropdown({
    Title="box type",
    List={"cornered", "filled", "3d"},
    Default="cornered",
    Flag="boxes-type-local"
})

player:Section("info", "Right", "local")

ui.toggle({
    Title="name",
    Flag="name-enabled-local",
    Default=false,
    Callback=function (v)
        print("name-enabled-local", v)
    end
}):Colorpicker({
    Color=ui.Theme.Accent[1],
    Flag="name-color-local"
})

ui.toggle({
    Title="health",
    Flag="health-enabled-local",
    Default=false,
    Callback=function (v)
        print("health-enabled-local", v)
    end
})

player:Section("team esp", "Left", "team")

ui.toggle({
    Title="enabled",
    Flag="esp-enabled-team",
    Default=false,
    Callback=function(v)
        print("esp-enbaled-team", v)
    end
}):Keybind({
    Flag="esp-enabled-bind-team",
    Key=Enum.UserInputType.None
})

ui.toggle({
    Title="box",
    Flag="boxes-enabled-team",
    Default=false,
    Callback=function (v)
        print("boxes-enabled-team", v)
    end
}):Colorpicker({
    Color=ui.Theme.Accent[1],
    Flag="boxes-color-team"
})

ui.dropdown({
    Title="box type",
    List={"cornered", "filled", "3d"},
    Default="cornered",
    Flag="boxes-type-team"
})

player:Section("info", "Right", "team")

player:Section("filters", "Right", "team")

ui.toggle({
    Title="visible check",
    Flag="visible-check-team",
    Default=false,
    Callback=function(v)
        print("visible-check-team", v)
    end
})

ui.toggle({
    Title="ignore bots",
    Flag="ignore-bots-team",
    Default=false,
    Callback=function(v)
        print("ignore-bots-team", v)
    end
})

misc:Section("general", "Left", "general")

local menubind
menubind = ui.label({
    Title="menu toggle: " .. ui.ToggleKey.Name
}):Keybind({
    Title="menu toggle",
    Flag="menu-toggle-bind",
    Default=ui.ToggleKey,
    Callback=function(menukey)
        task.defer(function()
            ui.ToggleKey = menukey
            menubind:Set("menu toggle" .. ui.ToggleKey.Name)
        end)
    end
})