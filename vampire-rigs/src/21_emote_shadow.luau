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

    local modeLabel = mode == "head" and "head" or ("orbit " .. shadowState.angle .. "°")
    notify("Shadow: " .. modeLabel .. " on " .. target.Name, "success")
    log("Shadow started:", modeLabel, target.Name)
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
