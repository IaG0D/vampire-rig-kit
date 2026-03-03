--==================================================
-- EVENTS
--==================================================

ScanBtn.MouseButton1Click:Connect(runScan)
CopyBtn.MouseButton1Click:Connect(copyToClipboard)
ExportAllBtn.MouseButton1Click:Connect(exportAllJSON)
SaveInstanceBtn.MouseButton1Click:Connect(function()
    SavePanel.Visible = not SavePanel.Visible
end)
SavePanelClose.MouseButton1Click:Connect(function()
    SavePanel.Visible = false
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

-- SAVE (uses toggle config)
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
        else
            log("Save ERROR:", tostring(err))
            ConfirmSaveBtn.Text = "💾 ERR"
        end
        task.delay(3, function() ConfirmSaveBtn.Text = "💾 SAVE" end)
    end)
end)

-- SAVE ALL (ignores config, default options)
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
        else
            log("Save All ERROR:", tostring(err))
            SaveAllBtn.Text = "⚡ ERR"
        end
        task.delay(3, function() SaveAllBtn.Text = "⚡ SAVE ALL" end)
    end)
end)
PreviewClose.MouseButton1Click:Connect(function()
    clearPreview()
    PreviewFrame.Visible = false
end)
-- X fecha tudo (destroy)
CloseBtn.MouseButton1Click:Connect(function()
    clearPreview()
    clearResults()
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
-- INIT
--==================================================

log("══════════════════════════════════════")
log("VAMPIRE RIG SCANNER v10")
log("Create By VampireSonata")
log("══════════════════════════════════════")
log("MiniBar mode! Ctrl+G to toggle")
log("══════════════════════════════════════")
