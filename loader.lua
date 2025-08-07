-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

local guiName = "Prow Universal Script"
local toggleName = "ToggleJanToolGUI"
local connections = {}

-- Fly State
local isFlying = false
local flySpeed = 50
local flyHotkey = Enum.KeyCode.F
local flyGyro, flyVelocity

-- Destroy everything on F2
local function killScript()
    if game.CoreGui:FindFirstChild(guiName) then game.CoreGui[guiName]:Destroy() end
    if game.CoreGui:FindFirstChild(toggleName) then game.CoreGui[toggleName]:Destroy() end
    for _, conn in ipairs(connections) do pcall(function() conn:Disconnect() end) end
end
-- Start Fly
local function startFly()
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    flyGyro = Instance.new("BodyGyro")
    flyGyro.P = 9e4
    flyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    flyGyro.CFrame = hrp.CFrame
    flyGyro.Parent = hrp

    flyVelocity = Instance.new("BodyVelocity")
    flyVelocity.Velocity = Vector3.new(0,0,0)
    flyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    flyVelocity.Parent = hrp
end

-- Stop Fly
local function stopFly()
    if flyGyro then flyGyro:Destroy() flyGyro = nil end
    if flyVelocity then flyVelocity:Destroy() flyVelocity = nil end
end

-- Fly Movement
local function updateFly()
    local cam = workspace.CurrentCamera
    local moveVec = Vector3.new(0,0,0)

    if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVec = moveVec + cam.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVec = moveVec - cam.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVec = moveVec - cam.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVec = moveVec + cam.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveVec = moveVec + Vector3.new(0,1,0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveVec = moveVec - Vector3.new(0,1,0) end

    if flyVelocity then 
        if moveVec.Magnitude > 0 then
            flyVelocity.Velocity = moveVec.Unit * flySpeed
        else
            flyVelocity.Velocity = Vector3.new(0,0,0)
        end
    end
    if flyGyro then flyGyro.CFrame = cam.CFrame end
end
-- Input connections
table.insert(connections, UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.F2 then
        killScript()
    elseif input.KeyCode == flyHotkey then
        isFlying = not isFlying
        if isFlying then
            startFly()
        else
            stopFly()
        end
    end
end))

table.insert(connections, RunService.RenderStepped:Connect(function()
    if isFlying then
        updateFly()
    end
end))
local function createGui()
    if game.CoreGui:FindFirstChild(guiName) then return end

    local screenGui = Instance.new("ScreenGui", game.CoreGui)
    screenGui.Name = guiName
    screenGui.ResetOnSpawn = false

    local frame = Instance.new("Frame", screenGui)
    frame.Size = UDim2.new(0, 500, 0, 400)
    frame.Position = UDim2.new(0.5, -250, 0.5, -200)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    frame.Active = true
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

    local dragBar = Instance.new("Frame", frame)
    dragBar.Size = UDim2.new(1, 0, 0, 40)
    dragBar.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    Instance.new("UICorner", dragBar).CornerRadius = UDim.new(0, 12)

    local title = Instance.new("TextLabel", dragBar)
    title.Text = "Prow Universal Script"
    title.Size = UDim2.new(1, -40, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.new(1,1,1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 20
    title.TextXAlignment = Enum.TextXAlignment.Left

    local closeBtn = Instance.new("TextButton", dragBar)
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.new(1,1,1)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 18
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)
    closeBtn.MouseButton1Click:Connect(function() screenGui.Enabled = false end)

    -- Tab Bar
    local tabBar = Instance.new("Frame", frame)
    tabBar.Size = UDim2.new(1, 0, 0, 40)
    tabBar.Position = UDim2.new(0, 0, 0, 50)
    tabBar.BackgroundTransparency = 1
    local layout = Instance.new("UIListLayout", tabBar)
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.SortOrder = Enum.SortOrder.LayoutOrder

    -- Scroll Frame
    local scroll = Instance.new("ScrollingFrame", frame)
    scroll.Size = UDim2.new(1, -20, 1, -100)
    scroll.Position = UDim2.new(0, 10, 0, 100)
    scroll.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    scroll.BorderSizePixel = 0
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.ScrollBarThickness = 8
    Instance.new("UICorner", scroll).CornerRadius = UDim.new(0, 8)
    local innerLayout = Instance.new("UIListLayout", scroll)
    innerLayout.Padding = UDim.new(0, 6)
    innerLayout.SortOrder = Enum.SortOrder.LayoutOrder
    local function clear()
        for _, c in pairs(scroll:GetChildren()) do
            if not c:IsA("UIListLayout") then
                c:Destroy()
            end
        end
    end

    local function populate(tab)
        clear()
        if tab == "Player" then
            local label = Instance.new("TextLabel", scroll)
            label.Size = UDim2.new(1, -10, 0, 30)
            label.Text = "Fly Controls:"
            label.BackgroundTransparency = 1
            label.TextColor3 = Color3.new(1,1,1)
            label.Font = Enum.Font.GothamBold
            label.TextSize = 16

            local hotkeyBox = Instance.new("TextBox", scroll)
            hotkeyBox.Size = UDim2.new(0.48, -5, 0, 30)
            hotkeyBox.PlaceholderText = "Hotkey (e.g. F)"
            hotkeyBox.Text = flyHotkey.Name
            hotkeyBox.BackgroundColor3 = Color3.fromRGB(70,70,80)
            hotkeyBox.TextColor3 = Color3.new(1,1,1)
            hotkeyBox.Font = Enum.Font.Gotham
            hotkeyBox.TextSize = 16
            hotkeyBox.ClearTextOnFocus = false
            hotkeyBox.FocusLost:Connect(function()
                local val = hotkeyBox.Text:upper()
                local newKey = Enum.KeyCode[val]
                if newKey then flyHotkey = newKey end
                hotkeyBox.Text = flyHotkey.Name
            end)

            local speedBox = Instance.new("TextBox", scroll)
            speedBox.Size = UDim2.new(0.48, -5, 0, 30)
            speedBox.Position = UDim2.new(0.52, 0, 0, 0)
            speedBox.PlaceholderText = "Fly Speed"
            speedBox.Text = tostring(flySpeed)
            speedBox.BackgroundColor3 = Color3.fromRGB(70,70,80)
            speedBox.TextColor3 = Color3.new(1,1,1)
            speedBox.Font = Enum.Font.Gotham
            speedBox.TextSize = 16
            speedBox.ClearTextOnFocus = false
            speedBox.FocusLost:Connect(function()
                local val = tonumber(speedBox.Text)
                if val and val > 0 and val <= 500 then
                    flySpeed = val
                end
                speedBox.Text = tostring(flySpeed)
            end)

            local toggleFlyBtn = Instance.new("TextButton", scroll)
            toggleFlyBtn.Size = UDim2.new(1, -10, 0, 30)
            toggleFlyBtn.Position = UDim2.new(0, 0, 0, 40)
            toggleFlyBtn.Text = isFlying and "Disable Fly" or "Enable Fly"
            toggleFlyBtn.BackgroundColor3 = Color3.fromRGB(70,130,180)
            toggleFlyBtn.TextColor3 = Color3.new(1,1,1)
            toggleFlyBtn.Font = Enum.Font.GothamBold
            toggleFlyBtn.TextSize = 18
            toggleFlyBtn.MouseButton1Click:Connect(function()
                isFlying = not isFlying
                if isFlying then
                    startFly()
                else
                    stopFly()
                end
                toggleFlyBtn.Text = isFlying and "Disable Fly" or "Enable Fly"
            end)
        else
            local label = Instance.new("TextLabel", scroll)
            label.Size = UDim2.new(1, -10, 0, 40)
            label.Text = tab .. " content"
            label.BackgroundColor3 = Color3.fromRGB(70,70,80)
            label.TextColor3 = Color3.new(1,1,1)
            label.Font = Enum.Font.Gotham
            label.TextSize = 18
            Instance.new("UICorner", label).CornerRadius = UDim.new(0,6)
        end
    end

    local tabNames = {"Main", "Player", "Troll", "Avatar", "Tools"}
    for _, name in ipairs(tabNames) do
        local btn = Instance.new("TextButton", tabBar)
        btn.Size = UDim2.new(1/#tabNames, 0, 1, 0)
        btn.Text = name
        btn.BackgroundColor3 = Color3.fromRGB(80,80,90)
        btn.TextColor3 = Color3.new(1,1,1)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 16
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0,0)
        btn.MouseButton1Click:Connect(function()
            populate(name)
        end)
    end

    populate("Main")
    -- Dragging
    local dragging = false
    local dragStart, startPos
    dragBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    return screenGui
end
local function createToggle()
    if game.CoreGui:FindFirstChild(toggleName) then return end

    local toggleGui = Instance.new("ScreenGui", game.CoreGui)
    toggleGui.Name = toggleName

    local btn = Instance.new("TextButton", toggleGui)
    btn.Name = "ToggleButton"
    btn.Size = UDim2.new(0, 120, 0, 40)
    btn.Position = UDim2.new(0, 10, 1, -50)
    btn.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
    btn.Text = "Close GUI"
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 18
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    local mainGui = createGui()
    btn.MouseButton1Click:Connect(function()
        mainGui.Enabled = not mainGui.Enabled
        btn.Text = mainGui.Enabled and "Close GUI" or "Open GUI"
    end)
end

createToggle()
