--[[
	vulpy-rig-kit | RigPreview
	ViewportFrame 3D preview do rig com drag-to-rotate.
	Funciona dentro de DockWidgetPluginGui (Studio plugin).

	Usa manipulacao direta de parts para preview em tempo real
	(ApplyDescription nao funciona em ViewportFrame).
]]

local UIHelpers = require(script.Parent.Parent.UIHelpers)
local COLORS = UIHelpers.COLORS

-- Mapa de partes R15 para cores
local BODY_COLOR_MAP = {
	HeadColor = { "Head" },
	TorsoColor = { "UpperTorso", "LowerTorso" },
	LeftArmColor = { "LeftUpperArm", "LeftLowerArm", "LeftHand" },
	RightArmColor = { "RightUpperArm", "RightLowerArm", "RightHand" },
	LeftLegColor = { "LeftUpperLeg", "LeftLowerLeg", "LeftFoot" },
	RightLegColor = { "RightUpperLeg", "RightLowerLeg", "RightFoot" },
}

-- Mapa de escala
local SCALE_MAP = {
	HeightScale = "BodyHeightScale",
	WidthScale = "BodyWidthScale",
	HeadScale = "HeadScale",
	ProportionScale = "BodyProportionScale",
}

local RigPreview = {}

function RigPreview.create(parent: GuiObject, props: {
	height: number?,
	layoutOrder: number?,
})
	local height = props.height or 180

	local container = Instance.new("Frame")
	container.Name = "RigPreview"
	container.Size = UDim2.new(1, 0, 0, height)
	container.BackgroundColor3 = COLORS.input
	container.LayoutOrder = props.layoutOrder or 99
	container.ClipsDescendants = true
	container.Parent = parent

	UIHelpers.criarCorner(container, 8)

	-- Label
	local previewLabel = UIHelpers.criarLabel(container, {
		text = "Preview 3D",
		size = UDim2.new(1, 0, 0, 16),
		textSize = 10,
		color = COLORS.textDim,
		bold = true,
	})
	previewLabel.TextXAlignment = Enum.TextXAlignment.Center
	previewLabel.Position = UDim2.new(0, 0, 0, 4)

	-- Viewport
	local viewport = Instance.new("ViewportFrame")
	viewport.Name = "Viewport"
	viewport.Size = UDim2.new(1, 0, 1, -20)
	viewport.Position = UDim2.new(0, 0, 0, 20)
	viewport.BackgroundTransparency = 1
	viewport.Parent = container

	local worldModel = Instance.new("WorldModel")
	worldModel.Parent = viewport

	local camera = Instance.new("Camera")
	camera.FieldOfView = 40 -- FOV menor = menos distorcao, mostra avatar completo
	camera.Parent = viewport
	viewport.CurrentCamera = camera

	local light = Instance.new("PointLight")
	light.Brightness = 2
	light.Range = 30
	light.Parent = camera

	-- Estado
	local rigClone: Model? = nil
	local angle = 0
	local cameraDistance = 10
	local lookAtCenter = Vector3.new(0, 0, 0)

	-- Drag overlay
	local overlay = Instance.new("TextButton")
	overlay.Name = "DragOverlay"
	overlay.Size = UDim2.new(1, 0, 1, 0)
	overlay.BackgroundTransparency = 1
	overlay.Text = ""
	overlay.Parent = viewport

	-- Empty state label
	local emptyLabel = UIHelpers.criarLabel(container, {
		text = "Selecione um rig",
		size = UDim2.new(1, 0, 0, 20),
		textSize = 11,
		color = COLORS.textDim,
	})
	emptyLabel.TextXAlignment = Enum.TextXAlignment.Center
	emptyLabel.Position = UDim2.new(0, 0, 0.5, -10)

	local function updateCamera()
		if not rigClone then return end

		local offset = CFrame.Angles(0, math.rad(angle), 0) * Vector3.new(0, 0, cameraDistance)
		local cameraPos = lookAtCenter + offset + Vector3.new(0, cameraDistance * 0.05, 0)
		camera.CFrame = CFrame.lookAt(cameraPos, lookAtCenter)
	end

	-- Drag to rotate
	local isDragging = false
	local lastMouseX = 0

	overlay.MouseButton1Down:Connect(function(x)
		isDragging = true
		lastMouseX = x
	end)

	overlay.InputChanged:Connect(function(input)
		if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position.X - lastMouseX
			lastMouseX = input.Position.X
			angle = angle - delta * 0.5
			updateCamera()
		end
	end)

	overlay.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			isDragging = false
		end
	end)

	-- API
	local api = {}

	function api.setRig(rig: Model?)
		-- Limpa clone anterior
		if rigClone then
			rigClone:Destroy()
			rigClone = nil
		end

		if not rig then
			emptyLabel.Visible = true
			return
		end

		emptyLabel.Visible = false

		-- Clona o rig para o viewport
		local success, clone = pcall(function()
			return rig:Clone()
		end)

		if not success or not clone then
			emptyLabel.Visible = true
			return
		end

		-- Parenta ao worldmodel primeiro para GetBoundingBox funcionar
		clone.Parent = worldModel
		local boundsCF, size = clone:GetBoundingBox()

		-- Centro do bounding box
		local bbCenter = boundsCF.Position

		-- Move o clone para que o centro do bounding box fique na origem
		local pivotCF = clone:GetPivot()
		local offsetVec = bbCenter - pivotCF.Position
		clone:PivotTo(CFrame.new(-offsetVec.X, -offsetVec.Y, -offsetVec.Z))

		-- Recalcula centro apos mover
		local newBoundsCF, _ = clone:GetBoundingBox()
		lookAtCenter = newBoundsCF.Position

		rigClone = clone

		-- Camera distance: mais longe para ver avatar completo com acessorios
		cameraDistance = math.max(size.Y * 1.8, size.Magnitude * 1.1, 8)

		angle = 180
		updateCamera()
	end

	-- ══════════════════════════════════════════════════
	-- Manipulacao direta para preview em tempo real
	-- ══════════════════════════════════════════════════

	-- Helper: encontra o Weld que conecta Handle ao corpo (mesmo do AdjustService)
	local function findCloneWeld(handle: BasePart): Weld?
		local weld = handle:FindFirstChild("AccessoryWeld")
		if weld and weld:IsA("Weld") then return weld end
		for _, child in handle:GetChildren() do
			if child:IsA("Weld") then return child end
		end
		local acc = handle.Parent
		if acc then
			for _, child in acc:GetChildren() do
				if child:IsA("Weld") then return child end
			end
		end
		return nil
	end

	-- Helper: guarda/recupera o C1 original do weld
	local function getCloneOrigC1(weld: Weld): CFrame
		local store = weld:FindFirstChild("_OrigC1")
		if store and store:IsA("CFrameValue") then return store.Value end
		local cfValue = Instance.new("CFrameValue")
		cfValue.Name = "_OrigC1"
		cfValue.Value = weld.C1
		cfValue.Parent = weld
		return weld.C1
	end

	-- Aplica ajuste de acessorio direto no clone via Weld.C1
	function api.applyAccessoryAdjust(accInstance: Instance?, position: Vector3, rotation: Vector3, scale: Vector3)
		if not rigClone or not accInstance then return end

		-- Encontra o Accessory correspondente no CLONE (nao no original)
		local cloneAcc = rigClone:FindFirstChild(accInstance.Name)
		if not cloneAcc or not cloneAcc:IsA("Accessory") then
			for _, child in rigClone:GetChildren() do
				if child:IsA("Accessory") and child.Name == accInstance.Name then
					cloneAcc = child
					break
				end
			end
		end

		if not cloneAcc then return end

		local handle = cloneAcc:FindFirstChild("Handle")
		if not handle or not handle:IsA("BasePart") then return end

		-- Modifica offset via Weld.C1 + recalcula CFrame (ViewportFrame nao tem fisica)
		local weld = findCloneWeld(handle)
		if weld then
			local origC1 = getCloneOrigC1(weld)
			local posOffset = CFrame.new(-position)
			local rotOffset = CFrame.Angles(
				-math.rad(rotation.X),
				-math.rad(rotation.Y),
				-math.rad(rotation.Z)
			)
			local newC1 = origC1 * posOffset * rotOffset
			weld.C1 = newC1

			-- Recalcula CFrame do Handle (sem fisica no ViewportFrame)
			local part1 = weld.Part1
			if part1 then
				handle.CFrame = part1.CFrame * newC1 * weld.C0:Inverse()
			end
		end

		-- Modifica escala via SpecialMesh
		local mesh = handle:FindFirstChildOfClass("SpecialMesh")
		if mesh then
			mesh.Scale = scale
		end
	end

	-- Aplica cores direto no clone (BasePart.Color)
	function api.applyColors(colors: { [string]: Color3 })
		if not rigClone then return end

		-- BodyColors
		local bc = rigClone:FindFirstChildOfClass("BodyColors")
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
				end
			end
		end

		-- BaseParts direto
		for colorKey, color in colors do
			local partNames = BODY_COLOR_MAP[colorKey]
			if partNames then
				for _, partName in partNames do
					local part = rigClone:FindFirstChild(partName)
					if part and part:IsA("BasePart") then
						part.Color = color
					end
				end
			end
		end
	end

	-- Aplica proporcoes direto no clone (NumberValues no Humanoid)
	function api.applyProportions(proportions: { [string]: number })
		if not rigClone then return end
		local humanoid = rigClone:FindFirstChildOfClass("Humanoid")
		if not humanoid then return end

		for descKey, value in proportions do
			local valueName = SCALE_MAP[descKey]
			if valueName then
				local scaleValue = humanoid:FindFirstChild(valueName)
				if scaleValue and scaleValue:IsA("NumberValue") then
					scaleValue.Value = value
				end
			end
		end
	end

	function api.getClone(): Model?
		return rigClone
	end

	function api.refresh()
		if rigClone then
			updateCamera()
		end
	end

	function api.getContainer()
		return container
	end

	function api.destroy()
		if rigClone then
			rigClone:Destroy()
			rigClone = nil
		end
		container:Destroy()
	end

	return api
end

return RigPreview
