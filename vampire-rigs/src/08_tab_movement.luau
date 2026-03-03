--==================================================
-- TAB: MOVEMENT
--==================================================

local MovementContent = Instance.new("Frame")
MovementContent.Name = "MovementContent"
MovementContent.Size = UDim2.new(1, 0, 1, 0)
MovementContent.BackgroundTransparency = 1
MovementContent.Visible = false
MovementContent.Parent = TabContent
tabContents["movement"] = MovementContent

-- Scroll container
local MoveScroll = Instance.new("ScrollingFrame")
MoveScroll.Size = UDim2.new(1, 0, 1, 0)
MoveScroll.BackgroundTransparency = 1
MoveScroll.ScrollBarThickness = 3
MoveScroll.ScrollBarImageColor3 = Colors.blood
MoveScroll.CanvasSize = UDim2.new(0, 0, 0, 320)
MoveScroll.BorderSizePixel = 0
MoveScroll.Parent = MovementContent

createSectionHeader(MoveScroll, "Movement", 0)

local moveToggles = {}

moveToggles.fly = createVampToggle(MoveScroll, "Fly (WASD+Space/Shift)", "fly", movementState, 26, Colors.glowPurple)
moveToggles.noclip = createVampToggle(MoveScroll, "Noclip (Walk Through)", "noclip", movementState, 56, Colors.warning)
moveToggles.infiniteJump = createVampToggle(MoveScroll, "Infinite Jump", "infiniteJump", movementState, 86, Colors.green)

createSectionHeader(MoveScroll, "Speed", 120)

local speedSlider = createSliderRow(MoveScroll, "Walk Speed", 1, 500, 16, 146, function(val)
    movementState.speed = val
    if applySpeed then applySpeed() end
end)

local jumpSlider = createSliderRow(MoveScroll, "Jump Power", 0, 300, 50, 178, function(val)
    movementState.jumpPower = val
    if applySpeed then applySpeed() end
end)

createSectionHeader(MoveScroll, "Camera", 214)

moveToggles.freecam = createVampToggle(MoveScroll, "Freecam (Detach Camera)", "freecam", movementState, 240, Colors.bloodLight)

-- Reset button
local ResetMoveBtn = Instance.new("TextButton")
ResetMoveBtn.Size = UDim2.new(1, 0, 0, 28)
ResetMoveBtn.Position = UDim2.new(0, 0, 0, 280)
ResetMoveBtn.BackgroundColor3 = Colors.bloodDark
ResetMoveBtn.Text = "🔴 RESET ALL"
ResetMoveBtn.TextColor3 = Colors.text
ResetMoveBtn.TextSize = 11
ResetMoveBtn.Font = Enum.Font.GothamBold
ResetMoveBtn.AutoButtonColor = false
ResetMoveBtn.Parent = MoveScroll
Instance.new("UICorner", ResetMoveBtn).CornerRadius = UDim.new(0, 6)
addBtnGradient(ResetMoveBtn)
makeHoverable(ResetMoveBtn, Colors.bloodDark, Colors.blood)
