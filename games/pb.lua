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

local function getBallHand()
    for _, ball in ipairs(workspace.Basketballs:GetChildren()) do
        local attrs = ball:FindFirstChild("Attributes")
        local charValue = attrs and attrs:FindFirstChild("Character")
        local character = charValue and charValue.Value

        if character then
            local right = character:FindFirstChild("RightHand")
            local left = character:FindFirstChild("LeftHand")

            if right and left then
                local r = (ball.Position - right.Position).Magnitude
                local l = (ball.Position - left.Position).Magnitude

                return r < l and "Right" or "Left"
            end
        end
    end

    return "No ball"
end

print(getBallHand())

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
    local sprint = ui.Flags["sprint-dribbles-toggle"]
    local hand = getBallHand()
    local delay = 0.01

    if hand == "Left" then
        if sprint then
            keypress(0xA0)
            task.wait(delay)
        end

        keypress(0x5A)
        task.wait(delay)
        keyrelease(0x5A)

        keypress(0x58)
        task.wait(delay)
        keyrelease(0x58)

        keypress(0x43)
        task.wait(delay)
        keyrelease(0x43)

        if sprint then
            keyrelease(0xA0)
        end

    elseif hand == "Right" then
        if sprint then
            keypress(0xA0)
            task.wait(delay)
        end

        keypress(0x43)
        task.wait(delay)
        keyrelease(0x43)

        keypress(0x58)
        task.wait(delay)
        keyrelease(0x58)

        keypress(0x5A)
        task.wait(delay)
        keyrelease(0x5A)

        if sprint then
            keyrelease(0xA0)
        end
    end
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