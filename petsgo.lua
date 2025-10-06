local Library = {}

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

-- Shortcuts
local InstanceNew = Instance.new
local UDim2New = UDim2.new
local UDimNew = UDim.new
local Vector2New = Vector2.new
local Color3New = Color3.new
local FromRGB = Color3.fromRGB
local TableInsert = table.insert

-- Library Data
Library.Connections = {}
Library.Flags = {}

-- Core Functions
function Library:Connect(event, callback)
    local connection = event:Connect(callback)
    TableInsert(self.Connections, connection)
    return connection
end

function Library:MakeDraggable(frame, dragFrame)
    local dragging, dragInput, dragStart, startPos
    
    dragFrame = dragFrame or frame
    
    self:Connect(dragFrame.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    
    self:Connect(dragFrame.InputChanged, function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    self:Connect(UserInputService.InputChanged, function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2New(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    self:Connect(UserInputService.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- Create Window
function Library:CreateWindow(config)
    config = config or {}
    
    local Window = {
        Tabs = {}
    }
    
    -- ScreenGui
    local ScreenGui = InstanceNew("ScreenGui")
    ScreenGui.Name = HttpService:GenerateGUID(false)
    ScreenGui.Parent = game:GetService("CoreGui")
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Main Frame (Gray Border)
    local MainFrame = InstanceNew("Frame")
    MainFrame.Size = config.Size or UDim2New(0, 500, 0, 600)
    MainFrame.Position = UDim2New(0.5, -250, 0.5, -300)
    MainFrame.BackgroundColor3 = FromRGB(90, 90, 95)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    
    -- Inner Frame (Black Background)
    local InnerFrame = InstanceNew("Frame")
    InnerFrame.Size = UDim2New(1, -6, 1, -6)
    InnerFrame.Position = UDim2New(0, 3, 0, 3)
    InnerFrame.BackgroundColor3 = FromRGB(15, 15, 20)
    InnerFrame.BorderSizePixel = 0
    InnerFrame.Parent = MainFrame
    
    -- Title Bar
    local TitleBar = InstanceNew("Frame")
    TitleBar.Size = UDim2New(1, 0, 0, 20)
    TitleBar.BackgroundColor3 = FromRGB(25, 25, 30)
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = InnerFrame
    
    -- Title Text
    local Title = InstanceNew("TextLabel")
    Title.Size = UDim2New(1, -10, 1, 0)
    Title.Position = UDim2New(0, 5, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = config.Name or "Thugsense Menu"
    Title.TextColor3 = FromRGB(200, 200, 200)
    Title.TextSize = 13
    Title.Font = Enum.Font.SourceSans
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TitleBar
    
    -- Tab Container
    local TabContainer = InstanceNew("Frame")
    TabContainer.Size = UDim2New(1, 0, 0, 18)
    TabContainer.Position = UDim2New(0, 0, 0, 20)
    TabContainer.BackgroundColor3 = FromRGB(20, 20, 25)
    TabContainer.BorderSizePixel = 0
    TabContainer.Parent = InnerFrame
    
    local TabLayout = InstanceNew("UIListLayout")
    TabLayout.FillDirection = Enum.FillDirection.Horizontal
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Parent = TabContainer
    
    -- Content Container
    local ContentContainer = InstanceNew("Frame")
    ContentContainer.Size = UDim2New(1, 0, 1, -38)
    ContentContainer.Position = UDim2New(0, 0, 0, 38)
    ContentContainer.BackgroundColor3 = FromRGB(8, 8, 13)
    ContentContainer.BorderSizePixel = 0
    ContentContainer.Parent = InnerFrame
    
    Library:MakeDraggable(MainFrame, TitleBar)
    
    function Window:CreateTab(name)
        local Tab = {}
        
        -- Tab Button
        local TabButton = InstanceNew("TextButton")
        TabButton.Size = UDim2New(0, 80, 1, 0)
        TabButton.BackgroundColor3 = FromRGB(20, 20, 25)
        TabButton.BorderSizePixel = 0
        TabButton.Text = name
        TabButton.TextColor3 = FromRGB(150, 150, 150)
        TabButton.TextSize = 12
        TabButton.Font = Enum.Font.SourceSans
        TabButton.AutoButtonColor = false
        TabButton.Parent = TabContainer
        
        -- Tab Content
        local TabContent = InstanceNew("ScrollingFrame")
        TabContent.Size = UDim2New(1, 0, 1, 0)
        TabContent.BackgroundTransparency = 1
        TabContent.BorderSizePixel = 0
        TabContent.ScrollBarThickness = 3
        TabContent.ScrollBarImageColor3 = FromRGB(50, 50, 55)
        TabContent.CanvasSize = UDim2New(0, 0, 0, 0)
        TabContent.Visible = false
        TabContent.Parent = ContentContainer
        
        local TabLayout = InstanceNew("UIListLayout")
        TabLayout.Padding = UDimNew(0, 5)
        TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
        TabLayout.Parent = TabContent
        
        local TabPadding = InstanceNew("UIPadding")
        TabPadding.PaddingTop = UDimNew(0, 8)
        TabPadding.PaddingLeft = UDimNew(0, 8)
        TabPadding.PaddingRight = UDimNew(0, 8)
        TabPadding.Parent = TabContent
        
        -- Auto resize
        Library:Connect(TabLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
            TabContent.CanvasSize = UDim2New(0, 0, 0, TabLayout.AbsoluteContentSize.Y + 16)
        end)
        
        -- Tab selection
        Library:Connect(TabButton.MouseButton1Click, function()
            for _, tab in pairs(Window.Tabs) do
                tab.Content.Visible = false
                tab.Button.BackgroundColor3 = FromRGB(20, 20, 25)
                tab.Button.TextColor3 = FromRGB(150, 150, 150)
            end
            
            TabContent.Visible = true
            TabButton.BackgroundColor3 = FromRGB(25, 25, 30)
            TabButton.TextColor3 = FromRGB(200, 200, 200)
        end)
        
        -- Select first tab
        if #Window.Tabs == 0 then
            TabContent.Visible = true
            TabButton.BackgroundColor3 = FromRGB(25, 25, 30)
            TabButton.TextColor3 = FromRGB(200, 200, 200)
        end
        
        Tab.Button = TabButton
        Tab.Content = TabContent
        TableInsert(Window.Tabs, Tab)
        
        function Tab:CreateButton(config)
            config = config or {}
            
            local Button = InstanceNew("TextButton")
            Button.Size = UDim2New(1, -8, 0, 20)
            Button.BackgroundColor3 = FromRGB(22, 22, 27)
            Button.BorderColor3 = FromRGB(35, 35, 40)
            Button.BorderSizePixel = 1
            Button.Text = config.Name or "Button"
            Button.TextColor3 = FromRGB(200, 200, 200)
            Button.TextSize = 12
            Button.Font = Enum.Font.SourceSans
            Button.AutoButtonColor = false
            Button.Parent = TabContent
            
            if config.Callback then
                Library:Connect(Button.MouseButton1Click, config.Callback)
            end
            
            Library:Connect(Button.MouseEnter, function()
                Button.BackgroundColor3 = FromRGB(28, 28, 33)
            end)
            
            Library:Connect(Button.MouseLeave, function()
                Button.BackgroundColor3 = FromRGB(22, 22, 27)
            end)
            
            return Button
        end
        
        function Tab:CreateToggle(config)
            config = config or {}
            
            local ToggleFrame = InstanceNew("Frame")
            ToggleFrame.Size = UDim2New(1, -8, 0, 20)
            ToggleFrame.BackgroundColor3 = FromRGB(22, 22, 27)
            ToggleFrame.BorderColor3 = FromRGB(35, 35, 40)
            ToggleFrame.BorderSizePixel = 1
            ToggleFrame.Parent = TabContent
            
            local Label = InstanceNew("TextLabel")
            Label.Size = UDim2New(1, -25, 1, 0)
            Label.Position = UDim2New(0, 5, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = config.Name or "Toggle"
            Label.TextColor3 = FromRGB(200, 200, 200)
            Label.TextSize = 12
            Label.Font = Enum.Font.SourceSans
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = ToggleFrame
            
            local Checkbox = InstanceNew("TextButton")
            Checkbox.Size = UDim2New(0, 10, 0, 10)
            Checkbox.Position = UDim2New(1, -15, 0.5, -5)
            Checkbox.BackgroundColor3 = config.Default and FromRGB(80, 180, 80) or FromRGB(45, 45, 50)
            Checkbox.BorderColor3 = FromRGB(35, 35, 40)
            Checkbox.BorderSizePixel = 1
            Checkbox.Text = ""
            Checkbox.AutoButtonColor = false
            Checkbox.Parent = ToggleFrame
            
            local toggled = config.Default or false
            
            if config.Flag then
                Library.Flags[config.Flag] = toggled
            end
            
            Library:Connect(Checkbox.MouseButton1Click, function()
                toggled = not toggled
                Checkbox.BackgroundColor3 = toggled and FromRGB(80, 180, 80) or FromRGB(45, 45, 50)
                
                if config.Flag then
                    Library.Flags[config.Flag] = toggled
                end
                
                if config.Callback then
                    config.Callback(toggled)
                end
            end)
            
            return ToggleFrame
        end
        
        function Tab:CreateSlider(config)
            config = config or {}
            local min = config.Min or 0
            local max = config.Max or 100
            local default = config.Default or min
            
            local SliderFrame = InstanceNew("Frame")
            SliderFrame.Size = UDim2New(1, -8, 0, 35)
            SliderFrame.BackgroundColor3 = FromRGB(22, 22, 27)
            SliderFrame.BorderColor3 = FromRGB(35, 35, 40)
            SliderFrame.BorderSizePixel = 1
            SliderFrame.Parent = TabContent
            
            local Label = InstanceNew("TextLabel")
            Label.Size = UDim2New(1, -50, 0, 15)
            Label.Position = UDim2New(0, 5, 0, 3)
            Label.BackgroundTransparency = 1
            Label.Text = config.Name or "Slider"
            Label.TextColor3 = FromRGB(200, 200, 200)
            Label.TextSize = 12
            Label.Font = Enum.Font.SourceSans
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = SliderFrame
            
            local ValueLabel = InstanceNew("TextLabel")
            ValueLabel.Size = UDim2New(0, 40, 0, 15)
            ValueLabel.Position = UDim2New(1, -45, 0, 3)
            ValueLabel.BackgroundTransparency = 1
            ValueLabel.Text = tostring(default)
            ValueLabel.TextColor3 = FromRGB(160, 160, 160)
            ValueLabel.TextSize = 12
            ValueLabel.Font = Enum.Font.SourceSans
            ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
            ValueLabel.Parent = SliderFrame
            
            local SliderBar = InstanceNew("Frame")
            SliderBar.Size = UDim2New(1, -10, 0, 4)
            SliderBar.Position = UDim2New(0, 5, 1, -10)
            SliderBar.BackgroundColor3 = FromRGB(35, 35, 40)
            SliderBar.BorderSizePixel = 0
            SliderBar.Parent = SliderFrame
            
            local SliderFill = InstanceNew("Frame")
            SliderFill.Size = UDim2New((default - min) / (max - min), 0, 1, 0)
            SliderFill.BackgroundColor3 = FromRGB(120, 80, 190)
            SliderFill.BorderSizePixel = 0
            SliderFill.Parent = SliderBar
            
            local SliderButton = InstanceNew("TextButton")
            SliderButton.Size = UDim2New(1, 0, 1, 0)
            SliderButton.BackgroundTransparency = 1
            SliderButton.Text = ""
            SliderButton.Parent = SliderBar
            
            local dragging = false
            
            if config.Flag then
                Library.Flags[config.Flag] = default
            end
            
            local function updateSlider(input)
                local pos = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
                local value = math.floor(min + (max - min) * pos)
                
                SliderFill.Size = UDim2New(pos, 0, 1, 0)
                ValueLabel.Text = tostring(value)
                
                if config.Flag then
                    Library.Flags[config.Flag] = value
                end
                
                if config.Callback then
                    config.Callback(value)
                end
            end
            
            Library:Connect(SliderButton.InputBegan, function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    updateSlider(input)
                end
            end)
            
            Library:Connect(UserInputService.InputEnded, function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)
            
            Library:Connect(UserInputService.InputChanged, function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    updateSlider(input)
                end
            end)
            
            return SliderFrame
        end
        
        function Tab:CreateTextbox(config)
            config = config or {}
            
            local TextboxFrame = InstanceNew("Frame")
            TextboxFrame.Size = UDim2New(1, -8, 0, 38)
            TextboxFrame.BackgroundColor3 = FromRGB(22, 22, 27)
            TextboxFrame.BorderColor3 = FromRGB(35, 35, 40)
            TextboxFrame.BorderSizePixel = 1
            TextboxFrame.Parent = TabContent
            
            local Label = InstanceNew("TextLabel")
            Label.Size = UDim2New(1, -10, 0, 15)
            Label.Position = UDim2New(0, 5, 0, 3)
            Label.BackgroundTransparency = 1
            Label.Text = config.Name or "Textbox"
            Label.TextColor3 = FromRGB(200, 200, 200)
            Label.TextSize = 12
            Label.Font = Enum.Font.SourceSans
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = TextboxFrame
            
            local Textbox = InstanceNew("TextBox")
            Textbox.Size = UDim2New(1, -10, 0, 16)
            Textbox.Position = UDim2New(0, 5, 0, 18)
            Textbox.BackgroundColor3 = FromRGB(15, 15, 20)
            Textbox.BorderColor3 = FromRGB(30, 30, 35)
            Textbox.BorderSizePixel = 1
            Textbox.Text = ""
            Textbox.PlaceholderText = config.Placeholder or ""
            Textbox.TextColor3 = FromRGB(200, 200, 200)
            Textbox.PlaceholderColor3 = FromRGB(100, 100, 105)
            Textbox.TextSize = 11
            Textbox.Font = Enum.Font.SourceSans
            Textbox.TextXAlignment = Enum.TextXAlignment.Left
            Textbox.ClearTextOnFocus = false
            Textbox.Parent = TextboxFrame
            
            local TextboxPadding = InstanceNew("UIPadding")
            TextboxPadding.PaddingLeft = UDimNew(0, 3)
            TextboxPadding.Parent = Textbox
            
            if config.Flag then
                Library.Flags[config.Flag] = ""
            end
            
            Library:Connect(Textbox.FocusLost, function(enter)
                if enter then
                    if config.Flag then
                        Library.Flags[config.Flag] = Textbox.Text
                    end
                    
                    if config.Callback then
                        config.Callback(Textbox.Text)
                    end
                end
            end)
            
            return TextboxFrame
        end
        
        function Tab:CreateLabel(text)
            local Label = InstanceNew("TextLabel")
            Label.Size = UDim2New(1, -8, 0, 18)
            Label.BackgroundTransparency = 1
            Label.Text = text or "Label"
            Label.TextColor3 = FromRGB(180, 180, 180)
            Label.TextSize = 12
            Label.Font = Enum.Font.SourceSans
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = TabContent
            
            local LabelPadding = InstanceNew("UIPadding")
            LabelPadding.PaddingLeft = UDimNew(0, 5)
            LabelPadding.Parent = Label
            
            return Label
        end
        
        return Tab
    end
    
    return Window
end

return Library
