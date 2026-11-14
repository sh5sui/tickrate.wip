local Lighting = game:GetService("Lighting")
local ui = loadstring(game:HttpGet("https://raw.githubusercontent.com/sh5sui/tickrate.wip/refs/heads/main/uisrc.lua"))()
local players = game:GetService("Players")

local soundservice = game:GetService("SoundService")
local getAsset = getcustomasset or getsynasset

local mp3 = "i-rot-che.mp3"
local mp3url = "https://raw.githubusercontent.com/sh5sui/tickrate.wip/main/i-rot-che.mp3"
local jaydesmp3 = "who-can-i-trust-jaydes.mp3"
local jaydesmp3url = "https://raw.githubusercontent.com/sh5sui/tickrate.wip/main/who-can-i-trust-jaydes.mp3"

if isfile and writefile and not isfile(mp3) then
    pcall(function ()
            writefile(mp3, game:HttpGet(mp3url))
    end)
end

if isfile and writefile and not isfile(jaydesmp3) then
    pcall(function()
            writefile(jaydesmp3, game:HttpGet(jaydesmp3url))
    end)
end

local music = Instance.new("Sound")
music.Name = "tickrate.cc"
music.Volume = 1
music.Looped = false
music.Parent = soundservice

local choice = math.random(1, 2)

if getAsset and isfile and isfile(mp3) and isfile(jaydesmp3) then
    if choice == 1 then
        music.SoundId = getAsset(mp3)
    end
    if choice == 2 then
        music.SoundId=getAsset(jaydesmp3)
    end
end

music:play()
ui.intro(5)

local window = ui.create("tickrate.wip", Vector2.new(530, 445))
ui.watermark("tickrate.wip | private")
ui.notify("Normal", "welcome to tickrate.wip", 5)
ui.ToggleKey = Enum.KeyCode.Insert

local config = ui.tab("config", {"general"})
local player = ui.tab("player", {"local", "team", "enemy"})
local world = ui.tab("world", {"sky", "lighting"})
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

misc:Section("menu", "Left", "general")

local menubind
menubind = ui.label({
    Title="menu toggle: " .. ui.ToggleKey.Name
}):Keybind({
    Title="menu toggle",
    Flag="menu-toggle-bind",
    Default=ui.ToggleKey,
    Callback=function(menukey)
        if menukey.EnumType == Enum.KeyCode then
        task.defer(function()
            ui.ToggleKey = menukey
            menubind:Set("menu toggle: " .. ui.ToggleKey.Name)
        end)
    end
end
})

ui.toggle({
    Title="watermark",
    Flag="watermark-toggle",
    Default=true,
    Callback=function(enabled)
        if enabled then
            ui.watermark("tickrate.wip | private")
        else
            ui.watermark(false)
    end
end
})

world:Section("general", "Left", "sky")

ui.toggle({
    Title="ambient",
    Flag="ambient",
    Default=false,
    Callback=function(enabled)
        if enabled then
            Lighting.Ambient = ui.Flags["ambient-picker"] or ui.Theme.Accent[1]
        else
            Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        end
    end
}):Colorpicker({
    Color=ui.Theme.Accent[1],
    Flag="ambient-picker",
    Callback=function(newColor)
       if ui.Flags["ambient"] then
        Lighting.Ambient = newColor
    end
end
})

world:Section("general", "Left", "lighting")

ui.textbox({
    Title="time of day",
    Flag="time-of-day",
    Default="14",
    Placeholder="0-24",
    Callback=function(text, enterPressed)
        local num = tonumber(text)
        if num then
            game:GetService("Lighting").ClockTime = math.clamp(num, 0, 24)
        end
    end
})

ui.textbox({
    Title="brightness",
    Flag="brightness",
    Default="2",
    Placeholder="2",
    Callback=function(text, enterPressed)
        local num = tonumber(text)
        if num then
            game:GetService("Lighting").Brightness = math.clamp(num, 0, 100)
        end
    end
})