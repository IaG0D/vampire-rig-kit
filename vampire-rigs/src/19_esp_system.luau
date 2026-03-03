--==================================================
-- ESP SYSTEM (Full) — 7 new features
-- Tracers, Skeleton, HeadDot, ThreatLevel, ToolESP,
-- Footsteps, SoundESP
--==================================================

--==================================================
-- TRACER CONTAINER (screen-space lines)
--==================================================

TracerContainer = Instance.new("Frame")
TracerContainer.Name = "TracerContainer"
TracerContainer.Size = UDim2.new(1, 0, 1, 0)
TracerContainer.BackgroundTransparency = 1
TracerContainer.Parent = ScreenGui

-- Screen-space line helper: draws a line between two Vector2 points
local function drawTracerLine(from, to, color)
    local dx = to.X - from.X
    local dy = to.Y - from.Y
    local dist = math.sqrt(dx * dx + dy * dy)
    local angle = math.atan2(dy, dx)

    local line = Instance.new("Frame")
    line.Size = UDim2.new(0, dist, 0, 1)
    line.Position = UDim2.new(0, from.X, 0, from.Y)
    line.AnchorPoint = Vector2.new(0, 0.5)
    line.Rotation = math.deg(angle)
    line.BackgroundColor3 = color or Color3.fromRGB(0, 180, 255)
    line.BackgroundTransparency = 0.3
    line.BorderSizePixel = 0
    line.Parent = TracerContainer
    return line
end

--==================================================
-- SKELETON BONE DEFINITIONS
--==================================================

local skeletonBones = {
    -- Spine
    { "HumanoidRootPart", "UpperTorso" },
    { "UpperTorso", "Head" },
    { "HumanoidRootPart", "LowerTorso" },
    -- Left arm
    { "UpperTorso", "LeftUpperArm" },
    { "LeftUpperArm", "LeftLowerArm" },
    { "LeftLowerArm", "LeftHand" },
    -- Right arm
    { "UpperTorso", "RightUpperArm" },
    { "RightUpperArm", "RightLowerArm" },
    { "RightLowerArm", "RightHand" },
    -- Left leg
    { "LowerTorso", "LeftUpperLeg" },
    { "LeftUpperLeg", "LeftLowerLeg" },
    { "LeftLowerLeg", "LeftFoot" },
    -- Right leg
    { "LowerTorso", "RightUpperLeg" },
    { "RightUpperLeg", "RightLowerLeg" },
    { "RightLowerLeg", "RightFoot" },
}

-- R6 fallback bones
local skeletonBonesR6 = {
    { "Torso", "Head" },
    { "Torso", "Left Arm" },
    { "Torso", "Right Arm" },
    { "Torso", "Left Leg" },
    { "Torso", "Right Leg" },
}

--==================================================
-- CORE ESP FUNCTIONS
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

    -- Tool ESP label (below distance)
    if espState.toolESP and not isCamera then
        local toolLabel = Instance.new("TextLabel")
        toolLabel.Name = "ESPTool"
        toolLabel.Size = UDim2.new(1, 0, 0, 12)
        toolLabel.Position = UDim2.new(0, 0, 0, 32)
        toolLabel.BackgroundTransparency = 1
        toolLabel.Text = ""
        toolLabel.TextColor3 = Color3.fromRGB(180, 120, 255)
        toolLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        toolLabel.TextStrokeTransparency = 0.3
        toolLabel.TextSize = 10
        toolLabel.Font = Enum.Font.GothamBold
        toolLabel.Parent = bg
        espData.toolLabel = toolLabel
    end

    -- Health bar
    if espState.healthBars and not isCamera then
        local hpY = espState.toolESP and 46 or 32
        local hpBg = Instance.new("Frame")
        hpBg.Name = "ESPHealth"
        hpBg.Size = UDim2.new(0, 100, 0, 6)
        hpBg.Position = UDim2.new(0.5, -50, 0, hpY)
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

    -- Head Dot
    if espState.headDot and not isCamera then
        local head = target:FindFirstChild("Head")
        if head then
            local dotBG = Instance.new("BillboardGui")
            dotBG.Name = "VampESP_HeadDot"
            dotBG.Size = UDim2.new(0, 8, 0, 8)
            dotBG.StudsOffset = Vector3.new(0, 0, 0)
            dotBG.AlwaysOnTop = true
            dotBG.Adornee = head
            dotBG.Parent = head

            local dot = Instance.new("Frame")
            dot.Size = UDim2.new(1, 0, 1, 0)
            dot.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
            dot.BorderSizePixel = 0
            dot.Parent = dotBG
            Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

            espData.headDotBG = dotBG
            table.insert(headDotObjects, dotBG)
        end
    end

    -- Skeleton ESP (Beams between body parts)
    if espState.skeleton and not isCamera then
        local bones = skeletonBones
        -- Detect R6 vs R15
        if not target:FindFirstChild("UpperTorso") and target:FindFirstChild("Torso") then
            bones = skeletonBonesR6
        end

        local beamData = {}
        for _, bonePair in ipairs(bones) do
            local partA = target:FindFirstChild(bonePair[1])
            local partB = target:FindFirstChild(bonePair[2])
            if partA and partB then
                local attA = Instance.new("Attachment")
                attA.Name = "VampSkel_A"
                attA.Parent = partA

                local attB = Instance.new("Attachment")
                attB.Name = "VampSkel_B"
                attB.Parent = partB

                local beam = Instance.new("Beam")
                beam.Name = "VampSkel_Beam"
                beam.Attachment0 = attA
                beam.Attachment1 = attB
                beam.Color = ColorSequence.new(Color3.fromRGB(200, 200, 200))
                beam.FaceCamera = true
                beam.Width0 = 0.05
                beam.Width1 = 0.05
                beam.Transparency = NumberSequence.new(0.2)
                beam.Parent = partA

                table.insert(beamData, { beam = beam, attA = attA, attB = attB })
            end
        end

        espData.skeletonBeams = beamData
        for _, bd in ipairs(beamData) do
            table.insert(skeletonBeams, bd)
        end
    end

    table.insert(espObjects, espData)
end

local function removeESPFromTarget(target)
    local hl = target:FindFirstChild("VampESP_HL")
    if hl then hl:Destroy() end
    local bg = target:FindFirstChild("VampESP_BG")
    if bg then bg:Destroy() end

    -- Clean head dots
    local head = target:FindFirstChild("Head")
    if head then
        local hd = head:FindFirstChild("VampESP_HeadDot")
        if hd then hd:Destroy() end
    end

    -- Clean skeleton beams
    for _, part in ipairs(target:GetDescendants()) do
        if part.Name == "VampSkel_A" or part.Name == "VampSkel_B" then
            part:Destroy()
        elseif part.Name == "VampSkel_Beam" then
            part:Destroy()
        end
    end
end

--==================================================
-- CLEAR ALL ESP
--==================================================

clearESP = function()
    if espConnection then
        espConnection:Disconnect()
        espConnection = nil
    end

    -- Clear tracers
    for _, line in ipairs(tracerLines) do
        if line and line.Parent then line:Destroy() end
    end
    tracerLines = {}

    -- Clear skeleton beams
    for _, bd in ipairs(skeletonBeams) do
        pcall(function() bd.beam:Destroy() end)
        pcall(function() bd.attA:Destroy() end)
        pcall(function() bd.attB:Destroy() end)
    end
    skeletonBeams = {}

    -- Clear head dots
    for _, hd in ipairs(headDotObjects) do
        if hd and hd.Parent then hd:Destroy() end
    end
    headDotObjects = {}

    -- Clear ESP objects
    for _, esp in ipairs(espObjects) do
        if esp.target and esp.target.Parent then
            removeESPFromTarget(esp.target)
        end
    end
    espObjects = {}
end

--==================================================
-- UPDATE ESP (main loop)
--==================================================

updateESP = function()
    clearESP()

    -- Check if any toggle in espToggles-managed features is active
    local anyActive = false
    for _, v in pairs(espState) do
        if v then anyActive = true break end
    end

    -- Ignore footsteps and soundESP for the "any active" check
    -- since they are managed separately
    local coreActive = espState.players or espState.npcs or espState.cameras
        or espState.healthBars or espState.boxESP or espState.chams
        or espState.tracers or espState.skeleton or espState.headDot
        or espState.threatLevel or espState.toolESP

    if not coreActive then
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

    -- Update loop (RenderStepped)
    espConnection = RunService.RenderStepped:Connect(function()
        local char = LP.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local myPos = hrp.Position
        local cam = workspace.CurrentCamera

        -- Clear old tracers each frame
        if espState.tracers then
            for _, line in ipairs(tracerLines) do
                if line and line.Parent then line:Destroy() end
            end
            tracerLines = {}
        end

        -- Screen bottom center (tracer origin)
        local screenCenter = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y)

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

                    -- Threat Level: color name label based on distance
                    if espState.threatLevel and esp.nameLabel then
                        if dist < 30 then
                            esp.nameLabel.TextColor3 = Color3.fromRGB(255, 40, 40)     -- RED close
                        elseif dist < 60 then
                            esp.nameLabel.TextColor3 = Color3.fromRGB(255, 180, 40)    -- YELLOW mid
                        else
                            esp.nameLabel.TextColor3 = Color3.fromRGB(40, 255, 80)     -- GREEN far
                        end
                    end

                    -- Tool ESP: show equipped tool name
                    if esp.toolLabel and esp.target:IsA("Model") then
                        local toolName = ""
                        for _, child in ipairs(esp.target:GetChildren()) do
                            if child:IsA("Tool") then
                                toolName = "🔧 " .. child.Name
                                break
                            end
                        end
                        esp.toolLabel.Text = toolName
                    end

                    -- Tracers: draw line from screen bottom to target screen position
                    if espState.tracers then
                        local screenPos, onScreen = cam:WorldToScreenPoint(targetPos)
                        if onScreen then
                            local targetScreen = Vector2.new(screenPos.X, screenPos.Y)
                            local tracerColor = Color3.fromRGB(0, 180, 255)
                            if espState.threatLevel then
                                if dist < 30 then
                                    tracerColor = Color3.fromRGB(255, 40, 40)
                                elseif dist < 60 then
                                    tracerColor = Color3.fromRGB(255, 180, 40)
                                else
                                    tracerColor = Color3.fromRGB(40, 255, 80)
                                end
                            end
                            local line = drawTracerLine(screenCenter, targetScreen, tracerColor)
                            table.insert(tracerLines, line)
                        end
                    end
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

--==================================================
-- FOOTSTEPS TRAIL SYSTEM (separate from main ESP)
--==================================================

startFootsteps = function()
    espState.footsteps = true
    FootstepsToggle.refresh()

    -- Track player positions every 0.5s and leave marks
    footstepConnection = RunService.Heartbeat:Connect(function()
        -- Throttle: only every ~0.5s
        if not footstepConnection then return end
    end)

    -- Use a separate task loop for mark placement
    footstepConnection = task.spawn(function()
        while espState.footsteps do
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LP and player.Character then
                    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local pos = hrp.Position

                        local mark = Instance.new("Part")
                        mark.Name = "VampFootstep"
                        mark.Size = Vector3.new(0.6, 0.1, 0.6)
                        mark.Position = Vector3.new(pos.X, pos.Y - 3, pos.Z)
                        mark.Anchored = true
                        mark.CanCollide = false
                        mark.Material = Enum.Material.Neon
                        mark.Color = Color3.fromRGB(120, 200, 80)
                        mark.Transparency = 0.4
                        mark.Parent = workspace

                        table.insert(footstepParts, mark)

                        -- Fade out and destroy after 8s
                        task.spawn(function()
                            task.wait(6)
                            if mark and mark.Parent then
                                TweenService:Create(mark, TweenInfo.new(2), { Transparency = 1 }):Play()
                                task.wait(2)
                                if mark and mark.Parent then mark:Destroy() end
                            end
                        end)
                    end
                end
            end

            -- Limit total marks
            while #footstepParts > 500 do
                local old = table.remove(footstepParts, 1)
                if old and old.Parent then old:Destroy() end
            end

            task.wait(0.5)
        end
    end)

    notify("Footsteps Trail ON", "success")
end

stopFootsteps = function()
    espState.footsteps = false
    FootstepsToggle.refresh()

    -- footstepConnection is a thread, it will exit on next loop check

    -- Clear existing marks
    for _, part in ipairs(footstepParts) do
        if part and part.Parent then part:Destroy() end
    end
    footstepParts = {}

    notify("Footsteps Trail OFF", "info")
end

--==================================================
-- SOUND ESP SYSTEM (separate from main ESP)
--==================================================

startSoundESP = function()
    espState.soundESP = true
    SoundESPToggle.refresh()

    -- Periodic scan for playing sounds
    soundEspConnection = task.spawn(function()
        while espState.soundESP do
            -- Clear old billboards
            for _, obj in ipairs(soundEspObjects) do
                if obj and obj.Parent then obj:Destroy() end
            end
            soundEspObjects = {}

            local myChar = LP.Character
            local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
            if myHRP then
                local myPos = myHRP.Position

                for _, desc in ipairs(workspace:GetDescendants()) do
                    if desc:IsA("Sound") and desc.Playing then
                        local parent = desc.Parent
                        if parent and (parent:IsA("BasePart") or parent:IsA("Model")) then
                            local adornee = parent
                            if parent:IsA("Model") then
                                adornee = parent.PrimaryPart or parent:FindFirstChildWhichIsA("BasePart")
                            end

                            if adornee and adornee:IsA("BasePart") then
                                local soundPos = adornee.Position
                                local dist = math.floor((myPos - soundPos).Magnitude)

                                local bg = Instance.new("BillboardGui")
                                bg.Name = "VampSoundESP"
                                bg.Size = UDim2.new(0, 160, 0, 30)
                                bg.StudsOffset = Vector3.new(0, 3, 0)
                                bg.AlwaysOnTop = true
                                bg.Adornee = adornee
                                bg.Parent = adornee

                                local lbl = Instance.new("TextLabel")
                                lbl.Size = UDim2.new(1, 0, 1, 0)
                                lbl.BackgroundTransparency = 1
                                lbl.Text = "🔊 " .. desc.Name .. " [" .. dist .. "m]"
                                lbl.TextColor3 = Color3.fromRGB(255, 200, 60)
                                lbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                                lbl.TextStrokeTransparency = 0.3
                                lbl.TextSize = 10
                                lbl.Font = Enum.Font.GothamBold
                                lbl.Parent = bg

                                table.insert(soundEspObjects, bg)
                            end
                        end
                    end
                end
            end

            task.wait(2)
        end
    end)

    notify("Sound ESP ON", "success")
end

stopSoundESP = function()
    espState.soundESP = false
    SoundESPToggle.refresh()

    -- soundEspConnection is a thread, exits on next loop check

    -- Clear billboards
    for _, obj in ipairs(soundEspObjects) do
        if obj and obj.Parent then obj:Destroy() end
    end
    soundEspObjects = {}

    notify("Sound ESP OFF", "info")
end
