local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FPSHelperUI"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Main UI Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 350, 0, 300)
MainFrame.Position = UDim2.new(0, 50, 0, 50)
MainFrame.BackgroundColor3 = Color3.fromRGB(34, 34, 34)
MainFrame.BorderSizePixel = 0
MainFrame.BackgroundTransparency = 0.8
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- Title Label
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "FPS Helper"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 24
Title.TextStrokeTransparency = 0.5
Title.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
Title.Parent = MainFrame

-- Toggle Button for Aimbot
local AimbotButton = Instance.new("TextButton")
AimbotButton.Size = UDim2.new(0, 300, 0, 40)
AimbotButton.Position = UDim2.new(0, 25, 0, 60)
AimbotButton.Text = "Aimbot: OFF"
AimbotButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
AimbotButton.TextColor3 = Color3.fromRGB(255, 255, 255)
AimbotButton.Font = Enum.Font.SourceSans
AimbotButton.TextSize = 20
AimbotButton.TextStrokeTransparency = 0.5
AimbotButton.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
AimbotButton.Parent = MainFrame

-- Toggle Button for ESP
local ESPButton = Instance.new("TextButton")
ESPButton.Size = UDim2.new(0, 300, 0, 40)
ESPButton.Position = UDim2.new(0, 25, 0, 110)
ESPButton.Text = "ESP: OFF"
ESPButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ESPButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ESPButton.Font = Enum.Font.SourceSans
ESPButton.TextSize = 20
ESPButton.TextStrokeTransparency = 0.5
ESPButton.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
ESPButton.Parent = MainFrame

-- Animation for UI Load
local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)
local goal = {Position = UDim2.new(0, 50, 0, 50)}
local tween = TweenService:Create(MainFrame, tweenInfo, goal)
tween:Play()

-- Status for Aimbot and ESP
local aimbotActive = false
local espActive = false

-- Aimbot Toggle
AimbotButton.MouseButton1Click:Connect(function()
	aimbotActive = not aimbotActive
	AimbotButton.Text = "Aimbot: " .. (aimbotActive and "ON" or "OFF")
end)

-- ESP Toggle
ESPButton.MouseButton1Click:Connect(function()
	espActive = not espActive
	ESPButton.Text = "ESP: " .. (espActive and "ON" or "OFF")
end)

-- ESP Functions (with better line creation)
local function createESPText()
	local text = Drawing.new("Text")
	text.Color = Color3.fromRGB(255, 255, 255)
	text.Size = 14
	text.Center = true
	text.Outline = true
	text.Visible = false
	return text
end

local function createESPLine()
	local line = Drawing.new("Line")
	line.Color = Color3.fromRGB(255, 255, 255)
	line.Thickness = 2
	line.Transparency = 1
	line.Visible = false
	return line
end

local espData = {}

local function setupESPForPlayer(player)
	if player == LocalPlayer then return end

	espData[player] = {
		Name = createESPText(),
		Distance = createESPText(),
		HP = createESPText(),
		LookLine = createESPLine(),
	}
end

for _, player in ipairs(Players:GetPlayers()) do
	setupESPForPlayer(player)
end

Players.PlayerAdded:Connect(setupESPForPlayer)

Players.PlayerRemoving:Connect(function(player)
	if espData[player] then
		for _, obj in pairs(espData[player]) do
			obj:Remove()
		end
		espData[player] = nil
	end
end)

RunService.RenderStepped:Connect(function()
	for player, data in pairs(espData) do
		local character = player.Character
		if character and character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("Humanoid") then
			local rootPart = character:FindFirstChild("HumanoidRootPart")
			local humanoid = character:FindFirstChild("Humanoid")

			local screenPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
			if onScreen and espActive then
				local dist = (rootPart.Position - Camera.CFrame.Position).Magnitude

				-- ESP Name
				data.Name.Position = Vector2.new(screenPos.X, screenPos.Y - 40)
				data.Name.Text = player.Name
				data.Name.Visible = true

				-- ESP Distance
				data.Distance.Position = Vector2.new(screenPos.X, screenPos.Y + 10)
				data.Distance.Text = string.format("[%.0f studs]", dist)
				data.Distance.Visible = true

				-- ESP HP
				data.HP.Position = Vector2.new(screenPos.X, screenPos.Y + 25)
				data.HP.Text = "HP: " .. math.floor(humanoid.Health)
				data.HP.Visible = true
			else
				data.Name.Visible = false
				data.Distance.Visible = false
				data.HP.Visible = false
			end
		end
	end
end)

-- Aimbot Function (on right-click)
local function getClosestPlayer()
	local closestPlayer = nil
	local shortestDistance = math.huge

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
			local head = player.Character.Head
			local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
			if onScreen then
				local distance = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)).Magnitude
				if distance < shortestDistance then
					shortestDistance = distance
					closestPlayer = player
				end
			end
		end
	end

	return closestPlayer
end

UserInputService.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton2 and aimbotActive then
		local targetPlayer = getClosestPlayer()
		if targetPlayer and targetPlayer.Character then
			local headPos = targetPlayer.Character.Head.Position
			local direction = (headPos - Camera.CFrame.Position).unit
			local cameraPos = Camera.CFrame.Position
			local aimCFrame = CFrame.new(cameraPos, cameraPos + direction)
			Camera.CFrame = aimCFrame
		end
	end
end)

RunService.RenderStepped:Connect(function()
	-- Aimbot logic when the right mouse button is held
	if aimbotActive and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
		local targetPlayer = getClosestPlayer()
		if targetPlayer and targetPlayer.Character then
			local headPos = targetPlayer.Character.Head.Position
			local direction = (headPos - Camera.CFrame.Position).unit
			local cameraPos = Camera.CFrame.Position
			local aimCFrame = CFrame.new(cameraPos, cameraPos + direction)
			Camera.CFrame = aimCFrame
		end
	end
end)
