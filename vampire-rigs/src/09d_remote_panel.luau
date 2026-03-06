--==================================================
-- REMOTE SPY PANEL — FLOATING
-- Scanner + Spy + Custom Fire + Block + Repeat + Export
-- Todas as variaveis sao GLOBALS para nao gastar locals
--==================================================

selectedFireRemote = nil

RemoteSpyPanel = Instance.new("Frame")
RemoteSpyPanel.Name = "RemoteSpyPanel"
RemoteSpyPanel.Size = UDim2.new(0, 280, 0, 710)
RemoteSpyPanel.Position = UDim2.new(0.5, -400, 0.5, -360)
RemoteSpyPanel.BackgroundColor3 = Colors.bg
RemoteSpyPanel.BorderSizePixel = 0
RemoteSpyPanel.Visible = false
RemoteSpyPanel.Parent = ScreenGui

Instance.new("UICorner", RemoteSpyPanel).CornerRadius = UDim.new(0, 10)
RemoteSpyPanelStroke = Instance.new("UIStroke", RemoteSpyPanel)
RemoteSpyPanelStroke.Color = Color3.fromRGB(0, 180, 160)
RemoteSpyPanelStroke.Thickness = 1.5
addGradient(RemoteSpyPanel, Colors.surfaceLight, Color3.fromRGB(6, 10, 10), 90)

--==================================================
-- TOP BAR
--==================================================

RemoteSpyTopBar = Instance.new("Frame")
RemoteSpyTopBar.Size = UDim2.new(1, 0, 0, 32)
RemoteSpyTopBar.BackgroundColor3 = Colors.topbar
RemoteSpyTopBar.BorderSizePixel = 0
RemoteSpyTopBar.Parent = RemoteSpyPanel
Instance.new("UICorner", RemoteSpyTopBar).CornerRadius = UDim.new(0, 10)
addGradient(RemoteSpyTopBar, Color3.fromRGB(8, 30, 28), Colors.topbar, 0)

RemoteSpyTopBarFix = Instance.new("Frame")
RemoteSpyTopBarFix.Size = UDim2.new(1, 0, 0, 10)
RemoteSpyTopBarFix.Position = UDim2.new(0, 0, 1, -10)
RemoteSpyTopBarFix.BackgroundColor3 = Colors.topbar
RemoteSpyTopBarFix.BorderSizePixel = 0
RemoteSpyTopBarFix.Parent = RemoteSpyTopBar

addAccentLine(RemoteSpyTopBar, UDim2.new(0, 0, 1, -1), Color3.fromRGB(0, 180, 160))

RemoteSpyTitle = Instance.new("TextLabel")
RemoteSpyTitle.Size = UDim2.new(1, -40, 1, 0)
RemoteSpyTitle.Position = UDim2.new(0, 10, 0, 0)
RemoteSpyTitle.BackgroundTransparency = 1
RemoteSpyTitle.Text = "🕵 Remote Spy"
RemoteSpyTitle.TextColor3 = Color3.fromRGB(100, 220, 200)
RemoteSpyTitle.TextSize = 12
RemoteSpyTitle.Font = Enum.Font.GothamBold
RemoteSpyTitle.TextXAlignment = Enum.TextXAlignment.Left
RemoteSpyTitle.Parent = RemoteSpyTopBar

RemoteSpyCloseBtn = Instance.new("TextButton")
RemoteSpyCloseBtn.Size = UDim2.new(0, 20, 0, 20)
RemoteSpyCloseBtn.Position = UDim2.new(1, -26, 0, 6)
RemoteSpyCloseBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 120)
RemoteSpyCloseBtn.Text = "X"
RemoteSpyCloseBtn.TextColor3 = Colors.text
RemoteSpyCloseBtn.TextSize = 11
RemoteSpyCloseBtn.Font = Enum.Font.GothamBold
RemoteSpyCloseBtn.AutoButtonColor = false
RemoteSpyCloseBtn.Parent = RemoteSpyTopBar
Instance.new("UICorner", RemoteSpyCloseBtn).CornerRadius = UDim.new(0, 6)
makeHoverable(RemoteSpyCloseBtn, Color3.fromRGB(0, 140, 120), Color3.fromRGB(0, 180, 160))

--==================================================
-- SCAN SECTION
--==================================================

RemoteSpyScanBtn = Instance.new("TextButton")
RemoteSpyScanBtn.Size = UDim2.new(0.5, -12, 0, 28)
RemoteSpyScanBtn.Position = UDim2.new(0, 10, 0, 40)
RemoteSpyScanBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 120)
RemoteSpyScanBtn.Text = "🔍 SCAN"
RemoteSpyScanBtn.TextColor3 = Colors.text
RemoteSpyScanBtn.TextSize = 10
RemoteSpyScanBtn.Font = Enum.Font.GothamBold
RemoteSpyScanBtn.AutoButtonColor = false
RemoteSpyScanBtn.Parent = RemoteSpyPanel
Instance.new("UICorner", RemoteSpyScanBtn).CornerRadius = UDim.new(0, 6)
addBtnGradient(RemoteSpyScanBtn)
makeHoverable(RemoteSpyScanBtn, Color3.fromRGB(0, 140, 120), Color3.fromRGB(0, 180, 160))

RemoteSpyVulnScanBtn = Instance.new("TextButton")
RemoteSpyVulnScanBtn.Size = UDim2.new(0.5, -12, 0, 28)
RemoteSpyVulnScanBtn.Position = UDim2.new(0.5, 2, 0, 40)
RemoteSpyVulnScanBtn.BackgroundColor3 = Color3.fromRGB(180, 80, 20)
RemoteSpyVulnScanBtn.Text = "⚠ VULN SCAN"
RemoteSpyVulnScanBtn.TextColor3 = Colors.text
RemoteSpyVulnScanBtn.TextSize = 10
RemoteSpyVulnScanBtn.Font = Enum.Font.GothamBold
RemoteSpyVulnScanBtn.AutoButtonColor = false
RemoteSpyVulnScanBtn.Parent = RemoteSpyPanel
Instance.new("UICorner", RemoteSpyVulnScanBtn).CornerRadius = UDim.new(0, 6)
addBtnGradient(RemoteSpyVulnScanBtn)
makeHoverable(RemoteSpyVulnScanBtn, Color3.fromRGB(180, 80, 20), Color3.fromRGB(220, 100, 30))

RemoteSpyStatsLabel = Instance.new("TextLabel")
RemoteSpyStatsLabel.Size = UDim2.new(1, -20, 0, 14)
RemoteSpyStatsLabel.Position = UDim2.new(0, 10, 0, 72)
RemoteSpyStatsLabel.BackgroundTransparency = 1
RemoteSpyStatsLabel.Text = "Found: 0 remotes"
RemoteSpyStatsLabel.TextColor3 = Colors.textDim
RemoteSpyStatsLabel.TextSize = 9
RemoteSpyStatsLabel.Font = Enum.Font.Code
RemoteSpyStatsLabel.TextXAlignment = Enum.TextXAlignment.Left
RemoteSpyStatsLabel.Parent = RemoteSpyPanel

RemoteSpyFilterBox = Instance.new("TextBox")
RemoteSpyFilterBox.Size = UDim2.new(1, -20, 0, 22)
RemoteSpyFilterBox.Position = UDim2.new(0, 10, 0, 90)
RemoteSpyFilterBox.BackgroundColor3 = Colors.content
RemoteSpyFilterBox.Text = ""
RemoteSpyFilterBox.PlaceholderText = "Filter remotes..."
RemoteSpyFilterBox.PlaceholderColor3 = Colors.textDim
RemoteSpyFilterBox.TextColor3 = Colors.text
RemoteSpyFilterBox.TextSize = 10
RemoteSpyFilterBox.Font = Enum.Font.Code
RemoteSpyFilterBox.TextXAlignment = Enum.TextXAlignment.Left
RemoteSpyFilterBox.ClearTextOnFocus = false
RemoteSpyFilterBox.Parent = RemoteSpyPanel
Instance.new("UICorner", RemoteSpyFilterBox).CornerRadius = UDim.new(0, 4)
Instance.new("UIPadding", RemoteSpyFilterBox).PaddingLeft = UDim.new(0, 6)

RemoteSpyListScroll = Instance.new("ScrollingFrame")
RemoteSpyListScroll.Size = UDim2.new(1, -20, 0, 120)
RemoteSpyListScroll.Position = UDim2.new(0, 10, 0, 116)
RemoteSpyListScroll.BackgroundColor3 = Colors.content
RemoteSpyListScroll.BorderSizePixel = 0
RemoteSpyListScroll.ScrollBarThickness = 3
RemoteSpyListScroll.ScrollBarImageColor3 = Color3.fromRGB(0, 180, 160)
RemoteSpyListScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
RemoteSpyListScroll.Parent = RemoteSpyPanel
Instance.new("UICorner", RemoteSpyListScroll).CornerRadius = UDim.new(0, 4)

RemoteSpyListLayout = Instance.new("UIListLayout")
RemoteSpyListLayout.Padding = UDim.new(0, 2)
RemoteSpyListLayout.Parent = RemoteSpyListScroll

RemoteSpyListPad = Instance.new("UIPadding", RemoteSpyListScroll)
RemoteSpyListPad.PaddingTop = UDim.new(0, 3)
RemoteSpyListPad.PaddingLeft = UDim.new(0, 3)
RemoteSpyListPad.PaddingRight = UDim.new(0, 3)

--==================================================
-- CUSTOM FIRE SECTION
--==================================================

RemoteSpySelectedLabel = Instance.new("TextLabel")
RemoteSpySelectedLabel.Size = UDim2.new(1, -20, 0, 14)
RemoteSpySelectedLabel.Position = UDim2.new(0, 10, 0, 240)
RemoteSpySelectedLabel.BackgroundTransparency = 1
RemoteSpySelectedLabel.Text = "Selected: (click 🎯 to select)"
RemoteSpySelectedLabel.TextColor3 = Colors.textDim
RemoteSpySelectedLabel.TextSize = 9
RemoteSpySelectedLabel.Font = Enum.Font.Code
RemoteSpySelectedLabel.TextXAlignment = Enum.TextXAlignment.Left
RemoteSpySelectedLabel.TextTruncate = Enum.TextTruncate.AtEnd
RemoteSpySelectedLabel.Parent = RemoteSpyPanel

RemoteSpyArgsBox = Instance.new("TextBox")
RemoteSpyArgsBox.Size = UDim2.new(1, -20, 0, 28)
RemoteSpyArgsBox.Position = UDim2.new(0, 10, 0, 256)
RemoteSpyArgsBox.BackgroundColor3 = Colors.inputBg
RemoteSpyArgsBox.Text = ""
RemoteSpyArgsBox.PlaceholderText = "Args: \"hello\", 123, true"
RemoteSpyArgsBox.PlaceholderColor3 = Colors.textDim
RemoteSpyArgsBox.TextColor3 = Colors.text
RemoteSpyArgsBox.TextSize = 10
RemoteSpyArgsBox.Font = Enum.Font.Code
RemoteSpyArgsBox.TextXAlignment = Enum.TextXAlignment.Left
RemoteSpyArgsBox.ClearTextOnFocus = false
RemoteSpyArgsBox.Parent = RemoteSpyPanel
Instance.new("UICorner", RemoteSpyArgsBox).CornerRadius = UDim.new(0, 4)
Instance.new("UIPadding", RemoteSpyArgsBox).PaddingLeft = UDim.new(0, 6)
RemoteSpyArgsStroke = Instance.new("UIStroke", RemoteSpyArgsBox)
RemoteSpyArgsStroke.Color = Colors.inputBorder
RemoteSpyArgsStroke.Thickness = 1

RemoteSpyArgsBox.Focused:Connect(function()
    TweenService:Create(RemoteSpyArgsStroke, TweenInfo.new(0.2), { Color = Color3.fromRGB(0, 200, 180), Thickness = 1.5 }):Play()
end)
RemoteSpyArgsBox.FocusLost:Connect(function()
    TweenService:Create(RemoteSpyArgsStroke, TweenInfo.new(0.3), { Color = Colors.inputBorder, Thickness = 1 }):Play()
end)

RemoteSpyFireCustomBtn = Instance.new("TextButton")
RemoteSpyFireCustomBtn.Size = UDim2.new(0.5, -12, 0, 26)
RemoteSpyFireCustomBtn.Position = UDim2.new(0, 10, 0, 288)
RemoteSpyFireCustomBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 30)
RemoteSpyFireCustomBtn.Text = "🔥 FIRE"
RemoteSpyFireCustomBtn.TextColor3 = Colors.text
RemoteSpyFireCustomBtn.TextSize = 10
RemoteSpyFireCustomBtn.Font = Enum.Font.GothamBold
RemoteSpyFireCustomBtn.AutoButtonColor = false
RemoteSpyFireCustomBtn.Parent = RemoteSpyPanel
Instance.new("UICorner", RemoteSpyFireCustomBtn).CornerRadius = UDim.new(0, 6)
addBtnGradient(RemoteSpyFireCustomBtn)
makeHoverable(RemoteSpyFireCustomBtn, Color3.fromRGB(180, 60, 30), Color3.fromRGB(220, 80, 40))

RemoteSpyMassFireBtn = Instance.new("TextButton")
RemoteSpyMassFireBtn.Size = UDim2.new(0.5, -12, 0, 26)
RemoteSpyMassFireBtn.Position = UDim2.new(0.5, 2, 0, 288)
RemoteSpyMassFireBtn.BackgroundColor3 = Color3.fromRGB(160, 30, 30)
RemoteSpyMassFireBtn.Text = "💣 MASS FIRE"
RemoteSpyMassFireBtn.TextColor3 = Colors.text
RemoteSpyMassFireBtn.TextSize = 10
RemoteSpyMassFireBtn.Font = Enum.Font.GothamBold
RemoteSpyMassFireBtn.AutoButtonColor = false
RemoteSpyMassFireBtn.Parent = RemoteSpyPanel
Instance.new("UICorner", RemoteSpyMassFireBtn).CornerRadius = UDim.new(0, 6)
addBtnGradient(RemoteSpyMassFireBtn)
makeHoverable(RemoteSpyMassFireBtn, Color3.fromRGB(160, 30, 30), Color3.fromRGB(200, 50, 50))

--==================================================
-- FUZZ + DECOMPILE ROW
--==================================================

RemoteSpyFuzzBtn = Instance.new("TextButton")
RemoteSpyFuzzBtn.Size = UDim2.new(0.5, -12, 0, 26)
RemoteSpyFuzzBtn.Position = UDim2.new(0, 10, 0, 318)
RemoteSpyFuzzBtn.BackgroundColor3 = Color3.fromRGB(120, 60, 180)
RemoteSpyFuzzBtn.Text = "🧪 FUZZ"
RemoteSpyFuzzBtn.TextColor3 = Colors.text
RemoteSpyFuzzBtn.TextSize = 10
RemoteSpyFuzzBtn.Font = Enum.Font.GothamBold
RemoteSpyFuzzBtn.AutoButtonColor = false
RemoteSpyFuzzBtn.Parent = RemoteSpyPanel
Instance.new("UICorner", RemoteSpyFuzzBtn).CornerRadius = UDim.new(0, 6)
addBtnGradient(RemoteSpyFuzzBtn)
makeHoverable(RemoteSpyFuzzBtn, Color3.fromRGB(120, 60, 180), Color3.fromRGB(160, 80, 220))

RemoteSpyDecompileBtn = Instance.new("TextButton")
RemoteSpyDecompileBtn.Size = UDim2.new(0.5, -12, 0, 26)
RemoteSpyDecompileBtn.Position = UDim2.new(0.5, 2, 0, 318)
RemoteSpyDecompileBtn.BackgroundColor3 = Color3.fromRGB(40, 100, 160)
RemoteSpyDecompileBtn.Text = "📜 DECOMPILE"
RemoteSpyDecompileBtn.TextColor3 = Colors.text
RemoteSpyDecompileBtn.TextSize = 10
RemoteSpyDecompileBtn.Font = Enum.Font.GothamBold
RemoteSpyDecompileBtn.AutoButtonColor = false
RemoteSpyDecompileBtn.Parent = RemoteSpyPanel
Instance.new("UICorner", RemoteSpyDecompileBtn).CornerRadius = UDim.new(0, 6)
addBtnGradient(RemoteSpyDecompileBtn)
makeHoverable(RemoteSpyDecompileBtn, Color3.fromRGB(40, 100, 160), Color3.fromRGB(60, 140, 200))

--==================================================
-- SPY SECTION
--==================================================

addAccentLine(RemoteSpyPanel, UDim2.new(0, 10, 0, 352), Color3.fromRGB(0, 180, 160), UDim2.new(1, -20, 0, 1))

RemoteSpyToggleBtn = Instance.new("TextButton")
RemoteSpyToggleBtn.Size = UDim2.new(1, -20, 0, 28)
RemoteSpyToggleBtn.Position = UDim2.new(0, 10, 0, 360)
RemoteSpyToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 80, 70)
RemoteSpyToggleBtn.Text = "🕵 START SPY"
RemoteSpyToggleBtn.TextColor3 = Colors.text
RemoteSpyToggleBtn.TextSize = 11
RemoteSpyToggleBtn.Font = Enum.Font.GothamBold
RemoteSpyToggleBtn.AutoButtonColor = false
RemoteSpyToggleBtn.Parent = RemoteSpyPanel
Instance.new("UICorner", RemoteSpyToggleBtn).CornerRadius = UDim.new(0, 6)
addBtnGradient(RemoteSpyToggleBtn)
makeHoverable(RemoteSpyToggleBtn, Color3.fromRGB(40, 80, 70), Color3.fromRGB(0, 140, 120))

RemoteSpyStatusLabel = Instance.new("TextLabel")
RemoteSpyStatusLabel.Size = UDim2.new(1, -20, 0, 14)
RemoteSpyStatusLabel.Position = UDim2.new(0, 10, 0, 392)
RemoteSpyStatusLabel.BackgroundTransparency = 1
RemoteSpyStatusLabel.Text = "Spy: OFF"
RemoteSpyStatusLabel.TextColor3 = Colors.textDim
RemoteSpyStatusLabel.TextSize = 9
RemoteSpyStatusLabel.Font = Enum.Font.Code
RemoteSpyStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
RemoteSpyStatusLabel.Parent = RemoteSpyPanel

RemoteSpyLogFilterBox = Instance.new("TextBox")
RemoteSpyLogFilterBox.Size = UDim2.new(1, -20, 0, 22)
RemoteSpyLogFilterBox.Position = UDim2.new(0, 10, 0, 410)
RemoteSpyLogFilterBox.BackgroundColor3 = Colors.content
RemoteSpyLogFilterBox.Text = ""
RemoteSpyLogFilterBox.PlaceholderText = "Search spy log..."
RemoteSpyLogFilterBox.PlaceholderColor3 = Colors.textDim
RemoteSpyLogFilterBox.TextColor3 = Colors.text
RemoteSpyLogFilterBox.TextSize = 10
RemoteSpyLogFilterBox.Font = Enum.Font.Code
RemoteSpyLogFilterBox.TextXAlignment = Enum.TextXAlignment.Left
RemoteSpyLogFilterBox.ClearTextOnFocus = false
RemoteSpyLogFilterBox.Parent = RemoteSpyPanel
Instance.new("UICorner", RemoteSpyLogFilterBox).CornerRadius = UDim.new(0, 4)
Instance.new("UIPadding", RemoteSpyLogFilterBox).PaddingLeft = UDim.new(0, 6)

-- Spy log scroll
RemoteSpyLogScroll = Instance.new("ScrollingFrame")
RemoteSpyLogScroll.Size = UDim2.new(1, -20, 0, 150)
RemoteSpyLogScroll.Position = UDim2.new(0, 10, 0, 436)
RemoteSpyLogScroll.BackgroundColor3 = Color3.fromRGB(10, 14, 14)
RemoteSpyLogScroll.BorderSizePixel = 0
RemoteSpyLogScroll.ScrollBarThickness = 3
RemoteSpyLogScroll.ScrollBarImageColor3 = Color3.fromRGB(0, 180, 160)
RemoteSpyLogScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
RemoteSpyLogScroll.Parent = RemoteSpyPanel
Instance.new("UICorner", RemoteSpyLogScroll).CornerRadius = UDim.new(0, 4)

RemoteSpyLogLayout = Instance.new("UIListLayout")
RemoteSpyLogLayout.Padding = UDim.new(0, 1)
RemoteSpyLogLayout.Parent = RemoteSpyLogScroll

RemoteSpyLogPad = Instance.new("UIPadding", RemoteSpyLogScroll)
RemoteSpyLogPad.PaddingTop = UDim.new(0, 2)
RemoteSpyLogPad.PaddingLeft = UDim.new(0, 3)
RemoteSpyLogPad.PaddingRight = UDim.new(0, 3)

-- Hint label
RemoteSpyLogHint = Instance.new("TextLabel")
RemoteSpyLogHint.Size = UDim2.new(1, -20, 0, 12)
RemoteSpyLogHint.Position = UDim2.new(0, 10, 0, 588)
RemoteSpyLogHint.BackgroundTransparency = 1
RemoteSpyLogHint.Text = "💡 Click entry → copy script + auto-fill args"
RemoteSpyLogHint.TextColor3 = Color3.fromRGB(80, 80, 90)
RemoteSpyLogHint.TextSize = 8
RemoteSpyLogHint.Font = Enum.Font.Gotham
RemoteSpyLogHint.TextXAlignment = Enum.TextXAlignment.Left
RemoteSpyLogHint.Parent = RemoteSpyPanel

--==================================================
-- AUTO-REPEAT SECTION
--==================================================

addAccentLine(RemoteSpyPanel, UDim2.new(0, 10, 0, 604), Color3.fromRGB(120, 60, 180), UDim2.new(1, -20, 0, 1))

RemoteSpyRepeatLabel = Instance.new("TextLabel")
RemoteSpyRepeatLabel.Size = UDim2.new(0, 48, 0, 22)
RemoteSpyRepeatLabel.Position = UDim2.new(0, 10, 0, 612)
RemoteSpyRepeatLabel.BackgroundTransparency = 1
RemoteSpyRepeatLabel.Text = "Repeat:"
RemoteSpyRepeatLabel.TextColor3 = Colors.textDim
RemoteSpyRepeatLabel.TextSize = 9
RemoteSpyRepeatLabel.Font = Enum.Font.GothamBold
RemoteSpyRepeatLabel.TextXAlignment = Enum.TextXAlignment.Left
RemoteSpyRepeatLabel.Parent = RemoteSpyPanel

-- Interval box
RemoteSpyIntervalBox = Instance.new("TextBox")
RemoteSpyIntervalBox.Size = UDim2.new(0, 50, 0, 22)
RemoteSpyIntervalBox.Position = UDim2.new(0, 60, 0, 612)
RemoteSpyIntervalBox.BackgroundColor3 = Colors.inputBg
RemoteSpyIntervalBox.Text = "1"
RemoteSpyIntervalBox.PlaceholderText = "sec"
RemoteSpyIntervalBox.PlaceholderColor3 = Colors.textDim
RemoteSpyIntervalBox.TextColor3 = Colors.text
RemoteSpyIntervalBox.TextSize = 9
RemoteSpyIntervalBox.Font = Enum.Font.Code
RemoteSpyIntervalBox.ClearTextOnFocus = false
RemoteSpyIntervalBox.Parent = RemoteSpyPanel
Instance.new("UICorner", RemoteSpyIntervalBox).CornerRadius = UDim.new(0, 4)

RemoteSpyRepeatXLabel = Instance.new("TextLabel")
RemoteSpyRepeatXLabel.Size = UDim2.new(0, 16, 0, 22)
RemoteSpyRepeatXLabel.Position = UDim2.new(0, 113, 0, 612)
RemoteSpyRepeatXLabel.BackgroundTransparency = 1
RemoteSpyRepeatXLabel.Text = "x"
RemoteSpyRepeatXLabel.TextColor3 = Colors.textDim
RemoteSpyRepeatXLabel.TextSize = 9
RemoteSpyRepeatXLabel.Font = Enum.Font.GothamBold
RemoteSpyRepeatXLabel.Parent = RemoteSpyPanel

-- Count box (0 = infinite)
RemoteSpyCountBox = Instance.new("TextBox")
RemoteSpyCountBox.Size = UDim2.new(0, 40, 0, 22)
RemoteSpyCountBox.Position = UDim2.new(0, 130, 0, 612)
RemoteSpyCountBox.BackgroundColor3 = Colors.inputBg
RemoteSpyCountBox.Text = "10"
RemoteSpyCountBox.PlaceholderText = "0=∞"
RemoteSpyCountBox.PlaceholderColor3 = Colors.textDim
RemoteSpyCountBox.TextColor3 = Colors.text
RemoteSpyCountBox.TextSize = 9
RemoteSpyCountBox.Font = Enum.Font.Code
RemoteSpyCountBox.ClearTextOnFocus = false
RemoteSpyCountBox.Parent = RemoteSpyPanel
Instance.new("UICorner", RemoteSpyCountBox).CornerRadius = UDim.new(0, 4)

-- Repeat button
RemoteSpyRepeatBtn = Instance.new("TextButton")
RemoteSpyRepeatBtn.Size = UDim2.new(0, 90, 0, 22)
RemoteSpyRepeatBtn.Position = UDim2.new(1, -100, 0, 612)
RemoteSpyRepeatBtn.BackgroundColor3 = Color3.fromRGB(80, 40, 120)
RemoteSpyRepeatBtn.Text = "▶ REPEAT"
RemoteSpyRepeatBtn.TextColor3 = Colors.text
RemoteSpyRepeatBtn.TextSize = 9
RemoteSpyRepeatBtn.Font = Enum.Font.GothamBold
RemoteSpyRepeatBtn.AutoButtonColor = false
RemoteSpyRepeatBtn.Parent = RemoteSpyPanel
Instance.new("UICorner", RemoteSpyRepeatBtn).CornerRadius = UDim.new(0, 4)
makeHoverable(RemoteSpyRepeatBtn, Color3.fromRGB(80, 40, 120), Color3.fromRGB(110, 60, 160))

--==================================================
-- BOTTOM BUTTONS
--==================================================

-- Row: [EXPORT] [CLEAR]
RemoteSpyExportBtn = Instance.new("TextButton")
RemoteSpyExportBtn.Size = UDim2.new(0.5, -12, 0, 26)
RemoteSpyExportBtn.Position = UDim2.new(0, 10, 0, 644)
RemoteSpyExportBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 140)
RemoteSpyExportBtn.Text = "📋 EXPORT LOG"
RemoteSpyExportBtn.TextColor3 = Colors.text
RemoteSpyExportBtn.TextSize = 9
RemoteSpyExportBtn.Font = Enum.Font.GothamBold
RemoteSpyExportBtn.AutoButtonColor = false
RemoteSpyExportBtn.Parent = RemoteSpyPanel
Instance.new("UICorner", RemoteSpyExportBtn).CornerRadius = UDim.new(0, 6)
makeHoverable(RemoteSpyExportBtn, Color3.fromRGB(0, 100, 140), Color3.fromRGB(0, 140, 180))

RemoteSpyClearBtn = Instance.new("TextButton")
RemoteSpyClearBtn.Size = UDim2.new(0.5, -12, 0, 26)
RemoteSpyClearBtn.Position = UDim2.new(0.5, 2, 0, 644)
RemoteSpyClearBtn.BackgroundColor3 = Colors.warning
RemoteSpyClearBtn.Text = "🗑 CLEAR"
RemoteSpyClearBtn.TextColor3 = Colors.bg
RemoteSpyClearBtn.TextSize = 10
RemoteSpyClearBtn.Font = Enum.Font.GothamBold
RemoteSpyClearBtn.AutoButtonColor = false
RemoteSpyClearBtn.Parent = RemoteSpyPanel
Instance.new("UICorner", RemoteSpyClearBtn).CornerRadius = UDim.new(0, 6)
makeHoverable(RemoteSpyClearBtn, Colors.warning, Color3.fromRGB(230, 180, 60))

-- Row: [CLOSE]
RemoteSpyCloseBottomBtn = Instance.new("TextButton")
RemoteSpyCloseBottomBtn.Size = UDim2.new(1, -20, 0, 26)
RemoteSpyCloseBottomBtn.Position = UDim2.new(0, 10, 0, 674)
RemoteSpyCloseBottomBtn.BackgroundColor3 = Colors.bloodDark
RemoteSpyCloseBottomBtn.Text = "🔴 CLOSE"
RemoteSpyCloseBottomBtn.TextColor3 = Colors.text
RemoteSpyCloseBottomBtn.TextSize = 10
RemoteSpyCloseBottomBtn.Font = Enum.Font.GothamBold
RemoteSpyCloseBottomBtn.AutoButtonColor = false
RemoteSpyCloseBottomBtn.Parent = RemoteSpyPanel
Instance.new("UICorner", RemoteSpyCloseBottomBtn).CornerRadius = UDim.new(0, 6)
makeHoverable(RemoteSpyCloseBottomBtn, Colors.bloodDark, Colors.blood)

--==================================================
-- REFRESH REMOTE LIST (cards com 🎯 select + 🚫 block + call count)
--==================================================

refreshRemoteList = function(filterText)
    for _, child in pairs(RemoteSpyListScroll:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end

    filterText = filterText and filterText:lower() or ""

    local count = 0
    local vulnCount = 0
    for idx, data in ipairs(scannedRemotes) do
        local match = true
        if filterText ~= "" and not data.name:lower():find(filterText, 1, true) and not data.path:lower():find(filterText, 1, true) then
            match = false
        end

        if match then
        count = count + 1
        if data.vuln == "vuln" then vulnCount = vulnCount + 1 end

        local isBlocked = blockedRemotes[data.path] == true
        local callCount = remoteCallCounts[data.path] or 0

        local card = Instance.new("Frame")
        card.Size = UDim2.new(1, -6, 0, 36)
        card.BorderSizePixel = 0
        card.LayoutOrder = idx
        card.Parent = RemoteSpyListScroll
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 4)

        -- Card color
        if isBlocked then
            card.BackgroundColor3 = Color3.fromRGB(50, 10, 10)
        elseif data.vuln == "vuln" then
            card.BackgroundColor3 = Color3.fromRGB(50, 15, 15)
        elseif data.vuln == "safe" then
            card.BackgroundColor3 = Color3.fromRGB(15, 40, 20)
        elseif data.vuln == "timeout" then
            card.BackgroundColor3 = Color3.fromRGB(40, 35, 10)
        else
            card.BackgroundColor3 = Colors.card
        end

        -- Type icon
        local icon = Instance.new("TextLabel")
        icon.Size = UDim2.new(0, 18, 0, 18)
        icon.Position = UDim2.new(0, 3, 0, 2)
        icon.BackgroundTransparency = 1
        icon.Text = data.class == "RemoteEvent" and "📡" or "📞"
        icon.TextSize = 11
        icon.Parent = card

        -- Vuln/Block badge
        if isBlocked then
            local badge = Instance.new("TextLabel")
            badge.Size = UDim2.new(0, 18, 0, 10)
            badge.Position = UDim2.new(0, 3, 0, 20)
            badge.BackgroundTransparency = 1
            badge.Text = "🚫"
            badge.TextSize = 7
            badge.Parent = card
        elseif data.vuln == "vuln" then
            local badge = Instance.new("TextLabel")
            badge.Size = UDim2.new(0, 18, 0, 10)
            badge.Position = UDim2.new(0, 3, 0, 20)
            badge.BackgroundTransparency = 1
            badge.Text = "⚠"
            badge.TextSize = 8
            badge.TextColor3 = Color3.fromRGB(255, 80, 40)
            badge.Parent = card
        elseif data.vuln == "safe" then
            local badge = Instance.new("TextLabel")
            badge.Size = UDim2.new(0, 18, 0, 10)
            badge.Position = UDim2.new(0, 3, 0, 20)
            badge.BackgroundTransparency = 1
            badge.Text = "✓"
            badge.TextSize = 8
            badge.TextColor3 = Color3.fromRGB(60, 200, 80)
            badge.Font = Enum.Font.GothamBold
            badge.Parent = card
        elseif data.vuln == "timeout" then
            local badge = Instance.new("TextLabel")
            badge.Size = UDim2.new(0, 18, 0, 10)
            badge.Position = UDim2.new(0, 3, 0, 20)
            badge.BackgroundTransparency = 1
            badge.Text = "⏱"
            badge.TextSize = 8
            badge.TextColor3 = Color3.fromRGB(200, 180, 60)
            badge.Parent = card
        end

        -- Name (with blocked prefix)
        local nameL = Instance.new("TextLabel")
        nameL.Size = UDim2.new(1, -68, 0, 14)
        nameL.Position = UDim2.new(0, 22, 0, 1)
        nameL.BackgroundTransparency = 1
        nameL.Text = (isBlocked and "[BLOCKED] " or "") .. data.name
        nameL.TextSize = 9
        nameL.Font = Enum.Font.GothamBold
        nameL.TextXAlignment = Enum.TextXAlignment.Left
        nameL.TextTruncate = Enum.TextTruncate.AtEnd
        nameL.Parent = card

        if isBlocked then
            nameL.TextColor3 = Color3.fromRGB(180, 60, 60)
        elseif data.vuln == "vuln" then
            nameL.TextColor3 = Color3.fromRGB(255, 100, 60)
        elseif data.vuln == "safe" then
            nameL.TextColor3 = Color3.fromRGB(80, 220, 100)
        else
            nameL.TextColor3 = Color3.fromRGB(100, 220, 200)
        end

        -- Path + call count
        local pathText = data.path
        if callCount > 0 then
            pathText = pathText .. " [x" .. callCount .. "]"
        end
        local pathL = Instance.new("TextLabel")
        pathL.Size = UDim2.new(1, -68, 0, 12)
        pathL.Position = UDim2.new(0, 22, 0, 16)
        pathL.BackgroundTransparency = 1
        pathL.Text = pathText
        pathL.TextColor3 = Colors.textDim
        pathL.TextSize = 7
        pathL.Font = Enum.Font.Code
        pathL.TextXAlignment = Enum.TextXAlignment.Left
        pathL.TextTruncate = Enum.TextTruncate.AtEnd
        pathL.Parent = card

        -- 🎯 Select button (left)
        local selBtn = Instance.new("TextButton")
        selBtn.Size = UDim2.new(0, 18, 0, 18)
        selBtn.Position = UDim2.new(1, -40, 0, 9)
        selBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 100)
        selBtn.Text = "🎯"
        selBtn.TextSize = 9
        selBtn.TextColor3 = Colors.text
        selBtn.Font = Enum.Font.GothamBold
        selBtn.AutoButtonColor = false
        selBtn.Parent = card
        Instance.new("UICorner", selBtn).CornerRadius = UDim.new(0, 4)
        makeHoverable(selBtn, Color3.fromRGB(0, 120, 100), Color3.fromRGB(0, 160, 140))

        selBtn.MouseButton1Click:Connect(function()
            selectedFireRemote = data
            RemoteSpySelectedLabel.Text = "Selected: " .. data.class:sub(7, 7) .. " " .. data.name
            RemoteSpySelectedLabel.TextColor3 = Color3.fromRGB(100, 220, 200)
            notify("Selected: " .. data.name, "info")
        end)

        -- 🚫 Block button (right)
        local blockBtn = Instance.new("TextButton")
        blockBtn.Size = UDim2.new(0, 18, 0, 18)
        blockBtn.Position = UDim2.new(1, -20, 0, 9)
        blockBtn.BackgroundColor3 = isBlocked and Color3.fromRGB(40, 120, 40) or Color3.fromRGB(120, 30, 30)
        blockBtn.Text = isBlocked and "✅" or "🚫"
        blockBtn.TextSize = 9
        blockBtn.TextColor3 = Colors.text
        blockBtn.Font = Enum.Font.GothamBold
        blockBtn.AutoButtonColor = false
        blockBtn.Parent = card
        Instance.new("UICorner", blockBtn).CornerRadius = UDim.new(0, 4)
        makeHoverable(blockBtn,
            isBlocked and Color3.fromRGB(40, 120, 40) or Color3.fromRGB(120, 30, 30),
            isBlocked and Color3.fromRGB(60, 160, 60) or Color3.fromRGB(160, 50, 50)
        )

        blockBtn.MouseButton1Click:Connect(function()
            if blockedRemotes[data.path] then
                blockedRemotes[data.path] = nil
                notify("Unblocked: " .. data.name, "success")
            else
                blockedRemotes[data.path] = true
                notify("Blocked: " .. data.name, "warning")
            end
            refreshRemoteList(RemoteSpyFilterBox.Text)
        end)
        end -- if match
    end

    RemoteSpyListScroll.CanvasSize = UDim2.new(0, 0, 0, count * 38)

    local statsText = "Found: " .. #scannedRemotes .. " remotes"
    if vulnCount > 0 then
        statsText = statsText .. " | ⚠ " .. vulnCount .. " vuln"
    end
    local blockedCount = 0
    for _ in pairs(blockedRemotes) do blockedCount = blockedCount + 1 end
    if blockedCount > 0 then
        statsText = statsText .. " | 🚫 " .. blockedCount .. " blocked"
    end
    if filterText ~= "" then
        statsText = statsText .. " (" .. count .. " shown)"
    end
    RemoteSpyStatsLabel.Text = statsText
end

--==================================================
-- REFRESH SPY LOG (clickable entries, filtro, caller, return)
--==================================================

refreshRemoteSpyLog = function()
    for _, child in pairs(RemoteSpyLogScroll:GetChildren()) do
        if child:IsA("TextButton") or child:IsA("TextLabel") then child:Destroy() end
    end

    local filterText = RemoteSpyLogFilterBox.Text:lower()
    local count = 0

    for idx, entry in ipairs(remoteSpyLog) do
        local secs = math.floor(entry.time % 60)
        local mins = math.floor((entry.time / 60) % 60)
        local hrs = math.floor((entry.time / 3600) % 24)
        local timeStr = string.format("%02d:%02d:%02d", hrs, mins, secs)

        local argStrs = {}
        for _, arg in ipairs(entry.args) do
            local s = tostring(arg)
            if #s > 30 then s = s:sub(1, 27) .. "..." end
            table.insert(argStrs, s)
        end
        local argsText = #argStrs > 0 and ("(" .. table.concat(argStrs, ", ") .. ")") or "()"

        local fullText = timeStr .. " " .. entry.name .. ":" .. entry.method .. argsText
        -- Add return value for InvokeServer
        if entry.returnValue then
            fullText = fullText .. " → " .. entry.returnValue
        end

        -- Apply filter
        local show = true
        if filterText ~= "" then
            if not fullText:lower():find(filterText, 1, true) and not entry.name:lower():find(filterText, 1, true) then
                show = false
            end
        end

        if show then
            count = count + 1

            -- TextButton for clickable (copy script)
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -6, 0, 14)
            btn.BackgroundColor3 = count % 2 == 0 and Color3.fromRGB(14, 18, 18) or Color3.fromRGB(10, 14, 14)
            btn.BackgroundTransparency = 0
            btn.BorderSizePixel = 0
            btn.LayoutOrder = idx
            btn.AutoButtonColor = false

            btn.Text = fullText
            btn.TextColor3 = entry.method == "FireServer" and Color3.fromRGB(100, 220, 200) or Color3.fromRGB(220, 180, 100)
            btn.TextSize = 7
            btn.Font = Enum.Font.Code
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.TextTruncate = Enum.TextTruncate.AtEnd
            btn.Parent = RemoteSpyLogScroll

            -- Click → copy generated script
            btn.MouseButton1Click:Connect(function()
                copyLogEntry(entry)
            end)

            -- Hover effect
            btn.MouseEnter:Connect(function()
                btn.BackgroundColor3 = Color3.fromRGB(20, 30, 30)
            end)
            btn.MouseLeave:Connect(function()
                btn.BackgroundColor3 = count % 2 == 0 and Color3.fromRGB(14, 18, 18) or Color3.fromRGB(10, 14, 14)
            end)
        end
    end

    RemoteSpyLogScroll.CanvasSize = UDim2.new(0, 0, 0, count * 15)
    RemoteSpyLogScroll.CanvasPosition = Vector2.new(0, math.max(0, count * 15 - 150))
end

--==================================================
-- OPEN REMOTE SPY PANEL
--==================================================

openRemoteSpyPanel = function()
    scanRemotes()
    refreshRemoteList("")
    RemoteSpyPanel.Visible = true
    notify("Remote Spy opened — " .. #scannedRemotes .. " remotes found", "info")
end

--==================================================
-- DECOMPILE RESULTS PANEL — FLOATING
--==================================================

DecompilePanel = Instance.new("Frame")
DecompilePanel.Name = "DecompilePanel"
DecompilePanel.Size = UDim2.new(0, 420, 0, 400)
DecompilePanel.Position = UDim2.new(0.5, 50, 0.5, -200)
DecompilePanel.BackgroundColor3 = Color3.fromRGB(10, 12, 16)
DecompilePanel.BorderSizePixel = 0
DecompilePanel.Visible = false
DecompilePanel.Parent = ScreenGui
Instance.new("UICorner", DecompilePanel).CornerRadius = UDim.new(0, 10)

DecompilePanelStroke = Instance.new("UIStroke", DecompilePanel)
DecompilePanelStroke.Color = Color3.fromRGB(40, 100, 160)
DecompilePanelStroke.Thickness = 1.5
addGradient(DecompilePanel, Color3.fromRGB(12, 16, 22), Color3.fromRGB(6, 8, 12), 90)

-- Top Bar
DecompileTopBar = Instance.new("Frame")
DecompileTopBar.Size = UDim2.new(1, 0, 0, 32)
DecompileTopBar.BackgroundColor3 = Color3.fromRGB(15, 20, 30)
DecompileTopBar.BorderSizePixel = 0
DecompileTopBar.Parent = DecompilePanel
Instance.new("UICorner", DecompileTopBar).CornerRadius = UDim.new(0, 10)
addGradient(DecompileTopBar, Color3.fromRGB(10, 18, 30), Color3.fromRGB(15, 20, 30), 0)

DecompileTopBarFix = Instance.new("Frame")
DecompileTopBarFix.Size = UDim2.new(1, 0, 0, 10)
DecompileTopBarFix.Position = UDim2.new(0, 0, 1, -10)
DecompileTopBarFix.BackgroundColor3 = Color3.fromRGB(15, 20, 30)
DecompileTopBarFix.BorderSizePixel = 0
DecompileTopBarFix.Parent = DecompileTopBar

addAccentLine(DecompileTopBar, UDim2.new(0, 0, 1, -1), Color3.fromRGB(40, 100, 160))

DecompileTitle = Instance.new("TextLabel")
DecompileTitle.Size = UDim2.new(1, -80, 1, 0)
DecompileTitle.Position = UDim2.new(0, 10, 0, 0)
DecompileTitle.BackgroundTransparency = 1
DecompileTitle.Text = "📜 Decompile Results"
DecompileTitle.TextColor3 = Color3.fromRGB(80, 160, 220)
DecompileTitle.TextSize = 12
DecompileTitle.Font = Enum.Font.GothamBold
DecompileTitle.TextXAlignment = Enum.TextXAlignment.Left
DecompileTitle.Parent = DecompileTopBar

DecompileCloseBtn = Instance.new("TextButton")
DecompileCloseBtn.Size = UDim2.new(0, 20, 0, 20)
DecompileCloseBtn.Position = UDim2.new(1, -26, 0, 6)
DecompileCloseBtn.BackgroundColor3 = Color3.fromRGB(40, 100, 160)
DecompileCloseBtn.Text = "X"
DecompileCloseBtn.TextColor3 = Colors.text
DecompileCloseBtn.TextSize = 11
DecompileCloseBtn.Font = Enum.Font.GothamBold
DecompileCloseBtn.AutoButtonColor = false
DecompileCloseBtn.Parent = DecompileTopBar
Instance.new("UICorner", DecompileCloseBtn).CornerRadius = UDim.new(0, 6)
makeHoverable(DecompileCloseBtn, Color3.fromRGB(40, 100, 160), Color3.fromRGB(60, 140, 200))

-- Copy button
DecompileCopyBtn = Instance.new("TextButton")
DecompileCopyBtn.Size = UDim2.new(0, 20, 0, 20)
DecompileCopyBtn.Position = UDim2.new(1, -50, 0, 6)
DecompileCopyBtn.BackgroundColor3 = Color3.fromRGB(30, 80, 60)
DecompileCopyBtn.Text = "📋"
DecompileCopyBtn.TextColor3 = Colors.text
DecompileCopyBtn.TextSize = 10
DecompileCopyBtn.Font = Enum.Font.GothamBold
DecompileCopyBtn.AutoButtonColor = false
DecompileCopyBtn.Parent = DecompileTopBar
Instance.new("UICorner", DecompileCopyBtn).CornerRadius = UDim.new(0, 6)
makeHoverable(DecompileCopyBtn, Color3.fromRGB(30, 80, 60), Color3.fromRGB(40, 120, 90))

-- Status label
DecompileStatusLabel = Instance.new("TextLabel")
DecompileStatusLabel.Size = UDim2.new(1, -20, 0, 14)
DecompileStatusLabel.Position = UDim2.new(0, 10, 0, 36)
DecompileStatusLabel.BackgroundTransparency = 1
DecompileStatusLabel.Text = "Searching..."
DecompileStatusLabel.TextColor3 = Colors.textDim
DecompileStatusLabel.TextSize = 9
DecompileStatusLabel.Font = Enum.Font.Code
DecompileStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
DecompileStatusLabel.Parent = DecompilePanel

-- Code scroll area (fundo estilo terminal)
DecompileCodeScroll = Instance.new("ScrollingFrame")
DecompileCodeScroll.Size = UDim2.new(1, -20, 1, -58)
DecompileCodeScroll.Position = UDim2.new(0, 10, 0, 54)
DecompileCodeScroll.BackgroundColor3 = Color3.fromRGB(4, 6, 10)
DecompileCodeScroll.BorderSizePixel = 0
DecompileCodeScroll.ScrollBarThickness = 4
DecompileCodeScroll.ScrollBarImageColor3 = Color3.fromRGB(40, 100, 160)
DecompileCodeScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
DecompileCodeScroll.Parent = DecompilePanel
Instance.new("UICorner", DecompileCodeScroll).CornerRadius = UDim.new(0, 6)

DecompileCodeLayout = Instance.new("UIListLayout")
DecompileCodeLayout.Padding = UDim.new(0, 0)
DecompileCodeLayout.Parent = DecompileCodeScroll

DecompileCodePad = Instance.new("UIPadding", DecompileCodeScroll)
DecompileCodePad.PaddingTop = UDim.new(0, 4)
DecompileCodePad.PaddingLeft = UDim.new(0, 6)
DecompileCodePad.PaddingRight = UDim.new(0, 4)

-- Texto do decompile guardado aqui para copy
decompileResultText = ""

-- Função para popular o painel
showDecompileResults = function(remoteName, results, checked)
    -- Limpa
    for _, c in pairs(DecompileCodeScroll:GetChildren()) do
        if c:IsA("TextLabel") then c:Destroy() end
    end

    local lineCount = 0

    local function addLine(text, color, bold)
        lineCount = lineCount + 1
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -4, 0, 13)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.TextColor3 = color or Color3.fromRGB(160, 170, 180)
        lbl.TextSize = 9
        lbl.Font = bold and Enum.Font.GothamBold or Enum.Font.Code
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextTruncate = Enum.TextTruncate.AtEnd
        lbl.LayoutOrder = lineCount
        lbl.Parent = DecompileCodeScroll
    end

    if #results == 0 then
        addLine("No scripts reference '" .. remoteName .. "'", Color3.fromRGB(200, 100, 60), true)
        DecompileStatusLabel.Text = "No results — checked " .. checked .. " scripts"
        DecompileStatusLabel.TextColor3 = Color3.fromRGB(200, 100, 60)
    else
        DecompileStatusLabel.Text = "Found in " .. #results .. " scripts — " .. checked .. " checked"
        DecompileStatusLabel.TextColor3 = Color3.fromRGB(80, 200, 120)

        -- Monta texto para copy
        local copyLines = {"-- Decompile: " .. remoteName, ""}
        for _, f in ipairs(results) do
            addLine("═══ " .. f.script .. " ═══", Color3.fromRGB(80, 160, 220), true)
            table.insert(copyLines, "-- ═══ " .. f.script .. " ═══")
            addLine("", nil, false)
            for _, l in ipairs(f.lines) do
                -- ▶ = linha do match (highlight amarelo), resto = contexto (cinza)
                local isMatch = l:sub(1, 3) == "▶" or l:find("▶") == 1
                local color = isMatch and Color3.fromRGB(255, 220, 80) or Color3.fromRGB(140, 160, 140)
                addLine(l, color, isMatch)
                table.insert(copyLines, l)
            end
            addLine("", nil, false)
            table.insert(copyLines, "")
        end
        decompileResultText = table.concat(copyLines, "\n")
    end

    DecompileCodeScroll.CanvasSize = UDim2.new(0, 0, 0, lineCount * 13)
    DecompileTitle.Text = "📜 Decompile: " .. remoteName
    DecompilePanel.Visible = true
end
