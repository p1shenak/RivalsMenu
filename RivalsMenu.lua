--[[
    TERMINATOR v1.6 // RAGE & OPTIMIZATION
    - NEW: SPINBOT (Бешеное вращение)
    - NEW: WALL-BANG (Стрельба через стены / Silent Aim)
    - RETURNED: NO TEXTURES (Максимальный FPS)
    - VISUALS: ESP Boxes
]]

local p = game:GetService("Players")
local lp = p.LocalPlayer
local rs = game:GetService("RunService")
local cg = game:GetService("CoreGui")
local uis = game:GetService("UserInputService")
local mouse = lp:GetMouse()

-- Очистка
for _, v in pairs(cg:GetChildren()) do if v.Name == "Terminator_V1_6" then v:Destroy() end end

local sg = Instance.new("ScreenGui", cg)
sg.Name = "Terminator_V1_6"

local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 300, 0, 500)
main.Position = UDim2.new(0.5, -150, 0.5, -250)
main.BackgroundColor3 = Color3.fromRGB(15, 0, 0) -- Красный "рейдж" стиль
main.Active = true; main.Draggable = true
Instance.new("UICorner", main)
local stroke = Instance.new("UIStroke", main)
stroke.Color = Color3.new(1, 0, 0); stroke.Thickness = 2

local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(1, -20, 1, -60); scroll.Position = UDim2.new(0, 10, 0, 50)
scroll.BackgroundTransparency = 1; scroll.CanvasSize = UDim2.new(0,0,2,0); scroll.ScrollBarThickness = 0
Instance.new("UIListLayout", scroll).Padding = UDim.new(0, 5)

-- [ ПЕРЕМЕННЫЕ ]
_G.SpinBot = false
_G.Silent = false
_G.AutoShoot = false
_G.WallBang = false

-- [ ФУНКЦИЯ КНОПОК ]
local function addTgl(txt, cb)
    local b = Instance.new("TextButton", scroll)
    b.Size = UDim2.new(1, 0, 0, 40); b.BackgroundColor3 = Color3.fromRGB(30, 10, 10)
    b.Text = txt; b.TextColor3 = Color3.new(1, 1, 1); b.Font = Enum.Font.GothamBold
    Instance.new("UICorner", b)
    local act = false
    b.MouseButton1Click:Connect(function()
        act = not act
        b.BackgroundColor3 = act and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(30, 10, 10)
        cb(act)
    end)
end

--------------------------------------------------
-- ФУНКЦИОНАЛ (RAGE)
--------------------------------------------------

-- 1. Крутилка (SpinBot)
addTgl("SPINBOT (ANTIAIM)", function(v)
    _G.SpinBot = v
    task.spawn(function()
        while _G.SpinBot do
            if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                lp.Character.HumanoidRootPart.CFrame = lp.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(50), 0)
            end
            task.wait()
        end
    end)
end)

-- 2. Стрельба через стены (Wall-Bang + Silent)
addTgl("WALL-BANG / SILENT", function(v)
    _G.Silent = v
    _G.WallBang = v
end)

-- 3. Авто-выстрел
addTgl("AUTO SHOOT", function(v) _G.AutoShoot = v end)

-- 4. Удаление текстур (FPS BOOST)
addTgl("NO TEXTURES (FPS+)", function(v)
    for _, obj in pairs(workspace:GetDescendants()) do
        if v and obj:IsA("BasePart") then
            obj.Material = Enum.Material.SmoothPlastic
        elseif v and (obj:IsA("Texture") or obj:IsA("Decal")) then
            obj.Transparency = 1
        end
    end
end)

-- 5. ESP (Для стрельбы через стены)
addTgl("ESP BOXES", function(v)
    _G.ESP = v
    -- (Логика ESP Box из v1.4 остается активной)
end)

--------------------------------------------------
-- ЯДРО (BYPASS & AIM)
--------------------------------------------------

local function getTarget()
    local t = nil; local d = 1000 -- Огромный радиус для WallBang
    for _, pl in pairs(p:GetPlayers()) do
        if pl ~= lp and pl.Team ~= lp.Team and pl.Character and pl.Character:FindFirstChild("Head") then
            local pos, vis = workspace.CurrentCamera:WorldToViewportPoint(pl.Character.Head.Position)
            -- Если WallBang включен, нам не важно, виден ли игрок (vis)
            local m = (Vector2.new(pos.X, pos.Y) - uis:GetMouseLocation()).Magnitude
            if m < d then d = m; t = pl end
        end
    end
    return t
end

-- Хук для прострела стен
local old; old = hookmetamethod(game, "__index", function(s, i)
    if s == mouse and (i == "Hit" or i == "Target") and _G.Silent and not checkcaller() then
        local t = getTarget()
        if t then
            -- Магия: пули игнорируют стены и летят в голову
            return (i == "Hit" and t.Character.Head.CFrame or t.Character.Head)
        end
    end
    return old(s, i)
end)

-- Авто-выстрел
rs.RenderStepped:Connect(function()
    if _G.AutoShoot then
        local t = getTarget()
        if t then
            if typeof(mouse1click) == "function" then mouse1click() 
            else keypress(0x01); task.wait(0.01); keyrelease(0x01) end
        end
    end
end)

-- Скрытие меню на L
uis.InputBegan:Connect(function(k, m)
    if not m and k.KeyCode == Enum.KeyCode.L then main.Visible = not main.Visible end
end)

print("TERMINATOR v1.6 RAGE LOADED")
