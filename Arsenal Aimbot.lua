local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local _G = _G
_G.aim = false -- Flag to track whether the aimbot is active
local aimingConnection -- Store the connection to RenderStepped

-- Function to get the closest enemy player
function getClosest()
    local closestDistance = math.huge  -- Start with a very large number
    local closestPlayer = nil

    -- Loop through all players in the game
    for _, player in pairs(game.Players:GetChildren()) do
        if player ~= game.Players.LocalPlayer and player.Team ~= game.Players.LocalPlayer.Team then
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                -- Calculate the distance between the local player and the other player's HumanoidRootPart
                local distance = (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - character.HumanoidRootPart.Position).Magnitude
                -- If the distance is smaller than the previous closest, update the closest player
                if distance < closestDistance then
                    closestDistance = distance
                    closestPlayer = player
                end
            end
        end
    end

    return closestPlayer
end

-- MouseButton2 pressed
UIS.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        _G.aim = true  -- Set aiming to true when the right mouse button is pressed

        -- Only create a new connection if it's not already running
        if not aimingConnection then
            aimingConnection = RunService.RenderStepped:Connect(function()
                if _G.aim then
                    local closestPlayer = getClosest()
                    if closestPlayer and closestPlayer.Character and closestPlayer.Character:FindFirstChild("Head") then
                        local camera = game.Workspace.CurrentCamera
                        -- Smoothly aim at the closest player's head
                        local targetPosition = closestPlayer.Character.Head.Position
                        local cameraPosition = camera.CFrame.Position
                        local newCFrame = CFrame.new(cameraPosition, targetPosition)
                        camera.CFrame = CFrame.new(cameraPosition, targetPosition)
                    end
                end
            end)
        end
    end
end)

-- MouseButton2 released
UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        _G.aim = false  -- Set aiming to false when the right mouse button is released

        -- Disconnect the aiming connection when the button is released
        if aimingConnection then
            aimingConnection:Disconnect()
            aimingConnection = nil
        end
    end
end)
