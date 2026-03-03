--==================================================
-- VAMPIRE RIG SCANNER v13 - TAB SYSTEM + FULL FEATURES
-- Create By VampireSonata
-- Tabs: Scanner, ESP, Players, Movement, TP, Settings
-- ⚡ Bundled automaticamente — NÃO edite este arquivo!
-- ⚡ Edite os modulos em vampire-rigs/src/
--==================================================


--[[ ═══════ MODULE: 01_core.luau ═══════ ]]

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local LP = Players.LocalPlayer

--==================================================
-- CONFIG
--==================================================

local HOTKEY = Enum.KeyCode.G
local REQUIRE_CTRL = true
local LOAD_DELAY = 0.1

--==================================================
-- DEBUG
--==================================================

local function log(...)
    print("[VampScanner]", ...)
end

--==================================================
-- CRIAR UI
--==================================================

if LP.PlayerGui:FindFirstChild("VampireRigScanner") then
    LP.PlayerGui:FindFirstChild("VampireRigScanner"):Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VampireRigScanner"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = LP.PlayerGui

--==================================================
-- CORES
--==================================================

local Colors = {
    bg = Color3.fromRGB(12, 12, 14),
    topbar = Color3.fromRGB(22, 22, 26),
    content = Color3.fromRGB(8, 8, 10),
    card = Color3.fromRGB(18, 18, 22),
    cardLoaded = Color3.fromRGB(18, 28, 18),

    blood = Color3.fromRGB(139, 0, 0),
    bloodLight = Color3.fromRGB(180, 20, 20),
    bloodDark = Color3.fromRGB(100, 0, 0),

    green = Color3.fromRGB(40, 120, 40),
    greenLight = Color3.fromRGB(60, 150, 60),

    text = Color3.fromRGB(240, 240, 245),
    textDim = Color3.fromRGB(130, 130, 140),
    textBlood = Color3.fromRGB(200, 50, 50),
    textLoading = Color3.fromRGB(255, 200, 100),

    -- Premium palette
    accent = Color3.fromRGB(180, 20, 20),
    glowRed = Color3.fromRGB(220, 40, 40),
    glowPurple = Color3.fromRGB(120, 60, 180),
    surfaceLight = Color3.fromRGB(28, 28, 32),
    surfaceMid = Color3.fromRGB(22, 22, 26),
    separator = Color3.fromRGB(45, 20, 20),
    purple = Color3.fromRGB(80, 40, 120),
    purpleLight = Color3.fromRGB(110, 60, 160),
    warning = Color3.fromRGB(200, 150, 50),
    tabActive = Color3.fromRGB(139, 0, 0),
    tabInactive = Color3.fromRGB(28, 28, 32),
    inputBg = Color3.fromRGB(25, 25, 30),
    inputBorder = Color3.fromRGB(50, 50, 60),
}

--==================================================
-- VARIABLES
--==================================================

local currentPreviewData = nil
local previewConnection = nil
local allScannedRigs = {}
local isExporting = false

-- Tab system
local activeTab = "scanner"
local tabButtons = {}
local tabContents = {}

-- Auto-scan
local autoScanConfig = { enabled = true, interval = 5 }
local autoScanConnection = nil
local scannedPlayerSet = {}
local scannedNPCSet = {}

-- Spectate state
local spectatingInfo = nil
local spectateHighlight = nil
local savedCameraSubject = nil

-- ESP state
local espState = {
    players = false,
    npcs = false,
    cameras = false,
    healthBars = false,
    boxESP = false,
    chams = false,
}
local espConnection = nil
local espObjects = {}

-- Movement state
local movementState = {
    fly = false,
    noclip = false,
    infiniteJump = false,
    freecam = false,
    speed = 16,
    jumpPower = 50,
}
local flyConnection = nil
local flyBG = nil
local flyBV = nil
local noclipConnection = nil
local jumpConnection = nil
local freecamConnection = nil
local savedCameraState = nil
local speedConnection = nil

-- Teleport state
local waypoints = {}

-- Notification state
local notifContainer = nil
local notifCount = 0

-- Settings state
local saveConfigState = {
    DecompileMode = false,
    SavePlayers = false,
    RemovePlayerCharacters = true,
    NilInstances = false,
    SaveNonCreatable = false,
    IsolateLocalPlayer = false,
    SaveCameraInstances = false,
}

--==================================================
-- FORWARD DECLARATIONS
--==================================================

local startSpectate
local stopSpectate
local switchTab
local notify
local startAutoScan, stopAutoScan
local updateESP, clearESP, toggleESPFeature
local startFly, stopFly
local toggleNoclip, toggleInfiniteJump
local startFreecam, stopFreecam
local applySpeed
local addWaypoint, removeWaypoint, tpToWaypoint, refreshWaypointList
local tpToPart
local filterResults
local runScan, clearResults, createResultCard
local refreshPlayerList
local updateServerInfo

--==================================================
-- UI HELPERS
--==================================================

local function addGradient(frame, c1, c2, rotation)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new(c1 or Colors.surfaceLight, c2 or Colors.bg)
    g.Rotation = rotation or 90
    g.Parent = frame
    return g
end

local function addAccentLine(parent, position, color, size)
    local line = Instance.new("Frame")
    line.Name = "AccentLine"
    line.Size = size or UDim2.new(1, 0, 0, 1)
    line.Position = position or UDim2.new(0, 0, 1, 0)
    line.BackgroundColor3 = color or Colors.accent
    line.BackgroundTransparency = 0.3
    line.BorderSizePixel = 0
    line.Parent = parent
    local lineGrad = Instance.new("UIGradient")
    lineGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, color or Colors.accent),
        ColorSequenceKeypoint.new(0.5, color or Colors.accent),
        ColorSequenceKeypoint.new(1, Colors.bg),
    })
    lineGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(0.7, 0),
        NumberSequenceKeypoint.new(1, 1),
    })
    lineGrad.Parent = line
    return line
end

local function makeHoverable(btn, normalColor, hoverColor, pressColor)
    local hc = hoverColor or Color3.new(
        math.min(normalColor.R + 0.08, 1),
        math.min(normalColor.G + 0.08, 1),
        math.min(normalColor.B + 0.08, 1)
    )
    local pc = pressColor or Color3.new(
        math.max(normalColor.R - 0.05, 0),
        math.max(normalColor.G - 0.05, 0),
        math.max(normalColor.B - 0.05, 0)
    )
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {
            BackgroundColor3 = hc,
        }):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {
            BackgroundColor3 = normalColor,
        }):Play()
    end)
    btn.MouseButton1Down:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.05), {
            BackgroundColor3 = pc,
        }):Play()
    end)
    btn.MouseButton1Up:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {
            BackgroundColor3 = hc,
        }):Play()
    end)
end

local function addBtnGradient(btn)
    local g = Instance.new("UIGradient")
    g.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.15),
        NumberSequenceKeypoint.new(0.5, 0),
        NumberSequenceKeypoint.new(1, 0.2),
    })
    g.Rotation = 0
    g.Parent = btn
    return g
end

--==================================================
-- REUSABLE UI COMPONENTS
--==================================================

local function createSectionHeader(parent, text, yPos)
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 22)
    header.Position = UDim2.new(0, 0, 0, yPos)
    header.BackgroundTransparency = 1
    header.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Colors.bloodLight
    label.TextSize = 11
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = header

    addAccentLine(header, UDim2.new(0, 0, 1, -1), Colors.blood, UDim2.new(1, 0, 0, 1))

    return header
end

local function createVampToggle(parent, label, key, stateTable, yPos, accentColor)
    local ac = accentColor or Colors.green

    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 28)
    row.Position = UDim2.new(0, 0, 0, yPos)
    row.BackgroundTransparency = 1
    row.Parent = parent

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -55, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = Colors.textDim
    lbl.TextSize = 11
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 44, 0, 22)
    btn.Position = UDim2.new(1, -44, 0, 3)
    btn.TextSize = 10
    btn.Font = Enum.Font.GothamBold
    btn.AutoButtonColor = false
    btn.Parent = row
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local function refresh()
        local on = stateTable[key]
        btn.Text = on and "ON" or "OFF"
        local targetColor = on and ac or Color3.fromRGB(50, 25, 25)
        TweenService:Create(btn, TweenInfo.new(0.15), {
            BackgroundColor3 = targetColor,
        }):Play()
        btn.TextColor3 = Colors.text
    end

    local function getColor()
        return stateTable[key] and ac or Color3.fromRGB(50, 25, 25)
    end
    btn.MouseEnter:Connect(function()
        local base = getColor()
        TweenService:Create(btn, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.new(
                math.min(base.R + 0.06, 1),
                math.min(base.G + 0.06, 1),
                math.min(base.B + 0.06, 1)
            ),
        }):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {
            BackgroundColor3 = getColor(),
        }):Play()
    end)

    refresh()
    return { row = row, btn = btn, lbl = lbl, refresh = refresh }
end

local function createSliderRow(parent, label, min, max, default, yPos, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 28)
    row.Position = UDim2.new(0, 0, 0, yPos)
    row.BackgroundTransparency = 1
    row.Parent = parent

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0, 120, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = Colors.textDim
    lbl.TextSize = 11
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local minusBtn = Instance.new("TextButton")
    minusBtn.Size = UDim2.new(0, 24, 0, 22)
    minusBtn.Position = UDim2.new(1, -100, 0, 3)
    minusBtn.BackgroundColor3 = Colors.surfaceLight
    minusBtn.Text = "-"
    minusBtn.TextColor3 = Colors.text
    minusBtn.TextSize = 14
    minusBtn.Font = Enum.Font.GothamBold
    minusBtn.AutoButtonColor = false
    minusBtn.Parent = row
    Instance.new("UICorner", minusBtn).CornerRadius = UDim.new(0, 4)

    local valBox = Instance.new("TextBox")
    valBox.Size = UDim2.new(0, 44, 0, 22)
    valBox.Position = UDim2.new(1, -74, 0, 3)
    valBox.BackgroundColor3 = Colors.inputBg
    valBox.Text = tostring(default)
    valBox.TextColor3 = Colors.text
    valBox.TextSize = 11
    valBox.Font = Enum.Font.Code
    valBox.ClearTextOnFocus = true
    valBox.Parent = row
    Instance.new("UICorner", valBox).CornerRadius = UDim.new(0, 4)
    local valStroke = Instance.new("UIStroke", valBox)
    valStroke.Color = Colors.inputBorder
    valStroke.Thickness = 1

    local plusBtn = Instance.new("TextButton")
    plusBtn.Size = UDim2.new(0, 24, 0, 22)
    plusBtn.Position = UDim2.new(1, -28, 0, 3)
    plusBtn.BackgroundColor3 = Colors.surfaceLight
    plusBtn.Text = "+"
    plusBtn.TextColor3 = Colors.text
    plusBtn.TextSize = 14
    plusBtn.Font = Enum.Font.GothamBold
    plusBtn.AutoButtonColor = false
    plusBtn.Parent = row
    Instance.new("UICorner", plusBtn).CornerRadius = UDim.new(0, 4)

    local currentVal = default

    local function setValue(v)
        currentVal = math.clamp(math.floor(v), min, max)
        valBox.Text = tostring(currentVal)
        if callback then callback(currentVal) end
    end

    local step = math.max(1, math.floor((max - min) / 20))
    minusBtn.MouseButton1Click:Connect(function() setValue(currentVal - step) end)
    plusBtn.MouseButton1Click:Connect(function() setValue(currentVal + step) end)
    valBox.FocusLost:Connect(function()
        local n = tonumber(valBox.Text)
        if n then setValue(n) else valBox.Text = tostring(currentVal) end
    end)

    valBox.Focused:Connect(function()
        TweenService:Create(valStroke, TweenInfo.new(0.2), { Color = Colors.bloodLight, Thickness = 1.5 }):Play()
    end)
    valBox.FocusLost:Connect(function()
        TweenService:Create(valStroke, TweenInfo.new(0.3), { Color = Colors.inputBorder, Thickness = 1 }):Play()
    end)

    return { row = row, getValue = function() return currentVal end, setValue = setValue, valBox = valBox }
end


--[[ ═══════ MODULE: 02_notifications.luau ═══════ ]]

--==================================================
-- NOTIFICATION SYSTEM
--==================================================

notifContainer = Instance.new("Frame")
notifContainer.Name = "Notifications"
notifContainer.Size = UDim2.new(0, 280, 1, -20)
notifContainer.Position = UDim2.new(1, -290, 0, 10)
notifContainer.BackgroundTransparency = 1
notifContainer.Parent = ScreenGui

local notifLayout = Instance.new("UIListLayout", notifContainer)
notifLayout.Padding = UDim.new(0, 6)
notifLayout.VerticalAlignment = Enum.VerticalAlignment.Top
notifLayout.SortOrder = Enum.SortOrder.LayoutOrder

local notifTypeColors = {
    info = Colors.blood,
    success = Colors.green,
    warning = Colors.warning,
    error = Colors.glowRed,
}

local notifTypeIcons = {
    info = "🦇",
    success = "✅",
    warning = "⚠",
    error = "❌",
}

notify = function(text, notifType)
    notifType = notifType or "info"
    local color = notifTypeColors[notifType] or Colors.blood
    local icon = notifTypeIcons[notifType] or "🦇"

    notifCount = notifCount + 1

    -- Limita a 5 notificacoes visiveis
    local children = notifContainer:GetChildren()
    local frames = {}
    for _, c in ipairs(children) do
        if c:IsA("Frame") then table.insert(frames, c) end
    end
    if #frames >= 5 then
        frames[1]:Destroy()
    end

    local toast = Instance.new("Frame")
    toast.Name = "Notif_" .. notifCount
    toast.Size = UDim2.new(1, 0, 0, 40)
    toast.BackgroundColor3 = Colors.card
    toast.BorderSizePixel = 0
    toast.LayoutOrder = notifCount
    toast.BackgroundTransparency = 1
    toast.Parent = notifContainer
    Instance.new("UICorner", toast).CornerRadius = UDim.new(0, 8)
    addGradient(toast, Colors.surfaceLight, Colors.card, 0)

    local toastStroke = Instance.new("UIStroke", toast)
    toastStroke.Color = color
    toastStroke.Thickness = 1
    toastStroke.Transparency = 0.5

    -- Left accent bar
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0, 3, 1, -8)
    bar.Position = UDim2.new(0, 0, 0, 4)
    bar.BackgroundColor3 = color
    bar.BorderSizePixel = 0
    bar.Parent = toast
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 2)

    -- Icon
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Size = UDim2.new(0, 24, 0, 24)
    iconLabel.Position = UDim2.new(0, 8, 0, 8)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = icon
    iconLabel.TextSize = 14
    iconLabel.Parent = toast

    -- Text
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, -40, 1, 0)
    textLabel.Position = UDim2.new(0, 34, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text
    textLabel.TextColor3 = Colors.text
    textLabel.TextSize = 11
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.TextTruncate = Enum.TextTruncate.AtEnd
    textLabel.Parent = toast

    -- Slide in
    TweenService:Create(toast, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0,
    }):Play()

    -- Auto dismiss
    task.delay(3, function()
        if toast and toast.Parent then
            local fadeOut = TweenService:Create(toast, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                BackgroundTransparency = 1,
            })
            fadeOut:Play()
            fadeOut.Completed:Connect(function()
                if toast and toast.Parent then toast:Destroy() end
            end)
        end
    end)
end


--[[ ═══════ MODULE: 03_minibar.luau ═══════ ]]

--==================================================
-- MINI BAR (widget no canto)
--==================================================

local MiniBar = Instance.new("TextButton")
MiniBar.Name = "MiniBar"
MiniBar.Size = UDim2.new(0, 210, 0, 56)
MiniBar.Position = UDim2.new(1, 0, 1, -70) -- comeca fora da tela (direita)
MiniBar.BackgroundColor3 = Colors.bg
MiniBar.BorderSizePixel = 0
MiniBar.AutoButtonColor = false
MiniBar.Text = ""
MiniBar.Parent = ScreenGui
Instance.new("UICorner", MiniBar).CornerRadius = UDim.new(0, 12)
local miniStroke = Instance.new("UIStroke", MiniBar)
miniStroke.Color = Colors.blood
miniStroke.Thickness = 1.5
addGradient(MiniBar, Colors.surfaceLight, Colors.bg, 45)

-- Avatar thumbnail
local AvatarFrame = Instance.new("Frame")
AvatarFrame.Size = UDim2.new(0, 40, 0, 40)
AvatarFrame.Position = UDim2.new(0, 8, 0, 8)
AvatarFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
AvatarFrame.Parent = MiniBar
Instance.new("UICorner", AvatarFrame).CornerRadius = UDim.new(1, 0)
local avatarStroke = Instance.new("UIStroke", AvatarFrame)
avatarStroke.Color = Colors.blood
avatarStroke.Thickness = 1.5

local AvatarImg = Instance.new("ImageLabel")
AvatarImg.Size = UDim2.new(1, 0, 1, 0)
AvatarImg.BackgroundTransparency = 1
AvatarImg.Image = ""
AvatarImg.Parent = AvatarFrame
Instance.new("UICorner", AvatarImg).CornerRadius = UDim.new(1, 0)

-- Carrega avatar do LocalPlayer
task.spawn(function()
    local ok, thumb = pcall(function()
        return Players:GetUserThumbnailAsync(LP.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
    end)
    if ok and thumb then
        AvatarImg.Image = thumb
    end
end)

-- Separador vertical
local miniSep = Instance.new("Frame")
miniSep.Size = UDim2.new(0, 1, 0, 36)
miniSep.Position = UDim2.new(0, 52, 0, 10)
miniSep.BackgroundColor3 = Colors.blood
miniSep.BackgroundTransparency = 0.5
miniSep.BorderSizePixel = 0
miniSep.Parent = MiniBar

-- Nome do usuario
local MiniName = Instance.new("TextLabel")
MiniName.Size = UDim2.new(0, 140, 0, 16)
MiniName.Position = UDim2.new(0, 55, 0, 6)
MiniName.BackgroundTransparency = 1
MiniName.Text = LP.DisplayName
MiniName.TextColor3 = Colors.bloodLight
MiniName.TextSize = 12
MiniName.Font = Enum.Font.GothamBold
MiniName.TextXAlignment = Enum.TextXAlignment.Left
MiniName.TextTruncate = Enum.TextTruncate.AtEnd
MiniName.Parent = MiniBar

-- Titulo
local MiniTitle = Instance.new("TextLabel")
MiniTitle.Size = UDim2.new(0, 140, 0, 14)
MiniTitle.Position = UDim2.new(0, 55, 0, 22)
MiniTitle.BackgroundTransparency = 1
MiniTitle.Text = "🦇 Vampire Rigs v13"
MiniTitle.TextColor3 = Colors.textDim
MiniTitle.TextSize = 10
MiniTitle.Font = Enum.Font.GothamBold
MiniTitle.TextXAlignment = Enum.TextXAlignment.Left
MiniTitle.Parent = MiniBar

-- Hint
local MiniHint = Instance.new("TextLabel")
MiniHint.Size = UDim2.new(0, 140, 0, 12)
MiniHint.Position = UDim2.new(0, 55, 0, 38)
MiniHint.BackgroundTransparency = 1
MiniHint.Text = "Ctrl+G to open"
MiniHint.TextColor3 = Color3.fromRGB(80, 80, 80)
MiniHint.TextSize = 9
MiniHint.Font = Enum.Font.Gotham
MiniHint.TextXAlignment = Enum.TextXAlignment.Left
MiniHint.Parent = MiniBar

-- Icone morcego pulsante
local MiniBat = Instance.new("TextLabel")
MiniBat.Size = UDim2.new(0, 20, 0, 20)
MiniBat.Position = UDim2.new(1, -26, 0, 18)
MiniBat.BackgroundTransparency = 1
MiniBat.Text = "🦇"
MiniBat.TextSize = 16
MiniBat.Parent = MiniBar


--[[ ═══════ MODULE: 04_mainframe.luau ═══════ ]]

--==================================================
-- MAIN FRAME + TAB SYSTEM
--==================================================

local MainFrame = Instance.new("Frame")
MainFrame.Name = "Main"
MainFrame.Size = UDim2.new(0, 420, 0, 560)
MainFrame.Position = UDim2.new(0.3, 0, 0.5, -280)
MainFrame.BackgroundColor3 = Colors.bg
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local mainStroke = Instance.new("UIStroke", MainFrame)
mainStroke.Color = Colors.blood
mainStroke.Thickness = 1.2
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
addGradient(MainFrame, Colors.surfaceLight, Color3.fromRGB(8, 8, 10), 90)

--==================================================
-- TOP BAR
--==================================================

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Colors.topbar
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 10)
addGradient(TopBar, Color3.fromRGB(40, 8, 8), Colors.topbar, 0)

local TopBarFix = Instance.new("Frame")
TopBarFix.Size = UDim2.new(1, 0, 0, 10)
TopBarFix.Position = UDim2.new(0, 0, 1, -10)
TopBarFix.BackgroundColor3 = Colors.topbar
TopBarFix.BorderSizePixel = 0
TopBarFix.Parent = TopBar

addAccentLine(TopBar, UDim2.new(0, 0, 1, -1), Colors.blood)

local VampIcon = Instance.new("TextLabel")
VampIcon.Size = UDim2.new(0, 30, 0, 30)
VampIcon.Position = UDim2.new(0, 8, 0, 5)
VampIcon.BackgroundTransparency = 1
VampIcon.Text = "🦇"
VampIcon.TextSize = 20
VampIcon.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -100, 1, 0)
Title.Position = UDim2.new(0, 40, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Vampire Rig Scanner"
Title.TextColor3 = Colors.bloodLight
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Position = UDim2.new(1, -32, 0, 7)
CloseBtn.BackgroundColor3 = Colors.blood
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Colors.text
CloseBtn.TextSize = 14
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.AutoButtonColor = false
CloseBtn.Parent = TopBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)
makeHoverable(CloseBtn, Colors.blood, Colors.glowRed)

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 25, 0, 25)
MinBtn.Position = UDim2.new(1, -62, 0, 7)
MinBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
MinBtn.Text = "-"
MinBtn.TextColor3 = Colors.text
MinBtn.TextSize = 18
MinBtn.Font = Enum.Font.GothamBold
MinBtn.AutoButtonColor = false
MinBtn.Parent = TopBar
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)
makeHoverable(MinBtn, Color3.fromRGB(50, 50, 50), Color3.fromRGB(70, 70, 70))

--==================================================
-- TAB BAR
--==================================================

local TabBar = Instance.new("Frame")
TabBar.Name = "TabBar"
TabBar.Size = UDim2.new(1, 0, 0, 34)
TabBar.Position = UDim2.new(0, 0, 0, 40)
TabBar.BackgroundColor3 = Colors.topbar
TabBar.BorderSizePixel = 0
TabBar.Parent = MainFrame
addAccentLine(TabBar, UDim2.new(0, 0, 1, -1), Colors.blood)

local tabDefs = {
    { id = "scanner",  icon = "🔍", label = "Scan" },
    { id = "esp",      icon = "👁",  label = "ESP" },
    { id = "player",   icon = "👤", label = "Players" },
    { id = "movement", icon = "🏃", label = "Move" },
    { id = "teleport", icon = "📍", label = "TP" },
    { id = "settings", icon = "⚙",  label = "Config" },
}

local tabBarLayout = Instance.new("UIListLayout", TabBar)
tabBarLayout.FillDirection = Enum.FillDirection.Horizontal
tabBarLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabBarLayout.Padding = UDim.new(0, 0)

for i, def in ipairs(tabDefs) do
    local tabBtn = Instance.new("TextButton")
    tabBtn.Name = "Tab_" .. def.id
    tabBtn.Size = UDim2.new(1 / #tabDefs, 0, 1, 0)
    tabBtn.LayoutOrder = i
    tabBtn.BackgroundColor3 = Colors.tabInactive
    tabBtn.BackgroundTransparency = 0.5
    tabBtn.Text = def.icon .. " " .. def.label
    tabBtn.TextColor3 = Colors.textDim
    tabBtn.TextSize = 10
    tabBtn.Font = Enum.Font.GothamBold
    tabBtn.AutoButtonColor = false
    tabBtn.BorderSizePixel = 0
    tabBtn.Parent = TabBar

    -- Active indicator line (bottom of tab)
    local indicator = Instance.new("Frame")
    indicator.Name = "Indicator"
    indicator.Size = UDim2.new(0.8, 0, 0, 2)
    indicator.Position = UDim2.new(0.1, 0, 1, -3)
    indicator.BackgroundColor3 = Colors.blood
    indicator.BorderSizePixel = 0
    indicator.Visible = false
    indicator.Parent = tabBtn
    Instance.new("UICorner", indicator).CornerRadius = UDim.new(0, 1)

    tabButtons[def.id] = { btn = tabBtn, indicator = indicator, def = def }

    tabBtn.MouseButton1Click:Connect(function()
        switchTab(def.id)
    end)
end

--==================================================
-- TAB CONTENT CONTAINER
--==================================================

local TabContent = Instance.new("Frame")
TabContent.Name = "TabContent"
TabContent.Size = UDim2.new(1, -16, 1, -107) -- 40 topbar + 34 tabbar + 8 pad + 25 footer
TabContent.Position = UDim2.new(0, 8, 0, 78)
TabContent.BackgroundTransparency = 1
TabContent.BorderSizePixel = 0
TabContent.Parent = MainFrame

--==================================================
-- FOOTER
--==================================================

local Footer = Instance.new("Frame")
Footer.Size = UDim2.new(1, 0, 0, 25)
Footer.Position = UDim2.new(0, 0, 1, -25)
Footer.BackgroundColor3 = Colors.topbar
Footer.BorderSizePixel = 0
Footer.Parent = MainFrame
Instance.new("UICorner", Footer).CornerRadius = UDim.new(0, 10)
addAccentLine(Footer, UDim2.new(0, 0, 0, 0), Colors.blood)

local Credits = Instance.new("TextLabel")
Credits.Size = UDim2.new(1, 0, 1, 0)
Credits.BackgroundTransparency = 1
Credits.Text = "🦇 Create By VampireSonata 🦇"
Credits.TextColor3 = Colors.textBlood
Credits.TextSize = 11
Credits.Font = Enum.Font.GothamBold
Credits.Parent = Footer

--==================================================
-- SWITCH TAB
--==================================================

switchTab = function(tabId)
    activeTab = tabId

    -- Update tab buttons
    for id, data in pairs(tabButtons) do
        local isActive = (id == tabId)
        data.btn.BackgroundTransparency = isActive and 0 or 0.5
        data.btn.BackgroundColor3 = isActive and Colors.tabActive or Colors.tabInactive
        data.btn.TextColor3 = isActive and Colors.text or Colors.textDim
        data.indicator.Visible = isActive
    end

    -- Update tab content visibility
    for id, content in pairs(tabContents) do
        content.Visible = (id == tabId)
    end
end


--[[ ═══════ MODULE: 05_tab_scanner.luau ═══════ ]]

--==================================================
-- TAB: SCANNER
--==================================================

local ScannerContent = Instance.new("Frame")
ScannerContent.Name = "ScannerContent"
ScannerContent.Size = UDim2.new(1, 0, 1, 0)
ScannerContent.BackgroundTransparency = 1
ScannerContent.Parent = TabContent
tabContents["scanner"] = ScannerContent

-- Search bar
local SearchBar = Instance.new("TextBox")
SearchBar.Name = "SearchBar"
SearchBar.Size = UDim2.new(1, 0, 0, 28)
SearchBar.Position = UDim2.new(0, 0, 0, 0)
SearchBar.BackgroundColor3 = Colors.inputBg
SearchBar.Text = ""
SearchBar.PlaceholderText = "🔍 Search rigs..."
SearchBar.TextColor3 = Colors.text
SearchBar.PlaceholderColor3 = Colors.textDim
SearchBar.TextSize = 11
SearchBar.Font = Enum.Font.Gotham
SearchBar.ClearTextOnFocus = false
SearchBar.Parent = ScannerContent
Instance.new("UICorner", SearchBar).CornerRadius = UDim.new(0, 6)
local searchStroke = Instance.new("UIStroke", SearchBar)
searchStroke.Color = Colors.inputBorder
searchStroke.Thickness = 1

SearchBar.Focused:Connect(function()
    TweenService:Create(searchStroke, TweenInfo.new(0.2), { Color = Colors.bloodLight, Thickness = 1.5 }):Play()
end)
SearchBar.FocusLost:Connect(function()
    TweenService:Create(searchStroke, TweenInfo.new(0.3), { Color = Colors.inputBorder, Thickness = 1 }):Play()
end)

-- Control row: Auto-scan toggle + Scan button
local ControlRow = Instance.new("Frame")
ControlRow.Size = UDim2.new(1, 0, 0, 30)
ControlRow.Position = UDim2.new(0, 0, 0, 32)
ControlRow.BackgroundTransparency = 1
ControlRow.Parent = ScannerContent

local AutoScanToggle = createVampToggle(ControlRow, "Auto-Scan", "enabled", autoScanConfig, 0, Colors.green)

local ScanBtn = Instance.new("TextButton")
ScanBtn.Size = UDim2.new(1, 0, 0, 30)
ScanBtn.Position = UDim2.new(0, 0, 0, 64)
ScanBtn.BackgroundColor3 = Colors.blood
ScanBtn.Text = "🩸 SCAN"
ScanBtn.TextColor3 = Colors.text
ScanBtn.TextSize = 13
ScanBtn.Font = Enum.Font.GothamBold
ScanBtn.AutoButtonColor = false
ScanBtn.Parent = ScannerContent
Instance.new("UICorner", ScanBtn).CornerRadius = UDim.new(0, 6)
addBtnGradient(ScanBtn)
makeHoverable(ScanBtn, Colors.blood, Colors.glowRed)

-- Export + count row
local ExportBtn = Instance.new("TextButton")
ExportBtn.Size = UDim2.new(0.5, -3, 0, 26)
ExportBtn.Position = UDim2.new(0, 0, 0, 98)
ExportBtn.BackgroundColor3 = Colors.bloodDark
ExportBtn.Text = "🦇 EXPORT ALL"
ExportBtn.TextColor3 = Colors.text
ExportBtn.TextSize = 11
ExportBtn.Font = Enum.Font.GothamBold
ExportBtn.AutoButtonColor = false
ExportBtn.Parent = ScannerContent
Instance.new("UICorner", ExportBtn).CornerRadius = UDim.new(0, 6)
addBtnGradient(ExportBtn)
makeHoverable(ExportBtn, Colors.bloodDark, Colors.blood)

local CountLabel = Instance.new("TextLabel")
CountLabel.Size = UDim2.new(0.5, -3, 0, 26)
CountLabel.Position = UDim2.new(0.5, 3, 0, 98)
CountLabel.BackgroundTransparency = 1
CountLabel.Text = "0P | 0N"
CountLabel.TextColor3 = Colors.textDim
CountLabel.TextSize = 11
CountLabel.Font = Enum.Font.GothamBold
CountLabel.TextXAlignment = Enum.TextXAlignment.Right
CountLabel.Parent = ScannerContent

-- Result scroll area
local ResultScroll = Instance.new("ScrollingFrame")
ResultScroll.Name = "ResultScroll"
ResultScroll.Size = UDim2.new(1, 0, 1, -162)
ResultScroll.Position = UDim2.new(0, 0, 0, 128)
ResultScroll.BackgroundColor3 = Colors.content
ResultScroll.BorderSizePixel = 0
ResultScroll.ScrollBarThickness = 4
ResultScroll.ScrollBarImageColor3 = Colors.blood
ResultScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
ResultScroll.Parent = ScannerContent
Instance.new("UICorner", ResultScroll).CornerRadius = UDim.new(0, 6)
local resultStroke = Instance.new("UIStroke", ResultScroll)
resultStroke.Color = Colors.separator
resultStroke.Thickness = 0.5
resultStroke.Transparency = 0.5

local ResultLayout = Instance.new("UIListLayout")
ResultLayout.Padding = UDim.new(0, 5)
ResultLayout.Parent = ResultScroll
local resultPad = Instance.new("UIPadding", ResultScroll)
resultPad.PaddingTop = UDim.new(0, 4)
resultPad.PaddingLeft = UDim.new(0, 4)
resultPad.PaddingRight = UDim.new(0, 4)

-- Unspectate button (hidden by default)
local UnspectateBtn = Instance.new("TextButton")
UnspectateBtn.Size = UDim2.new(1, 0, 0, 26)
UnspectateBtn.Position = UDim2.new(0, 0, 1, -28)
UnspectateBtn.BackgroundColor3 = Colors.blood
UnspectateBtn.Text = "🦇 UNSPECTATE"
UnspectateBtn.TextColor3 = Colors.text
UnspectateBtn.TextSize = 11
UnspectateBtn.Font = Enum.Font.GothamBold
UnspectateBtn.AutoButtonColor = false
UnspectateBtn.Visible = false
UnspectateBtn.Parent = ScannerContent
Instance.new("UICorner", UnspectateBtn).CornerRadius = UDim.new(0, 6)
addBtnGradient(UnspectateBtn)
makeHoverable(UnspectateBtn, Colors.blood, Colors.glowRed)


--[[ ═══════ MODULE: 06_tab_esp.luau ═══════ ]]

--==================================================
-- TAB: ESP
--==================================================

local ESPContent = Instance.new("Frame")
ESPContent.Name = "ESPContent"
ESPContent.Size = UDim2.new(1, 0, 1, 0)
ESPContent.BackgroundTransparency = 1
ESPContent.Visible = false
ESPContent.Parent = TabContent
tabContents["esp"] = ESPContent

-- Scroll container
local ESPScroll = Instance.new("ScrollingFrame")
ESPScroll.Size = UDim2.new(1, 0, 1, 0)
ESPScroll.BackgroundTransparency = 1
ESPScroll.ScrollBarThickness = 3
ESPScroll.ScrollBarImageColor3 = Colors.blood
ESPScroll.CanvasSize = UDim2.new(0, 0, 0, 340)
ESPScroll.BorderSizePixel = 0
ESPScroll.Parent = ESPContent

createSectionHeader(ESPScroll, "Players & NPCs", 0)

local espToggles = {}

espToggles.players = createVampToggle(ESPScroll, "Player ESP", "players", espState, 26, Colors.bloodLight)
espToggles.npcs = createVampToggle(ESPScroll, "NPC ESP", "npcs", espState, 56, Colors.green)
espToggles.cameras = createVampToggle(ESPScroll, "Camera ESP", "cameras", espState, 86, Colors.warning)

createSectionHeader(ESPScroll, "Visual Extras", 120)

espToggles.healthBars = createVampToggle(ESPScroll, "Health Bars", "healthBars", espState, 146, Colors.bloodLight)
espToggles.boxESP = createVampToggle(ESPScroll, "Box Highlight", "boxESP", espState, 176, Colors.glowPurple)
espToggles.chams = createVampToggle(ESPScroll, "Chams (Fill)", "chams", espState, 206, Colors.glowRed)

createSectionHeader(ESPScroll, "Info", 244)

local ESPStatusLabel = Instance.new("TextLabel")
ESPStatusLabel.Size = UDim2.new(1, 0, 0, 20)
ESPStatusLabel.Position = UDim2.new(0, 0, 0, 270)
ESPStatusLabel.BackgroundTransparency = 1
ESPStatusLabel.Text = "ESP OFF — toggle features above"
ESPStatusLabel.TextColor3 = Colors.textDim
ESPStatusLabel.TextSize = 11
ESPStatusLabel.Font = Enum.Font.Gotham
ESPStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
ESPStatusLabel.Parent = ESPScroll

-- Master OFF button
local ESPOffBtn = Instance.new("TextButton")
ESPOffBtn.Size = UDim2.new(1, 0, 0, 28)
ESPOffBtn.Position = UDim2.new(0, 0, 0, 300)
ESPOffBtn.BackgroundColor3 = Colors.bloodDark
ESPOffBtn.Text = "🔴 DISABLE ALL ESP"
ESPOffBtn.TextColor3 = Colors.text
ESPOffBtn.TextSize = 11
ESPOffBtn.Font = Enum.Font.GothamBold
ESPOffBtn.AutoButtonColor = false
ESPOffBtn.Parent = ESPScroll
Instance.new("UICorner", ESPOffBtn).CornerRadius = UDim.new(0, 6)
addBtnGradient(ESPOffBtn)
makeHoverable(ESPOffBtn, Colors.bloodDark, Colors.blood)


--[[ ═══════ MODULE: 07_tab_player.luau ═══════ ]]

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


--[[ ═══════ MODULE: 08_tab_movement.luau ═══════ ]]

--==================================================
-- TAB: MOVEMENT
--==================================================

local MovementContent = Instance.new("Frame")
MovementContent.Name = "MovementContent"
MovementContent.Size = UDim2.new(1, 0, 1, 0)
MovementContent.BackgroundTransparency = 1
MovementContent.Visible = false
MovementContent.Parent = TabContent
tabContents["movement"] = MovementContent

-- Scroll container
local MoveScroll = Instance.new("ScrollingFrame")
MoveScroll.Size = UDim2.new(1, 0, 1, 0)
MoveScroll.BackgroundTransparency = 1
MoveScroll.ScrollBarThickness = 3
MoveScroll.ScrollBarImageColor3 = Colors.blood
MoveScroll.CanvasSize = UDim2.new(0, 0, 0, 320)
MoveScroll.BorderSizePixel = 0
MoveScroll.Parent = MovementContent

createSectionHeader(MoveScroll, "Movement", 0)

local moveToggles = {}

moveToggles.fly = createVampToggle(MoveScroll, "Fly (WASD+Space/Shift)", "fly", movementState, 26, Colors.glowPurple)
moveToggles.noclip = createVampToggle(MoveScroll, "Noclip (Walk Through)", "noclip", movementState, 56, Colors.warning)
moveToggles.infiniteJump = createVampToggle(MoveScroll, "Infinite Jump", "infiniteJump", movementState, 86, Colors.green)

createSectionHeader(MoveScroll, "Speed", 120)

local speedSlider = createSliderRow(MoveScroll, "Walk Speed", 1, 500, 16, 146, function(val)
    movementState.speed = val
    if applySpeed then applySpeed() end
end)

local jumpSlider = createSliderRow(MoveScroll, "Jump Power", 0, 300, 50, 178, function(val)
    movementState.jumpPower = val
    if applySpeed then applySpeed() end
end)

createSectionHeader(MoveScroll, "Camera", 214)

moveToggles.freecam = createVampToggle(MoveScroll, "Freecam (Detach Camera)", "freecam", movementState, 240, Colors.bloodLight)

-- Reset button
local ResetMoveBtn = Instance.new("TextButton")
ResetMoveBtn.Size = UDim2.new(1, 0, 0, 28)
ResetMoveBtn.Position = UDim2.new(0, 0, 0, 280)
ResetMoveBtn.BackgroundColor3 = Colors.bloodDark
ResetMoveBtn.Text = "🔴 RESET ALL"
ResetMoveBtn.TextColor3 = Colors.text
ResetMoveBtn.TextSize = 11
ResetMoveBtn.Font = Enum.Font.GothamBold
ResetMoveBtn.AutoButtonColor = false
ResetMoveBtn.Parent = MoveScroll
Instance.new("UICorner", ResetMoveBtn).CornerRadius = UDim.new(0, 6)
addBtnGradient(ResetMoveBtn)
makeHoverable(ResetMoveBtn, Colors.bloodDark, Colors.blood)


--[[ ═══════ MODULE: 09_tab_teleport.luau ═══════ ]]

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


--[[ ═══════ MODULE: 10_tab_settings.luau ═══════ ]]

--==================================================
-- TAB: SETTINGS
--==================================================

local SettingsContent = Instance.new("Frame")
SettingsContent.Name = "SettingsContent"
SettingsContent.Size = UDim2.new(1, 0, 1, 0)
SettingsContent.BackgroundTransparency = 1
SettingsContent.Visible = false
SettingsContent.Parent = TabContent
tabContents["settings"] = SettingsContent

-- Scroll container
local SettingsScroll = Instance.new("ScrollingFrame")
SettingsScroll.Size = UDim2.new(1, 0, 1, 0)
SettingsScroll.BackgroundTransparency = 1
SettingsScroll.ScrollBarThickness = 3
SettingsScroll.ScrollBarImageColor3 = Colors.blood
SettingsScroll.CanvasSize = UDim2.new(0, 0, 0, 540)
SettingsScroll.BorderSizePixel = 0
SettingsScroll.Parent = SettingsContent

--==================================================
-- AUTO-SCAN SETTINGS
--==================================================

createSectionHeader(SettingsScroll, "Auto-Scan", 0)

local autoScanSettingToggle = createVampToggle(SettingsScroll, "Auto-Scan Enabled", "enabled", autoScanConfig, 26, Colors.green)

local autoScanIntervalSlider = createSliderRow(SettingsScroll, "Interval (sec)", 3, 30, autoScanConfig.interval, 56, function(val)
    autoScanConfig.interval = val
end)

--==================================================
-- HOTKEY INFO
--==================================================

createSectionHeader(SettingsScroll, "Hotkey", 92)

local hotkeyLabel = Instance.new("TextLabel")
hotkeyLabel.Size = UDim2.new(1, 0, 0, 20)
hotkeyLabel.Position = UDim2.new(0, 0, 0, 118)
hotkeyLabel.BackgroundTransparency = 1
hotkeyLabel.Text = "Ctrl+G — Toggle Scanner"
hotkeyLabel.TextColor3 = Colors.textDim
hotkeyLabel.TextSize = 11
hotkeyLabel.Font = Enum.Font.Gotham
hotkeyLabel.TextXAlignment = Enum.TextXAlignment.Left
hotkeyLabel.Parent = SettingsScroll

--==================================================
-- SAVE INSTANCE
--==================================================

createSectionHeader(SettingsScroll, "Save Instance", 144)

local FileNameLabel = Instance.new("TextLabel")
FileNameLabel.Size = UDim2.new(1, 0, 0, 16)
FileNameLabel.Position = UDim2.new(0, 0, 0, 170)
FileNameLabel.BackgroundTransparency = 1
FileNameLabel.Text = "File name:"
FileNameLabel.TextColor3 = Colors.textDim
FileNameLabel.TextSize = 11
FileNameLabel.Font = Enum.Font.GothamBold
FileNameLabel.TextXAlignment = Enum.TextXAlignment.Left
FileNameLabel.Parent = SettingsScroll

local FileNameBox = Instance.new("TextBox")
FileNameBox.Size = UDim2.new(1, 0, 0, 28)
FileNameBox.Position = UDim2.new(0, 0, 0, 188)
FileNameBox.BackgroundColor3 = Colors.inputBg
FileNameBox.Text = ""
FileNameBox.PlaceholderText = "auto: PlaceId_Date"
FileNameBox.TextColor3 = Colors.text
FileNameBox.PlaceholderColor3 = Colors.textDim
FileNameBox.TextSize = 11
FileNameBox.Font = Enum.Font.Code
FileNameBox.ClearTextOnFocus = false
FileNameBox.Parent = SettingsScroll
Instance.new("UICorner", FileNameBox).CornerRadius = UDim.new(0, 6)
local fileBoxStroke = Instance.new("UIStroke", FileNameBox)
fileBoxStroke.Color = Colors.inputBorder
fileBoxStroke.Thickness = 1

FileNameBox.Focused:Connect(function()
    TweenService:Create(fileBoxStroke, TweenInfo.new(0.2), { Color = Colors.purpleLight, Thickness = 1.5 }):Play()
end)
FileNameBox.FocusLost:Connect(function()
    TweenService:Create(fileBoxStroke, TweenInfo.new(0.3), { Color = Colors.inputBorder, Thickness = 1 }):Play()
end)

-- Save toggles
local saveY = 224
local saveToggles = {}

local saveToggleDefs = {
    { label = "Decompile Scripts", key = "DecompileMode" },
    { label = "Save Players", key = "SavePlayers" },
    { label = "Remove Characters", key = "RemovePlayerCharacters" },
    { label = "Nil Instances", key = "NilInstances" },
    { label = "Non-Creatable", key = "SaveNonCreatable" },
    { label = "Isolate LocalPlayer", key = "IsolateLocalPlayer" },
    { label = "Camera Instances", key = "SaveCameraInstances" },
}

for i, def in ipairs(saveToggleDefs) do
    saveToggles[def.key] = createVampToggle(SettingsScroll, def.label, def.key, saveConfigState, saveY + (i - 1) * 30, Colors.purple)
end

-- Save buttons
local saveBtnY = saveY + #saveToggleDefs * 30 + 8

local ConfirmSaveBtn = Instance.new("TextButton")
ConfirmSaveBtn.Size = UDim2.new(0.5, -3, 0, 32)
ConfirmSaveBtn.Position = UDim2.new(0, 0, 0, saveBtnY)
ConfirmSaveBtn.BackgroundColor3 = Colors.purple
ConfirmSaveBtn.Text = "💾 SAVE"
ConfirmSaveBtn.TextColor3 = Colors.text
ConfirmSaveBtn.TextSize = 12
ConfirmSaveBtn.Font = Enum.Font.GothamBold
ConfirmSaveBtn.AutoButtonColor = false
ConfirmSaveBtn.Parent = SettingsScroll
Instance.new("UICorner", ConfirmSaveBtn).CornerRadius = UDim.new(0, 6)
addBtnGradient(ConfirmSaveBtn)
makeHoverable(ConfirmSaveBtn, Colors.purple, Colors.purpleLight)

local SaveAllBtn = Instance.new("TextButton")
SaveAllBtn.Size = UDim2.new(0.5, -3, 0, 32)
SaveAllBtn.Position = UDim2.new(0.5, 3, 0, saveBtnY)
SaveAllBtn.BackgroundColor3 = Colors.green
SaveAllBtn.Text = "⚡ SAVE ALL"
SaveAllBtn.TextColor3 = Colors.text
SaveAllBtn.TextSize = 12
SaveAllBtn.Font = Enum.Font.GothamBold
SaveAllBtn.AutoButtonColor = false
SaveAllBtn.Parent = SettingsScroll
Instance.new("UICorner", SaveAllBtn).CornerRadius = UDim.new(0, 6)
addBtnGradient(SaveAllBtn)
makeHoverable(SaveAllBtn, Colors.green, Colors.greenLight)

--==================================================
-- ABOUT
--==================================================

createSectionHeader(SettingsScroll, "About", saveBtnY + 42)

local aboutLabel = Instance.new("TextLabel")
aboutLabel.Size = UDim2.new(1, 0, 0, 40)
aboutLabel.Position = UDim2.new(0, 0, 0, saveBtnY + 68)
aboutLabel.BackgroundTransparency = 1
aboutLabel.Text = "🦇 Vampire Rig Scanner v13\nCreate By VampireSonata"
aboutLabel.TextColor3 = Colors.textBlood
aboutLabel.TextSize = 11
aboutLabel.Font = Enum.Font.GothamBold
aboutLabel.TextXAlignment = Enum.TextXAlignment.Left
aboutLabel.TextWrapped = true
aboutLabel.Parent = SettingsScroll


--[[ ═══════ MODULE: 11_preview_ui.luau ═══════ ]]

--==================================================
-- PREVIEW WINDOW
--==================================================

local PreviewFrame = Instance.new("Frame")
PreviewFrame.Name = "Preview"
PreviewFrame.Size = UDim2.new(0, 320, 0, 550)
PreviewFrame.Position = UDim2.new(0.3, 430, 0.5, -275)
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


--[[ ═══════ MODULE: 12_helpers.luau ═══════ ]]

--==================================================
-- HELPERS
--==================================================

local function color3ToTable(c3)
    return { R = c3.R, G = c3.G, B = c3.B }
end

local function tableToColor3(t)
    if not t then return Color3.new(1, 1, 1) end
    return Color3.new(t.R or 1, t.G or 1, t.B or 1)
end

local AccessoryTypeMap = {
    [Enum.AccessoryType.Unknown] = "Unknown",
    [Enum.AccessoryType.Hat] = "Hat",
    [Enum.AccessoryType.Hair] = "Hair",
    [Enum.AccessoryType.Face] = "Face",
    [Enum.AccessoryType.Neck] = "Neck",
    [Enum.AccessoryType.Shoulder] = "Shoulder",
    [Enum.AccessoryType.Front] = "Front",
    [Enum.AccessoryType.Back] = "Back",
    [Enum.AccessoryType.Waist] = "Waist",
    [Enum.AccessoryType.TShirt] = "TShirt",
    [Enum.AccessoryType.Shirt] = "Shirt",
    [Enum.AccessoryType.Pants] = "Pants",
    [Enum.AccessoryType.Jacket] = "Jacket",
    [Enum.AccessoryType.Sweater] = "Sweater",
    [Enum.AccessoryType.Shorts] = "Shorts",
    [Enum.AccessoryType.LeftShoe] = "LeftShoe",
    [Enum.AccessoryType.RightShoe] = "RightShoe",
    [Enum.AccessoryType.DressSkirt] = "DressSkirt",
    [Enum.AccessoryType.Eyebrow] = "Eyebrow",
    [Enum.AccessoryType.Eyelash] = "Eyelash",
}

local function accessoryTypeToString(enumValue)
    return AccessoryTypeMap[enumValue] or tostring(enumValue):match("%.(%w+)$") or "Unknown"
end


--[[ ═══════ MODULE: 13_scanner_logic.luau ═══════ ]]

--==================================================
-- EXTRACT DESCRIPTION (pega o objeto HumanoidDescription)
--==================================================

local function getHumanoidDescription(humanoid)
    local success, desc = pcall(function()
        return humanoid:GetAppliedDescription()
    end)
    return success and desc or nil
end

-- Helper: tenta ler propriedade com pcall isolado
local function safeGet(obj, prop)
    local ok, val = pcall(function() return obj[prop] end)
    return ok and val or nil
end

-- Extrai dados para JSON (cada propriedade isolada pra nao derrubar as outras)
local function extractDescriptionData(desc, rigType)
    if not desc then return nil end

    local data = {}
    local capturado = {}
    local falhou = {}

    data.RigType = rigType or "R15"

    -- Roupas
    for _, prop in ipairs({"Shirt", "Pants", "GraphicTShirt", "Face"}) do
        local val = safeGet(desc, prop)
        if val ~= nil then
            data[prop] = val
            table.insert(capturado, prop)
        else
            table.insert(falhou, prop)
        end
    end

    -- Body parts
    for _, prop in ipairs({"Head", "Torso", "LeftArm", "RightArm", "LeftLeg", "RightLeg"}) do
        local val = safeGet(desc, prop)
        if val ~= nil then
            data[prop] = val
            table.insert(capturado, prop)
        else
            table.insert(falhou, prop)
        end
    end

    -- Cores
    for _, prop in ipairs({"HeadColor", "TorsoColor", "LeftArmColor", "RightArmColor", "LeftLegColor", "RightLegColor"}) do
        local val = safeGet(desc, prop)
        if val ~= nil then
            data[prop] = color3ToTable(val)
            table.insert(capturado, prop)
        else
            table.insert(falhou, prop)
        end
    end

    -- Escalas
    for _, prop in ipairs({"BodyTypeScale", "DepthScale", "HeadScale", "HeightScale", "ProportionScale", "WidthScale"}) do
        local val = safeGet(desc, prop)
        if val ~= nil then
            data[prop] = val
            table.insert(capturado, prop)
        else
            table.insert(falhou, prop)
        end
    end

    -- Propriedades legacy de acessorios
    for _, prop in ipairs({
        "HatAccessory", "HairAccessory", "FaceAccessory",
        "NeckAccessory", "ShouldersAccessory", "FrontAccessory",
        "BackAccessory", "WaistAccessory",
    }) do
        local val = safeGet(desc, prop)
        if val ~= nil and val ~= "" then
            data[prop] = val
            table.insert(capturado, prop)
        end
    end

    -- Accessories via GetAccessories
    local accOk, accErr = pcall(function()
        local accessories = desc:GetAccessories(true)
        data.Accessories = {}
        for _, acc in ipairs(accessories) do
            table.insert(data.Accessories, {
                AssetId = acc.AssetId,
                AccessoryType = accessoryTypeToString(acc.AccessoryType),
                Order = acc.Order,
                Puffiness = acc.Puffiness,
                IsLayered = acc.IsLayered,
            })
        end
    end)
    if accOk then
        table.insert(capturado, "Accessories(" .. #(data.Accessories or {}) .. ")")
    else
        table.insert(falhou, "Accessories: " .. tostring(accErr))
    end

    -- AccessoryBlob
    if gethiddenproperty then
        local ok, blob = pcall(function()
            return gethiddenproperty(desc, "AccessoryBlob")
        end)
        if ok and blob and type(blob) == "string" and blob ~= "" then
            data.AccessoryBlob = blob
            table.insert(capturado, "AccessoryBlob(" .. #blob .. " chars)")
        else
            table.insert(falhou, "AccessoryBlob(gethiddenproperty: " .. tostring(blob) .. ")")
        end
    end

    -- AccessoryDescriptions
    local adjOk, adjErr = pcall(function()
        local accDescriptions = {}
        for _, child in ipairs(desc:GetChildren()) do
            if child:IsA("AccessoryDescription") and child.AssetId and child.AssetId > 0 then
                local pos = child.Position
                local rot = child.Rotation
                local scl = child.Scale

                local posChanged = pos.X ~= 0 or pos.Y ~= 0 or pos.Z ~= 0
                local rotChanged = rot.X ~= 0 or rot.Y ~= 0 or rot.Z ~= 0
                local sclChanged = scl.X ~= 1 or scl.Y ~= 1 or scl.Z ~= 1

                if posChanged or rotChanged or sclChanged then
                    local entry: any = { AssetId = child.AssetId }
                    if posChanged then entry.Position = { pos.X, pos.Y, pos.Z } end
                    if rotChanged then entry.Rotation = { rot.X, rot.Y, rot.Z } end
                    if sclChanged then entry.Scale = { scl.X, scl.Y, scl.Z } end
                    table.insert(accDescriptions, entry)
                end
            end
        end
        if #accDescriptions > 0 then
            data.AccessoryDescriptions = accDescriptions
        end
    end)
    if adjOk and data.AccessoryDescriptions then
        table.insert(capturado, "AccessoryDescriptions(" .. #data.AccessoryDescriptions .. ")")
    elseif not adjOk then
        table.insert(falhou, "AccessoryDescriptions: " .. tostring(adjErr))
    end

    log("  CAPTURADO:", table.concat(capturado, ", "))
    if #falhou > 0 then
        log("  FALHOU:", table.concat(falhou, ", "))
    end

    return data
end

--==================================================
-- LOAD RIG DATA
--==================================================

local function loadRigData(info)
    log("loadRigData:", info.name)

    if info.loaded then
        log("  Ja carregado")
        return true
    end

    local character = info.character

    if info.player and info.player.Character then
        character = info.player.Character
        info.character = character
    end

    if not character or not character.Parent then
        log("  ERRO: character invalido")
        return false
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        log("  ERRO: sem Humanoid")
        return false
    end

    log("  Pegando HumanoidDescription...")
    info.humanoidDescription = getHumanoidDescription(humanoid)

    if info.humanoidDescription then
        log("  HumanoidDescription: OK")
        info.rigType = humanoid.RigType
        info.fullDescription = extractDescriptionData(info.humanoidDescription, humanoid.RigType.Name)

        pcall(function()
            local ATT_TO_TYPE = {
                HatAttachment = "Hat",
                HairAttachment = "Hair",
                FaceFrontAttachment = "Face",
                FaceCenterAttachment = "Face",
                NeckAttachment = "Neck",
                BodyFrontAttachment = "Front",
                BodyBackAttachment = "Back",
                WaistCenterAttachment = "Waist",
                WaistBackAttachment = "Waist",
                RightCollarAttachment = "Shoulder",
                LeftCollarAttachment = "Shoulder",
            }

            local rigidByType = {}
            if info.fullDescription and info.fullDescription.Accessories then
                for _, acc in ipairs(info.fullDescription.Accessories) do
                    if not acc.IsLayered then
                        local t = acc.AccessoryType
                        if not rigidByType[t] then rigidByType[t] = {} end
                        table.insert(rigidByType[t], acc.AssetId)
                    end
                end
            end

            local typeCounters = {}
            local transforms = {}

            for _, child in ipairs(character:GetChildren()) do
                if child:IsA("Accessory") then
                    local handle = child:FindFirstChild("Handle")
                    if handle then
                        for _, att in ipairs(handle:GetChildren()) do
                            if att:IsA("Attachment") and not att.Name:match("^Rig") then
                                local accType = ATT_TO_TYPE[att.Name]
                                if accType then
                                    typeCounters[accType] = (typeCounters[accType] or 0) + 1
                                    local idx = typeCounters[accType]
                                    local assetId = rigidByType[accType] and rigidByType[accType][idx] or 0

                                    if assetId ~= 0 then
                                        local cf = att.CFrame
                                        local pos = cf.Position
                                        local rx, ry, rz = cf:ToOrientation()

                                        local scale = 1
                                        pcall(function()
                                            local mesh = handle:FindFirstChildOfClass("SpecialMesh")
                                            if mesh then
                                                scale = mesh.Scale.Y
                                            end
                                        end)

                                        table.insert(transforms, {
                                            AssetId = assetId,
                                            Name = child.Name,
                                            AttName = att.Name,
                                            Pos = {X = pos.X, Y = pos.Y, Z = pos.Z},
                                            Rot = {RX = rx, RY = ry, RZ = rz},
                                            Scale = scale,
                                        })
                                    end
                                end
                                break
                            end
                        end
                    end
                end
            end

            if #transforms > 0 then
                info.fullDescription.AccessoryTransforms = transforms
                log("  AccessoryTransforms:", #transforms, "rigidos capturados")
            end
        end)
    else
        log("  HumanoidDescription: FALHOU")
    end

    local hrp = character:FindFirstChild("HumanoidRootPart")
    info.savedPosition = hrp and hrp.CFrame or CFrame.new()

    info.loaded = true
    return info.humanoidDescription ~= nil
end

local function generateRigJSON(info)
    return {
        name = info.name,
        type = info.type,
        userId = info.userId,
        description = info.fullDescription
    }
end

--==================================================
-- GERAR RIG PARA PREVIEW
--==================================================

local function generatePreviewRig(info)
    log("generatePreviewRig:", info.name)

    if not info.humanoidDescription then
        log("  ERRO: sem humanoidDescription")
        return nil
    end

    local rigType = info.rigType or Enum.HumanoidRigType.R15

    log("  Gerando rig tipo:", tostring(rigType))

    local success, model = pcall(function()
        return Players:CreateHumanoidModelFromDescription(info.humanoidDescription, rigType)
    end)

    if success and model then
        log("  Rig gerado com sucesso!")

        model:PivotTo(CFrame.new(0, -500, 0))
        model.Parent = workspace

        for _, obj in pairs(model:GetDescendants()) do
            if obj:IsA("BaseScript") then
                obj:Destroy()
            end
        end

        task.wait()

        for _, part in pairs(model:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Anchored = true
            end
        end

        model.Parent = nil

        return model
    else
        log("  ERRO ao gerar rig:", tostring(model))
        return nil
    end
end


--[[ ═══════ MODULE: 14_drag.luau ═══════ ]]

--==================================================
-- DRAG
--==================================================

local function makeDraggable(frame, handle)
    local dragging, dragInput, dragStart, startPos

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

makeDraggable(MiniBar, MiniBar)
makeDraggable(MainFrame, TopBar)
makeDraggable(PreviewFrame, PreviewTopBar)


--[[ ═══════ MODULE: 15_animations.luau ═══════ ]]

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


--[[ ═══════ MODULE: 16_preview.luau ═══════ ]]

--==================================================
-- PREVIEW
--==================================================

local function clearPreview()
    if previewConnection then
        previewConnection:Disconnect()
        previewConnection = nil
    end
    for _, child in pairs(Viewport:GetChildren()) do
        if child ~= ViewportStatus and not child:IsA("UICorner") and not child:IsA("UIStroke") then
            child:Destroy()
        end
    end
    ViewportStatus.Text = ""
end

local function showPreview(info)
    log("showPreview:", info.name)
    clearPreview()

    currentPreviewData = info
    PreviewTitle.Text = "🦇 " .. info.name
    PreviewFrame.Visible = true

    ViewportStatus.Text = "Carregando..."
    InfoLabel.Text = "Carregando dados..."

    if not info.loaded then
        log("  Carregando dados...")
        task.spawn(function()
            local success = loadRigData(info)

            if success then
                if info.cardFrame then
                    info.cardFrame.BackgroundColor3 = Colors.cardLoaded
                end
                if info.statusLabel and info.fullDescription then
                    local accCount = info.fullDescription.Accessories and #info.fullDescription.Accessories or 0
                    info.statusLabel.Text = (info.fullDescription.RigType or "?") .. " | " .. accCount .. " acc"
                    info.statusLabel.TextColor3 = Colors.greenLight
                end
                showPreview(info)
            else
                ViewportStatus.Text = "ERRO ao carregar"
                InfoLabel.Text = "Nao foi possivel carregar.\nO character pode ter saido."
            end
        end)
        return
    end

    log("  Gerando preview...")
    ViewportStatus.Text = "Gerando rig..."

    task.spawn(function()
        local previewModel = generatePreviewRig(info)

        if previewModel then
            local camera = Instance.new("Camera")
            camera.FieldOfView = 50
            camera.Parent = Viewport
            Viewport.CurrentCamera = camera

            local worldModel = Instance.new("WorldModel")
            worldModel.Parent = Viewport
            previewModel.Parent = worldModel

            previewModel:PivotTo(CFrame.new(0, 0, 0))

            local angle = 0
            previewConnection = RunService.RenderStepped:Connect(function(dt)
                angle = angle + dt * 0.8
                camera.CFrame = CFrame.new(
                    Vector3.new(math.sin(angle) * 12, 2, math.cos(angle) * 12),
                    Vector3.new(0, 0, 0)
                )
            end)

            ViewportStatus.Text = ""
            log("  Preview criado!")
        else
            ViewportStatus.Text = "Erro ao gerar rig"
        end
    end)

    local desc = info.fullDescription
    if desc then
        local txt = "=== " .. info.name .. " ===\n"
        txt = txt .. "Tipo: " .. info.type .. "\n"
        txt = txt .. "RigType: " .. tostring(desc.RigType or "?") .. "\n\n"

        txt = txt .. "-- ROUPAS --\n"
        txt = txt .. "Shirt: " .. tostring(desc.Shirt or 0) .. "\n"
        txt = txt .. "Pants: " .. tostring(desc.Pants or 0) .. "\n"
        txt = txt .. "Face: " .. tostring(desc.Face or 0) .. "\n\n"

        local accCount = desc.Accessories and #desc.Accessories or 0
        txt = txt .. "-- ACESSORIOS (" .. accCount .. ") --\n"
        if desc.Accessories then
            for i, acc in ipairs(desc.Accessories) do
                txt = txt .. i .. ". " .. acc.AccessoryType
                if acc.IsLayered then txt = txt .. " [L]" end
                txt = txt .. " - " .. acc.AssetId .. "\n"
            end
        end

        txt = txt .. "\n-- ESCALAS --\n"
        txt = txt .. "Height: " .. string.format("%.2f", desc.HeightScale or 1) .. "\n"
        txt = txt .. "Width: " .. string.format("%.2f", desc.WidthScale or 1) .. "\n"
        txt = txt .. "BodyType: " .. string.format("%.2f", desc.BodyTypeScale or 0) .. "\n"

        InfoLabel.Text = txt
    else
        InfoLabel.Text = "Sem dados"
    end
end


--[[ ═══════ MODULE: 17_actions.luau ═══════ ]]

--==================================================
-- COPY JSON
--==================================================

local function copyToClipboard()
    if not currentPreviewData then return end

    if not currentPreviewData.loaded then
        CopyBtn.Text = "Carregando..."
        loadRigData(currentPreviewData)
    end

    if not currentPreviewData.fullDescription then
        CopyBtn.Text = "Sem dados"
        task.delay(1.5, function() CopyBtn.Text = "🩸 COPY JSON" end)
        return
    end

    local rigData = generateRigJSON(currentPreviewData)
    local ok, jsonStr = pcall(function()
        return HttpService:JSONEncode(rigData)
    end)

    if ok then
        if setclipboard then
            setclipboard(jsonStr)
            CopyBtn.Text = "COPIADO!"
        elseif toclipboard then
            toclipboard(jsonStr)
            CopyBtn.Text = "COPIADO!"
        else
            print(jsonStr)
            CopyBtn.Text = "VER F9"
        end
        notify("JSON copiado: " .. currentPreviewData.name, "success")
    else
        CopyBtn.Text = "ERRO"
        notify("Erro ao copiar JSON", "error")
    end

    task.delay(1.5, function() CopyBtn.Text = "🩸 COPY JSON" end)
end

--==================================================
-- EXPORT ALL
--==================================================

local function exportAllJSON()
    if #allScannedRigs == 0 then
        ExportBtn.Text = "SCAN FIRST"
        task.delay(1.5, function() ExportBtn.Text = "🦇 EXPORT ALL" end)
        return
    end

    if isExporting then return end
    isExporting = true

    local total = #allScannedRigs
    local loaded = 0

    for i, info in ipairs(allScannedRigs) do
        ExportBtn.Text = "🦇 " .. i .. "/" .. total

        if not info.loaded then
            loadRigData(info)
            if info.cardFrame then
                info.cardFrame.BackgroundColor3 = Colors.cardLoaded
            end
            if info.statusLabel and info.fullDescription then
                local accCount = info.fullDescription.Accessories and #info.fullDescription.Accessories or 0
                info.statusLabel.Text = (info.fullDescription.RigType or "?") .. " | " .. accCount .. " acc"
                info.statusLabel.TextColor3 = Colors.greenLight
            end
        end

        if info.fullDescription then
            loaded = loaded + 1
        end

        task.wait(LOAD_DELAY)
    end

    local allData = {
        exportVersion = "Vampire-v13",
        exportDate = os.date("%Y-%m-%d %H:%M:%S"),
        createdBy = "VampireSonata",
        totalRigs = total,
        loadedRigs = loaded,
        rigs = {}
    }

    for _, info in ipairs(allScannedRigs) do
        if info.fullDescription then
            table.insert(allData.rigs, generateRigJSON(info))
        end
    end

    local ok, jsonStr = pcall(function()
        return HttpService:JSONEncode(allData)
    end)

    isExporting = false

    if ok then
        if setclipboard then
            setclipboard(jsonStr)
            ExportBtn.Text = "🦇 " .. loaded .. " RIGS!"
        elseif toclipboard then
            toclipboard(jsonStr)
            ExportBtn.Text = "🦇 " .. loaded .. " RIGS!"
        else
            print(jsonStr)
            ExportBtn.Text = "VER F9"
        end
        notify("Exportados " .. loaded .. " rigs!", "success")
    else
        ExportBtn.Text = "ERRO"
        notify("Erro ao exportar", "error")
    end

    task.delay(2, function() ExportBtn.Text = "🦇 EXPORT ALL" end)
end

--==================================================
-- SCANNER
--==================================================

clearResults = function()
    for _, child in pairs(ResultScroll:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    allScannedRigs = {}
    scannedPlayerSet = {}
    scannedNPCSet = {}
end

createResultCard = function(info)
    local accentColor = info.type == "PLAYER" and Colors.blood or Colors.green

    local Card = Instance.new("Frame")
    Card.Size = UDim2.new(1, -10, 0, 70)
    Card.BackgroundColor3 = Colors.card
    Card.BorderSizePixel = 0
    Card.Parent = ResultScroll
    Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 8)
    addGradient(Card, Colors.surfaceLight, Colors.card, 0)

    local cardStroke = Instance.new("UIStroke", Card)
    cardStroke.Color = accentColor
    cardStroke.Thickness = 1
    cardStroke.Transparency = 1

    -- Left accent bar
    local accentBar = Instance.new("Frame")
    accentBar.Size = UDim2.new(0, 3, 1, -8)
    accentBar.Position = UDim2.new(0, 0, 0, 4)
    accentBar.BackgroundColor3 = accentColor
    accentBar.BorderSizePixel = 0
    accentBar.Parent = Card
    Instance.new("UICorner", accentBar).CornerRadius = UDim.new(0, 2)

    -- Card hover
    Card.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            TweenService:Create(cardStroke, TweenInfo.new(0.15), { Transparency = 0.3 }):Play()
            TweenService:Create(Card, TweenInfo.new(0.15), { BackgroundColor3 = Colors.surfaceLight }):Play()
        end
    end)
    Card.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            TweenService:Create(cardStroke, TweenInfo.new(0.2), { Transparency = 1 }):Play()
            TweenService:Create(Card, TweenInfo.new(0.2), { BackgroundColor3 = Colors.card }):Play()
        end
    end)

    info.cardFrame = Card

    local TypeBadge = Instance.new("Frame")
    TypeBadge.Size = UDim2.new(0, 50, 0, 16)
    TypeBadge.Position = UDim2.new(1, -58, 0, 5)
    TypeBadge.BackgroundColor3 = accentColor
    TypeBadge.Parent = Card
    Instance.new("UICorner", TypeBadge).CornerRadius = UDim.new(0, 4)

    local TypeLabel = Instance.new("TextLabel")
    TypeLabel.Size = UDim2.new(1, 0, 1, 0)
    TypeLabel.BackgroundTransparency = 1
    TypeLabel.Text = info.type
    TypeLabel.TextColor3 = Colors.text
    TypeLabel.TextSize = 9
    TypeLabel.Font = Enum.Font.GothamBold
    TypeLabel.Parent = TypeBadge

    local NameLabel = Instance.new("TextLabel")
    NameLabel.Size = UDim2.new(1, -65, 0, 18)
    NameLabel.Position = UDim2.new(0, 12, 0, 5)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Text = info.name
    NameLabel.TextColor3 = Colors.bloodLight
    NameLabel.TextSize = 12
    NameLabel.Font = Enum.Font.GothamBold
    NameLabel.TextXAlignment = Enum.TextXAlignment.Left
    NameLabel.TextTruncate = Enum.TextTruncate.AtEnd
    NameLabel.Parent = Card

    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Size = UDim2.new(1, -10, 0, 14)
    StatusLabel.Position = UDim2.new(0, 12, 0, 22)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Text = "Click VIEW"
    StatusLabel.TextColor3 = Colors.textDim
    StatusLabel.TextSize = 10
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    StatusLabel.Parent = Card

    info.statusLabel = StatusLabel

    -- Botoes
    local ViewBtn = Instance.new("TextButton")
    ViewBtn.Size = UDim2.new(0, 48, 0, 20)
    ViewBtn.Position = UDim2.new(0, 12, 1, -26)
    ViewBtn.BackgroundColor3 = Colors.blood
    ViewBtn.Text = "VIEW"
    ViewBtn.TextColor3 = Colors.text
    ViewBtn.TextSize = 10
    ViewBtn.Font = Enum.Font.GothamBold
    ViewBtn.AutoButtonColor = false
    ViewBtn.Parent = Card
    Instance.new("UICorner", ViewBtn).CornerRadius = UDim.new(0, 4)
    makeHoverable(ViewBtn, Colors.blood, Colors.glowRed)

    ViewBtn.MouseButton1Click:Connect(function()
        showPreview(info)
    end)

    local TPBtn = Instance.new("TextButton")
    TPBtn.Size = UDim2.new(0, 32, 0, 20)
    TPBtn.Position = UDim2.new(0, 64, 1, -26)
    TPBtn.BackgroundColor3 = Colors.green
    TPBtn.Text = "TP"
    TPBtn.TextColor3 = Colors.text
    TPBtn.TextSize = 10
    TPBtn.Font = Enum.Font.GothamBold
    TPBtn.AutoButtonColor = false
    TPBtn.Parent = Card
    Instance.new("UICorner", TPBtn).CornerRadius = UDim.new(0, 4)
    makeHoverable(TPBtn, Colors.green, Colors.greenLight)

    TPBtn.MouseButton1Click:Connect(function()
        local myHRP = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        local targetChar = info.character
        if info.player and info.player.Character then
            targetChar = info.player.Character
        end
        if myHRP and targetChar then
            local hrp = targetChar:FindFirstChild("HumanoidRootPart")
            if hrp then
                myHRP.CFrame = hrp.CFrame
                notify("TP to " .. info.name, "success")
            end
        end
    end)

    local JSONBtn = Instance.new("TextButton")
    JSONBtn.Size = UDim2.new(0, 38, 0, 20)
    JSONBtn.Position = UDim2.new(0, 100, 1, -26)
    JSONBtn.BackgroundColor3 = Colors.bloodDark
    JSONBtn.Text = "JSON"
    JSONBtn.TextColor3 = Colors.text
    JSONBtn.TextSize = 10
    JSONBtn.Font = Enum.Font.GothamBold
    JSONBtn.AutoButtonColor = false
    JSONBtn.Parent = Card
    Instance.new("UICorner", JSONBtn).CornerRadius = UDim.new(0, 4)
    makeHoverable(JSONBtn, Colors.bloodDark, Colors.blood)

    local SpecBtn = Instance.new("TextButton")
    SpecBtn.Size = UDim2.new(0, 38, 0, 20)
    SpecBtn.Position = UDim2.new(0, 142, 1, -26)
    SpecBtn.BackgroundColor3 = Color3.fromRGB(80, 25, 25)
    SpecBtn.Text = "SPEC"
    SpecBtn.TextColor3 = Colors.text
    SpecBtn.TextSize = 10
    SpecBtn.Font = Enum.Font.GothamBold
    SpecBtn.AutoButtonColor = false
    SpecBtn.Parent = Card
    Instance.new("UICorner", SpecBtn).CornerRadius = UDim.new(0, 4)
    makeHoverable(SpecBtn, Color3.fromRGB(80, 25, 25), Color3.fromRGB(120, 35, 35))

    SpecBtn.MouseButton1Click:Connect(function()
        startSpectate(info)
    end)

    JSONBtn.MouseButton1Click:Connect(function()
        if not info.loaded then
            JSONBtn.Text = "..."
            loadRigData(info)
            Card.BackgroundColor3 = Colors.cardLoaded
            if info.fullDescription then
                StatusLabel.Text = (info.fullDescription.RigType or "?") .. " | " .. #(info.fullDescription.Accessories or {}) .. " acc"
                StatusLabel.TextColor3 = Colors.greenLight
            end
        end

        if info.fullDescription then
            local ok, json = pcall(function()
                return HttpService:JSONEncode(generateRigJSON(info))
            end)
            if ok then
                if setclipboard then setclipboard(json)
                elseif toclipboard then toclipboard(json)
                else print(json) end
                JSONBtn.Text = "OK!"
                notify("JSON: " .. info.name, "success")
            else
                JSONBtn.Text = "ERR"
            end
        else
            JSONBtn.Text = "ERR"
        end
        task.delay(1, function() JSONBtn.Text = "JSON" end)
    end)
end

runScan = function()
    log("=== SCAN INICIADO ===")
    clearResults()
    clearPreview()
    PreviewFrame.Visible = false

    local countP, countN = 0, 0
    local players = Players:GetPlayers()

    log("Players online:", #players)

    for _, player in pairs(players) do
        local char = player.Character
        if char and char:FindFirstChildOfClass("Humanoid") then
            log("  + PLAYER:", player.Name)
            local info = {
                name = player.Name,
                type = "PLAYER",
                character = char,
                player = player,
                userId = player.UserId,
                loaded = false,
            }
            table.insert(allScannedRigs, info)
            scannedPlayerSet[player] = info
            createResultCard(info)
            countP = countP + 1
        end
    end

    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") then
            local isPlayer = false
            for _, p in pairs(players) do
                if p.Character == obj then isPlayer = true break end
            end
            if not isPlayer then
                log("  + NPC:", obj.Name)
                local info = {
                    name = obj.Name,
                    type = "NPC",
                    character = obj,
                    loaded = false,
                }
                table.insert(allScannedRigs, info)
                scannedNPCSet[obj] = info
                createResultCard(info)
                countN = countN + 1
            end
        end
    end

    ResultScroll.CanvasSize = UDim2.new(0, 0, 0, ResultLayout.AbsoluteContentSize.Y + 10)
    CountLabel.Text = countP .. "P | " .. countN .. "N"
    Title.Text = "Vampire (" .. countP .. "P | " .. countN .. "N)"
    notify("Scan: " .. countP .. " players, " .. countN .. " NPCs", "info")
    log("=== SCAN COMPLETO ===")
end

--==================================================
-- SEARCH / FILTER
--==================================================

filterResults = function(searchText)
    local text = searchText:lower()
    for _, info in ipairs(allScannedRigs) do
        if info.cardFrame then
            if text == "" then
                info.cardFrame.Visible = true
            else
                info.cardFrame.Visible = info.name:lower():find(text, 1, true) ~= nil
            end
        end
    end
    task.defer(function()
        ResultScroll.CanvasSize = UDim2.new(0, 0, 0, ResultLayout.AbsoluteContentSize.Y + 10)
    end)
end

--==================================================
-- AUTO-SCAN
--==================================================

startAutoScan = function()
    if autoScanConnection then return end

    autoScanConnection = task.spawn(function()
        -- Do initial scan
        if #allScannedRigs == 0 then
            runScan()
        end

        while autoScanConfig.enabled do
            task.wait(autoScanConfig.interval)
            if not autoScanConfig.enabled then break end

            local players = Players:GetPlayers()

            -- Check for new players
            for _, player in pairs(players) do
                if not scannedPlayerSet[player] then
                    local char = player.Character
                    if char and char:FindFirstChildOfClass("Humanoid") then
                        local info = {
                            name = player.Name,
                            type = "PLAYER",
                            character = char,
                            player = player,
                            userId = player.UserId,
                            loaded = false,
                        }
                        table.insert(allScannedRigs, info)
                        scannedPlayerSet[player] = info
                        createResultCard(info)
                        notify(player.Name .. " joined", "info")
                    end
                end
            end

            -- Check for removed players (gray out card)
            for player, info in pairs(scannedPlayerSet) do
                if not player.Parent then
                    if info.cardFrame and info.cardFrame.Parent then
                        info.cardFrame.BackgroundTransparency = 0.6
                        if info.statusLabel then
                            info.statusLabel.Text = "LEFT"
                            info.statusLabel.TextColor3 = Colors.textDim
                        end
                    end
                    scannedPlayerSet[player] = nil
                end
            end

            -- Update counts
            local pCount, nCount = 0, 0
            for _, info in ipairs(allScannedRigs) do
                if info.type == "PLAYER" then pCount = pCount + 1
                else nCount = nCount + 1 end
            end
            CountLabel.Text = pCount .. "P | " .. nCount .. "N"
            ResultScroll.CanvasSize = UDim2.new(0, 0, 0, ResultLayout.AbsoluteContentSize.Y + 10)
        end
    end)
end

stopAutoScan = function()
    autoScanConfig.enabled = false
    if autoScanConnection then
        task.cancel(autoScanConnection)
        autoScanConnection = nil
    end
end

--==================================================
-- PLAYER LIST (for Player tab)
--==================================================

refreshPlayerList = function()
    -- Clear existing
    for _, child in pairs(PlayerScroll:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end

    for _, player in pairs(Players:GetPlayers()) do
        local card = Instance.new("Frame")
        card.Size = UDim2.new(1, -10, 0, 50)
        card.BackgroundColor3 = Colors.card
        card.BorderSizePixel = 0
        card.Parent = PlayerScroll
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 6)
        addGradient(card, Colors.surfaceLight, Colors.card, 0)

        -- Avatar thumbnail
        local thumbFrame = Instance.new("Frame")
        thumbFrame.Size = UDim2.new(0, 36, 0, 36)
        thumbFrame.Position = UDim2.new(0, 6, 0, 7)
        thumbFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        thumbFrame.Parent = card
        Instance.new("UICorner", thumbFrame).CornerRadius = UDim.new(1, 0)
        local thumbStroke = Instance.new("UIStroke", thumbFrame)
        thumbStroke.Color = Colors.blood
        thumbStroke.Thickness = 1

        local thumbImg = Instance.new("ImageLabel")
        thumbImg.Size = UDim2.new(1, 0, 1, 0)
        thumbImg.BackgroundTransparency = 1
        thumbImg.Parent = thumbFrame
        Instance.new("UICorner", thumbImg).CornerRadius = UDim.new(1, 0)

        task.spawn(function()
            local ok, thumb = pcall(function()
                return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
            end)
            if ok and thumb then thumbImg.Image = thumb end
        end)

        -- Name
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, -120, 0, 16)
        nameLabel.Position = UDim2.new(0, 48, 0, 5)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = player.DisplayName .. " (@" .. player.Name .. ")"
        nameLabel.TextColor3 = Colors.bloodLight
        nameLabel.TextSize = 11
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
        nameLabel.Parent = card

        -- Account age
        local ageLabel = Instance.new("TextLabel")
        ageLabel.Size = UDim2.new(1, -120, 0, 12)
        ageLabel.Position = UDim2.new(0, 48, 0, 20)
        ageLabel.BackgroundTransparency = 1
        ageLabel.Text = "Age: " .. player.AccountAge .. "d | ID: " .. player.UserId
        ageLabel.TextColor3 = Colors.textDim
        ageLabel.TextSize = 9
        ageLabel.Font = Enum.Font.Gotham
        ageLabel.TextXAlignment = Enum.TextXAlignment.Left
        ageLabel.Parent = card

        -- Health bar
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            local hpBg = Instance.new("Frame")
            hpBg.Size = UDim2.new(0, 80, 0, 6)
            hpBg.Position = UDim2.new(0, 48, 0, 35)
            hpBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            hpBg.BorderSizePixel = 0
            hpBg.Parent = card
            Instance.new("UICorner", hpBg).CornerRadius = UDim.new(0, 3)

            local pct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
            local hpFill = Instance.new("Frame")
            hpFill.Size = UDim2.new(pct, 0, 1, 0)
            hpFill.BackgroundColor3 = pct > 0.5 and Colors.green or (pct > 0.25 and Colors.warning or Colors.glowRed)
            hpFill.BorderSizePixel = 0
            hpFill.Parent = hpBg
            Instance.new("UICorner", hpFill).CornerRadius = UDim.new(0, 3)
        end

        -- Buttons: SPEC | TP
        local specBtn = Instance.new("TextButton")
        specBtn.Size = UDim2.new(0, 36, 0, 18)
        specBtn.Position = UDim2.new(1, -80, 0, 6)
        specBtn.BackgroundColor3 = Color3.fromRGB(80, 25, 25)
        specBtn.Text = "SPEC"
        specBtn.TextColor3 = Colors.text
        specBtn.TextSize = 9
        specBtn.Font = Enum.Font.GothamBold
        specBtn.AutoButtonColor = false
        specBtn.Parent = card
        Instance.new("UICorner", specBtn).CornerRadius = UDim.new(0, 4)
        makeHoverable(specBtn, Color3.fromRGB(80, 25, 25), Color3.fromRGB(120, 35, 35))

        specBtn.MouseButton1Click:Connect(function()
            local c = player.Character
            if c then
                startSpectate({
                    name = player.Name,
                    character = c,
                    player = player,
                })
            end
        end)

        local tpBtn = Instance.new("TextButton")
        tpBtn.Size = UDim2.new(0, 28, 0, 18)
        tpBtn.Position = UDim2.new(1, -40, 0, 6)
        tpBtn.BackgroundColor3 = Colors.green
        tpBtn.Text = "TP"
        tpBtn.TextColor3 = Colors.text
        tpBtn.TextSize = 9
        tpBtn.Font = Enum.Font.GothamBold
        tpBtn.AutoButtonColor = false
        tpBtn.Parent = card
        Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0, 4)
        makeHoverable(tpBtn, Colors.green, Colors.greenLight)

        tpBtn.MouseButton1Click:Connect(function()
            local myHRP = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            local c = player.Character
            if myHRP and c then
                local hrp = c:FindFirstChild("HumanoidRootPart")
                if hrp then
                    myHRP.CFrame = hrp.CFrame
                    notify("TP to " .. player.Name, "success")
                end
            end
        end)
    end

    PlayerScroll.CanvasSize = UDim2.new(0, 0, 0, PlayerLayout.AbsoluteContentSize.Y + 10)
end

--==================================================
-- SERVER INFO
--==================================================

updateServerInfo = function()
    task.spawn(function()
        local fps = 0
        local frameCount = 0
        local lastTime = tick()

        while ServerInfoLabel and ServerInfoLabel.Parent do
            frameCount = frameCount + 1
            local now = tick()
            if now - lastTime >= 1 then
                fps = frameCount
                frameCount = 0
                lastTime = now

                local placeId = game.PlaceId
                local jobId = game.JobId
                local shortJob = #jobId > 12 and jobId:sub(1, 12) .. "..." or jobId
                local playerCount = #Players:GetPlayers()
                local maxPlayers = Players.MaxPlayers

                ServerInfoLabel.Text = "Place: " .. placeId .. " | Job: " .. shortJob .. "\nPlayers: " .. playerCount .. "/" .. maxPlayers .. " | FPS: " .. fps
            end
            task.wait()
        end
    end)
end


--[[ ═══════ MODULE: 18_spectate.luau ═══════ ]]

--==================================================
-- SPECTATE MODE
--==================================================

startSpectate = function(info)
    local targetChar = info.character
    if info.player and info.player.Character then
        targetChar = info.player.Character
    end

    if not targetChar then
        log("Spectate: character not found")
        notify("Spectate: character not found", "error")
        return
    end

    local humanoid = targetChar:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        log("Spectate: no Humanoid found")
        notify("Spectate: no Humanoid", "error")
        return
    end

    if spectatingInfo and spectatingInfo == info then
        stopSpectate()
        return
    end

    if spectatingInfo then
        stopSpectate()
    end

    local camera = workspace.CurrentCamera
    savedCameraSubject = camera.CameraSubject

    camera.CameraSubject = humanoid
    spectatingInfo = info

    if spectateHighlight then
        spectateHighlight:Destroy()
    end
    spectateHighlight = Instance.new("Highlight")
    spectateHighlight.Name = "VampSpectateHL"
    spectateHighlight.FillColor = Colors.blood
    spectateHighlight.FillTransparency = 0.7
    spectateHighlight.OutlineColor = Colors.bloodLight
    spectateHighlight.OutlineTransparency = 0
    spectateHighlight.Adornee = targetChar
    spectateHighlight.Parent = targetChar

    UnspectateBtn.Visible = true
    UnspectateBtn.Text = "🦇 UNSPECTATE (" .. info.name .. ")"

    notify("Spectating: " .. info.name, "info")
    log("Spectating:", info.name)
end

stopSpectate = function()
    if not spectatingInfo then return end

    local camera = workspace.CurrentCamera
    if savedCameraSubject then
        camera.CameraSubject = savedCameraSubject
        savedCameraSubject = nil
    else
        local localChar = LP.Character
        if localChar then
            local hum = localChar:FindFirstChildOfClass("Humanoid")
            if hum then
                camera.CameraSubject = hum
            end
        end
    end

    if spectateHighlight then
        spectateHighlight:Destroy()
        spectateHighlight = nil
    end

    spectatingInfo = nil
    UnspectateBtn.Visible = false

    notify("Spectate stopped", "info")
    log("Spectate stopped")
end


--[[ ═══════ MODULE: 19_esp_system.luau ═══════ ]]

--==================================================
-- ESP SYSTEM (Full)
--==================================================

local function createESPObject(target, espName, espColor, isCamera, isNPC)
    local existing = target:FindFirstChild("VampESP_BG")
    if existing then return end

    local espData = {
        target = target,
        isCamera = isCamera,
        isNPC = isNPC,
    }

    -- Highlight (player/NPC/camera ESP)
    if espState.players or espState.npcs or espState.cameras then
        local hl = Instance.new("Highlight")
        hl.Name = "VampESP_HL"
        hl.Adornee = target
        hl.Parent = target

        if espState.chams then
            hl.FillColor = espColor
            hl.FillTransparency = 0.3
            hl.OutlineColor = espColor
            hl.OutlineTransparency = 0.2
        elseif espState.boxESP then
            hl.FillColor = espColor
            hl.FillTransparency = 1
            hl.OutlineColor = espColor
            hl.OutlineTransparency = 0
        else
            hl.FillColor = espColor
            hl.FillTransparency = 0.85
            hl.OutlineColor = espColor
            hl.OutlineTransparency = 0.2
        end

        espData.highlight = hl
    end

    -- BillboardGui com nome e distancia
    local bg = Instance.new("BillboardGui")
    bg.Name = "VampESP_BG"
    bg.Size = UDim2.new(0, 200, 0, 60)
    bg.StudsOffset = Vector3.new(0, isCamera and 2 or 4, 0)
    bg.AlwaysOnTop = true
    bg.Adornee = target
    bg.Parent = target

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "ESPName"
    nameLabel.Size = UDim2.new(1, 0, 0, 16)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = espName
    nameLabel.TextColor3 = espColor
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.TextStrokeTransparency = 0.3
    nameLabel.TextSize = 14
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.Parent = bg

    local distLabel = Instance.new("TextLabel")
    distLabel.Name = "ESPDist"
    distLabel.Size = UDim2.new(1, 0, 0, 14)
    distLabel.Position = UDim2.new(0, 0, 0, 16)
    distLabel.BackgroundTransparency = 1
    distLabel.Text = "? studs"
    distLabel.TextColor3 = Colors.textDim
    distLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    distLabel.TextStrokeTransparency = 0.3
    distLabel.TextSize = 11
    distLabel.Font = Enum.Font.Gotham
    distLabel.Parent = bg

    espData.billboard = bg
    espData.nameLabel = nameLabel
    espData.distLabel = distLabel

    -- Health bar
    if espState.healthBars and not isCamera then
        local hpBg = Instance.new("Frame")
        hpBg.Name = "ESPHealth"
        hpBg.Size = UDim2.new(0, 100, 0, 6)
        hpBg.Position = UDim2.new(0.5, -50, 0, 32)
        hpBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        hpBg.BorderSizePixel = 0
        hpBg.Parent = bg
        Instance.new("UICorner", hpBg).CornerRadius = UDim.new(0, 3)

        local hpFill = Instance.new("Frame")
        hpFill.Name = "Fill"
        hpFill.Size = UDim2.new(1, 0, 1, 0)
        hpFill.BackgroundColor3 = Colors.green
        hpFill.BorderSizePixel = 0
        hpFill.Parent = hpBg
        Instance.new("UICorner", hpFill).CornerRadius = UDim.new(0, 3)

        espData.healthBg = hpBg
        espData.healthFill = hpFill
    end

    -- Type label (camera)
    if isCamera then
        local typeLabel = Instance.new("TextLabel")
        typeLabel.Name = "ESPType"
        typeLabel.Size = UDim2.new(1, 0, 0, 12)
        typeLabel.Position = UDim2.new(0, 0, 0, 32)
        typeLabel.BackgroundTransparency = 1
        typeLabel.Text = "📷 CAMERA"
        typeLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
        typeLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        typeLabel.TextStrokeTransparency = 0.3
        typeLabel.TextSize = 10
        typeLabel.Font = Enum.Font.GothamBold
        typeLabel.Parent = bg
    end

    table.insert(espObjects, espData)
end

local function removeESPFromTarget(target)
    local hl = target:FindFirstChild("VampESP_HL")
    if hl then hl:Destroy() end
    local bg = target:FindFirstChild("VampESP_BG")
    if bg then bg:Destroy() end
end

clearESP = function()
    if espConnection then
        espConnection:Disconnect()
        espConnection = nil
    end

    for _, esp in ipairs(espObjects) do
        if esp.target and esp.target.Parent then
            removeESPFromTarget(esp.target)
        end
    end
    espObjects = {}
end

updateESP = function()
    clearESP()

    local anyActive = false
    for _, v in pairs(espState) do
        if v then anyActive = true break end
    end

    if not anyActive then
        ESPStatusLabel.Text = "ESP OFF — toggle features above"
        return
    end

    local myChar = LP.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local playerChars = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p.Character then playerChars[p.Character] = p end
    end

    -- Players
    if espState.players then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LP then
                local char = player.Character
                if char and char:FindFirstChildOfClass("Humanoid") then
                    createESPObject(char, player.Name, Colors.bloodLight, false, false)
                end
            end
        end
    end

    -- NPCs
    if espState.npcs then
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") and not playerChars[obj] then
                createESPObject(obj, obj.Name, Colors.green, false, true)
            end
        end
    end

    -- Cameras
    if espState.cameras then
        local cameraKeywords = { "camera", "cam", "cctv", "security", "surveillance", "monitor" }
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Camera") and obj ~= workspace.CurrentCamera then
                createESPObject(obj, obj.Name, Color3.fromRGB(255, 200, 100), true, false)
            elseif (obj:IsA("BasePart") or obj:IsA("Model")) and not obj:FindFirstChild("VampESP_BG") then
                local lowerName = obj.Name:lower()
                for _, keyword in ipairs(cameraKeywords) do
                    if lowerName:find(keyword) then
                        createESPObject(obj, obj.Name, Color3.fromRGB(255, 200, 100), true, false)
                        break
                    end
                end
            end
        end
    end

    -- Update loop
    espConnection = RunService.RenderStepped:Connect(function()
        local char = LP.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local myPos = hrp.Position

        for i = #espObjects, 1, -1 do
            local esp = espObjects[i]
            if not esp.target or not esp.target.Parent then
                table.remove(espObjects, i)
            else
                local targetPos
                if esp.target:IsA("Model") then
                    local tHRP = esp.target:FindFirstChild("HumanoidRootPart")
                        or esp.target:FindFirstChild("Head")
                        or esp.target.PrimaryPart
                    if tHRP then targetPos = tHRP.Position end
                elseif esp.target:IsA("BasePart") then
                    targetPos = esp.target.Position
                elseif esp.target:IsA("Camera") then
                    targetPos = esp.target.CFrame.Position
                end

                if targetPos then
                    local dist = math.floor((myPos - targetPos).Magnitude)
                    esp.distLabel.Text = dist .. " studs"
                end

                -- Update health bar
                if esp.healthFill and not esp.isCamera then
                    local hum = esp.target:FindFirstChildOfClass("Humanoid")
                    if hum then
                        local pct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                        esp.healthFill.Size = UDim2.new(pct, 0, 1, 0)
                        if pct > 0.5 then
                            esp.healthFill.BackgroundColor3 = Colors.green
                        elseif pct > 0.25 then
                            esp.healthFill.BackgroundColor3 = Colors.warning
                        else
                            esp.healthFill.BackgroundColor3 = Colors.glowRed
                        end
                    end
                end
            end
        end
    end)

    ESPStatusLabel.Text = #espObjects .. " targets tracked"
    log("ESP ON:", #espObjects, "targets")
end

toggleESPFeature = function(feature)
    espState[feature] = not espState[feature]
    updateESP()

    -- Refresh toggle UIs
    if espToggles[feature] then
        espToggles[feature].refresh()
    end
end


--[[ ═══════ MODULE: 20_movement.luau ═══════ ]]

--==================================================
-- MOVEMENT LOGIC
--==================================================

-- Apply speed/jump to humanoid
applySpeed = function()
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = movementState.speed
        hum.JumpPower = movementState.jumpPower
    end
end

--==================================================
-- FLY
--==================================================

startFly = function()
    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then
        notify("No character found", "error")
        return
    end

    -- Clean up old
    if flyBG then pcall(function() flyBG:Destroy() end) end
    if flyBV then pcall(function() flyBV:Destroy() end) end

    flyBG = Instance.new("BodyGyro")
    flyBG.MaxTorque = Vector3.new(4e5, 4e5, 4e5)
    flyBG.P = 10000
    flyBG.D = 500
    flyBG.Parent = hrp

    flyBV = Instance.new("BodyVelocity")
    flyBV.MaxForce = Vector3.new(4e5, 4e5, 4e5)
    flyBV.Velocity = Vector3.zero
    flyBV.Parent = hrp

    flyConnection = RunService.RenderStepped:Connect(function()
        local cam = workspace.CurrentCamera
        local dir = Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.yAxis end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.yAxis end

        if dir.Magnitude > 0 then
            flyBV.Velocity = dir.Unit * movementState.speed * 3
        else
            flyBV.Velocity = Vector3.zero
        end
        flyBG.CFrame = cam.CFrame
    end)

    notify("Fly ON", "success")
    log("Fly ON")
end

stopFly = function()
    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end
    if flyBG then pcall(function() flyBG:Destroy() end) flyBG = nil end
    if flyBV then pcall(function() flyBV:Destroy() end) flyBV = nil end

    notify("Fly OFF", "info")
    log("Fly OFF")
end

--==================================================
-- NOCLIP
--==================================================

toggleNoclip = function()
    if movementState.noclip then
        noclipConnection = RunService.Stepped:Connect(function()
            local char = LP.Character
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
        notify("Noclip ON", "success")
        log("Noclip ON")
    else
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
        notify("Noclip OFF", "info")
        log("Noclip OFF")
    end
end

--==================================================
-- INFINITE JUMP
--==================================================

toggleInfiniteJump = function()
    if movementState.infiniteJump then
        jumpConnection = UIS.JumpRequest:Connect(function()
            local char = LP.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
        notify("Infinite Jump ON", "success")
        log("Infinite Jump ON")
    else
        if jumpConnection then
            jumpConnection:Disconnect()
            jumpConnection = nil
        end
        notify("Infinite Jump OFF", "info")
        log("Infinite Jump OFF")
    end
end

--==================================================
-- FREECAM
--==================================================

startFreecam = function()
    local cam = workspace.CurrentCamera
    savedCameraState = {
        subject = cam.CameraSubject,
        ctype = cam.CameraType,
    }
    cam.CameraType = Enum.CameraType.Scriptable

    freecamConnection = RunService.RenderStepped:Connect(function(dt)
        local speed = movementState.speed * 2
        local move = Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then move = move + cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then move = move - cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then move = move - cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then move = move + cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.yAxis end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.yAxis end

        if move.Magnitude > 0 then
            cam.CFrame = cam.CFrame + move.Unit * speed * dt
        end
    end)

    notify("Freecam ON", "success")
    log("Freecam ON")
end

stopFreecam = function()
    if freecamConnection then
        freecamConnection:Disconnect()
        freecamConnection = nil
    end
    local cam = workspace.CurrentCamera
    if savedCameraState then
        cam.CameraType = savedCameraState.ctype
        cam.CameraSubject = savedCameraState.subject
        savedCameraState = nil
    end
    notify("Freecam OFF", "info")
    log("Freecam OFF")
end


--[[ ═══════ MODULE: 21_teleport.luau ═══════ ]]

--==================================================
-- TELEPORT LOGIC
--==================================================

-- TP to Part by name
tpToPart = function(name)
    if not name or name == "" then
        notify("Enter a part name", "warning")
        return
    end

    local lowerName = name:lower()
    for _, obj in pairs(workspace:GetDescendants()) do
        if (obj:IsA("BasePart") or obj:IsA("Model")) and obj.Name:lower():find(lowerName, 1, true) then
            local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local target
                if obj:IsA("Model") then
                    target = obj.PrimaryPart or obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart")
                else
                    target = obj
                end
                if target then
                    hrp.CFrame = target.CFrame + Vector3.new(0, 5, 0)
                    notify("TP to: " .. obj.Name, "success")
                    return
                end
            end
        end
    end
    notify("Not found: " .. name, "error")
end

--==================================================
-- WAYPOINTS
--==================================================

addWaypoint = function(name)
    if not name or name == "" then
        name = "WP " .. (#waypoints + 1)
    end

    local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then
        notify("No character", "error")
        return
    end

    table.insert(waypoints, {
        name = name,
        cframe = hrp.CFrame,
    })

    notify("Waypoint saved: " .. name, "success")
    refreshWaypointList()
end

tpToWaypoint = function(index)
    local wp = waypoints[index]
    if not wp then return end
    local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = wp.cframe
        notify("TP to: " .. wp.name, "success")
    end
end

removeWaypoint = function(index)
    local wp = waypoints[index]
    if wp then
        notify("Removed: " .. wp.name, "info")
        table.remove(waypoints, index)
        refreshWaypointList()
    end
end

refreshWaypointList = function()
    -- Clear existing
    for _, child in pairs(WaypointList:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end

    local myHRP = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")

    for i, wp in ipairs(waypoints) do
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 30)
        row.BackgroundColor3 = Colors.card
        row.BorderSizePixel = 0
        row.Parent = WaypointList
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)
        addGradient(row, Colors.surfaceLight, Colors.card, 0)

        -- Left accent
        local bar = Instance.new("Frame")
        bar.Size = UDim2.new(0, 3, 1, -6)
        bar.Position = UDim2.new(0, 0, 0, 3)
        bar.BackgroundColor3 = Colors.green
        bar.BorderSizePixel = 0
        bar.Parent = row
        Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 2)

        -- Name
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, -110, 1, 0)
        nameLabel.Position = UDim2.new(0, 10, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = wp.name
        nameLabel.TextColor3 = Colors.text
        nameLabel.TextSize = 11
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
        nameLabel.Parent = row

        -- Distance
        if myHRP then
            local dist = math.floor((myHRP.Position - wp.cframe.Position).Magnitude)
            local distLabel = Instance.new("TextLabel")
            distLabel.Size = UDim2.new(0, 50, 1, 0)
            distLabel.Position = UDim2.new(1, -108, 0, 0)
            distLabel.BackgroundTransparency = 1
            distLabel.Text = dist .. "m"
            distLabel.TextColor3 = Colors.textDim
            distLabel.TextSize = 9
            distLabel.Font = Enum.Font.Gotham
            distLabel.Parent = row
        end

        -- TP button
        local tpBtn = Instance.new("TextButton")
        tpBtn.Size = UDim2.new(0, 28, 0, 20)
        tpBtn.Position = UDim2.new(1, -58, 0, 5)
        tpBtn.BackgroundColor3 = Colors.green
        tpBtn.Text = "TP"
        tpBtn.TextColor3 = Colors.text
        tpBtn.TextSize = 9
        tpBtn.Font = Enum.Font.GothamBold
        tpBtn.AutoButtonColor = false
        tpBtn.Parent = row
        Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0, 4)
        makeHoverable(tpBtn, Colors.green, Colors.greenLight)

        local idx = i
        tpBtn.MouseButton1Click:Connect(function()
            tpToWaypoint(idx)
        end)

        -- Delete button
        local delBtn = Instance.new("TextButton")
        delBtn.Size = UDim2.new(0, 22, 0, 20)
        delBtn.Position = UDim2.new(1, -26, 0, 5)
        delBtn.BackgroundColor3 = Colors.bloodDark
        delBtn.Text = "X"
        delBtn.TextColor3 = Colors.text
        delBtn.TextSize = 9
        delBtn.Font = Enum.Font.GothamBold
        delBtn.AutoButtonColor = false
        delBtn.Parent = row
        Instance.new("UICorner", delBtn).CornerRadius = UDim.new(0, 4)
        makeHoverable(delBtn, Colors.bloodDark, Colors.blood)

        delBtn.MouseButton1Click:Connect(function()
            removeWaypoint(idx)
        end)
    end

    -- Also refresh Player TP list
    for _, child in pairs(PlayerTPList:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LP then
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, 0, 0, 26)
            row.BackgroundColor3 = Colors.card
            row.BorderSizePixel = 0
            row.Parent = PlayerTPList
            Instance.new("UICorner", row).CornerRadius = UDim.new(0, 4)

            local pName = Instance.new("TextLabel")
            pName.Size = UDim2.new(1, -40, 1, 0)
            pName.Position = UDim2.new(0, 6, 0, 0)
            pName.BackgroundTransparency = 1
            pName.Text = player.DisplayName
            pName.TextColor3 = Colors.bloodLight
            pName.TextSize = 10
            pName.Font = Enum.Font.GothamBold
            pName.TextXAlignment = Enum.TextXAlignment.Left
            pName.TextTruncate = Enum.TextTruncate.AtEnd
            pName.Parent = row

            local tpBtn2 = Instance.new("TextButton")
            tpBtn2.Size = UDim2.new(0, 28, 0, 18)
            tpBtn2.Position = UDim2.new(1, -32, 0, 4)
            tpBtn2.BackgroundColor3 = Colors.green
            tpBtn2.Text = "TP"
            tpBtn2.TextColor3 = Colors.text
            tpBtn2.TextSize = 9
            tpBtn2.Font = Enum.Font.GothamBold
            tpBtn2.AutoButtonColor = false
            tpBtn2.Parent = row
            Instance.new("UICorner", tpBtn2).CornerRadius = UDim.new(0, 4)
            makeHoverable(tpBtn2, Colors.green, Colors.greenLight)

            tpBtn2.MouseButton1Click:Connect(function()
                local myHRP2 = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                local c = player.Character
                if myHRP2 and c then
                    local hrp = c:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        myHRP2.CFrame = hrp.CFrame
                        notify("TP to " .. player.Name, "success")
                    end
                end
            end)
        end
    end
end


--[[ ═══════ MODULE: 22_events.luau ═══════ ]]

--==================================================
-- EVENTS
--==================================================

--==================================================
-- SCANNER TAB EVENTS
--==================================================

ScanBtn.MouseButton1Click:Connect(function()
    runScan()
end)

ExportBtn.MouseButton1Click:Connect(function()
    exportAllJSON()
end)

CopyBtn.MouseButton1Click:Connect(copyToClipboard)

-- Search filter
SearchBar:GetPropertyChangedSignal("Text"):Connect(function()
    filterResults(SearchBar.Text)
end)

-- Auto-scan toggle
AutoScanToggle.btn.MouseButton1Click:Connect(function()
    autoScanConfig.enabled = not autoScanConfig.enabled
    AutoScanToggle.refresh()
    autoScanSettingToggle.refresh() -- sync settings tab
    if autoScanConfig.enabled then
        startAutoScan()
    else
        stopAutoScan()
    end
end)

-- Unspectate
UnspectateBtn.MouseButton1Click:Connect(function()
    stopSpectate()
end)

--==================================================
-- ESP TAB EVENTS
--==================================================

for feature, toggle in pairs(espToggles) do
    toggle.btn.MouseButton1Click:Connect(function()
        toggleESPFeature(feature)
    end)
end

ESPOffBtn.MouseButton1Click:Connect(function()
    for k in pairs(espState) do
        espState[k] = false
    end
    clearESP()
    for _, toggle in pairs(espToggles) do
        toggle.refresh()
    end
    ESPStatusLabel.Text = "ESP OFF — toggle features above"
    notify("All ESP disabled", "info")
end)

--==================================================
-- PLAYER TAB EVENTS
--==================================================

RefreshPlayersBtn.MouseButton1Click:Connect(function()
    refreshPlayerList()
    notify("Player list refreshed", "info")
end)

-- Auto-refresh when tab switches to player
-- (handled in switchTab below)

--==================================================
-- MOVEMENT TAB EVENTS
--==================================================

moveToggles.fly.btn.MouseButton1Click:Connect(function()
    movementState.fly = not movementState.fly
    moveToggles.fly.refresh()
    if movementState.fly then
        startFly()
    else
        stopFly()
    end
end)

moveToggles.noclip.btn.MouseButton1Click:Connect(function()
    movementState.noclip = not movementState.noclip
    moveToggles.noclip.refresh()
    toggleNoclip()
end)

moveToggles.infiniteJump.btn.MouseButton1Click:Connect(function()
    movementState.infiniteJump = not movementState.infiniteJump
    moveToggles.infiniteJump.refresh()
    toggleInfiniteJump()
end)

moveToggles.freecam.btn.MouseButton1Click:Connect(function()
    movementState.freecam = not movementState.freecam
    moveToggles.freecam.refresh()
    if movementState.freecam then
        startFreecam()
    else
        stopFreecam()
    end
end)

ResetMoveBtn.MouseButton1Click:Connect(function()
    -- Stop all
    if movementState.fly then
        movementState.fly = false
        moveToggles.fly.refresh()
        stopFly()
    end
    if movementState.noclip then
        movementState.noclip = false
        moveToggles.noclip.refresh()
        toggleNoclip()
    end
    if movementState.infiniteJump then
        movementState.infiniteJump = false
        moveToggles.infiniteJump.refresh()
        toggleInfiniteJump()
    end
    if movementState.freecam then
        movementState.freecam = false
        moveToggles.freecam.refresh()
        stopFreecam()
    end
    -- Reset speed
    movementState.speed = 16
    movementState.jumpPower = 50
    speedSlider.setValue(16)
    jumpSlider.setValue(50)
    applySpeed()
    notify("Movement reset", "info")
end)

-- Apply speed on character spawn
LP.CharacterAdded:Connect(function()
    task.wait(0.5)
    applySpeed()
end)

--==================================================
-- TELEPORT TAB EVENTS
--==================================================

TPSearchBtn.MouseButton1Click:Connect(function()
    tpToPart(TPInput.Text)
end)

TPInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        tpToPart(TPInput.Text)
    end
end)

SaveWPBtn.MouseButton1Click:Connect(function()
    addWaypoint(WPNameInput.Text)
    WPNameInput.Text = ""
end)

WPNameInput.FocusLost:Connect(function(enterPressed)
    if enterPressed and WPNameInput.Text ~= "" then
        addWaypoint(WPNameInput.Text)
        WPNameInput.Text = ""
    end
end)

--==================================================
-- SETTINGS TAB EVENTS
--==================================================

autoScanSettingToggle.btn.MouseButton1Click:Connect(function()
    autoScanConfig.enabled = not autoScanConfig.enabled
    autoScanSettingToggle.refresh()
    -- Sync with scanner tab toggle
    AutoScanToggle.refresh()
    if autoScanConfig.enabled then
        startAutoScan()
    else
        stopAutoScan()
    end
end)

-- Helper: carrega SynSaveInstance
local function loadSSI()
    local Params = {
        RepoURL = "https://raw.githubusercontent.com/luau/SynSaveInstance/main/",
        SSI = "saveinstance",
    }
    local loader = loadstring(game:HttpGet(Params.RepoURL .. Params.SSI .. ".luau", true), Params.SSI)
    if not loader then error("Failed to load SynSaveInstance") end
    return loader()
end

ConfirmSaveBtn.MouseButton1Click:Connect(function()
    ConfirmSaveBtn.Text = "💾 ..."
    task.spawn(function()
        local ok, err = pcall(function()
            local synsaveinstance = loadSSI()

            local fname = FileNameBox.Text
            if fname == "" then
                fname = game.PlaceId .. "_" .. os.date("%Y%m%d_%H%M%S")
            end

            local options = {
                FileName = fname,
                DecompileMode = saveConfigState.DecompileMode and "decompile" or "none",
                SavePlayers = saveConfigState.SavePlayers,
                RemovePlayerCharacters = saveConfigState.RemovePlayerCharacters,
                NilInstances = saveConfigState.NilInstances,
                SaveNonCreatable = saveConfigState.SaveNonCreatable,
                IsolateLocalPlayer = saveConfigState.IsolateLocalPlayer,
                SaveCameraInstances = saveConfigState.SaveCameraInstances,
            }

            log("Save options:", HttpService:JSONEncode(options))
            synsaveinstance(options)
        end)
        if ok then
            ConfirmSaveBtn.Text = "💾 SAVED!"
            notify("Instance saved!", "success")
        else
            log("Save ERROR:", tostring(err))
            ConfirmSaveBtn.Text = "💾 ERR"
            notify("Save error: " .. tostring(err):sub(1, 50), "error")
        end
        task.delay(3, function() ConfirmSaveBtn.Text = "💾 SAVE" end)
    end)
end)

SaveAllBtn.MouseButton1Click:Connect(function()
    SaveAllBtn.Text = "⚡ ..."
    task.spawn(function()
        local ok, err = pcall(function()
            local synsaveinstance = loadSSI()
            local options = {}
            log("Save All: default options")
            synsaveinstance(options)
        end)
        if ok then
            SaveAllBtn.Text = "⚡ SAVED!"
            notify("All saved!", "success")
        else
            log("Save All ERROR:", tostring(err))
            SaveAllBtn.Text = "⚡ ERR"
            notify("Save error", "error")
        end
        task.delay(3, function() SaveAllBtn.Text = "⚡ SAVE ALL" end)
    end)
end)

--==================================================
-- PREVIEW EVENTS
--==================================================

PreviewClose.MouseButton1Click:Connect(function()
    clearPreview()
    PreviewFrame.Visible = false
end)

--==================================================
-- GLOBAL EVENTS
--==================================================

-- X fecha tudo (destroy)
CloseBtn.MouseButton1Click:Connect(function()
    stopSpectate()
    clearESP()
    clearPreview()
    clearResults()
    stopAutoScan()
    if movementState.fly then stopFly() end
    if movementState.noclip then
        movementState.noclip = false
        toggleNoclip()
    end
    if movementState.infiniteJump then
        movementState.infiniteJump = false
        toggleInfiniteJump()
    end
    if movementState.freecam then stopFreecam() end
    -- Reset speed
    movementState.speed = 16
    movementState.jumpPower = 50
    applySpeed()
    ScreenGui:Destroy()
end)

-- Minimizar = volta pro MiniBar
MinBtn.MouseButton1Click:Connect(function()
    closeScanner()
end)

-- Ctrl+G = toggle abrir/fechar
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == HOTKEY then
        if REQUIRE_CTRL and (UIS:IsKeyDown(Enum.KeyCode.LeftControl) or UIS:IsKeyDown(Enum.KeyCode.RightControl)) then
            toggleScanner()
        elseif not REQUIRE_CTRL then
            toggleScanner()
        end
    end
end)

--==================================================
-- TAB SWITCH ENHANCEMENT (refresh data on tab change)
--==================================================

-- Override switchTab to add refresh behavior
local baseSwitchTab = switchTab
switchTab = function(tabId)
    baseSwitchTab(tabId)

    -- Refresh player list when switching to player tab
    if tabId == "player" then
        refreshPlayerList()
        updateServerInfo()
    end

    -- Refresh TP player list
    if tabId == "teleport" then
        refreshWaypointList()
    end
end

--==================================================
-- INIT
--==================================================

-- Set default tab
switchTab("scanner")

-- Start auto-scan if enabled
if autoScanConfig.enabled then
    task.delay(1, function()
        startAutoScan()
    end)
end

log("══════════════════════════════════════")
log("VAMPIRE RIG SCANNER v13")
log("Create By VampireSonata")
log("══════════════════════════════════════")
log("MiniBar mode! Ctrl+G to toggle")
log("══════════════════════════════════════")

notify("🦇 Vampire Rig Scanner v13 loaded!", "success")

