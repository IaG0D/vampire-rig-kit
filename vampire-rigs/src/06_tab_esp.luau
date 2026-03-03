--==================================================
-- TAB: ESP
--==================================================

local ESPContent = Instance.new("Frame")
ESPContent.Name = "ESPContent"
ESPContent.Size = UDim2.new(1, 0, 1, 0)
ESPContent.BackgroundTransparency = 1
ESPContent.Visible = false
ESPContent.Parent = TabContent
tabContents["esp"] = ESPContent

-- Scroll container
local ESPScroll = Instance.new("ScrollingFrame")
ESPScroll.Size = UDim2.new(1, 0, 1, 0)
ESPScroll.BackgroundTransparency = 1
ESPScroll.ScrollBarThickness = 3
ESPScroll.ScrollBarImageColor3 = Colors.blood
ESPScroll.CanvasSize = UDim2.new(0, 0, 0, 340)
ESPScroll.BorderSizePixel = 0
ESPScroll.Parent = ESPContent

createSectionHeader(ESPScroll, "Players & NPCs", 0)

local espToggles = {}

espToggles.players = createVampToggle(ESPScroll, "Player ESP", "players", espState, 26, Colors.bloodLight)
espToggles.npcs = createVampToggle(ESPScroll, "NPC ESP", "npcs", espState, 56, Colors.green)
espToggles.cameras = createVampToggle(ESPScroll, "Camera ESP", "cameras", espState, 86, Colors.warning)

createSectionHeader(ESPScroll, "Visual Extras", 120)

espToggles.healthBars = createVampToggle(ESPScroll, "Health Bars", "healthBars", espState, 146, Colors.bloodLight)
espToggles.boxESP = createVampToggle(ESPScroll, "Box Highlight", "boxESP", espState, 176, Colors.glowPurple)
espToggles.chams = createVampToggle(ESPScroll, "Chams (Fill)", "chams", espState, 206, Colors.glowRed)

createSectionHeader(ESPScroll, "Info", 244)

local ESPStatusLabel = Instance.new("TextLabel")
ESPStatusLabel.Size = UDim2.new(1, 0, 0, 20)
ESPStatusLabel.Position = UDim2.new(0, 0, 0, 270)
ESPStatusLabel.BackgroundTransparency = 1
ESPStatusLabel.Text = "ESP OFF — toggle features above"
ESPStatusLabel.TextColor3 = Colors.textDim
ESPStatusLabel.TextSize = 11
ESPStatusLabel.Font = Enum.Font.Gotham
ESPStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
ESPStatusLabel.Parent = ESPScroll

-- Master OFF button
local ESPOffBtn = Instance.new("TextButton")
ESPOffBtn.Size = UDim2.new(1, 0, 0, 28)
ESPOffBtn.Position = UDim2.new(0, 0, 0, 300)
ESPOffBtn.BackgroundColor3 = Colors.bloodDark
ESPOffBtn.Text = "🔴 DISABLE ALL ESP"
ESPOffBtn.TextColor3 = Colors.text
ESPOffBtn.TextSize = 11
ESPOffBtn.Font = Enum.Font.GothamBold
ESPOffBtn.AutoButtonColor = false
ESPOffBtn.Parent = ESPScroll
Instance.new("UICorner", ESPOffBtn).CornerRadius = UDim.new(0, 6)
addBtnGradient(ESPOffBtn)
makeHoverable(ESPOffBtn, Colors.bloodDark, Colors.blood)
