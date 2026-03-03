--[[
	vulpy-rig-kit | JsonRigService
	Cria RIGs a partir de JSON exportado pelo Avatar Scanner.
	Suporta formato 1Player (objeto unico) e AllPlayers (array de rigs).
	Monta HumanoidDescription a partir dos dados JSON e reutiliza
	o RigCreatorService para criar o model.
]]

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local RigCreatorService = require(script.Parent.RigCreatorService)

local JsonRigService = {}

-- ════════════════════════════════════════════════════════════════
-- Constantes
-- ════════════════════════════════════════════════════════════════
local GRID_COLUMNS = 10
local GRID_SPACING_X = 6
local GRID_SPACING_Z = 6

-- ════════════════════════════════════════════════════════════════
-- Mapeamento AccessoryType string → Enum
-- ════════════════════════════════════════════════════════════════
local ACCESSORY_TYPE_MAP: { [string]: Enum.AccessoryType } = {
	Hat = Enum.AccessoryType.Hat,
	Hair = Enum.AccessoryType.Hair,
	Face = Enum.AccessoryType.Face,
	Neck = Enum.AccessoryType.Neck,
	Shoulder = Enum.AccessoryType.Shoulder,
	Front = Enum.AccessoryType.Front,
	Back = Enum.AccessoryType.Back,
	Waist = Enum.AccessoryType.Waist,
	TShirt = Enum.AccessoryType.TShirt,
	Shirt = Enum.AccessoryType.Shirt,
	Pants = Enum.AccessoryType.Pants,
	Jacket = Enum.AccessoryType.Jacket,
	Sweater = Enum.AccessoryType.Sweater,
	Shorts = Enum.AccessoryType.Shorts,
	LeftShoe = Enum.AccessoryType.LeftShoe,
	RightShoe = Enum.AccessoryType.RightShoe,
	DressSkirt = Enum.AccessoryType.DressSkirt,
	EyeAccessory = Enum.AccessoryType.Eyebrow,
}

-- ════════════════════════════════════════════════════════════════
-- Converte Color3 a partir de {R, G, B} do JSON (floats 0-1)
-- ════════════════════════════════════════════════════════════════
local function colorFromJson(data: { R: number, G: number, B: number }): Color3
	if not data then return Color3.new(0.63, 0.63, 0.63) end
	return Color3.new(data.R or 0, data.G or 0, data.B or 0)
end

-- ════════════════════════════════════════════════════════════════
-- Constroi HumanoidDescription a partir da tabela description do JSON
-- ════════════════════════════════════════════════════════════════
function JsonRigService.buildDescription(desc: any): HumanoidDescription
	local hd = Instance.new("HumanoidDescription")

	-- Body parts
	if desc.Head and desc.Head ~= 0 then hd.Head = desc.Head end
	if desc.Torso and desc.Torso ~= 0 then hd.Torso = desc.Torso end
	if desc.LeftArm and desc.LeftArm ~= 0 then hd.LeftArm = desc.LeftArm end
	if desc.RightArm and desc.RightArm ~= 0 then hd.RightArm = desc.RightArm end
	if desc.LeftLeg and desc.LeftLeg ~= 0 then hd.LeftLeg = desc.LeftLeg end
	if desc.RightLeg and desc.RightLeg ~= 0 then hd.RightLeg = desc.RightLeg end

	-- Face
	if desc.Face and desc.Face ~= 0 then hd.Face = desc.Face end

	-- Clothing
	if desc.Shirt and desc.Shirt ~= 0 then hd.Shirt = desc.Shirt end
	if desc.Pants and desc.Pants ~= 0 then hd.Pants = desc.Pants end
	if desc.GraphicTShirt and desc.GraphicTShirt ~= 0 then hd.GraphicTShirt = desc.GraphicTShirt end

	-- Scales
	if desc.HeadScale then hd.HeadScale = desc.HeadScale end
	if desc.HeightScale then hd.HeightScale = desc.HeightScale end
	if desc.WidthScale then hd.WidthScale = desc.WidthScale end
	if desc.DepthScale then hd.DepthScale = desc.DepthScale end
	if desc.BodyTypeScale then hd.BodyTypeScale = desc.BodyTypeScale end
	if desc.ProportionScale then hd.ProportionScale = desc.ProportionScale end

	-- Colors
	if desc.HeadColor then hd.HeadColor = colorFromJson(desc.HeadColor) end
	if desc.TorsoColor then hd.TorsoColor = colorFromJson(desc.TorsoColor) end
	if desc.LeftArmColor then hd.LeftArmColor = colorFromJson(desc.LeftArmColor) end
	if desc.RightArmColor then hd.RightArmColor = colorFromJson(desc.RightArmColor) end
	if desc.LeftLegColor then hd.LeftLegColor = colorFromJson(desc.LeftLegColor) end
	if desc.RightLegColor then hd.RightLegColor = colorFromJson(desc.RightLegColor) end

	-- Animations ignoradas: nao servem pra rig estatico

	-- Legacy accessory string properties (AssetIds separados por virgula)
	-- Importante: setar ANTES de SetAccessories pra engine resolver posicoes
	if desc.HatAccessory and desc.HatAccessory ~= "" then hd.HatAccessory = desc.HatAccessory end
	if desc.HairAccessory and desc.HairAccessory ~= "" then hd.HairAccessory = desc.HairAccessory end
	if desc.FaceAccessory and desc.FaceAccessory ~= "" then hd.FaceAccessory = desc.FaceAccessory end
	if desc.NeckAccessory and desc.NeckAccessory ~= "" then hd.NeckAccessory = desc.NeckAccessory end
	if desc.ShouldersAccessory and desc.ShouldersAccessory ~= "" then hd.ShouldersAccessory = desc.ShouldersAccessory end
	if desc.FrontAccessory and desc.FrontAccessory ~= "" then hd.FrontAccessory = desc.FrontAccessory end
	if desc.BackAccessory and desc.BackAccessory ~= "" then hd.BackAccessory = desc.BackAccessory end
	if desc.WaistAccessory and desc.WaistAccessory ~= "" then hd.WaistAccessory = desc.WaistAccessory end

	-- AccessoryBlob: posicao/rotacao/escala customizada dos acessorios
	if desc.AccessoryBlob and desc.AccessoryBlob ~= "" then
		pcall(function()
			hd.AccessoryBlob = desc.AccessoryBlob
		end)
	end

	-- Accessories (via SetAccessories)
	-- Rigidos: apenas AssetId + AccessoryType
	-- Layered: IsLayered=true + Order + Puffiness
	if desc.Accessories and #desc.Accessories > 0 then
		local accList = {}
		for _, acc in desc.Accessories do
			local accType = ACCESSORY_TYPE_MAP[acc.AccessoryType]
			if accType then
				local entry: any = {
					AssetId = acc.AssetId,
					AccessoryType = accType,
				}
				if acc.IsLayered then
					entry.IsLayered = true
					entry.Order = acc.Order or 0
					if acc.Puffiness then
						entry.Puffiness = acc.Puffiness
					end
				end
				table.insert(accList, entry)
			end
		end
		pcall(function()
			(hd :: HumanoidDescription):SetAccessories(accList, true)
		end)
	end

	-- AccessoryDescriptions: aplica Position/Rotation/Scale customizado
	-- Esses ajustes vem do Avatar Editor e sao a forma oficial do Roblox
	-- de persistir posicao/rotacao/escala de acessorios
	if desc.AccessoryDescriptions and #desc.AccessoryDescriptions > 0 then
		-- Monta mapa AssetId → ajuste pra busca rapida
		local adjMap: { [number]: any } = {}
		for _, adj in desc.AccessoryDescriptions do
			adjMap[adj.AssetId] = adj
		end

		-- Percorre AccessoryDescription children que o engine criou
		-- (existem apos SetAccessories ou legacy properties)
		for _, child in hd:GetChildren() do
			if child:IsA("AccessoryDescription") then
				local adj = adjMap[child.AssetId]
				if adj then
					if adj.Position then
						child.Position = Vector3.new(adj.Position[1], adj.Position[2], adj.Position[3])
					end
					if adj.Rotation then
						child.Rotation = Vector3.new(adj.Rotation[1], adj.Rotation[2], adj.Rotation[3])
					end
					if adj.Scale then
						child.Scale = Vector3.new(adj.Scale[1], adj.Scale[2], adj.Scale[3])
					end
				end
			end
		end
	end

	-- Emotes e EquippedEmotes ignorados: nao servem pra rig estatico
	-- e ocupam ~80% do tamanho do JSON

	return hd
end

-- ════════════════════════════════════════════════════════════════
-- Parse JSON string — detecta formato automaticamente
-- Retorna: "single", rigData  OU  "batch", {rigData, ...}
-- ════════════════════════════════════════════════════════════════
function JsonRigService.parseJson(jsonString: string): (string?, any, string?)
	local ok, data = pcall(function()
		return HttpService:JSONDecode(jsonString)
	end)

	if not ok or not data then
		return nil, nil, "JSON invalido"
	end

	-- Formato AllPlayers: tem campo "rigs" com array
	if data.rigs and type(data.rigs) == "table" then
		return "batch", data.rigs, nil
	end

	-- Formato 1Player: tem campo "description" direto
	if data.description and type(data.description) == "table" then
		return "single", data, nil
	end

	return nil, nil, "Formato JSON nao reconhecido"
end

-- ════════════════════════════════════════════════════════════════
-- Aplica transforms dos acessorios capturados pelo scanner
-- Match por AttName + ordem. Recalcula CFrame do Handle
-- manualmente porque partes ancoradas nao respondem a constraints.
-- Formula: Handle.CFrame = BodyPart.CFrame * BodyAtt.CFrame * HandleAtt.CFrame:Inverse()
-- ════════════════════════════════════════════════════════════════
local function aplicarAccessoryTransforms(model: Model, transforms: { any })
	if not transforms or #transforms == 0 then return end

	-- Agrupa transforms por AttName com indice de consumo
	local groups: { [string]: { list: { any }, next: number } } = {}
	for _, tf in transforms do
		local key = tf.AttName
		if not groups[key] then
			groups[key] = { list = {}, next = 1 }
		end
		table.insert(groups[key].list, tf)
	end

	-- Pre-coleta todos attachments do body (nao-Handle) pra busca rapida
	local bodyAttachments: { [string]: Attachment } = {}
	for _, desc in model:GetDescendants() do
		if desc:IsA("Attachment") and desc.Parent and desc.Parent:IsA("BasePart") then
			-- So pega attachments que NAO estao dentro de Handles de acessorios
			local parent = desc.Parent
			local isHandle = parent.Name == "Handle" and parent.Parent and parent.Parent:IsA("Accessory")
			if not isHandle then
				bodyAttachments[desc.Name] = desc
			end
		end
	end

	local aplicados = 0

	for _, child in model:GetChildren() do
		if child:IsA("Accessory") then
			local handle = child:FindFirstChild("Handle")
			if handle then
				for _, att in handle:GetChildren() do
					if att:IsA("Attachment") and not att.Name:match("^Rig") then
						local group = groups[att.Name]
						if group and group.next <= #group.list then
							local tf = group.list[group.next]
							group.next += 1

							-- Novo CFrame do attachment no Handle
							local p = tf.Pos
							local r = tf.Rot
							local newAttCFrame = CFrame.new(p.X, p.Y, p.Z)
								* CFrame.fromOrientation(r.RX, r.RY, r.RZ)
							att.CFrame = newAttCFrame

							-- Recalcula posicao do Handle (partes ancoradas nao movem via weld)
							local bodyAtt = bodyAttachments[att.Name]
							if bodyAtt and bodyAtt.Parent then
								local bodyPart = bodyAtt.Parent
								handle.CFrame = bodyPart.CFrame * bodyAtt.CFrame * newAttCFrame:Inverse()
							end

							-- Aplica scale uniforme se diferente de 1
							if tf.Scale and tf.Scale ~= 1 then
								pcall(function()
									local mesh = handle:FindFirstChildOfClass("SpecialMesh")
									if mesh then
										mesh.Scale = Vector3.new(tf.Scale, tf.Scale, tf.Scale)
									end
								end)
							end

							aplicados += 1
						end
						break
					end
				end
			end
		end
	end

	print("[vulpy-rig-kit] AccessoryTransforms aplicados:", aplicados, "de", #transforms)
end

-- ════════════════════════════════════════════════════════════════
-- Cria 1 rig a partir de dados JSON de 1 player
-- Reconstroi HumanoidDescription do JSON capturado pelo scanner.
-- ════════════════════════════════════════════════════════════════
function JsonRigService.criarRigDeJson(rigData: any, rigName: string, parent: Instance): (Model?, string?)
	if not rigData or not rigData.description then
		return nil, "Dados de description ausentes"
	end

	local description = JsonRigService.buildDescription(rigData.description)
	local model = RigCreatorService.createModelFromDescription(description, rigName, parent)
	description:Destroy()

	if not model then
		return nil, "Falha ao criar model do JSON"
	end

	-- Aplica posicao/rotacao customizada dos acessorios
	if rigData.description.AccessoryTransforms then
		aplicarAccessoryTransforms(model, rigData.description.AccessoryTransforms)
	end

	print("[vulpy-rig-kit] JSON RIG criado:", rigName)
	return model, nil
end

-- ════════════════════════════════════════════════════════════════
-- Cria todos os rigs de um batch JSON
-- Coloca numa Folder, grid de 10 colunas
-- Retorna: Folder, quantos criados, quantos falharam
-- ════════════════════════════════════════════════════════════════
function JsonRigService.criarRigsBatch(
	rigsData: { any },
	parent: Instance,
	onProgress: ((current: number, total: number) -> ())?
): (Folder, number, number)
	local folder = Instance.new("Folder")
	folder.Name = "JsonRigs"
	folder.Parent = parent

	local criados = 0
	local falhas = 0
	local total = #rigsData

	for i, rigData in rigsData do
		local rigName = string.format("%03d", i)
		if rigData.name then
			rigName = rigName .. "_" .. rigData.name
		end

		local model, err = JsonRigService.criarRigDeJson(rigData, rigName, folder)

		if model then
			-- Posiciona no grid: 10 colunas (X), linhas (Z)
			local col = (i - 1) % GRID_COLUMNS
			local row = math.floor((i - 1) / GRID_COLUMNS)
			local posX = col * GRID_SPACING_X
			local posZ = row * GRID_SPACING_Z
			model:PivotTo(CFrame.new(posX, 3, posZ))

			criados += 1
		else
			warn("[vulpy-rig-kit] JSON batch falha no rig", i, ":", err)
			falhas += 1
		end

		-- Callback de progresso
		if onProgress then
			onProgress(i, total)
		end
	end

	print("[vulpy-rig-kit] JSON batch concluido:", criados, "criados,", falhas, "falhas")
	return folder, criados, falhas
end

return JsonRigService
