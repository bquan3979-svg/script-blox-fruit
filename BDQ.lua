-- ==========================================
-- ANTI AFK
-- ==========================================
task.spawn(function()
    local VirtualUser = game:GetService("VirtualUser")
    game:GetService("Players").LocalPlayer.Idled:Connect(function()
        VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    end)
end)

-- ==========================================
-- SERVICES & LOCAL PLAYER
-- ==========================================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui", 10)

-- ==========================================
-- TẢI THƯ VIỆN UI (BDQ Hub)
-- ==========================================
local success, Library = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/hdanhhub/UI/refs/heads/main/ui_BananaHub_final.lua"))()
end)

if not success or type(Library) ~= "table" then
    warn("[BDQ Hub]: Không thể tải thư viện UI!")
    return
end

Window = Library:CreateWindow({
    Title = "BDQ Hub",
    Desc = "- Blox Fruit (Dark Edition)",
    Image = "rbxassetid://123613996022560"
})

-- ==========================================
-- HELPER FUNCTIONS & PROXY CHO UI
-- ==========================================
local function safeInvoke(fn, ...) 
    if type(fn) ~= "function" then return nil end
    local ok, result = pcall(fn, ...)
    if ok then return result end
    return nil
end

local function makeProxy(obj, callbackHolder)
    local proxy = {}
    setmetatable(proxy, {
        __index = function(_, k)
            if k == "OnChanged" then
                return function(_, fn)
                    callbackHolder.extra = fn
                    return proxy
                end
            end
            if k == "SetStage" and obj and obj.SetStage then
                return function(_, v) return safeInvoke(obj.SetStage, v) end
            end
            if k == "SetValue" then
                return function(_, v)
                    if obj and obj.SetValue then
                        local ok = pcall(obj.SetValue, v)
                        if not ok then
                            return pcall(function() return obj:SetValue(v) end)
                        end
                        return true
                    end
                    return nil
                end
            end
            if k == "GetValue" then
                return function(_)
                    if obj and obj.GetValue then
                        local ok, val = pcall(obj.GetValue)
                        if ok then return val end
                        local ok2, val2 = pcall(function() return obj:GetValue() end)
                        return val2
                    end
                    return nil
                end
            end
            local v = obj and (rawget(obj, k) or obj[k])
            if type(v) == "function" then
                return function(_, ...) return safeInvoke(v, obj, ...) end
            end
            return v
        end
    })
    return proxy
end

local function wrapTab(rawTab)
    local _currentSection = nil
    local _nextIsRight = false

    local function ensureSection()
        if not _currentSection then
            _currentSection = rawTab:AddLeftGroupbox(" ")
        end
    end

    local wrapped = {}

    function wrapped:AddSection(name)
        if _nextIsRight then
            _currentSection = rawTab:AddRightGroupbox(name or " ")
            _nextIsRight = false
        else
            _currentSection = rawTab:AddLeftGroupbox(name or " ")
            _nextIsRight = true
        end
        return _currentSection
    end

    function wrapped:AddToggle(id, setting)
        ensureSection()
        local holder = { extra = nil }
        local origCb = setting.Callback or setting["Callback"]
        setting.Callback = function(v)
            if origCb then pcall(origCb, v) end
            if holder.extra then pcall(holder.extra, v) end
        end
        setting["Callback"] = setting.Callback
        local obj = _currentSection:AddToggle(id, setting)
        return makeProxy(obj, holder)
    end

    function wrapped:AddButton(setting, cb)
        ensureSection()
        local proxy = _currentSection:AddButton(setting, cb)
        if proxy then
            return makeProxy(proxy, {})
        end
    end

    function wrapped:AddDropdown(id, setting)
        ensureSection()
        local holder = { extra = nil }
        local origCb = setting.Callback or setting["Callback"]
        setting.Callback = function(v)
            if origCb then pcall(origCb, v) end
            if holder.extra then pcall(holder.extra, v) end
        end
        setting["Callback"] = setting.Callback
        local obj = _currentSection:AddDropdown(id, setting)
        return makeProxy(obj, holder)
    end

    function wrapped:AddParagraph(setting)
        ensureSection()
        local title = setting.Title or setting["Title"] or ""
        local desc  = setting.Description or setting["Description"] or setting.Desc or ""
        local txt   = desc ~= "" and (title .. "\n" .. desc) or title
        local obj = _currentSection:AddLabel(txt)
        return makeProxy(obj, {})
    end

    function wrapped:AddLabel(text)
        ensureSection()
        local obj = _currentSection:AddLabel(text)
        return makeProxy(obj, {})
    end

    return wrapped
end

-- ==========================================
-- KHỞI TẠO TABS
-- ==========================================
Tabs = {
    ["Info"]     = wrapTab(Window:AddTab("Thông Tin")),
    ["Main"]     = wrapTab(Window:AddTab("Cày Cấp")),
    ["Sea"]      = wrapTab(Window:AddTab("Sự Kiện")),
    ["Setting"]  = wrapTab(Window:AddTab("Cài Đặt")),
    ["Misc"]     = wrapTab(Window:AddTab("Khác")),
}

-- TAB INFO
Tabs.Info:AddParagraph({ Title = "BDQ Hub", Description = "Phiên bản Blox Fruit Dark UI" })
Tabs.Info:AddLabel("Chủ sở hữu: BDQ")

-- TAB MAIN
Tabs.Main:AddSection("Tự Động Cày Cấp")
Tabs.Main:AddToggle("AutoFarmLevel", {
    Text = "Auto Farm Level",
    Default = false,
    Callback = function(v)
        _G.AutoLevel = v
    end
})

Library:Notify({
    Title = "BDQ Hub",
    Description = "Đã tải Menu thành công!",
    Duration = 4
})