--==================================================
-- ตัวอย่างการใช้ Sixly UI Library (ฉบับแก้บัคมือถือแล้ว)
-- วิธีใช้: รันสคริปต์นี้ใน executor ได้เลย
--==================================================

-- โหลด library (ใช้ URL ของ repo คุณเอง)
-- ⚠️ สำคัญมาก: ใส่ true (nocache) + เลขเวลาท้าย URL = ป้องกัน executor/CDN แคชไฟล์เก่า
local library = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/x9msms/X9msUilib/refs/heads/main/library/ui.lua?" .. tostring(os.time()),
    true
))()
assert(library and library.version == "windui-3", "ได้ไฟล์เก่า! ลองรันใหม่/เปลี่ยนไปใช้ library/v4.lua")

-- สร้างหน้าต่าง UI (พารามิเตอร์ที่ 2 = ไอค่อน ไม่ใส่ก็ได้)
-- ชื่อไอค่อนดูได้ที่ https://github.com/Footagesus/Icons (lucide เป็นค่าเริ่มต้น)
-- หน้าต่างขนาดคงที่ 392x380 — ลาก "มุมล่างขวา" เพื่อปรับขนาด (เนื้อหาในแท็บเลื่อนได้)
local window = library:createWindow("My Script", "gamepad-2", "Dungeon: Northern Lands")  -- ชื่อ, ไอคอน, คำโปรยใต้ชื่อ

-- หัวข้อในแถบเมนูด้านซ้าย
window:section("General")

-- สร้างแท็บ -- แต่ละแท็บพับ/กางได้
local main = window:newTab("Main", "house")
local farming = window:newTab("Farming", "wheat")
window:section("Utilities")
local settings = window:newTab("Settings", "settings")

-- ตารางเก็บค่า (ใช้ location + flag เพื่อเข้าถึงค่าภายหลัง)
local flags = {}

--=========================
-- 1) Label (ข้อความ)
--=========================
local info = main:label("info", "ยินดีต้อนรับ! ใช้ได้ทั้ง PC และมือถือ")

-- เปลี่ยนข้อความภายหลังได้:
-- info:changeText("ข้อความใหม่")

--=========================
-- 2) Button (ปุ่มกด)
--=========================
main:button("กดฉัน", function()
    library:notify("Button", "คุณกดปุ่มแล้ว!", 2)
end, "mouse-pointer-click")  -- พารามิเตอร์สุดท้าย = ไอค่อน (ไม่ใส่ก็ได้)

--=========================
-- 3) Toggle (สวิตช์ เปิด/ปิด)
--=========================
farming:toggle("Auto Farm", {
    default = false;      -- ค่าเริ่มต้น
    location = flags;     -- เก็บค่าไว้ใน flags
    flag = "auto_farm";   -- เรียกใช้ flags.auto_farm
    icon = "tractor";     -- ไอค่อน (ไม่ใส่ก็ได้)
}, false, nil, function(value)
    print("Auto Farm =", value)
end)

-- Toggle ผูกคีย์ลัด (กดปุ่มเพื่อสลับสถานะ) -- PC ใช้คีย์บอร์ด/เมาส์
farming:toggle("Speed Boost", {
    default = false;
    location = flags;
    flag = "speed";
}, true, {
    flag = "speed_bind";
    default = Enum.KeyCode.LeftControl;  -- กด LeftCtrl เพื่อสลับ
    -- kbonly = true;                    -- เปิดถ้าอยากให้ผูกได้เฉพาะคีย์บอร์ด
}, function(value)
    print("Speed =", value)
end)

-- Toggle สไตล์ "การ์ด" (ไอคอน + ชื่อ + คำโปรย + สวิตช์ pill แดงไล่สี) แบบในภาพ
farming:toggle("Combat", {
    default = true;
    location = flags;
    flag = "combat";
    card = true;              -- แสดงแบบการ์ด + สวิตช์ pill
    subtitle = "Dungeon Farming";
    icon = "swords";
}, false, nil, function(value)
    print("Combat =", value)
end)

--=========================
-- 4) Slider (เลื่อนค่า)
--=========================
farming:slider("WalkSpeed", {
    min = 16;
    max = 200;
    default = 16;
    step = 1;                 -- จำนวนที่เพิ่ม/ลดต่อการกดปุ่ม - / +
    location = flags;
    flag = "walkspeed";
}, function(value)
    print("WalkSpeed =", value)
    -- LocalPlayer.Character.Humanoid.WalkSpeed = value
end)

-- Slider พร้อม toggle ในตัว
farming:slider("Jump Power", {
    min = 50;
    max = 300;
    default = 50;
    location = flags;
    flag = "jumppower";
}, function(value)
    print("JumpPower =", value)
end, true, {
    flag = "jump_enabled";
    default = false;
    callback = function(on)
        print("เปิดใช้งาน Jump =", on)
    end;
})

--=========================
-- 5) TextBox (ช่องพิมพ์)
--=========================
settings:textbox("ชื่อผู้เล่น", {
    default = "พิมพ์ที่นี่";
    location = flags;
    flag = "player_name";
}, function(text)
    print("ข้อความที่พิมพ์ =", text)
end)
-- * หมายเหตุ: ต้องกด Enter เพื่อยืนยันข้อความ (callback ถึงจะทำงาน)

--=========================
-- 6) Dropdown (เมนูเลือก)
--=========================

-- 6.1 เลือกได้ทีละอัน (useToggles = false)
settings:dropdown("เลือกอาวุธ", false, {
    list = {"ดาบ", "ปืน", "ระเบิด", "ธนู"};
    default = "ดาบ";
    location = flags;
    flag = "weapon";
    icon = "swords";      -- ไอค่อน (ไม่ใส่ก็ได้)
}, function(value)
    print("อาวุธ =", value)
end)

-- 6.2 เลือกได้หลายอัน (useToggles = true)
settings:dropdown("เลือกหลายอย่าง", true, {
    list = {"Common", "Rare", "Epic", "Legendary", "Mythic"};
    default = {"Rare", "Epic"};     -- ติ๊กถูกเริ่มต้น
    location = flags;               -- flags["Rare"] = true/false
}, function(enabled, name, flag)
    print(name, "=", enabled)
end)

--=========================
-- 7) ColorSelector (เลือกสี)
--=========================
settings:colorSelector("สีธีม", {
    default = Color3.fromRGB(255, 59, 59);  -- สีแดง (ค่าเริ่มต้น)
    location = flags;
    flag = "theme_color";
}, function(color)
    library:setTheme(color)   -- เปลี่ยนสีธีมทั้ง UI ทันที (ปุ่ม/ติ๊กถูก/แถบ slider)
end)

--=========================
-- 9) ระบบไอค่อน (Footagesus/Icons)
--    ชื่อไอค่อน: https://github.com/Footagesus/Icons
--=========================

-- ดึง "rbxassetid://..." ไปใช้เอง
local iconId = library.icons.GetIcon("rocket")
print("icon:", iconId)

-- ระบุ pack:name (lucide, solar, craft, geist, sfsymbols, gravity)
local sfIcon = library.icons.GetIcon("sfsymbols:HouseFill")
local geistIcon = library.icons.GetIcon("geist:accessibility-unread")

-- เปลี่ยน pack เริ่มต้น (ค่าเริ่มต้นคือ lucide)
-- library.icons.SetIconsType("solar")

-- สร้าง ImageLabel ไอค่อนพร้อมสี (รองรับไอค่อนหลายสีอย่าง geist)
local iconObj = library.icons.Image({
    Icon = "house";
    Size = UDim2.fromOffset(24, 24);
    Colors = { Color3.fromRGB(255, 255, 255) };
})
-- iconObj.IconFrame.Parent = <ScreenGui ของคุณ>

--=========================
-- 10) Notification (แจ้งเตือน)
--     library:notify(หัวข้อ, ข้อความ, วินาที)
--=========================
library:notify("โหลดสำเร็จ!", "UI พร้อมใช้งานแล้ว", 3)

-- กางแท็บแรกออกอัตโนมัติ (ไม่ต้องกดเอง)
main.spFuncs:SimClck()

--=========================
-- เข้าถึงค่าภายหลัง
--=========================
print("auto_farm =", flags.auto_farm)
print("walkspeed =", flags.walkspeed)
print("weapon =", flags.weapon)

--[[
    สรุป API ทั้งหมด:
      library:createWindow(name, icon?, subtitle?)   -> window
      window:section(name)                           -> หัวข้อในแถบเมนูด้านซ้าย
      window:newTab(name, icon?)                   -> tab
      tab:label(name, text)                        -> label (:changeText(text))
      tab:button(name, callback, icon?)
      tab:toggle(name, options, useBind, bindOptions, callback)   -- options.icon / card = true (สวิตช์ pill + คำโปรย) / subtitle = "..."
      tab:slider(name, options, callback, useToggle, toggleOptions)
      tab:textbox(name, options, callback)
      tab:dropdown(name, useToggles, options, callback)           -- options.icon = "..."
      tab:colorSelector(name, options, callback)
      library:notify(title, text, timeout)
      library:setTheme(colorOrHex)             -> เปลี่ยนสีธีม (แบบไล่สี) ทั้ง UI (ค่าเริ่มต้น: แดง)
      library.themeColor                       -> สีธีมปัจจุบัน
      library.icons.GetIcon("house")               -> "rbxassetid://..."
      library.icons.GetIcon("geist:house")         -> ระบุ pack:name
      library.icons.SetIconsType("solar")          -> เปลี่ยน pack เริ่มต้น
      library.icons.Image({...})                   -> { IconFrame } (ไอค่อนหลายสี)
      tab.spFuncs:SimClck()                        -> พับ/กางแท็บ

    ชื่อไอค่อน: https://github.com/Footagesus/Icons
    pack ที่มี: lucide (ค่าเริ่มต้น), solar, craft, geist, sfsymbols, gravity

    การใช้งาน UI:
      พื้นหลังดำสนิท + ธีมแดงไล่สี (gradient) เป็นค่าเริ่มต้น (ปรับได้ด้วย library:setTheme)
      หน้าต่างขนาดคงที่ (392x380) ไม่ขยายตามแท็บ
      ลากมุมล่างขวา = ปรับขนาดหน้าต่าง (ขั้นต่ำ 390x220)
      เนื้อหาในแท็บ/รายชื่อด้านซ้าย = เลื่อนดูได้เมื่อยาวเกิน
      RightControl = ซ่อน/แสดง UI
]]
