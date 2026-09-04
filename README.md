-- ==========================================
-- FLY SCRIPT С МЕНЮ (Emergency Hamburg)
-- ==========================================

local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local flying = false
local speed = 50
local bodyVel, bodyGyro

-- Функция включения/выключения полёта
local function toggleFly()
    flying = not flying
    if flying then
        bodyVel = Instance.new("BodyVelocity")
        bodyVel.Velocity = Vector3.new(0,0,0)
        bodyVel.MaxForce = Vector3.new(1e9,1e9,1e9)
        bodyGyro = Instance.new("BodyGyro")
        bodyGyro.MaxTorque = Vector3.new(1e9,1e9,1e9)
        bodyVel.Parent = hrp
        bodyGyro.Parent = hrp
        game:GetService("RunService").Heartbeat:Connect(function()
            if flying and hrp and hrp.Parent then
                local dir = Vector3.new(0,0,0)
                local uis = game:GetService("UserInputService")
                if uis:IsKeyDown(Enum.KeyCode.W) then dir = dir + hrp.CFrame.LookVector end
                if uis:IsKeyDown(Enum.KeyCode.S) then dir = dir - hrp.CFrame.LookVector end
                if uis:IsKeyDown(Enum.KeyCode.A) then dir = dir - hrp.CFrame.RightVector end
                if uis:IsKeyDown(Enum.KeyCode.D) then dir = dir + hrp.CFrame.RightVector end
                if uis:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
                if uis:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0,1,0) end
                if dir.Magnitude > 0 then dir = dir.Unit * speed end
                bodyVel.Velocity = dir
                bodyGyro.CFrame = hrp.CFrame
            end
        end)
    else
        if bodyVel then bodyVel:Destroy() end
        if bodyGyro then bodyGyro:Destroy() end
    end
end

-- СОЗДАНИЕ GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FlyMenu"
screenGui.Parent = player.PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 250, 0, 150)
frame.Position = UDim2.new(0.5, -125, 0.5, -75)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
frame.BackgroundTransparency = 0.2
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.Text = "🛩️ Управление полётом"
title.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Parent = frame

local flyBtn = Instance.new("TextButton")
flyBtn.Size = UDim2.new(0, 150, 0, 35)
flyBtn.Position = UDim2.new(0.5, -75, 0, 40)
flyBtn.Text = "Включить полёт"
flyBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 60)
flyBtn.TextColor3 = Color3.fromRGB(255,255,255)
flyBtn.Parent = frame
flyBtn.MouseButton1Click:Connect(function()
    toggleFly()
    flyBtn.Text = flying and "Отключить полёт" or "Включить полёт"
    flyBtn.BackgroundColor3 = flying and Color3.fromRGB(180, 50, 50) or Color3.fromRGB(60, 120, 60)
end)

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0, 60, 0, 25)
speedLabel.Position = UDim2.new(0, 10, 0, 85)
speedLabel.Text = "Скорость:"
speedLabel.TextColor3 = Color3.fromRGB(255,255,255)
speedLabel.BackgroundTransparency = 1
speedLabel.Parent = frame

local speedBox = Instance.new("TextBox")
speedBox.Size = UDim2.new(0, 80, 0, 25)
speedBox.Position = UDim2.new(0, 80, 0, 85)
speedBox.Text = "50"
speedBox.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
speedBox.TextColor3 = Color3.fromRGB(255,255,255)
speedBox.Parent = frame
speedBox.FocusLost:Connect(function()
    local val = tonumber(speedBox.Text)
    if val and val > 0 then
        speed = val
    else
        speedBox.Text = tostring(speed)
    end
end)

print("✅ Меню полёта загружено. Наслаждайтесь!")
