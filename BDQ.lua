local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local VirtualUser = game:GetService("VirtualUser")
local Lighting = game:GetService("Lighting")
local CollectionService = game:GetService("CollectionService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui", 5)
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- Safe globals
_G.AutoLevel = false
_G.OneHitKill = false
_G.AutoBone = false
_G.AutoRandomBone = false
_G.TweenToKitsune = false
_G.CollectAzure = false
_G.AutoYama = false
_G.AutoBoss = false

-- Executor check
local executor = (getexecutorname and getexecutorname()) or (identifyexecutor and identifyexecutor())
if executor then
    local lower = string.lower(executor)
    local accepted =
        string.find(lower, "bunni") or
        string.find(lower, "fluxusz") or
        string.find(lower, "delta") or
        string.find(lower, "arceus") or
        string.find(lower, "xeno") or
        string.find(lower, "swift") or
        string.find(lower, "awp") or
        string.find(lower, "volcano") or
        string.find(lower, "argon") or
        string.find(lower, "macsploit") or
        string.find(lower, "potassium") or
        string.find(lower, "codex") or
        string.find(lower, "velocity") or
        string.find(lower, "romix") or
        string.find(lower, "neutron")

    if accepted then
        print("Executor Accepted: " .. executor)
    else
        Player:Kick("Please use Delta Exploit or PC use Volcano or Exploit paid!")
    end
end

-- Load UI library
local success, Library = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/mstudio45/LinoriaLib/main/Library.lua"))()
end)
if not success or not Library then
    warn("Failed to load library")
    return
end

local Window = Library:CreateWindow({
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

            if k == "SetStage" and obj and obj.SetStage then
                return function(_, v)
                    pcall(obj.SetStage, obj, v)
                end
            end

            if k == "SetValue" then
                return function(_, v)
                    if obj and obj.SetValue then
                        local ok = pcall(obj.SetValue, obj, v)
                        if not ok and obj.SetValue ~= nil then
                            pcall(function()
                                obj:SetValue(v)
                            end)
                        end
                    end
                end
            end

            if k == "GetValue" then
                return function(_)
                    if obj and obj.GetValue then
                        local ok, val = pcall(function()
                            return obj:GetValue()
                        end)
                        if ok then
                            return val
                        end
                    end
                    return nil
                end
            end

            if k == "SetText" or k == "SetDesc" then
                return function(_, t)
                    if obj and obj.SetText then
                        pcall(obj.SetText, obj, t)
                    elseif obj and obj.SetDesc then
                        pcall(obj.SetDesc, obj, t)
                    end
                end
            end

            local v = rawget(obj, k) or (type(obj) == "table" and obj[k])
            if type(v) == "function" then
                return function(_, ...)
                    local ok, result = pcall(v, obj, ...)
                    if ok then
                        return result
                    end
                    return nil
                end
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
            if origCb then
                pcall(origCb, v)
            end
            if holder.extra then
                pcall(holder.extra, v)
            end
        end
        setting["Description"] = nil
        local obj = _currentSection:AddToggle(id, setting)
        return makeProxy(obj, holder)
    end

    function wrapped:AddButton(setting, cb)
        ensureSection()
        if type(setting) == "table" then
            setting["Description"] = nil
        end
        local proxy = _currentSection:AddButton(setting, cb)
        if proxy then
            return makeProxy(proxy, {})
        end
        return nil
    end

    function wrapped:AddDropdown(id, setting)
        ensureSection()
        local holder = { extra = nil }
        local origCb = setting.Callback or setting["Callback"]
        setting.Callback = function(v)
            if origCb then
                pcall(origCb, v)
            end
            if holder.extra then
                pcall(holder.extra, v)
            end
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
            if origCb then
                pcall(origCb, v)
            end
            if holder.extra then
                pcall(holder.extra, v)
            end
        end
        setting["Description"] = nil

        -- Fixed: pass the id and config to the underlying library
        local obj = _currentSection:AddSlider(id, setting)
        return makeProxy(obj, holder)
    end

    function wrapped:AddParagraph(setting)
        ensureSection()
        local title = setting.Title or setting["Title"] or ""
        local desc = setting.Description or setting["Description"] or setting.Desc or ""
        local text = desc ~= "" and (title .. "\n" .. desc) or title
        local obj = _currentSection:AddLabel(text)
        return makeProxy(obj, {})
    end

    return wrapped
end

local Tabs = {
    Info = wrapTab(Window:AddTab("Thông Tin")),
    Main = wrapTab(Window:AddTab("Cày Cấp")),
    Sea = wrapTab(Window:AddTab("Sự Kiện")),
    Item = wrapTab(Window:AddTab("Lấy & Nâng Cấp Vật Phẩm")),
    Setting = wrapTab(Window:AddTab("Cài Đặt")),
    Status = wrapTab(Window:AddTab("Webhook")),
    Stats = wrapTab(Window:AddTab("Chỉ Số")),
    Player = wrapTab(Window:AddTab("Người Chơi")),
    Teleport = wrapTab(Window:AddTab("Dịch Chuyển")),
    Visual = wrapTab(Window:AddTab("Giả Mạo")),
    Fruit = wrapTab(Window:AddTab("Trái Ác Quỷ")),
    Raid = wrapTab(Window:AddTab("Đột Kích")),
    Race = wrapTab(Window:AddTab("Nâng Cấp Chủng Tộc")),
    Shop = wrapTab(Window:AddTab("Cửa Hàng")),
    Misc = wrapTab(Window:AddTab("Khác")),
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

-- Anti-AFK
Players.LocalPlayer.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
end)

-- Location checks
local Sea1 = game.PlaceId == 2753915549
local Sea2 = game.PlaceId == 4442272183
local Sea3 = game.PlaceId == 7449423635

local Pos = CFrame.new(0, 30, 0)
local ChooseWeapon = "Melee"
local SelectWeapon = "Melee"

local function AutoHaki()
    local char = Player.Character
    if not char then
        return
    end

    if not char:FindFirstChild("HasBuso") then
        local ok = pcall(function()
            ReplicatedStorage.Remotes.CommF_:InvokeServer("Buso")
        end)
        if not ok then
            pcall(function()
                ReplicatedStorage.Remotes.CommF_:InvokeServer("Buso")
            end)
        end
    end
end

local function EquipTool(toolName)
    local char = Player.Character
    if not char then
        return
    end

    local backpack = Player.Backpack
    local tool = backpack and backpack:FindFirstChild(toolName)
    if tool then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:EquipTool(tool)
        end
    end
end

local function Tween2(targetCFrame)
    local char = Player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not char or not hrp then
        return
    end

    local distance = (targetCFrame.Position - hrp.Position).Magnitude
    local speed = 350
    local tweenInfo = TweenInfo.new(distance / speed, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(hrp, tweenInfo, { CFrame = targetCFrame })
    tween:Play()
end

local function BKP(targetCFrame)
    local char = Player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = targetCFrame
    end
end

local function AttackNoCoolDown()
    local char = Player.Character
    if not char then
        return
    end

    local tool = char:FindFirstChildOfClass("Tool")
    if tool then
        if tool:FindFirstChild("LeftClickRemote") then
            tool.LeftClickRemote:FireServer(Vector3.new(0, -1, 0), 1)
            return
        end

        local ok = pcall(function()
            local net = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Net")
            net:WaitForChild("RE/RegisterAttack"):FireServer(1e-9)

            local enemy = Workspace.Enemies and Workspace.Enemies:FindFirstChildOfClass("Model")
            if enemy and enemy:FindFirstChild("Head") then
                net:WaitForChild("RE/RegisterHit"):FireServer(enemy.Head, { { enemy, enemy.Head } })
            end
        end)
        if not ok then
            warn("AttackNoCoolDown failed")
        end
    end
end

-- Main tab
Tabs.Main:AddSection("Cày Cấp")

local weaponDropdown = Tabs.Main:AddDropdown("DropdownSelectWeapon", {
    Title = "Vũ Khí",
    Values = { "Melee", "Sword", "Blox Fruit" },
    Default = 1,
})
weaponDropdown:OnChanged(function(v)
    ChooseWeapon = v
    SelectWeapon = v
end)

Tabs.Main:AddToggle("ToggleLevel", {
    Title = "Tự Động Cày Cấp (Auto Level)",
    Default = false,
}):OnChanged(function(v)
    _G.AutoLevel = v
end)

task.spawn(function()
    while task.wait(0.1) do
        if _G.AutoLevel then
            local char = Player.Character
            if not char then
                continue
            end

            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum then
                continue
            end

            pcall(function()
                for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
                    if enemy and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                        repeat
                            task.wait(0.05)
                            EquipTool(SelectWeapon)
                            AutoHaki()
                            local enemyHRP = enemy:FindFirstChild("HumanoidRootPart")
                            if enemyHRP then
                                BKP(enemyHRP.CFrame * Pos)
                            end
                            AttackNoCoolDown()
                        until not _G.AutoLevel or not enemy.Parent or not enemy:FindFirstChild("Humanoid") or enemy.Humanoid.Health <= 0
                    end
                end
            end)
        end
    end
end)

Tabs.Main:AddSection("Chiến Đấu Nhanh")
Tabs.Main:AddToggle("ToggleOneHit", {
    Title = "Đánh Nhanh (Fast Attack / Fast Kill)",
    Default = false,
}):OnChanged(function(v)
    _G.OneHitKill = v
end)

task.spawn(function()
    while task.wait(0.1) do
        if _G.OneHitKill then
            pcall(function()
                if Workspace.Enemies then
                    for _, mob in pairs(Workspace.Enemies:GetChildren()) do
                        local hum = mob and mob:FindFirstChild("Humanoid")
                        if hum and hum.Health > 0 then
                            hum.Health = hum.MaxHealth * 0.25
                        end
                    end
                end
            end)
        end
    end
end)

if Sea3 then
    Tabs.Main:AddSection("Cày Xương (Bone Farm)")
    Tabs.Main:AddToggle("ToggleBone", {
        Title = "Tự Động Cày Xương",
        Default = false,
    }):OnChanged(function(v)
        _G.AutoBone = v
    end)

    Tabs.Main:AddToggle("ToggleRandomBone", {
        Title = "Tự Động Random Xương",
        Default = false,
    }):OnChanged(function(v)
        _G.AutoRandomBone = v
    end)

    task.spawn(function()
        while task.wait(0.2) do
            if _G.AutoRandomBone then
                pcall(function()
                    ReplicatedStorage.Remotes.CommF_:InvokeServer("Bones", "Buy", 1, 1)
                end)
            end
        end
    end)
end

if Sea3 then
    Tabs.Sea:AddSection("Đảo Cáo (Kitsune Island)")
    Tabs.Sea:AddToggle("ToggleTPKitsune", {
        Title = "Bay Vào Đảo Cáo",
        Default = false,
    }):OnChanged(function(v)
        _G.TweenToKitsune = v
    end)

    Tabs.Sea:AddToggle("ToggleCollectAzure", {
        Title = "Nhặt Linh Hồn Azure",
        Default = false,
    }):OnChanged(function(v)
        _G.CollectAzure = v
    end)

    Tabs.Sea:AddButton({
        Title = "Đổi Linh Hồn Lấy Quà",
        Callback = function()
            pcall(function()
                ReplicatedStorage.Modules.Net["RF/KitsuneStatuePray"]:InvokeServer()
            end)
        end
    })
end

-- NoClip safety loop
RunService.Stepped:Connect(function()
    if _G.AutoLevel or _G.AutoBone or _G.AutoYama or _G.TweenToKitsune or _G.AutoBoss then
        local char = Player.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
end)

-- Info tab
Tabs.Info:AddSection("Thông Tin Community")
Tabs.Info:AddButton({
    Title = "BDQ Community",
    Callback = function()
        setclipboard("https://dsc.gg/nopermc")
    end
})

Tabs.Info:AddButton({
    Title = "BDQ Hub (Youtube)",
    Callback = function()
        setclipboard("https://youtube.com/@nopermc")
    end
})