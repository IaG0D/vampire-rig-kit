--[[
	vulpy-rig-kit | AlignService
	Logica de alinhamento dos rigs sobre os pedestais.
	Calcula posicoes usando bounding box e pivots para centralizar
	cada rig no topo do seu pedestal correspondente.
]]

local AlignService = {}

-- ════════════════════════════════════════════════════════════════
-- Retorna a posicao do centro do topo de um pedestal
-- Suporta BasePart, Model (GetBoundingBox) e Folder (bounding box manual)
-- ════════════════════════════════════════════════════════════════
function AlignService.getTopoPedestal(pedestal: Model | BasePart | Folder): Vector3
	if pedestal:IsA("BasePart") then
		return pedestal.Position + Vector3.new(0, pedestal.Size.Y / 2, 0)
	end

	if pedestal:IsA("Model") then
		local cf, size = pedestal:GetBoundingBox()
		return Vector3.new(cf.Position.X, cf.Position.Y + size.Y / 2, cf.Position.Z)
	end

	-- Folder: calcula bounding box manual de todas as BaseParts dentro
	local minX, minY, minZ = math.huge, math.huge, math.huge
	local maxX, maxY, maxZ = -math.huge, -math.huge, -math.huge

	for _, desc in pedestal:GetDescendants() do
		if desc:IsA("BasePart") then
			local pos = desc.Position
			local half = desc.Size / 2
			minX = math.min(minX, pos.X - half.X)
			minY = math.min(minY, pos.Y - half.Y)
			minZ = math.min(minZ, pos.Z - half.Z)
			maxX = math.max(maxX, pos.X + half.X)
			maxY = math.max(maxY, pos.Y + half.Y)
			maxZ = math.max(maxZ, pos.Z + half.Z)
		end
	end

	-- Centro X/Z, topo Y
	return Vector3.new((minX + maxX) / 2, maxY, (minZ + maxZ) / 2)
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
function AlignService.alinharRigAoPedestal(rig: Model, pedestal: Model | BasePart | Folder, offset: Vector3, rotacaoY: number?): boolean
	local success, err = pcall(function()
		local topoPos = AlignService.getTopoPedestal(pedestal)
		local pivotToFundo = AlignService.getPivotToFundo(rig)

		local targetPos = Vector3.new(
			topoPos.X + offset.X,
			topoPos.Y + pivotToFundo + offset.Y,
			topoPos.Z + offset.Z
		)

		-- Aplicar rotacao Y (graus) no eixo do rig
		local rotY = math.rad(rotacaoY or 0)
		rig:PivotTo(CFrame.new(targetPos) * CFrame.Angles(0, rotY, 0))
	end)

	if not success then
		warn("[vulpy-rig-kit] AlignService: Falha ao alinhar", rig.Name, "-", err)
	end

	return success
end

-- ════════════════════════════════════════════════════════════════
-- Alinha rigs nos pedestais com suporte a agrupamento
-- rigsPorPedestal: 1=Solo, 2=Duo, 3=Trio
-- spread: espacamento lateral (studs) entre rigs do mesmo pedestal
-- ════════════════════════════════════════════════════════════════
function AlignService.alinharTodos(rigs: { Model }, pedestais: { Model | BasePart | Folder }, offset: Vector3, rotacaoY: number?, rigsPorPedestal: number?, spread: number?): (number, number)
	local modo = rigsPorPedestal or 1
	local espacamento = spread or 3
	local totalRigs = #rigs
	local sucessos = 0

	if modo == 1 then
		-- Solo: comportamento original 1:1
		local total = math.min(totalRigs, #pedestais)

		if totalRigs ~= #pedestais then
			warn(string.format(
				"[vulpy-rig-kit] AlignService: Quantidade diferente - %d rigs, %d pedestais. Alinhando %d pares.",
				totalRigs, #pedestais, total
			))
		end

		for i = 1, total do
			local rig = rigs[i]
			local pedestal = pedestais[i]

			if not rig.Parent then
				warn("[vulpy-rig-kit] AlignService: Rig removido -", rig.Name)
				continue
			end
			if not pedestal.Parent then
				warn("[vulpy-rig-kit] AlignService: Pedestal removido -", pedestal.Name)
				continue
			end

			if AlignService.alinharRigAoPedestal(rig, pedestal, offset, rotacaoY) then
				sucessos += 1
			end
		end

		return sucessos, total
	end

	-- Duo/Trio: agrupar N rigs por pedestal, distribuir lateralmente
	local rigIndex = 1

	for _, pedestal in pedestais do
		if rigIndex > totalRigs then break end
		if not pedestal.Parent then
			warn("[vulpy-rig-kit] AlignService: Pedestal removido -", pedestal.Name)
			continue
		end

		-- Quantos rigs cabem neste pedestal
		local rigsNesteGrupo = math.min(modo, totalRigs - rigIndex + 1)

		-- Calcular offsets laterais simetricos
		-- Duo: [-spread/2, +spread/2]
		-- Trio: [-spread, 0, +spread]
		for slot = 1, rigsNesteGrupo do
			local rig = rigs[rigIndex]
			if not rig.Parent then
				warn("[vulpy-rig-kit] AlignService: Rig removido -", rig.Name)
				rigIndex += 1
				continue
			end

			local lateralOffset = 0
			if rigsNesteGrupo > 1 then
				-- Distribui de -(total-1)/2 ate +(total-1)/2
				lateralOffset = ((slot - 1) - (rigsNesteGrupo - 1) / 2) * espacamento
			end

			local offsetComSpread = Vector3.new(
				offset.X + lateralOffset,
				offset.Y,
				offset.Z
			)

			if AlignService.alinharRigAoPedestal(rig, pedestal, offsetComSpread, rotacaoY) then
				sucessos += 1
			end

			rigIndex += 1
		end
	end

	return sucessos, totalRigs
end

return AlignService
