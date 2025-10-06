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
    
    -- Outer Border Frame (Gray border)
    local outerBorder = Instance.new("Frame")
    outerBorder.Name = "OuterBorder"
    outerBorder.Size = UDim2.new(0, windowSize.X.Offset + 10, 0, windowSize.Y.Offset + 10)
    outerBorder.Position = UDim2.new(0.5, -(windowSize.X.Offset + 10)/2, 0.5, -(windowSize.Y.Offset + 10)/2)
    outerBorder.BackgroundColor3 = Color3.fromRGB(90, 90, 100)
    outerBorder.BorderSizePixel = 0
    outerBorder.Parent = gui
    
    local outerCorner = Instance.new("UICorner")
    outerCorner.CornerRadius = UDim.new(0, 6)
    outerCorner.Parent = outerBorder
    
    -- Main Container
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = windowSize
    mainFrame.Position = UDim2.new(0, 5, 0, 5)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = outerBorder
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 4)
    mainCorner.Parent = mainFrame
    
    -- Top Bar
    local topBar = Instance.new("Frame")
    topBar.Name = "TopBar"
    topBar.Size = UDim2.new(1, 0, 0, 35)
    topBar.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    topBar.BorderSizePixel = 0
    topBar.Parent = mainFrame
    
    local topCorner = Instance.new("UICorner")
    topCorner.CornerRadius = UDim.new(0, 4)
    topCorner.Parent = topBar
    
    -- Cover bottom of top bar corner
    local topBarBottom = Instance.new("Frame")
    topBarBottom.Size = UDim2.new(1, 0, 0, 4)
    topBarBottom.Position = UDim2.new(0, 0, 1, -4)
    topBarBottom.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    topBarBottom.BorderSizePixel = 0
    topBarBottom.Parent = topBar
    
    -- Title with gradient
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -80, 1, 0)
    titleLabel.Position = UDim2.new(0, 15, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = windowName
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 15
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = topBar
    
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 100, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 140, 255))
    }
    gradient.Parent = titleLabel
    
    -- Close Button (Red X)
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseButton"
    closeBtn.Size = UDim2.new(0, 28, 0, 28)
    closeBtn.Position = UDim2.new(1, -32, 0, 4)
    closeBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 60)
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 18
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.BorderSizePixel = 0
    closeBtn.AutoButtonColor = false
    closeBtn.Parent = topBar
    
    local closeBtnCorner = Instance.new("UICorner")
    closeBtnCorner.CornerRadius = UDim.new(0, 4)
    closeBtnCorner.Parent = closeBtn
    
    closeBtn.MouseEnter:Connect(function()
        Tween(closeBtn, {BackgroundColor3 = Color3.fromRGB(240, 70, 80)})
    end)
    
    closeBtn.MouseLeave:Connect(function()
        Tween(closeBtn, {BackgroundColor3 = Color3.fromRGB(220, 50, 60)})
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        Tween(outerBorder, {Size = UDim2.new(0, 0, 0, 0)}, 0.3)
        wait(0.3)
        gui:Destroy()
    end)
    
    -- Vertical Tab Container (Left side)
    local tabContainer = Instance.new("Frame")
    tabContainer.Name = "TabContainer"
    tabContainer.Size = UDim2.new(0, 130, 1, -45)
    tabContainer.Position = UDim2.new(0, 10, 0, 40)
    tabContainer.BackgroundTransparency = 1
    tabContainer.BorderSizePixel = 0
    tabContainer.Parent = mainFrame
    
    local tabList = Instance.new("UIListLayout")
    tabList.Padding = UDim.new(0, 8)
    tabList.SortOrder = Enum.SortOrder.LayoutOrder
    tabList.Parent = tabContainer
    
    -- Content Container (Right side with scrollbar)
    local contentContainer = Instance.new("Frame")
    contentContainer.Name = "ContentContainer"
    contentContainer.Size = UDim2.new(1, -155, 1, -45)
    contentContainer.Position = UDim2.new(0, 145, 0, 40)
    contentContainer.BackgroundTransparency = 1
    contentContainer.BorderSizePixel = 0
    contentContainer.Parent = mainFrame
    
    -- Make Draggable
    MakeDraggable(outerBorder, topBar)
    
    -- Intro Animation
    outerBorder.Size = UDim2.new(0, 0, 0, 0)
    Tween(outerBorder, {Size = UDim2.new(0, windowSize.X.Offset + 10, 0, windowSize.Y.Offset + 10)}, 0.3)
    
    local Window = {
        GUI = gui,
        OuterBorder = outerBorder,
        MainFrame = mainFrame,
        TabContainer = tabContainer,
        ContentContainer = contentContainer,
        Tabs = {},
        TabButtons = {}
    }
    
    function Window:CreateTab(tabName)
        local isFirst = #Window.Tabs == 0
        
        -- Tab Button (Purple rounded button)
        local tabButton = Instance.new("TextButton")
        tabButton.Name = tabName
        tabButton.Size = UDim2.new(1, 0, 0, 32)
        tabButton.BackgroundColor3 = isFirst and Color3.fromRGB(100, 80, 200) or Color3.fromRGB(30, 30, 40)
        tabButton.Text = tabName
        tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        tabButton.TextSize = 14
        tabButton.Font = Enum.Font.Gotham
        tabButton.BorderSizePixel = 0
        tabButton.AutoButtonColor = false
        tabButton.Parent = tabContainer
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 6)
        btnCorner.Parent = tabButton
        
        -- Tab Content (Scrolling frame)
        local tabContent = Instance.new("ScrollingFrame")
        tabContent.Name = tabName .. "Content"
        tabContent.Size = UDim2.new(1, 0, 1, 0)
        tabContent.BackgroundTransparency = 1
        tabContent.BorderSizePixel = 0
        tabContent.ScrollBarThickness = 4
        tabContent.ScrollBarImageColor3 = Color3.fromRGB(100, 80, 200)
        tabContent.Visible = isFirst
        tabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        tabContent.Parent = contentContainer
        
        local contentList = Instance.new("UIListLayout")
        contentList.Padding = UDim.new(0, 8)
        contentList.SortOrder = Enum.SortOrder.LayoutOrder
        contentList.Parent = tabContent
        
        local contentPadding = Instance.new("UIPadding")
        contentPadding.PaddingTop = UDim.new(0, 5)
        contentPadding.PaddingLeft = UDim.new(0, 5)
        contentPadding.PaddingRight = UDim.new(0, 5)
        contentPadding.PaddingBottom = UDim.new(0, 5)
        contentPadding.Parent = tabContent
        
        contentList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            tabContent.CanvasSize = UDim2.new(0, 0, 0, contentList.AbsoluteContentSize.Y + 10)
        end)
        
        tabButton.MouseEnter:Connect(function()
            if not tabContent.Visible then
                Tween(tabButton, {BackgroundColor3 = Color3.fromRGB(45, 45, 60)})
            end
        end)
        
        tabButton.MouseLeave:Connect(function()
            if not tabContent.Visible then
                Tween(tabButton, {BackgroundColor3 = Color3.fromRGB(30, 30, 40)})
            end
        end)
        
        tabButton.MouseButton1Click:Connect(function()
            for _, tab in pairs(Window.Tabs) do
                tab.Content.Visible = false
            end
            
            for _, btn in pairs(Window.TabButtons) do
                Tween(btn, {BackgroundColor3 = Color3.fromRGB(30, 30, 40)})
            end
            
            tabContent.Visible = true
            Tween(tabButton, {BackgroundColor3 = Color3.fromRGB(100, 80, 200)})
        end)
        
        table.insert(Window.TabButtons, tabButton)
        
        local Tab = {
            Button = tabButton,
            Content = tabContent
        }
        
        table.insert(Window.Tabs, Tab)
        
        function Tab:CreateButton(config)
            config = config or {}
            local btnText = config.Name or "Button"
            local callback = config.Callback or function() end
            
            local button = Instance.new("TextButton")
            button.Size = UDim2.new(1, -10, 0, 36)
            button.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
            button.Text = btnText
            button.TextColor3 = Color3.fromRGB(220, 220, 220)
            button.TextSize = 14
            button.Font = Enum.Font.Gotham
            button.BorderSizePixel = 0
            button.AutoButtonColor = false
            button.Parent = tabContent
            
            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 6)
            btnCorner.Parent = button
            
            button.MouseEnter:Connect(function()
                Tween(button, {BackgroundColor3 = Color3.fromRGB(90, 70, 180)})
            end)
            
            button.MouseLeave:Connect(function()
                Tween(button, {BackgroundColor3 = Color3.fromRGB(35, 35, 45)})
            end)
            
            button.MouseButton1Click:Connect(function()
                Tween(button, {BackgroundColor3 = Color3.fromRGB(110, 90, 200)}, 0.1)
                wait(0.1)
                Tween(button, {BackgroundColor3 = Color3.fromRGB(90, 70, 180)}, 0.1)
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
            toggleFrame.Size = UDim2.new(1, -10, 0, 36)
            toggleFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
            toggleFrame.BorderSizePixel = 0
            toggleFrame.Parent = tabContent
            
            local toggleCorner = Instance.new("UICorner")
            toggleCorner.CornerRadius = UDim.new(0, 6)
            toggleCorner.Parent = toggleFrame
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -60, 1, 0)
            label.Position = UDim2.new(0, 12, 0, 0)
            label.BackgroundTransparency = 1
            label.Text = toggleText
            label.TextColor3 = Color3.fromRGB(220, 220, 220)
            label.TextSize = 14
            label.Font = Enum.Font.Gotham
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = toggleFrame
            
            local toggleBtn = Instance.new("TextButton")
            toggleBtn.Size = UDim2.new(0, 42, 0, 20)
            toggleBtn.Position = UDim2.new(1, -50, 0.5, -10)
            toggleBtn.BackgroundColor3 = default and Color3.fromRGB(90, 180, 90) or Color3.fromRGB(60, 60, 70)
            toggleBtn.Text = ""
            toggleBtn.BorderSizePixel = 0
            toggleBtn.AutoButtonColor = false
            toggleBtn.Parent = toggleFrame
            
            local toggleBtnCorner = Instance.new("UICorner")
            toggleBtnCorner.CornerRadius = UDim.new(1, 0)
            toggleBtnCorner.Parent = toggleBtn
            
            local toggleCircle = Instance.new("Frame")
            toggleCircle.Size = UDim2.new(0, 14, 0, 14)
            toggleCircle.Position = default and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
            toggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            toggleCircle.BorderSizePixel = 0
            toggleCircle.Parent = toggleBtn
            
            local circleCorner = Instance.new("UICorner")
            circleCorner.CornerRadius = UDim.new(1, 0)
            circleCorner.Parent = toggleCircle
            
            local toggled = default
            
            toggleBtn.MouseButton1Click:Connect(function()
                toggled = not toggled
                
                Tween(toggleBtn, {BackgroundColor3 = toggled and Color3.fromRGB(90, 180, 90) or Color3.fromRGB(60, 60, 70)})
                Tween(toggleCircle, {Position = toggled and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)})
                
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
            sliderFrame.Size = UDim2.new(1, -10, 0, 50)
            sliderFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
            sliderFrame.BorderSizePixel = 0
            sliderFrame.Parent = tabContent
            
            local sliderCorner = Instance.new("UICorner")
            sliderCorner.CornerRadius = UDim.new(0, 6)
            sliderCorner.Parent = sliderFrame
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -60, 0, 20)
            label.Position = UDim2.new(0, 12, 0, 6)
            label.BackgroundTransparency = 1
            label.Text = sliderText
            label.TextColor3 = Color3.fromRGB(220, 220, 220)
            label.TextSize = 14
            label.Font = Enum.Font.Gotham
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = sliderFrame
            
            local valueLabel = Instance.new("TextLabel")
            valueLabel.Size = UDim2.new(0, 50, 0, 20)
            valueLabel.Position = UDim2.new(1, -56, 0, 6)
            valueLabel.BackgroundTransparency = 1
            valueLabel.Text = tostring(default)
            valueLabel.TextColor3 = Color3.fromRGB(150, 130, 240)
            valueLabel.TextSize = 13
            valueLabel.Font = Enum.Font.GothamBold
            valueLabel.TextXAlignment = Enum.TextXAlignment.Right
            valueLabel.Parent = sliderFrame
            
            local sliderBar = Instance.new("Frame")
            sliderBar.Size = UDim2.new(1, -24, 0, 6)
            sliderBar.Position = UDim2.new(0, 12, 1, -14)
            sliderBar.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
            sliderBar.BorderSizePixel = 0
            sliderBar.Parent = sliderFrame
            
            local barCorner = Instance.new("UICorner")
            barCorner.CornerRadius = UDim.new(1, 0)
            barCorner.Parent = sliderBar
            
            local sliderFill = Instance.new("Frame")
            sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
            sliderFill.BackgroundColor3 = Color3.fromRGB(100, 80, 200)
            sliderFill.BorderSizePixel = 0
            sliderFill.Parent = sliderBar
            
            local fillCorner = Instance.new("UICorner")
            fillCorner.CornerRadius = UDim.new(1, 0)
            fillCorner.Parent = sliderFill
            
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
            boxFrame.Size = UDim2.new(1, -10, 0, 65)
            boxFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
            boxFrame.BorderSizePixel = 0
            boxFrame.Parent = tabContent
            
            local boxCorner = Instance.new("UICorner")
            boxCorner.CornerRadius = UDim.new(0, 6)
            boxCorner.Parent = boxFrame
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -20, 0, 20)
            label.Position = UDim2.new(0, 12, 0, 6)
            label.BackgroundTransparency = 1
            label.Text = boxText
            label.TextColor3 = Color3.fromRGB(220, 220, 220)
            label.TextSize = 14
            label.Font = Enum.Font.Gotham
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = boxFrame
            
            local textbox = Instance.new("TextBox")
            textbox.Size = UDim2.new(1, -24, 0, 30)
            textbox.Position = UDim2.new(0, 12, 0, 30)
            textbox.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
            textbox.PlaceholderText = placeholder
            textbox.Text = ""
            textbox.TextColor3 = Color3.fromRGB(220, 220, 220)
            textbox.PlaceholderColor3 = Color3.fromRGB(100, 100, 110)
            textbox.TextSize = 13
            textbox.Font = Enum.Font.Gotham
            textbox.BorderSizePixel = 0
            textbox.ClearTextOnFocus = false
            textbox.Parent = boxFrame
            
            local textboxCorner = Instance.new("UICorner")
            textboxCorner.CornerRadius = UDim.new(0, 4)
            textboxCorner.Parent = textbox
            
            textbox.FocusLost:Connect(function(enter)
                if enter then
                    callback(textbox.Text)
                end
            end)
            
            return boxFrame
        end
        
        function Tab:CreateLabel(text)
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -10, 0, 32)
            label.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
            label.Text = text
            label.TextColor3 = Color3.fromRGB(200, 200, 200)
            label.TextSize = 14
            label.Font = Enum.Font.Gotham
            label.BorderSizePixel = 0
            label.Parent = tabContent
            
            local labelCorner = Instance.new("UICorner")
            labelCorner.CornerRadius = UDim.new(0, 6)
            labelCorner.Parent = label
            
            return label
        end
        
        return Tab
    end
    
    return Window
end

return Library
