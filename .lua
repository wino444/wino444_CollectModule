-- CollectModule Loader V2.0.4 (Fixed) ⚙️
local CONFIG = {
    PreventDuplicateRunLoader = true, -- ป้องกันรันซ้ำสำหรับ Loader 🚫
    LoadChatSystem = true,            -- เปิด/ปิด โหลดระบบแชท 💬 (true = โหลด, false = ไม่โหลด)
    DebugEnabled = true               -- เปิด/ปิด การแจ้งเตือนดีบั๊กใน Console 🖥️ (true = แสดง, false = เงียบ)
}

-- เวอร์ชัน
local LOADER_VERSION = "V2.0.4"

-- Table การรองรับป้องกันรันซ้ำตามเวอร์ชัน 📋
local SupportPreventDuplicate = {
    New = false, -- ไม่รับรอง 🚫
    Old = false, -- ไม่รับรอง 🚫
    Dev = true   -- รับรอง ✅
}

-- ฟังก์ชัน debugPrint (ศูนย์กลางการพิมพ์)
local function debugPrint(...)
    if CONFIG.DebugEnabled then
        print(("[CollectModule Loader %s] 🚀"):format(LOADER_VERSION), ...)
    end
end

-- สวัสดีแถวแรก — ตรวจจับการรันซ้ำ
if _G.CollectModuleInstalled then
    debugPrint("Module already installed! Skipping load. 🚫")
    return
elseif _G.CollectLoaderLoaded then
    if CONFIG.PreventDuplicateRunLoader then
        debugPrint("Script already loaded! Skipping duplicate run. 🚫")
        return
    else
        debugPrint("Duplicate run allowed, attempting reset... ♻️")
        if _G.CollectModule then
            local ok, err = pcall(function()
                if type(_G.CollectModule.ResetModule) == "function" then
                    _G.CollectModule.ResetModule()
                end
            end)
            if not ok then
                debugPrint("Reset error:", err, "🔴")
            end
            _G.CollectModule = nil
        end
    end
end

-- SERVICES 🌐
local Players = game:GetService("Players")

-- ฟังก์ชันหาหรือรอ LocalPlayer ให้แน่นอน
local function getLocalPlayer(timeout)
    timeout = timeout or 10
    if Players.LocalPlayer then
        return Players.LocalPlayer
    end

    -- พยายามรอ PlayerAdded ภายใน timeout
    local success, player
    local start = tick()
    while tick() - start < timeout do
        success, player = pcall(function() return Players.PlayerAdded:Wait() end)
        if success and player then
            -- ถ้ามี LocalPlayer ต่อมาจริง ๆ ให้ใช้มัน (ป้องกันกรณีรันใน environment แปลก ๆ)
            if Players.LocalPlayer then
                return Players.LocalPlayer
            end
            return player
        end
        task.wait(0.1)
    end

    -- สุดท้าย ถ้าไม่มีอะไรเลย คืนค่า Players.LocalPlayer (ยังอาจเป็น nil)
    return Players.LocalPlayer
end

local LocalPlayer = getLocalPlayer(10)
if not LocalPlayer then
    debugPrint("⚠️ ไม่พบ LocalPlayer หลังจากรอ 10 วินาที — การตรวจสอบ DevUser/ชื่อจะถูกข้าม.")
end

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

-- ฟังก์ชัน HTTP GET แบบปลอดภัย (พยายามหลายทาง)
local function safeHttpGet(url, timeout)
    timeout = timeout or 10
    -- พยายาม syn.request ก่อน (ถ้ามี)
    if type(syn) == "table" and type(syn.request) == "function" then
        local ok, resp = pcall(function()
            return syn.request({Url = url, Method = "GET", Timeout = timeout})
        end)
        if ok and resp and resp.Body then
            return true, resp.Body
        else
            return false, resp
        end
    end

    -- ปกติใช้ game:HttpGet (wrapped in pcall)
    local ok, body = pcall(function() return game:HttpGet(url, timeout) end)
    if ok then
        return true, body
    else
        return false, body
    end
end

-- ฟังก์ชันโหลด Module หลัก (เรียก safeHttpGet)
local function LoadModule(mode)
    local url = Links[mode]
    if not url then
        debugPrint("❌ ไม่เจอลิงก์สำหรับโหมด:", mode)
        return nil
    end

    local ok, responseOrErr = safeHttpGet(url, 10)
    if not ok then
        debugPrint("⚠️ การโหลดล้มเหลว:", responseOrErr)
        return nil
    end

    local moduleFunc, loadErr = loadstring(responseOrErr)
    if not moduleFunc then
        debugPrint("❌ โหลดสคริปต์ไม่สำเร็จ:", loadErr)
        return nil
    end

    local okRun, moduleOrErr = pcall(moduleFunc)
    if not okRun then
        debugPrint("❌ Module มี error ตอนรัน:", moduleOrErr)
        return nil
    end

    debugPrint("✅ โหลด", mode, "สำเร็จ!")
    return moduleOrErr
end

-- ฟังก์ชันโหลด Chat System 💬 (โหลดแค่ครั้งเดียว + ป้องกันกำลังโหลดซ้อน)
local function LoadChatSystem()
    if _G.ChatSystemLoaded then
        debugPrint("💬 Chat System เคยโหลดแล้ว ข้ามรอบนี้ 🚫")
        return true
    end
    if _G.ChatSystemLoading then
        debugPrint("💬 Chat System กำลังโหลดโดยรอบอื่น — ข้ามรอบนี้ 🚫")
        return false
    end

    _G.ChatSystemLoading = true
    local url = "https://raw.githubusercontent.com/wino444/PhantomNet/main/phantom_client.lua"
    local ok, result = safeHttpGet(url, 10)
    if not ok then
        debugPrint("⚠️ โหลด Chat System ไม่สำเร็จ:", result)
        _G.ChatSystemLoading = nil
        return false
    end

    local func, err = loadstring(result)
    if not func then
        debugPrint("❌ แปลง Chat System error:", err)
        _G.ChatSystemLoading = nil
        return false
    end

    local ran, runErr = pcall(func)
    if not ran then
        debugPrint("❌ Chat System run error:", runErr)
        _G.ChatSystemLoading = nil
        return false
    else
        _G.ChatSystemLoaded = true
        _G.ChatSystemLoading = nil
        debugPrint("💬 Chat System โหลดสำเร็จ! (ครั้งเดียว)")
        return true
    end
end

-- ------------------------------
-- Flow หลัก (ห่อด้วย pcall เพื่อจับ error)
-- ------------------------------
local okMain, mainErr = pcall(function()
    -- ตรวจสอบ DevUser (ถ้ามี LocalPlayer เท่านั้น)
    if LocalPlayer and EnableDevMode and DevUsers[LocalPlayer.Name] then
        Mode = "Dev"
        debugPrint("[Dev] 🚧 กำลังใช้เวอร์ชันทดสอบ")
    elseif LocalPlayer and DevUsers[LocalPlayer.Name] then
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
        local ver = "Unknown"
        if type(CollectModule.GetVersion) == "function" then
            local okv, vres = pcall(CollectModule.GetVersion)
            if okv and vres then ver = vres end
        end
        debugPrint("🚀 Module พร้อมใช้งาน! Version:", ver)
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
end)

if not okMain then
    debugPrint("🔥 Loader fatal error:", mainErr)
end
