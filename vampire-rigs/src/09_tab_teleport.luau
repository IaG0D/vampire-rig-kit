--==================================================
-- TAB: TELEPORT
--==================================================

local TeleportContent = Instance.new("Frame")
TeleportContent.Name = "TeleportContent"
TeleportContent.Size = UDim2.new(1, 0, 1, 0)
TeleportContent.BackgroundTransparency = 1
TeleportContent.Visible = false
TeleportContent.Parent = TabContent
tabContents["teleport"] = TeleportContent

-- Scroll container
local TPScroll = Instance.new("ScrollingFrame")
TPScroll.Size = UDim2.new(1, 0, 1, 0)
TPScroll.BackgroundTransparency = 1
TPScroll.ScrollBarThickness = 3
TPScroll.ScrollBarImageColor3 = Colors.blood
TPScroll.CanvasSize = UDim2.new(0, 0, 0, 600)
TPScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
TPScroll.BorderSizePixel = 0
TPScroll.Parent = TeleportContent

createSectionHeader(TPScroll, "TP to Part / Model", 0)

local TPInput = Instance.new("TextBox")
TPInput.Size = UDim2.new(1, -80, 0, 28)
TPInput.Position = UDim2.new(0, 0, 0, 26)
TPInput.BackgroundColor3 = Colors.inputBg
TPInput.Text = ""
TPInput.PlaceholderText = "Part name..."
TPInput.TextColor3 = Colors.text
TPInput.PlaceholderColor3 = Colors.textDim
TPInput.TextSize = 11
TPInput.Font = Enum.Font.Code
TPInput.ClearTextOnFocus = false
TPInput.Parent = TPScroll
Instance.new("UICorner", TPInput).CornerRadius = UDim.new(0, 6)
local tpInputStroke = Instance.new("UIStroke", TPInput)
tpInputStroke.Color = Colors.inputBorder
tpInputStroke.Thickness = 1

TPInput.Focused:Connect(function()
    TweenService:Create(tpInputStroke, TweenInfo.new(0.2), { Color = Colors.bloodLight, Thickness = 1.5 }):Play()
end)
TPInput.FocusLost:Connect(function()
    TweenService:Create(tpInputStroke, TweenInfo.new(0.3), { Color = Colors.inputBorder, Thickness = 1 }):Play()
end)

local TPSearchBtn = Instance.new("TextButton")
TPSearchBtn.Size = UDim2.new(0, 72, 0, 28)
TPSearchBtn.Position = UDim2.new(1, -72, 0, 26)
TPSearchBtn.BackgroundColor3 = Colors.blood
TPSearchBtn.Text = "📍 GO"
TPSearchBtn.TextColor3 = Colors.text
TPSearchBtn.TextSize = 11
TPSearchBtn.Font = Enum.Font.GothamBold
TPSearchBtn.AutoButtonColor = false
TPSearchBtn.Parent = TPScroll
Instance.new("UICorner", TPSearchBtn).CornerRadius = UDim.new(0, 6)
addBtnGradient(TPSearchBtn)
makeHoverable(TPSearchBtn, Colors.blood, Colors.glowRed)

--==================================================
-- WAYPOINTS
--==================================================

createSectionHeader(TPScroll, "Waypoints", 62)

local WPNameInput = Instance.new("TextBox")
WPNameInput.Size = UDim2.new(1, -80, 0, 28)
WPNameInput.Position = UDim2.new(0, 0, 0, 88)
WPNameInput.BackgroundColor3 = Colors.inputBg
WPNameInput.Text = ""
WPNameInput.PlaceholderText = "Waypoint name..."
WPNameInput.TextColor3 = Colors.text
WPNameInput.PlaceholderColor3 = Colors.textDim
WPNameInput.TextSize = 11
WPNameInput.Font = Enum.Font.Code
WPNameInput.ClearTextOnFocus = false
WPNameInput.Parent = TPScroll
Instance.new("UICorner", WPNameInput).CornerRadius = UDim.new(0, 6)
local wpStroke = Instance.new("UIStroke", WPNameInput)
wpStroke.Color = Colors.inputBorder
wpStroke.Thickness = 1

WPNameInput.Focused:Connect(function()
    TweenService:Create(wpStroke, TweenInfo.new(0.2), { Color = Colors.green, Thickness = 1.5 }):Play()
end)
WPNameInput.FocusLost:Connect(function()
    TweenService:Create(wpStroke, TweenInfo.new(0.3), { Color = Colors.inputBorder, Thickness = 1 }):Play()
end)

local SaveWPBtn = Instance.new("TextButton")
SaveWPBtn.Size = UDim2.new(0, 72, 0, 28)
SaveWPBtn.Position = UDim2.new(1, -72, 0, 88)
SaveWPBtn.BackgroundColor3 = Colors.green
SaveWPBtn.Text = "💾 SAVE"
SaveWPBtn.TextColor3 = Colors.text
SaveWPBtn.TextSize = 11
SaveWPBtn.Font = Enum.Font.GothamBold
SaveWPBtn.AutoButtonColor = false
SaveWPBtn.Parent = TPScroll
Instance.new("UICorner", SaveWPBtn).CornerRadius = UDim.new(0, 6)
addBtnGradient(SaveWPBtn)
makeHoverable(SaveWPBtn, Colors.green, Colors.greenLight)

-- Waypoint list frame
local WaypointList = Instance.new("Frame")
WaypointList.Name = "WaypointList"
WaypointList.Size = UDim2.new(1, 0, 0, 10)
WaypointList.Position = UDim2.new(0, 0, 0, 122)
WaypointList.BackgroundTransparency = 1
WaypointList.AutomaticSize = Enum.AutomaticSize.Y
WaypointList.Parent = TPScroll

local wpLayout = Instance.new("UIListLayout", WaypointList)
wpLayout.Padding = UDim.new(0, 4)

-- Quick TP to Players header (will be positioned dynamically after waypoints)
local QuickTPHeader = Instance.new("Frame")
QuickTPHeader.Name = "QuickTPHeader"
QuickTPHeader.Size = UDim2.new(1, 0, 0, 22)
QuickTPHeader.BackgroundTransparency = 1
QuickTPHeader.Parent = TPScroll

local quickTPLabel = Instance.new("TextLabel")
quickTPLabel.Size = UDim2.new(1, 0, 1, 0)
quickTPLabel.BackgroundTransparency = 1
quickTPLabel.Text = "Quick TP to Players"
quickTPLabel.TextColor3 = Colors.bloodLight
quickTPLabel.TextSize = 11
quickTPLabel.Font = Enum.Font.GothamBold
quickTPLabel.TextXAlignment = Enum.TextXAlignment.Left
quickTPLabel.Parent = QuickTPHeader
addAccentLine(QuickTPHeader, UDim2.new(0, 0, 1, -1), Colors.blood, UDim2.new(1, 0, 0, 1))

-- Player TP list
local PlayerTPList = Instance.new("Frame")
PlayerTPList.Name = "PlayerTPList"
PlayerTPList.Size = UDim2.new(1, 0, 0, 10)
PlayerTPList.BackgroundTransparency = 1
PlayerTPList.AutomaticSize = Enum.AutomaticSize.Y
PlayerTPList.Parent = TPScroll

local ptpLayout = Instance.new("UIListLayout", PlayerTPList)
ptpLayout.Padding = UDim.new(0, 3)
