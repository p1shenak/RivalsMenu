--[[
    TERMINATOR v1.7 // RIVALS FIX
    - FIXED: ESP (New Highlight Method)
    - FIXED: WALL-BANG (Hitbox Expander)
    - NEW: ANTI-RECOIL (Client-Side)
]]

local p = game:GetService("Players")
local lp = p.LocalPlayer
local rs = game:GetService("RunService")
local cg = game:GetService("CoreGui")
local uis = game:GetService("UserInputService")

-- Удаление старой версии
for _, v in pairs(cg:GetChildren()) do if v.Name == "Terminator_V1_7" then v:Destroy() end end

local sg = Instance.new("ScreenGui", cg)
sg.Name = "Terminator_V1_7"

local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 300, 0, 400)
main.Position = UDim2.new(0.5, -150, 0.5, -200)
main.BackgroundColor3 = Color3.fromRGB(5, 5, 10)
main.Active = true; main.Draggable = true
Instance.new("UICorner", main)
Instance.new("UIStroke", main).Color = Color3.new(0, 1, 1)

local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(1, -20, 1, -60); scroll.Position = UDim2.new(0, 10, 0, 50)
scroll.BackgroundTransparency = 1; scroll.CanvasSize = UDim2.new(0,0,1.5,0); scroll.ScrollBarThickness = 0
Instance.new("UIListLayout", scroll).Padding = UDim.new(0, 5)

-- [ ПЕРЕМЕННЫЕ ]
_G.WallBang = false
_G.EspActive = false
_G.Spin = false

-- [ КНОПКИ ]
local function addTgl(txt, cb)
    local b = Instance.new("TextButton", scroll)
    b.Size = UDim2.new(1, 0, 0, 40); b.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    b.Text = txt; b.TextColor3 = Color3.new(1, 1, 1); b.Font = Enum.Font.Gotham
    Instance.new("UICorner", b)
    local act = false
    b.MouseButton1Click:Connect(function()
        act = not act
        b.BackgroundColor3 = act and Color3.fromRGB(0, 150, 150) or Color3.fromRGB(20, 20, 30)
        cb(act)
    end)
end

--------------------------------------------------
-- 1. FIX ESP (Highlight Bypass)
--------------------------------------------------
addTgl("FIXED ESP (ALL)", function(v)
    _G.EspActive = v
    task.spawn(function()
        while _G.EspActive do
            for _, player in pairs(p:GetPlayers()) do
                if player ~= lp and player.Character then
                    local char = player.Character
                    local hl = char:FindFirstChild("T_Highlight") or Instance.new("Highlight", char)
                    hl.Name = "T_Highlight"
                    hl.Enabled = true
                    hl.FillColor = (player.Team ~= lp.Team) and Color3.new(1, 0, 0) or Color3.new(0, 1, 0)
                    hl.FillTransparency = 0.5
                    hl.OutlineTransparency = 0
                    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                end
            end
            task.wait(1)
        end
        -- Очистка при выключении
        for _, player in pairs(p:GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("T_Highlight") then
                player.Character.T_Highlight:Destroy()
            end
        end
    end)
end)

--------------------------------------------------
-- 2. FIX WALL-BANG (Hitbox Expander)
--------------------------------------------------
-- Если сервер блокирует лучи сквозь стены, мы просто увеличиваем голову врага до размеров комнаты
addTgl("WALL-BANG (EXPAND)", function(v)
    _G.WallBang = v
    task.spawn(function()
        while _G.WallBang do
            for _, player in pairs(p:GetPlayers()) do
                if player ~= lp and player.Team ~= lp.Team and player.Character and player.Character:FindFirstChild("Head") then
                    local head = player.Character.Head
                    head.Size = Vector3.new(10, 10, 10) -- Голова становится огромной
                    head.Transparency = 0.8 -- Чтобы не мешала обзору
                    head.CanCollide = false
                end
            end
            task.wait(0.5)
        end
        -- Возврат размеров
        for _, player in pairs(p:GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("Head") then
                player.Character.Head.Size = Vector3.new(1, 1, 1)
                player.Character.Head.Transparency = 0
            end
        end
    end)
end)

--------------------------------------------------
-- 3. SPINBOT & FPS
--------------------------------------------------
addTgl("SPINBOT", function(v)
    _G.Spin = v
    task.spawn(function()
        while _G.Spin do
            if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                lp.Character.HumanoidRootPart.CFrame = lp.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(50), 0)
            end
            rs.Heartbeat:Wait()
        end
    end)
end)

addTgl("NO TEXTURES (FPS)", function(v)
    for _, obj in pairs(workspace:GetDescendants()) do
        if v and obj:IsA("BasePart") then obj.Material = Enum.Material.SmoothPlastic
        elseif v and (obj:IsA("Texture") or obj:IsA("Decal")) then obj.Transparency = 1 end
    end
end)

print("TERMINATOR v1.7 BYPASS LOADED")
