--==================================================
-- VAMPIRE RIG SCANNER v12 - PREMIUM UI
-- Create By VampireSonata
-- Gera o rig no preview ao inves de clonar!
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


--[[ ═══════ MODULE: 02_minibar.luau ═══════ ]]

--==================================================
-- MINI BAR (widget no canto)
--==================================================

local MiniBar = Instance.new("TextButton")
MiniBar.Name = "MiniBar"
MiniBar.Size = UDim2.new(0, 210, 0, 56)
MiniBar.Position = UDim2.new(1, 0, 1, -70) -- começa fora da tela (direita)
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
Instance.new("UICorner", AvatarFrame).CornerRadius = UDim.new(1, 0) -- circulo
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
MiniTitle.Text = "🦇 Vampire Rigs"
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


--[[ ═══════ MODULE: 03_mainframe.luau ═══════ ]]

--==================================================
-- MAIN FRAME
--==================================================

local MainFrame = Instance.new("Frame")
MainFrame.Name = "Main"
MainFrame.Size = UDim2.new(0, 320, 0, 480)
MainFrame.Position = UDim2.new(0.3, 0, 0.5, -240)
MainFrame.BackgroundColor3 = Colors.bg
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local mainStroke = Instance.new("UIStroke", MainFrame)
mainStroke.Color = Colors.blood
mainStroke.Thickness = 1.2
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
addGradient(MainFrame, Colors.surfaceLight, Color3.fromRGB(8, 8, 10), 90)

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

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -20, 1, -195)
Content.Position = UDim2.new(0, 10, 0, 50)
Content.BackgroundColor3 = Colors.content
Content.BorderSizePixel = 0
Content.Parent = MainFrame
Instance.new("UICorner", Content).CornerRadius = UDim.new(0, 8)
local contentStroke = Instance.new("UIStroke", Content)
contentStroke.Color = Colors.separator
contentStroke.Thickness = 0.5
contentStroke.Transparency = 0.5

local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -10, 1, -10)
ScrollFrame.Position = UDim2.new(0, 5, 0, 5)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.ScrollBarThickness = 4
ScrollFrame.ScrollBarImageColor3 = Colors.blood
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.Parent = Content

local ListLayout = Instance.new("UIListLayout")
ListLayout.Padding = UDim.new(0, 5)
ListLayout.Parent = ScrollFrame

local BtnFrame = Instance.new("Frame")
BtnFrame.Size = UDim2.new(1, -20, 0, 140)
BtnFrame.Position = UDim2.new(0, 10, 1, -180)
BtnFrame.BackgroundTransparency = 1
BtnFrame.Parent = MainFrame

local ScanBtn = Instance.new("TextButton")
ScanBtn.Size = UDim2.new(1, 0, 0, 32)
ScanBtn.BackgroundColor3 = Colors.blood
ScanBtn.Text = "🩸 SCAN"
ScanBtn.TextColor3 = Colors.text
ScanBtn.TextSize = 14
ScanBtn.Font = Enum.Font.GothamBold
ScanBtn.AutoButtonColor = false
ScanBtn.Parent = BtnFrame
Instance.new("UICorner", ScanBtn).CornerRadius = UDim.new(0, 6)
addBtnGradient(ScanBtn)
makeHoverable(ScanBtn, Colors.blood, Colors.glowRed)

local ExportAllBtn = Instance.new("TextButton")
ExportAllBtn.Size = UDim2.new(1, 0, 0, 30)
ExportAllBtn.Position = UDim2.new(0, 0, 0, 37)
ExportAllBtn.BackgroundColor3 = Colors.bloodDark
ExportAllBtn.Text = "🦇 EXPORT ALL JSON"
ExportAllBtn.TextColor3 = Colors.text
ExportAllBtn.TextSize = 13
ExportAllBtn.Font = Enum.Font.GothamBold
ExportAllBtn.AutoButtonColor = false
ExportAllBtn.Parent = BtnFrame
Instance.new("UICorner", ExportAllBtn).CornerRadius = UDim.new(0, 6)
addBtnGradient(ExportAllBtn)
makeHoverable(ExportAllBtn, Colors.bloodDark, Colors.blood)

local SaveInstanceBtn = Instance.new("TextButton")
SaveInstanceBtn.Size = UDim2.new(0.5, -3, 0, 30)
SaveInstanceBtn.Position = UDim2.new(0, 0, 0, 72)
SaveInstanceBtn.BackgroundColor3 = Colors.purple
SaveInstanceBtn.Text = "💾 SAVE INSTANCE"
SaveInstanceBtn.TextColor3 = Colors.text
SaveInstanceBtn.TextSize = 11
SaveInstanceBtn.Font = Enum.Font.GothamBold
SaveInstanceBtn.AutoButtonColor = false
SaveInstanceBtn.Parent = BtnFrame
Instance.new("UICorner", SaveInstanceBtn).CornerRadius = UDim.new(0, 6)
addBtnGradient(SaveInstanceBtn)
makeHoverable(SaveInstanceBtn, Colors.purple, Colors.purpleLight)

local TracerBtn = Instance.new("TextButton")
TracerBtn.Size = UDim2.new(0.5, -3, 0, 30)
TracerBtn.Position = UDim2.new(0.5, 3, 0, 72)
TracerBtn.BackgroundColor3 = Color3.fromRGB(60, 30, 30)
TracerBtn.Text = "👁 TRACER OFF"
TracerBtn.TextColor3 = Colors.text
TracerBtn.TextSize = 11
TracerBtn.Font = Enum.Font.GothamBold
TracerBtn.AutoButtonColor = false
TracerBtn.Parent = BtnFrame
Instance.new("UICorner", TracerBtn).CornerRadius = UDim.new(0, 6)
addBtnGradient(TracerBtn)

local UnspectateBtn = Instance.new("TextButton")
UnspectateBtn.Size = UDim2.new(1, 0, 0, 28)
UnspectateBtn.Position = UDim2.new(0, 0, 0, 107)
UnspectateBtn.BackgroundColor3 = Colors.blood
UnspectateBtn.Text = "🦇 UNSPECTATE"
UnspectateBtn.TextColor3 = Colors.text
UnspectateBtn.TextSize = 12
UnspectateBtn.Font = Enum.Font.GothamBold
UnspectateBtn.AutoButtonColor = false
UnspectateBtn.Visible = false
UnspectateBtn.Parent = BtnFrame
Instance.new("UICorner", UnspectateBtn).CornerRadius = UDim.new(0, 6)
addBtnGradient(UnspectateBtn)
makeHoverable(UnspectateBtn, Colors.blood, Colors.glowRed)

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


--[[ ═══════ MODULE: 04_preview_ui.luau ═══════ ]]

--==================================================
-- PREVIEW WINDOW
--==================================================

local PreviewFrame = Instance.new("Frame")
PreviewFrame.Name = "Preview"
PreviewFrame.Size = UDim2.new(0, 320, 0, 550)
PreviewFrame.Position = UDim2.new(0.3, 330, 0.5, -275)
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


--[[ ═══════ MODULE: 05_save_panel.luau ═══════ ]]

--==================================================
-- SAVE INSTANCE CONFIG PANEL
--==================================================

local SavePanel = Instance.new("Frame")
SavePanel.Name = "SaveConfig"
SavePanel.Size = UDim2.new(0, 320, 0, 370)
SavePanel.Position = UDim2.new(0.3, 330, 0.5, -200)
SavePanel.BackgroundColor3 = Colors.bg
SavePanel.BorderSizePixel = 0
SavePanel.Visible = false
SavePanel.Parent = ScreenGui

local savePanelStroke = Instance.new("UIStroke", SavePanel)
savePanelStroke.Color = Colors.purple
savePanelStroke.Thickness = 1.2
Instance.new("UICorner", SavePanel).CornerRadius = UDim.new(0, 10)
addGradient(SavePanel, Color3.fromRGB(20, 14, 28), Colors.bg, 90)

local SaveTopBar = Instance.new("Frame")
SaveTopBar.Size = UDim2.new(1, 0, 0, 40)
SaveTopBar.BackgroundColor3 = Colors.topbar
SaveTopBar.BorderSizePixel = 0
SaveTopBar.Parent = SavePanel
Instance.new("UICorner", SaveTopBar).CornerRadius = UDim.new(0, 10)
addGradient(SaveTopBar, Color3.fromRGB(30, 14, 45), Colors.topbar, 0)
addAccentLine(SaveTopBar, UDim2.new(0, 0, 1, -1), Colors.purple)

local SaveTopBarFix = Instance.new("Frame")
SaveTopBarFix.Size = UDim2.new(1, 0, 0, 10)
SaveTopBarFix.Position = UDim2.new(0, 0, 1, -10)
SaveTopBarFix.BackgroundColor3 = Colors.topbar
SaveTopBarFix.BorderSizePixel = 0
SaveTopBarFix.Parent = SaveTopBar

local SaveTitle = Instance.new("TextLabel")
SaveTitle.Size = UDim2.new(1, -80, 1, 0)
SaveTitle.Position = UDim2.new(0, 10, 0, 0)
SaveTitle.BackgroundTransparency = 1
SaveTitle.Text = "💾 Save Instance"
SaveTitle.TextColor3 = Colors.purpleLight
SaveTitle.TextSize = 14
SaveTitle.Font = Enum.Font.GothamBold
SaveTitle.TextXAlignment = Enum.TextXAlignment.Left
SaveTitle.Parent = SaveTopBar

local SavePanelClose = Instance.new("TextButton")
SavePanelClose.Size = UDim2.new(0, 25, 0, 25)
SavePanelClose.Position = UDim2.new(1, -32, 0, 7)
SavePanelClose.BackgroundColor3 = Colors.purple
SavePanelClose.Text = "X"
SavePanelClose.TextColor3 = Colors.text
SavePanelClose.TextSize = 14
SavePanelClose.Font = Enum.Font.GothamBold
SavePanelClose.AutoButtonColor = false
SavePanelClose.Parent = SaveTopBar
Instance.new("UICorner", SavePanelClose).CornerRadius = UDim.new(0, 6)
makeHoverable(SavePanelClose, Colors.purple, Colors.purpleLight)

-- Nome do arquivo
local FileNameLabel = Instance.new("TextLabel")
FileNameLabel.Size = UDim2.new(1, -20, 0, 16)
FileNameLabel.Position = UDim2.new(0, 10, 0, 50)
FileNameLabel.BackgroundTransparency = 1
FileNameLabel.Text = "File name:"
FileNameLabel.TextColor3 = Colors.textDim
FileNameLabel.TextSize = 11
FileNameLabel.Font = Enum.Font.GothamBold
FileNameLabel.TextXAlignment = Enum.TextXAlignment.Left
FileNameLabel.Parent = SavePanel

local FileNameBox = Instance.new("TextBox")
FileNameBox.Size = UDim2.new(1, -20, 0, 30)
FileNameBox.Position = UDim2.new(0, 10, 0, 68)
FileNameBox.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
FileNameBox.Text = ""
FileNameBox.PlaceholderText = "auto: PlaceId_Data"
FileNameBox.TextColor3 = Colors.text
FileNameBox.PlaceholderColor3 = Colors.textDim
FileNameBox.TextSize = 12
FileNameBox.Font = Enum.Font.Code
FileNameBox.ClearTextOnFocus = false
FileNameBox.Parent = SavePanel
Instance.new("UICorner", FileNameBox).CornerRadius = UDim.new(0, 6)
local fileBoxStroke = Instance.new("UIStroke", FileNameBox)
fileBoxStroke.Color = Color3.fromRGB(50, 50, 60)
fileBoxStroke.Thickness = 1

-- Focus glow no input
FileNameBox.Focused:Connect(function()
    TweenService:Create(fileBoxStroke, TweenInfo.new(0.2), {
        Color = Colors.purpleLight,
        Thickness = 1.5,
    }):Play()
end)
FileNameBox.FocusLost:Connect(function()
    TweenService:Create(fileBoxStroke, TweenInfo.new(0.3), {
        Color = Color3.fromRGB(50, 50, 60),
        Thickness = 1,
    }):Play()
end)

-- Toggles container
local ToggleStart = 110
local saveConfigState = {
    DecompileMode = false,
    SavePlayers = false,
    RemovePlayerCharacters = true,
    NilInstances = false,
    SaveNonCreatable = false,
    IsolateLocalPlayer = false,
    SaveCameraInstances = false,
}

local toggleButtons = {}

local function createToggle(label, key, yPos)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -20, 0, 28)
    row.Position = UDim2.new(0, 10, 0, yPos)
    row.BackgroundTransparency = 1
    row.Parent = SavePanel

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
        local on = saveConfigState[key]
        btn.Text = on and "ON" or "OFF"
        local targetColor = on and Colors.green or Color3.fromRGB(50, 25, 25)
        TweenService:Create(btn, TweenInfo.new(0.15), {
            BackgroundColor3 = targetColor,
        }):Play()
        btn.TextColor3 = Colors.text
    end

    btn.MouseButton1Click:Connect(function()
        saveConfigState[key] = not saveConfigState[key]
        refresh()
    end)

    -- Hover effect
    local function getColor()
        return saveConfigState[key] and Colors.green or Color3.fromRGB(50, 25, 25)
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
    toggleButtons[key] = { btn = btn, lbl = lbl, refresh = refresh }
end

createToggle("Decompile Scripts", "DecompileMode", ToggleStart)
createToggle("Save Players", "SavePlayers", ToggleStart + 30)
createToggle("Remove Characters", "RemovePlayerCharacters", ToggleStart + 60)
createToggle("Nil Instances", "NilInstances", ToggleStart + 90)
createToggle("Non-Creatable", "SaveNonCreatable", ToggleStart + 120)
createToggle("Isolate LocalPlayer", "IsolateLocalPlayer", ToggleStart + 150)
createToggle("Camera Instances", "SaveCameraInstances", ToggleStart + 180)

-- Botao SAVE (usa config dos toggles)
local ConfirmSaveBtn = Instance.new("TextButton")
ConfirmSaveBtn.Size = UDim2.new(0.5, -15, 0, 36)
ConfirmSaveBtn.Position = UDim2.new(0, 10, 1, -50)
ConfirmSaveBtn.BackgroundColor3 = Colors.purple
ConfirmSaveBtn.Text = "💾 SAVE"
ConfirmSaveBtn.TextColor3 = Colors.text
ConfirmSaveBtn.TextSize = 13
ConfirmSaveBtn.Font = Enum.Font.GothamBold
ConfirmSaveBtn.AutoButtonColor = false
ConfirmSaveBtn.Parent = SavePanel
Instance.new("UICorner", ConfirmSaveBtn).CornerRadius = UDim.new(0, 6)
addBtnGradient(ConfirmSaveBtn)
makeHoverable(ConfirmSaveBtn, Colors.purple, Colors.purpleLight)

-- Botao SAVE ALL (ignora config, salva tudo padrao)
local SaveAllBtn = Instance.new("TextButton")
SaveAllBtn.Size = UDim2.new(0.5, -15, 0, 36)
SaveAllBtn.Position = UDim2.new(0.5, 5, 1, -50)
SaveAllBtn.BackgroundColor3 = Colors.green
SaveAllBtn.Text = "⚡ SAVE ALL"
SaveAllBtn.TextColor3 = Colors.text
SaveAllBtn.TextSize = 13
SaveAllBtn.Font = Enum.Font.GothamBold
SaveAllBtn.AutoButtonColor = false
SaveAllBtn.Parent = SavePanel
Instance.new("UICorner", SaveAllBtn).CornerRadius = UDim.new(0, 6)
addBtnGradient(SaveAllBtn)
makeHoverable(SaveAllBtn, Colors.green, Colors.greenLight)


--[[ ═══════ MODULE: 06_helpers.luau ═══════ ]]

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


--[[ ═══════ MODULE: 07_scanner_logic.luau ═══════ ]]

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

    -- Propriedades legacy de acessorios (strings com AssetIds separados por virgula)
    -- Essas propriedades sao scriptable e o engine usa pra posicionar acessorios
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

    -- AccessoryBlob: dados internos de roupas layered
    -- Propriedade NotScriptable — precisa de gethiddenproperty (executor)
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

    -- AccessoryDescriptions: Position/Rotation/Scale de cada acessorio
    -- Esses children do HumanoidDescription contem os ajustes do Avatar Editor
    -- É a forma oficial do Roblox pra persistir posicao customizada
    local adjOk, adjErr = pcall(function()
        local accDescriptions = {}
        for _, child in ipairs(desc:GetChildren()) do
            if child:IsA("AccessoryDescription") and child.AssetId and child.AssetId > 0 then
                local pos = child.Position
                local rot = child.Rotation
                local scl = child.Scale

                -- Só salva se diferente do padrão (0,0,0 / 0,0,0 / 1,1,1)
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

    -- Log resumo
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

    -- Atualiza referencia se for player
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

    -- Pega o HumanoidDescription OBJETO (nao so dados)
    log("  Pegando HumanoidDescription...")
    info.humanoidDescription = getHumanoidDescription(humanoid)

    if info.humanoidDescription then
        log("  HumanoidDescription: OK")
        info.rigType = humanoid.RigType
        info.fullDescription = extractDescriptionData(info.humanoidDescription, humanoid.RigType.Name)

        -- Captura CFrame real dos attachments de cada acessorio RIGIDO no character
        -- Isso preserva posicao/rotacao customizada do Avatar Editor
        -- Cross-referencia com Accessories pra pegar AssetId (gethiddenproperty falha)
        pcall(function()
            -- Mapa de AttachmentName → AccessoryType pra cross-referencia
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

            -- Agrupa AssetIds de acessorios RIGIDOS por tipo (da lista do GetAccessories)
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
                                    -- Cross-referencia pra pegar AssetId da lista de Accessories
                                    typeCounters[accType] = (typeCounters[accType] or 0) + 1
                                    local idx = typeCounters[accType]
                                    local assetId = rigidByType[accType] and rigidByType[accType][idx] or 0

                                    -- So inclui se tem AssetId valido (pula layered sem match)
                                    if assetId ~= 0 then
                                        local cf = att.CFrame
                                        local pos = cf.Position
                                        local rx, ry, rz = cf:ToOrientation()

                                        -- Captura scale uniforme do Handle
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

    -- Salva posicao
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

    -- Usa CreateHumanoidModelFromDescription pra gerar o rig!
    local rigType = info.rigType or Enum.HumanoidRigType.R15

    log("  Gerando rig tipo:", tostring(rigType))

    local success, model = pcall(function()
        return Players:CreateHumanoidModelFromDescription(info.humanoidDescription, rigType)
    end)

    if success and model then
        log("  Rig gerado com sucesso!")

        -- Parenta no workspace temporariamente pra Motor6D resolver as posicoes
        model:PivotTo(CFrame.new(0, -500, 0))
        model.Parent = workspace

        -- Remove scripts antes do wait
        for _, obj in pairs(model:GetDescendants()) do
            if obj:IsA("BaseScript") then
                obj:Destroy()
            end
        end

        -- Espera 1 frame pro Motor6D solver montar o rig corretamente
        task.wait()

        -- Ancora todas as partes DEPOIS do Motor6D resolver
        for _, part in pairs(model:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Anchored = true
            end
        end

        -- Remove do workspace (vai pro ViewportFrame depois)
        model.Parent = nil

        return model
    else
        log("  ERRO ao gerar rig:", tostring(model))
        return nil
    end
end


--[[ ═══════ MODULE: 08_drag.luau ═══════ ]]

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
makeDraggable(SavePanel, SaveTopBar)


--[[ ═══════ MODULE: 09_animations.luau ═══════ ]]

--==================================================
-- ANIMACOES & TOGGLE
--==================================================

local scannerOpen = false
local tweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local tweenInfoIn = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local miniBarTarget = UDim2.new(1, -220, 1, -70) -- posicao inicial (visivel)
local lastMiniBarPos = miniBarTarget -- salva posicao do usuario

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

    -- Salva posicao atual (pode ter sido arrastada)
    lastMiniBarPos = MiniBar.Position

    -- Esconde MiniBar
    MiniBar.Visible = false

    -- Mostra MainFrame com scale + fade
    MainFrame.Visible = true
    MainFrame.Size = UDim2.new(0, 280, 0, 420)
    MainFrame.BackgroundTransparency = 0.3
    local openTween = TweenService:Create(MainFrame, tweenInfo, {
        Size = UDim2.new(0, 320, 0, 480),
        BackgroundTransparency = 0,
    })
    openTween:Play()

    MiniHint.Text = "Ctrl+G to close"
end

local function closeScanner()
    if not scannerOpen then return end
    scannerOpen = false

    -- Fecha sub-paineis
    PreviewFrame.Visible = false
    SavePanel.Visible = false

    -- Anima MainFrame saindo
    local closeTween = TweenService:Create(MainFrame, tweenInfoIn, {
        Size = UDim2.new(0, 280, 0, 420),
        BackgroundTransparency = 0.5,
    })
    closeTween:Play()
    closeTween.Completed:Connect(function()
        if not scannerOpen then
            MainFrame.Visible = false
            -- Reseta tamanho pra proxima abertura
            MainFrame.Size = UDim2.new(0, 320, 0, 480)
            MainFrame.BackgroundTransparency = 0
        end
    end)

    -- Traz MiniBar de volta na posicao que o usuario deixou
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


--[[ ═══════ MODULE: 10_preview.luau ═══════ ]]

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

    -- Carrega dados se necessario
    if not info.loaded then
        log("  Carregando dados...")
        task.spawn(function()
            local success = loadRigData(info)

            if success then
                -- Atualiza card
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

    -- GERAR RIG PARA PREVIEW
    log("  Gerando preview...")
    ViewportStatus.Text = "Gerando rig..."

    task.spawn(function()
        local previewModel = generatePreviewRig(info)

        if previewModel then
            -- Camera
            local camera = Instance.new("Camera")
            camera.FieldOfView = 50
            camera.Parent = Viewport
            Viewport.CurrentCamera = camera

            -- WorldModel
            local worldModel = Instance.new("WorldModel")
            worldModel.Parent = Viewport
            previewModel.Parent = worldModel

            -- Centraliza (PivotTo preserva joints do R15)
            previewModel:PivotTo(CFrame.new(0, 0, 0))

            -- Rotacao
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

    -- INFO TEXT
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


--[[ ═══════ MODULE: 11_actions.luau ═══════ ]]

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
    else
        CopyBtn.Text = "ERRO"
    end

    task.delay(1.5, function() CopyBtn.Text = "🩸 COPY JSON" end)
end

--==================================================
-- EXPORT ALL
--==================================================

local function exportAllJSON()
    if #allScannedRigs == 0 then
        ExportAllBtn.Text = "ESCANEIE PRIMEIRO"
        task.delay(1.5, function() ExportAllBtn.Text = "🦇 EXPORT ALL JSON" end)
        return
    end

    if isExporting then return end
    isExporting = true

    local total = #allScannedRigs
    local loaded = 0

    for i, info in ipairs(allScannedRigs) do
        ExportAllBtn.Text = "🦇 " .. i .. "/" .. total

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
        exportVersion = "Vampire-v10",
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
            ExportAllBtn.Text = "🦇 " .. loaded .. " RIGS!"
        elseif toclipboard then
            toclipboard(jsonStr)
            ExportAllBtn.Text = "🦇 " .. loaded .. " RIGS!"
        else
            print(jsonStr)
            ExportAllBtn.Text = "VER F9"
        end
    else
        ExportAllBtn.Text = "ERRO"
    end

    task.delay(2, function() ExportAllBtn.Text = "🦇 EXPORT ALL JSON" end)
end

--==================================================
-- SCANNER
--==================================================

local function clearResults()
    for _, child in pairs(ScrollFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    allScannedRigs = {}
end

local function createResultCard(info)
    local accentColor = info.type == "PLAYER" and Colors.blood or Colors.green

    local Card = Instance.new("Frame")
    Card.Size = UDim2.new(1, -10, 0, 70)
    Card.BackgroundColor3 = Colors.card
    Card.BorderSizePixel = 0
    Card.Parent = ScrollFrame
    Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 8)
    addGradient(Card, Colors.surfaceLight, Colors.card, 0)

    -- Card stroke (hidden, shows on hover)
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

    -- Card hover effect
    Card.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            TweenService:Create(cardStroke, TweenInfo.new(0.15), {
                Transparency = 0.3,
            }):Play()
            TweenService:Create(Card, TweenInfo.new(0.15), {
                BackgroundColor3 = Colors.surfaceLight,
            }):Play()
        end
    end)
    Card.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            TweenService:Create(cardStroke, TweenInfo.new(0.2), {
                Transparency = 1,
            }):Play()
            TweenService:Create(Card, TweenInfo.new(0.2), {
                BackgroundColor3 = Colors.card,
            }):Play()
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
    ViewBtn.Size = UDim2.new(0, 50, 0, 20)
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
    TPBtn.Size = UDim2.new(0, 35, 0, 20)
    TPBtn.Position = UDim2.new(0, 67, 1, -26)
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
                myHRP.CFrame = hrp.CFrame * CFrame.new(0, 0, 5)
            end
        end
    end)

    local JSONBtn = Instance.new("TextButton")
    JSONBtn.Size = UDim2.new(0, 40, 0, 20)
    JSONBtn.Position = UDim2.new(0, 107, 1, -26)
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
    SpecBtn.Size = UDim2.new(0, 40, 0, 20)
    SpecBtn.Position = UDim2.new(0, 152, 1, -26)
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
            else
                JSONBtn.Text = "ERR"
            end
        else
            JSONBtn.Text = "ERR"
        end
        task.delay(1, function() JSONBtn.Text = "JSON" end)
    end)
end

local function runScan()
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
                createResultCard(info)
                countN = countN + 1
            end
        end
    end

    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 10)
    Title.Text = "Vampire (" .. countP .. "P | " .. countN .. "N)"
    log("=== SCAN COMPLETO ===")
end


--[[ ═══════ MODULE: 12_spectate.luau ═══════ ]]

--==================================================
-- SPECTATE MODE
--==================================================

local function startSpectate(info)
    -- Pega o character atual do target
    local targetChar = info.character
    if info.player and info.player.Character then
        targetChar = info.player.Character
    end

    if not targetChar then
        log("Spectate: character not found")
        return
    end

    local humanoid = targetChar:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        log("Spectate: no Humanoid found")
        return
    end

    -- Se ja ta spectando o mesmo, desspecta
    if spectatingInfo and spectatingInfo == info then
        stopSpectate()
        return
    end

    -- Limpa spectate anterior
    if spectatingInfo then
        stopSpectate()
    end

    -- Salva camera original
    local camera = workspace.CurrentCamera
    savedCameraSubject = camera.CameraSubject

    -- Seta camera no target
    camera.CameraSubject = humanoid
    spectatingInfo = info

    -- Cria Highlight blood no character
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

    -- Mostra botao unspectate
    UnspectateBtn.Visible = true
    UnspectateBtn.Text = "🦇 UNSPECTATE (" .. info.name .. ")"

    log("Spectating:", info.name)
end

local function stopSpectate()
    if not spectatingInfo then return end

    -- Restaura camera
    local camera = workspace.CurrentCamera
    if savedCameraSubject then
        camera.CameraSubject = savedCameraSubject
        savedCameraSubject = nil
    else
        -- Fallback: volta pro character local
        local localChar = LP.Character
        if localChar then
            local hum = localChar:FindFirstChildOfClass("Humanoid")
            if hum then
                camera.CameraSubject = hum
            end
        end
    end

    -- Remove highlight
    if spectateHighlight then
        spectateHighlight:Destroy()
        spectateHighlight = nil
    end

    spectatingInfo = nil
    UnspectateBtn.Visible = false

    log("Spectate stopped")
end


--[[ ═══════ MODULE: 13_tracer.luau ═══════ ]]

--==================================================
-- TRACER / ESP WALL
--==================================================

local function createESP(target, espName, espColor, isCamera)
    local existing = target:FindFirstChild("VampESP_BG")
    if existing then return end

    -- Highlight outline
    local hl = Instance.new("Highlight")
    hl.Name = "VampESP_HL"
    hl.FillColor = espColor
    hl.FillTransparency = 0.85
    hl.OutlineColor = espColor
    hl.OutlineTransparency = 0.2
    hl.Adornee = target
    hl.Parent = target

    -- BillboardGui com nome e distancia
    local bg = Instance.new("BillboardGui")
    bg.Name = "VampESP_BG"
    bg.Size = UDim2.new(0, 200, 0, 50)
    bg.StudsOffset = Vector3.new(0, isCamera and 2 or 4, 0)
    bg.AlwaysOnTop = true
    bg.Adornee = target
    bg.Parent = target

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "ESPName"
    nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
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
    distLabel.Size = UDim2.new(1, 0, 0.5, 0)
    distLabel.Position = UDim2.new(0, 0, 0.5, 0)
    distLabel.BackgroundTransparency = 1
    distLabel.Text = "? studs"
    distLabel.TextColor3 = Colors.textDim
    distLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    distLabel.TextStrokeTransparency = 0.3
    distLabel.TextSize = 11
    distLabel.Font = Enum.Font.Gotham
    distLabel.Parent = bg

    local typeLabel = Instance.new("TextLabel")
    typeLabel.Name = "ESPType"
    typeLabel.Size = UDim2.new(1, 0, 0, 12)
    typeLabel.Position = UDim2.new(0, 0, 1, 0)
    typeLabel.BackgroundTransparency = 1
    typeLabel.Text = isCamera and "📷 CAMERA" or ""
    typeLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
    typeLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    typeLabel.TextStrokeTransparency = 0.3
    typeLabel.TextSize = 10
    typeLabel.Font = Enum.Font.GothamBold
    typeLabel.Parent = bg

    table.insert(tracerESPs, {
        target = target,
        highlight = hl,
        billboard = bg,
        nameLabel = nameLabel,
        distLabel = distLabel,
        isCamera = isCamera,
    })
end

local function removeESP(target)
    local hl = target:FindFirstChild("VampESP_HL")
    if hl then hl:Destroy() end
    local bg = target:FindFirstChild("VampESP_BG")
    if bg then bg:Destroy() end
end

local function clearTracer()
    -- Desconecta RenderStepped
    if tracerConnection then
        tracerConnection:Disconnect()
        tracerConnection = nil
    end

    -- Remove todos os ESPs
    for _, esp in ipairs(tracerESPs) do
        if esp.target and esp.target.Parent then
            removeESP(esp.target)
        end
    end
    tracerESPs = {}
end

local function startTracer()
    clearTracer()

    local myChar = LP.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")

    -- ESP em todos os players
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LP then
            local char = player.Character
            if char and char:FindFirstChildOfClass("Humanoid") then
                createESP(char, player.Name, Colors.bloodLight, false)
            end
        end
    end

    -- ESP em NPCs (models com Humanoid que nao sao players)
    local playerChars = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p.Character then playerChars[p.Character] = true end
    end

    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") and not playerChars[obj] then
            createESP(obj, obj.Name, Colors.green, false)
        end
    end

    -- ESP em cameras (objetos Camera ou Parts com nome de camera)
    local cameraKeywords = { "camera", "cam", "cctv", "security", "surveillance", "monitor" }
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Camera") and obj ~= workspace.CurrentCamera then
            createESP(obj, obj.Name, Color3.fromRGB(255, 200, 100), true)
        elseif (obj:IsA("BasePart") or obj:IsA("Model")) and not obj:FindFirstChild("VampESP_BG") then
            local lowerName = obj.Name:lower()
            for _, keyword in ipairs(cameraKeywords) do
                if lowerName:find(keyword) then
                    local target = obj:IsA("Model") and obj or obj
                    createESP(target, obj.Name, Color3.fromRGB(255, 200, 100), true)
                    break
                end
            end
        end
    end

    -- Update loop: atualiza distancias
    tracerConnection = RunService.RenderStepped:Connect(function()
        local char = LP.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local myPos = hrp.Position

        for i = #tracerESPs, 1, -1 do
            local esp = tracerESPs[i]
            if not esp.target or not esp.target.Parent then
                -- Target sumiu, limpa
                table.remove(tracerESPs, i)
            else
                local targetPos
                if esp.target:IsA("Model") then
                    local tHRP = esp.target:FindFirstChild("HumanoidRootPart")
                        or esp.target:FindFirstChild("Head")
                        or esp.target.PrimaryPart
                    if tHRP then
                        targetPos = tHRP.Position
                    end
                elseif esp.target:IsA("BasePart") then
                    targetPos = esp.target.Position
                elseif esp.target:IsA("Camera") then
                    targetPos = esp.target.CFrame.Position
                end

                if targetPos then
                    local dist = math.floor((myPos - targetPos).Magnitude)
                    esp.distLabel.Text = dist .. " studs"
                end
            end
        end
    end)

    log("Tracer ON:", #tracerESPs, "targets")
end

local function toggleTracer()
    tracerActive = not tracerActive

    if tracerActive then
        startTracer()
        TracerBtn.Text = "👁 TRACER ON"
        TracerBtn.BackgroundColor3 = Colors.green
    else
        clearTracer()
        TracerBtn.Text = "👁 TRACER OFF"
        TracerBtn.BackgroundColor3 = Color3.fromRGB(60, 30, 30)
    end
end


--[[ ═══════ MODULE: 14_events.luau ═══════ ]]

--==================================================
-- EVENTS
--==================================================

ScanBtn.MouseButton1Click:Connect(runScan)
CopyBtn.MouseButton1Click:Connect(copyToClipboard)
ExportAllBtn.MouseButton1Click:Connect(exportAllJSON)
SaveInstanceBtn.MouseButton1Click:Connect(function()
    SavePanel.Visible = not SavePanel.Visible
end)
SavePanelClose.MouseButton1Click:Connect(function()
    SavePanel.Visible = false
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

-- SAVE (uses toggle config)
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
        else
            log("Save ERROR:", tostring(err))
            ConfirmSaveBtn.Text = "💾 ERR"
        end
        task.delay(3, function() ConfirmSaveBtn.Text = "💾 SAVE" end)
    end)
end)

-- SAVE ALL (ignores config, default options)
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
        else
            log("Save All ERROR:", tostring(err))
            SaveAllBtn.Text = "⚡ ERR"
        end
        task.delay(3, function() SaveAllBtn.Text = "⚡ SAVE ALL" end)
    end)
end)
-- Spectate
UnspectateBtn.MouseButton1Click:Connect(function()
    stopSpectate()
end)

-- Tracer toggle
TracerBtn.MouseButton1Click:Connect(function()
    toggleTracer()
end)

PreviewClose.MouseButton1Click:Connect(function()
    clearPreview()
    PreviewFrame.Visible = false
end)
-- X fecha tudo (destroy)
CloseBtn.MouseButton1Click:Connect(function()
    stopSpectate()
    clearTracer()
    clearPreview()
    clearResults()
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
-- INIT
--==================================================

log("══════════════════════════════════════")
log("VAMPIRE RIG SCANNER v12")
log("Create By VampireSonata")
log("══════════════════════════════════════")
log("MiniBar mode! Ctrl+G to toggle")
log("══════════════════════════════════════")

