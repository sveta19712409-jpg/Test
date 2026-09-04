-- ==========================================
-- СКРЫТЫЙ ПОЛЁТ (без BodyVelocity) для EH
-- ==========================================

local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local flying = false
local speed = 40
local runService = game:GetService("RunService")
local uis = game:GetService("UserInputService")

local function toggleFly()
    flying = not flying
    print(flying and "🛩️ Полет включен" or "🛩️ Полет выключен")
end

-- Управление с клавиатуры
uis.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.F then
        toggleFly()
    end
end)

-- Основной цикл полёта (без BodyVelocity)
runService.Heartbeat:Connect(function(dt)
    if not flying or not hrp or not hrp.Parent then return end
    local dir = Vector3.new(0,0,0)
    if uis:IsKeyDown(Enum.KeyCode.W) then dir = dir + hrp.CFrame.LookVector end
    if uis:IsKeyDown(Enum.KeyCode.S) then dir = dir - hrp.CFrame.LookVector end
    if uis:IsKeyDown(Enum.KeyCode.A) then dir = dir - hrp.CFrame.RightVector end
    if uis:IsKeyDown(Enum.KeyCode.D) then dir = dir + hrp.CFrame.RightVector end
    if uis:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
    if uis:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0,1,0) end
    if dir.Magnitude > 0 then
        dir = dir.Unit * speed * dt * 60 -- плавное движение
        hrp.CFrame = hrp.CFrame + dir
    end
end)

print("✅ Скрытый полёт активирован. Нажми F для включения/выключения.")
