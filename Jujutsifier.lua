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
local preloadedInstances = {}

local function preloadInstances()
    for i = 1, 5 do
        local gradient = Instance.new("UIGradient")
        gradient.Rotation = 90
        gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)), 
            ColorSequenceKeypoint.new(1, Color3.fromRGB(90,90,90))
        })
        table.insert(preloadedInstances, gradient)
    end
    
    for i = 1, 20 do
        local stroke = Instance.new("UIStroke")
        stroke.Thickness = 2
        stroke.Transparency = 0
        table.insert(preloadedInstances, stroke)
    end
end

local function usePreloadedGradient(parent)
    if parent:FindFirstChild("UIGradient") then return end
    local gradient = table.remove(preloadedInstances, 1)
    if gradient and gradient:IsA("UIGradient") then
        gradient.Parent = parent
    else
        local newGradient = Instance.new("UIGradient")
        newGradient.Parent = parent
        newGradient.Rotation = 90
        newGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)), 
            ColorSequenceKeypoint.new(1, Color3.fromRGB(90,90,90))
        })
    end
end

local function usePreloadedStroke(parent, thickness, transparency)
    if parent:FindFirstChild("UIStroke") then return end
    local stroke = table.remove(preloadedInstances, 1)
    if stroke and stroke:IsA("UIStroke") then
        stroke.Parent = parent
        stroke.Thickness = thickness or 2
        stroke.Transparency = transparency or 0
        if thickness and thickness > 2 then
            stroke.LineJoinMode = Enum.LineJoinMode.Miter
        end
    else
        local newStroke = Instance.new("UIStroke")
        newStroke.Parent = parent
        newStroke.Thickness = thickness or 2
        newStroke.Transparency = transparency or 0
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
    
    uiCache.textLabel.FontFace = preloadedFont
    uiCache.ult.FontFace = preloadedFont
    
    local elementsToDelete = {
        uiCache.textLabel:FindFirstChild("TextLabel"),
        uiCache.ult:FindFirstChild("TextLabel"),
        uiCache.healthBar:FindFirstChild("Empty")
    }
    
    for _, element in ipairs(elementsToDelete) do
        if element then 
            element.Parent = nil
        end
    end
    
    local basePos = uiCache.textLabel.Position
    uiCache.ult.Position = basePos + UDim2.new(0, 0, 0, 5)
    uiCache.textLabel.Position = basePos + UDim2.new(0, 0, 0, -20)
    uiCache.magicHealth.Position = uiCache.magicHealth.Position + UDim2.new(0, 0, 0, 5)
    uiCache.magicHealth.Size = UDim2.new(0, 300, 0, 20)
    
    uiCache.healthBar.Image = ""
    health.Glow.Image = ""
    uiCache.healthBar.BackgroundTransparency = 0
    
    if not uiCache.magicHealth:FindFirstChild("CustomFrame") then
        local frame = Instance.new("Frame")
        frame.Name = "CustomFrame"
        frame.Parent = uiCache.magicHealth
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.Position = health.Position
        frame.BackgroundTransparency = 0.5
        
        usePreloadedGradient(frame)
    end
    
    usePreloadedStroke(uiCache.textLabel, 2)
    usePreloadedStroke(uiCache.ult, 2)
    usePreloadedStroke(uiCache.magicHealth, 2.3, 0.35)
    usePreloadedGradient(uiCache.healthBar)
    
    uiCache.buttons = {}
    for i = 1, 13 do
        local button = hotbarPath:FindFirstChild(tostring(i))
        if button then
            local base = button:FindFirstChild("Base")
            if base then
                local number = base:FindFirstChild("Number")
                local reuse = base:FindFirstChild("Reuse")
                
                if number and reuse then
                    local delete4 = number:FindFirstChild("Number")
                    local delete5 = reuse:FindFirstChild("Reuse")
                    if delete4 then delete4.Parent = nil end
                    if delete5 then delete5.Parent = nil end
                    
                    usePreloadedStroke(number, 1.3)
                    usePreloadedStroke(reuse, 1.3)
                    
                    number.FontFace = preloadedFont
                    reuse.FontFace = preloadedFont
                    
                    uiCache.buttons[i] = {
                        button = button,
                        cooldown = button:FindFirstChild("Cooldown", true)
                    }
                end
            end
        end
    end
    
    return true
end

local function optimizedMainLoop()
    if not uiCache.textLabel then return end
    
    local delete1 = uiCache.textLabel:FindFirstChild("TextLabel")
    local delete2 = uiCache.ult:FindFirstChild("TextLabel")
    local delete3 = uiCache.healthBar:FindFirstChild("Empty")
    
    if delete1 then delete1.Text = "" end
    if delete2 then delete2.Text = "" end  
    if delete3 then delete3.Enabled = false end
    
    for _, buttonData in pairs(uiCache.buttons) do
        if buttonData.cooldown then
            buttonData.cooldown.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
            buttonData.cooldown.BackgroundTransparency = 0.2
        end
    end
    
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
    
    preloadInstances()
    
    local initConnection
    initConnection = RunService.Heartbeat:Connect(function()
        if aggressiveInitialize() then
            initConnection:Disconnect()
        end
    end)
end

localPlayer.CharacterAdded:Connect(function()
    instantStart()
end)

localPlayer.CharacterRemoving:Connect(function()
    if currentConnection then
        currentConnection:Disconnect()
    end
    isInitialized = false
end)

if localPlayer.Character then
    instantStart()
else
    local charAddedConnection
    charAddedConnection = localPlayer.CharacterAdded:Connect(function()
        charAddedConnection:Disconnect()
        instantStart()
    end)
end

playerGui:SetCore("SendNotification", {
        Title = "Made by KeyToWxn/Sairo";
        Text = "The Strongest Battlegrounds Jujutsifier (JJS GUI)";
        Icon = "rbxassetid://135454283842172";
        Duration = "8";
})
