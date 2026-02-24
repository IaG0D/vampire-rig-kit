--[[
	vulpy-rig-kit | UI
	Cria a interface do plugin (DockWidgetPluginGui).
	Layout com TAB BAR no topo: cada aba ocupa o painel inteiro.
	Abas: Alinhamento | Rig Creator | Loja | Config

	Suporte a temas e idiomas via aba de configuracoes.
]]

local UIHelpers = require(script.Parent.UIHelpers)
local Locale = require(script.Parent.Locale)
local ShopPanel = require(script.Parent.components.ShopPanel)

local COLORS = UIHelpers.COLORS

local UI = {}

-- ════════════════════════════════════════════════════════════════
-- Widget principal
-- ════════════════════════════════════════════════════════════════
function UI.criarWidget(pluginInstance: Plugin, callbacks: {
	onItemSelected: (any) -> (),
	setStatus: (string) -> (),
	getRigSelecionado: () -> Model?,
	onLimparRig: () -> (),
	onSettingsChanged: (string, string) -> (),
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
	widget.Title = Locale.get("pluginTitle")

	-- Referencia para shopPanel (precisa destruir no rebuild)
	local shopPanelApi: any = nil

	-- ══════════════════════════════════════════════════════════
	-- Funcao que constroi todo o conteudo dentro do widget
	-- ══════════════════════════════════════════════════════════
	local function buildContent()
		-- Limpa conteudo anterior
		if shopPanelApi then
			shopPanelApi.destroy()
			shopPanelApi = nil
		end
		for _, child in widget:GetChildren() do
			child:Destroy()
		end

		widget.Title = Locale.get("pluginTitle")

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
		-- TAB BAR no topo (40px)
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

		-- Creditos traduzidos
		local creditsText = Locale.get("credits")
		local createdByText = Instance.new("TextLabel")
		createdByText.Size = UDim2.new(1, -38, 0, 24)
		createdByText.Position = UDim2.new(0, 8, 0, 23)
		createdByText.BackgroundTransparency = 1
		createdByText.RichText = true
		createdByText.Text = '<font color="#999">' .. creditsText .. '</font>'
		createdByText.TextColor3 = COLORS.text
		createdByText.TextSize = 10
		createdByText.Font = Enum.Font.GothamMedium
		createdByText.TextXAlignment = Enum.TextXAlignment.Left
		createdByText.Parent = footer

		-- Avatar pequeno a direita do texto
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
		contentArea.Size = UDim2.new(1, 0, 1, -92)
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
			{ key = "settings", labelKey = "tabSettings" },
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
			label.TextSize = 11
			label.Font = Enum.Font.GothamBold
			label.Parent = btn

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

		local alignButton = UIHelpers.criarBotao(alignPage, {
			text = Locale.get("alignButton"),
			size = UDim2.new(1, 0, 0, 42),
			color = COLORS.green,
		})
		alignButton.TextSize = 16
		alignButton.Font = Enum.Font.GothamBold
		alignButton.LayoutOrder = 11

		UIHelpers.criarSeparador(alignPage).LayoutOrder = 12

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

		shopPanelApi = ShopPanel.create(shopPage, {
			onItemSelected = callbacks.onItemSelected,
			setStatus = callbacks.setStatus,
			onLimparRig = callbacks.onLimparRig,
		})

		-- ══════════════════════════════════════════════════════════
		-- PAGE 4: CONFIGURACOES
		-- ══════════════════════════════════════════════════════════
		local settingsPage = criarPagina("SettingsPage", false)
		tabPages["settings"] = settingsPage

		-- Titulo
		criarSectionHeader(settingsPage, Locale.get("settingsTitle"), 1)

		UIHelpers.criarSeparador(settingsPage).LayoutOrder = 2

		-- ── Secao Idioma ──
		UIHelpers.criarLabel(settingsPage, {
			text = Locale.get("languageSection"),
			size = UDim2.new(1, 0, 0, 18),
			bold = true, textSize = 13,
		}).LayoutOrder = 3

		local langRow = Instance.new("Frame")
		langRow.Name = "LangRow"
		langRow.Size = UDim2.new(1, 0, 0, 36)
		langRow.BackgroundTransparency = 1
		langRow.LayoutOrder = 4
		langRow.Parent = settingsPage

		local langRowLayout = Instance.new("UIListLayout")
		langRowLayout.FillDirection = Enum.FillDirection.Horizontal
		langRowLayout.Padding = UDim.new(0, 8)
		langRowLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		langRowLayout.Parent = langRow

		local currentLang = Locale.getLanguage()

		local function criarLangPill(parent: GuiObject, text: string, langKey: string, order: number): TextButton
			local isActive = langKey == currentLang
			local pill = Instance.new("TextButton")
			pill.Name = "Lang_" .. langKey
			pill.Size = UDim2.new(0.5, -4, 1, 0)
			pill.Text = text
			pill.TextSize = 12
			pill.Font = Enum.Font.GothamBold
			pill.TextColor3 = Color3.new(1, 1, 1)
			pill.BackgroundColor3 = if isActive then COLORS.primary else COLORS.surface
			pill.AutoButtonColor = true
			pill.LayoutOrder = order
			pill.Parent = parent
			UIHelpers.criarCorner(pill, 8)

			local stroke = UIHelpers.criarStroke(pill, if isActive then COLORS.primary else COLORS.separator, if isActive then 2 else 1)

			return pill
		end

		local enPill = criarLangPill(langRow, Locale.get("langEnglish"), "en", 1)
		local ptPill = criarLangPill(langRow, Locale.get("langPortuguese"), "pt-br", 2)

		local function updateLangSelection(lang: string)
			currentLang = lang
			local enActive = lang == "en"
			UIHelpers.tweenProperty(enPill, { BackgroundColor3 = if enActive then COLORS.primary else COLORS.surface }, 0.2)
			UIHelpers.tweenProperty(ptPill, { BackgroundColor3 = if enActive then COLORS.surface else COLORS.primary }, 0.2)
			local enStroke = enPill:FindFirstChildOfClass("UIStroke")
			local ptStroke = ptPill:FindFirstChildOfClass("UIStroke")
			if enStroke then UIHelpers.tweenProperty(enStroke, { Color = if enActive then COLORS.primary else COLORS.separator }, 0.2) end
			if ptStroke then UIHelpers.tweenProperty(ptStroke, { Color = if enActive then COLORS.separator else COLORS.primary }, 0.2) end

			-- Aplica e salva imediatamente + rebuild
			callbacks.onSettingsChanged(lang, UIHelpers.getCurrentTheme())
		end

		enPill.MouseButton1Click:Connect(function() updateLangSelection("en") end)
		ptPill.MouseButton1Click:Connect(function() updateLangSelection("pt-br") end)

		UIHelpers.criarSeparador(settingsPage).LayoutOrder = 5

		-- ── Secao Tema ──
		UIHelpers.criarLabel(settingsPage, {
			text = Locale.get("themeSection"),
			size = UDim2.new(1, 0, 0, 18),
			bold = true, textSize = 13,
		}).LayoutOrder = 6

		local currentThemeName = UIHelpers.getCurrentTheme()

		-- Helper: criar card de tema com preview de cores
		local function criarThemeCard(parent: GuiObject, themeName: string, labelKey: string, descKey: string, order: number): TextButton
			local isActive = themeName == currentThemeName
			local themeColors = UIHelpers.THEMES[themeName]

			local card = Instance.new("TextButton")
			card.Name = "Theme_" .. themeName
			card.Size = UDim2.new(1, 0, 0, 72)
			card.BackgroundColor3 = COLORS.surface
			card.Text = ""
			card.AutoButtonColor = false
			card.LayoutOrder = order
			card.Parent = parent
			UIHelpers.criarCorner(card, 10)

			local stroke = UIHelpers.criarStroke(card, if isActive then COLORS.primary else COLORS.separator, if isActive then 2 else 1)

			-- Nome do tema
			local nameLabel = Instance.new("TextLabel")
			nameLabel.Size = UDim2.new(1, -20, 0, 18)
			nameLabel.Position = UDim2.new(0, 10, 0, 8)
			nameLabel.BackgroundTransparency = 1
			nameLabel.Text = Locale.get(labelKey)
			nameLabel.TextColor3 = if isActive then COLORS.primary else COLORS.text
			nameLabel.TextSize = 13
			nameLabel.Font = Enum.Font.GothamBold
			nameLabel.TextXAlignment = Enum.TextXAlignment.Left
			nameLabel.Parent = card

			-- Descricao
			local descLabel = Instance.new("TextLabel")
			descLabel.Size = UDim2.new(1, -20, 0, 14)
			descLabel.Position = UDim2.new(0, 10, 0, 26)
			descLabel.BackgroundTransparency = 1
			descLabel.Text = Locale.get(descKey)
			descLabel.TextColor3 = COLORS.textDim
			descLabel.TextSize = 10
			descLabel.Font = Enum.Font.GothamMedium
			descLabel.TextXAlignment = Enum.TextXAlignment.Left
			descLabel.Parent = card

			-- Preview de cores (5 quadradinhos)
			local previewFrame = Instance.new("Frame")
			previewFrame.Size = UDim2.new(0, 130, 0, 18)
			previewFrame.Position = UDim2.new(0, 10, 0, 46)
			previewFrame.BackgroundTransparency = 1
			previewFrame.Parent = card

			local previewLayout = Instance.new("UIListLayout")
			previewLayout.FillDirection = Enum.FillDirection.Horizontal
			previewLayout.Padding = UDim.new(0, 4)
			previewLayout.Parent = previewFrame

			local previewColors = {
				themeColors.background,
				themeColors.primary,
				themeColors.surface,
				themeColors.green,
				themeColors.red,
			}

			for ci, color in previewColors do
				local swatch = Instance.new("Frame")
				swatch.Size = UDim2.new(0, 22, 0, 18)
				swatch.BackgroundColor3 = color
				swatch.BorderSizePixel = 0
				swatch.LayoutOrder = ci
				swatch.Parent = previewFrame
				UIHelpers.criarCorner(swatch, 4)
			end

			return card
		end

		local defaultCard = criarThemeCard(settingsPage, "default", "themeDefault", "themeDefaultDesc", 7)
		local vampireCard = criarThemeCard(settingsPage, "vampire", "themeVampire", "themeVampireDesc", 8)

		local function updateThemeSelection(themeName: string)
			currentThemeName = themeName
			-- Atualiza visuals dos cards
			local defStroke = defaultCard:FindFirstChildOfClass("UIStroke")
			local vampStroke = vampireCard:FindFirstChildOfClass("UIStroke")
			local defActive = themeName == "default"

			UIHelpers.tweenProperty(defaultCard, { BackgroundColor3 = COLORS.surface }, 0.2)
			UIHelpers.tweenProperty(vampireCard, { BackgroundColor3 = COLORS.surface }, 0.2)

			if defStroke then UIHelpers.tweenProperty(defStroke, { Color = if defActive then COLORS.primary else COLORS.separator, Thickness = if defActive then 2 else 1 }, 0.2) end
			if vampStroke then UIHelpers.tweenProperty(vampStroke, { Color = if defActive then COLORS.separator else COLORS.primary, Thickness = if defActive then 1 else 2 }, 0.2) end

			-- Nome do tema muda de cor
			local defName = defaultCard:FindFirstChild("TextLabel")
			local vampName = vampireCard:FindFirstChild("TextLabel")
			-- Pegar pelo Name nao funciona, vamos iterar
			for _, child in defaultCard:GetChildren() do
				if child:IsA("TextLabel") and child.Font == Enum.Font.GothamBold then
					UIHelpers.tweenProperty(child, { TextColor3 = if defActive then COLORS.primary else COLORS.text }, 0.2)
					break
				end
			end
			for _, child in vampireCard:GetChildren() do
				if child:IsA("TextLabel") and child.Font == Enum.Font.GothamBold then
					UIHelpers.tweenProperty(child, { TextColor3 = if defActive then COLORS.text else COLORS.primary }, 0.2)
					break
				end
			end

			-- Aplica e rebuild
			callbacks.onSettingsChanged(currentLang, themeName)
		end

		defaultCard.MouseButton1Click:Connect(function() updateThemeSelection("default") end)
		vampireCard.MouseButton1Click:Connect(function() updateThemeSelection("vampire") end)

		UIHelpers.criarSeparador(settingsPage).LayoutOrder = 9

		-- Creditos na pagina de settings tambem
		local settingsCreditsFrame = Instance.new("Frame")
		settingsCreditsFrame.Name = "SettingsCredits"
		settingsCreditsFrame.Size = UDim2.new(1, 0, 0, 60)
		settingsCreditsFrame.BackgroundTransparency = 1
		settingsCreditsFrame.LayoutOrder = 10
		settingsCreditsFrame.Parent = settingsPage

		-- Avatar circular
		local settingsAvatar = Instance.new("ImageLabel")
		settingsAvatar.Size = UDim2.new(0, 44, 0, 44)
		settingsAvatar.Position = UDim2.new(0.5, -52, 0, 8)
		settingsAvatar.BackgroundColor3 = COLORS.surface
		settingsAvatar.Image = "rbxthumb://type=AvatarHeadShot&id=8528429020&w=150&h=150"
		settingsAvatar.ScaleType = Enum.ScaleType.Fit
		settingsAvatar.Parent = settingsCreditsFrame
		UIHelpers.criarCorner(settingsAvatar, 22)
		UIHelpers.criarStroke(settingsAvatar, COLORS.primary, 2)

		local settingsNameLabel = Instance.new("TextLabel")
		settingsNameLabel.Size = UDim2.new(0, 100, 0, 44)
		settingsNameLabel.Position = UDim2.new(0.5, 0, 0, 8)
		settingsNameLabel.BackgroundTransparency = 1
		settingsNameLabel.RichText = true
		settingsNameLabel.Text = '<font color="#999">' .. Locale.get("credits") .. '</font>'
		settingsNameLabel.TextColor3 = COLORS.text
		settingsNameLabel.TextSize = 11
		settingsNameLabel.Font = Enum.Font.GothamMedium
		settingsNameLabel.TextXAlignment = Enum.TextXAlignment.Left
		settingsNameLabel.TextYAlignment = Enum.TextYAlignment.Center
		settingsNameLabel.Parent = settingsCreditsFrame

		-- ══════════════════════════════════════════════════════════
		-- Return refs
		-- ══════════════════════════════════════════════════════════
		return {
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
			-- Paineis visuais
			shopPanel = shopPanelApi,
		}
	end

	-- Constroi pela primeira vez
	local elements = buildContent()

	-- Funcao de rebuild (chamada ao trocar tema/idioma)
	local function rebuild()
		local newElements = buildContent()
		-- Atualiza referencia no return
		for key, val in newElements do
			elements[key] = val
		end
	end

	-- Expoe widget, elements e rebuild
	elements.widget = widget
	elements.rebuild = rebuild

	return elements
end

return UI
