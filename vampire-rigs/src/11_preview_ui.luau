--==================================================
-- PREVIEW WINDOW — BOLA DE CRISTAL
--==================================================

local PreviewFrame = Instance.new("Frame")
PreviewFrame.Name = "Preview"
PreviewFrame.Size = UDim2.new(0, 320, 0, 500)
PreviewFrame.Position = UDim2.new(0.3, 430, 0.5, -250)
PreviewFrame.BackgroundColor3 = Colors.bg
PreviewFrame.BorderSizePixel = 0
PreviewFrame.Visible = false
PreviewFrame.Parent = ScreenGui

local previewStroke = Instance.new("UIStroke", PreviewFrame)
previewStroke.Color = Colors.glowPurple
previewStroke.Thickness = 1.5
Instance.new("UICorner", PreviewFrame).CornerRadius = UDim.new(0, 10)
addGradient(PreviewFrame, Colors.surfaceLight, Color3.fromRGB(8, 8, 10), 90)

-- Top bar
local PreviewTopBar = Instance.new("Frame")
PreviewTopBar.Size = UDim2.new(1, 0, 0, 35)
PreviewTopBar.BackgroundColor3 = Colors.topbar
PreviewTopBar.BorderSizePixel = 0
PreviewTopBar.Parent = PreviewFrame
Instance.new("UICorner", PreviewTopBar).CornerRadius = UDim.new(0, 10)
addGradient(PreviewTopBar, Color3.fromRGB(30, 10, 40), Colors.topbar, 0)

local topBarFix = Instance.new("Frame")
topBarFix.Size = UDim2.new(1, 0, 0, 10)
topBarFix.Position = UDim2.new(0, 0, 1, -10)
topBarFix.BackgroundColor3 = Colors.topbar
topBarFix.BorderSizePixel = 0
topBarFix.Parent = PreviewTopBar

addAccentLine(PreviewTopBar, UDim2.new(0, 0, 1, -1), Colors.glowPurple)

local PreviewTitle = Instance.new("TextLabel")
PreviewTitle.Size = UDim2.new(1, -50, 1, 0)
PreviewTitle.Position = UDim2.new(0, 10, 0, 0)
PreviewTitle.BackgroundTransparency = 1
PreviewTitle.Text = "🔮 Crystal Ball"
PreviewTitle.TextColor3 = Colors.purpleLight
PreviewTitle.TextSize = 13
PreviewTitle.Font = Enum.Font.GothamBold
PreviewTitle.TextXAlignment = Enum.TextXAlignment.Left
PreviewTitle.Parent = PreviewTopBar

local PreviewClose = Instance.new("TextButton")
PreviewClose.Size = UDim2.new(0, 22, 0, 22)
PreviewClose.Position = UDim2.new(1, -28, 0, 6)
PreviewClose.BackgroundColor3 = Colors.blood
PreviewClose.Text = "X"
PreviewClose.TextColor3 = Colors.text
PreviewClose.TextSize = 12
PreviewClose.Font = Enum.Font.GothamBold
PreviewClose.AutoButtonColor = false
PreviewClose.Parent = PreviewTopBar
Instance.new("UICorner", PreviewClose).CornerRadius = UDim.new(0, 6)
makeHoverable(PreviewClose, Colors.blood, Colors.glowRed)

--==================================================
-- VIEWPORT (Crystal Ball)
--==================================================

local Viewport = Instance.new("ViewportFrame")
Viewport.Size = UDim2.new(1, -20, 0, 220)
Viewport.Position = UDim2.new(0, 10, 0, 42)
Viewport.BackgroundColor3 = Color3.fromRGB(5, 3, 8)
Viewport.BorderSizePixel = 0
Viewport.Ambient = Color3.fromRGB(180, 160, 200)
Viewport.LightColor = Color3.fromRGB(255, 240, 255)
Viewport.LightDirection = Vector3.new(-1, -1, -1)
Viewport.Parent = PreviewFrame
Instance.new("UICorner", Viewport).CornerRadius = UDim.new(0, 12)
local vpStroke = Instance.new("UIStroke", Viewport)
vpStroke.Color = Colors.glowPurple
vpStroke.Thickness = 2
vpStroke.Transparency = 0.2

-- "LIVE" badge overlay
local LiveBadge = Instance.new("TextLabel")
LiveBadge.Size = UDim2.new(0, 48, 0, 16)
LiveBadge.Position = UDim2.new(0, 6, 0, 6)
LiveBadge.BackgroundColor3 = Color3.fromRGB(180, 15, 15)
LiveBadge.Text = "● LIVE"
LiveBadge.TextColor3 = Colors.text
LiveBadge.TextSize = 9
LiveBadge.Font = Enum.Font.GothamBold
LiveBadge.Visible = false
LiveBadge.ZIndex = 10
LiveBadge.Parent = Viewport
Instance.new("UICorner", LiveBadge).CornerRadius = UDim.new(0, 4)

-- Distance overlay (top-right)
local DistLabel = Instance.new("TextLabel")
DistLabel.Size = UDim2.new(0, 60, 0, 16)
DistLabel.Position = UDim2.new(1, -66, 0, 6)
DistLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
DistLabel.BackgroundTransparency = 0.3
DistLabel.Text = ""
DistLabel.TextColor3 = Colors.textDim
DistLabel.TextSize = 9
DistLabel.Font = Enum.Font.Code
DistLabel.Visible = false
DistLabel.ZIndex = 10
DistLabel.Parent = Viewport
Instance.new("UICorner", DistLabel).CornerRadius = UDim.new(0, 4)

-- Status text (center, for loading/errors)
local ViewportStatus = Instance.new("TextLabel")
ViewportStatus.Size = UDim2.new(1, 0, 1, 0)
ViewportStatus.BackgroundTransparency = 1
ViewportStatus.Text = ""
ViewportStatus.TextColor3 = Colors.textLoading
ViewportStatus.TextSize = 12
ViewportStatus.Font = Enum.Font.GothamBold
ViewportStatus.TextWrapped = true
ViewportStatus.ZIndex = 5
ViewportStatus.Parent = Viewport

--==================================================
-- INFO BAR (name, type, HP)
--==================================================

local InfoBar = Instance.new("Frame")
InfoBar.Size = UDim2.new(1, -20, 0, 42)
InfoBar.Position = UDim2.new(0, 10, 0, 268)
InfoBar.BackgroundColor3 = Colors.card
InfoBar.BorderSizePixel = 0
InfoBar.Parent = PreviewFrame
Instance.new("UICorner", InfoBar).CornerRadius = UDim.new(0, 6)
addGradient(InfoBar, Colors.surfaceLight, Colors.card, 0)

local PreviewNameLabel = Instance.new("TextLabel")
PreviewNameLabel.Size = UDim2.new(1, -60, 0, 18)
PreviewNameLabel.Position = UDim2.new(0, 8, 0, 3)
PreviewNameLabel.BackgroundTransparency = 1
PreviewNameLabel.Text = ""
PreviewNameLabel.TextColor3 = Colors.purpleLight
PreviewNameLabel.TextSize = 12
PreviewNameLabel.Font = Enum.Font.GothamBold
PreviewNameLabel.TextXAlignment = Enum.TextXAlignment.Left
PreviewNameLabel.TextTruncate = Enum.TextTruncate.AtEnd
PreviewNameLabel.Parent = InfoBar

local PreviewTypeBadge = Instance.new("Frame")
PreviewTypeBadge.Size = UDim2.new(0, 50, 0, 14)
PreviewTypeBadge.Position = UDim2.new(1, -56, 0, 5)
PreviewTypeBadge.BackgroundColor3 = Colors.blood
PreviewTypeBadge.Parent = InfoBar
Instance.new("UICorner", PreviewTypeBadge).CornerRadius = UDim.new(0, 4)

local PreviewTypeLabel = Instance.new("TextLabel")
PreviewTypeLabel.Size = UDim2.new(1, 0, 1, 0)
PreviewTypeLabel.BackgroundTransparency = 1
PreviewTypeLabel.Text = "PLAYER"
PreviewTypeLabel.TextColor3 = Colors.text
PreviewTypeLabel.TextSize = 8
PreviewTypeLabel.Font = Enum.Font.GothamBold
PreviewTypeLabel.Parent = PreviewTypeBadge

-- HP bar
local PreviewHPBg = Instance.new("Frame")
PreviewHPBg.Size = UDim2.new(1, -16, 0, 6)
PreviewHPBg.Position = UDim2.new(0, 8, 0, 26)
PreviewHPBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
PreviewHPBg.BorderSizePixel = 0
PreviewHPBg.Parent = InfoBar
Instance.new("UICorner", PreviewHPBg).CornerRadius = UDim.new(0, 3)

local PreviewHPFill = Instance.new("Frame")
PreviewHPFill.Size = UDim2.new(1, 0, 1, 0)
PreviewHPFill.BackgroundColor3 = Colors.green
PreviewHPFill.BorderSizePixel = 0
PreviewHPFill.Parent = PreviewHPBg
Instance.new("UICorner", PreviewHPFill).CornerRadius = UDim.new(0, 3)

local PreviewHPLabel = Instance.new("TextLabel")
PreviewHPLabel.Size = UDim2.new(1, 0, 0, 8)
PreviewHPLabel.Position = UDim2.new(0, 0, 0, 34)
PreviewHPLabel.BackgroundTransparency = 1
PreviewHPLabel.Text = ""
PreviewHPLabel.TextColor3 = Colors.textDim
PreviewHPLabel.TextSize = 8
PreviewHPLabel.Font = Enum.Font.Code
PreviewHPLabel.Parent = InfoBar

--==================================================
-- INFO SCROLL (accessories, scales, etc)
--==================================================

local InfoScroll = Instance.new("ScrollingFrame")
InfoScroll.Size = UDim2.new(1, -20, 0, 115)
InfoScroll.Position = UDim2.new(0, 10, 0, 316)
InfoScroll.BackgroundColor3 = Colors.content
InfoScroll.BorderSizePixel = 0
InfoScroll.ScrollBarThickness = 3
InfoScroll.ScrollBarImageColor3 = Colors.glowPurple
InfoScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
InfoScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
InfoScroll.Parent = PreviewFrame
Instance.new("UICorner", InfoScroll).CornerRadius = UDim.new(0, 6)
local infoScrollStroke = Instance.new("UIStroke", InfoScroll)
infoScrollStroke.Color = Colors.separator
infoScrollStroke.Thickness = 0.5
infoScrollStroke.Transparency = 0.5

local InfoLabel = Instance.new("TextLabel")
InfoLabel.Size = UDim2.new(1, -16, 0, 0)
InfoLabel.Position = UDim2.new(0, 8, 0, 4)
InfoLabel.BackgroundTransparency = 1
InfoLabel.TextColor3 = Colors.textDim
InfoLabel.TextSize = 9
InfoLabel.Font = Enum.Font.Code
InfoLabel.TextXAlignment = Enum.TextXAlignment.Left
InfoLabel.TextYAlignment = Enum.TextYAlignment.Top
InfoLabel.TextWrapped = true
InfoLabel.AutomaticSize = Enum.AutomaticSize.Y
InfoLabel.Text = ""
InfoLabel.Parent = InfoScroll

--==================================================
-- COPY JSON BUTTON
--==================================================

local CopyBtn = Instance.new("TextButton")
CopyBtn.Size = UDim2.new(1, -20, 0, 30)
CopyBtn.Position = UDim2.new(0, 10, 1, -60)
CopyBtn.BackgroundColor3 = Colors.purple
CopyBtn.Text = "🩸 COPY JSON"
CopyBtn.TextColor3 = Colors.text
CopyBtn.TextSize = 12
CopyBtn.Font = Enum.Font.GothamBold
CopyBtn.AutoButtonColor = false
CopyBtn.Parent = PreviewFrame
Instance.new("UICorner", CopyBtn).CornerRadius = UDim.new(0, 6)
addBtnGradient(CopyBtn)
makeHoverable(CopyBtn, Colors.purple, Colors.purpleLight)

--==================================================
-- FOOTER
--==================================================

local PreviewFooter = Instance.new("Frame")
PreviewFooter.Size = UDim2.new(1, 0, 0, 25)
PreviewFooter.Position = UDim2.new(0, 0, 1, -25)
PreviewFooter.BackgroundColor3 = Colors.topbar
PreviewFooter.BorderSizePixel = 0
PreviewFooter.Parent = PreviewFrame
Instance.new("UICorner", PreviewFooter).CornerRadius = UDim.new(0, 10)
addAccentLine(PreviewFooter, UDim2.new(0, 0, 0, 0), Colors.glowPurple)

local PreviewCredits = Instance.new("TextLabel")
PreviewCredits.Size = UDim2.new(1, 0, 1, 0)
PreviewCredits.BackgroundTransparency = 1
PreviewCredits.Text = "🔮 Crystal Ball — VampireSonata"
PreviewCredits.TextColor3 = Colors.textBlood
PreviewCredits.TextSize = 10
PreviewCredits.Font = Enum.Font.GothamBold
PreviewCredits.Parent = PreviewFooter
