--==================================================
-- TROLL PANEL — FLOATING (aberto via botao TROLL em player cards)
-- Todas as variaveis sao GLOBALS para nao gastar locals
--==================================================

TrollPanel = Instance.new("Frame")
TrollPanel.Name = "TrollPanel"
TrollPanel.Size = UDim2.new(0, 240, 0, 710)
TrollPanel.Position = UDim2.new(0.5, 130, 0.5, -355)
TrollPanel.BackgroundColor3 = Colors.bg
TrollPanel.BorderSizePixel = 0
TrollPanel.Visible = false
TrollPanel.Parent = ScreenGui

Instance.new("UICorner", TrollPanel).CornerRadius = UDim.new(0, 10)
TrollPanelStroke = Instance.new("UIStroke", TrollPanel)
TrollPanelStroke.Color = Colors.glowRed
TrollPanelStroke.Thickness = 1.5
addGradient(TrollPanel, Colors.surfaceLight, Color3.fromRGB(10, 6, 6), 90)

--==================================================
-- TOP BAR
--==================================================

TrollPanelTopBar = Instance.new("Frame")
TrollPanelTopBar.Size = UDim2.new(1, 0, 0, 32)
TrollPanelTopBar.BackgroundColor3 = Colors.topbar
TrollPanelTopBar.BorderSizePixel = 0
TrollPanelTopBar.Parent = TrollPanel
Instance.new("UICorner", TrollPanelTopBar).CornerRadius = UDim.new(0, 10)
addGradient(TrollPanelTopBar, Color3.fromRGB(40, 8, 8), Colors.topbar, 0)

-- Fix bottom corners
TrollPanelTopBarFix = Instance.new("Frame")
TrollPanelTopBarFix.Size = UDim2.new(1, 0, 0, 10)
TrollPanelTopBarFix.Position = UDim2.new(0, 0, 1, -10)
TrollPanelTopBarFix.BackgroundColor3 = Colors.topbar
TrollPanelTopBarFix.BorderSizePixel = 0
TrollPanelTopBarFix.Parent = TrollPanelTopBar

addAccentLine(TrollPanelTopBar, UDim2.new(0, 0, 1, -1), Colors.blood)

TrollPanelTitle = Instance.new("TextLabel")
TrollPanelTitle.Size = UDim2.new(1, -40, 1, 0)
TrollPanelTitle.Position = UDim2.new(0, 10, 0, 0)
TrollPanelTitle.BackgroundTransparency = 1
TrollPanelTitle.Text = "💥 Troll Panel"
TrollPanelTitle.TextColor3 = Colors.bloodLight
TrollPanelTitle.TextSize = 12
TrollPanelTitle.Font = Enum.Font.GothamBold
TrollPanelTitle.TextXAlignment = Enum.TextXAlignment.Left
TrollPanelTitle.Parent = TrollPanelTopBar

TrollPanelClose = Instance.new("TextButton")
TrollPanelClose.Size = UDim2.new(0, 20, 0, 20)
TrollPanelClose.Position = UDim2.new(1, -26, 0, 6)
TrollPanelClose.BackgroundColor3 = Colors.blood
TrollPanelClose.Text = "X"
TrollPanelClose.TextColor3 = Colors.text
TrollPanelClose.TextSize = 11
TrollPanelClose.Font = Enum.Font.GothamBold
TrollPanelClose.AutoButtonColor = false
TrollPanelClose.Parent = TrollPanelTopBar
Instance.new("UICorner", TrollPanelClose).CornerRadius = UDim.new(0, 6)
makeHoverable(TrollPanelClose, Colors.blood, Colors.glowRed)

--==================================================
-- PLAYER INFO
--==================================================

-- Player photo (large, circular)
TrollPanelThumbFrame = Instance.new("Frame")
TrollPanelThumbFrame.Size = UDim2.new(0, 64, 0, 64)
TrollPanelThumbFrame.Position = UDim2.new(0.5, -32, 0, 40)
TrollPanelThumbFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TrollPanelThumbFrame.Parent = TrollPanel
Instance.new("UICorner", TrollPanelThumbFrame).CornerRadius = UDim.new(1, 0)
TrollPanelThumbStroke = Instance.new("UIStroke", TrollPanelThumbFrame)
TrollPanelThumbStroke.Color = Colors.blood
TrollPanelThumbStroke.Thickness = 2

TrollPanelThumb = Instance.new("ImageLabel")
TrollPanelThumb.Size = UDim2.new(1, 0, 1, 0)
TrollPanelThumb.BackgroundTransparency = 1
TrollPanelThumb.Parent = TrollPanelThumbFrame
Instance.new("UICorner", TrollPanelThumb).CornerRadius = UDim.new(1, 0)

-- Player name
TrollPanelPlayerName = Instance.new("TextLabel")
TrollPanelPlayerName.Size = UDim2.new(1, 0, 0, 18)
TrollPanelPlayerName.Position = UDim2.new(0, 0, 0, 110)
TrollPanelPlayerName.BackgroundTransparency = 1
TrollPanelPlayerName.Text = "Select a player"
TrollPanelPlayerName.TextColor3 = Colors.bloodLight
TrollPanelPlayerName.TextSize = 13
TrollPanelPlayerName.Font = Enum.Font.GothamBold
TrollPanelPlayerName.Parent = TrollPanel

-- Target status label
TrollTargetLabel = Instance.new("TextLabel")
TrollTargetLabel.Size = UDim2.new(1, -20, 0, 14)
TrollTargetLabel.Position = UDim2.new(0, 10, 0, 130)
TrollTargetLabel.BackgroundTransparency = 1
TrollTargetLabel.Text = "Target: none"
TrollTargetLabel.TextColor3 = Colors.textDim
TrollTargetLabel.TextSize = 10
TrollTargetLabel.Font = Enum.Font.GothamBold
TrollTargetLabel.TextXAlignment = Enum.TextXAlignment.Left
TrollTargetLabel.Parent = TrollPanel

--==================================================
-- SECTION: ACTIONS (SCROLLABLE)
--==================================================

addAccentLine(TrollPanel, UDim2.new(0, 10, 0, 150), Colors.blood, UDim2.new(1, -20, 0, 1))

-- Scrollable button area
TrollBtnScroll = Instance.new("ScrollingFrame")
TrollBtnScroll.Size = UDim2.new(1, 0, 0, 400)
TrollBtnScroll.Position = UDim2.new(0, 0, 0, 155)
TrollBtnScroll.BackgroundTransparency = 1
TrollBtnScroll.BorderSizePixel = 0
TrollBtnScroll.ScrollBarThickness = 4
TrollBtnScroll.ScrollBarImageColor3 = Colors.blood
TrollBtnScroll.CanvasSize = UDim2.new(0, 0, 0, 844)
TrollBtnScroll.Parent = TrollPanel

--==================================================
-- TROLL BUTTON GRID (2 columns, scrollable)
--==================================================

-- Helper to create a troll action button (40px height, compact)
createTrollBtn = function(parent, text, yPos, xCol, color)
    local btnW = 105
    local xPos = xCol == 0 and 10 or 125
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, btnW, 0, 40)
    btn.Position = UDim2.new(0, xPos, 0, yPos)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Colors.text
    btn.TextSize = 10
    btn.Font = Enum.Font.GothamBold
    btn.AutoButtonColor = false
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    addBtnGradient(btn)

    -- Hover color
    local hc = Color3.new(
        math.min(color.R + 0.1, 1),
        math.min(color.G + 0.1, 1),
        math.min(color.B + 0.1, 1)
    )
    makeHoverable(btn, color, hc)
    return btn
end

-- Row 1 (y=4)
TrollFlingBtn = createTrollBtn(TrollBtnScroll, "💥 FLING", 4, 0, Colors.glowRed)
TrollHeadsitBtn = createTrollBtn(TrollBtnScroll, "🪑 HEADSIT", 4, 1, Colors.warning)

-- Row 2 (y=48)
TrollBangBtn = createTrollBtn(TrollBtnScroll, "😏 BANG", 48, 0, Colors.purple)
TrollBang2Btn = createTrollBtn(TrollBtnScroll, "🍑 BANG 2", 48, 1, Color3.fromRGB(180, 50, 100))

-- Row 3 (y=92)
TrollBackpackBtn = createTrollBtn(TrollBtnScroll, "🎒 BACKPACK", 92, 0, Color3.fromRGB(40, 100, 120))
TrollOrbitBtn = createTrollBtn(TrollBtnScroll, "🌀 ORBIT", 92, 1, Colors.green)

-- Row 4 (y=136)
TrollHelicopterBtn = createTrollBtn(TrollBtnScroll, "🚁 HELICOPTER", 136, 0, Color3.fromRGB(200, 80, 40))
TrollSpinTopBtn = createTrollBtn(TrollBtnScroll, "🌪 SPIN TOP", 136, 1, Color3.fromRGB(180, 50, 180))

-- Row 5 (y=180)
TrollTrampolineBtn = createTrollBtn(TrollBtnScroll, "🦘 TRAMPOLINE", 180, 0, Color3.fromRGB(50, 160, 80))
TrollCreepBtn = createTrollBtn(TrollBtnScroll, "👀 CREEP", 180, 1, Color3.fromRGB(60, 60, 60))

-- Row 6 (y=224)
TrollFlingAllBtn = createTrollBtn(TrollBtnScroll, "💣 FLING ALL", 224, 0, Colors.bloodDark)
TrollLaunchBtn = createTrollBtn(TrollBtnScroll, "🚀 LAUNCH", 224, 1, Color3.fromRGB(80, 40, 160))

-- Row 7 (y=268)
TrollCarpetBtn = createTrollBtn(TrollBtnScroll, "🧎 CARPET", 268, 0, Color3.fromRGB(140, 100, 40))
TrollDizzyBtn = createTrollBtn(TrollBtnScroll, "😵 DIZZY", 268, 1, Color3.fromRGB(220, 60, 180))

-- Row 8 (y=312)
TrollMagnetBtn = createTrollBtn(TrollBtnScroll, "🧲 MAGNET", 312, 0, Color3.fromRGB(40, 80, 160))
TrollCloneBtn = createTrollBtn(TrollBtnScroll, "👤 CLONE", 312, 1, Color3.fromRGB(60, 60, 60))

-- Row 9 (y=356)
TrollUpsideDownBtn = createTrollBtn(TrollBtnScroll, "🙃 UPSIDE DOWN", 356, 0, Color3.fromRGB(120, 60, 160))
TrollTornadoBtn = createTrollBtn(TrollBtnScroll, "🌪 TORNADO", 356, 1, Color3.fromRGB(30, 120, 140))

-- Row 10 (y=400)
TrollSnakeBtn = createTrollBtn(TrollBtnScroll, "🐍 SNAKE", 400, 0, Color3.fromRGB(60, 140, 40))
TrollMirrorBtn = createTrollBtn(TrollBtnScroll, "🪞 MIRROR", 400, 1, Color3.fromRGB(100, 140, 200))

-- Row 11 (y=444)
TrollStackBtn = createTrollBtn(TrollBtnScroll, "🏋 STACK", 444, 0, Color3.fromRGB(180, 120, 40))
TrollFigure8Btn = createTrollBtn(TrollBtnScroll, "🔄 FIGURE 8", 444, 1, Color3.fromRGB(60, 120, 180))

-- Row 12 (y=488)
TrollDogBtn = createTrollBtn(TrollBtnScroll, "🐶 DOG", 488, 0, Color3.fromRGB(140, 100, 60))
TrollFerrisBtn = createTrollBtn(TrollBtnScroll, "🎡 FERRIS", 488, 1, Color3.fromRGB(200, 60, 120))

-- Row 13 (y=532)
TrollSalsaBtn = createTrollBtn(TrollBtnScroll, "💃 SALSA", 532, 0, Color3.fromRGB(200, 40, 80))
TrollUfoBtn = createTrollBtn(TrollBtnScroll, "🛸 UFO", 532, 1, Color3.fromRGB(80, 180, 80))

-- Row 14 (y=576)
TrollBoomerangBtn = createTrollBtn(TrollBtnScroll, "🪃 BOOMERANG", 576, 0, Color3.fromRGB(200, 140, 40))
TrollRollerBtn = createTrollBtn(TrollBtnScroll, "🎢 ROLLER", 576, 1, Color3.fromRGB(40, 100, 200))

-- Row 15 (y=620)
TrollSpiralBtn = createTrollBtn(TrollBtnScroll, "🌀 SPIRAL", 620, 0, Color3.fromRGB(160, 40, 200))
TrollSurfBtn = createTrollBtn(TrollBtnScroll, "🏄 SURF", 620, 1, Color3.fromRGB(40, 160, 200))

-- Row 16 (y=664)
TrollBouncerBtn = createTrollBtn(TrollBtnScroll, "🎪 BOUNCER", 664, 0, Color3.fromRGB(200, 100, 40))
TrollLapSitBtn = createTrollBtn(TrollBtnScroll, "💺 LAP SIT", 664, 1, Color3.fromRGB(160, 60, 100))

-- Row 17 (y=708)
TrollWaveBtn = createTrollBtn(TrollBtnScroll, "🌊 WAVE", 708, 0, Color3.fromRGB(40, 120, 180))
TrollParasiteBtn = createTrollBtn(TrollBtnScroll, "🦠 PARASITE", 708, 1, Color3.fromRGB(100, 200, 60))

-- Row 18 (y=752)
TrollStalkBtn = createTrollBtn(TrollBtnScroll, "👁 STALK", 752, 0, Color3.fromRGB(60, 60, 80))
TrollPushBtn = createTrollBtn(TrollBtnScroll, "🤜 PUSH", 752, 1, Color3.fromRGB(200, 120, 40))

-- Row 19 (y=796)
TrollSwapBtn = createTrollBtn(TrollBtnScroll, "🔀 SWAP", 796, 0, Color3.fromRGB(40, 160, 160))
TrollJailBtn = createTrollBtn(TrollBtnScroll, "🔒 JAIL", 796, 1, Color3.fromRGB(180, 0, 0))

--==================================================
-- TROLL SPEED SLIDER
--==================================================

addAccentLine(TrollPanel, UDim2.new(0, 10, 0, 558), Colors.blood, UDim2.new(1, -20, 0, 1))

TrollSpeedSlider = createSliderRow(TrollPanel, "Troll Speed", 0.5, 5, 1, 564, function(val)
    trollSpeedMul = val
end)

--==================================================
-- STOP TROLL BUTTON
--==================================================

TrollStopBtn = Instance.new("TextButton")
TrollStopBtn.Size = UDim2.new(1, -20, 0, 30)
TrollStopBtn.Position = UDim2.new(0, 10, 0, 610)
TrollStopBtn.BackgroundColor3 = Colors.warning
TrollStopBtn.Text = "⛔ STOP TROLL"
TrollStopBtn.TextColor3 = Colors.bg
TrollStopBtn.TextSize = 11
TrollStopBtn.Font = Enum.Font.GothamBold
TrollStopBtn.AutoButtonColor = false
TrollStopBtn.Parent = TrollPanel
Instance.new("UICorner", TrollStopBtn).CornerRadius = UDim.new(0, 6)
makeHoverable(TrollStopBtn, Colors.warning, Color3.fromRGB(230, 180, 60))

--==================================================
-- CLOSE BUTTON
--==================================================

TrollCloseBottomBtn = Instance.new("TextButton")
TrollCloseBottomBtn.Size = UDim2.new(1, -20, 0, 26)
TrollCloseBottomBtn.Position = UDim2.new(0, 10, 0, 646)
TrollCloseBottomBtn.BackgroundColor3 = Colors.bloodDark
TrollCloseBottomBtn.Text = "🔴 CLOSE"
TrollCloseBottomBtn.TextColor3 = Colors.text
TrollCloseBottomBtn.TextSize = 11
TrollCloseBottomBtn.Font = Enum.Font.GothamBold
TrollCloseBottomBtn.AutoButtonColor = false
TrollCloseBottomBtn.Parent = TrollPanel
Instance.new("UICorner", TrollCloseBottomBtn).CornerRadius = UDim.new(0, 6)
makeHoverable(TrollCloseBottomBtn, Colors.bloodDark, Colors.blood)

--==================================================
-- OPEN TROLL PANEL
--==================================================

openTrollPanel = function(player)
    trollTarget = player
    TrollTargetLabel.Text = "Target: " .. player.DisplayName
    TrollTargetLabel.TextColor3 = Colors.bloodLight
    TrollPanelPlayerName.Text = player.DisplayName
    TrollPanelTitle.Text = "💥 " .. player.DisplayName

    -- Reset speed slider
    TrollSpeedSlider.setValue(trollSpeedMul)

    -- Load thumbnail
    task.spawn(function()
        local ok, thumb = pcall(function()
            return Players:GetUserThumbnailAsync(
                player.UserId,
                Enum.ThumbnailType.HeadShot,
                Enum.ThumbnailSize.Size150x150
            )
        end)
        if ok and thumb then TrollPanelThumb.Image = thumb end
    end)

    TrollPanel.Visible = true
    notify("Troll target: " .. player.DisplayName, "info")
end
