--[[
	vulpy-rig-kit | ItemCard
	Card visual de um item do catalogo com thumbnail, nome e preco.
]]

local UIHelpers = require(script.Parent.Parent.UIHelpers)
local Locale = require(script.Parent.Parent.Locale)
local COLORS = UIHelpers.COLORS

local ItemCard = {}

function ItemCard.create(parent: GuiObject, item: {
	id: number,
	name: string,
	price: number?,
	creatorName: string?,
	thumbnail: string?,
}, layoutOrder: number, onClicked: (any) -> ()): TextButton
	local card = Instance.new("TextButton")
	card.Name = "Item_" .. tostring(item.id)
	card.Size = UDim2.new(1, 0, 0, 130)
	card.BackgroundColor3 = COLORS.cardBg
	card.Text = ""
	card.AutoButtonColor = false
	card.LayoutOrder = layoutOrder
	card.ClipsDescendants = true
	card.Parent = parent

	UIHelpers.criarCorner(card, 10)

	local stroke = UIHelpers.criarStroke(card, COLORS.cardBorder, 1)

	-- Thumbnail
	local thumbnail = Instance.new("ImageLabel")
	thumbnail.Name = "Thumbnail"
	thumbnail.Size = UDim2.new(1, -10, 0, 80)
	thumbnail.Position = UDim2.new(0, 5, 0, 5)
	thumbnail.BackgroundColor3 = COLORS.background
	thumbnail.ScaleType = Enum.ScaleType.Fit
	thumbnail.Parent = card

	if item.thumbnail and item.thumbnail ~= "" then
		thumbnail.Image = item.thumbnail
	else
		thumbnail.Image = "rbxthumb://type=Asset&id=" .. tostring(item.id) .. "&w=150&h=150"
	end

	UIHelpers.criarCorner(thumbnail, 8)

	-- Nome
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "ItemName"
	nameLabel.Size = UDim2.new(1, -12, 0, 16)
	nameLabel.Position = UDim2.new(0, 6, 0, 88)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = item.name or "Unknown"
	nameLabel.TextColor3 = COLORS.text
	nameLabel.TextSize = 10
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
	nameLabel.Parent = card

	-- Preco
	local priceRow = Instance.new("Frame")
	priceRow.Name = "PriceRow"
	priceRow.Size = UDim2.new(1, -12, 0, 18)
	priceRow.Position = UDim2.new(0, 6, 0, 106)
	priceRow.BackgroundTransparency = 1
	priceRow.Parent = card

	local priceLayout = Instance.new("UIListLayout")
	priceLayout.FillDirection = Enum.FillDirection.Horizontal
	priceLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	priceLayout.Padding = UDim.new(0, 4)
	priceLayout.Parent = priceRow

	-- Icone Robux
	local robuxIcon = Instance.new("ImageLabel")
	robuxIcon.Name = "RobuxIcon"
	robuxIcon.Size = UDim2.new(0, 12, 0, 12)
	robuxIcon.BackgroundTransparency = 1
	robuxIcon.Image = "rbxassetid://4892395953"
	robuxIcon.ScaleType = Enum.ScaleType.Fit
	robuxIcon.Parent = priceRow

	local priceLabel = Instance.new("TextLabel")
	priceLabel.Name = "Price"
	priceLabel.Size = UDim2.new(1, -16, 1, 0)
	priceLabel.BackgroundTransparency = 1
	priceLabel.TextXAlignment = Enum.TextXAlignment.Left
	priceLabel.TextSize = 10
	priceLabel.Font = Enum.Font.GothamBold
	priceLabel.Parent = priceRow

	if item.price and item.price > 0 then
		priceLabel.Text = tostring(item.price)
		priceLabel.TextColor3 = COLORS.gold
	elseif item.price == 0 then
		local lang = Locale.getLanguage()
		priceLabel.Text = if lang == "pt-br" then "Gratis" else "Free"
		priceLabel.TextColor3 = COLORS.green
		robuxIcon.Visible = false
	else
		priceLabel.Text = "Off Sale"
		priceLabel.TextColor3 = COLORS.textDim
		robuxIcon.Visible = false
	end

	-- Hover effects
	card.MouseEnter:Connect(function()
		UIHelpers.tweenProperty(stroke, { Color = COLORS.cardHoverBorder, Thickness = 2 }, 0.12)
		UIHelpers.tweenProperty(card, { BackgroundColor3 = COLORS.surfaceHover }, 0.12)
	end)

	card.MouseLeave:Connect(function()
		UIHelpers.tweenProperty(stroke, { Color = COLORS.cardBorder, Thickness = 1 }, 0.12)
		UIHelpers.tweenProperty(card, { BackgroundColor3 = COLORS.cardBg }, 0.12)
	end)

	-- Click
	card.MouseButton1Click:Connect(function()
		if onClicked then
			onClicked(item)
		end
	end)

	return card
end

return ItemCard
