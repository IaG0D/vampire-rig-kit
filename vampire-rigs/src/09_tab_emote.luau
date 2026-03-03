--==================================================
-- TAB: EMOTE + SHADOW
--==================================================

local EmoteContent = Instance.new("Frame")
EmoteContent.Name = "EmoteContent"
EmoteContent.Size = UDim2.new(1, 0, 1, 0)
EmoteContent.BackgroundTransparency = 1
EmoteContent.Visible = false
EmoteContent.Parent = TabContent
tabContents["emote"] = EmoteContent

local EmoteScroll = Instance.new("ScrollingFrame")
EmoteScroll.Size = UDim2.new(1, 0, 1, 0)
EmoteScroll.BackgroundTransparency = 1
EmoteScroll.ScrollBarThickness = 3
EmoteScroll.ScrollBarImageColor3 = Colors.blood
EmoteScroll.CanvasSize = UDim2.new(0, 0, 0, 700)
EmoteScroll.BorderSizePixel = 0
EmoteScroll.Parent = EmoteContent

--==================================================
-- EMOTE LIST
--==================================================

createSectionHeader(EmoteScroll, "Emotes", 0)

local emoteList = {
    { name = "Wave",      id = 507770239 },
    { name = "Point",     id = 507770453 },
    { name = "Laugh",     id = 507770818 },
    { name = "Cheer",     id = 507770677 },
    { name = "Dance 1",   id = 507771019 },
    { name = "Dance 2",   id = 507776043 },
    { name = "Dance 3",   id = 507777268 },
}

-- Grid: 2 columns
local emoteY = 26
local emoteButtons = {}
for i, emote in ipairs(emoteList) do
    local col = (i - 1) % 2
    local row = math.floor((i - 1) / 2)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.5, -3, 0, 28)
    btn.Position = UDim2.new(col * 0.5, col == 0 and 0 or 3, 0, emoteY + row * 32)
    btn.BackgroundColor3 = Colors.purple
    btn.Text = "💃 " .. emote.name
    btn.TextColor3 = Colors.text
    btn.TextSize = 10
    btn.Font = Enum.Font.GothamBold
    btn.AutoButtonColor = false
    btn.Parent = EmoteScroll
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    makeHoverable(btn, Colors.purple, Colors.purpleLight)

    emoteButtons[i] = { btn = btn, emote = emote }
end

local emoteGridHeight = math.ceil(#emoteList / 2) * 32

-- Custom animation ID input
local customEmoteY = emoteY + emoteGridHeight + 8

local CustomIDLabel = Instance.new("TextLabel")
CustomIDLabel.Size = UDim2.new(1, 0, 0, 14)
CustomIDLabel.Position = UDim2.new(0, 0, 0, customEmoteY)
CustomIDLabel.BackgroundTransparency = 1
CustomIDLabel.Text = "Custom Animation ID:"
CustomIDLabel.TextColor3 = Colors.textDim
CustomIDLabel.TextSize = 10
CustomIDLabel.Font = Enum.Font.GothamBold
CustomIDLabel.TextXAlignment = Enum.TextXAlignment.Left
CustomIDLabel.Parent = EmoteScroll

local CustomIDInput = Instance.new("TextBox")
CustomIDInput.Size = UDim2.new(1, -70, 0, 26)
CustomIDInput.Position = UDim2.new(0, 0, 0, customEmoteY + 16)
CustomIDInput.BackgroundColor3 = Colors.inputBg
CustomIDInput.Text = ""
CustomIDInput.PlaceholderText = "Animation ID..."
CustomIDInput.TextColor3 = Colors.text
CustomIDInput.PlaceholderColor3 = Colors.textDim
CustomIDInput.TextSize = 11
CustomIDInput.Font = Enum.Font.Code
CustomIDInput.ClearTextOnFocus = false
CustomIDInput.Parent = EmoteScroll
Instance.new("UICorner", CustomIDInput).CornerRadius = UDim.new(0, 6)
local customStroke = Instance.new("UIStroke", CustomIDInput)
customStroke.Color = Colors.inputBorder
customStroke.Thickness = 1

CustomIDInput.Focused:Connect(function()
    TweenService:Create(customStroke, TweenInfo.new(0.2), { Color = Colors.purpleLight, Thickness = 1.5 }):Play()
end)
CustomIDInput.FocusLost:Connect(function()
    TweenService:Create(customStroke, TweenInfo.new(0.3), { Color = Colors.inputBorder, Thickness = 1 }):Play()
end)

local PlayCustomBtn = Instance.new("TextButton")
PlayCustomBtn.Size = UDim2.new(0, 62, 0, 26)
PlayCustomBtn.Position = UDim2.new(1, -62, 0, customEmoteY + 16)
PlayCustomBtn.BackgroundColor3 = Colors.green
PlayCustomBtn.Text = "▶ PLAY"
PlayCustomBtn.TextColor3 = Colors.text
PlayCustomBtn.TextSize = 10
PlayCustomBtn.Font = Enum.Font.GothamBold
PlayCustomBtn.AutoButtonColor = false
PlayCustomBtn.Parent = EmoteScroll
Instance.new("UICorner", PlayCustomBtn).CornerRadius = UDim.new(0, 6)
makeHoverable(PlayCustomBtn, Colors.green, Colors.greenLight)

-- Stop emote button
local StopEmoteBtn = Instance.new("TextButton")
StopEmoteBtn.Size = UDim2.new(1, 0, 0, 26)
StopEmoteBtn.Position = UDim2.new(0, 0, 0, customEmoteY + 48)
StopEmoteBtn.BackgroundColor3 = Colors.bloodDark
StopEmoteBtn.Text = "⏹ STOP EMOTE"
StopEmoteBtn.TextColor3 = Colors.text
StopEmoteBtn.TextSize = 10
StopEmoteBtn.Font = Enum.Font.GothamBold
StopEmoteBtn.AutoButtonColor = false
StopEmoteBtn.Parent = EmoteScroll
Instance.new("UICorner", StopEmoteBtn).CornerRadius = UDim.new(0, 6)
makeHoverable(StopEmoteBtn, Colors.bloodDark, Colors.blood)

--==================================================
-- SHADOW MODE
--==================================================

local shadowSectionY = customEmoteY + 86

createSectionHeader(EmoteScroll, "Shadow Mode", shadowSectionY)

-- Shadow target display
local ShadowTargetLabel = Instance.new("TextLabel")
ShadowTargetLabel.Size = UDim2.new(1, 0, 0, 18)
ShadowTargetLabel.Position = UDim2.new(0, 0, 0, shadowSectionY + 26)
ShadowTargetLabel.BackgroundTransparency = 1
ShadowTargetLabel.Text = "Target: none"
ShadowTargetLabel.TextColor3 = Colors.textDim
ShadowTargetLabel.TextSize = 10
ShadowTargetLabel.Font = Enum.Font.GothamBold
ShadowTargetLabel.TextXAlignment = Enum.TextXAlignment.Left
ShadowTargetLabel.Parent = EmoteScroll

-- Shadow player list (select target)
local ShadowPlayerScroll = Instance.new("ScrollingFrame")
ShadowPlayerScroll.Size = UDim2.new(1, 0, 0, 80)
ShadowPlayerScroll.Position = UDim2.new(0, 0, 0, shadowSectionY + 46)
ShadowPlayerScroll.BackgroundColor3 = Colors.content
ShadowPlayerScroll.BorderSizePixel = 0
ShadowPlayerScroll.ScrollBarThickness = 3
ShadowPlayerScroll.ScrollBarImageColor3 = Colors.blood
ShadowPlayerScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
ShadowPlayerScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
ShadowPlayerScroll.Parent = EmoteScroll
Instance.new("UICorner", ShadowPlayerScroll).CornerRadius = UDim.new(0, 6)
local spStroke = Instance.new("UIStroke", ShadowPlayerScroll)
spStroke.Color = Colors.separator
spStroke.Thickness = 0.5

local ShadowPlayerLayout = Instance.new("UIListLayout", ShadowPlayerScroll)
ShadowPlayerLayout.Padding = UDim.new(0, 3)
local spPad = Instance.new("UIPadding", ShadowPlayerScroll)
spPad.PaddingTop = UDim.new(0, 3)
spPad.PaddingLeft = UDim.new(0, 3)
spPad.PaddingRight = UDim.new(0, 3)

-- Shadow mode buttons
local shadowModeY = shadowSectionY + 132

local shadowModeToggles = {}

local shadowModeDefs = {
    { name = "Follow Behind",     mode = "follow", color = Colors.green },
    { name = "Sit on Head",       mode = "head",   color = Colors.warning },
    { name = "Shadow Box (Mirror)", mode = "mirror", color = Colors.glowPurple },
}

for i, def in ipairs(shadowModeDefs) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 26)
    btn.Position = UDim2.new(0, 0, 0, shadowModeY + (i - 1) * 30)
    btn.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
    btn.Text = def.name
    btn.TextColor3 = Colors.textDim
    btn.TextSize = 10
    btn.Font = Enum.Font.GothamBold
    btn.AutoButtonColor = false
    btn.Parent = EmoteScroll
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    shadowModeToggles[def.mode] = { btn = btn, def = def }
end

-- Function to refresh shadow mode button highlights
local function refreshShadowModeButtons()
    for mode, data in pairs(shadowModeToggles) do
        local isActive = shadowState.active and shadowState.mode == mode
        data.btn.BackgroundColor3 = isActive and data.def.color or Color3.fromRGB(40, 20, 20)
        data.btn.TextColor3 = isActive and Colors.text or Colors.textDim
    end
end

-- Distance slider
local shadowDistY = shadowModeY + #shadowModeDefs * 30 + 6
local shadowDistSlider = createSliderRow(EmoteScroll, "Distance (studs)", 1, 15, 4, shadowDistY, function(val)
    shadowState.distance = val
end)

-- Delay slider
local shadowDelayY = shadowDistY + 32
local shadowDelaySlider = createSliderRow(EmoteScroll, "Delay (sec)", 0, 5, 0, shadowDelayY, function(val)
    shadowState.delay = val
end)

-- Stop shadow button
local StopShadowBtn = Instance.new("TextButton")
StopShadowBtn.Size = UDim2.new(1, 0, 0, 28)
StopShadowBtn.Position = UDim2.new(0, 0, 0, shadowDelayY + 38)
StopShadowBtn.BackgroundColor3 = Colors.bloodDark
StopShadowBtn.Text = "🔴 STOP SHADOW"
StopShadowBtn.TextColor3 = Colors.text
StopShadowBtn.TextSize = 11
StopShadowBtn.Font = Enum.Font.GothamBold
StopShadowBtn.AutoButtonColor = false
StopShadowBtn.Parent = EmoteScroll
Instance.new("UICorner", StopShadowBtn).CornerRadius = UDim.new(0, 6)
addBtnGradient(StopShadowBtn)
makeHoverable(StopShadowBtn, Colors.bloodDark, Colors.blood)

-- Update canvas size
EmoteScroll.CanvasSize = UDim2.new(0, 0, 0, shadowDelayY + 76)
