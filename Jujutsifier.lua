local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer

local uiCache = {}
local isInitialized = false
local currentConnection
local initAttempts = 0
local maxInitAttempts = 50

local characterData = {
    Bald = {text = "Serious mode", color = Color3.fromRGB(200, 50, 50)},
    Hunter = {text = "Rampage", color = Color3.fromRGB(50, 200, 255)},
    Cyborg = {text = "Maximum energy output", color = Color3.fromRGB(255, 146, 69)},
    Esper = {text = "Berserk", color = Color3.fromRGB(140, 255, 180)},
    Blade = {text = "Scorching blade", color = Color3.fromRGB(255, 100, 0)},
    Ninja = {text = "Can u even see me?", color = Color3.fromRGB(255, 0, 255)},
    Purple = {text = "Dragon's descent", color = Color3.fromRGB(154, 0, 255)},
    Batter = {text = "Limit breaker", color = Color3.fromRGB(160, 0, 0)},
    KJ = {text = "20 series", color = Color3.fromRGB(255, 0, 0)}
}

-- Безопасная загрузка шрифта
local preloadedFont
pcall(function()
    preloadedFont = Font.new("rbxassetid://12187375716")
end)

-- Если кастомный шрифт не загрузился, используем стандартный
if not preloadedFont then
    preloadedFont = Enum.Font.GothamBold
end

-- Улучшенная функция для создания UIGradient
local function createGradient(parent)
    if not parent or not parent.Parent then return end
    
    local existingGradient = parent:FindFirstChild("UIGradient")
    if existingGradient then 
        existingGradient:Destroy()
    end
    
    local gradient = Instance.new("UIGradient")
    gradient.Parent = parent
    gradient.Rotation = 90
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)), 
        ColorSequenceKeypoint.new(1, Color3.fromRGB(90,90,90))
    })
    return gradient
end

-- Улучшенная функция для создания UIStroke
local function createStroke(parent, thickness, transparency)
    if not parent or not parent.Parent then return end
    
    local existingStroke = parent:FindFirstChild("UIStroke")
    if existingStroke then 
        existingStroke:Destroy()
    end
    
    local stroke = Instance.new("UIStroke")
    stroke.Parent = parent
    stroke.Thickness = thickness or 2
    stroke.Transparency = transparency or 0
    if thickness and thickness > 2 then
        stroke.LineJoinMode = Enum.LineJoinMode.Miter
    end
    return stroke
end

-- Функция для безопасного удаления элементов
local function safeDestroy(element)
    if element and element.Parent then
        pcall(function()
            element:Destroy()
        end)
    end
end

-- Безопасная функция для поиска элементов UI
local function findChild(parent, name, timeout)
    if not parent then return nil end
    
    timeout = timeout or 0
    local startTime = tick()
    
    repeat
        local child = parent:FindFirstChild(name)
        if child then return child end
        
        if timeout > 0 then
            task.wait(0.1)
        end
    until timeout == 0 or (tick() - startTime) >= timeout
    
    return nil
end

local function ultraFastInitializeUI()
    local playerGui = localPlayer.PlayerGui
    if not playerGui then return false end
    
    -- Проверяем основные элементы интерфейса
    local bar = findChild(playerGui, "Bar")
    if not bar then return false end
    
    local hotbar = findChild(playerGui, "Hotbar")
    if not hotbar then return false end
    
    local magicHealth = findChild(bar, "MagicHealth")
    if not magicHealth then return false end
    
    local backpack = findChild(hotbar, "Backpack")
    if not backpack then return false end
    
    local hotbarPath = findChild(backpack, "Hotbar")
    if not hotbarPath then return false end
    
    -- Кэшируем элементы
    uiCache.playerGui = playerGui
    uiCache.magicHealth = magicHealth
    uiCache.hotbarPath = hotbarPath
    uiCache.textLabel = findChild(magicHealth, "TextLabel")
    uiCache.ult = findChild(magicHealth, "Ult")
    
    if not uiCache.textLabel or not uiCache.ult then return false end
    
    local health = findChild(magicHealth, "Health")
    if not health then return false end
    
    local healthBar = findChild(health, "Bar")
    if not healthBar then return false end
    
    uiCache.healthBar = findChild(healthBar, "Bar")
    if not uiCache.healthBar then return false end
    
    -- Безопасно применяем шрифт
    pcall(function()
        if typeof(preloadedFont) == "Font" then
            uiCache.textLabel.FontFace = preloadedFont
            uiCache.ult.FontFace = preloadedFont
        else
            uiCache.textLabel.Font = preloadedFont
            uiCache.ult.Font = preloadedFont
        end
    end)
    
    -- Удаляем ненужные элементы
    safeDestroy(findChild(uiCache.textLabel, "TextLabel"))
    safeDestroy(findChild(uiCache.ult, "TextLabel"))
    safeDestroy(findChild(uiCache.healthBar, "Empty"))
    
    -- Настройка позиций как в оригинальном скрипте
    pcall(function()
        local basePos = uiCache.textLabel.Position
        uiCache.ult.Position = basePos + UDim2.new(0, 0, 0, 5)
        uiCache.textLabel.Position = basePos + UDim2.new(0, 0, 0, -20)
        uiCache.magicHealth.Position = uiCache.magicHealth.Position + UDim2.new(0, 0, 0, 5)
        uiCache.magicHealth.Size = UDim2.new(0, 300, 0, 20)
    end)
    
    -- Настройка health bar без изменения размеров
    pcall(function()
        uiCache.healthBar.Image = ""
        local glow = findChild(health, "Glow")
        if glow then
            glow.Image = ""
        end
        uiCache.healthBar.BackgroundTransparency = 0
    end)
    
    -- Создание кастомного фрейма как в оригинале
    pcall(function()
        local existingFrame = findChild(uiCache.magicHealth, "CustomFrame")
        if existingFrame then existingFrame:Destroy() end
        
        local frame = Instance.new("Frame")
        frame.Name = "CustomFrame"
        frame.Parent = uiCache.magicHealth
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.Position = health.Position
        frame.BackgroundTransparency = 0.5
        createGradient(frame)
    end)
    
    -- Применяем стили к основным элементам
    pcall(function()
        createStroke(uiCache.textLabel, 2)
        createStroke(uiCache.ult, 2)
        createStroke(uiCache.magicHealth, 2.3, 0.35)
        createGradient(uiCache.healthBar)
    end)
    
    -- Инициализация кнопок хотбара
    uiCache.buttons = {}
    for i = 1, 13 do
        pcall(function()
            local button = findChild(hotbarPath, tostring(i))
            if button then
                local base = findChild(button, "Base")
                if base then
                    local number = findChild(base, "Number")
                    local reuse = findChild(base, "Reuse")
                    
                    if number and reuse then
                        -- Удаляем дубликаты
                        safeDestroy(findChild(number, "Number"))
                        safeDestroy(findChild(reuse, "Reuse"))
                        
                        -- Применяем стили
                        createStroke(number, 1.3)
                        createStroke(reuse, 1.3)
                        
                        -- Безопасно применяем шрифт
                        if typeof(preloadedFont) == "Font" then
                            number.FontFace = preloadedFont
                            reuse.FontFace = preloadedFont
                        else
                            number.Font = preloadedFont
                            reuse.Font = preloadedFont
                        end
                        
                        -- Ищем элемент кулдауна
                        local cooldown = findChild(button, "Cooldown") or findChild(base, "Cooldown")
                        
                        -- Если не нашли, ищем рекурсивно
                        if not cooldown then
                            for _, child in pairs(button:GetDescendants()) do
                                if child.Name == "Cooldown" and child:IsA("GuiObject") then
                                    cooldown = child
                                    break
                                end
                            end
                        end
                        
                        uiCache.buttons[i] = {
                            button = button,
                            cooldown = cooldown,
                            number = number,
                            reuse = reuse
                        }
                    end
                end
            end
        end)
    end
    
    return true
end

local function optimizedMainLoop()
    if not uiCache.textLabel or not uiCache.textLabel.Parent then 
        return 
    end
    
    -- Постоянное подавление нежелательных элементов
    pcall(function()
        local delete1 = findChild(uiCache.textLabel, "TextLabel")
        local delete2 = findChild(uiCache.ult, "TextLabel")
        local delete3 = findChild(uiCache.healthBar, "Empty")
        
        if delete1 then 
            delete1.Text = ""
            delete1.Visible = false
        end
        if delete2 then 
            delete2.Text = ""
            delete2.Visible = false
        end  
        if delete3 then 
            delete3.Enabled = false
            delete3.Visible = false
        end
    end)
    
    -- Обновление кулдаунов кнопок
    for i, buttonData in pairs(uiCache.buttons) do
        pcall(function()
            if buttonData.cooldown and buttonData.cooldown.Parent then
                buttonData.cooldown.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
                buttonData.cooldown.BackgroundTransparency = 0.2
            end
            
            -- Убеждаемся что шрифт применен
            if buttonData.number and buttonData.number.Parent then
                if typeof(preloadedFont) == "Font" then
                    buttonData.number.FontFace = preloadedFont
                else
                    buttonData.number.Font = preloadedFont
                end
            end
            if buttonData.reuse and buttonData.reuse.Parent then
                if typeof(preloadedFont) == "Font" then
                    buttonData.reuse.FontFace = preloadedFont
                else
                    buttonData.reuse.Font = preloadedFont
                end
            end
        end)
    end
    
    -- Обновление данных персонажа
    pcall(function()
        local character = localPlayer:GetAttribute("Character")
        if character then
            local charData = characterData[character]
            if charData then
                uiCache.textLabel.Text = charData.text
                uiCache.healthBar.BackgroundColor3 = charData.color
            end
        end
    end)
end

local function aggressiveInitialize()
    initAttempts = initAttempts + 1
    
    local success = pcall(function()
        return ultraFastInitializeUI()
    end)
    
    if success and ultraFastInitializeUI() then
        isInitialized = true
        initAttempts = 0
        
        if currentConnection then
            currentConnection:Disconnect()
        end
        
        currentConnection = RunService.Heartbeat:Connect(optimizedMainLoop)
        
        print("TSB Jujutsifier успешно инициализирован!")
        return true
    end
    
    if initAttempts >= maxInitAttempts then
        initAttempts = 0
        task.wait(0.5) -- Увеличена задержка
    end
    
    return false
end

local function instantStart()
    if currentConnection then
        currentConnection:Disconnect()
    end
    
    isInitialized = false
    initAttempts = 0
    
    local initConnection
    initConnection = RunService.Heartbeat:Connect(function()
        if aggressiveInitialize() then
            initConnection:Disconnect()
        end
    end)
end

-- Event connections
localPlayer.CharacterAdded:Connect(function()
    task.wait(0.5) -- Увеличена задержка для полной загрузки UI
    instantStart()
end)

localPlayer.CharacterRemoving:Connect(function()
    if currentConnection then
        currentConnection:Disconnect()
    end
    isInitialized = false
end)

-- Запуск
if localPlayer.Character then
    instantStart()
else
    local charAddedConnection
    charAddedConnection = localPlayer.CharacterAdded:Connect(function()
        charAddedConnection:Disconnect()
        task.wait(0.5)
        instantStart()
    end)
end

-- Уведомление
pcall(function()
    game.StarterGui:SetCore("SendNotification", {
        Title = "TSB Jujutsifier",
        Text = "Исправленная версия загружена!",
        Duration = 5
    })
end)

print("TSB Jujutsifier - Исправленная версия успешно загружен!")
