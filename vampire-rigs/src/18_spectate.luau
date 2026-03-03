--==================================================
-- SPECTATE MODE
--==================================================

startSpectate = function(info)
    local targetChar = info.character
    if info.player and info.player.Character then
        targetChar = info.player.Character
    end

    if not targetChar then
        log("Spectate: character not found")
        notify("Spectate: character not found", "error")
        return
    end

    local humanoid = targetChar:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        log("Spectate: no Humanoid found")
        notify("Spectate: no Humanoid", "error")
        return
    end

    if spectatingInfo and spectatingInfo == info then
        stopSpectate()
        return
    end

    if spectatingInfo then
        stopSpectate()
    end

    local camera = workspace.CurrentCamera
    savedCameraSubject = camera.CameraSubject

    camera.CameraSubject = humanoid
    spectatingInfo = info

    -- Highlight (respects config)
    if spectateHighlight then
        spectateHighlight:Destroy()
        spectateHighlight = nil
    end
    if spectateConfig.showHighlight then
        spectateHighlight = Instance.new("Highlight")
        spectateHighlight.Name = "VampSpectateHL"
        spectateHighlight.FillColor = Colors.blood
        spectateHighlight.FillTransparency = 0.7
        spectateHighlight.OutlineColor = Colors.bloodLight
        spectateHighlight.OutlineTransparency = 0
        spectateHighlight.Adornee = targetChar
        spectateHighlight.Parent = targetChar
    end

    local specLabel = "🦇 UNSPECTATE (" .. info.name .. ")"
    UnspectateBtn.Visible = true
    UnspectateBtn.Text = specLabel
    PlayerUnspectateBtn.Visible = true
    PlayerUnspectateBtn.Text = specLabel

    notify("Spectating: " .. info.name, "info")
    log("Spectating:", info.name)
end

stopSpectate = function()
    if not spectatingInfo then return end

    local camera = workspace.CurrentCamera
    if savedCameraSubject then
        camera.CameraSubject = savedCameraSubject
        savedCameraSubject = nil
    else
        local localChar = LP.Character
        if localChar then
            local hum = localChar:FindFirstChildOfClass("Humanoid")
            if hum then
                camera.CameraSubject = hum
            end
        end
    end

    if spectateHighlight then
        spectateHighlight:Destroy()
        spectateHighlight = nil
    end

    spectatingInfo = nil
    UnspectateBtn.Visible = false
    PlayerUnspectateBtn.Visible = false

    notify("Spectate stopped", "info")
    log("Spectate stopped")
end
