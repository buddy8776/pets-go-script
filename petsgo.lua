local Library = {}
Library.__index = Library

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

-- Optimizations
local InstanceNew = Instance.new
local UDim2New = UDim2.new
local UDimNew = UDim.new
local Vector2New = Vector2.new
local FromRGB = Color3.fromRGB
local TableInsert = table.insert

-- Library Settings
Library.Connections = {}
Library.Threads = {}
Library.ThemeItems = {}
Library.ThemeMap = {}
Library.Flags = {}
Library.SetFlags = {}

Library.Theme = {
    Background = FromRGB(15, 15, 20),
    Border = FromRGB(10, 10, 10),
    Outline = FromRGB(27, 27, 32),
    Text = FromRGB(215, 215, 215),
    ["Text Border"] = FromRGB(0, 0, 0),
    Accent = FromRGB(150, 100, 200),
    TabBackground = FromRGB(18, 18, 23),
    TabActive = FromRGB(22, 22, 27),
    ElementBackground = FromRGB(22, 22, 27),
    ElementBorder = FromRGB(35, 35, 40)
}

Library.Tween = {
    Time = 0.16,
    Style = Enum.EasingStyle.Quad,
    Direction = Enum.EasingDirection.Out
}

-- Tween Module
local Tween = {}
Tween.__index = Tween

function Tween:Create(Item, Info, Goal, IsRawItem)
    Item = IsRawItem and Item or Item.Instance
    Info = Info or TweenInfo.new(Library.Tween.Time, Library.Tween.Style, Library.Tween.Direction)

    local NewTween = {
        Tween = TweenService:Create(Item, Info, Goal),
        Info = Info,
        Goal = Goal,
        Item = Item
    }

    NewTween.Tween:Play()
    setmetatable(NewTween, Tween)
    return NewTween
end

-- Instances Module
local Instances = {}
Instances.__index = Instances

function Instances:Create(Class, Properties)
    local NewItem = {
        Instance = InstanceNew(Class),
        Properties = Properties,
        Class = Class
    }

    setmetatable(NewItem, Instances)

    for Property, Value in NewItem.Properties do
        NewItem.Instance[Property] = Value
    end

    return NewItem
end

function Instances:AddToTheme(Properties)
    if not self.Instance then return end
    Library:AddToTheme(self, Properties)
end

function Instances:Connect(Event, Callback)
    if not self.Instance then return end
    if not self.Instance[Event] then return end
    return Library:Connect(self.Instance[Event], Callback)
end

function Instances:Tween(Info, Goal)
    if not self.Instance then return end
    return Tween:Create(self, Info, Goal)
end

function Instances:Clean()
    if not self.Instance then return end
    self.Instance:Destroy()
    self = nil
end

function Instances:MakeDraggable()
    if not self.Instance then return end

    local Gui = self.Instance
    local Dragging = false
    local DragStart
    local StartPosition

    self:Connect("InputBegan", function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = true
            DragStart = Input.Position
            StartPosition = Gui.Position
        end
    end)

    self:Connect("InputEnded", function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = false
        end
    end)

    Library:Connect(UserInputService.InputChanged, function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseMovement and Dragging then
            local DragDelta = Input.Position - DragStart
            Gui.Position = UDim2New(
                StartPosition.X.Scale,
                StartPosition.X.Offset + DragDelta.X,
                StartPosition.Y.Scale,
                StartPosition.Y.Offset + DragDelta.Y
            )
        end
    end)
end

-- Core Library Functions
function Library:Connect(Event, Callback)
    local Connection = {
        Connection = Event:Connect(Callback)
    }
    TableInsert(self.Connections, Connection)
    return Connection
end

function Library:AddToTheme(Item, Properties)
    Item = Item.Instance or Item

    local ThemeData = {
        Item = Item,
        Properties = Properties,
    }

    for Property, Value in ThemeData.Properties do
        if type(Value) == "string" then
            Item[Property] = self.Theme[Value]
        end
    end

    TableInsert(self.ThemeItems, ThemeData)
    self.ThemeMap[Item] = ThemeData
end

-- Create ScreenGui
Library.Holder = Instances:Create("ScreenGui", {
    Parent = game:GetService("CoreGui"),
    Name = HttpService:GenerateGUID(false),
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling
})

-- Create Window
function Library:CreateWindow(config)
    config = config or {}
    local windowName = config.Name or "Thugsense Menu"
    local windowSize = config.Size or UDim2New(0, 500, 0, 600)

    local Window = {
        Tabs = {},
        CurrentTab = nil
    }

    local Items = {}

    -- Main Window Frame
    Items["Window"] = Instances:Create("Frame", {
        Parent = Library.Holder.Instance,
        Size = windowSize,
        Position = UDim2New(0.5, -windowSize.X.Offset/2, 0.5, -windowSize.Y.Offset/2),
        BorderColor3 = FromRGB(70, 70, 75),
        BorderSizePixel = 3,
        BackgroundColor3 = FromRGB(12, 12, 17)
    })
    Items["Window"]:MakeDraggable()

    -- Title Bar
    Items["TitleBar"] = Instances:Create("Frame", {
        Parent = Items["Window"].Instance,
        Size = UDim2New(1, 0, 0, 22),
        Position = UDim2New(0, 0, 0, 0),
        BackgroundColor3 = FromRGB(18, 18, 23),
        BorderSizePixel = 0
    })

    -- Title Text
    Items["Title"] = Instances:Create("TextLabel", {
        Parent = Items["TitleBar"].Instance,
        Text = windowName,
        Font = Enum.Font.SourceSans,
        TextSize = 13,
        TextColor3 = FromRGB(200, 200, 200),
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2New(1, -20, 1, 0),
        Position = UDim2New(0, 8, 0, 0)
    })

    -- Tab Container (Horizontal)
    Items["TabContainer"] = Instances:Create("Frame", {
        Parent = Items["Window"].Instance,
        Size = UDim2New(1, 0, 0, 20),
        Position = UDim2New(0, 0, 0, 22),
        BackgroundColor3 = FromRGB(15, 15, 20),
        BorderSizePixel = 0
    })

    Instances:Create("UIListLayout", {
        Parent = Items["TabContainer"].Instance,
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDimNew(0, 0)
    })

    -- Content Container
    Items["ContentContainer"] = Instances:Create("Frame", {
        Parent = Items["Window"].Instance,
        Size = UDim2New(1, 0, 1, -42),
        Position = UDim2New(0, 0, 0, 42),
        BackgroundTransparency = 1,
        BorderSizePixel = 0
    })

    function Window:CreateTab(tabName)
        local Tab = {
            Name = tabName,
            Elements = {}
        }

        local TabItems = {}

        -- Tab Button
        TabItems["Button"] = Instances:Create("TextButton", {
            Parent = Items["TabContainer"].Instance,
            Size = UDim2New(0, 85, 1, 0),
            BackgroundColor3 = FromRGB(15, 15, 20),
            BorderSizePixel = 0,
            Text = tabName,
            Font = Enum.Font.SourceSans,
            TextSize = 13,
            TextColor3 = FromRGB(160, 160, 160),
            AutoButtonColor = false
        })

        -- Tab Content (ScrollingFrame)
        TabItems["Content"] = Instances:Create("ScrollingFrame", {
            Parent = Items["ContentContainer"].Instance,
            Size = UDim2New(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = FromRGB(50, 50, 55),
            CanvasSize = UDim2New(0, 0, 0, 0),
            Visible = false
        })

        Instances:Create("UIListLayout", {
            Parent = TabItems["Content"].Instance,
            Padding = UDimNew(0, 5),
            SortOrder = Enum.SortOrder.LayoutOrder
        })

        Instances:Create("UIPadding", {
            Parent = TabItems["Content"].Instance,
            PaddingTop = UDimNew(0, 8),
            PaddingLeft = UDimNew(0, 8),
            PaddingRight = UDimNew(0, 8),
            PaddingBottom = UDimNew(0, 8)
        })

        -- Auto resize canvas
        TabItems["Content"].Instance:GetPropertyChangedSignal("AbsoluteCanvasSize"):Connect(function()
            TabItems["Content"].Instance.CanvasSize = UDim2New(0, 0, 0, TabItems["Content"].Instance.UIListLayout.AbsoluteContentSize.Y + 16)
        end)

        -- Tab Button Click
        TabItems["Button"]:Connect("MouseButton1Click", function()
            for _, tab in pairs(Window.Tabs) do
                tab.Content.Instance.Visible = false
                tab.Button.Instance.BackgroundColor3 = FromRGB(15, 15, 20)
                tab.Button.Instance.TextColor3 = FromRGB(160, 160, 160)
            end

            TabItems["Content"].Instance.Visible = true
            TabItems["Button"].Instance.BackgroundColor3 = FromRGB(20, 20, 25)
            TabItems["Button"].Instance.TextColor3 = FromRGB(200, 200, 200)
            Window.CurrentTab = Tab
        end)

        Tab.Button = TabItems["Button"]
        Tab.Content = TabItems["Content"]

        TableInsert(Window.Tabs, Tab)

        -- Select first tab
        if #Window.Tabs == 1 then
            TabItems["Button"].Instance.BackgroundColor3 = FromRGB(20, 20, 25)
            TabItems["Button"].Instance.TextColor3 = FromRGB(200, 200, 200)
            TabItems["Content"].Instance.Visible = true
            Window.CurrentTab = Tab
        end

        function Tab:CreateButton(config)
            config = config or {}
            local btnText = config.Name or "Button"
            local callback = config.Callback or function() end

            local button = Instances:Create("TextButton", {
                Parent = TabItems["Content"].Instance,
                Size = UDim2New(1, -8, 0, 22),
                BackgroundColor3 = FromRGB(20, 20, 25),
                BorderColor3 = FromRGB(30, 30, 35),
                BorderSizePixel = 1,
                Text = btnText,
                Font = Enum.Font.SourceSans,
                TextSize = 13,
                TextColor3 = FromRGB(200, 200, 200),
                TextXAlignment = Enum.TextXAlignment.Left,
                AutoButtonColor = false
            })

            Instances:Create("UIPadding", {
                Parent = button.Instance,
                PaddingLeft = UDimNew(0, 6)
            })

            button:Connect("MouseButton1Click", function()
                callback()
            end)

            button:Connect("MouseEnter", function()
                button.Instance.BackgroundColor3 = FromRGB(25, 25, 30)
            end)

            button:Connect("MouseLeave", function()
                button.Instance.BackgroundColor3 = FromRGB(20, 20, 25)
            end)

            return button
        end

        function Tab:CreateToggle(config)
            config = config or {}
            local toggleText = config.Name or "Toggle"
            local default = config.Default or false
            local callback = config.Callback or function() end

            local toggleFrame = Instances:Create("Frame", {
                Parent = TabItems["Content"].Instance,
                Size = UDim2New(1, -8, 0, 22),
                BackgroundColor3 = FromRGB(20, 20, 25),
                BorderColor3 = FromRGB(30, 30, 35),
                BorderSizePixel = 1
            })

            local label = Instances:Create("TextLabel", {
                Parent = toggleFrame.Instance,
                Size = UDim2New(1, -30, 1, 0),
                Position = UDim2New(0, 6, 0, 0),
                BackgroundTransparency = 1,
                Text = toggleText,
                Font = Enum.Font.SourceSans,
                TextSize = 13,
                TextColor3 = FromRGB(200, 200, 200),
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local checkbox = Instances:Create("TextButton", {
                Parent = toggleFrame.Instance,
                Size = UDim2New(0, 12, 0, 12),
                Position = UDim2New(1, -18, 0.5, -6),
                BackgroundColor3 = default and FromRGB(80, 180, 80) or FromRGB(40, 40, 45),
                BorderColor3 = FromRGB(50, 50, 55),
                BorderSizePixel = 1,
                Text = "",
                AutoButtonColor = false
            })

            local toggled = default

            checkbox:Connect("MouseButton1Click", function()
                toggled = not toggled
                checkbox.Instance.BackgroundColor3 = toggled and FromRGB(80, 180, 80) or FromRGB(40, 40, 45)
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

            local sliderFrame = Instances:Create("Frame", {
                Parent = TabItems["Content"].Instance,
                Size = UDim2New(1, -8, 0, 40),
                BackgroundColor3 = FromRGB(20, 20, 25),
                BorderColor3 = FromRGB(30, 30, 35),
                BorderSizePixel = 1
            })

            local label = Instances:Create("TextLabel", {
                Parent = sliderFrame.Instance,
                Size = UDim2New(1, -55, 0, 15),
                Position = UDim2New(0, 6, 0, 4),
                BackgroundTransparency = 1,
                Text = sliderText,
                Font = Enum.Font.SourceSans,
                TextSize = 13,
                TextColor3 = FromRGB(200, 200, 200),
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local valueLabel = Instances:Create("TextLabel", {
                Parent = sliderFrame.Instance,
                Size = UDim2.new(0, 45, 0, 15),
                Position = UDim2New(1, -50, 0, 4),
                BackgroundTransparency = 1,
                Text = tostring(default),
                Font = Enum.Font.SourceSans,
                TextSize = 13,
                TextColor3 = FromRGB(170, 170, 170),
                TextXAlignment = Enum.TextXAlignment.Right
            })

            local sliderBar = Instances:Create("Frame", {
                Parent = sliderFrame.Instance,
                Size = UDim2New(1, -12, 0, 5),
                Position = UDim2New(0, 6, 1, -12),
                BackgroundColor3 = FromRGB(30, 30, 35),
                BorderSizePixel = 0
            })

            local sliderFill = Instances:Create("Frame", {
                Parent = sliderBar.Instance,
                Size = UDim2New((default - min) / (max - min), 0, 1, 0),
                BackgroundColor3 = FromRGB(130, 90, 200),
                BorderSizePixel = 0
            })

            local sliderBtn = Instances:Create("TextButton", {
                Parent = sliderBar.Instance,
                Size = UDim2New(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "",
                AutoButtonColor = false
            })

            local dragging = false

            sliderBtn:Connect("InputBegan", function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                end
            end)

            Library:Connect(UserInputService.InputEnded, function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)

            Library:Connect(UserInputService.InputChanged, function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local pos = math.clamp((input.Position.X - sliderBar.Instance.AbsolutePosition.X) / sliderBar.Instance.AbsoluteSize.X, 0, 1)
                    local value = math.floor(min + (max - min) * pos)

                    sliderFill.Instance.Size = UDim2New(pos, 0, 1, 0)
                    valueLabel.Instance.Text = tostring(value)
                    callback(value)
                end
            end)

            return sliderFrame
        end

        function Tab:CreateTextbox(config)
            config = config or {}
            local boxText = config.Name or "Textbox"
            local placeholder = config.Placeholder or ""
            local callback = config.Callback or function() end

            local boxFrame = Instances:Create("Frame", {
                Parent = TabItems["Content"].Instance,
                Size = UDim2New(1, -8, 0, 42),
                BackgroundColor3 = FromRGB(20, 20, 25),
                BorderColor3 = FromRGB(30, 30, 35),
                BorderSizePixel = 1
            })

            local label = Instances:Create("TextLabel", {
                Parent = boxFrame.Instance,
                Size = UDim2New(1, -12, 0, 15),
                Position = UDim2New(0, 6, 0, 4),
                BackgroundTransparency = 1,
                Text = boxText,
                Font = Enum.Font.SourceSans,
                TextSize = 13,
                TextColor3 = FromRGB(200, 200, 200),
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local textbox = Instances:Create("TextBox", {
                Parent = boxFrame.Instance,
                Size = UDim2New(1, -12, 0, 18),
                Position = UDim2New(0, 6, 0, 20),
                BackgroundColor3 = FromRGB(15, 15, 20),
                BorderColor3 = FromRGB(25, 25, 30),
                BorderSizePixel = 1,
                Text = "",
                PlaceholderText = placeholder,
                Font = Enum.Font.SourceSans,
                TextSize = 12,
                TextColor3 = FromRGB(200, 200, 200),
                PlaceholderColor3 = FromRGB(100, 100, 105),
                TextXAlignment = Enum.TextXAlignment.Left,
                ClearTextOnFocus = false
            })

            Instances:Create("UIPadding", {
                Parent = textbox.Instance,
                PaddingLeft = UDimNew(0, 4)
            })

            textbox:Connect("FocusLost", function(enter)
                if enter then
                    callback(textbox.Instance.Text)
                end
            end)

            return boxFrame
        end

        function Tab:CreateLabel(text)
            local label = Instances:Create("TextLabel", {
                Parent = TabItems["Content"].Instance,
                Size = UDim2New(1, -8, 0, 20),
                BackgroundTransparency = 1,
                Text = text,
                Font = Enum.Font.SourceSans,
                TextSize = 13,
                TextColor3 = FromRGB(180, 180, 180),
                TextXAlignment = Enum.TextXAlignment.Left
            })

            Instances:Create("UIPadding", {
                Parent = label.Instance,
                PaddingLeft = UDimNew(0, 6)
            })

            return label
        end

        return Tab
    end

    return Window
end

return Library
