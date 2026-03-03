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

-- Unspectate
UnspectateBtn.MouseButton1Click:Connect(function()
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

ESPOffBtn.MouseButton1Click:Connect(function()
    for k in pairs(espState) do
        espState[k] = false
    end
    clearESP()
    for _, toggle in pairs(espToggles) do
        toggle.refresh()
    end
    ESPStatusLabel.Text = "ESP OFF — toggle features above"
    notify("All ESP disabled", "info")
end)

--==================================================
-- PLAYER TAB EVENTS
--==================================================

RefreshPlayersBtn.MouseButton1Click:Connect(function()
    refreshPlayerList()
    notify("Player list refreshed", "info")
end)

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
-- TELEPORT TAB EVENTS
--==================================================

TPSearchBtn.MouseButton1Click:Connect(function()
    tpToPart(TPInput.Text)
end)

TPInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        tpToPart(TPInput.Text)
    end
end)

SaveWPBtn.MouseButton1Click:Connect(function()
    addWaypoint(WPNameInput.Text)
    WPNameInput.Text = ""
end)

WPNameInput.FocusLost:Connect(function(enterPressed)
    if enterPressed and WPNameInput.Text ~= "" then
        addWaypoint(WPNameInput.Text)
        WPNameInput.Text = ""
    end
end)

--==================================================
-- SETTINGS TAB EVENTS
--==================================================

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

-- Ctrl+G = toggle abrir/fechar
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == HOTKEY then
        if REQUIRE_CTRL and (UIS:IsKeyDown(Enum.KeyCode.LeftControl) or UIS:IsKeyDown(Enum.KeyCode.RightControl)) then
            toggleScanner()
        elseif not REQUIRE_CTRL then
            toggleScanner()
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

    -- Refresh TP player list
    if tabId == "teleport" then
        refreshWaypointList()
    end
end

--==================================================
-- INIT
--==================================================

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
