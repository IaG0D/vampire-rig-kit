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
PlayerScroll.Size = UDim2.new(1, 0, 1, -100)
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

-- Refresh button
local RefreshPlayersBtn = Instance.new("TextButton")
RefreshPlayersBtn.Size = UDim2.new(1, 0, 0, 26)
RefreshPlayersBtn.Position = UDim2.new(0, 0, 1, -70)
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
