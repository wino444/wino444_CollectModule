local Players = game:GetService("Players")  
local LocalPlayer = Players.LocalPlayer  

-- โหมดปกติที่เลือกเอง  
local Mode = "Old"  -- "Old" / "New" / จะถูก override ถ้า user พิเศษ  

-- เปิด/ปิด Dev Mode (แม้จะมีชื่อใน DevUsers ก็ตาม)  
local EnableDevMode = true  -- true = เปิด, false = ปิด  

-- ลิงก์ของแต่ละเวอร์ชัน  
local Links = {  
    New = "https://raw.githubusercontent.com/wino444/CollectModule_New/main/CollectModule_New.lua",  
    Old = "https://raw.githubusercontent.com/wino444/CollectModule_Old/main/CollectModule_Old.lua",  
    Dev = "https://raw.githubusercontent.com/wino444/CollectModule_Dev/main/CollectModule_Dev.lua"  
}  

-- รายชื่อคนที่จะบังคับใช้ Dev  
local DevUsers = {  
    ["ojhvhknhj"] = true  
}  

-- ฟังก์ชันโหลด Module  
local function LoadModule(mode)  
    local url = Links[mode]  
    if not url then  
        warn("[CollectModule Loader] ❌ ไม่เจอลิงก์:", mode)  
        return  
    end  

    local success, response = pcall(function()  
        return game:HttpGet(url)  
    end)  

    if not success then  
        warn("[CollectModule Loader] ⚠️ โหลดล้มเหลว:", response)  
        return nil  
    end  

    local moduleFunc, loadErr = loadstring(response)  
    if not moduleFunc then  
        warn("[CollectModule Loader] ❌ โหลดสคริปต์ไม่สำเร็จ:", loadErr)  
        return nil  
    end  

    local ok, module = pcall(moduleFunc)  
    if not ok then  
        warn("[CollectModule Loader] ❌ Module มี error ตอนรัน:", module)  
        return nil  
    end  

    print("[CollectModule Loader] ✅ โหลดสำเร็จ:", mode)  
    return module  
end  

-- ตรวจสอบว่าเป็น DevUser + DevMode เปิดอยู่ไหม  
if EnableDevMode and DevUsers[LocalPlayer.Name] then  
    Mode = "Dev"  
    print("[CollectModule Loader] [Dev] 🚧 กำลังใช้เวอร์ชันทดสอบอยู่")  
end  

-- เริ่มโหลด  
local CollectModule = LoadModule(Mode)  
if CollectModule then  
    print("[CollectModule] 🚀 พร้อมใช้งานแล้ว")  
end
