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

    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://" .. tostring(animId)

    local ok, track = pcall(function()
        return animator:LoadAnimation(anim)
    end)

    if ok and track then
        track.Priority = Enum.AnimationPriority.Action
        track:Play()
        currentEmoteTrack = track
        notify("Playing emote", "success")
        log("Emote playing:", animId)
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

    shadowConnection = RunService.Heartbeat:Connect(function()
        local targetChar = target.Character
        if not targetChar or not targetChar.Parent then
            stopShadow()
            notify("Shadow target left", "error")
            return
        end

        local myChar = LP.Character
        local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
        if not myHRP or not targetHRP then return end

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

                if delayCF then
                    local behindCF = delayCF * CFrame.new(0, 0, dist)
                    myHRP.CFrame = behindCF
                end
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
