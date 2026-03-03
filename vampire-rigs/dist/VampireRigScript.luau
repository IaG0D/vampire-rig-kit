--==================================================
-- VAMPIRE RIG SCANNER v13 - TAB SYSTEM + FULL FEATURES
-- Create By VampireSonata
-- Tabs: Scanner, ESP, Players, Movement, Emote, Settings
-- ⚡ Bundled automaticamente — NÃO edite este arquivo!
-- ⚡ Edite os modulos em vampire-rigs/src/
--==================================================


--[[ ═══════ MODULE: 01_core.luau ═══════ ]]

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

-- Cosmetic state
cosmeticState = {
    headless = false,
    invisible = false,
    ghost = false,
}

-- Active troll connection
trollConnection = nil

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
    { id = "emote",    icon = "💃", label = "Emote" },
    { id = "settings", icon = "⚙",  label = "Config" },
}

-- Container para os botoes (UIListLayout aqui dentro, sem afetar o accent line)
local TabBtnContainer = Instance.new("Frame")
TabBtnContainer.Size = UDim2.new(1, 0, 1, 0)
TabBtnContainer.BackgroundTransparency = 1
TabBtnContainer.BorderSizePixel = 0
TabBtnContainer.Parent = TabBar

local tabBarLayout = Instance.new("UIListLayout", TabBtnContainer)
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
    tabBtn.Parent = TabBtnContainer

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
PlayerScroll.Size = UDim2.new(1, 0, 1, -132)
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

-- Unspectate button (hidden by default)
local PlayerUnspectateBtn = Instance.new("TextButton")
PlayerUnspectateBtn.Size = UDim2.new(1, 0, 0, 26)
PlayerUnspectateBtn.Position = UDim2.new(0, 0, 1, -130)
PlayerUnspectateBtn.BackgroundColor3 = Colors.blood
PlayerUnspectateBtn.Text = "🦇 UNSPECTATE"
PlayerUnspectateBtn.TextColor3 = Colors.text
PlayerUnspectateBtn.TextSize = 11
PlayerUnspectateBtn.Font = Enum.Font.GothamBold
PlayerUnspectateBtn.AutoButtonColor = false
PlayerUnspectateBtn.Visible = false
PlayerUnspectateBtn.Parent = PlayerContent
Instance.new("UICorner", PlayerUnspectateBtn).CornerRadius = UDim.new(0, 6)
addBtnGradient(PlayerUnspectateBtn)
makeHoverable(PlayerUnspectateBtn, Colors.blood, Colors.glowRed)

-- Refresh button
local RefreshPlayersBtn = Instance.new("TextButton")
RefreshPlayersBtn.Size = UDim2.new(1, 0, 0, 26)
RefreshPlayersBtn.Position = UDim2.new(0, 0, 1, -100)
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

-- Stop Troll button
StopTrollBtn = Instance.new("TextButton")
StopTrollBtn.Size = UDim2.new(0.5, -3, 0, 26)
StopTrollBtn.Position = UDim2.new(0, 0, 1, -70)
StopTrollBtn.BackgroundColor3 = Colors.warning
StopTrollBtn.Text = "⛔ STOP TROLL"
StopTrollBtn.TextColor3 = Colors.bg
StopTrollBtn.TextSize = 10
StopTrollBtn.Font = Enum.Font.GothamBold
StopTrollBtn.AutoButtonColor = false
StopTrollBtn.Parent = PlayerContent
Instance.new("UICorner", StopTrollBtn).CornerRadius = UDim.new(0, 6)
makeHoverable(StopTrollBtn, Colors.warning, Color3.fromRGB(230, 180, 60))

-- Fling All button
FlingAllBtn = Instance.new("TextButton")
FlingAllBtn.Size = UDim2.new(0.5, -3, 0, 26)
FlingAllBtn.Position = UDim2.new(0.5, 3, 1, -70)
FlingAllBtn.BackgroundColor3 = Colors.glowRed
FlingAllBtn.Text = "💥 FLING ALL"
FlingAllBtn.TextColor3 = Colors.text
FlingAllBtn.TextSize = 10
FlingAllBtn.Font = Enum.Font.GothamBold
FlingAllBtn.AutoButtonColor = false
FlingAllBtn.Parent = PlayerContent
Instance.new("UICorner", FlingAllBtn).CornerRadius = UDim.new(0, 6)
addBtnGradient(FlingAllBtn)
makeHoverable(FlingAllBtn, Colors.glowRed, Color3.fromRGB(255, 80, 80))

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


--[[ ═══════ MODULE: 09_tab_emote.luau ═══════ ]]

--==================================================
-- TAB: EMOTE (Favorites + Catalog Search + Custom ID)
--==================================================

local EmoteContent = Instance.new("Frame")
EmoteContent.Name = "EmoteContent"
EmoteContent.Size = UDim2.new(1, 0, 1, 0)
EmoteContent.BackgroundTransparency = 1
EmoteContent.Visible = false
EmoteContent.Parent = TabContent
tabContents["emote"] = EmoteContent

local EmoteScroll = Instance.new("ScrollingFrame")
EmoteScroll.Size = UDim2.new(1, 0, 1, 0)
EmoteScroll.BackgroundTransparency = 1
EmoteScroll.ScrollBarThickness = 3
EmoteScroll.ScrollBarImageColor3 = Colors.blood
EmoteScroll.CanvasSize = UDim2.new(0, 0, 0, 600)
EmoteScroll.BorderSizePixel = 0
EmoteScroll.Parent = EmoteContent

--==================================================
-- FAVORITES SECTION
--==================================================

createSectionHeader(EmoteScroll, "Favorites", 0)

local favSectionY = 24

-- Favorites grid container (global for cross-module access)
EmoteFavGrid = Instance.new("Frame")
EmoteFavGrid.Name = "FavGrid"
EmoteFavGrid.Size = UDim2.new(1, 0, 0, 0)
EmoteFavGrid.Position = UDim2.new(0, 0, 0, favSectionY)
EmoteFavGrid.BackgroundTransparency = 1
EmoteFavGrid.ClipsDescendants = true
EmoteFavGrid.Parent = EmoteScroll

EmoteFavGridLayout = Instance.new("UIGridLayout", EmoteFavGrid)
EmoteFavGridLayout.CellSize = UDim2.new(0, 60, 0, 82)
EmoteFavGridLayout.CellPadding = UDim2.new(0, 6, 0, 6)
EmoteFavGridLayout.FillDirection = Enum.FillDirection.Horizontal
EmoteFavGridLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Empty favorites label
EmoteFavEmpty = Instance.new("TextLabel")
EmoteFavEmpty.Size = UDim2.new(1, 0, 0, 24)
EmoteFavEmpty.Position = UDim2.new(0, 0, 0, favSectionY)
EmoteFavEmpty.BackgroundTransparency = 1
EmoteFavEmpty.Text = "No favorites yet — star emotes from catalog"
EmoteFavEmpty.TextColor3 = Colors.textDim
EmoteFavEmpty.TextSize = 9
EmoteFavEmpty.Font = Enum.Font.Gotham
EmoteFavEmpty.Visible = true
EmoteFavEmpty.Parent = EmoteScroll

--==================================================
-- CUSTOM ANIMATION ID
-- (Y positions set by recalcEmoteLayout)
--==================================================

local CustomIDLabel = Instance.new("TextLabel")
CustomIDLabel.Size = UDim2.new(1, 0, 0, 14)
CustomIDLabel.BackgroundTransparency = 1
CustomIDLabel.Text = "Custom Animation ID:"
CustomIDLabel.TextColor3 = Colors.textDim
CustomIDLabel.TextSize = 10
CustomIDLabel.Font = Enum.Font.GothamBold
CustomIDLabel.TextXAlignment = Enum.TextXAlignment.Left
CustomIDLabel.Parent = EmoteScroll

local CustomIDInput = Instance.new("TextBox")
CustomIDInput.Size = UDim2.new(1, -70, 0, 26)
CustomIDInput.BackgroundColor3 = Colors.inputBg
CustomIDInput.Text = ""
CustomIDInput.PlaceholderText = "Animation ID..."
CustomIDInput.TextColor3 = Colors.text
CustomIDInput.PlaceholderColor3 = Colors.textDim
CustomIDInput.TextSize = 11
CustomIDInput.Font = Enum.Font.Code
CustomIDInput.ClearTextOnFocus = false
CustomIDInput.Parent = EmoteScroll
Instance.new("UICorner", CustomIDInput).CornerRadius = UDim.new(0, 6)
local customStroke = Instance.new("UIStroke", CustomIDInput)
customStroke.Color = Colors.inputBorder
customStroke.Thickness = 1

CustomIDInput.Focused:Connect(function()
    TweenService:Create(customStroke, TweenInfo.new(0.2), { Color = Colors.purpleLight, Thickness = 1.5 }):Play()
end)
CustomIDInput.FocusLost:Connect(function()
    TweenService:Create(customStroke, TweenInfo.new(0.3), { Color = Colors.inputBorder, Thickness = 1 }):Play()
end)

local PlayCustomBtn = Instance.new("TextButton")
PlayCustomBtn.Size = UDim2.new(0, 62, 0, 26)
PlayCustomBtn.BackgroundColor3 = Colors.green
PlayCustomBtn.Text = "▶ PLAY"
PlayCustomBtn.TextColor3 = Colors.text
PlayCustomBtn.TextSize = 10
PlayCustomBtn.Font = Enum.Font.GothamBold
PlayCustomBtn.AutoButtonColor = false
PlayCustomBtn.Parent = EmoteScroll
Instance.new("UICorner", PlayCustomBtn).CornerRadius = UDim.new(0, 6)
makeHoverable(PlayCustomBtn, Colors.green, Colors.greenLight)

-- Pause/Resume button (left half)
PauseEmoteBtn = Instance.new("TextButton")
PauseEmoteBtn.Size = UDim2.new(0.5, -2, 0, 26)
PauseEmoteBtn.BackgroundColor3 = Colors.warning
PauseEmoteBtn.Text = "⏸ PAUSE"
PauseEmoteBtn.TextColor3 = Colors.text
PauseEmoteBtn.TextSize = 10
PauseEmoteBtn.Font = Enum.Font.GothamBold
PauseEmoteBtn.AutoButtonColor = false
PauseEmoteBtn.Parent = EmoteScroll
Instance.new("UICorner", PauseEmoteBtn).CornerRadius = UDim.new(0, 6)
makeHoverable(PauseEmoteBtn, Colors.warning, Color3.fromRGB(230, 180, 60))

-- Stop emote button (right half)
local StopEmoteBtn = Instance.new("TextButton")
StopEmoteBtn.Size = UDim2.new(0.5, -2, 0, 26)
StopEmoteBtn.BackgroundColor3 = Colors.bloodDark
StopEmoteBtn.Text = "⏹ STOP"
StopEmoteBtn.TextColor3 = Colors.text
StopEmoteBtn.TextSize = 10
StopEmoteBtn.Font = Enum.Font.GothamBold
StopEmoteBtn.AutoButtonColor = false
StopEmoteBtn.Parent = EmoteScroll
Instance.new("UICorner", StopEmoteBtn).CornerRadius = UDim.new(0, 6)
makeHoverable(StopEmoteBtn, Colors.bloodDark, Colors.blood)

--==================================================
-- CATALOG SEARCH
--==================================================

EmoteCatalogHeader = createSectionHeader(EmoteScroll, "Catalog Search", 0)

-- Search input (global for event wiring in 22_events)
EmoteSearchBox = Instance.new("TextBox")
EmoteSearchBox.Size = UDim2.new(1, 0, 0, 26)
EmoteSearchBox.BackgroundColor3 = Colors.inputBg
EmoteSearchBox.Text = ""
EmoteSearchBox.PlaceholderText = "🔍 Search emotes..."
EmoteSearchBox.PlaceholderColor3 = Colors.textDim
EmoteSearchBox.TextColor3 = Colors.text
EmoteSearchBox.TextSize = 11
EmoteSearchBox.Font = Enum.Font.Code
EmoteSearchBox.ClearTextOnFocus = false
EmoteSearchBox.Parent = EmoteScroll
Instance.new("UICorner", EmoteSearchBox).CornerRadius = UDim.new(0, 6)
local emoteSearchStroke = Instance.new("UIStroke", EmoteSearchBox)
emoteSearchStroke.Color = Colors.inputBorder
emoteSearchStroke.Thickness = 1

EmoteSearchBox.Focused:Connect(function()
    TweenService:Create(emoteSearchStroke, TweenInfo.new(0.2), { Color = Colors.purpleLight, Thickness = 1.5 }):Play()
end)
EmoteSearchBox.FocusLost:Connect(function()
    TweenService:Create(emoteSearchStroke, TweenInfo.new(0.3), { Color = Colors.inputBorder, Thickness = 1 }):Play()
end)

-- Catalog grid container (global for cross-module access)
EmoteCatalogGrid = Instance.new("Frame")
EmoteCatalogGrid.Name = "CatalogGrid"
EmoteCatalogGrid.Size = UDim2.new(1, 0, 0, 300)
EmoteCatalogGrid.BackgroundTransparency = 1
EmoteCatalogGrid.ClipsDescendants = true
EmoteCatalogGrid.Parent = EmoteScroll

EmoteCatalogGridLayout = Instance.new("UIGridLayout", EmoteCatalogGrid)
EmoteCatalogGridLayout.CellSize = UDim2.new(0, 60, 0, 82)
EmoteCatalogGridLayout.CellPadding = UDim2.new(0, 6, 0, 6)
EmoteCatalogGridLayout.FillDirection = Enum.FillDirection.Horizontal
EmoteCatalogGridLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Empty/status label
EmoteCatalogEmpty = Instance.new("TextLabel")
EmoteCatalogEmpty.Size = UDim2.new(1, 0, 0, 30)
EmoteCatalogEmpty.BackgroundTransparency = 1
EmoteCatalogEmpty.Text = "Loading popular emotes..."
EmoteCatalogEmpty.TextColor3 = Colors.textDim
EmoteCatalogEmpty.TextSize = 10
EmoteCatalogEmpty.Font = Enum.Font.Gotham
EmoteCatalogEmpty.Visible = true
EmoteCatalogEmpty.Parent = EmoteScroll

--==================================================
-- LAYOUT FUNCTION (global — repositions everything based on favorites grid height)
--==================================================

recalcEmoteLayout = function()
    local favHeight = EmoteFavGrid.Size.Y.Offset
    if favHeight < 10 then favHeight = 24 end

    local baseY = favSectionY + favHeight + 8

    -- Custom ID section
    CustomIDLabel.Position = UDim2.new(0, 0, 0, baseY)
    CustomIDInput.Position = UDim2.new(0, 0, 0, baseY + 16)
    PlayCustomBtn.Position = UDim2.new(1, -62, 0, baseY + 16)
    PauseEmoteBtn.Position = UDim2.new(0, 0, 0, baseY + 48)
    StopEmoteBtn.Position = UDim2.new(0.5, 2, 0, baseY + 48)

    -- Catalog section
    local catalogY = baseY + 86
    EmoteCatalogHeader.Position = UDim2.new(0, 0, 0, catalogY)
    EmoteSearchBox.Position = UDim2.new(0, 0, 0, catalogY + 26)
    EmoteCatalogGrid.Position = UDim2.new(0, 0, 0, catalogY + 58)
    EmoteCatalogEmpty.Position = UDim2.new(0, 0, 0, catalogY + 58)

    -- Update canvas
    EmoteScroll.CanvasSize = UDim2.new(0, 0, 0, catalogY + 58 + EmoteCatalogGrid.Size.Y.Offset + 20)
end

-- Initial layout (no favorites yet)
recalcEmoteLayout()


--[[ ═══════ MODULE: 09b_shadow_panel.luau ═══════ ]]

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
SettingsScroll.CanvasSize = UDim2.new(0, 0, 0, 600)
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
-- SPECTATE SETTINGS
--==================================================

createSectionHeader(SettingsScroll, "Spectate", 144)

local spectateHLToggle = createVampToggle(SettingsScroll, "Spectate Highlight", "showHighlight", spectateConfig, 170, Colors.bloodLight)

--==================================================
-- SAVE INSTANCE
--==================================================

createSectionHeader(SettingsScroll, "Save Instance", 200)

local FileNameLabel = Instance.new("TextLabel")
FileNameLabel.Size = UDim2.new(1, 0, 0, 16)
FileNameLabel.Position = UDim2.new(0, 0, 0, 226)
FileNameLabel.BackgroundTransparency = 1
FileNameLabel.Text = "File name:"
FileNameLabel.TextColor3 = Colors.textDim
FileNameLabel.TextSize = 11
FileNameLabel.Font = Enum.Font.GothamBold
FileNameLabel.TextXAlignment = Enum.TextXAlignment.Left
FileNameLabel.Parent = SettingsScroll

local FileNameBox = Instance.new("TextBox")
FileNameBox.Size = UDim2.new(1, 0, 0, 28)
FileNameBox.Position = UDim2.new(0, 0, 0, 244)
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
local saveY = 280
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

--==================================================
-- COSMETICS
--==================================================

createSectionHeader(SettingsScroll, "Cosmetics", saveBtnY + 116)

cosmeticHeadlessToggle = createVampToggle(SettingsScroll, "Headless", "headless", cosmeticState, saveBtnY + 142, Colors.glowPurple)
cosmeticInvisibleToggle = createVampToggle(SettingsScroll, "Invisible", "invisible", cosmeticState, saveBtnY + 170, Colors.glowPurple)
cosmeticGhostToggle = createVampToggle(SettingsScroll, "Ghost (Semi-Transparent)", "ghost", cosmeticState, saveBtnY + 198, Colors.glowPurple)

CosmeticResetBtn = Instance.new("TextButton")
CosmeticResetBtn.Size = UDim2.new(1, 0, 0, 26)
CosmeticResetBtn.Position = UDim2.new(0, 0, 0, saveBtnY + 232)
CosmeticResetBtn.BackgroundColor3 = Colors.warning
CosmeticResetBtn.Text = "↺ RESET COSMETICS"
CosmeticResetBtn.TextColor3 = Colors.bg
CosmeticResetBtn.TextSize = 11
CosmeticResetBtn.Font = Enum.Font.GothamBold
CosmeticResetBtn.AutoButtonColor = false
CosmeticResetBtn.Parent = SettingsScroll
Instance.new("UICorner", CosmeticResetBtn).CornerRadius = UDim.new(0, 6)
makeHoverable(CosmeticResetBtn, Colors.warning, Color3.fromRGB(230, 180, 60))

SettingsScroll.CanvasSize = UDim2.new(0, 0, 0, saveBtnY + 270)


--[[ ═══════ MODULE: 11_preview_ui.luau ═══════ ]]

--==================================================
-- PREVIEW WINDOW — BOLA DE CRISTAL
--==================================================

local PreviewFrame = Instance.new("Frame")
PreviewFrame.Name = "Preview"
PreviewFrame.Size = UDim2.new(0, 320, 0, 500)
PreviewFrame.Position = UDim2.new(0.3, 430, 0.5, -250)
PreviewFrame.BackgroundColor3 = Colors.bg
PreviewFrame.BorderSizePixel = 0
PreviewFrame.Visible = false
PreviewFrame.Parent = ScreenGui

local previewStroke = Instance.new("UIStroke", PreviewFrame)
previewStroke.Color = Colors.glowPurple
previewStroke.Thickness = 1.5
Instance.new("UICorner", PreviewFrame).CornerRadius = UDim.new(0, 10)
addGradient(PreviewFrame, Colors.surfaceLight, Color3.fromRGB(8, 8, 10), 90)

-- Top bar
local PreviewTopBar = Instance.new("Frame")
PreviewTopBar.Size = UDim2.new(1, 0, 0, 35)
PreviewTopBar.BackgroundColor3 = Colors.topbar
PreviewTopBar.BorderSizePixel = 0
PreviewTopBar.Parent = PreviewFrame
Instance.new("UICorner", PreviewTopBar).CornerRadius = UDim.new(0, 10)
addGradient(PreviewTopBar, Color3.fromRGB(30, 10, 40), Colors.topbar, 0)

local topBarFix = Instance.new("Frame")
topBarFix.Size = UDim2.new(1, 0, 0, 10)
topBarFix.Position = UDim2.new(0, 0, 1, -10)
topBarFix.BackgroundColor3 = Colors.topbar
topBarFix.BorderSizePixel = 0
topBarFix.Parent = PreviewTopBar

addAccentLine(PreviewTopBar, UDim2.new(0, 0, 1, -1), Colors.glowPurple)

local PreviewTitle = Instance.new("TextLabel")
PreviewTitle.Size = UDim2.new(1, -50, 1, 0)
PreviewTitle.Position = UDim2.new(0, 10, 0, 0)
PreviewTitle.BackgroundTransparency = 1
PreviewTitle.Text = "🔮 Crystal Ball"
PreviewTitle.TextColor3 = Colors.purpleLight
PreviewTitle.TextSize = 13
PreviewTitle.Font = Enum.Font.GothamBold
PreviewTitle.TextXAlignment = Enum.TextXAlignment.Left
PreviewTitle.Parent = PreviewTopBar

local PreviewClose = Instance.new("TextButton")
PreviewClose.Size = UDim2.new(0, 22, 0, 22)
PreviewClose.Position = UDim2.new(1, -28, 0, 6)
PreviewClose.BackgroundColor3 = Colors.blood
PreviewClose.Text = "X"
PreviewClose.TextColor3 = Colors.text
PreviewClose.TextSize = 12
PreviewClose.Font = Enum.Font.GothamBold
PreviewClose.AutoButtonColor = false
PreviewClose.Parent = PreviewTopBar
Instance.new("UICorner", PreviewClose).CornerRadius = UDim.new(0, 6)
makeHoverable(PreviewClose, Colors.blood, Colors.glowRed)

--==================================================
-- VIEWPORT (Crystal Ball)
--==================================================

local Viewport = Instance.new("ViewportFrame")
Viewport.Size = UDim2.new(1, -20, 0, 220)
Viewport.Position = UDim2.new(0, 10, 0, 42)
Viewport.BackgroundColor3 = Color3.fromRGB(5, 3, 8)
Viewport.BorderSizePixel = 0
Viewport.Ambient = Color3.fromRGB(180, 160, 200)
Viewport.LightColor = Color3.fromRGB(255, 240, 255)
Viewport.LightDirection = Vector3.new(-1, -1, -1)
Viewport.Parent = PreviewFrame
Instance.new("UICorner", Viewport).CornerRadius = UDim.new(0, 12)
local vpStroke = Instance.new("UIStroke", Viewport)
vpStroke.Color = Colors.glowPurple
vpStroke.Thickness = 2
vpStroke.Transparency = 0.2

-- "LIVE" badge overlay
local LiveBadge = Instance.new("TextLabel")
LiveBadge.Size = UDim2.new(0, 48, 0, 16)
LiveBadge.Position = UDim2.new(0, 6, 0, 6)
LiveBadge.BackgroundColor3 = Color3.fromRGB(180, 15, 15)
LiveBadge.Text = "● LIVE"
LiveBadge.TextColor3 = Colors.text
LiveBadge.TextSize = 9
LiveBadge.Font = Enum.Font.GothamBold
LiveBadge.Visible = false
LiveBadge.ZIndex = 10
LiveBadge.Parent = Viewport
Instance.new("UICorner", LiveBadge).CornerRadius = UDim.new(0, 4)

-- Distance overlay (top-right)
local DistLabel = Instance.new("TextLabel")
DistLabel.Size = UDim2.new(0, 60, 0, 16)
DistLabel.Position = UDim2.new(1, -66, 0, 6)
DistLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
DistLabel.BackgroundTransparency = 0.3
DistLabel.Text = ""
DistLabel.TextColor3 = Colors.textDim
DistLabel.TextSize = 9
DistLabel.Font = Enum.Font.Code
DistLabel.Visible = false
DistLabel.ZIndex = 10
DistLabel.Parent = Viewport
Instance.new("UICorner", DistLabel).CornerRadius = UDim.new(0, 4)

-- Status text (center, for loading/errors)
local ViewportStatus = Instance.new("TextLabel")
ViewportStatus.Size = UDim2.new(1, 0, 1, 0)
ViewportStatus.BackgroundTransparency = 1
ViewportStatus.Text = ""
ViewportStatus.TextColor3 = Colors.textLoading
ViewportStatus.TextSize = 12
ViewportStatus.Font = Enum.Font.GothamBold
ViewportStatus.TextWrapped = true
ViewportStatus.ZIndex = 5
ViewportStatus.Parent = Viewport

--==================================================
-- INFO BAR (name, type, HP)
--==================================================

local InfoBar = Instance.new("Frame")
InfoBar.Size = UDim2.new(1, -20, 0, 42)
InfoBar.Position = UDim2.new(0, 10, 0, 268)
InfoBar.BackgroundColor3 = Colors.card
InfoBar.BorderSizePixel = 0
InfoBar.Parent = PreviewFrame
Instance.new("UICorner", InfoBar).CornerRadius = UDim.new(0, 6)
addGradient(InfoBar, Colors.surfaceLight, Colors.card, 0)

local PreviewNameLabel = Instance.new("TextLabel")
PreviewNameLabel.Size = UDim2.new(1, -60, 0, 18)
PreviewNameLabel.Position = UDim2.new(0, 8, 0, 3)
PreviewNameLabel.BackgroundTransparency = 1
PreviewNameLabel.Text = ""
PreviewNameLabel.TextColor3 = Colors.purpleLight
PreviewNameLabel.TextSize = 12
PreviewNameLabel.Font = Enum.Font.GothamBold
PreviewNameLabel.TextXAlignment = Enum.TextXAlignment.Left
PreviewNameLabel.TextTruncate = Enum.TextTruncate.AtEnd
PreviewNameLabel.Parent = InfoBar

local PreviewTypeBadge = Instance.new("Frame")
PreviewTypeBadge.Size = UDim2.new(0, 50, 0, 14)
PreviewTypeBadge.Position = UDim2.new(1, -56, 0, 5)
PreviewTypeBadge.BackgroundColor3 = Colors.blood
PreviewTypeBadge.Parent = InfoBar
Instance.new("UICorner", PreviewTypeBadge).CornerRadius = UDim.new(0, 4)

local PreviewTypeLabel = Instance.new("TextLabel")
PreviewTypeLabel.Size = UDim2.new(1, 0, 1, 0)
PreviewTypeLabel.BackgroundTransparency = 1
PreviewTypeLabel.Text = "PLAYER"
PreviewTypeLabel.TextColor3 = Colors.text
PreviewTypeLabel.TextSize = 8
PreviewTypeLabel.Font = Enum.Font.GothamBold
PreviewTypeLabel.Parent = PreviewTypeBadge

-- HP bar
local PreviewHPBg = Instance.new("Frame")
PreviewHPBg.Size = UDim2.new(1, -16, 0, 6)
PreviewHPBg.Position = UDim2.new(0, 8, 0, 26)
PreviewHPBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
PreviewHPBg.BorderSizePixel = 0
PreviewHPBg.Parent = InfoBar
Instance.new("UICorner", PreviewHPBg).CornerRadius = UDim.new(0, 3)

local PreviewHPFill = Instance.new("Frame")
PreviewHPFill.Size = UDim2.new(1, 0, 1, 0)
PreviewHPFill.BackgroundColor3 = Colors.green
PreviewHPFill.BorderSizePixel = 0
PreviewHPFill.Parent = PreviewHPBg
Instance.new("UICorner", PreviewHPFill).CornerRadius = UDim.new(0, 3)

local PreviewHPLabel = Instance.new("TextLabel")
PreviewHPLabel.Size = UDim2.new(1, 0, 0, 8)
PreviewHPLabel.Position = UDim2.new(0, 0, 0, 34)
PreviewHPLabel.BackgroundTransparency = 1
PreviewHPLabel.Text = ""
PreviewHPLabel.TextColor3 = Colors.textDim
PreviewHPLabel.TextSize = 8
PreviewHPLabel.Font = Enum.Font.Code
PreviewHPLabel.Parent = InfoBar

--==================================================
-- INFO SCROLL (accessories, scales, etc)
--==================================================

local InfoScroll = Instance.new("ScrollingFrame")
InfoScroll.Size = UDim2.new(1, -20, 0, 115)
InfoScroll.Position = UDim2.new(0, 10, 0, 316)
InfoScroll.BackgroundColor3 = Colors.content
InfoScroll.BorderSizePixel = 0
InfoScroll.ScrollBarThickness = 3
InfoScroll.ScrollBarImageColor3 = Colors.glowPurple
InfoScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
InfoScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
InfoScroll.Parent = PreviewFrame
Instance.new("UICorner", InfoScroll).CornerRadius = UDim.new(0, 6)
local infoScrollStroke = Instance.new("UIStroke", InfoScroll)
infoScrollStroke.Color = Colors.separator
infoScrollStroke.Thickness = 0.5
infoScrollStroke.Transparency = 0.5

local InfoLabel = Instance.new("TextLabel")
InfoLabel.Size = UDim2.new(1, -16, 0, 0)
InfoLabel.Position = UDim2.new(0, 8, 0, 4)
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

--==================================================
-- COPY JSON BUTTON
--==================================================

local CopyBtn = Instance.new("TextButton")
CopyBtn.Size = UDim2.new(1, -20, 0, 30)
CopyBtn.Position = UDim2.new(0, 10, 1, -60)
CopyBtn.BackgroundColor3 = Colors.purple
CopyBtn.Text = "🩸 COPY JSON"
CopyBtn.TextColor3 = Colors.text
CopyBtn.TextSize = 12
CopyBtn.Font = Enum.Font.GothamBold
CopyBtn.AutoButtonColor = false
CopyBtn.Parent = PreviewFrame
Instance.new("UICorner", CopyBtn).CornerRadius = UDim.new(0, 6)
addBtnGradient(CopyBtn)
makeHoverable(CopyBtn, Colors.purple, Colors.purpleLight)

--==================================================
-- FOOTER
--==================================================

local PreviewFooter = Instance.new("Frame")
PreviewFooter.Size = UDim2.new(1, 0, 0, 25)
PreviewFooter.Position = UDim2.new(0, 0, 1, -25)
PreviewFooter.BackgroundColor3 = Colors.topbar
PreviewFooter.BorderSizePixel = 0
PreviewFooter.Parent = PreviewFrame
Instance.new("UICorner", PreviewFooter).CornerRadius = UDim.new(0, 10)
addAccentLine(PreviewFooter, UDim2.new(0, 0, 0, 0), Colors.glowPurple)

local PreviewCredits = Instance.new("TextLabel")
PreviewCredits.Size = UDim2.new(1, 0, 1, 0)
PreviewCredits.BackgroundTransparency = 1
PreviewCredits.Text = "🔮 Crystal Ball — VampireSonata"
PreviewCredits.TextColor3 = Colors.textBlood
PreviewCredits.TextSize = 10
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
                    local entry = { AssetId = child.AssetId }
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
makeDraggable(ShadowPanel, ShadowPanelTopBar)


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

    -- Release mouse if freecam is active
    if movementState.freecam then
        UIS.MouseBehavior = Enum.MouseBehavior.Default
        UIS.MouseIconEnabled = true
    end

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

    -- Re-lock mouse if freecam is still active
    if movementState.freecam then
        UIS.MouseBehavior = Enum.MouseBehavior.LockCenter
        UIS.MouseIconEnabled = false
    end

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
-- PREVIEW — BOLA DE CRISTAL (Live CFrame Sync)
--==================================================

local function clearPreview()
    if previewConnection then
        previewConnection:Disconnect()
        previewConnection = nil
    end
    for _, child in pairs(Viewport:GetChildren()) do
        if not child:IsA("UICorner") and not child:IsA("UIStroke")
            and child ~= ViewportStatus and child ~= LiveBadge and child ~= DistLabel then
            child:Destroy()
        end
    end
    ViewportStatus.Text = ""
    LiveBadge.Visible = false
    DistLabel.Visible = false
    PreviewHPFill.Size = UDim2.new(1, 0, 1, 0)
    PreviewHPFill.BackgroundColor3 = Colors.green
    PreviewHPLabel.Text = ""
    currentPreviewData = nil
end

local function displayPreviewInfo(info)
    local desc = info.fullDescription
    if not desc then
        InfoLabel.Text = "No data available"
        return
    end

    local txt = ""
    txt = txt .. "RigType: " .. tostring(desc.RigType or "?") .. "\n\n"

    txt = txt .. "-- CLOTHES --\n"
    txt = txt .. "Shirt: " .. tostring(desc.Shirt or 0) .. "\n"
    txt = txt .. "Pants: " .. tostring(desc.Pants or 0) .. "\n"
    txt = txt .. "Face: " .. tostring(desc.Face or 0) .. "\n\n"

    local accCount = desc.Accessories and #desc.Accessories or 0
    txt = txt .. "-- ACCESSORIES (" .. accCount .. ") --\n"
    if desc.Accessories then
        for i, acc in ipairs(desc.Accessories) do
            txt = txt .. i .. ". " .. acc.AccessoryType
            if acc.IsLayered then txt = txt .. " [L]" end
            txt = txt .. " - " .. acc.AssetId .. "\n"
        end
    end

    txt = txt .. "\n-- SCALES --\n"
    txt = txt .. "Height: " .. string.format("%.2f", desc.HeightScale or 1) .. "\n"
    txt = txt .. "Width: " .. string.format("%.2f", desc.WidthScale or 1) .. "\n"
    txt = txt .. "BodyType: " .. string.format("%.2f", desc.BodyTypeScale or 0) .. "\n"

    InfoLabel.Text = txt
end

local function showPreview(info)
    log("showPreview START:", info.name)
    clearPreview()
    currentPreviewData = info
    PreviewTitle.Text = "🔮 " .. info.name
    PreviewFrame.Visible = true
    log("  PreviewFrame.Visible = true")
    ViewportStatus.Text = "Connecting..."

    -- Info bar
    PreviewNameLabel.Text = info.name
    PreviewTypeLabel.Text = info.type
    PreviewTypeBadge.BackgroundColor3 = info.type == "PLAYER" and Colors.blood or Colors.green

    -- Get real character
    local realChar = info.character
    if info.player and info.player.Character then
        realChar = info.player.Character
    end

    if not realChar or not realChar.Parent then
        log("  Character not found")
        ViewportStatus.Text = "Character not found"
        InfoLabel.Text = ""
        return
    end

    log("  Cloning character...")
    -- Clone character for viewport
    local cloneOk, cloneModel = pcall(function()
        return realChar:Clone()
    end)

    if not cloneOk or not cloneModel then
        log("  Clone FAILED:", tostring(cloneModel))
        ViewportStatus.Text = "Failed to clone"
        InfoLabel.Text = ""
        return
    end
    log("  Clone OK, setting up viewport")

    -- Build part mapping (Clone preserves descendant order)
    local partMap = {}
    local realDescs = realChar:GetDescendants()
    local cloneDescs = cloneModel:GetDescendants()
    for i = 1, math.min(#realDescs, #cloneDescs) do
        local realPart = realDescs[i]
        local clonePart = cloneDescs[i]
        if realPart:IsA("BasePart") and clonePart:IsA("BasePart") then
            partMap[realPart] = clonePart
        end
    end

    -- Camera
    local camera = Instance.new("Camera")
    camera.FieldOfView = 50
    camera.Parent = Viewport
    Viewport.CurrentCamera = camera

    -- WorldModel container
    local worldModel = Instance.new("WorldModel")
    worldModel.Parent = Viewport

    -- Floor plane for visual grounding
    local floor = Instance.new("Part")
    floor.Size = Vector3.new(40, 0.1, 40)
    floor.Position = Vector3.new(0, -3.5, 0)
    floor.Color = Color3.fromRGB(12, 10, 18)
    floor.Material = Enum.Material.SmoothPlastic
    floor.Anchored = true
    floor.CanCollide = false
    floor.Parent = worldModel

    cloneModel.Parent = worldModel

    ViewportStatus.Text = ""
    LiveBadge.Visible = true
    DistLabel.Visible = true

    -- Live sync loop
    local angle = 0
    local livePulse = 0
    previewConnection = RunService.RenderStepped:Connect(function(dt)
        -- Check if real character still exists
        if not realChar or not realChar.Parent then
            ViewportStatus.Text = "Left the game"
            LiveBadge.Text = "● OFF"
            LiveBadge.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
            return
        end

        local realHRP = realChar:FindFirstChild("HumanoidRootPart")
        if not realHRP then return end

        -- Sync all part CFrames (centered at origin)
        local rootCF = realHRP.CFrame
        for realPart, clonePart in pairs(partMap) do
            if realPart.Parent and clonePart.Parent then
                pcall(function()
                    clonePart.CFrame = rootCF:Inverse() * realPart.CFrame
                end)
            end
        end

        -- Camera orbit
        angle = angle + dt * 0.4
        local camDist = 10
        local camHeight = 2.5
        camera.CFrame = CFrame.new(
            Vector3.new(math.sin(angle) * camDist, camHeight, math.cos(angle) * camDist),
            Vector3.new(0, 0.5, 0)
        )

        -- Update distance from local player
        local myHRP = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if myHRP then
            local dist = math.floor((myHRP.Position - realHRP.Position).Magnitude)
            DistLabel.Text = dist .. "m"
        end

        -- Update HP bar
        local hum = realChar:FindFirstChildOfClass("Humanoid")
        if hum then
            local pct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
            PreviewHPFill.Size = UDim2.new(pct, 0, 1, 0)
            if pct > 0.5 then
                PreviewHPFill.BackgroundColor3 = Colors.green
            elseif pct > 0.25 then
                PreviewHPFill.BackgroundColor3 = Colors.warning
            else
                PreviewHPFill.BackgroundColor3 = Colors.glowRed
            end
            PreviewHPLabel.Text = math.floor(hum.Health) .. "/" .. math.floor(hum.MaxHealth)
        end

        -- Pulse LIVE badge
        livePulse = livePulse + dt * 2
        local alpha = (math.sin(livePulse) + 1) / 2
        LiveBadge.BackgroundColor3 = Color3.fromRGB(
            math.floor(140 + alpha * 60),
            math.floor(10 + alpha * 10),
            math.floor(10 + alpha * 10)
        )
    end)

    -- Load rig data and display info
    if not info.loaded then
        InfoLabel.Text = "Loading data..."
        task.spawn(function()
            loadRigData(info)
            if info.cardFrame then
                info.cardFrame.BackgroundColor3 = Colors.cardLoaded
            end
            if info.statusLabel and info.fullDescription then
                local accCount = info.fullDescription.Accessories and #info.fullDescription.Accessories or 0
                info.statusLabel.Text = (info.fullDescription.RigType or "?") .. " | " .. accCount .. " acc"
                info.statusLabel.TextColor3 = Colors.greenLight
            end
            displayPreviewInfo(info)
        end)
    else
        displayPreviewInfo(info)
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

    -- Thumbnail (players only)
    local contentOffsetX = 12
    if info.type == "PLAYER" and info.userId then
        contentOffsetX = 46

        local thumbFrame = Instance.new("Frame")
        thumbFrame.Size = UDim2.new(0, 30, 0, 30)
        thumbFrame.Position = UDim2.new(0, 8, 0, 6)
        thumbFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        thumbFrame.Parent = Card
        Instance.new("UICorner", thumbFrame).CornerRadius = UDim.new(1, 0)
        local tStroke = Instance.new("UIStroke", thumbFrame)
        tStroke.Color = Colors.blood
        tStroke.Thickness = 1

        local thumbImg = Instance.new("ImageLabel")
        thumbImg.Size = UDim2.new(1, 0, 1, 0)
        thumbImg.BackgroundTransparency = 1
        thumbImg.Parent = thumbFrame
        Instance.new("UICorner", thumbImg).CornerRadius = UDim.new(1, 0)

        task.spawn(function()
            local ok, thumb = pcall(function()
                return Players:GetUserThumbnailAsync(info.userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
            end)
            if ok and thumb then thumbImg.Image = thumb end
        end)
    end

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
    NameLabel.Position = UDim2.new(0, contentOffsetX, 0, 5)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Text = info.displayName and (info.displayName .. " @" .. info.name) or info.name
    NameLabel.TextColor3 = Colors.bloodLight
    NameLabel.TextSize = 12
    NameLabel.Font = Enum.Font.GothamBold
    NameLabel.TextXAlignment = Enum.TextXAlignment.Left
    NameLabel.TextTruncate = Enum.TextTruncate.AtEnd
    NameLabel.Parent = Card

    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Size = UDim2.new(1, -10, 0, 14)
    StatusLabel.Position = UDim2.new(0, contentOffsetX, 0, 22)
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
        log("VIEW clicked:", info.name)
        local ok, err = pcall(showPreview, info)
        if not ok then
            log("showPreview ERROR:", tostring(err))
            notify("Preview error: " .. tostring(err):sub(1, 60), "error")
        end
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

    -- Shadow button (players only)
    if info.type == "PLAYER" and info.player then
        local ShadowResultBtn = Instance.new("TextButton")
        ShadowResultBtn.Size = UDim2.new(0, 52, 0, 20)
        ShadowResultBtn.Position = UDim2.new(0, 184, 1, -26)
        ShadowResultBtn.BackgroundColor3 = Colors.glowPurple
        ShadowResultBtn.Text = "SHADOW"
        ShadowResultBtn.TextColor3 = Colors.text
        ShadowResultBtn.TextSize = 9
        ShadowResultBtn.Font = Enum.Font.GothamBold
        ShadowResultBtn.AutoButtonColor = false
        ShadowResultBtn.Parent = Card
        Instance.new("UICorner", ShadowResultBtn).CornerRadius = UDim.new(0, 4)
        makeHoverable(ShadowResultBtn, Colors.glowPurple, Colors.purpleLight)

        ShadowResultBtn.MouseButton1Click:Connect(function()
            openShadowPanel(info.player)
        end)
    end

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
                displayName = player.DisplayName,
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
                local matchName = info.name:lower():find(text, 1, true) ~= nil
                local matchDisplay = info.displayName and info.displayName:lower():find(text, 1, true) ~= nil
                info.cardFrame.Visible = matchName or matchDisplay
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
                            displayName = player.DisplayName,
                            type = "PLAYER",
                            character = char,
                            player = player,
                            userId = player.UserId,
                            loaded = false,
                        }
                        table.insert(allScannedRigs, info)
                        scannedPlayerSet[player] = info
                        createResultCard(info)
                        notify(player.DisplayName .. " joined", "info")
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
        card.Size = UDim2.new(1, -10, 0, 94)
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

        -- Shadow button
        local shadowBtn = Instance.new("TextButton")
        shadowBtn.Size = UDim2.new(0, 52, 0, 18)
        shadowBtn.Position = UDim2.new(1, -80, 0, 30)
        shadowBtn.BackgroundColor3 = Colors.glowPurple
        shadowBtn.Text = "SHADOW"
        shadowBtn.TextColor3 = Colors.text
        shadowBtn.TextSize = 8
        shadowBtn.Font = Enum.Font.GothamBold
        shadowBtn.AutoButtonColor = false
        shadowBtn.Parent = card
        Instance.new("UICorner", shadowBtn).CornerRadius = UDim.new(0, 4)
        makeHoverable(shadowBtn, Colors.glowPurple, Colors.purpleLight)

        shadowBtn.MouseButton1Click:Connect(function()
            openShadowPanel(player)
        end)

        -- Fling button
        local flingBtn = Instance.new("TextButton")
        flingBtn.Size = UDim2.new(0, 36, 0, 18)
        flingBtn.Position = UDim2.new(1, -80, 0, 50)
        flingBtn.BackgroundColor3 = Colors.glowRed
        flingBtn.Text = "FLING"
        flingBtn.TextColor3 = Colors.text
        flingBtn.TextSize = 8
        flingBtn.Font = Enum.Font.GothamBold
        flingBtn.AutoButtonColor = false
        flingBtn.Parent = card
        Instance.new("UICorner", flingBtn).CornerRadius = UDim.new(0, 4)
        makeHoverable(flingBtn, Colors.glowRed, Color3.fromRGB(255, 80, 80))

        flingBtn.MouseButton1Click:Connect(function()
            flingPlayer(player)
        end)

        -- Headsit button
        local headsitBtn = Instance.new("TextButton")
        headsitBtn.Size = UDim2.new(0, 36, 0, 18)
        headsitBtn.Position = UDim2.new(1, -40, 0, 50)
        headsitBtn.BackgroundColor3 = Colors.warning
        headsitBtn.Text = "HEAD"
        headsitBtn.TextColor3 = Colors.bg
        headsitBtn.TextSize = 8
        headsitBtn.Font = Enum.Font.GothamBold
        headsitBtn.AutoButtonColor = false
        headsitBtn.Parent = card
        Instance.new("UICorner", headsitBtn).CornerRadius = UDim.new(0, 4)
        makeHoverable(headsitBtn, Colors.warning, Color3.fromRGB(230, 180, 60))

        headsitBtn.MouseButton1Click:Connect(function()
            headsitPlayer(player)
        end)

        -- Bang button
        local bangBtn = Instance.new("TextButton")
        bangBtn.Size = UDim2.new(0, 36, 0, 18)
        bangBtn.Position = UDim2.new(1, -80, 0, 70)
        bangBtn.BackgroundColor3 = Colors.purple
        bangBtn.Text = "BANG"
        bangBtn.TextColor3 = Colors.text
        bangBtn.TextSize = 8
        bangBtn.Font = Enum.Font.GothamBold
        bangBtn.AutoButtonColor = false
        bangBtn.Parent = card
        Instance.new("UICorner", bangBtn).CornerRadius = UDim.new(0, 4)
        makeHoverable(bangBtn, Colors.purple, Colors.purpleLight)

        bangBtn.MouseButton1Click:Connect(function()
            bangPlayer(player)
        end)

        -- Backpack button
        local backBtn = Instance.new("TextButton")
        backBtn.Size = UDim2.new(0, 36, 0, 18)
        backBtn.Position = UDim2.new(1, -40, 0, 70)
        backBtn.BackgroundColor3 = Color3.fromRGB(40, 100, 120)
        backBtn.Text = "BACK"
        backBtn.TextColor3 = Colors.text
        backBtn.TextSize = 8
        backBtn.Font = Enum.Font.GothamBold
        backBtn.AutoButtonColor = false
        backBtn.Parent = card
        Instance.new("UICorner", backBtn).CornerRadius = UDim.new(0, 4)
        makeHoverable(backBtn, Color3.fromRGB(40, 100, 120), Color3.fromRGB(60, 130, 150))

        backBtn.MouseButton1Click:Connect(function()
            backpackPlayer(player)
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

    -- Highlight (respects config)
    if spectateHighlight then
        spectateHighlight:Destroy()
        spectateHighlight = nil
    end
    if spectateConfig.showHighlight then
        spectateHighlight = Instance.new("Highlight")
        spectateHighlight.Name = "VampSpectateHL"
        spectateHighlight.FillColor = Colors.blood
        spectateHighlight.FillTransparency = 0.7
        spectateHighlight.OutlineColor = Colors.bloodLight
        spectateHighlight.OutlineTransparency = 0
        spectateHighlight.Adornee = targetChar
        spectateHighlight.Parent = targetChar
    end

    local specLabel = "🦇 UNSPECTATE (" .. info.name .. ")"
    UnspectateBtn.Visible = true
    UnspectateBtn.Text = specLabel
    PlayerUnspectateBtn.Visible = true
    PlayerUnspectateBtn.Text = specLabel

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
    PlayerUnspectateBtn.Visible = false

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
        hum.UseJumpPower = true
        hum.JumpPower = movementState.jumpPower
    end
end

--==================================================
-- FLY
--==================================================

startFly = function()
    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then
        notify("No character found", "error")
        return
    end

    -- Clean up old
    if flyBG then pcall(function() flyBG:Destroy() end) end
    if flyBV then pcall(function() flyBV:Destroy() end) end

    -- Disable falling animation
    hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
    hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    hum:ChangeState(Enum.HumanoidStateType.Physics)

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
        -- Keep humanoid from falling state
        if hum:GetState() == Enum.HumanoidStateType.Freefall then
            hum:ChangeState(Enum.HumanoidStateType.Physics)
        end

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

    -- Re-enable falling states
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
    end

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
        mouseBehavior = UIS.MouseBehavior,
        mouseIcon = UIS.MouseIconEnabled,
    }
    cam.CameraType = Enum.CameraType.Scriptable

    -- Extract initial yaw/pitch from current camera
    local rx, ry, _ = cam.CFrame:ToEulerAnglesYXZ()
    local yaw = ry
    local pitch = rx
    local sensitivity = 0.003

    -- Lock mouse to center + hide cursor
    UIS.MouseBehavior = Enum.MouseBehavior.LockCenter
    UIS.MouseIconEnabled = false

    -- Anchor character so it doesn't move while in freecam
    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.Anchored = true
    end

    freecamConnection = RunService.RenderStepped:Connect(function(dt)
        -- Mouse rotation
        local delta = UIS:GetMouseDelta()
        yaw = yaw - delta.X * sensitivity
        pitch = math.clamp(pitch - delta.Y * sensitivity, -math.rad(89), math.rad(89))

        local rotation = CFrame.fromEulerAnglesYXZ(pitch, yaw, 0)

        -- Movement
        local speed = movementState.speed * 2
        local move = Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then move = move + rotation.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then move = move - rotation.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then move = move - rotation.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then move = move + rotation.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.yAxis end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.yAxis end

        local pos = cam.CFrame.Position
        if move.Magnitude > 0 then
            pos = pos + move.Unit * speed * dt
        end

        cam.CFrame = CFrame.new(pos) * rotation
    end)

    notify("Freecam ON (mouse to look)", "success")
    log("Freecam ON")
end

stopFreecam = function()
    if freecamConnection then
        freecamConnection:Disconnect()
        freecamConnection = nil
    end

    -- Unanchor character
    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.Anchored = false
    end

    local cam = workspace.CurrentCamera
    if savedCameraState then
        cam.CameraType = savedCameraState.ctype
        cam.CameraSubject = savedCameraState.subject
        UIS.MouseBehavior = savedCameraState.mouseBehavior
        UIS.MouseIconEnabled = savedCameraState.mouseIcon
        savedCameraState = nil
    end
    notify("Freecam OFF", "info")
    log("Freecam OFF")
end


--[[ ═══════ MODULE: 21_emote_shadow.luau ═══════ ]]

--==================================================
-- EMOTE LOGIC
--==================================================

playEmote = function(animId)
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then
        notify("No character", "error")
        return
    end

    local animator = hum:FindFirstChildOfClass("Animator")
    if not animator then
        animator = Instance.new("Animator", hum)
    end

    -- Stop current emote
    if currentEmoteTrack then
        pcall(function() currentEmoteTrack:Stop() end)
        pcall(function() currentEmoteTrack:Destroy() end)
        currentEmoteTrack = nil
    end

    local animIdStr = "rbxassetid://" .. tostring(animId)

    -- Try to resolve bundle/emote asset → actual animation ID
    pcall(function()
        local objects = game:GetObjects(animIdStr)
        if objects and #objects > 0 then
            local obj = objects[1]
            if obj:IsA("Animation") then
                animIdStr = obj.AnimationId
            else
                for _, desc in ipairs(obj:GetDescendants()) do
                    if desc:IsA("Animation") then
                        animIdStr = desc.AnimationId
                        break
                    end
                end
            end
            pcall(function() obj:Destroy() end)
        end
    end)

    local anim = Instance.new("Animation")
    anim.AnimationId = animIdStr

    local ok, track = pcall(function()
        return animator:LoadAnimation(anim)
    end)

    if ok and track then
        track.Priority = Enum.AnimationPriority.Action
        track:Play()
        currentEmoteTrack = track
        emotePaused = false
        notify("Playing emote", "success")
        log("Emote playing:", animIdStr)
    else
        notify("Failed to load animation", "error")
        log("Emote error:", tostring(track))
    end

    anim:Destroy()
end

stopEmote = function()
    if currentEmoteTrack then
        pcall(function() currentEmoteTrack:Stop() end)
        pcall(function() currentEmoteTrack:Destroy() end)
        currentEmoteTrack = nil
        emotePaused = false
        notify("Emote stopped", "info")
    end
end

pauseEmote = function()
    if currentEmoteTrack and not emotePaused then
        pcall(function()
            currentEmoteTrack:AdjustSpeed(0)
        end)
        emotePaused = true
        notify("Emote paused", "info")
    end
end

resumeEmote = function()
    if currentEmoteTrack and emotePaused then
        pcall(function()
            currentEmoteTrack:AdjustSpeed(1)
        end)
        emotePaused = false
        notify("Emote resumed", "success")
    end
end

--==================================================
-- SHADOW LOGIC
--==================================================

startShadow = function(mode)
    if shadowConnection then
        shadowConnection:Disconnect()
        shadowConnection = nil
    end

    local target = shadowState.target
    if not target or not target.Character then
        notify("Select a shadow target first", "error")
        return
    end

    shadowState.active = true
    shadowState.mode = mode
    shadowHistory = {}
    refreshShadowModeButtons()

    -- Disable falling on local character
    local myChar = LP.Character
    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    if myHum then
        myHum:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
        myHum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    end

    -- Animation mirroring state (global so stopShadow can clean up)
    shadowMirroredTracks = {}
    local lastAnimSync = 0

    -- Apply trail if enabled
    if shadowState.trail then
        applyShadowTrail()
    end

    shadowConnection = RunService.Heartbeat:Connect(function()
        local targetChar = target.Character
        if not targetChar or not targetChar.Parent then
            stopShadow()
            notify("Shadow target left", "error")
            return
        end

        myChar = LP.Character
        local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
        if not myHRP or not targetHRP then return end

        -- Prevent falling state
        myHum = myChar:FindFirstChildOfClass("Humanoid")
        if myHum and myHum:GetState() == Enum.HumanoidStateType.Freefall then
            myHum:ChangeState(Enum.HumanoidStateType.Physics)
        end

        local dist = shadowState.distance

        if shadowState.mode == "head" then
            -- Sit on head
            local head = targetChar:FindFirstChild("Head")
            if head then
                myHRP.CFrame = head.CFrame * CFrame.new(0, 1.8, 0)
            end

        elseif shadowState.mode == "orbit" then
            -- Angle-based orbit positioning
            local targetCF = targetHRP.CFrame
            local useCF = targetCF

            if shadowState.delay > 0 then
                -- Store history
                table.insert(shadowHistory, { time = tick(), cf = targetCF })

                -- Find position from delay seconds ago
                local targetTime = tick() - shadowState.delay
                local delayCF = nil
                local cleanIdx = 0
                for i = #shadowHistory, 1, -1 do
                    if shadowHistory[i].time <= targetTime then
                        delayCF = shadowHistory[i].cf
                        cleanIdx = i
                        break
                    end
                end

                -- Clean old entries (keep last 300 max)
                if cleanIdx > 1 then
                    for _ = 1, cleanIdx - 1 do
                        table.remove(shadowHistory, 1)
                    end
                elseif #shadowHistory > 300 then
                    table.remove(shadowHistory, 1)
                end

                useCF = delayCF or targetCF
            end

            local angleRad = math.rad(shadowState.angle)
            local offsetX = math.sin(angleRad) * dist
            local offsetZ = math.cos(angleRad) * dist
            local orbitCF = useCF * CFrame.new(offsetX, shadowState.height, offsetZ)

            if shadowState.faceTarget then
                myHRP.CFrame = CFrame.lookAt(orbitCF.Position, targetHRP.Position)
            else
                myHRP.CFrame = orbitCF
            end
        end

        -- Auto-orbit: increment angle over time
        if shadowState.autoOrbit and shadowState.mode == "orbit" then
            shadowState.angle = (shadowState.angle + shadowState.orbitSpeed * 0.5) % 360
        end

        -- Record target path if recording
        if shadowRecording and targetHRP then
            table.insert(shadowRecordedPath, { time = tick(), cf = targetHRP.CFrame })
            -- Limit recording to ~1800 frames (~30s at 60fps)
            if #shadowRecordedPath > 1800 then
                table.remove(shadowRecordedPath, 1)
            end
        end

        -- Mirror target animations (~every 0.3s) — only if enabled
        local now = tick()
        if shadowState.mirrorAnims and now - lastAnimSync > 0.3 then
            lastAnimSync = now
            local targetHum = targetChar:FindFirstChildOfClass("Humanoid")
            if myHum and targetHum then
                local myAnimator = myHum:FindFirstChildOfClass("Animator")
                local targetAnimator = targetHum:FindFirstChildOfClass("Animator")
                if myAnimator and targetAnimator then
                    pcall(function()
                        local targetTracks = targetAnimator:GetPlayingAnimationTracks()
                        local targetIds = {}
                        for _, t in ipairs(targetTracks) do
                            if t.Animation then
                                targetIds[t.Animation.AnimationId] = t.Priority
                            end
                        end
                        -- Stop tracks target isn't playing
                        for id, track in pairs(shadowMirroredTracks) do
                            if not targetIds[id] then
                                pcall(function() track:Stop() end)
                                pcall(function() track:Destroy() end)
                                shadowMirroredTracks[id] = nil
                            end
                        end
                        -- Play tracks target IS playing
                        for id, priority in pairs(targetIds) do
                            if not shadowMirroredTracks[id] then
                                local anim = Instance.new("Animation")
                                anim.AnimationId = id
                                local ok2, myTrack = pcall(function()
                                    return myAnimator:LoadAnimation(anim)
                                end)
                                if ok2 and myTrack then
                                    myTrack.Priority = priority
                                    myTrack:Play()
                                    shadowMirroredTracks[id] = myTrack
                                end
                                anim:Destroy()
                            end
                        end
                    end)
                end
            end
        end
    end)

    local modeLabel = mode == "head" and "head" or ("orbit " .. shadowState.angle .. "°")
    notify("Shadow: " .. modeLabel .. " on " .. target.Name, "success")
    log("Shadow started:", modeLabel, target.Name)
end

stopShadow = function()
    shadowState.active = false
    shadowState.autoOrbit = false
    if shadowConnection then
        shadowConnection:Disconnect()
        shadowConnection = nil
    end
    shadowHistory = {}

    -- Stop and destroy all mirrored animation tracks
    if shadowMirroredTracks then
        for id, track in pairs(shadowMirroredTracks) do
            pcall(function() track:Stop() end)
            pcall(function() track:Destroy() end)
        end
        shadowMirroredTracks = {}
    end

    refreshShadowModeButtons()

    -- Re-enable falling states + force idle animation restart
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)

        -- Stop ALL playing animation tracks so Animate script restarts idle
        local animator = hum:FindFirstChildOfClass("Animator")
        if animator then
            pcall(function()
                for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                    track:Stop(0)
                end
            end)
        end

        -- Reset Animate script to force idle restart
        local animScript = char:FindFirstChild("Animate")
        if animScript then
            pcall(function()
                animScript.Disabled = true
                task.delay(0.1, function()
                    if animScript and animScript.Parent then
                        animScript.Disabled = false
                    end
                end)
            end)
        end
    end

    -- Remove trail
    removeShadowTrail()

    notify("Shadow stopped", "info")
    log("Shadow stopped")
end

--==================================================
-- SHADOW TRAIL
--==================================================

applyShadowTrail = function()
    removeShadowTrail()
    local char = LP.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local att0 = Instance.new("Attachment")
    att0.Name = "VampTrailAtt0"
    att0.Position = Vector3.new(0, 0, 0.5)
    att0.Parent = hrp

    local att1 = Instance.new("Attachment")
    att1.Name = "VampTrailAtt1"
    att1.Position = Vector3.new(0, 0, -0.5)
    att1.Parent = hrp

    shadowTrailInstance = Instance.new("Trail")
    shadowTrailInstance.Name = "VampShadowTrail"
    shadowTrailInstance.Attachment0 = att0
    shadowTrailInstance.Attachment1 = att1
    shadowTrailInstance.Lifetime = 1.5
    shadowTrailInstance.MinLength = 0.1
    shadowTrailInstance.FaceCamera = true
    shadowTrailInstance.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Colors.glowPurple),
        ColorSequenceKeypoint.new(0.5, Colors.blood),
        ColorSequenceKeypoint.new(1, Colors.bloodDark),
    })
    shadowTrailInstance.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.3),
        NumberSequenceKeypoint.new(0.5, 0.6),
        NumberSequenceKeypoint.new(1, 1),
    })
    shadowTrailInstance.WidthScale = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(1, 0.2),
    })
    shadowTrailInstance.Parent = hrp
end

removeShadowTrail = function()
    if shadowTrailInstance then
        pcall(function() shadowTrailInstance:Destroy() end)
        shadowTrailInstance = nil
    end
    local char = LP.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            for _, att in ipairs(hrp:GetChildren()) do
                if att.Name == "VampTrailAtt0" or att.Name == "VampTrailAtt1" then
                    att:Destroy()
                end
            end
        end
    end
end

--==================================================
-- SHADOW RECORD & REPLAY
--==================================================

startShadowRecording = function()
    shadowRecordedPath = {}
    shadowRecording = true
    ShadowRecBtn.Text = "⏹ STOP"
    ShadowRecBtn.BackgroundColor3 = Colors.glowRed
    notify("Recording path...", "info")
end

stopShadowRecording = function()
    shadowRecording = false
    ShadowRecBtn.Text = "⏺ REC"
    ShadowRecBtn.BackgroundColor3 = Colors.blood
    notify("Path recorded (" .. #shadowRecordedPath .. " frames)", "success")
end

startShadowReplay = function()
    if #shadowRecordedPath == 0 then
        notify("No recorded path — hit REC first", "warning")
        return
    end

    -- Stop current shadow if active
    if shadowState.active then
        stopShadow()
    end

    shadowReplaying = true
    ShadowPlayReplayBtn.Text = "⏹ STOP"
    ShadowPlayReplayBtn.BackgroundColor3 = Colors.bloodDark

    -- Disable falling
    local myChar = LP.Character
    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    if myHum then
        myHum:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
        myHum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    end

    -- Apply trail if enabled
    if shadowState.trail then
        applyShadowTrail()
    end

    -- Calculate path duration from recorded timestamps
    local startTime = shadowRecordedPath[1].time
    local endTime = shadowRecordedPath[#shadowRecordedPath].time
    local duration = endTime - startTime

    shadowReplayConnection = RunService.Heartbeat:Connect(function()
        if not shadowReplaying then return end

        myChar = LP.Character
        local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end

        -- Prevent falling
        myHum = myChar:FindFirstChildOfClass("Humanoid")
        if myHum and myHum:GetState() == Enum.HumanoidStateType.Freefall then
            myHum:ChangeState(Enum.HumanoidStateType.Physics)
        end

        -- Loop through recorded path using elapsed time
        local elapsed = (tick() - startTime) % duration
        local targetTime = startTime + elapsed

        -- Find closest frame
        local bestCF = shadowRecordedPath[1].cf
        for i = #shadowRecordedPath, 1, -1 do
            if shadowRecordedPath[i].time <= targetTime + startTime then
                bestCF = shadowRecordedPath[i].cf
                break
            end
        end

        myHRP.CFrame = bestCF
    end)

    notify("Replaying recorded path (loop)", "success")
end

stopShadowReplay = function()
    shadowReplaying = false
    if shadowReplayConnection then
        shadowReplayConnection:Disconnect()
        shadowReplayConnection = nil
    end
    ShadowPlayReplayBtn.Text = "▶ REPLAY"
    ShadowPlayReplayBtn.BackgroundColor3 = Colors.green

    -- Re-enable falling + restore idle
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
    end

    removeShadowTrail()
    notify("Replay stopped", "info")
end

--==================================================
-- TROLL FEATURES
--==================================================

flingPlayer = function(player)
    local targetChar = player.Character
    if not targetChar then
        notify("No character found", "error")
        return
    end
    local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
    local myChar = LP.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not targetHRP or not myHRP then
        notify("Missing HumanoidRootPart", "error")
        return
    end

    -- TP to target then apply massive velocity
    local savedCF = myHRP.CFrame
    myHRP.CFrame = targetHRP.CFrame * CFrame.new(0, 0, -2)

    task.delay(0.15, function()
        if not myChar or not myChar.Parent then return end
        local bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Velocity = Vector3.new(math.random(-200, 200), 300, math.random(-200, 200))
        bv.Parent = targetHRP
        task.delay(0.3, function()
            pcall(function() bv:Destroy() end)
        end)

        -- TP back
        task.delay(0.5, function()
            if myHRP and myHRP.Parent then
                myHRP.CFrame = savedCF
            end
        end)
    end)

    notify("Fling: " .. player.DisplayName, "success")
end

headsitPlayer = function(player)
    local targetChar = player.Character
    if not targetChar then
        notify("No character found", "error")
        return
    end
    local head = targetChar:FindFirstChild("Head")
    local myChar = LP.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    if not head or not myHRP or not myHum then
        notify("Missing parts", "error")
        return
    end

    -- Quick TP to head and sit
    myHRP.CFrame = head.CFrame * CFrame.new(0, 2, 0)
    myHum.Sit = true
    notify("Headsit: " .. player.DisplayName, "success")
end

--==================================================
-- MORE TROLLS
--==================================================

stopTroll = function()
    if trollConnection then
        pcall(function()
            if typeof(trollConnection) == "RBXScriptConnection" then
                trollConnection:Disconnect()
            else
                task.cancel(trollConnection)
            end
        end)
        trollConnection = nil
    end
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
    end
end

bangPlayer = function(player)
    stopTroll()
    local targetChar = player.Character
    if not targetChar then notify("No character", "error") return end
    local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
    local myChar = LP.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    if not targetHRP or not myHRP or not myHum then return end

    myHum:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
    myHum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)

    local t = 0
    trollConnection = RunService.Heartbeat:Connect(function()
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            stopTroll()
            return
        end
        myChar = LP.Character
        myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end

        targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
        t = t + 1
        -- Pump motion: oscillate forward/backward in front of target
        local offset = math.sin(t * 0.3) * 1.5
        local frontCF = targetHRP.CFrame * CFrame.new(0, 0, -2 - offset)
        myHRP.CFrame = CFrame.lookAt(frontCF.Position, targetHRP.Position)
    end)
    notify("Bang: " .. player.DisplayName, "success")
end

orbitTrollPlayer = function(player)
    stopTroll()
    local targetChar = player.Character
    if not targetChar then notify("No character", "error") return end
    local myChar = LP.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    if not myHRP or not myHum then return end

    myHum:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
    myHum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)

    local angle = 0
    trollConnection = RunService.Heartbeat:Connect(function()
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            stopTroll()
            return
        end
        myChar = LP.Character
        myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end

        local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
        angle = (angle + 15) % 360
        local rad = math.rad(angle)
        local pos = targetHRP.CFrame * CFrame.new(math.sin(rad) * 3, 0, math.cos(rad) * 3)
        myHRP.CFrame = CFrame.lookAt(pos.Position, targetHRP.Position)
    end)
    notify("Orbit troll: " .. player.DisplayName, "success")
end

backpackPlayer = function(player)
    stopTroll()
    local targetChar = player.Character
    if not targetChar then notify("No character", "error") return end
    local myChar = LP.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    if not myHRP or not myHum then return end

    myHum:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
    myHum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)

    trollConnection = RunService.Heartbeat:Connect(function()
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            stopTroll()
            return
        end
        myChar = LP.Character
        myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end

        local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
        myHRP.CFrame = targetHRP.CFrame * CFrame.new(0, 1.5, 1)
    end)
    notify("Backpack: " .. player.DisplayName, "success")
end

flingAllPlayers = function()
    local myChar = LP.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end

    local savedCF = myHRP.CFrame
    local count = 0

    task.spawn(function()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LP and player.Character then
                local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
                if targetHRP then
                    myHRP.CFrame = targetHRP.CFrame * CFrame.new(0, 0, -2)
                    task.wait(0.15)
                    local bv = Instance.new("BodyVelocity")
                    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                    bv.Velocity = Vector3.new(math.random(-200, 200), 300, math.random(-200, 200))
                    bv.Parent = targetHRP
                    task.delay(0.3, function()
                        pcall(function() bv:Destroy() end)
                    end)
                    count = count + 1
                    task.wait(0.3)
                end
            end
        end
        task.wait(0.2)
        if myHRP and myHRP.Parent then
            myHRP.CFrame = savedCF
        end
        notify("Flung " .. count .. " players!", "success")
    end)
end

--==================================================
-- COSMETICS
--==================================================

applyCosmeticHeadless = function()
    local char = LP.Character
    if not char then return end
    local head = char:FindFirstChild("Head")
    if head then
        head.Transparency = 1
        local face = head:FindFirstChildOfClass("Decal") or head:FindFirstChild("face") or head:FindFirstChild("Face")
        if face then face.Transparency = 1 end
        for _, child in ipairs(head:GetChildren()) do
            if child:IsA("SpecialMesh") then
                child.Scale = Vector3.new(0, 0, 0)
            end
        end
    end
    -- Hide hat/hair accessories
    for _, acc in ipairs(char:GetChildren()) do
        if acc:IsA("Accessory") then
            local handle = acc:FindFirstChild("Handle")
            if handle then
                local att = handle:FindFirstChildOfClass("Attachment")
                if att and (att.Name:find("Hat") or att.Name:find("Hair") or att.Name:find("Face")) then
                    handle.Transparency = 1
                end
            end
        end
    end
    cosmeticState.headless = true
    notify("Headless applied", "success")
end

removeCosmeticHeadless = function()
    local char = LP.Character
    if not char then return end
    local head = char:FindFirstChild("Head")
    if head then
        head.Transparency = 0
        local face = head:FindFirstChildOfClass("Decal") or head:FindFirstChild("face") or head:FindFirstChild("Face")
        if face then face.Transparency = 0 end
        for _, child in ipairs(head:GetChildren()) do
            if child:IsA("SpecialMesh") then
                child.Scale = Vector3.new(1, 1, 1)
            end
        end
    end
    for _, acc in ipairs(char:GetChildren()) do
        if acc:IsA("Accessory") then
            local handle = acc:FindFirstChild("Handle")
            if handle then handle.Transparency = 0 end
        end
    end
    cosmeticState.headless = false
    notify("Headless removed", "info")
end

applyCosmeticInvisible = function()
    local char = LP.Character
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = 1
        elseif part:IsA("Decal") or part:IsA("Texture") then
            part.Transparency = 1
        end
    end
    cosmeticState.invisible = true
    notify("Invisible applied", "success")
end

removeCosmeticInvisible = function()
    local char = LP.Character
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.Transparency = 0
        elseif part:IsA("Decal") then
            part.Transparency = 0
        end
    end
    cosmeticState.invisible = false
    notify("Visible again", "info")
end

applyCosmeticGhost = function()
    local char = LP.Character
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.Transparency = 0.7
        end
    end
    cosmeticState.ghost = true
    notify("Ghost mode applied", "success")
end

removeCosmeticGhost = function()
    local char = LP.Character
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.Transparency = 0
        end
    end
    cosmeticState.ghost = false
    notify("Ghost removed", "info")
end

resetAllCosmetics = function()
    if cosmeticState.headless then removeCosmeticHeadless() end
    if cosmeticState.invisible then removeCosmeticInvisible() end
    if cosmeticState.ghost then removeCosmeticGhost() end
    notify("All cosmetics reset", "info")
end

--==================================================
-- EMOTE CATALOG SEARCH
--==================================================

searchEmoteCatalog = function(keyword)
    emoteSearchVersion = emoteSearchVersion + 1
    local thisVersion = emoteSearchVersion

    -- Clear grid
    for _, child in pairs(EmoteCatalogGrid:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextButton") then child:Destroy() end
    end

    EmoteCatalogEmpty.Visible = false

    if keyword == nil or keyword == "" then
        -- Re-show trending if user clears search
        emoteTabPreloaded = false
        preloadTrendingEmotes()
        return
    end

    EmoteCatalogEmpty.Text = "Searching..."
    EmoteCatalogEmpty.Visible = true

    task.spawn(function()
        local params = CatalogSearchParams.new()
        params.AssetTypes = { Enum.AvatarAssetType.EmoteAnimation }
        params.SortType = Enum.CatalogSortType.Relevance
        params.SearchKeyword = keyword

        local ok, pages = pcall(function()
            return AvatarEditorService:SearchCatalog(params)
        end)

        if emoteSearchVersion ~= thisVersion then return end

        if not ok or not pages then
            EmoteCatalogEmpty.Text = "Search failed (AvatarEditorService)"
            EmoteCatalogEmpty.Visible = true
            log("Emote search failed:", tostring(pages))
            return
        end

        local pageOk, items = pcall(function()
            return pages:GetCurrentPage()
        end)

        if not pageOk or not items or #items == 0 then
            EmoteCatalogEmpty.Text = "No emotes found"
            EmoteCatalogEmpty.Visible = true
            return
        end

        EmoteCatalogEmpty.Visible = false
        emoteCatalogPages = pages
        emoteCatalogHasMore = not pages.IsFinished

        populateEmoteCatalogGrid(items, false)
    end)
end

populateEmoteCatalogGrid = function(items, append)
    if not append then
        for _, child in pairs(EmoteCatalogGrid:GetChildren()) do
            if child:IsA("Frame") or child:IsA("TextButton") then child:Destroy() end
        end
    end

    for _, item in ipairs(items) do
        local card = Instance.new("TextButton")
        card.Size = UDim2.new(0, 60, 0, 82)
        card.BackgroundColor3 = Colors.card
        card.AutoButtonColor = false
        card.BorderSizePixel = 0
        card.Text = ""
        card.Parent = EmoteCatalogGrid
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 6)

        -- Thumbnail
        local isBundle = item.BundleType ~= nil
        local thumbType = isBundle and "BundleThumbnail" or "Asset"
        local thumb = Instance.new("ImageLabel")
        thumb.Size = UDim2.new(1, -4, 0, 52)
        thumb.Position = UDim2.new(0, 2, 0, 2)
        thumb.BackgroundTransparency = 1
        thumb.Image = "rbxthumb://type=" .. thumbType .. "&id=" .. tostring(item.Id) .. "&w=150&h=150"
        thumb.ScaleType = Enum.ScaleType.Fit
        thumb.Parent = card

        -- Name label
        local nameL = Instance.new("TextLabel")
        nameL.Size = UDim2.new(1, -4, 0, 24)
        nameL.Position = UDim2.new(0, 2, 0, 56)
        nameL.BackgroundTransparency = 1
        nameL.Text = item.Name or "Emote"
        nameL.TextColor3 = Colors.textDim
        nameL.TextSize = 8
        nameL.Font = Enum.Font.GothamBold
        nameL.TextXAlignment = Enum.TextXAlignment.Center
        nameL.TextTruncate = Enum.TextTruncate.AtEnd
        nameL.TextWrapped = true
        nameL.Parent = card

        -- Favorite star button
        local isFav = isFavoriteEmote(item.Id)
        local starBtn = Instance.new("TextButton")
        starBtn.Size = UDim2.new(0, 16, 0, 16)
        starBtn.Position = UDim2.new(1, -18, 0, 64)
        starBtn.BackgroundTransparency = 1
        starBtn.Text = isFav and "★" or "☆"
        starBtn.TextSize = 12
        starBtn.TextColor3 = isFav and Color3.fromRGB(255, 200, 50) or Colors.textDim
        starBtn.Parent = card

        starBtn.MouseButton1Click:Connect(function()
            local added = toggleFavoriteEmote(item.Id, item.Name or "Emote", isBundle)
            starBtn.Text = added and "★" or "☆"
            starBtn.TextColor3 = added and Color3.fromRGB(255, 200, 50) or Colors.textDim
        end)

        -- Click to play
        card.MouseButton1Click:Connect(function()
            playEmote(item.Id)
        end)

        makeHoverable(card, Colors.card, Colors.surfaceLight)
    end

    -- Update grid height based on content
    local childCount = 0
    for _, child in pairs(EmoteCatalogGrid:GetChildren()) do
        if child:IsA("TextButton") then childCount = childCount + 1 end
    end
    local cols = math.max(1, math.floor(EmoteCatalogGrid.AbsoluteSize.X / 66))
    if cols < 1 then cols = 5 end
    local rows = math.ceil(childCount / cols)
    EmoteCatalogGrid.Size = UDim2.new(1, 0, 0, math.max(rows * 88, 88))

    -- Refresh scroll canvas
    recalcEmoteLayout()
end

loadMoreEmotes = function()
    if not emoteCatalogHasMore or not emoteCatalogPages or isLoadingMoreEmotes then return end
    isLoadingMoreEmotes = true

    task.spawn(function()
        local ok = pcall(function()
            emoteCatalogPages:AdvanceToNextPageAsync()
        end)
        if not ok then
            isLoadingMoreEmotes = false
            return
        end

        local pageOk, items = pcall(function()
            return emoteCatalogPages:GetCurrentPage()
        end)

        isLoadingMoreEmotes = false

        if not pageOk or not items or #items == 0 then
            emoteCatalogHasMore = false
            return
        end

        emoteCatalogHasMore = not emoteCatalogPages.IsFinished
        populateEmoteCatalogGrid(items, true)
    end)
end

--==================================================
-- PRE-LOAD POPULAR EMOTES
--==================================================

preloadTrendingEmotes = function()
    if emoteTabPreloaded then return end
    emoteTabPreloaded = true

    EmoteCatalogEmpty.Text = "Loading popular emotes..."
    EmoteCatalogEmpty.Visible = true

    -- Clear grid
    for _, child in pairs(EmoteCatalogGrid:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextButton") then child:Destroy() end
    end

    emoteSearchVersion = emoteSearchVersion + 1
    local thisVersion = emoteSearchVersion

    task.spawn(function()
        local params = CatalogSearchParams.new()
        params.AssetTypes = { Enum.AvatarAssetType.EmoteAnimation }
        params.SortType = Enum.CatalogSortType.MostFavorited

        local ok, pages = pcall(function()
            return AvatarEditorService:SearchCatalog(params)
        end)

        if emoteSearchVersion ~= thisVersion then return end

        if not ok or not pages then
            EmoteCatalogEmpty.Text = "Failed to load popular emotes"
            EmoteCatalogEmpty.Visible = true
            emoteTabPreloaded = false
            return
        end

        local pageOk, items = pcall(function()
            return pages:GetCurrentPage()
        end)

        if not pageOk or not items or #items == 0 then
            EmoteCatalogEmpty.Text = "No popular emotes found"
            EmoteCatalogEmpty.Visible = true
            return
        end

        EmoteCatalogEmpty.Visible = false
        emoteCatalogPages = pages
        emoteCatalogHasMore = not pages.IsFinished

        populateEmoteCatalogGrid(items, false)
    end)
end

--==================================================
-- FAVORITE EMOTES
--==================================================

loadFavoriteEmotes = function()
    favoriteEmotes = {}
    pcall(function()
        if isfile and isfile("VampireFavoriteEmotes.json") then
            local raw = readfile("VampireFavoriteEmotes.json")
            local parsed = HttpService:JSONDecode(raw)
            if type(parsed) == "table" then
                favoriteEmotes = parsed
            end
        end
    end)
    refreshFavoriteGrid()
end

saveFavoriteEmotes = function()
    pcall(function()
        if writefile then
            writefile("VampireFavoriteEmotes.json", HttpService:JSONEncode(favoriteEmotes))
        end
    end)
end

toggleFavoriteEmote = function(id, name, isBundle)
    -- Check if already favorited
    for i, fav in ipairs(favoriteEmotes) do
        if fav.id == id then
            table.remove(favoriteEmotes, i)
            saveFavoriteEmotes()
            refreshFavoriteGrid()
            notify("Removed from favorites", "info")
            return false
        end
    end
    -- Add new favorite
    table.insert(favoriteEmotes, { id = id, name = name, isBundle = isBundle or false })
    saveFavoriteEmotes()
    refreshFavoriteGrid()
    notify("Added to favorites!", "success")
    return true
end

isFavoriteEmote = function(id)
    for _, fav in ipairs(favoriteEmotes) do
        if fav.id == id then return true end
    end
    return false
end

refreshFavoriteGrid = function()
    -- Clear existing children
    for _, child in pairs(EmoteFavGrid:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextButton") then child:Destroy() end
    end

    if #favoriteEmotes == 0 then
        EmoteFavEmpty.Visible = true
        EmoteFavGrid.Size = UDim2.new(1, 0, 0, 24)
    else
        EmoteFavEmpty.Visible = false

        for idx, fav in ipairs(favoriteEmotes) do
            local card = Instance.new("TextButton")
            card.Size = UDim2.new(0, 60, 0, 82)
            card.BackgroundColor3 = Colors.card
            card.AutoButtonColor = false
            card.BorderSizePixel = 0
            card.Text = ""
            card.LayoutOrder = idx
            card.Parent = EmoteFavGrid
            Instance.new("UICorner", card).CornerRadius = UDim.new(0, 6)

            -- Thumbnail
            local thumbType = fav.isBundle and "BundleThumbnail" or "Asset"
            local thumb = Instance.new("ImageLabel")
            thumb.Size = UDim2.new(1, -4, 0, 44)
            thumb.Position = UDim2.new(0, 2, 0, 2)
            thumb.BackgroundTransparency = 1
            thumb.Image = "rbxthumb://type=" .. thumbType .. "&id=" .. tostring(fav.id) .. "&w=150&h=150"
            thumb.ScaleType = Enum.ScaleType.Fit
            thumb.Parent = card

            -- Name label
            local nameL = Instance.new("TextLabel")
            nameL.Size = UDim2.new(1, -4, 0, 18)
            nameL.Position = UDim2.new(0, 2, 0, 48)
            nameL.BackgroundTransparency = 1
            nameL.Text = fav.name or "Emote"
            nameL.TextColor3 = Colors.textDim
            nameL.TextSize = 8
            nameL.Font = Enum.Font.GothamBold
            nameL.TextXAlignment = Enum.TextXAlignment.Center
            nameL.TextTruncate = Enum.TextTruncate.AtEnd
            nameL.TextWrapped = true
            nameL.Parent = card

            -- Unfavorite star button
            local starBtn = Instance.new("TextButton")
            starBtn.Size = UDim2.new(0, 16, 0, 16)
            starBtn.Position = UDim2.new(1, -18, 0, 64)
            starBtn.BackgroundTransparency = 1
            starBtn.Text = "★"
            starBtn.TextSize = 12
            starBtn.TextColor3 = Color3.fromRGB(255, 200, 50)
            starBtn.Parent = card

            starBtn.MouseButton1Click:Connect(function()
                toggleFavoriteEmote(fav.id, fav.name, fav.isBundle)
            end)

            -- Click card to play
            card.MouseButton1Click:Connect(function()
                playEmote(fav.id)
            end)

            makeHoverable(card, Colors.card, Colors.surfaceLight)
        end

        -- Calculate grid height
        local cols = math.max(1, math.floor(EmoteFavGrid.AbsoluteSize.X / 66))
        if cols < 1 then cols = 3 end
        local rows = math.ceil(#favoriteEmotes / cols)
        EmoteFavGrid.Size = UDim2.new(1, 0, 0, math.max(rows * 88, 88))
    end

    -- Recalculate layout of everything below favorites
    recalcEmoteLayout()
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

-- Unspectate (scanner + player tabs)
UnspectateBtn.MouseButton1Click:Connect(function()
    stopSpectate()
end)

PlayerUnspectateBtn.MouseButton1Click:Connect(function()
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
-- EMOTE TAB EVENTS
--==================================================

-- Custom animation ID
PlayCustomBtn.MouseButton1Click:Connect(function()
    local id = tonumber(CustomIDInput.Text)
    if id then
        playEmote(id)
    else
        notify("Enter a valid animation ID", "warning")
    end
end)

CustomIDInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local id = tonumber(CustomIDInput.Text)
        if id then playEmote(id) end
    end
end)

PauseEmoteBtn.MouseButton1Click:Connect(function()
    if emotePaused then
        resumeEmote()
        PauseEmoteBtn.Text = "⏸ PAUSE"
        PauseEmoteBtn.BackgroundColor3 = Colors.warning
    else
        pauseEmote()
        PauseEmoteBtn.Text = "▶ RESUME"
        PauseEmoteBtn.BackgroundColor3 = Colors.green
    end
end)

StopEmoteBtn.MouseButton1Click:Connect(function()
    stopEmote()
    PauseEmoteBtn.Text = "⏸ PAUSE"
    PauseEmoteBtn.BackgroundColor3 = Colors.warning
end)

-- Emote catalog search (debounced 0.4s)
do
    local emoteSearchTimer = nil
    EmoteSearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        if emoteSearchTimer then
            task.cancel(emoteSearchTimer)
        end
        emoteSearchTimer = task.delay(0.4, function()
            emoteSearchTimer = nil
            searchEmoteCatalog(EmoteSearchBox.Text)
        end)
    end)
end

-- Emote catalog scroll pagination (load more near bottom)
EmoteScroll:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
    local scrollPos = EmoteScroll.CanvasPosition.Y
    local canvasH = EmoteScroll.CanvasSize.Y.Offset
    local frameH = EmoteScroll.AbsoluteSize.Y
    if canvasH > 0 and (scrollPos + frameH) >= (canvasH - 60) then
        loadMoreEmotes()
    end
end)

--==================================================
-- SHADOW PANEL EVENTS
--==================================================

-- Shadow preset buttons
for _, data in ipairs(shadowPresetButtons) do
    data.btn.MouseButton1Click:Connect(function()
        local def = data.def
        if def.mode == "head" then
            if shadowState.active and shadowState.mode == "head" then
                stopShadow()
            else
                startShadow("head")
            end
        else
            -- Orbit mode: set angle, height, faceTarget, then start
            shadowState.angle = def.angle
            shadowState.height = def.height
            shadowState.faceTarget = def.faceTarget
            ShadowPanelAngleSlider.setValue(def.angle)
            ShadowPanelHeightSlider.setValue(def.height)
            ShadowFaceTargetToggle.refresh()
            startShadow("orbit")
        end
    end)
end

-- Face Target toggle
ShadowFaceTargetToggle.btn.MouseButton1Click:Connect(function()
    shadowState.faceTarget = not shadowState.faceTarget
    ShadowFaceTargetToggle.refresh()
end)

-- Mirror Anims toggle
ShadowMirrorAnimsToggle.btn.MouseButton1Click:Connect(function()
    shadowState.mirrorAnims = not shadowState.mirrorAnims
    ShadowMirrorAnimsToggle.refresh()
    -- If turning off mirror, clean up existing mirrored tracks
    if not shadowState.mirrorAnims and shadowMirroredTracks then
        for id, track in pairs(shadowMirroredTracks) do
            pcall(function() track:Stop() end)
            pcall(function() track:Destroy() end)
        end
        shadowMirroredTracks = {}
        -- Restart idle animation
        local char = LP.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            local animator = hum:FindFirstChildOfClass("Animator")
            if animator then
                pcall(function()
                    for _, t in ipairs(animator:GetPlayingAnimationTracks()) do
                        t:Stop(0)
                    end
                end)
            end
            local animScript = char:FindFirstChild("Animate")
            if animScript then
                pcall(function()
                    animScript.Disabled = true
                    task.delay(0.1, function()
                        if animScript and animScript.Parent then
                            animScript.Disabled = false
                        end
                    end)
                end)
            end
        end
    end
end)

-- Auto-Orbit toggle
ShadowAutoOrbitToggle.btn.MouseButton1Click:Connect(function()
    shadowState.autoOrbit = not shadowState.autoOrbit
    ShadowAutoOrbitToggle.refresh()
end)

-- Trail toggle
ShadowTrailToggle.btn.MouseButton1Click:Connect(function()
    shadowState.trail = not shadowState.trail
    ShadowTrailToggle.refresh()
    if shadowState.trail and shadowState.active then
        applyShadowTrail()
    elseif not shadowState.trail then
        removeShadowTrail()
    end
end)

-- Record button
ShadowRecBtn.MouseButton1Click:Connect(function()
    if shadowRecording then
        stopShadowRecording()
    else
        if not shadowState.active then
            notify("Start shadow first to record", "warning")
            return
        end
        startShadowRecording()
    end
end)

-- Replay button
ShadowPlayReplayBtn.MouseButton1Click:Connect(function()
    if shadowReplaying then
        stopShadowReplay()
    else
        startShadowReplay()
    end
end)

-- Reset button — resets all shadow settings to defaults
ShadowResetBtn.MouseButton1Click:Connect(function()
    shadowState.angle = 0
    shadowState.height = 0
    shadowState.distance = 4
    shadowState.delay = 0
    shadowState.faceTarget = false
    shadowState.mirrorAnims = true
    shadowState.autoOrbit = false
    shadowState.orbitSpeed = 2
    shadowState.trail = false
    -- Sync UI
    ShadowPanelAngleSlider.setValue(0)
    ShadowPanelHeightSlider.setValue(0)
    ShadowPanelDistSlider.setValue(4)
    ShadowPanelDelaySlider.setValue(0)
    ShadowOrbitSpeedSlider.setValue(2)
    ShadowFaceTargetToggle.refresh()
    ShadowMirrorAnimsToggle.refresh()
    ShadowAutoOrbitToggle.refresh()
    ShadowTrailToggle.refresh()
    refreshShadowModeButtons()
    removeShadowTrail()
    notify("Shadow settings reset", "info")
end)

StopShadowBtn.MouseButton1Click:Connect(function()
    if shadowRecording then stopShadowRecording() end
    if shadowReplaying then stopShadowReplay() end
    stopShadow()
    ShadowMirrorAnimsToggle.refresh()
    ShadowAutoOrbitToggle.refresh()
    ShadowTrailToggle.refresh()
end)

ShadowPanelClose.MouseButton1Click:Connect(function()
    if shadowRecording then stopShadowRecording() end
    if shadowReplaying then stopShadowReplay() end
    stopShadow()
    ShadowMirrorAnimsToggle.refresh()
    ShadowAutoOrbitToggle.refresh()
    ShadowPanel.Visible = false
end)

--==================================================
-- PLAYER TAB TROLL EVENTS
--==================================================

StopTrollBtn.MouseButton1Click:Connect(function()
    stopTroll()
    notify("Troll stopped", "info")
end)

FlingAllBtn.MouseButton1Click:Connect(function()
    flingAllPlayers()
end)

--==================================================
-- SETTINGS TAB EVENTS
--==================================================

spectateHLToggle.btn.MouseButton1Click:Connect(function()
    spectateConfig.showHighlight = not spectateConfig.showHighlight
    spectateHLToggle.refresh()
    -- Apply immediately if spectating
    if spectatingInfo then
        if spectateConfig.showHighlight then
            local targetChar = spectatingInfo.character
            if spectatingInfo.player and spectatingInfo.player.Character then
                targetChar = spectatingInfo.player.Character
            end
            if targetChar and not spectateHighlight then
                spectateHighlight = Instance.new("Highlight")
                spectateHighlight.Name = "VampSpectateHL"
                spectateHighlight.FillColor = Colors.blood
                spectateHighlight.FillTransparency = 0.7
                spectateHighlight.OutlineColor = Colors.bloodLight
                spectateHighlight.OutlineTransparency = 0
                spectateHighlight.Adornee = targetChar
                spectateHighlight.Parent = targetChar
            end
        else
            if spectateHighlight then
                spectateHighlight:Destroy()
                spectateHighlight = nil
            end
        end
    end
end)

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

--==================================================
-- COSMETIC EVENTS
--==================================================

cosmeticHeadlessToggle.btn.MouseButton1Click:Connect(function()
    if cosmeticState.headless then
        removeCosmeticHeadless()
    else
        applyCosmeticHeadless()
    end
    cosmeticHeadlessToggle.refresh()
end)

cosmeticInvisibleToggle.btn.MouseButton1Click:Connect(function()
    if cosmeticState.invisible then
        removeCosmeticInvisible()
    else
        -- Turn off ghost if going invisible
        if cosmeticState.ghost then
            removeCosmeticGhost()
            cosmeticGhostToggle.refresh()
        end
        applyCosmeticInvisible()
    end
    cosmeticInvisibleToggle.refresh()
end)

cosmeticGhostToggle.btn.MouseButton1Click:Connect(function()
    if cosmeticState.ghost then
        removeCosmeticGhost()
    else
        -- Turn off invisible if going ghost
        if cosmeticState.invisible then
            removeCosmeticInvisible()
            cosmeticInvisibleToggle.refresh()
        end
        applyCosmeticGhost()
    end
    cosmeticGhostToggle.refresh()
end)

CosmeticResetBtn.MouseButton1Click:Connect(function()
    resetAllCosmetics()
    cosmeticHeadlessToggle.refresh()
    cosmeticInvisibleToggle.refresh()
    cosmeticGhostToggle.refresh()
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
    stopEmote()
    stopTroll()
    resetAllCosmetics()
    if shadowRecording then stopShadowRecording() end
    if shadowReplaying then stopShadowReplay() end
    stopShadow()
    ShadowPanel.Visible = false
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

-- Ctrl+G = toggle abrir/fechar | N = toggle freecam
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == HOTKEY then
        if REQUIRE_CTRL and (UIS:IsKeyDown(Enum.KeyCode.LeftControl) or UIS:IsKeyDown(Enum.KeyCode.RightControl)) then
            toggleScanner()
        elseif not REQUIRE_CTRL then
            toggleScanner()
        end
    elseif input.KeyCode == Enum.KeyCode.N then
        movementState.freecam = not movementState.freecam
        moveToggles.freecam.refresh()
        if movementState.freecam then
            startFreecam()
        else
            stopFreecam()
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

    -- Pre-load trending emotes + favorites on emote tab open
    if tabId == "emote" then
        preloadTrendingEmotes()
        if #favoriteEmotes == 0 then
            loadFavoriteEmotes()
        end
    end
end

--==================================================
-- VAMPIRE NAMETAG
--==================================================

local function createVampireNametag(char)
    if not char then return end
    local head = char:WaitForChild("Head", 5)
    if not head then return end

    -- Remove existing
    local existing = head:FindFirstChild("VampNametag")
    if existing then existing:Destroy() end

    local bb = Instance.new("BillboardGui")
    bb.Name = "VampNametag"
    bb.Size = UDim2.new(0, 300, 0, 60)
    bb.StudsOffset = Vector3.new(0, 2.5, 0)
    bb.AlwaysOnTop = false
    bb.Adornee = head
    bb.Parent = head

    -- Background card
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 0, 40)
    bg.Position = UDim2.new(0, 0, 0.5, -20)
    bg.BackgroundColor3 = Color3.fromRGB(15, 8, 12)
    bg.BackgroundTransparency = 0.2
    bg.BorderSizePixel = 0
    bg.Parent = bb
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 8)

    local bgStroke = Instance.new("UIStroke", bg)
    bgStroke.Color = Colors.blood
    bgStroke.Thickness = 1.8
    bgStroke.Transparency = 0.3

    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Colors.bloodDark),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(15, 8, 12)),
        ColorSequenceKeypoint.new(1, Colors.bloodDark),
    })
    grad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.4),
        NumberSequenceKeypoint.new(0.5, 0.15),
        NumberSequenceKeypoint.new(1, 0.4),
    })
    grad.Parent = bg

    -- Nametag text
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "🦇 Vampire Tester ❤"
    label.TextColor3 = Colors.bloodLight
    label.TextStrokeColor3 = Color3.fromRGB(40, 0, 0)
    label.TextStrokeTransparency = 0.4
    label.TextSize = 22
    label.Font = Enum.Font.GothamBold
    label.Parent = bg
end

-- Apply nametag on current + future characters
if LP.Character then
    task.spawn(function()
        createVampireNametag(LP.Character)
    end)
end
LP.CharacterAdded:Connect(function(char)
    task.spawn(function()
        createVampireNametag(char)
    end)
end)

--==================================================
-- INIT
--==================================================

-- Load favorite emotes from file
loadFavoriteEmotes()

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

