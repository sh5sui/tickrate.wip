local ui = loadstring(game:HttpGet("https://raw.githubusercontent.com/sh5sui/tickrate.wip/refs/heads/main/uisrc.lua"))()
local inputserv = game:GetService("UserInputService")
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
    if ui.Flags["sprint-dribbles-toggle"] then
        keypress(0xA0)
        task.wait(0.05)
        keypress(0x58)
        task.wait(0.05)
        keyrelease(0x58)
        task.wait(0.05)
        keypress(0x58)
        task.wait(0.05)
        keyrelease(0x58)
        task.wait(0.05)
        keyrelease(0xA0)
else
    keypress(0x58)
    task.wait(0.05)
    keyrelease(0x58)
    task.wait(0.05)
    keypress(0x58)
    task.wait(0.05)
    keyrelease(0x58)
end
end

local function spin()
    if ui.Flags["sprint-dribbles-toggle"] then
        keypress(0xA0)
        task.wait(0.05)
        keypress(0x5A)
        task.wait(0.05)
        keyrelease(0x5A)
        task.wait(0.05)
        keypress(0x58)
        task.wait(0.05)
        keyrelease(0x58)
        task.wait(0.05)
        keypress(0x43)
        task.wait(0.05)
        keyrelease(0x43)
        task.wait(0.05)
        keyrelease(0xA0)
else
    keypress(0x5A)
    task.wait(0.05)
    keyrelease(0x5A)
    task.wait(0.05)
    keypress(0x58)
    task.wait(0.05)
    keyrelease(0x58)
    task.wait(0.05)
    keypress(0x43)
    task.wait(0.05)
    keyrelease(0x43)
end

local function doublebtb()

end

physics:Section("enhancers", "Left", "player")

physics:Section("dribble macros", "Left", "macros")

ui.toggle({
    Title="sprint dribbles",
    Flag="sprint-dribbles-toggle",
    Default=false,
    Callback=function()
    end
})

ui.bind({
    Title="snatchback",
    Flag="snatchback-macro-bind",
    Default=Enum.KeyCode.None,
    Callback=function()
        snatchback()
    end
})

ui.bind({
    Title="spin",
    Flag="spin-macro-bind",
    Default=Enum.KeyCode.None,
    Callback=function()
        spin()
    end
})

ui.bind({
    Title="double btb",
    Flag="double-btb-macro-bind",
    Default=Enum.KeyCode.None,
    Callback=function()
        doublebtb()
    end
})