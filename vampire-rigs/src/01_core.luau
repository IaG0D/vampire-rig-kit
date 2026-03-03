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
local spectateConfig = { showHighlight = true }

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

-- Emote state
local currentEmoteTrack = nil

-- Shadow state
local shadowState = {
    active = false,
    mode = "follow", -- "follow" | "head" | "mirror"
    target = nil,
    delay = 0,
    distance = 4,
}
local shadowConnection = nil
local shadowHistory = {}

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
local filterResults
local runScan, clearResults, createResultCard
local refreshPlayerList
local updateServerInfo
local playEmote, stopEmote
local startShadow, stopShadow, refreshShadowPlayerList

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
