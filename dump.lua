-- [[ SEERE-STYLE UI LIBRARY ]] --
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local Library = {}
Library.__index = Library

function Library.new(titleText)
	local self = setmetatable({}, Library)
	
	self.ScreenGui = Instance.new("ScreenGui")
	self.ScreenGui.Name = "SeereStyleUI"
	self.ScreenGui.ResetOnSpawn = false
	self.ScreenGui.IgnoreGuiInset = true
	
	if syn and syn.protect_gui then
		syn.protect_gui(self.ScreenGui)
		self.ScreenGui.Parent = CoreGui
	elseif gethui then
		self.ScreenGui.Parent = gethui()
	else
		self.ScreenGui.Parent = CoreGui
	end

	self.MainFrame = Instance.new("Frame")
	self.MainFrame.Name = "MainFrame"
	self.MainFrame.Size = UDim2.new(0, 650, 0, 520)
	self.MainFrame.Position = UDim2.new(0.5, -325, 0.5, -260)
	self.MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
	self.MainFrame.BorderSizePixel = 1
	self.MainFrame.BorderColor3 = Color3.fromRGB(40, 40, 40)
	self.MainFrame.Parent = self.ScreenGui

	self.TopAccent = Instance.new("Frame")
	self.TopAccent.Size = UDim2.new(1, 0, 0, 2)
	self.TopAccent.BackgroundColor3 = Color3.fromRGB(214, 112, 214)
	self.TopAccent.BorderSizePixel = 0
	self.TopAccent.Parent = self.MainFrame

	self.TitleBar = Instance.new("TextLabel")
	self.TitleBar.Size = UDim2.new(1, -10, 0, 25)
	self.TitleBar.Position = UDim2.new(0, 8, 0, 4)
	self.TitleBar.BackgroundTransparency = 1
	self.TitleBar.Text = titleText
	self.TitleBar.TextColor3 = Color3.fromRGB(200, 200, 200)
	self.TitleBar.TextSize = 13
	self.TitleBar.Font = Enum.Font.Code
	self.TitleBar.TextXAlignment = Enum.TextXAlignment.Left
	self.TitleBar.Parent = self.MainFrame

	self.TabContainer = Instance.new("Frame")
	self.TabContainer.Size = UDim2.new(1, -16, 0, 28)
	self.TabContainer.Position = UDim2.new(0, 8, 0, 32)
	self.TabContainer.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
	self.TabContainer.BorderSizePixel = 1
	self.TabContainer.BorderColor3 = Color3.fromRGB(35, 35, 35)
	self.TabContainer.Parent = self.MainFrame

	local tabLayout = Instance.new("UIListLayout")
	tabLayout.FillDirection = Enum.FillDirection.Horizontal
	tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
	tabLayout.Parent = self.TabContainer

	self.ContentHolder = Instance.new("Folder")
	self.ContentHolder.Name = "Tabs"
	self.ContentHolder.Parent = self.MainFrame

	local dragging, dragStart, startPos
	self.TitleBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = self.MainFrame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
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

	self.Tabs = {}
	return self
end

function Library:AddTab(name)
	local tab = {}
	
	local tabButton = Instance.new("TextButton")
	tabButton.Size = UDim2.new(0, 85, 1, 0)
	tabButton.BackgroundTransparency = 1
	tabButton.Text = name
	tabButton.TextColor3 = Color3.fromRGB(130, 130, 130)
	tabButton.TextSize = 12
	tabButton.Font = Enum.Font.Code
	tabButton.Parent = self.MainFrame.TabContainer

	local tabPage = Instance.new("ScrollingFrame")
	tabPage.Size = UDim2.new(1, -16, 1, -75)
	tabPage.Position = UDim2.new(0, 8, 0, 68)
	tabPage.BackgroundTransparency = 1
	tabPage.BorderSizePixel = 0
	tabPage.Visible = false
	tabPage.CanvasSize = UDim2.new(0, 0, 0, 0)
	tabPage.ScrollBarThickness = 2
	tabPage.Parent = self.ContentHolder

	local pageLayout = Instance.new("UIListLayout")
	pageLayout.FillDirection = Enum.FillDirection.Horizontal
	pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
	pageLayout.Padding = UDim.new(0, 8)
	pageLayout.Parent = tabPage

	tabButton.MouseButton1Click:Connect(function()
		for _, t in pairs(self.Tabs) do
			t.Page.Visible = false
			t.Button.TextColor3 = Color3.fromRGB(130, 130, 130)
		end
		tabPage.Visible = true
		tabButton.TextColor3 = Color3.fromRGB(255, 110, 215)
	end)

	if #self.Tabs == 0 then
		tabPage.Visible = true
		tabButton.TextColor3 = Color3.fromRGB(255, 110, 215)
	end

	table.insert(self.Tabs, {Button = tabButton, Page = tabPage})

	function tab:AddGroup(groupName, width)
		width = width or 200
		local group = {}

		local groupFrame = Instance.new("Frame")
		groupFrame.Size = UDim2.new(0, width, 1, -10)
		groupFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
		groupFrame.BorderSizePixel = 1
		groupFrame.BorderColor3 = Color3.fromRGB(35, 35, 35)
		groupFrame.Parent = tabPage

		local groupTitle = Instance.new("TextLabel")
		groupTitle.Size = UDim2.new(0, 0, 0, 15)
		groupTitle.Position = UDim2.new(0, 10, 0, -7)
		groupTitle.BackgroundTransparency = 1
		groupTitle.Text = " " .. groupName .. " "
		groupTitle.TextColor3 = Color3.fromRGB(214, 112, 214)
		groupTitle.TextSize = 11
		groupTitle.Font = Enum.Font.Code
		groupTitle.Parent = groupFrame

		local groupLayout = Instance.new("UIListLayout")
		groupLayout.SortOrder = Enum.SortOrder.LayoutOrder
		groupLayout.Padding = UDim.new(0, 6)
		groupLayout.Parent = groupFrame

		local padding = Instance.new("UIPadding")
		padding.PaddingTop = UDim.new(0, 12)
		padding.PaddingLeft = UDim.new(0, 8)
		padding.PaddingRight = UDim.new(0, 8)
		padding.Parent = groupFrame

		function group:AddButton(text, callback)
			local btn = Instance.new("TextButton")
			btn.Size = UDim2.new(1, 0, 0, 22)
			btn.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
			btn.BorderSizePixel = 1
			btn.BorderColor3 = Color3.fromRGB(40, 40, 40)
			btn.Text = text
			btn.TextColor3 = Color3.fromRGB(180, 180, 180)
			btn.TextSize = 11
			btn.Font = Enum.Font.Code
			btn.Parent = groupFrame

			btn.MouseButton1Click:Connect(function()
				pcall(callback)
			end)
		end

		function group:AddToggle(text, default, callback)
			local toggled = default or false
			local toggleBtn = Instance.new("TextButton")
			toggleBtn.Size = UDim2.new(1, 0, 0, 20)
			toggleBtn.BackgroundTransparency = 1
			toggleBtn.Text = ""
			toggleBtn.Parent = groupFrame

			local box = Instance.new("Frame")
			box.Size = UDim2.new(0, 12, 0, 12)
			box.Position = UDim2.new(0, 0, 0.5, -6)
			box.BackgroundColor3 = toggled and Color3.fromRGB(214, 112, 214) or Color3.fromRGB(22, 22, 22)
			box.BorderSizePixel = 1
			box.BorderColor3 = Color3.fromRGB(50, 50, 50)
			box.Parent = toggleBtn

			local label = Instance.new("TextLabel")
			label.Size = UDim2.new(1, -20, 1, 0)
			label.Position = UDim2.new(0, 18, 0, 0)
			label.BackgroundTransparency = 1
			label.Text = text
			label.TextColor3 = Color3.fromRGB(160, 160, 160)
			label.TextSize = 11
			label.Font = Enum.Font.Code
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.Parent = toggleBtn

			toggleBtn.MouseButton1Click:Connect(function()
				toggled = not toggled
				box.BackgroundColor3 = toggled and Color3.fromRGB(214, 112, 214) or Color3.fromRGB(22, 22, 22)
				pcall(callback, toggled)
			end)
		end

		function group:AddTextBox(text, default, callback)
			local container = Instance.new("Frame")
			container.Size = UDim2.new(1, 0, 0, 38)
			container.BackgroundTransparency = 1
			container.Parent = groupFrame

			local label = Instance.new("TextLabel")
			label.Size = UDim2.new(1, 0, 0, 14)
			label.BackgroundTransparency = 1
			label.Text = text
			label.TextColor3 = Color3.fromRGB(160, 160, 160)
			label.TextSize = 11
			label.Font = Enum.Font.Code
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.Parent = container

			local box = Instance.new("TextBox")
			box.Size = UDim2.new(1, 0, 0, 20)
			box.Position = UDim2.new(0, 0, 0, 16)
			box.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
			box.BorderSizePixel = 1
			box.BorderColor3 = Color3.fromRGB(40, 40, 40)
			box.Text = default or ""
			box.TextColor3 = Color3.fromRGB(200, 200, 200)
			box.TextSize = 11
			box.Font = Enum.Font.Code
			box.ClearTextOnFocus = false
			box.Parent = container

			box.FocusLost:Connect(function(enterPressed)
				pcall(callback, box.Text)
			end)
		end

		function group:AddListbox(items, callback)
			local listFrame = Instance.new("ScrollingFrame")
			listFrame.Size = UDim2.new(1, 0, 0, 110)
			listFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
			listFrame.BorderSizePixel = 1
			listFrame.BorderColor3 = Color3.fromRGB(40, 40, 40)
			listFrame.CanvasSize = UDim2.new(0, 0, 0, #items * 18)
			listFrame.ScrollBarThickness = 2
			listFrame.Parent = groupFrame

			local listLayout = Instance.new("UIListLayout")
			listLayout.SortOrder = Enum.SortOrder.LayoutOrder
			listLayout.Parent = listFrame

			for _, item in ipairs(items) do
				local itemBtn = Instance.new("TextButton")
				itemBtn.Size = UDim2.new(1, 0, 0, 18)
				itemBtn.BackgroundTransparency = 1
				itemBtn.Text = " " .. item
				itemBtn.TextColor3 = Color3.fromRGB(160, 160, 160)
				itemBtn.TextSize = 11
				itemBtn.Font = Enum.Font.Code
				itemBtn.TextXAlignment = Enum.TextXAlignment.Left
				itemBtn.Parent = listFrame

				itemBtn.MouseButton1Click:Connect(function()
					pcall(callback, item)
				end)
			end
		end

		return group
	end

	return tab
end

return Library
