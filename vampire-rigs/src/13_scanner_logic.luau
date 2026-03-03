--==================================================
-- EXTRACT DESCRIPTION (pega o objeto HumanoidDescription)
--==================================================

local function getHumanoidDescription(humanoid)
    local success, desc = pcall(function()
        return humanoid:GetAppliedDescription()
    end)
    return success and desc or nil
end

-- Helper: tenta ler propriedade com pcall isolado
local function safeGet(obj, prop)
    local ok, val = pcall(function() return obj[prop] end)
    return ok and val or nil
end

-- Extrai dados para JSON (cada propriedade isolada pra nao derrubar as outras)
local function extractDescriptionData(desc, rigType)
    if not desc then return nil end

    local data = {}
    local capturado = {}
    local falhou = {}

    data.RigType = rigType or "R15"

    -- Roupas
    for _, prop in ipairs({"Shirt", "Pants", "GraphicTShirt", "Face"}) do
        local val = safeGet(desc, prop)
        if val ~= nil then
            data[prop] = val
            table.insert(capturado, prop)
        else
            table.insert(falhou, prop)
        end
    end

    -- Body parts
    for _, prop in ipairs({"Head", "Torso", "LeftArm", "RightArm", "LeftLeg", "RightLeg"}) do
        local val = safeGet(desc, prop)
        if val ~= nil then
            data[prop] = val
            table.insert(capturado, prop)
        else
            table.insert(falhou, prop)
        end
    end

    -- Cores
    for _, prop in ipairs({"HeadColor", "TorsoColor", "LeftArmColor", "RightArmColor", "LeftLegColor", "RightLegColor"}) do
        local val = safeGet(desc, prop)
        if val ~= nil then
            data[prop] = color3ToTable(val)
            table.insert(capturado, prop)
        else
            table.insert(falhou, prop)
        end
    end

    -- Escalas
    for _, prop in ipairs({"BodyTypeScale", "DepthScale", "HeadScale", "HeightScale", "ProportionScale", "WidthScale"}) do
        local val = safeGet(desc, prop)
        if val ~= nil then
            data[prop] = val
            table.insert(capturado, prop)
        else
            table.insert(falhou, prop)
        end
    end

    -- Propriedades legacy de acessorios
    for _, prop in ipairs({
        "HatAccessory", "HairAccessory", "FaceAccessory",
        "NeckAccessory", "ShouldersAccessory", "FrontAccessory",
        "BackAccessory", "WaistAccessory",
    }) do
        local val = safeGet(desc, prop)
        if val ~= nil and val ~= "" then
            data[prop] = val
            table.insert(capturado, prop)
        end
    end

    -- Accessories via GetAccessories
    local accOk, accErr = pcall(function()
        local accessories = desc:GetAccessories(true)
        data.Accessories = {}
        for _, acc in ipairs(accessories) do
            table.insert(data.Accessories, {
                AssetId = acc.AssetId,
                AccessoryType = accessoryTypeToString(acc.AccessoryType),
                Order = acc.Order,
                Puffiness = acc.Puffiness,
                IsLayered = acc.IsLayered,
            })
        end
    end)
    if accOk then
        table.insert(capturado, "Accessories(" .. #(data.Accessories or {}) .. ")")
    else
        table.insert(falhou, "Accessories: " .. tostring(accErr))
    end

    -- AccessoryBlob
    if gethiddenproperty then
        local ok, blob = pcall(function()
            return gethiddenproperty(desc, "AccessoryBlob")
        end)
        if ok and blob and type(blob) == "string" and blob ~= "" then
            data.AccessoryBlob = blob
            table.insert(capturado, "AccessoryBlob(" .. #blob .. " chars)")
        else
            table.insert(falhou, "AccessoryBlob(gethiddenproperty: " .. tostring(blob) .. ")")
        end
    end

    -- AccessoryDescriptions
    local adjOk, adjErr = pcall(function()
        local accDescriptions = {}
        for _, child in ipairs(desc:GetChildren()) do
            if child:IsA("AccessoryDescription") and child.AssetId and child.AssetId > 0 then
                local pos = child.Position
                local rot = child.Rotation
                local scl = child.Scale

                local posChanged = pos.X ~= 0 or pos.Y ~= 0 or pos.Z ~= 0
                local rotChanged = rot.X ~= 0 or rot.Y ~= 0 or rot.Z ~= 0
                local sclChanged = scl.X ~= 1 or scl.Y ~= 1 or scl.Z ~= 1

                if posChanged or rotChanged or sclChanged then
                    local entry: any = { AssetId = child.AssetId }
                    if posChanged then entry.Position = { pos.X, pos.Y, pos.Z } end
                    if rotChanged then entry.Rotation = { rot.X, rot.Y, rot.Z } end
                    if sclChanged then entry.Scale = { scl.X, scl.Y, scl.Z } end
                    table.insert(accDescriptions, entry)
                end
            end
        end
        if #accDescriptions > 0 then
            data.AccessoryDescriptions = accDescriptions
        end
    end)
    if adjOk and data.AccessoryDescriptions then
        table.insert(capturado, "AccessoryDescriptions(" .. #data.AccessoryDescriptions .. ")")
    elseif not adjOk then
        table.insert(falhou, "AccessoryDescriptions: " .. tostring(adjErr))
    end

    log("  CAPTURADO:", table.concat(capturado, ", "))
    if #falhou > 0 then
        log("  FALHOU:", table.concat(falhou, ", "))
    end

    return data
end

--==================================================
-- LOAD RIG DATA
--==================================================

local function loadRigData(info)
    log("loadRigData:", info.name)

    if info.loaded then
        log("  Ja carregado")
        return true
    end

    local character = info.character

    if info.player and info.player.Character then
        character = info.player.Character
        info.character = character
    end

    if not character or not character.Parent then
        log("  ERRO: character invalido")
        return false
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        log("  ERRO: sem Humanoid")
        return false
    end

    log("  Pegando HumanoidDescription...")
    info.humanoidDescription = getHumanoidDescription(humanoid)

    if info.humanoidDescription then
        log("  HumanoidDescription: OK")
        info.rigType = humanoid.RigType
        info.fullDescription = extractDescriptionData(info.humanoidDescription, humanoid.RigType.Name)

        pcall(function()
            local ATT_TO_TYPE = {
                HatAttachment = "Hat",
                HairAttachment = "Hair",
                FaceFrontAttachment = "Face",
                FaceCenterAttachment = "Face",
                NeckAttachment = "Neck",
                BodyFrontAttachment = "Front",
                BodyBackAttachment = "Back",
                WaistCenterAttachment = "Waist",
                WaistBackAttachment = "Waist",
                RightCollarAttachment = "Shoulder",
                LeftCollarAttachment = "Shoulder",
            }

            local rigidByType = {}
            if info.fullDescription and info.fullDescription.Accessories then
                for _, acc in ipairs(info.fullDescription.Accessories) do
                    if not acc.IsLayered then
                        local t = acc.AccessoryType
                        if not rigidByType[t] then rigidByType[t] = {} end
                        table.insert(rigidByType[t], acc.AssetId)
                    end
                end
            end

            local typeCounters = {}
            local transforms = {}

            for _, child in ipairs(character:GetChildren()) do
                if child:IsA("Accessory") then
                    local handle = child:FindFirstChild("Handle")
                    if handle then
                        for _, att in ipairs(handle:GetChildren()) do
                            if att:IsA("Attachment") and not att.Name:match("^Rig") then
                                local accType = ATT_TO_TYPE[att.Name]
                                if accType then
                                    typeCounters[accType] = (typeCounters[accType] or 0) + 1
                                    local idx = typeCounters[accType]
                                    local assetId = rigidByType[accType] and rigidByType[accType][idx] or 0

                                    if assetId ~= 0 then
                                        local cf = att.CFrame
                                        local pos = cf.Position
                                        local rx, ry, rz = cf:ToOrientation()

                                        local scale = 1
                                        pcall(function()
                                            local mesh = handle:FindFirstChildOfClass("SpecialMesh")
                                            if mesh then
                                                scale = mesh.Scale.Y
                                            end
                                        end)

                                        table.insert(transforms, {
                                            AssetId = assetId,
                                            Name = child.Name,
                                            AttName = att.Name,
                                            Pos = {X = pos.X, Y = pos.Y, Z = pos.Z},
                                            Rot = {RX = rx, RY = ry, RZ = rz},
                                            Scale = scale,
                                        })
                                    end
                                end
                                break
                            end
                        end
                    end
                end
            end

            if #transforms > 0 then
                info.fullDescription.AccessoryTransforms = transforms
                log("  AccessoryTransforms:", #transforms, "rigidos capturados")
            end
        end)
    else
        log("  HumanoidDescription: FALHOU")
    end

    local hrp = character:FindFirstChild("HumanoidRootPart")
    info.savedPosition = hrp and hrp.CFrame or CFrame.new()

    info.loaded = true
    return info.humanoidDescription ~= nil
end

local function generateRigJSON(info)
    return {
        name = info.name,
        type = info.type,
        userId = info.userId,
        description = info.fullDescription
    }
end

--==================================================
-- GERAR RIG PARA PREVIEW
--==================================================

local function generatePreviewRig(info)
    log("generatePreviewRig:", info.name)

    if not info.humanoidDescription then
        log("  ERRO: sem humanoidDescription")
        return nil
    end

    local rigType = info.rigType or Enum.HumanoidRigType.R15

    log("  Gerando rig tipo:", tostring(rigType))

    local success, model = pcall(function()
        return Players:CreateHumanoidModelFromDescription(info.humanoidDescription, rigType)
    end)

    if success and model then
        log("  Rig gerado com sucesso!")

        model:PivotTo(CFrame.new(0, -500, 0))
        model.Parent = workspace

        for _, obj in pairs(model:GetDescendants()) do
            if obj:IsA("BaseScript") then
                obj:Destroy()
            end
        end

        task.wait()

        for _, part in pairs(model:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Anchored = true
            end
        end

        model.Parent = nil

        return model
    else
        log("  ERRO ao gerar rig:", tostring(model))
        return nil
    end
end
