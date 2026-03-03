--[[
	vulpy-rig-kit | ShopPanel
	Painel da loja: categorias + subcategorias + busca + grid de itens.
	Layout: tudo fixo no topo, so o grid faz scroll.
]]

local UIHelpers = require(script.Parent.Parent.UIHelpers)
local Locale = require(script.Parent.Parent.Locale)
local ShopService = require(script.Parent.Parent.ShopService)
local CategoryTabs = require(script.Parent.CategoryTabs)
local ItemCard = require(script.Parent.ItemCard)

local COLORS = UIHelpers.COLORS

local ShopPanel = {}

function ShopPanel.create(parent: GuiObject, callbacks: {
	onItemSelected: (any) -> (),
	setStatus: (string) -> (),
	onLimparRig: () -> (),
})
	-- Container = Frame que preenche tudo
	local container = Instance.new("Frame")
	container.Name = "ShopPanel"
	container.Size = UDim2.new(1, 0, 1, 0)
	container.BackgroundTransparency = 1
	container.Parent = parent

	-- Topo fixo (categorias + busca)
	local topSection = Instance.new("Frame")
	topSection.Name = "TopSection"
	topSection.Size = UDim2.new(1, 0, 0, 0)
	topSection.BackgroundTransparency = 1
	topSection.Position = UDim2.new(0, 0, 0, 0)
	topSection.Parent = container

	local topLayout = Instance.new("UIListLayout")
	topLayout.Padding = UDim.new(0, 6)
	topLayout.SortOrder = Enum.SortOrder.LayoutOrder
	topLayout.Parent = topSection

	local topPad = Instance.new("UIPadding")
	topPad.PaddingTop = UDim.new(0, 8)
	topPad.PaddingLeft = UDim.new(0, 10)
	topPad.PaddingRight = UDim.new(0, 10)
	topPad.Parent = topSection

	-- Estado
	local currentMainCat = 1
	local currentSubCat = 1
	local currentKeyword = ""
	local currentItems: { any } = {}
	local isLoading = false
	local nextCursor: string? = nil
	local itemCards: { Instance } = {}

	-- Forward declare
	local doSearch: () -> ()

	-- ═══════════════════════════════════════════════════
	-- Traduz labels das categorias para exibicao
	-- ═══════════════════════════════════════════════════
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

	-- ═══════════════════════════════════════════════════
	-- Category tabs
	-- ═══════════════════════════════════════════════════
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
	local tabs = CategoryTabs.create(topSection, translatedCats, onMainCatChanged, onSubCatChanged)
	tabs.getContainer().LayoutOrder = 1

	-- ═══════════════════════════════════════════════════
	-- Search row
	-- ═══════════════════════════════════════════════════
	local searchRow = Instance.new("Frame")
	searchRow.Name = "SearchRow"
	searchRow.Size = UDim2.new(1, 0, 0, 32)
	searchRow.BackgroundTransparency = 1
	searchRow.LayoutOrder = 2
	searchRow.Parent = topSection

	local searchLayout = Instance.new("UIListLayout")
	searchLayout.FillDirection = Enum.FillDirection.Horizontal
	searchLayout.Padding = UDim.new(0, 6)
	searchLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	searchLayout.Parent = searchRow

	local searchInput = UIHelpers.criarInput(searchRow, {
		size = UDim2.new(1, -74, 1, 0),
		placeholder = Locale.get("searchPlaceholder"),
	})

	local searchBtn = UIHelpers.criarBotao(searchRow, {
		text = Locale.get("searchButton"),
		size = UDim2.new(0, 68, 1, 0),
		color = COLORS.primary,
	})
	searchBtn.Font = Enum.Font.GothamBold
	searchBtn.TextSize = 11

	-- Botao Limpar Rig
	local limparBtn = UIHelpers.criarBotao(topSection, {
		text = Locale.get("cleanRigButton"),
		size = UDim2.new(1, 0, 0, 30),
		color = COLORS.red,
	})
	limparBtn.Font = Enum.Font.GothamBold
	limparBtn.TextSize = 11
	limparBtn.LayoutOrder = 3

	limparBtn.MouseButton1Click:Connect(function()
		callbacks.onLimparRig()
	end)

	-- Bundle row compacto (mesma linha: input + botao)
	local bundleRow = Instance.new("Frame")
	bundleRow.Name = "BundleRow"
	bundleRow.Size = UDim2.new(1, 0, 0, 28)
	bundleRow.BackgroundTransparency = 1
	bundleRow.LayoutOrder = 4
	bundleRow.Parent = topSection

	local bundleRowLayout = Instance.new("UIListLayout")
	bundleRowLayout.FillDirection = Enum.FillDirection.Horizontal
	bundleRowLayout.Padding = UDim.new(0, 6)
	bundleRowLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	bundleRowLayout.Parent = bundleRow

	local bundleInput = UIHelpers.criarInput(bundleRow, {
		size = UDim2.new(1, -74, 1, 0),
		placeholder = Locale.get("bundleIdPlaceholder"),
	})

	local bundleLoadBtn = UIHelpers.criarBotao(bundleRow, {
		text = Locale.get("bundleLoad"),
		size = UDim2.new(0, 68, 1, 0),
		color = COLORS.surface,
	})
	bundleLoadBtn.Font = Enum.Font.GothamBold
	bundleLoadBtn.TextSize = 10

	-- Results label
	local resultsLabel = UIHelpers.criarLabel(topSection, {
		text = Locale.get("chooseCategory"),
		size = UDim2.new(1, 0, 0, 14),
		color = COLORS.textDim,
		textSize = 10,
	})
	resultsLabel.LayoutOrder = 5

	-- Calcula altura do topo apos layout
	local TOP_HEIGHT = 192

	-- ═══════════════════════════════════════════════════
	-- Grid scroll (preenche o resto)
	-- ═══════════════════════════════════════════════════
	local gridScroll = Instance.new("ScrollingFrame")
	gridScroll.Name = "GridScroll"
	gridScroll.Size = UDim2.new(1, 0, 1, -TOP_HEIGHT)
	gridScroll.Position = UDim2.new(0, 0, 0, TOP_HEIGHT)
	gridScroll.BackgroundTransparency = 1
	gridScroll.ScrollBarThickness = 4
	gridScroll.ScrollBarImageColor3 = COLORS.separator
	gridScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	gridScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	gridScroll.Parent = container

	local gridLayout = Instance.new("UIGridLayout")
	gridLayout.CellSize = UDim2.new(0.5, -6, 0, 130)
	gridLayout.CellPadding = UDim2.new(0, 8, 0, 8)
	gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
	gridLayout.Parent = gridScroll

	local gridPad = Instance.new("UIPadding")
	gridPad.PaddingTop = UDim.new(0, 4)
	gridPad.PaddingLeft = UDim.new(0, 10)
	gridPad.PaddingRight = UDim.new(0, 10)
	gridPad.PaddingBottom = UDim.new(0, 10)
	gridPad.Parent = gridScroll

	-- Loading indicator
	local loadingLabel = Instance.new("TextLabel")
	loadingLabel.Name = "Loading"
	loadingLabel.Size = UDim2.new(1, 0, 0, 40)
	loadingLabel.BackgroundTransparency = 1
	loadingLabel.Text = Locale.get("searching")
	loadingLabel.TextColor3 = COLORS.textDim
	loadingLabel.TextSize = 12
	loadingLabel.Font = Enum.Font.GothamMedium
	loadingLabel.Visible = false
	loadingLabel.Parent = gridScroll

	-- ═══════════════════════════════════════════════════
	-- Helpers
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
			local card = ItemCard.create(gridScroll, item, #itemCards + i, function(clickedItem)
				callbacks.onItemSelected(clickedItem)
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
			-- Busca por ID direto?
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

			-- Busca normal por categoria + keyword
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

	-- ═══════════════════════════════════════════════════
	-- Infinite scroll
	-- ═══════════════════════════════════════════════════
	gridScroll:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
		if isLoading or not nextCursor then return end
		local canvasH = gridScroll.AbsoluteCanvasSize.Y
		local frameH = gridScroll.AbsoluteSize.Y
		local scrollY = gridScroll.CanvasPosition.Y
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

	-- ═══════════════════════════════════════════════════
	-- Bundle load
	-- ═══════════════════════════════════════════════════
	local function doLoadBundle()
		local bundleId = tonumber(bundleInput.Text)
		if not bundleId then return end
		if isLoading then return end

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
		if enterPressed then
			doLoadBundle()
		end
	end)

	-- ═══════════════════════════════════════════════════
	-- Events
	-- ═══════════════════════════════════════════════════
	searchBtn.MouseButton1Click:Connect(doSearch)

	searchInput.FocusLost:Connect(function(enterPressed)
		if enterPressed then
			doSearch()
		end
	end)

	-- Busca inicial ao criar
	task.defer(doSearch)

	-- API
	local api = {}

	function api.getContainer()
		return container
	end

	function api.refresh()
		doSearch()
	end

	function api.destroy()
		clearGrid()
		tabs.destroy()
		container:Destroy()
	end

	return api
end

return ShopPanel
