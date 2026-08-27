-- [[ SEERE-STYLE UI LIBRARY ]] --
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local Library = {}
Library.__index = Library

function Library.new(titleText)
	local self = setmetatable({}, Library)
	
	-- Main ScreenGui
	self.ScreenGui = Instance.new("ScreenGui")
	self.ScreenGui.Name = "SeereStyleUI"
	self.ScreenGui.ResetOnSpawn = false
	self.ScreenGui.IgnoreGuiInset = true
	
	-- Protect GUI if running in an executor environment
	if syn and syn.protect_gui then
		syn.protect_gui(self.ScreenGui)
		self.ScreenGui.Parent = CoreGui
	elseif gethui then
		self.ScreenGui.Parent = gethui()
	else
		self.ScreenGui.Parent = CoreGui
	end

	-- Main Window Frame (Outer Border Frame)
	self.MainFrame = Instance.new("Frame")
	self.MainFrame.Name = "MainFrame"
	self.MainFrame.Size = UDim2.new(0, 650, 0, 520)
	self.MainFrame.Position = UDim2.new(0.5, -325, 0.5, -260)
	self.MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35) -- Outer border color
	self.MainFrame.BorderSizePixel = 1
	self.MainFrame.BorderColor3 = Color3.fromRGB(45, 45, 45)
	self.MainFrame.Parent = self.ScreenGui

	-- Inner Frame (Creates the double border effect)
	self.InnerFrame = Instance.new("Frame")
	self.InnerFrame.Name = "InnerFrame"
	self.InnerFrame.Size = UDim2.new(1, -6, 1, -6)
	self.InnerFrame.Position = UDim2.new(0, 3, 0, 3)
	self.InnerFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15) -- Main background
	self.InnerFrame.BorderSizePixel = 1
	self.InnerFrame.BorderColor3 = Color3.fromRGB(28, 28, 28)
	self.InnerFrame.Parent = self.MainFrame

	-- Top Title Bar Frame (Used for dragging)
	self.TitleBar = Instance.new("TextButton")
	self.TitleBar.Name = "TitleBar"
	self.TitleBar.Size = UDim2.new(1, -16, 0, 25)
	self.TitleBar.Position = UDim2.new(0, 8, 0, 4)
	self.TitleBar.BackgroundTransparency = 1
	self.TitleBar.Text = ""
	self.TitleBar.Parent = self.InnerFrame

	-- Title Text
	self.TitleText = Instance.new("TextLabel")
	self.TitleText.Name = "TitleText"
	self.TitleText.Size = UDim2.new(1, 0, 1, 0)
	self.TitleText.BackgroundTransparency = 1
	self.TitleText.Text = titleText
	self.TitleText.TextColor3 = Color3.fromRGB(200, 200, 200)
	self.TitleText.TextSize = 13
	self.TitleText.Font = Enum.Font.Code
	self.TitleText.TextXAlignment = Enum.TextXAlignment.Left
	self.TitleText.RichText = true
	self.TitleText.Parent = self.TitleBar

	-- Tab Container Bar
	self.TabContainer = Instance.new("Frame")
	self.TabContainer.Size = UDim2.new(1, -16, 0, 28)
	self.TabContainer.Position = UDim2.new(0, 8, 0, 32)
	self.TabContainer.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
	self.TabContainer.BorderSizePixel = 1
	self.TabContainer.BorderColor3 = Color3.fromRGB(25, 25, 25)
	self.TabContainer.Parent = self.InnerFrame

	local tabLayout = Instance.new("UIListLayout")
	tabLayout.FillDirection = Enum.FillDirection.Horizontal
	tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
	tabLayout.Padding = UDim.new(0, 8)
	tabLayout.Parent = self.TabContainer

	self.ContentHolder = Instance.new("Folder")
	self.ContentHolder.Name = "Tabs"
	self.ContentHolder.Parent = self.InnerFrame

	-- Dragging Logic
	local dragging = false
	local dragStart = Vector3.new()
	local startPos = UDim2.new()

	self.TitleBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = self.MainFrame.Position
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
			local delta = input.Position - dragStart
			self.MainFrame.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	self.Tabs = {}
	return self
end

function Library:AddTab(name)
	local tab = {}
	
	-- Tab Button
	local tabButton = Instance.new("TextButton")
	tabButton.Size = UDim2.new(0, 85, 1, 0)
	tabButton.BackgroundTransparency = 1
	tabButton.Text = name
	tabButton.TextColor3 = Color3.fromRGB(140, 140, 140)
	tabButton.TextSize = 12
	tabButton.Font = Enum.Font.Code
	tabButton.Parent = self.TabContainer

	-- Tab Underline Accent
	local tabAccent = Instance.new("Frame")
	tabAccent.Size = UDim2.new(1, 0, 0, 1)
	tabAccent.Position = UDim2.new(0, 0, 1, -1)
	tabAccent.BackgroundColor3 = Color3.fromRGB(214, 112, 214) -- Pink accent
	tabAccent.BorderSizePixel = 0
	tabAccent.Visible = false
	tabAccent.Parent = tabButton

	-- Tab Page Content Panel (Horizontal layout of columns)
	local tabPage = Instance.new("ScrollingFrame")
	tabPage.Size = UDim2.new(1, -16, 1, -75)
	tabPage.Position = UDim2.new(0, 8, 0, 68)
	tabPage.BackgroundTransparency = 1
	tabPage.BorderSizePixel = 0
	tabPage.Visible = false
	tabPage.CanvasSize = UDim2.new(0, 0, 0, 0)
	tabPage.ScrollBarThickness = 2
	tabPage.ScrollBarImageColor3 = Color3.fromRGB(214, 112, 214)
	tabPage.ClipsDescendants = false
	tabPage.Parent = self.ContentHolder

	local pageLayout = Instance.new("UIListLayout")
	pageLayout.FillDirection = Enum.FillDirection.Horizontal
	pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
	pageLayout.Padding = UDim.new(0, 8)
	pageLayout.Parent = tabPage

	-- Switch Tab Logic
	tabButton.MouseButton1Click:Connect(function()
		for _, t in pairs(self.Tabs) do
			t.Page.Visible = false
			t.Button.TextColor3 = Color3.fromRGB(140, 140, 140)
			t.Accent.Visible = false
		end
		tabPage.Visible = true
		tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		tabAccent.Visible = true
	end)

	if #self.Tabs == 0 then
		tabPage.Visible = true
		tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		tabAccent.Visible = true
	end

	table.insert(self.Tabs, {Button = tabButton, Page = tabPage, Accent = tabAccent})

	-- Columns implementation to allow vertical stacking of groupboxes
	function tab:AddColumn(width)
		width = width or 200
		local column = {}

		local colFrame = Instance.new("Frame")
		colFrame.Size = UDim2.new(0, width, 1, 0)
		colFrame.BackgroundTransparency = 1
		colFrame.ClipsDescendants = false
		colFrame.Parent = tabPage

		local colLayout = Instance.new("UIListLayout")
		colLayout.SortOrder = Enum.SortOrder.LayoutOrder
		colLayout.Padding = UDim.new(0, 12)
		colLayout.Parent = colFrame

		-- Auto resize column to height of contents, which allows dynamic scroll height on the tab
		colLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			colFrame.Size = UDim2.new(0, width, 0, colLayout.AbsoluteContentSize.Y + 10)
			-- Update Scrolling Frame Canvas Size
			local maxColHeight = 0
			for _, child in pairs(tabPage:GetChildren()) do
				if child:IsA("Frame") and child.AbsoluteSize.Y > maxColHeight then
					maxColHeight = child.AbsoluteSize.Y
				end
			end
			tabPage.CanvasSize = UDim2.new(0, 0, 0, maxColHeight + 10)
		end)

		function column:AddGroup(groupName)
			local group = {}

			local groupFrame = Instance.new("Frame")
			groupFrame.Size = UDim2.new(1, 0, 0, 40)
			groupFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
			groupFrame.BorderSizePixel = 0
			groupFrame.ClipsDescendants = false
			groupFrame.Parent = colFrame

			-- Custom borders to achieve pink top border and dark side/bottom borders
			local leftBorder = Instance.new("Frame")
			leftBorder.Size = UDim2.new(0, 1, 1, 0)
			leftBorder.Position = UDim2.new(0, 0, 0, 0)
			leftBorder.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
			leftBorder.BorderSizePixel = 0
			leftBorder.Parent = groupFrame

			local rightBorder = Instance.new("Frame")
			rightBorder.Size = UDim2.new(0, 1, 1, 0)
			rightBorder.Position = UDim2.new(1, -1, 0, 0)
			rightBorder.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
			rightBorder.BorderSizePixel = 0
			rightBorder.Parent = groupFrame

			local bottomBorder = Instance.new("Frame")
			bottomBorder.Size = UDim2.new(1, 0, 0, 1)
			bottomBorder.Position = UDim2.new(0, 0, 1, -1)
			bottomBorder.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
			bottomBorder.BorderSizePixel = 0
			bottomBorder.Parent = groupFrame

			-- Top border parts: TopLeft (pink), Group Title (white), TopRight (pink)
			local topLeftBorder = Instance.new("Frame")
			topLeftBorder.Size = UDim2.new(0, 8, 0, 1)
			topLeftBorder.Position = UDim2.new(0, 0, 0, 0)
			topLeftBorder.BackgroundColor3 = Color3.fromRGB(214, 112, 214) -- Pink accent
			topLeftBorder.BorderSizePixel = 0
			topLeftBorder.Parent = groupFrame

			local groupTitle = Instance.new("TextLabel")
			groupTitle.Size = UDim2.new(0, 0, 0, 14)
			groupTitle.Position = UDim2.new(0, 10, 0, -7)
			groupTitle.BackgroundTransparency = 1
			groupTitle.Text = " " .. groupName .. " "
			groupTitle.TextColor3 = Color3.fromRGB(220, 220, 220) -- White text in image
			groupTitle.TextSize = 11
			groupTitle.Font = Enum.Font.Code
			groupTitle.AutomaticSize = Enum.AutomaticSize.X
			groupTitle.Parent = groupFrame

			local topRightBorder = Instance.new("Frame")
			topRightBorder.BorderSizePixel = 0
			topRightBorder.BackgroundColor3 = Color3.fromRGB(214, 112, 214) -- Pink accent
			topRightBorder.Parent = groupFrame

			-- Update the top right border line length based on title text width dynamically
			groupTitle:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
				local textWidth = groupTitle.AbsoluteSize.X
				topRightBorder.Position = UDim2.new(0, 10 + textWidth, 0, 0)
				topRightBorder.Size = UDim2.new(1, -(10 + textWidth), 0, 1)
			end)

			-- Content Container Frame
			local contentFrame = Instance.new("Frame")
			contentFrame.Size = UDim2.new(1, -16, 1, -16)
			contentFrame.Position = UDim2.new(0, 8, 0, 10)
			contentFrame.BackgroundTransparency = 1
			contentFrame.ClipsDescendants = false
			contentFrame.Parent = groupFrame

			local groupLayout = Instance.new("UIListLayout")
			groupLayout.SortOrder = Enum.SortOrder.LayoutOrder
			groupLayout.Padding = UDim.new(0, 6)
			groupLayout.Parent = contentFrame

			-- Auto size groupbox vertically
			groupLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				groupFrame.Size = UDim2.new(1, 0, 0, groupLayout.AbsoluteContentSize.Y + 20)
			end)

			-- 1. Button Control
			function group:AddButton(text, callback)
				local btn = Instance.new("TextButton")
				btn.Size = UDim2.new(1, 0, 0, 20)
				btn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
				btn.BorderSizePixel = 1
				btn.BorderColor3 = Color3.fromRGB(40, 40, 40)
				btn.Text = text
				btn.TextColor3 = Color3.fromRGB(180, 180, 180)
				btn.TextSize = 11
				btn.Font = Enum.Font.Code
				btn.Parent = contentFrame

				btn.MouseButton1Click:Connect(function()
					pcall(callback)
				end)

				btn.MouseEnter:Connect(function()
					btn.BorderColor3 = Color3.fromRGB(214, 112, 214)
				end)

				btn.MouseLeave:Connect(function()
					btn.BorderColor3 = Color3.fromRGB(40, 40, 40)
				end)
				
				return btn
			end

			-- 2. Toggle Control
			function group:AddToggle(text, default, callback)
				if type(default) == "function" then
					callback = default
					default = false
				end
				default = default or false

				local toggled = default
				local toggleBtn = Instance.new("TextButton")
				toggleBtn.Size = UDim2.new(1, 0, 0, 16)
				toggleBtn.BackgroundTransparency = 1
				toggleBtn.Text = ""
				toggleBtn.Parent = contentFrame

				local box = Instance.new("Frame")
				box.Size = UDim2.new(0, 10, 0, 10)
				box.Position = UDim2.new(0, 0, 0.5, -5)
				box.BackgroundColor3 = toggled and Color3.fromRGB(214, 112, 214) or Color3.fromRGB(15, 15, 15)
				box.BorderSizePixel = 1
				box.BorderColor3 = Color3.fromRGB(45, 45, 45)
				box.Parent = toggleBtn

				local label = Instance.new("TextLabel")
				label.Size = UDim2.new(1, -16, 1, 0)
				label.Position = UDim2.new(0, 16, 0, 0)
				label.BackgroundTransparency = 1
				label.Text = text
				label.TextColor3 = toggled and Color3.fromRGB(220, 220, 220) or Color3.fromRGB(160, 160, 160)
				label.TextSize = 11
				label.Font = Enum.Font.Code
				label.TextXAlignment = Enum.TextXAlignment.Left
				label.Parent = toggleBtn

				local toggle = {}

				local function set(state)
					toggled = state
					box.BackgroundColor3 = toggled and Color3.fromRGB(214, 112, 214) or Color3.fromRGB(15, 15, 15)
					label.TextColor3 = toggled and Color3.fromRGB(220, 220, 220) or Color3.fromRGB(160, 160, 160)
					pcall(callback, toggled)
				end

				toggleBtn.MouseButton1Click:Connect(function()
					set(not toggled)
				end)

				toggleBtn.MouseEnter:Connect(function()
					box.BorderColor3 = Color3.fromRGB(214, 112, 214)
				end)

				toggleBtn.MouseLeave:Connect(function()
					box.BorderColor3 = Color3.fromRGB(45, 45, 45)
				end)

				function toggle:Set(state)
					set(state)
				end
				
				function toggle:Get()
					return toggled
				end

				return toggle
			end

			-- 3. TextBox Control
			function group:AddTextBox(labelText, defaultText, callback)
				if type(defaultText) == "function" then
					callback = defaultText
					defaultText = ""
				end
				defaultText = defaultText or ""

				local textContainer = Instance.new("Frame")
				textContainer.Size = UDim2.new(1, 0, 0, 36)
				textContainer.BackgroundTransparency = 1
				textContainer.Parent = contentFrame

				local label = Instance.new("TextLabel")
				label.Size = UDim2.new(1, 0, 0, 14)
				label.Position = UDim2.new(0, 0, 0, 0)
				label.BackgroundTransparency = 1
				label.Text = labelText
				label.TextColor3 = Color3.fromRGB(180, 180, 180)
				label.TextSize = 11
				label.Font = Enum.Font.Code
				label.TextXAlignment = Enum.TextXAlignment.Left
				label.Parent = textContainer

				local textBox = Instance.new("TextBox")
				textBox.Size = UDim2.new(1, 0, 0, 18)
				textBox.Position = UDim2.new(0, 0, 0, 16)
				textBox.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
				textBox.BorderSizePixel = 1
				textBox.BorderColor3 = Color3.fromRGB(40, 40, 40)
				textBox.Text = defaultText
				textBox.TextColor3 = Color3.fromRGB(220, 220, 220)
				textBox.PlaceholderText = ""
				textBox.TextSize = 11
				textBox.Font = Enum.Font.Code
				textBox.TextXAlignment = Enum.TextXAlignment.Left
				textBox.ClearTextOnFocus = false
				textBox.Parent = textContainer

				local textPadding = Instance.new("UIPadding")
				textPadding.PaddingLeft = UDim.new(0, 5)
				textPadding.Parent = textBox

				textBox.FocusLost:Connect(function(enterPressed)
					pcall(callback, textBox.Text, enterPressed)
				end)

				textBox.MouseEnter:Connect(function()
					textBox.BorderColor3 = Color3.fromRGB(214, 112, 214)
				end)

				textBox.MouseLeave:Connect(function()
					textBox.BorderColor3 = Color3.fromRGB(40, 40, 40)
				end)

				local txtObj = {}
				function txtObj:Set(val)
					textBox.Text = val
					pcall(callback, val, false)
				end
				function txtObj:Get()
					return textBox.Text
				end

				return txtObj
			end

			-- 4. Slider Control
			function group:AddSlider(labelText, min, max, default, callback)
				min = min or 0
				max = max or 100
				default = default or min

				local sliderContainer = Instance.new("Frame")
				sliderContainer.Size = UDim2.new(1, 0, 0, 28)
				sliderContainer.BackgroundTransparency = 1
				sliderContainer.Parent = contentFrame

				local label = Instance.new("TextLabel")
				label.Size = UDim2.new(0.5, 0, 0, 14)
				label.BackgroundTransparency = 1
				label.Text = labelText
				label.TextColor3 = Color3.fromRGB(180, 180, 180)
				label.TextSize = 11
				label.Font = Enum.Font.Code
				label.TextXAlignment = Enum.TextXAlignment.Left
				label.Parent = sliderContainer

				local valLabel = Instance.new("TextLabel")
				valLabel.Size = UDim2.new(0.5, 0, 0, 14)
				valLabel.Position = UDim2.new(0.5, 0, 0, 0)
				valLabel.BackgroundTransparency = 1
				valLabel.Text = tostring(default)
				valLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
				valLabel.TextSize = 11
				valLabel.Font = Enum.Font.Code
				valLabel.TextXAlignment = Enum.TextXAlignment.Right
				valLabel.Parent = sliderContainer

				local track = Instance.new("TextButton")
				track.Size = UDim2.new(1, 0, 0, 6)
				track.Position = UDim2.new(0, 0, 0, 18)
				track.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
				track.BorderSizePixel = 1
				track.BorderColor3 = Color3.fromRGB(40, 40, 40)
				track.Text = ""
				track.Parent = sliderContainer

				local fill = Instance.new("Frame")
				fill.Size = UDim2.new(math.clamp((default - min) / (max - min), 0, 1), 0, 1, 0)
				fill.BackgroundColor3 = Color3.fromRGB(214, 112, 214) -- Pink accent
				fill.BorderSizePixel = 0
				fill.Parent = track

				local sliderValue = default
				local sliding = false

				local function update(input)
					local percentage = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
					sliderValue = min + (max - min) * percentage
					
					-- Precision adjustment
					if (max - min) > 1 and (max - min) == math.floor(max - min) then
						sliderValue = math.round(sliderValue)
					else
						sliderValue = math.round(sliderValue * 100) / 100
					end
					
					fill.Size = UDim2.new(percentage, 0, 1, 0)
					valLabel.Text = tostring(sliderValue)
					pcall(callback, sliderValue)
				end

				track.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						sliding = true
						update(input)
					end
				end)

				UserInputService.InputChanged:Connect(function(input)
					if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
						update(input)
					end
				end)

				UserInputService.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						sliding = false
					end
				end)

				track.MouseEnter:Connect(function()
					track.BorderColor3 = Color3.fromRGB(214, 112, 214)
				end)

				track.MouseLeave:Connect(function()
					track.BorderColor3 = Color3.fromRGB(40, 40, 40)
				end)

				local sliderObj = {}
				function sliderObj:Set(val)
					sliderValue = math.clamp(val, min, max)
					fill.Size = UDim2.new((sliderValue - min) / (max - min), 0, 1, 0)
					valLabel.Text = tostring(sliderValue)
					pcall(callback, sliderValue)
				end
				function sliderObj:Get()
					return sliderValue
				end

				return sliderObj
			end

			-- 5. Dropdown Control
			function group:AddDropdown(labelText, options, default, callback)
				default = default or options[1]

				local dropdownContainer = Instance.new("Frame")
				dropdownContainer.Size = UDim2.new(1, 0, 0, 36)
				dropdownContainer.BackgroundTransparency = 1
				dropdownContainer.ClipsDescendants = false
				dropdownContainer.Parent = contentFrame

				local label = Instance.new("TextLabel")
				label.Size = UDim2.new(1, 0, 0, 14)
				label.Position = UDim2.new(0, 0, 0, 0)
				label.BackgroundTransparency = 1
				label.Text = labelText
				label.TextColor3 = Color3.fromRGB(180, 180, 180)
				label.TextSize = 11
				label.Font = Enum.Font.Code
				label.TextXAlignment = Enum.TextXAlignment.Left
				label.Parent = dropdownContainer

				local dropBtn = Instance.new("TextButton")
				dropBtn.Size = UDim2.new(1, 0, 0, 18)
				dropBtn.Position = UDim2.new(0, 0, 0, 16)
				dropBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
				dropBtn.BorderSizePixel = 1
				dropBtn.BorderColor3 = Color3.fromRGB(40, 40, 40)
				dropBtn.Text = ""
				dropBtn.Parent = dropdownContainer

				local selectedLabel = Instance.new("TextLabel")
				selectedLabel.Size = UDim2.new(1, -20, 1, 0)
				selectedLabel.Position = UDim2.new(0, 6, 0, 0)
				selectedLabel.BackgroundTransparency = 1
				selectedLabel.Text = tostring(default)
				selectedLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
				selectedLabel.TextSize = 11
				selectedLabel.Font = Enum.Font.Code
				selectedLabel.TextXAlignment = Enum.TextXAlignment.Left
				selectedLabel.Parent = dropBtn

				local arrow = Instance.new("TextLabel")
				arrow.Size = UDim2.new(0, 15, 1, 0)
				arrow.Position = UDim2.new(1, -15, 0, 0)
				arrow.BackgroundTransparency = 1
				arrow.Text = "v"
				arrow.TextColor3 = Color3.fromRGB(140, 140, 140)
				arrow.TextSize = 10
				arrow.Font = Enum.Font.Code
				arrow.TextXAlignment = Enum.TextXAlignment.Center
				arrow.Parent = dropBtn

				-- Dropdown list frame
				local listFrame = Instance.new("ScrollingFrame")
				listFrame.Size = UDim2.new(1, 0, 0, math.min(#options * 18, 100))
				listFrame.Position = UDim2.new(0, 0, 1, 1)
				listFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
				listFrame.BorderSizePixel = 1
				listFrame.BorderColor3 = Color3.fromRGB(40, 40, 40)
				listFrame.CanvasSize = UDim2.new(0, 0, 0, #options * 18)
				listFrame.ScrollBarThickness = 2
				listFrame.ScrollBarImageColor3 = Color3.fromRGB(214, 112, 214)
				listFrame.Visible = false
				listFrame.ZIndex = 100
				listFrame.Parent = dropBtn

				local listLayout = Instance.new("UIListLayout")
				listLayout.SortOrder = Enum.SortOrder.LayoutOrder
				listLayout.Parent = listFrame

				local open = false

				local function toggleDropdown()
					open = not open
					listFrame.Visible = open
					arrow.Text = open and "^" or "v"
				end

				dropBtn.MouseButton1Click:Connect(toggleDropdown)

				dropBtn.MouseEnter:Connect(function()
					dropBtn.BorderColor3 = Color3.fromRGB(214, 112, 214)
				end)

				dropBtn.MouseLeave:Connect(function()
					dropBtn.BorderColor3 = Color3.fromRGB(40, 40, 40)
				end)

				local currentSelection = default

				local function selectItem(item)
					currentSelection = item
					selectedLabel.Text = tostring(item)
					toggleDropdown()
					pcall(callback, item)
				end

				local function rebuildOptions()
					for _, child in pairs(listFrame:GetChildren()) do
						if child:IsA("TextButton") then
							child:Destroy()
						end
					end

					for i, opt in ipairs(options) do
						local optBtn = Instance.new("TextButton")
						optBtn.Size = UDim2.new(1, 0, 0, 18)
						optBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
						optBtn.BorderSizePixel = 0
						optBtn.Text = "  " .. tostring(opt)
						optBtn.TextColor3 = Color3.fromRGB(160, 160, 160)
						optBtn.TextSize = 11
						optBtn.Font = Enum.Font.Code
						optBtn.TextXAlignment = Enum.TextXAlignment.Left
						optBtn.ZIndex = 101
						optBtn.Parent = listFrame

						optBtn.MouseButton1Click:Connect(function()
							selectItem(opt)
						end)

						optBtn.MouseEnter:Connect(function()
							optBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
							optBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
						end)

						optBtn.MouseLeave:Connect(function()
							optBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
							optBtn.TextColor3 = Color3.fromRGB(160, 160, 160)
						end)
					end
					listFrame.CanvasSize = UDim2.new(0, 0, 0, #options * 18)
					listFrame.Size = UDim2.new(1, 0, 0, math.min(#options * 18, 100))
				end

				rebuildOptions()

				local dropObj = {}
				function dropObj:Set(item)
					selectItem(item)
				end
				function dropObj:Get()
					return currentSelection
				end
				function dropObj:Refresh(newOptions, newDefault)
					options = newOptions
					rebuildOptions()
					if newDefault then
						selectItem(newDefault)
					elseif not table.find(options, currentSelection) then
						selectItem(options[1])
					end
				end

				return dropObj
			end

			-- 6. ColorPicker Control
			function group:AddColorPicker(labelText, defaultColor, callback)
				defaultColor = defaultColor or Color3.fromRGB(255, 255, 255)

				local pickerContainer = Instance.new("Frame")
				pickerContainer.Size = UDim2.new(1, 0, 0, 18)
				pickerContainer.BackgroundTransparency = 1
				pickerContainer.ClipsDescendants = false
				pickerContainer.Parent = contentFrame

				local label = Instance.new("TextLabel")
				label.Size = UDim2.new(1, -25, 1, 0)
				label.BackgroundTransparency = 1
				label.Text = labelText
				label.TextColor3 = Color3.fromRGB(180, 180, 180)
				label.TextSize = 11
				label.Font = Enum.Font.Code
				label.TextXAlignment = Enum.TextXAlignment.Left
				label.Parent = pickerContainer

				local colorBoxBtn = Instance.new("TextButton")
				colorBoxBtn.Size = UDim2.new(0, 18, 0, 10)
				colorBoxBtn.Position = UDim2.new(1, -18, 0.5, -5)
				colorBoxBtn.BackgroundColor3 = defaultColor
				colorBoxBtn.BorderSizePixel = 1
				colorBoxBtn.BorderColor3 = Color3.fromRGB(40, 40, 40)
				colorBoxBtn.Text = ""
				colorBoxBtn.Parent = pickerContainer

				-- Pop-up Picker UI with simple RGB Sliders
				local pickerPopup = Instance.new("Frame")
				pickerPopup.Size = UDim2.new(0, 150, 0, 100)
				pickerPopup.Position = UDim2.new(1, -155, 0, 15)
				pickerPopup.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
				pickerPopup.BorderSizePixel = 1
				pickerPopup.BorderColor3 = Color3.fromRGB(45, 45, 45)
				pickerPopup.Visible = false
				pickerPopup.ZIndex = 200
				pickerPopup.Parent = pickerContainer

				-- Small inner border decoration
				local innerPop = Instance.new("Frame")
				innerPop.Size = UDim2.new(1, -4, 1, -4)
				innerPop.Position = UDim2.new(0, 2, 0, 2)
				innerPop.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
				innerPop.BorderSizePixel = 1
				innerPop.BorderColor3 = Color3.fromRGB(30, 30, 30)
				innerPop.ZIndex = 201
				innerPop.Parent = pickerPopup

				local popLayout = Instance.new("UIListLayout")
				popLayout.SortOrder = Enum.SortOrder.LayoutOrder
				popLayout.Padding = UDim.new(0, 4)
				popLayout.Parent = innerPop

				local popPadding = Instance.new("UIPadding")
				popPadding.PaddingLeft = UDim.new(0, 6)
				popPadding.PaddingRight = UDim.new(0, 6)
				popPadding.PaddingTop = UDim.new(0, 6)
				popPadding.Parent = innerPop

				local currentColor = defaultColor

				local function createPickerSlider(colorName, startVal, callbackRGB)
					local sliderFrame = Instance.new("Frame")
					sliderFrame.Size = UDim2.new(1, 0, 0, 22)
					sliderFrame.BackgroundTransparency = 1
					sliderFrame.ZIndex = 202
					sliderFrame.Parent = innerPop

					local colorLabel = Instance.new("TextLabel")
					colorLabel.Size = UDim2.new(0.3, 0, 0, 10)
					colorLabel.BackgroundTransparency = 1
					colorLabel.Text = colorName .. ":"
					colorLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
					colorLabel.TextSize = 10
					colorLabel.Font = Enum.Font.Code
					colorLabel.TextXAlignment = Enum.TextXAlignment.Left
					colorLabel.ZIndex = 203
					colorLabel.Parent = sliderFrame

					local valueLabel = Instance.new("TextLabel")
					valueLabel.Size = UDim2.new(0.7, 0, 0, 10)
					valueLabel.Position = UDim2.new(0.3, 0, 0, 0)
					valueLabel.BackgroundTransparency = 1
					valueLabel.Text = tostring(math.round(startVal * 255))
					valueLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
					valueLabel.TextSize = 10
					valueLabel.Font = Enum.Font.Code
					valueLabel.TextXAlignment = Enum.TextXAlignment.Right
					valueLabel.ZIndex = 203
					valueLabel.Parent = sliderFrame

					local sliderTrack = Instance.new("TextButton")
					sliderTrack.Size = UDim2.new(1, 0, 0, 4)
					sliderTrack.Position = UDim2.new(0, 0, 0, 12)
					sliderTrack.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
					sliderTrack.BorderSizePixel = 1
					sliderTrack.BorderColor3 = Color3.fromRGB(35, 35, 35)
					sliderTrack.Text = ""
					sliderTrack.ZIndex = 203
					sliderTrack.Parent = sliderFrame

					local sliderFill = Instance.new("Frame")
					sliderFill.Size = UDim2.new(startVal, 0, 1, 0)
					sliderFill.BackgroundColor3 = colorName == "R" and Color3.fromRGB(200, 50, 50) or (colorName == "G" and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(50, 50, 200))
					sliderFill.BorderSizePixel = 0
					sliderFill.ZIndex = 204
					sliderFill.Parent = sliderTrack

					local active = false
					local function adjust(input)
						local pct = math.clamp((input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X, 0, 1)
						sliderFill.Size = UDim2.new(pct, 0, 1, 0)
						valueLabel.Text = tostring(math.round(pct * 255))
						callbackRGB(pct)
					end

					sliderTrack.InputBegan:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 then
							active = true
							adjust(input)
						end
					end)

					UserInputService.InputChanged:Connect(function(input)
						if active and input.UserInputType == Enum.UserInputType.MouseMovement then
							adjust(input)
						end
					end)

					UserInputService.InputEnded:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 then
							active = false
						end
					end)
				end

				local function updateColor()
					colorBoxBtn.BackgroundColor3 = currentColor
					pcall(callback, currentColor)
				end

				createPickerSlider("R", currentColor.R, function(pct)
					currentColor = Color3.new(pct, currentColor.G, currentColor.B)
					updateColor()
				end)

				createPickerSlider("G", currentColor.G, function(pct)
					currentColor = Color3.new(currentColor.R, pct, currentColor.B)
					updateColor()
				end)

				createPickerSlider("B", currentColor.B, function(pct)
					currentColor = Color3.new(currentColor.R, currentColor.G, pct)
					updateColor()
				end)

				colorBoxBtn.MouseButton1Click:Connect(function()
					pickerPopup.Visible = not pickerPopup.Visible
				end)

				colorBoxBtn.MouseEnter:Connect(function()
					colorBoxBtn.BorderColor3 = Color3.fromRGB(214, 112, 214)
				end)

				colorBoxBtn.MouseLeave:Connect(function()
					colorBoxBtn.BorderColor3 = Color3.fromRGB(40, 40, 40)
				end)

				local colorPickerObj = {}
				function colorPickerObj:Set(col)
					currentColor = col
					colorBoxBtn.BackgroundColor3 = col
					pcall(callback, col)
				end
				function colorPickerObj:Get()
					return currentColor
				end

				return colorPickerObj
			end

			-- 7. ListBox Control
			function group:AddListBox(height, items, callback)
				height = height or 120
				items = items or {}

				local listboxFrame = Instance.new("ScrollingFrame")
				listboxFrame.Size = UDim2.new(1, 0, 0, height)
				listboxFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
				listboxFrame.BorderSizePixel = 1
				listboxFrame.BorderColor3 = Color3.fromRGB(30, 30, 30)
				listboxFrame.CanvasSize = UDim2.new(0, 0, 0, #items * 20)
				listboxFrame.ScrollBarThickness = 2
				listboxFrame.ScrollBarImageColor3 = Color3.fromRGB(214, 112, 214)
				listboxFrame.Parent = contentFrame

				local listLayout = Instance.new("UIListLayout")
				listLayout.SortOrder = Enum.SortOrder.LayoutOrder
				listLayout.Parent = listboxFrame

				local selectedItem = nil
				local buttons = {}

				local function selectRow(btn, text)
					for _, b in pairs(buttons) do
						b.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
						b.TextColor3 = Color3.fromRGB(160, 160, 160)
					end
					btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
					btn.TextColor3 = Color3.fromRGB(255, 255, 255)
					selectedItem = text
					pcall(callback, text)
				end

				local function populate()
					for _, b in pairs(buttons) do
						b:Destroy()
					end
					buttons = {}

					for i, itName in ipairs(items) do
						local itemBtn = Instance.new("TextButton")
						itemBtn.Size = UDim2.new(1, 0, 0, 20)
						itemBtn.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
						itemBtn.BorderSizePixel = 0
						itemBtn.Text = "  " .. tostring(itName)
						itemBtn.TextColor3 = Color3.fromRGB(160, 160, 160)
						itemBtn.TextSize = 11
						itemBtn.Font = Enum.Font.Code
						itemBtn.TextXAlignment = Enum.TextXAlignment.Left
						itemBtn.Parent = listboxFrame

						itemBtn.MouseButton1Click:Connect(function()
							selectRow(itemBtn, itName)
						end)

						table.insert(buttons, itemBtn)
					end
					listboxFrame.CanvasSize = UDim2.new(0, 0, 0, #items * 20)
				end

				populate()

				local listboxObj = {}
				function listboxObj:SetItems(newItems)
					items = newItems
					selectedItem = nil
					populate()
				end

				function listboxObj:GetSelected()
					return selectedItem
				end

				function listboxObj:Select(name)
					for _, b in pairs(buttons) do
						if string.sub(b.Text, 3) == name then
							selectRow(b, name)
							break
						end
					end
				end

				return listboxObj
			end

			return group
		end

		return column
	end

	-- Backward compatibility fallback: automatically creates a column if AddGroup is called on a tab directly
	function tab:AddGroup(groupName, width)
		local defaultColumn = tab:AddColumn(width or 200)
		return defaultColumn:AddGroup(groupName)
	end

	return tab
end

return Library
