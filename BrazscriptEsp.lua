-- =========================
-- Serviços
-- =========================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local ESP_ATIVO = false
local ESPs = {}

-- =========================
-- GUI
-- =========================
local gui = Instance.new("ScreenGui")
gui.Name = "PurpleESP"
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 130)
frame.Position = UDim2.new(0, 20, 0.5, -65)
frame.BorderSizePixel = 0
frame.Parent = gui

local corner = Instance.new("UICorner", frame)
corner.CornerRadius = UDim.new(0, 14)

-- RGB Background
task.spawn(function()
	local h = 0
	while frame.Parent do
		h = (h + 1) % 360
		frame.BackgroundColor3 = Color3.fromHSV(h/360, 1, 0.25)
		task.wait(0.03)
	end
end)

-- Título
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "Purple ESP"
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextColor3 = Color3.fromRGB(200,100,255)
title.Parent = frame

-- Botão ESP
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(1, -20, 0, 50)
toggleBtn.Position = UDim2.new(0, 10, 0, 40)
toggleBtn.Text = "ESP: OFF"
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 18
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
toggleBtn.Parent = frame

local btnCorner = Instance.new("UICorner", toggleBtn)
btnCorner.CornerRadius = UDim.new(0, 10)

-- =========================
-- GUI MÓVEL (DRAG)
-- =========================
local dragging = false
local dragStart
local startPos

local function updateDrag(input)
	local delta = input.Position - dragStart
	frame.Position = UDim2.new(
		startPos.X.Scale,
		startPos.X.Offset + delta.X,
		startPos.Y.Scale,
		startPos.Y.Offset + delta.Y
	)
end

frame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
	or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = frame.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

frame.InputChanged:Connect(function(input)
	if (input.UserInputType == Enum.UserInputType.MouseMovement
	or input.UserInputType == Enum.UserInputType.Touch) and dragging then
		updateDrag(input)
	end
end)

-- =========================
-- ESP FUNÇÕES
-- =========================
local function removerESP(character)
	if ESPs[character] then
		ESPs[character]:Destroy()
		ESPs[character] = nil
	end
end

local function criarSeta(head)
	local bb = Instance.new("BillboardGui")
	bb.Size = UDim2.new(0, 90, 0, 80)
	bb.StudsOffset = Vector3.new(0, 3.2, 0)
	bb.AlwaysOnTop = true
	bb.Adornee = head

	local arrow = Instance.new("TextLabel")
	arrow.Size = UDim2.new(1, 0, 0.6, 0)
	arrow.BackgroundTransparency = 1
	arrow.Text = "↓"
	arrow.TextScaled = true
	arrow.Font = Enum.Font.GothamBlack
	arrow.TextColor3 = Color3.fromRGB(180, 0, 255)
	arrow.Parent = bb

	local text = Instance.new("TextLabel")
	text.Position = UDim2.new(0, 0, 0.6, 0)
	text.Size = UDim2.new(1, 0, 0.4, 0)
	text.BackgroundTransparency = 1
	text.Text = "HERE"
	text.TextScaled = true
	text.Font = Enum.Font.GothamBold
	text.TextColor3 = Color3.fromRGB(220, 120, 255)
	text.Parent = bb

	return bb
end

local function criarESP(character)
	if not ESP_ATIVO then return end
	if Players:GetPlayerFromCharacter(character) == LocalPlayer then return end
	if ESPs[character] then return end

	local head = character:FindFirstChild("Head")
	if not head then return end

	local folder = Instance.new("Folder")
	folder.Name = "ESP_FOLDER"
	folder.Parent = character

	local hl = Instance.new("Highlight")
	hl.Adornee = character
	hl.FillTransparency = 1
	hl.OutlineTransparency = 0
	hl.OutlineColor = Color3.fromRGB(180, 0, 255)
	hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	hl.Parent = folder

	local arrow = criarSeta(head)
	arrow.Parent = folder

	ESPs[character] = folder
end

local function aplicarTodos()
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character then
			criarESP(plr.Character)
		end
	end
end

local function removerTodos()
	for char, _ in pairs(ESPs) do
		removerESP(char)
	end
end

-- =========================
-- Eventos
-- =========================
Players.PlayerAdded:Connect(function(plr)
	plr.CharacterAdded:Connect(function(char)
		task.wait(0.3)
		criarESP(char)
	end)
end)

Players.PlayerRemoving:Connect(function(plr)
	if plr.Character then
		removerESP(plr.Character)
	end
end)

-- =========================
-- BOTÃO
-- =========================
toggleBtn.MouseButton1Click:Connect(function()
	ESP_ATIVO = not ESP_ATIVO

	if ESP_ATIVO then
		toggleBtn.Text = "ESP: ON"
		toggleBtn.BackgroundColor3 = Color3.fromRGB(140, 0, 200)
		aplicarTodos()
	else
		toggleBtn.Text = "ESP: OFF"
		toggleBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
		removerTodos()
	end
end)
