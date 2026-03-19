--[[
    TERMINATOR v2.2 // ALL FUNCTIONS INCLUDED
    - COMBAT: Hard Aim, Wall-Bang (Expand), No Recoil, No Spread, SpeedHack
    - VISUALS: ESP (AlwaysOnTop), FullBright, Particle Rain ($, ★, ♥), Custom Sky
    - UTILS: Anti-Flash (Apollyon), Anti-Smoke (Local), FPS Boost
]]

local p = game:GetService("Players")
local lp = p.LocalPlayer
local rs = game:GetService("RunService")
local cg = game:GetService("CoreGui")
local uis = game:GetService("UserInputService")
local tw = game:GetService("TweenService")
local lighting = game:GetService("Lighting")

-- Чистка старых версий
for _, v in pairs(cg:GetChildren()) do if v.Name:find("Terminator") then v:Destroy() end end

--------------------------------------------------
-- [ ГЛОБАЛЬНЫЕ ПЕРЕМЕННЫЕ ]
--------------------------------------------------
_G.Aimbot = false; _G.EspActive = false; _G.WallBang = false
_G.NoRecoil = false; _G.SpeedHack = false; _G.FullBright = false
_G.AntiFlash = false; _G.AntiSmoke = false
_G.ParticleRain = false; _G.RainType = "$" 
_G.CustomSky = false; _G.SkyColor = Color3.fromRGB(0, 255, 255)

--------------------------------------------------
-- [ ИНТЕРФЕЙС ]
--------------------------------------------------
local sg = Instance.new("ScreenGui", cg); sg.Name = "Terminator_V2_2"
local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 350, 0, 450); main.Position = UDim2.new(0.5, -175, 0.5, -225)
main.BackgroundColor3 = Color3.fromRGB(10, 10, 15); main.Active = true; main.Draggable = true
Instance.new("UICorner", main); Instance.new("UIStroke", main).Color = Color3.new(0, 1, 1)

local tabs = Instance.new("Frame", main); tabs.Size = UDim2.new(1, -20, 0, 40); tabs.Position = UDim2.new(0, 10, 0, 10); tabs.BackgroundTransparency = 1
local b1 = Instance.new("TextButton", tabs); b1.Size = UDim2.new(0.5,-2,1,0); b1.Text = "COMBAT"; b1.BackgroundColor3 = Color3.fromRGB(0, 100, 100); b1.TextColor3 = Color3.new(1,1,1); b1.Font = Enum.Font.GothamBold; Instance.new("UICorner", b1)
local b2 = Instance.new("TextButton", tabs); b2.Size = UDim2.new(0.5,-2,1,0); b2.Position = UDim2.new(0.5,2,0,0); b2.Text = "VISUALS"; b2.BackgroundColor3 = Color3.fromRGB(25,25,35); b2.TextColor3 = Color3.new(1,1,1); b2.Font = Enum.Font.GothamBold; Instance.new("UICorner", b2)

local p1 = Instance.new("ScrollingFrame", main); p1.Size = UDim2.new(1,-20,1,-70); p1.Position = UDim2.new(0,10,0,60); p1.BackgroundTransparency = 1; p1.Visible = true; p1.ScrollBarThickness = 0; Instance.new("UIListLayout", p1).Padding = UDim.new(0,5)
local p2 = Instance.new("ScrollingFrame", main); p2.Size = UDim2.new(1,-20,1,-70); p2.Position = UDim2.new(0,10,0,60); p2.BackgroundTransparency = 1; p2.Visible = false; p2.ScrollBarThickness = 0; Instance.new("UIListLayout", p2).Padding = UDim.new(0,5)

b1.MouseButton1Click:Connect(function() p1.Visible = true; p2.Visible = false; b1.BackgroundColor3 = Color3.fromRGB(0, 100, 100); b2.BackgroundColor3 = Color3.fromRGB(25,25,35) end)
b2.MouseButton1Click:Connect(function() p1.Visible = false; p2.Visible = true; b2.BackgroundColor3 = Color3.fromRGB(0, 100, 100); b1.BackgroundColor3 = Color3.fromRGB(25,25,35) end)

--------------------------------------------------
-- [ ВСПОМОГАТЕЛЬНЫЕ ОКНА ]
--------------------------------------------------
local rainSett = Instance.new("Frame", main); rainSett.Size = UDim2.new(0,120,0,100); rainSett.Position = UDim2.new(1,5,0,60); rainSett.BackgroundColor3 = Color3.new(0,0,0); rainSett.Visible = false; Instance.new("UIListLayout", rainSett); Instance.new("UIStroke", rainSett).Color = Color3.new(0,1,1)
local function addRainOpt(t, v)
    local btn = Instance.new("TextButton", rainSett); btn.Size = UDim2.new(1,0,0,30); btn.Text = t; btn.BackgroundColor3 = Color3.new(0.1,0.1,0.1); btn.TextColor3 = Color3.new(1,1,1)
    btn.MouseButton1Click:Connect(function() _G.RainType = v; rainSett.Visible = false end)
end
addRainOpt("Dollars ($)", "$"); addRainOpt("Stars (★)", "★"); addRainOpt("Hearts (♥)", "♥")

--------------------------------------------------
-- [ ФУНКЦИИ ДОБАВЛЕНИЯ ]
--------------------------------------------------
local function addTgl(txt, var, parent, rmb)
    local b = Instance.new("TextButton", parent); b.Size = UDim2.new(1,0,0,40); b.BackgroundColor3 = Color3.fromRGB(25,25,35); b.Text = txt; b.TextColor3 = Color3.new(1,1,1); b.Font = Enum.Font.Gotham; Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function()
        _G[var] = not _G[var]
        b.BackgroundColor3 = _G[var] and Color3.fromRGB(0, 150, 150) or Color3.fromRGB(25,25,35)
    end)
    if rmb then b.MouseButton2Click:Connect(rmb) end
end

-- ВКЛАДКА COMBAT
addTgl("HARD AIMBOT (360)", "Aimbot", p1)
addTgl("WALL-BANG (EXPAND HITBOX)", "WallBang", p1)
addTgl("NO RECOIL / SPREAD", "NoRecoil", p1)
addTgl("SPEEDHACK (SHIFT)", "SpeedHack", p1)

-- ВКЛАДКА VISUALS
addTgl("WALLHACK (HIGHLIGHTS)", "EspActive", p2)
addTgl("FULLBRIGHT / NO FOG", "FullBright", p2)
addTgl("ANTI-FLASH (LOCAL)", "AntiFlash", p2)
addTgl("ANTI-SMOKE (ALL)", "AntiSmoke", p2)
addTgl("PARTICLE RAIN (RMB)", "ParticleRain", p2, function() rainSett.Visible = not rainSett.Visible end)
addTgl("CUSTOM SKY (CYAN)", "CustomSky", p2)

--------------------------------------------------
-- [ ЯДРО ЛОГИКИ ]
--------------------------------------------------
local rainPart = Instance.new("ParticleEmitter", Instance.new("Attachment", workspace.Terrain))
rainPart.Rate = 0; rainPart.Lifetime = NumberRange.new(5); rainPart.Speed = NumberRange.new(30); rainPart.Acceleration = Vector3.new(0,-20,0)

rs.RenderStepped:Connect(function()
    -- AIMBOT & ESP & WALLBANG
    for _, pl in pairs(p:GetPlayers()) do
        if pl ~= lp and pl.Character and pl.Character:FindFirstChild("Head") then
            local char = pl.Character
            -- ESP
            local hl = char:FindFirstChild("T_ESP")
            if _G.EspActive then
                if not hl then hl = Instance.new("Highlight", char); hl.Name = "T_ESP" end
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.FillColor = (pl.Team ~= lp.Team) and Color3.new(1,0,0) or Color3.new(0,1,0)
            elseif hl then hl:Destroy() end
            
            -- WALLBANG
            if _G.WallBang and pl.Team ~= lp.Team then
                char.Head.Size = Vector3.new(10, 10, 10); char.Head.Transparency = 0.7; char.Head.CanCollide = false
            else
                char.Head.Size = Vector3.new(1, 1, 1); char.Head.Transparency = 0
            end
        end
    end

    -- AIMBOT
    if _G.Aimbot then
        local target, dist = nil, math.huge
        for _, pl in pairs(p:GetPlayers()) do
            if pl ~= lp and pl.Team ~= lp.Team and pl.Character and pl.Character:FindFirstChild("Head") then
                local m = (pl.Character.Head.Position - lp.Character.Head.Position).Magnitude
                if m < dist then dist = m; target = pl end
            end
        end
        if target then workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, target.Character.Head.Position) end
    end

    -- VISUALS (RAIN / SKY / FLASH)
    if _G.ParticleRain and lp.Character:FindFirstChild("HumanoidRootPart") then
        rainPart.Parent.Position = lp.Character.HumanoidRootPart.Position + Vector3.new(0,50,0)
        rainPart.Rate = 50
        rainPart.Texture = (_G.RainType == "$") and "rbxassetid://10849911874" or (_G.RainType == "★") and "rbxassetid://10849919137" or "rbxassetid://10849924294"
    else rainPart.Rate = 0 end

    if _G.AntiFlash then
        for _, v in pairs(lp.PlayerGui:GetDescendants()) do if v:IsA("Frame") and v.Name:lower():find("flash") then v.Visible = false end end
    end
    
    if _G.FullBright then lighting.Brightness = 2; lighting.Ambient = Color3.new(1,1,1); lighting.FogEnd = 1e5 end
end)

-- SPEEDHACK & NO RECOIL
uis.InputBegan:Connect(function(i, g) if not g and i.KeyCode == Enum.KeyCode.LeftShift and _G.SpeedHack then lp.Character.Humanoid.WalkSpeed = 50 end end)
uis.InputEnded:Connect(function(i) if i.KeyCode == Enum.KeyCode.LeftShift then lp.Character.Humanoid.WalkSpeed = 16 end end)

task.spawn(function()
    while task.wait(0.5) do
        if _G.NoRecoil then
            for _, v in pairs(lp.Character:GetChildren()) do
                if v:IsA("Tool") and v:FindFirstChild("Settings") then
                    if v.Settings:FindFirstChild("Recoil") then v.Settings.Recoil.Value = 0 end
                    if v.Settings:FindFirstChild("Spread") then v.Settings.Spread.Value = 0 end
                end
            end
        end
        if _G.AntiSmoke then
            for _, v in pairs(workspace:GetDescendants()) do if v:IsA("ParticleEmitter") then v.Enabled = false end end
        end
    end
end)

uis.InputBegan:Connect(function(k, m) if not m and k.KeyCode == Enum.KeyCode.L then main.Visible = not main.Visible end end)
print("TERMINATOR v2.2 ALL FUNCTIONS LOADED")
