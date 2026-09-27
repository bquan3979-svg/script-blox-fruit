-- ==========================================
-- BDQ HUB - BLOX FRUIT (PC & MOBILE)
-- ==========================================

-- Tải Thư Viện UI Kavo
local Kavo = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Kavo.CreateLib("BDQ Hub - Blox Fruit", "DarkTheme")

-- ==========================================
-- TẠO CÁC TABS PHỤ
-- ==========================================
local TabInfo  = Window:NewTab("Thông Tin")
local TabMain  = Window:NewTab("Cày Cấp")
local TabSea   = Window:NewTab("Sự Kiện")
local TabStats = Window:NewTab("Chỉ Số")
local TabFruit = Window:NewTab("Trái Ác Quỷ")
local TabTele  = Window:NewTab("Dịch Chuyển")
local TabMisc  = Window:NewTab("Khác")

-- ==========================================
-- TAB THÔNG TIN
-- ==========================================
local SectionInfo = TabInfo:NewSection("Thông Tin Script")
SectionInfo:NewLabel("BDQ Hub - Hỗ Trợ PC & Mobile")
SectionInfo:NewLabel("Chủ Sở Hữu: BDQ")
SectionInfo:NewLabel("Phím Tắt Mở UI trên PC: Right Ctrl")
SectionInfo:NewButton("Sao Chép Link Discord", "Copy link Discord hỗ trợ", function()
    setclipboard("https://discord.gg/hdanhhub")
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "BDQ Hub",
        Text = "Đã sao chép link Discord!",
        Duration = 3
    })
end)

-- ==========================================
-- TAB CÀY CẤP (MAIN)
-- ==========================================
local SectionMain = TabMain:NewSection("Tự Động Cày Cấp")

SectionMain:NewToggle("Auto Farm Level", "Bật/Tắt tự động farm level", function(state)
    _G.AutoLevel = state
end)

SectionMain:NewDropdown("Chọn Vũ Khí", "Chọn loại vũ khí để farm", {"Melee", "Sword", "Blox Fruit"}, function(v)
    _G.SelectWeapon = v
end)

local SectionFarmMon = TabMain:NewSection("Farm Quái Chọn Lựa")
SectionFarmMon:NewDropdown("Chọn Quái", "Danh sách quái", {"Bandit", "Monkey", "Gorilla", "Pirate"}, function(v)
    _G.SelectMonster = v
end)

SectionFarmMon:NewToggle("Auto Farm Quái Đã Chọn", "Bật/Tắt farm quái chọn", function(state)
    _G.AutoFarmSelected = state
end)

-- ==========================================
-- TAB SỰ KIỆN (SEA)
-- ==========================================
local SectionSea = TabSea:NewSection("Sự Kiện Biển")
SectionSea:NewToggle("Auto Sea Event", "Tự động làm sự kiện biển", function(state)
    _G.AutoSea = state
end)

-- ==========================================
-- TAB CHỈ SỐ (STATS)
-- ==========================================
local SectionStats = TabStats:NewSection("Tự Động Cộng Điểm")
SectionStats:NewToggle("Cộng Melee", "Tự cộng điểm Cận chiến", function(state) _G.StatsMelee = state end)
SectionStats:NewToggle("Cộng Defense", "Tự cộng điểm Máu/Giáp", function(state) _G.StatsDefense = state end)
SectionStats:NewToggle("Cộng Sword", "Tự cộng điểm Kiếm", function(state) _G.StatsSword = state end)
SectionStats:NewToggle("Cộng Blox Fruit", "Tự cộng điểm Trái ác quỷ", function(state) _G.StatsFruit = state end)

-- ==========================================
-- TAB TRÁI ÁC QUỶ (FRUIT)
-- ==========================================
local SectionFruit = TabFruit:NewSection("Tính Năng Trái Ác Quỷ")
SectionFruit:NewButton("Random Trái Ác Quỷ", "Mua ngẫu nhiên trái ác quỷ", function()
    pcall(function()
        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Cousin", "Buy")
    end)
end)

SectionFruit:NewToggle("Auto Cất Trái (Store Fruit)", "Tự cất trái vào rương", function(state)
    _G.AutoStoreFruit = state
end)

-- ==========================================
-- TAB KHÁC (MISC)
-- ==========================================
local SectionMisc = TabMisc:NewSection("Cài Đặt Tiện Ích")
SectionMisc:NewButton("Mở Console / Sửa Lỗi Chat", "Mở bảng lệnh F9", function()
    game:GetService("StarterGui"):SetCore("DevConsoleVisible", true)
end)

SectionMisc:NewKeybind("Bật/Tắt Menu UI (Phím PC)", "Phím tắt ẩn/hiện bảng", Enum.KeyCode.RightControl, function()
    Kavo:ToggleUI()
end)

-- ==========================================
-- NÚT BẬT/TẮT MENU DÀNH CHO MOBILE & PC
-- ==========================================
task.spawn(function()
    local CoreGui = game:GetService("CoreGui")
    if CoreGui:FindFirstChild("BDQToggleGui") then
        CoreGui.BDQToggleGui:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    local ToggleButton = Instance.new("TextButton")
    local UICorner = Instance.new("UICorner")

    ScreenGui.Name = "BDQToggleGui"
    ScreenGui.Parent = CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    ToggleButton.Name = "ToggleButton"
    ToggleButton.Parent = ScreenGui
    ToggleButton.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    ToggleButton.Position = UDim2.new(0, 10, 0, 200)
    ToggleButton.Size = UDim2.new(0, 80, 0, 35)
    ToggleButton.Font = Enum.Font.SourceSansBold
    ToggleButton.Text = "BDQ HUB"
    ToggleButton.TextColor3 = Color3.fromRGB(0, 170, 255)
    ToggleButton.TextSize = 14.000
    ToggleButton.Active = true
    ToggleButton.Draggable = true

    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = ToggleButton

    ToggleButton.MouseButton1Click:Connect(function()
        Kavo:ToggleUI()
    end)
end)

-- Anti AFK
task.spawn(function()
    local VirtualUser = game:GetService("VirtualUser")
    game:GetService("Players").LocalPlayer.Idled:Connect(function()
        VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    end)
end)