-- Tải thư viện RedzLib V2 (Thư viện chuẩn của Banana Hub)
local RedzLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/REDzHUB/RedzLibV2/main/NewUi.lua"))()

-- Tạo Window chính
local Window = RedzLib:MakeWindow({
    Title = "BDQ Hub - Blox Fruit",
    SubTitle = "Banana Style Edition",
    SaveFolder = "BDQ_Hub_Config"
})

-- Tạo các Tab bên menu trái (sidebar)
local TabMain = Window:MakeTab({"Farming", "rbxassetid://10723407097"})
local TabItem = Window:MakeTab({"Get & Upgrade Items", "rbxassetid://10709782845"})
local TabSea  = Window:MakeTab({"Sea Event", "rbxassetid://10709782230"})
local TabFruit = Window:MakeTab({"Fruit & Raid", "rbxassetid://10709782522"})
local TabStats = Window:MakeTab({"Stats", "rbxassetid://10709782136"})
local TabTele  = Window:MakeTab({"Teleport", "rbxassetid://10709781919"})
local TabInfo  = Window:MakeTab({"Information", "rbxassetid://10709783103"})

-- Safe Globals
_G.AutoLevel = false
_G.FastAttack = false
_G.BringMob = false
_G.AutoRandomBone = false
_G.TweenToKitsune = false
_G.CollectAzure = false
_G.SelectWeapon = "Melee"

----------------------------------------------------
-- 1. TAB FARMING
----------------------------------------------------
TabMain:AddSection({"Auto Farm Settings"})

TabMain:AddDropdown({
    Name = "Select Weapon",
    Options = {"Melee", "Sword", "Blox Fruit"},
    Default = "Melee",
    Callback = function(v)
        _G.SelectWeapon = v
    end
})

TabMain:AddToggle({
    Name = "Auto Farm Level",
    Default = false,
    Callback = function(v)
        _G.AutoLevel = v
    end
})

TabMain:AddToggle({
    Name = "Fast Attack",
    Default = true,
    Callback = function(v)
        _G.FastAttack = v
    end
})

TabMain:AddToggle({
    Name = "Bring Mobs",
    Default = true,
    Callback = function(v)
        _G.BringMob = v
    end
})

----------------------------------------------------
-- 2. TAB ITEM
----------------------------------------------------
TabItem:AddSection({"Bone & Upgrades"})

if game.PlaceId == 7449423635 then -- Sea 3
    TabItem:AddToggle({
        Name = "Auto Random Bone",
        Default = false,
        Callback = function(v)
            _G.AutoRandomBone = v
        end
    })
end

----------------------------------------------------
-- 3. TAB SEA EVENT
----------------------------------------------------
TabSea:AddSection({"Kitsune Island"})

if game.PlaceId == 7449423635 then -- Sea 3
    TabSea:AddToggle({
        Name = "Tween To Kitsune Island",
        Default = false,
        Callback = function(v)
            _G.TweenToKitsune = v
        end
    })

    TabSea:AddToggle({
        Name = "Collect Azure Ember",
        Default = false,
        Callback = function(v)
            _G.CollectAzure = v
        end
    })

    TabSea:AddButton({
        Name = "Kitsune Statue Pray",
        Callback = function()
            pcall(function()
                game:GetService("ReplicatedStorage").Modules.Net["RF/KitsuneStatuePray"]:InvokeServer()
            end)
        end
    })
end

----------------------------------------------------
-- 4. TAB INFORMATION
----------------------------------------------------
TabInfo:AddSection({"BDQ Hub Socials"})

TabInfo:AddButton({
    Name = "Copy Discord Link",
    Callback = function()
        setclipboard("https://dsc.gg/nopermc")
    end
})

TabInfo:AddButton({
    Name = "Copy Youtube Link",
    Callback = function()
        setclipboard("https://youtube.com/@nopermc")
    end
})

----------------------------------------------------
-- CORE LOGIC (FARMING & FAST ATTACK)
----------------------------------------------------
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Player = Players.LocalPlayer

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

-- Vòng lặp Farm Level
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

-- Vòng lặp Random Bone
task.spawn(function()
    while task.wait(0.5) do
        if _G.AutoRandomBone then
            pcall(function()
                ReplicatedStorage.Remotes.CommF_:InvokeServer("Bones", "Buy", 1, 1)
            end)
        end
    end
end)

-- NoClip Engine
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