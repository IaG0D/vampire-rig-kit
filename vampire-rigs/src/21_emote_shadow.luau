--==================================================
-- EMOTE LOGIC
--==================================================

playEmote = function(animId)
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then
        notify("No character", "error")
        return
    end

    local animator = hum:FindFirstChildOfClass("Animator")
    if not animator then
        animator = Instance.new("Animator", hum)
    end

    -- Stop current emote
    if currentEmoteTrack then
        pcall(function() currentEmoteTrack:Stop() end)
        pcall(function() currentEmoteTrack:Destroy() end)
        currentEmoteTrack = nil
    end

    local animIdStr = "rbxassetid://" .. tostring(animId)

    -- Try to resolve bundle/emote asset → actual animation ID
    pcall(function()
        local objects = game:GetObjects(animIdStr)
        if objects and #objects > 0 then
            local obj = objects[1]
            if obj:IsA("Animation") then
                animIdStr = obj.AnimationId
            else
                for _, desc in ipairs(obj:GetDescendants()) do
                    if desc:IsA("Animation") then
                        animIdStr = desc.AnimationId
                        break
                    end
                end
            end
            pcall(function() obj:Destroy() end)
        end
    end)

    local anim = Instance.new("Animation")
    anim.AnimationId = animIdStr

    local ok, track = pcall(function()
        return animator:LoadAnimation(anim)
    end)

    if ok and track then
        track.Priority = Enum.AnimationPriority.Action
        track:Play()
        currentEmoteTrack = track
        emotePaused = false
        notify("Playing emote", "success")
        log("Emote playing:", animIdStr)
    else
        notify("Failed to load animation", "error")
        log("Emote error:", tostring(track))
    end

    anim:Destroy()
end

stopEmote = function()
    if currentEmoteTrack then
        pcall(function() currentEmoteTrack:Stop() end)
        pcall(function() currentEmoteTrack:Destroy() end)
        currentEmoteTrack = nil
        emotePaused = false
        notify("Emote stopped", "info")
    end
end

pauseEmote = function()
    if currentEmoteTrack and not emotePaused then
        pcall(function()
            currentEmoteTrack:AdjustSpeed(0)
        end)
        emotePaused = true
        notify("Emote paused", "info")
    end
end

resumeEmote = function()
    if currentEmoteTrack and emotePaused then
        pcall(function()
            currentEmoteTrack:AdjustSpeed(1)
        end)
        emotePaused = false
        notify("Emote resumed", "success")
    end
end

--==================================================
-- SHADOW LOGIC
--==================================================

startShadow = function(mode)
    if shadowConnection then
        shadowConnection:Disconnect()
        shadowConnection = nil
    end

    local target = shadowState.target
    if not target or not target.Character then
        notify("Select a shadow target first", "error")
        return
    end

    shadowState.active = true
    shadowState.mode = mode
    shadowHistory = {}
    refreshShadowModeButtons()

    -- Disable falling on local character
    local myChar = LP.Character
    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    if myHum then
        myHum:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
        myHum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    end

    -- Animation mirroring state (global so stopShadow can clean up)
    shadowMirroredTracks = {}
    local lastAnimSync = 0

    -- Apply trail if enabled
    if shadowState.trail then
        applyShadowTrail()
    end

    shadowConnection = RunService.Heartbeat:Connect(function()
        local targetChar = target.Character
        if not targetChar or not targetChar.Parent then
            stopShadow()
            notify("Shadow target left", "error")
            return
        end

        myChar = LP.Character
        local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
        if not myHRP or not targetHRP then return end

        -- Prevent falling state + zero velocity (anti-flicker)
        myHum = myChar:FindFirstChildOfClass("Humanoid")
        if myHum and myHum:GetState() == Enum.HumanoidStateType.Freefall then
            myHum:ChangeState(Enum.HumanoidStateType.Physics)
        end
        pcall(function()
            myHRP.Velocity = Vector3.new(0, 0, 0)
            myHRP.RotVelocity = Vector3.new(0, 0, 0)
        end)

        local dist = shadowState.distance

        if shadowState.mode == "head" then
            -- Sit on head
            local head = targetChar:FindFirstChild("Head")
            if head then
                myHRP.CFrame = head.CFrame * CFrame.new(0, 1.8, 0)
            end

        elseif shadowState.mode == "orbit" then
            -- Angle-based orbit positioning
            local targetCF = targetHRP.CFrame
            local useCF = targetCF

            if shadowState.delay > 0 then
                -- Store history
                table.insert(shadowHistory, { time = tick(), cf = targetCF })

                -- Find position from delay seconds ago
                local targetTime = tick() - shadowState.delay
                local delayCF = nil
                local cleanIdx = 0
                for i = #shadowHistory, 1, -1 do
                    if shadowHistory[i].time <= targetTime then
                        delayCF = shadowHistory[i].cf
                        cleanIdx = i
                        break
                    end
                end

                -- Clean old entries (keep last 300 max)
                if cleanIdx > 1 then
                    for _ = 1, cleanIdx - 1 do
                        table.remove(shadowHistory, 1)
                    end
                elseif #shadowHistory > 300 then
                    table.remove(shadowHistory, 1)
                end

                useCF = delayCF or targetCF
            end

            local angleRad = math.rad(shadowState.angle)
            local offsetX = math.sin(angleRad) * dist
            local offsetZ = math.cos(angleRad) * dist
            local orbitCF = useCF * CFrame.new(offsetX, shadowState.height, offsetZ)

            if shadowState.faceTarget then
                myHRP.CFrame = CFrame.lookAt(orbitCF.Position, targetHRP.Position)
            else
                myHRP.CFrame = orbitCF
            end
        end

        -- Auto-orbit: increment angle over time
        if shadowState.autoOrbit and shadowState.mode == "orbit" then
            shadowState.angle = (shadowState.angle + shadowState.orbitSpeed * 0.5) % 360
        end

        -- Record target path if recording
        if shadowRecording and targetHRP then
            table.insert(shadowRecordedPath, { time = tick(), cf = targetHRP.CFrame })
            -- Limit recording to ~1800 frames (~30s at 60fps)
            if #shadowRecordedPath > 1800 then
                table.remove(shadowRecordedPath, 1)
            end
        end

        -- Mirror target animations (~every 0.3s) — only if enabled
        local now = tick()
        if shadowState.mirrorAnims and now - lastAnimSync > 0.3 then
            lastAnimSync = now
            local targetHum = targetChar:FindFirstChildOfClass("Humanoid")
            if myHum and targetHum then
                local myAnimator = myHum:FindFirstChildOfClass("Animator")
                local targetAnimator = targetHum:FindFirstChildOfClass("Animator")
                if myAnimator and targetAnimator then
                    pcall(function()
                        local targetTracks = targetAnimator:GetPlayingAnimationTracks()
                        local targetIds = {}
                        for _, t in ipairs(targetTracks) do
                            if t.Animation then
                                targetIds[t.Animation.AnimationId] = t.Priority
                            end
                        end
                        -- Stop tracks target isn't playing
                        for id, track in pairs(shadowMirroredTracks) do
                            if not targetIds[id] then
                                pcall(function() track:Stop() end)
                                pcall(function() track:Destroy() end)
                                shadowMirroredTracks[id] = nil
                            end
                        end
                        -- Play tracks target IS playing
                        for id, priority in pairs(targetIds) do
                            if not shadowMirroredTracks[id] then
                                local anim = Instance.new("Animation")
                                anim.AnimationId = id
                                local ok2, myTrack = pcall(function()
                                    return myAnimator:LoadAnimation(anim)
                                end)
                                if ok2 and myTrack then
                                    myTrack.Priority = priority
                                    myTrack:Play()
                                    shadowMirroredTracks[id] = myTrack
                                end
                                anim:Destroy()
                            end
                        end
                    end)
                end
            end
        end
    end)

    local modeLabel = mode == "head" and "head" or ("orbit " .. shadowState.angle .. "°")
    notify("Shadow: " .. modeLabel .. " on " .. target.Name, "success")
    log("Shadow started:", modeLabel, target.Name)
end

stopShadow = function()
    shadowState.active = false
    shadowState.autoOrbit = false
    if shadowConnection then
        shadowConnection:Disconnect()
        shadowConnection = nil
    end
    shadowHistory = {}

    -- Stop and destroy all mirrored animation tracks
    if shadowMirroredTracks then
        for id, track in pairs(shadowMirroredTracks) do
            pcall(function() track:Stop() end)
            pcall(function() track:Destroy() end)
        end
        shadowMirroredTracks = {}
    end

    refreshShadowModeButtons()

    -- Re-enable falling states + zero velocity + force idle restart
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")

    -- Zero velocity ANTES de reabilitar freefall (evita sair voando)
    if hrp then
        pcall(function()
            hrp.Velocity = Vector3.new(0, 0, 0)
            hrp.RotVelocity = Vector3.new(0, 0, 0)
        end)
    end

    if hum then
        hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)

        -- Stop ALL playing animation tracks so Animate script restarts idle
        local animator = hum:FindFirstChildOfClass("Animator")
        if animator then
            pcall(function()
                for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                    track:Stop(0)
                end
            end)
        end

        -- Reset Animate script to force idle restart
        local animScript = char:FindFirstChild("Animate")
        if animScript then
            pcall(function()
                animScript.Disabled = true
                task.delay(0.1, function()
                    if animScript and animScript.Parent then
                        animScript.Disabled = false
                    end
                end)
            end)
        end
    end

    -- Remove trail
    removeShadowTrail()

    notify("Shadow stopped", "info")
    log("Shadow stopped")
end

--==================================================
-- SHADOW TRAIL
--==================================================

applyShadowTrail = function()
    removeShadowTrail()
    local char = LP.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local att0 = Instance.new("Attachment")
    att0.Name = "VampTrailAtt0"
    att0.Position = Vector3.new(0, 0, 0.5)
    att0.Parent = hrp

    local att1 = Instance.new("Attachment")
    att1.Name = "VampTrailAtt1"
    att1.Position = Vector3.new(0, 0, -0.5)
    att1.Parent = hrp

    shadowTrailInstance = Instance.new("Trail")
    shadowTrailInstance.Name = "VampShadowTrail"
    shadowTrailInstance.Attachment0 = att0
    shadowTrailInstance.Attachment1 = att1
    shadowTrailInstance.Lifetime = 1.5
    shadowTrailInstance.MinLength = 0.1
    shadowTrailInstance.FaceCamera = true
    shadowTrailInstance.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Colors.glowPurple),
        ColorSequenceKeypoint.new(0.5, Colors.blood),
        ColorSequenceKeypoint.new(1, Colors.bloodDark),
    })
    shadowTrailInstance.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.3),
        NumberSequenceKeypoint.new(0.5, 0.6),
        NumberSequenceKeypoint.new(1, 1),
    })
    shadowTrailInstance.WidthScale = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(1, 0.2),
    })
    shadowTrailInstance.Parent = hrp
end

removeShadowTrail = function()
    if shadowTrailInstance then
        pcall(function() shadowTrailInstance:Destroy() end)
        shadowTrailInstance = nil
    end
    local char = LP.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            for _, att in ipairs(hrp:GetChildren()) do
                if att.Name == "VampTrailAtt0" or att.Name == "VampTrailAtt1" then
                    att:Destroy()
                end
            end
        end
    end
end

--==================================================
-- SHADOW RECORD & REPLAY
--==================================================

startShadowRecording = function()
    shadowRecordedPath = {}
    shadowRecording = true
    ShadowRecBtn.Text = "⏹ STOP"
    ShadowRecBtn.BackgroundColor3 = Colors.glowRed
    notify("Recording path...", "info")
end

stopShadowRecording = function()
    shadowRecording = false
    ShadowRecBtn.Text = "⏺ REC"
    ShadowRecBtn.BackgroundColor3 = Colors.blood
    notify("Path recorded (" .. #shadowRecordedPath .. " frames)", "success")
end

startShadowReplay = function()
    if #shadowRecordedPath == 0 then
        notify("No recorded path — hit REC first", "warning")
        return
    end

    -- Stop current shadow if active
    if shadowState.active then
        stopShadow()
    end

    shadowReplaying = true
    ShadowPlayReplayBtn.Text = "⏹ STOP"
    ShadowPlayReplayBtn.BackgroundColor3 = Colors.bloodDark

    -- Disable falling
    local myChar = LP.Character
    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    if myHum then
        myHum:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
        myHum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    end

    -- Apply trail if enabled
    if shadowState.trail then
        applyShadowTrail()
    end

    -- Calculate path duration from recorded timestamps
    local startTime = shadowRecordedPath[1].time
    local endTime = shadowRecordedPath[#shadowRecordedPath].time
    local duration = endTime - startTime

    shadowReplayConnection = RunService.Heartbeat:Connect(function()
        if not shadowReplaying then return end

        myChar = LP.Character
        local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end

        -- Prevent falling
        myHum = myChar:FindFirstChildOfClass("Humanoid")
        if myHum and myHum:GetState() == Enum.HumanoidStateType.Freefall then
            myHum:ChangeState(Enum.HumanoidStateType.Physics)
        end

        -- Loop through recorded path using elapsed time
        local elapsed = (tick() - startTime) % duration
        local targetTime = startTime + elapsed

        -- Find closest frame
        local bestCF = shadowRecordedPath[1].cf
        for i = #shadowRecordedPath, 1, -1 do
            if shadowRecordedPath[i].time <= targetTime then
                bestCF = shadowRecordedPath[i].cf
                break
            end
        end

        myHRP.CFrame = bestCF
    end)

    notify("Replaying recorded path (loop)", "success")
end

stopShadowReplay = function()
    shadowReplaying = false
    if shadowReplayConnection then
        shadowReplayConnection:Disconnect()
        shadowReplayConnection = nil
    end
    ShadowPlayReplayBtn.Text = "▶ REPLAY"
    ShadowPlayReplayBtn.BackgroundColor3 = Colors.green

    -- Re-enable falling + restore idle
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
    end

    removeShadowTrail()
    notify("Replay stopped", "info")
end

--==================================================
-- TROLL FEATURES
--==================================================

flingPlayer = function(player)
    stopTroll()
    local targetChar = player.Character
    if not targetChar then
        notify("No character found", "error")
        return
    end
    local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
    local myChar = LP.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not targetHRP or not myHRP then
        notify("Missing HumanoidRootPart", "error")
        return
    end

    -- TP to target then apply massive velocity
    local savedCF = myHRP.CFrame
    myHRP.CFrame = targetHRP.CFrame * CFrame.new(0, 0, -2)

    task.delay(0.15, function()
        if not myChar or not myChar.Parent then return end
        local bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Velocity = Vector3.new(math.random(-200, 200), 300, math.random(-200, 200))
        bv.Parent = targetHRP
        task.delay(0.3, function()
            pcall(function() bv:Destroy() end)
        end)

        -- TP back
        task.delay(0.5, function()
            if myHRP and myHRP.Parent then
                myHRP.CFrame = savedCF
            end
        end)
    end)

    notify("Fling: " .. player.DisplayName, "success")
end

headsitPlayer = function(player)
    stopTroll()
    local targetChar = player.Character
    if not targetChar then notify("No character", "error") return end
    local head = targetChar:FindFirstChild("Head")
    local myChar = LP.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    if not head or not myHRP or not myHum then return end

    trollSaveCFrame()
    myHum:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
    myHum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    myHum.Sit = true
    myHum:ChangeState(Enum.HumanoidStateType.Seated)

    -- Força animação de sentar
    pcall(function()
        local animator = myHum:FindFirstChildOfClass("Animator")
        if not animator then animator = Instance.new("Animator", myHum) end
        local sitAnim = Instance.new("Animation")
        sitAnim.AnimationId = "rbxassetid://2506281703"
        trollSitTrack = animator:LoadAnimation(sitAnim)
        trollSitTrack.Priority = Enum.AnimationPriority.Action
        trollSitTrack.Looped = true
        trollSitTrack:Play()
    end)

    trollConnection = RunService.Heartbeat:Connect(function()
        if not player.Character or not player.Character:FindFirstChild("Head") then
            stopTroll()
            return
        end
        myChar = LP.Character
        myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
        if not myHRP then return end

        head = player.Character:FindFirstChild("Head")
        myHRP.CFrame = head.CFrame * CFrame.new(0, 2, 0)
        if myHum and not myHum.Sit then myHum.Sit = true end
    end)
    notify("Headsit: " .. player.DisplayName, "success")
end

--==================================================
-- MORE TROLLS
--==================================================

-- Salva posição antes de iniciar troll
trollSaveCFrame = function()
    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        trollSavedCFrame = hrp.CFrame
    end
end

-- Zera velocity do HRP (chamar dentro do Heartbeat pra reduzir flicker)
trollZeroVelocity = function()
    pcall(function()
        local char = LP.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.Velocity = Vector3.new(0, 0, 0)
            hrp.RotVelocity = Vector3.new(0, 0, 0)
        end
    end)
end

stopTroll = function()
    if trollConnection then
        pcall(function()
            if typeof(trollConnection) == "RBXScriptConnection" then
                trollConnection:Disconnect()
            else
                task.cancel(trollConnection)
            end
        end)
        trollConnection = nil
    end
    -- Para animação de sit se estiver rodando
    if trollSitTrack then
        pcall(function() trollSitTrack:Stop() end)
        pcall(function() trollSitTrack:Destroy() end)
        trollSitTrack = nil
    end

    -- Limpa jail parts
    for _, p in ipairs(trollJailParts) do
        if p and p.Parent then p:Destroy() end
    end
    trollJailParts = {}

    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hum then
        hum.Sit = false
        hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)

        -- Restaurar posição salva (evita cair no void)
        if trollSavedCFrame and hrp then
            hrp.CFrame = trollSavedCFrame
            hrp.Velocity = Vector3.new(0, 0, 0)
            hrp.RotVelocity = Vector3.new(0, 0, 0)
        end
        trollSavedCFrame = nil

        -- Stop all playing animation tracks
        local animator = hum:FindFirstChildOfClass("Animator")
        if animator then
            pcall(function()
                for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                    track:Stop(0)
                end
            end)
        end

        -- Reset Animate script to force idle restart
        local animScript = char:FindFirstChild("Animate")
        if animScript then
            pcall(function()
                animScript.Disabled = true
                task.delay(0.1, function()
                    if animScript and animScript.Parent then
                        animScript.Disabled = false
                    end
                end)
            end)
        end

    end
end

-- Auto velocity zero — roda sempre, zera velocity quando troll ativo
-- Reduz flicker pra outros clients (menos rubber-banding)
RunService.Heartbeat:Connect(function()
    if trollConnection then
        trollZeroVelocity()
    end
end)

bangPlayer = function(player)
    stopTroll()
    local targetChar = player.Character
    if not targetChar then notify("No character", "error") return end
    local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
    local myChar = LP.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    if not targetHRP or not myHRP or not myHum then return end

    trollSaveCFrame()
    myHum:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
    myHum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)

    local t = 0
    trollConnection = RunService.Heartbeat:Connect(function()
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            stopTroll()
            return
        end
        myChar = LP.Character
        myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end

        targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
        t = t + 1
        -- Pump motion por TRÁS do alvo
        local offset = math.sin(t * 0.3 * trollSpeedMul) * 1.5
        local behindCF = targetHRP.CFrame * CFrame.new(0, 0, 2 + offset)
        myHRP.CFrame = CFrame.lookAt(behindCF.Position, targetHRP.Position)
    end)
    notify("Bang: " .. player.DisplayName, "success")
end

--==================================================
-- BANG 2 — pela frente, cintura na cabeça
--==================================================

bangFrontPlayer = function(player)
    stopTroll()
    local targetChar = player.Character
    if not targetChar then notify("No character", "error") return end
    local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
    local myChar = LP.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    if not targetHRP or not myHRP or not myHum then return end

    trollSaveCFrame()
    myHum:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
    myHum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)

    local t = 0
    trollConnection = RunService.Heartbeat:Connect(function()
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            stopTroll()
            return
        end
        myChar = LP.Character
        myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end

        targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
        t = t + 1
        -- Pump na frente, levantado (cintura na altura da cabeça)
        local offset = math.sin(t * 0.3 * trollSpeedMul) * 1.5
        local frontCF = targetHRP.CFrame * CFrame.new(0, 1.8, -2 - offset)
        myHRP.CFrame = CFrame.lookAt(frontCF.Position, targetHRP.Position)
    end)
    notify("Bang 2: " .. player.DisplayName, "success")
end

orbitTrollPlayer = function(player)
    stopTroll()
    local targetChar = player.Character
    if not targetChar then notify("No character", "error") return end
    local myChar = LP.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    if not myHRP or not myHum then return end

    trollSaveCFrame()
    myHum:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
    myHum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)

    local angle = 0
    trollConnection = RunService.Heartbeat:Connect(function()
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            stopTroll()
            return
        end
        myChar = LP.Character
        myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end

        local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
        angle = (angle + 15 * trollSpeedMul) % 360
        local rad = math.rad(angle)
        local pos = targetHRP.CFrame * CFrame.new(math.sin(rad) * 3, 0, math.cos(rad) * 3)
        myHRP.CFrame = CFrame.lookAt(pos.Position, targetHRP.Position)
    end)
    notify("Orbit troll: " .. player.DisplayName, "success")
end

backpackPlayer = function(player)
    stopTroll()
    local targetChar = player.Character
    if not targetChar then notify("No character", "error") return end
    local myChar = LP.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    if not myHRP or not myHum then return end

    trollSaveCFrame()
    myHum:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
    myHum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)

    trollConnection = RunService.Heartbeat:Connect(function()
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            stopTroll()
            return
        end
        myChar = LP.Character
        myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end

        local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
        myHRP.CFrame = targetHRP.CFrame * CFrame.new(0, 1.5, 1)
    end)
    notify("Backpack: " .. player.DisplayName, "success")
end

flingAllPlayers = function()
    stopTroll()
    local myChar = LP.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end

    local savedCF = myHRP.CFrame
    local count = 0

    task.spawn(function()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LP and player.Character then
                local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
                if targetHRP then
                    myHRP.CFrame = targetHRP.CFrame * CFrame.new(0, 0, -2)
                    task.wait(0.15)
                    local bv = Instance.new("BodyVelocity")
                    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                    bv.Velocity = Vector3.new(math.random(-200, 200), 300, math.random(-200, 200))
                    bv.Parent = targetHRP
                    task.delay(0.3, function()
                        pcall(function() bv:Destroy() end)
                    end)
                    count = count + 1
                    task.wait(0.3)
                end
            end
        end
        task.wait(0.2)
        if myHRP and myHRP.Parent then
            myHRP.CFrame = savedCF
        end
        notify("Flung " .. count .. " players!", "success")
    end)
end

--==================================================
-- HELICOPTER TROLL — deita duro e gira na cabeça
--==================================================

helicopterPlayer = function(player)
    stopTroll()
    local targetChar = player.Character
    if not targetChar then notify("No character", "error") return end
    local head = targetChar:FindFirstChild("Head")
    local myChar = LP.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    if not head or not myHRP or not myHum then return end

    trollSaveCFrame()
    myHum:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
    myHum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)

    local angle = 0
    trollConnection = RunService.Heartbeat:Connect(function()
        if not player.Character or not player.Character:FindFirstChild("Head") then
            stopTroll()
            return
        end
        myChar = LP.Character
        myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end

        head = player.Character:FindFirstChild("Head")
        angle = (angle + 16 * trollSpeedMul) % 360
        -- Deitado duro (Z=90°) + girando rápido (Y) na cabeça
        myHRP.CFrame = head.CFrame
            * CFrame.new(0, 2.5, 0)
            * CFrame.Angles(math.rad(90), math.rad(angle), 0)
    end)
    notify("Helicopter: " .. player.DisplayName, "success")
end

--==================================================
-- SPIN TOP — gira em pé na cabeça do alvo
--==================================================

spinTopPlayer = function(player)
    stopTroll()
    local targetChar = player.Character
    if not targetChar then notify("No character", "error") return end
    local head = targetChar:FindFirstChild("Head")
    local myChar = LP.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    if not head or not myHRP or not myHum then return end

    trollSaveCFrame()
    myHum:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
    myHum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)

    local angle = 0
    trollConnection = RunService.Heartbeat:Connect(function()
        if not player.Character or not player.Character:FindFirstChild("Head") then
            stopTroll()
            return
        end
        myChar = LP.Character
        myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end

        head = player.Character:FindFirstChild("Head")
        angle = (angle + 20 * trollSpeedMul) % 360
        -- Em pé girando rápido tipo pião
        myHRP.CFrame = head.CFrame
            * CFrame.new(0, 2, 0)
            * CFrame.Angles(0, math.rad(angle), 0)
    end)
    notify("Spin top: " .. player.DisplayName, "success")
end

--==================================================
-- TRAMPOLINE — pula em cima do alvo
--==================================================

trampolinePlayer = function(player)
    stopTroll()
    local targetChar = player.Character
    if not targetChar then notify("No character", "error") return end
    local myChar = LP.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    if not myHRP or not myHum then return end

    trollSaveCFrame()
    myHum:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
    myHum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)

    local t = 0
    trollConnection = RunService.Heartbeat:Connect(function()
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            stopTroll()
            return
        end
        myChar = LP.Character
        myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end

        local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
        t = t + 1
        -- Pula e desce, loop infinito
        local bounce = math.abs(math.sin(t * 0.08 * trollSpeedMul)) * 5
        myHRP.CFrame = targetHRP.CFrame * CFrame.new(0, 3 + bounce, 0)
    end)
    notify("Trampoline: " .. player.DisplayName, "success")
end

--==================================================
-- CREEP — se aproxima lentamente por trás
--==================================================

creepPlayer = function(player)
    stopTroll()
    local targetChar = player.Character
    if not targetChar then notify("No character", "error") return end
    local myChar = LP.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    if not myHRP or not myHum then return end

    trollSaveCFrame()
    myHum:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
    myHum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)

    local dist = 20
    trollConnection = RunService.Heartbeat:Connect(function()
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            stopTroll()
            return
        end
        myChar = LP.Character
        myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end

        local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
        -- Vai se aproximando devagar por trás
        dist = math.max(dist - 0.03 * trollSpeedMul, 1.5)
        local behindCF = targetHRP.CFrame * CFrame.new(0, 0, dist)
        myHRP.CFrame = CFrame.lookAt(behindCF.Position, targetHRP.Position)
    end)
    notify("Creeping on " .. player.DisplayName .. "...", "success")
end

--==================================================
-- LAUNCH — manda o alvo pro céu repetidamente
--==================================================

launchPlayer = function(player)
    stopTroll()
    local myChar = LP.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end

    local savedCF = myHRP.CFrame

    trollConnection = task.spawn(function()
        while true do
            if not player.Character then break end
            local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
            if not targetHRP then break end

            myChar = LP.Character
            myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
            if not myHRP then break end

            -- TP pra perto e aplica velocity pra cima
            myHRP.CFrame = targetHRP.CFrame * CFrame.new(0, 0, -2)
            task.wait(0.15)
            local bv = Instance.new("BodyVelocity")
            bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bv.Velocity = Vector3.new(0, 500, 0)
            bv.Parent = targetHRP
            task.delay(0.2, function()
                pcall(function() bv:Destroy() end)
            end)
            -- Volta pra posição original
            task.wait(0.3)
            if myHRP and myHRP.Parent then
                myHRP.CFrame = savedCF
            end
            task.wait(2 / trollSpeedMul)
        end
    end)
    notify("Launching: " .. player.DisplayName, "success")
end

--==================================================
-- CARPET — deita no chão embaixo do alvo
--==================================================

carpetPlayer = function(player)
    stopTroll()
    local targetChar = player.Character
    if not targetChar then notify("No character", "error") return end
    local myChar = LP.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    if not myHRP or not myHum then return end

    trollSaveCFrame()
    myHum:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
    myHum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)

    trollConnection = RunService.Heartbeat:Connect(function()
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            stopTroll()
            return
        end
        myChar = LP.Character
        myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end

        local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
        -- Deitado embaixo dos pés do alvo (tapete humano)
        myHRP.CFrame = targetHRP.CFrame
            * CFrame.new(0, -2.5, 0)
            * CFrame.Angles(math.rad(90), 0, 0)
    end)
    notify("Carpet: " .. player.DisplayName, "success")
end

--==================================================
-- DIZZY — orbita super rápido e perto
--==================================================

dizzyPlayer = function(player)
    stopTroll()
    local targetChar = player.Character
    if not targetChar then notify("No character", "error") return end
    local myChar = LP.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    if not myHRP or not myHum then return end

    trollSaveCFrame()
    myHum:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
    myHum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)

    local angle = 0
    local yBob = 0
    trollConnection = RunService.Heartbeat:Connect(function()
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            stopTroll()
            return
        end
        myChar = LP.Character
        myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end

        local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
        -- Orbita SUPER rápido e colado (raio 1.5)
        angle = (angle + 30 * trollSpeedMul) % 360
        yBob = yBob + 0.15 * trollSpeedMul
        local rad = math.rad(angle)
        local yOffset = math.sin(yBob) * 1.5
        local pos = targetHRP.CFrame * CFrame.new(math.sin(rad) * 1.5, yOffset, math.cos(rad) * 1.5)
        myHRP.CFrame = CFrame.lookAt(pos.Position, targetHRP.Position)
    end)
    notify("Dizzy: " .. player.DisplayName, "success")
end

--==================================================
-- REMOTE SPY FUNCTIONS
--==================================================

scanRemotes = function()
    scannedRemotes = {}
    local seen = {}

    local function addRemote(obj, src)
        local ok2, path = pcall(function() return obj:GetFullName() end)
        if not ok2 then path = src .. "." .. tostring(obj) end
        if seen[path] then return end
        seen[path] = true
        local prefix = ""
        if src == "nil" then prefix = "👻 "
        elseif src == "gc" then prefix = "🗑 " end
        table.insert(scannedRemotes, {
            instance = obj,
            name = prefix .. obj.Name,
            path = path,
            class = obj.ClassName,
            source = src,
        })
    end

    -- 1. Descendants normais
    pcall(function()
        for _, obj in pairs(game:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction")
                or obj:IsA("BindableEvent") or obj:IsA("BindableFunction") then
                addRemote(obj, "tree")
            end
        end
    end)

    -- 2. Nil instances (remotes escondidos sem parent)
    local _env = (typeof(getgenv) == "function" and getgenv()) or {}
    local _getNil = getnilinstances or _env.getnilinstances
    if _getNil then
        pcall(function()
            for _, obj in pairs(_getNil()) do
                if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction")
                    or obj:IsA("BindableEvent") or obj:IsA("BindableFunction") then
                    addRemote(obj, "nil")
                end
            end
        end)
    end

    -- 3. Garbage collector (referências vazadas)
    local _getGC = getgc or _env.getgc
    if _getGC then
        pcall(function()
            for _, v in pairs(_getGC(true)) do
                if typeof(v) == "Instance" then
                    if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
                        addRemote(v, "gc")
                    end
                end
            end
        end)
    end

    table.sort(scannedRemotes, function(a, b) return a.name < b.name end)
    log("Deep scanned remotes:", #scannedRemotes)
end

--==================================================
-- SERIALIZE ARG — converte valor Lua em codigo copiavel
--==================================================

serializeArg = function(value)
    local t = typeof(value)
    if t == "string" then
        return '"' .. value:gsub('\\', '\\\\'):gsub('"', '\\"'):gsub('\n', '\\n') .. '"'
    elseif t == "number" then
        return tostring(value)
    elseif t == "boolean" then
        return tostring(value)
    elseif t == "nil" then
        return "nil"
    elseif t == "Instance" then
        return "game." .. value:GetFullName()
    elseif t == "Vector3" then
        return string.format("Vector3.new(%s, %s, %s)", value.X, value.Y, value.Z)
    elseif t == "CFrame" then
        local c = {value:GetComponents()}
        return "CFrame.new(" .. table.concat(c, ", ") .. ")"
    elseif t == "Color3" then
        return string.format("Color3.new(%s, %s, %s)", value.R, value.G, value.B)
    elseif t == "UDim2" then
        return string.format("UDim2.new(%s, %s, %s, %s)", value.X.Scale, value.X.Offset, value.Y.Scale, value.Y.Offset)
    elseif t == "EnumItem" then
        return tostring(value)
    elseif t == "table" then
        local parts = {}
        for k, v in pairs(value) do
            if type(k) == "number" then
                table.insert(parts, serializeArg(v))
            else
                table.insert(parts, "[" .. serializeArg(k) .. "] = " .. serializeArg(v))
            end
        end
        return "{" .. table.concat(parts, ", ") .. "}"
    else
        return "nil --[[ " .. t .. ": " .. tostring(value) .. " ]]"
    end
end

--==================================================
-- COPY LOG ENTRY — gera script e copia pro clipboard
--==================================================

copyLogEntry = function(entry)
    local argParts = {}
    for _, arg in ipairs(entry.args) do
        pcall(function()
            table.insert(argParts, serializeArg(arg))
        end)
    end
    local argsStr = table.concat(argParts, ", ")

    local script = ""
    -- Comentario com caller se disponivel
    if entry.caller and entry.caller ~= "" then
        script = script .. "-- Caller: " .. entry.caller .. "\n"
    end
    -- Comentario com return se disponivel
    if entry.returnValue then
        script = script .. "-- Return: " .. entry.returnValue .. "\n"
    end
    -- Comando principal
    script = script .. "game." .. entry.path .. ":" .. entry.method .. "(" .. argsStr .. ")"

    pcall(function()
        if setclipboard then
            setclipboard(script)
        elseif toclipboard then
            toclipboard(script)
        end
    end)

    -- Auto-fill args box para re-fire rápido
    pcall(function() RemoteSpyArgsBox.Text = argsStr end)

    -- Auto-select o remote se existe nos scannedRemotes
    pcall(function()
        for _, data in ipairs(scannedRemotes) do
            if data.path == entry.path then
                selectedFireRemote = data
                RemoteSpySelectedLabel.Text = "Selected: " .. data.class:sub(7, 7) .. " " .. data.name
                RemoteSpySelectedLabel.TextColor3 = Color3.fromRGB(100, 220, 200)
                break
            end
        end
    end)

    notify("Copied + auto-selected!", "success")
    log("Copied script:", script:sub(1, 100))
end

--==================================================
-- EXPORT SPY LOG — copia log inteiro pro clipboard
--==================================================

exportSpyLog = function()
    if #remoteSpyLog == 0 then
        notify("Spy log is empty", "warning")
        return
    end

    local lines = {}
    table.insert(lines, "-- Remote Spy Log Export")
    table.insert(lines, "-- " .. #remoteSpyLog .. " entries")
    table.insert(lines, "")

    for idx, entry in ipairs(remoteSpyLog) do
        local secs = math.floor(entry.time % 60)
        local mins = math.floor((entry.time / 60) % 60)
        local hrs = math.floor((entry.time / 3600) % 24)
        local timeStr = string.format("%02d:%02d:%02d", hrs, mins, secs)

        local argParts = {}
        for _, arg in ipairs(entry.args) do
            pcall(function()
                table.insert(argParts, serializeArg(arg))
            end)
        end
        local argsStr = table.concat(argParts, ", ")

        local line = "-- [" .. timeStr .. "]"
        if entry.caller and entry.caller ~= "" then
            line = line .. " from " .. entry.caller
        end
        table.insert(lines, line)
        local cmd = "game." .. entry.path .. ":" .. entry.method .. "(" .. argsStr .. ")"
        if entry.returnValue then
            cmd = cmd .. " -- → " .. entry.returnValue
        end
        table.insert(lines, cmd)
        table.insert(lines, "")
    end

    local fullText = table.concat(lines, "\n")
    pcall(function()
        if setclipboard then
            setclipboard(fullText)
        elseif toclipboard then
            toclipboard(fullText)
        end
    end)
    notify("Exported " .. #remoteSpyLog .. " entries to clipboard!", "success")
end

--==================================================
-- SPY HOOK — com block, call counter, caller, return logger
--==================================================

startRemoteSpy = function()
    if remoteSpyActive then return end

    remoteSpyActive = true
    remoteSpyLog = {}

    -- So instala hook uma vez (evita double-hook)
    if not remoteSpyHook then
        -- Resolve funções do executor (direto ou via getgenv)
        local _env = (typeof(getgenv) == "function" and getgenv()) or {}
        local _hookMeta = hookmetamethod or _env.hookmetamethod
        local _getMethod = getnamecallmethod or _env.getnamecallmethod
        local _wrap = newcclosure or clonefunction or _env.newcclosure or _env.clonefunction
        local _getRawMT = getrawmetatable or _env.getrawmetatable
        local _setReadonly = setreadonly or _env.setreadonly
        local _hookFn = hookfunction or _env.hookfunction
        local _getCaller = getcallingscript or _env.getcallingscript

        local hookOk = false

        -- ═══ Estratégia A: __namecall hook (precisa de getnamecallmethod) ═══
        if _getMethod then
            local function spyHookFn(self, ...)
                local method = _getMethod()
                if method == "FireServer" or method == "InvokeServer" then
                    local isRemote = false
                    pcall(function()
                        isRemote = self:IsA("RemoteEvent") or self:IsA("RemoteFunction")
                    end)
                    if isRemote then
                        local remotePath = "?"
                        pcall(function() remotePath = self:GetFullName() end)
                        remoteCallCounts[remotePath] = (remoteCallCounts[remotePath] or 0) + 1
                        if blockedRemotes[remotePath] then return nil end
                        if remoteSpyActive then
                            local caller = ""
                            pcall(function()
                                if _getCaller then
                                    local cs = _getCaller()
                                    if cs then caller = cs:GetFullName() end
                                end
                            end)
                            local entry = {
                                time = os.clock(), name = "?", path = remotePath,
                                method = method, args = {...}, caller = caller, returnValue = nil,
                            }
                            pcall(function() entry.name = self.Name end)
                            local result = remoteSpyHook(self, ...)
                            if method == "InvokeServer" then
                                pcall(function() entry.returnValue = tostring(result) end)
                            end
                            table.insert(remoteSpyLog, entry)
                            if #remoteSpyLog > 200 then table.remove(remoteSpyLog, 1) end
                            pcall(function() refreshRemoteSpyLog() end)
                            return result
                        end
                    end
                end
                return remoteSpyHook(self, ...)
            end

            local wrappedHook = spyHookFn
            if _wrap then pcall(function() wrappedHook = _wrap(spyHookFn) end) end

            -- Metodo 1: hookmetamethod (preferido)
            if _hookMeta then
                pcall(function()
                    remoteSpyHook = _hookMeta(game, "__namecall", wrappedHook)
                    if remoteSpyHook then hookOk = true end
                end)
            end

            -- Metodo 2: getrawmetatable + setreadonly
            if not hookOk and _getRawMT then
                pcall(function()
                    local mt = _getRawMT(game)
                    local oldNamecall = mt.__namecall
                    remoteSpyHook = oldNamecall
                    if _setReadonly then _setReadonly(mt, false) end
                    mt.__namecall = wrappedHook
                    if _setReadonly then _setReadonly(mt, true) end
                    hookOk = true
                end)
            end

            -- Metodo 3: hookfunction no __namecall
            if not hookOk and _hookFn and _getRawMT then
                pcall(function()
                    local mt = _getRawMT(game)
                    if mt and mt.__namecall then
                        remoteSpyHook = _hookFn(mt.__namecall, wrappedHook)
                        hookOk = true
                    end
                end)
            end
        end

        -- ═══ Estratégia B: Hook direto FireServer/InvokeServer (sem getnamecallmethod) ═══
        if not hookOk and _hookFn then
            pcall(function()
                local tmpRE = Instance.new("RemoteEvent")
                local tmpRF = Instance.new("RemoteFunction")
                local origFire = tmpRE.FireServer
                local origInvoke = tmpRF.InvokeServer
                tmpRE:Destroy()
                tmpRF:Destroy()

                -- Refs mutáveis — hookfunction retorna o original real
                local realFire, realInvoke

                local function fireSpyHook(self, ...)
                    local remotePath = "?"
                    pcall(function() remotePath = self:GetFullName() end)
                    remoteCallCounts[remotePath] = (remoteCallCounts[remotePath] or 0) + 1
                    if blockedRemotes[remotePath] then return nil end
                    if remoteSpyActive then
                        local caller = ""
                        pcall(function()
                            if _getCaller then local cs = _getCaller() if cs then caller = cs:GetFullName() end end
                        end)
                        local entry = {
                            time = os.clock(), name = "?", path = remotePath,
                            method = "FireServer", args = {...}, caller = caller, returnValue = nil,
                        }
                        pcall(function() entry.name = self.Name end)
                        table.insert(remoteSpyLog, entry)
                        if #remoteSpyLog > 200 then table.remove(remoteSpyLog, 1) end
                        pcall(function() refreshRemoteSpyLog() end)
                    end
                    return realFire(self, ...)
                end

                local function invokeSpyHook(self, ...)
                    local remotePath = "?"
                    pcall(function() remotePath = self:GetFullName() end)
                    remoteCallCounts[remotePath] = (remoteCallCounts[remotePath] or 0) + 1
                    if blockedRemotes[remotePath] then return nil end
                    if remoteSpyActive then
                        local caller = ""
                        pcall(function()
                            if _getCaller then local cs = _getCaller() if cs then caller = cs:GetFullName() end end
                        end)
                        local entry = {
                            time = os.clock(), name = "?", path = remotePath,
                            method = "InvokeServer", args = {...}, caller = caller, returnValue = nil,
                        }
                        pcall(function() entry.name = self.Name end)
                        local result = realInvoke(self, ...)
                        pcall(function() entry.returnValue = tostring(result) end)
                        table.insert(remoteSpyLog, entry)
                        if #remoteSpyLog > 200 then table.remove(remoteSpyLog, 1) end
                        pcall(function() refreshRemoteSpyLog() end)
                        return result
                    end
                    return realInvoke(self, ...)
                end

                local wFire = fireSpyHook
                local wInvoke = invokeSpyHook
                if _wrap then
                    pcall(function() wFire = _wrap(fireSpyHook) end)
                    pcall(function() wInvoke = _wrap(invokeSpyHook) end)
                end

                realFire = _hookFn(origFire, wFire)
                realInvoke = _hookFn(origInvoke, wInvoke)
                remoteSpyHook = true -- marca que hook foi instalado
                hookOk = true
            end)
        end

        if not hookOk then
            remoteSpyHook = nil
            remoteSpyActive = false
            notify("Hook failed — executor not supported", "error")
            return false
        end
    end

    notify("Remote Spy ON — logging calls", "success")
    RemoteSpyStatusLabel.Text = "Spy: ON (logging...)"
    RemoteSpyStatusLabel.TextColor3 = Color3.fromRGB(100, 220, 200)
    RemoteSpyToggleBtn.Text = "⏹ STOP SPY"
    RemoteSpyToggleBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 30)
    return true
end

stopRemoteSpy = function()
    remoteSpyActive = false
    RemoteSpyStatusLabel.Text = "Spy: OFF (hook active)"
    RemoteSpyStatusLabel.TextColor3 = Colors.textDim
    RemoteSpyToggleBtn.Text = "🕵 START SPY"
    RemoteSpyToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 80, 70)
    notify("Remote Spy OFF", "info")
end

--==================================================
-- PARSE FIRE ARGS
--==================================================

parseFireArgs = function(text)
    if not text or text == "" then return {} end
    local fn, err = loadstring("return {" .. text .. "}")
    if fn then
        local ok, result = pcall(fn)
        if ok and type(result) == "table" then
            return result
        end
    end
    notify("Args parse error — sending as string", "warning")
    return { text }
end

fireTestRemote = function(remote, customArgs)
    if not remote or not remote.Parent then
        notify("Remote no longer exists", "error")
        return
    end
    local remoteName = remote.Name
    local remotePath = pcall(function() return remote:GetFullName() end) and remote:GetFullName() or remoteName
    local args = customArgs or {}
    local argCount = #args

    log("Test fire:", remotePath, "args:", argCount)

    task.spawn(function()
        local ok, err = pcall(function()
            if remote:IsA("RemoteEvent") then
                remote:FireServer(unpack(args))
                notify("Fired: " .. remoteName .. " (" .. argCount .. " args)", "success")
            elseif remote:IsA("RemoteFunction") then
                notify("Invoking: " .. remoteName .. "...", "info")
                local result = remote:InvokeServer(unpack(args))
                notify("Invoked: " .. remoteName .. " → " .. tostring(result), "success")
            end
        end)
        if not ok then
            notify("Fire error: " .. tostring(err):sub(1, 60), "error")
        end
    end)
end

--==================================================
-- AUTO-REPEAT — repete fire no remote selecionado
--==================================================

startAutoRepeat = function(interval, count)
    if not selectedFireRemote then
        notify("Select a remote first (🎯)", "warning")
        return
    end
    if autoRepeatActive then
        notify("Already repeating", "warning")
        return
    end

    autoRepeatActive = true
    local remote = selectedFireRemote.instance
    local args = parseFireArgs(RemoteSpyArgsBox.Text)
    local remoteName = selectedFireRemote.name

    RemoteSpyRepeatBtn.Text = "⏹ STOP"
    RemoteSpyRepeatBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)

    task.spawn(function()
        local fired = 0
        while autoRepeatActive and (count == 0 or fired < count) do
            if not remote or not remote.Parent then
                notify("Remote gone, stopping", "error")
                break
            end
            pcall(function()
                if remote:IsA("RemoteEvent") then
                    remote:FireServer(unpack(args))
                else
                    remote:InvokeServer(unpack(args))
                end
            end)
            fired = fired + 1
            task.wait(interval)
        end
        autoRepeatActive = false
        RemoteSpyRepeatBtn.Text = "▶ REPEAT"
        RemoteSpyRepeatBtn.BackgroundColor3 = Color3.fromRGB(80, 40, 120)
        notify("Repeat done: " .. fired .. "x " .. remoteName, "info")
    end)
end

stopAutoRepeat = function()
    autoRepeatActive = false
end

--==================================================
-- VULNERABILITY SCAN
--==================================================

vulnScanRemotes = function()
    if #scannedRemotes == 0 then
        scanRemotes()
    end
    local vulnCount = 0
    local tested = 0
    local pending = 0

    for _, data in ipairs(scannedRemotes) do
        local remote = data.instance
        if not remote or not remote.Parent then
            data.vuln = "gone"
        else
            tested = tested + 1
            if remote:IsA("RemoteEvent") then
                local ok = pcall(function()
                    remote:FireServer()
                end)
                data.vuln = ok and "vuln" or "safe"
                if ok then vulnCount = vulnCount + 1 end
            else
                data.vuln = "testing"
                pending = pending + 1
                task.spawn(function()
                    local ok = pcall(function()
                        remote:InvokeServer()
                    end)
                    if data.vuln == "testing" then
                        data.vuln = ok and "vuln" or "safe"
                        if ok then vulnCount = vulnCount + 1 end
                    end
                    pending = pending - 1
                end)
            end
        end
    end

    local deadline = os.clock() + 3
    while pending > 0 and os.clock() < deadline do
        task.wait(0.1)
    end

    for _, data in ipairs(scannedRemotes) do
        if data.vuln == "testing" then
            data.vuln = "timeout"
        end
    end

    refreshRemoteList(RemoteSpyFilterBox.Text)
    local msg = "Vuln scan: " .. vulnCount .. " vuln / " .. tested .. " tested"
    if pending > 0 then
        msg = msg .. " (" .. pending .. " timeout)"
    end
    notify(msg, vulnCount > 0 and "error" or "success")
    RemoteSpyStatsLabel.Text = msg
end

--==================================================
-- MASS FIRE
--==================================================

massFireRemotes = function()
    if #scannedRemotes == 0 then
        notify("Scan remotes first", "error")
        return
    end
    local fired = 0
    for _, data in ipairs(scannedRemotes) do
        local remote = data.instance
        if remote and remote.Parent and not blockedRemotes[data.path] then
            pcall(function()
                if remote:IsA("RemoteEvent") then
                    remote:FireServer()
                elseif remote:IsA("RemoteFunction") then
                    remote:InvokeServer()
                end
            end)
            fired = fired + 1
        end
    end
    notify("Mass fire: " .. fired .. " remotes fired", "success")
end

--==================================================
-- FUZZ REMOTE — testa 18 padrões de args automaticamente
--==================================================

fuzzRemote = function()
    if not selectedFireRemote then
        notify("Select a remote first (🎯)", "warning")
        return
    end
    local remote = selectedFireRemote.instance
    if not remote or not remote.Parent then
        notify("Remote no longer exists", "error")
        return
    end

    local remoteName = selectedFireRemote.name
    notify("🧪 Fuzzing: " .. remoteName .. "...", "info")

    local LP2 = game.Players.LocalPlayer
    local patterns = {
        { "empty",      {} },
        { "true",       {true} },
        { "false",      {false} },
        { "0",          {0} },
        { "1",          {1} },
        { "-1",         {-1} },
        { "huge",       {math.huge} },
        { "999999999",  {999999999} },
        { "string",     {"test"} },
        { "empty str",  {""} },
        { "player",     {LP2} },
        { "name",       {LP2.Name} },
        { "userId",     {LP2.UserId} },
        { "workspace",  {workspace} },
        { "empty tbl",  {{}} },
        { "kv tbl",     {{Action = "test"}} },
        { "multi str",  {"admin", true, 999} },
        { "char",       {LP2.Character} },
    }

    local isEvent = remote:IsA("RemoteEvent")

    task.spawn(function()
        local results = {}
        local okCount = 0
        for _, p in ipairs(patterns) do
            local label, args = p[1], p[2]
            local ok, err
            local ret = nil
            ok, err = pcall(function()
                if isEvent then
                    remote:FireServer(unpack(args))
                else
                    ret = remote:InvokeServer(unpack(args))
                end
            end)

            local icon = ok and "✅" or "❌"
            if ok then okCount = okCount + 1 end
            local detail = ""
            if ok and not isEvent and ret ~= nil then
                detail = " → " .. tostring(ret):sub(1, 50)
            elseif not ok then
                detail = " → " .. tostring(err):sub(1, 50)
            end
            table.insert(results, icon .. " " .. label .. detail)
            task.wait(0.15)
        end

        -- Copia resultados pro clipboard
        local lines = {
            "-- ═══ Fuzz Results ═══",
            "-- Remote: " .. remoteName,
            "-- Type: " .. (isEvent and "RemoteEvent" or "RemoteFunction"),
            "-- Accepted: " .. okCount .. "/" .. #results,
            "",
        }
        for _, r in ipairs(results) do
            table.insert(lines, "-- " .. r)
        end
        local text = table.concat(lines, "\n")
        pcall(function()
            if setclipboard then setclipboard(text)
            elseif toclipboard then toclipboard(text) end
        end)

        notify("Fuzz: " .. okCount .. "/" .. #results .. " accepted — copied!", okCount > 0 and "success" or "warning")
    end)
end

--==================================================
-- DECOMPILE FOR REMOTE — acha uso do remote nos scripts
--==================================================

decompileForRemote = function()
    if not selectedFireRemote then
        notify("Select a remote first (🎯)", "warning")
        return
    end
    local remoteName = selectedFireRemote.name:gsub("👻 ", ""):gsub("🗑 ", "")

    local _env = (typeof(getgenv) == "function" and getgenv()) or {}
    local _decompile = decompile or _env.decompile
    if not _decompile then
        notify("decompile() not available", "error")
        return
    end

    notify("📜 Decompiling for: " .. remoteName .. "...", "info")

    task.spawn(function()
        local scripts = {}
        pcall(function()
            for _, obj in pairs(game:GetDescendants()) do
                if obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
                    table.insert(scripts, obj)
                end
            end
        end)

        local found = {}
        local checked = 0
        for _, scr in ipairs(scripts) do
            checked = checked + 1
            pcall(function()
                local source = _decompile(scr)
                if source and source:find(remoteName, 1, true) then
                    local context = {}
                    local lineNum = 0
                    for line in source:gmatch("[^\n]+") do
                        lineNum = lineNum + 1
                        if line:find(remoteName, 1, true) then
                            table.insert(context, "L" .. lineNum .. ": " .. line:sub(1, 120))
                        end
                    end
                    if #context > 0 then
                        table.insert(found, {
                            script = scr:GetFullName(),
                            lines = context,
                        })
                    end
                end
            end)
            if #found >= 15 then break end
            if checked % 10 == 0 then task.wait() end
        end

        if #found == 0 then
            notify("No scripts reference '" .. remoteName .. "'", "warning")
            return
        end

        local lines = {
            "-- ═══ Decompile Results ═══",
            "-- Remote: " .. remoteName,
            "-- Checked: " .. checked .. " scripts",
            "-- Found in: " .. #found .. " scripts",
            "",
        }
        for _, f in ipairs(found) do
            table.insert(lines, "-- ═══ " .. f.script .. " ═══")
            for _, l in ipairs(f.lines) do
                table.insert(lines, "--   " .. l)
            end
            table.insert(lines, "")
        end

        local text = table.concat(lines, "\n")
        pcall(function()
            if setclipboard then setclipboard(text)
            elseif toclipboard then toclipboard(text) end
        end)

        notify("Found in " .. #found .. " scripts — copied!", "success")
    end)
end

--==================================================
-- MORE FUN TROLLS
--==================================================

-- MAGNET — gruda nas costas do alvo (piggyback)
magnetPlayer = function(player)
    stopTroll()
    local targetChar = player.Character
    if not targetChar then notify("No character", "error") return end
    local myChar = LP.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    if not myHRP or not myHum then return end

    trollSaveCFrame()
    myHum:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
    myHum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)

    trollConnection = RunService.Heartbeat:Connect(function()
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            stopTroll()
            return
        end
        myChar = LP.Character
        myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end

        local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
        -- Costas do alvo, um pouco acima (piggyback)
        myHRP.CFrame = targetHRP.CFrame * CFrame.new(0, 1.5, 1)
    end)
    notify("Magnet: " .. player.DisplayName, "success")
end

-- CLONE — sobrepor exatamente no avatar do alvo (impostor)
clonePlayer = function(player)
    stopTroll()
    local targetChar = player.Character
    if not targetChar then notify("No character", "error") return end
    local myChar = LP.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    if not myHRP or not myHum then return end

    trollSaveCFrame()
    myHum:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
    myHum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)

    trollConnection = RunService.Heartbeat:Connect(function()
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            stopTroll()
            return
        end
        myChar = LP.Character
        myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end

        local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
        -- Exatamente na mesma posição (overlap total)
        myHRP.CFrame = targetHRP.CFrame
    end)
    notify("Clone: " .. player.DisplayName, "success")
end

-- UPSIDE DOWN — pendurado de cabeça pra baixo acima do alvo
upsideDownPlayer = function(player)
    stopTroll()
    local targetChar = player.Character
    if not targetChar then notify("No character", "error") return end
    local myChar = LP.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    if not myHRP or not myHum then return end

    trollSaveCFrame()
    myHum:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
    myHum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)

    trollConnection = RunService.Heartbeat:Connect(function()
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            stopTroll()
            return
        end
        myChar = LP.Character
        myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end

        local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
        -- Acima do alvo, invertido 180° no eixo Z
        myHRP.CFrame = targetHRP.CFrame
            * CFrame.new(0, 6, 0)
            * CFrame.Angles(0, 0, math.rad(180))
    end)
    notify("Upside Down: " .. player.DisplayName, "success")
end

-- TORNADO — orbita que pulsa (raio muda, sobe e desce)
tornadoPlayer = function(player)
    stopTroll()
    local targetChar = player.Character
    if not targetChar then notify("No character", "error") return end
    local myChar = LP.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    if not myHRP or not myHum then return end

    trollSaveCFrame()
    myHum:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
    myHum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)

    local angle = 0
    local t = 0
    trollConnection = RunService.Heartbeat:Connect(function()
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            stopTroll()
            return
        end
        myChar = LP.Character
        myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end

        local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
        angle = (angle + 12 * trollSpeedMul) % 360
        t = t + 0.08 * trollSpeedMul
        -- Raio pulsa entre 2 e 6
        local radius = 4 + math.sin(t) * 2
        -- Altura sobe e desce
        local yOffset = math.sin(t * 1.5) * 3
        local rad = math.rad(angle)
        local pos = targetHRP.CFrame * CFrame.new(math.sin(rad) * radius, yOffset, math.cos(rad) * radius)
        myHRP.CFrame = CFrame.lookAt(pos.Position, targetHRP.Position)
    end)
    notify("Tornado: " .. player.DisplayName, "success")
end

--==================================================
-- NEW TROLLS (15)
--==================================================

snakePlayer = function(player)
    stopTroll()
    local myChar = LP.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    if not myHRP or not myHum then return end
    trollSaveCFrame()
    myHum:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
    myHum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    local t = 0
    trollConnection = RunService.Heartbeat:Connect(function()
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            stopTroll()
            return
        end
        myChar = LP.Character
        myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end
        local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
        t = t + 0.05 * trollSpeedMul
        local behind = targetHRP.CFrame * CFrame.new(math.sin(t * 3) * 2, -2.5, -4)
        myHRP.CFrame = CFrame.new(behind.Position, targetHRP.Position) * CFrame.Angles(math.rad(80), 0, 0)
    end)
    notify("Snake: " .. player.DisplayName, "success")
end

mirrorPlayer = function(player)
    stopTroll()
    local myChar = LP.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    if not myHRP or not myHum then return end
    trollSaveCFrame()
    myHum:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
    myHum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    trollConnection = RunService.Heartbeat:Connect(function()
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            stopTroll()
            return
        end
        myChar = LP.Character
        myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end
        local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
        local frontPos = targetHRP.CFrame * CFrame.new(0, 0, -3)
        myHRP.CFrame = CFrame.lookAt(frontPos.Position, targetHRP.Position)
    end)
    notify("Mirror: " .. player.DisplayName, "success")
end

stackPlayer = function(player)
    stopTroll()
    local myChar = LP.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    if not myHRP or not myHum then return end
    trollSaveCFrame()
    myHum:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
    myHum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    trollConnection = RunService.Heartbeat:Connect(function()
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            stopTroll()
            return
        end
        myChar = LP.Character
        myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end
        local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
        myHRP.CFrame = targetHRP.CFrame * CFrame.new(0, 5, 0)
    end)
    notify("Stack: " .. player.DisplayName, "success")
end

figure8Player = function(player)
    stopTroll()
    local myChar = LP.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    if not myHRP or not myHum then return end
    trollSaveCFrame()
    myHum:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
    myHum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    local t = 0
    trollConnection = RunService.Heartbeat:Connect(function()
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            stopTroll()
            return
        end
        myChar = LP.Character
        myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end
        local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
        t = t + 0.03 * trollSpeedMul
        local scale = 5
        local x = scale * math.sin(t)
        local z = scale * math.sin(t) * math.cos(t)
        local pos = targetHRP.CFrame * CFrame.new(x, 0, z)
        myHRP.CFrame = CFrame.lookAt(pos.Position, targetHRP.Position)
    end)
    notify("Figure 8: " .. player.DisplayName, "success")
end

dogPlayer = function(player)
    stopTroll()
    local myChar = LP.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    if not myHRP or not myHum then return end
    trollSaveCFrame()
    myHum:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
    myHum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    trollConnection = RunService.Heartbeat:Connect(function()
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            stopTroll()
            return
        end
        myChar = LP.Character
        myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end
        local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
        local behindPos = targetHRP.CFrame * CFrame.new(0, -2, -4)
        myHRP.CFrame = CFrame.new(behindPos.Position, targetHRP.Position) * CFrame.Angles(math.rad(90), 0, 0)
    end)
    notify("Dog: " .. player.DisplayName, "success")
end

ferrisPlayer = function(player)
    stopTroll()
    local myChar = LP.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    if not myHRP or not myHum then return end
    trollSaveCFrame()
    myHum:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
    myHum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    local angle = 0
    trollConnection = RunService.Heartbeat:Connect(function()
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            stopTroll()
            return
        end
        myChar = LP.Character
        myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end
        local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
        angle = (angle + 3 * trollSpeedMul) % 360
        local rad = math.rad(angle)
        local radius = 5
        local pos = targetHRP.CFrame * CFrame.new(0, math.sin(rad) * radius, math.cos(rad) * radius)
        myHRP.CFrame = CFrame.lookAt(pos.Position, targetHRP.Position)
    end)
    notify("Ferris: " .. player.DisplayName, "success")
end

salsaPlayer = function(player)
    stopTroll()
    local myChar = LP.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    if not myHRP or not myHum then return end
    trollSaveCFrame()
    myHum:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
    myHum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    local t = 0
    trollConnection = RunService.Heartbeat:Connect(function()
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            stopTroll()
            return
        end
        myChar = LP.Character
        myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end
        local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
        t = t + 0.06 * trollSpeedMul
        local xOffset = math.sin(t * 2) * 3
        local zOffset = -3 + math.sin(t * 4) * 0.5
        local pos = targetHRP.CFrame * CFrame.new(xOffset, 0, zOffset)
        myHRP.CFrame = CFrame.lookAt(pos.Position, targetHRP.Position)
    end)
    notify("Salsa: " .. player.DisplayName, "success")
end

ufoPlayer = function(player)
    stopTroll()
    local myChar = LP.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    if not myHRP or not myHum then return end
    trollSaveCFrame()
    myHum:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
    myHum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    local angle = 0
    trollConnection = RunService.Heartbeat:Connect(function()
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            stopTroll()
            return
        end
        myChar = LP.Character
        myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end
        local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
        angle = (angle + 10 * trollSpeedMul) % 360
        local pos = targetHRP.CFrame * CFrame.new(0, 20, 0)
        myHRP.CFrame = CFrame.new(pos.Position) * CFrame.Angles(0, math.rad(angle), 0)
    end)
    notify("UFO: " .. player.DisplayName, "success")
end

boomerangPlayer = function(player)
    stopTroll()
    local myChar = LP.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    if not myHRP or not myHum then return end
    trollSaveCFrame()
    myHum:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
    myHum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    local t = 0
    trollConnection = RunService.Heartbeat:Connect(function()
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            stopTroll()
            return
        end
        myChar = LP.Character
        myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end
        local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
        t = t + 0.02 * trollSpeedMul
        local dist = 30 * (1 - math.cos(t))
        local yOff = math.sin(t * 2) * 5
        local pos = targetHRP.CFrame * CFrame.new(0, yOff, -dist)
        myHRP.CFrame = CFrame.lookAt(pos.Position, targetHRP.Position)
    end)
    notify("Boomerang: " .. player.DisplayName, "success")
end

rollerPlayer = function(player)
    stopTroll()
    local myChar = LP.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    if not myHRP or not myHum then return end
    trollSaveCFrame()
    myHum:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
    myHum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    local angle = 0
    trollConnection = RunService.Heartbeat:Connect(function()
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            stopTroll()
            return
        end
        myChar = LP.Character
        myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end
        local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
        angle = (angle + 4 * trollSpeedMul) % 360
        local rad = math.rad(angle)
        local radius = 6
        local yOff = math.sin(rad * 3) * 8
        local pos = targetHRP.CFrame * CFrame.new(math.sin(rad) * radius, yOff, math.cos(rad) * radius)
        myHRP.CFrame = CFrame.lookAt(pos.Position, targetHRP.Position)
    end)
    notify("Roller: " .. player.DisplayName, "success")
end

spiralPlayer = function(player)
    stopTroll()
    local myChar = LP.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    if not myHRP or not myHum then return end
    trollSaveCFrame()
    myHum:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
    myHum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    local angle = 0
    local height = 0
    trollConnection = RunService.Heartbeat:Connect(function()
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            stopTroll()
            return
        end
        myChar = LP.Character
        myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end
        local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
        angle = (angle + 8 * trollSpeedMul) % 360
        height = height + 0.15 * trollSpeedMul
        if height > 20 then height = 0 end
        local rad = math.rad(angle)
        local radius = 4
        local pos = targetHRP.CFrame * CFrame.new(math.sin(rad) * radius, height, math.cos(rad) * radius)
        myHRP.CFrame = CFrame.lookAt(pos.Position, targetHRP.Position)
    end)
    notify("Spiral: " .. player.DisplayName, "success")
end

surfPlayer = function(player)
    stopTroll()
    local myChar = LP.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    if not myHRP or not myHum then return end
    trollSaveCFrame()
    myHum:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
    myHum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    local angle = 0
    trollConnection = RunService.Heartbeat:Connect(function()
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            stopTroll()
            return
        end
        myChar = LP.Character
        myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end
        local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
        angle = (angle + 5 * trollSpeedMul) % 360
        local rad = math.rad(angle)
        local radius = 5
        local pos = targetHRP.CFrame * CFrame.new(math.sin(rad) * radius, -1, math.cos(rad) * radius)
        local lookDir = targetHRP.CFrame * CFrame.new(math.sin(rad + 0.1) * radius, -1, math.cos(rad + 0.1) * radius)
        myHRP.CFrame = CFrame.lookAt(pos.Position, lookDir.Position) * CFrame.Angles(0, 0, math.rad(90))
    end)
    notify("Surf: " .. player.DisplayName, "success")
end

bouncerPlayer = function(player)
    stopTroll()
    local myChar = LP.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    if not myHRP or not myHum then return end
    trollSaveCFrame()
    myHum:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
    myHum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    local t = 0
    trollConnection = RunService.Heartbeat:Connect(function()
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            stopTroll()
            return
        end
        myChar = LP.Character
        myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end
        local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
        t = t + 0.08 * trollSpeedMul
        local xOff = math.sin(t) * 6
        local yOff = math.abs(math.sin(t * 2)) * 3
        local pos = targetHRP.CFrame * CFrame.new(xOff, yOff, -2)
        myHRP.CFrame = CFrame.lookAt(pos.Position, targetHRP.Position)
    end)
    notify("Bouncer: " .. player.DisplayName, "success")
end

lapSitPlayer = function(player)
    stopTroll()
    local myChar = LP.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    if not myHRP or not myHum then return end
    trollSaveCFrame()
    myHum:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
    myHum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    myHum.Sit = true
    trollConnection = RunService.Heartbeat:Connect(function()
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            stopTroll()
            return
        end
        myChar = LP.Character
        myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
        if not myHRP then return end
        if myHum then myHum.Sit = true end
        local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
        myHRP.CFrame = targetHRP.CFrame * CFrame.new(0, -0.5, -1)
    end)
    notify("Lap Sit: " .. player.DisplayName, "success")
end

wavePlayer = function(player)
    stopTroll()
    local myChar = LP.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    if not myHRP or not myHum then return end
    trollSaveCFrame()
    myHum:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
    myHum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    local t = 0
    trollConnection = RunService.Heartbeat:Connect(function()
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            stopTroll()
            return
        end
        myChar = LP.Character
        myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end
        local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
        t = t + 0.04 * trollSpeedMul
        local zOff = math.sin(t) * 8
        local xOff = math.sin(t * 2) * 4
        local yOff = math.sin(t * 3) * 2
        local pos = targetHRP.CFrame * CFrame.new(xOff, yOff, zOff)
        myHRP.CFrame = CFrame.lookAt(pos.Position, targetHRP.Position)
    end)
    notify("Wave: " .. player.DisplayName, "success")
end

--==================================================
-- NEW TROLLS: Parasite, Stalk, Push, Swap, Jail
--==================================================

parasitePlayer = function(player)
    stopTroll()
    local targetChar = player.Character
    if not targetChar then notify("No character", "error") return end
    local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
    local myChar = LP.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    if not targetHRP or not myHRP or not myHum then return end

    trollSaveCFrame()
    myHum:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
    myHum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)

    trollConnection = RunService.Heartbeat:Connect(function()
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            stopTroll()
            return
        end
        myChar = LP.Character
        myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end
        -- Fica dentro do character alvo (sobreposto)
        myHRP.CFrame = player.Character:FindFirstChild("HumanoidRootPart").CFrame
    end)
    notify("Parasite: " .. player.DisplayName, "success")
end

stalkPlayer = function(player)
    stopTroll()
    local targetChar = player.Character
    if not targetChar then notify("No character", "error") return end
    local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
    local myChar = LP.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    if not targetHRP or not myHRP or not myHum then return end

    trollSaveCFrame()
    myHum:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
    myHum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)

    trollConnection = RunService.Heartbeat:Connect(function()
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            stopTroll()
            return
        end
        myChar = LP.Character
        myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end
        local tHRP = player.Character:FindFirstChild("HumanoidRootPart")
        -- 10 studs atrás, olhando pra ele
        local behindCF = tHRP.CFrame * CFrame.new(0, 0, 10)
        myHRP.CFrame = CFrame.lookAt(behindCF.Position, tHRP.Position)
    end)
    notify("Stalking: " .. player.DisplayName, "success")
end

pushPlayer = function(player)
    stopTroll()
    local targetChar = player.Character
    if not targetChar then notify("No character", "error") return end
    local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
    local myChar = LP.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    if not targetHRP or not myHRP or not myHum then return end

    trollSaveCFrame()
    myHum:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
    myHum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)

    trollConnection = RunService.Heartbeat:Connect(function()
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            stopTroll()
            return
        end
        myChar = LP.Character
        myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end
        local tHRP = player.Character:FindFirstChild("HumanoidRootPart")
        -- Fica 1 stud na frente dele empurrando
        local pushCF = tHRP.CFrame * CFrame.new(0, 0, -1)
        myHRP.CFrame = CFrame.lookAt(pushCF.Position, tHRP.Position)
        myHRP.Velocity = (tHRP.Position - myHRP.Position).Unit * 80
    end)
    notify("Pushing: " .. player.DisplayName, "success")
end

swapPlayer = function(player)
    local targetChar = player.Character
    if not targetChar then notify("No character", "error") return end
    local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
    local myChar = LP.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not targetHRP or not myHRP then return end

    -- Swap instantâneo (teleporta você pra posição dele)
    myHRP.CFrame = targetHRP.CFrame
    notify("Swapped with: " .. player.DisplayName, "success")
end

jailPlayer = function(player)
    stopTroll()
    local targetChar = player.Character
    if not targetChar then notify("No character", "error") return end
    local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
    if not targetHRP then return end

    -- Limpa jail anterior
    for _, p in ipairs(trollJailParts) do
        if p and p.Parent then p:Destroy() end
    end
    trollJailParts = {}

    -- Cria gaiola de 6 paredes ao redor do alvo
    local pos = targetHRP.Position
    local wallSize = 8
    local walls = {
        { size = Vector3.new(wallSize, wallSize, 0.5), cf = CFrame.new(pos + Vector3.new(0, 0, wallSize/2)) },
        { size = Vector3.new(wallSize, wallSize, 0.5), cf = CFrame.new(pos + Vector3.new(0, 0, -wallSize/2)) },
        { size = Vector3.new(0.5, wallSize, wallSize), cf = CFrame.new(pos + Vector3.new(wallSize/2, 0, 0)) },
        { size = Vector3.new(0.5, wallSize, wallSize), cf = CFrame.new(pos + Vector3.new(-wallSize/2, 0, 0)) },
        { size = Vector3.new(wallSize, 0.5, wallSize), cf = CFrame.new(pos + Vector3.new(0, wallSize/2, 0)) },
        { size = Vector3.new(wallSize, 0.5, wallSize), cf = CFrame.new(pos + Vector3.new(0, -wallSize/2, 0)) },
    }

    for _, w in ipairs(walls) do
        local part = Instance.new("Part")
        part.Size = w.size
        part.CFrame = w.cf
        part.Anchored = true
        part.CanCollide = true
        part.Material = Enum.Material.ForceField
        part.Color = Color3.fromRGB(180, 0, 0)
        part.Transparency = 0.5
        part.Parent = workspace
        table.insert(trollJailParts, part)
    end

    -- Seguir o alvo (atualiza posição da jail)
    trollConnection = RunService.Heartbeat:Connect(function()
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            stopTroll()
            return
        end
        local tHRP = player.Character:FindFirstChild("HumanoidRootPart")
        local tPos = tHRP.Position
        local i = 1
        for _, w in ipairs(walls) do
            if trollJailParts[i] and trollJailParts[i].Parent then
                local offsets = {
                    Vector3.new(0, 0, wallSize/2),
                    Vector3.new(0, 0, -wallSize/2),
                    Vector3.new(wallSize/2, 0, 0),
                    Vector3.new(-wallSize/2, 0, 0),
                    Vector3.new(0, wallSize/2, 0),
                    Vector3.new(0, -wallSize/2, 0),
                }
                trollJailParts[i].CFrame = CFrame.new(tPos + offsets[i])
            end
            i = i + 1
        end
    end)
    notify("Jailed: " .. player.DisplayName .. " (client-side)", "success")
end

--==================================================
-- PLAYER INFO CARDS
--==================================================

createPlayerInfoCard = function(player)
    if not player or not player.Character then return end
    if player == LP then return end
    local char = player.Character

    -- Remove existing
    local existing = char:FindFirstChild("VampPlayerInfo")
    if existing then existing:Destroy() end

    local bg = Instance.new("BillboardGui")
    bg.Name = "VampPlayerInfo"
    bg.Size = UDim2.new(0, 160, 0, 80)
    bg.StudsOffset = Vector3.new(0, 6, 0)
    bg.AlwaysOnTop = true
    bg.Adornee = char
    bg.Parent = char

    -- Card frame
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 1, 0)
    card.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
    card.BackgroundTransparency = 0.1
    card.Parent = bg
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)
    local cardStroke = Instance.new("UIStroke", card)
    cardStroke.Color = Color3.fromRGB(40, 180, 60)
    cardStroke.Thickness = 1
    cardStroke.Transparency = 0.3
    addGradient(card, Color3.fromRGB(20, 20, 24), Color3.fromRGB(8, 8, 10), 90)

    -- Photo (circular)
    local photoFrame = Instance.new("Frame")
    photoFrame.Size = UDim2.new(0, 36, 0, 36)
    photoFrame.Position = UDim2.new(0, 6, 0, 6)
    photoFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    photoFrame.Parent = card
    Instance.new("UICorner", photoFrame).CornerRadius = UDim.new(1, 0)
    local photoStroke = Instance.new("UIStroke", photoFrame)
    photoStroke.Color = Colors.blood
    photoStroke.Thickness = 1

    local photo = Instance.new("ImageLabel")
    photo.Size = UDim2.new(1, 0, 1, 0)
    photo.BackgroundTransparency = 1
    photo.Parent = photoFrame
    Instance.new("UICorner", photo).CornerRadius = UDim.new(1, 0)

    -- Load thumbnail async
    task.spawn(function()
        local ok, thumb = pcall(function()
            return Players:GetUserThumbnailAsync(
                player.UserId,
                Enum.ThumbnailType.HeadShot,
                Enum.ThumbnailSize.Size100x100
            )
        end)
        if ok and thumb then photo.Image = thumb end
    end)

    -- Display name
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -48, 0, 14)
    nameLabel.Position = UDim2.new(0, 46, 0, 4)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.DisplayName
    nameLabel.TextColor3 = Colors.text
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.TextStrokeTransparency = 0.5
    nameLabel.TextSize = 11
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
    nameLabel.Parent = card

    -- @username
    local userLabel = Instance.new("TextLabel")
    userLabel.Size = UDim2.new(1, -48, 0, 12)
    userLabel.Position = UDim2.new(0, 46, 0, 18)
    userLabel.BackgroundTransparency = 1
    userLabel.Text = "@" .. player.Name
    userLabel.TextColor3 = Colors.textDim
    userLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    userLabel.TextStrokeTransparency = 0.5
    userLabel.TextSize = 9
    userLabel.Font = Enum.Font.Gotham
    userLabel.TextXAlignment = Enum.TextXAlignment.Left
    userLabel.TextTruncate = Enum.TextTruncate.AtEnd
    userLabel.Parent = card

    -- ID
    local idLabel = Instance.new("TextLabel")
    idLabel.Size = UDim2.new(1, -48, 0, 12)
    idLabel.Position = UDim2.new(0, 46, 0, 30)
    idLabel.BackgroundTransparency = 1
    idLabel.Text = "ID: " .. tostring(player.UserId)
    idLabel.TextColor3 = Colors.textDim
    idLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    idLabel.TextStrokeTransparency = 0.5
    idLabel.TextSize = 8
    idLabel.Font = Enum.Font.Code
    idLabel.TextXAlignment = Enum.TextXAlignment.Left
    idLabel.Parent = card

    -- Account age
    local ageText
    local ageDays = player.AccountAge
    if ageDays >= 365 then
        ageText = string.format("%.1f years", ageDays / 365)
    elseif ageDays >= 30 then
        ageText = math.floor(ageDays / 30) .. " months"
    else
        ageText = ageDays .. " days"
    end

    local ageLabel = Instance.new("TextLabel")
    ageLabel.Size = UDim2.new(1, -12, 0, 12)
    ageLabel.Position = UDim2.new(0, 6, 0, 48)
    ageLabel.BackgroundTransparency = 1
    ageLabel.Text = "📅 " .. ageText
    ageLabel.TextColor3 = Color3.fromRGB(80, 220, 100)
    ageLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    ageLabel.TextStrokeTransparency = 0.5
    ageLabel.TextSize = 9
    ageLabel.Font = Enum.Font.GothamBold
    ageLabel.TextXAlignment = Enum.TextXAlignment.Left
    ageLabel.Parent = card

    -- Distance (updated every frame)
    local distLabel = Instance.new("TextLabel")
    distLabel.Name = "DistLabel"
    distLabel.Size = UDim2.new(1, -12, 0, 12)
    distLabel.Position = UDim2.new(0, 6, 0, 62)
    distLabel.BackgroundTransparency = 1
    distLabel.Text = "? studs"
    distLabel.TextColor3 = Colors.textDim
    distLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    distLabel.TextStrokeTransparency = 0.5
    distLabel.TextSize = 8
    distLabel.Font = Enum.Font.Code
    distLabel.TextXAlignment = Enum.TextXAlignment.Left
    distLabel.Parent = card

    table.insert(playerInfoBillboards, {
        player = player,
        billboard = bg,
        distLabel = distLabel,
    })
end

clearPlayerInfo = function()
    if playerInfoConnection then
        playerInfoConnection:Disconnect()
        playerInfoConnection = nil
    end
    for _, info in ipairs(playerInfoBillboards) do
        if info.billboard and info.billboard.Parent then
            info.billboard:Destroy()
        end
    end
    playerInfoBillboards = {}
end

updatePlayerInfo = function()
    clearPlayerInfo()
    if not playerInfoActive then return end

    -- Create for all existing players
    for _, player in ipairs(Players:GetPlayers()) do
        createPlayerInfoCard(player)
    end

    -- Update loop: distance + auto-detect new/respawned players
    local checkTimer = 0
    playerInfoConnection = RunService.RenderStepped:Connect(function(dt)
        local myChar = LP.Character
        local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myHRP then return end
        local myPos = myHRP.Position

        -- Update distance for tracked players
        for i = #playerInfoBillboards, 1, -1 do
            local info = playerInfoBillboards[i]
            if not info.player or not info.player.Parent or not info.player.Character or not info.billboard.Parent then
                if info.billboard and info.billboard.Parent then
                    info.billboard:Destroy()
                end
                table.remove(playerInfoBillboards, i)
            else
                local tHRP = info.player.Character:FindFirstChild("HumanoidRootPart")
                if tHRP then
                    local dist = math.floor((myPos - tHRP.Position).Magnitude)
                    info.distLabel.Text = dist .. " studs"
                end
            end
        end

        -- Check for new/respawned players every 2 seconds
        checkTimer = checkTimer + dt
        if checkTimer >= 2 then
            checkTimer = 0
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LP and player.Character then
                    local found = false
                    for _, info in ipairs(playerInfoBillboards) do
                        if info.player == player then
                            found = true
                            break
                        end
                    end
                    if not found then
                        createPlayerInfoCard(player)
                    end
                end
            end
        end
    end)

    notify("Player Info Cards ON", "success")
end

--==================================================
-- ANTI-AFK
--==================================================

startAntiAfk = function()
    if antiAfkActive then return end
    antiAfkActive = true
    antiAfkConnection = task.spawn(function()
        while antiAfkActive do
            pcall(function()
                local vu = game:GetService("VirtualUser")
                vu:CaptureController()
                vu:ClickButton2(Vector2.new())
            end)
            task.wait(60)
        end
    end)
    AntiAfkBtn.Text = "⚡ ANTI-AFK: ON"
    AntiAfkBtn.BackgroundColor3 = Colors.green
    notify("Anti-AFK ON", "success")
end

stopAntiAfk = function()
    antiAfkActive = false
    if antiAfkConnection then
        pcall(function() task.cancel(antiAfkConnection) end)
        antiAfkConnection = nil
    end
    AntiAfkBtn.Text = "⚡ ANTI-AFK: OFF"
    AntiAfkBtn.BackgroundColor3 = Color3.fromRGB(50, 25, 25)
    notify("Anti-AFK OFF", "info")
end

--==================================================
-- CHAT SPY
--==================================================

startChatSpy = function()
    if chatSpyActive then return end
    chatSpyActive = true
    chatSpyConnections = {}

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LP then
            local conn = player.Chatted:Connect(function(msg)
                if not chatSpyActive then return end
                table.insert(chatSpyLog, {
                    time = os.time(),
                    player = player.DisplayName,
                    message = msg,
                })
                if #chatSpyLog > 200 then
                    table.remove(chatSpyLog, 1)
                end
                refreshChatSpyLog()
            end)
            table.insert(chatSpyConnections, conn)
        end
    end

    -- Listen for new players joining
    local addedConn = Players.PlayerAdded:Connect(function(player)
        local conn = player.Chatted:Connect(function(msg)
            if not chatSpyActive then return end
            table.insert(chatSpyLog, {
                time = os.time(),
                player = player.DisplayName,
                message = msg,
            })
            if #chatSpyLog > 200 then
                table.remove(chatSpyLog, 1)
            end
            refreshChatSpyLog()
        end)
        table.insert(chatSpyConnections, conn)
    end)
    table.insert(chatSpyConnections, addedConn)

    ChatSpyToggleBtn.Text = "🛑 STOP SPY"
    ChatSpyToggleBtn.BackgroundColor3 = Colors.blood
    ChatSpyStatusLabel.Text = "Spy: ON"
    ChatSpyStatusLabel.TextColor3 = Color3.fromRGB(80, 220, 100)
    notify("Chat Spy ON", "success")
end

stopChatSpy = function()
    chatSpyActive = false
    if chatSpyConnections then
        for _, conn in ipairs(chatSpyConnections) do
            pcall(function() conn:Disconnect() end)
        end
        chatSpyConnections = {}
    end
    ChatSpyToggleBtn.Text = "🕵 START SPY"
    ChatSpyToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 140, 40)
    ChatSpyStatusLabel.Text = "Spy: OFF"
    ChatSpyStatusLabel.TextColor3 = Colors.textDim
    notify("Chat Spy OFF", "info")
end

--==================================================
-- EXECUTE SCRIPT
--==================================================

executeScript = function(code)
    if not code or code == "" then
        notify("No script to execute", "error")
        return
    end
    local ok, err = pcall(function()
        local fn = loadstring(code)
        if fn then
            fn()
        else
            error("Failed to parse script")
        end
    end)
    if ok then
        notify("Script executed!", "success")
    else
        notify("Error: " .. tostring(err):sub(1, 60), "error")
    end
end

--==================================================
-- COSMETICS
--==================================================

applyCosmeticHeadless = function()
    local char = LP.Character
    if not char then return end
    local head = char:FindFirstChild("Head")
    if head then
        head.Transparency = 1
        local face = head:FindFirstChildOfClass("Decal") or head:FindFirstChild("face") or head:FindFirstChild("Face")
        if face then face.Transparency = 1 end
        for _, child in ipairs(head:GetChildren()) do
            if child:IsA("SpecialMesh") then
                child.Scale = Vector3.new(0, 0, 0)
            end
        end
    end
    -- Hide hat/hair accessories
    for _, acc in ipairs(char:GetChildren()) do
        if acc:IsA("Accessory") then
            local handle = acc:FindFirstChild("Handle")
            if handle then
                local att = handle:FindFirstChildOfClass("Attachment")
                if att and (att.Name:find("Hat") or att.Name:find("Hair") or att.Name:find("Face")) then
                    handle.Transparency = 1
                end
            end
        end
    end
    cosmeticState.headless = true
    notify("Headless applied", "success")
end

removeCosmeticHeadless = function()
    local char = LP.Character
    if not char then return end
    local head = char:FindFirstChild("Head")
    if head then
        head.Transparency = 0
        local face = head:FindFirstChildOfClass("Decal") or head:FindFirstChild("face") or head:FindFirstChild("Face")
        if face then face.Transparency = 0 end
        for _, child in ipairs(head:GetChildren()) do
            if child:IsA("SpecialMesh") then
                child.Scale = Vector3.new(1, 1, 1)
            end
        end
    end
    for _, acc in ipairs(char:GetChildren()) do
        if acc:IsA("Accessory") then
            local handle = acc:FindFirstChild("Handle")
            if handle then handle.Transparency = 0 end
        end
    end
    cosmeticState.headless = false
    notify("Headless removed", "info")
end

applyCosmeticInvisible = function()
    local char = LP.Character
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = 1
        elseif part:IsA("Decal") or part:IsA("Texture") then
            part.Transparency = 1
        end
    end
    cosmeticState.invisible = true
    notify("Invisible applied", "success")
end

removeCosmeticInvisible = function()
    local char = LP.Character
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.Transparency = 0
        elseif part:IsA("Decal") then
            part.Transparency = 0
        end
    end
    cosmeticState.invisible = false
    notify("Visible again", "info")
end

applyCosmeticGhost = function()
    local char = LP.Character
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.Transparency = 0.7
        end
    end
    cosmeticState.ghost = true
    notify("Ghost mode applied", "success")
end

removeCosmeticGhost = function()
    local char = LP.Character
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.Transparency = 0
        end
    end
    cosmeticState.ghost = false
    notify("Ghost removed", "info")
end

resetAllCosmetics = function()
    if cosmeticState.headless then removeCosmeticHeadless() end
    if cosmeticState.invisible then removeCosmeticInvisible() end
    if cosmeticState.ghost then removeCosmeticGhost() end
    notify("All cosmetics reset", "info")
end

--==================================================
-- EMOTE CATALOG SEARCH
--==================================================

searchEmoteCatalog = function(keyword)
    emoteSearchVersion = emoteSearchVersion + 1
    local thisVersion = emoteSearchVersion

    -- Clear grid
    for _, child in pairs(EmoteCatalogGrid:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextButton") then child:Destroy() end
    end

    EmoteCatalogEmpty.Visible = false

    if keyword == nil or keyword == "" then
        -- Re-show trending if user clears search
        emoteTabPreloaded = false
        preloadTrendingEmotes()
        return
    end

    EmoteCatalogEmpty.Text = "Searching..."
    EmoteCatalogEmpty.Visible = true

    task.spawn(function()
        local params = CatalogSearchParams.new()
        params.AssetTypes = { Enum.AvatarAssetType.EmoteAnimation }
        params.SortType = Enum.CatalogSortType.Relevance
        params.SearchKeyword = keyword

        local ok, pages = pcall(function()
            return AvatarEditorService:SearchCatalog(params)
        end)

        if emoteSearchVersion ~= thisVersion then return end

        if not ok or not pages then
            EmoteCatalogEmpty.Text = "Search failed (AvatarEditorService)"
            EmoteCatalogEmpty.Visible = true
            log("Emote search failed:", tostring(pages))
            return
        end

        local pageOk, items = pcall(function()
            return pages:GetCurrentPage()
        end)

        if not pageOk or not items or #items == 0 then
            EmoteCatalogEmpty.Text = "No emotes found"
            EmoteCatalogEmpty.Visible = true
            return
        end

        EmoteCatalogEmpty.Visible = false
        emoteCatalogPages = pages
        emoteCatalogHasMore = not pages.IsFinished

        populateEmoteCatalogGrid(items, false)
    end)
end

populateEmoteCatalogGrid = function(items, append)
    if not append then
        for _, child in pairs(EmoteCatalogGrid:GetChildren()) do
            if child:IsA("Frame") or child:IsA("TextButton") then child:Destroy() end
        end
    end

    for _, item in ipairs(items) do
        local card = Instance.new("TextButton")
        card.Size = UDim2.new(0, 60, 0, 82)
        card.BackgroundColor3 = Colors.card
        card.AutoButtonColor = false
        card.BorderSizePixel = 0
        card.Text = ""
        card.Parent = EmoteCatalogGrid
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 6)

        -- Thumbnail
        local isBundle = item.BundleType ~= nil
        local thumbType = isBundle and "BundleThumbnail" or "Asset"
        local thumb = Instance.new("ImageLabel")
        thumb.Size = UDim2.new(1, -4, 0, 52)
        thumb.Position = UDim2.new(0, 2, 0, 2)
        thumb.BackgroundTransparency = 1
        thumb.Image = "rbxthumb://type=" .. thumbType .. "&id=" .. tostring(item.Id) .. "&w=150&h=150"
        thumb.ScaleType = Enum.ScaleType.Fit
        thumb.Parent = card

        -- Name label
        local nameL = Instance.new("TextLabel")
        nameL.Size = UDim2.new(1, -4, 0, 24)
        nameL.Position = UDim2.new(0, 2, 0, 56)
        nameL.BackgroundTransparency = 1
        nameL.Text = item.Name or "Emote"
        nameL.TextColor3 = Colors.textDim
        nameL.TextSize = 8
        nameL.Font = Enum.Font.GothamBold
        nameL.TextXAlignment = Enum.TextXAlignment.Center
        nameL.TextTruncate = Enum.TextTruncate.AtEnd
        nameL.TextWrapped = true
        nameL.Parent = card

        -- Favorite star button
        local isFav = isFavoriteEmote(item.Id)
        local starBtn = Instance.new("TextButton")
        starBtn.Size = UDim2.new(0, 16, 0, 16)
        starBtn.Position = UDim2.new(1, -18, 0, 64)
        starBtn.BackgroundTransparency = 1
        starBtn.Text = isFav and "★" or "☆"
        starBtn.TextSize = 12
        starBtn.TextColor3 = isFav and Color3.fromRGB(255, 200, 50) or Colors.textDim
        starBtn.Parent = card

        starBtn.MouseButton1Click:Connect(function()
            local added = toggleFavoriteEmote(item.Id, item.Name or "Emote", isBundle)
            starBtn.Text = added and "★" or "☆"
            starBtn.TextColor3 = added and Color3.fromRGB(255, 200, 50) or Colors.textDim
        end)

        -- Click to play
        card.MouseButton1Click:Connect(function()
            playEmote(item.Id)
        end)

        makeHoverable(card, Colors.card, Colors.surfaceLight)
    end

    -- Update grid height based on content
    local childCount = 0
    for _, child in pairs(EmoteCatalogGrid:GetChildren()) do
        if child:IsA("TextButton") then childCount = childCount + 1 end
    end
    local cols = math.max(1, math.floor(EmoteCatalogGrid.AbsoluteSize.X / 66))
    if cols < 1 then cols = 5 end
    local rows = math.ceil(childCount / cols)
    EmoteCatalogGrid.Size = UDim2.new(1, 0, 0, math.max(rows * 88, 88))

    -- Refresh scroll canvas
    recalcEmoteLayout()
end

loadMoreEmotes = function()
    if not emoteCatalogHasMore or not emoteCatalogPages or isLoadingMoreEmotes then return end
    isLoadingMoreEmotes = true

    task.spawn(function()
        local ok = pcall(function()
            emoteCatalogPages:AdvanceToNextPageAsync()
        end)
        if not ok then
            isLoadingMoreEmotes = false
            return
        end

        local pageOk, items = pcall(function()
            return emoteCatalogPages:GetCurrentPage()
        end)

        isLoadingMoreEmotes = false

        if not pageOk or not items or #items == 0 then
            emoteCatalogHasMore = false
            return
        end

        emoteCatalogHasMore = not emoteCatalogPages.IsFinished
        populateEmoteCatalogGrid(items, true)
    end)
end

--==================================================
-- PRE-LOAD POPULAR EMOTES
--==================================================

preloadTrendingEmotes = function()
    if emoteTabPreloaded then return end
    emoteTabPreloaded = true

    EmoteCatalogEmpty.Text = "Loading popular emotes..."
    EmoteCatalogEmpty.Visible = true

    -- Clear grid
    for _, child in pairs(EmoteCatalogGrid:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextButton") then child:Destroy() end
    end

    emoteSearchVersion = emoteSearchVersion + 1
    local thisVersion = emoteSearchVersion

    task.spawn(function()
        local params = CatalogSearchParams.new()
        params.AssetTypes = { Enum.AvatarAssetType.EmoteAnimation }
        params.SortType = Enum.CatalogSortType.MostFavorited

        local ok, pages = pcall(function()
            return AvatarEditorService:SearchCatalog(params)
        end)

        if emoteSearchVersion ~= thisVersion then return end

        if not ok or not pages then
            EmoteCatalogEmpty.Text = "Failed to load popular emotes"
            EmoteCatalogEmpty.Visible = true
            emoteTabPreloaded = false
            return
        end

        local pageOk, items = pcall(function()
            return pages:GetCurrentPage()
        end)

        if not pageOk or not items or #items == 0 then
            EmoteCatalogEmpty.Text = "No popular emotes found"
            EmoteCatalogEmpty.Visible = true
            return
        end

        EmoteCatalogEmpty.Visible = false
        emoteCatalogPages = pages
        emoteCatalogHasMore = not pages.IsFinished

        populateEmoteCatalogGrid(items, false)
    end)
end

--==================================================
-- FAVORITE EMOTES
--==================================================

loadFavoriteEmotes = function()
    favoriteEmotes = {}
    pcall(function()
        if isfile and isfile("VampireFavoriteEmotes.json") then
            local raw = readfile("VampireFavoriteEmotes.json")
            local parsed = HttpService:JSONDecode(raw)
            if type(parsed) == "table" then
                favoriteEmotes = parsed
            end
        end
    end)
    refreshFavoriteGrid()
end

saveFavoriteEmotes = function()
    pcall(function()
        if writefile then
            writefile("VampireFavoriteEmotes.json", HttpService:JSONEncode(favoriteEmotes))
        end
    end)
end

toggleFavoriteEmote = function(id, name, isBundle)
    -- Check if already favorited
    for i, fav in ipairs(favoriteEmotes) do
        if fav.id == id then
            table.remove(favoriteEmotes, i)
            saveFavoriteEmotes()
            refreshFavoriteGrid()
            notify("Removed from favorites", "info")
            return false
        end
    end
    -- Add new favorite
    table.insert(favoriteEmotes, { id = id, name = name, isBundle = isBundle or false })
    saveFavoriteEmotes()
    refreshFavoriteGrid()
    notify("Added to favorites!", "success")
    return true
end

isFavoriteEmote = function(id)
    for _, fav in ipairs(favoriteEmotes) do
        if fav.id == id then return true end
    end
    return false
end

refreshFavoriteGrid = function()
    -- Clear existing children
    for _, child in pairs(EmoteFavGrid:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextButton") then child:Destroy() end
    end

    if #favoriteEmotes == 0 then
        EmoteFavEmpty.Visible = true
        EmoteFavGrid.Size = UDim2.new(1, 0, 0, 24)
    else
        EmoteFavEmpty.Visible = false

        for idx, fav in ipairs(favoriteEmotes) do
            local card = Instance.new("TextButton")
            card.Size = UDim2.new(0, 60, 0, 82)
            card.BackgroundColor3 = Colors.card
            card.AutoButtonColor = false
            card.BorderSizePixel = 0
            card.Text = ""
            card.LayoutOrder = idx
            card.Parent = EmoteFavGrid
            Instance.new("UICorner", card).CornerRadius = UDim.new(0, 6)

            -- Thumbnail
            local thumbType = fav.isBundle and "BundleThumbnail" or "Asset"
            local thumb = Instance.new("ImageLabel")
            thumb.Size = UDim2.new(1, -4, 0, 44)
            thumb.Position = UDim2.new(0, 2, 0, 2)
            thumb.BackgroundTransparency = 1
            thumb.Image = "rbxthumb://type=" .. thumbType .. "&id=" .. tostring(fav.id) .. "&w=150&h=150"
            thumb.ScaleType = Enum.ScaleType.Fit
            thumb.Parent = card

            -- Name label
            local nameL = Instance.new("TextLabel")
            nameL.Size = UDim2.new(1, -4, 0, 18)
            nameL.Position = UDim2.new(0, 2, 0, 48)
            nameL.BackgroundTransparency = 1
            nameL.Text = fav.name or "Emote"
            nameL.TextColor3 = Colors.textDim
            nameL.TextSize = 8
            nameL.Font = Enum.Font.GothamBold
            nameL.TextXAlignment = Enum.TextXAlignment.Center
            nameL.TextTruncate = Enum.TextTruncate.AtEnd
            nameL.TextWrapped = true
            nameL.Parent = card

            -- Unfavorite star button
            local starBtn = Instance.new("TextButton")
            starBtn.Size = UDim2.new(0, 16, 0, 16)
            starBtn.Position = UDim2.new(1, -18, 0, 64)
            starBtn.BackgroundTransparency = 1
            starBtn.Text = "★"
            starBtn.TextSize = 12
            starBtn.TextColor3 = Color3.fromRGB(255, 200, 50)
            starBtn.Parent = card

            starBtn.MouseButton1Click:Connect(function()
                toggleFavoriteEmote(fav.id, fav.name, fav.isBundle)
            end)

            -- Click card to play
            card.MouseButton1Click:Connect(function()
                playEmote(fav.id)
            end)

            makeHoverable(card, Colors.card, Colors.surfaceLight)
        end

        -- Calculate grid height
        local cols = math.max(1, math.floor(EmoteFavGrid.AbsoluteSize.X / 66))
        if cols < 1 then cols = 3 end
        local rows = math.ceil(#favoriteEmotes / cols)
        EmoteFavGrid.Size = UDim2.new(1, 0, 0, math.max(rows * 88, 88))
    end

    -- Recalculate layout of everything below favorites
    recalcEmoteLayout()
end
