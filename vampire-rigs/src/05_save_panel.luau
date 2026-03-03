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
