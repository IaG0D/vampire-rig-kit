--==================================================
-- EVENTS
--==================================================

--==================================================
-- SCANNER TAB EVENTS
--==================================================

ScanBtn.MouseButton1Click:Connect(function()
    runScan()
end)

ExportBtn.MouseButton1Click:Connect(function()
    exportAllJSON()
end)

CopyBtn.MouseButton1Click:Connect(copyToClipboard)

-- Search filter
SearchBar:GetPropertyChangedSignal("Text"):Connect(function()
    filterResults(SearchBar.Text)
end)

-- Auto-scan toggle
AutoScanToggle.btn.MouseButton1Click:Connect(function()
    autoScanConfig.enabled = not autoScanConfig.enabled
    AutoScanToggle.refresh()
    autoScanSettingToggle.refresh() -- sync settings tab
    if autoScanConfig.enabled then
        startAutoScan()
    else
        stopAutoScan()
    end
end)

-- Unspectate (scanner + player tabs)
UnspectateBtn.MouseButton1Click:Connect(function()
    stopSpectate()
end)

PlayerUnspectateBtn.MouseButton1Click:Connect(function()
    stopSpectate()
end)

--==================================================
-- ESP TAB EVENTS
--==================================================

for feature, toggle in pairs(espToggles) do
    toggle.btn.MouseButton1Click:Connect(function()
        toggleESPFeature(feature)
    end)
end

-- Footsteps toggle (separate from espToggles)
FootstepsToggle.btn.MouseButton1Click:Connect(function()
    if espState.footsteps then
        stopFootsteps()
    else
        startFootsteps()
    end
end)

-- Sound ESP toggle (separate from espToggles)
SoundESPToggle.btn.MouseButton1Click:Connect(function()
    if espState.soundESP then
        stopSoundESP()
    else
        startSoundESP()
    end
end)

ESPOffBtn.MouseButton1Click:Connect(function()
    -- Stop separate systems first
    if espState.footsteps then stopFootsteps() end
    if espState.soundESP then stopSoundESP() end
    -- Reset all state
    for k in pairs(espState) do
        espState[k] = false
    end
    clearESP()
    for _, toggle in pairs(espToggles) do
        toggle.refresh()
    end
    FootstepsToggle.refresh()
    SoundESPToggle.refresh()
    ESPStatusLabel.Text = "ESP OFF — toggle features above"
    notify("All ESP disabled", "info")
end)

--==================================================
-- PLAYER TAB EVENTS
--==================================================

RefreshPlayersBtn.MouseButton1Click:Connect(function()
    refreshPlayerList(PlayerSearchBox.Text)
    notify("Player list refreshed", "info")
end)

-- Player search filter
do
    local playerFilterTimer = nil
    PlayerSearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        if playerFilterTimer then
            task.cancel(playerFilterTimer)
        end
        playerFilterTimer = task.delay(0.3, function()
            playerFilterTimer = nil
            refreshPlayerList(PlayerSearchBox.Text)
        end)
    end)
end

-- Auto-refresh when tab switches to player
-- (handled in switchTab below)

--==================================================
-- MOVEMENT TAB EVENTS
--==================================================

moveToggles.fly.btn.MouseButton1Click:Connect(function()
    movementState.fly = not movementState.fly
    moveToggles.fly.refresh()
    if movementState.fly then
        startFly()
    else
        stopFly()
    end
end)

moveToggles.noclip.btn.MouseButton1Click:Connect(function()
    movementState.noclip = not movementState.noclip
    moveToggles.noclip.refresh()
    toggleNoclip()
end)

moveToggles.infiniteJump.btn.MouseButton1Click:Connect(function()
    movementState.infiniteJump = not movementState.infiniteJump
    moveToggles.infiniteJump.refresh()
    toggleInfiniteJump()
end)

moveToggles.freecam.btn.MouseButton1Click:Connect(function()
    movementState.freecam = not movementState.freecam
    moveToggles.freecam.refresh()
    if movementState.freecam then
        startFreecam()
    else
        stopFreecam()
    end
end)

ResetMoveBtn.MouseButton1Click:Connect(function()
    -- Stop all
    if movementState.fly then
        movementState.fly = false
        moveToggles.fly.refresh()
        stopFly()
    end
    if movementState.noclip then
        movementState.noclip = false
        moveToggles.noclip.refresh()
        toggleNoclip()
    end
    if movementState.infiniteJump then
        movementState.infiniteJump = false
        moveToggles.infiniteJump.refresh()
        toggleInfiniteJump()
    end
    if movementState.freecam then
        movementState.freecam = false
        moveToggles.freecam.refresh()
        stopFreecam()
    end
    -- Reset speed
    movementState.speed = 16
    movementState.jumpPower = 50
    speedSlider.setValue(16)
    jumpSlider.setValue(50)
    applySpeed()
    notify("Movement reset", "info")
end)

-- Apply speed on character spawn
LP.CharacterAdded:Connect(function()
    task.wait(0.5)
    applySpeed()
end)

--==================================================
-- EMOTE TAB EVENTS
--==================================================

-- Custom animation ID
PlayCustomBtn.MouseButton1Click:Connect(function()
    local id = tonumber(CustomIDInput.Text)
    if id then
        playEmote(id)
    else
        notify("Enter a valid animation ID", "warning")
    end
end)

CustomIDInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local id = tonumber(CustomIDInput.Text)
        if id then playEmote(id) end
    end
end)

PauseEmoteBtn.MouseButton1Click:Connect(function()
    if emotePaused then
        resumeEmote()
        PauseEmoteBtn.Text = "⏸ PAUSE"
        PauseEmoteBtn.BackgroundColor3 = Colors.warning
    else
        pauseEmote()
        PauseEmoteBtn.Text = "▶ RESUME"
        PauseEmoteBtn.BackgroundColor3 = Colors.green
    end
end)

StopEmoteBtn.MouseButton1Click:Connect(function()
    stopEmote()
    PauseEmoteBtn.Text = "⏸ PAUSE"
    PauseEmoteBtn.BackgroundColor3 = Colors.warning
end)

-- Emote catalog search (debounced 0.4s)
do
    local emoteSearchTimer = nil
    EmoteSearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        if emoteSearchTimer then
            task.cancel(emoteSearchTimer)
        end
        emoteSearchTimer = task.delay(0.4, function()
            emoteSearchTimer = nil
            searchEmoteCatalog(EmoteSearchBox.Text)
        end)
    end)
end

-- Emote catalog scroll pagination (load more near bottom)
EmoteScroll:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
    local scrollPos = EmoteScroll.CanvasPosition.Y
    local canvasH = EmoteScroll.CanvasSize.Y.Offset
    local frameH = EmoteScroll.AbsoluteSize.Y
    if canvasH > 0 and (scrollPos + frameH) >= (canvasH - 60) then
        loadMoreEmotes()
    end
end)

--==================================================
-- SHADOW PANEL EVENTS
--==================================================

-- Shadow preset buttons
for _, data in ipairs(shadowPresetButtons) do
    data.btn.MouseButton1Click:Connect(function()
        local def = data.def
        if def.mode == "head" then
            if shadowState.active and shadowState.mode == "head" then
                stopShadow()
            else
                startShadow("head")
            end
        else
            -- Orbit mode: set angle, height, faceTarget, then start
            shadowState.angle = def.angle
            shadowState.height = def.height
            shadowState.faceTarget = def.faceTarget
            ShadowPanelAngleSlider.setValue(def.angle)
            ShadowPanelHeightSlider.setValue(def.height)
            ShadowFaceTargetToggle.refresh()
            startShadow("orbit")
        end
    end)
end

-- Face Target toggle
ShadowFaceTargetToggle.btn.MouseButton1Click:Connect(function()
    shadowState.faceTarget = not shadowState.faceTarget
    ShadowFaceTargetToggle.refresh()
end)

-- Mirror Anims toggle
ShadowMirrorAnimsToggle.btn.MouseButton1Click:Connect(function()
    shadowState.mirrorAnims = not shadowState.mirrorAnims
    ShadowMirrorAnimsToggle.refresh()
    -- If turning off mirror, clean up existing mirrored tracks
    if not shadowState.mirrorAnims and shadowMirroredTracks then
        for id, track in pairs(shadowMirroredTracks) do
            pcall(function() track:Stop() end)
            pcall(function() track:Destroy() end)
        end
        shadowMirroredTracks = {}
        -- Restart idle animation
        local char = LP.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            local animator = hum:FindFirstChildOfClass("Animator")
            if animator then
                pcall(function()
                    for _, t in ipairs(animator:GetPlayingAnimationTracks()) do
                        t:Stop(0)
                    end
                end)
            end
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
end)

-- Auto-Orbit toggle
ShadowAutoOrbitToggle.btn.MouseButton1Click:Connect(function()
    shadowState.autoOrbit = not shadowState.autoOrbit
    ShadowAutoOrbitToggle.refresh()
end)

-- Trail toggle
ShadowTrailToggle.btn.MouseButton1Click:Connect(function()
    shadowState.trail = not shadowState.trail
    ShadowTrailToggle.refresh()
    if shadowState.trail and shadowState.active then
        applyShadowTrail()
    elseif not shadowState.trail then
        removeShadowTrail()
    end
end)

-- Record button
ShadowRecBtn.MouseButton1Click:Connect(function()
    if shadowRecording then
        stopShadowRecording()
    else
        if not shadowState.active then
            notify("Start shadow first to record", "warning")
            return
        end
        startShadowRecording()
    end
end)

-- Replay button
ShadowPlayReplayBtn.MouseButton1Click:Connect(function()
    if shadowReplaying then
        stopShadowReplay()
    else
        startShadowReplay()
    end
end)

-- Reset button — resets all shadow settings to defaults
ShadowResetBtn.MouseButton1Click:Connect(function()
    shadowState.angle = 0
    shadowState.height = 0
    shadowState.distance = 4
    shadowState.delay = 0
    shadowState.faceTarget = false
    shadowState.mirrorAnims = true
    shadowState.autoOrbit = false
    shadowState.orbitSpeed = 2
    shadowState.trail = false
    -- Sync UI
    ShadowPanelAngleSlider.setValue(0)
    ShadowPanelHeightSlider.setValue(0)
    ShadowPanelDistSlider.setValue(4)
    ShadowPanelDelaySlider.setValue(0)
    ShadowOrbitSpeedSlider.setValue(2)
    ShadowFaceTargetToggle.refresh()
    ShadowMirrorAnimsToggle.refresh()
    ShadowAutoOrbitToggle.refresh()
    ShadowTrailToggle.refresh()
    refreshShadowModeButtons()
    removeShadowTrail()
    notify("Shadow settings reset", "info")
end)

StopShadowBtn.MouseButton1Click:Connect(function()
    if shadowRecording then stopShadowRecording() end
    if shadowReplaying then stopShadowReplay() end
    stopShadow()
    ShadowMirrorAnimsToggle.refresh()
    ShadowAutoOrbitToggle.refresh()
    ShadowTrailToggle.refresh()
end)

ShadowPanelClose.MouseButton1Click:Connect(function()
    if shadowRecording then stopShadowRecording() end
    if shadowReplaying then stopShadowReplay() end
    stopShadow()
    ShadowMirrorAnimsToggle.refresh()
    ShadowAutoOrbitToggle.refresh()
    ShadowPanel.Visible = false
end)

--==================================================
-- TROLL PANEL EVENTS
--==================================================

TrollFlingBtn.MouseButton1Click:Connect(function()
    if trollTarget then flingPlayer(trollTarget) end
end)

TrollHeadsitBtn.MouseButton1Click:Connect(function()
    if trollTarget then headsitPlayer(trollTarget) end
end)

TrollBangBtn.MouseButton1Click:Connect(function()
    if trollTarget then bangPlayer(trollTarget) end
end)

TrollBackpackBtn.MouseButton1Click:Connect(function()
    if trollTarget then backpackPlayer(trollTarget) end
end)

TrollBang2Btn.MouseButton1Click:Connect(function()
    if trollTarget then bangFrontPlayer(trollTarget) end
end)

TrollOrbitBtn.MouseButton1Click:Connect(function()
    if trollTarget then orbitTrollPlayer(trollTarget) end
end)

TrollFlingAllBtn.MouseButton1Click:Connect(function()
    flingAllPlayers()
end)

TrollHelicopterBtn.MouseButton1Click:Connect(function()
    if trollTarget then helicopterPlayer(trollTarget) end
end)

TrollSpinTopBtn.MouseButton1Click:Connect(function()
    if trollTarget then spinTopPlayer(trollTarget) end
end)

TrollTrampolineBtn.MouseButton1Click:Connect(function()
    if trollTarget then trampolinePlayer(trollTarget) end
end)

TrollCreepBtn.MouseButton1Click:Connect(function()
    if trollTarget then creepPlayer(trollTarget) end
end)

TrollLaunchBtn.MouseButton1Click:Connect(function()
    if trollTarget then launchPlayer(trollTarget) end
end)

TrollCarpetBtn.MouseButton1Click:Connect(function()
    if trollTarget then carpetPlayer(trollTarget) end
end)

TrollDizzyBtn.MouseButton1Click:Connect(function()
    if trollTarget then dizzyPlayer(trollTarget) end
end)

TrollMagnetBtn.MouseButton1Click:Connect(function()
    if trollTarget then magnetPlayer(trollTarget) end
end)

TrollCloneBtn.MouseButton1Click:Connect(function()
    if trollTarget then clonePlayer(trollTarget) end
end)

TrollUpsideDownBtn.MouseButton1Click:Connect(function()
    if trollTarget then upsideDownPlayer(trollTarget) end
end)

TrollTornadoBtn.MouseButton1Click:Connect(function()
    if trollTarget then tornadoPlayer(trollTarget) end
end)

TrollSnakeBtn.MouseButton1Click:Connect(function()
    if trollTarget then snakePlayer(trollTarget) end
end)

TrollMirrorBtn.MouseButton1Click:Connect(function()
    if trollTarget then mirrorPlayer(trollTarget) end
end)

TrollStackBtn.MouseButton1Click:Connect(function()
    if trollTarget then stackPlayer(trollTarget) end
end)

TrollFigure8Btn.MouseButton1Click:Connect(function()
    if trollTarget then figure8Player(trollTarget) end
end)

TrollDogBtn.MouseButton1Click:Connect(function()
    if trollTarget then dogPlayer(trollTarget) end
end)

TrollFerrisBtn.MouseButton1Click:Connect(function()
    if trollTarget then ferrisPlayer(trollTarget) end
end)

TrollSalsaBtn.MouseButton1Click:Connect(function()
    if trollTarget then salsaPlayer(trollTarget) end
end)

TrollUfoBtn.MouseButton1Click:Connect(function()
    if trollTarget then ufoPlayer(trollTarget) end
end)

TrollBoomerangBtn.MouseButton1Click:Connect(function()
    if trollTarget then boomerangPlayer(trollTarget) end
end)

TrollRollerBtn.MouseButton1Click:Connect(function()
    if trollTarget then rollerPlayer(trollTarget) end
end)

TrollSpiralBtn.MouseButton1Click:Connect(function()
    if trollTarget then spiralPlayer(trollTarget) end
end)

TrollSurfBtn.MouseButton1Click:Connect(function()
    if trollTarget then surfPlayer(trollTarget) end
end)

TrollBouncerBtn.MouseButton1Click:Connect(function()
    if trollTarget then bouncerPlayer(trollTarget) end
end)

TrollLapSitBtn.MouseButton1Click:Connect(function()
    if trollTarget then lapSitPlayer(trollTarget) end
end)

TrollWaveBtn.MouseButton1Click:Connect(function()
    if trollTarget then wavePlayer(trollTarget) end
end)

TrollParasiteBtn.MouseButton1Click:Connect(function()
    if trollTarget then parasitePlayer(trollTarget) end
end)

TrollStalkBtn.MouseButton1Click:Connect(function()
    if trollTarget then stalkPlayer(trollTarget) end
end)

TrollPushBtn.MouseButton1Click:Connect(function()
    if trollTarget then pushPlayer(trollTarget) end
end)

TrollSwapBtn.MouseButton1Click:Connect(function()
    if trollTarget then swapPlayer(trollTarget) end
end)

TrollJailBtn.MouseButton1Click:Connect(function()
    if trollTarget then jailPlayer(trollTarget) end
end)

TrollStopBtn.MouseButton1Click:Connect(function()
    stopTroll()
    notify("Troll stopped", "info")
end)

TrollPanelClose.MouseButton1Click:Connect(function()
    stopTroll()
    TrollPanel.Visible = false
end)

TrollCloseBottomBtn.MouseButton1Click:Connect(function()
    stopTroll()
    TrollPanel.Visible = false
end)

--==================================================
-- SETTINGS TAB EVENTS
--==================================================

spectateHLToggle.btn.MouseButton1Click:Connect(function()
    spectateConfig.showHighlight = not spectateConfig.showHighlight
    spectateHLToggle.refresh()
    -- Apply immediately if spectating
    if spectatingInfo then
        if spectateConfig.showHighlight then
            local targetChar = spectatingInfo.character
            if spectatingInfo.player and spectatingInfo.player.Character then
                targetChar = spectatingInfo.player.Character
            end
            if targetChar and not spectateHighlight then
                spectateHighlight = Instance.new("Highlight")
                spectateHighlight.Name = "VampSpectateHL"
                spectateHighlight.FillColor = Colors.blood
                spectateHighlight.FillTransparency = 0.7
                spectateHighlight.OutlineColor = Colors.bloodLight
                spectateHighlight.OutlineTransparency = 0
                spectateHighlight.Adornee = targetChar
                spectateHighlight.Parent = targetChar
            end
        else
            if spectateHighlight then
                spectateHighlight:Destroy()
                spectateHighlight = nil
            end
        end
    end
end)

autoScanSettingToggle.btn.MouseButton1Click:Connect(function()
    autoScanConfig.enabled = not autoScanConfig.enabled
    autoScanSettingToggle.refresh()
    -- Sync with scanner tab toggle
    AutoScanToggle.refresh()
    if autoScanConfig.enabled then
        startAutoScan()
    else
        stopAutoScan()
    end
end)

--==================================================
-- COSMETIC EVENTS
--==================================================

cosmeticHeadlessToggle.btn.MouseButton1Click:Connect(function()
    if cosmeticState.headless then
        removeCosmeticHeadless()
    else
        applyCosmeticHeadless()
    end
    cosmeticHeadlessToggle.refresh()
end)

cosmeticInvisibleToggle.btn.MouseButton1Click:Connect(function()
    if cosmeticState.invisible then
        removeCosmeticInvisible()
    else
        -- Turn off ghost if going invisible
        if cosmeticState.ghost then
            removeCosmeticGhost()
            cosmeticGhostToggle.refresh()
        end
        applyCosmeticInvisible()
    end
    cosmeticInvisibleToggle.refresh()
end)

cosmeticGhostToggle.btn.MouseButton1Click:Connect(function()
    if cosmeticState.ghost then
        removeCosmeticGhost()
    else
        -- Turn off invisible if going ghost
        if cosmeticState.invisible then
            removeCosmeticInvisible()
            cosmeticInvisibleToggle.refresh()
        end
        applyCosmeticGhost()
    end
    cosmeticGhostToggle.refresh()
end)

CosmeticResetBtn.MouseButton1Click:Connect(function()
    resetAllCosmetics()
    cosmeticHeadlessToggle.refresh()
    cosmeticInvisibleToggle.refresh()
    cosmeticGhostToggle.refresh()
end)

--==================================================
-- REMOTE SPY EVENTS
--==================================================

RemoteSpyOpenBtn.MouseButton1Click:Connect(function()
    openRemoteSpyPanel()
end)

RemoteSpyScanBtn.MouseButton1Click:Connect(function()
    scanRemotes()
    refreshRemoteList(RemoteSpyFilterBox.Text)
    notify("Scanned: " .. #scannedRemotes .. " remotes", "success")
end)

RemoteSpyVulnScanBtn.MouseButton1Click:Connect(function()
    RemoteSpyVulnScanBtn.Text = "⚠ Scanning..."
    task.spawn(function()
        vulnScanRemotes()
        RemoteSpyVulnScanBtn.Text = "⚠ VULN SCAN"
    end)
end)

RemoteSpyFireCustomBtn.MouseButton1Click:Connect(function()
    if not selectedFireRemote then
        notify("Select a remote first (click 🎯)", "warning")
        return
    end
    local remote = selectedFireRemote.instance
    local args = parseFireArgs(RemoteSpyArgsBox.Text)
    fireTestRemote(remote, args)
end)

RemoteSpyMassFireBtn.MouseButton1Click:Connect(function()
    massFireRemotes()
end)

RemoteSpyFuzzBtn.MouseButton1Click:Connect(function()
    fuzzRemote()
end)

RemoteSpyDecompileBtn.MouseButton1Click:Connect(function()
    decompileForRemote()
end)

DecompileCloseBtn.MouseButton1Click:Connect(function()
    DecompilePanel.Visible = false
end)

DecompileCopyBtn.MouseButton1Click:Connect(function()
    pcall(function()
        if setclipboard then setclipboard(decompileResultText)
        elseif toclipboard then toclipboard(decompileResultText) end
    end)
    notify("Decompile results copied!", "success")
end)

RemoteSpyToggleBtn.MouseButton1Click:Connect(function()
    if remoteSpyActive then
        stopRemoteSpy()
    else
        startRemoteSpy()
    end
end)

RemoteSpyClearBtn.MouseButton1Click:Connect(function()
    remoteSpyLog = {}
    refreshRemoteSpyLog()
    notify("Spy log cleared", "info")
end)

RemoteSpyRepeatBtn.MouseButton1Click:Connect(function()
    if autoRepeatActive then
        stopAutoRepeat()
        RemoteSpyRepeatBtn.Text = "▶ REPEAT"
        RemoteSpyRepeatBtn.BackgroundColor3 = Color3.fromRGB(0, 160, 140)
    else
        if not selectedFireRemote then
            notify("Select a remote first (click 🎯)", "warning")
            return
        end
        local interval = tonumber(RemoteSpyRepeatIntervalBox.Text) or 1
        local count = tonumber(RemoteSpyRepeatCountBox.Text) or 0
        if interval < 0.1 then interval = 0.1 end
        startAutoRepeat(interval, count)
        RemoteSpyRepeatBtn.Text = "⏹ STOP"
        RemoteSpyRepeatBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
    end
end)

RemoteSpyExportBtn.MouseButton1Click:Connect(function()
    exportSpyLog()
end)

RemoteSpyCloseBtn.MouseButton1Click:Connect(function()
    if autoRepeatActive then stopAutoRepeat() end
    RemoteSpyPanel.Visible = false
end)

RemoteSpyCloseBottomBtn.MouseButton1Click:Connect(function()
    if autoRepeatActive then stopAutoRepeat() end
    RemoteSpyPanel.Visible = false
end)

-- Remote list filter debounce
do
    local remoteFilterTimer = nil
    RemoteSpyFilterBox:GetPropertyChangedSignal("Text"):Connect(function()
        if remoteFilterTimer then
            task.cancel(remoteFilterTimer)
        end
        remoteFilterTimer = task.delay(0.3, function()
            remoteFilterTimer = nil
            refreshRemoteList(RemoteSpyFilterBox.Text)
        end)
    end)
end

-- Spy log filter debounce
do
    local spyLogFilterTimer = nil
    RemoteSpyLogFilterBox:GetPropertyChangedSignal("Text"):Connect(function()
        if spyLogFilterTimer then
            task.cancel(spyLogFilterTimer)
        end
        spyLogFilterTimer = task.delay(0.3, function()
            spyLogFilterTimer = nil
            refreshRemoteSpyLog()
        end)
    end)
end

--==================================================
-- PLAYER INFO EVENTS
--==================================================

PlayerInfoToggle.btn.MouseButton1Click:Connect(function()
    playerInfoState.active = not playerInfoState.active
    PlayerInfoToggle.refresh()
    playerInfoActive = playerInfoState.active
    if playerInfoActive then
        updatePlayerInfo()
    else
        clearPlayerInfo()
        notify("Player Info Cards OFF", "info")
    end
end)

--==================================================
-- DEV TOOLS EVENTS
--==================================================

AntiAfkBtn.MouseButton1Click:Connect(function()
    if antiAfkActive then
        stopAntiAfk()
    else
        startAntiAfk()
    end
end)

ChatSpyOpenBtn.MouseButton1Click:Connect(function()
    openChatSpyPanel()
end)

ExecRunBtn.MouseButton1Click:Connect(function()
    executeScript(ExecScriptBox.Text)
end)

--==================================================
-- CHAT SPY EVENTS
--==================================================

ChatSpyToggleBtn.MouseButton1Click:Connect(function()
    if chatSpyActive then
        stopChatSpy()
    else
        startChatSpy()
    end
end)

ChatSpyClearBtn.MouseButton1Click:Connect(function()
    chatSpyLog = {}
    refreshChatSpyLog()
    notify("Chat log cleared", "info")
end)

ChatSpyCloseX.MouseButton1Click:Connect(function()
    ChatSpyPanel.Visible = false
end)

ChatSpyCloseBtn.MouseButton1Click:Connect(function()
    ChatSpyPanel.Visible = false
end)

-- Chat spy filter debounce
do
    local chatFilterTimer = nil
    ChatSpyFilterBox:GetPropertyChangedSignal("Text"):Connect(function()
        if chatFilterTimer then
            task.cancel(chatFilterTimer)
        end
        chatFilterTimer = task.delay(0.3, function()
            chatFilterTimer = nil
            refreshChatSpyLog()
        end)
    end)
end

--==================================================
-- BACKPACK VIEWER EVENTS
--==================================================

BackpackCloseX.MouseButton1Click:Connect(function()
    BackpackPanel.Visible = false
end)

BackpackCloseBtn.MouseButton1Click:Connect(function()
    BackpackPanel.Visible = false
end)

BackpackRefreshBtn.MouseButton1Click:Connect(function()
    if backpackTarget then
        scanBackpack(backpackTarget)
        refreshBackpackList()
        notify("Backpack refreshed", "info")
    end
end)

-- Backpack filter debounce
do
    local bpFilterTimer = nil
    BackpackFilterBox:GetPropertyChangedSignal("Text"):Connect(function()
        if bpFilterTimer then
            task.cancel(bpFilterTimer)
        end
        bpFilterTimer = task.delay(0.3, function()
            bpFilterTimer = nil
            refreshBackpackList()
        end)
    end)
end

--==================================================
-- DEATH BALL EVENTS
--==================================================

DeathBallCard.MouseButton1Click:Connect(function()
    DeathBallPanel.Visible = true
    notify("Death Ball v2 panel opened", "info")
end)

DeathBallAutoBtn.MouseButton1Click:Connect(function()
    if deathBallActive then
        stopDeathBall()
    else
        startDeathBall()
    end
end)

-- ESP toggle
DeathBallEspBtn.MouseButton1Click:Connect(function()
    deathBallEspActive = not deathBallEspActive
    if deathBallEspActive then
        DeathBallEspBtn.Text = "ESP: ON"
        DeathBallEspBtn.BackgroundColor3 = Color3.fromRGB(40, 80, 120)
        notify("Ball ESP ON", "success")
    else
        DeathBallEspBtn.Text = "ESP: OFF"
        DeathBallEspBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
        clearBallESP()
        notify("Ball ESP OFF", "info")
    end
end)

-- Dodge toggle
DeathBallDodgeBtn.MouseButton1Click:Connect(function()
    deathBallDodgeActive = not deathBallDodgeActive
    if deathBallDodgeActive then
        DeathBallDodgeBtn.Text = "DODGE: ON"
        DeathBallDodgeBtn.BackgroundColor3 = Color3.fromRGB(40, 100, 60)
        notify("Auto-Dodge ON", "success")
    else
        DeathBallDodgeBtn.Text = "DODGE: OFF"
        DeathBallDodgeBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
        notify("Auto-Dodge OFF", "info")
    end
end)

-- Scan for balls (multi-ball)
DeathBallScanBtn.MouseButton1Click:Connect(function()
    local ballName = DeathBallNameBox.Text or "Ball"
    deathBallCacheTime = 0
    local balls = findAllBalls(ballName)
    if #balls > 0 then
        local names = {}
        for i, b in ipairs(balls) do
            if i <= 5 then table.insert(names, b.Name .. " (" .. b:GetFullName():sub(1, 30) .. ")") end
        end
        notify("Found " .. #balls .. " balls!", "success")
        DeathBallBallInfo.Text = "Balls: " .. #balls .. " found"
        DeathBallBallInfo.TextColor3 = Color3.fromRGB(100, 220, 200)
    else
        notify("No balls with name '" .. ballName .. "' found", "warning")
        DeathBallBallInfo.Text = "Balls: none found"
        DeathBallBallInfo.TextColor3 = Color3.fromRGB(200, 100, 60)
    end
end)

-- Auto-Detect toggle
DeathBallAutoDetectBtn.MouseButton1Click:Connect(function()
    deathBallAutoDetect = not deathBallAutoDetect
    deathBallCacheTime = 0 -- force re-scan
    if deathBallAutoDetect then
        DeathBallAutoDetectBtn.Text = "AUTO-DETECT: ON"
        DeathBallAutoDetectBtn.BackgroundColor3 = Color3.fromRGB(40, 140, 60)
        notify("Auto-detect ON — finds balls by velocity", "success")
    else
        DeathBallAutoDetectBtn.Text = "AUTO-DETECT: OFF"
        DeathBallAutoDetectBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
        notify("Auto-detect OFF — using Ball Name field", "info")
    end
end)

-- Debug Mode toggle
DeathBallDebugBtn.MouseButton1Click:Connect(function()
    deathBallDebugMode = not deathBallDebugMode
    if deathBallDebugMode then
        DeathBallDebugBtn.Text = "DEBUG: ON"
        DeathBallDebugBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 120)
        notify("Debug ON — shows raw ball data in status", "info")
    else
        DeathBallDebugBtn.Text = "DEBUG: OFF"
        DeathBallDebugBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
        notify("Debug OFF", "info")
    end
end)

DeathBallCloseBtn.MouseButton1Click:Connect(function()
    if deathBallScannerActive then stopObjectScanner() end
    if deathBallBotActive then stopDeathBallBot() end
    if deathBallActive then stopDeathBall() end
    clearBallESP()
    DeathBallPanel.Visible = false
end)

DeathBallCloseBtnBottom.MouseButton1Click:Connect(function()
    if deathBallScannerActive then stopObjectScanner() end
    if deathBallBotActive then stopDeathBallBot() end
    if deathBallActive then stopDeathBall() end
    clearBallESP()
    DeathBallPanel.Visible = false
end)

-- AFK Bot toggle
DeathBallBotBtn.MouseButton1Click:Connect(function()
    if deathBallBotActive then
        stopDeathBallBot()
    else
        startDeathBallBot()
    end
end)

-- Set Queue Position
DeathBallSetQueueBtn.MouseButton1Click:Connect(function()
    setQueuePosition()
end)

-- Miss chance live update
DeathBallMissBox:GetPropertyChangedSignal("Text"):Connect(function()
    local val = tonumber(DeathBallMissBox.Text)
    if val then
        deathBallMissChance = math.clamp(val / 100, 0, 0.5)
    end
end)

-- Object Scanner toggle
DeathBallScanObjBtn.MouseButton1Click:Connect(function()
    if deathBallScannerActive then
        stopObjectScanner()
    else
        startObjectScanner()
    end
end)

-- Helper: carrega SynSaveInstance
local function loadSSI()
    local Params = {
        RepoURL = "https://raw.githubusercontent.com/luau/SynSaveInstance/main/",
        SSI = "saveinstance",
    }
    local loader = loadstring(game:HttpGet(Params.RepoURL .. Params.SSI .. ".luau", true), Params.SSI)
    if not loader then error("Failed to load SynSaveInstance") end
    return loader()
end

ConfirmSaveBtn.MouseButton1Click:Connect(function()
    ConfirmSaveBtn.Text = "💾 ..."
    task.spawn(function()
        local ok, err = pcall(function()
            local synsaveinstance = loadSSI()

            local fname = FileNameBox.Text
            if fname == "" then
                fname = game.PlaceId .. "_" .. os.date("%Y%m%d_%H%M%S")
            end

            local options = {
                FileName = fname,
                DecompileMode = saveConfigState.DecompileMode and "decompile" or "none",
                SavePlayers = saveConfigState.SavePlayers,
                RemovePlayerCharacters = saveConfigState.RemovePlayerCharacters,
                NilInstances = saveConfigState.NilInstances,
                SaveNonCreatable = saveConfigState.SaveNonCreatable,
                IsolateLocalPlayer = saveConfigState.IsolateLocalPlayer,
                SaveCameraInstances = saveConfigState.SaveCameraInstances,
            }

            log("Save options:", HttpService:JSONEncode(options))
            synsaveinstance(options)
        end)
        if ok then
            ConfirmSaveBtn.Text = "💾 SAVED!"
            notify("Instance saved!", "success")
        else
            log("Save ERROR:", tostring(err))
            ConfirmSaveBtn.Text = "💾 ERR"
            notify("Save error: " .. tostring(err):sub(1, 50), "error")
        end
        task.delay(3, function() ConfirmSaveBtn.Text = "💾 SAVE" end)
    end)
end)

SaveAllBtn.MouseButton1Click:Connect(function()
    SaveAllBtn.Text = "⚡ ..."
    task.spawn(function()
        local ok, err = pcall(function()
            local synsaveinstance = loadSSI()
            local options = {}
            log("Save All: default options")
            synsaveinstance(options)
        end)
        if ok then
            SaveAllBtn.Text = "⚡ SAVED!"
            notify("All saved!", "success")
        else
            log("Save All ERROR:", tostring(err))
            SaveAllBtn.Text = "⚡ ERR"
            notify("Save error", "error")
        end
        task.delay(3, function() SaveAllBtn.Text = "⚡ SAVE ALL" end)
    end)
end)

--==================================================
-- PREVIEW EVENTS
--==================================================

PreviewClose.MouseButton1Click:Connect(function()
    clearPreview()
    PreviewFrame.Visible = false
end)

--==================================================
-- GLOBAL EVENTS
--==================================================

-- X fecha tudo (destroy)
CloseBtn.MouseButton1Click:Connect(function()
    stopSpectate()
    stopEmote()
    stopTroll()
    resetAllCosmetics()
    if shadowRecording then stopShadowRecording() end
    if shadowReplaying then stopShadowReplay() end
    stopShadow()
    ShadowPanel.Visible = false
    TrollPanel.Visible = false
    stopRemoteSpy()
    if autoRepeatActive then stopAutoRepeat() end
    RemoteSpyPanel.Visible = false
    DecompilePanel.Visible = false
    if deathBallScannerActive then stopObjectScanner() end
    if deathBallBotActive then stopDeathBallBot() end
    if deathBallActive then stopDeathBall() end
    clearBallESP()
    DeathBallPanel.Visible = false
    stopChatSpy()
    ChatSpyPanel.Visible = false
    BackpackPanel.Visible = false
    if antiAfkActive then stopAntiAfk() end
    clearPlayerInfo()
    playerInfoActive = false
    playerInfoState.active = false
    if espState.footsteps then stopFootsteps() end
    if espState.soundESP then stopSoundESP() end
    clearESP()
    clearPreview()
    clearResults()
    stopAutoScan()
    if movementState.fly then stopFly() end
    if movementState.noclip then
        movementState.noclip = false
        toggleNoclip()
    end
    if movementState.infiniteJump then
        movementState.infiniteJump = false
        toggleInfiniteJump()
    end
    if movementState.freecam then stopFreecam() end
    -- Remove nametag
    pcall(function()
        local char = LP.Character
        if char then
            local head = char:FindFirstChild("Head")
            if head then
                local tag = head:FindFirstChild("VampNametag")
                if tag then tag:Destroy() end
            end
        end
    end)
    -- Reset speed
    movementState.speed = 16
    movementState.jumpPower = 50
    applySpeed()
    ScreenGui:Destroy()
end)

-- Minimizar = volta pro MiniBar
MinBtn.MouseButton1Click:Connect(function()
    closeScanner()
end)

-- Ctrl+G = toggle abrir/fechar | N = toggle freecam
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == HOTKEY then
        if REQUIRE_CTRL and (UIS:IsKeyDown(Enum.KeyCode.LeftControl) or UIS:IsKeyDown(Enum.KeyCode.RightControl)) then
            toggleScanner()
        elseif not REQUIRE_CTRL then
            toggleScanner()
        end
    elseif input.KeyCode == Enum.KeyCode.N then
        movementState.freecam = not movementState.freecam
        moveToggles.freecam.refresh()
        if movementState.freecam then
            startFreecam()
        else
            stopFreecam()
        end
    end
end)

--==================================================
-- TAB SWITCH ENHANCEMENT (refresh data on tab change)
--==================================================

-- Override switchTab to add refresh behavior
local baseSwitchTab = switchTab
switchTab = function(tabId)
    baseSwitchTab(tabId)

    -- Refresh player list when switching to player tab
    if tabId == "player" then
        refreshPlayerList()
        updateServerInfo()
    end

    -- Pre-load trending emotes + favorites on emote tab open
    if tabId == "emote" then
        preloadTrendingEmotes()
        if #favoriteEmotes == 0 then
            loadFavoriteEmotes()
        end
    end
end

--==================================================
-- VAMPIRE NAMETAG
--==================================================

local function createVampireNametag(char)
    if not char then return end
    local head = char:WaitForChild("Head", 5)
    if not head then return end

    -- Remove existing
    local existing = head:FindFirstChild("VampNametag")
    if existing then existing:Destroy() end

    local bb = Instance.new("BillboardGui")
    bb.Name = "VampNametag"
    bb.Size = UDim2.new(0, 300, 0, 60)
    bb.StudsOffset = Vector3.new(0, 2.5, 0)
    bb.AlwaysOnTop = false
    bb.Adornee = head
    bb.Parent = head

    -- Background card
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 0, 40)
    bg.Position = UDim2.new(0, 0, 0.5, -20)
    bg.BackgroundColor3 = Color3.fromRGB(15, 8, 12)
    bg.BackgroundTransparency = 0.2
    bg.BorderSizePixel = 0
    bg.Parent = bb
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 8)

    local bgStroke = Instance.new("UIStroke", bg)
    bgStroke.Color = Colors.blood
    bgStroke.Thickness = 1.8
    bgStroke.Transparency = 0.3

    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Colors.bloodDark),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(15, 8, 12)),
        ColorSequenceKeypoint.new(1, Colors.bloodDark),
    })
    grad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.4),
        NumberSequenceKeypoint.new(0.5, 0.15),
        NumberSequenceKeypoint.new(1, 0.4),
    })
    grad.Parent = bg

    -- Nametag text
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "🦇 Vampire Tester ❤"
    label.TextColor3 = Colors.bloodLight
    label.TextStrokeColor3 = Color3.fromRGB(40, 0, 0)
    label.TextStrokeTransparency = 0.4
    label.TextSize = 22
    label.Font = Enum.Font.GothamBold
    label.Parent = bg
end

-- Apply nametag on current + future characters
if LP.Character then
    task.spawn(function()
        createVampireNametag(LP.Character)
    end)
end
LP.CharacterAdded:Connect(function(char)
    task.spawn(function()
        createVampireNametag(char)
    end)
end)

--==================================================
-- INIT
--==================================================

-- Load favorite emotes from file
loadFavoriteEmotes()

-- Set default tab
switchTab("scanner")

-- Start auto-scan if enabled
if autoScanConfig.enabled then
    task.delay(1, function()
        startAutoScan()
    end)
end

log("══════════════════════════════════════")
log("VAMPIRE RIG SCANNER v13")
log("Create By VampireSonata")
log("══════════════════════════════════════")
log("MiniBar mode! Ctrl+G to toggle")
log("══════════════════════════════════════")

notify("🦇 Vampire Rig Scanner v13 loaded!", "success")
