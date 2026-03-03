--==================================================
-- MAIN FRAME
--==================================================

local MainFrame = Instance.new("Frame")
MainFrame.Name = "Main"
MainFrame.Size = UDim2.new(0, 320, 0, 480)
MainFrame.Position = UDim2.new(0.3, 0, 0.5, -240)
MainFrame.BackgroundColor3 = Colors.bg
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local mainStroke = Instance.new("UIStroke", MainFrame)
mainStroke.Color = Colors.blood
mainStroke.Thickness = 1.2
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
addGradient(MainFrame, Colors.surfaceLight, Color3.fromRGB(8, 8, 10), 90)

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

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -20, 1, -195)
Content.Position = UDim2.new(0, 10, 0, 50)
Content.BackgroundColor3 = Colors.content
Content.BorderSizePixel = 0
Content.Parent = MainFrame
Instance.new("UICorner", Content).CornerRadius = UDim.new(0, 8)
local contentStroke = Instance.new("UIStroke", Content)
contentStroke.Color = Colors.separator
contentStroke.Thickness = 0.5
contentStroke.Transparency = 0.5

local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -10, 1, -10)
ScrollFrame.Position = UDim2.new(0, 5, 0, 5)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.ScrollBarThickness = 4
ScrollFrame.ScrollBarImageColor3 = Colors.blood
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.Parent = Content

local ListLayout = Instance.new("UIListLayout")
ListLayout.Padding = UDim.new(0, 5)
ListLayout.Parent = ScrollFrame

local BtnFrame = Instance.new("Frame")
BtnFrame.Size = UDim2.new(1, -20, 0, 140)
BtnFrame.Position = UDim2.new(0, 10, 1, -180)
BtnFrame.BackgroundTransparency = 1
BtnFrame.Parent = MainFrame

local ScanBtn = Instance.new("TextButton")
ScanBtn.Size = UDim2.new(1, 0, 0, 32)
ScanBtn.BackgroundColor3 = Colors.blood
ScanBtn.Text = "🩸 SCAN"
ScanBtn.TextColor3 = Colors.text
ScanBtn.TextSize = 14
ScanBtn.Font = Enum.Font.GothamBold
ScanBtn.AutoButtonColor = false
ScanBtn.Parent = BtnFrame
Instance.new("UICorner", ScanBtn).CornerRadius = UDim.new(0, 6)
addBtnGradient(ScanBtn)
makeHoverable(ScanBtn, Colors.blood, Colors.glowRed)

local ExportAllBtn = Instance.new("TextButton")
ExportAllBtn.Size = UDim2.new(1, 0, 0, 30)
ExportAllBtn.Position = UDim2.new(0, 0, 0, 37)
ExportAllBtn.BackgroundColor3 = Colors.bloodDark
ExportAllBtn.Text = "🦇 EXPORT ALL JSON"
ExportAllBtn.TextColor3 = Colors.text
ExportAllBtn.TextSize = 13
ExportAllBtn.Font = Enum.Font.GothamBold
ExportAllBtn.AutoButtonColor = false
ExportAllBtn.Parent = BtnFrame
Instance.new("UICorner", ExportAllBtn).CornerRadius = UDim.new(0, 6)
addBtnGradient(ExportAllBtn)
makeHoverable(ExportAllBtn, Colors.bloodDark, Colors.blood)

local SaveInstanceBtn = Instance.new("TextButton")
SaveInstanceBtn.Size = UDim2.new(0.5, -3, 0, 30)
SaveInstanceBtn.Position = UDim2.new(0, 0, 0, 72)
SaveInstanceBtn.BackgroundColor3 = Colors.purple
SaveInstanceBtn.Text = "💾 SAVE INSTANCE"
SaveInstanceBtn.TextColor3 = Colors.text
SaveInstanceBtn.TextSize = 11
SaveInstanceBtn.Font = Enum.Font.GothamBold
SaveInstanceBtn.AutoButtonColor = false
SaveInstanceBtn.Parent = BtnFrame
Instance.new("UICorner", SaveInstanceBtn).CornerRadius = UDim.new(0, 6)
addBtnGradient(SaveInstanceBtn)
makeHoverable(SaveInstanceBtn, Colors.purple, Colors.purpleLight)

local TracerBtn = Instance.new("TextButton")
TracerBtn.Size = UDim2.new(0.5, -3, 0, 30)
TracerBtn.Position = UDim2.new(0.5, 3, 0, 72)
TracerBtn.BackgroundColor3 = Color3.fromRGB(60, 30, 30)
TracerBtn.Text = "👁 TRACER OFF"
TracerBtn.TextColor3 = Colors.text
TracerBtn.TextSize = 11
TracerBtn.Font = Enum.Font.GothamBold
TracerBtn.AutoButtonColor = false
TracerBtn.Parent = BtnFrame
Instance.new("UICorner", TracerBtn).CornerRadius = UDim.new(0, 6)
addBtnGradient(TracerBtn)

local UnspectateBtn = Instance.new("TextButton")
UnspectateBtn.Size = UDim2.new(1, 0, 0, 28)
UnspectateBtn.Position = UDim2.new(0, 0, 0, 107)
UnspectateBtn.BackgroundColor3 = Colors.blood
UnspectateBtn.Text = "🦇 UNSPECTATE"
UnspectateBtn.TextColor3 = Colors.text
UnspectateBtn.TextSize = 12
UnspectateBtn.Font = Enum.Font.GothamBold
UnspectateBtn.AutoButtonColor = false
UnspectateBtn.Visible = false
UnspectateBtn.Parent = BtnFrame
Instance.new("UICorner", UnspectateBtn).CornerRadius = UDim.new(0, 6)
addBtnGradient(UnspectateBtn)
makeHoverable(UnspectateBtn, Colors.blood, Colors.glowRed)

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
