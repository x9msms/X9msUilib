local DEFAULT_THEME_COLOR = Color3.fromRGB(255, 59, 59) -- สีธีมเริ่มต้น (สีแดง)

local library = {
    toggled = true;
    binding = false;
    binds = {};

    themeColor = DEFAULT_THEME_COLOR;
    themeElements = {};
}

-- ธีมแบบไล่สี: แต้มสีจะไล่จากโทนอ่อน -> สีหลัก -> โทนเข้ม (แนวทแยง 45 องศา)
local function buildThemeGradient(base)
    local light = base:Lerp(Color3.new(1, 1, 1), 0.35)
    local dark = base:Lerp(Color3.new(0, 0, 0), 0.55)

    return ColorSequence.new({
        ColorSequenceKeypoint.new(0, light);
        ColorSequenceKeypoint.new(0.5, base);
        ColorSequenceKeypoint.new(1, dark);
    })
end

local function applyTheme(obj, prop)
    -- สีฐานขาว เพื่อให้ UIGradient แสดงสีได้เต็มที่ (ไม่ทับซ้อนกับสีเดิม)
    obj[prop] = Color3.new(1, 1, 1)

    local gradient = obj:FindFirstChild("themeGradient")
    if not gradient then
        gradient = Instance.new("UIGradient")
        gradient.Name = "themeGradient"
        gradient.Rotation = 45
        gradient.Parent = obj
    end

    gradient.Color = buildThemeGradient(library.themeColor)
end

local function registerTheme(obj, prop)
    table.insert(library.themeElements, {obj = obj, prop = prop})
    applyTheme(obj, prop)
end

local function createPrimaryCheck(size, position, zIndex)
    local check = Instance.new("Frame")
    check.Name = "toggle"
    check.Size = size
    check.Position = position
    registerTheme(check, "BackgroundColor3")
    check.BorderSizePixel = 0
    check.ClipsDescendants = true
    check.ZIndex = zIndex or 1

    local corner = Instance.new("UICorner", check)
    corner.CornerRadius = UDim.new(0, 4)

    local mark = Instance.new("ImageLabel", check)
    mark.Name = "check"
    mark.Size = UDim2.fromScale(0.9, 0.9)
    mark.Position = UDim2.fromScale(0.05, 0.05)
    mark.BackgroundTransparency = 1
    mark.Image = "rbxassetid://90637392710152"
    mark.ImageColor3 = Color3.fromRGB(255, 255, 255)
    mark.ScaleType = Enum.ScaleType.Fit
    mark.ZIndex = check.ZIndex + 1

    return check
end

-- สวิตช์แบบ pill: แถบพื้นเข้ม + แถบแดงไล่สีเลื่อน + ปุ่มกลมขาว (แบบ UI ทั่วไป)
local function createSwitch(initialOn, zIndex)
    local z = zIndex or 1

    local track = Instance.new("Frame")
    track.Name = "toggle"
    track.Size = UDim2.new(1, 0, 1, 0)
    track.Position = UDim2.new(0, 0, 0, 0)
    track.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
    track.BorderSizePixel = 0
    track.ClipsDescendants = true
    track.ZIndex = z

    local trackCorner = Instance.new("UICorner", track)
    trackCorner.CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame", track)
    fill.Name = "fill"
    fill.Size = (initialOn and UDim2.new(1, 0, 1, 0)) or UDim2.new(0, 0, 0, 0)
    fill.Position = UDim2.new(0, 0, 0, 0)
    fill.BorderSizePixel = 0
    fill.ZIndex = z + 1
    registerTheme(fill, "BackgroundColor3")

    local fillCorner = Instance.new("UICorner", fill)
    fillCorner.CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame", track)
    knob.Name = "knob"
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Size = UDim2.new(0.42, 0, 0.72, 0)
    knob.Position = (initialOn and UDim2.new(0.72, 0, 0.5, 0)) or UDim2.new(0.28, 0, 0.5, 0)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.ZIndex = z + 2

    local knobCorner = Instance.new("UICorner", knob)
    knobCorner.CornerRadius = UDim.new(1, 0)

    return track
end

-- อัปเดตภาพสวิตช์/เช็คบ็อกซ์ตามสถานะ (รองรับทั้ง 2 สไตล์)
local function setToggleVisual(toggleObj, on)
    local fill = toggleObj:FindFirstChild("fill")
    local knob = toggleObj:FindFirstChild("knob")

    if fill and knob then
        fill:TweenSize((on and UDim2.new(1, 0, 1, 0)) or UDim2.new(0, 0, 0, 0), "Out", "Quad", 0.18, true)
        knob:TweenPosition((on and UDim2.new(0.72, 0, 0.5, 0)) or UDim2.new(0.28, 0, 0.5, 0), "Out", "Quad", 0.18, true)
    else
        toggleObj:TweenSizeAndPosition((on and UDim2.new(1, 0, 1, 0)) or UDim2.new(0, 0, 0, 0), (on and UDim2.new(0, 0, 0, 0)) or UDim2.new(0.5, 0, 0.5, 0), (on and 'Out') or 'In', (on and 'Elastic') or 'Quad', (on and 0.75) or 0.15, true)
    end
end

--==================== ระบบไอค่อน (based on Footagesus/Icons — MIT License) ====================
-- https://github.com/Footagesus/Icons
local icons = (function()
--============================================================
-- icons.lua — ระบบไอค่อนสำหรับ X9msUilib
-- Based on Footagesus/Icons (MIT License)
-- https://github.com/Footagesus/Icons
--
-- API (compatible with Footagesus Icons V2):
--   icons.SetIconsType("lucide")                 -- ตั้ง pack เริ่มต้น (lucide, solar, craft, geist, sfsymbols, gravity)
--   icons.GetIcon("house")                       -- -> "rbxassetid://..." (lucide)
--   icons.GetIcon("sfsymbols:HouseFill")         -- ระบุ pack:name
--   icons.Icon2("geist:accessibility-unread")    -- -> { image, {ImageRectSize, ImageRectPosition, Parts} }
--   icons.Image({ Icon = "house", Size = UDim2.fromOffset(24,24), Colors = {Color3} })
--                                                -- -> { IconFrame = ImageLabel } (รองรับหลายสี/Parts)
--   icons.AddIcons("mypack", { iconname = "rbxassetid://..." })  -- เพิ่ม pack ของตัวเอง
--============================================================

local cloneref = (cloneref or clonereference or function(instance)
	return instance
end)

local HttpService = cloneref(game:GetService("HttpService"))
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))

local BASE_URL = "https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main"

local function IsExploit()
	return request and true or false
end

local function Get(url)
	if IsExploit() then
		return game:HttpGet(url)
	end

	local Success, Result = pcall(function()
		return HttpService:GetAsync(url)
	end)
	if Success then
		return Result
	end

	return ReplicatedStorage:WaitForChild("Request", 9999):InvokeServer({ Url = url })
end

local function Loadstring(src)
	if not IsExploit() and ReplicatedStorage:FindFirstChild("Loadstring") then
		return function()
			return ReplicatedStorage:WaitForChild("Loadstring", 9999):InvokeServer(src)
		end
	end

	return loadstring(src)
end

local PACKS = { "lucide", "solar", "craft", "geist", "sfsymbols", "gravity" }

local IconModule = {
	IconsType = "lucide",
	Packs = PACKS,

	New = nil,
	IconThemeTag = nil,

	Icons = {}, -- [packName] = pack data (โหลดแบบ lazy)
}

local function parseIconString(iconString)
	if type(iconString) == "string" then
		local splitIndex = iconString:find(":", 1, true)
		if splitIndex then
			return iconString:sub(1, splitIndex - 1), iconString:sub(splitIndex + 1)
		end
	end
	return nil, iconString
end

-- โหลดข้อมูล pack จาก Footagesus/Icons (ครั้งแรกที่ใช้เท่านั้น แล้วเก็บ cache ไว้)
local function loadPack(packName)
	local cached = IconModule.Icons[packName]
	if cached ~= nil then
		return cached or nil
	end

	local ok, data = pcall(function()
		return Loadstring(Get(("%s/%s/dist/Icons.lua"):format(BASE_URL, packName)))()
	end)

	if ok and type(data) == "table" then
		IconModule.Icons[packName] = data
		return data
	end

	warn("[icons] failed to load pack: " .. tostring(packName))
	IconModule.Icons[packName] = false
	return nil
end

function IconModule.SetIconsType(iconType)
	IconModule.IconsType = iconType
end

function IconModule.Init(New, IconThemeTag)
	IconModule.New = New
	IconModule.IconThemeTag = IconThemeTag

	return IconModule
end

function IconModule.Icon(Icon, Type, DefaultFormat)
	DefaultFormat = DefaultFormat ~= false
	local iconType, iconName = parseIconString(Icon)

	local targetType = iconType or Type or IconModule.IconsType
	local targetName = iconName

	local iconSet = IconModule.Icons[targetType]
	if iconSet == nil then
		iconSet = loadPack(targetType)
	end
	if not iconSet then
		return nil
	end

	if iconSet.Icons and iconSet.Icons[targetName] then
		return {
			iconSet.Spritesheets[tostring(iconSet.Icons[targetName].Image)],
			iconSet.Icons[targetName],
		}
	elseif type(iconSet[targetName]) == "string" and string.find(iconSet[targetName], "rbxassetid://") then
		return DefaultFormat
			and {
				iconSet[targetName],
				{ ImageRectSize = Vector2.new(0, 0), ImageRectPosition = Vector2.new(0, 0) },
			}
			or iconSet[targetName]
	end

	return nil
end

function IconModule.GetIcon(Icon, Type)
	return IconModule.Icon(Icon, Type, false)
end

function IconModule.Icon2(Icon, Type)
	return IconModule.Icon(Icon, Type, true)
end

function IconModule.AddIcons(packName, iconsData)
	if type(packName) ~= "string" or type(iconsData) ~= "table" then
		error("AddIcons: packName must be string, iconsData must be table")
		return
	end

	if not IconModule.Icons[packName] or IconModule.Icons[packName] == false then
		IconModule.Icons[packName] = {
			Icons = {},
			Spritesheets = {},
		}
	end

	for iconName, iconValue in pairs(iconsData) do
		if type(iconValue) == "number" or (type(iconValue) == "string" and iconValue:match("^rbxassetid://")) then
			local imageId = iconValue
			if type(iconValue) == "number" then
				imageId = "rbxassetid://" .. tostring(iconValue)
			end

			IconModule.Icons[packName].Icons[iconName] = {
				Image = imageId,
				ImageRectSize = Vector2.new(0, 0),
				ImageRectPosition = Vector2.new(0, 0),
				Parts = nil,
			}
			IconModule.Icons[packName].Spritesheets[imageId] = imageId
		elseif type(iconValue) == "table" and iconValue.Image and iconValue.ImageRectSize and iconValue.ImageRectPosition then
			local imageId = iconValue.Image
			if type(imageId) == "number" then
				imageId = "rbxassetid://" .. tostring(imageId)
			end

			IconModule.Icons[packName].Icons[iconName] = {
				Image = imageId,
				ImageRectSize = iconValue.ImageRectSize,
				ImageRectPosition = iconValue.ImageRectPosition,
				Parts = iconValue.Parts,
			}

			if not IconModule.Icons[packName].Spritesheets[imageId] then
				IconModule.Icons[packName].Spritesheets[imageId] = imageId
			end
		else
			warn("AddIcons: unsupported data type for icon '" .. tostring(iconName) .. "': " .. type(iconValue))
		end
	end
end

function IconModule.Image(IconConfig)
	local Icon = {
		Icon = IconConfig.Icon or nil,
		Type = IconConfig.Type,
		Colors = IconConfig.Colors or { (IconModule.IconThemeTag or Color3.new(1, 1, 1)), Color3.new(1, 1, 1) },
		Size = IconConfig.Size or UDim2.new(0, 24, 0, 24),

		IconFrame = nil,
	}

	local Colors = {}

	for i, color in next, Icon.Colors do
		Colors[i] = {
			ThemeTag = typeof(color) == "string" and color,
			Color = typeof(color) == "Color3" and color,
		}
	end

	local IconLabel = IconModule.Icon2(Icon.Icon, Icon.Type)

	local IconFrame = Instance.new("ImageLabel")
	IconFrame.Size = Icon.Size
	IconFrame.BackgroundTransparency = 1

	Icon.IconFrame = IconFrame

	if not IconLabel then
		warn("[icons] icon not found: " .. tostring(Icon.Icon))
		return Icon
	end

	IconFrame.ImageColor3 = Colors[1] and Colors[1].Color or Color3.new(1, 1, 1)
	IconFrame.Image = IconLabel[1]
	IconFrame.ImageRectSize = IconLabel[2].ImageRectSize
	IconFrame.ImageRectOffset = IconLabel[2].ImageRectPosition

	if IconLabel[2].Parts then
		for i, part in next, IconLabel[2].Parts do
			local IconPartLabel = IconModule.Icon2(part, Icon.Type)
			if IconPartLabel then
				local IconPart = Instance.new("ImageLabel")
				IconPart.Size = UDim2.new(1, 0, 1, 0)
				IconPart.BackgroundTransparency = 1
				IconPart.ImageColor3 = Colors[1 + i] and Colors[1 + i].Color or Color3.new(1, 1, 1)
				IconPart.Image = IconPartLabel[1]
				IconPart.ImageRectSize = IconPartLabel[2].ImageRectSize
				IconPart.ImageRectOffset = IconPartLabel[2].ImageRectPosition
				IconPart.Parent = IconFrame
			end
		end
	end

	return Icon
end

return IconModule

end)()

library.icons = icons

local function applyIcon(imageLabel, icon, iconType)
    if not icon or not imageLabel then return end

    local ok, data = pcall(function()
        return icons.Icon2(icon, iconType)
    end)

    if ok and data then
        imageLabel.Image = data[1]

        local info = data[2]
        if info and info.ImageRectSize and info.ImageRectSize.X > 0 then
            imageLabel.ImageRectSize = info.ImageRectSize
            imageLabel.ImageRectOffset = info.ImageRectPosition or Vector2.new(0, 0)
        end
    else
        warn("[ui] icon not found: " .. tostring(icon))
    end
end

if getgenv and getgenv().ui then
    getgenv().ui:Destroy()
end

local HttpService = game:GetService("HttpService")
do
    local contentProvider = game:GetService("ContentProvider")
    local userInputService = game:GetService("UserInputService")
    local runService = game:GetService("RunService")
    local guiService = game:GetService("GuiService")

    contentProvider:PreloadAsync({
		"rbxassetid://90637392710152";
		"rbxassetid://5882688826";
		"rbxassetid://4896743658";
		"rbxassetid://4894670678";
		"rbxassetid://4892761119";
        "rbxassetid://4892463081";
    })


    local tabList = {}
    local dropList = {}
    local main = {}
    main.__index = main
    local tabs = {}
    tabs.__index = tabs
    local labels = {}
    labels.__index = labels

    local function isPrimaryInput(input)
        return input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch
    end

    -- วิธีคลิกแบบ WindUI (ตาม src): MouseButton1Click บนปุ่ม ทับด้วยตัวรับทัชเต็มพื้นที่
    -- ยิงคู่ (คลิก + แตะลง) และกันยิงซ้ำใน 0.3 วิ → แตะตรง ๆ ติดทุกอุปกรณ์ ไม่ต้องลาก
    local lastPress = 0

    local function firePress(callback)
        local now = tick()
        if now - lastPress < 0.3 then return end
        lastPress = now
        callback()
    end

    local function onPress(object, callback)
        local catcher = Instance.new("TextButton")
        catcher.Name = "tapCatcher"
        catcher.Size = UDim2.new(1, 0, 1, 0)
        catcher.Position = UDim2.new(0, 0, 0, 0)
        catcher.BackgroundTransparency = 1
        catcher.Text = ""
        catcher.AutoButtonColor = false
        catcher.BorderSizePixel = 0
        catcher.ZIndex = 5
        catcher.Parent = object

        catcher.MouseButton1Click:Connect(function()
            firePress(callback)
        end)

        catcher.InputBegan:Connect(function(input)
            if not isPrimaryInput(input) then return end
            firePress(callback)
        end)

        if object:IsA("GuiButton") then
            object.MouseButton1Click:Connect(function()
                firePress(callback)
            end)
        end
    end

    local function toGuiPosition(screenPos)
        if typeof(screenPos) == "Vector3" then
            screenPos = Vector2.new(screenPos.X, screenPos.Y)
        end

        -- IgnoreGuiInset = true (แบบ WindUI): พิกัดจอจริง = พิกัด GUI ตรง ๆ ไม่ต้องหัก inset
        return screenPos
    end

    local function isInGui(frame, screenPos)
        if not frame then return end

        local mouse = toGuiPosition(screenPos or userInputService:GetMouseLocation())

        local x1, x2 = frame.AbsolutePosition.X, frame.AbsolutePosition.X + frame.AbsoluteSize.X
        local y1, y2 = frame.AbsolutePosition.Y, frame.AbsolutePosition.Y + frame.AbsoluteSize.Y

        return (mouse.X >= x1 and mouse.X <= x2) and (mouse.Y >= y1 and mouse.Y <= y2)
    end



    -- แตะ/คลิก: ใช้ InputBegan + isPrimaryInput ทันที (รองรับทั้งเมาส์และนิ้ว)

    local function setScrollingEnabled(frame, enabled)
        local p = frame.Parent
        while p and not p:IsA("ScrollingFrame") do
            p = p.Parent
        end

        if p then
            p.ScrollingEnabled = enabled
        end
    end

    function main:section(name)
        return library:createElement("TextLabel", {
            Name = "section";
            Size = UDim2.new(1, 0, 0, 24);
            LayoutOrder = self:getOrder();
            BackgroundTransparency = 1;
            Text = name;
            TextColor3 = Color3.fromRGB(150, 150, 150);
            TextXAlignment = Enum.TextXAlignment.Left;
            Font = Enum.Font.GothamSemibold;
            TextSize = 11;
            ZIndex = 3;
            Parent = self.container;
        })
    end

    function main:resize()
        -- หน้าต่างขนาดคงที่แล้ว (ปรับขนาดได้จากมุมล่างขวา) ไม่ย่อ/ขยายตามเนื้อหา
    end

    function main:getOrder()
        local count = 0

        for i,v in pairs(self.container:GetChildren()) do
            if not v:IsA("UIListLayout") then
                count = count + 1
            end
        end

        return count
    end

    function tabs:getOrder()
        local count = 0

        for i,v in pairs(self.container:GetChildren()) do
            if not v:IsA("UIListLayout") then
                count = count + 1
            end
        end

        return count
    end

    local function CreateDrag(gui)
        local dragging = false
        local dragInput
        local dragStart
        local startPos

        -- drag starts only from the title bar; input on it propagates up from its children,
        -- and no coordinate math is needed (works for mouse, touch and any DPI/inset)
        gui.frame.topBorder.InputBegan:Connect(function(input)
            if dragging then return end
            if not isPrimaryInput(input) then return end

            dragging = true
            dragInput = input
            dragStart = input.Position
            startPos = gui.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End or input.UserInputState == Enum.UserInputState.Cancel then
                    dragging = false
                    dragInput = nil
                end
            end)
        end)

        userInputService.InputChanged:Connect(function(input)
            if not dragging then return end

            local isDragMove = (input == dragInput)
                or (input.UserInputType == Enum.UserInputType.MouseMovement)
                or (dragInput and dragInput.UserInputType == Enum.UserInputType.Touch and input.UserInputType == Enum.UserInputType.Touch)

            if not isDragMove then return end

            local delta = input.Position - dragStart
            gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end)
    end

    local RESIZE_MIN_X, RESIZE_MIN_Y = 390, 220

    local function CreateResize(gui)
        local resizing = false
        local resizeInput
        local resizeStart
        local startSize

        -- จุดปรับขนาดที่มุมล่างขวา (ลากได้ทั้งเมาส์และนิ้ว)
        local handle = library:createElement("ImageLabel", {
            Name = "resizeHandle";
            Size = UDim2.new(0, 24, 0, 24);
            Position = UDim2.new(1, -24, 1, -24);
            BackgroundTransparency = 1;
            Image = "rbxassetid://4894670678";
            ImageColor3 = Color3.fromRGB(60, 60, 60);
            ImageTransparency = 0.5;
            ScaleType = Enum.ScaleType.Slice;
            SliceCenter = Rect.new(5, 5, 434, 297);
            ZIndex = 6;
            Parent = gui;
        })

        for i = 0, 2 do
            library:createElement("Frame", {
                Name = "grip";
                Size = UDim2.new(0, 2, 0, 8);
                Position = UDim2.new(0, 6 + i * 5, 0, 12 - i * 5);
                Rotation = 45;
                BorderSizePixel = 0;
                BackgroundColor3 = Color3.fromRGB(150, 150, 150);
                ZIndex = 7;
                Parent = handle;
            })
        end

        handle.InputBegan:Connect(function(input)
            if resizing then return end
            if not isPrimaryInput(input) then return end

            resizing = true
            resizeInput = input
            resizeStart = input.Position
            startSize = gui.AbsoluteSize

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End or input.UserInputState == Enum.UserInputState.Cancel then
                    resizing = false
                    resizeInput = nil
                end
            end)
        end)

        userInputService.InputChanged:Connect(function(input)
            if not resizing then return end

            local isResizeMove = (input == resizeInput)
                or (input.UserInputType == Enum.UserInputType.MouseMovement)
                or (resizeInput and resizeInput.UserInputType == Enum.UserInputType.Touch and input.UserInputType == Enum.UserInputType.Touch)

            if not isResizeMove then return end

            local delta = input.Position - resizeStart

            gui.Size = UDim2.new(
                0, math.max(RESIZE_MIN_X, startSize.X + delta.X),
                0, math.max(RESIZE_MIN_Y, startSize.Y + delta.Y)
            )
        end)
    end


    function main:window(name, icon, subtitle)
        local newWindow = library:createElement("ImageLabel", {
            Name = name;
            Size = UDim2.new(0, 392, 0, 380);
            Position = UDim2.new(0, 10, 0, 40);
            Image = "rbxassetid://4894670678";
            ImageColor3 = Color3.fromRGB(0, 0, 0);
            ImageTransparency = 0.5;
            ScaleType = Enum.ScaleType.Slice;
            SliceCenter = Rect.new(5, 5, 434, 297);
            BackgroundTransparency = 1;
            ClipsDescendants = true;
            library:createElement("ImageLabel", {
                Name = "frame";
                Size = UDim2.new(1, -2, 1, -2);
                Position = UDim2.new(0, 1, 0, 1);
                Image = "rbxassetid://4894670678";
                ImageColor3 = Color3.fromRGB(0, 0, 0);
                ScaleType = Enum.ScaleType.Slice;
                SliceCenter = Rect.new(5, 5, 454, 297);
                BackgroundTransparency = 1;
                library:createElement("ImageLabel", {
                    Name = "topBorder";
                    Size = UDim2.new(1, 0, 0, 35);
                    Position = UDim2.new(0, 0, 0, 0);
                    Image = "rbxassetid://4892463081";
                    ImageColor3 = Color3.fromRGB(16, 16, 16);
                    ScaleType = Enum.ScaleType.Slice;
                    SliceCenter = Rect.new(5, 5, 434, 125);
                    BackgroundTransparency = 1;
                    library:createElement("TextLabel", {
                        Name = "title";
                        Size = UDim2.new(0, 180, 0, 35);
                        Position = UDim2.new(0, 15, 0, 0);
                        Text = name;
                        TextWrapped = true;
                        TextXAlignment = Enum.TextXAlignment.Left;
                        TextColor3 = Color3.fromRGB(250, 250, 250);
                        Font = Enum.Font.GothamSemibold;
                        TextSize = 16;
                        BackgroundTransparency = 1;
                    });
                    library:createElement("Frame", {
                        Name = "line";
                        Size = UDim2.new(1, 0, 0, 2);
                        Position = UDim2.new(0, 0, 1, -2);
                        BorderSizePixel = 0;
                        BackgroundColor3 = Color3.fromRGB(28, 28, 28);
                    })
                })
            });
            library:createElement("ImageLabel", {
                Name = "containerBorder";
                Size = UDim2.new(0, 160, 1, -55);
                Position = UDim2.new(0, 10, 0, 45);
                Image = "rbxassetid://4894670678";
                ImageColor3 = Color3.fromRGB(0, 0, 0);
                ImageTransparency = 0;
                ScaleType = Enum.ScaleType.Slice;
                SliceCenter = Rect.new(5, 5, 434, 297);
                BackgroundTransparency = 1;
                ZIndex = 3;
                library:createElement("ImageLabel", {
                    Name = "Container";
                    Size = UDim2.new(1, -2, 1, -2);
                    Position = UDim2.new(0, 1, 0, 1);
                    Image = "rbxassetid://4894670678";
                    ImageColor3 = Color3.fromRGB(16, 16, 16);
                    ScaleType = Enum.ScaleType.Slice;
                    SliceCenter = Rect.new(5, 5, 434, 297);
                    BackgroundTransparency = 1;
                    ClipsDescendants = true;
                    ZIndex = 3;
                    library:createElement("UIListLayout", {
                        SortOrder = 2;
                        Name = "list";
                    })
                });
            });
            Parent = library.container;
        })
        if icon then
            local iconLabel = library:createElement("ImageLabel", {
                Name = "icon";
                Size = UDim2.new(0, 18, 0, 18);
                Position = UDim2.new(0, 14, 0, 8);
                BackgroundTransparency = 1;
                ImageColor3 = "@theme";
                ZIndex = 3;
                Parent = newWindow.frame.topBorder;
            })
            applyIcon(iconLabel, icon)
            newWindow.frame.topBorder.title.Position = UDim2.new(0, 38, 0, 0)
            newWindow.frame.topBorder.title.Size = UDim2.new(0, 142, 0, 35)
        end

        CreateDrag(newWindow)
        CreateResize(newWindow)

        if subtitle then
            local topTitle = newWindow.frame.topBorder.title
            topTitle.Size = UDim2.new(0, 180, 0, 18)
            topTitle.Position = UDim2.new(0, 15, 0, 1)

            library:createElement("TextLabel", {
                Name = "subtitle";
                Size = UDim2.new(0, 180, 0, 14);
                Position = UDim2.new(0, 15, 0, 19);
                Text = subtitle;
                TextColor3 = Color3.fromRGB(150, 150, 150);
                TextWrapped = true;
                TextXAlignment = Enum.TextXAlignment.Left;
                Font = Enum.Font.GothamSemibold;
                TextSize = 10;
                BackgroundTransparency = 1;
                Parent = newWindow.frame.topBorder;
            })
        end

        local window = setmetatable({
            toggled = true;
            object = newWindow;
            container = newWindow.containerBorder.Container;
        }, main)

        return window
    end

    function main:newTab(name, icon)
        local newTab = library:createElement("Frame", {
            Name = name;
            Size = UDim2.new(1, 0, 0, 35);
            BackgroundTransparency = 1;
            LayoutOrder = self:getOrder();
            ZIndex = 3;
            library:createElement("TextButton", {
                Name = "button";
                Size = UDim2.new(1, 0, 0, 25);
                Position = UDim2.new(0, 0, 0, 5);
                Text = "";
                AutoButtonColor = false;
                BackgroundTransparency = 1;
                ZIndex = 3;
                library:createElement("TextLabel", {
                    Name = "title";
                    Size = UDim2.new(1, -35, 1, 0);
                    Position = UDim2.new(0, 35, 0, 0);
                    BackgroundTransparency = 1;
                    Text = name;
                    TextColor3 = Color3.fromRGB(250, 250, 250);
                    TextXAlignment = Enum.TextXAlignment.Left;
                    Font = Enum.Font.GothamSemibold;
                    TextSize = 12;
                    ZIndex = 3;
                });
                library:createElement("ImageLabel", {
                    Name = "toggleOutline";
                    Size = UDim2.new(0, 20, 0, 20);
                    Position = UDim2.new(0, 5, 0, 5/2);
                    Image = "rbxassetid://4892761119";
                    ScaleType = Enum.ScaleType.Slice;
                    SliceCenter = Rect.new(6, 6, 14, 14);
                    BackgroundTransparency = 1;
                    ZIndex = 3;
                    createPrimaryCheck(
                        UDim2.new(0, 0, 0, 0),
                        UDim2.new(0.5, 0, 0.5, 0),
                        3
                    )
                })
            });
            Parent = self.container;
        })

        if icon then
            local iconLabel = library:createElement("ImageLabel", {
                Name = "icon";
                Size = UDim2.new(0, 16, 0, 16);
                Position = UDim2.new(0, 32, 0, 4);
                BackgroundTransparency = 1;
                ImageColor3 = "@theme";
                ZIndex = 3;
                Parent = newTab.button;
            })
            applyIcon(iconLabel, icon)
            newTab.button.title.Position = UDim2.new(0, 54, 0, 0)
            newTab.button.title.Size = UDim2.new(1, -64, 1, 0)
        end

        local container = library:createElement("ScrollingFrame", {
            Name = "container";
            Size = UDim2.new(1, -190, 1, -57);
            Position = UDim2.new(0, 10, 0, 47);
            BorderSizePixel = 0;
            BackgroundTransparency = 1;
            ZIndex = 2;
            Visible = false;
            ClipsDescendants = true;
            ScrollingDirection = Enum.ScrollingDirection.Y;
            ScrollBarThickness = 3;
            ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255);
            ScrollBarImageTransparency = 0.7;
            CanvasSize = UDim2.new(0, 0, 0, 0);
            library:createElement("UIListLayout", {
                Name = "list";
                SortOrder = 2;
            });
            Parent = self.object;
        })

        -- เนื้อหาในแท็บเลื่อนได้เองตามความสูง (หน้าต่างขนาดคงที่)
        local contentLayout = container.list
        contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            container.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 5)
        end)

        local tab = setmetatable({
            toggled = false;
            parentObject = self.object;
            parentContainer = self.container;
            object = newTab;
            container = container;
            check = newTab.button.toggleOutline.toggle;
            flags = {};
            spFuncs = {};
        }, tabs)
        table.insert(tabList, tab)

        local containerSizeY = 0

        function tab.spFuncs:SimClck()
            do
                tab.toggled = not tab.toggled

                for i,v in pairs(dropList) do
                    if v.toggled then
                    
                        v.toggled = false
                        v.object.ZIndex = 1
                        if not v.usesToggles then
                            v.label.TextTransparency = 0
                            v.label.Text = v.l[v.f]
                        end

                        v.container.Parent.Parent.Parent:TweenSize(UDim2.new(1, 0, 0, 0), "In", "Quad", 0.15, true)

                        v.arrow.Rotation = 0
                        wait(0.15)

                    end
                end
                
                for i,v in pairs(tabList) do
                    if v ~= tab and v.toggled then
                        spawn(function()
                            v.toggled = false
                            v.check:TweenSizeAndPosition(UDim2.new(0, 0, 0, 0), UDim2.new(0.5, 0, 0.5, 0), "In", "Quad", 0.15, true)
                            v.container:TweenPosition(UDim2.new(0, 10, 0, 47), "In", "Quad", 0.15, true)
                            wait(0.15)

                            v.container.Visible = false
                        end)
                    end
                end

                if tab.toggled then
                    tab.check:TweenSizeAndPosition(UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), "Out", "Elastic", 0.75, true)
                    spawn(function()
                        wait(0.15)

                        if tab.toggled then

                            tab.container.Visible = true
                            tab.container:TweenPosition(UDim2.new(0, 180, 0, 47), "Out", "Quad", 0.15, true)

                        end
                    end)
                else
                    tab.check:TweenSizeAndPosition(UDim2.new(0, 0, 0, 0), UDim2.new(0.5, 0, 0.5, 0), "In", "Quad", 0.15, true)
                    tab.container:TweenPosition(UDim2.new(0, 10, 0, 47), "In", "Quad", 0.15, true)
                    spawn(function()
                        wait(0.15)

                        if not tab.toggled then

                            tab.container.Visible = false

                        end
                    end)
                end
            end
        end

        -- ตัวรับทัชทับปุ่มแท็บเต็มพื้นที่: กดตรง ๆ ติดทันที เหมือน toggle
        onPress(newTab.button, function()
            spawn(function()
                tab.spFuncs:SimClck()
            end)
        end)

        self:resize()
        

        return tab
    end

    function tabs:label(name, text)
        local newLabel = library:createElement("Frame", {
            Name = name;
            Size = UDim2.new(0, 200, 0, 35);
            BackgroundTransparency = 1;
            LayoutOrder = self:getOrder();
            library:createElement("ImageLabel", {
                Name = "border";
                Size = UDim2.new(1, 0, 0, 26);
                Position = UDim2.new(0, 0, 0, 5);
                BackgroundTransparency = 1;
                Image = "rbxassetid://4894670678";
                ImageColor3 = "@theme";
                ImageTransparency = 0.35;
                ScaleType = Enum.ScaleType.Slice;
                SliceCenter = Rect.new(5, 5, 434, 297);
                library:createElement("ImageButton", {
                    Name = "frame";
                    Size = UDim2.new(1, -2, 1, -2);
                    Position = UDim2.new(0, 1, 0, 1);
                    BackgroundTransparency = 1;
                    Image = "rbxassetid://4894670678";
                    ImageColor3 = Color3.fromRGB(16, 16, 16);
                    ScaleType = Enum.ScaleType.Slice;
                    SliceCenter = Rect.new(5, 5, 434, 297);
                    ClipsDescendants = true;
                    library:createElement("TextLabel", {
                        Name = "text";
                        Size = UDim2.new(1, -10, 1, -10);
                        Position = UDim2.new(0, 5, 0, 5);
                        Text = text;
                        TextColor3 = Color3.fromRGB(250, 250, 250);
                        TextSize = 12;
                        TextWrapped = true;
                        Font = Enum.Font.GothamSemibold;
                        BackgroundTransparency = 1;
                    });
                })
            });
            Parent = self.container;
        })

        local label = setmetatable({
            object = newLabel;
            tabObject = self.object;
            parentObject = self.parentObject;
            container = self.container;
            textBox = newLabel.border.frame.text;
        }, labels)

        while not label.textBox.TextFits do
            runService.RenderStepped:Wait()
            newLabel.Size = newLabel.Size + UDim2.new(0, 0, 0, 10);
            newLabel.border.Size = newLabel.border.Size + UDim2.new(0, 0, 0, 10)
        end

        return label
    end

    function labels:changeText(text)
        self.textBox.Text = text;

        if self.textBox.TextFits then
            while self.textBox.TextFits do
                runService.RenderStepped:Wait()

                self.object.Size = self.object.Size + UDim2.new(0, 0, 0, -10)
                self.object.border.Size = self.object.border.Size + UDim2.new(0, 0, 0, -10)
            end

            self.object.Size = self.object.Size + UDim2.new(0, 0, 0, 10)
            self.object.border.Size = self.object.border.Size + UDim2.new(0, 0, 0, 10)
        else
            while not self.textBox.TextFits do
                runService.RenderStepped:Wait()

                self.object.Size = self.object.Size + UDim2.new(0, 0, 0, 10)
                self.object.border.Size = self.object.border.Size + UDim2.new(0, 0, 0, 10)
            end
        end
    end

    function tabs:textbox(name, options, callback)
        local default = options.default or "..."
        local location = options.location or self.flags
        local flag = options.flag or ""
        local callback = callback or function() end

        local newTextBox = library:createElement("Frame", {
            Name = name;
            Size = UDim2.new(0, 200, 0, 45);
            BackgroundTransparency = 1;
            LayoutOrder = self:getOrder();
            library:createElement("ImageLabel", {
                Name = "border";
                Size = UDim2.new(1, 0, 0, 35);
                Position = UDim2.new(0, 0, 0, 5);
                Image = "rbxassetid://4894670678";
                ImageColor3 = Color3.fromRGB(28, 28, 28);
                ImageTransparency = 0.5;
                ScaleType = Enum.ScaleType.Slice;
                SliceCenter = Rect.new(5, 5, 434, 297);
                BackgroundTransparency = 1;
                ClipsDescendants = true;
                library:createElement("ImageLabel", {
                    Name = "frame";
                    Size = UDim2.new(1, -2, 1, -2);
                    Position = UDim2.new(0, 1, 0, 1);
                    Image = "rbxassetid://4894670678";
                    ImageColor3 = Color3.fromRGB(16, 16, 16);
                    ScaleType = Enum.ScaleType.Slice;
                    SliceCenter = Rect.new(5, 5, 434, 297);
                    BackgroundTransparency = 1;
                    library:createElement("TextLabel", {
                        Name = "title";
                        Size = UDim2.new(1, -8, 0.5, 0);
                        Position = UDim2.new(0, 8, 0, 0);
                        Text = name;
                        TextColor3 = Color3.fromRGB(250, 250, 250);
                        TextSize = 12;
                        TextWrapped = true;
                        Font = Enum.Font.GothamSemibold;
                        BackgroundTransparency = 1;
                    });
                    library:createElement("ImageLabel", {
                        Name = "textBorder";
                        Size = UDim2.new(0, 135, 0, 15);
                        Position = UDim2.new(0, 35, 0, 16);
                        Image = "rbxassetid://4894670678";
                        ImageColor3 = Color3.fromRGB(28, 28, 28);
                        ImageTransparency = 0.5;
                        ScaleType = Enum.ScaleType.Slice;
                        SliceCenter = Rect.new(5, 5, 434, 297);
                        BackgroundTransparency = 1;
                        library:createElement("ImageLabel", {
                            Name = "textFrame";
                            Size = UDim2.new(1, -2, 1, -2);
                            Position = UDim2.new(0, 1, 0, 1);
                            Image = "rbxassetid://4894670678";
                            ImageColor3 = Color3.fromRGB(32, 32, 32);
                            ScaleType = Enum.ScaleType.Slice;
                            SliceCenter = Rect.new(5, 5, 434, 297);
                            BackgroundTransparency = 1;
                            ClipsDescendants = true;
                            library:createElement("TextBox", {
                                Name = "textInput";
                                Size = UDim2.new(1, 0, 1, 0);
                                Position = UDim2.new(0, 0, 0, 0);
                                Text = default;
                                TextColor3 = Color3.fromRGB(250, 250, 250);
                                TextSize = 12;
                                TextWrapped = true;
                                Font = Enum.Font.GothamSemibold;
                                BackgroundTransparency = 1;
                            })
                        })
                    });
                })
            });
            Parent = self.container;
        })

        local textBox = newTextBox.border.frame.textBorder.textFrame.textInput

        textBox.FocusLost:Connect(function(enterPressed)
            if not enterPressed then return end

            location[flag] = textBox.Text
            callback(location[flag])
        end)
    end

    function tabs:colorSelector(name, options, callback)
        local location = options.location or self.flags
        local flag = options.flag or ""
        local default = options.default or Color3.fromRGB(255, 255, 255)
        local callback = callback or function() end

        location[flag] = default

        local R = math.floor(default.R * 255)
        local G = math.floor(default.G * 255)
        local B = math.floor(default.B * 255)

        local newColorSelector = library:createElement("Frame", {
            Name = name;
            Size = UDim2.new(0, 200, 0, 160);
            BackgroundTransparency = 1;
            LayoutOrder = self:getOrder();
            library:createElement("ImageLabel", {
                Name = "border";
                Size = UDim2.new(1, 0, 0, 151);
                Position = UDim2.new(0, 0, 0, 5);
                BackgroundTransparency = 1;
                Image = "rbxassetid://4894670678";
                ImageColor3 = "@theme";
                ImageTransparency = 0.35;
                ScaleType = Enum.ScaleType.Slice;
                SliceCenter = Rect.new(5, 5, 434, 297);
                library:createElement("ImageLabel", {
                    Name = "frame";
                    Size = UDim2.new(1, -2, 1, -2);
                    Position = UDim2.new(0, 1, 0, 1);
                    BackgroundTransparency = 1;
                    Image = "rbxassetid://4894670678";
                    ImageColor3 = Color3.fromRGB(16, 16, 16);
                    ScaleType = Enum.ScaleType.Slice;
                    SliceCenter = Rect.new(5, 5, 434, 297);
                    ClipsDescendants = true;
                    library:createElement("TextLabel", {
                        Name = "title";
                        Size = UDim2.new(1, 0, 0, 25);
                        Position = UDim2.new(0, 0, 0, 0);
                        Text = name;
                        TextColor3 = Color3.fromRGB(250, 250, 250);
                        TextSize = 12;
                        TextWrapped = true;
                        Font = Enum.Font.GothamSemibold;
                        BackgroundTransparency = 1;
                    });
                    library:createElement("ImageLabel", {
                        Name = "redBorder";
                        Size = UDim2.new(1, -10, 0, 25);
                        Position = UDim2.new(0, 5, 0, 25);
                        BackgroundTransparency = 1;
                        Image = "rbxassetid://4894670678";
                        ImageColor3 = Color3.fromRGB(28, 28, 28);
                        ImageTransparency = 0.35;
                        ScaleType = Enum.ScaleType.Slice;
                        SliceCenter = Rect.new(5, 5, 434, 297);
                        library:createElement("ImageLabel", {
                            Name = "frame";
                            Size = UDim2.new(1, -2, 1, -2);
                            Position = UDim2.new(0, 1, 0, 1);
                            BackgroundTransparency = 1;
                            Image = "rbxassetid://4894670678";
                            ImageColor3 = Color3.fromRGB(10, 10, 10);
                            ScaleType = Enum.ScaleType.Slice;
                            SliceCenter = Rect.new(5, 5, 434, 297);
                            ClipsDescendants = true;
                            library:createElement("TextLabel", {
                                Name = "redLabel";
                                Size = UDim2.new(0.1, 0, 0.1, 0);
                                Position = UDim2.new(0.015, 0, 0.5, -1);
                                Text = "R";
                                TextColor3 = Color3.fromRGB(250, 250, 250);
                                TextSize = 10;
                                TextWrapped = true;
                                Font = Enum.Font.GothamSemibold;
                                BackgroundTransparency = 1;
                            });
                            library:createElement("ImageLabel", {
                                Name = "gradientSelectorBorder";
                                Size = UDim2.new(0.65, 0, 0.65, 0);
                                Position = UDim2.new(0.25/2, 0, 0.35/2, 0);
                                Image = "rbxassetid://4894670678";
                                ImageColor3 = Color3.fromRGB(28, 28, 28);
                                ScaleType = Enum.ScaleType.Slice;
                                SliceCenter = Rect.new(5, 5, 434, 297);
                                BackgroundTransparency = 1;
                                library:createElement("ImageLabel", {
                                    Name = "gradientSelector";
                                    Size = UDim2.new(1, -2, 1, -2);
                                    Position = UDim2.new(0, 1, 0, 1);
                                    Image = "rbxassetid://4894670678";
                                    ImageColor3 = Color3.fromRGB(255, 255, 255);
                                    ScaleType = Enum.ScaleType.Slice;
                                    SliceCenter = Rect.new(5, 5, 434, 297);
                                    BackgroundTransparency = 1;
                                    ClipsDescendants = true;
                                    library:createElement("UIGradient", {
                                        Name = "gradient";
                                        Color = ColorSequence.new(Color3.fromRGB(0, 0, 0), Color3.fromRGB(255, 0, 0));
                                    });
                                    library:createElement("Frame", {
                                        Name = "slider";
                                        Size = UDim2.new(0, 2, 1, 0);
                                        BorderSizePixel = 0;
                                        BackgroundColor3 = Color3.fromRGB(255, 255, 255);
                                        Position = UDim2.new(math.clamp(R / 255, 0, 0.98), 0, 0, 0);
                                    })
                                });
                            });
                            library:createElement("ImageLabel", {
                                Name = "selectedColorBorder";
                                Size = UDim2.new(0.09, 0, 0.65, 0);
                                Position = UDim2.new(0.87, 0, 0.35/2, 0);
                                BackgroundTransparency = 1;
                                Image = "rbxassetid://4894670678";
                                ImageColor3 = Color3.fromRGB(28, 28, 28);
                                ImageTransparency = 0.35;
                                ScaleType = Enum.ScaleType.Slice;
                                SliceCenter = Rect.new(5, 5, 434, 297);
                                library:createElement("ImageLabel", {
                                    Name = "selectedColor";
                                    Size = UDim2.new(1, -2, 1, -2);
                                    Position = UDim2.new(0, 1, 0, 1);
                                    Image = "rbxassetid://4894670678";
                                    ImageColor3 = Color3.fromRGB(R, 0, 0);
                                    ScaleType = Enum.ScaleType.Slice;
                                    SliceCenter = Rect.new(5, 5, 434, 297);
                                    BackgroundTransparency = 1;
                                    ClipsDescendants = true;
                                })
                            })
                        })
                    });
                    library:createElement("ImageLabel", {
                        Name = "greenBorder";
                        Size = UDim2.new(1, -10, 0, 25);
                        Position = UDim2.new(0, 5, 0, 55);
                        BackgroundTransparency = 1;
                        Image = "rbxassetid://4894670678";
                        ImageColor3 = Color3.fromRGB(28, 28, 28);
                        ImageTransparency = 0.35;
                        ScaleType = Enum.ScaleType.Slice;
                        SliceCenter = Rect.new(5, 5, 434, 297);
                        library:createElement("ImageLabel", {
                            Name = "frame";
                            Size = UDim2.new(1, -2, 1, -2);
                            Position = UDim2.new(0, 1, 0, 1);
                            BackgroundTransparency = 1;
                            Image = "rbxassetid://4894670678";
                            ImageColor3 = Color3.fromRGB(10, 10, 10);
                            ScaleType = Enum.ScaleType.Slice;
                            SliceCenter = Rect.new(5, 5, 434, 297);
                            ClipsDescendants = true;
                            library:createElement("TextLabel", {
                                Name = "greenLabel";
                                Size = UDim2.new(0.1, 0, 0.1, 0);
                                Position = UDim2.new(0.015, 0, 0.5, -1);
                                Text = "G";
                                TextColor3 = Color3.fromRGB(250, 250, 250);
                                TextSize = 10;
                                TextWrapped = true;
                                Font = Enum.Font.GothamSemibold;
                                BackgroundTransparency = 1;
                            });
                            library:createElement("ImageLabel", {
                                Name = "gradientSelectorBorder";
                                Size = UDim2.new(0.65, 0, 0.65, 0);
                                Position = UDim2.new(0.25/2, 0, 0.35/2, 0);
                                Image = "rbxassetid://4894670678";
                                ImageColor3 = Color3.fromRGB(28, 28, 28);
                                ScaleType = Enum.ScaleType.Slice;
                                SliceCenter = Rect.new(5, 5, 434, 297);
                                BackgroundTransparency = 1;
                                library:createElement("ImageLabel", {
                                    Name = "gradientSelector";
                                    Size = UDim2.new(1, -2, 1, -2);
                                    Position = UDim2.new(0, 1, 0, 1);
                                    Image = "rbxassetid://4894670678";
                                    ImageColor3 = Color3.fromRGB(255, 255, 255);
                                    ScaleType = Enum.ScaleType.Slice;
                                    SliceCenter = Rect.new(5, 5, 434, 297);
                                    BackgroundTransparency = 1;
                                    ClipsDescendants = true;
                                    library:createElement("UIGradient", {
                                        Name = "gradient";
                                        Color = ColorSequence.new(Color3.fromRGB(0, 0, 0), Color3.fromRGB(0, 255, 0));
                                    });
                                    library:createElement("Frame", {
                                        Name = "slider";
                                        Size = UDim2.new(0, 2, 1, 0);
                                        BorderSizePixel = 0;
                                        BackgroundColor3 = Color3.fromRGB(255, 255, 255);
                                        Position = UDim2.new(math.clamp(G / 255, 0, 0.98), 0, 0, 0);
                                    })
                                });
                            });
                            library:createElement("ImageLabel", {
                                Name = "selectedColorBorder";
                                Size = UDim2.new(0.09, 0, 0.65, 0);
                                Position = UDim2.new(0.87, 0, 0.35/2, 0);
                                BackgroundTransparency = 1;
                                Image = "rbxassetid://4894670678";
                                ImageColor3 = Color3.fromRGB(28, 28, 28);
                                ImageTransparency = 0.35;
                                ScaleType = Enum.ScaleType.Slice;
                                SliceCenter = Rect.new(5, 5, 434, 297);
                                library:createElement("ImageLabel", {
                                    Name = "selectedColor";
                                    Size = UDim2.new(1, -2, 1, -2);
                                    Position = UDim2.new(0, 1, 0, 1);
                                    Image = "rbxassetid://4894670678";
                                    ImageColor3 = Color3.fromRGB(0, G, 0);
                                    ScaleType = Enum.ScaleType.Slice;
                                    SliceCenter = Rect.new(5, 5, 434, 297);
                                    BackgroundTransparency = 1;
                                    ClipsDescendants = true;
                                })
                            })
                        })
                    });
                    library:createElement("ImageLabel", {
                        Name = "blueBorder";
                        Size = UDim2.new(1, -10, 0, 25);
                        Position = UDim2.new(0, 5, 0, 85);
                        BackgroundTransparency = 1;
                        Image = "rbxassetid://4894670678";
                        ImageColor3 = Color3.fromRGB(28, 28, 28);
                        ImageTransparency = 0.35;
                        ScaleType = Enum.ScaleType.Slice;
                        SliceCenter = Rect.new(5, 5, 434, 297);
                        library:createElement("ImageLabel", {
                            Name = "frame";
                            Size = UDim2.new(1, -2, 1, -2);
                            Position = UDim2.new(0, 1, 0, 1);
                            BackgroundTransparency = 1;
                            Image = "rbxassetid://4894670678";
                            ImageColor3 = Color3.fromRGB(10, 10, 10);
                            ScaleType = Enum.ScaleType.Slice;
                            SliceCenter = Rect.new(5, 5, 434, 297);
                            ClipsDescendants = true;
                            library:createElement("TextLabel", {
                                Name = "blueLabel";
                                Size = UDim2.new(0.1, 0, 0.1, 0);
                                Position = UDim2.new(0.015, 0, 0.5, -1);
                                Text = "B";
                                TextColor3 = Color3.fromRGB(250, 250, 250);
                                TextSize = 10;
                                TextWrapped = true;
                                Font = Enum.Font.GothamSemibold;
                                BackgroundTransparency = 1;
                            });
                            library:createElement("ImageLabel", {
                                Name = "gradientSelectorBorder";
                                Size = UDim2.new(0.65, 0, 0.65, 0);
                                Position = UDim2.new(0.25/2, 0, 0.35/2, 0);
                                Image = "rbxassetid://4894670678";
                                ImageColor3 = Color3.fromRGB(28, 28, 28);
                                ScaleType = Enum.ScaleType.Slice;
                                SliceCenter = Rect.new(5, 5, 434, 297);
                                BackgroundTransparency = 1;
                                library:createElement("ImageLabel", {
                                    Name = "gradientSelector";
                                    Size = UDim2.new(1, -2, 1, -2);
                                    Position = UDim2.new(0, 1, 0, 1);
                                    Image = "rbxassetid://4894670678";
                                    ImageColor3 = Color3.fromRGB(255, 255, 255);
                                    ScaleType = Enum.ScaleType.Slice;
                                    SliceCenter = Rect.new(5, 5, 434, 297);
                                    BackgroundTransparency = 1;
                                    ClipsDescendants = true;
                                    library:createElement("UIGradient", {
                                        Name = "gradient";
                                        Color = ColorSequence.new(Color3.fromRGB(0, 0, 0), Color3.fromRGB(0, 0, 255));
                                    });
                                    library:createElement("Frame", {
                                        Name = "slider";
                                        Size = UDim2.new(0, 2, 1, 0);
                                        BorderSizePixel = 0;
                                        BackgroundColor3 = Color3.fromRGB(255, 255, 255);
                                        Position = UDim2.new(math.clamp(B / 255, 0, 0.98), 0, 0, 0);
                                    })
                                });
                            });
                            library:createElement("ImageLabel", {
                                Name = "selectedColorBorder";
                                Size = UDim2.new(0.09, 0, 0.65, 0);
                                Position = UDim2.new(0.87, 0, 0.35/2, 0);
                                BackgroundTransparency = 1;
                                Image = "rbxassetid://4894670678";
                                ImageColor3 = Color3.fromRGB(28, 28, 28);
                                ImageTransparency = 0.35;
                                ScaleType = Enum.ScaleType.Slice;
                                SliceCenter = Rect.new(5, 5, 434, 297);
                                library:createElement("ImageLabel", {
                                    Name = "selectedColor";
                                    Size = UDim2.new(1, -2, 1, -2);
                                    Position = UDim2.new(0, 1, 0, 1);
                                    Image = "rbxassetid://4894670678";
                                    ImageColor3 = Color3.fromRGB(0, 0, B);
                                    ScaleType = Enum.ScaleType.Slice;
                                    SliceCenter = Rect.new(5, 5, 434, 297);
                                    BackgroundTransparency = 1;
                                    ClipsDescendants = true;
                                })
                            })
                        })
                    });
                    library:createElement("ImageLabel", {
                        Name = "finalBorder";
                        Size = UDim2.new(1, -10, 0, 25);
                        Position = UDim2.new(0, 5, 0, 115);
                        BackgroundTransparency = 1;
                        Image = "rbxassetid://4894670678";
                        ImageColor3 = Color3.fromRGB(28, 28, 28);
                        ImageTransparency = 0.35;
                        ScaleType = Enum.ScaleType.Slice;
                        SliceCenter = Rect.new(5, 5, 434, 297);
                        library:createElement("ImageLabel", {
                            Name = "frame";
                            Size = UDim2.new(1, -2, 1, -2);
                            Position = UDim2.new(0, 1, 0, 1);
                            BackgroundTransparency = 1;
                            Image = "rbxassetid://4894670678";
                            ImageColor3 = Color3.fromRGB(10, 10, 10);
                            ScaleType = Enum.ScaleType.Slice;
                            SliceCenter = Rect.new(5, 5, 434, 297);
                            ClipsDescendants = true;
                            library:createElement("TextLabel", {
                                Name = "redLabel";
                                Size = UDim2.new(0.1, 0, 0.1, 0);
                                Position = UDim2.new(0.015, 0, 0.5, -1);
                                Text = "R";
                                TextColor3 = Color3.fromRGB(250, 250, 250);
                                TextSize = 10;
                                TextWrapped = true;
                                Font = Enum.Font.GothamSemibold;
                                BackgroundTransparency = 1;
                            });
                            library:createElement("ImageLabel", {
                                Name = "redButtonBorder";
                                Size = UDim2.new(0, 30, 0, 15);
                                Position = UDim2.new(0, 20, 0, 4);
                                Image = "rbxassetid://4894670678";
                                ImageColor3 = Color3.fromRGB(28, 28, 28);
                                ImageTransparency = 0.5;
                                ScaleType = Enum.ScaleType.Slice;
                                SliceCenter = Rect.new(5, 5, 434, 297);
                                BackgroundTransparency = 1;
                                library:createElement("ImageLabel", {
                                    Name = "redButtonFrame";
                                    Size = UDim2.new(1, -2, 1, -2);
                                    Position = UDim2.new(0, 1, 0, 1);
                                    Image = "rbxassetid://4894670678";
                                    ImageColor3 = Color3.fromRGB(32, 32, 32);
                                    ScaleType = Enum.ScaleType.Slice;
                                    SliceCenter = Rect.new(5, 5, 434, 297);
                                    BackgroundTransparency = 1;
                                    ClipsDescendants = true;
                                    library:createElement("TextBox", {
                                        Name = "redLabel";
                                        Size = UDim2.new(1, 0, 1, 0);
                                        Position = UDim2.new(0, 0, 0, 0);
                                        Text = R;
                                        TextColor3 = Color3.fromRGB(250, 250, 250);
                                        TextSize = 12;
                                        TextWrapped = true;
                                        Font = Enum.Font.GothamSemibold;
                                        BackgroundTransparency = 1;
                                    })
                                })
                            });
                            library:createElement("TextLabel", {
                                Name = "greenLabel";
                                Size = UDim2.new(0.1, 0, 0.1, 0);
                                Position = UDim2.new(0.27, 0, 0.5, -1);
                                Text = "G";
                                TextColor3 = Color3.fromRGB(250, 250, 250);
                                TextSize = 10;
                                TextWrapped = true;
                                Font = Enum.Font.GothamSemibold;
                                BackgroundTransparency = 1;
                            });
                            library:createElement("ImageLabel", {
                                Name = "greenButtonBorder";
                                Size = UDim2.new(0, 30, 0, 15);
                                Position = UDim2.new(0, 68, 0, 4);
                                Image = "rbxassetid://4894670678";
                                ImageColor3 = Color3.fromRGB(28, 28, 28);
                                ImageTransparency = 0.5;
                                ScaleType = Enum.ScaleType.Slice;
                                SliceCenter = Rect.new(5, 5, 434, 297);
                                BackgroundTransparency = 1;
                                library:createElement("ImageLabel", {
                                    Name = "greenButtonFrame";
                                    Size = UDim2.new(1, -2, 1, -2);
                                    Position = UDim2.new(0, 1, 0, 1);
                                    Image = "rbxassetid://4894670678";
                                    ImageColor3 = Color3.fromRGB(32, 32, 32);
                                    ScaleType = Enum.ScaleType.Slice;
                                    SliceCenter = Rect.new(5, 5, 434, 297);
                                    BackgroundTransparency = 1;
                                    ClipsDescendants = true;
                                    library:createElement("TextBox", {
                                        Name = "greenLabel";
                                        Size = UDim2.new(1, 0, 1, 0);
                                        Position = UDim2.new(0, 0, 0, 0);
                                        Text = G;
                                        TextColor3 = Color3.fromRGB(250, 250, 250);
                                        TextSize = 12;
                                        TextWrapped = true;
                                        Font = Enum.Font.GothamSemibold;
                                        BackgroundTransparency = 1;
                                    })
                                })
                            });
                            library:createElement("TextLabel", {
                                Name = "blueLabel";
                                Size = UDim2.new(0.1, 0, 0.1, 0);
                                Position = UDim2.new(0.53, 0, 0.5, -1);
                                Text = "B";
                                TextColor3 = Color3.fromRGB(250, 250, 250);
                                TextSize = 10;
                                TextWrapped = true;
                                Font = Enum.Font.GothamSemibold;
                                BackgroundTransparency = 1;
                            });
                            library:createElement("ImageLabel", {
                                Name = "blueButtonBorder";
                                Size = UDim2.new(0, 30, 0, 15);
                                Position = UDim2.new(0, 116, 0, 4);
                                Image = "rbxassetid://4894670678";
                                ImageColor3 = Color3.fromRGB(28, 28, 28);
                                ImageTransparency = 0.5;
                                ScaleType = Enum.ScaleType.Slice;
                                SliceCenter = Rect.new(5, 5, 434, 297);
                                BackgroundTransparency = 1;
                                library:createElement("ImageLabel", {
                                    Name = "blueButtonFrame";
                                    Size = UDim2.new(1, -2, 1, -2);
                                    Position = UDim2.new(0, 1, 0, 1);
                                    Image = "rbxassetid://4894670678";
                                    ImageColor3 = Color3.fromRGB(32, 32, 32);
                                    ScaleType = Enum.ScaleType.Slice;
                                    SliceCenter = Rect.new(5, 5, 434, 297);
                                    BackgroundTransparency = 1;
                                    ClipsDescendants = true;
                                    library:createElement("TextBox", {
                                        Name = "blueLabel";
                                        Size = UDim2.new(1, 0, 1, 0);
                                        Position = UDim2.new(0, 0, 0, 0);
                                        Text = B;
                                        TextColor3 = Color3.fromRGB(250, 250, 250);
                                        TextSize = 12;
                                        TextWrapped = true;
                                        Font = Enum.Font.GothamSemibold;
                                        BackgroundTransparency = 1;
                                    })
                                })
                            });
                            library:createElement("ImageLabel", {
                                Name = "selectedColorBorder";
                                Size = UDim2.new(0.09, 0, 0.65, 0);
                                Position = UDim2.new(0.87, 0, 0.35/2, 0);
                                BackgroundTransparency = 1;
                                Image = "rbxassetid://4894670678";
                                ImageColor3 = Color3.fromRGB(28, 28, 28);
                                ImageTransparency = 0.35;
                                ScaleType = Enum.ScaleType.Slice;
                                SliceCenter = Rect.new(5, 5, 434, 297);
                                library:createElement("ImageLabel", {
                                    Name = "selectedColor";
                                    Size = UDim2.new(1, -2, 1, -2);
                                    Position = UDim2.new(0, 1, 0, 1);
                                    Image = "rbxassetid://4894670678";
                                    ImageColor3 = Color3.fromRGB(R, G, B);
                                    ScaleType = Enum.ScaleType.Slice;
                                    SliceCenter = Rect.new(5, 5, 434, 297);
                                    BackgroundTransparency = 1;
                                    ClipsDescendants = true;
                                })
                            })
                        })
                    });
                })
            });
            Parent = self.container;
        })

        local selectors = {
            red = {
                slider = newColorSelector.border.frame.redBorder.frame.gradientSelectorBorder.gradientSelector.slider;
                selectedColor = newColorSelector.border.frame.redBorder.frame.selectedColorBorder.selectedColor;
            };
            green = {
                slider = newColorSelector.border.frame.greenBorder.frame.gradientSelectorBorder.gradientSelector.slider;
                selectedColor = newColorSelector.border.frame.greenBorder.frame.selectedColorBorder.selectedColor;
            };
            blue = {
                slider = newColorSelector.border.frame.blueBorder.frame.gradientSelectorBorder.gradientSelector.slider;
                selectedColor = newColorSelector.border.frame.blueBorder.frame.selectedColorBorder.selectedColor;
            };
        }

        local textBoxes = {
            finalColor = newColorSelector.border.frame.finalBorder.frame.selectedColorBorder.selectedColor;
            red = {
                textBox = newColorSelector.border.frame.finalBorder.frame.redButtonBorder.redButtonFrame.redLabel;
            };
            green = {
                textBox = newColorSelector.border.frame.finalBorder.frame.greenButtonBorder.greenButtonFrame.greenLabel;
            };
            blue = {
                textBox = newColorSelector.border.frame.finalBorder.frame.blueButtonBorder.blueButtonFrame.blueLabel;
            };
        }
        
        local function updateColors(color, num)
            if color == "red" then
                R = num
                selectors[color].selectedColor.ImageColor3 = Color3.fromRGB(R, 0, 0)
            elseif color == "green" then
                G = num
                selectors[color].selectedColor.ImageColor3 = Color3.fromRGB(0, G, 0)
            elseif color == "blue" then
                B = num
                selectors[color].selectedColor.ImageColor3 = Color3.fromRGB(0, 0, B)
            else
                return
            end

            textBoxes[color].textBox.Text = num

            textBoxes.finalColor.ImageColor3 = Color3.fromRGB(R, G, B)

            selectors[color].slider.Position = UDim2.new(math.clamp(num / 255, 0, 0.98), 0, 0, 0)

            location[flag] = Color3.fromRGB(R, G, B)
            callback(location[flag])
        end

        for i,v in pairs(selectors) do
            local renderStepped
            local activeInput = nil

            local connected = false

            local slider = v.slider
            local container = slider.Parent
            local selectedColor = v.selectedColor

            local function update()
                if renderStepped then renderStepped:Disconnect() end

                renderStepped = runService.RenderStepped:Connect(function()
                    local screenPos = userInputService:GetMouseLocation()
                    if activeInput and activeInput.UserInputType == Enum.UserInputType.Touch then
                        screenPos = activeInput.Position
                    end

                    local mouse = toGuiPosition(screenPos)
                    local percent = (mouse.X - container.AbsolutePosition.X) / (container.AbsoluteSize.X)

                    percent = math.clamp(percent, 0, 1)
                    percent = tonumber(string.format("%.2f", percent))

                    local num = math.floor(percent * 255)

                    updateColors(i, num)
                end)
            end

            local function stop()
                if renderStepped then renderStepped:Disconnect() end
                renderStepped = nil
            end

            local function pressEnded(input)
                if not connected or input ~= activeInput then return end
                connected = false
                activeInput = nil
                setScrollingEnabled(container, true)
                stop()
            end

            local function pressBegan(input)
                if not isPrimaryInput(input) then return end
                if connected and activeInput == input then return end

                activeInput = input
                connected = true
                setScrollingEnabled(container, false)
                update()

                input.Changed:Connect(function()
                    local state = input.UserInputState
                    if state == Enum.UserInputState.End or state == Enum.UserInputState.Cancel then
                        pressEnded(input)
                    end
                end)

                local pressEndedConn
                pressEndedConn = userInputService.InputEnded:Connect(function(ended)
                    if ended == input then
                        pressEndedConn:Disconnect()
                        pressEnded(input)
                    end
                end)
            end

            container.InputBegan:Connect(pressBegan)
            container.InputEnded:Connect(pressEnded)
            slider.InputBegan:Connect(pressBegan)
            slider.InputEnded:Connect(pressEnded)
        end

        for i,v in pairs(textBoxes) do
            if type(v) == "table" then

                local slider = selectors[i].slider

                local first = true

                v.textBox:GetPropertyChangedSignal("Text"):Connect(function()
                    v.textBox.Text = v.textBox.Text:gsub("%D+", "")
                end)

                v.textBox.FocusLost:Connect(function(enterPressed)
                    if not enterPressed then 
                        if i == "red" then
                            v.textBox.Text = R
                        elseif i == "green" then
                            v.textBox.Text = G
                        elseif i == "blue" then
                            v.textBox.Text = B
                        end

                        return 
                    end

                    v.textBox.Text = math.clamp(tonumber(v.textBox.Text), 0, 255)

                    updateColors(i, tonumber(v.textBox.Text))
                end)

            end
        end
    end

    function tabs:button(name, callback, icon)
        local callback = callback or function() end

        local newButton = library:createElement("Frame", {
            Name = name;
            Size = UDim2.new(0, 200, 0, 35);
            BackgroundTransparency = 1;
            LayoutOrder = self:getOrder();
            library:createElement("ImageLabel", {
                Name = "border";
                Size = UDim2.new(1, 0, 0, 26);
                Position = UDim2.new(0, 0, 0, 5);
                BackgroundTransparency = 1;
                Image = "rbxassetid://4894670678";
                ImageColor3 = "@theme";
                ImageTransparency = 0.35;
                ScaleType = Enum.ScaleType.Slice;
                SliceCenter = Rect.new(5, 5, 434, 297);
                library:createElement("ImageButton", {
                    Name = "frame";
                    Size = UDim2.new(1, -2, 1, -2);
                    Position = UDim2.new(0, 1, 0, 1);
                    BackgroundTransparency = 1;
                    Image = "rbxassetid://4894670678";
                    ImageColor3 = Color3.fromRGB(16, 16, 16);
                    ScaleType = Enum.ScaleType.Slice;
                    SliceCenter = Rect.new(5, 5, 434, 297);
                    ClipsDescendants = true;
                    library:createElement("TextLabel", {
                        Name = "title";
                        Size = UDim2.new(1, 0, 1, 0);
                        Position = UDim2.new(0, 0, 0, 0);
                        Text = name;
                        TextColor3 = Color3.fromRGB(250, 250, 250);
                        TextSize = 12;
                        TextWrapped = true;
                        Font = Enum.Font.GothamSemibold;
                        BackgroundTransparency = 1;
                    });
                })
            });
            Parent = self.container;
        })

        if icon then
            local iconLabel = library:createElement("ImageLabel", {
                Name = "icon";
                Size = UDim2.new(0, 16, 0, 16);
                Position = UDim2.new(0, 8, 0, 4);
                BackgroundTransparency = 1;
                ImageColor3 = "@theme";
                ZIndex = 3;
                Parent = newButton.border.frame;
            })
            applyIcon(iconLabel, icon)
            newButton.border.frame.title.Position = UDim2.new(0, 30, 0, 0)
            newButton.border.frame.title.Size = UDim2.new(1, -38, 1, 0)
            newButton.border.frame.title.TextXAlignment = Enum.TextXAlignment.Left
        end

        onPress(newButton.border.frame, callback)
    end

    function tabs:toggle(name, options, useBind, bindOptions, callback)
        local location = options.location or self.flags
        local flag = options.flag or ""
        local default = options.default or false
        local callback = callback or function() end

        location[flag] = default

        local newToggle = library:createElement("Frame", {
            Name = name;
            Size = UDim2.new(0, 200, 0, (options.card and 46) or 35);
            BackgroundTransparency = 1;
            LayoutOrder = self:getOrder();
            library:createElement("ImageLabel", {
                Name = "border";
                Size = UDim2.new(1, 0, 0, (options.card and 38) or 26);
                Position = UDim2.new(0, 0, 0, (options.card and 4) or 5);
                BackgroundTransparency = 1;
                Image = "rbxassetid://4894670678";
                ImageColor3 = Color3.fromRGB(28, 28, 28);
                ImageTransparency = 0.5;
                ScaleType = Enum.ScaleType.Slice;
                SliceCenter = Rect.new(5, 5, 434, 297);
                library:createElement("ImageButton", {
                    Name = "frame";
                    Size = UDim2.new(1, -2, 1, -2);
                    Position = UDim2.new(0, 1, 0, 1);
                    AutoButtonColor = false;
                    BackgroundTransparency = 1;
                    Image = "rbxassetid://4894670678";
                    ImageColor3 = Color3.fromRGB(16, 16, 16);
                    ScaleType = Enum.ScaleType.Slice;
                    SliceCenter = Rect.new(5, 5, 434, 297);
                    ClipsDescendants = true;
                    library:createElement("TextLabel", {
                        Name = "title";
                        Size = UDim2.new(1, -10, 1, 0);
                        Position = UDim2.new(0, 10, 0, 0);
                        Text = name;
                        TextColor3 = Color3.fromRGB(250, 250, 250);
                        TextSize = 12;
                        TextWrapped = true;
                        Font = Enum.Font.GothamSemibold;
                        TextXAlignment = Enum.TextXAlignment.Left;
                        BackgroundTransparency = 1;
                    });
                    library:createElement("ImageLabel", {
                        Name = "button";
                        Size = UDim2.new(0, (options.card and 36) or 18, 0, (options.card and 20) or 18);
                        Position = UDim2.new(1, (options.card and -44) or -26, 0, (options.card and 2) or 3);
                        BackgroundTransparency = 1;
                        Image = (options.card and "") or "rbxassetid://4892761119";
                        ScaleType = Enum.ScaleType.Slice;
                        SliceCenter = Rect.new(6, 6, 14, 14);
                        BackgroundTransparency = 1;
                        ((options.card and createSwitch(location[flag], 2)) or createPrimaryCheck(
                            (location[flag] and UDim2.new(1, 0, 1, 0)) or UDim2.new(0, 0, 0, 0),
                            (location[flag] and UDim2.new(0, 0, 0, 0)) or UDim2.new(0.5, 0, 0.5, 0),
                            2
                        ))
                    })
                })
            });
            Parent = self.container;
        })

        if options.icon then
            local iconLabel = library:createElement("ImageLabel", {
                Name = "icon";
                Size = UDim2.new(0, 16, 0, 16);
                Position = UDim2.new(0, 10, 0, 4);
                BackgroundTransparency = 1;
                ImageColor3 = "@theme";
                ZIndex = 3;
                Parent = newToggle.border.frame;
            })
            applyIcon(iconLabel, options.icon)
            newToggle.border.frame.title.Position = UDim2.new(0, 32, 0, 0)
            newToggle.border.frame.title.Size = UDim2.new(1, -42, 1, 0)
        end

        if options.card then
            local title = newToggle.border.frame.title
            title.Size = UDim2.new(1, -56, 0, 16)
            title.Position = UDim2.new(0, (options.icon and 32) or 10, 0, 1)
            title.TextSize = 13

            library:createElement("TextLabel", {
                Name = "subtitle";
                Size = UDim2.new(1, -56, 0, 13);
                Position = UDim2.new(0, (options.icon and 32) or 10, 0, 18);
                Text = options.subtitle or "";
                TextColor3 = Color3.fromRGB(160, 160, 160);
                TextSize = 11;
                TextWrapped = true;
                Font = Enum.Font.GothamSemibold;
                TextXAlignment = Enum.TextXAlignment.Left;
                BackgroundTransparency = 1;
                ZIndex = 3;
                Parent = newToggle.border.frame;
            })
        end

        local button = newToggle.border.frame.button

        local click = function()
            location[flag] = not location[flag]
            callback(location[flag])
            setToggleVisual(button.toggle, location[flag])
        end

        if useBind then
            local shortNames = {
                LeftControl = "LeftCtrl";
                LeftShift = "LShift";
                RightShift = "RShift";
                MouseButton1 = "Mouse1";
                MouseButton2 = "Mouse2";
            }

            local banned = {
                Return = true;
                Space = true;
                Tab = true;
                Unknown = true;
                RightControl = true;
            }

            local allowed = {
                MouseButton1 = true;
                MouseButton2 = true;
            }

            local bindLocation = bindOptions.location or self.flags
            local bindFlag = bindOptions.flag or ""
            local kbOnly = bindOptions.kbonly or false
            local bindDefault = bindOptions.default or nil

            local passed = true
            if kbOnly and tostring(bindDefault):find("MouseButton") then
                passed = false
            end
            
            if passed then
                bindLocation[bindFlag] = bindDefault
            end

            local name = (bindDefault and (shortNames[bindDefault.Name] or bindDefault.Name)) or "None"

            local bind = library:createElement("ImageLabel", {
                Name = "bindBorder";
                Size = ((bindDefault and shortNames[bindDefault.Name] or name == "None") and UDim2.new(0, 50, 0, 15)) or UDim2.new(0, 30, 0, 15);
                Position = ((bindDefault and shortNames[bindDefault.Name] or name == "None") and UDim2.new(0, 115, 0, 4)) or UDim2.new(0, 135, 0, 4);
                Image = "rbxassetid://4894670678";
                ImageColor3 = Color3.fromRGB(28, 28, 28);
                ImageTransparency = 0.5;
                ScaleType = Enum.ScaleType.Slice;
                SliceCenter = Rect.new(5, 5, 434, 297);
                BackgroundTransparency = 1;
                ZIndex = 10;
                library:createElement("ImageLabel", {
                    Name = "bindFrame";
                    Size = UDim2.new(1, -2, 1, -2);
                    Position = UDim2.new(0, 1, 0, 1);
                    Image = "rbxassetid://4894670678";
                    ImageColor3 = Color3.fromRGB(32, 32, 32);
                    ScaleType = Enum.ScaleType.Slice;
                    SliceCenter = Rect.new(5, 5, 434, 297);
                    BackgroundTransparency = 1;
                    ClipsDescendants = true;
                    library:createElement("TextButton", {
                        Name = "bindLabel";
                        Size = UDim2.new(1, 0, 1, 0);
                        Position = UDim2.new(0, 0, 0, 0);
                        Text = name;
                        TextColor3 = Color3.fromRGB(250, 250, 250);
                        TextSize = 12;
                        TextWrapped = true;
                        Font = Enum.Font.GothamSemibold;
                        BackgroundTransparency = 1;
                    })
                });
                Parent = newToggle.border.frame;
            })

            onPress(bind.bindFrame.bindLabel, function()
                library.binding = true

                bind.bindFrame.bindLabel.Text = "..."

                local input, b = userInputService.InputBegan:Wait()

                if (input.UserInputType ~= Enum.UserInputType.Keyboard and allowed[input.UserInputType.Name] and not kbOnly) or (input.KeyCode and not banned[input.KeyCode.Name]) then
                    local name = (input.UserInputType ~= Enum.UserInputType.Keyboard and input.UserInputType.Name) or ((input.KeyCode == Enum.KeyCode.Delete or input.KeyCode == Enum.KeyCode.Escape) and "None") or input.KeyCode.Name
                    
                    if name == "None" then
                        bindLocation[bindFlag] = nil
                    else
                        bindLocation[bindFlag] = input
                    end

                    if shortNames[name] then
                        bind:TweenSizeAndPosition(UDim2.new(0, 50, 0, 15), UDim2.new(0, 115, 0, 4), "Out", "Quad", 0.15, true)
                        bind.bindFrame.bindLabel.Text = shortNames[name]
                    else
                        bind:TweenSizeAndPosition((string.len(name) > 3 and UDim2.new(0, 50, 0, 15)) or UDim2.new(0, 30, 0, 15), (string.len(name) > 3 and UDim2.new(0, 115, 0, 4)) or UDim2.new(0, 135, 0, 4), 'Out', 'Quad', 0.15, true)
                        bind.bindFrame.bindLabel.Text = name
                    end
                else
                    if bindLocation[bindFlag] then
                        local name

                        if (not pcall(function()
                            return bindLocation[bindFlag].UserInputType
                        end)) then
                            name = tostring(bindLocation[bindFlag])
                        else
                            name = (bindLocation[bindFlag].UserInputType ~= Enum.UserInputType.Keyboard and bindLocation[bindFlag].UserInputType.Name) or bindLocation[bindFlag].KeyCode.Name
                        end

                        if shortNames[name] then
                            bind:TweenSizeAndPosition(UDim2.new(0, 50, 0, 15), UDim2.new(0, 115, 0, 4), 'Out', 'Quad', 0.15, true);
                            bind.bindFrame.bindLabel.Text = shortNames[name]
                        else
                            bind:TweenSizeAndPosition((string.len(name) > 3 and UDim2.new(0, 50, 0, 15)) or UDim2.new(0, 30, 0, 15), (string.len(name) > 3 and UDim2.new(0, 115, 0, 4)) or UDim2.new(0, 135, 0, 4), 'Out', 'Quad', 0.15, true)
                            bind.bindFrame.bindLabel.Text = name
                        end
                    end
                end

                wait(0.1)
                library.binding = false
            end)

            library.binds[bindFlag] = {
                location = bindLocation;
                call = click;
            }
        end

        onPress(newToggle.border.frame, click)
    end

    function tabs:slider(name, options, sliderCallback, useToggle, toggleOptions)
        local sLocation = options.location or self.flags
        local sFlag = options.flag or ""
        local min = options.min or 0
        local max = options.max or 1
        local sDefault = (options.default ~= nil and math.floor(math.clamp(options.default, min, max))) or min
        local sCallback = sliderCallback or function() end

        sLocation[sFlag] = sDefault

        local newSlider = library:createElement("Frame", {
            Name = name;
            Size = UDim2.new(0, 200, 0, 55);
            BackgroundTransparency = 1;
            LayoutOrder = self:getOrder();
            library:createElement("ImageLabel", {
                Name = "border";
                Size = UDim2.new(1, 0, 0, 45);
                Position = UDim2.new(0, 0, 0, 5);
                Image = "rbxassetid://4894670678";
                ImageColor3 = Color3.fromRGB(28, 28, 28);
                ImageTransparency = 0.5;
                ScaleType = Enum.ScaleType.Slice;
                SliceCenter = Rect.new(5, 5, 434, 297);
                BackgroundTransparency = 1;
                ClipsDescendants = true;
                library:createElement("ImageLabel", {
                    Name = "frame";
                    Size = UDim2.new(1, -2, 1, -2);
                    Position = UDim2.new(0, 1, 0, 1);
                    Image = "rbxassetid://4894670678";
                    ImageColor3 = Color3.fromRGB(16, 16, 16);
                    ScaleType = Enum.ScaleType.Slice;
                    SliceCenter = Rect.new(5, 5, 434, 297);
                    BackgroundTransparency = 1;
                    library:createElement("TextLabel", {
                        Name = "title";
                        Size = UDim2.new(1, -8, 0.5, 0);
                        Position = UDim2.new(0, 8, 0, 0);
                        Text = name;
                        TextColor3 = Color3.fromRGB(250, 250, 250);
                        TextSize = 12;
                        TextWrapped = true;
                        Font = Enum.Font.GothamSemibold;
                        TextXAlignment = Enum.TextXAlignment.Left;
                        BackgroundTransparency = 1;
                    });
                    library:createElement("ImageLabel", {
                        Name = "valueButtonBorder";
                        Size = UDim2.new(0, 35, 0, 15);
                        Position = UDim2.new(0, 155, 0, 4);
                        Image = "rbxassetid://4894670678";
                        ImageColor3 = Color3.fromRGB(28, 28, 28);
                        ImageTransparency = 0.5;
                        ScaleType = Enum.ScaleType.Slice;
                        SliceCenter = Rect.new(5, 5, 434, 297);
                        BackgroundTransparency = 1;
                        library:createElement("ImageLabel", {
                            Name = "valueButtonFrame";
                            Size = UDim2.new(1, -2, 1, -2);
                            Position = UDim2.new(0, 1, 0, 1);
                            Image = "rbxassetid://4894670678";
                            ImageColor3 = Color3.fromRGB(32, 32, 32);
                            ScaleType = Enum.ScaleType.Slice;
                            SliceCenter = Rect.new(5, 5, 434, 297);
                            BackgroundTransparency = 1;
                            ClipsDescendants = true;
                            library:createElement("TextBox", {
                                Name = "valueLabel";
                                Size = UDim2.new(1, 0, 1, 0);
                                Position = UDim2.new(0, 0, 0, 0);
                                Text = tostring(sDefault);
                                TextColor3 = Color3.fromRGB(250, 250, 250);
                                TextSize = 12;
                                TextWrapped = true;
                                Font = Enum.Font.GothamSemibold;
                                BackgroundTransparency = 1;
                            })
                        })
                    });
                    library:createElement("TextLabel", {
                        Name = "minus";
                        Size = UDim2.new(0, 13, 0, 13);
                        Position = UDim2.new(0, (useToggle and 36) or 8, 0, 24);
                        Text = "-";
                        TextColor3 = Color3.fromRGB(250, 250, 250);
                        TextSize = 13;
                        Font = Enum.Font.GothamSemibold;
                        BackgroundColor3 = Color3.fromRGB(32, 32, 32);
                        BorderSizePixel = 0;
                        ZIndex = 2;
                        (function() local c = Instance.new("UICorner") c.CornerRadius = UDim.new(1, 0) return c end)();
                    });
                    library:createElement("TextLabel", {
                        Name = "plus";
                        Size = UDim2.new(0, 13, 0, 13);
                        Position = UDim2.new(0, (useToggle and 161) or 173, 0, 24);
                        Text = "+";
                        TextColor3 = Color3.fromRGB(250, 250, 250);
                        TextSize = 13;
                        Font = Enum.Font.GothamSemibold;
                        BackgroundColor3 = Color3.fromRGB(32, 32, 32);
                        BorderSizePixel = 0;
                        ZIndex = 2;
                        (function() local c = Instance.new("UICorner") c.CornerRadius = UDim.new(1, 0) return c end)();
                    });
                    library:createElement("Frame", {
                        Name = "container";
                        BorderSizePixel = 0;
                        Size = UDim2.new(0, (useToggle and 104) or 144, 0, 8);
                        Position = UDim2.new(0, (useToggle and 53) or 25, 0, 27);
                        BackgroundTransparency = 1;
                        library:createElement("Frame", {
                            Name = "sliderBar";
                            Size = UDim2.new(1, 0, 0, 2);
                            Position = UDim2.new(0, 0, 0, 3);
                            BorderSizePixel = 0;
                            library:createElement("Frame", {
                                Name = "moveBar";
                                Size = UDim2.new(((sDefault - min) / (max - min)), 0, 1, 0);
                                Position = UDim2.new(0, 0, 0, 0);
                                BorderSizePixel = 0;
                                BackgroundColor3 = "@theme";
                                BackgroundTransparency = 0;
                            });
                            library:createElement("ImageLabel", {
                                Name = "circleBorder";
                                Size = UDim2.new(0, 10, 0, 10);
                                Position = UDim2.new(((sDefault - min) / (max - min)), 0, 0, -4);
                                BackgroundTransparency = 1;
                                Image = "rbxassetid://4896743658";
                                ImageColor3 = "@theme";
                                ImageTransparency = 0.3;
                                library:createElement("ImageLabel", {
                                    Name = "circleFrame";
                                    Size = UDim2.new(1, -2, 1, -2);
                                    Position = UDim2.new(0, 1, 0, 1);
                                    BackgroundTransparency = 1;
                                    Image = "rbxassetid://4896743658";
                                    ImageColor3 = Color3.fromRGB(255, 255, 255);
                                    ScaleType = Enum.ScaleType.Slice;
                                    SliceCenter = Rect.new(5, 5, 5, 5);
                                })
                            })
                        })
                    })
                })
            });
            Parent = self.container;
        })

        if useToggle then
            local tLocation = toggleOptions.location or self.flags
            local tFlag = toggleOptions.flag or ""
            local tDefault = toggleOptions.default or false
            local tCallback = toggleOptions.callback or function() end

            tLocation[tFlag] = tDefault

            local sliderToggle = library:createElement("ImageButton", {
                Name = "button";
                Size = UDim2.new(0, 30, 0, 17);
                Position = UDim2.new(0, 4, 0, 21);
                Image = "";
                BackgroundTransparency = 1;
                createSwitch(tLocation[tFlag], 2);
                Parent = newSlider.border.frame;
            })

            onPress(sliderToggle, function()
                tLocation[tFlag] = not tLocation[tFlag]
                tCallback(tLocation[tFlag])
                setToggleVisual(sliderToggle.toggle, tLocation[tFlag])
            end)
        end

        local renderStepped
        local activeInput = nil
        local connected = false
        local first = true

        local container = newSlider.border.frame.container
        local textBox = newSlider.border.frame.valueButtonBorder.valueButtonFrame.valueLabel

        local function update()
            if renderStepped then renderStepped:Disconnect() end

            renderStepped = runService.RenderStepped:Connect(function()
                local screenPos = userInputService:GetMouseLocation()
                if activeInput and activeInput.UserInputType == Enum.UserInputType.Touch then
                    screenPos = activeInput.Position
                end

                local mouse = toGuiPosition(screenPos)
                local percent = (mouse.X - container.AbsolutePosition.X) / (container.AbsoluteSize.X)

                percent = math.clamp(percent, 0, 1)
                percent = tonumber(string.format("%.2f", percent))

                if first then
                    container.sliderBar.circleBorder.Position = UDim2.new(((sDefault - min) / (max - min)), -4, 0, -4)
                    container.sliderBar.moveBar.Size = UDim2.new(((sDefault - min) / (max - min)), -4, 0, 2)
                    first = false
                end

                container.sliderBar.circleBorder.Position = UDim2.new(math.clamp(percent, 0, 1), -4, 0, -4)
                container.sliderBar.moveBar.Size = UDim2.new(math.clamp(percent, 0, 1), -4, 0, 2)

                local num = min + (max - min) * percent
                local value = math.floor(num)

                textBox.Parent.Parent:TweenSizeAndPosition((string.len(tostring(value)) > 3 and UDim2.new(0, 45, 0, 15)) or UDim2.new(0, 30, 0, 15), (string.len(tostring(value)) > 3 and UDim2.new(0, 140, 0, 4)) or UDim2.new(0, 155, 0, 4), 'Out', 'Quad', 0.15, true)

                textBox.Text = value
                sLocation[sFlag] = tonumber(value)
                sCallback(sLocation[sFlag])
            end)
        end

        local function stop()
            if renderStepped then renderStepped:Disconnect() end
            renderStepped = nil
        end

        local function pressEnded(input)
            if not connected or input ~= activeInput then return end
            connected = false
            activeInput = nil
            setScrollingEnabled(container, true)
            stop()
        end

        local function pressBegan(input)
            if not isPrimaryInput(input) then return end
            if connected and activeInput == input then return end

            activeInput = input
            connected = true
            setScrollingEnabled(container, false)
            update()

            input.Changed:Connect(function()
                local state = input.UserInputState
                if state == Enum.UserInputState.End or state == Enum.UserInputState.Cancel then
                    pressEnded(input)
                end
            end)

            local pressEndedConn
            pressEndedConn = userInputService.InputEnded:Connect(function(ended)
                if ended == input then
                    pressEndedConn:Disconnect()
                    pressEnded(input)
                end
            end)
        end

        container.InputBegan:Connect(pressBegan)
        container.InputEnded:Connect(pressEnded)
        container.sliderBar.InputBegan:Connect(pressBegan)
        container.sliderBar.InputEnded:Connect(pressEnded)
        container.sliderBar.moveBar.InputBegan:Connect(pressBegan)
        container.sliderBar.moveBar.InputEnded:Connect(pressEnded)
        container.sliderBar.circleBorder.InputBegan:Connect(pressBegan)
        container.sliderBar.circleBorder.InputEnded:Connect(pressEnded)

        local step = options.step or 1

        local function setValue(v)
            v = math.floor(math.clamp(tonumber(v) or min, min, max))
            sLocation[sFlag] = v
            textBox.Text = tostring(v)

            local p = (max > min) and ((v - min) / (max - min)) or 0
            container.sliderBar.circleBorder.Position = UDim2.new(math.clamp(p, 0, 1), -4, 0, -4)
            container.sliderBar.moveBar.Size = UDim2.new(math.clamp(p, 0, 1), -4, 0, 2)
            sCallback(v)
        end

        onPress(newSlider.border.frame.minus, function()
            setValue((sLocation[sFlag] or min) - step)
        end)

        onPress(newSlider.border.frame.plus, function()
            setValue((sLocation[sFlag] or min) + step)
        end)

        textBox:GetPropertyChangedSignal("Text"):Connect(function()
            textBox.Text = textBox.Text:gsub("[^%-%d]", "")
            textBox.Parent.Parent:TweenSizeAndPosition((string.len(textBox.Text) > 3 and UDim2.new(0, 45, 0, 15)) or UDim2.new(0, 30, 0, 15), (string.len(textBox.Text) > 3 and UDim2.new(0, 140, 0, 4)) or UDim2.new(0, 155, 0, 4), 'Out', 'Quad', 0.15, true)
        end)

        textBox.FocusLost:Connect(function(enterPressed)
            if not enterPressed then return end

            textBox.Text = math.floor(math.clamp(tonumber(textBox.Text), min, max))
            textBox.Parent.Parent:TweenSizeAndPosition((string.len(textBox.Text) > 3 and UDim2.new(0, 45, 0, 15)) or UDim2.new(0, 30, 0, 15), (string.len(textBox.Text) > 3 and UDim2.new(0, 140, 0, 4)) or UDim2.new(0, 155, 0, 4), 'Out', 'Quad', 0.15, true)
            sLocation[sFlag] = tonumber(textBox.Text)
            sCallback(sLocation[sFlag])

            container.sliderBar.circleBorder:TweenPosition(UDim2.new(((math.floor(math.clamp(tonumber(textBox.Text), min, max)) - min) / (max - min)), -4, 0, -4), 'Out', 'Quad', 0.15, true)
            container.sliderBar.moveBar:TweenSize(UDim2.new(((math.floor(math.clamp(tonumber(textBox.Text), min, max)) - min) / (max - min)), -4, 0, 2), 'Out', 'Quad', 0.15, true)
        end)
    end

    function tabs:dropdown(name, useToggles, options, callback)
        local location = options.location or self.flags
        local flag = not useToggles and options.flag or ""
        local callback = callback or function() end
        local list = {}

        for i,v in ipairs(options.list or {}) do
            if type(v) == "table" then
                local item = {}
                for key,value in pairs(v) do
                    item[key] = value
                end
                item.Name = tostring(v.Name or v.name or v[1] or ("Option " .. i))
                item.flag = v.flag or item.Name
                table.insert(list,item)
            else
                local itemName = tostring(v)
                table.insert(list,{
                    Name = itemName;
                    flag = itemName;
                })
            end
        end

        local default

        if useToggles then
            local defaults = type(options.default) == "table" and options.default or {}

            for _,item in ipairs(list) do
                if location[item.flag] == nil then
                    local configured = defaults[item.flag]
                    if configured == nil then
                        configured = table.find(defaults,item.Name) ~= nil
                    end
                    location[item.flag] = configured == true
                end
            end

            default = name
        else
            default = options.default or (list[1] and list[1].Name) or "None"
        end

        if not useToggles then
            location[flag] = default
        end

        local newDropdown = library:createElement("Frame", {
            Name = name;
            Size = UDim2.new(0, 200, 0, 35);
            BackgroundTransparency = 1;
            LayoutOrder = self:getOrder();
            library:createElement("ImageLabel", {
                Name = "border";
                Size = UDim2.new(1, 0, 0, 26);
                Position = UDim2.new(0, 0, 0, 5);
                BackgroundTransparency = 1;
                Image = "rbxassetid://4894670678";
                ImageColor3 = Color3.fromRGB(28, 28, 28);
                ImageTransparency = 0.5;
                ScaleType = Enum.ScaleType.Slice;
                SliceCenter = Rect.new(5, 5, 434, 297);
                ZIndex = 2;
                library:createElement("ImageButton", {
                    Name = "frame";
                    Size = UDim2.new(1, -2, 1, -2);
                    Position = UDim2.new(0, 1, 0, 1);
                    BackgroundTransparency = 1;
                    Image = "rbxassetid://4894670678";
                    ImageColor3 = Color3.fromRGB(16, 16, 16);
                    ScaleType = Enum.ScaleType.Slice;
                    SliceCenter = Rect.new(5, 5, 434, 297);
                    ZIndex = 2;
                    library:createElement("TextLabel", {
                        Name = "label";
                        Size = UDim2.new(1, -10, 0, 25);
                        Position = UDim2.new(0, 10, 0, 0);
                        Text = default;
                        TextColor3 = Color3.fromRGB(250, 250, 250);
                        TextSize = 12;
                        TextWrapped = true;
                        Font = Enum.Font.GothamSemibold;
                        TextXAlignment = Enum.TextXAlignment.Left;
                        BackgroundTransparency = 1;
                        ZIndex = 2;
                    })
                })
            });
            Parent = self.container;
        })

        local arrow = library:createElement("ImageLabel", {
            Name = "arrow";
            Size = UDim2.new(0, 11, 0, 6);
            Position = UDim2.new(1, -25, 0, 10);
            BackgroundTransparency = 1;
            Image = "rbxassetid://5882688826";
            ImageColor3 = Color3.fromRGB(190, 190, 190);
            ZIndex = 2;
            Parent = newDropdown.border;
        })

        -- รายการดรอปดาว์น = แผ่นลอยทับด้านล่าง (ไม่ดัน UI ให้ขยาย) สูงสุด 5 แถว เลื่อนดูได้ แบบ Wind UI
        local container = library:createElement("Frame", {
            Name = "containerFrame";
            Size = UDim2.new(1, 0, 0, 0);
            Position = UDim2.new(0, 0, 0, 31);
            BackgroundTransparency = 1;
            ZIndex = 20;
            ClipsDescendants = true;
            library:createElement("ImageLabel", {
                Name = "containerBorder";
                Size = UDim2.new(1, 0, 1, 0);
                Position = UDim2.new(0, 0, 0, 0);
                BackgroundTransparency = 1;
                Image = "rbxassetid://4894670678";
                ImageColor3 = Color3.fromRGB(35, 35, 35);
                ImageTransparency = 0.15;
                ScaleType = Enum.ScaleType.Slice;
                SliceCenter = Rect.new(5, 5, 434, 297);
                ClipsDescendants = true;
                ZIndex = 1;
                library:createElement("ImageLabel", {
                    Name = "container";
                    Size = UDim2.new(1, -2, 1, -2);
                    Position = UDim2.new(0, 1, 0, 1);
                    BackgroundTransparency = 1;
                    Image = "rbxassetid://4894670678";
                    ImageColor3 = Color3.fromRGB(18, 18, 18);
                    ImageTransparency = 0.02;
                    ScaleType = Enum.ScaleType.Slice;
                    SliceCenter = Rect.new(5, 5, 434, 297);
                    ClipsDescendants = true;
                    ZIndex = 1;
                    library:createElement("ScrollingFrame", {
                        Name = "scroll";
                        Size = UDim2.new(1, -10, 1, -10);
                        Position = UDim2.new(0, 5, 0, 5);
                        CanvasSize = UDim2.new(0, 0, 0, #list * 32 + 2);
                        ScrollingEnabled = #list > 5;
                        ScrollBarThickness = (#list > 5 and 2) or 0;
                        ScrollBarImageTransparency = (#list > 5 and 0.2) or 1;
                        ScrollingDirection = Enum.ScrollingDirection.Y;
                        ElasticBehavior = Enum.ElasticBehavior.Never;
                        BackgroundTransparency = 1;
                        library:createElement("UIListLayout", {
                            Name = "list";
                            SortOrder = 2;
                            Padding = UDim.new(0, 2);
                            HorizontalAlignment = Enum.HorizontalAlignment.Center;
                        })
                    })
                })
            });
            Parent = newDropdown;
        })

        if options.icon then
            local iconLabel = library:createElement("ImageLabel", {
                Name = "icon";
                Size = UDim2.new(0, 16, 0, 16);
                Position = UDim2.new(0, 10, 0, 4);
                BackgroundTransparency = 1;
                ImageColor3 = "@theme";
                ZIndex = 2;
                Parent = newDropdown.border.frame;
            })
            applyIcon(iconLabel, options.icon)
            newDropdown.border.frame.label.Position = UDim2.new(0, 32, 0, 0)
            newDropdown.border.frame.label.Size = UDim2.new(1, -42, 0, 25)
        end

        local border = newDropdown:WaitForChild("border")
        local button = border:WaitForChild("frame")
        local label = button:WaitForChild("label")

        local dropDown = {
            toggled = false;
            object = newDropdown;
            border = border;
            label = label;
            arrow = arrow;
            container = container.containerBorder.container.scroll;
            l = location;
            f = flag;
            usesToggles = useToggles;
        }
        table.insert(dropList, dropDown)

        for i,v in pairs(list) do
            -- แถวตัวเลือกแบบ WindUI (TabItem): แถมมน, ตัวหนังสือจางเมื่อยังไม่เลือก, เลือกแล้วสว่าง + ✓ แดง
            local listItem = library:createElement("TextButton", {
                Name = v.Name;
                Size = UDim2.new(1, -8, 0, 30);
                BackgroundTransparency = 1;
                Image = "rbxassetid://4894670678";
                ImageColor3 = Color3.fromRGB(45, 45, 45);
                ImageTransparency = 1;
                ScaleType = Enum.ScaleType.Slice;
                SliceCenter = Rect.new(5, 5, 434, 297);
                Text = "";
                AutoButtonColor = false;
                LayoutOrder = i;
                ZIndex = 2;
                library:createElement("TextLabel", {
                    Name = "title";
                    Size = UDim2.new(1, -44, 1, 0);
                    Position = UDim2.new(0, 12, 0, 0);
                    BackgroundTransparency = 1;
                    Text = v.Name;
                    TextColor3 = Color3.fromRGB(250, 250, 250);
                    TextSize = 12;
                    Font = Enum.Font.GothamSemibold;
                    TextXAlignment = Enum.TextXAlignment.Left;
                    TextTruncate = Enum.TextTruncate.AtEnd;
                    TextTransparency = 0.4;
                    ZIndex = 2;
                });
                library:createElement("TextLabel", {
                    Name = "mark";
                    Size = UDim2.new(0, 16, 1, 0);
                    Position = UDim2.new(1, -24, 0, 0);
                    BackgroundTransparency = 1;
                    Text = "✓";
                    TextColor3 = Color3.fromRGB(255, 59, 59);
                    TextSize = 12;
                    Font = Enum.Font.GothamBold;
                    TextTransparency = 1;
                    ZIndex = 2;
                });
                Parent = dropDown.container;
            })

            local function applyVisual(selected)
                listItem.ImageTransparency = (selected and 0.7) or 1
                listItem.title.TextTransparency = (selected and 0) or 0.4
                listItem.mark.TextTransparency = (selected and 0) or 1
            end

            applyVisual((useToggles and location[v.flag]) or ((not useToggles) and v.Name == default))

            local function switch()
                if useToggles then
                    location[v.flag] = not location[v.flag]
                    callback(location[v.flag], v.Name, v.flag)
                    applyVisual(location[v.flag])
                else
                    for _, other in pairs(dropDown.container:GetChildren()) do
                        if other:IsA("TextButton") and other ~= listItem then
                            other.ImageTransparency = 1
                            other.title.TextTransparency = 0.4
                            other.mark.TextTransparency = 1
                        end
                    end

                    applyVisual(true)

                    dropDown.toggled = false

                    button.label.TextTransparency = 0
                    button.label.Text = v.Name


                    dropDown.arrow.Rotation = 0
                    newDropdown.ZIndex = 1
                    container:TweenSize(UDim2.new(1, 0, 0, 0), "In", "Quad", 0.15, true)
                    
                    location[flag] = v.Name
                    callback(location[flag])
                end
            end

            onPress(listItem, switch)
        end

        -- ตัวรับทัชอยู่ในปุ่มโดยตรง (แบบเดียวกับ toggle ที่กดได้แล้ว)
        onPress(button, function()
            dropDown.toggled = not dropDown.toggled

            if not useToggles then
                dropDown.label.TextTransparency = (dropDown.toggled and 0.5) or 0
                dropDown.label.Text = (dropDown.toggled and name) or location[flag]
            end

            -- สูงสุด 5 แถวแบบ WindUI (เกินนั้นเลื่อนดูในแผ่น) + เผื่อขอบ/ระยะห่าง
            local y = math.min(#list, 5) * 32 + 10

            for i,v in pairs(dropList) do
                if v ~= dropDown and v.toggled then 
                    v.toggled = false
                    v.object.ZIndex = 1
                    
                    v.arrow.Rotation = 0;
                    v.container.Parent.Parent.Parent:TweenSize(UDim2.new(1, 0, 0, 0), "In", "Quad", 0.15, true)
                    wait(0.15)

                    if not v.usesToggles then
                        v.label.TextTransparency = 0
                        v.label.Text = v.l[v.f]
                    end
                end
            end

            dropDown.arrow.Rotation = (dropDown.toggled and 180) or 0
            newDropdown.ZIndex = (dropDown.toggled and 30) or 1
            container:TweenSize(UDim2.new(1, 0, 0, (dropDown.toggled and y) or 0), (dropDown.toggled and "Out") or "In", "Quad", 0.15, true)
        end)

        userInputService.InputBegan:Connect(function(input)
            if not isPrimaryInput(input) then return end
            if not dropDown.toggled or (isInGui(dropDown.border, input.Position) or isInGui(container.containerBorder, input.Position)) then return end

            dropDown.toggled = false

            if not useToggles then
                dropDown.label.TextTransparency = 0
                dropDown.label.Text = location[flag]
            end

            newDropdown.ZIndex = 1
            container:TweenSize(UDim2.new(1, 0, 0, 0), "In", "Quad", 0.15, true)

            dropDown.arrow.Rotation = 0
        end)
    end

    function library:setTheme(color)
        if type(color) == "string" then
            color = Color3.fromHex(color)
        end

        self.themeColor = color

        for _, entry in ipairs(self.themeElements) do
            applyTheme(entry.obj, entry.prop)
        end
    end

    function library:createElement(class, data)
        local obj = Instance.new(class)
        
        for i,v in pairs(data) do
            if i ~= "Parent" then
            
                if typeof(v) == "Instance" then
                    v.Parent = obj
                elseif v == "@theme" then
                    registerTheme(obj, i)
                else
                    obj[i] = v
                end
            end
        end
        
        obj.Parent = data.Parent
        return obj
    end
    
    function library:createWindow(name, icon, subtitle)
        if not library.container then
            library.container = self:createElement("ScreenGui", {
                IgnoreGuiInset = true;
                self:createElement("Frame", {
                    Name = "Container";
                    Size = UDim2.new(1, -30, 1, 0);
                    Position = UDim2.new(0, 20, 0, 20);
                    BackgroundTransparency = 1;
                    Active = false;
                });
            }):FindFirstChild("Container")
        end

        if syn and syn.protect_gui then
            syn.protect_gui(library.container.Parent)
        end

        library.container.Parent.Parent = game:GetService("CoreGui");

        if not library.options then
            library.options = setmetatable({}, {__index = defaults})
        end

        if getgenv then
            getgenv().ui = library.container
        end

        local window = main:window(name, icon, subtitle)
        return window
    end

    function library:notify(title, text, timeout)
        local timeout = timeout or 5

        local notification = library:createElement("ImageLabel", {
            Name = "border";
            Size = UDim2.new(0, 200, 0, 75);
            Position = UDim2.new(1.1, 0, 0.87, 0);
            BackgroundTransparency = 1;
            Image = "rbxassetid://4894670678";
            ImageColor3 = "@theme";
            ImageTransparency = 0.35;
            ScaleType = Enum.ScaleType.Slice;
            SliceCenter = Rect.new(5, 5, 434, 297);
            library:createElement("ImageLabel", {
                Name = "frame";
                Size = UDim2.new(1, -2, 1, -2);
                Position = UDim2.new(0, 1, 0, 1);
                BackgroundTransparency = 1;
                Image = "rbxassetid://4894670678";
                ImageColor3 = Color3.fromRGB(10, 10, 10);
                ScaleType = Enum.ScaleType.Slice;
                SliceCenter = Rect.new(5, 5, 434, 297);
                ClipsDescendants = true;
                library:createElement("ImageLabel", {
                    Name = "topBorder";
                    Size = UDim2.new(1, 0, 0, 30);
                    Position = UDim2.new(0, 0, 0, 0);
                    Image = "rbxassetid://4892463081";
                    ImageColor3 = Color3.fromRGB(16, 16, 16);
                    ScaleType = Enum.ScaleType.Slice;
                    SliceCenter = Rect.new(5, 5, 434, 125);
                    BackgroundTransparency = 1;
                    library:createElement("TextLabel", {
                        Name = "title";
                        Size = UDim2.new(0, 200, 0, 30);
                        Position = UDim2.new(0, 15, 0, 0);
                        Text = title;
                        TextWrapped = true;
                        TextXAlignment = Enum.TextXAlignment.Left;
                        TextColor3 = Color3.fromRGB(250, 250, 250);
                        Font = Enum.Font.GothamSemibold;
                        TextSize = 14;
                        BackgroundTransparency = 1;
                    });
                    library:createElement("Frame", {
                        Name = "line";
                        Size = UDim2.new(1, 0, 0, 2);
                        Position = UDim2.new(0, 0, 1, -2);
                        BorderSizePixel = 0;
                        BackgroundColor3 = Color3.fromRGB(28, 28, 28);
                    })
                });
                library:createElement("TextLabel", {
                    Name = "text";
                    Size = UDim2.new(0, 180, 0, 40);
                    Position = UDim2.new(0, 10, 0, 30);
                    Text = text;
                    TextColor3 = Color3.fromRGB(250, 250, 250);
                    TextWrapped = true;
                    Font = Enum.Font.GothamSemibold;
                    TextSize = 12;
                    BackgroundTransparency = 1;
                })
            });
            Parent = library.container;
        })
        spawn(function()
            wait(0.2)

            notification:TweenPosition(UDim2.new(0.88, 0, 0.87, 0), "In", "Quad", 0.25, true)

            wait(timeout)

            notification:TweenPosition(UDim2.new(1.1, 0, 0.87, 0), "In", "Quad", 0.25, true)

            wait(0.25)

            notification:Destroy()
        end)
    end

    local function isReallyPressed(bind, input)
        if typeof(bind) == "Instance" then
            if bind.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == bind.KeyCode then
                return true
            elseif tostring(bind.UserInputType):find("MouseButton") and input.UserInputType == bind.UserInputType then
                return true
            end
        end

        if tostring(bind):find("MouseButton1") then
            return bind == input.UserInputType
        else
            return bind == input.KeyCode
        end
    end

    userInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.RightControl then
            library.toggled = not library.toggled
            --library.container:TweenPosition(UDim2.new(0, (library.toggled and 20) or (-30 - (library.container:GetChildren()[1].frame.AbsolutePosition.X + library.container:GetChildren()[1].frame.AbsoluteSize.X)), 0, library.container.AbsolutePosition.Y), "Out", "Quad", 0.15, true)
            library.container.Visible = not library.container.Visible
        end

        if library.binding then return end

        for i,v in pairs(library.binds) do
            if v.location[i] ~= nil then

                local realBinding = v.location[i]

                if realBinding and isReallyPressed(realBinding, input) then
                    v.call()
                end

            end
        end
    end)

    return library
end
