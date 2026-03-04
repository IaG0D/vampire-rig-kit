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
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then
        notify("No character found", "error")
        return
    end

    -- Clean up old
    if flyBG then pcall(function() flyBG:Destroy() end) end
    if flyBV then pcall(function() flyBV:Destroy() end) end

    -- Disable falling animation
    hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
    hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    hum:ChangeState(Enum.HumanoidStateType.Physics)

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
        -- Keep humanoid from falling state
        if hum:GetState() == Enum.HumanoidStateType.Freefall then
            hum:ChangeState(Enum.HumanoidStateType.Physics)
        end

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

    -- Re-enable falling states
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
    end

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
        mouseBehavior = UIS.MouseBehavior,
        mouseIcon = UIS.MouseIconEnabled,
    }
    cam.CameraType = Enum.CameraType.Scriptable

    -- Extract initial yaw/pitch from current camera
    local rx, ry, _ = cam.CFrame:ToEulerAnglesYXZ()
    local yaw = ry
    local pitch = rx
    local sensitivity = 0.003

    -- Lock mouse to center + hide cursor
    UIS.MouseBehavior = Enum.MouseBehavior.LockCenter
    UIS.MouseIconEnabled = false

    -- Anchor character so it doesn't move while in freecam
    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.Anchored = true
    end

    freecamConnection = RunService.RenderStepped:Connect(function(dt)
        -- Mouse rotation
        local delta = UIS:GetMouseDelta()
        yaw = yaw - delta.X * sensitivity
        pitch = math.clamp(pitch - delta.Y * sensitivity, -math.rad(89), math.rad(89))

        local rotation = CFrame.fromEulerAnglesYXZ(pitch, yaw, 0)

        -- Movement
        local speed = movementState.speed * 2
        local move = Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then move = move + rotation.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then move = move - rotation.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then move = move - rotation.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then move = move + rotation.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.yAxis end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.yAxis end

        local pos = cam.CFrame.Position
        if move.Magnitude > 0 then
            pos = pos + move.Unit * speed * dt
        end

        cam.CFrame = CFrame.new(pos) * rotation
    end)

    notify("Freecam ON (mouse to look)", "success")
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

    -- Sempre restaurar mouse primeiro (evita ficar travado)
    UIS.MouseBehavior = Enum.MouseBehavior.Default
    UIS.MouseIconEnabled = true

    if savedCameraState then
        -- Verifica se o subject salvo ainda é valido
        local subject = savedCameraState.subject
        local subjectValid = false
        pcall(function()
            subjectValid = subject and subject.Parent ~= nil
        end)

        if subjectValid then
            cam.CameraSubject = subject
        else
            -- Subject morreu/respawnou — usa humanoid atual
            local newChar = LP.Character
            local newHum = newChar and newChar:FindFirstChildOfClass("Humanoid")
            if newHum then
                cam.CameraSubject = newHum
            end
        end

        cam.CameraType = Enum.CameraType.Custom
        savedCameraState = nil
    else
        -- Fallback: restaura camera pro character atual
        local newChar = LP.Character
        local newHum = newChar and newChar:FindFirstChildOfClass("Humanoid")
        if newHum then
            cam.CameraSubject = newHum
        end
        cam.CameraType = Enum.CameraType.Custom
    end

    notify("Freecam OFF", "info")
    log("Freecam OFF")
end
