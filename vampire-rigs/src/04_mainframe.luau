--==================================================
-- MAIN FRAME + TAB SYSTEM
--==================================================

local MainFrame = Instance.new("Frame")
MainFrame.Name = "Main"
MainFrame.Size = UDim2.new(0, 420, 0, 560)
MainFrame.Position = UDim2.new(0.3, 0, 0.5, -280)
MainFrame.BackgroundColor3 = Colors.bg
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local mainStroke = Instance.new("UIStroke", MainFrame)
mainStroke.Color = Colors.blood
mainStroke.Thickness = 1.2
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
addGradient(MainFrame, Colors.surfaceLight, Color3.fromRGB(8, 8, 10), 90)

--==================================================
-- TOP BAR
--==================================================

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Colors.topbar
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 10)
addGradient(TopBar, Color3.fromRGB(40, 8, 8), Colors.topbar, 0)

local TopBarFix = Instance.new("Frame")
TopBarFix.Size = UDim2.new(1, 0, 0, 10)
TopBarFix.Position = UDim2.new(0, 0, 1, -10)
TopBarFix.BackgroundColor3 = Colors.topbar
TopBarFix.BorderSizePixel = 0
TopBarFix.Parent = TopBar

addAccentLine(TopBar, UDim2.new(0, 0, 1, -1), Colors.blood)

local VampIcon = Instance.new("TextLabel")
VampIcon.Size = UDim2.new(0, 30, 0, 30)
VampIcon.Position = UDim2.new(0, 8, 0, 5)
VampIcon.BackgroundTransparency = 1
VampIcon.Text = "🦇"
VampIcon.TextSize = 20
VampIcon.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -100, 1, 0)
Title.Position = UDim2.new(0, 40, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Vampire Rig Scanner"
Title.TextColor3 = Colors.bloodLight
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Position = UDim2.new(1, -32, 0, 7)
CloseBtn.BackgroundColor3 = Colors.blood
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Colors.text
CloseBtn.TextSize = 14
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.AutoButtonColor = false
CloseBtn.Parent = TopBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)
makeHoverable(CloseBtn, Colors.blood, Colors.glowRed)

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 25, 0, 25)
MinBtn.Position = UDim2.new(1, -62, 0, 7)
MinBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
MinBtn.Text = "-"
MinBtn.TextColor3 = Colors.text
MinBtn.TextSize = 18
MinBtn.Font = Enum.Font.GothamBold
MinBtn.AutoButtonColor = false
MinBtn.Parent = TopBar
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)
makeHoverable(MinBtn, Color3.fromRGB(50, 50, 50), Color3.fromRGB(70, 70, 70))

--==================================================
-- TAB BAR
--==================================================

local TabBar = Instance.new("Frame")
TabBar.Name = "TabBar"
TabBar.Size = UDim2.new(1, 0, 0, 34)
TabBar.Position = UDim2.new(0, 0, 0, 40)
TabBar.BackgroundColor3 = Colors.topbar
TabBar.BorderSizePixel = 0
TabBar.Parent = MainFrame
addAccentLine(TabBar, UDim2.new(0, 0, 1, -1), Colors.blood)

local tabDefs = {
    { id = "scanner",  icon = "🔍", label = "Scan" },
    { id = "esp",      icon = "👁",  label = "ESP" },
    { id = "player",   icon = "👤", label = "Players" },
    { id = "movement", icon = "🏃", label = "Move" },
    { id = "teleport", icon = "📍", label = "TP" },
    { id = "settings", icon = "⚙",  label = "Config" },
}

local tabBarLayout = Instance.new("UIListLayout", TabBar)
tabBarLayout.FillDirection = Enum.FillDirection.Horizontal
tabBarLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabBarLayout.Padding = UDim.new(0, 0)

for i, def in ipairs(tabDefs) do
    local tabBtn = Instance.new("TextButton")
    tabBtn.Name = "Tab_" .. def.id
    tabBtn.Size = UDim2.new(1 / #tabDefs, 0, 1, 0)
    tabBtn.LayoutOrder = i
    tabBtn.BackgroundColor3 = Colors.tabInactive
    tabBtn.BackgroundTransparency = 0.5
    tabBtn.Text = def.icon .. " " .. def.label
    tabBtn.TextColor3 = Colors.textDim
    tabBtn.TextSize = 10
    tabBtn.Font = Enum.Font.GothamBold
    tabBtn.AutoButtonColor = false
    tabBtn.BorderSizePixel = 0
    tabBtn.Parent = TabBar

    -- Active indicator line (bottom of tab)
    local indicator = Instance.new("Frame")
    indicator.Name = "Indicator"
    indicator.Size = UDim2.new(0.8, 0, 0, 2)
    indicator.Position = UDim2.new(0.1, 0, 1, -3)
    indicator.BackgroundColor3 = Colors.blood
    indicator.BorderSizePixel = 0
    indicator.Visible = false
    indicator.Parent = tabBtn
    Instance.new("UICorner", indicator).CornerRadius = UDim.new(0, 1)

    tabButtons[def.id] = { btn = tabBtn, indicator = indicator, def = def }

    tabBtn.MouseButton1Click:Connect(function()
        switchTab(def.id)
    end)
end

--==================================================
-- TAB CONTENT CONTAINER
--==================================================

local TabContent = Instance.new("Frame")
TabContent.Name = "TabContent"
TabContent.Size = UDim2.new(1, -16, 1, -107) -- 40 topbar + 34 tabbar + 8 pad + 25 footer
TabContent.Position = UDim2.new(0, 8, 0, 78)
TabContent.BackgroundTransparency = 1
TabContent.BorderSizePixel = 0
TabContent.Parent = MainFrame

--==================================================
-- FOOTER
--==================================================

local Footer = Instance.new("Frame")
Footer.Size = UDim2.new(1, 0, 0, 25)
Footer.Position = UDim2.new(0, 0, 1, -25)
Footer.BackgroundColor3 = Colors.topbar
Footer.BorderSizePixel = 0
Footer.Parent = MainFrame
Instance.new("UICorner", Footer).CornerRadius = UDim.new(0, 10)
addAccentLine(Footer, UDim2.new(0, 0, 0, 0), Colors.blood)

local Credits = Instance.new("TextLabel")
Credits.Size = UDim2.new(1, 0, 1, 0)
Credits.BackgroundTransparency = 1
Credits.Text = "🦇 Create By VampireSonata 🦇"
Credits.TextColor3 = Colors.textBlood
Credits.TextSize = 11
Credits.Font = Enum.Font.GothamBold
Credits.Parent = Footer

--==================================================
-- SWITCH TAB
--==================================================

switchTab = function(tabId)
    activeTab = tabId

    -- Update tab buttons
    for id, data in pairs(tabButtons) do
        local isActive = (id == tabId)
        data.btn.BackgroundTransparency = isActive and 0 or 0.5
        data.btn.BackgroundColor3 = isActive and Colors.tabActive or Colors.tabInactive
        data.btn.TextColor3 = isActive and Colors.text or Colors.textDim
        data.indicator.Visible = isActive
    end

    -- Update tab content visibility
    for id, content in pairs(tabContents) do
        content.Visible = (id == tabId)
    end
end
