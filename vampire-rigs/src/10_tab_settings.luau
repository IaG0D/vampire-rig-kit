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
