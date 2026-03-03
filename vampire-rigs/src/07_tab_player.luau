--==================================================
-- TAB: PLAYERS
--==================================================

local PlayerContent = Instance.new("Frame")
PlayerContent.Name = "PlayerContent"
PlayerContent.Size = UDim2.new(1, 0, 1, 0)
PlayerContent.BackgroundTransparency = 1
PlayerContent.Visible = false
PlayerContent.Parent = TabContent
tabContents["player"] = PlayerContent

createSectionHeader(PlayerContent, "Online Players", 0)

-- Player list scroll
local PlayerScroll = Instance.new("ScrollingFrame")
PlayerScroll.Name = "PlayerScroll"
PlayerScroll.Size = UDim2.new(1, 0, 1, -132)
PlayerScroll.Position = UDim2.new(0, 0, 0, 26)
PlayerScroll.BackgroundColor3 = Colors.content
PlayerScroll.BorderSizePixel = 0
PlayerScroll.ScrollBarThickness = 4
PlayerScroll.ScrollBarImageColor3 = Colors.blood
PlayerScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
PlayerScroll.Parent = PlayerContent
Instance.new("UICorner", PlayerScroll).CornerRadius = UDim.new(0, 6)
local playerStroke = Instance.new("UIStroke", PlayerScroll)
playerStroke.Color = Colors.separator
playerStroke.Thickness = 0.5
playerStroke.Transparency = 0.5

local PlayerLayout = Instance.new("UIListLayout")
PlayerLayout.Padding = UDim.new(0, 4)
PlayerLayout.Parent = PlayerScroll
local playerPad = Instance.new("UIPadding", PlayerScroll)
playerPad.PaddingTop = UDim.new(0, 4)
playerPad.PaddingLeft = UDim.new(0, 4)
playerPad.PaddingRight = UDim.new(0, 4)

-- Unspectate button (hidden by default)
local PlayerUnspectateBtn = Instance.new("TextButton")
PlayerUnspectateBtn.Size = UDim2.new(1, 0, 0, 26)
PlayerUnspectateBtn.Position = UDim2.new(0, 0, 1, -130)
PlayerUnspectateBtn.BackgroundColor3 = Colors.blood
PlayerUnspectateBtn.Text = "🦇 UNSPECTATE"
PlayerUnspectateBtn.TextColor3 = Colors.text
PlayerUnspectateBtn.TextSize = 11
PlayerUnspectateBtn.Font = Enum.Font.GothamBold
PlayerUnspectateBtn.AutoButtonColor = false
PlayerUnspectateBtn.Visible = false
PlayerUnspectateBtn.Parent = PlayerContent
Instance.new("UICorner", PlayerUnspectateBtn).CornerRadius = UDim.new(0, 6)
addBtnGradient(PlayerUnspectateBtn)
makeHoverable(PlayerUnspectateBtn, Colors.blood, Colors.glowRed)

-- Refresh button
local RefreshPlayersBtn = Instance.new("TextButton")
RefreshPlayersBtn.Size = UDim2.new(1, 0, 0, 26)
RefreshPlayersBtn.Position = UDim2.new(0, 0, 1, -100)
RefreshPlayersBtn.BackgroundColor3 = Colors.blood
RefreshPlayersBtn.Text = "🔄 REFRESH PLAYERS"
RefreshPlayersBtn.TextColor3 = Colors.text
RefreshPlayersBtn.TextSize = 11
RefreshPlayersBtn.Font = Enum.Font.GothamBold
RefreshPlayersBtn.AutoButtonColor = false
RefreshPlayersBtn.Parent = PlayerContent
Instance.new("UICorner", RefreshPlayersBtn).CornerRadius = UDim.new(0, 6)
addBtnGradient(RefreshPlayersBtn)
makeHoverable(RefreshPlayersBtn, Colors.blood, Colors.glowRed)

-- Stop Troll button
StopTrollBtn = Instance.new("TextButton")
StopTrollBtn.Size = UDim2.new(0.5, -3, 0, 26)
StopTrollBtn.Position = UDim2.new(0, 0, 1, -70)
StopTrollBtn.BackgroundColor3 = Colors.warning
StopTrollBtn.Text = "⛔ STOP TROLL"
StopTrollBtn.TextColor3 = Colors.bg
StopTrollBtn.TextSize = 10
StopTrollBtn.Font = Enum.Font.GothamBold
StopTrollBtn.AutoButtonColor = false
StopTrollBtn.Parent = PlayerContent
Instance.new("UICorner", StopTrollBtn).CornerRadius = UDim.new(0, 6)
makeHoverable(StopTrollBtn, Colors.warning, Color3.fromRGB(230, 180, 60))

-- Fling All button
FlingAllBtn = Instance.new("TextButton")
FlingAllBtn.Size = UDim2.new(0.5, -3, 0, 26)
FlingAllBtn.Position = UDim2.new(0.5, 3, 1, -70)
FlingAllBtn.BackgroundColor3 = Colors.glowRed
FlingAllBtn.Text = "💥 FLING ALL"
FlingAllBtn.TextColor3 = Colors.text
FlingAllBtn.TextSize = 10
FlingAllBtn.Font = Enum.Font.GothamBold
FlingAllBtn.AutoButtonColor = false
FlingAllBtn.Parent = PlayerContent
Instance.new("UICorner", FlingAllBtn).CornerRadius = UDim.new(0, 6)
addBtnGradient(FlingAllBtn)
makeHoverable(FlingAllBtn, Colors.glowRed, Color3.fromRGB(255, 80, 80))

--==================================================
-- SERVER INFO
--==================================================

createSectionHeader(PlayerContent, "Server Info", -42)
-- Reposition relative to bottom
local ServerInfo = Instance.new("Frame")
ServerInfo.Size = UDim2.new(1, 0, 0, 38)
ServerInfo.Position = UDim2.new(0, 0, 1, -38)
ServerInfo.BackgroundColor3 = Colors.card
ServerInfo.BorderSizePixel = 0
ServerInfo.Parent = PlayerContent
Instance.new("UICorner", ServerInfo).CornerRadius = UDim.new(0, 6)
addGradient(ServerInfo, Colors.surfaceLight, Colors.card, 0)

local ServerInfoLabel = Instance.new("TextLabel")
ServerInfoLabel.Name = "ServerInfoLabel"
ServerInfoLabel.Size = UDim2.new(1, -10, 1, 0)
ServerInfoLabel.Position = UDim2.new(0, 5, 0, 0)
ServerInfoLabel.BackgroundTransparency = 1
ServerInfoLabel.Text = "Loading server info..."
ServerInfoLabel.TextColor3 = Colors.textDim
ServerInfoLabel.TextSize = 9
ServerInfoLabel.Font = Enum.Font.Code
ServerInfoLabel.TextXAlignment = Enum.TextXAlignment.Left
ServerInfoLabel.TextWrapped = true
ServerInfoLabel.Parent = ServerInfo
