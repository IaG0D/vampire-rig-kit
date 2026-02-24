--[[
	vulpy-rig-kit | CategoryTabs
	Tabs horizontais de categorias e subcategorias, estilo pills.
]]

local UIHelpers = require(script.Parent.Parent.UIHelpers)
local COLORS = UIHelpers.COLORS

local CategoryTabs = {}

local function criarPill(parent: GuiObject, text: string, height: number, isActive: boolean, onClick: () -> ()): TextButton
	local btn = Instance.new("TextButton")
	btn.Name = text
	btn.AutomaticSize = Enum.AutomaticSize.X
	btn.Size = UDim2.new(0, 0, 0, height)
	btn.BackgroundColor3 = if isActive then COLORS.tabActive else COLORS.tabInactive
	btn.Text = ""
	btn.AutoButtonColor = false
	btn.Parent = parent

	UIHelpers.criarCorner(btn, math.floor(height / 2))

	local pad = Instance.new("UIPadding")
	pad.PaddingLeft = UDim.new(0, 14)
	pad.PaddingRight = UDim.new(0, 14)
	pad.Parent = btn

	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.AutomaticSize = Enum.AutomaticSize.X
	label.Size = UDim2.new(0, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = if isActive then Color3.new(1, 1, 1) else COLORS.textDim
	label.TextSize = if height > 26 then 12 else 11
	label.Font = Enum.Font.GothamBold
	label.Parent = btn

	-- Hover
	btn.MouseEnter:Connect(function()
		if btn.BackgroundColor3 ~= COLORS.tabActive then
			UIHelpers.tweenProperty(btn, { BackgroundColor3 = COLORS.buttonHover }, 0.1)
		end
	end)

	btn.MouseLeave:Connect(function()
		if btn.BackgroundColor3 ~= COLORS.tabActive then
			UIHelpers.tweenProperty(btn, { BackgroundColor3 = COLORS.tabInactive }, 0.1)
		end
	end)

	btn.MouseButton1Click:Connect(onClick)

	return btn
end

function CategoryTabs.create(parent: GuiObject, categories: { any }, onMainSelected: (number) -> (), onSubSelected: (number) -> ())
	local container = Instance.new("Frame")
	container.Name = "CategoryTabs"
	container.Size = UDim2.new(1, 0, 0, 60)
	container.BackgroundTransparency = 1
	container.Parent = parent

	local containerLayout = Instance.new("UIListLayout")
	containerLayout.Padding = UDim.new(0, 4)
	containerLayout.Parent = container

	-- Main tabs scroll
	local mainScroll = Instance.new("ScrollingFrame")
	mainScroll.Name = "MainTabs"
	mainScroll.Size = UDim2.new(1, 0, 0, 30)
	mainScroll.BackgroundTransparency = 1
	mainScroll.ScrollBarThickness = 0
	mainScroll.ScrollingDirection = Enum.ScrollingDirection.X
	mainScroll.AutomaticCanvasSize = Enum.AutomaticSize.X
	mainScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	mainScroll.Parent = container

	local mainLayout = Instance.new("UIListLayout")
	mainLayout.FillDirection = Enum.FillDirection.Horizontal
	mainLayout.Padding = UDim.new(0, 6)
	mainLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	mainLayout.Parent = mainScroll

	-- Sub tabs scroll
	local subScroll = Instance.new("ScrollingFrame")
	subScroll.Name = "SubTabs"
	subScroll.Size = UDim2.new(1, 0, 0, 26)
	subScroll.BackgroundTransparency = 1
	subScroll.ScrollBarThickness = 0
	subScroll.ScrollingDirection = Enum.ScrollingDirection.X
	subScroll.AutomaticCanvasSize = Enum.AutomaticSize.X
	subScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	subScroll.Visible = false
	subScroll.Parent = container

	local subLayout = Instance.new("UIListLayout")
	subLayout.FillDirection = Enum.FillDirection.Horizontal
	subLayout.Padding = UDim.new(0, 4)
	subLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	subLayout.Parent = subScroll

	-- Estado
	local activeMain = 1
	local activeSub = 1
	local mainButtons: { TextButton } = {}
	local subButtons: { TextButton } = {}

	local function updateMainStyles()
		for i, btn in mainButtons do
			local isActive = i == activeMain
			UIHelpers.tweenProperty(btn, {
				BackgroundColor3 = if isActive then COLORS.tabActive else COLORS.tabInactive,
			}, 0.12)
			local label = btn:FindFirstChild("Label")
			if label then
				UIHelpers.tweenProperty(label, {
					TextColor3 = if isActive then Color3.new(1, 1, 1) else COLORS.textDim,
				}, 0.12)
			end
		end
	end

	local function updateSubStyles()
		for i, btn in subButtons do
			local isActive = i == activeSub
			UIHelpers.tweenProperty(btn, {
				BackgroundColor3 = if isActive then COLORS.tabActive else COLORS.tabInactive,
			}, 0.12)
			local label = btn:FindFirstChild("Label")
			if label then
				UIHelpers.tweenProperty(label, {
					TextColor3 = if isActive then Color3.new(1, 1, 1) else COLORS.textDim,
				}, 0.12)
			end
		end
	end

	local function buildSubTabs(categoryIndex: number)
		-- Limpa sub tabs existentes
		for _, btn in subButtons do
			btn:Destroy()
		end
		subButtons = {}
		activeSub = 1

		local cat = categories[categoryIndex]
		if not cat or not cat.subcategories or #cat.subcategories == 0 then
			subScroll.Visible = false
			container.Size = UDim2.new(1, 0, 0, 32)
			return
		end

		subScroll.Visible = true
		container.Size = UDim2.new(1, 0, 0, 60)

		for i, sub in cat.subcategories do
			local btn = criarPill(subScroll, sub.label, 24, i == 1, function()
				activeSub = i
				updateSubStyles()
				onSubSelected(i)
			end)
			table.insert(subButtons, btn)
		end
	end

	-- Cria main tabs
	for i, cat in categories do
		local btn = criarPill(mainScroll, cat.label, 28, i == 1, function()
			activeMain = i
			updateMainStyles()
			buildSubTabs(i)
			onMainSelected(i)
		end)
		table.insert(mainButtons, btn)
	end

	-- Build initial sub tabs
	buildSubTabs(1)

	local api = {}

	function api.getContainer()
		return container
	end

	function api.getActiveMain(): number
		return activeMain
	end

	function api.getActiveSub(): number
		return activeSub
	end

	function api.destroy()
		container:Destroy()
	end

	return api
end

return CategoryTabs
