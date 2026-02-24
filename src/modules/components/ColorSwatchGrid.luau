--[[
	vulpy-rig-kit | ColorSwatchGrid
	Grid de swatches de cores pre-definidas + input hex + seletor de body part.
]]

local UIHelpers = require(script.Parent.Parent.UIHelpers)
local COLORS = UIHelpers.COLORS

local ColorSwatchGrid = {}

-- Paleta de cores de pele comuns
local SKIN_PRESETS = {
	Color3.fromRGB(255, 204, 153),
	Color3.fromRGB(234, 184, 146),
	Color3.fromRGB(210, 160, 120),
	Color3.fromRGB(180, 130, 90),
	Color3.fromRGB(150, 100, 60),
	Color3.fromRGB(120, 75, 40),
	Color3.fromRGB(90, 55, 30),
	Color3.fromRGB(60, 35, 20),
	-- Cores extras
	Color3.fromRGB(255, 255, 255),
	Color3.fromRGB(200, 200, 200),
	Color3.fromRGB(255, 0, 0),
	Color3.fromRGB(0, 150, 255),
	Color3.fromRGB(0, 200, 0),
	Color3.fromRGB(255, 200, 0),
	Color3.fromRGB(200, 0, 200),
	Color3.fromRGB(0, 0, 0),
}

local BODY_PARTS = {
	{ key = "All", label = "Tudo" },
	{ key = "Head", label = "Cabeca" },
	{ key = "Torso", label = "Torso" },
	{ key = "LeftArm", label = "Br.Esq" },
	{ key = "RightArm", label = "Br.Dir" },
	{ key = "LeftLeg", label = "Pn.Esq" },
	{ key = "RightLeg", label = "Pn.Dir" },
}

-- Mapeia key para propriedade do HumanoidDescription
local KEY_TO_PROPS = {
	All = { "HeadColor", "TorsoColor", "LeftArmColor", "RightArmColor", "LeftLegColor", "RightLegColor" },
	Head = { "HeadColor" },
	Torso = { "TorsoColor" },
	LeftArm = { "LeftArmColor" },
	RightArm = { "RightArmColor" },
	LeftLeg = { "LeftLegColor" },
	RightLeg = { "RightLegColor" },
}

function ColorSwatchGrid.create(parent: GuiObject, props: {
	onColorSelected: (string, Color3) -> (), -- (bodyPartKey, color)
	layoutOrder: number?,
})
	local container = Instance.new("Frame")
	container.Name = "ColorSwatchGrid"
	container.Size = UDim2.new(1, 0, 0, 230)
	container.BackgroundTransparency = 1
	container.LayoutOrder = props.layoutOrder or 0
	container.Parent = parent

	local mainLayout = Instance.new("UIListLayout")
	mainLayout.Padding = UDim.new(0, 6)
	mainLayout.Parent = container

	-- Body part selector
	UIHelpers.criarLabel(container, {
		text = "Parte do Corpo",
		size = UDim2.new(1, 0, 0, 14),
		color = COLORS.textDim,
		textSize = 11,
		bold = true,
	})

	local bodyPartFrame = Instance.new("Frame")
	bodyPartFrame.Name = "BodyParts"
	bodyPartFrame.Size = UDim2.new(1, 0, 0, 48)
	bodyPartFrame.BackgroundTransparency = 1
	bodyPartFrame.Parent = container

	local bodyPartGrid = Instance.new("UIGridLayout")
	bodyPartGrid.CellSize = UDim2.new(0, 52, 0, 22)
	bodyPartGrid.CellPadding = UDim2.new(0, 4, 0, 4)
	bodyPartGrid.Parent = bodyPartFrame

	local selectedBodyPart = "All"
	local bodyPartButtons: { [string]: TextButton } = {}

	local function updateBodyPartStyles()
		for key, btn in bodyPartButtons do
			local isActive = key == selectedBodyPart
			UIHelpers.tweenProperty(btn, {
				BackgroundColor3 = if isActive then COLORS.primary else COLORS.surface,
			}, 0.1)
		end
	end

	for _, part in BODY_PARTS do
		local btn = Instance.new("TextButton")
		btn.Name = part.key
		btn.Size = UDim2.new(0, 52, 0, 22)
		btn.BackgroundColor3 = if part.key == "All" then COLORS.primary else COLORS.surface
		btn.Text = part.label
		btn.TextColor3 = COLORS.text
		btn.TextSize = 9
		btn.Font = Enum.Font.GothamBold
		btn.AutoButtonColor = true
		btn.Parent = bodyPartFrame
		UIHelpers.criarCorner(btn, 6)

		bodyPartButtons[part.key] = btn

		btn.MouseButton1Click:Connect(function()
			selectedBodyPart = part.key
			updateBodyPartStyles()
		end)
	end

	-- Separador
	UIHelpers.criarSeparador(container)

	-- Swatches
	UIHelpers.criarLabel(container, {
		text = "Cores Rapidas",
		size = UDim2.new(1, 0, 0, 14),
		color = COLORS.textDim,
		textSize = 11,
		bold = true,
	})

	local swatchFrame = Instance.new("Frame")
	swatchFrame.Name = "Swatches"
	swatchFrame.Size = UDim2.new(1, 0, 0, 68)
	swatchFrame.BackgroundTransparency = 1
	swatchFrame.Parent = container

	local swatchGrid = Instance.new("UIGridLayout")
	swatchGrid.CellSize = UDim2.new(0, 28, 0, 28)
	swatchGrid.CellPadding = UDim2.new(0, 6, 0, 6)
	swatchGrid.Parent = swatchFrame

	local selectedSwatchStroke: UIStroke? = nil

	for i, color in SKIN_PRESETS do
		local swatch = Instance.new("TextButton")
		swatch.Name = "Swatch_" .. i
		swatch.Size = UDim2.new(0, 28, 0, 28)
		swatch.BackgroundColor3 = color
		swatch.Text = ""
		swatch.AutoButtonColor = false
		swatch.Parent = swatchFrame

		UIHelpers.criarCorner(swatch, 14)
		local swStroke = UIHelpers.criarStroke(swatch, Color3.new(1, 1, 1), 2)
		swStroke.Transparency = 1

		swatch.MouseEnter:Connect(function()
			if swStroke.Transparency > 0.5 then
				UIHelpers.tweenProperty(swStroke, { Transparency = 0.5 }, 0.1)
			end
		end)

		swatch.MouseLeave:Connect(function()
			if selectedSwatchStroke ~= swStroke then
				UIHelpers.tweenProperty(swStroke, { Transparency = 1 }, 0.1)
			end
		end)

		swatch.MouseButton1Click:Connect(function()
			-- Deseleciona anterior
			if selectedSwatchStroke then
				UIHelpers.tweenProperty(selectedSwatchStroke, { Transparency = 1 }, 0.1)
			end
			selectedSwatchStroke = swStroke
			UIHelpers.tweenProperty(swStroke, { Transparency = 0 }, 0.1)

			-- Notifica
			if props.onColorSelected then
				props.onColorSelected(selectedBodyPart, color)
			end
		end)
	end

	-- Hex input
	UIHelpers.criarSeparador(container)

	local hexRow = Instance.new("Frame")
	hexRow.Name = "HexRow"
	hexRow.Size = UDim2.new(1, 0, 0, 30)
	hexRow.BackgroundTransparency = 1
	hexRow.Parent = container

	local hexLayout = Instance.new("UIListLayout")
	hexLayout.FillDirection = Enum.FillDirection.Horizontal
	hexLayout.Padding = UDim.new(0, 6)
	hexLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	hexLayout.Parent = hexRow

	local hexInput = UIHelpers.criarInput(hexRow, {
		size = UDim2.new(1, -80, 1, 0),
		placeholder = "#FFFFFF",
	})

	local hexApplyBtn = UIHelpers.criarBotao(hexRow, {
		text = "Aplicar",
		size = UDim2.new(0, 74, 1, 0),
		color = COLORS.primary,
	})
	hexApplyBtn.Font = Enum.Font.GothamBold
	hexApplyBtn.TextSize = 11

	hexApplyBtn.MouseButton1Click:Connect(function()
		local hex = hexInput.Text:gsub("#", "")
		if #hex ~= 6 then return end
		local r = tonumber(hex:sub(1, 2), 16)
		local g = tonumber(hex:sub(3, 4), 16)
		local b = tonumber(hex:sub(5, 6), 16)
		if not r or not g or not b then return end

		local color = Color3.fromRGB(r, g, b)
		if props.onColorSelected then
			props.onColorSelected(selectedBodyPart, color)
		end
	end)

	-- API
	local api = {}

	function api.getContainer()
		return container
	end

	function api.getSelectedBodyPart(): string
		return selectedBodyPart
	end

	api.KEY_TO_PROPS = KEY_TO_PROPS

	function api.destroy()
		container:Destroy()
	end

	return api
end

return ColorSwatchGrid
