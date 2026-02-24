--[[
	vulpy-rig-kit | AlignService
	Logica de alinhamento dos rigs sobre os pedestais.
	Calcula posicoes usando bounding box e pivots para centralizar
	cada rig no topo do seu pedestal correspondente.
]]

local AlignService = {}

-- ════════════════════════════════════════════════════════════════
-- Retorna a posicao do centro do topo de um pedestal
-- ════════════════════════════════════════════════════════════════
function AlignService.getTopoPedestal(pedestal: Model | BasePart): Vector3
	if pedestal:IsA("BasePart") then
		return pedestal.Position + Vector3.new(0, pedestal.Size.Y / 2, 0)
	end

	-- Model: usar bounding box
	local cf, size = pedestal:GetBoundingBox()
	return Vector3.new(cf.Position.X, cf.Position.Y + size.Y / 2, cf.Position.Z)
end

-- ════════════════════════════════════════════════════════════════
-- Calcula a distancia do pivot do rig ate o fundo do bounding box
-- ════════════════════════════════════════════════════════════════
function AlignService.getPivotToFundo(rig: Model): number
	local cf, size = rig:GetBoundingBox()
	local fundoY = cf.Position.Y - size.Y / 2
	local pivotY = rig:GetPivot().Position.Y
	return pivotY - fundoY
end

-- ════════════════════════════════════════════════════════════════
-- Alinha um unico rig no topo de um pedestal
-- Preserva a rotacao original do rig
-- ════════════════════════════════════════════════════════════════
function AlignService.alinharRigAoPedestal(rig: Model, pedestal: Model | BasePart, offset: Vector3): boolean
	local success, err = pcall(function()
		local topoPos = AlignService.getTopoPedestal(pedestal)
		local pivotToFundo = AlignService.getPivotToFundo(rig)

		local targetPos = Vector3.new(
			topoPos.X + offset.X,
			topoPos.Y + pivotToFundo + offset.Y,
			topoPos.Z + offset.Z
		)

		-- Preservar rotacao atual do rig
		local rigRotation = rig:GetPivot().Rotation
		rig:PivotTo(CFrame.new(targetPos) * rigRotation)
	end)

	if not success then
		warn("[vulpy-rig-kit] AlignService: Falha ao alinhar", rig.Name, "-", err)
	end

	return success
end

-- ════════════════════════════════════════════════════════════════
-- Alinha todos os pares rig/pedestal por indice
-- rig[1] → pedestal[1], rig[2] → pedestal[2], ...
-- Retorna (quantidade de sucessos, total de pares)
-- ════════════════════════════════════════════════════════════════
function AlignService.alinharTodos(rigs: { Model }, pedestais: { Model | BasePart }, offset: Vector3): (number, number)
	local total = math.min(#rigs, #pedestais)
	local sucessos = 0

	if #rigs ~= #pedestais then
		warn(string.format(
			"[vulpy-rig-kit] AlignService: Quantidade diferente - %d rigs, %d pedestais. Alinhando %d pares.",
			#rigs, #pedestais, total
		))
	end

	for i = 1, total do
		local rig = rigs[i]
		local pedestal = pedestais[i]

		-- Verificar se os objetos ainda existem no workspace
		if not rig.Parent then
			warn("[vulpy-rig-kit] AlignService: Rig removido -", rig.Name)
			continue
		end
		if not pedestal.Parent then
			warn("[vulpy-rig-kit] AlignService: Pedestal removido -", pedestal.Name)
			continue
		end

		if AlignService.alinharRigAoPedestal(rig, pedestal, offset) then
			sucessos += 1
		end
	end

	return sucessos, total
end

return AlignService
