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
