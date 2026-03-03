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

--==================================================
-- SECURITY TOOLS
--==================================================

createSectionHeader(SettingsScroll, "Security Tools", saveBtnY + 268)

RemoteSpyOpenBtn = Instance.new("TextButton")
RemoteSpyOpenBtn.Size = UDim2.new(1, 0, 0, 28)
RemoteSpyOpenBtn.Position = UDim2.new(0, 0, 0, saveBtnY + 294)
RemoteSpyOpenBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 120)
RemoteSpyOpenBtn.Text = "🕵 OPEN REMOTE SPY"
RemoteSpyOpenBtn.TextColor3 = Colors.text
RemoteSpyOpenBtn.TextSize = 11
RemoteSpyOpenBtn.Font = Enum.Font.GothamBold
RemoteSpyOpenBtn.AutoButtonColor = false
RemoteSpyOpenBtn.Parent = SettingsScroll
Instance.new("UICorner", RemoteSpyOpenBtn).CornerRadius = UDim.new(0, 6)
addBtnGradient(RemoteSpyOpenBtn)
makeHoverable(RemoteSpyOpenBtn, Color3.fromRGB(0, 140, 120), Color3.fromRGB(0, 180, 160))

--==================================================
-- DEV TOOLS
--==================================================

createSectionHeader(SettingsScroll, "Dev Tools", saveBtnY + 334)

-- Anti-AFK toggle button
AntiAfkBtn = Instance.new("TextButton")
AntiAfkBtn.Size = UDim2.new(1, 0, 0, 28)
AntiAfkBtn.Position = UDim2.new(0, 0, 0, saveBtnY + 360)
AntiAfkBtn.BackgroundColor3 = Color3.fromRGB(50, 25, 25)
AntiAfkBtn.Text = "⚡ ANTI-AFK: OFF"
AntiAfkBtn.TextColor3 = Colors.text
AntiAfkBtn.TextSize = 11
AntiAfkBtn.Font = Enum.Font.GothamBold
AntiAfkBtn.AutoButtonColor = false
AntiAfkBtn.Parent = SettingsScroll
Instance.new("UICorner", AntiAfkBtn).CornerRadius = UDim.new(0, 6)
addBtnGradient(AntiAfkBtn)
makeHoverable(AntiAfkBtn, Color3.fromRGB(50, 25, 25), Color3.fromRGB(70, 40, 40))

-- Chat Spy open button
ChatSpyOpenBtn = Instance.new("TextButton")
ChatSpyOpenBtn.Size = UDim2.new(1, 0, 0, 28)
ChatSpyOpenBtn.Position = UDim2.new(0, 0, 0, saveBtnY + 394)
ChatSpyOpenBtn.BackgroundColor3 = Color3.fromRGB(40, 140, 40)
ChatSpyOpenBtn.Text = "💬 OPEN CHAT SPY"
ChatSpyOpenBtn.TextColor3 = Colors.text
ChatSpyOpenBtn.TextSize = 11
ChatSpyOpenBtn.Font = Enum.Font.GothamBold
ChatSpyOpenBtn.AutoButtonColor = false
ChatSpyOpenBtn.Parent = SettingsScroll
Instance.new("UICorner", ChatSpyOpenBtn).CornerRadius = UDim.new(0, 6)
addBtnGradient(ChatSpyOpenBtn)
makeHoverable(ChatSpyOpenBtn, Color3.fromRGB(40, 140, 40), Color3.fromRGB(60, 180, 60))

-- Execute Script label
ExecLabel = Instance.new("TextLabel")
ExecLabel.Size = UDim2.new(1, 0, 0, 16)
ExecLabel.Position = UDim2.new(0, 0, 0, saveBtnY + 430)
ExecLabel.BackgroundTransparency = 1
ExecLabel.Text = "Execute Script:"
ExecLabel.TextColor3 = Colors.textDim
ExecLabel.TextSize = 11
ExecLabel.Font = Enum.Font.GothamBold
ExecLabel.TextXAlignment = Enum.TextXAlignment.Left
ExecLabel.Parent = SettingsScroll

-- Execute TextBox
ExecScriptBox = Instance.new("TextBox")
ExecScriptBox.Size = UDim2.new(1, 0, 0, 60)
ExecScriptBox.Position = UDim2.new(0, 0, 0, saveBtnY + 448)
ExecScriptBox.BackgroundColor3 = Colors.inputBg
ExecScriptBox.Text = ""
ExecScriptBox.PlaceholderText = "paste lua code here..."
ExecScriptBox.TextColor3 = Colors.text
ExecScriptBox.PlaceholderColor3 = Colors.textDim
ExecScriptBox.TextSize = 10
ExecScriptBox.Font = Enum.Font.Code
ExecScriptBox.TextXAlignment = Enum.TextXAlignment.Left
ExecScriptBox.TextYAlignment = Enum.TextYAlignment.Top
ExecScriptBox.ClearTextOnFocus = false
ExecScriptBox.TextWrapped = true
ExecScriptBox.MultiLine = true
ExecScriptBox.Parent = SettingsScroll
Instance.new("UICorner", ExecScriptBox).CornerRadius = UDim.new(0, 6)
ExecScriptBoxPad = Instance.new("UIPadding", ExecScriptBox)
ExecScriptBoxPad.PaddingLeft = UDim.new(0, 6)
ExecScriptBoxPad.PaddingTop = UDim.new(0, 4)
ExecScriptStroke = Instance.new("UIStroke", ExecScriptBox)
ExecScriptStroke.Color = Colors.inputBorder
ExecScriptStroke.Thickness = 1

ExecScriptBox.Focused:Connect(function()
    TweenService:Create(ExecScriptStroke, TweenInfo.new(0.2), { Color = Color3.fromRGB(80, 220, 100), Thickness = 1.5 }):Play()
end)
ExecScriptBox.FocusLost:Connect(function()
    TweenService:Create(ExecScriptStroke, TweenInfo.new(0.3), { Color = Colors.inputBorder, Thickness = 1 }):Play()
end)

-- Run button
ExecRunBtn = Instance.new("TextButton")
ExecRunBtn.Size = UDim2.new(1, 0, 0, 28)
ExecRunBtn.Position = UDim2.new(0, 0, 0, saveBtnY + 514)
ExecRunBtn.BackgroundColor3 = Color3.fromRGB(40, 140, 40)
ExecRunBtn.Text = "▶ RUN SCRIPT"
ExecRunBtn.TextColor3 = Colors.text
ExecRunBtn.TextSize = 11
ExecRunBtn.Font = Enum.Font.GothamBold
ExecRunBtn.AutoButtonColor = false
ExecRunBtn.Parent = SettingsScroll
Instance.new("UICorner", ExecRunBtn).CornerRadius = UDim.new(0, 6)
addBtnGradient(ExecRunBtn)
makeHoverable(ExecRunBtn, Color3.fromRGB(40, 140, 40), Color3.fromRGB(60, 180, 60))

SettingsScroll.CanvasSize = UDim2.new(0, 0, 0, saveBtnY + 560)
