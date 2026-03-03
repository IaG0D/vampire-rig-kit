--==================================================
-- MINI BAR (widget no canto)
--==================================================

local MiniBar = Instance.new("TextButton")
MiniBar.Name = "MiniBar"
MiniBar.Size = UDim2.new(0, 210, 0, 56)
MiniBar.Position = UDim2.new(1, 0, 1, -70) -- comeca fora da tela (direita)
MiniBar.BackgroundColor3 = Colors.bg
MiniBar.BorderSizePixel = 0
MiniBar.AutoButtonColor = false
MiniBar.Text = ""
MiniBar.Parent = ScreenGui
Instance.new("UICorner", MiniBar).CornerRadius = UDim.new(0, 12)
local miniStroke = Instance.new("UIStroke", MiniBar)
miniStroke.Color = Colors.blood
miniStroke.Thickness = 1.5
addGradient(MiniBar, Colors.surfaceLight, Colors.bg, 45)

-- Avatar thumbnail
local AvatarFrame = Instance.new("Frame")
AvatarFrame.Size = UDim2.new(0, 40, 0, 40)
AvatarFrame.Position = UDim2.new(0, 8, 0, 8)
AvatarFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
AvatarFrame.Parent = MiniBar
Instance.new("UICorner", AvatarFrame).CornerRadius = UDim.new(1, 0)
local avatarStroke = Instance.new("UIStroke", AvatarFrame)
avatarStroke.Color = Colors.blood
avatarStroke.Thickness = 1.5

local AvatarImg = Instance.new("ImageLabel")
AvatarImg.Size = UDim2.new(1, 0, 1, 0)
AvatarImg.BackgroundTransparency = 1
AvatarImg.Image = ""
AvatarImg.Parent = AvatarFrame
Instance.new("UICorner", AvatarImg).CornerRadius = UDim.new(1, 0)

-- Carrega avatar do LocalPlayer
task.spawn(function()
    local ok, thumb = pcall(function()
        return Players:GetUserThumbnailAsync(LP.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
    end)
    if ok and thumb then
        AvatarImg.Image = thumb
    end
end)

-- Separador vertical
local miniSep = Instance.new("Frame")
miniSep.Size = UDim2.new(0, 1, 0, 36)
miniSep.Position = UDim2.new(0, 52, 0, 10)
miniSep.BackgroundColor3 = Colors.blood
miniSep.BackgroundTransparency = 0.5
miniSep.BorderSizePixel = 0
miniSep.Parent = MiniBar

-- Nome do usuario
local MiniName = Instance.new("TextLabel")
MiniName.Size = UDim2.new(0, 140, 0, 16)
MiniName.Position = UDim2.new(0, 55, 0, 6)
MiniName.BackgroundTransparency = 1
MiniName.Text = LP.DisplayName
MiniName.TextColor3 = Colors.bloodLight
MiniName.TextSize = 12
MiniName.Font = Enum.Font.GothamBold
MiniName.TextXAlignment = Enum.TextXAlignment.Left
MiniName.TextTruncate = Enum.TextTruncate.AtEnd
MiniName.Parent = MiniBar

-- Titulo
local MiniTitle = Instance.new("TextLabel")
MiniTitle.Size = UDim2.new(0, 140, 0, 14)
MiniTitle.Position = UDim2.new(0, 55, 0, 22)
MiniTitle.BackgroundTransparency = 1
MiniTitle.Text = "🦇 Vampire Rigs v13"
MiniTitle.TextColor3 = Colors.textDim
MiniTitle.TextSize = 10
MiniTitle.Font = Enum.Font.GothamBold
MiniTitle.TextXAlignment = Enum.TextXAlignment.Left
MiniTitle.Parent = MiniBar

-- Hint
local MiniHint = Instance.new("TextLabel")
MiniHint.Size = UDim2.new(0, 140, 0, 12)
MiniHint.Position = UDim2.new(0, 55, 0, 38)
MiniHint.BackgroundTransparency = 1
MiniHint.Text = "Ctrl+G to open"
MiniHint.TextColor3 = Color3.fromRGB(80, 80, 80)
MiniHint.TextSize = 9
MiniHint.Font = Enum.Font.Gotham
MiniHint.TextXAlignment = Enum.TextXAlignment.Left
MiniHint.Parent = MiniBar

-- Icone morcego pulsante
local MiniBat = Instance.new("TextLabel")
MiniBat.Size = UDim2.new(0, 20, 0, 20)
MiniBat.Position = UDim2.new(1, -26, 0, 18)
MiniBat.BackgroundTransparency = 1
MiniBat.Text = "🦇"
MiniBat.TextSize = 16
MiniBat.Parent = MiniBar
