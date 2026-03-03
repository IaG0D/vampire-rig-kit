--==================================================
-- TELEPORT LOGIC
--==================================================

-- TP to Part by name
tpToPart = function(name)
    if not name or name == "" then
        notify("Enter a part name", "warning")
        return
    end

    local lowerName = name:lower()
    for _, obj in pairs(workspace:GetDescendants()) do
        if (obj:IsA("BasePart") or obj:IsA("Model")) and obj.Name:lower():find(lowerName, 1, true) then
            local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local target
                if obj:IsA("Model") then
                    target = obj.PrimaryPart or obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart")
                else
                    target = obj
                end
                if target then
                    hrp.CFrame = target.CFrame + Vector3.new(0, 5, 0)
                    notify("TP to: " .. obj.Name, "success")
                    return
                end
            end
        end
    end
    notify("Not found: " .. name, "error")
end

--==================================================
-- WAYPOINTS
--==================================================

addWaypoint = function(name)
    if not name or name == "" then
        name = "WP " .. (#waypoints + 1)
    end

    local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then
        notify("No character", "error")
        return
    end

    table.insert(waypoints, {
        name = name,
        cframe = hrp.CFrame,
    })

    notify("Waypoint saved: " .. name, "success")
    refreshWaypointList()
end

tpToWaypoint = function(index)
    local wp = waypoints[index]
    if not wp then return end
    local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = wp.cframe
        notify("TP to: " .. wp.name, "success")
    end
end

removeWaypoint = function(index)
    local wp = waypoints[index]
    if wp then
        notify("Removed: " .. wp.name, "info")
        table.remove(waypoints, index)
        refreshWaypointList()
    end
end

refreshWaypointList = function()
    -- Clear existing
    for _, child in pairs(WaypointList:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end

    local myHRP = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")

    for i, wp in ipairs(waypoints) do
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 30)
        row.BackgroundColor3 = Colors.card
        row.BorderSizePixel = 0
        row.Parent = WaypointList
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)
        addGradient(row, Colors.surfaceLight, Colors.card, 0)

        -- Left accent
        local bar = Instance.new("Frame")
        bar.Size = UDim2.new(0, 3, 1, -6)
        bar.Position = UDim2.new(0, 0, 0, 3)
        bar.BackgroundColor3 = Colors.green
        bar.BorderSizePixel = 0
        bar.Parent = row
        Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 2)

        -- Name
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, -110, 1, 0)
        nameLabel.Position = UDim2.new(0, 10, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = wp.name
        nameLabel.TextColor3 = Colors.text
        nameLabel.TextSize = 11
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
        nameLabel.Parent = row

        -- Distance
        if myHRP then
            local dist = math.floor((myHRP.Position - wp.cframe.Position).Magnitude)
            local distLabel = Instance.new("TextLabel")
            distLabel.Size = UDim2.new(0, 50, 1, 0)
            distLabel.Position = UDim2.new(1, -108, 0, 0)
            distLabel.BackgroundTransparency = 1
            distLabel.Text = dist .. "m"
            distLabel.TextColor3 = Colors.textDim
            distLabel.TextSize = 9
            distLabel.Font = Enum.Font.Gotham
            distLabel.Parent = row
        end

        -- TP button
        local tpBtn = Instance.new("TextButton")
        tpBtn.Size = UDim2.new(0, 28, 0, 20)
        tpBtn.Position = UDim2.new(1, -58, 0, 5)
        tpBtn.BackgroundColor3 = Colors.green
        tpBtn.Text = "TP"
        tpBtn.TextColor3 = Colors.text
        tpBtn.TextSize = 9
        tpBtn.Font = Enum.Font.GothamBold
        tpBtn.AutoButtonColor = false
        tpBtn.Parent = row
        Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0, 4)
        makeHoverable(tpBtn, Colors.green, Colors.greenLight)

        local idx = i
        tpBtn.MouseButton1Click:Connect(function()
            tpToWaypoint(idx)
        end)

        -- Delete button
        local delBtn = Instance.new("TextButton")
        delBtn.Size = UDim2.new(0, 22, 0, 20)
        delBtn.Position = UDim2.new(1, -26, 0, 5)
        delBtn.BackgroundColor3 = Colors.bloodDark
        delBtn.Text = "X"
        delBtn.TextColor3 = Colors.text
        delBtn.TextSize = 9
        delBtn.Font = Enum.Font.GothamBold
        delBtn.AutoButtonColor = false
        delBtn.Parent = row
        Instance.new("UICorner", delBtn).CornerRadius = UDim.new(0, 4)
        makeHoverable(delBtn, Colors.bloodDark, Colors.blood)

        delBtn.MouseButton1Click:Connect(function()
            removeWaypoint(idx)
        end)
    end

    -- Also refresh Player TP list
    for _, child in pairs(PlayerTPList:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LP then
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, 0, 0, 26)
            row.BackgroundColor3 = Colors.card
            row.BorderSizePixel = 0
            row.Parent = PlayerTPList
            Instance.new("UICorner", row).CornerRadius = UDim.new(0, 4)

            local pName = Instance.new("TextLabel")
            pName.Size = UDim2.new(1, -40, 1, 0)
            pName.Position = UDim2.new(0, 6, 0, 0)
            pName.BackgroundTransparency = 1
            pName.Text = player.DisplayName
            pName.TextColor3 = Colors.bloodLight
            pName.TextSize = 10
            pName.Font = Enum.Font.GothamBold
            pName.TextXAlignment = Enum.TextXAlignment.Left
            pName.TextTruncate = Enum.TextTruncate.AtEnd
            pName.Parent = row

            local tpBtn2 = Instance.new("TextButton")
            tpBtn2.Size = UDim2.new(0, 28, 0, 18)
            tpBtn2.Position = UDim2.new(1, -32, 0, 4)
            tpBtn2.BackgroundColor3 = Colors.green
            tpBtn2.Text = "TP"
            tpBtn2.TextColor3 = Colors.text
            tpBtn2.TextSize = 9
            tpBtn2.Font = Enum.Font.GothamBold
            tpBtn2.AutoButtonColor = false
            tpBtn2.Parent = row
            Instance.new("UICorner", tpBtn2).CornerRadius = UDim.new(0, 4)
            makeHoverable(tpBtn2, Colors.green, Colors.greenLight)

            tpBtn2.MouseButton1Click:Connect(function()
                local myHRP2 = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                local c = player.Character
                if myHRP2 and c then
                    local hrp = c:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        myHRP2.CFrame = hrp.CFrame
                        notify("TP to " .. player.Name, "success")
                    end
                end
            end)
        end
    end
end
