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
local TeleportService = game:GetService("TeleportService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Lighting = game:GetService("Lighting")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui", 10)

-- ==========================================
-- EXPLOIT CHECK
-- ==========================================
local executor = (getexecutorname and getexecutorname()) or (identifyexecutor and identifyexecutor()) or ""
local executorName = string.lower(tostring(executor))

local allowedExecutors = {
    "delta", "fluxus", "fluxusz", "scriptware", "synapse x", "synapsex",
    "krnl", "arceus", "arceus x", "xeno", "swift", "volcano", "velocity",
    "comet", "sirius", "nexus", "hydrogen", "trigon", "vse", "jjsploit",
    "wearedevs", "electron", "reckless", "sunshine", "halo", "quasar", "codex"
}

local validExecutor = false
for _, name in ipairs(allowedExecutors) do
    if string.find(executorName, name, 1, true) then
        validExecutor = true
        break
    end
end

if executorName ~= "" and not validExecutor then
    Player:Kick("Vui lòng sử dụng Executor tương thích như Delta, Fluxus, Codex, KRNL, Synapse X...")
end

-- ==========================================
-- TẢI THƯ VIỆN UI (BDQ Hub)
-- ==========================================
local success, Library = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/hdanhhub/UI/refs/heads/main/ui_BananaHub_final.lua"))()
end)

if not success or type(Library) ~= "table" then
    warn("[BDQ Hub]: Không thể tải thư viện UI. Vui lòng kiểm tra lại kết nối mạng!")
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
            if k == "SetText" or k == "SetDesc" then
                return function(_, t)
                    if obj and obj.SetText then
                        return safeInvoke(obj.SetText, obj, t)
                    elseif obj and obj.SetDesc then
                        return safeInvoke(obj.SetDesc, obj, t)
                    end
                    return nil
                end
            end
            if k == "GetNewList" then
                return function(_, list)
                    if obj and obj.GetNewList then
                        return safeInvoke(obj.GetNewList, obj, list)
                    end
                    return nil
                end
            end
            if k == "ClearText" then
                return function(_, v)
                    if obj and obj.ClearText then
                        return safeInvoke(obj.ClearText, obj, v)
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
        setting["Description"] = nil
        setting.Description = nil
        local obj = _currentSection:AddToggle(id, setting)
        return makeProxy(obj, holder)
    end

    function wrapped:AddButton(setting, cb)
        ensureSection()
        if type(setting) == "table" then
            setting["Description"] = nil
            setting.Description = nil
        end
        local proxy = _currentSection:AddButton(setting, cb)
        if proxy then
            local holder = {}
            return makeProxy(proxy, holder)
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
        setting["Description"] = nil
        setting.Description = nil
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
        setting["Callback"] = setting.Callback
        setting["Description"] = nil
        setting.Description = nil
        local obj = _currentSection:AddSlider(setting)
        return makeProxy(obj, holder)
    end

    function wrapped:AddInput(id, setting)
        ensureSection()
        local holder = { extra = nil }
        local origCb = setting.Callback or setting["Callback"]
        setting.Callback = function(v)
            if origCb then pcall(origCb, v) end
            if holder.extra then pcall(holder.extra, v) end
        end
        setting["Callback"] = setting.Callback
        local obj = _currentSection:AddInput(id, setting)
        return makeProxy(obj, holder)
    end

    function wrapped:AddParagraph(setting)
        ensureSection()
        local title = setting.Title or setting["Title"] or ""
        local desc  = setting.Description or setting["Description"] or setting.Desc or ""
        local txt   = desc ~= "" and (title .. "\n" .. desc) or title
        local obj = _currentSection:AddLabel(txt)
        local holder = {}
        return makeProxy(obj, holder)
    end

    function wrapped:AddLabel(text)
        ensureSection()
        local obj = _currentSection:AddLabel(text)
        local holder = {}
        return makeProxy(obj, holder)
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

-- ==========================================
-- THIẾT LẬP THEME MÀU ĐEN (DARK MODE)
-- ==========================================
pcall(function()
    if Library.SetTheme then
        Library:SetTheme({
            Background         = Color3.fromRGB(18, 18, 20),
            Accent             = Color3.fromRGB(0, 150, 255),
            PrimaryText        = Color3.fromRGB(240, 240, 240),
            SecondaryText      = Color3.fromRGB(160, 160, 170),
            Divider            = Color3.fromRGB(35, 35, 40),
            Header             = Color3.fromRGB(25, 25, 30),
            Box                = Color3.fromRGB(28, 28, 32),
            Button             = Color3.fromRGB(35, 35, 42),
            Hover              = Color3.fromRGB(50, 50, 60),
            Toggle             = Color3.fromRGB(0, 150, 255),
            ToggleBackground   = Color3.fromRGB(30, 30, 35),
            Dropdown           = Color3.fromRGB(28, 28, 32),
            DropdownBackground = Color3.fromRGB(20, 20, 24),
            Scrollbar          = Color3.fromRGB(60, 60, 70),
            Outline            = Color3.fromRGB(45, 45, 50),
            Shadow             = Color3.fromRGB(0, 0, 0),
        })
    end
end)

-- ==========================================
-- DỮ LIỆU CÁC BIỂN (SEA DATA)
-- ==========================================
local PlaceId = game.PlaceId
local Sea1, Sea2, Sea3 = false, false, false

if PlaceId == 2753915549 then
    Sea1 = true
elseif PlaceId == 4442272183 then
    Sea2 = true
elseif PlaceId == 7449423635 then
    Sea3 = true
else
    Sea1 = true
end

local tableMon, AreaList = {}, {}

if Sea1 then
    tableMon = {
        "Bandit", "Monkey", "Gorilla", "Pirate", "Brute", "Desert Bandit", "Desert Officer",
        "Snow Bandit", "Snowman", "Chief Petty Officer", "Sky Bandit", "Dark Master", "Prisoner",
        "Dangerous Prisoner", "Toga Warrior", "Gladiator", "Military Soldier", "Military Spy",
        "Fishman Warrior", "Fishman Commando", "God's Guard", "Shanda", "Royal Squad",
        "Royal Soldier", "Galley Pirate", "Galley Captain"
    }
    AreaList = {
        "Jungle", "Buggy", "Desert", "Snow", "Marine", "Sky", "Prison",
        "Colosseum", "Magma", "Fishman", "Sky Island", "Fountain"
    }
elseif Sea2 then
    tableMon = {
        "Raider", "Mercenary", "Swan Pirate", "Factory Staff", "Marine Lieutenant", "Marine Captain",
        "Zombie", "Vampire", "Snow Trooper", "Winter Warrior", "Lab Subordinate", "Horned Warrior",
        "Magma Ninja", "Lava Pirate", "Ship Deckhand", "Ship Engineer", "Ship Steward", "Ship Officer",
        "Arctic Warrior", "Snow Lurker", "Sea Soldier", "Water Fighter"
    }
    AreaList = {
        "Area 1", "Area 2", "Zombie", "Marine", "Snow Mountain", "Ice fire", "Ship", "Frost", "Forgotten"
    }
elseif Sea3 then
    tableMon = {
        "Pirate Millionaire", "Dragon Crew Warrior", "Dragon Crew Archer", "Hydra Enforcer", "Venomous Assailant",
        "Marine Commodore", "Marine Rear Admiral", "Fishman Raider", "Fishman Captain", "Forest Pirate",
        "Mythological Pirate", "Jungle Pirate", "Musketeer Pirate", "Reborn Skeleton", "Living Zombie",
        "Demonic Soul", "Posessed Mummy", "Peanut Scout", "Peanut President", "Ice Cream Chef",
        "Ice Cream Commander", "Cookie Crafter", "Cake Guard", "Baking Staff", "Head Baker",
        "Cocoa Warrior", "Chocolate Bar Battler", "Sweet Thief", "Candy Rebel", "Candy Pirate",
        "Snow Demon", "Isle Outlaw", "Island Boy", "Sun-kissed Warrior", "Isle Champion",
        "Serpent Hunter", "Skull Slayer"
    }
    AreaList = {
        "Pirate Port", "Amazon", "Marine Tree", "Deep Forest", "Haunted Castle", "Nut Island",
        "Ice Cream Island", "Cake Island", "Choco Island", "Candy Island", "Tiki Outpost"
    }
end

-- ==========================================
-- GIAO DIỆN CHI TIẾT TỪNG TAB
-- ==========================================

-- TAB: INFO
Tabs.Info:AddParagraph({ Title = "BDQ Hub", Description = "Phiên bản Blox Fruit Dark UI" })
Tabs.Info:AddLabel("Chủ sở hữu: BDQ")
Tabs.Info:AddButton({ Text = "Sao chép Discord Link" }, function()
    setclipboard("https://discord.gg/")
    Library:Notify({ Title = "Thông báo", Description = "Đã sao chép link Discord!", Duration = 3 })
end)

-- TAB: MAIN
Tabs.Main:AddSection("Tự Động Cày Cấp")
Tabs.Main:AddToggle("AutoFarmLevel", {
    Text = "Auto Farm Level",
    Default = false,
    Callback = function(v) _G.AutoLevel = v end
})
Tabs.Main:AddDropdown("SelectWeapon", {
    Title = "Chọn Vũ Khí",
    Values = {"Melee", "Sword", "Blox Fruit"},
    Default = "Melee",
    Callback = function(v) _G.SelectWeapon = v end
})

Tabs.Main:AddSection("Tự Động Đánh Quái Chọn Lựa")
Tabs.Main:AddDropdown("SelectMonster", {
    Title = "Chọn Quái",
    Values = tableMon,
    Default = tableMon[1] or "Bandit",
    Callback = function(v) SelectMonster = v end
})
Tabs.Main:AddToggle("AutoFarmSelectedMonster", {
    Text = "Auto Farm Quái Đã Chọn",
    Default = false,
    Callback = function(v) _G.AutoFarmSelected = v end
})

-- TAB: SEA
Tabs.Sea:AddSection("Sự Kiện Biển")
Tabs.Sea:AddToggle("AutoSeaEvent", {
    Text = "Auto Sea Event",
    Default = false,
    Callback = function(v) _G.AutoSea = v end
})

-- TAB: ITEM
Tabs.Item:AddSection("Lấy & Nâng Cấp Võ")
Tabs.Item:AddToggle("AutoSuperhuman", { Text = "Auto Superhuman", Default = false, Callback = function(v) _G.AutoSuperhuman = v end })
Tabs.Item:AddToggle("AutoDeathStep", { Text = "Auto Death Step", Default = false, Callback = function(v) _G.AutoDeathStep = v end })
Tabs.Item:AddToggle("AutoSharkmanKarate", { Text = "Auto Sharkman Karate", Default = false, Callback = function(v) _G.AutoSharkmanKarate = v end })
Tabs.Item:AddToggle("AutoElectricClaw", { Text = "Auto Electric Claw", Default = false, Callback = function(v) _G.AutoElectricClaw = v end })
Tabs.Item:AddToggle("AutoDragonTalon", { Text = "Auto Dragon Talon", Default = false, Callback = function(v) _G.AutoDragonTalon = v end })
Tabs.Item:AddToggle("AutoGodhuman", { Text = "Auto Godhuman", Default = false, Callback = function(v) _G.AutoGodhuman = v end })

-- TAB: STATS
Tabs.Stats:AddSection("Tự Động Cộng Điểm")
Tabs.Stats:AddToggle("StatsMelee", { Text = "Melee", Default = false, Callback = function(v) _G.StatsMelee = v end })
Tabs.Stats:AddToggle("StatsDefense", { Text = "Defense", Default = false, Callback = function(v) _G.StatsDefense = v end })
Tabs.Stats:AddToggle("StatsSword", { Text = "Sword", Default = false, Callback = function(v) _G.StatsSword = v end })
Tabs.Stats:AddToggle("StatsGun", { Text = "Gun", Default = false, Callback = function(v) _G.StatsGun = v end })
Tabs.Stats:AddToggle("StatsFruit", { Text = "Blox Fruits", Default = false, Callback = function(v) _G.StatsFruit = v end })

-- TAB: TELEPORT
Tabs.Teleport:AddSection("Dịch Chuyển Đảo")
Tabs.Teleport:AddDropdown("SelectArea", {
    Title = "Chọn Đảo",
    Values = AreaList,
    Default = AreaList[1] or "Jungle",
    Callback = function(v) SelectArea = v end
})
Tabs.Teleport:AddButton({ Text = "Dịch Chuyển Đến Đảo" }, function()
    Library:Notify({ Title = "Dịch Chuyển", Description = "Đang di chuyển đến " .. tostring(SelectArea), Duration = 3 })
end)

-- TAB: FRUIT
Tabs.Fruit:AddSection("Trái Ác Quỷ")
Tabs.Fruit:AddButton({ Text = "Mua Trái Ác Quỷ Ngẫu Nhiên (Random Fruit)" }, function()
    pcall(function()
        ReplicatedStorage.Remotes.CommF_:InvokeServer("Cousin", "Buy")
    end)
end)
Tabs.Fruit:AddToggle("AutoStoreFruit", { Text = "Auto Store Fruit", Default = true, Callback = function(v) _G.AutoStoreFruit = v end })

-- TAB: MISC
Tabs.Misc:AddSection("Tiện Ích")
Tabs.Misc:AddButton({ Text = "Mở Bàn Phím Sửa Lỗi Chat / Console" }, function()
    game:GetService("StarterGui"):SetCore("DevConsoleVisible", true)
end)
Tabs.Misc:AddToggle("RejoinOnKick", { Text = "Tự Động Kết Nối Lại Khi Bị Văng", Default = true, Callback = function(v) _G.AutoRejoin = v end })

-- ==========================================
-- THÔNG BÁO HOÀN TẤT
-- ==========================================
Library:Notify({
    Title = "BDQ Hub",
    Description = "Đã tải thành công giao diện Dark Mode!",
    Duration = 4
})