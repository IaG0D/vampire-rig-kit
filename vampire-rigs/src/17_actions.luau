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
        card.Size = UDim2.new(1, -10, 0, 72)
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
