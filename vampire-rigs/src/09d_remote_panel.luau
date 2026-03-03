--==================================================
-- REMOTE SPY PANEL — FLOATING
-- Scanner de RemoteEvents/RemoteFunctions + Spy __namecall
-- Todas as variaveis sao GLOBALS para nao gastar locals
--==================================================

RemoteSpyPanel = Instance.new("Frame")
RemoteSpyPanel.Name = "RemoteSpyPanel"
RemoteSpyPanel.Size = UDim2.new(0, 280, 0, 560)
RemoteSpyPanel.Position = UDim2.new(0.5, -400, 0.5, -280)
RemoteSpyPanel.BackgroundColor3 = Colors.bg
RemoteSpyPanel.BorderSizePixel = 0
RemoteSpyPanel.Visible = false
RemoteSpyPanel.Parent = ScreenGui

Instance.new("UICorner", RemoteSpyPanel).CornerRadius = UDim.new(0, 10)
RemoteSpyPanelStroke = Instance.new("UIStroke", RemoteSpyPanel)
RemoteSpyPanelStroke.Color = Color3.fromRGB(0, 180, 160)
RemoteSpyPanelStroke.Thickness = 1.5
addGradient(RemoteSpyPanel, Colors.surfaceLight, Color3.fromRGB(6, 10, 10), 90)

--==================================================
-- TOP BAR
--==================================================

RemoteSpyTopBar = Instance.new("Frame")
RemoteSpyTopBar.Size = UDim2.new(1, 0, 0, 32)
RemoteSpyTopBar.BackgroundColor3 = Colors.topbar
RemoteSpyTopBar.BorderSizePixel = 0
RemoteSpyTopBar.Parent = RemoteSpyPanel
Instance.new("UICorner", RemoteSpyTopBar).CornerRadius = UDim.new(0, 10)
addGradient(RemoteSpyTopBar, Color3.fromRGB(8, 30, 28), Colors.topbar, 0)

-- Fix bottom corners
RemoteSpyTopBarFix = Instance.new("Frame")
RemoteSpyTopBarFix.Size = UDim2.new(1, 0, 0, 10)
RemoteSpyTopBarFix.Position = UDim2.new(0, 0, 1, -10)
RemoteSpyTopBarFix.BackgroundColor3 = Colors.topbar
RemoteSpyTopBarFix.BorderSizePixel = 0
RemoteSpyTopBarFix.Parent = RemoteSpyTopBar

addAccentLine(RemoteSpyTopBar, UDim2.new(0, 0, 1, -1), Color3.fromRGB(0, 180, 160))

RemoteSpyTitle = Instance.new("TextLabel")
RemoteSpyTitle.Size = UDim2.new(1, -40, 1, 0)
RemoteSpyTitle.Position = UDim2.new(0, 10, 0, 0)
RemoteSpyTitle.BackgroundTransparency = 1
RemoteSpyTitle.Text = "🕵 Remote Spy"
RemoteSpyTitle.TextColor3 = Color3.fromRGB(100, 220, 200)
RemoteSpyTitle.TextSize = 12
RemoteSpyTitle.Font = Enum.Font.GothamBold
RemoteSpyTitle.TextXAlignment = Enum.TextXAlignment.Left
RemoteSpyTitle.Parent = RemoteSpyTopBar

RemoteSpyCloseBtn = Instance.new("TextButton")
RemoteSpyCloseBtn.Size = UDim2.new(0, 20, 0, 20)
RemoteSpyCloseBtn.Position = UDim2.new(1, -26, 0, 6)
RemoteSpyCloseBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 120)
RemoteSpyCloseBtn.Text = "X"
RemoteSpyCloseBtn.TextColor3 = Colors.text
RemoteSpyCloseBtn.TextSize = 11
RemoteSpyCloseBtn.Font = Enum.Font.GothamBold
RemoteSpyCloseBtn.AutoButtonColor = false
RemoteSpyCloseBtn.Parent = RemoteSpyTopBar
Instance.new("UICorner", RemoteSpyCloseBtn).CornerRadius = UDim.new(0, 6)
makeHoverable(RemoteSpyCloseBtn, Color3.fromRGB(0, 140, 120), Color3.fromRGB(0, 180, 160))

--==================================================
-- SCAN SECTION
--==================================================

RemoteSpyScanBtn = Instance.new("TextButton")
RemoteSpyScanBtn.Size = UDim2.new(1, -20, 0, 28)
RemoteSpyScanBtn.Position = UDim2.new(0, 10, 0, 40)
RemoteSpyScanBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 120)
RemoteSpyScanBtn.Text = "🔍 SCAN REMOTES"
RemoteSpyScanBtn.TextColor3 = Colors.text
RemoteSpyScanBtn.TextSize = 11
RemoteSpyScanBtn.Font = Enum.Font.GothamBold
RemoteSpyScanBtn.AutoButtonColor = false
RemoteSpyScanBtn.Parent = RemoteSpyPanel
Instance.new("UICorner", RemoteSpyScanBtn).CornerRadius = UDim.new(0, 6)
addBtnGradient(RemoteSpyScanBtn)
makeHoverable(RemoteSpyScanBtn, Color3.fromRGB(0, 140, 120), Color3.fromRGB(0, 180, 160))

-- Stats label
RemoteSpyStatsLabel = Instance.new("TextLabel")
RemoteSpyStatsLabel.Size = UDim2.new(1, -20, 0, 14)
RemoteSpyStatsLabel.Position = UDim2.new(0, 10, 0, 72)
RemoteSpyStatsLabel.BackgroundTransparency = 1
RemoteSpyStatsLabel.Text = "Found: 0 remotes"
RemoteSpyStatsLabel.TextColor3 = Colors.textDim
RemoteSpyStatsLabel.TextSize = 9
RemoteSpyStatsLabel.Font = Enum.Font.Code
RemoteSpyStatsLabel.TextXAlignment = Enum.TextXAlignment.Left
RemoteSpyStatsLabel.Parent = RemoteSpyPanel

-- Filter textbox
RemoteSpyFilterBox = Instance.new("TextBox")
RemoteSpyFilterBox.Size = UDim2.new(1, -20, 0, 22)
RemoteSpyFilterBox.Position = UDim2.new(0, 10, 0, 90)
RemoteSpyFilterBox.BackgroundColor3 = Colors.content
RemoteSpyFilterBox.Text = ""
RemoteSpyFilterBox.PlaceholderText = "Filter remotes..."
RemoteSpyFilterBox.PlaceholderColor3 = Colors.textDim
RemoteSpyFilterBox.TextColor3 = Colors.text
RemoteSpyFilterBox.TextSize = 10
RemoteSpyFilterBox.Font = Enum.Font.Code
RemoteSpyFilterBox.TextXAlignment = Enum.TextXAlignment.Left
RemoteSpyFilterBox.ClearTextOnFocus = false
RemoteSpyFilterBox.Parent = RemoteSpyPanel
Instance.new("UICorner", RemoteSpyFilterBox).CornerRadius = UDim.new(0, 4)
Instance.new("UIPadding", RemoteSpyFilterBox).PaddingLeft = UDim.new(0, 6)

-- Remote list scroll
RemoteSpyListScroll = Instance.new("ScrollingFrame")
RemoteSpyListScroll.Size = UDim2.new(1, -20, 0, 146)
RemoteSpyListScroll.Position = UDim2.new(0, 10, 0, 116)
RemoteSpyListScroll.BackgroundColor3 = Colors.content
RemoteSpyListScroll.BorderSizePixel = 0
RemoteSpyListScroll.ScrollBarThickness = 3
RemoteSpyListScroll.ScrollBarImageColor3 = Color3.fromRGB(0, 180, 160)
RemoteSpyListScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
RemoteSpyListScroll.Parent = RemoteSpyPanel
Instance.new("UICorner", RemoteSpyListScroll).CornerRadius = UDim.new(0, 4)

RemoteSpyListLayout = Instance.new("UIListLayout")
RemoteSpyListLayout.Padding = UDim.new(0, 2)
RemoteSpyListLayout.Parent = RemoteSpyListScroll

RemoteSpyListPad = Instance.new("UIPadding", RemoteSpyListScroll)
RemoteSpyListPad.PaddingTop = UDim.new(0, 3)
RemoteSpyListPad.PaddingLeft = UDim.new(0, 3)
RemoteSpyListPad.PaddingRight = UDim.new(0, 3)

--==================================================
-- SPY SECTION
--==================================================

addAccentLine(RemoteSpyPanel, UDim2.new(0, 10, 0, 268), Color3.fromRGB(0, 180, 160), UDim2.new(1, -20, 0, 1))

RemoteSpyToggleBtn = Instance.new("TextButton")
RemoteSpyToggleBtn.Size = UDim2.new(1, -20, 0, 28)
RemoteSpyToggleBtn.Position = UDim2.new(0, 10, 0, 276)
RemoteSpyToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 80, 70)
RemoteSpyToggleBtn.Text = "🕵 START SPY"
RemoteSpyToggleBtn.TextColor3 = Colors.text
RemoteSpyToggleBtn.TextSize = 11
RemoteSpyToggleBtn.Font = Enum.Font.GothamBold
RemoteSpyToggleBtn.AutoButtonColor = false
RemoteSpyToggleBtn.Parent = RemoteSpyPanel
Instance.new("UICorner", RemoteSpyToggleBtn).CornerRadius = UDim.new(0, 6)
addBtnGradient(RemoteSpyToggleBtn)
makeHoverable(RemoteSpyToggleBtn, Color3.fromRGB(40, 80, 70), Color3.fromRGB(0, 140, 120))

-- Spy status label
RemoteSpyStatusLabel = Instance.new("TextLabel")
RemoteSpyStatusLabel.Size = UDim2.new(1, -20, 0, 14)
RemoteSpyStatusLabel.Position = UDim2.new(0, 10, 0, 308)
RemoteSpyStatusLabel.BackgroundTransparency = 1
RemoteSpyStatusLabel.Text = "Spy: OFF"
RemoteSpyStatusLabel.TextColor3 = Colors.textDim
RemoteSpyStatusLabel.TextSize = 9
RemoteSpyStatusLabel.Font = Enum.Font.Code
RemoteSpyStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
RemoteSpyStatusLabel.Parent = RemoteSpyPanel

-- Spy log scroll
RemoteSpyLogScroll = Instance.new("ScrollingFrame")
RemoteSpyLogScroll.Size = UDim2.new(1, -20, 0, 178)
RemoteSpyLogScroll.Position = UDim2.new(0, 10, 0, 326)
RemoteSpyLogScroll.BackgroundColor3 = Color3.fromRGB(10, 14, 14)
RemoteSpyLogScroll.BorderSizePixel = 0
RemoteSpyLogScroll.ScrollBarThickness = 3
RemoteSpyLogScroll.ScrollBarImageColor3 = Color3.fromRGB(0, 180, 160)
RemoteSpyLogScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
RemoteSpyLogScroll.Parent = RemoteSpyPanel
Instance.new("UICorner", RemoteSpyLogScroll).CornerRadius = UDim.new(0, 4)

RemoteSpyLogLayout = Instance.new("UIListLayout")
RemoteSpyLogLayout.Padding = UDim.new(0, 1)
RemoteSpyLogLayout.Parent = RemoteSpyLogScroll

RemoteSpyLogPad = Instance.new("UIPadding", RemoteSpyLogScroll)
RemoteSpyLogPad.PaddingTop = UDim.new(0, 2)
RemoteSpyLogPad.PaddingLeft = UDim.new(0, 3)
RemoteSpyLogPad.PaddingRight = UDim.new(0, 3)

--==================================================
-- BOTTOM BUTTONS
--==================================================

RemoteSpyClearBtn = Instance.new("TextButton")
RemoteSpyClearBtn.Size = UDim2.new(0.5, -12, 0, 26)
RemoteSpyClearBtn.Position = UDim2.new(0, 10, 0, 512)
RemoteSpyClearBtn.BackgroundColor3 = Colors.warning
RemoteSpyClearBtn.Text = "🗑 CLEAR"
RemoteSpyClearBtn.TextColor3 = Colors.bg
RemoteSpyClearBtn.TextSize = 10
RemoteSpyClearBtn.Font = Enum.Font.GothamBold
RemoteSpyClearBtn.AutoButtonColor = false
RemoteSpyClearBtn.Parent = RemoteSpyPanel
Instance.new("UICorner", RemoteSpyClearBtn).CornerRadius = UDim.new(0, 6)
makeHoverable(RemoteSpyClearBtn, Colors.warning, Color3.fromRGB(230, 180, 60))

RemoteSpyCloseBottomBtn = Instance.new("TextButton")
RemoteSpyCloseBottomBtn.Size = UDim2.new(0.5, -12, 0, 26)
RemoteSpyCloseBottomBtn.Position = UDim2.new(0.5, 2, 0, 512)
RemoteSpyCloseBottomBtn.BackgroundColor3 = Colors.bloodDark
RemoteSpyCloseBottomBtn.Text = "🔴 CLOSE"
RemoteSpyCloseBottomBtn.TextColor3 = Colors.text
RemoteSpyCloseBottomBtn.TextSize = 10
RemoteSpyCloseBottomBtn.Font = Enum.Font.GothamBold
RemoteSpyCloseBottomBtn.AutoButtonColor = false
RemoteSpyCloseBottomBtn.Parent = RemoteSpyPanel
Instance.new("UICorner", RemoteSpyCloseBottomBtn).CornerRadius = UDim.new(0, 6)
makeHoverable(RemoteSpyCloseBottomBtn, Colors.bloodDark, Colors.blood)

--==================================================
-- REFRESH REMOTE LIST (popula scroll com cards)
--==================================================

refreshRemoteList = function(filterText)
    -- Clear existing cards
    for _, child in pairs(RemoteSpyListScroll:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end

    filterText = filterText and filterText:lower() or ""

    local count = 0
    for idx, data in ipairs(scannedRemotes) do
        -- Filter
        local match = true
        if filterText ~= "" and not data.name:lower():find(filterText, 1, true) and not data.path:lower():find(filterText, 1, true) then
            match = false
        end

        if match then
        count = count + 1
        local card = Instance.new("Frame")
        card.Size = UDim2.new(1, -6, 0, 36)
        card.BackgroundColor3 = Colors.card
        card.BorderSizePixel = 0
        card.LayoutOrder = idx
        card.Parent = RemoteSpyListScroll
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 4)

        -- Type icon
        local icon = Instance.new("TextLabel")
        icon.Size = UDim2.new(0, 18, 0, 18)
        icon.Position = UDim2.new(0, 3, 0, 2)
        icon.BackgroundTransparency = 1
        icon.Text = data.class == "RemoteEvent" and "📡" or "📞"
        icon.TextSize = 11
        icon.Parent = card

        -- Name
        local nameL = Instance.new("TextLabel")
        nameL.Size = UDim2.new(1, -68, 0, 14)
        nameL.Position = UDim2.new(0, 22, 0, 1)
        nameL.BackgroundTransparency = 1
        nameL.Text = data.name
        nameL.TextColor3 = Color3.fromRGB(100, 220, 200)
        nameL.TextSize = 9
        nameL.Font = Enum.Font.GothamBold
        nameL.TextXAlignment = Enum.TextXAlignment.Left
        nameL.TextTruncate = Enum.TextTruncate.AtEnd
        nameL.Parent = card

        -- Path
        local pathL = Instance.new("TextLabel")
        pathL.Size = UDim2.new(1, -68, 0, 12)
        pathL.Position = UDim2.new(0, 22, 0, 16)
        pathL.BackgroundTransparency = 1
        pathL.Text = data.path
        pathL.TextColor3 = Colors.textDim
        pathL.TextSize = 7
        pathL.Font = Enum.Font.Code
        pathL.TextXAlignment = Enum.TextXAlignment.Left
        pathL.TextTruncate = Enum.TextTruncate.AtEnd
        pathL.Parent = card

        -- Fire button
        local fireBtn = Instance.new("TextButton")
        fireBtn.Size = UDim2.new(0, 36, 0, 20)
        fireBtn.Position = UDim2.new(1, -40, 0, 8)
        fireBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 30)
        fireBtn.Text = "🔥"
        fireBtn.TextSize = 10
        fireBtn.TextColor3 = Colors.text
        fireBtn.Font = Enum.Font.GothamBold
        fireBtn.AutoButtonColor = false
        fireBtn.Parent = card
        Instance.new("UICorner", fireBtn).CornerRadius = UDim.new(0, 4)
        makeHoverable(fireBtn, Color3.fromRGB(180, 60, 30), Color3.fromRGB(220, 80, 40))

        fireBtn.MouseButton1Click:Connect(function()
            fireTestRemote(data.instance)
        end)
        end -- if match
    end

    -- Update canvas size
    RemoteSpyListScroll.CanvasSize = UDim2.new(0, 0, 0, count * 38)

    -- Update stats
    RemoteSpyStatsLabel.Text = "Found: " .. #scannedRemotes .. " remotes" .. (filterText ~= "" and (" (showing " .. count .. ")") or "")
end

--==================================================
-- REFRESH SPY LOG
--==================================================

refreshRemoteSpyLog = function()
    -- Clear existing entries
    for _, child in pairs(RemoteSpyLogScroll:GetChildren()) do
        if child:IsA("TextLabel") then child:Destroy() end
    end

    for idx, entry in ipairs(remoteSpyLog) do
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -6, 0, 14)
        label.BackgroundColor3 = idx % 2 == 0 and Color3.fromRGB(14, 18, 18) or Color3.fromRGB(10, 14, 14)
        label.BackgroundTransparency = 0
        label.BorderSizePixel = 0
        label.LayoutOrder = idx

        -- Format time
        local secs = math.floor(entry.time % 60)
        local mins = math.floor((entry.time / 60) % 60)
        local hrs = math.floor((entry.time / 3600) % 24)
        local timeStr = string.format("%02d:%02d:%02d", hrs, mins, secs)

        -- Format args
        local argStrs = {}
        for _, arg in ipairs(entry.args) do
            local s = tostring(arg)
            if #s > 30 then s = s:sub(1, 27) .. "..." end
            table.insert(argStrs, s)
        end
        local argsText = #argStrs > 0 and ("(" .. table.concat(argStrs, ", ") .. ")") or "()"

        label.Text = timeStr .. " " .. entry.method .. " " .. entry.name .. argsText
        label.TextColor3 = entry.method == "FireServer" and Color3.fromRGB(100, 220, 200) or Color3.fromRGB(220, 180, 100)
        label.TextSize = 7
        label.Font = Enum.Font.Code
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextTruncate = Enum.TextTruncate.AtEnd
        label.Parent = RemoteSpyLogScroll
    end

    -- Update canvas + auto-scroll to bottom
    RemoteSpyLogScroll.CanvasSize = UDim2.new(0, 0, 0, #remoteSpyLog * 15)
    RemoteSpyLogScroll.CanvasPosition = Vector2.new(0, math.max(0, #remoteSpyLog * 15 - 178))
end

--==================================================
-- OPEN REMOTE SPY PANEL
--==================================================

openRemoteSpyPanel = function()
    -- Auto-scan on open
    scanRemotes()
    refreshRemoteList("")
    RemoteSpyPanel.Visible = true
    notify("Remote Spy opened — " .. #scannedRemotes .. " remotes found", "info")
end
