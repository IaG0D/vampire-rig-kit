--==================================================
-- PREVIEW — BOLA DE CRISTAL (Live CFrame Sync)
--==================================================

local function clearPreview()
    if previewConnection then
        previewConnection:Disconnect()
        previewConnection = nil
    end
    for _, child in pairs(Viewport:GetChildren()) do
        if not child:IsA("UICorner") and not child:IsA("UIStroke")
            and child ~= ViewportStatus and child ~= LiveBadge and child ~= DistLabel then
            child:Destroy()
        end
    end
    ViewportStatus.Text = ""
    LiveBadge.Visible = false
    DistLabel.Visible = false
    PreviewHPFill.Size = UDim2.new(1, 0, 1, 0)
    PreviewHPFill.BackgroundColor3 = Colors.green
    PreviewHPLabel.Text = ""
    currentPreviewData = nil
end

local function displayPreviewInfo(info)
    local desc = info.fullDescription
    if not desc then
        InfoLabel.Text = "No data available"
        return
    end

    local txt = ""
    txt = txt .. "RigType: " .. tostring(desc.RigType or "?") .. "\n\n"

    txt = txt .. "-- CLOTHES --\n"
    txt = txt .. "Shirt: " .. tostring(desc.Shirt or 0) .. "\n"
    txt = txt .. "Pants: " .. tostring(desc.Pants or 0) .. "\n"
    txt = txt .. "Face: " .. tostring(desc.Face or 0) .. "\n\n"

    local accCount = desc.Accessories and #desc.Accessories or 0
    txt = txt .. "-- ACCESSORIES (" .. accCount .. ") --\n"
    if desc.Accessories then
        for i, acc in ipairs(desc.Accessories) do
            txt = txt .. i .. ". " .. acc.AccessoryType
            if acc.IsLayered then txt = txt .. " [L]" end
            txt = txt .. " - " .. acc.AssetId .. "\n"
        end
    end

    txt = txt .. "\n-- SCALES --\n"
    txt = txt .. "Height: " .. string.format("%.2f", desc.HeightScale or 1) .. "\n"
    txt = txt .. "Width: " .. string.format("%.2f", desc.WidthScale or 1) .. "\n"
    txt = txt .. "BodyType: " .. string.format("%.2f", desc.BodyTypeScale or 0) .. "\n"

    InfoLabel.Text = txt
end

local function showPreview(info)
    clearPreview()
    currentPreviewData = info
    PreviewTitle.Text = "🔮 " .. info.name
    PreviewFrame.Visible = true
    ViewportStatus.Text = "Connecting..."

    -- Info bar
    PreviewNameLabel.Text = info.name
    PreviewTypeLabel.Text = info.type
    PreviewTypeBadge.BackgroundColor3 = info.type == "PLAYER" and Colors.blood or Colors.green

    -- Get real character
    local realChar = info.character
    if info.player and info.player.Character then
        realChar = info.player.Character
    end

    if not realChar or not realChar.Parent then
        ViewportStatus.Text = "Character not found"
        InfoLabel.Text = ""
        return
    end

    -- Clone character for viewport
    local cloneOk, cloneModel = pcall(function()
        return realChar:Clone()
    end)

    if not cloneOk or not cloneModel then
        ViewportStatus.Text = "Failed to clone"
        InfoLabel.Text = ""
        return
    end

    -- Build part mapping (Clone preserves descendant order)
    local partMap = {}
    local realDescs = realChar:GetDescendants()
    local cloneDescs = cloneModel:GetDescendants()
    for i = 1, math.min(#realDescs, #cloneDescs) do
        local realPart = realDescs[i]
        local clonePart = cloneDescs[i]
        if realPart:IsA("BasePart") and clonePart:IsA("BasePart") then
            partMap[realPart] = clonePart
        end
    end

    -- Camera
    local camera = Instance.new("Camera")
    camera.FieldOfView = 50
    camera.Parent = Viewport
    Viewport.CurrentCamera = camera

    -- WorldModel container
    local worldModel = Instance.new("WorldModel")
    worldModel.Parent = Viewport

    -- Floor plane for visual grounding
    local floor = Instance.new("Part")
    floor.Size = Vector3.new(40, 0.1, 40)
    floor.Position = Vector3.new(0, -3.5, 0)
    floor.Color = Color3.fromRGB(12, 10, 18)
    floor.Material = Enum.Material.SmoothPlastic
    floor.Anchored = true
    floor.CanCollide = false
    floor.Parent = worldModel

    cloneModel.Parent = worldModel

    ViewportStatus.Text = ""
    LiveBadge.Visible = true
    DistLabel.Visible = true

    -- Live sync loop
    local angle = 0
    local livePulse = 0
    previewConnection = RunService.RenderStepped:Connect(function(dt)
        -- Check if real character still exists
        if not realChar or not realChar.Parent then
            ViewportStatus.Text = "Left the game"
            LiveBadge.Text = "● OFF"
            LiveBadge.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
            return
        end

        local realHRP = realChar:FindFirstChild("HumanoidRootPart")
        if not realHRP then return end

        -- Sync all part CFrames (centered at origin)
        local rootCF = realHRP.CFrame
        for realPart, clonePart in pairs(partMap) do
            if realPart.Parent and clonePart.Parent then
                pcall(function()
                    clonePart.CFrame = rootCF:Inverse() * realPart.CFrame
                end)
            end
        end

        -- Camera orbit
        angle = angle + dt * 0.4
        local camDist = 10
        local camHeight = 2.5
        camera.CFrame = CFrame.new(
            Vector3.new(math.sin(angle) * camDist, camHeight, math.cos(angle) * camDist),
            Vector3.new(0, 0.5, 0)
        )

        -- Update distance from local player
        local myHRP = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if myHRP then
            local dist = math.floor((myHRP.Position - realHRP.Position).Magnitude)
            DistLabel.Text = dist .. "m"
        end

        -- Update HP bar
        local hum = realChar:FindFirstChildOfClass("Humanoid")
        if hum then
            local pct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
            PreviewHPFill.Size = UDim2.new(pct, 0, 1, 0)
            if pct > 0.5 then
                PreviewHPFill.BackgroundColor3 = Colors.green
            elseif pct > 0.25 then
                PreviewHPFill.BackgroundColor3 = Colors.warning
            else
                PreviewHPFill.BackgroundColor3 = Colors.glowRed
            end
            PreviewHPLabel.Text = math.floor(hum.Health) .. "/" .. math.floor(hum.MaxHealth)
        end

        -- Pulse LIVE badge
        livePulse = livePulse + dt * 2
        local alpha = (math.sin(livePulse) + 1) / 2
        LiveBadge.BackgroundColor3 = Color3.fromRGB(
            math.floor(140 + alpha * 60),
            math.floor(10 + alpha * 10),
            math.floor(10 + alpha * 10)
        )
    end)

    -- Load rig data and display info
    if not info.loaded then
        InfoLabel.Text = "Loading data..."
        task.spawn(function()
            loadRigData(info)
            if info.cardFrame then
                info.cardFrame.BackgroundColor3 = Colors.cardLoaded
            end
            if info.statusLabel and info.fullDescription then
                local accCount = info.fullDescription.Accessories and #info.fullDescription.Accessories or 0
                info.statusLabel.Text = (info.fullDescription.RigType or "?") .. " | " .. accCount .. " acc"
                info.statusLabel.TextColor3 = Colors.greenLight
            end
            displayPreviewInfo(info)
        end)
    else
        displayPreviewInfo(info)
    end
end
