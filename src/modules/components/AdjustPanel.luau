--[[
	vulpy-rig-kit | AdjustPanel
	Painel visual completo de ajustes do rig.
	Tabs: Acessorios | Cores | Proporcoes + Preview 3D.
	Compoe Slider, ColorSwatchGrid, RigPreview.
]]

local ChangeHistoryService = game:GetService("ChangeHistoryService")
local Selection = game:GetService("Selection")

local UIHelpers = require(script.Parent.Parent.UIHelpers)
local AdjustService = require(script.Parent.Parent.AdjustService)
local Slider = require(script.Parent.Slider)
local ColorSwatchGrid = require(script.Parent.ColorSwatchGrid)
local RigPreview = require(script.Parent.RigPreview)

local COLORS = UIHelpers.COLORS
local AXIS_COLORS = UIHelpers.AXIS_COLORS

local AdjustPanel = {}

function AdjustPanel.create(parent: GuiObject, callbacks: {
	setStatus: (string) -> (),
	getRigSelecionado: () -> Model?,
})
	-- Container principal = ScrollingFrame que ocupa toda a pagina
	local container = Instance.new("ScrollingFrame")
	container.Name = "AdjustPanel"
	container.Size = UDim2.new(1, 0, 1, 0)
	container.BackgroundTransparency = 1
	container.BorderSizePixel = 0
	container.ScrollBarThickness = 4
	container.ScrollBarImageColor3 = COLORS.separator
	container.CanvasSize = UDim2.new(0, 0, 0, 0)
	container.AutomaticCanvasSize = Enum.AutomaticSize.Y
	container.Parent = parent

	local mainLayout = Instance.new("UIListLayout")
	mainLayout.Padding = UDim.new(0, 6)
	mainLayout.SortOrder = Enum.SortOrder.LayoutOrder
	mainLayout.Parent = container

	local mainPad = Instance.new("UIPadding")
	mainPad.PaddingTop = UDim.new(0, 10)
	mainPad.PaddingBottom = UDim.new(0, 10)
	mainPad.PaddingLeft = UDim.new(0, 12)
	mainPad.PaddingRight = UDim.new(0, 12)
	mainPad.Parent = container

	-- Titulo
	UIHelpers.criarLabel(container, {
		text = "Ajustes do Rig",
		size = UDim2.new(1, 0, 0, 20),
		bold = true,
		textSize = 15,
	}).LayoutOrder = 0

	local infoLabel = UIHelpers.criarLabel(container, {
		text = "Selecione 1 rig no workspace para ajustar",
		size = UDim2.new(1, 0, 0, 14),
		color = COLORS.textDim,
		textSize = 11,
	})
	infoLabel.LayoutOrder = 1

	-- ═══════════════════════════════════════════════════
	-- Preview 3D (no topo, sempre visivel)
	-- ═══════════════════════════════════════════════════
	local preview = RigPreview.create(container, {
		height = 200,
		layoutOrder = 2,
	})

	UIHelpers.criarSeparador(container).LayoutOrder = 3

	-- ═══════════════════════════════════════════════════
	-- Tab bar principal
	-- ═══════════════════════════════════════════════════
	local tabBar = Instance.new("Frame")
	tabBar.Name = "TabBar"
	tabBar.Size = UDim2.new(1, 0, 0, 30)
	tabBar.BackgroundTransparency = 1
	tabBar.LayoutOrder = 4
	tabBar.Parent = container

	local tabLayout = Instance.new("UIListLayout")
	tabLayout.FillDirection = Enum.FillDirection.Horizontal
	tabLayout.Padding = UDim.new(0, 4)
	tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	tabLayout.Parent = tabBar

	local TABS = {
		{ key = "accessories", label = "Acessorios" },
		{ key = "colors", label = "Cores" },
		{ key = "proportions", label = "Proporcoes" },
	}

	local activeTab = "accessories"
	local tabButtons: { [string]: TextButton } = {}
	local tabContents: { [string]: Frame } = {}

	local function createTabButton(tabKey: string, label: string): TextButton
		local btn = Instance.new("TextButton")
		btn.Name = "Tab_" .. tabKey
		btn.AutomaticSize = Enum.AutomaticSize.X
		btn.Size = UDim2.new(0, 0, 0, 28)
		btn.BackgroundColor3 = if tabKey == activeTab then COLORS.primary else COLORS.surface
		btn.Text = ""
		btn.AutoButtonColor = false
		btn.Parent = tabBar

		UIHelpers.criarCorner(btn, 8)

		local pad = Instance.new("UIPadding")
		pad.PaddingLeft = UDim.new(0, 14)
		pad.PaddingRight = UDim.new(0, 14)
		pad.Parent = btn

		local lbl = Instance.new("TextLabel")
		lbl.Name = "Label"
		lbl.AutomaticSize = Enum.AutomaticSize.X
		lbl.Size = UDim2.new(0, 0, 1, 0)
		lbl.BackgroundTransparency = 1
		lbl.Text = label
		lbl.TextColor3 = if tabKey == activeTab then Color3.new(1, 1, 1) else COLORS.textDim
		lbl.TextSize = 12
		lbl.Font = Enum.Font.GothamBold
		lbl.Parent = btn

		tabButtons[tabKey] = btn
		return btn
	end

	local function switchTab(tabKey: string)
		activeTab = tabKey
		for key, btn in tabButtons do
			local isActive = key == tabKey
			UIHelpers.tweenProperty(btn, {
				BackgroundColor3 = if isActive then COLORS.primary else COLORS.surface,
			}, 0.12)
			local lbl = btn:FindFirstChild("Label")
			if lbl then
				UIHelpers.tweenProperty(lbl, {
					TextColor3 = if isActive then Color3.new(1, 1, 1) else COLORS.textDim,
				}, 0.12)
			end
		end
		for key, content in tabContents do
			content.Visible = key == tabKey
		end
	end

	for _, tab in TABS do
		local btn = createTabButton(tab.key, tab.label)
		btn.MouseButton1Click:Connect(function()
			switchTab(tab.key)
		end)
	end

	-- ═══════════════════════════════════════════════════
	-- Accessories tab (Frame direto no scroll, nao nested)
	-- ═══════════════════════════════════════════════════
	local accTab = Instance.new("Frame")
	accTab.Name = "AccessoriesTab"
	accTab.Size = UDim2.new(1, 0, 0, 300)
	accTab.BackgroundTransparency = 1
	accTab.LayoutOrder = 5
	accTab.Parent = container

	local accLayout = Instance.new("UIListLayout")
	accLayout.Padding = UDim.new(0, 6)
	accLayout.Parent = accTab

	tabContents["accessories"] = accTab

	-- Acessory thumbnails (horizontal scroll)
	UIHelpers.criarLabel(accTab, {
		text = "Acessorios do Rig",
		size = UDim2.new(1, 0, 0, 14),
		color = COLORS.textDim,
		textSize = 11,
		bold = true,
	})

	local accThumbs = Instance.new("ScrollingFrame")
	accThumbs.Name = "AccThumbs"
	accThumbs.Size = UDim2.new(1, 0, 0, 54)
	accThumbs.BackgroundTransparency = 1
	accThumbs.ScrollBarThickness = 0
	accThumbs.ScrollingDirection = Enum.ScrollingDirection.X
	accThumbs.AutomaticCanvasSize = Enum.AutomaticSize.X
	accThumbs.CanvasSize = UDim2.new(0, 0, 0, 0)
	accThumbs.Parent = accTab

	local accThumbLayout = Instance.new("UIListLayout")
	accThumbLayout.FillDirection = Enum.FillDirection.Horizontal
	accThumbLayout.Padding = UDim.new(0, 6)
	accThumbLayout.Parent = accThumbs

	local noAccLabel = UIHelpers.criarLabel(accTab, {
		text = "Nenhum acessorio ajustavel",
		size = UDim2.new(1, 0, 0, 14),
		color = COLORS.textDim,
		textSize = 10,
	})

	-- Sub-tab bar: Mover | Rotacionar | Escalar
	local subTabBar = Instance.new("Frame")
	subTabBar.Name = "SubTabBar"
	subTabBar.Size = UDim2.new(1, 0, 0, 30)
	subTabBar.BackgroundColor3 = COLORS.surface
	subTabBar.Parent = accTab
	UIHelpers.criarCorner(subTabBar, 8)

	local subTabLayout = Instance.new("UIGridLayout")
	subTabLayout.CellSize = UDim2.new(1 / 3, -3, 0, 26)
	subTabLayout.CellPadding = UDim2.new(0, 2, 0, 0)
	subTabLayout.Parent = subTabBar

	local subTabPad = Instance.new("UIPadding")
	subTabPad.PaddingTop = UDim.new(0, 2)
	subTabPad.PaddingLeft = UDim.new(0, 2)
	subTabPad.Parent = subTabBar

	local SUB_TABS = {
		{ key = "move", label = "Mover" },
		{ key = "rotate", label = "Rotacionar" },
		{ key = "scale", label = "Escalar" },
	}

	local activeSubTab = "move"
	local subTabButtons: { [string]: TextButton } = {}
	local subTabContents: { [string]: Frame } = {}

	local function switchSubTab(subKey: string)
		activeSubTab = subKey
		for key, btn in subTabButtons do
			local isActive = key == subKey
			UIHelpers.tweenProperty(btn, {
				BackgroundColor3 = if isActive then COLORS.primary else COLORS.surface,
			}, 0.1)
			local lbl = btn:FindFirstChild("Label")
			if lbl then
				lbl.TextColor3 = if isActive then Color3.new(1, 1, 1) else COLORS.textDim
			end
		end
		for key, content in subTabContents do
			content.Visible = key == subKey
		end
	end

	for _, st in SUB_TABS do
		local btn = Instance.new("TextButton")
		btn.Name = "SubTab_" .. st.key
		btn.Size = UDim2.new(1 / 3, -3, 0, 26)
		btn.BackgroundColor3 = if st.key == "move" then COLORS.primary else COLORS.surface
		btn.Text = ""
		btn.AutoButtonColor = false
		btn.Parent = subTabBar
		UIHelpers.criarCorner(btn, 6)

		local lbl = Instance.new("TextLabel")
		lbl.Name = "Label"
		lbl.Size = UDim2.new(1, 0, 1, 0)
		lbl.BackgroundTransparency = 1
		lbl.Text = st.label
		lbl.TextColor3 = if st.key == "move" then Color3.new(1, 1, 1) else COLORS.textDim
		lbl.TextSize = 11
		lbl.Font = Enum.Font.GothamBold
		lbl.Parent = btn

		subTabButtons[st.key] = btn

		btn.MouseButton1Click:Connect(function()
			switchSubTab(st.key)
		end)
	end

	-- Slider containers
	local moveFrame = Instance.new("Frame")
	moveFrame.Name = "MoveSliders"
	moveFrame.Size = UDim2.new(1, 0, 0, 96)
	moveFrame.BackgroundTransparency = 1
	moveFrame.Visible = true
	moveFrame.Parent = accTab
	local moveLayout = Instance.new("UIListLayout")
	moveLayout.Padding = UDim.new(0, 4)
	moveLayout.Parent = moveFrame
	subTabContents["move"] = moveFrame

	local rotateFrame = Instance.new("Frame")
	rotateFrame.Name = "RotateSliders"
	rotateFrame.Size = UDim2.new(1, 0, 0, 96)
	rotateFrame.BackgroundTransparency = 1
	rotateFrame.Visible = false
	rotateFrame.Parent = accTab
	local rotateLayout = Instance.new("UIListLayout")
	rotateLayout.Padding = UDim.new(0, 4)
	rotateLayout.Parent = rotateFrame
	subTabContents["rotate"] = rotateFrame

	local scaleFrame = Instance.new("Frame")
	scaleFrame.Name = "ScaleSliders"
	scaleFrame.Size = UDim2.new(1, 0, 0, 36)
	scaleFrame.BackgroundTransparency = 1
	scaleFrame.Visible = false
	scaleFrame.Parent = accTab
	local scaleLayout = Instance.new("UIListLayout")
	scaleLayout.Padding = UDim.new(0, 4)
	scaleLayout.Parent = scaleFrame
	subTabContents["scale"] = scaleFrame

	-- Forward declarations
	local moveSliders
	local rotateSliders
	local scaleSlider

	-- Estado de acessorios (declarado cedo para uso nos callbacks)
	local selectedAssetId: number? = nil
	local selectedAccInstance: Instance? = nil -- referencia ao Accessory no rig original
	local accessoryList: { any } = {}
	local accThumbButtons: { Instance } = {}

	-- Funcao para aplicar ajuste de acessorio no preview em tempo real
	local function previewAccessoryAdjust()
		if not selectedAccInstance then return end
		if not moveSliders or not rotateSliders or not scaleSlider then return end
		preview.applyAccessoryAdjust(
			selectedAccInstance,
			Vector3.new(moveSliders.X.getValue(), moveSliders.Y.getValue(), moveSliders.Z.getValue()),
			Vector3.new(rotateSliders.X.getValue(), rotateSliders.Y.getValue(), rotateSliders.Z.getValue()),
			Vector3.new(scaleSlider.getValue(), scaleSlider.getValue(), scaleSlider.getValue())
		)
	end

	-- Sliders (com onChanged para preview em tempo real)
	moveSliders = {
		X = Slider.create(moveFrame, { axisName = "X", axisColor = AXIS_COLORS.X, min = -0.3, max = 0.3, step = 0.01, default = 0, format = "%.2f", layoutOrder = 1, onChanged = previewAccessoryAdjust }),
		Y = Slider.create(moveFrame, { axisName = "Y", axisColor = AXIS_COLORS.Y, min = -0.3, max = 0.3, step = 0.01, default = 0, format = "%.2f", layoutOrder = 2, onChanged = previewAccessoryAdjust }),
		Z = Slider.create(moveFrame, { axisName = "Z", axisColor = AXIS_COLORS.Z, min = -0.3, max = 0.3, step = 0.01, default = 0, format = "%.2f", layoutOrder = 3, onChanged = previewAccessoryAdjust }),
	}

	rotateSliders = {
		X = Slider.create(rotateFrame, { axisName = "X", axisColor = AXIS_COLORS.X, min = -30, max = 30, step = 1, default = 0, format = "%.0f", layoutOrder = 1, onChanged = previewAccessoryAdjust }),
		Y = Slider.create(rotateFrame, { axisName = "Y", axisColor = AXIS_COLORS.Y, min = -30, max = 30, step = 1, default = 0, format = "%.0f", layoutOrder = 2, onChanged = previewAccessoryAdjust }),
		Z = Slider.create(rotateFrame, { axisName = "Z", axisColor = AXIS_COLORS.Z, min = -30, max = 30, step = 1, default = 0, format = "%.0f", layoutOrder = 3, onChanged = previewAccessoryAdjust }),
	}

	scaleSlider = Slider.create(scaleFrame, { axisName = "S", axisColor = AXIS_COLORS.S, min = 0.75, max = 1.25, step = 0.01, default = 1, format = "%.2f", layoutOrder = 1, onChanged = previewAccessoryAdjust })

	-- Botao aplicar acessorios
	local applyAccBtn = UIHelpers.criarBotao(accTab, {
		text = "Aplicar Ajustes de Acessorio",
		size = UDim2.new(1, 0, 0, 32),
		color = COLORS.primary,
	})
	applyAccBtn.Font = Enum.Font.GothamBold
	applyAccBtn.TextSize = 13

	local function clearAccThumbs()
		for _, btn in accThumbButtons do
			btn:Destroy()
		end
		accThumbButtons = {}
	end

	local function selectAccessory(assetId: number)
		selectedAssetId = assetId
		selectedAccInstance = nil

		for _, acc in accessoryList do
			if acc.assetId == assetId then
				selectedAccInstance = acc.instance
				moveSliders.X.setValue(acc.position.X)
				moveSliders.Y.setValue(acc.position.Y)
				moveSliders.Z.setValue(acc.position.Z)
				rotateSliders.X.setValue(acc.rotation.X)
				rotateSliders.Y.setValue(acc.rotation.Y)
				rotateSliders.Z.setValue(acc.rotation.Z)
				scaleSlider.setValue(acc.scale.X)
				break
			end
		end

		for _, btn in accThumbButtons do
			local stroke = btn:FindFirstChildOfClass("UIStroke")
			if stroke then
				stroke.Transparency = if btn.Name == "Acc_" .. tostring(assetId) then 0 else 1
			end
		end
	end

	local function loadAccessories(rig: Model)
		clearAccThumbs()
		accessoryList = AdjustService.getAcessorios(rig)

		if #accessoryList == 0 then
			noAccLabel.Visible = true
			accThumbs.Visible = false
			return
		end

		noAccLabel.Visible = false
		accThumbs.Visible = true

		for i, acc in accessoryList do
			local btn = Instance.new("ImageButton")
			btn.Name = "Acc_" .. tostring(acc.assetId)
			btn.Size = UDim2.new(0, 48, 0, 48)
			btn.BackgroundColor3 = COLORS.cardBg
			btn.Image = "rbxthumb://type=Asset&id=" .. tostring(acc.assetId) .. "&w=150&h=150"
			btn.ScaleType = Enum.ScaleType.Fit
			btn.AutoButtonColor = true
			btn.LayoutOrder = i
			btn.Parent = accThumbs

			UIHelpers.criarCorner(btn, 8)
			local stroke = UIHelpers.criarStroke(btn, COLORS.primary, 2)
			stroke.Transparency = 1

			btn.MouseButton1Click:Connect(function()
				selectAccessory(acc.assetId)
			end)

			table.insert(accThumbButtons, btn)
		end

		if #accessoryList > 0 then
			selectAccessory(accessoryList[1].assetId)
		end
	end

	-- Aplicar ajustes de acessorio
	applyAccBtn.MouseButton1Click:Connect(function()
		local rig = callbacks.getRigSelecionado()
		if not rig then
			callbacks.setStatus("Selecione um rig (Model com Humanoid)!")
			return
		end
		if not selectedAssetId then
			callbacks.setStatus("Selecione um acessorio para ajustar!")
			return
		end

		ChangeHistoryService:SetWaypoint("Antes de ajustar acessorio")

		local adjustments = {
			[selectedAssetId] = {
				Position = Vector3.new(moveSliders.X.getValue(), moveSliders.Y.getValue(), moveSliders.Z.getValue()),
				Rotation = Vector3.new(rotateSliders.X.getValue(), rotateSliders.Y.getValue(), rotateSliders.Z.getValue()),
				Scale = Vector3.new(scaleSlider.getValue(), scaleSlider.getValue(), scaleSlider.getValue()),
			},
		}

		local pos = Vector3.new(moveSliders.X.getValue(), moveSliders.Y.getValue(), moveSliders.Z.getValue())
		local rot = Vector3.new(rotateSliders.X.getValue(), rotateSliders.Y.getValue(), rotateSliders.Z.getValue())
		local scl = Vector3.new(scaleSlider.getValue(), scaleSlider.getValue(), scaleSlider.getValue())

		-- Aplica no rig do workspace (manipulacao direta)
		local ok = AdjustService.aplicarAjusteAcessorios(rig, adjustments)

		-- Tambem aplica direto no Accessory instance como fallback
		if selectedAccInstance then
			AdjustService.aplicarAjusteDireto(selectedAccInstance, pos, rot, scl)
		end

		ChangeHistoryService:SetWaypoint("Ajustar acessorio")

		if ok then
			callbacks.setStatus("Acessorio ajustado!")
		else
			callbacks.setStatus("Ajuste aplicado via manipulacao direta.")
		end
	end)

	-- ═══════════════════════════════════════════════════
	-- Colors tab
	-- ═══════════════════════════════════════════════════
	local colorsTab = Instance.new("Frame")
	colorsTab.Name = "ColorsTab"
	colorsTab.Size = UDim2.new(1, 0, 0, 260)
	colorsTab.BackgroundTransparency = 1
	colorsTab.LayoutOrder = 6
	colorsTab.Visible = false
	colorsTab.Parent = container

	tabContents["colors"] = colorsTab

	local colorsLayout = Instance.new("UIListLayout")
	colorsLayout.Padding = UDim.new(0, 6)
	colorsLayout.Parent = colorsTab

	-- Mapa de body part -> propriedades de cor (definido antes do callback)
	local COLOR_KEY_TO_PROPS = {
		All = { "HeadColor", "TorsoColor", "LeftArmColor", "RightArmColor", "LeftLegColor", "RightLegColor" },
		Head = { "HeadColor" },
		Torso = { "TorsoColor" },
		LeftArm = { "LeftArmColor" },
		RightArm = { "RightArmColor" },
		LeftLeg = { "LeftLegColor" },
		RightLeg = { "RightLegColor" },
	}

	local swatchGrid = ColorSwatchGrid.create(colorsTab, {
		onColorSelected = function(bodyPartKey: string, color: Color3)
			local rig = callbacks.getRigSelecionado()
			if not rig then
				callbacks.setStatus("Selecione um rig!")
				return
			end

			ChangeHistoryService:SetWaypoint("Antes de aplicar cor")

			local propKeys = COLOR_KEY_TO_PROPS[bodyPartKey] or COLOR_KEY_TO_PROPS["All"]
			local colors = {}
			for _, prop in propKeys do
				colors[prop] = color
			end

			local ok = AdjustService.aplicarCores(rig, colors)
			ChangeHistoryService:SetWaypoint("Aplicar cor")

			-- Atualiza preview direto (sem re-clone)
			preview.applyColors(colors)

			if ok then
				local hex = string.format("#%02X%02X%02X",
					math.round(color.R * 255),
					math.round(color.G * 255),
					math.round(color.B * 255)
				)
				callbacks.setStatus("Cor " .. hex .. " aplicada!")
			else
				callbacks.setStatus("Falha ao aplicar cor.")
			end
		end,
	})

	-- ═══════════════════════════════════════════════════
	-- Proportions tab
	-- ═══════════════════════════════════════════════════
	local propsTab = Instance.new("Frame")
	propsTab.Name = "ProportionsTab"
	propsTab.Size = UDim2.new(1, 0, 0, 200)
	propsTab.BackgroundTransparency = 1
	propsTab.LayoutOrder = 7
	propsTab.Visible = false
	propsTab.Parent = container

	tabContents["proportions"] = propsTab

	local propsLayout = Instance.new("UIListLayout")
	propsLayout.Padding = UDim.new(0, 6)
	propsLayout.Parent = propsTab

	UIHelpers.criarLabel(propsTab, {
		text = "Proporcoes do Corpo",
		size = UDim2.new(1, 0, 0, 14),
		color = COLORS.textDim,
		textSize = 11,
		bold = true,
	})

	local propSliders
	local function previewProportions()
		if not propSliders then return end
		preview.applyProportions({
			HeightScale = propSliders.Height.getValue(),
			WidthScale = propSliders.Width.getValue(),
			HeadScale = propSliders.Head.getValue(),
			ProportionScale = propSliders.Proportion.getValue(),
		})
	end

	propSliders = {
		Height = Slider.create(propsTab, { axisName = "H", axisColor = AXIS_COLORS.Y, min = 0.90, max = 1.05, step = 0.01, default = 1.00, format = "%.2f", layoutOrder = 1, onChanged = previewProportions }),
		Width = Slider.create(propsTab, { axisName = "W", axisColor = AXIS_COLORS.X, min = 0.70, max = 1.00, step = 0.01, default = 1.00, format = "%.2f", layoutOrder = 2, onChanged = previewProportions }),
		Head = Slider.create(propsTab, { axisName = "Hd", axisColor = AXIS_COLORS.Z, min = 0.95, max = 1.00, step = 0.01, default = 1.00, format = "%.2f", layoutOrder = 3, onChanged = previewProportions }),
		Proportion = Slider.create(propsTab, { axisName = "P", axisColor = Color3.fromRGB(200, 150, 50), min = 0.00, max = 1.00, step = 0.01, default = 0.00, format = "%.2f", layoutOrder = 4, onChanged = previewProportions }),
	}

	local applyPropsBtn = UIHelpers.criarBotao(propsTab, {
		text = "Aplicar Proporcoes",
		size = UDim2.new(1, 0, 0, 32),
		color = COLORS.primary,
	})
	applyPropsBtn.Font = Enum.Font.GothamBold
	applyPropsBtn.TextSize = 13
	applyPropsBtn.LayoutOrder = 10

	applyPropsBtn.MouseButton1Click:Connect(function()
		local rig = callbacks.getRigSelecionado()
		if not rig then
			callbacks.setStatus("Selecione um rig!")
			return
		end

		ChangeHistoryService:SetWaypoint("Antes de aplicar proporcoes")

		local ok = AdjustService.aplicarProporcoes(rig, {
			HeightScale = propSliders.Height.getValue(),
			WidthScale = propSliders.Width.getValue(),
			HeadScale = propSliders.Head.getValue(),
			ProportionScale = propSliders.Proportion.getValue(),
		})

		ChangeHistoryService:SetWaypoint("Aplicar proporcoes")

		if ok then
			callbacks.setStatus("Proporcoes aplicadas!")
		else
			callbacks.setStatus("Falha ao aplicar proporcoes.")
		end
	end)

	-- ═══════════════════════════════════════════════════
	-- API
	-- ═══════════════════════════════════════════════════
	local api = {}

	function api.getContainer()
		return container
	end

	function api.refresh()
		local rig = callbacks.getRigSelecionado()

		preview.setRig(rig)

		if rig then
			loadAccessories(rig)

			local currentProps = AdjustService.getProporcoesAtuais(rig)
			if currentProps.HeightScale then propSliders.Height.setValue(currentProps.HeightScale) end
			if currentProps.WidthScale then propSliders.Width.setValue(currentProps.WidthScale) end
			if currentProps.HeadScale then propSliders.Head.setValue(currentProps.HeadScale) end
			if currentProps.ProportionScale then propSliders.Proportion.setValue(currentProps.ProportionScale) end

			infoLabel.Text = "Rig: " .. rig.Name
		else
			infoLabel.Text = "Selecione 1 rig no workspace para ajustar"
			clearAccThumbs()
			noAccLabel.Visible = true
		end
	end

	function api.destroy()
		preview.destroy()
		swatchGrid.destroy()
		container:Destroy()
	end

	-- Listener de selecao
	local selectionConn = Selection.SelectionChanged:Connect(function()
		api.refresh()
	end)

	local oldDestroy = api.destroy
	function api.destroy()
		selectionConn:Disconnect()
		oldDestroy()
	end

	return api
end

return AdjustPanel
