local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local GuiParent = (gethui and gethui()) or game:GetService("CoreGui") or PlayerGui
if GuiParent:FindFirstChild("TickrateLibraryUI") then
	GuiParent.TickrateLibraryUI:Destroy()
end

local ui = {
	Flags = {},
	CurrentWindow = nil,
	CurrentTab = nil,
	CurrentSubTab = nil,
	CurrentSection = nil,
	Theme = {
		Background = Color3.fromRGB(11, 11, 13),
		SectionBg = Color3.fromRGB(13, 13, 15),
		ElementBg = Color3.fromRGB(17, 17, 20),
		Border = Color3.fromRGB(32, 32, 36),
		Accent = {
			Color3.fromRGB(190, 200, 240),
			Color3.fromRGB(220, 50, 50),
			Color3.fromRGB(240, 150, 20),
			Color3.fromRGB(165, 245, 175)
		},
		TextActive = Color3.fromRGB(230, 230, 235),
		TextInactive = Color3.fromRGB(145, 145, 155),
		TextDim = Color3.fromRGB(95, 95, 105),
		Font = Enum.Font.BuilderSansMedium,
		FontBold = Enum.Font.BuilderSansBold
	},
	ToggleKey = Enum.KeyCode.RightShift
}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TickrateLibraryUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = GuiParent

local function NormalizeOpts(opts)
	if type(opts) == "string" then
		return {Title = opts}
	end
	opts = opts or {}
	opts.Title = opts.Title or opts.title or opts.Text or opts.text
	opts.Flag = opts.Flag or opts.flag
	if opts.Default == nil then opts.Default = opts.default end
	opts.Callback = opts.Callback or opts.callback
	opts.List = opts.List or opts.list
	opts.Min = opts.Min or opts.min
	opts.Max = opts.Max or opts.max
	opts.Symbol = opts.Symbol or opts.symbol
	opts.Color = opts.Color or opts.color
	opts.Key = opts.Key or opts.key
	opts.Placeholder = opts.Placeholder or opts.placeholder
	return opts
end

local function GetTickrateLogo()
	local fileName = "tickrate.wip.png"
	local rawUrl = "https://raw.githubusercontent.com/sh5sui/tickrate.wip/main/tickrate.wip.png"
	local getAsset = getcustomasset or getsynasset

	if not getAsset then
		return nil
	end

	local success, assetId = pcall(function()
		if isfile and not isfile(fileName) then
			local response = game:HttpGet(rawUrl)
			if response and #response > 0 and writefile then
				writefile(fileName, response)
			end
		end
		return getAsset(fileName)
	end)

	if success and assetId then
		return assetId
	end
	return nil
end

local function ApplyStyle(instance, radius, strokeColor)
	if radius and radius > 0 then
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, radius)
		corner.Parent = instance
	end
	if strokeColor then
		local stroke = Instance.new("UIStroke")
		stroke.Color = strokeColor
		stroke.Thickness = 1
		stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		stroke.Parent = instance
		return stroke
	end
end

local function MakeDraggable(topBar, targetFrame)
	local dragging, dragInput, dragStart, startPos
	topBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = targetFrame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	topBar.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			dragInput = input
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			targetFrame.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)
end

local NotifHolder = Instance.new("Frame")
NotifHolder.Name = "Notifications"
NotifHolder.Size = UDim2.new(0, 260, 1, -20)
NotifHolder.Position = UDim2.new(1, -270, 0, 10)
NotifHolder.BackgroundTransparency = 1
NotifHolder.Parent = ScreenGui

local NotifLayout = Instance.new("UIListLayout")
NotifLayout.SortOrder = Enum.SortOrder.LayoutOrder
NotifLayout.Padding = UDim.new(0, 6)
NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
NotifLayout.Parent = NotifHolder

function ui.CreateLoader(duration)
	local totalTime = duration or 5
	local fadeTime = 1.2
	local holdTime = math.max(0.5, totalTime - (fadeTime * 2))

	local fileName = "tickrate.wip.full.png"
	local rawUrl = "https://raw.githubusercontent.com/sh5sui/tickrate.wip/main/tickrate.wip.full.png"
	local getAsset = getcustomasset or getsynasset
	local assetId = nil

	if getAsset then
		pcall(function()
			if isfile and not isfile(fileName) then
				local response = game:HttpGet(rawUrl)
				if response and #response > 0 and writefile then
					writefile(fileName, response)
				end
			end
			assetId = getAsset(fileName)
		end)
	end

	local IntroImg = Instance.new("ImageLabel")
	IntroImg.Name = "TickrateIntro"
	IntroImg.Size = UDim2.new(0, 320, 0, 140)
	IntroImg.Position = UDim2.new(0.5, 0, 0.5, 15)
	IntroImg.AnchorPoint = Vector2.new(0.5, 0.5)
	IntroImg.BackgroundTransparency = 1
	IntroImg.Image = assetId or ""
	IntroImg.ImageTransparency = 1
	IntroImg.ScaleType = Enum.ScaleType.Fit
	IntroImg.ZIndex = 100
	IntroImg.Parent = ScreenGui

	local fadeIn = TweenService:Create(
		IntroImg,
		TweenInfo.new(fadeTime, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
		{ ImageTransparency = 0, Position = UDim2.new(0.5, 0, 0.5, 0) }
	)
	fadeIn:Play()
	fadeIn.Completed:Wait()

	task.wait(holdTime)

	local fadeOut = TweenService:Create(
		IntroImg,
		TweenInfo.new(fadeTime, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
		{ ImageTransparency = 1, Position = UDim2.new(0.5, 0, 0.5, -15) }
	)
	fadeOut:Play()
	fadeOut.Completed:Wait()

	IntroImg:Destroy()
end

ui.intro = ui.CreateLoader

local function CreateSectionInColumn(parentCol, secTitle)
	local SectionObj = {}

	local SecFrame = Instance.new("Frame")
	SecFrame.Size = UDim2.new(1, -2, 0, 0)
	SecFrame.AutomaticSize = Enum.AutomaticSize.Y
	SecFrame.BackgroundColor3 = ui.Theme.SectionBg
	SecFrame.Parent = parentCol
	ApplyStyle(SecFrame, 4, ui.Theme.Border)

	local SecPadding = Instance.new("UIPadding")
	SecPadding.PaddingTop = UDim.new(0, 6)
	SecPadding.PaddingBottom = UDim.new(0, 10)
	SecPadding.PaddingLeft = UDim.new(0, 10)
	SecPadding.PaddingRight = UDim.new(0, 10)
	SecPadding.Parent = SecFrame

	local SecLayout = Instance.new("UIListLayout")
	SecLayout.SortOrder = Enum.SortOrder.LayoutOrder
	SecLayout.Padding = UDim.new(0, 6)
	SecLayout.Parent = SecFrame

	local HeaderLbl = Instance.new("TextLabel")
	HeaderLbl.Size = UDim2.new(1, 0, 0, 18)
	HeaderLbl.BackgroundTransparency = 1
	HeaderLbl.Text = secTitle
	HeaderLbl.TextColor3 = ui.Theme.TextInactive
	HeaderLbl.Font = ui.Theme.Font
	HeaderLbl.TextSize = 13
	HeaderLbl.TextXAlignment = Enum.TextXAlignment.Center
	HeaderLbl.Parent = SecFrame

	local function AttachRowAddons(TargetObj, RightAddons, baseFlag, onTrigger)
		function TargetObj:Colorpicker(cpOpts)
			cpOpts = NormalizeOpts(cpOpts)
			local cpFlag = cpOpts.Flag or (baseFlag .. "_Color")
			local colorList = {
				cpOpts.Color or ui.Theme.Accent[1],
				Color3.fromRGB(255, 255, 255),
				ui.Theme.Accent[2],
				ui.Theme.Accent[3],
				ui.Theme.Accent[4]
			}
			local colorIdx = 1
			ui.Flags[cpFlag] = colorList[1]

			local Swatch = Instance.new("TextButton")
			Swatch.Size = UDim2.new(0, 18, 0, 10)
			Swatch.BackgroundColor3 = colorList[1]
			Swatch.Text = ""
			Swatch.Parent = RightAddons
			ApplyStyle(Swatch, 2, ui.Theme.Border)

			Swatch.MouseButton1Click:Connect(function()
				colorIdx = (colorIdx % #colorList) + 1
				local nextCol = colorList[colorIdx]
				Swatch.BackgroundColor3 = nextCol
				ui.Flags[cpFlag] = nextCol
				if cpOpts.Callback then
					cpOpts.Callback(nextCol)
				end
			end)
			return TargetObj
		end

		function TargetObj:Keybind(kbOpts)
			kbOpts = NormalizeOpts(kbOpts)
			local kbFlag = kbOpts.Flag or (baseFlag .. "_Key")
			local currentKey = kbOpts.Key or kbOpts.Default or Enum.KeyCode.None
			ui.Flags[kbFlag] = currentKey

			local GearBtn = Instance.new("TextButton")
			GearBtn.Size = UDim2.new(0, 16, 0, 16)
			GearBtn.BackgroundTransparency = 1
			GearBtn.Text = "⚙"
			GearBtn.TextColor3 = ui.Theme.TextActive
			GearBtn.TextSize = 13
			GearBtn.Font = ui.Theme.FontBold
			GearBtn.Parent = RightAddons

			local binding = false
			GearBtn.MouseButton1Click:Connect(function()
				binding = true
				GearBtn.Text = "..."
			end)

			UserInputService.InputBegan:Connect(function(input, gp)
				if binding then
					if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode ~= Enum.KeyCode.Unknown then
						currentKey = input.KeyCode
					elseif input.UserInputType == Enum.UserInputType.MouseButton1
						or input.UserInputType == Enum.UserInputType.MouseButton2 then
						currentKey = input.UserInputType
					end
					ui.Flags[kbFlag] = currentKey
					GearBtn.Text = "⚙"
					binding = false
					if kbOpts.Callback then
						kbOpts.Callback(currentKey)
					end
				elseif not gp and (input.KeyCode == currentKey or input.UserInputType == currentKey) then
					if onTrigger then
						onTrigger(currentKey)
					end
				end
			end)

			return TargetObj
		end
	end

	function SectionObj:Toggle(opts)
		opts = NormalizeOpts(opts)
		local flag = opts.Flag or opts.Title or "Toggle"
		local state = opts.Default or false
		ui.Flags[flag] = state

		local Row = Instance.new("Frame")
		Row.Size = UDim2.new(1, 0, 0, 18)
		Row.BackgroundTransparency = 1
		Row.Parent = SecFrame

		local Box = Instance.new("TextButton")
		Box.Size = UDim2.new(0, 12, 0, 12)
		Box.Position = UDim2.new(0, 0, 0.5, -6)
		Box.BackgroundColor3 = state and ui.Theme.Accent[1] or Color3.fromRGB(10, 10, 12)
		Box.Text = ""
		Box.AutoButtonColor = false
		Box.Parent = Row
		ApplyStyle(Box, 2, ui.Theme.Border)

		local Title = Instance.new("TextButton")
		Title.Size = UDim2.new(1, -60, 1, 0)
		Title.Position = UDim2.new(0, 20, 0, 0)
		Title.BackgroundTransparency = 1
		Title.Text = opts.Title or "Toggle"
		Title.TextColor3 = state and ui.Theme.TextActive or ui.Theme.TextInactive
		Title.Font = ui.Theme.Font
		Title.TextSize = 13
		Title.TextXAlignment = Enum.TextXAlignment.Left
		Title.Parent = Row

		local RightAddons = Instance.new("Frame")
		RightAddons.Size = UDim2.new(0, 60, 1, 0)
		RightAddons.Position = UDim2.new(1, -60, 0, 0)
		RightAddons.BackgroundTransparency = 1
		RightAddons.Parent = Row

		local AddonLayout = Instance.new("UIListLayout")
		AddonLayout.FillDirection = Enum.FillDirection.Horizontal
		AddonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
		AddonLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		AddonLayout.Padding = UDim.new(0, 6)
		AddonLayout.Parent = RightAddons

		local function SetState(newState)
			state = newState
			ui.Flags[flag] = state
			Box.BackgroundColor3 = state and ui.Theme.Accent[1] or Color3.fromRGB(10, 10, 12)
			Title.TextColor3 = state and ui.Theme.TextActive or ui.Theme.TextInactive
			if opts.Callback then
				opts.Callback(state)
			end
		end

		Box.MouseButton1Click:Connect(function() SetState(not state) end)
		Title.MouseButton1Click:Connect(function() SetState(not state) end)

		local ToggleRet = {
			Set = SetState
		}
		AttachRowAddons(ToggleRet, RightAddons, flag, function()
			SetState(not state)
		end)

		return ToggleRet
	end

	function SectionObj:Keybind(opts)
		opts = NormalizeOpts(opts)
		local kbFlag = opts.Flag or opts.Title or "Keybind"
		local currentKey = opts.Key or opts.Default or Enum.KeyCode.RightShift
		ui.Flags[kbFlag] = currentKey

		local Row = Instance.new("Frame")
		Row.Size = UDim2.new(1, 0, 0, 18)
		Row.BackgroundTransparency = 1
		Row.Parent = SecFrame

		local Lbl = Instance.new("TextLabel")
		Lbl.Size = UDim2.new(1, -60, 1, 0)
		Lbl.BackgroundTransparency = 1
		Lbl.Text = opts.Title or "keybind"
		Lbl.TextColor3 = ui.Theme.TextInactive
		Lbl.Font = ui.Theme.Font
		Lbl.TextSize = 13
		Lbl.TextXAlignment = Enum.TextXAlignment.Left
		Lbl.Parent = Row

		local KeyBtn = Instance.new("TextButton")
		KeyBtn.AutomaticSize = Enum.AutomaticSize.X
		KeyBtn.Size = UDim2.new(0, 24, 0, 16)
		KeyBtn.Position = UDim2.new(1, 0, 0.5, -8)
		KeyBtn.AnchorPoint = Vector2.new(1, 0)
		KeyBtn.BackgroundColor3 = Color3.fromRGB(11, 11, 13)
		KeyBtn.Text = " " .. currentKey.Name .. " "
		KeyBtn.TextColor3 = ui.Theme.TextActive
		KeyBtn.Font = ui.Theme.Font
		KeyBtn.TextSize = 11
		KeyBtn.Parent = Row
		ApplyStyle(KeyBtn, 2, ui.Theme.Border)

		local binding = false
		KeyBtn.MouseButton1Click:Connect(function()
			binding = true
			KeyBtn.Text = " ... "
		end)

		UserInputService.InputBegan:Connect(function(input, gp)
			if binding then
				if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode ~= Enum.KeyCode.Unknown then
					currentKey = input.KeyCode
					ui.Flags[kbFlag] = currentKey
					KeyBtn.Text = " " .. currentKey.Name .. " "
					binding = false
					if opts.Callback then
						opts.Callback(currentKey)
					end
				end
			end
		end)
	end

	function SectionObj:Textbox(opts)
		opts = NormalizeOpts(opts)
		local flag = opts.Flag or opts.Title or "Textbox"
		local defaultText = opts.Default or ""
		ui.Flags[flag] = defaultText

		local Container = Instance.new("Frame")
		Container.Size = UDim2.new(1, 0, 0, 38)
		Container.BackgroundTransparency = 1
		Container.Parent = SecFrame

		local Title = Instance.new("TextLabel")
		Title.Size = UDim2.new(1, 0, 0, 15)
		Title.BackgroundTransparency = 1
		Title.Text = opts.Title or "textbox"
		Title.TextColor3 = ui.Theme.TextInactive
		Title.Font = ui.Theme.Font
		Title.TextSize = 12
		Title.TextXAlignment = Enum.TextXAlignment.Left
		Title.Parent = Container

		local InputFrame = Instance.new("Frame")
		InputFrame.Size = UDim2.new(1, 0, 0, 20)
		InputFrame.Position = UDim2.new(0, 0, 0, 17)
		InputFrame.BackgroundColor3 = Color3.fromRGB(11, 11, 13)
		InputFrame.Parent = Container
		local stroke = ApplyStyle(InputFrame, 2, ui.Theme.Border)

		local Box = Instance.new("TextBox")
		Box.Size = UDim2.new(1, -12, 1, 0)
		Box.Position = UDim2.new(0, 6, 0, 0)
		Box.BackgroundTransparency = 1
		Box.Text = defaultText
		Box.PlaceholderText = opts.Placeholder or "type here..."
		Box.PlaceholderColor3 = ui.Theme.TextDim
		Box.TextColor3 = ui.Theme.TextActive
		Box.Font = ui.Theme.Font
		Box.TextSize = 12
		Box.TextXAlignment = Enum.TextXAlignment.Left
		Box.ClearTextOnFocus = opts.ClearOnFocus or false
		Box.Parent = InputFrame

		Box.Focused:Connect(function()
			if stroke then stroke.Color = ui.Theme.Accent[1] end
		end)

		Box.FocusLost:Connect(function(enterPressed)
			if stroke then stroke.Color = ui.Theme.Border end
			ui.Flags[flag] = Box.Text
			if opts.Callback then
				opts.Callback(Box.Text, enterPressed)
			end
		end)

		return Box
	end

	function SectionObj:Colorpicker(opts)
		opts = NormalizeOpts(opts)
		local cpFlag = opts.Flag or opts.Title or "Colorpicker"
		local palette = {
			opts.Color or ui.Theme.Accent[2],
			ui.Theme.Accent[3],
			ui.Theme.Accent[1],
			ui.Theme.Accent[4],
			Color3.fromRGB(255, 255, 255)
		}
		local idx = 1
		ui.Flags[cpFlag] = palette[1]

		local Row = Instance.new("Frame")
		Row.Size = UDim2.new(1, 0, 0, 18)
		Row.BackgroundTransparency = 1
		Row.Parent = SecFrame

		local Lbl = Instance.new("TextLabel")
		Lbl.Size = UDim2.new(1, -30, 1, 0)
		Lbl.BackgroundTransparency = 1
		Lbl.Text = opts.Title or "colour"
		Lbl.TextColor3 = ui.Theme.TextInactive
		Lbl.Font = ui.Theme.Font
		Lbl.TextSize = 13
		Lbl.TextXAlignment = Enum.TextXAlignment.Left
		Lbl.Parent = Row

		local Swatch = Instance.new("TextButton")
		Swatch.Size = UDim2.new(0, 18, 0, 10)
		Swatch.Position = UDim2.new(1, -18, 0.5, -5)
		Swatch.BackgroundColor3 = palette[1]
		Swatch.Text = ""
		Swatch.Parent = Row
		ApplyStyle(Swatch, 2, ui.Theme.Border)

		Swatch.MouseButton1Click:Connect(function()
			idx = (idx % #palette) + 1
			Swatch.BackgroundColor3 = palette[idx]
			ui.Flags[cpFlag] = palette[idx]
			if opts.Callback then
				opts.Callback(palette[idx])
			end
		end)
	end

	function SectionObj:Dropdown(opts)
		opts = NormalizeOpts(opts)
		local flag = opts.Flag or opts.Title or "Dropdown"
		local list = opts.List or {"Option 1"}
		local idx = table.find(list, opts.Default) or 1
		ui.Flags[flag] = list[idx]

		local Container = Instance.new("Frame")
		Container.Size = UDim2.new(1, 0, 0, 38)
		Container.BackgroundTransparency = 1
		Container.Parent = SecFrame

		local Title = Instance.new("TextLabel")
		Title.Size = UDim2.new(1, 0, 0, 15)
		Title.BackgroundTransparency = 1
		Title.Text = opts.Title or "dropdown"
		Title.TextColor3 = ui.Theme.TextInactive
		Title.Font = ui.Theme.Font
		Title.TextSize = 12
		Title.TextXAlignment = Enum.TextXAlignment.Left
		Title.Parent = Container

		local Box = Instance.new("TextButton")
		Box.Size = UDim2.new(1, 0, 0, 20)
		Box.Position = UDim2.new(0, 0, 0, 17)
		Box.BackgroundColor3 = Color3.fromRGB(11, 11, 13)
		Box.Text = ""
		Box.AutoButtonColor = false
		Box.Parent = Container
		ApplyStyle(Box, 2, ui.Theme.Border)

		local ValLabel = Instance.new("TextLabel")
		ValLabel.Size = UDim2.new(1, -12, 1, 0)
		ValLabel.Position = UDim2.new(0, 6, 0, 0)
		ValLabel.BackgroundTransparency = 1
		ValLabel.Text = tostring(list[idx])
		ValLabel.TextColor3 = ui.Theme.TextInactive
		ValLabel.Font = ui.Theme.Font
		ValLabel.TextSize = 12
		ValLabel.TextXAlignment = Enum.TextXAlignment.Left
		ValLabel.Parent = Box

		Box.MouseButton1Click:Connect(function()
			idx = (idx % #list) + 1
			local selected = list[idx]
			ValLabel.Text = tostring(selected)
			ui.Flags[flag] = selected
			if opts.Callback then
				opts.Callback(selected)
			end
		end)
	end

	function SectionObj:Slider(opts)
		opts = NormalizeOpts(opts)
		local flag = opts.Flag or opts.Title or "Slider"
		local min = opts.Min or 0
		local max = opts.Max or 100
		local symbol = opts.Symbol or ""
		local val = math.clamp(opts.Default or min, min, max)
		ui.Flags[flag] = val

		local Container = Instance.new("Frame")
		Container.Size = UDim2.new(1, 0, 0, 30)
		Container.BackgroundTransparency = 1
		Container.Parent = SecFrame

		local Title = Instance.new("TextLabel")
		Title.Size = UDim2.new(1, 0, 0, 15)
		Title.BackgroundTransparency = 1
		Title.Text = opts.Title or "slider"
		Title.TextColor3 = ui.Theme.TextInactive
		Title.Font = ui.Theme.Font
		Title.TextSize = 12
		Title.TextXAlignment = Enum.TextXAlignment.Left
		Title.Parent = Container

		local Track = Instance.new("TextButton")
		Track.Size = UDim2.new(1, 0, 0, 8)
		Track.Position = UDim2.new(0, 0, 0, 19)
		Track.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
		Track.Text = ""
		Track.AutoButtonColor = false
		Track.Parent = Container
		ApplyStyle(Track, 2, ui.Theme.Border)

		local Fill = Instance.new("Frame")
		Fill.Size = UDim2.new((val - min) / (max - min), 0, 1, 0)
		Fill.BackgroundColor3 = Color3.fromRGB(145, 150, 175)
		Fill.BorderSizePixel = 0
		Fill.Parent = Track
		ApplyStyle(Fill, 2)

		local ValText = Instance.new("TextLabel")
		ValText.Size = UDim2.new(1, 0, 1, 0)
		ValText.BackgroundTransparency = 1
		ValText.Text = tostring(val) .. symbol
		ValText.TextColor3 = ui.Theme.TextActive
		ValText.Font = ui.Theme.Font
		ValText.TextSize = 11
		ValText.Parent = Track

		local sliding = false
		local function UpdateSlider(input)
			local pct = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
			local raw = min + (max - min) * pct
			local mult = 10 ^ (opts.Decimals or 0)
			val = math.floor(raw * mult + 0.5) / mult
			Fill.Size = UDim2.new(pct, 0, 1, 0)
			ValText.Text = tostring(val) .. symbol
			ui.Flags[flag] = val
			if opts.Callback then
				opts.Callback(val)
			end
		end

		Track.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				sliding = true
				UpdateSlider(input)
			end
		end)
		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				sliding = false
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
				UpdateSlider(input)
			end
		end)
	end

	function SectionObj:Button(opts)
		opts = NormalizeOpts(opts)
		local Btn = Instance.new("TextButton")
		Btn.Size = UDim2.new(1, 0, 0, 22)
		Btn.BackgroundColor3 = ui.Theme.ElementBg
		Btn.Text = opts.Title or "Button"
		Btn.TextColor3 = ui.Theme.TextActive
		Btn.Font = ui.Theme.Font
		Btn.TextSize = 12
		Btn.Parent = SecFrame
		ApplyStyle(Btn, 2, ui.Theme.Border)

		Btn.MouseButton1Click:Connect(function()
			if opts.Callback then
				opts.Callback()
			end
		end)
	end

	function SectionObj:Label(opts)
		opts = NormalizeOpts(opts)
		local baseFlag = opts.Flag or opts.Title or "Label"

		local Row = Instance.new("Frame")
		Row.Size = UDim2.new(1, 0, 0, 18)
		Row.BackgroundTransparency = 1
		Row.Parent = SecFrame

		local Lbl = Instance.new("TextLabel")
		Lbl.Size = UDim2.new(1, -60, 1, 0)
		Lbl.BackgroundTransparency = 1
		Lbl.Text = opts.Title or "Label"
		Lbl.TextColor3 = opts.Color or ui.Theme.TextInactive
		Lbl.Font = ui.Theme.Font
		Lbl.TextSize = 13
		Lbl.TextXAlignment = Enum.TextXAlignment.Left
		Lbl.Parent = Row

		local RightAddons = Instance.new("Frame")
		RightAddons.Size = UDim2.new(0, 60, 1, 0)
		RightAddons.Position = UDim2.new(1, -60, 0, 0)
		RightAddons.BackgroundTransparency = 1
		RightAddons.Parent = Row

		local AddonLayout = Instance.new("UIListLayout")
		AddonLayout.FillDirection = Enum.FillDirection.Horizontal
		AddonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
		AddonLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		AddonLayout.Padding = UDim.new(0, 6)
		AddonLayout.Parent = RightAddons

		local LabelRet = {}

		function LabelRet:Set(newText, newColor)
			Lbl.Text = tostring(newText)
			if newColor then
				Lbl.TextColor3 = newColor
			end
		end

		AttachRowAddons(LabelRet, RightAddons, baseFlag)

		return LabelRet
	end
	SectionObj.Text = SectionObj.Label

	return SectionObj
end

function ui.Window(title, size)
	local WindowObj = {
		Tabs = {},
		ActiveTab = nil,
		Visible = true
	}
	ui.CurrentWindow = WindowObj

	local winSize = size or Vector2.new(530, 445)
	local MainFrame = Instance.new("Frame")
	MainFrame.Name = "MainWindow"
	MainFrame.Size = UDim2.new(0, winSize.X, 0, winSize.Y)
	MainFrame.Position = UDim2.new(0.5, -winSize.X / 2, 0.5, -winSize.Y / 2)
	MainFrame.BackgroundColor3 = ui.Theme.Background
	MainFrame.BorderSizePixel = 0
	MainFrame.Parent = ScreenGui
	ApplyStyle(MainFrame, 6, ui.Theme.Border)

	UserInputService.InputBegan:Connect(function(input, gp)
		if not gp and input.KeyCode == ui.ToggleKey then
			WindowObj.Visible = not WindowObj.Visible
			MainFrame.Visible = WindowObj.Visible
		end
	end)

	local Header = Instance.new("Frame")
	Header.Name = "Header"
	Header.Size = UDim2.new(1, 0, 0, 32)
	Header.BackgroundTransparency = 1
	Header.Parent = MainFrame
	MakeDraggable(Header, MainFrame)

	local LogoBox = Instance.new("Frame")
	LogoBox.Size = UDim2.new(0, 20, 0, 18)
	LogoBox.Position = UDim2.new(0, 10, 0.5, -9)
	LogoBox.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
	LogoBox.ClipsDescendants = true
	LogoBox.Parent = Header
	ApplyStyle(LogoBox, 3, ui.Theme.Border)

	local logoAsset = GetTickrateLogo()
	if logoAsset then
		local LogoImg = Instance.new("ImageLabel")
		LogoImg.Size = UDim2.new(1, 0, 1, 0)
		LogoImg.BackgroundTransparency = 1
		LogoImg.Image = logoAsset
		LogoImg.ScaleType = Enum.ScaleType.Fit
		LogoImg.Parent = LogoBox
	else
		local LogoText = Instance.new("TextLabel")
		LogoText.Size = UDim2.new(1, 0, 1, 0)
		LogoText.BackgroundTransparency = 1
		LogoText.RichText = true
		LogoText.Text = "<b><i>t<font color='#e65c9c'>r</font></i></b>"
		LogoText.TextColor3 = ui.Theme.TextActive
		LogoText.Font = ui.Theme.FontBold
		LogoText.TextSize = 13
		LogoText.Parent = LogoBox
	end

	local TitleLabel = Instance.new("TextLabel")
	TitleLabel.Size = UDim2.new(0, 160, 1, 0)
	TitleLabel.Position = UDim2.new(0, 36, 0, 0)
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.RichText = true
	local base, ext = string.match(title or "tickrate.wip", "^(.-)%.(.+)$")
	if base and ext then
		TitleLabel.Text = string.format("<font color='#9696a0'>%s.</font><b>%s</b>", base, ext)
	else
		TitleLabel.Text = title or "tickrate.wip"
	end
	TitleLabel.TextColor3 = ui.Theme.TextActive
	TitleLabel.Font = ui.Theme.Font
	TitleLabel.TextSize = 13
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	TitleLabel.Parent = Header

	local TopTabHolder = Instance.new("Frame")
	TopTabHolder.Size = UDim2.new(0, 280, 1, 0)
	TopTabHolder.Position = UDim2.new(1, -290, 0, 0)
	TopTabHolder.BackgroundTransparency = 1
	TopTabHolder.Parent = Header

	local TopTabLayout = Instance.new("UIListLayout")
	TopTabLayout.FillDirection = Enum.FillDirection.Horizontal
	TopTabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	TopTabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	TopTabLayout.Padding = UDim.new(0, 14)
	TopTabLayout.Parent = TopTabHolder

	local Divider1 = Instance.new("Frame")
	Divider1.Size = UDim2.new(1, 0, 0, 1)
	Divider1.Position = UDim2.new(0, 0, 0, 32)
	Divider1.BackgroundColor3 = ui.Theme.Border
	Divider1.BorderSizePixel = 0
	Divider1.Parent = MainFrame

	local SubHeader = Instance.new("Frame")
	SubHeader.Size = UDim2.new(1, -24, 0, 26)
	SubHeader.Position = UDim2.new(0, 12, 0, 33)
	SubHeader.BackgroundTransparency = 1
	SubHeader.Parent = MainFrame

	local SubTabLayout = Instance.new("UIListLayout")
	SubTabLayout.FillDirection = Enum.FillDirection.Horizontal
	SubTabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	SubTabLayout.Padding = UDim.new(0, 14)
	SubTabLayout.Parent = SubHeader

	local ContentContainer = Instance.new("Frame")
	ContentContainer.Size = UDim2.new(1, -24, 1, -72)
	ContentContainer.Position = UDim2.new(0, 12, 0, 62)
	ContentContainer.BackgroundTransparency = 1
	ContentContainer.Parent = MainFrame

	local WatermarkFrame = Instance.new("Frame")
	WatermarkFrame.Size = UDim2.new(0, 150, 0, 24)
	WatermarkFrame.Position = UDim2.new(0, 15, 0, 15)
	WatermarkFrame.BackgroundColor3 = ui.Theme.Background
	WatermarkFrame.Visible = false
	WatermarkFrame.Parent = ScreenGui
	ApplyStyle(WatermarkFrame, 4, ui.Theme.Border)

	local WatermarkLabel = Instance.new("TextLabel")
	WatermarkLabel.Size = UDim2.new(1, -16, 1, 0)
	WatermarkLabel.Position = UDim2.new(0, 8, 0, 0)
	WatermarkLabel.BackgroundTransparency = 1
	WatermarkLabel.TextColor3 = ui.Theme.TextActive
	WatermarkLabel.Font = ui.Theme.Font
	WatermarkLabel.TextSize = 12
	WatermarkLabel.TextXAlignment = Enum.TextXAlignment.Left
	WatermarkLabel.Parent = WatermarkFrame

    WatermarkFrame.Name = "Watermark"

        function WindowObj.Watermark(text)
            if not text or text == "" or text == false then
                WatermarkFrame.Visible = false
                return
            end
            WatermarkLabel.Text = tostring(text)
            WatermarkFrame.Size = UDim2.new(0, WatermarkLabel.TextBounds.X + 20, 0, 24)
            WatermarkFrame.Visible = true
        end

	function WindowObj.SendNotification(notifType, text, duration)
		local notif = Instance.new("Frame")
		notif.Size = UDim2.new(1, 0, 0, 36)
		notif.BackgroundColor3 = ui.Theme.Background
		notif.Parent = NotifHolder
		ApplyStyle(notif, 4, ui.Theme.Border)

		local accentBar = Instance.new("Frame")
		accentBar.Size = UDim2.new(0, 2, 1, 0)
		accentBar.BorderSizePixel = 0
		accentBar.BackgroundColor3 = (notifType == "Error" and ui.Theme.Accent[2])
			or (notifType == "Warning" and ui.Theme.Accent[3])
			or ui.Theme.Accent[1]
		accentBar.Parent = notif

		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(1, -16, 1, 0)
		lbl.Position = UDim2.new(0, 10, 0, 0)
		lbl.BackgroundTransparency = 1
		lbl.Text = text
		lbl.TextColor3 = ui.Theme.TextActive
		lbl.Font = ui.Theme.Font
		lbl.TextSize = 12
		lbl.TextWrapped = true
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Parent = notif

		task.delay(duration or 4, function()
			if notif and notif.Parent then
				notif:Destroy()
			end
		end)
	end

	function WindowObj.ToggleAnime() end

	function WindowObj:SwitchTab(tabObj)
		for _, t in ipairs(WindowObj.Tabs) do
			t.Page.Visible = false
			t.Button.TextColor3 = ui.Theme.TextInactive
			t.Underline.Visible = false
			for _, st in ipairs(t.SubTabs) do
				st.Button.Visible = false
			end
		end
		tabObj.Page.Visible = true
		tabObj.Button.TextColor3 = ui.Theme.TextActive
		tabObj.Underline.Visible = true
		for _, st in ipairs(tabObj.SubTabs) do
			st.Button.Visible = true
		end
		WindowObj.ActiveTab = tabObj
		ui.CurrentTab = tabObj
	end

	function WindowObj:Tab(tabTitle, subTabsList)
		local TabObj = {
			SubTabs = {},
			SubTabMap = {},
			ActiveSubTab = nil
		}

		local TabBtn = Instance.new("TextButton")
		TabBtn.Name = tabTitle
		TabBtn.AutomaticSize = Enum.AutomaticSize.X
		TabBtn.Size = UDim2.new(0, 0, 1, 0)
		TabBtn.BackgroundTransparency = 1
		TabBtn.Text = tabTitle
		TabBtn.TextColor3 = ui.Theme.TextInactive
		TabBtn.Font = ui.Theme.Font
		TabBtn.TextSize = 13
		TabBtn.Parent = TopTabHolder

		local Underline = Instance.new("Frame")
		Underline.Size = UDim2.new(1, 0, 0, 2)
		Underline.Position = UDim2.new(0, 0, 1, -6)
		Underline.BackgroundColor3 = ui.Theme.Accent[1]
		Underline.BorderSizePixel = 0
		Underline.Visible = false
		Underline.Parent = TabBtn

		local Page = Instance.new("Frame")
		Page.Size = UDim2.new(1, 0, 1, 0)
		Page.BackgroundTransparency = 1
		Page.Visible = false
		Page.Parent = ContentContainer

		function TabObj:SwitchSubTab(subTabObj)
			for _, st in ipairs(TabObj.SubTabs) do
				st.SubPage.Visible = false
				st.Button.TextColor3 = ui.Theme.TextInactive
				st.Line.Visible = false
			end
			subTabObj.SubPage.Visible = true
			subTabObj.Button.TextColor3 = ui.Theme.TextActive
			subTabObj.Line.Visible = true
			TabObj.ActiveSubTab = subTabObj
			ui.CurrentSubTab = subTabObj
		end

		function TabObj:SubTab(subName)
			local key = string.lower(subName)
			if TabObj.SubTabMap[key] then
				ui.CurrentSubTab = TabObj.SubTabMap[key]
				return TabObj.SubTabMap[key]
			end

			local SubTabObj = {}

			local SubBtn = Instance.new("TextButton")
			SubBtn.AutomaticSize = Enum.AutomaticSize.X
			SubBtn.Size = UDim2.new(0, 0, 1, 0)
			SubBtn.BackgroundTransparency = 1
			SubBtn.Text = subName
			SubBtn.TextColor3 = ui.Theme.TextInactive
			SubBtn.Font = ui.Theme.Font
			SubBtn.TextSize = 13
			SubBtn.Visible = (WindowObj.ActiveTab == TabObj)
			SubBtn.Parent = SubHeader

			local SubLine = Instance.new("Frame")
			SubLine.Size = UDim2.new(1, 0, 0, 2)
			SubLine.Position = UDim2.new(0, 0, 1, -2)
			SubLine.BackgroundColor3 = ui.Theme.Accent[1]
			SubLine.BorderSizePixel = 0
			SubLine.Visible = false
			SubLine.Parent = SubBtn

			local SubPage = Instance.new("Frame")
			SubPage.Name = subName .. "_SubPage"
			SubPage.Size = UDim2.new(1, 0, 1, 0)
			SubPage.BackgroundTransparency = 1
			SubPage.Visible = false
			SubPage.Parent = Page

			local LeftCol = Instance.new("ScrollingFrame")
			LeftCol.Size = UDim2.new(0.5, -6, 1, 0)
			LeftCol.BackgroundTransparency = 1
			LeftCol.BorderSizePixel = 0
			LeftCol.ScrollBarThickness = 0
			LeftCol.AutomaticCanvasSize = Enum.AutomaticSize.Y
			LeftCol.CanvasSize = UDim2.new(0, 0, 0, 0)
			LeftCol.Parent = SubPage

			local LeftLayout = Instance.new("UIListLayout")
			LeftLayout.SortOrder = Enum.SortOrder.LayoutOrder
			LeftLayout.Padding = UDim.new(0, 10)
			LeftLayout.Parent = LeftCol

			local RightCol = Instance.new("ScrollingFrame")
			RightCol.Size = UDim2.new(0.5, -6, 1, 0)
			RightCol.Position = UDim2.new(0.5, 6, 0, 0)
			RightCol.BackgroundTransparency = 1
			RightCol.BorderSizePixel = 0
			RightCol.ScrollBarThickness = 0
			RightCol.AutomaticCanvasSize = Enum.AutomaticSize.Y
			RightCol.CanvasSize = UDim2.new(0, 0, 0, 0)
			RightCol.Parent = SubPage

			local RightLayout = Instance.new("UIListLayout")
			RightLayout.SortOrder = Enum.SortOrder.LayoutOrder
			RightLayout.Padding = UDim.new(0, 10)
			RightLayout.Parent = RightCol

			SubTabObj.Button = SubBtn
			SubTabObj.Line = SubLine
			SubTabObj.SubPage = SubPage

			function SubTabObj:Section(secTitle, side)
				local col = (string.lower(tostring(side)) == "right") and RightCol or LeftCol
				local sec = CreateSectionInColumn(col, secTitle)
				ui.CurrentSection = sec
				return sec
			end

			SubBtn.MouseButton1Click:Connect(function()
				TabObj:SwitchSubTab(SubTabObj)
			end)

			table.insert(TabObj.SubTabs, SubTabObj)
			TabObj.SubTabMap[key] = SubTabObj

			if #TabObj.SubTabs == 1 then
				TabObj:SwitchSubTab(SubTabObj)
			end

			return SubTabObj
		end

		local subList = subTabsList or (#WindowObj.Tabs == 0 and {"players", "world"} or {tabTitle})
		for _, subName in ipairs(subList) do
			TabObj:SubTab(subName)
		end

		TabObj.Button = TabBtn
		TabObj.Underline = Underline
		TabObj.Page = Page

		TabBtn.MouseButton1Click:Connect(function()
			WindowObj:SwitchTab(TabObj)
		end)

		function TabObj:Section(secTitle, side, subTabName)
			local targetSub = subTabName and TabObj:SubTab(subTabName) or TabObj.SubTabs[1]
			local sec = targetSub:Section(secTitle, side)
			ui.CurrentSection = sec
			return sec
		end

		table.insert(WindowObj.Tabs, TabObj)
		if #WindowObj.Tabs == 1 then
			WindowObj:SwitchTab(TabObj)
		end
		ui.CurrentTab = TabObj
		ui.CurrentSubTab = TabObj.SubTabs[1]
		return TabObj
	end

	function WindowObj:AddSettingsTab()
		local ConfigTab = WindowObj:Tab("config", {"configs"})
		local ConfigSec = ConfigTab:Section("configuration", "Left")
		ConfigSec:Button({
			Title = "print all flags to console",
			Callback = function()
				for k, v in pairs(ui.Flags) do
					print(k, "=", tostring(v))
				end
			end
		})
	end

	return WindowObj
end

local function EnsureActiveSection()
	if not ui.CurrentWindow then
		ui.create("tickrate.wip")
	end
	if not ui.CurrentTab then
		ui.tab("visuals", {"players", "world"})
	end
	if not ui.CurrentSection then
		ui.section("main", "Left")
	end
	return ui.CurrentSection
end

function ui.create(title, size)
	return ui.Window(title or "tickrate.wip", size or Vector2.new(530, 445))
end

function ui.watermark(text)
	if ui.CurrentWindow then
		ui.CurrentWindow.Watermark(text)
	end
end

function ui.notify(notifType, text, duration)
	if ui.CurrentWindow then
		ui.CurrentWindow.SendNotification(notifType, text, duration)
	end
end

function ui.tab(title, subTabs)
	if not ui.CurrentWindow then ui.create() end
	return ui.CurrentWindow:Tab(title, subTabs)
end

function ui.subtab(subName)
	if not ui.CurrentTab then ui.tab("visuals") end
	return ui.CurrentTab:SubTab(subName)
end

function ui.section(title, side, subTabName)
	if not ui.CurrentTab then ui.tab("visuals") end
	local targetTab = ui.CurrentTab

	if subTabName and ui.CurrentWindow then
		local key = string.lower(subTabName)
		for _, t in ipairs(ui.CurrentWindow.Tabs) do
			if t.SubTabMap and t.SubTabMap[key] then
				targetTab = t
				break
			end
		end
	end

	return targetTab:Section(title, side, subTabName)
end

function ui.toggle(opts)
	return EnsureActiveSection():Toggle(opts)
end

function ui.keybind(opts)
	return EnsureActiveSection():Keybind(opts)
end

function ui.textbox(opts)
	return EnsureActiveSection():Textbox(opts)
end

function ui.slider(opts)
	return EnsureActiveSection():Slider(opts)
end

function ui.dropdown(opts)
	return EnsureActiveSection():Dropdown(opts)
end

function ui.colorpicker(opts)
	return EnsureActiveSection():Colorpicker(opts)
end

function ui.button(opts)
	return EnsureActiveSection():Button(opts)
end

function ui.label(opts)
	return EnsureActiveSection():Label(opts)
end

ui.text = ui.label

if getgenv then
	getgenv().Library = ui
	getgenv().ui = ui
end

return ui