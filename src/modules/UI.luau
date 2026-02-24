--[[
	vulpy-rig-kit | UI
	Cria a interface do plugin (DockWidgetPluginGui).
	Layout com TAB BAR no topo: cada aba ocupa o painel inteiro.
	Abas: Alinhamento | Rig Creator | Loja

	Inclui seletor de idioma no primeiro uso e creditos.
]]

local UIHelpers = require(script.Parent.UIHelpers)
local Locale = require(script.Parent.Locale)
local ShopPanel = require(script.Parent.components.ShopPanel)

local COLORS = UIHelpers.COLORS

local UI = {}

-- ════════════════════════════════════════════════════════════════
-- Seletor de idioma (dialog modal no primeiro uso)
-- ════════════════════════════════════════════════════════════════
local function criarSeletorIdioma(widget: DockWidgetPluginGui, pluginInstance: Plugin, onSelected: (string) -> ())
	-- Overlay escuro
	local overlay = Instance.new("Frame")
	overlay.Name = "LangOverlay"
	overlay.Size = UDim2.new(1, 0, 1, 0)
	overlay.BackgroundColor3 = Color3.new(0, 0, 0)
	overlay.BackgroundTransparency = 0.3
	overlay.BorderSizePixel = 0
	overlay.ZIndex = 100
	overlay.Parent = widget

	-- Card central
	local card = Instance.new("Frame")
	card.Name = "LangCard"
	card.Size = UDim2.new(0, 280, 0, 380)
	card.Position = UDim2.new(0.5, -140, 0.5, -190)
	card.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	card.BorderSizePixel = 0
	card.ZIndex = 101
	card.Parent = overlay

	UIHelpers.criarCorner(card, 16)
	local cardStroke = Instance.new("UIStroke")
	cardStroke.Color = COLORS.primary
	cardStroke.Thickness = 2
	cardStroke.Parent = card

	-- Logo / Titulo area
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, 0, 0, 30)
	titleLabel.Position = UDim2.new(0, 0, 0, 30)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = "Vulpy Rig Kit"
	titleLabel.TextColor3 = COLORS.primary
	titleLabel.TextSize = 22
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.ZIndex = 102
	titleLabel.Parent = card

	-- Subtitle
	local subLabel = Instance.new("TextLabel")
	subLabel.Size = UDim2.new(1, 0, 0, 16)
	subLabel.Position = UDim2.new(0, 0, 0, 62)
	subLabel.BackgroundTransparency = 1
	subLabel.Text = "Choose Language / Escolha o Idioma"
	subLabel.TextColor3 = COLORS.textDim
	subLabel.TextSize = 11
	subLabel.Font = Enum.Font.GothamMedium
	subLabel.ZIndex = 102
	subLabel.Parent = card

	UIHelpers.criarSeparador(card).Position = UDim2.new(0.1, 0, 0, 90)
	local sep = card:FindFirstChildOfClass("Frame")
	if sep and sep:IsA("Frame") and sep ~= card then
		sep.Size = UDim2.new(0.8, 0, 0, 1)
		sep.ZIndex = 102
	end

	-- Estado selecionado
	local selectedLang = "en"

	-- Opcoes de idioma
	local function criarOpcaoIdioma(text: string, subtitle: string, langKey: string, yPos: number): TextButton
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(0.8, 0, 0, 52)
		btn.Position = UDim2.new(0.1, 0, 0, yPos)
		btn.BackgroundColor3 = if langKey == selectedLang then COLORS.primary else COLORS.surface
		btn.Text = ""
		btn.AutoButtonColor = false
		btn.ZIndex = 102
		btn.Parent = card

		UIHelpers.criarCorner(btn, 10)

		local btnStroke = Instance.new("UIStroke")
		btnStroke.Color = if langKey == selectedLang then COLORS.primary else COLORS.separator
		btnStroke.Thickness = if langKey == selectedLang then 2 else 1
		btnStroke.Parent = btn

		local mainText = Instance.new("TextLabel")
		mainText.Size = UDim2.new(1, -20, 0, 22)
		mainText.Position = UDim2.new(0, 10, 0, 6)
		mainText.BackgroundTransparency = 1
		mainText.Text = text
		mainText.TextColor3 = Color3.new(1, 1, 1)
		mainText.TextSize = 14
		mainText.Font = Enum.Font.GothamBold
		mainText.TextXAlignment = Enum.TextXAlignment.Left
		mainText.ZIndex = 103
		mainText.Parent = btn

		local subText = Instance.new("TextLabel")
		subText.Size = UDim2.new(1, -20, 0, 16)
		subText.Position = UDim2.new(0, 10, 0, 28)
		subText.BackgroundTransparency = 1
		subText.Text = subtitle
		subText.TextColor3 = Color3.fromRGB(180, 180, 180)
		subText.TextSize = 10
		subText.Font = Enum.Font.GothamMedium
		subText.TextXAlignment = Enum.TextXAlignment.Left
		subText.ZIndex = 103
		subText.Parent = btn

		return btn
	end

	local enBtn = criarOpcaoIdioma("English", "Interface in English", "en", 104)
	local ptBtn = criarOpcaoIdioma("Portugues BR", "Interface em Portugues", "pt-br", 166)

	local function updateSelection(lang: string)
		selectedLang = lang
		-- Atualiza visual dos botoes
		local enStroke = enBtn:FindFirstChildOfClass("UIStroke")
		local ptStroke = ptBtn:FindFirstChildOfClass("UIStroke")

		if lang == "en" then
			UIHelpers.tweenProperty(enBtn, { BackgroundColor3 = COLORS.primary }, 0.2)
			UIHelpers.tweenProperty(ptBtn, { BackgroundColor3 = COLORS.surface }, 0.2)
			if enStroke then UIHelpers.tweenProperty(enStroke, { Color = COLORS.primary, Thickness = 2 }, 0.2) end
			if ptStroke then UIHelpers.tweenProperty(ptStroke, { Color = COLORS.separator, Thickness = 1 }, 0.2) end
		else
			UIHelpers.tweenProperty(enBtn, { BackgroundColor3 = COLORS.surface }, 0.2)
			UIHelpers.tweenProperty(ptBtn, { BackgroundColor3 = COLORS.primary }, 0.2)
			if enStroke then UIHelpers.tweenProperty(enStroke, { Color = COLORS.separator, Thickness = 1 }, 0.2) end
			if ptStroke then UIHelpers.tweenProperty(ptStroke, { Color = COLORS.primary, Thickness = 2 }, 0.2) end
		end
	end

	enBtn.MouseButton1Click:Connect(function() updateSelection("en") end)
	ptBtn.MouseButton1Click:Connect(function() updateSelection("pt-br") end)

	-- Botao confirmar
	local confirmBtn = Instance.new("TextButton")
	confirmBtn.Size = UDim2.new(0.6, 0, 0, 38)
	confirmBtn.Position = UDim2.new(0.2, 0, 0, 236)
	confirmBtn.BackgroundColor3 = COLORS.green
	confirmBtn.Text = "Confirm / Confirmar"
	confirmBtn.TextColor3 = Color3.new(1, 1, 1)
	confirmBtn.TextSize = 14
	confirmBtn.Font = Enum.Font.GothamBold
	confirmBtn.AutoButtonColor = true
	confirmBtn.ZIndex = 102
	confirmBtn.Parent = card
	UIHelpers.criarCorner(confirmBtn, 10)

	-- Credits com avatar
	local creditsFrame = Instance.new("Frame")
	creditsFrame.Name = "Credits"
	creditsFrame.Size = UDim2.new(1, 0, 0, 56)
	creditsFrame.Position = UDim2.new(0, 0, 0, 290)
	creditsFrame.BackgroundTransparency = 1
	creditsFrame.ZIndex = 102
	creditsFrame.Parent = card

	-- Avatar circular
	local avatarImg = Instance.new("ImageLabel")
	avatarImg.Name = "Avatar"
	avatarImg.Size = UDim2.new(0, 44, 0, 44)
	avatarImg.Position = UDim2.new(0.5, -72, 0, 0)
	avatarImg.BackgroundColor3 = COLORS.surface
	avatarImg.Image = "rbxthumb://type=AvatarHeadShot&id=8528429020&w=150&h=150"
	avatarImg.ScaleType = Enum.ScaleType.Fit
	avatarImg.ZIndex = 103
	avatarImg.Parent = creditsFrame
	UIHelpers.criarCorner(avatarImg, 22)

	local avatarStroke = Instance.new("UIStroke")
	avatarStroke.Color = COLORS.primary
	avatarStroke.Thickness = 2
	avatarStroke.Parent = avatarImg

	-- Texto dos creditos ao lado do avatar
	local creditsText = Instance.new("Frame")
	creditsText.Size = UDim2.new(0, 100, 0, 44)
	creditsText.Position = UDim2.new(0.5, -22, 0, 0)
	creditsText.BackgroundTransparency = 1
	creditsText.ZIndex = 102
	creditsText.Parent = creditsFrame

	local createdByLabel = Instance.new("TextLabel")
	createdByLabel.Size = UDim2.new(1, 0, 0, 14)
	createdByLabel.Position = UDim2.new(0, 0, 0, 8)
	createdByLabel.BackgroundTransparency = 1
	createdByLabel.Text = "Created by"
	createdByLabel.TextColor3 = COLORS.textDim
	createdByLabel.TextSize = 10
	createdByLabel.Font = Enum.Font.GothamMedium
	createdByLabel.TextXAlignment = Enum.TextXAlignment.Left
	createdByLabel.ZIndex = 103
	createdByLabel.Parent = creditsText

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, 0, 0, 16)
	nameLabel.Position = UDim2.new(0, 0, 0, 22)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = "VampireSonata"
	nameLabel.TextColor3 = COLORS.primary
	nameLabel.TextSize = 13
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.ZIndex = 103
	nameLabel.Parent = creditsText

	confirmBtn.MouseButton1Click:Connect(function()
		pluginInstance:SetSetting("VulpyRigKit_Language", selectedLang)
		overlay:Destroy()
		onSelected(selectedLang)
	end)
end

-- ════════════════════════════════════════════════════════════════
-- Widget principal
-- ════════════════════════════════════════════════════════════════
function UI.criarWidget(pluginInstance: Plugin, callbacks: {
	onItemSelected: (any) -> (),
	setStatus: (string) -> (),
	getRigSelecionado: () -> Model?,
	onLimparRig: () -> (),
})
	local widgetInfo = DockWidgetPluginGuiInfo.new(
		Enum.InitialDockState.Float,
		false,
		false,
		400,
		620,
		340,
		480
	)

	local widget = pluginInstance:CreateDockWidgetPluginGuiAsync("VulpyRigKit", widgetInfo)
	widget.Title = "Vulpy Rig Kit"

	-- ══════════════════════════════════════════════════════════
	-- Frame principal
	-- ══════════════════════════════════════════════════════════
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(1, 0, 1, 0)
	mainFrame.BackgroundColor3 = COLORS.background
	mainFrame.BorderSizePixel = 0
	mainFrame.Parent = widget

	-- ══════════════════════════════════════════════════════════
	-- TAB BAR no topo (40px, mais elegante)
	-- ══════════════════════════════════════════════════════════
	local tabBar = Instance.new("Frame")
	tabBar.Name = "TabBar"
	tabBar.Size = UDim2.new(1, 0, 0, 40)
	tabBar.Position = UDim2.new(0, 0, 0, 0)
	tabBar.BackgroundColor3 = COLORS.headerBar
	tabBar.BorderSizePixel = 0
	tabBar.Parent = mainFrame

	local tabBarLayout = Instance.new("UIListLayout")
	tabBarLayout.FillDirection = Enum.FillDirection.Horizontal
	tabBarLayout.SortOrder = Enum.SortOrder.LayoutOrder
	tabBarLayout.Parent = tabBar

	-- Accent line embaixo do header
	local accentLine = Instance.new("Frame")
	accentLine.Name = "AccentLine"
	accentLine.Size = UDim2.new(1, 0, 0, 2)
	accentLine.Position = UDim2.new(0, 0, 0, 40)
	accentLine.BackgroundColor3 = COLORS.primary
	accentLine.BorderSizePixel = 0
	accentLine.Parent = mainFrame

	-- ══════════════════════════════════════════════════════════
	-- Footer com creditos + status (50px)
	-- ══════════════════════════════════════════════════════════
	local footer = Instance.new("Frame")
	footer.Name = "Footer"
	footer.Size = UDim2.new(1, 0, 0, 50)
	footer.Position = UDim2.new(0, 0, 1, -50)
	footer.BackgroundColor3 = COLORS.headerBar
	footer.BorderSizePixel = 0
	footer.Parent = mainFrame

	local footerTopLine = Instance.new("Frame")
	footerTopLine.Size = UDim2.new(1, 0, 0, 1)
	footerTopLine.BackgroundColor3 = COLORS.separator
	footerTopLine.BorderSizePixel = 0
	footerTopLine.Parent = footer

	-- Status label no topo do footer
	local statusLabel = Instance.new("TextLabel")
	statusLabel.Name = "StatusLabel"
	statusLabel.Size = UDim2.new(1, -16, 0, 16)
	statusLabel.Position = UDim2.new(0, 8, 0, 3)
	statusLabel.BackgroundTransparency = 1
	statusLabel.Text = Locale.get("ready")
	statusLabel.TextColor3 = COLORS.textDim
	statusLabel.TextSize = 9
	statusLabel.Font = Enum.Font.GothamMedium
	statusLabel.TextXAlignment = Enum.TextXAlignment.Left
	statusLabel.TextTruncate = Enum.TextTruncate.AtEnd
	statusLabel.Parent = footer

	-- Linha separando status dos creditos
	local creditsSep = Instance.new("Frame")
	creditsSep.Size = UDim2.new(1, -16, 0, 1)
	creditsSep.Position = UDim2.new(0, 8, 0, 20)
	creditsSep.BackgroundColor3 = COLORS.separator
	creditsSep.BorderSizePixel = 0
	creditsSep.Parent = footer

	-- "Created by VampireSonata" [foto]
	local createdByText = Instance.new("TextLabel")
	createdByText.Size = UDim2.new(1, -38, 0, 24)
	createdByText.Position = UDim2.new(0, 8, 0, 23)
	createdByText.BackgroundTransparency = 1
	createdByText.RichText = true
	createdByText.Text = '<font color="#999">Created by</font> <font color="rgb(88,101,242)"><b>VampireSonata</b></font>'
	createdByText.TextColor3 = COLORS.text
	createdByText.TextSize = 10
	createdByText.Font = Enum.Font.GothamMedium
	createdByText.TextXAlignment = Enum.TextXAlignment.Left
	createdByText.Parent = footer

	-- Avatar pequeno a direita do texto (sem borda)
	local footerAvatar = Instance.new("ImageLabel")
	footerAvatar.Name = "FooterAvatar"
	footerAvatar.Size = UDim2.new(0, 20, 0, 20)
	footerAvatar.Position = UDim2.new(1, -28, 0, 25)
	footerAvatar.BackgroundTransparency = 1
	footerAvatar.Image = "rbxthumb://type=AvatarHeadShot&id=8528429020&w=150&h=150"
	footerAvatar.ScaleType = Enum.ScaleType.Fit
	footerAvatar.Parent = footer
	UIHelpers.criarCorner(footerAvatar, 10)

	-- ══════════════════════════════════════════════════════════
	-- Area de conteudo
	-- ══════════════════════════════════════════════════════════
	local contentArea = Instance.new("Frame")
	contentArea.Name = "ContentArea"
	contentArea.Size = UDim2.new(1, 0, 1, -92) -- 40 tabbar + 2 accent + 50 footer = 92
	contentArea.Position = UDim2.new(0, 0, 0, 42)
	contentArea.BackgroundTransparency = 1
	contentArea.ClipsDescendants = true
	contentArea.Parent = mainFrame

	-- ══════════════════════════════════════════════════════════
	-- Sistema de tabs
	-- ══════════════════════════════════════════════════════════
	local TABS = {
		{ key = "align", labelKey = "tabAlign" },
		{ key = "creator", labelKey = "tabCreator" },
		{ key = "shop", labelKey = "tabShop" },
	}

	local tabButtons: { [string]: TextButton } = {}
	local tabPages: { [string]: GuiObject } = {}

	local function switchTab(tabKey: string)
		for key, btn in tabButtons do
			local isActive = key == tabKey

			local label = btn:FindFirstChild("Label")
			if label then
				UIHelpers.tweenProperty(label, {
					TextColor3 = if isActive then Color3.new(1, 1, 1) else COLORS.textDim,
				}, 0.15)
			end

			-- Indicador
			local indicator = btn:FindFirstChild("Indicator")
			if indicator then
				UIHelpers.tweenProperty(indicator, {
					BackgroundTransparency = if isActive then 0 else 1,
				}, 0.15)
			end
		end
		for key, page in tabPages do
			page.Visible = key == tabKey
		end
	end

	-- Atualiza labels das tabs com o idioma atual
	local function updateTabLabels()
		for _, tab in TABS do
			local btn = tabButtons[tab.key]
			if btn then
				local label = btn:FindFirstChild("Label")
				if label then
					label.Text = Locale.get(tab.labelKey)
				end
			end
		end
	end

	-- Criar botoes de tab
	for i, tab in TABS do
		local btn = Instance.new("TextButton")
		btn.Name = "Tab_" .. tab.key
		btn.Size = UDim2.new(1 / #TABS, 0, 1, 0)
		btn.BackgroundColor3 = COLORS.headerBar
		btn.BackgroundTransparency = 1
		btn.Text = ""
		btn.AutoButtonColor = false
		btn.LayoutOrder = i
		btn.Parent = tabBar

		local label = Instance.new("TextLabel")
		label.Name = "Label"
		label.Size = UDim2.new(1, 0, 1, -4)
		label.BackgroundTransparency = 1
		label.Text = Locale.get(tab.labelKey)
		label.TextColor3 = if i == 1 then Color3.new(1, 1, 1) else COLORS.textDim
		label.TextSize = 12
		label.Font = Enum.Font.GothamBold
		label.Parent = btn

		-- Indicador colorido embaixo
		local indicator = Instance.new("Frame")
		indicator.Name = "Indicator"
		indicator.Size = UDim2.new(0.5, 0, 0, 3)
		indicator.Position = UDim2.new(0.25, 0, 1, -3)
		indicator.BackgroundColor3 = COLORS.primary
		indicator.BorderSizePixel = 0
		indicator.BackgroundTransparency = if i == 1 then 0 else 1
		indicator.Parent = btn
		UIHelpers.criarCorner(indicator, 2)

		tabButtons[tab.key] = btn

		btn.MouseButton1Click:Connect(function()
			switchTab(tab.key)
		end)
	end

	-- ══════════════════════════════════════════════════════════
	-- Helper: criar pagina com scroll
	-- ══════════════════════════════════════════════════════════
	local function criarPagina(name: string, visible: boolean): ScrollingFrame
		local page = Instance.new("ScrollingFrame")
		page.Name = name
		page.Size = UDim2.new(1, 0, 1, 0)
		page.BackgroundTransparency = 1
		page.BorderSizePixel = 0
		page.ScrollBarThickness = 4
		page.ScrollBarImageColor3 = COLORS.separator
		page.CanvasSize = UDim2.new(0, 0, 0, 0)
		page.AutomaticCanvasSize = Enum.AutomaticSize.Y
		page.Visible = visible
		page.Parent = contentArea

		local layout = Instance.new("UIListLayout")
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		layout.Padding = UDim.new(0, 8)
		layout.Parent = page

		local pad = Instance.new("UIPadding")
		pad.PaddingTop = UDim.new(0, 12)
		pad.PaddingBottom = UDim.new(0, 12)
		pad.PaddingLeft = UDim.new(0, 14)
		pad.PaddingRight = UDim.new(0, 14)
		pad.Parent = page

		return page
	end

	-- ══════════════════════════════════════════════════════════
	-- Helper: criar section header com estilo
	-- ══════════════════════════════════════════════════════════
	local function criarSectionHeader(parent: GuiObject, text: string, order: number): TextLabel
		local label = UIHelpers.criarLabel(parent, {
			text = text,
			size = UDim2.new(1, 0, 0, 20),
			bold = true, textSize = 14,
			color = COLORS.primary,
		})
		label.LayoutOrder = order
		return label
	end

	-- ══════════════════════════════════════════════════════════
	-- PAGE 1: ALINHAMENTO
	-- ══════════════════════════════════════════════════════════
	local alignPage = criarPagina("AlignPage", true)
	tabPages["align"] = alignPage

	-- Rigs section
	local rigsHeader = criarSectionHeader(alignPage, Locale.get("rigsTitle"), 1)

	local rigsCountLabel = UIHelpers.criarLabel(alignPage, {
		text = Locale.get("noRigsDefined"),
		size = UDim2.new(1, 0, 0, 16),
		color = COLORS.textDim, textSize = 11,
	})
	rigsCountLabel.LayoutOrder = 2

	local setRigsButton = UIHelpers.criarBotao(alignPage, {
		text = Locale.get("setRigs"),
		size = UDim2.new(1, 0, 0, 32),
		color = COLORS.primary,
	})
	setRigsButton.LayoutOrder = 3

	local clearRigsButton = UIHelpers.criarBotao(alignPage, {
		text = Locale.get("clearRigs"),
		size = UDim2.new(1, 0, 0, 26),
		color = COLORS.surface,
	})
	clearRigsButton.TextSize = 11
	clearRigsButton.LayoutOrder = 4

	UIHelpers.criarSeparador(alignPage).LayoutOrder = 5

	-- Pedestais section
	local pedestaisHeader = criarSectionHeader(alignPage, Locale.get("pedestalsTitle"), 6)

	local pedestaisCountLabel = UIHelpers.criarLabel(alignPage, {
		text = Locale.get("noPedestalsDefined"),
		size = UDim2.new(1, 0, 0, 16),
		color = COLORS.textDim, textSize = 11,
	})
	pedestaisCountLabel.LayoutOrder = 7

	local setPedestaisButton = UIHelpers.criarBotao(alignPage, {
		text = Locale.get("setPedestals"),
		size = UDim2.new(1, 0, 0, 32),
		color = COLORS.primary,
	})
	setPedestaisButton.LayoutOrder = 8

	local clearPedestaisButton = UIHelpers.criarBotao(alignPage, {
		text = Locale.get("clearPedestals"),
		size = UDim2.new(1, 0, 0, 26),
		color = COLORS.surface,
	})
	clearPedestaisButton.TextSize = 11
	clearPedestaisButton.LayoutOrder = 9

	UIHelpers.criarSeparador(alignPage).LayoutOrder = 10

	-- Botao Alinhar
	local alignButton = UIHelpers.criarBotao(alignPage, {
		text = Locale.get("alignButton"),
		size = UDim2.new(1, 0, 0, 42),
		color = COLORS.green,
	})
	alignButton.TextSize = 16
	alignButton.Font = Enum.Font.GothamBold
	alignButton.LayoutOrder = 11

	UIHelpers.criarSeparador(alignPage).LayoutOrder = 12

	-- Offset section
	local offsetHeader = criarSectionHeader(alignPage, Locale.get("offsetTitle"), 13)

	local offsetFrame = Instance.new("Frame")
	offsetFrame.Name = "OffsetFrame"
	offsetFrame.Size = UDim2.new(1, 0, 0, 96)
	offsetFrame.BackgroundTransparency = 1
	offsetFrame.LayoutOrder = 14
	offsetFrame.Parent = alignPage

	local offsetLayout = Instance.new("UIListLayout")
	offsetLayout.Padding = UDim.new(0, 4)
	offsetLayout.Parent = offsetFrame

	local offsetX, offsetXMinus, offsetXPlus = UIHelpers.criarLinhaOffset(offsetFrame, "X")
	local offsetY, offsetYMinus, offsetYPlus = UIHelpers.criarLinhaOffset(offsetFrame, "Y")
	local offsetZ, offsetZMinus, offsetZPlus = UIHelpers.criarLinhaOffset(offsetFrame, "Z")

	local applyOffsetButton = UIHelpers.criarBotao(alignPage, {
		text = Locale.get("applyOffset"),
		size = UDim2.new(1, 0, 0, 32),
		color = COLORS.primary,
	})
	applyOffsetButton.LayoutOrder = 15

	-- ══════════════════════════════════════════════════════════
	-- PAGE 2: RIG CREATOR
	-- ══════════════════════════════════════════════════════════
	local creatorPage = criarPagina("CreatorPage", false)
	tabPages["creator"] = creatorPage

	criarSectionHeader(creatorPage, Locale.get("createRigTitle"), 1)

	UIHelpers.criarLabel(creatorPage, {
		text = Locale.get("createRigDesc"),
		size = UDim2.new(1, 0, 0, 32),
		color = COLORS.textDim, textSize = 10,
	}).LayoutOrder = 2

	UIHelpers.criarSeparador(creatorPage).LayoutOrder = 3

	UIHelpers.criarLabel(creatorPage, {
		text = Locale.get("usernameOrId"),
		size = UDim2.new(1, 0, 0, 16),
		bold = true, textSize = 12,
	}).LayoutOrder = 4

	local rigCreatorInput = UIHelpers.criarInput(creatorPage, {
		size = UDim2.new(1, 0, 0, 34),
		placeholder = Locale.get("usernameOrIdPlaceholder"),
	})
	rigCreatorInput.LayoutOrder = 5

	UIHelpers.criarLabel(creatorPage, {
		text = Locale.get("rigNameOptional"),
		size = UDim2.new(1, 0, 0, 16),
		bold = true, textSize = 12,
	}).LayoutOrder = 6

	local rigNameInput = UIHelpers.criarInput(creatorPage, {
		size = UDim2.new(1, 0, 0, 34),
		placeholder = Locale.get("rigNamePlaceholder"),
	})
	rigNameInput.LayoutOrder = 7

	UIHelpers.criarSeparador(creatorPage).LayoutOrder = 8

	local createRigButton = UIHelpers.criarBotao(creatorPage, {
		text = Locale.get("createRigButton"),
		size = UDim2.new(1, 0, 0, 42),
		color = COLORS.green,
	})
	createRigButton.Font = Enum.Font.GothamBold
	createRigButton.TextSize = 16
	createRigButton.LayoutOrder = 9

	-- ══════════════════════════════════════════════════════════
	-- PAGE 3: LOJA
	-- ══════════════════════════════════════════════════════════
	local shopPage = Instance.new("Frame")
	shopPage.Name = "ShopPage"
	shopPage.Size = UDim2.new(1, 0, 1, 0)
	shopPage.BackgroundTransparency = 1
	shopPage.Visible = false
	shopPage.Parent = contentArea
	tabPages["shop"] = shopPage

	local shopPanel = ShopPanel.create(shopPage, {
		onItemSelected = callbacks.onItemSelected,
		setStatus = callbacks.setStatus,
		onLimparRig = callbacks.onLimparRig,
	})

	-- ══════════════════════════════════════════════════════════
	-- Seletor de idioma (verifica se ja foi escolhido)
	-- ══════════════════════════════════════════════════════════
	local savedLang = pluginInstance:GetSetting("VulpyRigKit_Language")

	if savedLang then
		Locale.setLanguage(savedLang)
		-- Atualiza labels com idioma salvo
		updateTabLabels()
		statusLabel.Text = Locale.get("ready")
		-- Atualiza labels da pagina de alinhamento
		rigsHeader.Text = Locale.get("rigsTitle")
		rigsCountLabel.Text = Locale.get("noRigsDefined")
		setRigsButton.Text = Locale.get("setRigs")
		clearRigsButton.Text = Locale.get("clearRigs")
		pedestaisHeader.Text = Locale.get("pedestalsTitle")
		pedestaisCountLabel.Text = Locale.get("noPedestalsDefined")
		setPedestaisButton.Text = Locale.get("setPedestals")
		clearPedestaisButton.Text = Locale.get("clearPedestals")
		alignButton.Text = Locale.get("alignButton")
		offsetHeader.Text = Locale.get("offsetTitle")
		applyOffsetButton.Text = Locale.get("applyOffset")
		-- Rig Creator
		rigCreatorInput.PlaceholderText = Locale.get("usernameOrIdPlaceholder")
		rigNameInput.PlaceholderText = Locale.get("rigNamePlaceholder")
		createRigButton.Text = Locale.get("createRigButton")
	else
		criarSeletorIdioma(widget, pluginInstance, function(lang: string)
			Locale.setLanguage(lang)
			-- Atualiza tudo com o idioma escolhido
			updateTabLabels()
			statusLabel.Text = Locale.get("ready")
			rigsHeader.Text = Locale.get("rigsTitle")
			rigsCountLabel.Text = Locale.get("noRigsDefined")
			setRigsButton.Text = Locale.get("setRigs")
			clearRigsButton.Text = Locale.get("clearRigs")
			pedestaisHeader.Text = Locale.get("pedestalsTitle")
			pedestaisCountLabel.Text = Locale.get("noPedestalsDefined")
			setPedestaisButton.Text = Locale.get("setPedestals")
			clearPedestaisButton.Text = Locale.get("clearPedestals")
			alignButton.Text = Locale.get("alignButton")
			offsetHeader.Text = Locale.get("offsetTitle")
			applyOffsetButton.Text = Locale.get("applyOffset")
			rigCreatorInput.PlaceholderText = Locale.get("usernameOrIdPlaceholder")
			rigNameInput.PlaceholderText = Locale.get("rigNamePlaceholder")
			createRigButton.Text = Locale.get("createRigButton")
		end)
	end

	-- ══════════════════════════════════════════════════════════
	-- Return refs
	-- ══════════════════════════════════════════════════════════
	return {
		widget = widget,
		-- Alinhamento
		setRigsButton = setRigsButton,
		clearRigsButton = clearRigsButton,
		setPedestaisButton = setPedestaisButton,
		clearPedestaisButton = clearPedestaisButton,
		alignButton = alignButton,
		applyOffsetButton = applyOffsetButton,
		rigsCountLabel = rigsCountLabel,
		pedestaisCountLabel = pedestaisCountLabel,
		statusLabel = statusLabel,
		offsetX = offsetX,
		offsetY = offsetY,
		offsetZ = offsetZ,
		offsetXMinus = offsetXMinus,
		offsetXPlus = offsetXPlus,
		offsetYMinus = offsetYMinus,
		offsetYPlus = offsetYPlus,
		offsetZMinus = offsetZMinus,
		offsetZPlus = offsetZPlus,
		-- Rig Creator
		rigCreatorInput = rigCreatorInput,
		rigNameInput = rigNameInput,
		createRigButton = createRigButton,
		-- Paineis visuais (APIs)
		shopPanel = shopPanel,
	}
end

return UI
