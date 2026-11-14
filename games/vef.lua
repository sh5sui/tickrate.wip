local Lighting = game:GetService("Lighting")
local ui = loadstring(game:HttpGet("https://raw.githubusercontent.com/sh5sui/tickrate.wip/refs/heads/main/uisrc.lua?t=" .. os.time()))()
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
    getgenv().TOOLS = {"Dribble", "Pass", "Tackle"}
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
        if not ui.Flags["ball-chase"] then
            return
        end
        if not Tool or not Character or not Humanoid or not HumanoidRootPart or not Head then
            return
        end

        local Path = getgenv().PATH
        if not Path or not Path.Parent then
            Path = workspace:FindFirstChild("Balls", true)
            getgenv().PATH = Path
        end

        if not Path then return end

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

local function CreateHitboxExtender(initialSize)
	local Players = game:GetService("Players")
	local RunService = game:GetService("RunService")
	local Player = Players.LocalPlayer

	local Extender = {
		Enabled = false,
		Size = initialSize or 2.10,
		Connections = {},
		Running = true
	}

	local function safeConn(c)
		table.insert(Extender.Connections, c)
		return c
	end

	local BallCache = {}
	local _cachedBall = nil
	local _lastSeenBall = nil
	local _lastSeenAt = 0
	local BALL_PERSIST = 3.0
	local BALL_SIZES = { 2.5, 1.75, 2 }

	local function isWelded(part)
		local welded = part:FindFirstChild("Welded")
		return welded and welded.Value == true
	end

	local function inWorkspaceNoHumanoid(part)
		local p = part.Parent
		while p do
			if p:IsA("Model") and p:FindFirstChildOfClass("Humanoid") then return false end
			if p == workspace then return true end
			p = p.Parent
		end
		return false
	end

	local function ballScore(part)
		if not part or not part:IsA("BasePart") or part.Name == "RefreshReach" then return 0 end
		if not inWorkspaceNoHumanoid(part) then return 0 end

		if part.Parent and part.Parent.Name == "Balls" then
			return 5
		end

		local s = part.Size
		local maxd = math.max(s.X, s.Y, s.Z)
		local mind = math.min(s.X, s.Y, s.Z)
		local roundEnough = maxd > 0 and (maxd - mind) <= maxd * 0.3
		local saneSize = maxd >= 0.6 and maxd <= 8
		local exact = false
		for _, b in ipairs(BALL_SIZES) do
			if s.X == b and s.Y == b and s.Z == b then exact = true break end
		end
		local shaped = part:IsA("Part") and part.Shape == Enum.PartType.Ball
		local named = part.Name:lower():find("ball") ~= nil

		local score = 0
		if part.Name == "VEF" or (exact and shaped) then score = 4
		elseif (shaped and saneSize) or (named and saneSize and roundEnough) then score = 3
		elseif named and saneSize then score = 2
		end
		if score == 0 then return 0 end

		if part.Anchored then score = score - 0.5 end
		if isWelded(part) then score = score - 0.5 end
		return score
	end

	for _, part in pairs(workspace:GetDescendants()) do
		if ballScore(part) > 0 then BallCache[part] = true end
	end

	safeConn(workspace.DescendantAdded:Connect(function(part)
		if ballScore(part) > 0 then BallCache[part] = true end
	end))

	safeConn(workspace.DescendantRemoving:Connect(function(part)
		BallCache[part] = nil
	end))

	local function getNearestBall()
		local char = Player.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if not hrp then _cachedBall = nil return nil end
		local best, bestScore, bestDist = nil, -1, math.huge
		for part in pairs(BallCache) do
			if part and part.Parent then
				local score = ballScore(part)
				if score > 0 then
					local d = (part.Position - hrp.Position).Magnitude
					if score > bestScore or (score == bestScore and d < bestDist) then
						best, bestScore, bestDist = part, score, d
					end
				end
			end
		end
		if best then
			_cachedBall = best
			_lastSeenBall = best
			_lastSeenAt = os.clock()
			return best
		end
		if _lastSeenBall and _lastSeenBall.Parent and (os.clock() - _lastSeenAt) < BALL_PERSIST then
			_cachedBall = _lastSeenBall
			return _lastSeenBall
		end
		_cachedBall = nil
		return nil
	end

	local staleReach = workspace:FindFirstChild("RefreshReach")
	if staleReach then pcall(function() staleReach:Destroy() end) end

	local reachPart = Instance.new("Part")
	reachPart.Name = "RefreshReach"
	reachPart.Anchored = true
	reachPart.CanCollide = false
	reachPart.CanTouch = true
	reachPart.CanQuery = false
	reachPart.Transparency = 1
	reachPart.Shape = Enum.PartType.Ball
	reachPart.Material = Enum.Material.SmoothPlastic
	reachPart.Size = Vector3.new(Extender.Size, Extender.Size, Extender.Size)
	reachPart.Position = Vector3.new(0, -1000, 0)
	reachPart.Parent = workspace

	local reachLimbs = {}
	local function rebuildReachLimbs()
		reachLimbs = {}
		local char = Player.Character
		if not char then return end
		for _, p in ipairs(char:GetDescendants()) do
			if p:IsA("BasePart") then reachLimbs[p] = true end
		end
	end
	rebuildReachLimbs()

	safeConn(Player.CharacterAdded:Connect(function(char)
		task.wait(0.2)
		rebuildReachLimbs()
		safeConn(char.DescendantAdded:Connect(function(p)
			if p:IsA("BasePart") then reachLimbs[p] = true end
		end))
		safeConn(char.DescendantRemoving:Connect(function(p)
			reachLimbs[p] = nil
		end))
	end))

	local reachFTICooldowns = {}
	local REACH_FTI_COOLDOWN = 0.05

	local function reachFireFTI(limb, ball)
		if not limb or not limb.Parent or not limb:IsA("BasePart") then return end
		if not ball or not ball.Parent then return end
		local key = tostring(limb) .. tostring(ball)
		local now = tick()
		if reachFTICooldowns[key] and now - reachFTICooldowns[key] < REACH_FTI_COOLDOWN then return end
		reachFTICooldowns[key] = now
		if typeof(firetouchinterest) == "function" then
			pcall(firetouchinterest, limb, ball, 0)
			pcall(firetouchinterest, limb, ball, 1)
		end
	end

	safeConn(reachPart.Touched:Connect(function(other)
		if not Extender.Enabled then return end
		if reachLimbs[other] and _cachedBall then
			reachFireFTI(other, _cachedBall)
		end
	end))

	local reachLastBall = nil
	safeConn(RunService.Heartbeat:Connect(function()
		if not Extender.Enabled then
			if reachPart.CanTouch then reachPart.CanTouch = false end
			reachPart.Position = Vector3.new(0, -1000, 0)
			reachLastBall = nil
			return
		end
		local ball = getNearestBall()
		if not ball or not ball.Parent then
			if reachPart.CanTouch then reachPart.CanTouch = false end
			reachPart.Position = Vector3.new(0, -1000, 0)
			reachLastBall = nil
			return
		end
		local size = math.max(1, Extender.Size)
		reachPart.Size = Vector3.new(size, size, size)
		reachPart.Position = ball.Position
		if ball ~= reachLastBall then
			reachLastBall = ball
			reachPart.CanTouch = false
			reachPart.CanTouch = true
		elseif not reachPart.CanTouch then
			reachPart.CanTouch = true
		end

		local char = Player.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if hrp and (ball.Position - hrp.Position).Magnitude <= (size + 6) then
			for limb in pairs(reachLimbs) do
				if limb and limb.Parent and (limb.Position - ball.Position).Magnitude <= size then
					reachFireFTI(limb, ball)
				end
			end
		end
	end))

	task.spawn(function()
		while Extender.Running do
			task.wait(4)
			local now = tick()
			for k, t in pairs(reachFTICooldowns) do
				if now - t > 3 then reachFTICooldowns[k] = nil end
			end
		end
	end)

	function Extender:SetEnabled(state)
		self.Enabled = state
	end

	function Extender:SetSize(newSize)
		self.Size = math.max(1, tonumber(newSize) or 2.10)
		if reachPart then
			reachPart.Size = Vector3.new(self.Size, self.Size, self.Size)
		end
	end

	function Extender:Destroy()
		self.Running = false
		self.Enabled = false
		for _, c in ipairs(self.Connections) do
			pcall(function() c:Disconnect() end)
		end
		if reachPart then pcall(function() reachPart:Destroy() end) end
	end

	return Extender
end

local bigfoot = CreateHitboxExtender(2.1)

physics:Section("ball", "Left", "general")

ui.toggle({
    Title="bigfoot",
    Flag="bigfoot",
    Default=false,
    Callback=function(enabled)
        bigfoot:SetEnabled(enabled)
    end
})

ui.slider({
    Title="bigfoot reach",
    Flag="bigfoot-reach",
    Symbol=" studs",
    Default=2.1,
    Min=1,
    Max=10,
    Decimals=2,
    Callback=function(val)
        bigfoot:SetSize(val)
    end
})

physics:Section("local", "Right", "general")

ui.toggle({
    Title="auto-ball chase",
    Flag="ball-chase",
    Default=false,
    Callback=function(v)
        if v then
            chase()
        end
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