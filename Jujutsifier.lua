local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer

local uiCache = {}
local isInitialized = false
local currentConnection
local initAttempts = 0
local maxInitAttempts = 100

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

local preloadedFont = Font.new("rbxassetid://12187375716")

-- Улучшенная функция для создания UIGradient
local function createGradient(parent)
    if parent:FindFirstChild("UIGradient") then 
        parent:FindFirstChild("UIGradient"):Destroy()
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
    if parent:FindFirstChild("UIStroke") then 
        parent:FindFirstChild("UIStroke"):Destroy()
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
        element:Destroy()
    end
end

local function ultraFastInitializeUI()
    local playerGui = localPlayer.PlayerGui
    
    local bar = playerGui:FindFirstChild("Bar")
    if not bar then return false end
    
    local hotbar = playerGui:FindFirstChild("Hotbar")
    if not hotbar then return false end
    
    local magicHealth = bar:FindFirstChild("MagicHealth")
    if not magicHealth then return false end
    
    local backpack = hotbar:FindFirstChild("Backpack")
    if not backpack then return false end
    
    local hotbarPath = backpack:FindFirstChild("Hotbar")
    if not hotbarPath then return false end
    
    uiCache.playerGui = playerGui
    uiCache.magicHealth = magicHealth
    uiCache.hotbarPath = hotbarPath
    uiCache.textLabel = magicHealth:FindFirstChild("TextLabel")
    uiCache.ult = magicHealth:FindFirstChild("Ult")
    
    if not uiCache.textLabel or not uiCache.ult then return false end
    
    local health = magicHealth:FindFirstChild("Health")
    if not health then return false end
    
    local healthBar = health:FindFirstChild("Bar")
    if not healthBar then return false end
    
    uiCache.healthBar = healthBar:FindFirstChild("Bar")
    if not uiCache.healthBar then return false end
    
    -- Применяем шрифт
    uiCache.textLabel.FontFace = preloadedFont
    uiCache.ult.FontFace = preloadedFont
    
    -- Удаляем ненужные элементы сразу при инициализации
    safeDestroy(uiCache.textLabel:FindFirstChild("TextLabel"))
    safeDestroy(uiCache.ult:FindFirstChild("TextLabel"))
    safeDestroy(uiCache.healthBar:FindFirstChild("Empty"))
    
    -- Настройка позиций
    local basePos = uiCache.textLabel.Position
    uiCache.ult.Position = basePos + UDim2.new(0, 0, 0, 5)
    uiCache.textLabel.Position = basePos + UDim2.new(0, 0, 0, -20)
    uiCache.magicHealth.Position = uiCache.magicHealth.Position + UDim2.new(0, 0, 0, 5)
    uiCache.magicHealth.Size = UDim2.new(0, 300, 0, 20)
    
    -- Настройка health bar
    uiCache.healthBar.Image = ""
    if health:FindFirstChild("Glow") then
        health.Glow.Image = ""
    end
    uiCache.healthBar.BackgroundTransparency = 0
    
    -- Создание кастомного фрейма
    local existingFrame = uiCache.magicHealth:FindFirstChild("CustomFrame")
    if existingFrame then existingFrame:Destroy() end
    
    local frame = Instance.new("Frame")
    frame.Name = "CustomFrame"
    frame.Parent = uiCache.magicHealth
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.Position = health.Position
    frame.BackgroundTransparency = 0.5
    createGradient(frame)
    
    -- Применяем стили к основным элементам
    createStroke(uiCache.textLabel, 2)
    createStroke(uiCache.ult, 2)
    createStroke(uiCache.magicHealth, 2.3, 0.35)
    createGradient(uiCache.healthBar)
    
    -- Инициализация кнопок хотбара
    uiCache.buttons = {}
    for i = 1, 13 do
        local button = hotbarPath:FindFirstChild(tostring(i))
        if button then
            local base = button:FindFirstChild("Base")
            if base then
                local number = base:FindFirstChild("Number")
                local reuse = base:FindFirstChild("Reuse")
                
                if number and reuse then
                    -- Удаляем дубликаты
                    safeDestroy(number:FindFirstChild("Number"))
                    safeDestroy(reuse:FindFirstChild("Reuse"))
                    
                    -- Применяем стили
                    createStroke(number, 1.3)
                    createStroke(reuse, 1.3)
                    
                    -- Применяем шрифт
                    number.FontFace = preloadedFont
                    reuse.FontFace = preloadedFont
                    
                    -- Ищем элемент кулдауна более тщательно
                    local cooldown = nil
                    
                    -- Сначала ищем прямо в button
                    cooldown = button:FindFirstChild("Cooldown")
                    
                    -- Если не нашли, ищем в base
                    if not cooldown and base then
                        cooldown = base:FindFirstChild("Cooldown")
                    end
                    
                    -- Если все еще не нашли, ищем рекурсивно
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
    end
    
    return true
end

local function optimizedMainLoop()
    if not uiCache.textLabel then return end
    
    -- Постоянное подавление нежелательных элементов
    local delete1 = uiCache.textLabel:FindFirstChild("TextLabel")
    local delete2 = uiCache.ult:FindFirstChild("TextLabel")
    local delete3 = uiCache.healthBar:FindFirstChild("Empty")
    
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
    
    -- Обновление кулдаунов кнопок
    for i, buttonData in pairs(uiCache.buttons) do
        if buttonData.cooldown then
            buttonData.cooldown.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
            buttonData.cooldown.BackgroundTransparency = 0.2
        end
        
        -- Убеждаемся что шрифт применен
        if buttonData.number then
            buttonData.number.FontFace = preloadedFont
        end
        if buttonData.reuse then
            buttonData.reuse.FontFace = preloadedFont
        end
    end
    
    -- Обновление данных персонажа
    local character = localPlayer:GetAttribute("Character")
    if character then
        local charData = characterData[character]
        if charData then
            uiCache.textLabel.Text = charData.text
            uiCache.healthBar.BackgroundColor3 = charData.color
        end
    end
end

local function aggressiveInitialize()
    initAttempts = initAttempts + 1
    
    if ultraFastInitializeUI() then
        isInitialized = true
        initAttempts = 0
        
        if currentConnection then
            currentConnection:Disconnect()
        end
        
        currentConnection = RunService.Heartbeat:Connect(optimizedMainLoop)
        
        print("JJS GUI успешно инициализирован!")
        return true
    end
    
    if initAttempts >= maxInitAttempts then
        initAttempts = 0
        task.wait(0.1)
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
    task.wait(0.1) -- Небольшая задержка для полной загрузки UI
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
        task.wait(0.1)
        instantStart()
    end)
end

-- Уведомление
-- Замените последнюю часть скрипта (уведомление) на этот код:

-- Уведомление (исправленная версия)
local success, err = pcall(function()
    game.StarterGui:SetCore("SendNotification", {
        Title = "Made by KeyToWxn/Sairo",
        Text = "JJS GUI - Fixed Version loaded!",
        Duration = 8,
    })
end)

-- Если основной способ не работает, используем альтернативный
if not success then
    pcall(function()
        local StarterGui = game:GetService("StarterGui")
        StarterGui:SetCore("SendNotification", {
            Title = "JJS GUI",
            Text = "Script loaded successfully!",
            Duration = 8
        })
    end)
end

-- Если и это не работает, выводим в консоль
if not success then
    print("JJS GUI - Fixed Version успешно загружен!")
