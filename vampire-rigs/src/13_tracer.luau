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
