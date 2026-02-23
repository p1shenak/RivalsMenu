--[[
    TERMINATOR v1.1 // RIVALS STABLE
    - Метод: Mouse Index Hook (работает даже если Raycast защищен)
    - Оптимизация под Xeno
    - Исправлен ESP
]]

local p = game:GetService("Players")
local lp = p.LocalPlayer
local mouse = lp:GetMouse()
local rs = game:GetService("RunService")
local cg = game:GetService("CoreGui")
local uis = game:GetService("UserInputService")

-- Очистка
if cg:FindFirstChild("Terminator_V1") then cg.Terminator_V1:Destroy() end

local sg = Instance.new("ScreenGui", cg)
sg.Name = "Terminator_V1"

-- [ GUI ]
local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 350, 0, 400)
main.Position = UDim2.new(0.5, -175, 0.5, -200)
main.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
main.Active = true
main.Draggable = true
Instance.new("UICorner", main)
Instance.new("UIStroke", main).Color = Color3.fromRGB(0, 255, 255)

local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(1, -20, 1, -60)
scroll.Position = UDim2.new(0, 10, 0, 50)
scroll.BackgroundTransparency = 1; scroll.CanvasSize = UDim2.new(0,0,1.2,0)
Instance.new("UIListLayout", scroll).Padding = UDim.new(0, 5)

-- [ FOV ]
local fov = Drawing.new("Circle")
fov.Thickness = 1; fov.Radius = 150; fov.Color = Color3.new(0, 1, 1); fov.Visible = false

-- [ ФУНКЦИЯ ]
local function getClosest()
    local target = nil
    local dist = fov.Radius
    for _, pl in pairs(p:GetPlayers()) do
        if pl ~= lp and pl.Character and pl.Character:FindFirstChild("Head") and pl.Team ~= lp.Team then
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
    b.Size = UDim2.new(1, 0, 0, 40); b.Text = txt; b.BackgroundColor3 = Color3.fromRGB(20,20,25)
    b.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", b)
    local act = false
    b.MouseButton1Click:Connect(function()
        act = not act
        b.BackgroundColor3 = act and Color3.fromRGB(0, 100, 100) or Color3.fromRGB(20,20,25)
        cb(act)
    end)
end

-- 1. Silent Aim (Index Hook) - САМАЯ ВАЖНАЯ ЧАСТЬ
addBtn("SILENT AIM", function(v)
    _G.Silent = v
    fov.Visible = v
end)

-- 2. ESP
addBtn("ESP BOX", function(v)
    _G.Esp = v
    task.spawn(function()
        while _G.Esp do
            for _, pl in pairs(p:GetPlayers()) do
                if pl ~= lp and pl.Character and not pl.Character:FindFirstChild("T_ESP") then
                    local h = Instance.new("Highlight", pl.Character)
                    h.Name = "T_ESP"; h.FillTransparency = 0.5
                end
            end
            task.wait(1)
        end
    end)
end)

-- [ ХУК МЫШКИ ]
local oldIndex
oldIndex = hookmetamethod(game, "__index", function(self, idx)
    if self == mouse and (idx == "Hit" or idx == "Target") and _G.Silent and not checkcaller() then
        local t = getClosest()
        if t then
            return (idx == "Hit" and t.Character.Head.CFrame or t.Character.Head)
        end
    end
    return oldIndex(self, idx)
end)

rs.RenderStepped:Connect(function()
    fov.Position = uis:GetMouseLocation()
end)

uis.InputBegan:Connect(function(k, m)
    if not m and k.KeyCode == Enum.KeyCode.L then main.Visible = not main.Visible end
end)

print("TERMINATOR v1.1 LOADED")
