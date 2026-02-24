--[[
	vulpy-rig-kit | UIHelpers
	Helpers compartilhados de UI, tema de cores, e utilitarios de tween.
	Usado por todos os componentes do plugin.
]]

local TweenService = game:GetService("TweenService")

local UIHelpers = {}

-- ════════════════════════════════════════════════════════════════
-- Tema de cores (dark Studio - refinado)
-- ════════════════════════════════════════════════════════════════
UIHelpers.COLORS = {
	background = Color3.fromRGB(30, 30, 30),
	surface = Color3.fromRGB(42, 42, 42),
	surfaceHover = Color3.fromRGB(52, 52, 52),
	text = Color3.fromRGB(230, 230, 230),
	textDim = Color3.fromRGB(140, 140, 140),
	button = Color3.fromRGB(55, 55, 55),
	buttonHover = Color3.fromRGB(70, 70, 70),
	primary = Color3.fromRGB(88, 101, 242),   -- Discord-style purple-blue
	primaryHover = Color3.fromRGB(110, 123, 255),
	primaryDim = Color3.fromRGB(60, 70, 180),
	separator = Color3.fromRGB(60, 60, 60),
	input = Color3.fromRGB(22, 22, 22),
	inputBorder = Color3.fromRGB(55, 55, 55),
	-- Cards
	cardBg = Color3.fromRGB(38, 38, 38),
	cardBorder = Color3.fromRGB(55, 55, 55),
	cardHoverBorder = Color3.fromRGB(88, 101, 242),
	-- Tabs
	tabActive = Color3.fromRGB(88, 101, 242),
	tabInactive = Color3.fromRGB(48, 48, 48),
	-- Sliders
	sliderTrack = Color3.fromRGB(45, 45, 45),
	sliderFill = Color3.fromRGB(200, 200, 200),
	sliderThumb = Color3.fromRGB(255, 255, 255),
	-- Accent
	green = Color3.fromRGB(59, 165, 93),
	red = Color3.fromRGB(237, 66, 69),
	gold = Color3.fromRGB(254, 179, 38),
	-- Header bar
	headerBar = Color3.fromRGB(24, 24, 24),
}

-- Cores dos eixos para sliders
UIHelpers.AXIS_COLORS = {
	X = Color3.fromRGB(235, 65, 65),
	Y = Color3.fromRGB(65, 190, 65),
	Z = Color3.fromRGB(65, 120, 235),
	S = Color3.fromRGB(65, 120, 235),
}

-- ════════════════════════════════════════════════════════════════
-- Helpers de criacao
-- ════════════════════════════════════════════════════════════════

function UIHelpers.criarCorner(parent: GuiObject, radius: number?): UICorner
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 6)
	corner.Parent = parent
	return corner
end

function UIHelpers.criarStroke(parent: GuiObject, color: Color3?, thickness: number?): UIStroke
	local stroke = Instance.new("UIStroke")
	stroke.Color = color or UIHelpers.COLORS.cardBorder
	stroke.Thickness = thickness or 1
	stroke.Parent = parent
	return stroke
end

function UIHelpers.criarLabel(parent: GuiObject, props: {
	text: string,
	size: UDim2,
	position: UDim2?,
	bold: boolean?,
	textSize: number?,
	color: Color3?,
	truncate: boolean?,
}): TextLabel
	local label = Instance.new("TextLabel")
	label.Text = props.text
	label.Size = props.size
	label.Position = props.position or UDim2.new(0, 0, 0, 0)
	label.BackgroundTransparency = 1
	label.TextColor3 = props.color or UIHelpers.COLORS.text
	label.TextSize = props.textSize or 14
	label.Font = if props.bold then Enum.Font.GothamBold else Enum.Font.GothamMedium
	label.TextXAlignment = Enum.TextXAlignment.Left
	if props.truncate then
		label.TextTruncate = Enum.TextTruncate.AtEnd
	end
	label.Parent = parent
	return label
end

function UIHelpers.criarBotao(parent: GuiObject, props: {
	text: string,
	size: UDim2,
	color: Color3?,
	textColor: Color3?,
}): TextButton
	local btn = Instance.new("TextButton")
	btn.Text = props.text
	btn.Size = props.size
	btn.BackgroundColor3 = props.color or UIHelpers.COLORS.button
	btn.TextColor3 = props.textColor or Color3.new(1, 1, 1)
	btn.TextSize = 14
	btn.Font = Enum.Font.GothamMedium
	btn.AutoButtonColor = true
	btn.Parent = parent

	UIHelpers.criarCorner(btn, 8)
	return btn
end

function UIHelpers.criarSeparador(parent: GuiObject): Frame
	local sep = Instance.new("Frame")
	sep.Size = UDim2.new(1, 0, 0, 1)
	sep.BackgroundColor3 = UIHelpers.COLORS.separator
	sep.BorderSizePixel = 0
	sep.Parent = parent
	return sep
end

function UIHelpers.criarInput(parent: GuiObject, props: {
	size: UDim2,
	placeholder: string?,
	text: string?,
}): TextBox
	local input = Instance.new("TextBox")
	input.Size = props.size
	input.Text = props.text or ""
	input.PlaceholderText = props.placeholder or ""
	input.PlaceholderColor3 = UIHelpers.COLORS.textDim
	input.TextColor3 = UIHelpers.COLORS.text
	input.TextSize = 13
	input.Font = Enum.Font.GothamMedium
	input.BackgroundColor3 = UIHelpers.COLORS.input
	input.TextXAlignment = Enum.TextXAlignment.Left
	input.ClearTextOnFocus = false
	input.Parent = parent

	UIHelpers.criarCorner(input, 8)

	local stroke = Instance.new("UIStroke")
	stroke.Color = UIHelpers.COLORS.inputBorder
	stroke.Thickness = 1
	stroke.Parent = input

	local pad = Instance.new("UIPadding")
	pad.PaddingLeft = UDim.new(0, 10)
	pad.PaddingRight = UDim.new(0, 10)
	pad.Parent = input

	-- Focus effects
	input.Focused:Connect(function()
		UIHelpers.tweenProperty(stroke, { Color = UIHelpers.COLORS.primary }, 0.15)
	end)
	input.FocusLost:Connect(function()
		UIHelpers.tweenProperty(stroke, { Color = UIHelpers.COLORS.inputBorder }, 0.15)
	end)

	return input
end

function UIHelpers.criarLinhaOffset(parent: GuiObject, eixo: string): (TextBox, TextButton, TextButton)
	local COLORS = UIHelpers.COLORS

	local row = Instance.new("Frame")
	row.Name = "Offset" .. eixo
	row.Size = UDim2.new(1, 0, 0, 28)
	row.BackgroundTransparency = 1
	row.Parent = parent

	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.VerticalAlignment = Enum.VerticalAlignment.Center
	layout.Padding = UDim.new(0, 4)
	layout.Parent = row

	local axisColor = UIHelpers.AXIS_COLORS[eixo] or COLORS.text
	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.Size = UDim2.new(0, 24, 1, 0)
	label.Text = eixo
	label.TextColor3 = axisColor
	label.TextSize = 14
	label.Font = Enum.Font.GothamBold
	label.BackgroundTransparency = 1
	label.Parent = row

	local minusBtn = Instance.new("TextButton")
	minusBtn.Name = "Minus"
	minusBtn.Size = UDim2.new(0, 28, 1, 0)
	minusBtn.Text = "-"
	minusBtn.TextSize = 16
	minusBtn.Font = Enum.Font.GothamBold
	minusBtn.TextColor3 = Color3.new(1, 1, 1)
	minusBtn.BackgroundColor3 = COLORS.button
	minusBtn.AutoButtonColor = true
	minusBtn.Parent = row
	UIHelpers.criarCorner(minusBtn, 6)

	local textBox = Instance.new("TextBox")
	textBox.Name = "Input"
	textBox.Size = UDim2.new(1, -92, 1, 0)
	textBox.Text = "0"
	textBox.TextSize = 13
	textBox.Font = Enum.Font.GothamMedium
	textBox.TextColor3 = COLORS.text
	textBox.PlaceholderText = "0"
	textBox.PlaceholderColor3 = COLORS.textDim
	textBox.BackgroundColor3 = COLORS.input
	textBox.TextXAlignment = Enum.TextXAlignment.Center
	textBox.ClearTextOnFocus = false
	textBox.Parent = row
	UIHelpers.criarCorner(textBox, 6)

	local plusBtn = Instance.new("TextButton")
	plusBtn.Name = "Plus"
	plusBtn.Size = UDim2.new(0, 28, 1, 0)
	plusBtn.Text = "+"
	plusBtn.TextSize = 16
	plusBtn.Font = Enum.Font.GothamBold
	plusBtn.TextColor3 = Color3.new(1, 1, 1)
	plusBtn.BackgroundColor3 = COLORS.button
	plusBtn.AutoButtonColor = true
	plusBtn.Parent = row
	UIHelpers.criarCorner(plusBtn, 6)

	return textBox, minusBtn, plusBtn
end

-- ════════════════════════════════════════════════════════════════
-- Tween helper
-- ════════════════════════════════════════════════════════════════

function UIHelpers.tweenProperty(instance: Instance, props: { [string]: any }, duration: number?)
	local info = TweenInfo.new(duration or 0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	local tween = TweenService:Create(instance, info, props)
	tween:Play()
	return tween
end

return UIHelpers
