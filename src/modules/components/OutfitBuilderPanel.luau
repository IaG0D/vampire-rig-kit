--[[
	vulpy-rig-kit | OutfitBuilderPanel
	Painel do Outfit Builder: duas telas.
	Tela 1: Escolher avatar base (nick/userId + amigos)
	Tela 2: Preview + itens adicionados + acoes (topo fixo) + catalogo (scroll)
]]

local Players = game:GetService("Players")

local UIHelpers = require(script.Parent.Parent.UIHelpers)
local Locale = require(script.Parent.Parent.Locale)
local ShopService = require(script.Parent.Parent.ShopService)
local OutfitBuilderService = require(script.Parent.Parent.OutfitBuilderService)
local RigCreatorService = require(script.Parent.Parent.RigCreatorService)
local FriendsService = require(script.Parent.Parent.FriendsService)
local CategoryTabs = require(script.Parent.CategoryTabs)
local ItemCard = require(script.Parent.ItemCard)
local RigPreview = require(script.Parent.RigPreview)

local COLORS = UIHelpers.COLORS

local OutfitBuilderPanel = {}

function OutfitBuilderPanel.create(parent: GuiObject, callbacks: {
	setStatus: (string) -> (),
	onRigCreated: (Model) -> (),
})
	-- Container principal
	local container = Instance.new("Frame")
	container.Name = "OutfitBuilderPanel"
	container.Size = UDim2.new(1, 0, 1, 0)
	container.BackgroundTransparency = 1
	container.Parent = parent

	-- ═══════════════════════════════════════════════════
	-- Tela 1: BASE AVATAR (scroll)
	-- ═══════════════════════════════════════════════════
	local baseScreen = Instance.new("ScrollingFrame")
	baseScreen.Name = "BaseScreen"
	baseScreen.Size = UDim2.new(1, 0, 1, 0)
	baseScreen.BackgroundTransparency = 1
	baseScreen.BorderSizePixel = 0
	baseScreen.ScrollBarThickness = 4
	baseScreen.ScrollBarImageColor3 = COLORS.separator
	baseScreen.AutomaticCanvasSize = Enum.AutomaticSize.Y
	baseScreen.CanvasSize = UDim2.new(0, 0, 0, 0)
	baseScreen.Parent = container

	local baseLayout = Instance.new("UIListLayout")
	baseLayout.SortOrder = Enum.SortOrder.LayoutOrder
	baseLayout.Padding = UDim.new(0, 8)
	baseLayout.Parent = baseScreen

	local basePad = Instance.new("UIPadding")
	basePad.PaddingTop = UDim.new(0, 12)
	basePad.PaddingBottom = UDim.new(0, 12)
	basePad.PaddingLeft = UDim.new(0, 14)
	basePad.PaddingRight = UDim.new(0, 14)
	basePad.Parent = baseScreen

	-- ═══════════════════════════════════════════════════
	-- Tela 2: BUILD
	-- ═══════════════════════════════════════════════════
	local buildScreen = Instance.new("Frame")
	buildScreen.Name = "BuildScreen"
	buildScreen.Size = UDim2.new(1, 0, 1, 0)
	buildScreen.BackgroundTransparency = 1
	buildScreen.Visible = false
	buildScreen.Parent = container

	local function switchScreen(screen: string)
		baseScreen.Visible = screen == "base"
		buildScreen.Visible = screen == "build"
	end

	-- ═══════════════════════════════════════════════════
	-- BASE SCREEN: conteudo
	-- ═══════════════════════════════════════════════════

	-- Header
	local headerLabel = UIHelpers.criarLabel(baseScreen, {
		text = Locale.get("outfitBuilderTitle"),
		size = UDim2.new(1, 0, 0, 20),
		bold = true, textSize = 14,
		color = COLORS.primary,
	})
	headerLabel.LayoutOrder = 1

	UIHelpers.criarLabel(baseScreen, {
		text = Locale.get("outfitBuilderDesc"),
		size = UDim2.new(1, 0, 0, 32),
		color = COLORS.textDim, textSize = 10,
	}).LayoutOrder = 2

	UIHelpers.criarSeparador(baseScreen).LayoutOrder = 3

	UIHelpers.criarLabel(baseScreen, {
		text = Locale.get("usernameOrId"),
		size = UDim2.new(1, 0, 0, 16),
		bold = true, textSize = 12,
	}).LayoutOrder = 4

	-- Row: input + Go
	local inputRow = Instance.new("Frame")
	inputRow.Name = "InputRow"
	inputRow.Size = UDim2.new(1, 0, 0, 34)
	inputRow.BackgroundTransparency = 1
	inputRow.LayoutOrder = 5
	inputRow.Parent = baseScreen

	local inputRowLayout = Instance.new("UIListLayout")
	inputRowLayout.FillDirection = Enum.FillDirection.Horizontal
	inputRowLayout.Padding = UDim.new(0, 6)
	inputRowLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	inputRowLayout.Parent = inputRow

	local baseInput = UIHelpers.criarInput(inputRow, {
		size = UDim2.new(1, -54, 0, 34),
		placeholder = Locale.get("usernameOrIdPlaceholder"),
	})
	baseInput.LayoutOrder = 1

	local goButton = UIHelpers.criarBotao(inputRow, {
		text = Locale.get("goButton"),
		size = UDim2.new(0, 48, 0, 34),
		color = COLORS.primary,
	})
	goButton.LayoutOrder = 2

	UIHelpers.criarSeparador(baseScreen).LayoutOrder = 6

	-- Amigos
	UIHelpers.criarLabel(baseScreen, {
		text = Locale.get("friendsTitle"),
		size = UDim2.new(1, 0, 0, 20),
		bold = true, textSize = 14,
		color = COLORS.primary,
	}).LayoutOrder = 7

	local friendsInputRow = Instance.new("Frame")
	friendsInputRow.Name = "FriendsInputRow"
	friendsInputRow.Size = UDim2.new(1, 0, 0, 34)
	friendsInputRow.BackgroundTransparency = 1
	friendsInputRow.LayoutOrder = 8
	friendsInputRow.Parent = baseScreen

	local friendsInputLayout = Instance.new("UIListLayout")
	friendsInputLayout.FillDirection = Enum.FillDirection.Horizontal
	friendsInputLayout.Padding = UDim.new(0, 6)
	friendsInputLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	friendsInputLayout.Parent = friendsInputRow

	local friendsSearchInput = UIHelpers.criarInput(friendsInputRow, {
		size = UDim2.new(1, -80, 0, 34),
		placeholder = Locale.get("friendsPlaceholder"),
	})
	friendsSearchInput.LayoutOrder = 1

	local friendsLoadButton = UIHelpers.criarBotao(friendsInputRow, {
		text = Locale.get("friendsLoadButton"),
		size = UDim2.new(0, 74, 0, 34),
		color = COLORS.primary,
	})
	friendsLoadButton.LayoutOrder = 2

	local friendsStatusLabel = UIHelpers.criarLabel(baseScreen, {
		text = Locale.get("friendsLoading"),
		size = UDim2.new(1, 0, 0, 16),
		color = COLORS.textDim, textSize = 11,
	})
	friendsStatusLabel.LayoutOrder = 9

	local friendsGrid = Instance.new("Frame")
	friendsGrid.Name = "FriendsGrid"
	friendsGrid.Size = UDim2.new(1, 0, 0, 0)
	friendsGrid.AutomaticSize = Enum.AutomaticSize.Y
	friendsGrid.BackgroundTransparency = 1
	friendsGrid.LayoutOrder = 10
	friendsGrid.Parent = baseScreen

	local gridLayout = Instance.new("UIGridLayout")
	gridLayout.CellSize = UDim2.new(0, 80, 0, 100)
	gridLayout.CellPadding = UDim2.new(0, 8, 0, 8)
	gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
	gridLayout.FillDirection = Enum.FillDirection.Horizontal
	gridLayout.Parent = friendsGrid

	-- Estado amigos
	local friendsLoadId = 0

	-- ═══════════════════════════════════════════════════
	-- Preview + funcoes de update
	-- ═══════════════════════════════════════════════════
	local previewApi: any = nil
	local previewUpdateId = 0

	local function atualizarPreview()
		if not previewApi then return end
		previewUpdateId += 1
		local myId = previewUpdateId

		task.spawn(function()
			-- Debounce
			task.wait(0.5)
			if myId ~= previewUpdateId then return end

			local tempModel = OutfitBuilderService.criarPreviewModel()
			if myId ~= previewUpdateId then return end

			-- O Service gerencia o ciclo de vida do tempModel (nao destruir aqui)
			if tempModel then
				previewApi.setRig(tempModel)
			end
		end)
	end

	-- Forward declare
	local atualizarListaItens: () -> ()

	local function irParaBuild(userId: number, username: string)
		callbacks.setStatus(Locale.get("friendsLoading"))

		task.spawn(function()
			local ok, err = OutfitBuilderService.setBaseAvatar(userId, username)
			if not ok then
				callbacks.setStatus(Locale.get("baseAvatarError") .. (err and (": " .. err) or ""))
				return
			end

			callbacks.setStatus(Locale.fmt("baseAvatarLoaded", username))
			switchScreen("build")

			-- Atualiza label do base
			local baseLabel = buildScreen:FindFirstChild("BaseLabel", true)
			if baseLabel then
				(baseLabel :: TextLabel).Text = Locale.fmt("baseAvatarLabel", username)
			end

			-- Atualiza preview e lista
			atualizarPreview()
			if atualizarListaItens then atualizarListaItens() end
		end)
	end

	-- Go button / Enter
	local function irParaConfirmacaoBase()
		local input = baseInput.Text
		if input == "" then
			callbacks.setStatus(Locale.get("typeUsernameOrId"))
			return
		end

		task.spawn(function()
			callbacks.setStatus(Locale.get("friendsLoading"))

			local userId, err = RigCreatorService.resolverUserId(input)
			if not userId then
				callbacks.setStatus(Locale.get("baseAvatarError"))
				return
			end

			local nameOk, displayName = pcall(function()
				return Players:GetNameFromUserIdAsync(userId)
			end)
			local nome = if nameOk and displayName then displayName else input

			irParaBuild(userId, nome)
		end)
	end

	goButton.MouseButton1Click:Connect(irParaConfirmacaoBase)
	baseInput.FocusLost:Connect(function(enterPressed)
		if enterPressed then irParaConfirmacaoBase() end
	end)

	-- ═══════════════════════════════════════════════════
	-- Carregar amigos no grid
	-- ═══════════════════════════════════════════════════
	local function carregarAmigos(userId: number)
		friendsLoadId += 1
		local myLoadId = friendsLoadId

		for _, child in friendsGrid:GetChildren() do
			if child:IsA("ImageButton") then child:Destroy() end
		end
		friendsStatusLabel.Visible = true
		friendsStatusLabel.Text = Locale.get("friendsLoading")

		task.spawn(function()
			local amigos, err = FriendsService.buscarAmigos(userId)
			if myLoadId ~= friendsLoadId then return end

			if not amigos or #amigos == 0 then
				friendsStatusLabel.Text = if err then Locale.get("friendsError") else Locale.get("friendsNone")
				return
			end

			friendsStatusLabel.Visible = false

			for i, friend in amigos do
				if myLoadId ~= friendsLoadId then return end

				local card = Instance.new("ImageButton")
				card.Name = "Friend_" .. friend.Id
				card.Size = UDim2.new(0, 80, 0, 100)
				card.BackgroundColor3 = COLORS.surface
				card.AutoButtonColor = true
				card.LayoutOrder = i
				card.Parent = friendsGrid
				UIHelpers.criarCorner(card, 8)
				UIHelpers.criarStroke(card, COLORS.cardBorder, 1)

				local avatar = Instance.new("ImageLabel")
				avatar.Name = "Avatar"
				avatar.Size = UDim2.new(0, 56, 0, 56)
				avatar.Position = UDim2.new(0.5, -28, 0, 6)
				avatar.BackgroundColor3 = COLORS.input
				avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. friend.Id .. "&w=150&h=150"
				avatar.ScaleType = Enum.ScaleType.Fit
				avatar.Parent = card
				UIHelpers.criarCorner(avatar, 28)

				local nameLabel = Instance.new("TextLabel")
				nameLabel.Name = "NameLabel"
				nameLabel.Size = UDim2.new(1, -8, 0, 28)
				nameLabel.Position = UDim2.new(0, 4, 0, 66)
				nameLabel.BackgroundTransparency = 1
				nameLabel.Text = friend.DisplayName
				nameLabel.TextColor3 = COLORS.text
				nameLabel.TextSize = 10
				nameLabel.Font = Enum.Font.GothamMedium
				nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
				nameLabel.Parent = card

				card.MouseEnter:Connect(function()
					local stroke = card:FindFirstChildOfClass("UIStroke")
					if stroke then UIHelpers.tweenProperty(stroke, { Color = COLORS.primary }, 0.15) end
				end)
				card.MouseLeave:Connect(function()
					local stroke = card:FindFirstChildOfClass("UIStroke")
					if stroke then UIHelpers.tweenProperty(stroke, { Color = COLORS.cardBorder }, 0.15) end
				end)

				card.MouseButton1Click:Connect(function()
					irParaBuild(friend.Id, friend.DisplayName)
				end)
			end
		end)
	end

	-- LOAD button
	local function carregarAmigosDoInput()
		local input = friendsSearchInput.Text
		if input == "" then return end
		task.spawn(function()
			local userId, err = RigCreatorService.resolverUserId(input)
			if not userId then
				friendsStatusLabel.Visible = true
				friendsStatusLabel.Text = Locale.get("friendsError")
				return
			end
			carregarAmigos(userId)
		end)
	end

	friendsLoadButton.MouseButton1Click:Connect(carregarAmigosDoInput)
	friendsSearchInput.FocusLost:Connect(function(enterPressed)
		if enterPressed then carregarAmigosDoInput() end
	end)

	-- Auto-load amigos do usuario logado
	do
		local studioUserId = FriendsService.getStudioUserId()
		if studioUserId == 0 then
			friendsStatusLabel.Text = Locale.get("friendsError")
		else
			carregarAmigos(studioUserId)
		end
	end

	-- ═══════════════════════════════════════════════════
	-- BUILD SCREEN: topo fixo (preview/itens/acoes/catalogo tabs)
	--              + scroll inferior (grid do catalogo)
	-- ═══════════════════════════════════════════════════

	-- Topo fixo com AutomaticSize
	local buildTop = Instance.new("Frame")
	buildTop.Name = "BuildTop"
	buildTop.Size = UDim2.new(1, 0, 0, 0)
	buildTop.AutomaticSize = Enum.AutomaticSize.Y
	buildTop.BackgroundTransparency = 1
	buildTop.Parent = buildScreen

	local buildTopLayout = Instance.new("UIListLayout")
	buildTopLayout.Padding = UDim.new(0, 4)
	buildTopLayout.SortOrder = Enum.SortOrder.LayoutOrder
	buildTopLayout.Parent = buildTop

	local buildTopPad = Instance.new("UIPadding")
	buildTopPad.PaddingTop = UDim.new(0, 6)
	buildTopPad.PaddingBottom = UDim.new(0, 4)
	buildTopPad.PaddingLeft = UDim.new(0, 10)
	buildTopPad.PaddingRight = UDim.new(0, 10)
	buildTopPad.Parent = buildTop

	-- 1. Back + Base label row
	local backRow = Instance.new("Frame")
	backRow.Name = "BackRow"
	backRow.Size = UDim2.new(1, 0, 0, 24)
	backRow.BackgroundTransparency = 1
	backRow.LayoutOrder = 1
	backRow.Parent = buildTop

	local backRowLayout = Instance.new("UIListLayout")
	backRowLayout.FillDirection = Enum.FillDirection.Horizontal
	backRowLayout.Padding = UDim.new(0, 8)
	backRowLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	backRowLayout.Parent = backRow

	local backBtn = UIHelpers.criarBotao(backRow, {
		text = "< " .. Locale.get("backButton"),
		size = UDim2.new(0, 60, 0, 22),
		color = COLORS.surface,
	})
	backBtn.TextSize = 9
	backBtn.LayoutOrder = 1

	backBtn.MouseButton1Click:Connect(function()
		switchScreen("base")
	end)

	local baseLabelText = Instance.new("TextLabel")
	baseLabelText.Name = "BaseLabel"
	baseLabelText.Size = UDim2.new(1, -68, 0, 22)
	baseLabelText.BackgroundTransparency = 1
	baseLabelText.Text = ""
	baseLabelText.TextColor3 = COLORS.primary
	baseLabelText.TextSize = 11
	baseLabelText.Font = Enum.Font.GothamBold
	baseLabelText.TextXAlignment = Enum.TextXAlignment.Left
	baseLabelText.TextTruncate = Enum.TextTruncate.AtEnd
	baseLabelText.LayoutOrder = 2
	baseLabelText.Parent = backRow

	-- 2. Preview 3D
	previewApi = RigPreview.create(buildTop, {
		height = 150,
		layoutOrder = 2,
	})

	-- 3. Itens adicionados: header
	local addedHeader = UIHelpers.criarLabel(buildTop, {
		text = Locale.get("noItemsAdded"),
		size = UDim2.new(1, 0, 0, 14),
		color = COLORS.textDim, textSize = 10,
	})
	addedHeader.LayoutOrder = 3

	-- 3b. Lista de itens adicionados
	local addedListFrame = Instance.new("Frame")
	addedListFrame.Name = "AddedList"
	addedListFrame.Size = UDim2.new(1, 0, 0, 0)
	addedListFrame.AutomaticSize = Enum.AutomaticSize.Y
	addedListFrame.BackgroundTransparency = 1
	addedListFrame.LayoutOrder = 4
	addedListFrame.Parent = buildTop

	local addedListLayout = Instance.new("UIListLayout")
	addedListLayout.Padding = UDim.new(0, 3)
	addedListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	addedListLayout.Parent = addedListFrame

	-- 4. Botoes: Limpar + Criar Rig
	local btnRow = Instance.new("Frame")
	btnRow.Name = "ButtonRow"
	btnRow.Size = UDim2.new(1, 0, 0, 32)
	btnRow.BackgroundTransparency = 1
	btnRow.LayoutOrder = 5
	btnRow.Parent = buildTop

	local btnRowLayout = Instance.new("UIListLayout")
	btnRowLayout.FillDirection = Enum.FillDirection.Horizontal
	btnRowLayout.Padding = UDim.new(0, 6)
	btnRowLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	btnRowLayout.Parent = btnRow

	local cleanBtn = UIHelpers.criarBotao(btnRow, {
		text = Locale.get("cleanItemsButton"),
		size = UDim2.new(0.3, -3, 1, 0),
		color = COLORS.red,
	})
	cleanBtn.Font = Enum.Font.GothamBold
	cleanBtn.TextSize = 10
	cleanBtn.LayoutOrder = 1

	local createBtn = UIHelpers.criarBotao(btnRow, {
		text = Locale.get("createOutfitRig"),
		size = UDim2.new(0.7, -3, 1, 0),
		color = COLORS.green,
	})
	createBtn.Font = Enum.Font.GothamBold
	createBtn.TextSize = 14
	createBtn.LayoutOrder = 2

	-- 5. Rig Name + Name Tag (compacto, lado a lado)
	local rigNameRow = Instance.new("Frame")
	rigNameRow.Name = "RigNameRow"
	rigNameRow.Size = UDim2.new(1, 0, 0, 28)
	rigNameRow.BackgroundTransparency = 1
	rigNameRow.LayoutOrder = 6
	rigNameRow.Parent = buildTop

	local rigNameRowLayout = Instance.new("UIListLayout")
	rigNameRowLayout.FillDirection = Enum.FillDirection.Horizontal
	rigNameRowLayout.Padding = UDim.new(0, 6)
	rigNameRowLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	rigNameRowLayout.Parent = rigNameRow

	local rigNameInput = UIHelpers.criarInput(rigNameRow, {
		size = UDim2.new(1, -110, 0, 28),
		placeholder = Locale.get("rigNamePlaceholder"),
	})
	rigNameInput.LayoutOrder = 1

	local nameTagToggle, getNameTagState = UIHelpers.criarToggle(rigNameRow, {
		label = Locale.get("nameTagLabel"),
		description = "",
		size = UDim2.new(0, 104, 0, 28),
		default = false,
	})
	nameTagToggle.LayoutOrder = 2

	-- 6. Separador
	UIHelpers.criarSeparador(buildTop).LayoutOrder = 7

	-- Estado catalogo
	local currentMainCat = 1
	local currentSubCat = 1
	local currentKeyword = ""
	local currentItems: { any } = {}
	local isLoading = false
	local nextCursor: string? = nil
	local itemCards: { Instance } = {}

	local doSearch: () -> ()

	-- 7. Category tabs
	local function translateCategories()
		local cats = {}
		for _, cat in ShopService.CATEGORIES do
			local translated = {
				key = cat.key,
				label = Locale.get(cat.label),
				categoryId = cat.categoryId,
				subcategories = {},
			}
			if cat.subcategories then
				for _, sub in cat.subcategories do
					table.insert(translated.subcategories, {
						key = sub.key,
						label = Locale.get(sub.label),
						subcategoryId = sub.subcategoryId,
					})
				end
			end
			table.insert(cats, translated)
		end
		return cats
	end

	local function onMainCatChanged(index: number)
		currentMainCat = index
		currentSubCat = 1
		task.defer(doSearch)
	end

	local function onSubCatChanged(index: number)
		currentSubCat = index
		task.defer(doSearch)
	end

	local translatedCats = translateCategories()
	local tabs = CategoryTabs.create(buildTop, translatedCats, onMainCatChanged, onSubCatChanged)
	tabs.getContainer().LayoutOrder = 8

	-- 8. Search row
	local searchRow = Instance.new("Frame")
	searchRow.Name = "SearchRow"
	searchRow.Size = UDim2.new(1, 0, 0, 28)
	searchRow.BackgroundTransparency = 1
	searchRow.LayoutOrder = 9
	searchRow.Parent = buildTop

	local searchLayout = Instance.new("UIListLayout")
	searchLayout.FillDirection = Enum.FillDirection.Horizontal
	searchLayout.Padding = UDim.new(0, 6)
	searchLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	searchLayout.Parent = searchRow

	local searchInput = UIHelpers.criarInput(searchRow, {
		size = UDim2.new(1, -68, 1, 0),
		placeholder = Locale.get("searchPlaceholder"),
	})

	local searchBtn = UIHelpers.criarBotao(searchRow, {
		text = Locale.get("searchButton"),
		size = UDim2.new(0, 62, 1, 0),
		color = COLORS.primary,
	})
	searchBtn.Font = Enum.Font.GothamBold
	searchBtn.TextSize = 10

	-- 9. Bundle row
	local bundleRow = Instance.new("Frame")
	bundleRow.Name = "BundleRow"
	bundleRow.Size = UDim2.new(1, 0, 0, 24)
	bundleRow.BackgroundTransparency = 1
	bundleRow.LayoutOrder = 10
	bundleRow.Parent = buildTop

	local bundleRowLayout = Instance.new("UIListLayout")
	bundleRowLayout.FillDirection = Enum.FillDirection.Horizontal
	bundleRowLayout.Padding = UDim.new(0, 6)
	bundleRowLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	bundleRowLayout.Parent = bundleRow

	local bundleInput = UIHelpers.criarInput(bundleRow, {
		size = UDim2.new(1, -68, 1, 0),
		placeholder = Locale.get("bundleIdPlaceholder"),
	})

	local bundleLoadBtn = UIHelpers.criarBotao(bundleRow, {
		text = Locale.get("bundleLoad"),
		size = UDim2.new(0, 62, 1, 0),
		color = COLORS.surface,
	})
	bundleLoadBtn.Font = Enum.Font.GothamBold
	bundleLoadBtn.TextSize = 9

	-- 10. Results label
	local resultsLabel = UIHelpers.criarLabel(buildTop, {
		text = Locale.get("chooseCategory"),
		size = UDim2.new(1, 0, 0, 12),
		color = COLORS.textDim,
		textSize = 9,
	})
	resultsLabel.LayoutOrder = 11

	-- ═══════════════════════════════════════════════════
	-- Scroll area (catalogo grid)
	-- Posicao dinamica: acompanha altura do buildTop
	-- ═══════════════════════════════════════════════════
	local buildScroll = Instance.new("ScrollingFrame")
	buildScroll.Name = "BuildScroll"
	buildScroll.Size = UDim2.new(1, 0, 1, 0)
	buildScroll.Position = UDim2.new(0, 0, 0, 0)
	buildScroll.BackgroundTransparency = 1
	buildScroll.ScrollBarThickness = 4
	buildScroll.ScrollBarImageColor3 = COLORS.separator
	buildScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	buildScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	buildScroll.Parent = buildScreen

	-- Ajusta posicao do scroll baseado na altura real do topo
	local function ajustarScrollPosition()
		local h = buildTopLayout.AbsoluteContentSize.Y + 16 -- padding top/bottom
		buildScroll.Size = UDim2.new(1, 0, 1, -h)
		buildScroll.Position = UDim2.new(0, 0, 0, h)
	end

	buildTopLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(ajustarScrollPosition)
	task.defer(ajustarScrollPosition)

	local buildScrollLayout = Instance.new("UIListLayout")
	buildScrollLayout.SortOrder = Enum.SortOrder.LayoutOrder
	buildScrollLayout.Padding = UDim.new(0, 8)
	buildScrollLayout.Parent = buildScroll

	local buildScrollPad = Instance.new("UIPadding")
	buildScrollPad.PaddingTop = UDim.new(0, 4)
	buildScrollPad.PaddingBottom = UDim.new(0, 12)
	buildScrollPad.PaddingLeft = UDim.new(0, 10)
	buildScrollPad.PaddingRight = UDim.new(0, 10)
	buildScrollPad.Parent = buildScroll

	-- Grid de itens do catalogo
	local catalogGrid = Instance.new("Frame")
	catalogGrid.Name = "CatalogGrid"
	catalogGrid.Size = UDim2.new(1, 0, 0, 0)
	catalogGrid.AutomaticSize = Enum.AutomaticSize.Y
	catalogGrid.BackgroundTransparency = 1
	catalogGrid.LayoutOrder = 1
	catalogGrid.Parent = buildScroll

	local catalogGridLayout = Instance.new("UIGridLayout")
	catalogGridLayout.CellSize = UDim2.new(0.5, -6, 0, 130)
	catalogGridLayout.CellPadding = UDim2.new(0, 8, 0, 8)
	catalogGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
	catalogGridLayout.Parent = catalogGrid

	-- Loading label
	local loadingLabel = Instance.new("TextLabel")
	loadingLabel.Name = "Loading"
	loadingLabel.Size = UDim2.new(1, 0, 0, 40)
	loadingLabel.BackgroundTransparency = 1
	loadingLabel.Text = Locale.get("searching")
	loadingLabel.TextColor3 = COLORS.textDim
	loadingLabel.TextSize = 12
	loadingLabel.Font = Enum.Font.GothamMedium
	loadingLabel.Visible = false
	loadingLabel.LayoutOrder = 2
	loadingLabel.Parent = buildScroll

	-- ═══════════════════════════════════════════════════
	-- Atualizar lista de itens adicionados
	-- ═══════════════════════════════════════════════════
	atualizarListaItens = function()
		-- Limpa lista atual
		for _, child in addedListFrame:GetChildren() do
			if child:IsA("Frame") and child.Name ~= "UIListLayout" then
				child:Destroy()
			end
		end

		local items = OutfitBuilderService.getAddedItems()

		if #items == 0 then
			addedHeader.Text = Locale.get("noItemsAdded")
			return
		end

		addedHeader.Text = Locale.fmt("addedItemsCount", #items)

		for i, item in items do
			local row = Instance.new("Frame")
			row.Name = "AddedItem_" .. item.assetId
			row.Size = UDim2.new(1, 0, 0, 24)
			row.BackgroundColor3 = COLORS.surface
			row.LayoutOrder = i
			row.Parent = addedListFrame
			UIHelpers.criarCorner(row, 5)

			-- Thumbnail pequena
			local thumb = Instance.new("ImageLabel")
			thumb.Size = UDim2.new(0, 20, 0, 20)
			thumb.Position = UDim2.new(0, 2, 0, 2)
			thumb.BackgroundTransparency = 1
			thumb.Image = "rbxthumb://type=Asset&id=" .. item.assetId .. "&w=150&h=150"
			thumb.ScaleType = Enum.ScaleType.Fit
			thumb.Parent = row
			UIHelpers.criarCorner(thumb, 3)

			-- Nome
			local nameLabel = Instance.new("TextLabel")
			nameLabel.Size = UDim2.new(1, -52, 1, 0)
			nameLabel.Position = UDim2.new(0, 26, 0, 0)
			nameLabel.BackgroundTransparency = 1
			nameLabel.Text = item.name
			nameLabel.TextColor3 = COLORS.text
			nameLabel.TextSize = 9
			nameLabel.Font = Enum.Font.GothamMedium
			nameLabel.TextXAlignment = Enum.TextXAlignment.Left
			nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
			nameLabel.Parent = row

			-- Botao [X] remover
			local removeBtn = Instance.new("TextButton")
			removeBtn.Size = UDim2.new(0, 20, 0, 20)
			removeBtn.Position = UDim2.new(1, -22, 0, 2)
			removeBtn.BackgroundColor3 = COLORS.red
			removeBtn.Text = "X"
			removeBtn.TextColor3 = Color3.new(1, 1, 1)
			removeBtn.TextSize = 9
			removeBtn.Font = Enum.Font.GothamBold
			removeBtn.AutoButtonColor = true
			removeBtn.Parent = row
			UIHelpers.criarCorner(removeBtn, 4)

			removeBtn.MouseButton1Click:Connect(function()
				OutfitBuilderService.removerItem(item.assetId)
				callbacks.setStatus(Locale.fmt("itemRemoved", item.name))
				atualizarListaItens()
				atualizarPreview()
			end)
		end
	end

	-- ═══════════════════════════════════════════════════
	-- Catalogo: helpers
	-- ═══════════════════════════════════════════════════
	local function getCurrentCat()
		return ShopService.CATEGORIES[currentMainCat]
	end

	local function getCurrentSub()
		local cat = getCurrentCat()
		if not cat or not cat.subcategories or #cat.subcategories == 0 then return nil end
		return cat.subcategories[currentSubCat]
	end

	local function clearGrid()
		for _, card in itemCards do
			card:Destroy()
		end
		itemCards = {}
		currentItems = {}
		nextCursor = nil
	end

	local function addItemsToGrid(items: { any })
		for i, item in items do
			local card = ItemCard.create(catalogGrid, item, #itemCards + i, function(clickedItem)
				-- Adicionar ao outfit
				task.spawn(function()
					local ok, err, name = OutfitBuilderService.adicionarItem(clickedItem.id)
					if ok then
						callbacks.setStatus(Locale.fmt("itemAdded", name or clickedItem.name or "Item"))
						atualizarListaItens()
						atualizarPreview()
					else
						callbacks.setStatus(err or Locale.get("applyFailed"))
					end
				end)
			end)
			table.insert(itemCards, card)
		end
	end

	-- ═══════════════════════════════════════════════════
	-- Busca principal
	-- ═══════════════════════════════════════════════════
	doSearch = function()
		if isLoading then return end
		isLoading = true

		clearGrid()
		loadingLabel.Visible = true
		loadingLabel.Text = Locale.get("searching")
		resultsLabel.Text = ""

		local keyword = searchInput.Text
		currentKeyword = keyword

		task.spawn(function()
			local assetId = tonumber(keyword)
			if assetId then
				local item = ShopService.buscarPorId(assetId)
				isLoading = false
				loadingLabel.Visible = false

				if item then
					currentItems = { item }
					resultsLabel.Text = Locale.fmt("results", 1)
					addItemsToGrid(currentItems)
					callbacks.setStatus(Locale.get("itemFound") .. item.name)
				else
					resultsLabel.Text = Locale.get("noResults")
					callbacks.setStatus(Locale.get("itemNotFound") .. tostring(assetId))
				end
				return
			end

			local cat = getCurrentCat()
			local sub = getCurrentSub()
			local categoryId = if cat then cat.categoryId else nil
			local subcategoryId = if sub then sub.subcategoryId else nil

			local result = ShopService.buscarCatalogo(keyword, categoryId, subcategoryId, 30)

			isLoading = false
			loadingLabel.Visible = false

			if result and result.items then
				nextCursor = result.nextPageCursor
				currentItems = result.items

				if #result.items > 0 then
					resultsLabel.Text = Locale.fmt("results", #result.items)
					addItemsToGrid(result.items)
					callbacks.setStatus(Locale.fmt("itemsFound", #result.items))
				else
					resultsLabel.Text = Locale.get("noResults")
					callbacks.setStatus(Locale.get("noItemFound"))
				end
			else
				resultsLabel.Text = Locale.get("searchError")
				callbacks.setStatus(Locale.get("catalogError"))
			end
		end)
	end

	-- Infinite scroll
	buildScroll:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
		if isLoading or not nextCursor then return end
		local canvasH = buildScroll.AbsoluteCanvasSize.Y
		local frameH = buildScroll.AbsoluteSize.Y
		local scrollY = buildScroll.CanvasPosition.Y
		if canvasH > 0 and canvasH - scrollY - frameH < 200 then
			isLoading = true
			loadingLabel.Visible = true
			loadingLabel.Text = Locale.get("loadingMore")

			task.spawn(function()
				local cat = getCurrentCat()
				local sub = getCurrentSub()
				local categoryId = if cat then cat.categoryId else nil
				local subcategoryId = if sub then sub.subcategoryId else nil

				local result = ShopService.buscarCatalogo(currentKeyword, categoryId, subcategoryId, 30, nextCursor)

				isLoading = false
				loadingLabel.Visible = false

				if result and result.items then
					nextCursor = result.nextPageCursor
					for _, item in result.items do
						table.insert(currentItems, item)
					end
					addItemsToGrid(result.items)
				end
			end)
		end
	end)

	-- Bundle load
	local function doLoadBundle()
		local bundleId = tonumber(bundleInput.Text)
		if not bundleId or isLoading then return end

		isLoading = true
		clearGrid()
		loadingLabel.Visible = true
		loadingLabel.Text = Locale.get("bundleLoading")
		resultsLabel.Text = ""

		task.spawn(function()
			local bundle = ShopService.buscarBundle(bundleId)

			isLoading = false
			loadingLabel.Visible = false

			if bundle and bundle.items and #bundle.items > 0 then
				currentItems = bundle.items
				resultsLabel.Text = Locale.fmt("bundleLoaded", bundle.name or "?", #bundle.items)
				addItemsToGrid(bundle.items)
				callbacks.setStatus(Locale.fmt("bundleLoaded", bundle.name or "?", #bundle.items))
			else
				resultsLabel.Text = Locale.get("bundleNotFound")
				callbacks.setStatus(Locale.get("bundleError"))
			end
		end)
	end

	bundleLoadBtn.MouseButton1Click:Connect(doLoadBundle)
	bundleInput.FocusLost:Connect(function(enterPressed)
		if enterPressed then doLoadBundle() end
	end)

	-- Search events
	searchBtn.MouseButton1Click:Connect(doSearch)
	searchInput.FocusLost:Connect(function(enterPressed)
		if enterPressed then doSearch() end
	end)

	-- Busca inicial
	task.defer(doSearch)

	-- ═══════════════════════════════════════════════════
	-- Botoes: Limpar e Criar Rig
	-- ═══════════════════════════════════════════════════
	cleanBtn.MouseButton1Click:Connect(function()
		local count = OutfitBuilderService.limpar()
		callbacks.setStatus(Locale.fmt("itemsCleaned", count))
		atualizarListaItens()
		atualizarPreview()
	end)

	createBtn.MouseButton1Click:Connect(function()
		if not OutfitBuilderService.hasBase() then
			callbacks.setStatus(Locale.get("noBaseAvatar"))
			return
		end

		local rigName = rigNameInput.Text
		if rigName == "" then
			local _, username = OutfitBuilderService.getBaseInfo()
			rigName = username or "OutfitRig"
		end

		local addNameTag = getNameTagState()

		callbacks.setStatus(Locale.get("creatingRig"))

		task.spawn(function()
			local model, err = OutfitBuilderService.criarRigFinal(rigName, workspace, addNameTag)
			if model then
				callbacks.onRigCreated(model)
			else
				callbacks.setStatus(Locale.get("outfitRigError") .. (err or "unknown"))
			end
		end)
	end)

	-- ═══════════════════════════════════════════════════
	-- API
	-- ═══════════════════════════════════════════════════
	local api = {}

	function api.destroy()
		clearGrid()
		tabs.destroy()
		if previewApi then previewApi.destroy() end
		OutfitBuilderService.reset()
		container:Destroy()
	end

	return api
end

return OutfitBuilderPanel
