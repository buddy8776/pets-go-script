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
local StringFormat = string.format

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
    Accent = FromRGB(235, 157, 255),
    TabBackground = FromRGB(20, 20, 25),
    TabActive = FromRGB(25, 25, 30),
    ElementBackground = FromRGB(25, 25, 30)
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
        BorderColor3 = FromRGB(10, 10, 10),
        BorderSizePixel = 2,
        BackgroundColor3 = FromRGB(15, 15, 20)
    })
    Items["Window"]:AddToTheme({BackgroundColor3 = "Background", BorderColor3 = "Border"})
    Items["Window"]:MakeDraggable()

    -- Outline
    Instances:Create("UIStroke", {
        Parent = Items["Window"].Instance,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        LineJoinMode = Enum.LineJoinMode.Miter,
        Color = FromRGB(27, 27, 32)
    }):AddToTheme({Color = "Outline"})

    -- Title Bar
    Items["TitleBar"] = Instances:Create("Frame", {
        Parent = Items["Window"].Instance,
        Size = UDim2New(1, 0, 0, 20),
        Position = UDim2New(0, 0, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0
    })

    -- Title Text
    Items["Title"] = Instances:Create("TextLabel", {
        Parent = Items["TitleBar"].Instance,
        Text = windowName,
        Font = Enum.Font.SourceSans,
        TextSize = 13,
        TextColor3 = FromRGB(215, 215, 215),
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2New(1, -20, 1, 0),
        Position = UDim2New(0, 5, 0, 0)
    })
    Items["Title"]:AddToTheme({TextColor3 = "Text"})

    -- Tab Container (Horizontal)
    Items["TabContainer"] = Instances:Create("Frame", {
        Parent = Items["Window"].Instance,
        Size = UDim2New(1, 0, 0, 18),
        Position = UDim2New(0, 0, 0, 20),
        BackgroundColor3 = FromRGB(20, 20, 25),
        BorderSizePixel = 0
    })
    Items["TabContainer"]:AddToTheme({BackgroundColor3 = "TabBackground"})

    Instances:Create("UIListLayout", {
        Parent = Items["TabContainer"].Instance,
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDimNew(0, 0)
    })

    -- Content Container
    Items["ContentContainer"] = Instances:Create("Frame", {
        Parent = Items["Window"].Instance,
        Size = UDim2New(1, 0, 1, -38),
        Position = UDim2New(0, 0, 0, 38),
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
            Size = UDim2New(0, 80, 1, 0),
            BackgroundColor3 = FromRGB(20, 20, 25),
            BorderSizePixel = 0,
            Text = tabName,
            Font = Enum.Font.SourceSans,
            TextSize = 12,
            TextColor3 = FromRGB(180, 180, 180),
            AutoButtonColor = false
        })

        -- Tab Content (ScrollingFrame)
        TabItems["Content"] = Instances:Create("ScrollingFrame", {
            Parent = Items["ContentContainer"].Instance,
            Size = UDim2New(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = FromRGB(60, 60, 65),
            CanvasSize = UDim2New(0, 0, 0, 0),
            Visible = false
        })

        Instances:Create("UIListLayout", {
            Parent = TabItems["Content"].Instance,
            Padding = UDimNew(0, 6),
            SortOrder = Enum.SortOrder.LayoutOrder
        })

        Instances:Create("UIPadding", {
            Parent = TabItems["Content"].Instance,
            PaddingTop = UDimNew(0, 6),
            PaddingLeft = UDimNew(0, 6),
            PaddingRight = UDimNew(0, 6),
            PaddingBottom = UDimNew(0, 6)
        })

        -- Auto resize canvas
        TabItems["Content"].Instance:GetPropertyChangedSignal("AbsoluteCanvasSize"):Connect(function()
            TabItems["Content"].Instance.CanvasSize = UDim2New(0, 0, 0, TabItems["Content"].Instance.UIListLayout.AbsoluteContentSize.Y + 12)
        end)

        -- Tab Button Click
        TabItems["Button"]:Connect("MouseButton1Click", function()
            for _, tab in pairs(Window.Tabs) do
                tab.Content.Instance.Visible = false
                tab.Button:Tween(nil, {BackgroundColor3 = FromRGB(20, 20, 25), TextColor3 = FromRGB(180, 180, 180)})
            end

            TabItems["Content"].Instance.Visible = true
            TabItems["Button"]:Tween(nil, {BackgroundColor3 = FromRGB(25, 25, 30), TextColor3 = FromRGB(215, 215, 215)})
            Window.CurrentTab = Tab
        end)

        Tab.Button = TabItems["Button"]
        Tab.Content = TabItems["Content"]

        TableInsert(Window.Tabs, Tab)

        -- Select first tab
        if #Window.Tabs == 1 then
            TabItems["Button"].Instance.BackgroundColor3 = FromRGB(25, 25, 30)
            TabItems["Button"].Instance.TextColor3 = FromRGB(215, 215, 215)
            TabItems["Content"].Instance.Visible = true
            Window.CurrentTab = Tab
        end

        function Tab:CreateButton(config)
            config = config or {}
            local btnText = config.Name or "Button"
            local callback = config.Callback or function() end

            local button = Instances:Create("TextButton", {
                Parent = TabItems["Content"].Instance,
                Size = UDim2New(1, -6, 0, 20),
                BackgroundColor3 = FromRGB(25, 25, 30),
                BorderColor3 = FromRGB(10, 10, 10),
                BorderSizePixel = 1,
                Text = btnText,
                Font = Enum.Font.SourceSans,
                TextSize = 12,
                TextColor3 = FromRGB(215, 215, 215),
                TextXAlignment = Enum.TextXAlignment.Left,
                AutoButtonColor = false
            })
            button:AddToTheme({BackgroundColor3 = "ElementBackground"})

            Instances:Create("UIPadding", {
                Parent = button.Instance,
                PaddingLeft = UDimNew(0, 5)
            })

            button:Connect("MouseButton1Click", function()
                callback()
            end)

            button:Connect("MouseEnter", function()
                button:Tween(nil, {BackgroundColor3 = FromRGB(30, 30, 35)})
            end)

            button:Connect("MouseLeave", function()
                button:Tween(nil, {BackgroundColor3 = FromRGB(25, 25, 30)})
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
                Size = UDim2New(1, -6, 0, 20),
                BackgroundColor3 = FromRGB(25, 25, 30),
                BorderColor3 = FromRGB(10, 10, 10),
                BorderSizePixel = 1
            })
            toggleFrame:AddToTheme({BackgroundColor3 = "ElementBackground"})

            local label = Instances:Create("TextLabel", {
                Parent = toggleFrame.Instance,
                Size = UDim2New(1, -25, 1, 0),
                Position = UDim2New(0, 5, 0, 0),
                BackgroundTransparency = 1,
                Text = toggleText,
                Font = Enum.Font.SourceSans,
                TextSize = 12,
                TextColor3 = FromRGB(215, 215, 215),
                TextXAlignment = Enum.TextXAlignment.Left
            })
            label:AddToTheme({TextColor3 = "Text"})

            local checkbox = Instances:Create("TextButton", {
                Parent = toggleFrame.Instance,
                Size = UDim2New(0, 10, 0, 10),
                Position = UDim2New(1, -15, 0.5, -5),
                BackgroundColor3 = default and FromRGB(100, 200, 100) or FromRGB(50, 50, 55),
                BorderColor3 = FromRGB(10, 10, 10),
                BorderSizePixel = 1,
                Text = "",
                AutoButtonColor = false
            })

            local toggled = default

            checkbox:Connect("MouseButton1Click", function()
                toggled = not toggled
                checkbox:Tween(nil, {BackgroundColor3 = toggled and FromRGB(100, 200, 100) or FromRGB(50, 50, 55)})
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
                Size = UDim2New(1, -6, 0, 35),
                BackgroundColor3 = FromRGB(25, 25, 30),
                BorderColor3 = FromRGB(10, 10, 10),
                BorderSizePixel = 1
            })
            sliderFrame:AddToTheme({BackgroundColor3 = "ElementBackground"})

            local label = Instances:Create("TextLabel", {
                Parent = sliderFrame.Instance,
                Size = UDim2New(1, -50, 0, 15),
                Position = UDim2New(0, 5, 0, 2),
                BackgroundTransparency = 1,
                Text = sliderText,
                Font = Enum.Font.SourceSans,
                TextSize = 12,
                TextColor3 = FromRGB(215, 215, 215),
                TextXAlignment = Enum.TextXAlignment.Left
            })
            label:AddToTheme({TextColor3 = "Text"})

            local valueLabel = Instances:Create("TextLabel", {
                Parent = sliderFrame.Instance,
                Size = UDim2New(0, 40, 0, 15),
                Position = UDim2New(1, -45, 0, 2),
                BackgroundTransparency = 1,
                Text = tostring(default),
                Font = Enum.Font.SourceSans,
                TextSize = 12,
                TextColor3 = FromRGB(180, 180, 180),
                TextXAlignment = Enum.TextXAlignment.Right
            })

            local sliderBar = Instances:Create("Frame", {
                Parent = sliderFrame.Instance,
                Size = UDim2New(1, -10, 0, 4),
                Position = UDim2New(0, 5, 1, -10),
                BackgroundColor3 = FromRGB(35, 35, 40),
                BorderSizePixel = 0
            })

            local sliderFill = Instances:Create("Frame", {
                Parent = sliderBar.Instance,
                Size = UDim2New((default - min) / (max - min), 0, 1, 0),
                BackgroundColor3 = Library.Theme.Accent,
                BorderSizePixel = 0
            })
            sliderFill:AddToTheme({BackgroundColor3 = "Accent"})

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
                Size = UDim2New(1, -6, 0, 38),
                BackgroundColor3 = FromRGB(25, 25, 30),
                BorderColor3 = FromRGB(10, 10, 10),
                BorderSizePixel = 1
            })
            boxFrame:AddToTheme({BackgroundColor3 = "ElementBackground"})

            local label = Instances:Create("TextLabel", {
                Parent = boxFrame.Instance,
                Size = UDim2New(1, -10, 0, 15),
                Position = UDim2New(0, 5, 0, 2),
                BackgroundTransparency = 1,
                Text = boxText,
                Font = Enum.Font.SourceSans,
                TextSize = 12,
                TextColor3 = FromRGB(215, 215, 215),
                TextXAlignment = Enum.TextXAlignment.Left
            })
            label:AddToTheme({TextColor3 = "Text"})

            local textbox = Instances:Create("TextBox", {
                Parent = boxFrame.Instance,
                Size = UDim2New(1, -10, 0, 16),
                Position = UDim2New(0, 5, 0, 18),
                BackgroundColor3 = FromRGB(18, 18, 22),
                BorderColor3 = FromRGB(10, 10, 10),
                BorderSizePixel = 1,
                Text = "",
                PlaceholderText = placeholder,
                Font = Enum.Font.SourceSans,
                TextSize = 11,
                TextColor3 = FromRGB(215, 215, 215),
                TextXAlignment = Enum.TextXAlignment.Left,
                ClearTextOnFocus = false
            })

            Instances:Create("UIPadding", {
                Parent = textbox.Instance,
                PaddingLeft = UDimNew(0, 3)
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
                Size = UDim2New(1, -6, 0, 18),
                BackgroundTransparency = 1,
                Text = text,
                Font = Enum.Font.SourceSans,
                TextSize = 12,
                TextColor3 = FromRGB(215, 215, 215),
                TextXAlignment = Enum.TextXAlignment.Left
            })
            label:AddToTheme({TextColor3 = "Text"})

            Instances:Create("UIPadding", {
                Parent = label.Instance,
                PaddingLeft = UDimNew(0, 5)
            })

            return label
        end

        return Tab
    end

    return Window
end

return Library
