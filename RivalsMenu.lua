--[[
    TERMINATOR v1.5 // RIVALS WORLD MODS
    - WORLD: Dark Sky & No Textures (FPS Boost)
    - COMBAT: Silent Aim & Auto Shoot (Stable)
    - VISUALS: Full ESP
]]

local p = game:GetService("Players")
local lp = p.LocalPlayer
local mouse = lp:GetMouse()
local rs = game:GetService("RunService")
local cg = game:GetService("CoreGui")
local uis = game:GetService("UserInputService")
local lighting = game:GetService("Lighting")

-- Чистка
for _, v in pairs(cg:GetChildren()) do if v.Name == "Terminator_V1_3" then v:Destroy() end end

local sg = Instance.new("ScreenGui", cg)
sg.Name = "Terminator_V1_3"

local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 320, 0, 480)
main.Position = UDim2.new(0.5, -160, 0.5, -240)
main.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
main.Active = true
main.Draggable = true
Instance.new("UICorner", main)
Instance.new("UIStroke", main).Color = Color3.fromRGB(0, 255, 255)

local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(1, -20, 1, -60)
scroll.Position = UDim2.new(0, 10, 0, 50)
scroll.BackgroundTransparency = 1; scroll.CanvasSize = UDim2.new(0,0,2,0); scroll.ScrollBarThickness = 0
Instance.new("UIListLayout", scroll).Padding = UDim.new(0, 5)

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
        b.TextColor3 = act and Color3.new(1, 1, 1) or Color3.new(0.8, 0.8, 0.8)
        cb(act)
    end)
end

--------------------------------------------------
-- МОДУЛИ МИРА (НОВОЕ)
--------------------------------------------------

-- 1. Тусклое небо (Night Mode)
addTgl("DARK SKY (NIGHT)", function(v)
    if v then
        lighting.Ambient = Color3.fromRGB(0, 0, 0)
        lighting.OutdoorAmbient = Color3.fromRGB(10, 10, 15)
        lighting.Brightness = 0.5
        lighting.ClockTime = 0 -- Ночь
    else
        lighting.Ambient = Color3.fromRGB(127, 127, 127)
        lighting.OutdoorAmbient = Color3.fromRGB(127, 127, 127)
        lighting.Brightness = 2
        lighting.ClockTime = 12 -- День
    end
end)

-- 2. Отключение текстур (FPS BOOST)
addTgl("NO TEXTURES (SMOOTH)", function(v)
    for _, obj in pairs(workspace:GetDescendants()) do
        if v then
            if obj:IsA("Texture") or obj:IsA("Decal") then
                obj.Transparency = 1 -- Скрываем текстуры
            elseif obj:IsA("BasePart") then
                obj.Material = Enum.Material.SmoothPlastic -- Делаем все гладким
            end
        else
            -- Возврат в норму (частичный, так как оригиналы не сохраняем для легкости)
            if obj:IsA("BasePart") then obj.Material = Enum.Material.Plastic end
            if obj:IsA("Texture") then obj.Transparency = 0 end
        end
    end
end)

--------------------------------------------------
-- БОЕВОЙ МОДУЛЬ
--------------------------------------------------

_G.Silent = false
_G.AutoShoot = false

addTgl("SILENT AIM", function(v) _G.Silent = v end)
addTgl("AUTO SHOOT", function(v) _G.AutoShoot = v end)

-- Логика Аима
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

-- Хук
local old; old = hookmetamethod(game, "__index", function(s, i)
    if s == mouse and (i == "Hit" or i == "Target") and _G.Silent and not checkcaller() then
        local t = getTarg()
        if t then return (i == "Hit" and t.Character.Head.CFrame or t.Character.Head) end
    end
    return old(s, i)
end)

-- Авто-выстрел
rs.RenderStepped:Connect(function()
    if _G.AutoShoot then
        local target = getTarg()
        if target then
            if typeof(mouse1click) == "function" then
                mouse1click()
            else
                -- Альтернатива если нет mouse1click
                keypress(0x01); task.wait(); keyrelease(0x01)
            end
        end
    end
end)

-- Скрытие на L
uis.InputBegan:Connect(function(k, m)
    if not m and k.KeyCode == Enum.KeyCode.L then main.Visible = not main.Visible end
end)

print("TERMINATOR v1.3 // WORLD MODS LOADED")
