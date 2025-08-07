local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local mouse = player:GetMouse()

local guiName = "MultiTabJanToolGUI"
local toggleName = "ToggleJanToolGUI"

-- Creates the GUI
local function createGui()
    if game.CoreGui:FindFirstChild(guiName) then
        return game.CoreGui[guiName]
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = guiName
    screenGui.ResetOnSpawn = false
    screenGui.Parent = game.CoreGui

    -- Main draggable frame
    local frame = Instance.new("Frame", screenGui)
    frame.Size = UDim2.new(0, 500, 0, 400)
    frame.Position = UDim2.new(0.5, -250, 0.5, -200)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    frame.Active = true
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

    -- Drag bar
    local dragBar = Instance.new("Frame", frame)
    dragBar.Size = UDim2.new(1, 0, 0, 40)
    dragBar.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    Instance.new("UICorner", dragBar).CornerRadius = UDim.new(0, 12)

    -- Title label
    local title = Instance.new("TextLabel", dragBar)
    title.Text = "Jan Tool GUI"
    title.Size = UDim2.new(1, -40, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.new(1,1,1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 20
    title.TextXAlignment = Enum.TextXAlignment.Left

    -- X close button
    local closeBtn = Instance.new("TextButton", dragBar)
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.new(1,1,1)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 18
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)

    -- Tab bar
    local tabBar = Instance.new("Frame", frame)
    tabBar.Size = UDim2.new(1, 0, 0, 40)
    tabBar.Position = UDim2.new(0, 0, 0, 50)
    tabBar.BackgroundTransparency = 1
    local layout = Instance.new("UIListLayout", tabBar)
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.Padding = UDim.new(0, 0)
    layout.SortOrder = Enum.SortOrder.LayoutOrder

    -- Content scroll area
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

    local tabNames = {"Main","Troll","Avatar","Tools"}

    local function clear()
        for _, c in pairs(scroll:GetChildren()) do
            if not c:IsA("UIListLayout") then
                c:Destroy()
            end
        end
    end

    local function populate(tab)
        clear()
        if tab == "Tools" then
            local btn = Instance.new("TextButton", scroll)
            btn.Size = UDim2.new(1, -10, 0, 50)
            btn.Text = "Jan Tool"
            btn.BackgroundColor3 = Color3.fromRGB(90, 90, 100)
            btn.TextColor3 = Color3.new(1,1,1)
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 20
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

            btn.MouseButton1Click:Connect(function()
                if not player.Backpack:FindFirstChild("JanTool") then
                    local tool = Instance.new("Tool")
                    tool.Name = "JanTool"
                    tool.RequiresHandle = false
                    tool.CanBeDropped = false
                    tool.Parent = player.Backpack

                    local selectedPart = nil
                    local offset = Vector3.new()
                    local moving = false

                    tool.Equipped:Connect(function()
                        RunService.RenderStepped:Connect(function()
                            if selectedPart and moving then
                                local ray = workspace.CurrentCamera:ScreenPointToRay(mouse.X, mouse.Y)
                                local newPos = ray.Origin + ray.Direction * 20 + offset
                                selectedPart.Position = newPos
                            end
                        end)
                    end)

                    mouse.Button1Down:Connect(function()
                        if tool.Parent == player.Character and mouse.Target and mouse.Target:IsA("BasePart") then
                            selectedPart = mouse.Target
                            if selectedPart.Anchored then
                                selectedPart.Anchored = false
                            end
                            selectedPart:SetNetworkOwner(player)
                            offset = selectedPart.Position - mouse.Hit.Position
                            moving = true
                        end
                    end)

                    mouse.Button1Up:Connect(function()
                        moving = false
                        selectedPart = nil
                    end)
                end
            end)
        else
            local label = Instance.new("TextLabel", scroll)
            label.Size = UDim2.new(1, -10, 0, 40)
            label.Text = tab.." content"
            label.BackgroundColor3 = Color3.fromRGB(70,70,80)
            label.TextColor3 = Color3.new(1,1,1)
            label.Font = Enum.Font.Gotham
            label.TextSize = 18
            Instance.new("UICorner", label).CornerRadius = UDim.new(0,6)
        end
    end

    for _, name in ipairs(tabNames) do
        local btn = Instance.new("TextButton", tabBar)
        btn.Size = UDim2.new(1/#tabNames,0,1,0)
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

    -- Draggable logic
    local dragging, startPos, dragStart
    dragBar.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = inp.Position
            startPos = frame.Position
            inp.Changed:Connect(function() if inp.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = inp.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    closeBtn.MouseButton1Click:Connect(function()
        screenGui.Enabled = false
        local toggle = game.CoreGui:FindFirstChild(toggleName)
        if toggle then toggle.ToggleButton.Text = "Open GUI" end
    end)

    return screenGui
end

-- Toggle button
local function createToggle()
    if game.CoreGui:FindFirstChild(toggleName) then return end
    local togglegui = Instance.new("ScreenGui", game.CoreGui)
    togglegui.Name = toggleName
    local btn = Instance.new("TextButton", togglegui)
    btn.Name = "ToggleButton"
    btn.Size = UDim2.new(0,120,0,40)
    btn.Position = UDim2.new(0,10,1,-50)
    btn.BackgroundColor3 = Color3.fromRGB(70,130,180)
    btn.Text = "Close GUI"
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 18
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)

    local gui = createGui()
    btn.MouseButton1Click:Connect(function()
        gui.Enabled = not gui.Enabled
        btn.Text = gui.Enabled and "Close GUI" or "Open GUI"
    end)
end

createToggle()
