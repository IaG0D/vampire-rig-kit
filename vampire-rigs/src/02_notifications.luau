--==================================================
-- NOTIFICATION SYSTEM
--==================================================

notifContainer = Instance.new("Frame")
notifContainer.Name = "Notifications"
notifContainer.Size = UDim2.new(0, 280, 1, -20)
notifContainer.Position = UDim2.new(1, -290, 0, 10)
notifContainer.BackgroundTransparency = 1
notifContainer.Parent = ScreenGui

local notifLayout = Instance.new("UIListLayout", notifContainer)
notifLayout.Padding = UDim.new(0, 6)
notifLayout.VerticalAlignment = Enum.VerticalAlignment.Top
notifLayout.SortOrder = Enum.SortOrder.LayoutOrder

local notifTypeColors = {
    info = Colors.blood,
    success = Colors.green,
    warning = Colors.warning,
    error = Colors.glowRed,
}

local notifTypeIcons = {
    info = "🦇",
    success = "✅",
    warning = "⚠",
    error = "❌",
}

notify = function(text, notifType)
    notifType = notifType or "info"
    local color = notifTypeColors[notifType] or Colors.blood
    local icon = notifTypeIcons[notifType] or "🦇"

    notifCount = notifCount + 1

    -- Limita a 5 notificacoes visiveis
    local children = notifContainer:GetChildren()
    local frames = {}
    for _, c in ipairs(children) do
        if c:IsA("Frame") then table.insert(frames, c) end
    end
    if #frames >= 5 then
        frames[1]:Destroy()
    end

    local toast = Instance.new("Frame")
    toast.Name = "Notif_" .. notifCount
    toast.Size = UDim2.new(1, 0, 0, 40)
    toast.BackgroundColor3 = Colors.card
    toast.BorderSizePixel = 0
    toast.LayoutOrder = notifCount
    toast.BackgroundTransparency = 1
    toast.Parent = notifContainer
    Instance.new("UICorner", toast).CornerRadius = UDim.new(0, 8)
    addGradient(toast, Colors.surfaceLight, Colors.card, 0)

    local toastStroke = Instance.new("UIStroke", toast)
    toastStroke.Color = color
    toastStroke.Thickness = 1
    toastStroke.Transparency = 0.5

    -- Left accent bar
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0, 3, 1, -8)
    bar.Position = UDim2.new(0, 0, 0, 4)
    bar.BackgroundColor3 = color
    bar.BorderSizePixel = 0
    bar.Parent = toast
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 2)

    -- Icon
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Size = UDim2.new(0, 24, 0, 24)
    iconLabel.Position = UDim2.new(0, 8, 0, 8)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = icon
    iconLabel.TextSize = 14
    iconLabel.Parent = toast

    -- Text
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, -40, 1, 0)
    textLabel.Position = UDim2.new(0, 34, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text
    textLabel.TextColor3 = Colors.text
    textLabel.TextSize = 11
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.TextTruncate = Enum.TextTruncate.AtEnd
    textLabel.Parent = toast

    -- Slide in
    TweenService:Create(toast, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0,
    }):Play()

    -- Auto dismiss
    task.delay(3, function()
        if toast and toast.Parent then
            local fadeOut = TweenService:Create(toast, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                BackgroundTransparency = 1,
            })
            fadeOut:Play()
            fadeOut.Completed:Connect(function()
                if toast and toast.Parent then toast:Destroy() end
            end)
        end
    end)
end
