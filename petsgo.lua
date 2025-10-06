local Library = {}
Library.__index = Library

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

-- Optimizations
local InstanceNew = Instance.new
local UDim2New = UDim2.new
local UDimNew = UDim.new
local Vector2New = Vector2.new
local Vector3New = Vector3.new
local FromRGB = Color3.fromRGB
local FromHSV = Color3.fromHSV
local TableInsert = table.insert
local TableRemove = table.remove
local StringFormat = string.format
local MathFloor = math.floor
local MathClamp = math.clamp
local MathAbs = math.abs

-- Library Settings
Library.Connections = {}
Library.Threads = {}
Library.ThemeItems = {}
Library.ThemeMap = {}
Library.Flags = {}
Library.SetFlags = {}
Library.Dropdowns = {}
Library.Colorpickers = {}
Library.OpenColorpickers = {}
Library.KeybindList = nil
Library.Watermark = nil

Library.Theme = {
    Background = FromRGB(12, 12, 17),
    WindowBorder = FromRGB(70, 70, 75),
    TitleBar = FromRGB(18, 18, 23),
    TabBackground = FromRGB(15, 15, 20),
    TabActive = FromRGB(20, 20, 25),
    ContentBackground = FromRGB(8, 8, 13),
    ElementBackground = FromRGB(20, 20, 25),
    ElementBorder = FromRGB(30, 30, 35),
    Text = FromRGB(200, 200, 200),
    TextDark = FromRGB(160, 160, 160),
    Accent = FromRGB(130, 90, 200),
    AccentDark = FromRGB(100, 70, 160),
    Toggle = FromRGB(80, 180, 80),
    ToggleOff = FromRGB(40, 40, 45),
    Slider = FromRGB(30, 30, 35),
    Dropdown = FromRGB(18, 18, 23),
    DropdownSelected = FromRGB(25, 25, 30)
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

function Tween:Cancel()
    if self.Tween then
        self.Tween:Cancel()
    end
end

function Tween:Pause()
    if self.Tween then
        self.Tween:Pause()
    end
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

function Instances:ChangeTheme(Properties)
    if not self.Instance then return end
    Library:ChangeItemTheme(self, Properties)
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

-- Utility Functions
function Library:Connect(Event, Callback)
    local Connection = {
        Connection = Event:Connect(Callback)
    }
    TableInsert(self.Connections, Connection)
    return Connection
end

function Library:Disconnect(Connection)
    if Connection and Connection.Connection then
        Connection.Connection:Disconnect()
    end
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

function Library:ChangeItemTheme(Item, Properties)
    Item = Item.Instance or Item

    if self.ThemeMap[Item] then
        self.ThemeMap[Item].Properties = Properties

        for Property, Value in Properties do
            if type(Value) == "string" then
                Item[Property] = self.Theme[Value]
            end
        end
    end
end

function Library:UpdateTheme(ThemeName, Color)
    self.Theme[ThemeName] = Color

    for _, ThemeData in pairs(self.ThemeItems) do
        for Property, Value in pairs(ThemeData.Properties) do
            if type(Value) == "string" and Value == ThemeName then
                ThemeData.Item[Property] = Color
            end
        end
    end
end

function Library:CloseDropdowns(Exception)
    for _, Dropdown in pairs(self.Dropdowns) do
        if Dropdown ~= Exception and Dropdown.IsOpen then
            Dropdown:Close()
        end
    end
end

function Library:CloseColorpickers(Exception)
    for _, Picker in pairs(self.OpenColorpickers) do
        if Picker ~= Exception and Picker.IsOpen then
            Picker:Close()
        end
    end
end

-- Create ScreenGui
Library.Holder = Instances:Create("ScreenGui", {
    Parent = game:GetService("CoreGui"),
    Name = HttpService:GenerateGUID(false),
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling
})

-- Notification System
function Library:Notify(config)
    config = config or {}
    local text = config.Text or "Notification"
    local duration = config.Duration or 3
    local color = config.Color or self.Theme.Accent

    local notif = Instances:Create("Frame", {
        Parent = self.Holder.Instance,
        Size = UDim2New(0, 0, 0, 40),
        Position = UDim2New(1, -10, 1, -50),
        BackgroundColor3 = self.Theme.ElementBackground,
        BorderColor3 = color,
        BorderSizePixel = 2,
        ClipsDescendants = true
    })

    local text = Instances:Create("TextLabel", {
        Parent = notif.Instance,
        Size = UDim2New(1, -10, 1, 0),
        Position = UDim2New(0, 5, 0, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = self.Theme.Text,
        TextSize = 14,
        Font = Enum.Font.SourceSans,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true
    })

    notif:Tween(nil, {Size = UDim2New(0, 250, 0, 40)})

    task.delay(duration, function()
        notif:Tween(nil, {Size = UDim2New(0, 0, 0, 40)})
        task.wait(0.2)
        notif:Clean()
    end)
end

-- Create Window
function Library:CreateWindow(config)
    config = config or {}
    local windowName = config.Name or "Thugsense Menu"
    local windowSize = config.Size or UDim2New(0, 500, 0, 600)

    local Window = {
        Tabs = {},
        CurrentTab = nil,
        Holder = self.Holder
    }

    local Items = {}

    -- Outer Border
    Items["OuterBorder"] = Instances:Create("Frame", {
        Parent = Library.Holder.Instance,
        Size = UDim2New(0, windowSize.X.Offset + 6, 0, windowSize.Y.Offset + 6),
        Position = UDim2New(0.5, -(windowSize.X.Offset + 6)/2, 0.5, -(windowSize.Y.Offset + 6)/2),
        BackgroundColor3 = Library.Theme.WindowBorder,
        BorderSizePixel = 0
    })
    Items["OuterBorder"]:AddToTheme({BackgroundColor3 = "WindowBorder"})

    -- Main Window Frame
    Items["Window"] = Instances:Create("Frame", {
        Parent = Items["OuterBorder"].Instance,
        Size = windowSize,
        Position = UDim2New(0, 3, 0, 3),
        BackgroundColor3 = Library.Theme.Background,
        BorderSizePixel = 0
    })
    Items["Window"]:AddToTheme({BackgroundColor3 = "Background"})
    Items["OuterBorder"]:MakeDraggable()

    -- Title Bar
    Items["TitleBar"] = Instances:Create("Frame", {
        Parent = Items["Window"].Instance,
        Size = UDim2New(1, 0, 0, 22),
        Position = UDim2New(0, 0, 0, 0),
        BackgroundColor3 = Library.Theme.TitleBar,
        BorderSizePixel = 0
    })
    Items["TitleBar"]:AddToTheme({BackgroundColor3 = "TitleBar"})

    -- Title Text
    Items["Title"] = Instances:Create("TextLabel", {
        Parent = Items["TitleBar"].Instance,
        Text = windowName,
        Font = Enum.Font.SourceSans,
        TextSize = 13,
        TextColor3 = Library.Theme.Text,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2New(1, -20, 1, 0),
        Position = UDim2New(0, 8, 0, 0)
    })
    Items["Title"]:AddToTheme({TextColor3 = "Text"})

    -- Tab Container (Horizontal)
    Items["TabContainer"] = Instances:Create("Frame", {
        Parent = Items["Window"].Instance,
        Size = UDim2New(1, 0, 0, 20),
        Position = UDim2New(0, 0, 0, 22),
        BackgroundColor3 = Library.Theme.TabBackground,
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
        Size = UDim2New(1, 0, 1, -42),
        Position = UDim2New(0, 0, 0, 42),
        BackgroundColor3 = Library.Theme.ContentBackground,
        BorderSizePixel = 0
    })
    Items["ContentContainer"]:AddToTheme({BackgroundColor3 = "ContentBackground"})

    Window.OuterBorder = Items["OuterBorder"]
    Window.MainFrame = Items["Window"]

    function Window:CreateTab(tabName)
        local Tab = {
            Name = tabName,
            Elements = {},
            Sections = {},
            Window = Window
        }

        local TabItems = {}

        -- Tab Button
        TabItems["Button"] = Instances:Create("TextButton", {
            Parent = Items["TabContainer"].Instance,
            Size = UDim2New(0, 85, 1, 0),
            BackgroundColor3 = Library.Theme.TabBackground,
            BorderSizePixel = 0,
            Text = tabName,
            Font = Enum.Font.SourceSans,
            TextSize = 13,
            TextColor3 = Library.Theme.TextDark,
            AutoButtonColor = false
        })
        TabItems["Button"]:AddToTheme({BackgroundColor3 = "TabBackground", TextColor3 = "TextDark"})

        -- Tab Content (ScrollingFrame)
        TabItems["Content"] = Instances:Create("ScrollingFrame", {
            Parent = Items["ContentContainer"].Instance,
            Size = UDim2New(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = Library.Theme.ElementBorder,
            CanvasSize = UDim2New(0, 0, 0, 0),
            Visible = false
        })

        -- Left Column
        TabItems["LeftColumn"] = Instances:Create("Frame", {
            Parent = TabItems["Content"].Instance,
            Size = UDim2New(0.5, -10, 1, 0),
            Position = UDim2New(0, 8, 0, 8),
            BackgroundTransparency = 1,
            BorderSizePixel = 0
        })

        Instances:Create("UIListLayout", {
            Parent = TabItems["LeftColumn"].Instance,
            Padding = UDimNew(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder
        })

        -- Right Column
        TabItems["RightColumn"] = Instances:Create("Frame", {
            Parent = TabItems["Content"].Instance,
            Size = UDim2New(0.5, -10, 1, 0),
            Position = UDim2New(0.5, 2, 0, 8),
            BackgroundTransparency = 1,
            BorderSizePixel = 0
        })

        Instances:Create("UIListLayout", {
            Parent = TabItems["RightColumn"].Instance,
            Padding = UDimNew(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder
        })

        -- Auto resize canvas
        local function UpdateCanvasSize()
            local leftSize = TabItems["LeftColumn"].Instance.UIListLayout.AbsoluteContentSize.Y
            local rightSize = TabItems["RightColumn"].Instance.UIListLayout.AbsoluteContentSize.Y
            local maxSize = math.max(leftSize, rightSize)
            TabItems["Content"].Instance.CanvasSize = UDim2New(0, 0, 0, maxSize + 16)
        end

        TabItems["LeftColumn"].Instance.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateCanvasSize)
        TabItems["RightColumn"].Instance.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateCanvasSize)

        -- Tab Button Click
        TabItems["Button"]:Connect("MouseButton1Click", function()
            for _, tab in pairs(Window.Tabs) do
                tab.Content.Instance.Visible = false
                tab.Button:Tween(nil, {BackgroundColor3 = Library.Theme.TabBackground})
                tab.Button.Instance.TextColor3 = Library.Theme.TextDark
            end

            TabItems["Content"].Instance.Visible = true
            TabItems["Button"]:Tween(nil, {BackgroundColor3 = Library.Theme.TabActive})
            TabItems["Button"].Instance.TextColor3 = Library.Theme.Text
            Window.CurrentTab = Tab
        end)

        Tab.Button = TabItems["Button"]
        Tab.Content = TabItems["Content"]
        Tab.LeftColumn = TabItems["LeftColumn"]
        Tab.RightColumn = TabItems["RightColumn"]

        TableInsert(Window.Tabs, Tab)

        -- Select first tab
        if #Window.Tabs == 1 then
            TabItems["Button"].Instance.BackgroundColor3 = Library.Theme.TabActive
            TabItems["Button"].Instance.TextColor3 = Library.Theme.Text
            TabItems["Content"].Instance.Visible = true
            Window.CurrentTab = Tab
        end

        function Tab:CreateSection(config)
            config = config or {}
            local sectionName = config.Name or "Section"
            local side = config.Side or "Left"

            local Section = {
                Elements = {},
                Name = sectionName
            }

            local parent = side == "Left" and TabItems["LeftColumn"] or TabItems["RightColumn"]

            local SectionItems = {}

            SectionItems["Container"] = Instances:Create("Frame", {
                Parent = parent.Instance,
                Size = UDim2New(1, 0, 0, 0),
                BackgroundColor3 = Library.Theme.ElementBackground,
                BorderColor3 = Library.Theme.ElementBorder,
                BorderSizePixel = 1,
                AutomaticSize = Enum.AutomaticSize.Y
            })
            SectionItems["Container"]:AddToTheme({BackgroundColor3 = "ElementBackground", BorderColor3 = "ElementBorder"})

            SectionItems["Title"] = Instances:Create("TextLabel", {
                Parent = SectionItems["Container"].Instance,
                Size = UDim2New(1, -10, 0, 20),
                Position = UDim2New(0, 5, 0, 3),
                BackgroundTransparency = 1,
                Text = sectionName,
                Font = Enum.Font.SourceSansBold,
                TextSize = 14,
                TextColor3 = Library.Theme.Text,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            SectionItems["Title"]:AddToTheme({TextColor3 = "Text"})

            SectionItems["Content"] = Instances:Create("Frame", {
                Parent = SectionItems["Container"].Instance,
                Size = UDim2New(1, -10, 0, 0),
                Position = UDim2New(0, 5, 0, 25),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                AutomaticSize = Enum.AutomaticSize.Y
            })

            Instances:Create("UIListLayout", {
                Parent = SectionItems["Content"].Instance,
                Padding = UDimNew(0, 5),
                SortOrder = Enum.SortOrder.LayoutOrder
            })

            Instances:Create("UIPadding", {
                Parent = SectionItems["Container"].Instance,
                PaddingBottom = UDimNew(0, 8)
            })

            Section.Container = SectionItems["Container"]
            Section.Content = SectionItems["Content"]

            function Section:CreateButton(config)
                config = config or {}
                local btnText = config.Name or "Button"
                local callback = config.Callback or function() end

                local button = Instances:Create("TextButton", {
                    Parent = SectionItems["Content"].Instance,
                    Size = UDim2New(1, 0, 0, 22),
                    BackgroundColor3 = Library.Theme.ElementBackground,
                    BorderColor3 = Library.Theme.ElementBorder,
                    BorderSizePixel = 1,
                    Text = btnText,
                    Font = Enum.Font.SourceSans,
                    TextSize = 13,
                    TextColor3 = Library.Theme.Text,
                    TextXAlignment = Enum.TextXAlignment.Center,
                    AutoButtonColor = false
                })
                button:AddToTheme({BackgroundColor3 = "ElementBackground", BorderColor3 = "ElementBorder", TextColor3 = "Text"})

                button:Connect("MouseButton1Click", function()
                    callback()
                end)

                button:Connect("MouseEnter", function()
                    button:Tween(nil, {BackgroundColor3 = Library.Theme.TabActive})
                end)

                button:Connect("MouseLeave", function()
                    button:Tween(nil, {BackgroundColor3 = Library.Theme.ElementBackground})
                end)

                TableInsert(Section.Elements, button)
                return button
            end

            function Section:CreateToggle(config)
                config = config or {}
                local toggleText = config.Name or "Toggle"
                local default = config.Default or false
                local flag = config.Flag
                local callback = config.Callback or function() end

                local toggleFrame = Instances:Create("Frame", {
                    Parent = SectionItems["Content"].Instance,
                    Size = UDim2New(1, 0, 0, 22),
                    BackgroundColor3 = Library.Theme.ElementBackground,
                    BorderColor3 = Library.Theme.ElementBorder,
                    BorderSizePixel = 1
                })
                toggleFrame:AddToTheme({BackgroundColor3 = "ElementBackground", BorderColor3 = "ElementBorder"})

                local label = Instances:Create("TextLabel", {
                    Parent = toggleFrame.Instance,
                    Size = UDim2New(1, -30, 1, 0),
                    Position = UDim2New(0, 6, 0, 0),
                    BackgroundTransparency = 1,
                    Text = toggleText,
                    Font = Enum.Font.SourceSans,
                    TextSize = 13,
                    TextColor3 = Library.Theme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                label:AddToTheme({TextColor3 = "Text"})

                local checkbox = Instances:Create("TextButton", {
                    Parent = toggleFrame.Instance,
                    Size = UDim2New(0, 12, 0, 12),
                    Position = UDim2New(1, -18, 0.5, -6),
                    BackgroundColor3 = default and Library.Theme.Toggle or Library.Theme.ToggleOff,
                    BorderColor3 = Library.Theme.ElementBorder,
                    BorderSizePixel = 1,
                    Text = "",
                    AutoButtonColor = false
                })

                local toggled = default

                if flag then
                    Library.Flags[flag] = toggled
                    Library.SetFlags[flag] = function(value)
                        toggled = value
                        checkbox.Instance.BackgroundColor3 = toggled and Library.Theme.Toggle or Library.Theme.ToggleOff
                        callback(toggled)
                    end
                end

                checkbox:Connect("MouseButton1Click", function()
                    toggled = not toggled
                    checkbox:Tween(nil, {BackgroundColor3 = toggled and Library.Theme.Toggle or Library.Theme.ToggleOff})
                    
                    if flag then
                        Library.Flags[flag] = toggled
                    end
                    
                    callback(toggled)
                end)

                TableInsert(Section.Elements, toggleFrame)
                return toggleFrame
            end

            function Section:CreateSlider(config)
                config = config or {}
                local sliderText = config.Name or "Slider"
                local min = config.Min or 0
                local max = config.Max or 100
                local default = config.Default or min
                local flag = config.Flag
                local callback = config.Callback or function() end

                local sliderFrame = Instances:Create("Frame", {
                    Parent = SectionItems["Content"].Instance,
                    Size = UDim2New(1, 0, 0, 40),
                    BackgroundColor3 = Library.Theme.ElementBackground,
                    BorderColor3 = Library.Theme.ElementBorder,
                    BorderSizePixel = 1
                })
                sliderFrame:AddToTheme({BackgroundColor3 = "ElementBackground", BorderColor3 = "ElementBorder"})

                local label = Instances:Create("TextLabel", {
                    Parent = sliderFrame.Instance,
                    Size = UDim2New(1, -55, 0, 15),
                    Position = UDim2New(0, 6, 0, 4),
                    BackgroundTransparency = 1,
                    Text = sliderText,
                    Font = Enum.Font.SourceSans,
                    TextSize = 13,
                    TextColor3 = Library.Theme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                label:AddToTheme({TextColor3 = "Text"})

                local valueLabel = Instances:Create("TextLabel", {
                    Parent = sliderFrame.Instance,
                    Size = UDim2.new(0, 45, 0, 15),
                    Position = UDim2New(1, -50, 0, 4),
                    BackgroundTransparency = 1,
                    Text = tostring(default),
                    Font = Enum.Font.SourceSans,
                    TextSize = 13,
                    TextColor3 = Library.Theme.TextDark,
                    TextXAlignment = Enum.TextXAlignment.Right
                })
                valueLabel:AddToTheme({TextColor3 = "TextDark"})

                local sliderBar = Instances:Create("Frame", {
                    Parent = sliderFrame.Instance,
                    Size = UDim2New(1, -12, 0, 5),
                    Position = UDim2New(0, 6, 1, -12),
                    BackgroundColor3 = Library.Theme.Slider,
                    BorderSizePixel = 0
                })
                sliderBar:AddToTheme({BackgroundColor3 = "Slider"})

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
                local currentValue = default

                if flag then
                    Library.Flags[flag] = currentValue
                    Library.SetFlags[flag] = function(value)
                        currentValue = MathClamp(value, min, max)
                        local percentage = (currentValue - min) / (max - min)
                        sliderFill.Instance.Size = UDim2New(percentage, 0, 1, 0)
                        valueLabel.Instance.Text = tostring(currentValue)
                        callback(currentValue)
                    end
                end

                local function UpdateSlider(input)
                    local pos = MathClamp((input.Position.X - sliderBar.Instance.AbsolutePosition.X) / sliderBar.Instance.AbsoluteSize.X, 0, 1)
                    local value = MathFloor(min + (max - min) * pos)

                    if value ~= currentValue then
                        currentValue = value
                        sliderFill.Instance.Size = UDim2New(pos, 0, 1, 0)
                        valueLabel.Instance.Text = tostring(value)
                        
                        if flag then
                            Library.Flags[flag] = value
                        end
                        
                        callback(value)
                    end
                end

                sliderBtn:Connect("InputBegan", function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        UpdateSlider(input)
                    end
                end)

                Library:Connect(UserInputService.InputEnded, function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)

                Library:Connect(UserInputService.InputChanged, function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        UpdateSlider(input)
                    end
                end)

                TableInsert(Section.Elements, sliderFrame)
                return sliderFrame
            end

            function Section:CreateDropdown(config)
                config = config or {}
                local dropdownText = config.Name or "Dropdown"
                local options = config.Options or {"Option 1", "Option 2"}
                local default = config.Default
                local flag = config.Flag
                local callback = config.Callback or function() end

                local Dropdown = {
                    IsOpen = false,
                    Options = options,
                    Selected = default or options[1]
                }

                local dropdownFrame = Instances:Create("Frame", {
                    Parent = SectionItems["Content"].Instance,
                    Size = UDim2New(1, 0, 0, 42),
                    BackgroundColor3 = Library.Theme.ElementBackground,
                    BorderColor3 = Library.Theme.ElementBorder,
                    BorderSizePixel = 1
                })
                dropdownFrame:AddToTheme({BackgroundColor3 = "ElementBackground", BorderColor3 = "ElementBorder"})

                local label = Instances:Create("TextLabel", {
                    Parent = dropdownFrame.Instance,
                    Size = UDim2New(1, -12, 0, 15),
                    Position = UDim2New(0, 6, 0, 4),
                    BackgroundTransparency = 1,
                    Text = dropdownText,
                    Font = Enum.Font.SourceSans,
                    TextSize = 13,
                    TextColor3 = Library.Theme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                label:AddToTheme({TextColor3 = "Text"})

                local dropdownBtn = Instances:Create("TextButton", {
                    Parent = dropdownFrame.Instance,
                    Size = UDim2New(1, -12, 0, 18),
                    Position = UDim2New(0, 6, 0, 20),
                    BackgroundColor3 = Library.Theme.Dropdown,
                    BorderColor3 = Library.Theme.ElementBorder,
                    BorderSizePixel = 1,
                    Text = Dropdown.Selected,
                    Font = Enum.Font.SourceSans,
                    TextSize = 12,
                    TextColor3 = Library.Theme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    AutoButtonColor = false
                })
                dropdownBtn:AddToTheme({BackgroundColor3 = "Dropdown", BorderColor3 = "ElementBorder", TextColor3 = "Text"})

                Instances:Create("UIPadding", {
                    Parent = dropdownBtn.Instance,
                    PaddingLeft = UDimNew(0, 4)
                })

                local arrow = Instances:Create("TextLabel", {
                    Parent = dropdownBtn.Instance,
                    Size = UDim2New(0, 15, 1, 0),
                    Position = UDim2New(1, -15, 0, 0),
                    BackgroundTransparency = 1,
                    Text = "▼",
                    Font = Enum.Font.SourceSans,
                    TextSize = 10,
                    TextColor3 = Library.Theme.TextDark,
                    TextXAlignment = Enum.TextXAlignment.Center
                })

                local optionsFrame = Instances:Create("Frame", {
                    Parent = dropdownFrame.Instance,
                    Size = UDim2New(1, -12, 0, 0),
                    Position = UDim2New(0, 6, 0, 38),
                    BackgroundColor3 = Library.Theme.Dropdown,
                    BorderColor3 = Library.Theme.ElementBorder,
                    BorderSizePixel = 1,
                    Visible = false,
                    ClipsDescendants = true,
                    ZIndex = 10
                })
                optionsFrame:AddToTheme({BackgroundColor3 = "Dropdown", BorderColor3 = "ElementBorder"})

                Instances:Create("UIListLayout", {
                    Parent = optionsFrame.Instance,
                    Padding = UDimNew(0, 0),
                    SortOrder = Enum.SortOrder.LayoutOrder
                })

                if flag then
                    Library.Flags[flag] = Dropdown.Selected
                    Library.SetFlags[flag] = function(value)
                        Dropdown.Selected = value
                        dropdownBtn.Instance.Text = value
                        callback(value)
                    end
                end

                function Dropdown:Refresh(newOptions)
                    Dropdown.Options = newOptions
                    
                    for _, child in pairs(optionsFrame.Instance:GetChildren()) do
                        if child:IsA("TextButton") then
                            child:Destroy()
                        end
                    end

                    for _, option in pairs(Dropdown.Options) do
                        local optionBtn = Instances:Create("TextButton", {
                            Parent = optionsFrame.Instance,
                            Size = UDim2New(1, 0, 0, 20),
                            BackgroundColor3 = Library.Theme.Dropdown,
                            BorderSizePixel = 0,
                            Text = option,
                            Font = Enum.Font.SourceSans,
                            TextSize = 12,
                            TextColor3 = Library.Theme.Text,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            AutoButtonColor = false
                        })

                        Instances:Create("UIPadding", {
                            Parent = optionBtn.Instance,
                            PaddingLeft = UDimNew(0, 4)
                        })

                        optionBtn:Connect("MouseButton1Click", function()
                            Dropdown.Selected = option
                            dropdownBtn.Instance.Text = option
                            Dropdown:Close()
                            
                            if flag then
                                Library.Flags[flag] = option
                            end
                            
                            callback(option)
                        end)

                        optionBtn:Connect("MouseEnter", function()
                            optionBtn:Tween(nil, {BackgroundColor3 = Library.Theme.DropdownSelected})
                        end)

                        optionBtn:Connect("MouseLeave", function()
                            optionBtn:Tween(nil, {BackgroundColor3 = Library.Theme.Dropdown})
                        end)
                    end
                end

                function Dropdown:Open()
                    Library:CloseDropdowns(Dropdown)
                    Dropdown.IsOpen = true
                    optionsFrame.Instance.Visible = true
                    dropdownFrame:Tween(nil, {Size = UDim2New(1, 0, 0, 42 + (#Dropdown.Options * 20))})
                    optionsFrame:Tween(nil, {Size = UDim2New(1, -12, 0, #Dropdown.Options * 20)})
                end

                function Dropdown:Close()
                    Dropdown.IsOpen = false
                    dropdownFrame:Tween(nil, {Size = UDim2New(1, 0, 0, 42)})
                    optionsFrame:Tween(nil, {Size = UDim2New(1, -12, 0, 0)})
                    task.wait(0.2)
                    optionsFrame.Instance.Visible = false
                end

                dropdownBtn:Connect("MouseButton1Click", function()
                    if Dropdown.IsOpen then
                        Dropdown:Close()
                    else
                        Dropdown:Open()
                    end
                end)

                Dropdown:Refresh(options)
                TableInsert(Library.Dropdowns, Dropdown)
                TableInsert(Section.Elements, dropdownFrame)
                return Dropdown
            end

            function Section:CreateTextbox(config)
                config = config or {}
                local boxText = config.Name or "Textbox"
                local placeholder = config.Placeholder or ""
                local flag = config.Flag
                local callback = config.Callback or function() end

                local boxFrame = Instances:Create("Frame", {
                    Parent = SectionItems["Content"].Instance,
                    Size = UDim2New(1, 0, 0, 42),
                    BackgroundColor3 = Library.Theme.ElementBackground,
                    BorderColor3 = Library.Theme.ElementBorder,
                    BorderSizePixel = 1
                })
                boxFrame:AddToTheme({BackgroundColor3 = "ElementBackground", BorderColor3 = "ElementBorder"})

                local label = Instances:Create("TextLabel", {
                    Parent = boxFrame.Instance,
                    Size = UDim2New(1, -12, 0, 15),
                    Position = UDim2New(0, 6, 0, 4),
                    BackgroundTransparency = 1,
                    Text = boxText,
                    Font = Enum.Font.SourceSans,
                    TextSize = 13,
                    TextColor3 = Library.Theme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                label:AddToTheme({TextColor3 = "Text"})

                local textbox = Instances:Create("TextBox", {
                    Parent = boxFrame.Instance,
                    Size = UDim2New(1, -12, 0, 18),
                    Position = UDim2New(0, 6, 0, 20),
                    BackgroundColor3 = Library.Theme.Dropdown,
                    BorderColor3 = Library.Theme.ElementBorder,
                    BorderSizePixel = 1,
                    Text = "",
                    PlaceholderText = placeholder,
                    Font = Enum.Font.SourceSans,
                    TextSize = 12,
                    TextColor3 = Library.Theme.Text,
                    PlaceholderColor3 = Library.Theme.TextDark,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ClearTextOnFocus = false
                })
                textbox:AddToTheme({BackgroundColor3 = "Dropdown", BorderColor3 = "ElementBorder", TextColor3 = "Text", PlaceholderColor3 = "TextDark"})

                Instances:Create("UIPadding", {
                    Parent = textbox.Instance,
                    PaddingLeft = UDimNew(0, 4)
                })

                if flag then
                    Library.Flags[flag] = ""
                    Library.SetFlags[flag] = function(value)
                        textbox.Instance.Text = value
                        callback(value)
                    end
                end

                textbox:Connect("FocusLost", function(enter)
                    if enter then
                        if flag then
                            Library.Flags[flag] = textbox.Instance.Text
                        end
                        callback(textbox.Instance.Text)
                    end
                end)

                TableInsert(Section.Elements, boxFrame)
                return boxFrame
            end

            function Section:CreateKeybind(config)
                config = config or {}
                local keybindText = config.Name or "Keybind"
                local default = config.Default or Enum.KeyCode.Unknown
                local flag = config.Flag
                local callback = config.Callback or function() end

                local Keybind = {
                    Key = default,
                    IsBinding = false,
                    Mode = config.Mode or "Toggle"
                }

                local keybindFrame = Instances:Create("Frame", {
                    Parent = SectionItems["Content"].Instance,
                    Size = UDim2New(1, 0, 0, 22),
                    BackgroundColor3 = Library.Theme.ElementBackground,
                    BorderColor3 = Library.Theme.ElementBorder,
                    BorderSizePixel = 1
                })
                keybindFrame:AddToTheme({BackgroundColor3 = "ElementBackground", BorderColor3 = "ElementBorder"})

                local label = Instances:Create("TextLabel", {
                    Parent = keybindFrame.Instance,
                    Size = UDim2New(1, -70, 1, 0),
                    Position = UDim2New(0, 6, 0, 0),
                    BackgroundTransparency = 1,
                    Text = keybindText,
                    Font = Enum.Font.SourceSans,
                    TextSize = 13,
                    TextColor3 = Library.Theme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                label:AddToTheme({TextColor3 = "Text"})

                local keybindBtn = Instances:Create("TextButton", {
                    Parent = keybindFrame.Instance,
                    Size = UDim2New(0, 60, 0, 16),
                    Position = UDim2New(1, -66, 0.5, -8),
                    BackgroundColor3 = Library.Theme.Dropdown,
                    BorderColor3 = Library.Theme.ElementBorder,
                    BorderSizePixel = 1,
                    Text = default.Name,
                    Font = Enum.Font.SourceSans,
                    TextSize = 11,
                    TextColor3 = Library.Theme.Text,
                    AutoButtonColor = false
                })
                keybindBtn:AddToTheme({BackgroundColor3 = "Dropdown", BorderColor3 = "ElementBorder", TextColor3 = "Text"})

                if flag then
                    Library.Flags[flag] = {Key = Keybind.Key, Mode = Keybind.Mode}
                    Library.SetFlags[flag] = function(data)
                        Keybind.Key = data.Key or Keybind.Key
                        Keybind.Mode = data.Mode or Keybind.Mode
                        keybindBtn.Instance.Text = Keybind.Key.Name
                    end
                end

                keybindBtn:Connect("MouseButton1Click", function()
                    Keybind.IsBinding = true
                    keybindBtn.Instance.Text = "..."
                end)

                Library:Connect(UserInputService.InputBegan, function(input)
                    if Keybind.IsBinding then
                        local key = input.KeyCode ~= Enum.KeyCode.Unknown and input.KeyCode or input.UserInputType
                        
                        Keybind.Key = key
                        Keybind.IsBinding = false
                        keybindBtn.Instance.Text = key.Name
                        
                        if flag then
                            Library.Flags[flag] = {Key = Keybind.Key, Mode = Keybind.Mode}
                        end
                    elseif input.KeyCode == Keybind.Key or input.UserInputType == Keybind.Key then
                        callback()
                    end
                end)

                TableInsert(Section.Elements, keybindFrame)
                return Keybind
            end

            function Section:CreateColorpicker(config)
                config = config or {}
                local colorText = config.Name or "Color"
                local default = config.Default or FromRGB(255, 255, 255)
                local flag = config.Flag
                local callback = config.Callback or function() end

                local Colorpicker = {
                    Color = default,
                    Hue = 0,
                    Sat = 0,
                    Val = 0,
                    IsOpen = false
                }

                local colorFrame = Instances:Create("Frame", {
                    Parent = SectionItems["Content"].Instance,
                    Size = UDim2New(1, 0, 0, 22),
                    BackgroundColor3 = Library.Theme.ElementBackground,
                    BorderColor3 = Library.Theme.ElementBorder,
                    BorderSizePixel = 1
                })
                colorFrame:AddToTheme({BackgroundColor3 = "ElementBackground", BorderColor3 = "ElementBorder"})

                local label = Instances:Create("TextLabel", {
                    Parent = colorFrame.Instance,
                    Size = UDim2New(1, -30, 1, 0),
                    Position = UDim2New(0, 6, 0, 0),
                    BackgroundTransparency = 1,
                    Text = colorText,
                    Font = Enum.Font.SourceSans,
                    TextSize = 13,
                    TextColor3 = Library.Theme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                label:AddToTheme({TextColor3 = "Text"})

                local colorBtn = Instances:Create("TextButton", {
                    Parent = colorFrame.Instance,
                    Size = UDim2New(0, 18, 0, 14),
                    Position = UDim2New(1, -23, 0.5, -7),
                    BackgroundColor3 = default,
                    BorderColor3 = Library.Theme.ElementBorder,
                    BorderSizePixel = 1,
                    Text = "",
                    AutoButtonColor = false
                })

                local pickerFrame = Instances:Create("Frame", {
                    Parent = Library.Holder.Instance,
                    Size = UDim2New(0, 200, 0, 0),
                    Position = UDim2New(0.5, -100, 0.5, -100),
                    BackgroundColor3 = Library.Theme.ElementBackground,
                    BorderColor3 = Library.Theme.ElementBorder,
                    BorderSizePixel = 1,
                    Visible = false,
                    ClipsDescendants = true,
                    ZIndex = 100
                })
                pickerFrame:AddToTheme({BackgroundColor3 = "ElementBackground", BorderColor3 = "ElementBorder"})

                if flag then
                    Library.Flags[flag] = {Color = default, Alpha = 1}
                    Library.SetFlags[flag] = function(color, alpha)
                        Colorpicker.Color = color
                        colorBtn.Instance.BackgroundColor3 = color
                        callback(color, alpha or 1)
                    end
                end

                function Colorpicker:Open()
                    Library:CloseColorpickers(Colorpicker)
                    Colorpicker.IsOpen = true
                    pickerFrame.Instance.Visible = true
                    pickerFrame:Tween(nil, {Size = UDim2New(0, 200, 0, 200)})
                end

                function Colorpicker:Close()
                    Colorpicker.IsOpen = false
                    pickerFrame:Tween(nil, {Size = UDim2New(0, 200, 0, 0)})
                    task.wait(0.2)
                    pickerFrame.Instance.Visible = false
                end

                colorBtn:Connect("MouseButton1Click", function()
                    if Colorpicker.IsOpen then
                        Colorpicker:Close()
                    else
                        Colorpicker:Open()
                    end
                end)

                TableInsert(Library.OpenColorpickers, Colorpicker)
                TableInsert(Section.Elements, colorFrame)
                return Colorpicker
            end

            function Section:CreateLabel(text)
                local label = Instances:Create("TextLabel", {
                    Parent = SectionItems["Content"].Instance,
                    Size = UDim2New(1, 0, 0, 18),
                    BackgroundTransparency = 1,
                    Text = text,
                    Font = Enum.Font.SourceSans,
                    TextSize = 13,
                    TextColor3 = Library.Theme.TextDark,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                label:AddToTheme({TextColor3 = "TextDark"})

                Instances:Create("UIPadding", {
                    Parent = label.Instance,
                    PaddingLeft = UDimNew(0, 6)
                })

                function label:SetText(newText)
                    label.Instance.Text = newText
                end

                TableInsert(Section.Elements, label)
                return label
            end

            TableInsert(Tab.Sections, Section)
            return Section
        end

        -- For backward compatibility - add elements directly to tab
        function Tab:CreateButton(config)
            local section = Tab:CreateSection({Name = "Main", Side = "Left"})
            return section:CreateButton(config)
        end

        function Tab:CreateToggle(config)
            local section = Tab:CreateSection({Name = "Main", Side = "Left"})
            return section:CreateToggle(config)
        end

        function Tab:CreateSlider(config)
            local section = Tab:CreateSection({Name = "Main", Side = "Left"})
            return section:CreateSlider(config)
        end

        function Tab:CreateDropdown(config)
            local section = Tab:CreateSection({Name = "Main", Side = "Left"})
            return section:CreateDropdown(config)
        end

        function Tab:CreateTextbox(config)
            local section = Tab:CreateSection({Name = "Main", Side = "Left"})
            return section:CreateTextbox(config)
        end

        function Tab:CreateKeybind(config)
            local section = Tab:CreateSection({Name = "Main", Side = "Left"})
            return section:CreateKeybind(config)
        end

        function Tab:CreateColorpicker(config)
            local section = Tab:CreateSection({Name = "Main", Side = "Left"})
            return section:CreateColorpicker(config)
        end

        function Tab:CreateLabel(text)
            local section = Tab:CreateSection({Name = "Main", Side = "Left"})
            return section:CreateLabel(text)
        end

        return Tab
    end

    function Window:Unload()
        for _, connection in pairs(Library.Connections) do
            Library:Disconnect(connection)
        end
        
        Library.Holder:Clean()
    end

    return Window
end

return Library
