--==================================================
-- TAB: GAMES
--==================================================

GamesContent = Instance.new("Frame")
GamesContent.Name = "GamesContent"
GamesContent.Size = UDim2.new(1, 0, 1, 0)
GamesContent.BackgroundTransparency = 1
GamesContent.Visible = false
GamesContent.Parent = TabContent
tabContents["games"] = GamesContent

-- Scroll container
GamesScroll = Instance.new("ScrollingFrame")
GamesScroll.Size = UDim2.new(1, 0, 1, 0)
GamesScroll.BackgroundTransparency = 1
GamesScroll.ScrollBarThickness = 3
GamesScroll.ScrollBarImageColor3 = Colors.blood
GamesScroll.CanvasSize = UDim2.new(0, 0, 0, 300)
GamesScroll.BorderSizePixel = 0
GamesScroll.Parent = GamesContent

GamesScrollLayout = Instance.new("UIListLayout", GamesScroll)
GamesScrollLayout.Padding = UDim.new(0, 6)

GamesScrollPad = Instance.new("UIPadding", GamesScroll)
GamesScrollPad.PaddingTop = UDim.new(0, 8)
GamesScrollPad.PaddingLeft = UDim.new(0, 8)
GamesScrollPad.PaddingRight = UDim.new(0, 8)

-- Header
GamesHeaderLabel = Instance.new("TextLabel")
GamesHeaderLabel.Size = UDim2.new(1, 0, 0, 18)
GamesHeaderLabel.BackgroundTransparency = 1
GamesHeaderLabel.Text = "🎮 Game-Specific Exploits"
GamesHeaderLabel.TextColor3 = Colors.text
GamesHeaderLabel.TextSize = 13
GamesHeaderLabel.Font = Enum.Font.GothamBold
GamesHeaderLabel.TextXAlignment = Enum.TextXAlignment.Left
GamesHeaderLabel.Parent = GamesScroll

GamesDescLabel = Instance.new("TextLabel")
GamesDescLabel.Size = UDim2.new(1, 0, 0, 12)
GamesDescLabel.BackgroundTransparency = 1
GamesDescLabel.Text = "Select a game to open its exploit panel"
GamesDescLabel.TextColor3 = Colors.textDim
GamesDescLabel.TextSize = 9
GamesDescLabel.Font = Enum.Font.Gotham
GamesDescLabel.TextXAlignment = Enum.TextXAlignment.Left
GamesDescLabel.Parent = GamesScroll

-- ═══ GAME CARD: DEATH BALL ═══
DeathBallCard = Instance.new("TextButton")
DeathBallCard.Size = UDim2.new(1, 0, 0, 54)
DeathBallCard.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
DeathBallCard.Text = ""
DeathBallCard.AutoButtonColor = false
DeathBallCard.Parent = GamesScroll
Instance.new("UICorner", DeathBallCard).CornerRadius = UDim.new(0, 8)
addBtnGradient(DeathBallCard)

DeathBallCardStroke = Instance.new("UIStroke", DeathBallCard)
DeathBallCardStroke.Color = Color3.fromRGB(200, 60, 60)
DeathBallCardStroke.Thickness = 1

DeathBallCardIcon = Instance.new("TextLabel")
DeathBallCardIcon.Size = UDim2.new(0, 40, 0, 40)
DeathBallCardIcon.Position = UDim2.new(0, 8, 0, 7)
DeathBallCardIcon.BackgroundTransparency = 1
DeathBallCardIcon.Text = "⚽"
DeathBallCardIcon.TextSize = 24
DeathBallCardIcon.Parent = DeathBallCard

DeathBallCardTitle = Instance.new("TextLabel")
DeathBallCardTitle.Size = UDim2.new(1, -60, 0, 18)
DeathBallCardTitle.Position = UDim2.new(0, 52, 0, 6)
DeathBallCardTitle.BackgroundTransparency = 1
DeathBallCardTitle.Text = "Death Ball"
DeathBallCardTitle.TextColor3 = Color3.fromRGB(255, 80, 80)
DeathBallCardTitle.TextSize = 13
DeathBallCardTitle.Font = Enum.Font.GothamBold
DeathBallCardTitle.TextXAlignment = Enum.TextXAlignment.Left
DeathBallCardTitle.Parent = DeathBallCard

DeathBallCardDesc = Instance.new("TextLabel")
DeathBallCardDesc.Size = UDim2.new(1, -60, 0, 12)
DeathBallCardDesc.Position = UDim2.new(0, 52, 0, 26)
DeathBallCardDesc.BackgroundTransparency = 1
DeathBallCardDesc.Text = "Auto-Rebater • ESP • Dodge • Prediction • Kill Feed"
DeathBallCardDesc.TextColor3 = Colors.textDim
DeathBallCardDesc.TextSize = 9
DeathBallCardDesc.Font = Enum.Font.Gotham
DeathBallCardDesc.TextXAlignment = Enum.TextXAlignment.Left
DeathBallCardDesc.Parent = DeathBallCard

DeathBallCardArrow = Instance.new("TextLabel")
DeathBallCardArrow.Size = UDim2.new(0, 20, 1, 0)
DeathBallCardArrow.Position = UDim2.new(1, -24, 0, 0)
DeathBallCardArrow.BackgroundTransparency = 1
DeathBallCardArrow.Text = "▸"
DeathBallCardArrow.TextColor3 = Color3.fromRGB(200, 60, 60)
DeathBallCardArrow.TextSize = 16
DeathBallCardArrow.Font = Enum.Font.GothamBold
DeathBallCardArrow.Parent = DeathBallCard

makeHoverable(DeathBallCard, Color3.fromRGB(20, 20, 30), Color3.fromRGB(35, 20, 25))

--==================================================
-- DEATH BALL PANEL — FLOATING (v2 FULL FEATURES)
--==================================================

DeathBallPanel = Instance.new("Frame")
DeathBallPanel.Name = "DeathBallPanel"
DeathBallPanel.Size = UDim2.new(0, 280, 0, 870)
DeathBallPanel.Position = UDim2.new(0.5, -140, 0.5, -420)
DeathBallPanel.BackgroundColor3 = Color3.fromRGB(14, 10, 14)
DeathBallPanel.BorderSizePixel = 0
DeathBallPanel.Visible = false
DeathBallPanel.Parent = ScreenGui
Instance.new("UICorner", DeathBallPanel).CornerRadius = UDim.new(0, 10)

DeathBallPanelStroke = Instance.new("UIStroke", DeathBallPanel)
DeathBallPanelStroke.Color = Color3.fromRGB(200, 60, 60)
DeathBallPanelStroke.Thickness = 1.5
addGradient(DeathBallPanel, Color3.fromRGB(18, 10, 14), Color3.fromRGB(8, 6, 10), 90)

-- Top Bar
DeathBallTopBar = Instance.new("Frame")
DeathBallTopBar.Size = UDim2.new(1, 0, 0, 32)
DeathBallTopBar.BackgroundColor3 = Color3.fromRGB(30, 12, 18)
DeathBallTopBar.BorderSizePixel = 0
DeathBallTopBar.Parent = DeathBallPanel
Instance.new("UICorner", DeathBallTopBar).CornerRadius = UDim.new(0, 10)
addGradient(DeathBallTopBar, Color3.fromRGB(35, 12, 18), Color3.fromRGB(20, 8, 12), 0)

DeathBallTopBarFix = Instance.new("Frame")
DeathBallTopBarFix.Size = UDim2.new(1, 0, 0, 10)
DeathBallTopBarFix.Position = UDim2.new(0, 0, 1, -10)
DeathBallTopBarFix.BackgroundColor3 = Color3.fromRGB(30, 12, 18)
DeathBallTopBarFix.BorderSizePixel = 0
DeathBallTopBarFix.Parent = DeathBallTopBar

addAccentLine(DeathBallTopBar, UDim2.new(0, 0, 1, -1), Color3.fromRGB(200, 60, 60))

DeathBallTitleLabel = Instance.new("TextLabel")
DeathBallTitleLabel.Size = UDim2.new(1, -40, 1, 0)
DeathBallTitleLabel.Position = UDim2.new(0, 10, 0, 0)
DeathBallTitleLabel.BackgroundTransparency = 1
DeathBallTitleLabel.Text = "⚽ Death Ball v3 AUTO"
DeathBallTitleLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
DeathBallTitleLabel.TextSize = 12
DeathBallTitleLabel.Font = Enum.Font.GothamBold
DeathBallTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
DeathBallTitleLabel.Parent = DeathBallTopBar

DeathBallCloseBtn = Instance.new("TextButton")
DeathBallCloseBtn.Size = UDim2.new(0, 20, 0, 20)
DeathBallCloseBtn.Position = UDim2.new(1, -26, 0, 6)
DeathBallCloseBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
DeathBallCloseBtn.Text = "X"
DeathBallCloseBtn.TextColor3 = Colors.text
DeathBallCloseBtn.TextSize = 11
DeathBallCloseBtn.Font = Enum.Font.GothamBold
DeathBallCloseBtn.AutoButtonColor = false
DeathBallCloseBtn.Parent = DeathBallTopBar
Instance.new("UICorner", DeathBallCloseBtn).CornerRadius = UDim.new(0, 6)
makeHoverable(DeathBallCloseBtn, Color3.fromRGB(200, 60, 60), Color3.fromRGB(240, 80, 80))

-- ═══ AUTO-PLAY TOGGLE (botão principal) ═══
DeathBallAutoBtn = Instance.new("TextButton")
DeathBallAutoBtn.Size = UDim2.new(1, -20, 0, 38)
DeathBallAutoBtn.Position = UDim2.new(0, 10, 0, 40)
DeathBallAutoBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
DeathBallAutoBtn.Text = "⚡ AUTO-PLAY: OFF"
DeathBallAutoBtn.TextColor3 = Colors.text
DeathBallAutoBtn.TextSize = 13
DeathBallAutoBtn.Font = Enum.Font.GothamBold
DeathBallAutoBtn.AutoButtonColor = false
DeathBallAutoBtn.Parent = DeathBallPanel
Instance.new("UICorner", DeathBallAutoBtn).CornerRadius = UDim.new(0, 8)
addBtnGradient(DeathBallAutoBtn)
makeHoverable(DeathBallAutoBtn, Color3.fromRGB(40, 20, 20), Color3.fromRGB(60, 30, 30))

-- ═══ ROW 1: AUTO-DETECT + ESP ═══
DeathBallAutoDetectBtn = Instance.new("TextButton")
DeathBallAutoDetectBtn.Size = UDim2.new(0.48, -5, 0, 26)
DeathBallAutoDetectBtn.Position = UDim2.new(0, 10, 0, 84)
DeathBallAutoDetectBtn.BackgroundColor3 = Color3.fromRGB(40, 140, 60)
DeathBallAutoDetectBtn.Text = "AUTO-DETECT: ON"
DeathBallAutoDetectBtn.TextColor3 = Colors.text
DeathBallAutoDetectBtn.TextSize = 9
DeathBallAutoDetectBtn.Font = Enum.Font.GothamBold
DeathBallAutoDetectBtn.AutoButtonColor = false
DeathBallAutoDetectBtn.Parent = DeathBallPanel
Instance.new("UICorner", DeathBallAutoDetectBtn).CornerRadius = UDim.new(0, 6)
addBtnGradient(DeathBallAutoDetectBtn)
makeHoverable(DeathBallAutoDetectBtn, Color3.fromRGB(40, 140, 60), Color3.fromRGB(60, 180, 80))

DeathBallEspBtn = Instance.new("TextButton")
DeathBallEspBtn.Size = UDim2.new(0.48, -5, 0, 26)
DeathBallEspBtn.Position = UDim2.new(0.52, 0, 0, 84)
DeathBallEspBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
DeathBallEspBtn.Text = "ESP: OFF"
DeathBallEspBtn.TextColor3 = Colors.text
DeathBallEspBtn.TextSize = 9
DeathBallEspBtn.Font = Enum.Font.GothamBold
DeathBallEspBtn.AutoButtonColor = false
DeathBallEspBtn.Parent = DeathBallPanel
Instance.new("UICorner", DeathBallEspBtn).CornerRadius = UDim.new(0, 6)
addBtnGradient(DeathBallEspBtn)
makeHoverable(DeathBallEspBtn, Color3.fromRGB(30, 30, 50), Color3.fromRGB(50, 50, 80))

-- ═══ ROW 2: DODGE + DEBUG ═══
DeathBallDodgeBtn = Instance.new("TextButton")
DeathBallDodgeBtn.Size = UDim2.new(0.48, -5, 0, 26)
DeathBallDodgeBtn.Position = UDim2.new(0, 10, 0, 114)
DeathBallDodgeBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
DeathBallDodgeBtn.Text = "DODGE: OFF"
DeathBallDodgeBtn.TextColor3 = Colors.text
DeathBallDodgeBtn.TextSize = 9
DeathBallDodgeBtn.Font = Enum.Font.GothamBold
DeathBallDodgeBtn.AutoButtonColor = false
DeathBallDodgeBtn.Parent = DeathBallPanel
Instance.new("UICorner", DeathBallDodgeBtn).CornerRadius = UDim.new(0, 6)
addBtnGradient(DeathBallDodgeBtn)
makeHoverable(DeathBallDodgeBtn, Color3.fromRGB(30, 30, 50), Color3.fromRGB(50, 50, 80))

DeathBallDebugBtn = Instance.new("TextButton")
DeathBallDebugBtn.Size = UDim2.new(0.48, -5, 0, 26)
DeathBallDebugBtn.Position = UDim2.new(0.52, 0, 0, 114)
DeathBallDebugBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
DeathBallDebugBtn.Text = "DEBUG: OFF"
DeathBallDebugBtn.TextColor3 = Colors.text
DeathBallDebugBtn.TextSize = 9
DeathBallDebugBtn.Font = Enum.Font.GothamBold
DeathBallDebugBtn.AutoButtonColor = false
DeathBallDebugBtn.Parent = DeathBallPanel
Instance.new("UICorner", DeathBallDebugBtn).CornerRadius = UDim.new(0, 6)
addBtnGradient(DeathBallDebugBtn)
makeHoverable(DeathBallDebugBtn, Color3.fromRGB(30, 30, 50), Color3.fromRGB(50, 50, 80))

-- ═══ SETTINGS ROW 1: RANGE + COOLDOWN ═══
DeathBallRangeLabel = Instance.new("TextLabel")
DeathBallRangeLabel.Size = UDim2.new(0, 50, 0, 20)
DeathBallRangeLabel.Position = UDim2.new(0, 10, 0, 148)
DeathBallRangeLabel.BackgroundTransparency = 1
DeathBallRangeLabel.Text = "Range:"
DeathBallRangeLabel.TextColor3 = Colors.textDim
DeathBallRangeLabel.TextSize = 9
DeathBallRangeLabel.Font = Enum.Font.GothamBold
DeathBallRangeLabel.TextXAlignment = Enum.TextXAlignment.Left
DeathBallRangeLabel.Parent = DeathBallPanel

DeathBallRangeBox = Instance.new("TextBox")
DeathBallRangeBox.Size = UDim2.new(0, 40, 0, 20)
DeathBallRangeBox.Position = UDim2.new(0, 58, 0, 148)
DeathBallRangeBox.BackgroundColor3 = Colors.inputBg
DeathBallRangeBox.Text = "15"
DeathBallRangeBox.PlaceholderText = "studs"
DeathBallRangeBox.PlaceholderColor3 = Colors.textDim
DeathBallRangeBox.TextColor3 = Colors.text
DeathBallRangeBox.TextSize = 10
DeathBallRangeBox.Font = Enum.Font.Code
DeathBallRangeBox.ClearTextOnFocus = false
DeathBallRangeBox.Parent = DeathBallPanel
Instance.new("UICorner", DeathBallRangeBox).CornerRadius = UDim.new(0, 4)

DeathBallCooldownLabel = Instance.new("TextLabel")
DeathBallCooldownLabel.Size = UDim2.new(0, 60, 0, 20)
DeathBallCooldownLabel.Position = UDim2.new(0.5, -20, 0, 148)
DeathBallCooldownLabel.BackgroundTransparency = 1
DeathBallCooldownLabel.Text = "Cooldown:"
DeathBallCooldownLabel.TextColor3 = Colors.textDim
DeathBallCooldownLabel.TextSize = 9
DeathBallCooldownLabel.Font = Enum.Font.GothamBold
DeathBallCooldownLabel.TextXAlignment = Enum.TextXAlignment.Left
DeathBallCooldownLabel.Parent = DeathBallPanel

DeathBallCooldownBox = Instance.new("TextBox")
DeathBallCooldownBox.Size = UDim2.new(0, 40, 0, 20)
DeathBallCooldownBox.Position = UDim2.new(0.5, 42, 0, 148)
DeathBallCooldownBox.BackgroundColor3 = Colors.inputBg
DeathBallCooldownBox.Text = "0.2"
DeathBallCooldownBox.PlaceholderText = "sec"
DeathBallCooldownBox.PlaceholderColor3 = Colors.textDim
DeathBallCooldownBox.TextColor3 = Colors.text
DeathBallCooldownBox.TextSize = 10
DeathBallCooldownBox.Font = Enum.Font.Code
DeathBallCooldownBox.ClearTextOnFocus = false
DeathBallCooldownBox.Parent = DeathBallPanel
Instance.new("UICorner", DeathBallCooldownBox).CornerRadius = UDim.new(0, 4)

-- ═══ SETTINGS ROW 2: BALL NAME (usado quando auto-detect OFF) ═══
DeathBallNameLabel = Instance.new("TextLabel")
DeathBallNameLabel.Size = UDim2.new(0, 80, 0, 20)
DeathBallNameLabel.Position = UDim2.new(0, 10, 0, 174)
DeathBallNameLabel.BackgroundTransparency = 1
DeathBallNameLabel.Text = "Ball Name:"
DeathBallNameLabel.TextColor3 = Colors.textDim
DeathBallNameLabel.TextSize = 9
DeathBallNameLabel.Font = Enum.Font.GothamBold
DeathBallNameLabel.TextXAlignment = Enum.TextXAlignment.Left
DeathBallNameLabel.Parent = DeathBallPanel

DeathBallNameBox = Instance.new("TextBox")
DeathBallNameBox.Size = UDim2.new(1, -100, 0, 20)
DeathBallNameBox.Position = UDim2.new(0, 90, 0, 174)
DeathBallNameBox.BackgroundColor3 = Colors.inputBg
DeathBallNameBox.Text = "Ball"
DeathBallNameBox.PlaceholderText = "only if auto-detect OFF"
DeathBallNameBox.PlaceholderColor3 = Colors.textDim
DeathBallNameBox.TextColor3 = Colors.text
DeathBallNameBox.TextSize = 10
DeathBallNameBox.Font = Enum.Font.Code
DeathBallNameBox.ClearTextOnFocus = false
DeathBallNameBox.Parent = DeathBallPanel
Instance.new("UICorner", DeathBallNameBox).CornerRadius = UDim.new(0, 4)

-- ═══ SEPARATOR 1 ═══
addAccentLine(DeathBallPanel, UDim2.new(0, 10, 0, 200), Color3.fromRGB(200, 60, 60), UDim2.new(1, -20, 0, 1))

-- ═══ STATUS & INFO ═══
DeathBallStatusLabel = Instance.new("TextLabel")
DeathBallStatusLabel.Size = UDim2.new(1, -20, 0, 14)
DeathBallStatusLabel.Position = UDim2.new(0, 10, 0, 208)
DeathBallStatusLabel.BackgroundTransparency = 1
DeathBallStatusLabel.Text = "Status: Idle — press AUTO-PLAY to start"
DeathBallStatusLabel.TextColor3 = Colors.textDim
DeathBallStatusLabel.TextSize = 9
DeathBallStatusLabel.Font = Enum.Font.Code
DeathBallStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
DeathBallStatusLabel.Parent = DeathBallPanel

DeathBallBallInfo = Instance.new("TextLabel")
DeathBallBallInfo.Size = UDim2.new(1, -20, 0, 14)
DeathBallBallInfo.Position = UDim2.new(0, 10, 0, 224)
DeathBallBallInfo.BackgroundTransparency = 1
DeathBallBallInfo.Text = "Balls: --"
DeathBallBallInfo.TextColor3 = Colors.textDim
DeathBallBallInfo.TextSize = 9
DeathBallBallInfo.Font = Enum.Font.Code
DeathBallBallInfo.TextXAlignment = Enum.TextXAlignment.Left
DeathBallBallInfo.Parent = DeathBallPanel

DeathBallDistInfo = Instance.new("TextLabel")
DeathBallDistInfo.Size = UDim2.new(1, -20, 0, 14)
DeathBallDistInfo.Position = UDim2.new(0, 10, 0, 240)
DeathBallDistInfo.BackgroundTransparency = 1
DeathBallDistInfo.Text = "Distance: --"
DeathBallDistInfo.TextColor3 = Colors.textDim
DeathBallDistInfo.TextSize = 9
DeathBallDistInfo.Font = Enum.Font.Code
DeathBallDistInfo.TextXAlignment = Enum.TextXAlignment.Left
DeathBallDistInfo.Parent = DeathBallPanel

DeathBallColorInfo = Instance.new("TextLabel")
DeathBallColorInfo.Size = UDim2.new(1, -20, 0, 14)
DeathBallColorInfo.Position = UDim2.new(0, 10, 0, 256)
DeathBallColorInfo.BackgroundTransparency = 1
DeathBallColorInfo.Text = "Method: none"
DeathBallColorInfo.TextColor3 = Colors.textDim
DeathBallColorInfo.TextSize = 9
DeathBallColorInfo.Font = Enum.Font.Code
DeathBallColorInfo.TextXAlignment = Enum.TextXAlignment.Left
DeathBallColorInfo.Parent = DeathBallPanel

DeathBallVelInfo = Instance.new("TextLabel")
DeathBallVelInfo.Size = UDim2.new(1, -20, 0, 14)
DeathBallVelInfo.Position = UDim2.new(0, 10, 0, 272)
DeathBallVelInfo.BackgroundTransparency = 1
DeathBallVelInfo.Text = "Velocity: --"
DeathBallVelInfo.TextColor3 = Colors.textDim
DeathBallVelInfo.TextSize = 9
DeathBallVelInfo.Font = Enum.Font.Code
DeathBallVelInfo.TextXAlignment = Enum.TextXAlignment.Left
DeathBallVelInfo.Parent = DeathBallPanel

-- ═══ SEPARATOR 2 ═══
addAccentLine(DeathBallPanel, UDim2.new(0, 10, 0, 292), Color3.fromRGB(200, 60, 60), UDim2.new(1, -20, 0, 1))

-- ═══ STATS ═══
DeathBallStatsLabel = Instance.new("TextLabel")
DeathBallStatsLabel.Size = UDim2.new(1, -20, 0, 14)
DeathBallStatsLabel.Position = UDim2.new(0, 10, 0, 298)
DeathBallStatsLabel.BackgroundTransparency = 1
DeathBallStatsLabel.Text = "Rebated: 0 | Missed: 0"
DeathBallStatsLabel.TextColor3 = Color3.fromRGB(200, 200, 100)
DeathBallStatsLabel.TextSize = 10
DeathBallStatsLabel.Font = Enum.Font.GothamBold
DeathBallStatsLabel.TextXAlignment = Enum.TextXAlignment.Left
DeathBallStatsLabel.Parent = DeathBallPanel

-- ═══ SCAN BALL BUTTON ═══
DeathBallScanBtn = Instance.new("TextButton")
DeathBallScanBtn.Size = UDim2.new(1, -20, 0, 26)
DeathBallScanBtn.Position = UDim2.new(0, 10, 0, 318)
DeathBallScanBtn.BackgroundColor3 = Color3.fromRGB(40, 80, 120)
DeathBallScanBtn.Text = "SCAN FOR BALLS (manual)"
DeathBallScanBtn.TextColor3 = Colors.text
DeathBallScanBtn.TextSize = 10
DeathBallScanBtn.Font = Enum.Font.GothamBold
DeathBallScanBtn.AutoButtonColor = false
DeathBallScanBtn.Parent = DeathBallPanel
Instance.new("UICorner", DeathBallScanBtn).CornerRadius = UDim.new(0, 6)
addBtnGradient(DeathBallScanBtn)
makeHoverable(DeathBallScanBtn, Color3.fromRGB(40, 80, 120), Color3.fromRGB(60, 110, 160))

-- ═══ SEPARATOR 3: OBJECT SCANNER ═══
addAccentLine(DeathBallPanel, UDim2.new(0, 10, 0, 352), Color3.fromRGB(0, 200, 160), UDim2.new(1, -20, 0, 1))

DeathBallScanObjHeader = Instance.new("TextLabel")
DeathBallScanObjHeader.Size = UDim2.new(1, -20, 0, 14)
DeathBallScanObjHeader.Position = UDim2.new(0, 10, 0, 358)
DeathBallScanObjHeader.BackgroundTransparency = 1
DeathBallScanObjHeader.Text = "Object Scanner — find part names"
DeathBallScanObjHeader.TextColor3 = Color3.fromRGB(0, 220, 180)
DeathBallScanObjHeader.TextSize = 9
DeathBallScanObjHeader.Font = Enum.Font.GothamBold
DeathBallScanObjHeader.TextXAlignment = Enum.TextXAlignment.Left
DeathBallScanObjHeader.Parent = DeathBallPanel

-- Scan range + button row
DeathBallScanRangeLabel = Instance.new("TextLabel")
DeathBallScanRangeLabel.Size = UDim2.new(0, 46, 0, 22)
DeathBallScanRangeLabel.Position = UDim2.new(0, 10, 0, 376)
DeathBallScanRangeLabel.BackgroundTransparency = 1
DeathBallScanRangeLabel.Text = "Range:"
DeathBallScanRangeLabel.TextColor3 = Colors.textDim
DeathBallScanRangeLabel.TextSize = 9
DeathBallScanRangeLabel.Font = Enum.Font.GothamBold
DeathBallScanRangeLabel.TextXAlignment = Enum.TextXAlignment.Left
DeathBallScanRangeLabel.Parent = DeathBallPanel

DeathBallScanRangeBox = Instance.new("TextBox")
DeathBallScanRangeBox.Size = UDim2.new(0, 36, 0, 22)
DeathBallScanRangeBox.Position = UDim2.new(0, 54, 0, 376)
DeathBallScanRangeBox.BackgroundColor3 = Colors.inputBg
DeathBallScanRangeBox.Text = "50"
DeathBallScanRangeBox.PlaceholderText = "studs"
DeathBallScanRangeBox.PlaceholderColor3 = Colors.textDim
DeathBallScanRangeBox.TextColor3 = Colors.text
DeathBallScanRangeBox.TextSize = 10
DeathBallScanRangeBox.Font = Enum.Font.Code
DeathBallScanRangeBox.ClearTextOnFocus = false
DeathBallScanRangeBox.Parent = DeathBallPanel
Instance.new("UICorner", DeathBallScanRangeBox).CornerRadius = UDim.new(0, 4)

DeathBallScanObjBtn = Instance.new("TextButton")
DeathBallScanObjBtn.Size = UDim2.new(1, -110, 0, 22)
DeathBallScanObjBtn.Position = UDim2.new(0, 100, 0, 376)
DeathBallScanObjBtn.BackgroundColor3 = Color3.fromRGB(40, 80, 120)
DeathBallScanObjBtn.Text = "SCAN OBJECTS"
DeathBallScanObjBtn.TextColor3 = Colors.text
DeathBallScanObjBtn.TextSize = 9
DeathBallScanObjBtn.Font = Enum.Font.GothamBold
DeathBallScanObjBtn.AutoButtonColor = false
DeathBallScanObjBtn.Parent = DeathBallPanel
Instance.new("UICorner", DeathBallScanObjBtn).CornerRadius = UDim.new(0, 4)
addBtnGradient(DeathBallScanObjBtn)
makeHoverable(DeathBallScanObjBtn, Color3.fromRGB(40, 80, 120), Color3.fromRGB(60, 110, 160))

-- Results scroll
DeathBallScanResultLabel = Instance.new("TextLabel")
DeathBallScanResultLabel.Size = UDim2.new(1, -20, 0, 90)
DeathBallScanResultLabel.Position = UDim2.new(0, 10, 0, 404)
DeathBallScanResultLabel.BackgroundColor3 = Color3.fromRGB(8, 6, 10)
DeathBallScanResultLabel.BackgroundTransparency = 0.3
DeathBallScanResultLabel.Text = "Click SCAN OBJECTS to see nearby parts\nBillboards show name, class, dist, vel & color"
DeathBallScanResultLabel.TextColor3 = Colors.textDim
DeathBallScanResultLabel.TextSize = 8
DeathBallScanResultLabel.Font = Enum.Font.Code
DeathBallScanResultLabel.TextXAlignment = Enum.TextXAlignment.Left
DeathBallScanResultLabel.TextYAlignment = Enum.TextYAlignment.Top
DeathBallScanResultLabel.TextWrapped = true
DeathBallScanResultLabel.Parent = DeathBallPanel
Instance.new("UICorner", DeathBallScanResultLabel).CornerRadius = UDim.new(0, 4)

DeathBallScanResultPad = Instance.new("UIPadding", DeathBallScanResultLabel)
DeathBallScanResultPad.PaddingTop = UDim.new(0, 4)
DeathBallScanResultPad.PaddingLeft = UDim.new(0, 4)

-- ═══ SEPARATOR 4: KILL FEED ═══
addAccentLine(DeathBallPanel, UDim2.new(0, 10, 0, 502), Color3.fromRGB(200, 60, 60), UDim2.new(1, -20, 0, 1))

DeathBallKillHeader = Instance.new("TextLabel")
DeathBallKillHeader.Size = UDim2.new(1, -20, 0, 16)
DeathBallKillHeader.Position = UDim2.new(0, 10, 0, 508)
DeathBallKillHeader.BackgroundTransparency = 1
DeathBallKillHeader.Text = "Kill Feed"
DeathBallKillHeader.TextColor3 = Color3.fromRGB(255, 120, 120)
DeathBallKillHeader.TextSize = 10
DeathBallKillHeader.Font = Enum.Font.GothamBold
DeathBallKillHeader.TextXAlignment = Enum.TextXAlignment.Left
DeathBallKillHeader.Parent = DeathBallPanel

DeathBallKillScroll = Instance.new("ScrollingFrame")
DeathBallKillScroll.Size = UDim2.new(1, -20, 0, 70)
DeathBallKillScroll.Position = UDim2.new(0, 10, 0, 526)
DeathBallKillScroll.BackgroundColor3 = Color3.fromRGB(8, 6, 10)
DeathBallKillScroll.BackgroundTransparency = 0.3
DeathBallKillScroll.ScrollBarThickness = 3
DeathBallKillScroll.ScrollBarImageColor3 = Color3.fromRGB(200, 60, 60)
DeathBallKillScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
DeathBallKillScroll.BorderSizePixel = 0
DeathBallKillScroll.Parent = DeathBallPanel
Instance.new("UICorner", DeathBallKillScroll).CornerRadius = UDim.new(0, 4)

DeathBallKillScrollLayout = Instance.new("UIListLayout", DeathBallKillScroll)
DeathBallKillScrollLayout.Padding = UDim.new(0, 2)

DeathBallKillScrollPad = Instance.new("UIPadding", DeathBallKillScroll)
DeathBallKillScrollPad.PaddingTop = UDim.new(0, 4)
DeathBallKillScrollPad.PaddingLeft = UDim.new(0, 4)

DeathBallKillEmpty = Instance.new("TextLabel")
DeathBallKillEmpty.Size = UDim2.new(1, 0, 0, 14)
DeathBallKillEmpty.BackgroundTransparency = 1
DeathBallKillEmpty.Text = "No kills yet..."
DeathBallKillEmpty.TextColor3 = Colors.textDim
DeathBallKillEmpty.TextSize = 9
DeathBallKillEmpty.Font = Enum.Font.Code
DeathBallKillEmpty.TextXAlignment = Enum.TextXAlignment.Left
DeathBallKillEmpty.Parent = DeathBallKillScroll

-- ═══ SEPARATOR 5: AFK BOT SECTION ═══
addAccentLine(DeathBallPanel, UDim2.new(0, 10, 0, 604), Color3.fromRGB(60, 200, 100), UDim2.new(1, -20, 0, 2))

DeathBallBotHeader = Instance.new("TextLabel")
DeathBallBotHeader.Size = UDim2.new(1, -20, 0, 16)
DeathBallBotHeader.Position = UDim2.new(0, 10, 0, 612)
DeathBallBotHeader.BackgroundTransparency = 1
DeathBallBotHeader.Text = "AFK Bot Mode"
DeathBallBotHeader.TextColor3 = Color3.fromRGB(100, 255, 150)
DeathBallBotHeader.TextSize = 11
DeathBallBotHeader.Font = Enum.Font.GothamBold
DeathBallBotHeader.TextXAlignment = Enum.TextXAlignment.Left
DeathBallBotHeader.Parent = DeathBallPanel

-- AFK Bot toggle
DeathBallBotBtn = Instance.new("TextButton")
DeathBallBotBtn.Size = UDim2.new(1, -20, 0, 30)
DeathBallBotBtn.Position = UDim2.new(0, 10, 0, 632)
DeathBallBotBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
DeathBallBotBtn.Text = "AFK BOT: OFF"
DeathBallBotBtn.TextColor3 = Colors.text
DeathBallBotBtn.TextSize = 11
DeathBallBotBtn.Font = Enum.Font.GothamBold
DeathBallBotBtn.AutoButtonColor = false
DeathBallBotBtn.Parent = DeathBallPanel
Instance.new("UICorner", DeathBallBotBtn).CornerRadius = UDim.new(0, 6)
addBtnGradient(DeathBallBotBtn)
makeHoverable(DeathBallBotBtn, Color3.fromRGB(30, 30, 50), Color3.fromRGB(40, 80, 50))

-- Set Queue Position button
DeathBallSetQueueBtn = Instance.new("TextButton")
DeathBallSetQueueBtn.Size = UDim2.new(1, -20, 0, 24)
DeathBallSetQueueBtn.Position = UDim2.new(0, 10, 0, 668)
DeathBallSetQueueBtn.BackgroundColor3 = Color3.fromRGB(40, 80, 120)
DeathBallSetQueueBtn.Text = "SET QUEUE POSITION"
DeathBallSetQueueBtn.TextColor3 = Colors.text
DeathBallSetQueueBtn.TextSize = 9
DeathBallSetQueueBtn.Font = Enum.Font.GothamBold
DeathBallSetQueueBtn.AutoButtonColor = false
DeathBallSetQueueBtn.Parent = DeathBallPanel
Instance.new("UICorner", DeathBallSetQueueBtn).CornerRadius = UDim.new(0, 6)
addBtnGradient(DeathBallSetQueueBtn)
makeHoverable(DeathBallSetQueueBtn, Color3.fromRGB(40, 80, 120), Color3.fromRGB(60, 110, 160))

-- Queue position label
DeathBallQueuePosLabel = Instance.new("TextLabel")
DeathBallQueuePosLabel.Size = UDim2.new(1, -20, 0, 14)
DeathBallQueuePosLabel.Position = UDim2.new(0, 10, 0, 696)
DeathBallQueuePosLabel.BackgroundTransparency = 1
DeathBallQueuePosLabel.Text = "Queue: not set"
DeathBallQueuePosLabel.TextColor3 = Color3.fromRGB(200, 100, 60)
DeathBallQueuePosLabel.TextSize = 9
DeathBallQueuePosLabel.Font = Enum.Font.Code
DeathBallQueuePosLabel.TextXAlignment = Enum.TextXAlignment.Left
DeathBallQueuePosLabel.Parent = DeathBallPanel

-- Miss chance setting
DeathBallMissLabel = Instance.new("TextLabel")
DeathBallMissLabel.Size = UDim2.new(0, 80, 0, 18)
DeathBallMissLabel.Position = UDim2.new(0, 10, 0, 714)
DeathBallMissLabel.BackgroundTransparency = 1
DeathBallMissLabel.Text = "Miss chance:"
DeathBallMissLabel.TextColor3 = Colors.textDim
DeathBallMissLabel.TextSize = 9
DeathBallMissLabel.Font = Enum.Font.GothamBold
DeathBallMissLabel.TextXAlignment = Enum.TextXAlignment.Left
DeathBallMissLabel.Parent = DeathBallPanel

DeathBallMissBox = Instance.new("TextBox")
DeathBallMissBox.Size = UDim2.new(0, 40, 0, 18)
DeathBallMissBox.Position = UDim2.new(0, 90, 0, 714)
DeathBallMissBox.BackgroundColor3 = Colors.inputBg
DeathBallMissBox.Text = "12"
DeathBallMissBox.PlaceholderText = "%"
DeathBallMissBox.PlaceholderColor3 = Colors.textDim
DeathBallMissBox.TextColor3 = Colors.text
DeathBallMissBox.TextSize = 10
DeathBallMissBox.Font = Enum.Font.Code
DeathBallMissBox.ClearTextOnFocus = false
DeathBallMissBox.Parent = DeathBallPanel
Instance.new("UICorner", DeathBallMissBox).CornerRadius = UDim.new(0, 4)

DeathBallMissPercent = Instance.new("TextLabel")
DeathBallMissPercent.Size = UDim2.new(0, 12, 0, 18)
DeathBallMissPercent.Position = UDim2.new(0, 132, 0, 714)
DeathBallMissPercent.BackgroundTransparency = 1
DeathBallMissPercent.Text = "%"
DeathBallMissPercent.TextColor3 = Colors.textDim
DeathBallMissPercent.TextSize = 9
DeathBallMissPercent.Font = Enum.Font.GothamBold
DeathBallMissPercent.Parent = DeathBallPanel

-- Bot state label
DeathBallBotStateLabel = Instance.new("TextLabel")
DeathBallBotStateLabel.Size = UDim2.new(1, -20, 0, 14)
DeathBallBotStateLabel.Position = UDim2.new(0, 10, 0, 738)
DeathBallBotStateLabel.BackgroundTransparency = 1
DeathBallBotStateLabel.Text = "Bot: Idle"
DeathBallBotStateLabel.TextColor3 = Colors.textDim
DeathBallBotStateLabel.TextSize = 9
DeathBallBotStateLabel.Font = Enum.Font.Code
DeathBallBotStateLabel.TextXAlignment = Enum.TextXAlignment.Left
DeathBallBotStateLabel.Parent = DeathBallPanel

-- Rounds counter
DeathBallBotRoundsLabel = Instance.new("TextLabel")
DeathBallBotRoundsLabel.Size = UDim2.new(1, -20, 0, 14)
DeathBallBotRoundsLabel.Position = UDim2.new(0, 10, 0, 754)
DeathBallBotRoundsLabel.BackgroundTransparency = 1
DeathBallBotRoundsLabel.Text = "Rounds: 0"
DeathBallBotRoundsLabel.TextColor3 = Color3.fromRGB(200, 200, 100)
DeathBallBotRoundsLabel.TextSize = 9
DeathBallBotRoundsLabel.Font = Enum.Font.GothamBold
DeathBallBotRoundsLabel.TextXAlignment = Enum.TextXAlignment.Left
DeathBallBotRoundsLabel.Parent = DeathBallPanel

-- ═══ INFO TEXT ═══
DeathBallInfoText = Instance.new("TextLabel")
DeathBallInfoText.Size = UDim2.new(1, -20, 0, 50)
DeathBallInfoText.Position = UDim2.new(0, 10, 0, 774)
DeathBallInfoText.BackgroundTransparency = 1
DeathBallInfoText.Text = "v3 AUTO: just press AUTO-PLAY!\nAuto-detects balls, tries all click methods\nFor AFK: set queue pos + turn on bot"
DeathBallInfoText.TextColor3 = Colors.textDim
DeathBallInfoText.TextSize = 8
DeathBallInfoText.Font = Enum.Font.Code
DeathBallInfoText.TextXAlignment = Enum.TextXAlignment.Left
DeathBallInfoText.TextYAlignment = Enum.TextYAlignment.Top
DeathBallInfoText.TextWrapped = true
DeathBallInfoText.Parent = DeathBallPanel

-- ═══ CLOSE ═══
DeathBallCloseBtnBottom = Instance.new("TextButton")
DeathBallCloseBtnBottom.Size = UDim2.new(1, -20, 0, 26)
DeathBallCloseBtnBottom.Position = UDim2.new(0, 10, 0, 830)
DeathBallCloseBtnBottom.BackgroundColor3 = Colors.bloodDark
DeathBallCloseBtnBottom.Text = "CLOSE"
DeathBallCloseBtnBottom.TextColor3 = Colors.text
DeathBallCloseBtnBottom.TextSize = 10
DeathBallCloseBtnBottom.Font = Enum.Font.GothamBold
DeathBallCloseBtnBottom.AutoButtonColor = false
DeathBallCloseBtnBottom.Parent = DeathBallPanel
Instance.new("UICorner", DeathBallCloseBtnBottom).CornerRadius = UDim.new(0, 6)
makeHoverable(DeathBallCloseBtnBottom, Colors.bloodDark, Colors.blood)
