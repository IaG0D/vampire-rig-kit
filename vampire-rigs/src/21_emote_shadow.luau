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

        -- Prevent falling state
        myHum = myChar:FindFirstChildOfClass("Humanoid")
        if myHum and myHum:GetState() == Enum.HumanoidStateType.Freefall then
            myHum:ChangeState(Enum.HumanoidStateType.Physics)
        end

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

    -- Re-enable falling states + force idle animation restart
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
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

    myHum:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
    myHum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    myHum.Sit = true

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
        -- Manter sentado
        if myHum and not myHum.Sit then myHum.Sit = true end
    end)
    notify("Headsit: " .. player.DisplayName, "success")
end

--==================================================
-- MORE TROLLS
--==================================================

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
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
    end
end

bangPlayer = function(player)
    stopTroll()
    local targetChar = player.Character
    if not targetChar then notify("No character", "error") return end
    local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
    local myChar = LP.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    if not targetHRP or not myHRP or not myHum then return end

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
    pcall(function()
        for _, obj in pairs(game:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                table.insert(scannedRemotes, {
                    instance = obj,
                    name = obj.Name,
                    path = obj:GetFullName(),
                    class = obj.ClassName,
                })
            end
        end
    end)
    table.sort(scannedRemotes, function(a, b)
        return a.name < b.name
    end)
    log("Scanned remotes:", #scannedRemotes)
end

startRemoteSpy = function()
    if remoteSpyActive then return end

    -- Checa se executor suporta hookmetamethod
    if not hookmetamethod then
        notify("hookmetamethod not supported", "error")
        return false
    end
    if not getnamecallmethod then
        notify("getnamecallmethod not supported", "error")
        return false
    end
    if not newcclosure then
        notify("newcclosure not supported", "error")
        return false
    end

    remoteSpyActive = true
    remoteSpyLog = {}

    pcall(function()
        remoteSpyHook = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
            local method = getnamecallmethod()
            if remoteSpyActive and (method == "FireServer" or method == "InvokeServer") then
                local isRemote = false
                pcall(function()
                    isRemote = self:IsA("RemoteEvent") or self:IsA("RemoteFunction")
                end)
                if isRemote then
                    local entry = {
                        time = os.clock(),
                        name = "?",
                        path = "?",
                        method = method,
                        args = {...},
                    }
                    pcall(function() entry.name = self.Name end)
                    pcall(function() entry.path = self:GetFullName() end)
                    table.insert(remoteSpyLog, entry)
                    if #remoteSpyLog > 200 then
                        table.remove(remoteSpyLog, 1)
                    end
                    -- Refresh UI (safe)
                    pcall(function() refreshRemoteSpyLog() end)
                end
            end
            return remoteSpyHook(self, ...)
        end))
    end)

    if remoteSpyHook then
        notify("Remote Spy ON — logging calls", "success")
        RemoteSpyStatusLabel.Text = "Spy: ON (logging...)"
        RemoteSpyStatusLabel.TextColor3 = Color3.fromRGB(100, 220, 200)
        RemoteSpyToggleBtn.Text = "⏹ STOP SPY"
        RemoteSpyToggleBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 30)
        return true
    else
        remoteSpyActive = false
        notify("Failed to hook __namecall", "error")
        return false
    end
end

stopRemoteSpy = function()
    remoteSpyActive = false
    RemoteSpyStatusLabel.Text = "Spy: OFF"
    RemoteSpyStatusLabel.TextColor3 = Colors.textDim
    RemoteSpyToggleBtn.Text = "🕵 START SPY"
    RemoteSpyToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 80, 70)
    notify("Remote Spy OFF", "info")
end

fireTestRemote = function(remote)
    if not remote or not remote.Parent then
        notify("Remote no longer exists", "error")
        return
    end
    pcall(function()
        if remote:IsA("RemoteEvent") then
            remote:FireServer()
            notify("Fired: " .. remote.Name, "success")
        elseif remote:IsA("RemoteFunction") then
            local result = remote:InvokeServer()
            notify("Invoked: " .. remote.Name .. " → " .. tostring(result), "success")
        end
    end)
    log("Test fire:", remote:GetFullName())
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
