--==================================================
-- TAB: SCANNER
--==================================================

local ScannerContent = Instance.new("Frame")
ScannerContent.Name = "ScannerContent"
ScannerContent.Size = UDim2.new(1, 0, 1, 0)
ScannerContent.BackgroundTransparency = 1
ScannerContent.Parent = TabContent
tabContents["scanner"] = ScannerContent

-- Search bar
local SearchBar = Instance.new("TextBox")
SearchBar.Name = "SearchBar"
SearchBar.Size = UDim2.new(1, 0, 0, 28)
SearchBar.Position = UDim2.new(0, 0, 0, 0)
SearchBar.BackgroundColor3 = Colors.inputBg
SearchBar.Text = ""
SearchBar.PlaceholderText = "🔍 Search rigs..."
SearchBar.TextColor3 = Colors.text
SearchBar.PlaceholderColor3 = Colors.textDim
SearchBar.TextSize = 11
SearchBar.Font = Enum.Font.Gotham
SearchBar.ClearTextOnFocus = false
SearchBar.Parent = ScannerContent
Instance.new("UICorner", SearchBar).CornerRadius = UDim.new(0, 6)
local searchStroke = Instance.new("UIStroke", SearchBar)
searchStroke.Color = Colors.inputBorder
searchStroke.Thickness = 1

SearchBar.Focused:Connect(function()
    TweenService:Create(searchStroke, TweenInfo.new(0.2), { Color = Colors.bloodLight, Thickness = 1.5 }):Play()
end)
SearchBar.FocusLost:Connect(function()
    TweenService:Create(searchStroke, TweenInfo.new(0.3), { Color = Colors.inputBorder, Thickness = 1 }):Play()
end)

-- Control row: Auto-scan toggle + Scan button
local ControlRow = Instance.new("Frame")
ControlRow.Size = UDim2.new(1, 0, 0, 30)
ControlRow.Position = UDim2.new(0, 0, 0, 32)
ControlRow.BackgroundTransparency = 1
ControlRow.Parent = ScannerContent

local AutoScanToggle = createVampToggle(ControlRow, "Auto-Scan", "enabled", autoScanConfig, 0, Colors.green)

local ScanBtn = Instance.new("TextButton")
ScanBtn.Size = UDim2.new(1, 0, 0, 30)
ScanBtn.Position = UDim2.new(0, 0, 0, 64)
ScanBtn.BackgroundColor3 = Colors.blood
ScanBtn.Text = "🩸 SCAN"
ScanBtn.TextColor3 = Colors.text
ScanBtn.TextSize = 13
ScanBtn.Font = Enum.Font.GothamBold
ScanBtn.AutoButtonColor = false
ScanBtn.Parent = ScannerContent
Instance.new("UICorner", ScanBtn).CornerRadius = UDim.new(0, 6)
addBtnGradient(ScanBtn)
makeHoverable(ScanBtn, Colors.blood, Colors.glowRed)

-- Export + count row
local ExportBtn = Instance.new("TextButton")
ExportBtn.Size = UDim2.new(0.5, -3, 0, 26)
ExportBtn.Position = UDim2.new(0, 0, 0, 98)
ExportBtn.BackgroundColor3 = Colors.bloodDark
ExportBtn.Text = "🦇 EXPORT ALL"
ExportBtn.TextColor3 = Colors.text
ExportBtn.TextSize = 11
ExportBtn.Font = Enum.Font.GothamBold
ExportBtn.AutoButtonColor = false
ExportBtn.Parent = ScannerContent
Instance.new("UICorner", ExportBtn).CornerRadius = UDim.new(0, 6)
addBtnGradient(ExportBtn)
makeHoverable(ExportBtn, Colors.bloodDark, Colors.blood)

local CountLabel = Instance.new("TextLabel")
CountLabel.Size = UDim2.new(0.5, -3, 0, 26)
CountLabel.Position = UDim2.new(0.5, 3, 0, 98)
CountLabel.BackgroundTransparency = 1
CountLabel.Text = "0P | 0N"
CountLabel.TextColor3 = Colors.textDim
CountLabel.TextSize = 11
CountLabel.Font = Enum.Font.GothamBold
CountLabel.TextXAlignment = Enum.TextXAlignment.Right
CountLabel.Parent = ScannerContent

-- Result scroll area
local ResultScroll = Instance.new("ScrollingFrame")
ResultScroll.Name = "ResultScroll"
ResultScroll.Size = UDim2.new(1, 0, 1, -162)
ResultScroll.Position = UDim2.new(0, 0, 0, 128)
ResultScroll.BackgroundColor3 = Colors.content
ResultScroll.BorderSizePixel = 0
ResultScroll.ScrollBarThickness = 4
ResultScroll.ScrollBarImageColor3 = Colors.blood
ResultScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
ResultScroll.Parent = ScannerContent
Instance.new("UICorner", ResultScroll).CornerRadius = UDim.new(0, 6)
local resultStroke = Instance.new("UIStroke", ResultScroll)
resultStroke.Color = Colors.separator
resultStroke.Thickness = 0.5
resultStroke.Transparency = 0.5

local ResultLayout = Instance.new("UIListLayout")
ResultLayout.Padding = UDim.new(0, 5)
ResultLayout.Parent = ResultScroll
local resultPad = Instance.new("UIPadding", ResultScroll)
resultPad.PaddingTop = UDim.new(0, 4)
resultPad.PaddingLeft = UDim.new(0, 4)
resultPad.PaddingRight = UDim.new(0, 4)

-- Unspectate button (hidden by default)
local UnspectateBtn = Instance.new("TextButton")
UnspectateBtn.Size = UDim2.new(1, 0, 0, 26)
UnspectateBtn.Position = UDim2.new(0, 0, 1, -28)
UnspectateBtn.BackgroundColor3 = Colors.blood
UnspectateBtn.Text = "🦇 UNSPECTATE"
UnspectateBtn.TextColor3 = Colors.text
UnspectateBtn.TextSize = 11
UnspectateBtn.Font = Enum.Font.GothamBold
UnspectateBtn.AutoButtonColor = false
UnspectateBtn.Visible = false
UnspectateBtn.Parent = ScannerContent
Instance.new("UICorner", UnspectateBtn).CornerRadius = UDim.new(0, 6)
addBtnGradient(UnspectateBtn)
makeHoverable(UnspectateBtn, Colors.blood, Colors.glowRed)
