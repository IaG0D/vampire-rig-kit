--==================================================
-- CHAT SPY PANEL — FLOATING
-- Espiona mensagens do chat em tempo real
-- Todas as variaveis sao GLOBALS para nao gastar locals
--==================================================

ChatSpyPanel = Instance.new("Frame")
ChatSpyPanel.Name = "ChatSpyPanel"
ChatSpyPanel.Size = UDim2.new(0, 260, 0, 420)
ChatSpyPanel.Position = UDim2.new(0.5, 160, 0.5, -210)
ChatSpyPanel.BackgroundColor3 = Colors.bg
ChatSpyPanel.BorderSizePixel = 0
ChatSpyPanel.Visible = false
ChatSpyPanel.Parent = ScreenGui

Instance.new("UICorner", ChatSpyPanel).CornerRadius = UDim.new(0, 10)
ChatSpyPanelStroke = Instance.new("UIStroke", ChatSpyPanel)
ChatSpyPanelStroke.Color = Color3.fromRGB(40, 180, 60)
ChatSpyPanelStroke.Thickness = 1.5
addGradient(ChatSpyPanel, Colors.surfaceLight, Color3.fromRGB(6, 10, 6), 90)

--==================================================
-- TOP BAR
--==================================================

ChatSpyTopBar = Instance.new("Frame")
ChatSpyTopBar.Size = UDim2.new(1, 0, 0, 32)
ChatSpyTopBar.BackgroundColor3 = Colors.topbar
ChatSpyTopBar.BorderSizePixel = 0
ChatSpyTopBar.Parent = ChatSpyPanel
Instance.new("UICorner", ChatSpyTopBar).CornerRadius = UDim.new(0, 10)
addGradient(ChatSpyTopBar, Color3.fromRGB(8, 28, 8), Colors.topbar, 0)

-- Fix bottom corners
ChatSpyTopBarFix = Instance.new("Frame")
ChatSpyTopBarFix.Size = UDim2.new(1, 0, 0, 10)
ChatSpyTopBarFix.Position = UDim2.new(0, 0, 1, -10)
ChatSpyTopBarFix.BackgroundColor3 = Colors.topbar
ChatSpyTopBarFix.BorderSizePixel = 0
ChatSpyTopBarFix.Parent = ChatSpyTopBar

addAccentLine(ChatSpyTopBar, UDim2.new(0, 0, 1, -1), Color3.fromRGB(40, 180, 60))

ChatSpyTitle = Instance.new("TextLabel")
ChatSpyTitle.Size = UDim2.new(1, -40, 1, 0)
ChatSpyTitle.Position = UDim2.new(0, 10, 0, 0)
ChatSpyTitle.BackgroundTransparency = 1
ChatSpyTitle.Text = "💬 Chat Spy"
ChatSpyTitle.TextColor3 = Color3.fromRGB(80, 220, 100)
ChatSpyTitle.TextSize = 12
ChatSpyTitle.Font = Enum.Font.GothamBold
ChatSpyTitle.TextXAlignment = Enum.TextXAlignment.Left
ChatSpyTitle.Parent = ChatSpyTopBar

-- Close X
ChatSpyCloseX = Instance.new("TextButton")
ChatSpyCloseX.Size = UDim2.new(0, 20, 0, 20)
ChatSpyCloseX.Position = UDim2.new(1, -26, 0, 6)
ChatSpyCloseX.BackgroundColor3 = Color3.fromRGB(40, 140, 40)
ChatSpyCloseX.Text = "X"
ChatSpyCloseX.TextColor3 = Colors.text
ChatSpyCloseX.TextSize = 11
ChatSpyCloseX.Font = Enum.Font.GothamBold
ChatSpyCloseX.AutoButtonColor = false
ChatSpyCloseX.Parent = ChatSpyTopBar
Instance.new("UICorner", ChatSpyCloseX).CornerRadius = UDim.new(0, 6)
makeHoverable(ChatSpyCloseX, Color3.fromRGB(40, 140, 40), Color3.fromRGB(60, 180, 60))

--==================================================
-- TOGGLE SPY BUTTON
--==================================================

ChatSpyToggleBtn = Instance.new("TextButton")
ChatSpyToggleBtn.Size = UDim2.new(1, -20, 0, 28)
ChatSpyToggleBtn.Position = UDim2.new(0, 10, 0, 40)
ChatSpyToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 140, 40)
ChatSpyToggleBtn.Text = "🕵 START SPY"
ChatSpyToggleBtn.TextColor3 = Colors.text
ChatSpyToggleBtn.TextSize = 11
ChatSpyToggleBtn.Font = Enum.Font.GothamBold
ChatSpyToggleBtn.AutoButtonColor = false
ChatSpyToggleBtn.Parent = ChatSpyPanel
Instance.new("UICorner", ChatSpyToggleBtn).CornerRadius = UDim.new(0, 6)
addBtnGradient(ChatSpyToggleBtn)
makeHoverable(ChatSpyToggleBtn, Color3.fromRGB(40, 140, 40), Color3.fromRGB(60, 180, 60))

--==================================================
-- STATUS + FILTER
--==================================================

ChatSpyStatusLabel = Instance.new("TextLabel")
ChatSpyStatusLabel.Size = UDim2.new(1, -20, 0, 14)
ChatSpyStatusLabel.Position = UDim2.new(0, 10, 0, 72)
ChatSpyStatusLabel.BackgroundTransparency = 1
ChatSpyStatusLabel.Text = "Spy: OFF"
ChatSpyStatusLabel.TextColor3 = Colors.textDim
ChatSpyStatusLabel.TextSize = 10
ChatSpyStatusLabel.Font = Enum.Font.GothamBold
ChatSpyStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
ChatSpyStatusLabel.Parent = ChatSpyPanel

ChatSpyFilterBox = Instance.new("TextBox")
ChatSpyFilterBox.Size = UDim2.new(1, -20, 0, 22)
ChatSpyFilterBox.Position = UDim2.new(0, 10, 0, 90)
ChatSpyFilterBox.BackgroundColor3 = Colors.inputBg
ChatSpyFilterBox.Text = ""
ChatSpyFilterBox.PlaceholderText = "Filter messages..."
ChatSpyFilterBox.PlaceholderColor3 = Colors.textDim
ChatSpyFilterBox.TextColor3 = Colors.text
ChatSpyFilterBox.TextSize = 10
ChatSpyFilterBox.Font = Enum.Font.Code
ChatSpyFilterBox.TextXAlignment = Enum.TextXAlignment.Left
ChatSpyFilterBox.ClearTextOnFocus = false
ChatSpyFilterBox.Parent = ChatSpyPanel
Instance.new("UICorner", ChatSpyFilterBox).CornerRadius = UDim.new(0, 4)
Instance.new("UIPadding", ChatSpyFilterBox).PaddingLeft = UDim.new(0, 6)
ChatSpyFilterStroke = Instance.new("UIStroke", ChatSpyFilterBox)
ChatSpyFilterStroke.Color = Colors.separator
ChatSpyFilterStroke.Thickness = 0.5

--==================================================
-- LOG SCROLL
--==================================================

addAccentLine(ChatSpyPanel, UDim2.new(0, 10, 0, 116), Color3.fromRGB(40, 180, 60), UDim2.new(1, -20, 0, 1))

ChatSpyLogScroll = Instance.new("ScrollingFrame")
ChatSpyLogScroll.Size = UDim2.new(1, -20, 0, 236)
ChatSpyLogScroll.Position = UDim2.new(0, 10, 0, 120)
ChatSpyLogScroll.BackgroundColor3 = Colors.content
ChatSpyLogScroll.BorderSizePixel = 0
ChatSpyLogScroll.ScrollBarThickness = 3
ChatSpyLogScroll.ScrollBarImageColor3 = Color3.fromRGB(40, 180, 60)
ChatSpyLogScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
ChatSpyLogScroll.Parent = ChatSpyPanel
Instance.new("UICorner", ChatSpyLogScroll).CornerRadius = UDim.new(0, 6)
ChatSpyLogStroke = Instance.new("UIStroke", ChatSpyLogScroll)
ChatSpyLogStroke.Color = Colors.separator
ChatSpyLogStroke.Thickness = 0.5
ChatSpyLogStroke.Transparency = 0.5

ChatSpyLogLayout = Instance.new("UIListLayout")
ChatSpyLogLayout.Padding = UDim.new(0, 2)
ChatSpyLogLayout.Parent = ChatSpyLogScroll
ChatSpyLogPad = Instance.new("UIPadding", ChatSpyLogScroll)
ChatSpyLogPad.PaddingTop = UDim.new(0, 4)
ChatSpyLogPad.PaddingLeft = UDim.new(0, 4)

--==================================================
-- BOTTOM BUTTONS
--==================================================

ChatSpyClearBtn = Instance.new("TextButton")
ChatSpyClearBtn.Size = UDim2.new(1, -20, 0, 24)
ChatSpyClearBtn.Position = UDim2.new(0, 10, 0, 364)
ChatSpyClearBtn.BackgroundColor3 = Colors.warning
ChatSpyClearBtn.Text = "🗑 CLEAR LOG"
ChatSpyClearBtn.TextColor3 = Colors.bg
ChatSpyClearBtn.TextSize = 11
ChatSpyClearBtn.Font = Enum.Font.GothamBold
ChatSpyClearBtn.AutoButtonColor = false
ChatSpyClearBtn.Parent = ChatSpyPanel
Instance.new("UICorner", ChatSpyClearBtn).CornerRadius = UDim.new(0, 6)
makeHoverable(ChatSpyClearBtn, Colors.warning, Color3.fromRGB(230, 180, 60))

ChatSpyCloseBtn = Instance.new("TextButton")
ChatSpyCloseBtn.Size = UDim2.new(1, -20, 0, 24)
ChatSpyCloseBtn.Position = UDim2.new(0, 10, 0, 392)
ChatSpyCloseBtn.BackgroundColor3 = Color3.fromRGB(40, 100, 40)
ChatSpyCloseBtn.Text = "🔴 CLOSE"
ChatSpyCloseBtn.TextColor3 = Colors.text
ChatSpyCloseBtn.TextSize = 11
ChatSpyCloseBtn.Font = Enum.Font.GothamBold
ChatSpyCloseBtn.AutoButtonColor = false
ChatSpyCloseBtn.Parent = ChatSpyPanel
Instance.new("UICorner", ChatSpyCloseBtn).CornerRadius = UDim.new(0, 6)
makeHoverable(ChatSpyCloseBtn, Color3.fromRGB(40, 100, 40), Color3.fromRGB(60, 140, 60))

--==================================================
-- REFRESH LOG FUNCTION
--==================================================

refreshChatSpyLog = function(filterText)
    for _, child in ipairs(ChatSpyLogScroll:GetChildren()) do
        if child:IsA("TextLabel") then
            child:Destroy()
        end
    end
    local filter = filterText or ChatSpyFilterBox.Text
    filter = filter:lower()
    local count = 0

    for i = #chatSpyLog, 1, -1 do
        local entry = chatSpyLog[i]
        local text = entry.player .. ": " .. entry.message

        local match = true
        if filter ~= "" then
            if not text:lower():find(filter, 1, true) then
                match = false
            end
        end

        if match then
            local timeStr = os.date("%H:%M:%S", entry.time)
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, -8, 0, 16)
            lbl.BackgroundTransparency = 1
            lbl.Text = "[" .. timeStr .. "] " .. entry.player .. ": " .. entry.message
            lbl.TextColor3 = Colors.text
            lbl.TextSize = 9
            lbl.Font = Enum.Font.Code
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.TextTruncate = Enum.TextTruncate.AtEnd
            lbl.Parent = ChatSpyLogScroll
            count = count + 1
        end
    end

    ChatSpyLogScroll.CanvasSize = UDim2.new(0, 0, 0, count * 18)
end

--==================================================
-- OPEN FUNCTION
--==================================================

openChatSpyPanel = function()
    ChatSpyPanel.Visible = true
    refreshChatSpyLog()
end
