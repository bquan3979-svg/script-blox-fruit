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

-- Safe Globals
_G.AutoLevel = false
_G.FastAttack = false
_G.BringMob = false
_G.AutoBone = false
_G.AutoRandomBone = false
_G.TweenToKitsune = false
_G.CollectAzure = false
_G.AutoYama = false
_G.AutoBoss = false
_G.SelectWeapon = "Melee"

-- Executor Check
local executor = (getexecutorname and getexecutorname()) or (identifyexecutor and identifyexecutor())
if executor then
    local lower = string.lower(executor)
    local accepted = string.find(lower, "bunni") or string.find(lower, "fluxus") or string.find(lower, "delta") or
                     string.find(lower, "arceus") or string.find(lower, "xeno") or string.find(lower, "swift") or
                     string.find(lower, "awp") or string.find(lower, "volcano") or string.find(lower, "argon") or
                     string.find(lower, "macsploit") or string.find(lower, "potassium") or string.find(lower, "codex") or
                     string.find(lower, "velocity") or string.find(lower, "romix") or string.find(lower, "neutron")
    if not accepted then
        Player:Kick("[BDQ Hub]: Executor không được hỗ trợ!")
    end
end

-- Load LinoriaLib (Banana Style)
local success, Library = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/mstudio45/LinoriaLib/main/Library.lua"))()
end)
if not success or not Library then
    warn("Lỗi tải LinoriaLib")
    return
end

local Window = Library:CreateWindow({
    Title = "BDQ Hub | Banana Style Version",
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

-- Custom UI Wrapper (Adapting Linoria to Tab standard)
local function wrapTab(rawTab)
    local currentLeft = rawTab:AddLeftGroupbox("Cài Đặt Chức Năng")
    local currentRight = rawTab:AddRightGroupbox("Tùy Chọn Khác")
    local sideToggle = false

    local wrapped = {}
    function wrapped:AddSection(name)
        sideToggle = not sideToggle
        if sideToggle then
            currentLeft = rawTab:AddLeftGroupbox(name or " ")
            return currentLeft
        else
            currentRight = rawTab:AddRightGroupbox(name or " ")
            return currentRight
        end
    end

    function wrapped:AddToggle(id, config)
        local target = sideToggle and currentLeft or currentRight
        return target:AddToggle(id, {
            Text = config.Title or id,
            Default = config.Default or false,
            Callback = config.Callback or function() end
        })
    end

    function wrapped:AddDropdown(id, config)
        local target = sideToggle and currentLeft or currentRight
        return target:AddDropdown(id, {
            Values = config.Values or {},
            Default = config.Default or 1,
            Multi = false,
            Text = config.Title or id,
            Callback = config.Callback or function() end
        })
    end

    function wrapped:AddButton(config)
        local target = sideToggle and currentLeft or currentRight
        return target:AddButton({
            Text = config.Title or "Button",
            Func = config.Callback or function() end
        })
    end

    return wrapped
end

-- Tabs Config
local Tabs = {
    Info = wrapTab(Window:AddTab("Thông Tin")),
    Main = wrapTab(Window:AddTab("Farm Level")),
    Sea = wrapTab(Window:AddTab("Sự Kiện")),
    Item = wrapTab(Window:AddTab("Vật Phẩm")),
    Stats = wrapTab(Window:AddTab("Chỉ Số")),
    Teleport = wrapTab(Window:AddTab("Dịch Chuyển")),
    Fruit = wrapTab(Window:AddTab("Trái Ác Quỷ")),
    Misc = wrapTab(Window:AddTab("Khác")),
}

-- Watermark (Banana Hub Style)
local FrameTimer = tick()
local FrameCounter = 0
local FPS = 60
local Watermark = Library:SetWatermark("BDQ Hub | Banana Style | FPS: 60 | Ping: 0ms")

RunService.RenderStepped:Connect(function()
    FrameCounter = FrameCounter + 1
    if (tick() - FrameTimer) >= 1 then
        FPS = FrameCounter
        FrameCounter = 0
        FrameTimer = tick()
        local ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
        Library:SetWatermark(string.format("BDQ Hub | Banana Style | FPS: %d | Ping: %dms", FPS, ping))
    end
end)

-- Anti-AFK
Players.LocalPlayer.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
end)

-- Core Functions (Banana Standard)
local function AutoHaki()
    local char = Player.Character
    if char and not char:FindFirstChild("HasBuso") then
        pcall(function()
            ReplicatedStorage.Remotes.CommF_:InvokeServer("Buso")
        end)
    end
end

local function EquipWeapon(weaponType)
    local char = Player.Character
    local backpack = Player.Backpack
    if not char or not backpack then return end

    for _, item in pairs(backpack:GetChildren()) do
        if item:IsA("Tool") then
            if (weaponType == "Melee" and item.ToolTip == "Melee") or
               (weaponType == "Sword" and item.ToolTip == "Sword") or
               (weaponType == "Blox Fruit" and item.ToolTip == "Blox Fruit") then
                char.Humanoid:EquipTool(item)
                break
            end
        end
    end
end

local function FastAttack()
    if not _G.FastAttack then return end
    pcall(function()
        local net = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Net")
        net:WaitForChild("RE/RegisterAttack"):FireServer(1e-9)
        
        local enemies = Workspace.Enemies:GetChildren()
        for _, enemy in pairs(enemies) do
            local hum = enemy:FindFirstChild("Humanoid")
            local hrp = enemy:FindFirstChild("HumanoidRootPart")
            if hum and hrp and hum.Health > 0 then
                if (hrp.Position - Player.Character.HumanoidRootPart.Position).Magnitude <= 55 then
                    net:WaitForChild("RE/RegisterHit"):FireServer(hrp, {{enemy, hrp}})
                end
            end
        end
    end)
end

-- Bring Mob (Banana Feature)
local function BringMobs(targetPos)
    if not _G.BringMob then return end
    for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
        local hum = enemy:FindFirstChild("Humanoid")
        local hrp = enemy:FindFirstChild("HumanoidRootPart")
        if hum and hrp and hum.Health > 0 and (hrp.Position - targetPos).Magnitude <= 300 then
            hrp.CFrame = CFrame.new(targetPos)
            hrp.CanCollide = false
            hum.WalkSpeed = 0
        end
    end
end

-- Tween Flight
local function TweenTo(targetCFrame)
    local char = Player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local distance = (targetCFrame.Position - hrp.Position).Magnitude
    local speed = 300
    local tweenInfo = TweenInfo.new(distance / speed, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
    tween:Play()
end

-- TAB: MAIN (FARM LEVEL)
local FarmSection = Tabs.Main:AddSection("Tùy Chọn Cày Cấp")

Tabs.Main:AddDropdown("SelectWeapon", {
    Title = "Chọn Vũ Khí Farm",
    Values = { "Melee", "Sword", "Blox Fruit" },
    Default = 1,
    Callback = function(v)
        _G.SelectWeapon = v
    end
})

Tabs.Main:AddToggle("ToggleAutoLevel", {
    Title = "Tự Động Cày Cấp (Auto Level)",
    Default = false,
    Callback = function(v)
        _G.AutoLevel = v
    end
})

Tabs.Main:AddToggle("ToggleFastAttack", {
    Title = "Đánh Nhanh (Fast Attack)",
    Default = true,
    Callback = function(v)
        _G.FastAttack = v
    end
})

Tabs.Main:AddToggle("ToggleBringMob", {
    Title = "Gom Quái Lại Gần (Bring Mobs)",
    Default = true,
    Callback = function(v)
        _G.BringMob = v
    end
})

-- Auto Level Loop
task.spawn(function()
    while task.wait(0.1) do
        if _G.AutoLevel then
            pcall(function()
                AutoHaki()
                EquipWeapon(_G.SelectWeapon)

                local enemies = Workspace.Enemies:GetChildren()
                local hasTarget = false

                for _, enemy in pairs(enemies) do
                    local hum = enemy:FindFirstChild("Humanoid")
                    local hrp = enemy:FindFirstChild("HumanoidRootPart")
                    if hum and hrp and hum.Health > 0 then
                        hasTarget = true
                        repeat
                            task.wait()
                            AutoHaki()
                            EquipWeapon(_G.SelectWeapon)
                            
                            -- Giữ khoảng cách farm an toàn phía trên quái (Banana Style)
                            Player.Character.HumanoidRootPart.CFrame = hrp.CFrame * CFrame.new(0, 20, 0) * CFrame.Angles(math.rad(-90), 0, 0)
                            
                            BringMobs(hrp.Position)
                            FastAttack()
                        until not _G.AutoLevel or not enemy.Parent or hum.Health <= 0
                    end
                end
            end)
        end
    end
end)

-- TAB: SEA EVENTS (KITSUNE / BONE)
if game.PlaceId == 7449423635 then -- Sea 3
    Tabs.Sea:AddSection("Sự Kiện Đảo Cáo (Kitsune Island)")

    Tabs.Sea:AddToggle("ToggleKitsuneTP", {
        Title = "Bay Đến Đảo Cáo",
        Default = false,
        Callback = function(v)
            _G.TweenToKitsune = v
        end
    })

    Tabs.Sea:AddToggle("ToggleAzure", {
        Title = "Tự Nhặt Linh Hồn Azure",
        Default = false,
        Callback = function(v)
            _G.CollectAzure = v
        end
    })

    Tabs.Sea:AddButton({
        Title = "Đổi Linh Hồn Lấy Quà (Kitsune Pray)",
        Callback = function()
            pcall(function()
                ReplicatedStorage.Modules.Net["RF/KitsuneStatuePray"]:InvokeServer()
            end)
        end
    })

    Tabs.Main:AddSection("Cày Xương (Bone Farm)")
    Tabs.Main:AddToggle("ToggleRandomBone", {
        Title = "Tự Động Random Xương",
        Default = false,
        Callback = function(v)
            _G.AutoRandomBone = v
        end
    })

    task.spawn(function()
        while task.wait(0.5) do
            if _G.AutoRandomBone then
                pcall(function()
                    ReplicatedStorage.Remotes.CommF_:InvokeServer("Bones", "Buy", 1, 1)
                end)
            end
        end
    end)
end

-- TAB: INFO
Tabs.Info:AddSection("Cộng Đồng & Hỗ Trợ")
Tabs.Info:AddButton({
    Title = "Copy Link Discord BDQ",
    Callback = function()
        setclipboard("https://dsc.gg/nopermc")
        Library:Notify({ Title = "Success", Description = "Đã copy link Discord!", Duration = 3 })
    end
})

Tabs.Info:AddButton({
    Title = "Kênh Youtube BDQ Hub",
    Callback = function()
        setclipboard("https://youtube.com/@nopermc")
        Library:Notify({ Title = "Success", Description = "Đã copy link Youtube!", Duration = 3 })
    end
})

-- NoClip Engine (Xử lý bay qua địa hình)
RunService.Stepped:Connect(function()
    if _G.AutoLevel or _G.TweenToKitsune or _G.CollectAzure then
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

-- Bật thông báo hoàn tất
Library:Notify({
    Title = "BDQ Hub x Banana",
    Description = "Script loaded thành công! Nhấn 'H' để Ẩn/Hiện Menu.",
    Duration = 5
})