-- Xbox-inspired dashboard library. Require from a LocalScript.
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")
local Library = {}
local Window = {}
Window.__index = Window
local Page = {}
Page.__index = Page
local WHITE = Color3.fromRGB(245, 247, 245)
local MUTED = Color3.fromRGB(170, 184, 174)
local PANEL = Color3.fromRGB(29, 38, 33)

local function make(class, props, parent)
    local object = Instance.new(class)
    for key, value in pairs(props) do object[key] = value end
    object.Parent = parent
    return object
end
local function round(object, radius)
    make("UICorner", {CornerRadius = UDim.new(0, radius or 10)}, object)
end
local function label(parent, text, size, position, dimensions, color)
    return make("TextLabel", {
        BackgroundTransparency = 1, Text = text, TextSize = size,
        TextColor3 = color or WHITE, Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true,
        Position = position, Size = dimensions,
    }, parent)
end
function Window:_connect(signal, callback)
    local connection = signal:Connect(callback)
    table.insert(self._connections, connection)
    return connection
end
function Window:_button(parent, props, callback)
    props.AutoButtonColor = false
    props.Selectable = true
    props.TextColor3 = WHITE
    props.Font = Enum.Font.GothamMedium
    props.TextSize = props.TextSize or 17
    props.BorderSizePixel = 0
    local button = make("TextButton", props, parent)
    round(button)
    local outline = make("UIStroke", {Color = self.Accent, Thickness = 3, Transparency = 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border}, button)
    local hover, selected = false, false
    local function repaint()
        TweenService:Create(outline, TweenInfo.new(0.12), {
            Transparency = (hover or selected) and 0 or 1,
        }):Play()
    end
    self:_connect(button.MouseEnter, function() hover = true; repaint() end)
    self:_connect(button.MouseLeave, function() hover = false; repaint() end)
    self:_connect(button.SelectionGained, function() selected = true; repaint() end)
    self:_connect(button.SelectionLost, function() selected = false; repaint() end)
    self:_connect(button.Activated, function()
        if callback then callback() end
    end)
    return button
end

function Library.new(options)
    options = options or {}
    assert(Players.LocalPlayer, "XboxUI must run on the client")
    local self = setmetatable({_connections = {}, Pages = {}, _destroyed = false}, Window)
    self.Accent = options.Accent or Color3.fromRGB(144, 232, 66)
    self.Gui = make("ScreenGui", {Name = "XboxUI", ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = options.DisplayOrder or 10},
        options.Parent or Players.LocalPlayer:WaitForChild("PlayerGui"))
    local root = make("Frame", {Size = UDim2.fromScale(1, 1), BorderSizePixel = 0,
        BackgroundColor3 = Color3.fromRGB(9, 19, 16)}, self.Gui)
    make("UIGradient", {Rotation = 25, Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(9, 17, 19)),
        ColorSequenceKeypoint.new(0.55, Color3.fromRGB(23, 57, 41)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 19, 15)),
    })}, root)
    if options.BackgroundImage then
        make("ImageLabel", {BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1),
            Image = options.BackgroundImage, ImageTransparency = 0.45,
            ScaleType = Enum.ScaleType.Crop}, root)
    end
    local canvas = make("Frame", {BackgroundTransparency = 1, Size = UDim2.fromOffset(1200, 720),
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5)}, root)
    local scale = make("UIScale", {}, canvas)
    local function resize()
        scale.Scale = math.max(0.1, math.min(root.AbsoluteSize.X / 1200, root.AbsoluteSize.Y / 720))
    end
    self:_connect(root:GetPropertyChangedSignal("AbsoluteSize"), resize)
    resize()
    label(canvas, options.Title or "NEXUS", 23, UDim2.fromOffset(36, 24), UDim2.fromOffset(230, 40))
    label(canvas, options.ProfileName or Players.LocalPlayer.DisplayName, 15,
        UDim2.fromOffset(890, 24), UDim2.fromOffset(270, 40)).TextXAlignment = Enum.TextXAlignment.Right
    self.Nav = make("ScrollingFrame", {BackgroundTransparency = 1, BorderSizePixel = 0,
        Position = UDim2.fromOffset(36, 86), Size = UDim2.fromOffset(1128, 56),
        CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.X,
        ScrollingDirection = Enum.ScrollingDirection.X, ScrollBarThickness = 2}, canvas)
    make("UIPadding", {PaddingLeft = UDim.new(0, 5), PaddingTop = UDim.new(0, 5)}, self.Nav)
    make("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 12), SortOrder = Enum.SortOrder.LayoutOrder}, self.Nav)
    self.Body = make("Frame", {BackgroundTransparency = 1, Position = UDim2.fromOffset(36, 164),
        Size = UDim2.fromOffset(1128, 496)}, canvas)
    label(canvas, "A  Select     B  Close     •     Right Shift  Toggle", 13,
        UDim2.fromOffset(36, 680), UDim2.fromOffset(790, 22), MUTED)
    self:_button(canvas, {Text = "Close", BackgroundColor3 = PANEL,
        Position = UDim2.fromOffset(1054, 674), Size = UDim2.fromOffset(110, 32)}, function()
        self:SetVisible(false)
    end)
    self.Toast = label(canvas, "", 16, UDim2.fromOffset(350, 612), UDim2.fromOffset(500, 48))
    self.Toast.BackgroundColor3 = PANEL
    self.Toast.BackgroundTransparency = 0
    self.Toast.TextXAlignment = Enum.TextXAlignment.Center
    self.Toast.ZIndex = 20
    self.Toast.Visible = false
    round(self.Toast)
    self:_connect(UIS.InputBegan, function(input, processed)
        if UIS:GetFocusedTextBox() then return end
        if input.KeyCode == (options.ToggleKey or Enum.KeyCode.RightShift) and not processed then
            self:SetVisible(not self.Gui.Enabled)
        elseif input.KeyCode == Enum.KeyCode.ButtonB and self.Gui.Enabled then
            self:SetVisible(false)
        elseif input.KeyCode == Enum.KeyCode.ButtonStart and not processed then
            self:SetVisible(not self.Gui.Enabled)
        end
    end)
    self:_connect(UIS.GamepadConnected, function()
        if self.Gui.Enabled and self.ActivePage then GuiService.SelectedObject = self.ActivePage.Tab end
    end)
    return self
end

function Window:AddPage(name)
    local page = setmetatable({Window = self, Name = name}, Page)
    page.Frame = make("ScrollingFrame", {BackgroundTransparency = 1, BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1), CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 3,
        ScrollBarImageColor3 = self.Accent, Visible = false}, self.Body)
    make("UIPadding", {PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 12),
        PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 12)}, page.Frame)
    make("UIListLayout", {Padding = UDim.new(0, 16), SortOrder = Enum.SortOrder.LayoutOrder}, page.Frame)
    page.Tab = self:_button(self.Nav, {Text = name, BackgroundColor3 = PANEL,
        Size = UDim2.fromOffset(150, 40), LayoutOrder = #self.Pages + 1}, function() self:SelectPage(page) end)
    table.insert(self.Pages, page)
    if not self.ActivePage then self:SelectPage(page) end
    return page
end
function Window:SelectPage(page)
    assert(page.Window == self, "Page belongs to another window")
    for _, item in ipairs(self.Pages) do
        item.Frame.Visible = item == page
        item.Tab.BackgroundColor3 = item == page and self.Accent or PANEL
        item.Tab.TextColor3 = item == page and Color3.fromRGB(12, 26, 13) or WHITE
    end
    self.ActivePage = page
    if UIS.GamepadEnabled or (GuiService.SelectedObject and GuiService.SelectedObject:IsDescendantOf(self.Gui)) then
        GuiService.SelectedObject = page.Tab
    end
end
function Window:SetVisible(visible)
    if self._destroyed then return end
    self.Gui.Enabled = visible
    if visible and UIS.GamepadEnabled and self.ActivePage then
        self._previousSelection = GuiService.SelectedObject
        GuiService.SelectedObject = self.ActivePage.Tab
    elseif not visible and GuiService.SelectedObject and GuiService.SelectedObject:IsDescendantOf(self.Gui) then
        local previous = self._previousSelection
        GuiService.SelectedObject = previous and previous.Parent and previous or nil
    end
end
function Window:Notify(message, duration)
    self._toastId = (self._toastId or 0) + 1
    local id = self._toastId
    self.Toast.Text = tostring(message)
    self.Toast.Visible = true
    task.delay(duration or 3, function()
        if not self._destroyed and self._toastId == id then self.Toast.Visible = false end
    end)
end
function Window:Destroy()
    if self._destroyed then return end
    self:SetVisible(false)
    self._destroyed = true
    for _, connection in ipairs(self._connections) do connection:Disconnect() end
    self.Gui:Destroy()
end
function Page:AddSection(title)
    return label(self.Frame, title, 21, UDim2.new(), UDim2.new(1, 0, 0, 34))
end
function Page:AddHero(options)
    local hero = self.Window:_button(self.Frame, {Text = "", BackgroundColor3 = options.Color or Color3.fromRGB(27, 80, 48),
        Size = UDim2.new(1, 0, 0, 205), ClipsDescendants = true}, options.Callback)
    if options.Image then
        make("ImageLabel", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
            Image = options.Image, ScaleType = Enum.ScaleType.Crop, ImageTransparency = 0.3}, hero)
    end
    local shade = make("Frame", {Size = UDim2.fromScale(1, 1), BorderSizePixel = 0,
        BackgroundColor3 = Color3.new(0, 0, 0)}, hero)
    make("UIGradient", {Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.15),
        NumberSequenceKeypoint.new(1, 0.85)})}, shade)
    label(hero, options.Tag or "FEATURED", 12, UDim2.fromOffset(26, 22), UDim2.fromOffset(650, 24), self.Window.Accent)
    label(hero, options.Title or "Welcome home.", 36, UDim2.fromOffset(26, 52), UDim2.fromOffset(860, 54))
    label(hero, options.Description or "Your next adventure starts here.", 16,
        UDim2.fromOffset(26, 112), UDim2.fromOffset(880, 34), MUTED)
    label(hero, options.ActionText or "PLAY NOW  →", 14, UDim2.fromOffset(26, 165), UDim2.fromOffset(850, 24))
    return hero
end
function Page:AddTiles(items)
    local row = make("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y}, self.Frame)
    make("UIGridLayout", {CellSize = UDim2.new(0.25, -12, 0, 166), CellPadding = UDim2.fromOffset(14, 14),
        SortOrder = Enum.SortOrder.LayoutOrder}, row)
    for index, item in ipairs(items) do
        local tile = self.Window:_button(row, {Text = "", BackgroundColor3 = item.Color or PANEL,
            LayoutOrder = index, ClipsDescendants = true}, item.Callback)
        if item.Image then
            make("ImageLabel", {BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1),
                Image = item.Image, ScaleType = Enum.ScaleType.Crop, ImageTransparency = 0.25}, tile)
        end
        label(tile, item.Icon or string.format("%02d", index), 32, UDim2.fromOffset(18, 18), UDim2.fromOffset(150, 48), self.Window.Accent)
        local caption = make("Frame", {BackgroundColor3 = Color3.fromRGB(10, 18, 14),
            BackgroundTransparency = 0.15, BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 1, -64), Size = UDim2.new(1, 0, 0, 64)}, tile)
        label(caption, item.Title or "Tile", 18, UDim2.fromOffset(16, 6), UDim2.new(1, -32, 0, 26))
        label(caption, item.Description or "Open", 12, UDim2.fromOffset(16, 34), UDim2.new(1, -32, 0, 20), MUTED)
    end
    return row
end
function Page:AddButton(options)
    return self.Window:_button(self.Frame, {Text = "   " .. options.Title .. "   →", TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundColor3 = PANEL, Size = UDim2.new(1, 0, 0, 58)}, options.Callback)
end
function Page:AddToggle(options)
    local value = options.Default == true
    local button
    local function paint()
        button.Text = "   " .. options.Title .. "     " .. (value and "ON  ●" or "OFF  ○")
        button.TextColor3 = value and self.Window.Accent or WHITE
    end
    local control = {}
    function control:Set(nextValue, silent)
        value = nextValue == true
        paint()
        if not silent and options.Callback then options.Callback(value) end
    end
    function control:Get() return value end
    button = self.Window:_button(self.Frame, {Text = "", TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundColor3 = PANEL, Size = UDim2.new(1, 0, 0, 58)}, function() control:Set(not value) end)
    control.Instance = button
    paint()
    return control
end
function Page:AddSlider(options)
    local minimum, maximum, step = options.Min or 0, options.Max or 100, options.Step or 1
    assert(maximum > minimum and step > 0, "Slider requires Max > Min and Step > 0")
    local row = make("Frame", {BackgroundColor3 = PANEL, BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 82)}, self.Frame)
    round(row)
    local title = label(row, "", 16, UDim2.fromOffset(18, 10), UDim2.new(1, -180, 0, 28))
    local track = make("Frame", {BackgroundColor3 = Color3.fromRGB(55, 66, 59), BorderSizePixel = 0,
        Position = UDim2.fromOffset(18, 52), Size = UDim2.new(1, -190, 0, 6)}, row)
    round(track)
    local fill = make("Frame", {BackgroundColor3 = self.Window.Accent, BorderSizePixel = 0}, track)
    round(fill)
    local value, control = minimum, {}
    function control:Set(nextValue, silent)
        value = math.clamp(minimum + math.floor((nextValue - minimum) / step + 0.5) * step, minimum, maximum)
        title.Text = options.Title .. "   " .. tostring(math.round(value * 1000) / 1000)
        fill.Size = UDim2.fromScale((value - minimum) / (maximum - minimum), 1)
        if not silent and options.Callback then options.Callback(value) end
    end
    function control:Get() return value end
    for index, delta in ipairs({-step, step}) do
        self.Window:_button(row, {Text = index == 1 and "−" or "+", BackgroundColor3 = Color3.fromRGB(48, 61, 52),
            Position = UDim2.new(1, index == 1 and -150 or -80, 0, 18), Size = UDim2.fromOffset(60, 46)},
            function() control:Set(value + delta) end)
    end
    control.Instance = row
    control:Set(options.Default or minimum, true)
    return control
end
return Library
