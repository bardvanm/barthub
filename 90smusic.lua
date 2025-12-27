repeat task.wait() until game:IsLoaded()

local vu = game:GetService("VirtualUser")
local player = game.Players.LocalPlayer
player.Idled:Connect(function()
    vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait()
    vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

-- =========================
-- SERVICES
-- =========================
local RunService = game:GetService("RunService")

-- =========================
-- GLOBALS & CACHES
-- =========================
getgenv().spamDroppers = false
getgenv().autoCollect = false
getgenv().myTycoon = nil
getgenv().dropperCD = nil
getgenv().collector = nil
getgenv().collectConnection = nil

-- =========================
-- HELPERS
-- =========================
local function getPlayerTycoon()
    local TYCOONS_FOLDER = workspace:FindFirstChild("Tycoons")
    if not TYCOONS_FOLDER then return nil end
    
    local player = game.Players.LocalPlayer
    
    for _, tycoon in ipairs(TYCOONS_FOLDER:GetChildren()) do
        -- Common owner checks (StringValue name, IntValue UserId, ObjectValue player)
        local owner = tycoon:FindFirstChild("Owner")
        if owner then
            if owner:IsA("StringValue") and owner.Value == player.Name then return tycoon end
            if owner:IsA("ObjectValue") and owner.Value == player then return tycoon end
        end
        
        local ownerVal = tycoon:FindFirstChild("OwnerValue")
        if ownerVal and ownerVal:IsA("StringValue") and ownerVal.Value == player.Name then return tycoon end
        
        local values = tycoon:FindFirstChild("Values")
        if values then
            owner = values:FindFirstChild("Owner")
            if owner and owner:IsA("StringValue") and owner.Value == player.Name then return tycoon end
            
            local ownerId = values:FindFirstChild("OwnerId") or values:FindFirstChild("Player")
            if ownerId and ownerId:IsA("IntValue") and ownerId.Value == player.UserId then return tycoon end
        end
        
        local tycoonInfo = tycoon:FindFirstChild("TycoonInfo")
        if tycoonInfo then
            owner = tycoonInfo:FindFirstChild("Owner")
            if owner and owner:IsA("StringValue") and owner.Value == player.Name then return tycoon end
        end
    end
    
    return nil
end

local function updateCache()
    getgenv().myTycoon = getPlayerTycoon()
    if not getgenv().myTycoon then
        getgenv().dropperCD = nil
        getgenv().collector = nil
        return false
    end
    
    -- Cache Dropper ClickDetector
    local dropper = getgenv().myTycoon:FindFirstChild("F1ManualDropper", true)
    if dropper then
        local clickPart = dropper:FindFirstChild("ClickPart") or dropper:FindFirstChildWhichIsA("BasePart", true)
        getgenv().dropperCD = clickPart and (clickPart:FindFirstChildOfClass("ClickDetector") or clickPart:FindFirstChild("ClickDetector"))
    else
        getgenv().dropperCD = nil
    end
    
    -- Cache CollectorPart (for TouchInterest auto-collect)
    local moneyClaimer = getgenv().myTycoon:FindFirstChild("MoneyClaimer")
    getgenv().collector = moneyClaimer and moneyClaimer:FindFirstChild("CollectorPart")
    
    return true
end

local function isMoneyPart(part)
    if not part or not part:IsA("BasePart") or part.Parent ~= workspace or not part:FindFirstChild("TouchInterest") then
        return false
    end
    
    local name = part.Name:lower()
    if name:match("money|cash|drop|note|cd|record|vinyl|cassette|coin|bill|dollar|spawn|%$$") then
        return true
    end
    
    -- Check for money values
    local value = part:FindFirstChildWhichIsA("IntValue") or part:FindFirstChildWhichIsA("NumberValue")
    if value and (value.Name:lower():match("value|amount|money")) then
        return true
    end
    
    return false
end

local function collectPart(drop)
    if getgenv().collector and drop and drop.Parent then
        pcall(function()
            firetouchinterest(getgenv().collector, drop, 0)
            task.wait()
            firetouchinterest(getgenv().collector, drop, 1)
        end)
    end
end

local function collectExisting()
    task.spawn(function()
        for _, part in ipairs(workspace:GetChildren()) do
            if isMoneyPart(part) then
                collectPart(part)
                task.wait(0.01) -- Tiny batch delay
            end
        end
    end)
end

-- =========================
-- SPAM DROPPERS (OPTIMIZED: Cached CD, ultra-fast loop)
-- =========================
function spamDroppers()
    task.spawn(function()
        local lastUpdate = 0
        while getgenv().spamDroppers do
            local now = tick()
            if now - lastUpdate > 10 then -- Update cache every 10s
                updateCache()
                lastUpdate = now
            end
            
            if getgenv().dropperCD then
                pcall(function() fireclickdetector(getgenv().dropperCD) end)
            end
            
            RunService.Heartbeat:Wait() -- ~60 FPS spam, zero lag
        end
    end)
end

-- =========================
-- AUTO COLLECT (OPTIMIZED: ChildAdded + Periodic Sweep + Cached Collector)
-- =========================
function autoCollectMoney()
    -- Disconnect old connection
    if getgenv().collectConnection then
        getgenv().collectConnection:Disconnect()
        getgenv().collectConnection = nil
    end
    
    task.spawn(function()
        local lastUpdate = 0
        local lastSweep = 0
        
        -- Initial cache & sweep
        updateCache()
        collectExisting()
        
        -- Connect to new drops (perf king)
        getgenv().collectConnection = workspace.ChildAdded:Connect(function(child)
            task.spawn(function()
                task.wait(0.1) -- Let spawn/phys settle
                if isMoneyPart(child) then
                    collectPart(child)
                end
            end)
        end)
        
        while getgenv().autoCollect do
            local now = tick()
            
            -- Update cache sparingly
            if now - lastUpdate > 10 then
                updateCache()
                lastUpdate = now
            end
            
            -- Periodic sweep for missed/rare drops (every 3s)
            if now - lastSweep > 3 then
                collectExisting()
                lastSweep = now
            end
            
            task.wait(0.5) -- Low CPU loop
        end
        
        -- Cleanup on disable
        if getgenv().collectConnection then
            getgenv().collectConnection:Disconnect()
            getgenv().collectConnection = nil
        end
    end)
end

-- =========================
-- GUI
-- =========================
local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/bardvanm/bartlib/main/bartlib.lua"))()
local win = lib:CreateWindow("90sMusic")
local auto = win:CreateFolder("Auto")

auto:Toggle("Spam Droppers", function(v)
    getgenv().spamDroppers = v
    if v then 
        updateCache()
        spamDroppers() 
    end
end)

auto:Toggle("Auto Collect", function(v)
    getgenv().autoCollect = v
    if v then 
        updateCache()
        autoCollectMoney() 
    end
end)

-- Auto-update cache on player respawn/tycoon claim (bonus perf)
player.CharacterAdded:Connect(updateCache)
workspace.ChildAdded:Connect(function(child)
    if child.Name == "Tycoons" then updateCache() end
end)

print("🚀 90sMusic Tycoon Hub Loaded! Claim tycoon → Toggle ON → AFK Farm!")