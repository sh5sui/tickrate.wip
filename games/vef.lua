local Lighting = game:GetService("Lighting")
local ui = loadstring(game:HttpGet("https://raw.githubusercontent.com/sh5sui/tickrate.wip/refs/heads/main/uisrc.lua"))()
local players = game:GetService("Players")

local window = ui.create("tickrate.wip", Vector2.new(530, 445))
ui.watermark("tickrate.wip | private")
ui.notify("Normal", "welcome to tickrate.wip", 5)
ui.ToggleKey = Enum.KeyCode.Insert

local config = ui.tab("config", {"general"})
local player = ui.tab("player", {"local"})
local world = ui.tab("world", {"sky", "lighting"})
local misc = ui.tab("misc", {"general"})
local physics = ui.tab("physics", {"general"})

local function chase()
    local getgenv = getgenv or function() return shared end
    local cloneref = cloneref or clonereference or function(Any) return Any end

    getgenv().PATH = workspace:FindFirstChild("Balls", true)
    getgenv().TOOLS = {"Dribble", "Pass", "Tackle"} -- Added "Tackle" here
    getgenv().MAX_DISTANCE = 10
    getgenv().MIN_DISTANCE = 3
    getgenv().OWNERCHECK = false
    getgenv().AIRCHECK = false
    getgenv().PREDICTION = true

    if getgenv().LOADED then return end
    getgenv().LOADED = true

    local Players = cloneref(game:GetService("Players"))
    local RunService = cloneref(game:GetService("RunService"))

    local LocalPlayer = Players.LocalPlayer
    local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local Humanoid: Humanoid = Character:WaitForChild("Humanoid")
    local HumanoidRootPart: Part = Character:WaitForChild("HumanoidRootPart")
    local Head: Part = Character:WaitForChild("Head")

    local Connections = {}
    local Tool = false

    local function CheckTools()
        Tool = false
        for _, toolName in ipairs(getgenv().TOOLS) do
            if Character:FindFirstChild(toolName) then
                Tool = true
                break
            end
        end
    end

    local function HandleCharacter()
        CheckTools()

        table.insert(Connections, Character.ChildAdded:Connect(function(Any)
            if Any:IsA("Tool") then
                for _, toolName in ipairs(getgenv().TOOLS) do
                    if Any.Name == toolName then
                        Tool = true
                        break
                    end
                end
            end
        end))

        table.insert(Connections, Character.ChildRemoved:Connect(function(Any)
            if Any:IsA("Tool") then
                for _, toolName in ipairs(getgenv().TOOLS) do
                    if Any.Name == toolName then
                        CheckTools()
                        break
                    end
                end
            end
        end))
    end

    LocalPlayer.CharacterAdded:Connect(function(NewCharacter)
        for _, Connection in Connections do
            Connection:Disconnect()
        end
        table.clear(Connections)

        Character = NewCharacter
        Humanoid = Character:WaitForChild("Humanoid")
        HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
        Head = Character:WaitForChild("Head")

        Tool = false

        HandleCharacter()
    end)

    HandleCharacter()

    RunService.RenderStepped:Connect(function()
        if not Tool or not Character or not Humanoid or not HumanoidRootPart or not Head then
            return
        end

        local Path = getgenv().PATH
        if not Path or not Path.Parent then
            Path = workspace:FindFirstChild("Balls", true)
            getgenv().PATH = Path
        end

        if not Path then return end

        -- Dynamically find the nearest ball every frame
        local NearestBall = nil
        local SmallestMagnitude = math.huge

        for _, Ball in Path:GetChildren() do
            if not Ball:IsA("BasePart") then continue end

            local Magnitude = (Ball.Position - HumanoidRootPart.Position).Magnitude
            if Magnitude < SmallestMagnitude then
                SmallestMagnitude = Magnitude
                NearestBall = Ball
            end
        end

        if not NearestBall then return end

        -- Apply distance and state checks to the nearest ball
        if SmallestMagnitude > getgenv().MAX_DISTANCE then return end
        if Humanoid.MoveDirection.Magnitude > 0 then return end
        if SmallestMagnitude < getgenv().MIN_DISTANCE then return end
        if getgenv().OWNERCHECK and isnetworkowner(NearestBall) then return end
        if getgenv().AIRCHECK and NearestBall.Position.Y > Head.Position.Y then return end

        if getgenv().PREDICTION then
            Humanoid:Move(
                NearestBall.Position + NearestBall.AssemblyLinearVelocity
                    - HumanoidRootPart.Position,
                false
            )
        else
            Humanoid:Move(
                NearestBall.Position - HumanoidRootPart.Position,
                false
            )
        end
    end)
end

physics:Section("ball", "Left", "general")

physics:Section("local", "Right", "general")

ui.toggle({
    Title="auto-ball chase",
    Flag="ball-chase",
    Default=false,
    Callback=function(v)
        chase()
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