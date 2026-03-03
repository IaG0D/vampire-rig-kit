--==================================================
-- MOVEMENT LOGIC
--==================================================

-- Apply speed/jump to humanoid
applySpeed = function()
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = movementState.speed
        hum.UseJumpPower = true
        hum.JumpPower = movementState.jumpPower
    end
end

--==================================================
-- FLY
--==================================================

startFly = function()
    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then
        notify("No character found", "error")
        return
    end

    -- Clean up old
    if flyBG then pcall(function() flyBG:Destroy() end) end
    if flyBV then pcall(function() flyBV:Destroy() end) end

    flyBG = Instance.new("BodyGyro")
    flyBG.MaxTorque = Vector3.new(4e5, 4e5, 4e5)
    flyBG.P = 10000
    flyBG.D = 500
    flyBG.Parent = hrp

    flyBV = Instance.new("BodyVelocity")
    flyBV.MaxForce = Vector3.new(4e5, 4e5, 4e5)
    flyBV.Velocity = Vector3.zero
    flyBV.Parent = hrp

    flyConnection = RunService.RenderStepped:Connect(function()
        local cam = workspace.CurrentCamera
        local dir = Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.yAxis end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.yAxis end

        if dir.Magnitude > 0 then
            flyBV.Velocity = dir.Unit * movementState.speed * 3
        else
            flyBV.Velocity = Vector3.zero
        end
        flyBG.CFrame = cam.CFrame
    end)

    notify("Fly ON", "success")
    log("Fly ON")
end

stopFly = function()
    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end
    if flyBG then pcall(function() flyBG:Destroy() end) flyBG = nil end
    if flyBV then pcall(function() flyBV:Destroy() end) flyBV = nil end

    notify("Fly OFF", "info")
    log("Fly OFF")
end

--==================================================
-- NOCLIP
--==================================================

toggleNoclip = function()
    if movementState.noclip then
        noclipConnection = RunService.Stepped:Connect(function()
            local char = LP.Character
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
        notify("Noclip ON", "success")
        log("Noclip ON")
    else
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
        notify("Noclip OFF", "info")
        log("Noclip OFF")
    end
end

--==================================================
-- INFINITE JUMP
--==================================================

toggleInfiniteJump = function()
    if movementState.infiniteJump then
        jumpConnection = UIS.JumpRequest:Connect(function()
            local char = LP.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
        notify("Infinite Jump ON", "success")
        log("Infinite Jump ON")
    else
        if jumpConnection then
            jumpConnection:Disconnect()
            jumpConnection = nil
        end
        notify("Infinite Jump OFF", "info")
        log("Infinite Jump OFF")
    end
end

--==================================================
-- FREECAM
--==================================================

startFreecam = function()
    local cam = workspace.CurrentCamera
    savedCameraState = {
        subject = cam.CameraSubject,
        ctype = cam.CameraType,
    }
    cam.CameraType = Enum.CameraType.Scriptable

    -- Anchor character so it doesn't move while in freecam
    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.Anchored = true
    end

    freecamConnection = RunService.RenderStepped:Connect(function(dt)
        local speed = movementState.speed * 2
        local move = Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then move = move + cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then move = move - cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then move = move - cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then move = move + cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.yAxis end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.yAxis end

        if move.Magnitude > 0 then
            cam.CFrame = cam.CFrame + move.Unit * speed * dt
        end
    end)

    notify("Freecam ON", "success")
    log("Freecam ON")
end

stopFreecam = function()
    if freecamConnection then
        freecamConnection:Disconnect()
        freecamConnection = nil
    end

    -- Unanchor character
    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.Anchored = false
    end

    local cam = workspace.CurrentCamera
    if savedCameraState then
        cam.CameraType = savedCameraState.ctype
        cam.CameraSubject = savedCameraState.subject
        savedCameraState = nil
    end
    notify("Freecam OFF", "info")
    log("Freecam OFF")
end
