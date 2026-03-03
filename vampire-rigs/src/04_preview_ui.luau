--==================================================
-- PREVIEW WINDOW
--==================================================

local PreviewFrame = Instance.new("Frame")
PreviewFrame.Name = "Preview"
PreviewFrame.Size = UDim2.new(0, 320, 0, 550)
PreviewFrame.Position = UDim2.new(0.3, 330, 0.5, -275)
PreviewFrame.BackgroundColor3 = Colors.bg
PreviewFrame.BorderSizePixel = 0
PreviewFrame.Visible = false
PreviewFrame.Parent = ScreenGui

local previewStroke = Instance.new("UIStroke", PreviewFrame)
previewStroke.Color = Colors.blood
previewStroke.Thickness = 1.2
Instance.new("UICorner", PreviewFrame).CornerRadius = UDim.new(0, 10)
addGradient(PreviewFrame, Colors.surfaceLight, Color3.fromRGB(8, 8, 10), 90)

local PreviewTopBar = Instance.new("Frame")
PreviewTopBar.Size = UDim2.new(1, 0, 0, 40)
PreviewTopBar.BackgroundColor3 = Colors.topbar
PreviewTopBar.BorderSizePixel = 0
PreviewTopBar.Parent = PreviewFrame
Instance.new("UICorner", PreviewTopBar).CornerRadius = UDim.new(0, 10)
addGradient(PreviewTopBar, Color3.fromRGB(40, 8, 8), Colors.topbar, 0)
addAccentLine(PreviewTopBar, UDim2.new(0, 0, 1, -1), Colors.blood)

local PreviewTitle = Instance.new("TextLabel")
PreviewTitle.Size = UDim2.new(1, -80, 1, 0)
PreviewTitle.Position = UDim2.new(0, 10, 0, 0)
PreviewTitle.BackgroundTransparency = 1
PreviewTitle.Text = "Preview"
PreviewTitle.TextColor3 = Colors.bloodLight
PreviewTitle.TextSize = 14
PreviewTitle.Font = Enum.Font.GothamBold
PreviewTitle.TextXAlignment = Enum.TextXAlignment.Left
PreviewTitle.Parent = PreviewTopBar

local PreviewClose = Instance.new("TextButton")
PreviewClose.Size = UDim2.new(0, 25, 0, 25)
PreviewClose.Position = UDim2.new(1, -32, 0, 7)
PreviewClose.BackgroundColor3 = Colors.blood
PreviewClose.Text = "X"
PreviewClose.TextColor3 = Colors.text
PreviewClose.TextSize = 14
PreviewClose.Font = Enum.Font.GothamBold
PreviewClose.AutoButtonColor = false
PreviewClose.Parent = PreviewTopBar
Instance.new("UICorner", PreviewClose).CornerRadius = UDim.new(0, 6)
makeHoverable(PreviewClose, Colors.blood, Colors.glowRed)

local Viewport = Instance.new("ViewportFrame")
Viewport.Size = UDim2.new(1, -20, 0, 200)
Viewport.Position = UDim2.new(0, 10, 0, 50)
Viewport.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
Viewport.BorderSizePixel = 0
Viewport.Ambient = Color3.fromRGB(200, 200, 200)
Viewport.LightColor = Color3.fromRGB(255, 255, 255)
Viewport.LightDirection = Vector3.new(-1, -1, -1)
Viewport.Parent = PreviewFrame
Instance.new("UICorner", Viewport).CornerRadius = UDim.new(0, 8)
local vpStroke = Instance.new("UIStroke", Viewport)
vpStroke.Color = Colors.glowRed
vpStroke.Thickness = 1.5
vpStroke.Transparency = 0.3

local ViewportStatus = Instance.new("TextLabel")
ViewportStatus.Size = UDim2.new(1, 0, 1, 0)
ViewportStatus.BackgroundTransparency = 1
ViewportStatus.Text = ""
ViewportStatus.TextColor3 = Colors.textLoading
ViewportStatus.TextSize = 12
ViewportStatus.Font = Enum.Font.GothamBold
ViewportStatus.TextWrapped = true
ViewportStatus.Parent = Viewport

local InfoScroll = Instance.new("ScrollingFrame")
InfoScroll.Size = UDim2.new(1, -20, 0, 200)
InfoScroll.Position = UDim2.new(0, 10, 0, 260)
InfoScroll.BackgroundColor3 = Colors.content
InfoScroll.BorderSizePixel = 0
InfoScroll.ScrollBarThickness = 3
InfoScroll.ScrollBarImageColor3 = Colors.blood
InfoScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
InfoScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
InfoScroll.Parent = PreviewFrame
Instance.new("UICorner", InfoScroll).CornerRadius = UDim.new(0, 6)

local InfoLabel = Instance.new("TextLabel")
InfoLabel.Size = UDim2.new(1, -16, 0, 0)
InfoLabel.Position = UDim2.new(0, 8, 0, 8)
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

local CopyBtn = Instance.new("TextButton")
CopyBtn.Size = UDim2.new(1, -20, 0, 35)
CopyBtn.Position = UDim2.new(0, 10, 1, -80)
CopyBtn.BackgroundColor3 = Colors.blood
CopyBtn.Text = "🩸 COPY JSON"
CopyBtn.TextColor3 = Colors.text
CopyBtn.TextSize = 14
CopyBtn.Font = Enum.Font.GothamBold
CopyBtn.AutoButtonColor = false
CopyBtn.Parent = PreviewFrame
Instance.new("UICorner", CopyBtn).CornerRadius = UDim.new(0, 6)
addBtnGradient(CopyBtn)
makeHoverable(CopyBtn, Colors.blood, Colors.glowRed)

local PreviewFooter = Instance.new("Frame")
PreviewFooter.Size = UDim2.new(1, 0, 0, 25)
PreviewFooter.Position = UDim2.new(0, 0, 1, -25)
PreviewFooter.BackgroundColor3 = Colors.topbar
PreviewFooter.BorderSizePixel = 0
PreviewFooter.Parent = PreviewFrame
Instance.new("UICorner", PreviewFooter).CornerRadius = UDim.new(0, 10)
addAccentLine(PreviewFooter, UDim2.new(0, 0, 0, 0), Colors.blood)

local PreviewCredits = Instance.new("TextLabel")
PreviewCredits.Size = UDim2.new(1, 0, 1, 0)
PreviewCredits.BackgroundTransparency = 1
PreviewCredits.Text = "🦇 Create By VampireSonata 🦇"
PreviewCredits.TextColor3 = Colors.textBlood
PreviewCredits.TextSize = 11
PreviewCredits.Font = Enum.Font.GothamBold
PreviewCredits.Parent = PreviewFooter
