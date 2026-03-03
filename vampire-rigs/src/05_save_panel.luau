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
