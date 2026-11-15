local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ui = loadstring(game:HttpGet("https://raw.githubusercontent.com/sh5sui/tickrate.wip/refs/heads/main/uisrc.lua"))()
local locplayer = Players.LocalPlayer
local camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local HeadOff = Vector3.new(0, 0.5, 0)
local LegOff = Vector3.new(0, 3, 0)

local boxConnections = {}
local boxDrawings = {}
local playerAddedConnection

local nameDrawings = {}
local nameConnections = {}
local playerAddedConnection
local playerRemovingConnection
local started = false

local function nameEsp(v)

    if v == Players.LocalPlayer or nameDrawings[v] ~= nil then
        return
    end

    local nameLabel = Drawing.new("Text")
    nameLabel.Text = v.DisplayName
    nameLabel.Size = 13
    nameLabel.Center = true
    nameLabel.Font = 3
    nameLabel.Color = Color3.fromRGB(255, 255, 255)
    nameLabel.Outline = false
    nameLabel.Visible = false

    nameDrawings[v] = nameLabel

    nameConnections[v] = RunService.RenderStepped:Connect(function()
        local char = v.Character
        local humanoid = char and char:FindFirstChild("Humanoid")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local head = char and char:FindFirstChild("Head")

        if not char or not humanoid or not hrp or not head or humanoid.Health <= 0 then
            nameLabel.Visible = false
            return
        end

        local plrpos, onScreen = camera:WorldToViewportPoint(head.Position)

        if not onScreen then
            nameLabel.Visible = false
            return
        end

    nameLabel.Position = Vector2.new(plrpos.X, plrpos.Y - 30)
    
    if v.TeamColor == locplayer.TeamColor then
    nameLabel.Visible = false
    return
else
    nameLabel.Visible = true
end
    end)
end

local function stopNameEsp()

    if started == false then
        return
    end

    started = false

    for i,v in pairs(Players:GetPlayers()) do
        if nameConnections[v] then
            nameConnections[v]:Disconnect()
        end
        if nameDrawings[v] then
            nameDrawings[v]:Remove()
        end
        nameConnections[v] = nil
        nameDrawings[v] = nil
    end

    if playerAddedConnection then
        playerAddedConnection:Disconnect()
        playerAddedConnection = nil
    end

    if playerRemovingConnection then
        playerRemovingConnection:Disconnect()
        playerRemovingConnection = nil
    end

end

local function drawNameEsp(enabled)

    if started then
        return
    end

    started = true

    if enabled then
        for i,v in pairs(Players:GetPlayers()) do
            nameEsp(v)
        end

    playerAddedConnection = Players.PlayerAdded:Connect(function(v)
        nameEsp(v)
    end)

    playerRemovingConnection = Players.PlayerRemoving:Connect(function(v)
        if nameConnections[v] then
            nameConnections[v]:Disconnect()
        end
        if nameDrawings[v] then
            nameDrawings[v]:Remove()
        end
        nameConnections[v] = nil
        nameDrawings[v] = nil
    end)
else
    stopNameEsp()
    end
end

local function createBoxESP(v)
    if v == locplayer or boxDrawings[v] then
        return
    end

    local BoxOutline = Drawing.new("Square")
    BoxOutline.Visible = false
    BoxOutline.Color = Color3.fromRGB(0, 0, 0)
    BoxOutline.Thickness = 3
    BoxOutline.Transparency = 1
    BoxOutline.Filled = false

    local Box = Drawing.new("Square")
    Box.Visible = false
    Box.Color = ui.Flags["boxes-color-enemy"] or Color3.fromRGB(255, 255, 255)
    Box.Thickness = 1
    Box.Transparency = 1
    Box.Filled = false

    boxDrawings[v] = {
        Box = Box,
        BoxOutline = BoxOutline
    }

    boxConnections[v] = RunService.RenderStepped:Connect(function()
        local character = v.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local RootPart = character and character:FindFirstChild("HumanoidRootPart")
        local Head = character and character:FindFirstChild("Head")

        if not character or not humanoid or not RootPart or not Head or humanoid.Health <= 0 then
            Box.Visible = false
            BoxOutline.Visible = false
            return
        end

        local RootPosition, onScreen = camera:WorldToViewportPoint(RootPart.Position)

        if onScreen and RootPosition.Z > 0 then
            local HeadPosition = camera:WorldToViewportPoint(Head.Position + HeadOff)
            local LegPosition = camera:WorldToViewportPoint(RootPart.Position - LegOff)

            local height = math.abs(HeadPosition.Y - LegPosition.Y)
            local width = height / 2

            BoxOutline.Size = Vector2.new(width, height)
            BoxOutline.Position = Vector2.new(
                RootPosition.X - width / 2,
                math.min(HeadPosition.Y, LegPosition.Y)
            )

            Box.Size = Vector2.new(width, height)
            Box.Position = BoxOutline.Position

            Box.Visible = true
            BoxOutline.Visible = true

            if v.TeamColor == locplayer.TeamColor then
                Box.Visible = false
                BoxOutline.Visible = false
                return
            end

        else
            Box.Visible = false
            BoxOutline.Visible = false
        end
    end)
end

local function removeBoxESP(v)
    if boxConnections[v] then
        boxConnections[v]:Disconnect()
        boxConnections[v] = nil
    end

    if boxDrawings[v] then
        boxDrawings[v].Box:Remove()
        boxDrawings[v].BoxOutline:Remove()
        boxDrawings[v] = nil
    end
end

local function drawboxesp(enabled)
    if enabled then
        for _, v in pairs(Players:GetPlayers()) do
            createBoxESP(v)
        end

        playerAddedConnection = Players.PlayerAdded:Connect(function(v)
            createBoxESP(v)
        end)

    else
        if playerAddedConnection then
            playerAddedConnection:Disconnect()
            playerAddedConnection = nil
        end

        for v in pairs(boxDrawings) do
            removeBoxESP(v)
        end
    end
end

Players.PlayerRemoving:Connect(function(v)
    removeBoxESP(v)
end)

local window = ui.create("tickrate.wip", Vector2.new(530, 445))
ui.watermark("tickrate.wip | private")
ui.notify("Normal", "welcome to tickrate.wip", 5)
ui.ToggleKey = Enum.KeyCode.Insert

local lname = locplayer.Name
local lid = locplayer.UserId
local ldisplay = locplayer.DisplayName

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

local ldraw
local nameConnection

ui.toggle({
    Title = "name",
    Flag = "name-enabled-local",
    Default = false,

    Callback = function(enabled)

        if not ui.Flags["esp-enabled-local"] then
            return
        end

        if enabled then
            ldraw = Drawing.new("Text")
            ldraw.Text = ldisplay
            ldraw.Size = 16
            ldraw.Center = true
            ldraw.Outline = true
            ldraw.Color = ui.Flags["name-color-local"] or ui.Theme.Accent[1]
            ldraw.Visible = true

            nameConnection = RunService.RenderStepped:Connect(function()
                local character = locplayer.Character
                local head = character and character:FindFirstChild("Head")

                if not head then
                    ldraw.Visible = false
                    return
                end

                local position, onScreen =
                    camera:WorldToViewportPoint(head.Position)

                ldraw.Position = Vector2.new(
                    position.X,
                    position.Y - 70
                )

                ldraw.Visible = onScreen
            end)

        else
            if nameConnection then
                nameConnection:Disconnect()
                nameConnection = nil
            end

            if ldraw then
                ldraw:Remove()
                ldraw = nil
            else
                ldraw:Remove()
            end
        end
    end
}):Colorpicker({
    Color = ui.Theme.Accent[1],
    Flag = "name-color-local",
    Callback=function(newColor)
        if ui.Flags["name-enabled-local"] then
            ldraw.Color = newColor
    end
end
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

local tdraw

ui.toggle({
    Title = "name",
    Flag = "name-enabled-team",
    Default = false,

    Callback = function(enabled)

        if not ui.Flags["esp-enabled-team"] then
            return
        end

        if enabled then
            tdraw = Drawing.new("Text")
            tdraw.Text = ldisplay
            tdraw.Size = 16
            tdraw.Center = true
            tdraw.Outline = true
            tdraw.Color = ui.Flags["name-color-team"] or ui.Theme.Accent[1]
            tdraw.Visible = true

            nameConnection = RunService.RenderStepped:Connect(function()
                local character = locplayer.Character
                local head = character and character:FindFirstChild("Head")

                if not head then
                    tdraw.Visible = false
                    return
                end

                local position, onScreen =
                    camera:WorldToViewportPoint(head.Position)

                tdraw.Position = Vector2.new(
                    position.X,
                    position.Y - 70
                )

                tdraw.Visible = onScreen
            end)

        else
            if nameConnection then
                nameConnection:Disconnect()
                nameConnection = nil
            end

            if tdraw then
                tdraw:Remove()
                tdraw = nil
            else
                tdraw:Remove()
            end
        end
    end
}):Colorpicker({
    Color = ui.Theme.Accent[1],
    Flag = "name-color-local",
    Callback=function(newColor)
        if ui.Flags["name-enabled-team"] then
            tdraw.Color = newColor
    end
end
})

ui.toggle({
    Title="health",
    Flag="health-enabled-team",
    Default=false,
    Callback=function (v)
        print("health-enabled-team", v)
    end
})

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

player:Section("enemy esp", "Left,", "enemy")

ui.toggle({
    Title="enabled",
    Flag="esp-enabled-enemy",
    Default=false,
    Callback=function(v)
        print("esp-enbaled-enemy", v)
    end
}):Keybind({
    Flag="esp-enabled-bind-enemy",
    Key=Enum.UserInputType.None
})

ui.toggle({
    Title="box",
    Flag="boxes-enabled-enemy",
    Default=false,
    Callback=function(value)
        drawboxesp(value)
    end
}):Colorpicker({
    Color=ui.Theme.Accent[1],
    Flag="boxes-color-enemy",
    Callback=function(newColor)
        for _, drawings in pairs(boxDrawings) do
            drawings.Box.Color = newColor
        end
    end
})

ui.dropdown({
    Title="box type",
    List={"cornered", "filled", "3d"},
    Default="cornered",
    Flag="boxes-type-enemy"
})

player:Section("info", "Right", "enemy")

local edraw

ui.toggle({
    Title = "name",
    Flag = "name-enabled-enemy",
    Default = false,
    Callback = function(value)
        drawNameEsp(value)
    end
}):Colorpicker({
    Color = ui.Theme.Accent[1],
    Flag = "name-color-enemy",
    Callback=function(newColor)
end
})

ui.toggle({
    Title="health",
    Flag="health-enabled-enemy",
    Default=false,
    Callback=function (v)
        print("health-enabled-enemy", v)
    end
})

player:Section("filters", "Right", "enemy")

ui.toggle({
    Title="visible check",
    Flag="visible-check-enemy",
    Default=false,
    Callback=function(v)
        print("visible-check-enemy", v)
    end
})

ui.toggle({
    Title="ignore bots",
    Flag="ignore-bots-enemy",
    Default=false,
    Callback=function(v)
        print("ignore-bots-enemy", v)
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