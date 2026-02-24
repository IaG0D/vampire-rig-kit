--[[
	vulpy-rig-kit | Slider
	Slider visual com circulo colorida do eixo, track, fill, thumb e value label.
	Suporta click-to-position e drag.
]]

local UIHelpers = require(script.Parent.Parent.UIHelpers)
local COLORS = UIHelpers.COLORS

local Slider = {}

function Slider.create(parent: GuiObject, props: {
	axisName: string,
	axisColor: Color3,
	min: number,
	max: number,
	step: number,
	default: number?,
	format: string?,
	layoutOrder: number?,
	onChanged: ((number) -> ())?,
})
	local min = props.min
	local max = props.max
	local step = props.step
	local fmt = props.format or "%.2f"
	local currentValue = props.default or (min + max) / 2

	-- Container row
	local row = Instance.new("Frame")
	row.Name = "Slider_" .. props.axisName
	row.Size = UDim2.new(1, 0, 0, 28)
	row.BackgroundTransparency = 1
	row.LayoutOrder = props.layoutOrder or 0
	row.Parent = parent

	-- Circle do eixo
	local circle = Instance.new("Frame")
	circle.Name = "AxisCircle"
	circle.Size = UDim2.new(0, 20, 0, 20)
	circle.Position = UDim2.new(0, 0, 0.5, -10)
	circle.BackgroundColor3 = props.axisColor
	circle.Parent = row
	UIHelpers.criarCorner(circle, 10)

	local axisLabel = Instance.new("TextLabel")
	axisLabel.Size = UDim2.new(1, 0, 1, 0)
	axisLabel.BackgroundTransparency = 1
	axisLabel.Text = props.axisName
	axisLabel.TextColor3 = Color3.new(1, 1, 1)
	axisLabel.TextSize = 10
	axisLabel.Font = Enum.Font.GothamBold
	axisLabel.Parent = circle

	-- Value label (right side)
	local valueLabel = Instance.new("TextLabel")
	valueLabel.Name = "Value"
	valueLabel.Size = UDim2.new(0, 46, 1, 0)
	valueLabel.Position = UDim2.new(1, -46, 0, 0)
	valueLabel.BackgroundTransparency = 1
	valueLabel.Text = string.format(fmt, currentValue)
	valueLabel.TextColor3 = COLORS.text
	valueLabel.TextSize = 11
	valueLabel.Font = Enum.Font.GothamMedium
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right
	valueLabel.Parent = row

	-- Track area (clickable)
	local trackArea = Instance.new("TextButton")
	trackArea.Name = "TrackArea"
	trackArea.Size = UDim2.new(1, -74, 1, 0)
	trackArea.Position = UDim2.new(0, 26, 0, 0)
	trackArea.BackgroundTransparency = 1
	trackArea.Text = ""
	trackArea.Parent = row

	-- Track bar
	local track = Instance.new("Frame")
	track.Name = "Track"
	track.Size = UDim2.new(1, 0, 0, 3)
	track.Position = UDim2.new(0, 0, 0.5, -1)
	track.BackgroundColor3 = COLORS.sliderTrack
	track.BorderSizePixel = 0
	track.Parent = trackArea
	UIHelpers.criarCorner(track, 2)

	-- Fill bar
	local fill = Instance.new("Frame")
	fill.Name = "Fill"
	fill.Size = UDim2.new(0.5, 0, 1, 0)
	fill.BackgroundColor3 = props.axisColor
	fill.BorderSizePixel = 0
	fill.Parent = track
	UIHelpers.criarCorner(fill, 2)

	-- Thumb
	local thumb = Instance.new("Frame")
	thumb.Name = "Thumb"
	thumb.Size = UDim2.new(0, 14, 0, 14)
	thumb.Position = UDim2.new(0.5, -7, 0.5, -7)
	thumb.BackgroundColor3 = COLORS.sliderThumb
	thumb.ZIndex = 2
	thumb.Parent = trackArea
	UIHelpers.criarCorner(thumb, 7)

	-- Logica de update visual
	local function updateVisual()
		local fraction = if max ~= min then (currentValue - min) / (max - min) else 0
		fraction = math.clamp(fraction, 0, 1)

		fill.Size = UDim2.new(fraction, 0, 1, 0)
		thumb.Position = UDim2.new(fraction, -7, 0.5, -7)
		valueLabel.Text = string.format(fmt, currentValue)
	end

	local function setValueFromFraction(fraction: number)
		fraction = math.clamp(fraction, 0, 1)
		local rawValue = min + (max - min) * fraction
		-- Snap to step
		currentValue = math.round(rawValue / step) * step
		currentValue = math.clamp(currentValue, min, max)
		updateVisual()
		if props.onChanged then
			props.onChanged(currentValue)
		end
	end

	local function getMouseFraction(input: InputObject): number
		local absPos = trackArea.AbsolutePosition.X
		local absSize = trackArea.AbsoluteSize.X
		if absSize == 0 then return 0.5 end
		return (input.Position.X - absPos) / absSize
	end

	-- Drag state
	local isDragging = false

	trackArea.MouseButton1Down:Connect(function()
		isDragging = true
	end)

	trackArea.InputChanged:Connect(function(input)
		if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			setValueFromFraction(getMouseFraction(input))
		end
	end)

	trackArea.MouseButton1Up:Connect(function(_, _, input)
		if isDragging then
			isDragging = false
		end
	end)

	-- Click to position
	trackArea.MouseButton1Click:Connect(function()
		-- Use absoluto
		local mouse = trackArea:FindFirstAncestorWhichIsA("PluginGui")
		if not mouse then return end
		-- Fallback: usa posicao do thumb atual se nao conseguir ler mouse
	end)

	-- Tambem para global mouse up (caso mouse saia do track)
	trackArea.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			isDragging = false
		end
	end)

	-- InputBegan no trackArea para click direto
	trackArea.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			isDragging = true
			setValueFromFraction(getMouseFraction(input))
		end
	end)

	-- Init visual
	updateVisual()

	-- API
	local api = {}

	function api.setValue(value: number)
		currentValue = math.clamp(value, min, max)
		updateVisual()
	end

	function api.getValue(): number
		return currentValue
	end

	function api.setRange(newMin: number, newMax: number)
		min = newMin
		max = newMax
		currentValue = math.clamp(currentValue, min, max)
		updateVisual()
	end

	function api.getRow()
		return row
	end

	return api
end

return Slider
