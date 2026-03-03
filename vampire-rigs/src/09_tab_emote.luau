--==================================================
-- TAB: EMOTE (Favorites + Catalog Search + Custom ID)
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
-- FAVORITES SECTION
--==================================================

createSectionHeader(EmoteScroll, "Favorites", 0)

local favSectionY = 24

-- Favorites grid container (global for cross-module access)
EmoteFavGrid = Instance.new("Frame")
EmoteFavGrid.Name = "FavGrid"
EmoteFavGrid.Size = UDim2.new(1, 0, 0, 0)
EmoteFavGrid.Position = UDim2.new(0, 0, 0, favSectionY)
EmoteFavGrid.BackgroundTransparency = 1
EmoteFavGrid.ClipsDescendants = true
EmoteFavGrid.Parent = EmoteScroll

EmoteFavGridLayout = Instance.new("UIGridLayout", EmoteFavGrid)
EmoteFavGridLayout.CellSize = UDim2.new(0, 60, 0, 82)
EmoteFavGridLayout.CellPadding = UDim2.new(0, 6, 0, 6)
EmoteFavGridLayout.FillDirection = Enum.FillDirection.Horizontal
EmoteFavGridLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Empty favorites label
EmoteFavEmpty = Instance.new("TextLabel")
EmoteFavEmpty.Size = UDim2.new(1, 0, 0, 24)
EmoteFavEmpty.Position = UDim2.new(0, 0, 0, favSectionY)
EmoteFavEmpty.BackgroundTransparency = 1
EmoteFavEmpty.Text = "No favorites yet — star emotes from catalog"
EmoteFavEmpty.TextColor3 = Colors.textDim
EmoteFavEmpty.TextSize = 9
EmoteFavEmpty.Font = Enum.Font.Gotham
EmoteFavEmpty.Visible = true
EmoteFavEmpty.Parent = EmoteScroll

--==================================================
-- CUSTOM ANIMATION ID
-- (Y positions set by recalcEmoteLayout)
--==================================================

local CustomIDLabel = Instance.new("TextLabel")
CustomIDLabel.Size = UDim2.new(1, 0, 0, 14)
CustomIDLabel.BackgroundTransparency = 1
CustomIDLabel.Text = "Custom Animation ID:"
CustomIDLabel.TextColor3 = Colors.textDim
CustomIDLabel.TextSize = 10
CustomIDLabel.Font = Enum.Font.GothamBold
CustomIDLabel.TextXAlignment = Enum.TextXAlignment.Left
CustomIDLabel.Parent = EmoteScroll

local CustomIDInput = Instance.new("TextBox")
CustomIDInput.Size = UDim2.new(1, -70, 0, 26)
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
PlayCustomBtn.BackgroundColor3 = Colors.green
PlayCustomBtn.Text = "▶ PLAY"
PlayCustomBtn.TextColor3 = Colors.text
PlayCustomBtn.TextSize = 10
PlayCustomBtn.Font = Enum.Font.GothamBold
PlayCustomBtn.AutoButtonColor = false
PlayCustomBtn.Parent = EmoteScroll
Instance.new("UICorner", PlayCustomBtn).CornerRadius = UDim.new(0, 6)
makeHoverable(PlayCustomBtn, Colors.green, Colors.greenLight)

-- Pause/Resume button (left half)
PauseEmoteBtn = Instance.new("TextButton")
PauseEmoteBtn.Size = UDim2.new(0.5, -2, 0, 26)
PauseEmoteBtn.BackgroundColor3 = Colors.warning
PauseEmoteBtn.Text = "⏸ PAUSE"
PauseEmoteBtn.TextColor3 = Colors.text
PauseEmoteBtn.TextSize = 10
PauseEmoteBtn.Font = Enum.Font.GothamBold
PauseEmoteBtn.AutoButtonColor = false
PauseEmoteBtn.Parent = EmoteScroll
Instance.new("UICorner", PauseEmoteBtn).CornerRadius = UDim.new(0, 6)
makeHoverable(PauseEmoteBtn, Colors.warning, Color3.fromRGB(230, 180, 60))

-- Stop emote button (right half)
local StopEmoteBtn = Instance.new("TextButton")
StopEmoteBtn.Size = UDim2.new(0.5, -2, 0, 26)
StopEmoteBtn.BackgroundColor3 = Colors.bloodDark
StopEmoteBtn.Text = "⏹ STOP"
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

EmoteCatalogHeader = createSectionHeader(EmoteScroll, "Catalog Search", 0)

-- Search input (global for event wiring in 22_events)
EmoteSearchBox = Instance.new("TextBox")
EmoteSearchBox.Size = UDim2.new(1, 0, 0, 26)
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
EmoteCatalogEmpty.BackgroundTransparency = 1
EmoteCatalogEmpty.Text = "Loading popular emotes..."
EmoteCatalogEmpty.TextColor3 = Colors.textDim
EmoteCatalogEmpty.TextSize = 10
EmoteCatalogEmpty.Font = Enum.Font.Gotham
EmoteCatalogEmpty.Visible = true
EmoteCatalogEmpty.Parent = EmoteScroll

--==================================================
-- LAYOUT FUNCTION (global — repositions everything based on favorites grid height)
--==================================================

recalcEmoteLayout = function()
    local favHeight = EmoteFavGrid.Size.Y.Offset
    if favHeight < 10 then favHeight = 24 end

    local baseY = favSectionY + favHeight + 8

    -- Custom ID section
    CustomIDLabel.Position = UDim2.new(0, 0, 0, baseY)
    CustomIDInput.Position = UDim2.new(0, 0, 0, baseY + 16)
    PlayCustomBtn.Position = UDim2.new(1, -62, 0, baseY + 16)
    PauseEmoteBtn.Position = UDim2.new(0, 0, 0, baseY + 48)
    StopEmoteBtn.Position = UDim2.new(0.5, 2, 0, baseY + 48)

    -- Catalog section
    local catalogY = baseY + 86
    EmoteCatalogHeader.Position = UDim2.new(0, 0, 0, catalogY)
    EmoteSearchBox.Position = UDim2.new(0, 0, 0, catalogY + 26)
    EmoteCatalogGrid.Position = UDim2.new(0, 0, 0, catalogY + 58)
    EmoteCatalogEmpty.Position = UDim2.new(0, 0, 0, catalogY + 58)

    -- Update canvas
    EmoteScroll.CanvasSize = UDim2.new(0, 0, 0, catalogY + 58 + EmoteCatalogGrid.Size.Y.Offset + 20)
end

-- Initial layout (no favorites yet)
recalcEmoteLayout()
