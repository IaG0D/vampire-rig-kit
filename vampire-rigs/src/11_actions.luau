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
