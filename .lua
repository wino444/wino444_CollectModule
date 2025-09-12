-- CollectModule Loader V2.0.5 (Unified Loader) ⚙️
local CONFIG = {
    PreventDuplicateRunLoader = true, -- ป้องกันรันซ้ำสำหรับ Loader 🚫
    LoadChatSystem = true,            -- เปิด/ปิด โหลดระบบแชท 💬
    DebugEnabled = true               -- เปิด/ปิด log debug 🖥️
}

local LOADER_VERSION = "V2.0.5"

-- Table การรองรับป้องกันรันซ้ำ 📋
local SupportPreventDuplicate = {
    New = true,
    Old = false,
    Dev = true
}

-- ฟังก์ชัน debugPrint 🖥️
local function debugPrint(...)
    if CONFIG.DebugEnabled then
        print(("[CollectModule Loader %s] 🚀"):format(LOADER_VERSION), ...)
    end
end

-- ป้องกันรันซ้ำ 📛
if _G.CollectModuleInstalled then
    debugPrint("Module already installed! Skipping load. 🚫")
    return
elseif _G.CollectLoaderLoaded then
    if CONFIG.PreventDuplicateRunLoader then
        debugPrint("Script already loaded! Skipping duplicate run. 🚫")
        return
    else
        debugPrint("Duplicate run allowed, resetting... ♻️")
        if _G.CollectModule then
            local ok, err = pcall(function()
                if type(_G.CollectModule.ResetModule) == "function" then
                    _G.CollectModule.ResetModule()
                end
            end)
            if not ok then
                debugPrint("Reset error:", err)
            end
            _G.CollectModule = nil
        end
    end
end

-- SERVICES 🌐
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

-- โหมดเริ่มต้น
local Mode = "New"
local EnableDevMode = true

-- ลิงก์ของแต่ละเวอร์ชัน
local Links = {
    New = "https://raw.githubusercontent.com/wino444/wino444_CollectModule/main/CollectModule_New.lua",
    Old = "https://raw.githubusercontent.com/wino444/wino444_CollectModule/main/CollectModule_Old.lua",
    Dev = "https://raw.githubusercontent.com/wino444/wino444_CollectModule/main/CollectModule_Dev.lua"
}

-- ลิงก์ Chat System
local ChatURL = "https://raw.githubusercontent.com/wino444/PhantomNet/main/phantom_client.lua"

-- รายชื่อ DevUsers
local DevUsers = {
    ["ojhvhknhj"] = true,
    ["AniF_Xx"] = true
}

-- ฟังก์ชัน HTTP GET แบบปลอดภัย
local function safeHttpGet(url, timeout)
    timeout = timeout or 10
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
    local ok, body = pcall(function() return game:HttpGet(url, timeout) end)
    if ok then
        return true, body
    else
        return false, body
    end
end

-- ฟังก์ชันโหลด Script (ใช้ได้ทั้ง CollectModule/ChatSystem) 🎯
local function LoadScript(name, url)
    local ok, response = safeHttpGet(url, 10)
    if not ok then
        debugPrint("⚠️ โหลด " .. name .. " ล้มเหลว:", response)
        return nil
    end

    local func, err = loadstring(response)
    if not func then
        debugPrint("❌ แปลง " .. name .. " error:", err)
        return nil
    end

    local ran, result = pcall(func)
    if not ran then
        debugPrint("❌ รัน " .. name .. " error:", result)
        return nil
    end

    debugPrint("✅ โหลด " .. name .. " สำเร็จ!")
    return result
end

-- ตรวจสอบ DevUser
if EnableDevMode and DevUsers[LocalPlayer.Name] then
    Mode = "Dev"
    debugPrint("[Dev] 🚧 กำลังใช้เวอร์ชันทดสอบ")
elseif DevUsers[LocalPlayer.Name] then
    debugPrint("[Dev] ⚠️ DevUser แต่ DevMode ปิด – ใช้โหมดปกติ")
end

-- ตรวจสอบการรองรับ PreventDuplicateRun
if CONFIG.PreventDuplicateRunLoader and not SupportPreventDuplicate[Mode] then
    debugPrint("⚠️ เวอร์ชัน", Mode, "ไม่รองรับ PreventDuplicateRun – ปิดอัตโนมัติ")
    CONFIG.PreventDuplicateRunLoader = false
end

-- โหลด Collect Module
local CollectModule = LoadScript("CollectModule(" .. Mode .. ")", Links[Mode])
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

-- โหลด Chat System (ครั้งเดียว)
if CONFIG.LoadChatSystem then
    if not _G.ChatSystemLoaded then
        local chat = LoadScript("Chat System", ChatURL)
        if chat then
            _G.ChatSystemLoaded = true
        end
    else
        debugPrint("💬 Chat System เคยโหลดแล้ว ข้าม 🚫")
    end
else
    debugPrint("💬 Chat System ถูกปิดใน CONFIG")
end

-- ตั้ง flag
_G.CollectLoaderLoaded = true

-- log สรุป 📊
debugPrint("SupportPreventDuplicate Table: New =", SupportPreventDuplicate.New and "✅" or "🚫",
    ", Old =", SupportPreventDuplicate.Old and "✅" or "🚫",
    ", Dev =", SupportPreventDuplicate.Dev and "✅" or "🚫")
debugPrint("Loader loaded! Prevent Duplicate Run:", CONFIG.PreventDuplicateRunLoader and "On 🚫" or "Off ♻️",
    "Module Installed:", _G.CollectModuleInstalled and "Yes ✅" or "No 🚫",
    "Chat System:", CONFIG.LoadChatSystem and (_G.ChatSystemLoaded and "Enabled 💬" or "Error ❌") or "Disabled ❌")
