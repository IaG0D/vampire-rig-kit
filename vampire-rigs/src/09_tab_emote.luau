--==================================================
-- TAB: EMOTE (Pure — Catalog Search + Presets)
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
EmoteScroll.CanvasSize = UDim2.new(0, 0, 0, 600)
EmoteScroll.BorderSizePixel = 0
EmoteScroll.Parent = EmoteContent

--==================================================
-- PRESET EMOTES
--==================================================

createSectionHeader(EmoteScroll, "Quick Emotes", 0)

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

--==================================================
-- CUSTOM ANIMATION ID
--==================================================

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
-- CATALOG SEARCH
--==================================================

local catalogSectionY = customEmoteY + 86

createSectionHeader(EmoteScroll, "Catalog Search", catalogSectionY)

-- Search input (global for event wiring in 22_events)
EmoteSearchBox = Instance.new("TextBox")
EmoteSearchBox.Size = UDim2.new(1, 0, 0, 26)
EmoteSearchBox.Position = UDim2.new(0, 0, 0, catalogSectionY + 26)
EmoteSearchBox.BackgroundColor3 = Colors.inputBg
EmoteSearchBox.Text = ""
EmoteSearchBox.PlaceholderText = "🔍 Search emotes..."
EmoteSearchBox.PlaceholderColor3 = Colors.textDim
EmoteSearchBox.TextColor3 = Colors.text
EmoteSearchBox.TextSize = 11
EmoteSearchBox.Font = Enum.Font.Code
EmoteSearchBox.ClearTextOnFocus = false
EmoteSearchBox.Parent = EmoteScroll
Instance.new("UICorner", EmoteSearchBox).CornerRadius = UDim.new(0, 6)
local emoteSearchStroke = Instance.new("UIStroke", EmoteSearchBox)
emoteSearchStroke.Color = Colors.inputBorder
emoteSearchStroke.Thickness = 1

EmoteSearchBox.Focused:Connect(function()
    TweenService:Create(emoteSearchStroke, TweenInfo.new(0.2), { Color = Colors.purpleLight, Thickness = 1.5 }):Play()
end)
EmoteSearchBox.FocusLost:Connect(function()
    TweenService:Create(emoteSearchStroke, TweenInfo.new(0.3), { Color = Colors.inputBorder, Thickness = 1 }):Play()
end)

-- Catalog grid container (global for cross-module access)
EmoteCatalogGrid = Instance.new("Frame")
EmoteCatalogGrid.Name = "CatalogGrid"
EmoteCatalogGrid.Size = UDim2.new(1, 0, 0, 300)
EmoteCatalogGrid.Position = UDim2.new(0, 0, 0, catalogSectionY + 58)
EmoteCatalogGrid.BackgroundTransparency = 1
EmoteCatalogGrid.ClipsDescendants = true
EmoteCatalogGrid.Parent = EmoteScroll

EmoteCatalogGridLayout = Instance.new("UIGridLayout", EmoteCatalogGrid)
EmoteCatalogGridLayout.CellSize = UDim2.new(0, 60, 0, 82)
EmoteCatalogGridLayout.CellPadding = UDim2.new(0, 6, 0, 6)
EmoteCatalogGridLayout.FillDirection = Enum.FillDirection.Horizontal
EmoteCatalogGridLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Empty/status label
EmoteCatalogEmpty = Instance.new("TextLabel")
EmoteCatalogEmpty.Size = UDim2.new(1, 0, 0, 30)
EmoteCatalogEmpty.Position = UDim2.new(0, 0, 0, catalogSectionY + 58)
EmoteCatalogEmpty.BackgroundTransparency = 1
EmoteCatalogEmpty.Text = "Type to search emotes..."
EmoteCatalogEmpty.TextColor3 = Colors.textDim
EmoteCatalogEmpty.TextSize = 10
EmoteCatalogEmpty.Font = Enum.Font.Gotham
EmoteCatalogEmpty.Visible = true
EmoteCatalogEmpty.Parent = EmoteScroll

-- Update canvas size
EmoteScroll.CanvasSize = UDim2.new(0, 0, 0, catalogSectionY + 370)
