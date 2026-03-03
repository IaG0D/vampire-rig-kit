--==================================================
-- PREVIEW
--==================================================

local function clearPreview()
    if previewConnection then
        previewConnection:Disconnect()
        previewConnection = nil
    end
    for _, child in pairs(Viewport:GetChildren()) do
        if child ~= ViewportStatus and not child:IsA("UICorner") and not child:IsA("UIStroke") then
            child:Destroy()
        end
    end
    ViewportStatus.Text = ""
end

local function showPreview(info)
    log("showPreview:", info.name)
    clearPreview()

    currentPreviewData = info
    PreviewTitle.Text = "🦇 " .. info.name
    PreviewFrame.Visible = true

    ViewportStatus.Text = "Carregando..."
    InfoLabel.Text = "Carregando dados..."

    -- Carrega dados se necessario
    if not info.loaded then
        log("  Carregando dados...")
        task.spawn(function()
            local success = loadRigData(info)

            if success then
                -- Atualiza card
                if info.cardFrame then
                    info.cardFrame.BackgroundColor3 = Colors.cardLoaded
                end
                if info.statusLabel and info.fullDescription then
                    local accCount = info.fullDescription.Accessories and #info.fullDescription.Accessories or 0
                    info.statusLabel.Text = (info.fullDescription.RigType or "?") .. " | " .. accCount .. " acc"
                    info.statusLabel.TextColor3 = Colors.greenLight
                end
                showPreview(info)
            else
                ViewportStatus.Text = "ERRO ao carregar"
                InfoLabel.Text = "Nao foi possivel carregar.\nO character pode ter saido."
            end
        end)
        return
    end

    -- GERAR RIG PARA PREVIEW
    log("  Gerando preview...")
    ViewportStatus.Text = "Gerando rig..."

    task.spawn(function()
        local previewModel = generatePreviewRig(info)

        if previewModel then
            -- Camera
            local camera = Instance.new("Camera")
            camera.FieldOfView = 50
            camera.Parent = Viewport
            Viewport.CurrentCamera = camera

            -- WorldModel
            local worldModel = Instance.new("WorldModel")
            worldModel.Parent = Viewport
            previewModel.Parent = worldModel

            -- Centraliza (PivotTo preserva joints do R15)
            previewModel:PivotTo(CFrame.new(0, 0, 0))

            -- Rotacao
            local angle = 0
            previewConnection = RunService.RenderStepped:Connect(function(dt)
                angle = angle + dt * 0.8
                camera.CFrame = CFrame.new(
                    Vector3.new(math.sin(angle) * 12, 2, math.cos(angle) * 12),
                    Vector3.new(0, 0, 0)
                )
            end)

            ViewportStatus.Text = ""
            log("  Preview criado!")
        else
            ViewportStatus.Text = "Erro ao gerar rig"
        end
    end)

    -- INFO TEXT
    local desc = info.fullDescription
    if desc then
        local txt = "=== " .. info.name .. " ===\n"
        txt = txt .. "Tipo: " .. info.type .. "\n"
        txt = txt .. "RigType: " .. tostring(desc.RigType or "?") .. "\n\n"

        txt = txt .. "-- ROUPAS --\n"
        txt = txt .. "Shirt: " .. tostring(desc.Shirt or 0) .. "\n"
        txt = txt .. "Pants: " .. tostring(desc.Pants or 0) .. "\n"
        txt = txt .. "Face: " .. tostring(desc.Face or 0) .. "\n\n"

        local accCount = desc.Accessories and #desc.Accessories or 0
        txt = txt .. "-- ACESSORIOS (" .. accCount .. ") --\n"
        if desc.Accessories then
            for i, acc in ipairs(desc.Accessories) do
                txt = txt .. i .. ". " .. acc.AccessoryType
                if acc.IsLayered then txt = txt .. " [L]" end
                txt = txt .. " - " .. acc.AssetId .. "\n"
            end
        end

        txt = txt .. "\n-- ESCALAS --\n"
        txt = txt .. "Height: " .. string.format("%.2f", desc.HeightScale or 1) .. "\n"
        txt = txt .. "Width: " .. string.format("%.2f", desc.WidthScale or 1) .. "\n"
        txt = txt .. "BodyType: " .. string.format("%.2f", desc.BodyTypeScale or 0) .. "\n"

        InfoLabel.Text = txt
    else
        InfoLabel.Text = "Sem dados"
    end
end
