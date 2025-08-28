local Mode = "New"  -- "Old" ก็ได้

local Links = {
    New = "https://raw.githubusercontent.com/wino444/CollectModule_New/main/CollectModule_New.lua",
    Old = "https://raw.githubusercontent.com/wino444/CollectModule_Old/main/CollectModule_Old.lua"
}

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

-- เริ่มโหลด
local CollectModule = LoadModule(Mode)
if CollectModule then
    print("[CollectModule] 🚀 พร้อมใช้งานแล้ว")
end
