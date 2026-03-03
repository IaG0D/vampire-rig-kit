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

    -- Animation mirroring state (global so stopShadow can clean up)
    shadowMirroredTracks = {}
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

    -- Stop and destroy all mirrored animation tracks
    if shadowMirroredTracks then
        for id, track in pairs(shadowMirroredTracks) do
            pcall(function() track:Stop() end)
            pcall(function() track:Destroy() end)
        end
        shadowMirroredTracks = {}
    end

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
        EmoteCatalogEmpty.Text = "Type to search emotes..."
        EmoteCatalogEmpty.Visible = true
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
    EmoteScroll.CanvasSize = UDim2.new(0, 0, 0, EmoteCatalogGrid.Position.Y.Offset + EmoteCatalogGrid.Size.Y.Offset + 20)
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
