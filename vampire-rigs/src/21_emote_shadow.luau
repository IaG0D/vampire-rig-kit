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
        notify("Emote stopped", "info")
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

    -- Animation mirroring state
    local mirroredTracks = {}
    local lastAnimSync = 0

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

        elseif shadowState.mode == "follow" then
            -- Follow behind
            local targetCF = targetHRP.CFrame

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

                -- Use delayed position, or follow instantly while history builds up
                local useCF = delayCF or targetCF
                local behindCF = useCF * CFrame.new(0, 0, dist)
                myHRP.CFrame = behindCF
            else
                -- Instant follow
                local behindCF = targetCF * CFrame.new(0, 0, dist)
                myHRP.CFrame = behindCF
            end

        elseif shadowState.mode == "mirror" then
            -- Shadow box: face them, mirrored position
            local targetCF = targetHRP.CFrame
            local frontPos = (targetCF * CFrame.new(0, 0, -dist)).Position
            myHRP.CFrame = CFrame.lookAt(frontPos, targetHRP.Position)
        end

        -- Mirror target animations (~every 0.3s)
        local now = tick()
        if now - lastAnimSync > 0.3 then
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
                        for id, track in pairs(mirroredTracks) do
                            if not targetIds[id] then
                                pcall(function() track:Stop() end)
                                pcall(function() track:Destroy() end)
                                mirroredTracks[id] = nil
                            end
                        end
                        -- Play tracks target IS playing
                        for id, priority in pairs(targetIds) do
                            if not mirroredTracks[id] then
                                local anim = Instance.new("Animation")
                                anim.AnimationId = id
                                local ok2, myTrack = pcall(function()
                                    return myAnimator:LoadAnimation(anim)
                                end)
                                if ok2 and myTrack then
                                    myTrack.Priority = priority
                                    myTrack:Play()
                                    mirroredTracks[id] = myTrack
                                end
                                anim:Destroy()
                            end
                        end
                    end)
                end
            end
        end
    end)

    notify("Shadow: " .. mode .. " on " .. target.Name, "success")
    log("Shadow started:", mode, target.Name)
end

stopShadow = function()
    shadowState.active = false
    if shadowConnection then
        shadowConnection:Disconnect()
        shadowConnection = nil
    end
    shadowHistory = {}
    refreshShadowModeButtons()

    -- Re-enable falling states
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
    end

    notify("Shadow stopped", "info")
    log("Shadow stopped")
end

refreshShadowPlayerList = function()
    -- Clear existing
    for _, child in pairs(ShadowPlayerScroll:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LP then
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, 0, 0, 30)
            row.BackgroundColor3 = Colors.card
            row.BorderSizePixel = 0
            row.Parent = ShadowPlayerScroll
            Instance.new("UICorner", row).CornerRadius = UDim.new(0, 4)

            local isSelected = shadowState.target == player

            -- Thumbnail
            local thumbFrame = Instance.new("Frame")
            thumbFrame.Size = UDim2.new(0, 22, 0, 22)
            thumbFrame.Position = UDim2.new(0, 4, 0, 4)
            thumbFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            thumbFrame.Parent = row
            Instance.new("UICorner", thumbFrame).CornerRadius = UDim.new(1, 0)
            local tStroke = Instance.new("UIStroke", thumbFrame)
            tStroke.Color = isSelected and Colors.glowPurple or Colors.textDim
            tStroke.Thickness = 1

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

            local pName = Instance.new("TextLabel")
            pName.Size = UDim2.new(1, -82, 1, 0)
            pName.Position = UDim2.new(0, 30, 0, 0)
            pName.BackgroundTransparency = 1
            pName.Text = player.DisplayName
            pName.TextColor3 = isSelected and Colors.purpleLight or Colors.bloodLight
            pName.TextSize = 10
            pName.Font = Enum.Font.GothamBold
            pName.TextXAlignment = Enum.TextXAlignment.Left
            pName.TextTruncate = Enum.TextTruncate.AtEnd
            pName.Parent = row

            local selectBtn = Instance.new("TextButton")
            selectBtn.Size = UDim2.new(0, 48, 0, 22)
            selectBtn.Position = UDim2.new(1, -52, 0, 4)
            selectBtn.BackgroundColor3 = isSelected and Colors.glowPurple or Colors.surfaceLight
            selectBtn.Text = isSelected and "ACTIVE" or "SELECT"
            selectBtn.TextColor3 = Colors.text
            selectBtn.TextSize = 8
            selectBtn.Font = Enum.Font.GothamBold
            selectBtn.AutoButtonColor = false
            selectBtn.Parent = row
            Instance.new("UICorner", selectBtn).CornerRadius = UDim.new(0, 4)
            makeHoverable(selectBtn, isSelected and Colors.glowPurple or Colors.surfaceLight, Colors.purpleLight)

            selectBtn.MouseButton1Click:Connect(function()
                shadowState.target = player
                ShadowTargetLabel.Text = "Target: " .. player.DisplayName
                ShadowTargetLabel.TextColor3 = Colors.purpleLight
                refreshShadowPlayerList()
                notify("Shadow target: " .. player.Name, "info")
            end)
        end
    end
end
