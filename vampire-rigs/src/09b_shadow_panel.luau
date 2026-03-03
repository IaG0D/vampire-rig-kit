--==================================================
-- SHADOW PANEL — FLOATING (aberto via botao SHADOW em player cards)
-- Todas as variaveis sao GLOBALS para nao gastar locals
--==================================================

ShadowPanel = Instance.new("Frame")
ShadowPanel.Name = "ShadowPanel"
ShadowPanel.Size = UDim2.new(0, 240, 0, 380)
ShadowPanel.Position = UDim2.new(0.5, -120, 0.5, -190)
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
-- SHADOW MODE BUTTONS
--==================================================

shadowModeToggles = {}
shadowModeDefs = {
    { name = "Follow Behind",       mode = "follow", color = Colors.green },
    { name = "Sit on Head",         mode = "head",   color = Colors.warning },
    { name = "Shadow Box (Mirror)", mode = "mirror", color = Colors.glowPurple },
}

do
    local modeY = 150
    for i, def in ipairs(shadowModeDefs) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -20, 0, 26)
        btn.Position = UDim2.new(0, 10, 0, modeY + (i - 1) * 30)
        btn.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
        btn.Text = def.name
        btn.TextColor3 = Colors.textDim
        btn.TextSize = 10
        btn.Font = Enum.Font.GothamBold
        btn.AutoButtonColor = false
        btn.Parent = ShadowPanel
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        shadowModeToggles[def.mode] = { btn = btn, def = def }
    end
end

refreshShadowModeButtons = function()
    for mode, data in pairs(shadowModeToggles) do
        local isActive = shadowState.active and shadowState.mode == mode
        data.btn.BackgroundColor3 = isActive and data.def.color or Color3.fromRGB(40, 20, 20)
        data.btn.TextColor3 = isActive and Colors.text or Colors.textDim
    end
end

--==================================================
-- SLIDERS
--==================================================

-- Distance slider
ShadowPanelDistSlider = createSliderRow(ShadowPanel, "Distance (studs)", 1, 15, 4, 244, function(val)
    shadowState.distance = val
end)

-- Delay slider
ShadowPanelDelaySlider = createSliderRow(ShadowPanel, "Delay (sec)", 0, 5, 0, 276, function(val)
    shadowState.delay = val
end)

--==================================================
-- STOP BUTTON
--==================================================

StopShadowBtn = Instance.new("TextButton")
StopShadowBtn.Size = UDim2.new(1, -20, 0, 28)
StopShadowBtn.Position = UDim2.new(0, 10, 0, 314)
StopShadowBtn.BackgroundColor3 = Colors.bloodDark
StopShadowBtn.Text = "🔴 STOP SHADOW"
StopShadowBtn.TextColor3 = Colors.text
StopShadowBtn.TextSize = 11
StopShadowBtn.Font = Enum.Font.GothamBold
StopShadowBtn.AutoButtonColor = false
StopShadowBtn.Parent = ShadowPanel
Instance.new("UICorner", StopShadowBtn).CornerRadius = UDim.new(0, 6)
addBtnGradient(StopShadowBtn)
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

    refreshShadowModeButtons()
    ShadowPanel.Visible = true
    notify("Shadow target: " .. player.DisplayName, "info")
end
