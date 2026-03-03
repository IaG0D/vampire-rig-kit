--[[
	vulpy-rig-kit | OutfitBuilderService
	Gerencia um HumanoidDescription em memoria para montar outfits customizados.
	O usuario escolhe um avatar base, adiciona/remove itens do catalogo,
	e no final gera o rig via CreateHumanoidModelFromDescription.
]]

local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")

local RigCreatorService = require(script.Parent.RigCreatorService)

local OutfitBuilderService = {}

-- ════════════════════════════════════════════════════════════════
-- Mapa: AssetTypeId -> propriedade do HumanoidDescription
-- ════════════════════════════════════════════════════════════════
local ASSET_TYPE_TO_DESC = {
	-- Acessorios (comma-separated, modo "append")
	[8]  = { prop = "HatAccessory",       mode = "append" },    -- Hat
	[41] = { prop = "HairAccessory",      mode = "append" },    -- Hair
	[42] = { prop = "FaceAccessory",      mode = "append" },    -- Face Accessory
	[43] = { prop = "NeckAccessory",      mode = "append" },    -- Neck
	[44] = { prop = "ShouldersAccessory", mode = "append" },    -- Shoulders
	[45] = { prop = "FrontAccessory",     mode = "append" },    -- Front
	[46] = { prop = "BackAccessory",      mode = "append" },    -- Back
	[47] = { prop = "WaistAccessory",     mode = "append" },    -- Waist
	-- Roupas (single ID, modo "single")
	[11] = { prop = "Shirt",             mode = "single" },    -- Shirt
	[12] = { prop = "Pants",             mode = "single" },    -- Pants
	[2]  = { prop = "GraphicTShirt",     mode = "single" },    -- T-Shirt
	[18] = { prop = "Face",              mode = "single" },    -- Face (decal)
	-- Body parts (single ID)
	[17] = { prop = "Head",              mode = "single" },    -- Head
	[79] = { prop = "Head",              mode = "single" },    -- Head (alt)
	[27] = { prop = "Torso",             mode = "single" },    -- Torso
	[28] = { prop = "RightArm",          mode = "single" },    -- Right Arm
	[29] = { prop = "LeftArm",           mode = "single" },    -- Left Arm
	[30] = { prop = "LeftLeg",           mode = "single" },    -- Left Leg
	[31] = { prop = "RightLeg",          mode = "single" },    -- Right Leg
}

-- ════════════════════════════════════════════════════════════════
-- Estado interno
-- ════════════════════════════════════════════════════════════════
local baseDescription: HumanoidDescription? = nil
local workingDescription: HumanoidDescription? = nil
local addedItems: { { assetId: number, prop: string, name: string, mode: string } } = {}
local baseUserId: number? = nil
local baseUsername: string? = nil
local previewModel: Model? = nil

-- ════════════════════════════════════════════════════════════════
-- Helpers para manipular propriedades comma-separated
-- ════════════════════════════════════════════════════════════════
local function appendToCommaSeparated(current: string, assetId: number): string
	local str = tostring(assetId)
	if current == "" or current == "0" then
		return str
	end
	return current .. "," .. str
end

local function removeFromCommaSeparated(current: string, assetId: number): string
	local str = tostring(assetId)
	local parts = {}
	for part in string.gmatch(current, "[^,]+") do
		if part ~= str then
			table.insert(parts, part)
		end
	end
	return table.concat(parts, ",")
end

local function getDescProp(desc: HumanoidDescription, prop: string): any
	local ok, val = pcall(function()
		return (desc :: any)[prop]
	end)
	return if ok then val else nil
end

local function setDescProp(desc: HumanoidDescription, prop: string, value: any)
	pcall(function()
		(desc :: any)[prop] = value
	end)
end

-- ════════════════════════════════════════════════════════════════
-- Clona um HumanoidDescription copiando todas as propriedades relevantes
-- ════════════════════════════════════════════════════════════════
local DESC_PROPS = {
	-- Acessorios
	"HatAccessory", "HairAccessory", "FaceAccessory", "NeckAccessory",
	"ShouldersAccessory", "FrontAccessory", "BackAccessory", "WaistAccessory",
	-- Roupas
	"Shirt", "Pants", "GraphicTShirt", "Face",
	-- Body parts
	"Head", "Torso", "RightArm", "LeftArm", "RightLeg", "LeftLeg",
	-- Cores
	"HeadColor", "TorsoColor", "LeftArmColor", "RightArmColor", "LeftLegColor", "RightLegColor",
	-- Escalas
	"HeightScale", "WidthScale", "HeadScale", "ProportionScale", "DepthScale", "BodyTypeScale",
}

local function cloneDescription(source: HumanoidDescription): HumanoidDescription
	local newDesc = Instance.new("HumanoidDescription")
	for _, prop in DESC_PROPS do
		local val = getDescProp(source, prop)
		if val ~= nil then
			setDescProp(newDesc, prop, val)
		end
	end
	return newDesc
end

-- ════════════════════════════════════════════════════════════════
-- Funcoes publicas
-- ════════════════════════════════════════════════════════════════

-- Carrega avatar base de um userId
function OutfitBuilderService.setBaseAvatar(userId: number, username: string?): (boolean, string?)
	-- Limpa estado anterior
	if baseDescription then baseDescription:Destroy() end
	if workingDescription then workingDescription:Destroy() end
	baseDescription = nil
	workingDescription = nil
	addedItems = {}

	local desc: HumanoidDescription? = nil
	local ok = pcall(function()
		desc = Players:GetHumanoidDescriptionFromUserId(userId)
	end)

	if not ok or not desc then
		return false, "Falha ao obter avatar do userId " .. tostring(userId)
	end

	baseDescription = desc
	workingDescription = cloneDescription(desc)
	baseUserId = userId
	baseUsername = username

	return true, nil
end

-- Adiciona um item ao outfit em construcao
function OutfitBuilderService.adicionarItem(assetId: number): (boolean, string?, string?)
	if not workingDescription then
		return false, "Nenhum avatar base carregado", nil
	end

	-- Busca info do asset para determinar tipo
	local info
	local ok = pcall(function()
		info = MarketplaceService:GetProductInfo(assetId, Enum.InfoType.Asset)
	end)

	if not ok or not info then
		return false, "Item nao encontrado: " .. tostring(assetId), nil
	end

	local assetTypeId = info.AssetTypeId
	local mapping = ASSET_TYPE_TO_DESC[assetTypeId]

	if not mapping then
		return false, "Tipo de item nao suportado (AssetTypeId: " .. tostring(assetTypeId) .. ")", nil
	end

	local prop = mapping.prop
	local mode = mapping.mode
	local name = info.Name or ("Item " .. tostring(assetId))

	if mode == "append" then
		local current = getDescProp(workingDescription, prop) or ""
		setDescProp(workingDescription, prop, appendToCommaSeparated(tostring(current), assetId))
	else
		setDescProp(workingDescription, prop, assetId)
	end

	-- Registra o item adicionado
	table.insert(addedItems, {
		assetId = assetId,
		prop = prop,
		name = name,
		mode = mode,
	})

	return true, nil, name
end

-- Remove um item especifico do outfit
function OutfitBuilderService.removerItem(assetId: number): boolean
	if not workingDescription or not baseDescription then
		return false
	end

	-- Encontra o item na lista
	local index: number? = nil
	local item: any = nil
	for i, it in addedItems do
		if it.assetId == assetId then
			index = i
			item = it
			break
		end
	end

	if not index or not item then
		return false
	end

	local prop = item.prop
	local mode = item.mode

	-- Remove da lista
	table.remove(addedItems, index)

	if mode == "append" then
		-- Remove o ID da string comma-separated
		local current = tostring(getDescProp(workingDescription, prop) or "")
		setDescProp(workingDescription, prop, removeFromCommaSeparated(current, assetId))
	else
		-- Para "single": se nao ha mais itens adicionados nessa prop, restaura o base
		local outrosNaProp = false
		for _, it in addedItems do
			if it.prop == prop then
				outrosNaProp = true
				break
			end
		end
		if not outrosNaProp then
			-- Restaura valor original do base
			local baseVal = getDescProp(baseDescription, prop)
			setDescProp(workingDescription, prop, baseVal)
		end
	end

	return true
end

-- Limpa todos os itens adicionados, preservando o avatar base
function OutfitBuilderService.limpar(): number
	if not workingDescription or not baseDescription then
		return 0
	end

	local count = #addedItems

	-- Coleta todas as propriedades afetadas
	local propsAfetadas: { [string]: boolean } = {}
	for _, item in addedItems do
		propsAfetadas[item.prop] = true
	end

	-- Restaura cada propriedade ao valor base
	for prop in propsAfetadas do
		local baseVal = getDescProp(baseDescription, prop)
		setDescProp(workingDescription, prop, baseVal)
	end

	addedItems = {}
	return count
end

-- Retorna o HumanoidDescription de trabalho atual
function OutfitBuilderService.getWorkingDescription(): HumanoidDescription?
	return workingDescription
end

-- Retorna lista dos itens adicionados
function OutfitBuilderService.getAddedItems(): { { assetId: number, prop: string, name: string, mode: string } }
	return addedItems
end

-- Cria o rig final no workspace
function OutfitBuilderService.criarRigFinal(rigName: string, parent: Instance, addNameTag: boolean?): (Model?, string?)
	if not workingDescription then
		return nil, "Nenhum avatar base carregado"
	end

	local descClone = cloneDescription(workingDescription)
	local model = RigCreatorService.createModelFromDescription(descClone, rigName, parent)
	descClone:Destroy()

	if not model then
		return nil, "Falha ao criar model"
	end

	if addNameTag then
		RigCreatorService.criarNameTag(model, rigName)
	end

	print("[vulpy-rig-kit] Outfit rig criado:", rigName)
	return model, nil
end

-- Destroi preview anterior (chamado internamente e no reset)
local function destroyPreview()
	if previewModel then
		previewModel:Destroy()
		previewModel = nil
	end
end

-- Cria modelo temporario para preview (underground, sem cleanup pesado)
-- O modelo anterior e destruido automaticamente. O modelo retornado
-- permanece vivo no workspace (Y=-500) ate o proximo preview ou reset().
function OutfitBuilderService.criarPreviewModel(): Model?
	if not workingDescription then
		return nil
	end

	-- Destroi preview anterior
	destroyPreview()

	local descClone = cloneDescription(workingDescription)

	local success, model = pcall(function()
		return Players:CreateHumanoidModelFromDescription(descClone, Enum.HumanoidRigType.R15)
	end)

	descClone:Destroy()

	if not success or not model then
		return nil
	end

	model.Name = "OutfitPreview"

	local rootPart = model:FindFirstChild("HumanoidRootPart")
	if rootPart and rootPart:IsA("BasePart") then
		rootPart.Anchored = true
	end

	-- Posiciona underground para nao aparecer no viewport do Studio
	model:PivotTo(CFrame.new(0, -500, 0))
	model.Parent = workspace
	task.wait(1.5)

	-- Reaplica description para garantir acessorios
	local descClone2 = cloneDescription(workingDescription)
	local humanoid = model:FindFirstChildOfClass("Humanoid")
	if humanoid then
		pcall(function()
			(humanoid :: Humanoid):ApplyDescription(descClone2)
		end)
		task.wait(1)
	end
	descClone2:Destroy()

	-- Ancora todas as partes
	for _, part in model:GetDescendants() do
		if part:IsA("BasePart") then
			part.Anchored = true
		end
	end

	-- Salva referencia para cleanup futuro
	previewModel = model

	return model
end

-- Retorna se tem avatar base carregado
function OutfitBuilderService.hasBase(): boolean
	return baseDescription ~= nil
end

-- Retorna info do avatar base
function OutfitBuilderService.getBaseInfo(): (number?, string?)
	return baseUserId, baseUsername
end

-- Reseta todo o estado (para cleanup)
function OutfitBuilderService.reset()
	destroyPreview()
	if baseDescription then baseDescription:Destroy() end
	if workingDescription then workingDescription:Destroy() end
	baseDescription = nil
	workingDescription = nil
	addedItems = {}
	baseUserId = nil
	baseUsername = nil
end

return OutfitBuilderService
