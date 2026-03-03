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
ConfirmSaveBtn.MouseButton1Click:Connect(function()
    ConfirmSaveBtn.Text = "💾 SALVANDO..."
    task.spawn(function()
        local ok, err = pcall(function()
            local Params = {
                RepoURL = "https://raw.githubusercontent.com/luau/SynSaveInstance/main/",
                SSI = "saveinstance",
            }
            local loader = loadstring(game:HttpGet(Params.RepoURL .. Params.SSI .. ".luau", true), Params.SSI)
            if not loader then error("Falha ao carregar SynSaveInstance") end
            local synsaveinstance = loader()

            -- Monta nome do arquivo
            local fname = FileNameBox.Text
            if fname == "" then
                fname = game.PlaceId .. "_" .. os.date("%Y%m%d_%H%M%S")
            end

            -- Monta options a partir dos toggles
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

            -- Se OnlyRigs, coleta todos os modelos com Humanoid
            if saveConfigState.OnlyRigs then
                local rigs = {}
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") then
                        table.insert(rigs, obj)
                    end
                end
                options.Mode = "custom"
                options.ExtraInstances = rigs
                log("OnlyRigs: encontrados " .. #rigs .. " rigs")
            end

            log("SaveInstance options:", HttpService:JSONEncode(options))
            synsaveinstance(options)
        end)
        if ok then
            ConfirmSaveBtn.Text = "💾 SALVO!"
        else
            log("SaveInstance ERRO:", tostring(err))
            ConfirmSaveBtn.Text = "💾 ERRO: " .. tostring(err):sub(1, 30)
        end
        task.delay(3, function() ConfirmSaveBtn.Text = "💾 SALVAR AGORA" end)
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
