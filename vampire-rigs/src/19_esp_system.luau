--==================================================
-- ESP SYSTEM (Full)
--==================================================

local function createESPObject(target, espName, espColor, isCamera, isNPC)
    local existing = target:FindFirstChild("VampESP_BG")
    if existing then return end

    local espData = {
        target = target,
        isCamera = isCamera,
        isNPC = isNPC,
    }

    -- Highlight (player/NPC/camera ESP)
    if espState.players or espState.npcs or espState.cameras then
        local hl = Instance.new("Highlight")
        hl.Name = "VampESP_HL"
        hl.Adornee = target
        hl.Parent = target

        if espState.chams then
            hl.FillColor = espColor
            hl.FillTransparency = 0.3
            hl.OutlineColor = espColor
            hl.OutlineTransparency = 0.2
        elseif espState.boxESP then
            hl.FillColor = espColor
            hl.FillTransparency = 1
            hl.OutlineColor = espColor
            hl.OutlineTransparency = 0
        else
            hl.FillColor = espColor
            hl.FillTransparency = 0.85
            hl.OutlineColor = espColor
            hl.OutlineTransparency = 0.2
        end

        espData.highlight = hl
    end

    -- BillboardGui com nome e distancia
    local bg = Instance.new("BillboardGui")
    bg.Name = "VampESP_BG"
    bg.Size = UDim2.new(0, 200, 0, 60)
    bg.StudsOffset = Vector3.new(0, isCamera and 2 or 4, 0)
    bg.AlwaysOnTop = true
    bg.Adornee = target
    bg.Parent = target

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "ESPName"
    nameLabel.Size = UDim2.new(1, 0, 0, 16)
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
    distLabel.Size = UDim2.new(1, 0, 0, 14)
    distLabel.Position = UDim2.new(0, 0, 0, 16)
    distLabel.BackgroundTransparency = 1
    distLabel.Text = "? studs"
    distLabel.TextColor3 = Colors.textDim
    distLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    distLabel.TextStrokeTransparency = 0.3
    distLabel.TextSize = 11
    distLabel.Font = Enum.Font.Gotham
    distLabel.Parent = bg

    espData.billboard = bg
    espData.nameLabel = nameLabel
    espData.distLabel = distLabel

    -- Health bar
    if espState.healthBars and not isCamera then
        local hpBg = Instance.new("Frame")
        hpBg.Name = "ESPHealth"
        hpBg.Size = UDim2.new(0, 100, 0, 6)
        hpBg.Position = UDim2.new(0.5, -50, 0, 32)
        hpBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        hpBg.BorderSizePixel = 0
        hpBg.Parent = bg
        Instance.new("UICorner", hpBg).CornerRadius = UDim.new(0, 3)

        local hpFill = Instance.new("Frame")
        hpFill.Name = "Fill"
        hpFill.Size = UDim2.new(1, 0, 1, 0)
        hpFill.BackgroundColor3 = Colors.green
        hpFill.BorderSizePixel = 0
        hpFill.Parent = hpBg
        Instance.new("UICorner", hpFill).CornerRadius = UDim.new(0, 3)

        espData.healthBg = hpBg
        espData.healthFill = hpFill
    end

    -- Type label (camera)
    if isCamera then
        local typeLabel = Instance.new("TextLabel")
        typeLabel.Name = "ESPType"
        typeLabel.Size = UDim2.new(1, 0, 0, 12)
        typeLabel.Position = UDim2.new(0, 0, 0, 32)
        typeLabel.BackgroundTransparency = 1
        typeLabel.Text = "📷 CAMERA"
        typeLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
        typeLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        typeLabel.TextStrokeTransparency = 0.3
        typeLabel.TextSize = 10
        typeLabel.Font = Enum.Font.GothamBold
        typeLabel.Parent = bg
    end

    table.insert(espObjects, espData)
end

local function removeESPFromTarget(target)
    local hl = target:FindFirstChild("VampESP_HL")
    if hl then hl:Destroy() end
    local bg = target:FindFirstChild("VampESP_BG")
    if bg then bg:Destroy() end
end

clearESP = function()
    if espConnection then
        espConnection:Disconnect()
        espConnection = nil
    end

    for _, esp in ipairs(espObjects) do
        if esp.target and esp.target.Parent then
            removeESPFromTarget(esp.target)
        end
    end
    espObjects = {}
end

updateESP = function()
    clearESP()

    local anyActive = false
    for _, v in pairs(espState) do
        if v then anyActive = true break end
    end

    if not anyActive then
        ESPStatusLabel.Text = "ESP OFF — toggle features above"
        return
    end

    local myChar = LP.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local playerChars = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p.Character then playerChars[p.Character] = p end
    end

    -- Players
    if espState.players then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LP then
                local char = player.Character
                if char and char:FindFirstChildOfClass("Humanoid") then
                    createESPObject(char, player.Name, Colors.bloodLight, false, false)
                end
            end
        end
    end

    -- NPCs
    if espState.npcs then
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") and not playerChars[obj] then
                createESPObject(obj, obj.Name, Colors.green, false, true)
            end
        end
    end

    -- Cameras
    if espState.cameras then
        local cameraKeywords = { "camera", "cam", "cctv", "security", "surveillance", "monitor" }
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Camera") and obj ~= workspace.CurrentCamera then
                createESPObject(obj, obj.Name, Color3.fromRGB(255, 200, 100), true, false)
            elseif (obj:IsA("BasePart") or obj:IsA("Model")) and not obj:FindFirstChild("VampESP_BG") then
                local lowerName = obj.Name:lower()
                for _, keyword in ipairs(cameraKeywords) do
                    if lowerName:find(keyword) then
                        createESPObject(obj, obj.Name, Color3.fromRGB(255, 200, 100), true, false)
                        break
                    end
                end
            end
        end
    end

    -- Update loop
    espConnection = RunService.RenderStepped:Connect(function()
        local char = LP.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local myPos = hrp.Position

        for i = #espObjects, 1, -1 do
            local esp = espObjects[i]
            if not esp.target or not esp.target.Parent then
                table.remove(espObjects, i)
            else
                local targetPos
                if esp.target:IsA("Model") then
                    local tHRP = esp.target:FindFirstChild("HumanoidRootPart")
                        or esp.target:FindFirstChild("Head")
                        or esp.target.PrimaryPart
                    if tHRP then targetPos = tHRP.Position end
                elseif esp.target:IsA("BasePart") then
                    targetPos = esp.target.Position
                elseif esp.target:IsA("Camera") then
                    targetPos = esp.target.CFrame.Position
                end

                if targetPos then
                    local dist = math.floor((myPos - targetPos).Magnitude)
                    esp.distLabel.Text = dist .. " studs"
                end

                -- Update health bar
                if esp.healthFill and not esp.isCamera then
                    local hum = esp.target:FindFirstChildOfClass("Humanoid")
                    if hum then
                        local pct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                        esp.healthFill.Size = UDim2.new(pct, 0, 1, 0)
                        if pct > 0.5 then
                            esp.healthFill.BackgroundColor3 = Colors.green
                        elseif pct > 0.25 then
                            esp.healthFill.BackgroundColor3 = Colors.warning
                        else
                            esp.healthFill.BackgroundColor3 = Colors.glowRed
                        end
                    end
                end
            end
        end
    end)

    ESPStatusLabel.Text = #espObjects .. " targets tracked"
    log("ESP ON:", #espObjects, "targets")
end

toggleESPFeature = function(feature)
    espState[feature] = not espState[feature]
    updateESP()

    -- Refresh toggle UIs
    if espToggles[feature] then
        espToggles[feature].refresh()
    end
end
