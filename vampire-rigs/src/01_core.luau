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
}

--==================================================
-- VARIABLES
--==================================================

local currentPreviewData = nil
local previewConnection = nil
local allScannedRigs = {}
local isExporting = false

-- Spectate state
local spectatingInfo = nil
local spectateHighlight = nil
local savedCameraSubject = nil

-- Tracer/ESP state
local tracerActive = false
local tracerConnection = nil
local tracerESPs = {}

--==================================================
-- UI HELPERS (Premium)
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
