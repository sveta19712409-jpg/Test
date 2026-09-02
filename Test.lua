loadstring([[
-- ==========================================
-- ОСНОВНОЙ СКРИПТ: GUI + КЛОНИРОВАНИЕ + СБОР + ФАРМ + КВЕСТЫ
-- СТИЛЬ: REDZ HUB
-- ==========================================

-- === НАСТРОЙКИ (меняй под себя) ===
local Settings = {
    Fruits = {"Control", "Leopard", "Kitsune", "T-Rex", "Yeti"},
    CloneOffset = Vector3.new(5, 0, 0),
    CollectDistance = 25,
    FarmRange = 35,
    AttackKey = Enum.KeyCode.E,
    QuestNPCs = {"Quest Giver", "NPC", "Giver"},
    QuestDistance = 15,
    QuestInterval = 30,
}

-- === СОЗДАНИЕ GUI (REDZ СТИЛЬ) ===
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/main/fluent.luau"))()
local Window = Library:CreateWindow({
    Title = "🔥 Redz Style | Blox Fruits",
    SubTitle = "by Custom Script",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightControl,
})

-- Вкладка "Фарм"
local FarmTab = Window:AddTab({ Title = "🤖 Фарм", Icon = "farm" })

-- Вкладка "Фрукты"
local FruitTab = Window:AddTab({ Title = "🍎 Фрукты", Icon = "fruit" })

-- Вкладка "Настройки"
local SettingsTab = Window:AddTab({ Title = "⚙️ Настройки", Icon = "settings" })

-- === ПЕРЕМЕННЫЕ ДЛЯ УПРАВЛЕНИЯ ===
local AutoCollect = false
local AutoFarm = false
local AutoClone = false
local CollectLoop = nil
local FarmLoop = nil

-- === ОСНОВНЫЕ ФУНКЦИИ ===
local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local humanoid = char:WaitForChild("Humanoid")
local vim = game:GetService("VirtualInputManager")
local mouse = player:GetMouse()

local function clickObject(pos)
    mouse.Move(pos)
    wait(0.05)
    mouse.Click()
end

local function pressKey(key, duration)
    duration = duration or 0.1
    vim:SendKeyEvent(true, key, false, game)
    wait(duration)
    vim:SendKeyEvent(false, key, false, game)
end

-- === 1. КЛОНИРОВАНИЕ ===
local function cloneFruit(original)
    if not original or not original:IsA("Model") then return end
    local primary = original.PrimaryPart
    if not primary then return end
    local clone = original:Clone()
    clone.Parent = workspace
    clone:SetPrimaryPartCFrame(primary.CFrame + Settings.CloneOffset)
    print("[Клон] Создан: " .. original.Name)
    return clone
end

local function startCloning()
    if AutoClone then return end
    AutoClone = true
    print("[Клон] Запущен")
    workspace.ChildAdded:Connect(function(child)
        if not AutoClone then return end
        for _, name in ipairs(Settings.Fruits) do
            if child.Name == name then
                wait(0.3)
                cloneFruit(child)
                break
            end
        end
    end)
    for _, obj in pairs(workspace:GetChildren()) do
        for _, name in ipairs(Settings.Fruits) do
            if obj.Name == name then
                cloneFruit(obj)
                break
            end
        end
    end
end

-- === 2. АВТОСБОР ===
local function collectNearestFruit()
    local closest, minDist = nil, Settings.CollectDistance
    for _, obj in pairs(workspace:GetChildren()) do
        for _, name in ipairs(Settings.Fruits) do
            if obj.Name == name then
                local pos = obj.PrimaryPart and obj.PrimaryPart.Position or obj.Position
                local d = (pos - hrp.Position).Magnitude
                if d < minDist then
                    minDist = d
                    closest = obj
                end
                break
            end
        end
    end
    if closest then
        local pos = closest.PrimaryPart and closest.PrimaryPart.Position or closest.Position
        humanoid:MoveTo(pos)
        repeat wait(0.2) until (pos - hrp.Position).Magnitude < 5 or not AutoCollect
        if (pos - hrp.Position).Magnitude < 5 then
            pressKey(Enum.KeyCode.E)
            wait(0.1)
            clickObject(pos)
            print("[Сбор] Подобран " .. closest.Name)
            return true
        end
    end
    return false
end

local function startCollecting()
    if CollectLoop then return end
    AutoCollect = true
    CollectLoop = game:GetService("RunService").Heartbeat:Connect(function()
        if AutoCollect then
            collectNearestFruit()
        end
    end)
    print("[Сбор] Запущен")
end

local function stopCollecting()
    AutoCollect = false
    if CollectLoop then
        CollectLoop:Disconnect()
        CollectLoop = nil
    end
    print("[Сбор] Остановлен")
end

-- === 3. КВЕСТ + ФАРМ ===
local function findQuestNPC()
    for _, obj in pairs(workspace:GetChildren()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") then
            for _, name in ipairs(Settings.QuestNPCs) do
                if obj.Name:find(name) or obj.Name == name then
                    local pos = obj.PrimaryPart and obj.PrimaryPart.Position or obj.HumanoidRootPart.Position
                    return obj, pos
                end
            end
        end
    end
    return nil, nil
end

local function takeQuest()
    local npc, pos = findQuestNPC()
    if not npc then
        print("[Квест] NPC не найден")
        return false
    end
    local dist = (pos - hrp.Position).Magnitude
    if dist > Settings.QuestDistance then
        humanoid:MoveTo(pos)
        repeat wait(0.2) until (pos - hrp.Position).Magnitude < Settings.QuestDistance or not AutoFarm
        if (pos - hrp.Position).Magnitude > Settings.QuestDistance then
            print("[Квест] Не удалось подойти к NPC")
            return false
        end
    end
    pressKey(Enum.KeyCode.E, 0.2)
    wait(0.3)
    clickObject(pos)
    print("[Квест] Взято задание у " .. npc.Name)
    return true
end

local function getNearestEnemy()
    local enemies = {}
    for _, obj in pairs(workspace:GetChildren()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") then
            local isPlayer = game.Players:GetPlayerFromCharacter(obj)
            if not isPlayer and obj.Name ~= player.Name then
                table.insert(enemies, obj)
            end
        end
    end
    local closest, minDist = nil, Settings.FarmRange
    for _, enemy in ipairs(enemies) do
        local pos = enemy.PrimaryPart and enemy.PrimaryPart.Position or enemy.HumanoidRootPart.Position
        local d = (pos - hrp.Position).Magnitude
        if d < minDist then
            minDist = d
            closest = enemy
        end
    end
    return closest
end

local function attackEnemy(enemy)
    if not enemy then return false end
    local pos = enemy.PrimaryPart and enemy.PrimaryPart.Position or enemy.HumanoidRootPart.Position
    humanoid:MoveTo(pos)
    repeat wait(0.2) until (pos - hrp.Position).Magnitude < 10 or not AutoFarm
    if (pos - hrp.Position).Magnitude < 10 then
        pressKey(Settings.AttackKey, 0.3)
        clickObject(pos)
        return true
    end
    return false
end

local lastQuestTime = 0

local function startFarming()
    if FarmLoop then return end
    AutoFarm = true
    FarmLoop = game:GetService("RunService").Heartbeat:Connect(function()
        if not AutoFarm then return end
        local now = tick()
        if now - lastQuestTime > Settings.QuestInterval then
            takeQuest()
            lastQuestTime = now
        end
        local enemy = getNearestEnemy()
        if enemy then
            attackEnemy(enemy)
        end
    end)
    print("[Фарм] Запущен")
end

local function stopFarming()
    AutoFarm = false
    if FarmLoop then
        FarmLoop:Disconnect()
        FarmLoop = nil
    end
    print("[Фарм] Остановлен")
end

-- === СОЗДАНИЕ ЭЛЕМЕНТОВ GUI ===

-- Вкладка "Фарм"
FarmTab:AddToggle("AutoFarm", {
    Title = "Автофарм + Квесты",
    Default = false,
    Callback = function(Value)
        if Value then
            startFarming()
        else
            stopFarming()
        end
    end
})

FarmTab:AddToggle("AutoCollect", {
    Title = "Автосбор фруктов",
    Default = false,
    Callback = function(Value)
        if Value then
            startCollecting()
        else
            stopCollecting()
        end
    end
})

-- Вкладка "Фрукты"
FruitTab:AddToggle("AutoClone", {
    Title = "Клонирование фруктов",
    Default = false,
    Callback = function(Value)
        if Value then
            startCloning()
        else
            AutoClone = false
            print("[Клон] Остановлен")
        end
    end
})

FruitTab:AddButton("Собрать ближайший фрукт", function()
    collectNearestFruit()
end)

-- Вкладка "Настройки"
SettingsTab:AddParagraph("Информация", "Скрипт создан в стиле Redz Hub.\nКлонирует: Control, Leopard, Kitsune, T-Rex, Yeti.\nАвтофарм + квесты.\nАвтосбор.")

SettingsTab:AddButton("Остановить всё", function()
    stopFarming()
    stopCollecting()
    AutoClone = false
    print("[Стоп] Все процессы остановлены")
end)

print("✅ GUI загружен! Используй RightControl для сворачивания.")
]])
