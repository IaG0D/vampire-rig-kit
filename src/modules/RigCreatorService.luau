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
function RigCreatorService.criarRig(input: string, rigName: string, parent: Instance, animationId: string?): (Model?, string?)
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

	return RigCreatorService.criarRigDeUserId(userId, rigName, parent, animationId)
end

return RigCreatorService
