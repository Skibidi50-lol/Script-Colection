local Players = game:GetService("Players")

local function applyHighlight(player)
local function onCharacterAdded(character)
-- Create a new Highlight instance and set properties
local highlight = Instance.new("Highlight", character)

highlight.Archivable = true
highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop -- Ensures highlight is always visible
highlight.Enabled = true
highlight.FillColor = Color3.fromRGB(255, 0, 4) -- Set fill color to bright red
highlight.OutlineColor = Color3.fromRGB(255, 255, 255) -- Set outline color to white
highlight.FillTransparency = 0.5 -- Set fill transparency
highlight.OutlineTransparency = 0 -- No transparency on the outline
end

-- If the player's character already exists, apply the highlight
if player.Character then
onCharacterAdded(player.Character)
end

-- Connect to CharacterAdded to ensure highlight is added when character respawns
player.CharacterAdded:Connect(onCharacterAdded)
end

-- Apply the highlight to all current players
for _, player in pairs(Players:GetPlayers()) do
applyHighlight(player)
end

-- Listen for new players joining
Players.PlayerAdded:Connect(applyHighlight)
