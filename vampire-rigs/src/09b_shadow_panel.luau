--==================================================
-- SHADOW PANEL — FLOATING (aberto via botao SHADOW em player cards)
-- Todas as variaveis sao GLOBALS para nao gastar locals
--==================================================

ShadowPanel = Instance.new("Frame")
ShadowPanel.Name = "ShadowPanel"
ShadowPanel.Size = UDim2.new(0, 240, 0, 540)
ShadowPanel.Position = UDim2.new(0.5, -120, 0.5, -270)
ShadowPanel.BackgroundColor3 = Colors.bg
ShadowPanel.BorderSizePixel = 0
ShadowPanel.Visible = false
ShadowPanel.Parent = ScreenGui

Instance.new("UICorner", ShadowPanel).CornerRadius = UDim.new(0, 10)
ShadowPanelStroke = Instance.new("UIStroke", ShadowPanel)
ShadowPanelStroke.Color = Colors.glowPurple
ShadowPanelStroke.Thickness = 1.5
addGradient(ShadowPanel, Colors.surfaceLight, Color3.fromRGB(8, 8, 10), 90)

--==================================================
-- TOP BAR
--==================================================

ShadowPanelTopBar = Instance.new("Frame")
ShadowPanelTopBar.Size = UDim2.new(1, 0, 0, 32)
ShadowPanelTopBar.BackgroundColor3 = Colors.topbar
ShadowPanelTopBar.BorderSizePixel = 0
ShadowPanelTopBar.Parent = ShadowPanel
Instance.new("UICorner", ShadowPanelTopBar).CornerRadius = UDim.new(0, 10)
addGradient(ShadowPanelTopBar, Color3.fromRGB(30, 10, 40), Colors.topbar, 0)

-- Fix bottom corners
ShadowPanelTopBarFix = Instance.new("Frame")
ShadowPanelTopBarFix.Size = UDim2.new(1, 0, 0, 10)
ShadowPanelTopBarFix.Position = UDim2.new(0, 0, 1, -10)
ShadowPanelTopBarFix.BackgroundColor3 = Colors.topbar
ShadowPanelTopBarFix.BorderSizePixel = 0
ShadowPanelTopBarFix.Parent = ShadowPanelTopBar

addAccentLine(ShadowPanelTopBar, UDim2.new(0, 0, 1, -1), Colors.glowPurple)

ShadowPanelTitle = Instance.new("TextLabel")
ShadowPanelTitle.Size = UDim2.new(1, -40, 1, 0)
ShadowPanelTitle.Position = UDim2.new(0, 10, 0, 0)
ShadowPanelTitle.BackgroundTransparency = 1
ShadowPanelTitle.Text = "👤 Shadow Mode"
ShadowPanelTitle.TextColor3 = Colors.purpleLight
ShadowPanelTitle.TextSize = 12
ShadowPanelTitle.Font = Enum.Font.GothamBold
ShadowPanelTitle.TextXAlignment = Enum.TextXAlignment.Left
ShadowPanelTitle.Parent = ShadowPanelTopBar

ShadowPanelClose = Instance.new("TextButton")
ShadowPanelClose.Size = UDim2.new(0, 20, 0, 20)
ShadowPanelClose.Position = UDim2.new(1, -26, 0, 6)
ShadowPanelClose.BackgroundColor3 = Colors.blood
ShadowPanelClose.Text = "X"
ShadowPanelClose.TextColor3 = Colors.text
ShadowPanelClose.TextSize = 11
ShadowPanelClose.Font = Enum.Font.GothamBold
ShadowPanelClose.AutoButtonColor = false
ShadowPanelClose.Parent = ShadowPanelTopBar
Instance.new("UICorner", ShadowPanelClose).CornerRadius = UDim.new(0, 6)
makeHoverable(ShadowPanelClose, Colors.blood, Colors.glowRed)

--==================================================
-- PLAYER INFO
--==================================================

-- Player photo (large, circular)
ShadowPanelThumbFrame = Instance.new("Frame")
ShadowPanelThumbFrame.Size = UDim2.new(0, 64, 0, 64)
ShadowPanelThumbFrame.Position = UDim2.new(0.5, -32, 0, 40)
ShadowPanelThumbFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ShadowPanelThumbFrame.Parent = ShadowPanel
Instance.new("UICorner", ShadowPanelThumbFrame).CornerRadius = UDim.new(1, 0)
ShadowPanelThumbStroke = Instance.new("UIStroke", ShadowPanelThumbFrame)
ShadowPanelThumbStroke.Color = Colors.glowPurple
ShadowPanelThumbStroke.Thickness = 2

ShadowPanelThumb = Instance.new("ImageLabel")
ShadowPanelThumb.Size = UDim2.new(1, 0, 1, 0)
ShadowPanelThumb.BackgroundTransparency = 1
ShadowPanelThumb.Parent = ShadowPanelThumbFrame
Instance.new("UICorner", ShadowPanelThumb).CornerRadius = UDim.new(1, 0)

-- Player name
ShadowPanelPlayerName = Instance.new("TextLabel")
ShadowPanelPlayerName.Size = UDim2.new(1, 0, 0, 18)
ShadowPanelPlayerName.Position = UDim2.new(0, 0, 0, 110)
ShadowPanelPlayerName.BackgroundTransparency = 1
ShadowPanelPlayerName.Text = "Select a player"
ShadowPanelPlayerName.TextColor3 = Colors.purpleLight
ShadowPanelPlayerName.TextSize = 13
ShadowPanelPlayerName.Font = Enum.Font.GothamBold
ShadowPanelPlayerName.Parent = ShadowPanel

-- Target status label (same name as before — used by 21_emote_shadow)
ShadowTargetLabel = Instance.new("TextLabel")
ShadowTargetLabel.Size = UDim2.new(1, -20, 0, 14)
ShadowTargetLabel.Position = UDim2.new(0, 10, 0, 130)
ShadowTargetLabel.BackgroundTransparency = 1
ShadowTargetLabel.Text = "Target: none"
ShadowTargetLabel.TextColor3 = Colors.textDim
ShadowTargetLabel.TextSize = 10
ShadowTargetLabel.Font = Enum.Font.GothamBold
ShadowTargetLabel.TextXAlignment = Enum.TextXAlignment.Left
ShadowTargetLabel.Parent = ShadowPanel

--==================================================
-- QUICK PRESETS (row of 5 buttons)
--==================================================

shadowPresetButtons = {}
shadowPresetDefs = {
    { name = "Behind", angle = 0,   height = 0, faceTarget = false, mode = "orbit" },
    { name = "Front",  angle = 180, height = 0, faceTarget = true,  mode = "orbit" },
    { name = "Left",   angle = 270, height = 0, faceTarget = false, mode = "orbit" },
    { name = "Right",  angle = 90,  height = 0, faceTarget = false, mode = "orbit" },
    { name = "Head",   angle = 0,   height = 0, faceTarget = false, mode = "head" },
}

do
    local btnWidth = 42
    local gap = 2
    local startX = 10
    for i, def in ipairs(shadowPresetDefs) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, btnWidth, 0, 24)
        btn.Position = UDim2.new(0, startX + (i - 1) * (btnWidth + gap), 0, 152)
        btn.BackgroundColor3 = Color3.fromRGB(40, 20, 40)
        btn.Text = def.name
        btn.TextColor3 = Colors.textDim
        btn.TextSize = 9
        btn.Font = Enum.Font.GothamBold
        btn.AutoButtonColor = false
        btn.Parent = ShadowPanel
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
        makeHoverable(btn, Color3.fromRGB(40, 20, 40), Colors.glowPurple)
        shadowPresetButtons[i] = { btn = btn, def = def }
    end
end

--==================================================
-- REFRESH PRESET HIGHLIGHT
--==================================================

refreshShadowModeButtons = function()
    for _, data in ipairs(shadowPresetButtons) do
        local def = data.def
        local isActive = shadowState.active and shadowState.mode == def.mode
        if def.mode == "orbit" and isActive then
            isActive = (shadowState.angle == def.angle and shadowState.faceTarget == def.faceTarget)
        end
        data.btn.BackgroundColor3 = isActive and Colors.glowPurple or Color3.fromRGB(40, 20, 40)
        data.btn.TextColor3 = isActive and Colors.text or Colors.textDim
    end
end

--==================================================
-- SLIDERS
--==================================================

-- Angle slider (0-360)
ShadowPanelAngleSlider = createSliderRow(ShadowPanel, "Angle (0-360)", 0, 360, 0, 182, function(val)
    shadowState.angle = val
end)

-- Height slider (-5 to 10)
ShadowPanelHeightSlider = createSliderRow(ShadowPanel, "Height (studs)", -5, 10, 0, 216, function(val)
    shadowState.height = val
end)

-- Distance slider (1-15)
ShadowPanelDistSlider = createSliderRow(ShadowPanel, "Distance (studs)", 1, 15, 4, 250, function(val)
    shadowState.distance = val
end)

-- Delay slider (0-5)
ShadowPanelDelaySlider = createSliderRow(ShadowPanel, "Delay (sec)", 0, 5, 0, 284, function(val)
    shadowState.delay = val
end)

--==================================================
-- FACE TARGET TOGGLE
--==================================================

ShadowFaceTargetToggle = createVampToggle(
    ShadowPanel, "Face Target", "faceTarget", shadowState, 318, Colors.glowPurple
)

--==================================================
-- MIRROR ANIMS TOGGLE
--==================================================

ShadowMirrorAnimsToggle = createVampToggle(
    ShadowPanel, "Mirror Anims", "mirrorAnims", shadowState, 346, Colors.glowPurple
)

--==================================================
-- AUTO-ORBIT TOGGLE + SPEED SLIDER
--==================================================

ShadowAutoOrbitToggle = createVampToggle(
    ShadowPanel, "Auto-Orbit", "autoOrbit", shadowState, 374, Colors.glowPurple
)

ShadowOrbitSpeedSlider = createSliderRow(ShadowPanel, "Orbit Speed", 1, 10, 2, 404, function(val)
    shadowState.orbitSpeed = val
end)

--==================================================
-- SHADOW TRAIL TOGGLE
--==================================================

ShadowTrailToggle = createVampToggle(
    ShadowPanel, "Trail Effect", "trail", shadowState, 438, Colors.blood
)

--==================================================
-- RECORD & REPLAY BUTTONS (row of 2)
--==================================================

ShadowRecBtn = Instance.new("TextButton")
ShadowRecBtn.Size = UDim2.new(0.5, -12, 0, 24)
ShadowRecBtn.Position = UDim2.new(0, 10, 0, 470)
ShadowRecBtn.BackgroundColor3 = Colors.blood
ShadowRecBtn.Text = "⏺ REC"
ShadowRecBtn.TextColor3 = Colors.text
ShadowRecBtn.TextSize = 10
ShadowRecBtn.Font = Enum.Font.GothamBold
ShadowRecBtn.AutoButtonColor = false
ShadowRecBtn.Parent = ShadowPanel
Instance.new("UICorner", ShadowRecBtn).CornerRadius = UDim.new(0, 6)
makeHoverable(ShadowRecBtn, Colors.blood, Colors.glowRed)

ShadowPlayReplayBtn = Instance.new("TextButton")
ShadowPlayReplayBtn.Size = UDim2.new(0.5, -12, 0, 24)
ShadowPlayReplayBtn.Position = UDim2.new(0.5, 2, 0, 470)
ShadowPlayReplayBtn.BackgroundColor3 = Colors.green
ShadowPlayReplayBtn.Text = "▶ REPLAY"
ShadowPlayReplayBtn.TextColor3 = Colors.text
ShadowPlayReplayBtn.TextSize = 10
ShadowPlayReplayBtn.Font = Enum.Font.GothamBold
ShadowPlayReplayBtn.AutoButtonColor = false
ShadowPlayReplayBtn.Parent = ShadowPanel
Instance.new("UICorner", ShadowPlayReplayBtn).CornerRadius = UDim.new(0, 6)
makeHoverable(ShadowPlayReplayBtn, Colors.green, Colors.greenLight)

--==================================================
-- RESET + STOP BUTTONS (row of 2)
--==================================================

ShadowResetBtn = Instance.new("TextButton")
ShadowResetBtn.Size = UDim2.new(0.5, -12, 0, 24)
ShadowResetBtn.Position = UDim2.new(0, 10, 0, 500)
ShadowResetBtn.BackgroundColor3 = Colors.warning
ShadowResetBtn.Text = "↺ RESET"
ShadowResetBtn.TextColor3 = Colors.bg
ShadowResetBtn.TextSize = 10
ShadowResetBtn.Font = Enum.Font.GothamBold
ShadowResetBtn.AutoButtonColor = false
ShadowResetBtn.Parent = ShadowPanel
Instance.new("UICorner", ShadowResetBtn).CornerRadius = UDim.new(0, 6)
makeHoverable(ShadowResetBtn, Colors.warning, Color3.fromRGB(230, 180, 60))

StopShadowBtn = Instance.new("TextButton")
StopShadowBtn.Size = UDim2.new(0.5, -12, 0, 24)
StopShadowBtn.Position = UDim2.new(0.5, 2, 0, 500)
StopShadowBtn.BackgroundColor3 = Colors.bloodDark
StopShadowBtn.Text = "🔴 STOP"
StopShadowBtn.TextColor3 = Colors.text
StopShadowBtn.TextSize = 10
StopShadowBtn.Font = Enum.Font.GothamBold
StopShadowBtn.AutoButtonColor = false
StopShadowBtn.Parent = ShadowPanel
Instance.new("UICorner", StopShadowBtn).CornerRadius = UDim.new(0, 6)
makeHoverable(StopShadowBtn, Colors.bloodDark, Colors.blood)

--==================================================
-- OPEN SHADOW PANEL
--==================================================

openShadowPanel = function(player)
    shadowState.target = player
    ShadowTargetLabel.Text = "Target: " .. player.DisplayName
    ShadowTargetLabel.TextColor3 = Colors.purpleLight
    ShadowPanelPlayerName.Text = player.DisplayName
    ShadowPanelTitle.Text = "👤 " .. player.DisplayName

    -- Load thumbnail
    task.spawn(function()
        local ok, thumb = pcall(function()
            return Players:GetUserThumbnailAsync(
                player.UserId,
                Enum.ThumbnailType.HeadShot,
                Enum.ThumbnailSize.Size150x150
            )
        end)
        if ok and thumb then ShadowPanelThumb.Image = thumb end
    end)

    -- Sync sliders + toggles to current state
    ShadowPanelAngleSlider.setValue(shadowState.angle)
    ShadowPanelHeightSlider.setValue(shadowState.height)
    ShadowPanelDistSlider.setValue(shadowState.distance)
    ShadowPanelDelaySlider.setValue(shadowState.delay)
    ShadowOrbitSpeedSlider.setValue(shadowState.orbitSpeed)
    ShadowFaceTargetToggle.refresh()
    ShadowMirrorAnimsToggle.refresh()
    ShadowAutoOrbitToggle.refresh()
    ShadowTrailToggle.refresh()
    refreshShadowModeButtons()
    ShadowPanel.Visible = true
    notify("Shadow target: " .. player.DisplayName, "info")
end
