--[[
    TERMINATOR v1.0 // RIVALS PROJECT
    - Focused: Combat & Visuals
    - Bypass: Silent Aim Raycast Hook
    - Optimized for Xeno
]]

pcall(function()
    local p = game:GetService("Players")
    local lp = p.LocalPlayer
    local mouse = lp:GetMouse()
    local rs = game:GetService("RunService")
    local cg = game:GetService("CoreGui")
    local uis = game:GetService("UserInputService")
    local cam = workspace.CurrentCamera

    -- ОЧИСТКА
    if cg:FindFirstChild("Terminator_Rivals_V1") then cg.Terminator_Rivals_V1:Destroy() end

    local sg = Instance.new("ScreenGui", cg)
    sg.Name = "Terminator_Rivals_V1"

    -- ГЛАВНОЕ ОКНО
    local main = Instance.new("Frame", sg)
    main.Size = UDim2.new(0, 380, 0, 450)
    main.Position = UDim2.new(0.5, -190, 0.5, -225)
    main.BackgroundColor3 = Color3.fromRGB(7, 7, 10)
    main.Active = true
    main.Draggable = true
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)
    
    local stroke = Instance.new("UIStroke", main)
    stroke.Color = Color3.fromRGB(0, 255, 255)
    stroke.Thickness = 1.5

    local title = Instance.new("TextLabel", main)
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Text = "TERMINATOR v1.0 // RIVALS"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamBold; title.TextSize = 18; title.BackgroundTransparency = 1

    local scroll = Instance.new("ScrollingFrame", main)
    scroll.Size = UDim2.new(1, -20, 1, -70)
    scroll.Position = UDim2.new(0, 10, 0, 60)
    scroll.BackgroundTransparency = 1; scroll.ScrollBarThickness = 0
    Instance.new("UIListLayout", scroll).Padding = UDim.new(0, 5)

    -- [ НАСТРОЙКИ FOV ]
    local fov_circle = Drawing.new("Circle")
    fov_circle.Thickness = 1; fov_circle.NumSides = 60; fov_circle.Radius = 120
    fov_circle.Filled = false; fov_circle.Color = Color3.new(0, 1, 1); fov_circle.Visible = false

    -- [ ФУНКЦИЯ КНОПКИ ]
    local function addTgl(txt, cb)
        local b = Instance.new("TextButton", scroll)
        b.Size = UDim2.new(1, 0, 0, 45)
        b.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
        b.Text = txt; b.TextColor3 = Color3.new(0.7, 0.7, 0.7); b.Font = Enum.Font.Gotham
        Instance.new("UICorner", b)
        
        local active = false
        b.MouseButton1Click:Connect(function()
            active = not active
            b.BackgroundColor3 = active and Color3.fromRGB(0, 120, 120) or Color3.fromRGB(15, 15, 20)
            b.TextColor3 = active and Color3.new(1, 1, 1) or Color3.new(0.7, 0.7, 0.7)
            cb(active)
        end)
    end

    -- [ ЛОГИКА ПОИСКА ЦЕЛИ ]
    local function getTarget()
        local target = nil
        local dist = fov_circle.Radius
        for _, pl in pairs(p:GetPlayers()) do
            if pl ~= lp and pl.Character and pl.Character:FindFirstChild("Head") and pl.Team ~= lp.Team then
                local pos, onScreen = cam:WorldToViewportPoint(pl.Character.Head.Position)
                if onScreen then
                    local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(mouse.X, mouse.Y)).Magnitude
                    if mag < dist then
                        dist = mag
                        target = pl
                    end
                end
            end
        end
        return target
    end

    --------------------------------------------------
    -- ВКЛАДКИ
    --------------------------------------------------

    -- 1. SILENT AIM (BYPASS)
    addTgl("ACTIVATE SILENT AIM", function(v) 
        _G.SilentAim = v 
        fov_circle.Visible = v
    end)

    -- 2. ESP WALLHACK
    addTgl("PLAYER HIGHLIGHT (ESP)", function(v)
        _G.Esp = v
        task.spawn(function()
            while _G.Esp do
                for _, pl in pairs(p:GetPlayers()) do
                    if pl ~= lp and pl.Character then
                        local h = pl.Character:FindFirstChild("T1_Highlight") or Instance.new("Highlight", pl.Character)
                        h.Name = "T1_Highlight"
                        h.FillColor = (pl.Team ~= lp.Team) and Color3.new(1, 0, 0) or Color3.new(0, 1, 0)
                        h.Enabled = true
                    end
                end
                task.wait(1)
            end
            for _, pl in pairs(p:GetPlayers()) do
                if pl.Character and pl.Character:FindFirstChild("T1_Highlight") then pl.Character.T1_Highlight:Destroy() end
            end
        end)
    end)

    -- 3. NO RECOIL (STABLE)
    addTgl("NO RECOIL & SPREAD", function(v)
        _G.NoRecoil = v
        -- В Rivals отдача часто сбрасывается через камеру
        rs.RenderStepped:Connect(function()
            if _G.NoRecoil and lp.Character then
                pcall(function()
                   -- Прямая очистка значений в GUI/Скриптах Rivals
                   if lp.PlayerGui:FindFirstChild("MainGui") then
                       lp.PlayerGui.MainGui.Internal.Recoil.Value = 0
                   end
                end)
            end
        end)
    end)

    -- 4. FOV SIZE +
    addTgl("BIGGER FOV (150)", function(v)
        fov_circle.Radius = v and 200 or 120
    end)

    --------------------------------------------------
    -- ХУКИ И ОБНОВЛЕНИЯ
    --------------------------------------------------

    -- Главный обход для Silent Aim
    local old; old = hookmetamethod(game, "__namecall", function(self, ...)
        local args = {...}
        local method = getnamecallmethod()
        if _G.SilentAim and method == "Raycast" and not checkcaller() then
            local target = getTarget()
            if target then
                args[2] = (target.Character.Head.Position - args[1]).Unit * 1000
                return old(self, unpack(args))
            end
        end
        return old(self, ...)
    end)

    -- Обновление круга FOV за мышкой
    rs.RenderStepped:Connect(function()
        fov_circle.Position = Vector2.new(mouse.X, mouse.Y + 36)
    end)

    -- Скрытие меню
    uis.InputBegan:Connect(function(k, m)
        if not m and k.KeyCode == Enum.KeyCode.L then main.Visible = not main.Visible end
    end)

    print("TERMINATOR v1.0 RIVALS - LOADED")
end)
