--==================================================
-- VAMPIRE RIG SCANNER v10 - GENERATE RIG PREVIEW
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
    bg = Color3.fromRGB(15, 15, 15),
    topbar = Color3.fromRGB(25, 25, 25),
    content = Color3.fromRGB(10, 10, 10),
    card = Color3.fromRGB(20, 20, 20),
    cardLoaded = Color3.fromRGB(20, 30, 20),

    blood = Color3.fromRGB(139, 0, 0),
    bloodLight = Color3.fromRGB(180, 20, 20),
    bloodDark = Color3.fromRGB(100, 0, 0),

    green = Color3.fromRGB(40, 120, 40),
    greenLight = Color3.fromRGB(60, 150, 60),

    text = Color3.fromRGB(255, 255, 255),
    textDim = Color3.fromRGB(150, 150, 150),
    textBlood = Color3.fromRGB(200, 50, 50),
    textLoading = Color3.fromRGB(255, 200, 100),
}

--==================================================
-- VARIABLES
--==================================================

local currentPreviewData = nil
local previewConnection = nil
local allScannedRigs = {}
local isExporting = false


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
Instance.new("UICorner", MiniBar).CornerRadius = UDim.new(0, 10)
local miniStroke = Instance.new("UIStroke", MiniBar)
miniStroke.Color = Colors.blood
miniStroke.Thickness = 1.5

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

Instance.new("UIStroke", MainFrame).Color = Colors.blood
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Colors.topbar
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 8)

local TopBarFix = Instance.new("Frame")
TopBarFix.Size = UDim2.new(1, 0, 0, 10)
TopBarFix.Position = UDim2.new(0, 0, 1, -10)
TopBarFix.BackgroundColor3 = Colors.topbar
TopBarFix.BorderSizePixel = 0
TopBarFix.Parent = TopBar

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
CloseBtn.Parent = TopBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 4)

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 25, 0, 25)
MinBtn.Position = UDim2.new(1, -62, 0, 7)
MinBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
MinBtn.Text = "-"
MinBtn.TextColor3 = Colors.text
MinBtn.TextSize = 18
MinBtn.Font = Enum.Font.GothamBold
MinBtn.Parent = TopBar
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 4)

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -20, 1, -160)
Content.Position = UDim2.new(0, 10, 0, 50)
Content.BackgroundColor3 = Colors.content
Content.BorderSizePixel = 0
Content.Parent = MainFrame
Instance.new("UICorner", Content).CornerRadius = UDim.new(0, 6)

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
BtnFrame.Size = UDim2.new(1, -20, 0, 105)
BtnFrame.Position = UDim2.new(0, 10, 1, -145)
BtnFrame.BackgroundTransparency = 1
BtnFrame.Parent = MainFrame

local ScanBtn = Instance.new("TextButton")
ScanBtn.Size = UDim2.new(1, 0, 0, 30)
ScanBtn.BackgroundColor3 = Colors.blood
ScanBtn.Text = "🩸 SCAN"
ScanBtn.TextColor3 = Colors.text
ScanBtn.TextSize = 14
ScanBtn.Font = Enum.Font.GothamBold
ScanBtn.Parent = BtnFrame
Instance.new("UICorner", ScanBtn).CornerRadius = UDim.new(0, 6)

local ExportAllBtn = Instance.new("TextButton")
ExportAllBtn.Size = UDim2.new(1, 0, 0, 30)
ExportAllBtn.Position = UDim2.new(0, 0, 0, 35)
ExportAllBtn.BackgroundColor3 = Colors.bloodDark
ExportAllBtn.Text = "🦇 EXPORT ALL JSON"
ExportAllBtn.TextColor3 = Colors.text
ExportAllBtn.TextSize = 14
ExportAllBtn.Font = Enum.Font.GothamBold
ExportAllBtn.Parent = BtnFrame
Instance.new("UICorner", ExportAllBtn).CornerRadius = UDim.new(0, 6)

local SaveInstanceBtn = Instance.new("TextButton")
SaveInstanceBtn.Size = UDim2.new(1, 0, 0, 30)
SaveInstanceBtn.Position = UDim2.new(0, 0, 0, 70)
SaveInstanceBtn.BackgroundColor3 = Color3.fromRGB(80, 40, 120)
SaveInstanceBtn.Text = "💾 SAVE INSTANCE"
SaveInstanceBtn.TextColor3 = Colors.text
SaveInstanceBtn.TextSize = 14
SaveInstanceBtn.Font = Enum.Font.GothamBold
SaveInstanceBtn.Parent = BtnFrame
Instance.new("UICorner", SaveInstanceBtn).CornerRadius = UDim.new(0, 6)

local Footer = Instance.new("Frame")
Footer.Size = UDim2.new(1, 0, 0, 25)
Footer.Position = UDim2.new(0, 0, 1, -25)
Footer.BackgroundColor3 = Colors.topbar
Footer.BorderSizePixel = 0
Footer.Parent = MainFrame
Instance.new("UICorner", Footer).CornerRadius = UDim.new(0, 8)

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

Instance.new("UIStroke", PreviewFrame).Color = Colors.blood
Instance.new("UICorner", PreviewFrame).CornerRadius = UDim.new(0, 8)

local PreviewTopBar = Instance.new("Frame")
PreviewTopBar.Size = UDim2.new(1, 0, 0, 40)
PreviewTopBar.BackgroundColor3 = Colors.topbar
PreviewTopBar.BorderSizePixel = 0
PreviewTopBar.Parent = PreviewFrame
Instance.new("UICorner", PreviewTopBar).CornerRadius = UDim.new(0, 8)

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
PreviewClose.Parent = PreviewTopBar
Instance.new("UICorner", PreviewClose).CornerRadius = UDim.new(0, 4)

local Viewport = Instance.new("ViewportFrame")
Viewport.Size = UDim2.new(1, -20, 0, 200)
Viewport.Position = UDim2.new(0, 10, 0, 50)
Viewport.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
Viewport.BorderSizePixel = 0
Viewport.Ambient = Color3.fromRGB(200, 200, 200)
Viewport.LightColor = Color3.fromRGB(255, 255, 255)
Viewport.LightDirection = Vector3.new(-1, -1, -1)
Viewport.Parent = PreviewFrame
Instance.new("UICorner", Viewport).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", Viewport).Color = Colors.blood

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
CopyBtn.Parent = PreviewFrame
Instance.new("UICorner", CopyBtn).CornerRadius = UDim.new(0, 6)

local PreviewFooter = Instance.new("Frame")
PreviewFooter.Size = UDim2.new(1, 0, 0, 25)
PreviewFooter.Position = UDim2.new(0, 0, 1, -25)
PreviewFooter.BackgroundColor3 = Colors.topbar
PreviewFooter.BorderSizePixel = 0
PreviewFooter.Parent = PreviewFrame
Instance.new("UICorner", PreviewFooter).CornerRadius = UDim.new(0, 8)

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
SavePanel.Size = UDim2.new(0, 320, 0, 430)
SavePanel.Position = UDim2.new(0.3, 330, 0.5, -200)
SavePanel.BackgroundColor3 = Colors.bg
SavePanel.BorderSizePixel = 0
SavePanel.Visible = false
SavePanel.Parent = ScreenGui

Instance.new("UIStroke", SavePanel).Color = Color3.fromRGB(80, 40, 120)
Instance.new("UICorner", SavePanel).CornerRadius = UDim.new(0, 8)

local SaveTopBar = Instance.new("Frame")
SaveTopBar.Size = UDim2.new(1, 0, 0, 40)
SaveTopBar.BackgroundColor3 = Colors.topbar
SaveTopBar.BorderSizePixel = 0
SaveTopBar.Parent = SavePanel
Instance.new("UICorner", SaveTopBar).CornerRadius = UDim.new(0, 8)

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
SaveTitle.TextColor3 = Color3.fromRGB(160, 100, 220)
SaveTitle.TextSize = 14
SaveTitle.Font = Enum.Font.GothamBold
SaveTitle.TextXAlignment = Enum.TextXAlignment.Left
SaveTitle.Parent = SaveTopBar

local SavePanelClose = Instance.new("TextButton")
SavePanelClose.Size = UDim2.new(0, 25, 0, 25)
SavePanelClose.Position = UDim2.new(1, -32, 0, 7)
SavePanelClose.BackgroundColor3 = Color3.fromRGB(80, 40, 120)
SavePanelClose.Text = "X"
SavePanelClose.TextColor3 = Colors.text
SavePanelClose.TextSize = 14
SavePanelClose.Font = Enum.Font.GothamBold
SavePanelClose.Parent = SaveTopBar
Instance.new("UICorner", SavePanelClose).CornerRadius = UDim.new(0, 4)

-- Nome do arquivo
local FileNameLabel = Instance.new("TextLabel")
FileNameLabel.Size = UDim2.new(1, -20, 0, 16)
FileNameLabel.Position = UDim2.new(0, 10, 0, 50)
FileNameLabel.BackgroundTransparency = 1
FileNameLabel.Text = "Nome do arquivo:"
FileNameLabel.TextColor3 = Colors.textDim
FileNameLabel.TextSize = 11
FileNameLabel.Font = Enum.Font.GothamBold
FileNameLabel.TextXAlignment = Enum.TextXAlignment.Left
FileNameLabel.Parent = SavePanel

local FileNameBox = Instance.new("TextBox")
FileNameBox.Size = UDim2.new(1, -20, 0, 30)
FileNameBox.Position = UDim2.new(0, 10, 0, 68)
FileNameBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
FileNameBox.Text = ""
FileNameBox.PlaceholderText = "auto: PlaceId_Data"
FileNameBox.TextColor3 = Colors.text
FileNameBox.PlaceholderColor3 = Colors.textDim
FileNameBox.TextSize = 12
FileNameBox.Font = Enum.Font.Code
FileNameBox.ClearTextOnFocus = false
FileNameBox.Parent = SavePanel
Instance.new("UICorner", FileNameBox).CornerRadius = UDim.new(0, 4)
Instance.new("UIStroke", FileNameBox).Color = Color3.fromRGB(60, 60, 60)

-- Toggles container
local ToggleStart = 110
local saveConfigState = {
    OnlyRigs = false,
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
    btn.Parent = row
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

    local function refresh()
        local on = saveConfigState[key]
        btn.Text = on and "ON" or "OFF"
        btn.BackgroundColor3 = on and Color3.fromRGB(40, 120, 40) or Color3.fromRGB(60, 30, 30)
        btn.TextColor3 = Colors.text
    end

    btn.MouseButton1Click:Connect(function()
        saveConfigState[key] = not saveConfigState[key]
        refresh()
    end)

    refresh()
    toggleButtons[key] = { btn = btn, lbl = lbl, refresh = refresh }
end

-- Acinzenta/desabilita os toggles irrelevantes quando OnlyRigs está ON
local function refreshOnlyRigsState()
    local rigsOn = saveConfigState.OnlyRigs
    local disabledKeys = {
        "DecompileMode", "SavePlayers", "RemovePlayerCharacters",
        "NilInstances", "SaveNonCreatable", "IsolateLocalPlayer", "SaveCameraInstances",
    }
    for _, k in ipairs(disabledKeys) do
        local t = toggleButtons[k]
        if t then
            if rigsOn then
                t.btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                t.btn.TextColor3 = Color3.fromRGB(80, 80, 80)
                t.btn.Text = "—"
                t.btn.Active = false
                t.lbl.TextColor3 = Color3.fromRGB(60, 60, 60)
            else
                t.btn.Active = true
                t.lbl.TextColor3 = Colors.textDim
                t.refresh()
            end
        end
    end
end

createToggle("⚡ Somente Rigs", "OnlyRigs", ToggleStart)
createToggle("Decompile Scripts", "DecompileMode", ToggleStart + 30)
createToggle("Salvar Players", "SavePlayers", ToggleStart + 60)
createToggle("Remover Characters", "RemovePlayerCharacters", ToggleStart + 90)
createToggle("Nil Instances", "NilInstances", ToggleStart + 120)
createToggle("Non-Creatable", "SaveNonCreatable", ToggleStart + 150)
createToggle("Isolar LocalPlayer", "IsolateLocalPlayer", ToggleStart + 180)
createToggle("Camera Instances", "SaveCameraInstances", ToggleStart + 210)

-- Hook: quando OnlyRigs muda, atualiza estado visual dos outros
toggleButtons["OnlyRigs"].btn.MouseButton1Click:Connect(refreshOnlyRigsState)

-- Botao SALVAR
local ConfirmSaveBtn = Instance.new("TextButton")
ConfirmSaveBtn.Size = UDim2.new(1, -20, 0, 36)
ConfirmSaveBtn.Position = UDim2.new(0, 10, 1, -50)
ConfirmSaveBtn.BackgroundColor3 = Color3.fromRGB(80, 40, 120)
ConfirmSaveBtn.Text = "💾 SALVAR AGORA"
ConfirmSaveBtn.TextColor3 = Colors.text
ConfirmSaveBtn.TextSize = 14
ConfirmSaveBtn.Font = Enum.Font.GothamBold
ConfirmSaveBtn.Parent = SavePanel
Instance.new("UICorner", ConfirmSaveBtn).CornerRadius = UDim.new(0, 6)


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
            Color = Colors.bloodLight,
        })
        t1:Play()
        t1.Completed:Wait()
        local t2 = TweenService:Create(avatarStroke, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            Color = Colors.blood,
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

-- MiniBar hover effect
MiniBar.MouseEnter:Connect(function()
    TweenService:Create(miniStroke, TweenInfo.new(0.2), {
        Color = Colors.bloodLight,
        Thickness = 2,
    }):Play()
    TweenService:Create(MiniBar, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(22, 22, 22),
    }):Play()
end)
MiniBar.MouseLeave:Connect(function()
    TweenService:Create(miniStroke, TweenInfo.new(0.3), {
        Color = Colors.blood,
        Thickness = 1.5,
    }):Play()
    TweenService:Create(MiniBar, TweenInfo.new(0.3), {
        BackgroundColor3 = Colors.bg,
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
    local Card = Instance.new("Frame")
    Card.Size = UDim2.new(1, -10, 0, 70)
    Card.BackgroundColor3 = Colors.card
    Card.BorderSizePixel = 0
    Card.Parent = ScrollFrame
    Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 6)

    info.cardFrame = Card

    local TypeBadge = Instance.new("Frame")
    TypeBadge.Size = UDim2.new(0, 50, 0, 16)
    TypeBadge.Position = UDim2.new(1, -58, 0, 5)
    TypeBadge.BackgroundColor3 = info.type == "PLAYER" and Colors.green or Colors.blood
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
    NameLabel.Position = UDim2.new(0, 8, 0, 5)
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
    StatusLabel.Position = UDim2.new(0, 8, 0, 22)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Text = "Clique VIEW"
    StatusLabel.TextColor3 = Colors.textDim
    StatusLabel.TextSize = 10
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    StatusLabel.Parent = Card

    info.statusLabel = StatusLabel

    -- Botoes
    local ViewBtn = Instance.new("TextButton")
    ViewBtn.Size = UDim2.new(0, 50, 0, 20)
    ViewBtn.Position = UDim2.new(0, 8, 1, -26)
    ViewBtn.BackgroundColor3 = Colors.blood
    ViewBtn.Text = "VIEW"
    ViewBtn.TextColor3 = Colors.text
    ViewBtn.TextSize = 10
    ViewBtn.Font = Enum.Font.GothamBold
    ViewBtn.Parent = Card
    Instance.new("UICorner", ViewBtn).CornerRadius = UDim.new(0, 4)

    ViewBtn.MouseButton1Click:Connect(function()
        showPreview(info)
    end)

    local TPBtn = Instance.new("TextButton")
    TPBtn.Size = UDim2.new(0, 35, 0, 20)
    TPBtn.Position = UDim2.new(0, 63, 1, -26)
    TPBtn.BackgroundColor3 = Colors.green
    TPBtn.Text = "TP"
    TPBtn.TextColor3 = Colors.text
    TPBtn.TextSize = 10
    TPBtn.Font = Enum.Font.GothamBold
    TPBtn.Parent = Card
    Instance.new("UICorner", TPBtn).CornerRadius = UDim.new(0, 4)

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
    JSONBtn.Size = UDim2.new(0, 45, 0, 20)
    JSONBtn.Position = UDim2.new(0, 103, 1, -26)
    JSONBtn.BackgroundColor3 = Colors.bloodDark
    JSONBtn.Text = "JSON"
    JSONBtn.TextColor3 = Colors.text
    JSONBtn.TextSize = 10
    JSONBtn.Font = Enum.Font.GothamBold
    JSONBtn.Parent = Card
    Instance.new("UICorner", JSONBtn).CornerRadius = UDim.new(0, 4)

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


--[[ ═══════ MODULE: 12_events.luau ═══════ ]]

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
ConfirmSaveBtn.MouseButton1Click:Connect(function()
    ConfirmSaveBtn.Text = "💾 SALVANDO..."
    task.spawn(function()
        local ok, err = pcall(function()
            local Params = {
                RepoURL = "https://raw.githubusercontent.com/luau/SynSaveInstance/main/",
                SSI = "saveinstance",
            }
            local loader = loadstring(game:HttpGet(Params.RepoURL .. Params.SSI .. ".luau", true), Params.SSI)
            if not loader then error("Falha ao carregar SynSaveInstance") end
            local synsaveinstance = loader()

            -- Monta nome do arquivo
            local fname = FileNameBox.Text
            if fname == "" then
                fname = game.PlaceId .. "_" .. os.date("%Y%m%d_%H%M%S")
            end

            local options = { FileName = fname }

            if saveConfigState.OnlyRigs then
                -- OnlyRigs: saves ONLY rigs (models with Humanoid)
                -- Overrides all other options to avoid conflicts
                local rigs = {}
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") then
                        table.insert(rigs, obj)
                    end
                end
                options.Mode = "custom"
                options.ExtraInstances = rigs
                options.SavePlayers = true
                options.RemovePlayerCharacters = false
                log("OnlyRigs: found " .. #rigs .. " rigs")
            else
                -- Normal mode: uses panel toggles
                options.DecompileMode = saveConfigState.DecompileMode and "decompile" or "none"
                options.SavePlayers = saveConfigState.SavePlayers
                options.RemovePlayerCharacters = saveConfigState.RemovePlayerCharacters
                options.NilInstances = saveConfigState.NilInstances
                options.SaveNonCreatable = saveConfigState.SaveNonCreatable
                options.IsolateLocalPlayer = saveConfigState.IsolateLocalPlayer
                options.SaveCameraInstances = saveConfigState.SaveCameraInstances
            end

            log("SaveInstance options:", HttpService:JSONEncode(options))
            synsaveinstance(options)
        end)
        if ok then
            ConfirmSaveBtn.Text = "💾 SALVO!"
        else
            log("SaveInstance ERRO:", tostring(err))
            ConfirmSaveBtn.Text = "💾 ERRO: " .. tostring(err):sub(1, 30)
        end
        task.delay(3, function() ConfirmSaveBtn.Text = "💾 SALVAR AGORA" end)
    end)
end)
PreviewClose.MouseButton1Click:Connect(function()
    clearPreview()
    PreviewFrame.Visible = false
end)
-- X fecha tudo (destroy)
CloseBtn.MouseButton1Click:Connect(function()
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
log("VAMPIRE RIG SCANNER v10")
log("Create By VampireSonata")
log("══════════════════════════════════════")
log("MiniBar mode! Ctrl+G to toggle")
log("══════════════════════════════════════")

