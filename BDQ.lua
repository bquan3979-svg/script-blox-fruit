loadstring(game:HttpGet("https://raw.githubusercontent.com/AnhDangNhoEm/TuanAnhIOS/refs/heads/main/koby"))()

-- ==========================================
-- SERVICES & LOCAL VARIABLES
-- ==========================================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local VirtualUser = game:GetService("VirtualUser")
local Lighting = game:GetService("Lighting")
local CollectionService = game:GetService("CollectionService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui", 5)
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- EXPLOIT CHECK
local executor = (getexecutorname and getexecutorname()) or (identifyexecutor and identifyexecutor())
if executor then
    if string.find(executor, "Bunni") or string.find(executor, "FluxusZ") or string.find(executor, "Delta") or
       string.find(executor, "Arceus") or string.find(executor, "Xeno") or string.find(executor, "Swift") or
       string.find(executor, "Awp") or string.find(executor, "Volcano") or string.find(executor, "Argon") or
       string.find(executor, "Macsploit") or string.find(executor, "Potassium") or string.find(executor, "CodeX") or
       string.find(executor, "Velocity") or string.find(executor, "Romix") or string.find(executor, "Neutron") then
        print("Executor Accepted: " .. executor)
    else
        game.Players.LocalPlayer:Kick("Please use Delta Exploit or PC use Volcano or Exploit paid!")
    end
end

-- ==========================================
-- LOAD UI LIBRARY & THEME CONFIGURATION
-- ==========================================
Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/mstudio45/LinoriaLib/main/Library.lua"))(

Window = Library:CreateWindow({
    Title = "BDQ Hub",
    Desc = "- Blox Fruit",
    Image = "rbxassetid://123613996022560"
})

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
            if k == "SetStage" and obj.SetStage then
                return function(_, v) pcall(obj.SetStage, v) end
            end
            if k == "SetValue" then
                return function(_, v)
                    if obj.SetValue then
                        local ok = pcall(obj.SetValue, v)
                        if not ok then pcall(function() obj:SetValue(v) end) end
                    end
                end
            end
            if k == "GetValue" then
                return function(_)
                    if obj.GetValue then
                        local ok, val = pcall(obj.GetValue)
                        if ok then return val end
                        local ok2, val2 = pcall(function() return obj:GetValue() end)
                        return val2
                    end
                end
            end
            if k == "SetText" or k == "SetDesc" then
                return function(_, t)
                    if obj.SetText then pcall(obj.SetText, obj, t)
                    elseif obj.SetDesc then pcall(obj.SetDesc, obj, t) end
                end
            end
            local v = rawget(obj, k) or (type(obj) == "table" and obj[k])
            if type(v) == "function" then
                return function(_, ...) return pcall(v, obj, ...) end
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
        if not _currentSection then _currentSection = rawTab:AddLeftGroupbox(" ") end
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
        setting["Description"] = nil
        local obj = _currentSection:AddToggle(id, setting)
        return makeProxy(obj, holder)
    end

    function wrapped:AddButton(setting, cb)
        ensureSection()
        if type(setting) == "table" then setting["Description"] = nil end
        local proxy = _currentSection:AddButton(setting, cb)
        if proxy then return makeProxy(proxy, {}) end
    end

    function wrapped:AddDropdown(id, setting)
        ensureSection()
        local holder = { extra = nil }
        local origCb = setting.Callback or setting["Callback"]
        setting.Callback = function(v)
            if origCb then pcall(origCb, v) end
            if holder.extra then pcall(holder.extra, v) end
        end
        setting["Description"] = nil
        local obj = _currentSection:AddDropdown(id, setting)
        return makeProxy(obj, holder)
    end

    function wrapped:AddSlider(id, setting)
        ensureSection()
        local holder = { extra = nil }
        local origCb = setting.Callback or setting["Callback"]
        setting.Callback = function(v)
            if origCb then pcall(origCb, v) end
            if holder.extra then pcall(holder.extra, v) end
        end
        setting["Description"] = nil
        local obj = _currentSection:AddSlider(setting)
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

    return wrapped
end

Tabs = {
    ["Info"]     = wrapTab(Window:AddTab("Thông Tin")),
    ["Main"]     = wrapTab(Window:AddTab("Cày Cấp")),
    ["Sea"]      = wrapTab(Window:AddTab("Sự Kiện")),
    ["Item"]     = wrapTab(Window:AddTab("Lấy & Nâng Cấp Vật Phẩm")),
    ["Setting"]  = wrapTab(Window:AddTab("Cài Đặt")),
    ["Status"]   = wrapTab(Window:AddTab("Webhook")),
    ["Stats"]    = wrapTab(Window:AddTab("Chỉ Số")),
    ["Player"]   = wrapTab(Window:AddTab("Người Chơi")),
    ["Teleport"] = wrapTab(Window:AddTab("Dịch Chuyển")),
    ["Visual"]   = wrapTab(Window:AddTab("Giả Mạo")),
    ["Fruit"]    = wrapTab(Window:AddTab("Trái Ác Quỷ")),
    ["Raid"]     = wrapTab(Window:AddTab("Đột Kích")),
    ["Race"]     = wrapTab(Window:AddTab("Nâng Cấp Chủng Tộc")),
    ["Shop"]     = wrapTab(Window:AddTab("Cửa Hàng")),
    ["Misc"]     = wrapTab(Window:AddTab("Khác")),
}

pcall(function()
    if Library.SetTheme then
        Library:SetTheme({
            Background         = Color3.fromRGB(255, 182, 193),
            Accent             = Color3.fromRGB(255, 20, 147),
            PrimaryText        = Color3.fromRGB(255, 255, 255),
            SecondaryText      = Color3.fromRGB(255, 220, 230),
            Divider            = Color3.fromRGB(255, 105, 180),
            Header             = Color3.fromRGB(220, 20, 90),
            Box                = Color3.fromRGB(255, 145, 175),
            Button             = Color3.fromRGB(255, 20, 147),
            Hover              = Color3.fromRGB(255, 80, 160),
            Toggle             = Color3.fromRGB(255, 20, 147),
            ToggleBackground   = Color3.fromRGB(255, 182, 193),
            Dropdown           = Color3.fromRGB(255, 145, 175),
            DropdownBackground = Color3.fromRGB(255, 182, 193),
            Scrollbar          = Color3.fromRGB(255, 20, 147),
            Outline            = Color3.fromRGB(255, 105, 180),
            Shadow             = Color3.fromRGB(180, 0, 80),
        })
    end
end)

Library:Notify({
    Title = "BDQ Hub",
    Description = "Chào mừng! UI màu hồng đã được load thành công.",
    Duration = 4
})

-- Anti AFK
Players.LocalPlayer.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
end)

-- ==========================================
-- CORE HELPER FUNCTIONS & FARM LOGIC
-- ==========================================
Sea1 = game.PlaceId == 2753915549 or true
Sea2 = game.PlaceId == 4442272183 or true
Sea3 = game.PlaceId == 7449423635 or true

Pos = CFrame.new(0, 30, 0)
ChooseWeapon = "Melee"
SelectWeapon = "Melee"

function AutoHaki()
    if not Player.Character:FindFirstChild("HasBuso") then
        ReplicatedStorage.Remotes.CommF_:InvokeServer("Buso")
    end
end

function EquipTool(toolName)
    if Player.Backpack:FindFirstChild(toolName) then
        local tool = Player.Backpack:FindFirstChild(toolName)
        Player.Character.Humanoid:EquipTool(tool)
    end
end

function Tween2(targetCFrame)
    local distance = (targetCFrame.Position - Player.Character.HumanoidRootPart.Position).Magnitude
    local speed = 350
    local tweenInfo = TweenInfo.new(distance / speed, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(Player.Character.HumanoidRootPart, tweenInfo, { CFrame = targetCFrame })
    tween:Play()
end

function BKP(targetCFrame)
    if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
        Player.Character.HumanoidRootPart.CFrame = targetCFrame
    end
end

function AttackNoCoolDown()
    local char = Player.Character
    if not char then return end
    local tool = char:FindFirstChildOfClass("Tool")
    if tool then
        if tool:FindFirstChild("LeftClickRemote") then
            tool.LeftClickRemote:FireServer(Vector3.new(0, -1, 0), 1)
        else
            pcall(function()
                local net = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Net")
                net:WaitForChild("RE/RegisterAttack"):FireServer(1e-9)
                local enemy = Workspace.Enemies:FindFirstChildOfClass("Model")
                if enemy and enemy:FindFirstChild("Head") then
                    net:WaitForChild("RE/RegisterHit"):FireServer(enemy.Head, {{ enemy, enemy.Head }})
                end
            end)
        end
    end
end

-- ==========================================
-- TAB: THÔNG TIN (INFO)
-- ==========================================
Tabs.Info:AddSection("Thông Tin Community")
Tabs.Info:AddButton({
    ["Title"] = "BDQ Community",
    ["Callback"] = function() setclipboard("https://dsc.gg/nopermc") end
})
Tabs.Info:AddButton({
    ["Title"] = "BDQ Hub (Youtube)",
    ["Callback"] = function() setclipboard("https://youtube.com/@nopermc") end
})

-- ==========================================
-- TAB: CÀY CẤP (MAIN)
-- ==========================================
Tabs.Main:AddSection("Cày Cấp")
local weaponDropdown = Tabs.Main:AddDropdown("DropdownSelectWeapon", {
    ["Title"] = "Vũ Khí",
    ["Values"] = { "Melee", "Sword", "Blox Fruit" },
    ["Default"] = 1
})
weaponDropdown:OnChanged(function(v) ChooseWeapon = v end)

Tabs.Main:AddToggle("ToggleLevel", {
    ["Title"] = "Tự Động Cày Cấp (Auto Level)",
    ["Default"] = false
}):OnChanged(function(v) _G.AutoLevel = v end)

task.spawn(function()
    while task.wait(0.1) do
        if _G.AutoLevel then
            pcall(function()
                -- Tự động kiểm tra cấp và làm Quest
                for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
                    if enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                        repeat
                            task.wait(0.05)
                            EquipTool(SelectWeapon)
                            AutoHaki()
                            BKP(enemy.HumanoidRootPart.CFrame * Pos)
                            AttackNoCoolDown()
                        until not _G.AutoLevel or not enemy.Parent or enemy.Humanoid.Health <= 0
                    end
                end
            end)
        end
    end
end)

Tabs.Main:AddSection("Chiến Đấu Nhanh")
Tabs.Main:AddToggle("ToggleOneHit", {
    ["Title"] = "Đánh Nhanh (Fast Attack / Fast Kill)",
    ["Default"] = false
}):OnChanged(function(v) _G.OneHitKill = v end)

task.spawn(function()
    while task.wait(0.1) do
        if _G.OneHitKill then
            pcall(function()
                for _, mob in pairs(Workspace.Enemies:GetChildren()) do
                    local hum = mob:FindFirstChild("Humanoid")
                    if hum and hum.Health > hum.MaxHealth * 0.25 then
                        hum.Health = hum.MaxHealth * 0.25
                    end
                end
            end)
        end
    end
end)

if Sea3 then
    Tabs.Main:AddSection("Cày Xương (Bone Farm)")
    Tabs.Main:AddToggle("ToggleBone", {
        ["Title"] = "Tự Động Cày Xương",
        ["Default"] = false
    }):OnChanged(function(v) _G.AutoBone = v end)

    Tabs.Main:AddToggle("ToggleRandomBone", {
        ["Title"] = "Tự Động Random Xương",
        ["Default"] = false
    }):OnChanged(function(v) _G.AutoRandomBone = v end)

    task.spawn(function()
        while task.wait(0.2) do
            if _G.AutoRandomBone then
                ReplicatedStorage.Remotes.CommF_:InvokeServer("Bones", "Buy", 1, 1)
            end
        end
    end)
end

-- ==========================================
-- TAB: SỰ KIỆN (SEA)
-- ==========================================
if Sea3 then
    Tabs.Sea:AddSection("Đảo Cáo (Kitsune Island)")
    Tabs.Sea:AddToggle("ToggleTPKitsune", {
        ["Title"] = "Bay Vào Đảo Cáo",
        ["Default"] = false
    }):OnChanged(function(v) _G.TweenToKitsune = v end)

    Tabs.Sea:AddToggle("ToggleCollectAzure", {
        ["Title"] = "Nhặt Linh Hồn Azure",
        ["Default"] = false
    }):OnChanged(function(v) _G.CollectAzure = v end)

    Tabs.Sea:AddButton({
        ["Title"] = "Đổi Linh Hồn Lấy Quà",
        ["Callback"] = function()
            ReplicatedStorage.Modules.Net["RF/KitsuneStatuePray"]:InvokeServer()
        end
    })
end

-- NoClip Clip Safety Loop
RunService.Stepped:Connect(function()
    if _G.AutoLevel or _G.AutoBone or _G.AutoYama or _G.TweenToKitsune or _G.AutoBoss then
        if Player.Character then
            for _, part in pairs(Player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
end)