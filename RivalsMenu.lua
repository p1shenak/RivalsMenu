--[[
    TERMINATOR v1.6 // RIVALS CUSTOM
    - VISUALS: ESP Boxes & Names
    - WORLD: Adjustable Sky Darkness (Cycle Mode)
    - COMBAT: Silent Aim & Auto Shoot
]]

local p = game:GetService("Players")
local lp = p.LocalPlayer
local mouse = lp:GetMouse()
local rs = game:GetService("RunService")
local cg = game:GetService("CoreGui")
local uis = game:GetService("UserInputService")
local lighting = game:GetService("Lighting")

-- Очистка
for _, v in pairs(cg:GetChildren()) do if v.Name == "Terminator_V1_4" then v:Destroy() end end

local sg = Instance.new("ScreenGui", cg)
sg.Name = "Terminator_V1_6"

local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 320, 0, 520)
main.Position = UDim2.new(0.5, -160, 0.5, -260)
main.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
main.Active = true
main.Draggable = true
Instance.new("UICorner", main)
Instance.new("UIStroke", main).Color = Color3.fromRGB(0, 255, 255)

local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(1, -20, 1, -60)
scroll.Position = UDim2.new(0, 10, 0, 50)
scroll.BackgroundTransparency = 1; scroll.CanvasSize = UDim2.new(0,0,2.2,0); scroll.ScrollBarThickness = 0
Instance.new("UIListLayout", scroll).Padding = UDim.new(0, 5)

-- [ ПЕРЕМЕННЫЕ ]
_G.Silent = false
_G.AutoShoot = false
_G.ESP = false
local SkyLevels = {12, 18, 20, 22, 0, 2} -- Режимы времени (День -> Закат -> Ночь)
local currentSky = 1

-- [ ФУНКЦИИ ]
local function addTgl(txt, cb)
    local b = Instance.new("TextButton", scroll)
    b.Size = UDim2.new(1, 0, 0, 40); b.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    b.Text = txt; b.TextColor3 = Color3.new(0.8, 0.8, 0.8); b.Font = Enum.Font.Gotham
    Instance.new("UICorner", b)
    local act = false
    b.MouseButton1Click:Connect(function()
        act = not act
        b.BackgroundColor3 = act and Color3.fromRGB(0, 120, 120) or Color3.fromRGB(25, 25, 30)
        cb(act)
    end)
    return b
end

--------------------------------------------------
-- ЛОГИКА МИРА
--------------------------------------------------

-- Настройка неба (Цикличная кнопка)
local skyBtn = addTgl("SKY DARKNESS: DAY", function()
    currentSky = currentSky + 1
    if currentSky > #SkyLevels then currentSky = 1 end
    
    local time = SkyLevels[currentSky]
    lighting.ClockTime = time
    
    -- Меняем текст кнопки в зависимости от времени
    if time == 12 then skyBtn.Text = "SKY DARKNESS: DAY"
    elseif time == 18 or time == 20 then skyBtn.Text = "SKY DARKNESS: DUSK"
    else skyBtn.Text = "SKY DARKNESS: NIGHT" end
    
    -- Авто-яркость для атмосферы
    lighting.Brightness = (time == 12) and 2 or 0.5
    lighting.ExposureCompensation = (time == 12) and 0 or -1
end)

--------------------------------------------------
-- ЛОГИКА ESP (BOX + NAME)
--------------------------------------------------

addTgl("ACTIVATE ESP", function(v)
    _G.ESP = v
end)

local function createESP(player)
    local box = Instance.new("BoxHandleAdornment")
    box.Name = "E_Box"
    box.AlwaysOnTop = true
    box.ZIndex = 10
    box.Adornee = player.Character
    box.Transparency = 0.7
    box.Color3 = (player.Team ~= lp.Team) and Color3.new(1, 0, 0) or Color3.new(0, 1, 0)
    box.Parent = player.Character:WaitForChild("HumanoidRootPart")
    
    -- Простая привязка размера к размеру персонажа
    box.Size = Vector3.new(4, 6, 1)
end

rs.RenderStepped:Connect(function()
    if _G.ESP then
        for _, player in pairs(p:GetPlayers()) do
            if player ~= lp and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                if not player.Character.HumanoidRootPart:FindFirstChild("E_Box") then
                    createESP(player)
                end
                -- Обновление цвета если команда сменилась
                local b = player.Character.HumanoidRootPart:FindFirstChild("E_Box")
                if b then b.Visible = true end
            end
        end
    else
        for _, player in pairs(p:GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local b = player.Character.HumanoidRootPart:FindFirstChild("E_Box")
                if b then b.Visible = false end
            end
        end
    end
end)

--------------------------------------------------
-- БОЕВОЙ МОДУЛЬ (STABLE)
--------------------------------------------------

addTgl("SILENT AIM", function(v) _G.Silent = v end)
addTgl("AUTO SHOOT", function(v) _G.AutoShoot = v end)

local function getTarg()
    local t = nil; local d = 300
    for _, pl in pairs(p:GetPlayers()) do
        if pl ~= lp and pl.Team ~= lp.Team and pl.Character and pl.Character:FindFirstChild("Head") then
            local pos, vis = workspace.CurrentCamera:WorldToViewportPoint(pl.Character.Head.Position)
            if vis then
                local m = (Vector2.new(pos.X, pos.Y) - uis:GetMouseLocation()).Magnitude
                if m < d then d = m; t = pl end
            end
        end
    end
    return t
end

local old; old = hookmetamethod(game, "__index", function(s, i)
    if s == mouse and (i == "Hit" or i == "Target") and _G.Silent and not checkcaller() then
        local t = getTarg()
        if t then return (i == "Hit" and t.Character.Head.CFrame or t.Character.Head) end
    end
    return old(s, i)
end)

rs.RenderStepped:Connect(function()
    if _G.AutoShoot then
        local target = getTarg()
        if target then
            if typeof(mouse1click) == "function" then mouse1click() 
            else keypress(0x01); task.wait(); keyrelease(0x01) end
        end
    end
end)

uis.InputBegan:Connect(function(k, m)
    if not m and k.KeyCode == Enum.KeyCode.L then main.Visible = not main.Visible end
end)

print("TERMINATOR v1.6 // READY")
