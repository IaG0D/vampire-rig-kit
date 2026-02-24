--[[
	vulpy-rig-kit | RigCreatorService
	Cria RIGs a partir de userId ou username diretamente no Studio.
	Adaptado do RigCreatorService do vulpy-avatar-catalog.
	O model fica ancorado, limpo de scripts, pronto pra uso no mapa.
]]

local Players = game:GetService("Players")
local InsertService = game:GetService("InsertService")

local RigCreatorService = {}

-- ════════════════════════════════════════════════════════════════
-- Limpa um model para funcionar como RIG estatico
-- Humanoid e mantido (necessario para roupas/acessorios renderizarem)
-- ════════════════════════════════════════════════════════════════
local function cleanupClone(model: Model)
	for _, desc in model:GetDescendants() do
		if desc:IsA("BaseScript") then
			desc:Destroy()
		end
	end

	local animate = model:FindFirstChild("Animate")
	if animate then
		animate:Destroy()
	end

	local health = model:FindFirstChild("Health")
	if health then
		health:Destroy()
	end

	local humanoid = model:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		local animator = humanoid:FindFirstChildOfClass("Animator")
		if animator then
			animator:Destroy()
		end
	end

	-- Ancora todas as partes
	for _, part in model:GetDescendants() do
		if part:IsA("BasePart") then
			part.Anchored = true
		end
	end
end

-- ════════════════════════════════════════════════════════════════
-- Carrega e aplica uma animacao no rig (para pose de compra/dance)
-- ════════════════════════════════════════════════════════════════
local function aplicarAnimacao(model: Model, animationId: string)
	local humanoid = model:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	-- Cria Animator se nao existe
	local animator = humanoid:FindFirstChildOfClass("Animator")
	if not animator then
		animator = Instance.new("Animator")
		animator.Parent = humanoid
	end

	local anim = Instance.new("Animation")
	anim.AnimationId = animationId

	local success, track = pcall(function()
		return animator:LoadAnimation(anim)
	end)

	if success and track then
		track:Play()
		-- Pausa no frame 0 para ficar como pose estatica
		track:AdjustSpeed(0)
		track.TimePosition = 0
	end

	anim:Destroy()
end

-- ════════════════════════════════════════════════════════════════
-- Cria um model R15 a partir de HumanoidDescription
-- Posiciona, limpa e retorna o model pronto
-- ════════════════════════════════════════════════════════════════
local function createModelFromDescription(description: HumanoidDescription, rigName: string, parent: Instance): Model?
	local success, model = pcall(function()
		return Players:CreateHumanoidModelFromDescription(description, Enum.HumanoidRigType.R15)
	end)

	if not success or not model then
		warn("[vulpy-rig-kit] RigCreatorService: Falha ao criar model -", model)
		return nil
	end

	model.Name = rigName

	-- Ancora HumanoidRootPart antes de parentar
	local rootPart = model:FindFirstChild("HumanoidRootPart")
	if rootPart and rootPart:IsA("BasePart") then
		rootPart.Anchored = true
	end

	-- Posiciona underground temporariamente, parenta, espera assets carregarem
	model:PivotTo(CFrame.new(0, -500, 0))
	model.Parent = parent
	task.wait(1)

	-- Reaplica description para garantir acessorios
	local humanoid = model:FindFirstChildOfClass("Humanoid")
	if humanoid then
		pcall(function()
			(humanoid :: Humanoid):ApplyDescription(description)
		end)
		task.wait(1)
	end

	-- Reposiciona na origem e limpa
	model:PivotTo(CFrame.new(0, 3, 0))
	cleanupClone(model)

	return model
end

-- ════════════════════════════════════════════════════════════════
-- Cria um BillboardGui com o nome acima da cabeca do rig
-- ════════════════════════════════════════════════════════════════
function RigCreatorService.criarNameTag(model: Model, nomeExibicao: string)
	local head = model:FindFirstChild("Head")
	if not head or not head:IsA("BasePart") then return end

	-- Remove name tag existente se houver
	local existente = head:FindFirstChild("NameTag")
	if existente then existente:Destroy() end

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "NameTag"
	billboard.Adornee = head
	billboard.Size = UDim2.new(0, 200, 0, 40)
	billboard.StudsOffset = Vector3.new(0, 2, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = head

	local label = Instance.new("TextLabel")
	label.Name = "NameLabel"
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = nomeExibicao
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextStrokeTransparency = 0.5
	label.TextStrokeColor3 = Color3.new(0, 0, 0)
	label.TextSize = 16
	label.Font = Enum.Font.GothamBold
	label.TextScaled = false
	label.Parent = billboard
end

-- ════════════════════════════════════════════════════════════════
-- Atualiza a aparencia de um rig existente sem mudar Name ou posicao
-- Destroi o antigo e cria um novo no mesmo lugar com o mesmo nome
-- ════════════════════════════════════════════════════════════════
function RigCreatorService.atualizarRig(model: Model, userId: number, addNameTag: boolean, nomeTag: string?): (Model?, string?)
	-- Salva posicao e nome do rig atual
	local savedCFrame = model:GetPivot()
	local savedName = model.Name
	local savedParent = model.Parent or workspace

	-- Destroi o rig antigo
	model:Destroy()

	-- Cria um novo rig no lugar
	local novoModel, err = RigCreatorService.criarRigDeUserId(userId, savedName, savedParent)
	if not novoModel then
		return nil, err or "Falha ao criar novo model"
	end

	-- Reposiciona no mesmo lugar do antigo
	novoModel:PivotTo(savedCFrame)

	-- Name tag
	if addNameTag and nomeTag then
		RigCreatorService.criarNameTag(novoModel, nomeTag)
	end

	print("[vulpy-rig-kit] RIG atualizado:", savedName, "| userId:", userId)
	return novoModel, nil
end

-- ════════════════════════════════════════════════════════════════
-- Resolve username para userId via Players:GetUserIdFromNameAsync()
-- ════════════════════════════════════════════════════════════════
function RigCreatorService.resolverUserId(input: string): (number?, string?)
	-- Se for numero, usa direto como userId
	local numId = tonumber(input)
	if numId then
		return numId, nil
	end

	-- Tenta resolver username → userId
	local success, userId = pcall(function()
		return Players:GetUserIdFromNameAsync(input)
	end)

	if success and userId then
		return userId, nil
	end

	return nil, "Usuario nao encontrado: " .. input
end

-- ════════════════════════════════════════════════════════════════
-- Cria um RIG a partir de userId
-- Retorna o model criado ou nil + mensagem de erro
-- ════════════════════════════════════════════════════════════════
function RigCreatorService.criarRigDeUserId(userId: number, rigName: string, parent: Instance, animationId: string?): (Model?, string?)
	-- Busca HumanoidDescription do userId
	local description
	local ok = pcall(function()
		description = Players:GetHumanoidDescriptionFromUserId(userId)
	end)

	if not ok or not description then
		return nil, "Falha ao obter avatar do userId " .. tostring(userId)
	end

	local model = createModelFromDescription(description, rigName, parent)
	description:Destroy()

	if not model then
		return nil, "Falha ao criar model"
	end

	-- Aplica animacao se fornecida
	if animationId and animationId ~= "" then
		aplicarAnimacao(model, animationId)
	end

	print("[vulpy-rig-kit] RIG criado:", rigName, "| userId:", userId)
	return model, nil
end

-- ════════════════════════════════════════════════════════════════
-- Cria um RIG a partir de username ou userId (string input)
-- Wrapper conveniente que resolve automaticamente
-- ════════════════════════════════════════════════════════════════
function RigCreatorService.criarRig(input: string, rigName: string, parent: Instance, animationId: string?, addNameTag: boolean?): (Model?, string?)
	local userId, err = RigCreatorService.resolverUserId(input)
	if not userId then
		return nil, err
	end

	-- Se rigName estiver vazio, tenta usar o username
	if rigName == "" then
		local nameOk, name = pcall(function()
			return Players:GetNameFromUserIdAsync(userId)
		end)
		rigName = if nameOk and name then name else ("Rig_" .. tostring(userId))
	end

	local model, rigErr = RigCreatorService.criarRigDeUserId(userId, rigName, parent, animationId)

	if model and addNameTag then
		RigCreatorService.criarNameTag(model, rigName)
	end

	return model, rigErr
end

return RigCreatorService
