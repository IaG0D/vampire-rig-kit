--==================================================
-- BACKPACK VIEWER PANEL — FLOATING
-- Visualiza tools/items de qualquer player
-- Todas as variaveis sao GLOBALS para nao gastar locals
--==================================================

BackpackPanel = Instance.new("Frame")
BackpackPanel.Name = "BackpackPanel"
BackpackPanel.Size = UDim2.new(0, 260, 0, 420)
BackpackPanel.Position = UDim2.new(0.5, 160, 0.5, -210)
BackpackPanel.BackgroundColor3 = Colors.bg
BackpackPanel.BorderSizePixel = 0
BackpackPanel.Visible = false
BackpackPanel.Parent = ScreenGui

Instance.new("UICorner", BackpackPanel).CornerRadius = UDim.new(0, 10)
BackpackPanelStroke = Instance.new("UIStroke", BackpackPanel)
BackpackPanelStroke.Color = Color3.fromRGB(200, 140, 40)
BackpackPanelStroke.Thickness = 1.5
addGradient(BackpackPanel, Colors.surfaceLight, Color3.fromRGB(12, 10, 6), 90)

--==================================================
-- TOP BAR
--==================================================

BackpackTopBar = Instance.new("Frame")
BackpackTopBar.Size = UDim2.new(1, 0, 0, 32)
BackpackTopBar.BackgroundColor3 = Colors.topbar
BackpackTopBar.BorderSizePixel = 0
BackpackTopBar.Parent = BackpackPanel
Instance.new("UICorner", BackpackTopBar).CornerRadius = UDim.new(0, 10)
addGradient(BackpackTopBar, Color3.fromRGB(28, 18, 6), Colors.topbar, 0)

BackpackTopBarFix = Instance.new("Frame")
BackpackTopBarFix.Size = UDim2.new(1, 0, 0, 10)
BackpackTopBarFix.Position = UDim2.new(0, 0, 1, -10)
BackpackTopBarFix.BackgroundColor3 = Colors.topbar
BackpackTopBarFix.BorderSizePixel = 0
BackpackTopBarFix.Parent = BackpackTopBar

addAccentLine(BackpackTopBar, UDim2.new(0, 0, 1, -1), Color3.fromRGB(200, 140, 40))

BackpackTitle = Instance.new("TextLabel")
BackpackTitle.Size = UDim2.new(1, -40, 1, 0)
BackpackTitle.Position = UDim2.new(0, 10, 0, 0)
BackpackTitle.BackgroundTransparency = 1
BackpackTitle.Text = "Backpack Viewer"
BackpackTitle.TextColor3 = Color3.fromRGB(240, 180, 60)
BackpackTitle.TextSize = 12
BackpackTitle.Font = Enum.Font.GothamBold
BackpackTitle.TextXAlignment = Enum.TextXAlignment.Left
BackpackTitle.Parent = BackpackTopBar

BackpackCloseX = Instance.new("TextButton")
BackpackCloseX.Size = UDim2.new(0, 20, 0, 20)
BackpackCloseX.Position = UDim2.new(1, -26, 0, 6)
BackpackCloseX.BackgroundColor3 = Color3.fromRGB(160, 110, 30)
BackpackCloseX.Text = "X"
BackpackCloseX.TextColor3 = Colors.text
BackpackCloseX.TextSize = 11
BackpackCloseX.Font = Enum.Font.GothamBold
BackpackCloseX.AutoButtonColor = false
BackpackCloseX.Parent = BackpackTopBar
Instance.new("UICorner", BackpackCloseX).CornerRadius = UDim.new(0, 6)
makeHoverable(BackpackCloseX, Color3.fromRGB(160, 110, 30), Color3.fromRGB(200, 140, 40))

--==================================================
-- PLAYER INFO ROW
--==================================================

BackpackThumb = Instance.new("ImageLabel")
BackpackThumb.Size = UDim2.new(0, 36, 0, 36)
BackpackThumb.Position = UDim2.new(0, 10, 0, 40)
BackpackThumb.BackgroundColor3 = Colors.content
BackpackThumb.Image = ""
BackpackThumb.Parent = BackpackPanel
Instance.new("UICorner", BackpackThumb).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", BackpackThumb).Color = Color3.fromRGB(200, 140, 40)

BackpackPlayerName = Instance.new("TextLabel")
BackpackPlayerName.Size = UDim2.new(0, 130, 0, 16)
BackpackPlayerName.Position = UDim2.new(0, 52, 0, 42)
BackpackPlayerName.BackgroundTransparency = 1
BackpackPlayerName.Text = "Player"
BackpackPlayerName.TextColor3 = Colors.text
BackpackPlayerName.TextSize = 11
BackpackPlayerName.Font = Enum.Font.GothamBold
BackpackPlayerName.TextXAlignment = Enum.TextXAlignment.Left
BackpackPlayerName.TextTruncate = Enum.TextTruncate.AtEnd
BackpackPlayerName.Parent = BackpackPanel

BackpackPlayerUser = Instance.new("TextLabel")
BackpackPlayerUser.Size = UDim2.new(0, 130, 0, 12)
BackpackPlayerUser.Position = UDim2.new(0, 52, 0, 58)
BackpackPlayerUser.BackgroundTransparency = 1
BackpackPlayerUser.Text = "@username"
BackpackPlayerUser.TextColor3 = Colors.textDim
BackpackPlayerUser.TextSize = 9
BackpackPlayerUser.Font = Enum.Font.Gotham
BackpackPlayerUser.TextXAlignment = Enum.TextXAlignment.Left
BackpackPlayerUser.TextTruncate = Enum.TextTruncate.AtEnd
BackpackPlayerUser.Parent = BackpackPanel

BackpackRefreshBtn = Instance.new("TextButton")
BackpackRefreshBtn.Size = UDim2.new(0, 60, 0, 22)
BackpackRefreshBtn.Position = UDim2.new(1, -70, 0, 47)
BackpackRefreshBtn.BackgroundColor3 = Color3.fromRGB(160, 110, 30)
BackpackRefreshBtn.Text = "REFRESH"
BackpackRefreshBtn.TextColor3 = Colors.text
BackpackRefreshBtn.TextSize = 9
BackpackRefreshBtn.Font = Enum.Font.GothamBold
BackpackRefreshBtn.AutoButtonColor = false
BackpackRefreshBtn.Parent = BackpackPanel
Instance.new("UICorner", BackpackRefreshBtn).CornerRadius = UDim.new(0, 4)
makeHoverable(BackpackRefreshBtn, Color3.fromRGB(160, 110, 30), Color3.fromRGB(200, 140, 40))

--==================================================
-- FILTER
--==================================================

BackpackFilterBox = Instance.new("TextBox")
BackpackFilterBox.Size = UDim2.new(1, -20, 0, 22)
BackpackFilterBox.Position = UDim2.new(0, 10, 0, 84)
BackpackFilterBox.BackgroundColor3 = Colors.inputBg
BackpackFilterBox.Text = ""
BackpackFilterBox.PlaceholderText = "Filter tools..."
BackpackFilterBox.PlaceholderColor3 = Colors.textDim
BackpackFilterBox.TextColor3 = Colors.text
BackpackFilterBox.TextSize = 10
BackpackFilterBox.Font = Enum.Font.Code
BackpackFilterBox.TextXAlignment = Enum.TextXAlignment.Left
BackpackFilterBox.ClearTextOnFocus = false
BackpackFilterBox.Parent = BackpackPanel
Instance.new("UICorner", BackpackFilterBox).CornerRadius = UDim.new(0, 4)
Instance.new("UIPadding", BackpackFilterBox).PaddingLeft = UDim.new(0, 6)
BackpackFilterStroke = Instance.new("UIStroke", BackpackFilterBox)
BackpackFilterStroke.Color = Colors.separator
BackpackFilterStroke.Thickness = 0.5

--==================================================
-- TOOL LIST SCROLL
--==================================================

addAccentLine(BackpackPanel, UDim2.new(0, 10, 0, 112), Color3.fromRGB(200, 140, 40), UDim2.new(1, -20, 0, 1))

BackpackListScroll = Instance.new("ScrollingFrame")
BackpackListScroll.Size = UDim2.new(1, -20, 0, 250)
BackpackListScroll.Position = UDim2.new(0, 10, 0, 116)
BackpackListScroll.BackgroundColor3 = Colors.content
BackpackListScroll.BorderSizePixel = 0
BackpackListScroll.ScrollBarThickness = 3
BackpackListScroll.ScrollBarImageColor3 = Color3.fromRGB(200, 140, 40)
BackpackListScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
BackpackListScroll.Parent = BackpackPanel
Instance.new("UICorner", BackpackListScroll).CornerRadius = UDim.new(0, 6)
BackpackListStroke = Instance.new("UIStroke", BackpackListScroll)
BackpackListStroke.Color = Colors.separator
BackpackListStroke.Thickness = 0.5
BackpackListStroke.Transparency = 0.5

BackpackListLayout = Instance.new("UIListLayout")
BackpackListLayout.Padding = UDim.new(0, 3)
BackpackListLayout.Parent = BackpackListScroll
BackpackListPad = Instance.new("UIPadding", BackpackListScroll)
BackpackListPad.PaddingTop = UDim.new(0, 4)
BackpackListPad.PaddingLeft = UDim.new(0, 4)

--==================================================
-- STATS + BOTTOM BUTTONS
--==================================================

BackpackStatsLabel = Instance.new("TextLabel")
BackpackStatsLabel.Size = UDim2.new(1, -20, 0, 14)
BackpackStatsLabel.Position = UDim2.new(0, 10, 0, 372)
BackpackStatsLabel.BackgroundTransparency = 1
BackpackStatsLabel.Text = "Tools: 0"
BackpackStatsLabel.TextColor3 = Colors.textDim
BackpackStatsLabel.TextSize = 10
BackpackStatsLabel.Font = Enum.Font.GothamBold
BackpackStatsLabel.TextXAlignment = Enum.TextXAlignment.Left
BackpackStatsLabel.Parent = BackpackPanel

BackpackCloseBtn = Instance.new("TextButton")
BackpackCloseBtn.Size = UDim2.new(1, -20, 0, 24)
BackpackCloseBtn.Position = UDim2.new(0, 10, 0, 390)
BackpackCloseBtn.BackgroundColor3 = Color3.fromRGB(120, 80, 20)
BackpackCloseBtn.Text = "CLOSE"
BackpackCloseBtn.TextColor3 = Colors.text
BackpackCloseBtn.TextSize = 11
BackpackCloseBtn.Font = Enum.Font.GothamBold
BackpackCloseBtn.AutoButtonColor = false
BackpackCloseBtn.Parent = BackpackPanel
Instance.new("UICorner", BackpackCloseBtn).CornerRadius = UDim.new(0, 6)
makeHoverable(BackpackCloseBtn, Color3.fromRGB(120, 80, 20), Color3.fromRGB(160, 110, 30))

--==================================================
-- SCAN + REFRESH FUNCTIONS
--==================================================

scanBackpack = function(player)
    backpackItems = {}
    pcall(function()
        -- 1. Backpack (tools nao equipadas)
        local bp = player:FindFirstChild("Backpack")
        if bp then
            for _, tool in pairs(bp:GetChildren()) do
                table.insert(backpackItems, {
                    name = tool.Name,
                    class = tool.ClassName,
                    location = "Backpack",
                    texture = tool:IsA("Tool") and tool.TextureId or "",
                    instance = tool,
                })
            end
        end
        -- 2. Character (tool equipada na mao)
        local char = player.Character
        if char then
            for _, obj in pairs(char:GetChildren()) do
                if obj:IsA("Tool") or obj:IsA("HopperBin") then
                    table.insert(backpackItems, {
                        name = obj.Name,
                        class = obj.ClassName,
                        location = "Equipped",
                        texture = obj:IsA("Tool") and obj.TextureId or "",
                        instance = obj,
                    })
                end
            end
        end
        -- 3. StarterGear (persistente)
        local sg = player:FindFirstChild("StarterGear")
        if sg then
            for _, tool in pairs(sg:GetChildren()) do
                table.insert(backpackItems, {
                    name = tool.Name,
                    class = tool.ClassName,
                    location = "StarterGear",
                    texture = tool:IsA("Tool") and tool.TextureId or "",
                    instance = tool,
                })
            end
        end
    end)
    table.sort(backpackItems, function(a, b) return a.name < b.name end)
end

refreshBackpackList = function()
    for _, child in ipairs(BackpackListScroll:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end

    local filter = BackpackFilterBox.Text:lower()
    local count = 0

    for _, item in ipairs(backpackItems) do
        local match = true
        if filter ~= "" then
            if not item.name:lower():find(filter, 1, true) and not item.class:lower():find(filter, 1, true) then
                match = false
            end
        end

        if match then
            -- Card frame
            local card = Instance.new("Frame")
            card.Size = UDim2.new(1, -8, 0, 38)
            card.BackgroundColor3 = Color3.fromRGB(25, 22, 18)
            card.BorderSizePixel = 0
            card.Parent = BackpackListScroll
            Instance.new("UICorner", card).CornerRadius = UDim.new(0, 4)

            -- Location color indicator (barra lateral)
            local locBar = Instance.new("Frame")
            locBar.Size = UDim2.new(0, 3, 1, -6)
            locBar.Position = UDim2.new(0, 2, 0, 3)
            locBar.BorderSizePixel = 0
            locBar.Parent = card
            Instance.new("UICorner", locBar).CornerRadius = UDim.new(0, 2)

            if item.location == "Equipped" then
                locBar.BackgroundColor3 = Color3.fromRGB(60, 200, 80)
            elseif item.location == "StarterGear" then
                locBar.BackgroundColor3 = Color3.fromRGB(160, 100, 220)
            else
                locBar.BackgroundColor3 = Color3.fromRGB(80, 150, 220)
            end

            -- Tool name
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(1, -14, 0, 14)
            nameLabel.Position = UDim2.new(0, 10, 0, 3)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = item.name
            nameLabel.TextColor3 = Colors.text
            nameLabel.TextSize = 10
            nameLabel.Font = Enum.Font.GothamBold
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
            nameLabel.Parent = card

            -- Class + location
            local infoLabel = Instance.new("TextLabel")
            infoLabel.Size = UDim2.new(1, -14, 0, 12)
            infoLabel.Position = UDim2.new(0, 10, 0, 18)
            infoLabel.BackgroundTransparency = 1
            infoLabel.Text = item.class .. " | " .. item.location
            infoLabel.TextColor3 = Colors.textDim
            infoLabel.TextSize = 9
            infoLabel.Font = Enum.Font.Gotham
            infoLabel.TextXAlignment = Enum.TextXAlignment.Left
            infoLabel.TextTruncate = Enum.TextTruncate.AtEnd
            infoLabel.Parent = card

            count = count + 1
        end
    end

    BackpackListScroll.CanvasSize = UDim2.new(0, 0, 0, count * 41 + 8)
    BackpackStatsLabel.Text = "Tools: " .. count .. (#backpackItems ~= count and (" / " .. #backpackItems .. " total") or "")
end

--==================================================
-- OPEN FUNCTION
--==================================================

openBackpackPanel = function(player)
    backpackTarget = player
    BackpackTitle.Text = "Backpack — " .. player.DisplayName
    BackpackPlayerName.Text = player.DisplayName
    BackpackPlayerUser.Text = "@" .. player.Name

    -- Thumbnail async
    task.spawn(function()
        local ok, thumb = pcall(function()
            return Players:GetUserThumbnailAsync(
                player.UserId,
                Enum.ThumbnailType.HeadShot,
                Enum.ThumbnailSize.Size150x150
            )
        end)
        if ok and thumb then BackpackThumb.Image = thumb end
    end)

    scanBackpack(player)
    refreshBackpackList()
    BackpackPanel.Visible = true
end
