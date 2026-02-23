--[[
    TERMINATOR v1.4 // RIVALS PROJECT (FIXED)
    - Убраны Drawing API (могут вызывать вылет)
    - Silent Aim заменен на Mouse Hook
    - Оптимизация под Xeno
]]

local p = game:GetService("Players")
local lp = p.LocalPlayer
local mouse = lp:GetMouse()
local rs = game:GetService("RunService")
local cg = game:GetService("CoreGui")
local uis = game:GetService("UserInputService")

-- Удаляем старое если есть
for _, v in pairs(cg:GetChildren()) do
    if v.Name == "Terminator_V1_2" then v:Destroy() end
end

local sg = Instance.new("ScreenGui", cg)
sg.Name = "Terminator_V1_2"

-- [ ГЛАВНОЕ ОКНО ]
local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 280, 0, 350)
main.Position = UDim2.new(0.5, -140, 0.5, -175)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
main.Active = true
main.Draggable = true
Instance.new("UICorner", main)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "TERMINATOR v1.2 FIX"; title.TextColor3 = Color3.new(0, 1, 1)
title.Font = Enum.Font.GothamBold; title.BackgroundTransparency = 1

local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(1, -20, 1, -50)
scroll.Position = UDim2.new(0, 10, 0, 45)
scroll.BackgroundTransparency = 1; scroll.CanvasSize = UDim2.new(0,0,1.5,0)
Instance.new("UIListLayout", scroll).Padding = UDim.new(0, 5)

-- [ НАСТРОЙКИ ]
_G.Silent = false
_G.Trigger = false
_G.ESP = false

-- [ ПОИСК ЦЕЛИ ]
local function getTarget()
    local target = nil
    local dist = 300 -- Радиус захвата (вместо круга)
    for _, pl in pairs(p:GetPlayers()) do
        if pl ~= lp and pl.Team ~= lp.Team and pl.Character and pl.Character:FindFirstChild("Head") then
            local pos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(pl.Character.Head.Position)
            if onScreen then
                local mag = (Vector2.new(pos.X, pos.Y) - uis:GetMouseLocation()).Magnitude
                if mag < dist then
                    dist = mag
                    target = pl
                end
            end
        end
    end
    return target
end

-- [ КНОПКИ ]
local function addBtn(txt, cb)
    local b = Instance.new("TextButton", scroll)
    b.Size = UDim2.new(1, 0, 0, 40); b.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    b.Text = txt; b.TextColor3 = Color3.new(1,1,1); b.Font = Enum.Font.Gotham
    Instance.new("UICorner", b)
    local act = false
    b.MouseButton1Click:Connect(function()
        act = not act
        b.BackgroundColor3 = act and Color3.fromRGB(0, 100, 100) or Color3.fromRGB(30, 30, 35)
        cb(act)
    end)
end

--------------------------------------------------
-- ФУНКЦИИ
--------------------------------------------------

addBtn("SILENT AIM", function(v) _G.Silent = v end)
addBtn("AUTO SHOOT", function(v) _G.Trigger = v end)
addBtn("ESP BOX", function(v) 
    _G.ESP = v 
    task.spawn(function()
        while _G.ESP do
            for _, pl in pairs(p:GetPlayers()) do
                if pl ~= lp and pl.Character and not pl.Character:FindFirstChild("Highlight") then
                    Instance.new("Highlight", pl.Character).FillColor = Color3.new(1,0,0)
                end
            end
            task.wait(2)
        end
    end)
end)

-- [ ХУК ДЛЯ СТРЕЛЬБЫ ]
local oldIndex
oldIndex = hookmetamethod(game, "__index", function(self, idx)
    if self == mouse and (idx == "Hit" or idx == "Target") and _G.Silent and not checkcaller() then
        local t = getTarget()
        if t then
            return (idx == "Hit" and t.Character.Head.CFrame or t.Character.Head)
        end
    end
    return oldIndex(self, idx)
end)

-- [ ЦИКЛ АВТО-ВЫСТРЕЛА ]
rs.RenderStepped:Connect(function()
    if _G.Trigger then
        local t = getTarget()
        if t then
            -- Выстрел
            keypress(0x01) -- Левая кнопка мыши (Virtual Key Code)
            task.wait(0.05)
            keyrelease(0x01)
        end
    end
end)

-- Скрытие на L
uis.InputBegan:Connect(function(k, m)
    if not m and k.KeyCode == Enum.KeyCode.L then main.Visible = not main.Visible end
end)

print("TERMINATOR v1.2 FIX - LOADED")
