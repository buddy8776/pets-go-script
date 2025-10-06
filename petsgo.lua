local Library = {}
Library.__index = Library

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Create ScreenGui
local function CreateScreenGui()
    local gui = Instance.new("ScreenGui")
    gui.Name = "ThugsenseMenu_" .. math.random(1000, 9999)
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.ResetOnSpawn = false
    gui.Parent = game:GetService("CoreGui")
    return gui
end

-- Utility Functions
local function Tween(obj, props, duration)
    duration = duration or 0.3
    local tween = TweenService:Create(obj, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
    tween:Play()
    return tween
end

local function MakeDraggable(frame, dragHandle)
    local dragging, dragInput, dragStart, startPos
    
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    
    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            Tween(frame, {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}, 0.1)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- Create Window
function Library:CreateWindow(config)
    config = config or {}
    local windowName = config.Name or "Thugsense Menu"
    local windowSize = config.Size or UDim2.new(0, 500, 0, 600)
    
    local gui = CreateScreenGui()
    
    -- Outer Border Frame
    local outerBorder = Instance.new("Frame")
    outerBorder.Name = "OuterBorder"
    outerBorder.Size = UDim2.new(0, windowSize.X.Offset + 8, 0, windowSize.Y.Offset + 8)
    outerBorder.Position = UDim2.new(0.5, -(windowSize.X.Offset + 8)/2, 0.5, -(windowSize.Y.Offset + 8)/2)
    outerBorder.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    outerBorder.BorderSizePixel = 0
    outerBorder.Parent = gui
    
    -- Main Container
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = windowSize
    mainFrame.Position = UDim2.new(0, 4, 0, 4)
    mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = outerBorder
    
    -- Inner Border (subtle inner glow)
    local innerBorder = Instance.new("Frame")
    innerBorder.Name = "InnerBorder"
    innerBorder.Size = UDim2.new(1, -2, 1, -2)
    innerBorder.Position = UDim2.new(0, 1, 0, 1)
    innerBorder.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    innerBorder.BorderColor3 = Color3.fromRGB(40, 40, 40)
    innerBorder.BorderSizePixel = 1
    innerBorder.Parent = mainFrame
    
    -- Top Bar
    local topBar = Instance.new("Frame")
    topBar.Name = "TopBar"
    topBar.Size = UDim2.new(1, -4, 0, 32)
    topBar.Position = UDim2.new(0, 2, 0, 2)
    topBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    topBar.BorderSizePixel = 0
    topBar.Parent = innerBorder
    
    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -10, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = windowName
    titleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    titleLabel.TextSize = 13
    titleLabel.Font = Enum.Font.SourceSans
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = topBar
    
    -- Tab Container (Horizontal tabs below title)
    local tabButtonContainer = Instance.new("Frame")
    tabButtonContainer.Name = "TabButtonContainer"
    tabButtonContainer.Size = UDim2.new(1, -4, 0, 28)
    tabButtonContainer.Position = UDim2.new(0, 2, 0, 34)
    tabButtonContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    tabButtonContainer.BorderSizePixel = 0
    tabButtonContainer.Parent = innerBorder
    
    local tabButtonList = Instance.new("UIListLayout")
    tabButtonList.FillDirection = Enum.FillDirection.Horizontal
    tabButtonList.SortOrder = Enum.SortOrder.LayoutOrder
    tabButtonList.Padding = UDim.new(0, 0)
    tabButtonList.Parent = tabButtonContainer
    
    -- Content Container
    local contentContainer = Instance.new("Frame")
    contentContainer.Name = "ContentContainer"
    contentContainer.Size = UDim2.new(1, -8, 1, -70)
    contentContainer.Position = UDim2.new(0, 4, 0, 66)
    contentContainer.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    contentContainer.BorderSizePixel = 0
    contentContainer.Parent = innerBorder
    
    -- Make Draggable
    MakeDraggable(outerBorder, topBar)
    
    -- Intro Animation
    outerBorder.Size = UDim2.new(0, 0, 0, 0)
    Tween(outerBorder, {Size = UDim2.new(0, windowSize.X.Offset + 8, 0, windowSize.Y.Offset + 8)}, 0.3)
    
    local Window = {
        GUI = gui,
        OuterBorder = outerBorder,
        MainFrame = mainFrame,
        TabButtonContainer = tabButtonContainer,
        ContentContainer = contentContainer,
        Tabs = {},
        TabButtons = {}
    }
    
    function Window:CreateTab(tabName)
        local isFirst = #Window.Tabs == 0
        
        -- Tab Button
        local tabButton = Instance.new("TextButton")
        tabButton.Name = tabName
        tabButton.Size = UDim2.new(0, 90, 1, 0)
        tabButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        tabButton.Text = tabName
        tabButton.TextColor3 = Color3.fromRGB(150, 150, 150)
        tabButton.TextSize = 12
        tabButton.Font = Enum.Font.SourceSans
        tabButton.BorderSizePixel = 0
        tabButton.AutoButtonColor = false
        tabButton.Parent = tabButtonContainer
        
        -- Tab Content
        local tabContent = Instance.new("ScrollingFrame")
        tabContent.Name = tabName .. "Content"
        tabContent.Size = UDim2.new(1, 0, 1, 0)
        tabContent.BackgroundTransparency = 1
        tabContent.BorderSizePixel = 0
        tabContent.ScrollBarThickness = 6
        tabContent.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 60)
        tabContent.Visible = isFirst
        tabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        tabContent.Parent = contentContainer
        
        local contentList = Instance.new("UIListLayout")
        contentList.Padding = UDim.new(0, 6)
        contentList.SortOrder = Enum.SortOrder.LayoutOrder
        contentList.Parent = tabContent
        
        local contentPadding = Instance.new("UIPadding")
        contentPadding.PaddingTop = UDim.new(0, 8)
        contentPadding.PaddingLeft = UDim.new(0, 8)
        contentPadding.PaddingRight = UDim.new(0, 8)
        contentPadding.PaddingBottom = UDim.new(0, 8)
        contentPadding.Parent = tabContent
        
        contentList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            tabContent.CanvasSize = UDim2.new(0, 0, 0, contentList.AbsoluteContentSize.Y + 16)
        end)
        
        tabButton.MouseEnter:Connect(function()
            if not tabContent.Visible then
                tabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
            end
        end)
        
        tabButton.MouseLeave:Connect(function()
            if not tabContent.Visible then
                tabButton.TextColor3 = Color3.fromRGB(150, 150, 150)
            end
        end)
        
        tabButton.MouseButton1Click:Connect(function()
            for _, tab in pairs(Window.Tabs) do
                tab.Content.Visible = false
            end
            
            for _, btn in pairs(Window.TabButtons) do
                btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
                btn.TextColor3 = Color3.fromRGB(150, 150, 150)
            end
            
            tabContent.Visible = true
            tabButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            tabButton.TextColor3 = Color3.fromRGB(220, 220, 220)
        end)
        
        table.insert(Window.TabButtons, tabButton)
        
        local Tab = {
            Button = tabButton,
            Content = tabContent
        }
        
        table.insert(Window.Tabs, Tab)
        
        if isFirst then
            tabButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            tabButton.TextColor3 = Color3.fromRGB(220, 220, 220)
        end
        
        function Tab:CreateButton(config)
            config = config or {}
            local btnText = config.Name or "Button"
            local callback = config.Callback or function() end
            
            local button = Instance.new("TextButton")
            button.Size = UDim2.new(1, -6, 0, 32)
            button.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            button.Text = btnText
            button.TextColor3 = Color3.fromRGB(200, 200, 200)
            button.TextSize = 13
            button.Font = Enum.Font.SourceSans
            button.BorderColor3 = Color3.fromRGB(45, 45, 45)
            button.BorderSizePixel = 1
            button.AutoButtonColor = false
            button.Parent = tabContent
            
            button.MouseEnter:Connect(function()
                button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            end)
            
            button.MouseLeave:Connect(function()
                button.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            end)
            
            button.MouseButton1Click:Connect(function()
                callback()
            end)
            
            return button
        end
        
        function Tab:CreateToggle(config)
            config = config or {}
            local toggleText = config.Name or "Toggle"
            local default = config.Default or false
            local callback = config.Callback or function() end
            
            local toggleFrame = Instance.new("Frame")
            toggleFrame.Size = UDim2.new(1, -6, 0, 32)
            toggleFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            toggleFrame.BorderColor3 = Color3.fromRGB(45, 45, 45)
            toggleFrame.BorderSizePixel = 1
            toggleFrame.Parent = tabContent
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -50, 1, 0)
            label.Position = UDim2.new(0, 8, 0, 0)
            label.BackgroundTransparency = 1
            label.Text = toggleText
            label.TextColor3 = Color3.fromRGB(200, 200, 200)
            label.TextSize = 13
            label.Font = Enum.Font.SourceSans
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = toggleFrame
            
            local toggleBtn = Instance.new("TextButton")
            toggleBtn.Size = UDim2.new(0, 40, 0, 20)
            toggleBtn.Position = UDim2.new(1, -46, 0.5, -10)
            toggleBtn.BackgroundColor3 = default and Color3.fromRGB(60, 120, 60) or Color3.fromRGB(50, 50, 50)
            toggleBtn.Text = default and "ON" or "OFF"
            toggleBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
            toggleBtn.TextSize = 11
            toggleBtn.Font = Enum.Font.SourceSansBold
            toggleBtn.BorderColor3 = Color3.fromRGB(70, 70, 70)
            toggleBtn.BorderSizePixel = 1
            toggleBtn.AutoButtonColor = false
            toggleBtn.Parent = toggleFrame
            
            local toggled = default
            
            toggleBtn.MouseButton1Click:Connect(function()
                toggled = not toggled
                
                if toggled then
                    toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 60)
                    toggleBtn.Text = "ON"
                else
                    toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                    toggleBtn.Text = "OFF"
                end
                
                callback(toggled)
            end)
            
            return toggleFrame
        end
        
        function Tab:CreateSlider(config)
            config = config or {}
            local sliderText = config.Name or "Slider"
            local min = config.Min or 0
            local max = config.Max or 100
            local default = config.Default or min
            local callback = config.Callback or function() end
            
            local sliderFrame = Instance.new("Frame")
            sliderFrame.Size = UDim2.new(1, -6, 0, 48)
            sliderFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            sliderFrame.BorderColor3 = Color3.fromRGB(45, 45, 45)
            sliderFrame.BorderSizePixel = 1
            sliderFrame.Parent = tabContent
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -60, 0, 20)
            label.Position = UDim2.new(0, 8, 0, 4)
            label.BackgroundTransparency = 1
            label.Text = sliderText
            label.TextColor3 = Color3.fromRGB(200, 200, 200)
            label.TextSize = 13
            label.Font = Enum.Font.SourceSans
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = sliderFrame
            
            local valueLabel = Instance.new("TextLabel")
            valueLabel.Size = UDim2.new(0, 50, 0, 20)
            valueLabel.Position = UDim2.new(1, -56, 0, 4)
            valueLabel.BackgroundTransparency = 1
            valueLabel.Text = tostring(default)
            valueLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
            valueLabel.TextSize = 12
            valueLabel.Font = Enum.Font.SourceSans
            valueLabel.TextXAlignment = Enum.TextXAlignment.Right
            valueLabel.Parent = sliderFrame
            
            local sliderBar = Instance.new("Frame")
            sliderBar.Size = UDim2.new(1, -16, 0, 8)
            sliderBar.Position = UDim2.new(0, 8, 1, -14)
            sliderBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            sliderBar.BorderColor3 = Color3.fromRGB(60, 60, 60)
            sliderBar.BorderSizePixel = 1
            sliderBar.Parent = sliderFrame
            
            local sliderFill = Instance.new("Frame")
            sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
            sliderFill.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
            sliderFill.BorderSizePixel = 0
            sliderFill.Parent = sliderBar
            
            local sliderBtn = Instance.new("TextButton")
            sliderBtn.Size = UDim2.new(1, 0, 1, 0)
            sliderBtn.BackgroundTransparency = 1
            sliderBtn.Text = ""
            sliderBtn.Parent = sliderBar
            
            local dragging = false
            
            sliderBtn.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                end
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)
            
            sliderBtn.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local pos = math.clamp((input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
                    local value = math.floor(min + (max - min) * pos)
                    
                    sliderFill.Size = UDim2.new(pos, 0, 1, 0)
                    valueLabel.Text = tostring(value)
                    callback(value)
                end
            end)
            
            return sliderFrame
        end
        
        function Tab:CreateTextbox(config)
            config = config or {}
            local boxText = config.Name or "Textbox"
            local placeholder = config.Placeholder or "Enter text..."
            local callback = config.Callback or function() end
            
            local boxFrame = Instance.new("Frame")
            boxFrame.Size = UDim2.new(1, -6, 0, 58)
            boxFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            boxFrame.BorderColor3 = Color3.fromRGB(45, 45, 45)
            boxFrame.BorderSizePixel = 1
            boxFrame.Parent = tabContent
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -16, 0, 20)
            label.Position = UDim2.new(0, 8, 0, 4)
            label.BackgroundTransparency = 1
            label.Text = boxText
            label.TextColor3 = Color3.fromRGB(200, 200, 200)
            label.TextSize = 13
            label.Font = Enum.Font.SourceSans
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = boxFrame
            
            local textbox = Instance.new("TextBox")
            textbox.Size = UDim2.new(1, -16, 0, 26)
            textbox.Position = UDim2.new(0, 8, 0, 26)
            textbox.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
            textbox.PlaceholderText = placeholder
            textbox.Text = ""
            textbox.TextColor3 = Color3.fromRGB(200, 200, 200)
            textbox.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
            textbox.TextSize = 12
            textbox.Font = Enum.Font.SourceSans
            textbox.BorderColor3 = Color3.fromRGB(50, 50, 50)
            textbox.BorderSizePixel = 1
            textbox.ClearTextOnFocus = false
            textbox.Parent = boxFrame
            
            textbox.FocusLost:Connect(function(enter)
                if enter then
                    callback(textbox.Text)
                end
            end)
            
            return boxFrame
        end
        
        function Tab:CreateLabel(text)
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -6, 0, 28)
            label.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            label.Text = text
            label.TextColor3 = Color3.fromRGB(180, 180, 180)
            label.TextSize = 13
            label.Font = Enum.Font.SourceSans
            label.BorderColor3 = Color3.fromRGB(45, 45, 45)
            label.BorderSizePixel = 1
            label.Parent = tabContent
            
            return label
        end
        
        return Tab
    end
    
    return Window
end

return Library
