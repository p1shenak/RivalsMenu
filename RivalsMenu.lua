--[[
    TERMINATOR v1.2 // RIVALS STABLE
    - МЕТОД: Camera Interpolation (Не требует hookmetamethod)
    - СОВМЕСТИМОСТЬ: Xeno / Любой инжектор
    - ФУНКЦИИ: Aim, ESP, Speed, Jump
]]

local p = game:GetService("Players")
local lp = p.LocalPlayer
local rs = game:GetService("RunService")
local cg = game:GetService("CoreGui")
local uis = game:GetService("UserInputService")
local mouse = lp:GetMouse()
local cam = workspace.CurrentCamera

-- Очистка старых версий
if cg:FindFirstChild("Terminator_V1_Fixed") then cg.Terminator_V1_Fixed:Destroy() end

local sg = Instance.new("ScreenGui", cg)
sg.Name = "Terminator_V1_Fixed"

-- [ ГЛАВНОЕ МЕНЮ ]
local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 300, 0, 400)
main.Position = UDim2.new(0.5, -150, 0.5, -200)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
main.Active = true
main.Draggable = true
Instance.new("UICorner", main)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "TERMINATOR v1.0 [FIXED]"; title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold; title.BackgroundTransparency = 1

local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(1, -20, 1, -50)
scroll.Position = UDim2.new(0, 10, 0, 45)
scroll.BackgroundTransparency = 1; scroll.CanvasSize = UDim2.new(0,0,1.5,0)
Instance.new("UIListLayout", scroll).Padding = UDim.new(0, 5)

-- [ НАСТРОЙКИ ]
_G.Aimbot = false
_G.ESP = false
_G.Speed = false
local FOV_RADIUS = 150

-- [ КРУГ FOV ]
local fov_circle = Drawing.new("Circle")
fov_circle.Thickness = 1; fov_circle.Radius = FOV_RADIUS; fov_circle.Color = Color3.new(0, 1, 1); fov_circle.Visible = false

-- [ ПОИСК ЦЕЛИ ]
local function getClosestPlayer()
    local target = nil
    local shortestDistance = math.huge

    for _, player in pairs(p:GetPlayers()) do
        if player ~= lp and player.Team ~= lp.Team and player.Character and player.Character:FindFirstChild("Head") then
            local pos, onScreen = cam:WorldToViewportPoint(player.Character.Head.Position)
            if onScreen then
                local distance = (Vector2.new(pos.X, pos.Y) - uis:GetMouseLocation()).Magnitude
                if distance < shortestDistance and distance <= FOV_RADIUS then
                    shortestDistance = distance
                    target = player
                end
            end
        end
    end
    return target
end

-- [ ФУНКЦИЯ КНОПОК ]
local function createBtn(name, callback)
    local b = Instance.new("TextButton", scroll)
    b.Size = UDim2.new(1, 0, 0, 40)
    b.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    b.Text = name; b.TextColor3 = Color3.new(1,1,1); b.Font = Enum.Font.Gotham
    Instance.new("UICorner", b)
    
    local active = false
    b.MouseButton1Click:Connect(function()
        active = not active
        b.BackgroundColor3 = active and Color3.fromRGB(0, 150, 150) or Color3.fromRGB(30, 30, 35)
        callback(active)
    end)
end

--------------------------------------------------
-- ЛОГИКА
--------------------------------------------------

-- 1. AIMBOT (Через вращение камеры - самый стабильный метод)
createBtn("AIMBOT [AUTO]", function(v)
    _G.Aimbot = v
    fov_circle.Visible = v
end)

-- 2. ESP (Highlights)
createBtn("ESP [WALLHACK]", function(v)
    _G.ESP = v
    task.spawn(function()
        while _G.ESP do
            for _, player in pairs(p:GetPlayers()) do
                if player ~= lp and player.Character then
                    if not player.Character:FindFirstChild("Highlight") then
                        local hl = Instance.new("Highlight", player.Character)
                        hl.FillColor = Color3.new(1, 0, 0)
                    end
                end
            end
            task.wait(1)
        end
        for _, player in pairs(p:GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("Highlight") then
                player.Character.Highlight:Destroy()
            end
        end
    end)
end)

-- 3. SPEEDHACK
createBtn("SPEED [FAST]", function(v)
    _G.Speed = v
end)

-- [ ГЛАВНЫЙ ЦИКЛ ОБНОВЛЕНИЯ ]
rs.RenderStepped:Connect(function()
    -- Обновление круга FOV
    fov_circle.Position = uis:GetMouseLocation()

    -- Логика Аимбота
    if _G.Aimbot then
        local target = getClosestPlayer()
        if target and uis:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then -- Работает при зажатой правой кнопке мыши
            cam.CFrame = CFrame.new(cam.CFrame.Position, target.Character.Head.Position)
        end
    end

    -- Логика Скорости
    if _G.Speed and lp.Character and lp.Character:FindFirstChild("Humanoid") then
        lp.Character.Humanoid.WalkSpeed = 40
    elseif lp.Character and lp.Character:FindFirstChild("Humanoid") then
        lp.Character.Humanoid.WalkSpeed = 16
    end
end)

-- Скрытие меню на L
uis.InputBegan:Connect(function(k, m)
    if not m and k.KeyCode == Enum.KeyCode.L then main.Visible = not main.Visible end
end)

print("TERMINATOR v1.0 FIXED LOADED")
