local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local AvatarEditorService = game:GetService("AvatarEditorService")
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

-- State variables (globals to stay under Lua's 200 local limit)
currentPreviewData = nil
previewConnection = nil
allScannedRigs = {}
isExporting = false

-- Tab system
activeTab = "scanner"
tabButtons = {}
tabContents = {}

-- Auto-scan
autoScanConfig = { enabled = true, interval = 5 }
autoScanConnection = nil
scannedPlayerSet = {}
scannedNPCSet = {}

-- Spectate state
spectatingInfo = nil
spectateHighlight = nil
savedCameraSubject = nil
spectateConfig = { showHighlight = true }

-- ESP state
espState = {
    players = false,
    npcs = false,
    cameras = false,
    healthBars = false,
    boxESP = false,
    chams = false,
}
espConnection = nil
espObjects = {}

-- Movement state
movementState = {
    fly = false,
    noclip = false,
    infiniteJump = false,
    freecam = false,
    speed = 16,
    jumpPower = 50,
}
flyConnection = nil
flyBG = nil
flyBV = nil
noclipConnection = nil
jumpConnection = nil
freecamConnection = nil
savedCameraState = nil
speedConnection = nil

-- Emote state
currentEmoteTrack = nil
emotePaused = false

-- Shadow state
shadowState = {
    active = false,
    mode = "orbit",      -- "orbit" | "head"
    target = nil,
    delay = 0,
    distance = 4,
    angle = 0,           -- 0-360° (0=behind, 90=right, 180=front, 270=left)
    height = 0,          -- -5 to 10 studs vertical offset
    faceTarget = false,  -- look at target or match their rotation
    mirrorAnims = true,  -- mirror target animations (ON by default)
    autoOrbit = false,   -- slowly rotate around target
    orbitSpeed = 2,      -- degrees per frame (1-10)
    trail = false,       -- trail effect while shadowing
}
shadowConnection = nil
shadowHistory = {}
shadowRecordedPath = {}
shadowRecording = false
shadowReplaying = false
shadowReplayConnection = nil
shadowTrailInstance = nil

-- Notification state
notifContainer = nil
notifCount = 0

-- Settings state
saveConfigState = {
    DecompileMode = false,
    SavePlayers = false,
    RemovePlayerCharacters = true,
    NilInstances = false,
    SaveNonCreatable = false,
    IsolateLocalPlayer = false,
    SaveCameraInstances = false,
}

-- Emote catalog state
emoteCatalogPages = nil
emoteCatalogHasMore = false
emoteSearchVersion = 0
isLoadingMoreEmotes = false

-- Favorite emotes state
favoriteEmotes = {}         -- Array of { id, name, isBundle }
emoteTabPreloaded = false   -- Whether trending emotes have been loaded

-- Forward-declared functions are assigned as globals by later modules
-- (removed local forward declarations to stay under Lua's 200 local limit)

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
    row.Size = UDim2.new(1, -20, 0, 32)
    row.Position = UDim2.new(0, 10, 0, yPos)
    row.BackgroundTransparency = 1
    row.Parent = parent

    -- Label (left)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.65, 0, 0, 12)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = Colors.textDim
    lbl.TextSize = 10
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    -- Value label (right)
    local valLabel = Instance.new("TextLabel")
    valLabel.Size = UDim2.new(0.35, 0, 0, 12)
    valLabel.BackgroundTransparency = 1
    valLabel.Text = tostring(default)
    valLabel.TextColor3 = Colors.text
    valLabel.TextSize = 10
    valLabel.Font = Enum.Font.GothamBold
    valLabel.TextXAlignment = Enum.TextXAlignment.Right
    valLabel.Parent = row

    -- Track bar
    local track = Instance.new("TextButton")
    track.Size = UDim2.new(1, 0, 0, 8)
    track.Position = UDim2.new(0, 0, 0, 18)
    track.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    track.BorderSizePixel = 0
    track.Text = ""
    track.AutoButtonColor = false
    track.Parent = row
    Instance.new("UICorner", track).CornerRadius = UDim.new(0, 4)

    -- Fill bar
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(math.clamp((default - min) / math.max(max - min, 1), 0, 1), 0, 1, 0)
    fill.BackgroundColor3 = Colors.glowPurple
    fill.BorderSizePixel = 0
    fill.Parent = track
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 4)

    local fillGrad = Instance.new("UIGradient")
    fillGrad.Color = ColorSequence.new(Colors.blood, Colors.glowPurple)
    fillGrad.Parent = fill

    -- Thumb knob
    local thumb = Instance.new("Frame")
    thumb.Size = UDim2.new(0, 14, 0, 14)
    thumb.AnchorPoint = Vector2.new(0.5, 0.5)
    thumb.Position = UDim2.new(math.clamp((default - min) / math.max(max - min, 1), 0, 1), 0, 0.5, 0)
    thumb.BackgroundColor3 = Colors.text
    thumb.BorderSizePixel = 0
    thumb.ZIndex = 2
    thumb.Parent = track
    Instance.new("UICorner", thumb).CornerRadius = UDim.new(1, 0)
    local thumbStroke = Instance.new("UIStroke", thumb)
    thumbStroke.Color = Colors.glowPurple
    thumbStroke.Thickness = 1.5

    local currentVal = default
    local dragging = false

    local function updateVisual(pct)
        pct = math.clamp(pct, 0, 1)
        fill.Size = UDim2.new(pct, 0, 1, 0)
        thumb.Position = UDim2.new(pct, 0, 0.5, 0)
    end

    local function setValue(v)
        currentVal = math.clamp(math.floor(v + 0.5), min, max)
        local pct = (currentVal - min) / math.max(max - min, 1)
        updateVisual(pct)
        valLabel.Text = tostring(currentVal)
        if callback then callback(currentVal) end
    end

    local function handleInput(inputPos)
        local absPos = track.AbsolutePosition.X
        local absSize = track.AbsoluteSize.X
        if absSize <= 0 then return end
        local pct = math.clamp((inputPos - absPos) / absSize, 0, 1)
        local rawVal = min + pct * (max - min)
        setValue(rawVal)
    end

    -- Click on track
    track.MouseButton1Down:Connect(function()
        dragging = true
    end)

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            handleInput(input.Position.X)
        end
    end)

    -- Drag anywhere while held
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            handleInput(input.Position.X)
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    -- Thumb hover glow
    thumb.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            TweenService:Create(thumb, TweenInfo.new(0.15), { Size = UDim2.new(0, 16, 0, 16) }):Play()
            TweenService:Create(thumbStroke, TweenInfo.new(0.15), { Thickness = 2 }):Play()
        end
    end)
    thumb.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            TweenService:Create(thumb, TweenInfo.new(0.2), { Size = UDim2.new(0, 14, 0, 14) }):Play()
            TweenService:Create(thumbStroke, TweenInfo.new(0.2), { Thickness = 1.5 }):Play()
        end
    end)

    return { row = row, getValue = function() return currentVal end, setValue = setValue }
end
