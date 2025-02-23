local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = game:GetService("Workspace").CurrentCamera

local screenGui = Instance.new("ScreenGui")
screenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

local function createDraggableButton(name, position, text)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 100, 0, 50)
    button.Position = position
    button.Text = text
    button.Parent = screenGui
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    local dragging
    local dragInput
    local dragStart
    local startPos
    
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = button.Position
        end
    end)
    
    button.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            button.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    button.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    return button
end

local highlightButton = createDraggableButton("HighlightButton", UDim2.new(0.1, 0, 0.1, 0), "ESP")
local noclipButton = createDraggableButton("NoclipButton", UDim2.new(0.1, 0, 0.2, 0), "Noclip")
local aimAssistButton = createDraggableButton("AimAssistButton", UDim2.new(0.1, 0, 0.3, 0), "Toggle Aimbot")

local highlightEnabled = true

local function highlightPlayers()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local highlight = player.Character:FindFirstChild("Highlight")
            if highlightEnabled then
                if not highlight then
                    highlight = Instance.new("Highlight")
                    highlight.Parent = player.Character
                    highlight.FillColor = Color3.fromRGB(255, 255, 0)
                    highlight.OutlineColor = Color3.fromRGB(0, 0, 0)
                end
            else
                if highlight then
                    highlight:Destroy()
                end
            end
        end
    end
end

highlightButton.MouseButton1Click:Connect(function()
    highlightEnabled = not highlightEnabled
    highlightPlayers()
end)

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        if highlightEnabled then
            wait(1) -- Wait for character to load
            highlightPlayers()
        end
    end)
end)

local noclipEnabled = false
noclipButton.MouseButton1Click:Connect(function()
    noclipEnabled = not noclipEnabled
    if noclipEnabled then
        RunService.Stepped:Connect(function()
            if noclipEnabled and LocalPlayer.Character then
                for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    end
end)

local aimAssistEnabled = false
local lockedTarget = nil

local function getNearestTarget()
    if lockedTarget and lockedTarget.Parent and lockedTarget.Parent:FindFirstChild("Humanoid") and lockedTarget.Parent.Humanoid.Health > 0 then
        return lockedTarget
    end
    
    local nearestTarget = nil
    local shortestDistance = math.huge
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local head = player.Character.Head
            local screenPosition, onScreen = Camera:WorldToViewportPoint(head.Position)
            if onScreen then
                local distance = (Vector2.new(screenPosition.X, screenPosition.Y) - UserInputService:GetMouseLocation()).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    nearestTarget = head
                end
            end
        end
    end
    lockedTarget = nearestTarget
    return nearestTarget
end

RunService.RenderStepped:Connect(function()
    if aimAssistEnabled then
        local target = getNearestTarget()
        if target then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
        end
    end
end)

aimAssistButton.MouseButton1Click:Connect(function()
    aimAssistEnabled = not aimAssistEnabled
    if aimAssistEnabled then
        lockedTarget = nil  -- Reset target when toggling aim assist
        print("Aim Assist Enabled")
    else
        print("Aim Assist Disabled")
    end
end)
