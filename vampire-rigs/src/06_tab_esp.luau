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
ESPScroll.CanvasSize = UDim2.new(0, 0, 0, 670)
ESPScroll.BorderSizePixel = 0
ESPScroll.Parent = ESPContent

--==================================================
-- SECTION: Players & NPCs
--==================================================

createSectionHeader(ESPScroll, "Players & NPCs", 0)

local espToggles = {}

espToggles.players = createVampToggle(ESPScroll, "Player ESP", "players", espState, 26, Colors.bloodLight)
espToggles.npcs = createVampToggle(ESPScroll, "NPC ESP", "npcs", espState, 56, Colors.green)
espToggles.cameras = createVampToggle(ESPScroll, "Camera ESP", "cameras", espState, 86, Colors.warning)

--==================================================
-- SECTION: Visual Modes
--==================================================

createSectionHeader(ESPScroll, "Visual Modes", 120)

espToggles.healthBars = createVampToggle(ESPScroll, "Health Bars", "healthBars", espState, 146, Colors.bloodLight)
espToggles.boxESP = createVampToggle(ESPScroll, "Box Highlight", "boxESP", espState, 176, Colors.glowPurple)
espToggles.chams = createVampToggle(ESPScroll, "Chams (Fill)", "chams", espState, 206, Colors.glowRed)

--==================================================
-- SECTION: Tracking
--==================================================

createSectionHeader(ESPScroll, "Tracking", 240)

espToggles.tracers = createVampToggle(ESPScroll, "Tracers (Lines)", "tracers", espState, 266, Color3.fromRGB(0, 180, 255))
espToggles.skeleton = createVampToggle(ESPScroll, "Skeleton ESP", "skeleton", espState, 296, Color3.fromRGB(200, 200, 200))
espToggles.headDot = createVampToggle(ESPScroll, "Head Dot", "headDot", espState, 326, Color3.fromRGB(255, 80, 80))
espToggles.threatLevel = createVampToggle(ESPScroll, "Threat Level", "threatLevel", espState, 356, Color3.fromRGB(255, 160, 0))
espToggles.toolESP = createVampToggle(ESPScroll, "Tool ESP", "toolESP", espState, 386, Color3.fromRGB(180, 120, 255))

--==================================================
-- SECTION: World
--==================================================

createSectionHeader(ESPScroll, "World", 420)

-- These toggles are NOT in espToggles — they have separate start/stop
FootstepsToggle = createVampToggle(ESPScroll, "Footsteps Trail", "footsteps", espState, 446, Color3.fromRGB(120, 200, 80))
SoundESPToggle = createVampToggle(ESPScroll, "Sound ESP", "soundESP", espState, 476, Color3.fromRGB(255, 200, 60))

--==================================================
-- SECTION: Player Details
--==================================================

createSectionHeader(ESPScroll, "Player Details", 510)

PlayerInfoToggle = createVampToggle(ESPScroll, "Player Info Cards", "active", playerInfoState, 536, Color3.fromRGB(40, 180, 60))

--==================================================
-- SECTION: Info
--==================================================

createSectionHeader(ESPScroll, "Info", 570)

local ESPStatusLabel = Instance.new("TextLabel")
ESPStatusLabel.Size = UDim2.new(1, 0, 0, 20)
ESPStatusLabel.Position = UDim2.new(0, 0, 0, 596)
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
ESPOffBtn.Position = UDim2.new(0, 0, 0, 626)
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
