
-- CONFIG ⚙️
local CONFIG = {
    PreventDuplicateRunLoader = true  -- เปิด/ปิดป้องกันรันซ้ำสำหรับ Loader 🚫
}

-- Table การรองรับป้องกันรันซ้ำตามเวอร์ชัน 📋
local SupportPreventDuplicate = {
    New = false,  -- ไม่รับรอง 🚫
    Old = false,  -- ไม่รับรอง 🚫
    Dev = true    -- รับรอง ✅
}

-- ป้องกันรันซ้ำสำหรับ Loader 📛
if _G.CollectModuleInstalled then
    print("[CollectModule Loader V2.0.1] Module already installed! Skipping load. 🚫")
    return
elseif _G.CollectLoaderLoaded then
    if CONFIG.PreventDuplicateRunLoader then
        print("[CollectModule Loader V2.0.1] Script already loaded! Skipping duplicate run. 🚫")
        return
    else
        print("[CollectModule Loader V2.0.1] Duplicate run allowed, resetting... ♻️")
        if _G.CollectModule then
            local ok, err = pcall(function()
                if _G.CollectModule.ResetModule then
                    _G.CollectModule.ResetModule()
                end
            end)
            if not ok then
                print("[CollectModule Loader V2.0.1] Reset error:", err, "🔴")
            end
            _G.CollectModule = nil
        end
    end
end

-- SERVICES 🌐
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- โหมดปกติที่เลือกเอง
local Mode = "New"  -- "Old" / "New" / จะถูก override ถ้า user พิเศษ

-- เปิด/ปิด Dev Mode (แม้จะมีชื่อใน DevUsers ก็ตาม)
local EnableDevMode = true  -- true = เปิด, false = ปิด

-- ลิงก์ของแต่ละเวอร์ชัน
local Links = {  
    New = "https://raw.githubusercontent.com/wino444/wino444_CollectModule/main/CollectModule_New.lua",  
    Old = "https://raw.githubusercontent.com/wino444/wino444_CollectModule/main/CollectModule_Old.lua",  
    Dev = "https://raw.githubusercontent.com/wino444/wino444_CollectModule/main/CollectModule_Dev.lua"  
}

-- รายชื่อคนที่จะบังคับใช้ Dev
local DevUsers = {
    ["ojhvhknhj"] = true,
    ["AniF_Xx"] = false  -- เพิ่ม AniF_Xx เพื่อให้เข้าถึงโหมด Dev ✅
}

-- ฟังก์ชัน debugPrint 🖥️
local function debugPrint(...)
    print("[CollectModule Loader V2.0.1] 🚀", ...)
end

-- ฟังก์ชันโหลด Module
local function LoadModule(mode)
    local url = Links[mode]
    if not url then
        debugPrint("❌ ไม่เจอลิงก์สำหรับโหมด:", mode)
        return nil
    end

    local success, response = pcall(function()
        return game:HttpGet(url, 10) -- เพิ่ม timeout 10 วินาที
    end)

    if not success then
        debugPrint("⚠️ การโหลดล้มเหลว:", response)
        return nil
    end

    local moduleFunc, loadErr = loadstring(response)
    if not moduleFunc then
        debugPrint("❌ โหลดสคริปต์ไม่สำเร็จ:", loadErr)
        return nil
    end

    local ok, module = pcall(moduleFunc)
    if not ok then
        debugPrint("❌ Module มี error ตอนรัน:", module)
        return nil
    end

    debugPrint("✅ โหลด", mode, "สำเร็จ!")
    return module
end

-- ตรวจสอบว่าเป็น DevUser + DevMode เปิดอยู่ไหม
if EnableDevMode and DevUsers[LocalPlayer.Name] then
    Mode = "Dev"
    debugPrint("[Dev] 🚧 กำลังใช้เวอร์ชันทดสอบ")
elseif DevUsers[LocalPlayer.Name] then
    debugPrint("[Dev] ⚠️ DevUser แต่ DevMode ปิดอยู่ – ใช้โหมดปกติ")
end

-- ตรวจสอบการรองรับ PreventDuplicateRun และปรับ CONFIG ถ้าจำเป็น
if CONFIG.PreventDuplicateRunLoader and not SupportPreventDuplicate[Mode] then
    debugPrint("⚠️ เวอร์ชัน", Mode, "ไม่รองรับ PreventDuplicateRun – ปิดการป้องกันอัตโนมัติเพื่อความปลอดภัย!")
    CONFIG.PreventDuplicateRunLoader = false
end

-- เริ่มโหลด
local CollectModule = LoadModule(Mode)
if CollectModule then
    _G.CollectModule = CollectModule  -- ตั้ง global เพื่อ sync กับ AutoCollect
    _G.CollectModuleInstalled = true  -- ตั้ง flag ว่าติดตั้งสำเร็จ
    debugPrint("🚀 Module พร้อมใช้งาน! Version:", CollectModule.GetVersion and CollectModule.GetVersion() or "Unknown")
else
    debugPrint("❌ การโหลด Module ล้มเหลว!")
end

-- ตั้ง flag ว่า loader โหลดแล้ว
_G.CollectLoaderLoaded = true

-- แสดง table การรองรับใน log สำหรับความชัดเจน 📊
debugPrint("SupportPreventDuplicate Table: New =", SupportPreventDuplicate.New and "✅" or "🚫", ", Old =", SupportPreventDuplicate.Old and "✅" or "🚫", ", Dev =", SupportPreventDuplicate.Dev and "✅" or "🚫")
debugPrint("Loader loaded successfully! Prevent Duplicate Run:", CONFIG.PreventDuplicateRunLoader and "On 🚫" or "Off ♻️", "Module Installed:", _G.CollectModuleInstalled and "Yes ✅" or "No 🚫")
