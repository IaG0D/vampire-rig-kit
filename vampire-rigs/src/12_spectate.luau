--==================================================
-- SPECTATE MODE
--==================================================

local function startSpectate(info)
    -- Pega o character atual do target
    local targetChar = info.character
    if info.player and info.player.Character then
        targetChar = info.player.Character
    end

    if not targetChar then
        log("Spectate: character not found")
        return
    end

    local humanoid = targetChar:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        log("Spectate: no Humanoid found")
        return
    end

    -- Se ja ta spectando o mesmo, desspecta
    if spectatingInfo and spectatingInfo == info then
        stopSpectate()
        return
    end

    -- Limpa spectate anterior
    if spectatingInfo then
        stopSpectate()
    end

    -- Salva camera original
    local camera = workspace.CurrentCamera
    savedCameraSubject = camera.CameraSubject

    -- Seta camera no target
    camera.CameraSubject = humanoid
    spectatingInfo = info

    -- Cria Highlight blood no character
    if spectateHighlight then
        spectateHighlight:Destroy()
    end
    spectateHighlight = Instance.new("Highlight")
    spectateHighlight.Name = "VampSpectateHL"
    spectateHighlight.FillColor = Colors.blood
    spectateHighlight.FillTransparency = 0.7
    spectateHighlight.OutlineColor = Colors.bloodLight
    spectateHighlight.OutlineTransparency = 0
    spectateHighlight.Adornee = targetChar
    spectateHighlight.Parent = targetChar

    -- Mostra botao unspectate
    UnspectateBtn.Visible = true
    UnspectateBtn.Text = "🦇 UNSPECTATE (" .. info.name .. ")"

    log("Spectating:", info.name)
end

local function stopSpectate()
    if not spectatingInfo then return end

    -- Restaura camera
    local camera = workspace.CurrentCamera
    if savedCameraSubject then
        camera.CameraSubject = savedCameraSubject
        savedCameraSubject = nil
    else
        -- Fallback: volta pro character local
        local localChar = LP.Character
        if localChar then
            local hum = localChar:FindFirstChildOfClass("Humanoid")
            if hum then
                camera.CameraSubject = hum
            end
        end
    end

    -- Remove highlight
    if spectateHighlight then
        spectateHighlight:Destroy()
        spectateHighlight = nil
    end

    spectatingInfo = nil
    UnspectateBtn.Visible = false

    log("Spectate stopped")
end
