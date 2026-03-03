--==================================================
-- ANIMACOES & TOGGLE
--==================================================

local scannerOpen = false
local tweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local tweenInfoIn = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local miniBarTarget = UDim2.new(1, -220, 1, -70)
local lastMiniBarPos = miniBarTarget

-- Anima entrada da MiniBar (slide da direita)
task.delay(0.3, function()
    TweenService:Create(MiniBar, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = miniBarTarget
    }):Play()
end)

-- Pulso sutil no morcego da MiniBar
task.spawn(function()
    while MiniBar and MiniBar.Parent do
        local t1 = TweenService:Create(MiniBat, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            TextTransparency = 0.5,
            Rotation = -10,
        })
        t1:Play()
        t1.Completed:Wait()
        local t2 = TweenService:Create(MiniBat, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            TextTransparency = 0,
            Rotation = 10,
        })
        t2:Play()
        t2.Completed:Wait()
    end
end)

-- Pulso sutil na borda do avatar
task.spawn(function()
    while MiniBar and MiniBar.Parent do
        local t1 = TweenService:Create(avatarStroke, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            Color = Colors.glowRed,
            Thickness = 2,
        })
        t1:Play()
        t1.Completed:Wait()
        local t2 = TweenService:Create(avatarStroke, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            Color = Colors.blood,
            Thickness = 1.5,
        })
        t2:Play()
        t2.Completed:Wait()
    end
end)

-- Pulso sutil no stroke principal da MiniBar
task.spawn(function()
    while MiniBar and MiniBar.Parent do
        local t1 = TweenService:Create(miniStroke, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            Thickness = 2,
            Transparency = 0,
        })
        t1:Play()
        t1.Completed:Wait()
        local t2 = TweenService:Create(miniStroke, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            Thickness = 1.2,
            Transparency = 0.2,
        })
        t2:Play()
        t2.Completed:Wait()
    end
end)

local function openScanner()
    if scannerOpen then return end
    scannerOpen = true

    lastMiniBarPos = MiniBar.Position
    MiniBar.Visible = false

    MainFrame.Visible = true
    MainFrame.Size = UDim2.new(0, 380, 0, 500)
    MainFrame.BackgroundTransparency = 0.3
    local openTween = TweenService:Create(MainFrame, tweenInfo, {
        Size = UDim2.new(0, 420, 0, 560),
        BackgroundTransparency = 0,
    })
    openTween:Play()

    -- Set default tab
    switchTab(activeTab)

    MiniHint.Text = "Ctrl+G to close"
end

local function closeScanner()
    if not scannerOpen then return end
    scannerOpen = false

    PreviewFrame.Visible = false

    local closeTween = TweenService:Create(MainFrame, tweenInfoIn, {
        Size = UDim2.new(0, 380, 0, 500),
        BackgroundTransparency = 0.5,
    })
    closeTween:Play()
    closeTween.Completed:Connect(function()
        if not scannerOpen then
            MainFrame.Visible = false
            MainFrame.Size = UDim2.new(0, 420, 0, 560)
            MainFrame.BackgroundTransparency = 0
        end
    end)

    MiniBar.Position = lastMiniBarPos
    MiniBar.Visible = true

    MiniHint.Text = "Ctrl+G to open"
end

local function toggleScanner()
    if scannerOpen then
        closeScanner()
    else
        openScanner()
    end
end

-- MiniBar hover effect (premium)
MiniBar.MouseEnter:Connect(function()
    TweenService:Create(miniStroke, TweenInfo.new(0.2), {
        Color = Colors.glowRed,
        Thickness = 2.5,
        Transparency = 0,
    }):Play()
    TweenService:Create(MiniBar, TweenInfo.new(0.2), {
        BackgroundColor3 = Colors.surfaceLight,
    }):Play()
    TweenService:Create(miniSep, TweenInfo.new(0.2), {
        BackgroundTransparency = 0.2,
        BackgroundColor3 = Colors.glowRed,
    }):Play()
end)
MiniBar.MouseLeave:Connect(function()
    TweenService:Create(miniStroke, TweenInfo.new(0.3), {
        Color = Colors.blood,
        Thickness = 1.5,
        Transparency = 0,
    }):Play()
    TweenService:Create(MiniBar, TweenInfo.new(0.3), {
        BackgroundColor3 = Colors.bg,
    }):Play()
    TweenService:Create(miniSep, TweenInfo.new(0.3), {
        BackgroundTransparency = 0.5,
        BackgroundColor3 = Colors.blood,
    }):Play()
end)

-- Click na MiniBar abre o scanner
MiniBar.MouseButton1Click:Connect(toggleScanner)
