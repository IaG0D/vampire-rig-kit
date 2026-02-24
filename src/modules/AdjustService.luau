--[[
	vulpy-rig-kit | AdjustService
	Servico de ajustes no rig selecionado:
	- Acessorios (posicao, rotacao, escala via Weld.C1 direto)
	- Cores do corpo (direto em BodyColors + BasePart.Color)
	- Proporcoes (direto em NumberValues do Humanoid)

	Tudo via manipulacao direta de parts.
	ApplyDescription NAO funciona visualmente em edit mode.
]]

local Players = game:GetService("Players")

local AdjustService = {}

-- ════════════════════════════════════════════════════════════════
-- Mapa de partes R15 para cores
-- ════════════════════════════════════════════════════════════════
local BODY_COLOR_MAP = {
	HeadColor = { "Head" },
	TorsoColor = { "UpperTorso", "LowerTorso" },
	LeftArmColor = { "LeftUpperArm", "LeftLowerArm", "LeftHand" },
	RightArmColor = { "RightUpperArm", "RightLowerArm", "RightHand" },
	LeftLegColor = { "LeftUpperLeg", "LeftLowerLeg", "LeftFoot" },
	RightLegColor = { "RightUpperLeg", "RightLowerLeg", "RightFoot" },
}

-- Mapa de escala HumanoidDescription -> NumberValue no Humanoid
local SCALE_MAP = {
	HeightScale = "BodyHeightScale",
	WidthScale = "BodyWidthScale",
	HeadScale = "HeadScale",
	ProportionScale = "BodyProportionScale",
}

-- ════════════════════════════════════════════════════════════════
-- Helper: encontra o Weld que conecta o Handle ao corpo
-- ════════════════════════════════════════════════════════════════
local function findAccessoryWeld(handle: BasePart): Weld?
	-- Procura AccessoryWeld no Handle
	local weld = handle:FindFirstChild("AccessoryWeld")
	if weld and weld:IsA("Weld") then
		return weld
	end
	-- Fallback: qualquer Weld no Handle
	for _, child in handle:GetChildren() do
		if child:IsA("Weld") then
			return child
		end
	end
	-- Procura no pai (Accessory)
	local acc = handle.Parent
	if acc then
		for _, child in acc:GetChildren() do
			if child:IsA("Weld") then
				return child
			end
		end
	end
	return nil
end

-- ════════════════════════════════════════════════════════════════
-- Helper: guarda o C1 original do weld para poder aplicar offsets
-- ════════════════════════════════════════════════════════════════
local function getOriginalC1(weld: Weld): CFrame
	local store = weld:FindFirstChild("_OrigC1")
	if store and store:IsA("CFrameValue") then
		return store.Value
	end
	-- Primeira vez: salva o C1 original
	local cfValue = Instance.new("CFrameValue")
	cfValue.Name = "_OrigC1"
	cfValue.Value = weld.C1
	cfValue.Parent = weld
	return weld.C1
end

-- ════════════════════════════════════════════════════════════════
-- Retorna lista de acessorios ajustaveis de um rig
-- ════════════════════════════════════════════════════════════════
function AdjustService.getAcessorios(rig: Model): { any }
	local list = {}

	for _, child in rig:GetChildren() do
		if child:IsA("Accessory") then
			local handle = child:FindFirstChild("Handle")
			if handle and handle:IsA("BasePart") then
				-- Tenta pegar assetId do nome ou usa hash
				local assetId = 0

				-- Tenta extrair de HumanoidDescription se disponivel
				local humanoid = rig:FindFirstChildOfClass("Humanoid")
				if humanoid then
					pcall(function()
						local desc = (humanoid :: Humanoid):GetAppliedDescription()
						if desc then
							for _, accDesc in desc:GetChildren() do
								if accDesc:IsA("AccessoryDescription") then
									-- Tenta casar pelo tipo
									if accDesc.AccessoryType == child.AccessoryType then
										-- Verifica se ja foi usado
										local used = false
										for _, existing in list do
											if existing.assetId == accDesc.AssetId then
												used = true
												break
											end
										end
										if not used then
											assetId = accDesc.AssetId
											break
										end
									end
								end
							end
							desc:Destroy()
						end
					end)
				end

				-- Se nao encontrou, gera um ID unico baseado no index
				if assetId == 0 then
					assetId = #list + 1
				end

				-- Le offset atual do weld
				local position = Vector3.zero
				local rotation = Vector3.zero
				local scale = Vector3.one

				local weld = findAccessoryWeld(handle)
				if weld then
					local origC1 = getOriginalC1(weld)
					local currentC1 = weld.C1
					-- Calcula o delta entre original e atual
					local delta = origC1:Inverse() * currentC1
					position = -delta.Position -- invertido porque C1 offset eh negativo
					local rx, ry, rz = delta:ToEulerAnglesXYZ()
					rotation = Vector3.new(-math.deg(rx), -math.deg(ry), -math.deg(rz))
				end

				-- Le escala do mesh
				local mesh = handle:FindFirstChildOfClass("SpecialMesh")
				if mesh then
					scale = mesh.Scale
				end

				table.insert(list, {
					assetId = assetId,
					name = child.Name,
					accessoryType = child.AccessoryType,
					position = position,
					rotation = rotation,
					scale = scale,
					instance = child,
				})
			end
		end
	end

	return list
end

-- ════════════════════════════════════════════════════════════════
-- Aplica ajuste de UM acessorio via Weld.C1 direto
-- Funciona em qualquer contexto (workspace, ViewportFrame, etc.)
-- ════════════════════════════════════════════════════════════════
function AdjustService.aplicarAjusteDireto(accInstance: Instance, position: Vector3, rotation: Vector3, scale: Vector3): boolean
	if not accInstance or not accInstance:IsA("Accessory") then
		warn("[vulpy-rig-kit] aplicarAjusteDireto: instancia invalida")
		return false
	end

	local handle = accInstance:FindFirstChild("Handle")
	if not handle or not handle:IsA("BasePart") then
		warn("[vulpy-rig-kit] aplicarAjusteDireto: Handle nao encontrado em", accInstance.Name)
		return false
	end

	-- Modifica offset via Weld.C1 + recalcula CFrame do Handle
	-- Em edit mode, o Weld nao reposiciona automaticamente (sem fisica)
	local weld = findAccessoryWeld(handle)
	if weld then
		local origC1 = getOriginalC1(weld)
		local posOffset = CFrame.new(-position) -- negativo porque C1 offset funciona invertido
		local rotOffset = CFrame.Angles(
			-math.rad(rotation.X),
			-math.rad(rotation.Y),
			-math.rad(rotation.Z)
		)
		local newC1 = origC1 * posOffset * rotOffset
		weld.C1 = newC1

		-- Recalcula CFrame do Handle manualmente (edit mode nao tem fisica)
		-- Equacao do Weld: Part0.CFrame * C0 = Part1.CFrame * C1
		-- Part0 = Handle, Part1 = BodyPart
		-- Handle.CFrame = Part1.CFrame * C1 * C0:Inverse()
		local part1 = weld.Part1
		if part1 then
			handle.CFrame = part1.CFrame * newC1 * weld.C0:Inverse()
		end

		print("[vulpy-rig-kit] Acessorio '", accInstance.Name, "' offset via Weld.C1 + CFrame")
	else
		warn("[vulpy-rig-kit] aplicarAjusteDireto: Weld nao encontrado em", accInstance.Name)
	end

	-- Modifica escala via SpecialMesh
	local mesh = handle:FindFirstChildOfClass("SpecialMesh")
	if mesh then
		mesh.Scale = scale
	end

	return true
end

-- ════════════════════════════════════════════════════════════════
-- Aplica ajustes de acessorios no rig (wrapper que encontra instances)
-- ════════════════════════════════════════════════════════════════
function AdjustService.aplicarAjusteAcessorios(rig: Model, adjustments: { [number]: { Position: Vector3?, Rotation: Vector3?, Scale: Vector3? } }): boolean
	local accList = AdjustService.getAcessorios(rig)
	local applied = false

	for _, acc in accList do
		local adj = adjustments[acc.assetId]
		if adj and acc.instance then
			local pos = adj.Position or Vector3.zero
			local rot = adj.Rotation or Vector3.zero
			local scl = adj.Scale or Vector3.one

			local ok = AdjustService.aplicarAjusteDireto(acc.instance, pos, rot, scl)
			if ok then
				applied = true
			end
		end
	end

	if not applied then
		warn("[vulpy-rig-kit] AdjustService: Nenhum acessorio aplicado. Verifique se o rig tem Accessories com Handle.")
	end

	return applied
end

-- ════════════════════════════════════════════════════════════════
-- Aplica cores do corpo no rig (direto em parts)
-- ════════════════════════════════════════════════════════════════
function AdjustService.aplicarCores(rig: Model, colors: { [string]: Color3 }): boolean
	local applied = false

	-- Modifica BodyColors (R6/R15)
	local bc = rig:FindFirstChildOfClass("BodyColors")
	if bc then
		local BC_MAP = {
			HeadColor = "HeadColor3",
			TorsoColor = "TorsoColor3",
			LeftArmColor = "LeftArmColor3",
			RightArmColor = "RightArmColor3",
			LeftLegColor = "LeftLegColor3",
			RightLegColor = "RightLegColor3",
		}
		for colorKey, color in colors do
			local bcProp = BC_MAP[colorKey]
			if bcProp then
				pcall(function()
					(bc :: any)[bcProp] = color
				end)
				applied = true
			end
		end
	end

	-- Modifica diretamente as BaseParts (R15)
	for colorKey, color in colors do
		local partNames = BODY_COLOR_MAP[colorKey]
		if partNames then
			for _, partName in partNames do
				local part = rig:FindFirstChild(partName)
				if part and part:IsA("BasePart") then
					part.Color = color
					applied = true
				end
			end
		end
	end

	if applied then
		print("[vulpy-rig-kit] Cores aplicadas via manipulacao direta")
	end

	return applied
end

-- ════════════════════════════════════════════════════════════════
-- Aplica proporcoes no rig (direto em NumberValues do Humanoid)
-- ════════════════════════════════════════════════════════════════
function AdjustService.aplicarProporcoes(rig: Model, proportions: { [string]: number }): boolean
	local humanoid = rig:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		warn("[vulpy-rig-kit] Humanoid nao encontrado para proporcoes")
		return false
	end

	local applied = false

	for descKey, value in proportions do
		local valueName = SCALE_MAP[descKey]
		if valueName then
			local scaleValue = humanoid:FindFirstChild(valueName)
			if scaleValue and scaleValue:IsA("NumberValue") then
				scaleValue.Value = value
				applied = true
			end
		end
	end

	if applied then
		print("[vulpy-rig-kit] Proporcoes aplicadas via NumberValues direto")
	end

	return applied
end

-- ════════════════════════════════════════════════════════════════
-- Retorna as cores atuais do corpo do rig
-- ════════════════════════════════════════════════════════════════
function AdjustService.getCoresAtuais(rig: Model): { [string]: Color3 }
	local cores = {}

	local bc = rig:FindFirstChildOfClass("BodyColors")
	if bc then
		pcall(function() cores.HeadColor = bc.HeadColor3 end)
		pcall(function() cores.TorsoColor = bc.TorsoColor3 end)
		pcall(function() cores.LeftArmColor = bc.LeftArmColor3 end)
		pcall(function() cores.RightArmColor = bc.RightArmColor3 end)
		pcall(function() cores.LeftLegColor = bc.LeftLegColor3 end)
		pcall(function() cores.RightLegColor = bc.RightLegColor3 end)
		return cores
	end

	for colorKey, partNames in BODY_COLOR_MAP do
		for _, partName in partNames do
			local part = rig:FindFirstChild(partName)
			if part and part:IsA("BasePart") then
				cores[colorKey] = part.Color
				break
			end
		end
	end

	return cores
end

-- ════════════════════════════════════════════════════════════════
-- Retorna as proporcoes atuais do rig
-- ════════════════════════════════════════════════════════════════
function AdjustService.getProporcoesAtuais(rig: Model): { [string]: number }
	local humanoid = rig:FindFirstChildOfClass("Humanoid")
	if not humanoid then return {} end

	local props = {}

	for descKey, valueName in SCALE_MAP do
		local scaleValue = humanoid:FindFirstChild(valueName)
		if scaleValue and scaleValue:IsA("NumberValue") then
			props[descKey] = scaleValue.Value
		end
	end

	return props
end

-- ════════════════════════════════════════════════════════════════
-- Aplica um item (assetId) no rig via HumanoidDescription
-- (este precisa de ApplyDescription pois adiciona novos itens)
-- ════════════════════════════════════════════════════════════════
function AdjustService.aplicarItem(rig: Model, assetId: number, assetType: string): boolean
	local humanoid = rig:FindFirstChildOfClass("Humanoid")
	if not humanoid then return false end

	local desc
	local ok = pcall(function()
		desc = (humanoid :: Humanoid):GetAppliedDescription()
	end)
	if not ok or not desc then return false end

	local assetStr = tostring(assetId)

	-- Mapa de tipo de acessorio -> propriedade no HumanoidDescription
	local ACC_TYPE_TO_PROP = {
		Hat = "HatAccessory",
		HairAccessory = "HairAccessory",
		FaceAccessory = "FaceAccessory",
		NeckAccessory = "NeckAccessory",
		ShoulderAccessory = "ShoulderAccessory",
		FrontAccessory = "FrontAccessory",
		BackAccessory = "BackAccessory",
		WaistAccessory = "WaistAccessory",
		HeadAccessory = "HatAccessory",
	}

	local accProp = ACC_TYPE_TO_PROP[assetType]
	if accProp then
		local current = (desc :: any)[accProp]
		if current and current ~= "" then
			(desc :: any)[accProp] = current .. "," .. assetStr
		else
			(desc :: any)[accProp] = assetStr
		end
	elseif assetType == "Shirt" then
		desc.Shirt = assetId
	elseif assetType == "Pants" then
		desc.Pants = assetId
	elseif assetType == "TShirt" or assetType == "TeeShirt" then
		desc.GraphicTShirt = assetId
	elseif assetType == "Face" then
		desc.Face = assetId
	elseif assetType == "Head" then
		desc.Head = assetId
	elseif assetType == "Torso" then
		desc.Torso = assetId
	elseif assetType == "RightArm" then
		desc.RightArm = assetId
	elseif assetType == "LeftArm" then
		desc.LeftArm = assetId
	elseif assetType == "RightLeg" then
		desc.RightLeg = assetId
	elseif assetType == "LeftLeg" then
		desc.LeftLeg = assetId
	end

	local applyOk = pcall(function()
		(humanoid :: Humanoid):ApplyDescription(desc)
	end)
	desc:Destroy()

	return applyOk
end

return AdjustService
