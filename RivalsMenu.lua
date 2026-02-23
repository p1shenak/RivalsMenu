--[[
    TERMINATOR v1.3 // RIVALS PROJECT
    - SILENT AIM: Пули сами летят в голову (Raycast Bypass)
    - AUTO SHOOT: Автоматическая стрельба при наведении
    - FOV LOCK: Радиус захвата целей
    - NO RECOIL: Полное отсутствие отдачи
]]

local p = game:GetService("Players")
local lp = p.LocalPlayer
local rs = game:GetService("RunService")
local cg = game:GetService("CoreGui")
local uis = game:GetService("UserInputService")
local mouse = lp:GetMouse()
local cam = workspace.CurrentCamera

-- Очистка старого кода
if cg:FindFirstChild("Terminator_V1.2") then cg.Terminator_V1.2:Destroy() end

local sg = Instance.new("ScreenGui", cg)
sg.Name = "Terminator_V1.2"

-- [ ИНТЕРФЕЙС ]
local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 320, 0, 400)
main.Position = UDim2.new(0.5, -160, 0.5, -200)
main.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
main.Active = true
main.Draggable = true
Instance.new("UICorner", main)
Instance.new("UIStroke", main).Color = Color3.fromRGB(0, 255, 255)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 45)
title.Text = "TERMINATOR v1.2 // RIVALS"; title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold; title.BackgroundTransparency = 1

local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(1, -20, 1, -60)
scroll.Position = UDim2.new(0, 10, 0, 50)
scroll.BackgroundTransparency = 1; scroll.CanvasSize = UDim2.new(0,0,1.3,0)
Instance.new("UIListLayout", scroll).Padding = UDim.new(0, 5)

-- [ ПЕРЕМЕННЫЕ ]
_G.SilentAim = false
_G.AutoShoot = false
_G.NoRecoil = false
local FOV_RADIUS = 150

-- [ КРУГ FOV ]
local fov_circle = Drawing.new("Circle")
fov_circle.Thickness = 1; fov_circle.Radius = FOV_RADIUS; fov_circle.Color = Color3.new(0, 255, 255); fov_circle.Visible = false

-- [ ПОИСК ЦЕЛИ ]
local function getTarget()
    local target = nil
    local dist = FOV_RADIUS
    for _, player in pairs(p:GetPlayers()) do
        if player ~= lp and player.Team ~= lp.Team and player.Character and player.Character:FindFirstChild("Head") then
            local pos, onScreen = cam:WorldToViewportPoint(player.Character.Head.Position)
            if onScreen then
                local mag = (Vector2.new(pos.X, pos.Y) - uis:GetMouseLocation()).Magnitude
                if mag < dist then
                    dist = mag
                    target = player
                end
            end
        end
    end
    return target
end

-- [ КНОПКИ ]
local function addBtn(name, callback)
    local b = Instance.new("TextButton", scroll)
    b.Size = UDim2.new(1, 0, 0, 40); b.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    b.Text = name; b.TextColor3 = Color3.new(1,1,1); b.Font = Enum.Font.Gotham
    Instance.new("UICorner", b)
    local act = false
    b.MouseButton1Click:Connect(function()
        act = not act
        b.BackgroundColor3 = act and Color3.fromRGB(0, 150, 150) or Color3.fromRGB(25, 25, 30)
        callback(act)
    end)
end

--------------------------------------------------
-- ФУНКЦИОНАЛ
--------------------------------------------------

-- 1. SILENT AIM (Пули летят в голову)
addBtn("SILENT AIM (HEAD)", function(v)
    _G.SilentAim = v
    fov_circle.Visible = v
end)

-- 2. AUTO SHOOT (Сам стреляет)
addBtn("AUTO SHOOT (TRIGGER)", function(v)
    _G.AutoShoot = v
end)

-- 3. NO RECOIL
addBtn("NO RECOIL", function(v)
    _G.NoRecoil = v
end)

-- [ ГЛАВНЫЙ BYPASS ]
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    
    if _G.SilentAim and method == "Raycast" and not checkcaller() then
        local t = getTarget()
        if t then
            -- Подменяем направление луча на голову цели
            args[2] = (t.Character.Head.Position - args[1]).Unit * 1000
            return oldNamecall(self, unpack(args))
        end
    end
    return oldNamecall(self, ...)
end)

-- [ АВТО-ВЫСТРЕЛ И ОБНОВЛЕНИЕ ]
rs.RenderStepped:Connect(function()
    fov_circle.Position = uis:GetMouseLocation()
    
    local target = getTarget()
    
    -- Логика AutoShoot
    if _G.AutoShoot and target then
        -- Виртуальный клик (Xeno поддерживает mouse1click)
        if typeof(mouse1click) == "function" then
            mouse1click()
        end
    end
    
    -- Убираем отдачу (Rivals NoRecoil)
    if _G.NoRecoil then
        pcall(function()
            lp.PlayerGui.MainGui.Internal.Recoil.Value = 0
        end)
    end
end)

-- Скрытие на L
uis.InputBegan:Connect(function(k, m)
    if not m and k.KeyCode == Enum.KeyCode.L then main.Visible = not main.Visible end
end)

print("TERMINATOR v1.2 ULTIMATE LOADED")
