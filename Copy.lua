local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local baseplatesFolder = workspace:WaitForChild("Baseplates")

local screenGui = Instance.new("ScreenGui", playerGui)
screenGui.Name = "CopyBuildGUI"

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 250, 0, 160)
frame.Position = UDim2.new(0, 20, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.BorderSizePixel = 0

local textBox = Instance.new("TextBox", frame)
textBox.PlaceholderText = "Enter username"
textBox.Size = UDim2.new(1, -20, 0, 40)
textBox.Position = UDim2.new(0, 10, 0, 10)
textBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
textBox.TextColor3 = Color3.new(0, 0, 0)

local copyButton = Instance.new("TextButton", frame)
copyButton.Text = "Copy Build"
copyButton.Size = UDim2.new(1, -20, 0, 40)
copyButton.Position = UDim2.new(0, 10, 0, 60)
copyButton.BackgroundColor3 = Color3.fromRGB(100, 200, 100)

local deleteButton = Instance.new("TextButton", frame)
deleteButton.Text = "Delete All"
deleteButton.Size = UDim2.new(1, -20, 0, 40)
deleteButton.Position = UDim2.new(0, 10, 0, 110)
deleteButton.BackgroundColor3 = Color3.fromRGB(200, 100, 100)

textBox:GetPropertyChangedSignal("Text"):Connect(function()
	local text = textBox.Text:lower()
	if text == "" then return end
	local matches = {}
	for _, baseplate in ipairs(baseplatesFolder:GetChildren()) do
		local nameLower = baseplate.Name:lower()
		if nameLower:sub(1, #text) == text then
			table.insert(matches, baseplate.Name)
		end
	end
	if #matches == 1 then
		textBox.Text = matches[1]
		textBox.CursorPosition = #matches[1] + 1
	end
end)

copyButton.MouseButton1Click:Connect(function()
	local targetName = textBox.Text
	if targetName == "" then return end
	local myBase = baseplatesFolder:FindFirstChild(player.Name)
	local theirBase = baseplatesFolder:FindFirstChild(targetName)
	if not myBase or not theirBase then return end
	local offset = myBase.Position - theirBase.Position
	local blocks = theirBase:FindFirstChild("Blocks")
	if not blocks then return end
	local remote = game.ReplicatedStorage:FindFirstChild("CreatePart")
	if not remote then return end
	local tool = player.Character and player.Character:FindFirstChild("StamperTool")
	if not tool then return end
	for _, item in ipairs(blocks:GetChildren()) do
		if item:IsA("BasePart") then
			coroutine.wrap(function()
				remote:FireServer(item.Name, item.CFrame + offset, tool)
			end)()
		elseif item:IsA("Model") then
			coroutine.wrap(function()
				local primaryPart = item.PrimaryPart
				local cframe = primaryPart and (primaryPart.CFrame + offset) or (item:GetModelCFrame() + offset)
				remote:FireServer(item.Name, cframe, tool)
			end)()
		end
	end
end)

deleteButton.MouseButton1Click:Connect(function()
	local myBase = baseplatesFolder:FindFirstChild(player.Name)
	if not myBase then return end
	local blocks = myBase:FindFirstChild("Blocks")
	if not blocks then return end
	local deleteRemote = player.Character and player.Character:FindFirstChild("Delete") and player.Character.Delete:FindFirstChild("Delete")
	if not deleteRemote then return end
	for _, item in ipairs(blocks:GetChildren()) do
		coroutine.wrap(function()
			deleteRemote:FireServer(item)
		end)()
	end
end)
