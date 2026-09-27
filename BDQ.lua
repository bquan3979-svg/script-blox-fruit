local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui", 5)
local Character = Player.Character or Player.CharacterAdded:Wait()

-- Safe Globals
_G.AutoLevel = false
_G.FastAttack = false
_G.BringMob = false
_G.AutoBone = false
_G.AutoRandomBone = false
_G.TweenToKitsune = false
_G.CollectAzure = false
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

-- Tải Thư viện UI LinoriaLib (Dark Theme Style)
local success, Library = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/mstudio45/LinoriaLib/main/Library.lua"))()
end)
if not success or not Library then
    warn("Lỗi tải thư viện LinoriaLib")
    return
end

local Window = Library:CreateWindow({
    Title = "BDQ Hub - Blox Fruit (Dark Edition)",
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

-- Thiết lập Màu Đen (Dark Theme Style)
pcall(function()
    if Library.SetTheme then
        Library:SetTheme({
            Background         = Color3.fromRGB(18, 18, 18),
            Accent             = Color3.fromRGB(45, 45, 45),
            PrimaryText        = Color3.fromRGB(240, 240, 240),
            SecondaryText      = Color3.fromRGB(160, 160, 160),
            Divider            = Color3.fromRGB(35, 35, 35),
            Header             = Color3.fromRGB(25, 25, 25),
            Box                = Color3.fromRGB(28, 28, 28),
            Button             = Color3.fromRGB(35, 35, 35),
            Hover              = Color3.fromRGB(50, 50, 50),
            Toggle             = Color3.fromRGB(255, 255, 255),
            ToggleBackground   = Color3.fromRGB(30, 30, 30),
            Dropdown           = Color3.fromRGB(28, 28, 28),
            DropdownBackground = Color3.fromRGB(20, 20, 20),
            Scrollbar          = Color3.fromRGB(60, 60, 60),
            Outline            = Color3.fromRGB(40, 40, 40),
            Shadow             = Color3.fromRGB(0, 0, 0),
        })
    end
end)

-- Tạo các Tab danh mục bên trái (Left Sidebar Tabs)
local Tabs = {
    Main     = Window:AddTab("Farming"),
    Item     = Window:AddTab("Get and Upgrade Items"),
    Sea      = Window:AddTab("Sea Event"),
    Fruit    = Window:AddTab("Fruit and Raid"),
    Stats    = Window:AddTab("Stats"),
    Teleport = Window:AddTab("Teleport"),
    Info     = Window:AddTab("Information"),
}

-- 1. TAB FARMING
local FarmGroup = Tabs.Main:AddLeftGroupbox("Auto Farm Settings")

FarmGroup:AddDropdown("SelectWeapon", {
    Values = { "Melee", "Sword", "Blox Fruit" },
    Default = 1,
    Multi = false,
    Text = "Select Weapon",
    Callback = function(v)
        _G.SelectWeapon = v
    end
})

FarmGroup:AddToggle("ToggleAutoLevel", {
    Text = "Auto Farm Level",
    Default = false,
    Callback = function(v)
        _G.AutoLevel = v
    end
})

FarmGroup:AddToggle("ToggleFastAttack", {
    Text = "Fast Attack",
    Default = true,
    Callback = function(v)
        _G.FastAttack = v
    end
})

FarmGroup:AddToggle("ToggleBringMob", {
    Text = "Bring Mobs",
    Default = true,
    Callback = function(v)
        _G.BringMob = v
    end
})

-- 2. TAB GET AND UPGRADE ITEMS
local ItemGroup = Tabs.Item:AddLeftGroupbox("Items & Upgrades")

if game.PlaceId == 7449423635 then -- Sea 3
    ItemGroup:AddToggle("ToggleRandomBone", {
        Text = "Auto Random Bone",
        Default = false,
        Callback = function(v)
            _G.AutoRandomBone = v
        end
    })
end

-- 3. TAB SEA EVENT
local SeaGroup = Tabs.Sea:AddLeftGroupbox("Kitsune Island")

if game.PlaceId == 7449423635 then -- Sea 3
    SeaGroup:AddToggle("ToggleKitsuneTP", {
        Text = "Tween To Kitsune Island",
        Default = false,
        Callback = function(v)
            _G.TweenToKitsune = v
        end
    })

    SeaGroup:AddToggle("ToggleAzure", {
        Text = "Collect Azure Ember",
        Default = false,
        Callback = function(v)
            _G.CollectAzure = v
        end
    })

    SeaGroup:AddButton({
        Text = "Kitsune Statue Pray",
        Func = function()
            pcall(function()
                ReplicatedStorage.Modules.Net["RF/KitsuneStatuePray"]:InvokeServer()
            end)
        end
    })
end

-- 4. TAB INFORMATION
local InfoGroup = Tabs.Info:AddLeftGroupbox("BDQ Hub Socials")

InfoGroup:AddButton({
    Text = "Copy Discord Link",
    Func = function()
        setclipboard("https://dsc.gg/nopermc")
        Library:Notify("Đã copy link Discord vào bộ nhớ tạm!")
    end
})

InfoGroup:AddButton({
    Text = "Copy Youtube Link",
    Func = function()
        setclipboard("https://youtube.com/@nopermc")
        Library:Notify("Đã copy link Youtube vào bộ nhớ tạm!")
    end
})

-- WATERMARK (FPS & PING)
local FrameTimer = tick()
local FrameCounter = 0
local FPS = 60
Library:SetWatermark("BDQ Hub Dark | FPS: 60 | Ping: 0ms")

RunService.RenderStepped:Connect(function()
    FrameCounter = FrameCounter + 1
    if (tick() - FrameTimer) >= 1 then
        FPS = FrameCounter
        FrameCounter = 0
        FrameTimer = tick()
        local ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
        Library:SetWatermark(string.format("BDQ Hub Dark | FPS: %d | Ping: %dms", FPS, ping))
    end
end)

-- CORE FUNCTIONS
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

-- AUTO FARM LOOP
task.spawn(function()
    while task.wait(0.1) do
        if _G.AutoLevel then
            pcall(function()
                AutoHaki()
                EquipWeapon(_G.SelectWeapon)

                local enemies = Workspace.Enemies:GetChildren()
                for _, enemy in pairs(enemies) do
                    local hum = enemy:FindFirstChild("Humanoid")
                    local hrp = enemy:FindFirstChild("HumanoidRootPart")
                    if hum and hrp and hum.Health > 0 then
                        repeat
                            task.wait()
                            AutoHaki()
                            EquipWeapon(_G.SelectWeapon)
                            
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

-- ANTI-AFK & NOCLIP
Players.LocalPlayer.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
end)

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

-- THÔNG BÁO TẢI THÀNH CÔNG
Library:Notify("BDQ Hub - Dark Theme đã tải thành công!")