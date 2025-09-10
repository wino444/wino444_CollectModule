-- CONFIG ⚙️
local CONFIG = {
    PreventDuplicateRunLoader = true, -- ป้องกันรันซ้ำสำหรับ Loader 🚫
    LoadChatSystem = true,           -- เปิด/ปิด โหลดระบบแชท 💬 (true = โหลด, false = ไม่โหลด)
    DebugEnabled = false              -- เปิด/ปิด การแจ้งเตือนดีบั๊กใน Console 🖥️ (true = แสดง, false = เงียบ)
}

-- Table การรองรับป้องกันรันซ้ำตามเวอร์ชัน 📋
local SupportPreventDuplicate = {
    New = false, -- ไม่รับรอง 🚫
    Old = false, -- ไม่รับรอง 🚫
    Dev = true   -- รับรอง ✅
}

-- ป้องกันรันซ้ำสำหรับ Loader 📛
if _G.CollectModuleInstalled then
    if CONFIG.DebugEnabled then
        print("[CollectModule Loader V2.0.3] Module already installed! Skipping load. 🚫")
    end
    return
elseif _G.CollectLoaderLoaded then
    if CONFIG.PreventDuplicateRunLoader then
        if CONFIG.DebugEnabled then
            print("[CollectModule Loader V2.0.3] Script already loaded! Skipping duplicate run. 🚫")
        end
        return
    else
        if CONFIG.DebugEnabled then
            print("[CollectModule Loader V2.0.3] Duplicate run allowed, resetting... ♻️")
        end
        if _G.CollectModule then
            local ok, err = pcall(function()
                if _G.CollectModule.ResetModule then
                    _G.CollectModule.ResetModule()
                end
            end)
            if not ok and CONFIG.DebugEnabled then
                print("[CollectModule Loader V2.0.3] Reset error:", err, "🔴")
            end
            _G.CollectModule = nil
        end
    end
end

-- SERVICES 🌐
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- โหมดปกติที่เลือกเอง
local Mode = "New" -- "Old" / "New" / จะถูก override ถ้า user พิเศษ

-- เปิด/ปิด Dev Mode
local EnableDevMode = true -- true = เปิด, false = ปิด

-- ลิงก์ของแต่ละเวอร์ชัน
local Links = {
    New = "https://raw.githubusercontent.com/wino444/wino444_CollectModule/main/CollectModule_New.lua",
    Old = "https://raw.githubusercontent.com/wino444/wino444_CollectModule/main/CollectModule_Old.lua",
    Dev = "https://raw.githubusercontent.com/wino444/wino444_CollectModule/main/CollectModule_Dev.lua"
}

-- รายชื่อ DevUsers
local DevUsers = {
    ["ojhvhknhj"] = true,
    ["AniF_Xx"] = true -- ✅
}

-- ฟังก์ชัน debugPrint 🖥️
local function debugPrint(...)
    if CONFIG.DebugEnabled then
        print("[CollectModule Loader V2.0.3] 🚀", ...)
    end
end

-- ฟังก์ชันโหลด Module หลัก
local function LoadModule(mode)
    local url = Links[mode]
    if not url then
        debugPrint("❌ ไม่เจอลิงก์สำหรับโหมด:", mode)
        return nil
    end

    local success, response = pcall(function()
        return game:HttpGet(url, 10)
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

-- ฟังก์ชันโหลด Chat System 💬 (โหลดแค่ครั้งเดียว)
local function LoadChatSystem()
    if _G.ChatSystemLoaded then
        debugPrint("💬 Chat System เคยโหลดแล้ว ข้ามรอบนี้ 🚫")
        return
    end

    local url = "https://raw.githubusercontent.com/wino444/PhantomNet/main/phantom_client.lua"
    local ok, result = pcall(function()
        return game:HttpGet(url, 10)
    end)
    if not ok then
        debugPrint("⚠️ โหลด Chat System ไม่สำเร็จ:", result)
        return
    end

    local func, err = loadstring(result)
    if not func then
        debugPrint("❌ แปลง Chat System error:", err)
        return
    end

    local ran, runErr = pcall(func)
    if not ran then
        debugPrint("❌ Chat System run error:", runErr)
    else
        _G.ChatSystemLoaded = true
        debugPrint("💬 Chat System โหลดสำเร็จ! (ครั้งเดียว)")
    end
end

-- ตรวจสอบ DevUser
if EnableDevMode and DevUsers[LocalPlayer.Name] then
    Mode = "Dev"
    debugPrint("[Dev] 🚧 กำลังใช้เวอร์ชันทดสอบ")
elseif DevUsers[LocalPlayer.Name] then
    debugPrint("[Dev] ⚠️ DevUser แต่ DevMode ปิดอยู่ – ใช้โหมดปกติ")
end

-- ตรวจสอบการรองรับ PreventDuplicateRun
if CONFIG.PreventDuplicateRunLoader and not SupportPreventDuplicate[Mode] then
    debugPrint("⚠️ เวอร์ชัน", Mode, "ไม่รองรับ PreventDuplicateRun – ปิดการป้องกันอัตโนมัติเพื่อความปลอดภัย!")
    CONFIG.PreventDuplicateRunLoader = false
end

-- โหลด Collect Module
local CollectModule = LoadModule(Mode)
if CollectModule then
    _G.CollectModule = CollectModule
    _G.CollectModuleInstalled = true
    debugPrint("🚀 Module พร้อมใช้งาน! Version:", CollectModule.GetVersion and CollectModule.GetVersion() or "Unknown")
else
    debugPrint("❌ การโหลด Module ล้มเหลว!")
end

-- โหลด Chat System ถ้าเปิด
if CONFIG.LoadChatSystem then
    LoadChatSystem()
else
    debugPrint("💬 Chat System ถูกปิดไว้ใน CONFIG")
end

-- ตั้ง flag ว่า loader โหลดแล้ว
_G.CollectLoaderLoaded = true

-- แสดงสถานะสุดท้ายใน log 📊
debugPrint("SupportPreventDuplicate Table: New =", SupportPreventDuplicate.New and "✅" or "🚫",
    ", Old =", SupportPreventDuplicate.Old and "✅" or "🚫",
    ", Dev =", SupportPreventDuplicate.Dev and "✅" or "🚫")
debugPrint("Loader loaded successfully! Prevent Duplicate Run:", CONFIG.PreventDuplicateRunLoader and "On 🚫" or "Off ♻️",
    "Module Installed:", _G.CollectModuleInstalled and "Yes ✅" or "No 🚫",
    "Chat System:", CONFIG.LoadChatSystem and (_G.ChatSystemLoaded and "Enabled 💬" or "Error ❌") or "Disabled ❌")
