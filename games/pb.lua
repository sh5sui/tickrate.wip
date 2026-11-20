local ui = loadstring(game:HttpGet("https://raw.githubusercontent.com/sh5sui/tickrate.wip/refs/heads/main/uisrc.lua"))()
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local inputserv = game:GetService("UserInputService")
local vinputmgr = game:GetService("VirtualInputManager")

local window = ui.create("tickrate.wip", Vector2.new(530, 445))
ui.watermark("tickrate.wip | private")
ui.notify("Normal", "welcome to tickrate.wip", 5)
ui.ToggleKey = Enum.KeyCode.Insert

local config = ui.tab("config", {"general"})
local scoring = ui.tab("scoring", {"scoring"})
local physics = ui.tab("physics", {"player", "macros"})
local menu = ui.tab("menu", {"general"})

local MONITORED_KEYS = {
    [Enum.KeyCode.E] = 0x45,
    [Enum.KeyCode.Space] = 0x20,
}

local IGNORE_ANIMS = {
    ["rbxassetid://15814935511"] = true,
}

local JUMPSHOT_ANIMS = {
    ["rbxassetid://109811332443306"] = true,
    ["rbxassetid://90734416867039"]  = true,
}

local ANIM_RELEASE_TIMES = {
    ["rbxassetid://109811332443306"] = 0.330,
    ["rbxassetid://90734416867039"]  = 0.330,
    ["rbxassetid://117785999630918"] = 0.450,
    ["rbxassetid://12031953650"]     = 0.450,
    ["rbxassetid://109084161206360"] = 0.500,
}

local UNDER_RIM_DIST    = 11.0
local UNDER_RIM_RELEASE = 0.430
local DEEP_DIST         = 42.0
local DEEP_RELEASE      = 0.380
local FADEAWAY_RELEASE  = 0.360
local DEFAULT_FALLBACK  = 0.450
local PING_OFFSET       = 0

local isTracking = false
local activeKey = nil
local isSyntheticRelease = false

local function getCharacter()
    local lp = Players.LocalPlayer
    local charName = lp and lp.Name or "2sxw"
    local charsFolder = Workspace:FindFirstChild("Characters")
    return (charsFolder and charsFolder:FindFirstChild(charName))
        or (lp and lp.Character)
        or Workspace:FindFirstChild(charName)
end

local function getDistanceToNearestHoop(char)
    local root = char and (char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart or char:FindFirstChildWhichIsA("BasePart", true))
    if not root then return math.huge end

    local hoopsFolder = Workspace:FindFirstChild("Hoops") or Workspace:FindFirstChild("Hoops", true)
    if not hoopsFolder then return math.huge end

    local shortestDist = math.huge
    for _, hoop in ipairs(hoopsFolder:GetChildren()) do
        local target = hoop:FindFirstChild("Goal") or hoop
        if target:IsA("BasePart") then
            local flatDist = (Vector2.new(target.Position.X, target.Position.Z) - Vector2.new(root.Position.X, root.Position.Z)).Magnitude
            if flatDist < shortestDist then
                shortestDist = flatDist
            end
        end
    end

    return shortestDist
end

local function forceReleaseKey(keyCode)
    isTracking = false
    activeKey = nil
    isSyntheticRelease = true
    vinputmgr:SendKeyEvent(false, keyCode, false, game)
    local vk = MONITORED_KEYS[keyCode]
    if vk and keyrelease then
        keyrelease(vk)
    end
    task.defer(function()
        isSyntheticRelease = false
    end)
end

local function startAutoRelease(keyCode)
    if isTracking or not ui.Flags["auto-time-toggle"] then return end

    local char = getCharacter()
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local animator = hum and hum:FindFirstChildOfClass("Animator")
    if not char or not animator then return end

    isTracking = true
    activeKey = keyCode

    local initialTracks = {}
    for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
        initialTracks[track] = true
    end

    local startTime = os.clock()
    local shotTrack = nil
    local lockedIsKnown = false
    local isFadeaway = false
    local distAtStart = getDistanceToNearestHoop(char)
    local targetTimePos = DEFAULT_FALLBACK

    task.spawn(function()
        while isTracking and activeKey == keyCode and ui.Flags["auto-time-toggle"] do
            if (os.clock() - startTime) > 1.8 then
                isTracking = false
                activeKey = nil
                return
            end

            if shotTrack and not shotTrack.IsPlaying then
                shotTrack = nil
                lockedIsKnown = false
            end

            if not shotTrack or not lockedIsKnown then
                for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                    if not initialTracks[track] and track.IsPlaying then
                        local animId = track.Animation and track.Animation.AnimationId or ""

                        if IGNORE_ANIMS[animId] then
                            isFadeaway = true
                        else
                            local isKnown = JUMPSHOT_ANIMS[animId] or (ANIM_RELEASE_TIMES[animId] ~= nil)
                            if isKnown or not shotTrack then
                                shotTrack = track
                                lockedIsKnown = isKnown

                                if JUMPSHOT_ANIMS[animId] then
                                    if isFadeaway then
                                        targetTimePos = FADEAWAY_RELEASE + PING_OFFSET
                                    elseif distAtStart <= UNDER_RIM_DIST then
                                        targetTimePos = UNDER_RIM_RELEASE + PING_OFFSET
                                    elseif distAtStart >= DEEP_DIST then
                                        targetTimePos = DEEP_RELEASE + PING_OFFSET
                                    else
                                        targetTimePos = (ANIM_RELEASE_TIMES[animId] or 0.330) + PING_OFFSET
                                    end
                                elseif ANIM_RELEASE_TIMES[animId] then
                                    targetTimePos = ANIM_RELEASE_TIMES[animId] + PING_OFFSET
                                else
                                    targetTimePos = DEFAULT_FALLBACK + PING_OFFSET
                                end

                                if isKnown then
                                    break
                                end
                            end
                        end
                    end
                end
            end

            if shotTrack and shotTrack.TimePosition >= targetTimePos then
                forceReleaseKey(keyCode)
                return
            end

            RunService.RenderStepped:Wait()
        end

        isTracking = false
        activeKey = nil
    end)
end

inputserv.InputBegan:Connect(function(input)
    if inputserv:GetFocusedTextBox() then return end
    if not ui.Flags["auto-time-toggle"] then return end

    if MONITORED_KEYS[input.KeyCode] then
        startAutoRelease(input.KeyCode)
    end
end)

inputserv.InputEnded:Connect(function(input)
    if isSyntheticRelease then return end

    if input.KeyCode == activeKey then
        isTracking = false
        activeKey = nil
    end
end)

local function getBallHand()
    local myChar = getCharacter()
    if not myChar then return "No ball" end

    local ballsFolder = Workspace:FindFirstChild("Basketballs")
    if ballsFolder then
        for _, ball in ipairs(ballsFolder:GetChildren()) do
            local attrs = ball:FindFirstChild("Attributes")
            local charValue = attrs and attrs:FindFirstChild("Character")
            if charValue and charValue.Value == myChar then
                local right = myChar:FindFirstChild("RightHand")
                local left = myChar:FindFirstChild("LeftHand")
                if right and left then
                    local r = (ball.Position - right.Position).Magnitude
                    local l = (ball.Position - left.Position).Magnitude
                    return r < l and "Right" or "Left"
                end
            end
        end
    end

    local handAttr = myChar:GetAttribute("Hand")
    if handAttr == "L" then return "Left" end
    if handAttr == "R" then return "Right" end

    return "No ball"
end

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
    local delay = 0.015

    if hand == "No ball" then return end

    keyrelease(0xA2)
    task.wait(0.01)

    if sprint then
        keypress(0xA0)
        task.wait(delay)
    end

    if hand == "Left" then
        keypress(0x5A)
        task.wait(delay)
        keyrelease(0x5A)

        keypress(0x58)
        task.wait(delay)
        keyrelease(0x58)

        keypress(0x43)
        task.wait(delay)
        keyrelease(0x43)
    elseif hand == "Right" then
        keypress(0x43)
        task.wait(delay)
        keyrelease(0x43)

        keypress(0x58)
        task.wait(delay)
        keyrelease(0x58)

        keypress(0x5A)
        task.wait(delay)
        keyrelease(0x5A)
    end

    if sprint then
        keyrelease(0xA0)
    end
end

local function doublebtb()

end

scoring:Section("timing", "Left", "scoring")

ui.toggle({
    Title="auto time",
    Flag="auto-time-toggle",
    Default=false,
    Callback=function(state)
        if not state then
            isTracking = false
            activeKey = nil
        end
    end
})

physics:Section("enhancers", "Left", "player")

ui.slider({
    Title="dribble enhancer",
    Flag="dribble-enhancer-slider",
    Symbol="",
    Default=1,
    Min=1,
    Max=10,
    Decimals=1,
    Callback=function()
    end
})

ui.slider({
    Title="shot glide",
    Flag="shot-glide-slider",
    Symbol="",
    Default=1,
    Min=1,
    Max=10,
    Decimals=1,
    Callback=function()
    end
})

ui.slider({
    Title="side step glide",
    Flag="side-step-glide-slider",
    Symbol="",
    Default=1,
    Min=1,
    Max=10,
    Decimals=1,
    Callback=function()
    end
})

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

menu:Section("menu", "Left", "general")

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

config:Section("config", "Left", "general")

ui.textbox({
    Title="config name",
    Flag="config-textbox",
    Default="default",
    Placeholder="default",
    Callback=function()
    end
})

ui.dropdown({
    Title="configs",
    List={""},
    Default="configs-dropdown",
    Callback=function()
    end
})

ui.button({
    Title="save",
    Flag="save-button",
    Callback=function()
        ui.notify("Normal", "saved config: " .. ui.Flags["config-textbox"], 3)
    end
})

ui.button({
    Title="override",
    Flag="override-button",
    Callback=function()
        ui.notify("Normal", "config overridden: " .. ui.Flags["config-textbox"], 3)
    end
})

ui.button({
    Title="load",
    Flag="load-button",
    Callback=function()
        ui.notify("Normal", "loaded config: " .. ui.Flags["config-textbox"], 3)
    end
})

ui.button({
    Title="set autoload",
    Flag="autoload-button",
    Callback=function()
        ui.notify("Normal", "set " .. ui.Flags["config-textbox"] .. " as autoload", 3)
    end
})