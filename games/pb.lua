local ui = loadstring(game:HttpGet("https://raw.githubusercontent.com/sh5sui/tickrate.wip/refs/heads/main/uisrc.lua"))()
local inputservice = game:GetService("UserInputService")
local vinputmgr = game:GetService("VirtualInputManager")

local window = ui.create("tickrate.wip", Vector2.new(530, 445))
ui.watermark("tickrate.wip | private")
ui.notify("Normal", "welcome to tickrate.wip", 5)
ui.ToggleKey = Enum.KeyCode.Insert

local config = ui.tab("config", {"general"})
local scoring = ui.tab("scoring", {"general"})
local physics = ui.tab("physics", {"player", "macros"})
local misc = ui.tab("misc", {"general"})

local function snatchback()
    vinputmgr:SendKeyEvent(true, Enum.KeyCode.X, false, game)
    task.wait(0.1)
    vinputmgr:SendKeyEvent(true, Enum.KeyCode.X, false, game)
    vinputmgr:SendKeyEvent(true, Enum.KeyCode.X, false, game)
    task.wait(0.1)
    vinputmgr:SendKeyEvent(true, Enum.KeyCode.X, false, game)
end

physics:Section("enhancers", "Left", "player")

physics:Section("dribble macros", "Left", "macros")

ui.bind({
    Title="snatchback",
    Flag="snatchback-macro-bind",
    Default=Enum.KeyCode.None,
    Callback=function()
        snatchback()
    end
})

ui.toggle({
    Title="spin",
    Flag="spin-macro",
    Default=false,
    Callback=function()

    end
}):Keybind({
    Flag="spin-macro-bind",
    Key=Enum.UserInputType.None
})

ui.toggle({
    Title="double btb",
    Flag="double-btb-macro",
    Default=false,
    Callback=function()

    end
}):Keybind({
    Flag="double-btb-macro-bind",
    Key=Enum.UserInputType.None
})