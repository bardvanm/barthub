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
-- GLOBALS
-- =========================
getgenv().spamDroppers = false
getgenv().autoCollect = false
getgenv().autoCrate = false
getgenv().autoCrateDelay = 0.05
getgenv().autoUpgrade = false
getgenv().autoSave = false
getgenv().autoComplete = false

-- tracked crates and connections to avoid heavy rescans
local autoCrateCubes = {}
local autoCrateAddConn, autoCrateRemoveConn
local function clearAutoCrateTracking()
    if autoCrateAddConn then autoCrateAddConn:Disconnect(); autoCrateAddConn = nil end
    if autoCrateRemoveConn then autoCrateRemoveConn:Disconnect(); autoCrateRemoveConn = nil end
    for k in pairs(autoCrateCubes) do autoCrateCubes[k] = nil end
end
local function seedAutoCrates()
    for _, child in ipairs(workspace:GetChildren()) do
        if child:IsA("Model") and child.Name == "MoneyCube" then
            autoCrateCubes[child] = true
        end
    end
end
local function hookAutoCrateSignals()
    autoCrateAddConn = workspace.ChildAdded:Connect(function(obj)
        if obj:IsA("Model") and obj.Name == "MoneyCube" then
            autoCrateCubes[obj] = true
        end
    end)
    autoCrateRemoveConn = workspace.ChildRemoved:Connect(function(obj)
        if autoCrateCubes[obj] then autoCrateCubes[obj] = nil end
    end)
end

-- =========================
-- SPAM FUNCTION
-- =========================
function spamDroppers()
    task.spawn(function()
        local TYCOONS_FOLDER = workspace:FindFirstChild("Tycoons")
        while getgenv().spamDroppers do
            if TYCOONS_FOLDER then
                for _, tycoon in ipairs(TYCOONS_FOLDER:GetChildren()) do
                    if not getgenv().spamDroppers then break end

                    -- try to find the manual dropper and its ClickDetector
                    local dropper = tycoon:FindFirstChild("F1ManualDropper", true) -- recursive search
                    if dropper then
                        local clickPart = dropper:FindFirstChild("ClickPart") or dropper:FindFirstChildWhichIsA("BasePart", true)
                        local cd = clickPart and (clickPart:FindFirstChildOfClass("ClickDetector") or clickPart:FindFirstChild("ClickDetector"))
                        if cd then
                            pcall(function() fireclickdetector(cd) end)
                        end
                    end

                    -- slight pause to avoid freezing; effectively "spams" by looping quickly
                    RunService.Heartbeat:Wait()
                end
            else
                -- if no Tycoons folder, wait briefly and try again
                RunService.Heartbeat:Wait()
            end
        end
    end)
end

-- =========================
-- AUTO COLLECT FUNCTION
-- =========================
function autoCollect()
    task.spawn(function()
        local TYCOONS_FOLDER = workspace:FindFirstChild("Tycoons")
        while getgenv().autoCollect do
            if TYCOONS_FOLDER then
                for _, tycoon in ipairs(TYCOONS_FOLDER:GetChildren()) do
                    if not getgenv().autoCollect then break end

                    local moneyClaimer = tycoon:FindFirstChild("MoneyClaimer", true)
                    local collectorPart = moneyClaimer and moneyClaimer:FindFirstChild("CollectorPart", true)
                    local touchInterest = collectorPart and collectorPart:FindFirstChild("TouchInterest")

                    if collectorPart and touchInterest then
                        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                        if hrp and typeof(firetouchinterest) == "function" then
                            pcall(function()
                                firetouchinterest(hrp, collectorPart, 0)
                                firetouchinterest(hrp, collectorPart, 1)
                            end)
                        end
                    end

                    RunService.Heartbeat:Wait()
                end
            else
                RunService.Heartbeat:Wait()
            end
        end
    end)
end

-- =========================
-- AUTO CRATE FUNCTION
-- =========================
function autoCrate()
    task.spawn(function()
        clearAutoCrateTracking()
        seedAutoCrates()
        hookAutoCrateSignals()

        while getgenv().autoCrate do
            local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if hrp and typeof(firetouchinterest) == "function" then
                for cube in pairs(autoCrateCubes) do
                    if not getgenv().autoCrate then break end
                    local hitbox = cube:FindFirstChild("Hitbox")
                    local ti = hitbox and hitbox:FindFirstChild("TouchInterest")
                    if hitbox and ti then
                        pcall(function()
                            firetouchinterest(hrp, hitbox, 0)
                            firetouchinterest(hrp, hitbox, 1)
                        end)
                    end
                end
            end
            RunService.Heartbeat:Wait()
            task.wait(getgenv().autoCrateDelay or 0.05)
        end

        clearAutoCrateTracking()
    end)
end

-- =========================
-- AUTO UPGRADE FUNCTION
-- =========================
function autoUpgrade()
    task.spawn(function()
        local TYCOONS_FOLDER = workspace:FindFirstChild("Tycoons")
        while getgenv().autoUpgrade do
            local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if hrp and typeof(firetouchinterest) == "function" and TYCOONS_FOLDER then
                for _, tycoon in ipairs(TYCOONS_FOLDER:GetChildren()) do
                    if not getgenv().autoUpgrade then break end
                    local buyButtons = tycoon:FindFirstChild("BuyButtons")
                    if buyButtons then
                        local prio1, prio2, rest = {}, {}, {}

                        local function hasKeyword(btn, keywords)
                            local p = btn.Parent
                            local g = p and p.Parent
                            local pn = tostring(p and p.Name or ""):lower()
                            local gn = tostring(g and g.Name or ""):lower()
                            for _, kw in ipairs(keywords) do
                                if pn:find(kw) or gn:find(kw) then return true end
                            end
                            return false
                        end

                        local prio1Keys = {"dropper", "upgrader", "conveyor", "fence"}
                        local prio2Keys = {"walls", "wall", "wall upgrade", "stairs", "stair", "floor", "roof", "windows", "window"}

                        for _, btn in ipairs(buyButtons:GetDescendants()) do
                            if btn:IsA("BasePart") and btn.Name == "PurchaseButton" then
                                local ti = btn:FindFirstChild("TouchInterest")
                                if ti then
                                    if hasKeyword(btn, prio1Keys) then
                                        table.insert(prio1, btn)
                                    elseif hasKeyword(btn, prio2Keys) then
                                        table.insert(prio2, btn)
                                    else
                                        table.insert(rest, btn)
                                    end
                                end
                            end
                        end

                        local function tap(list)
                            for _, btn in ipairs(list) do
                                if not getgenv().autoUpgrade then break end
                                pcall(function()
                                    firetouchinterest(hrp, btn, 0)
                                    firetouchinterest(hrp, btn, 1)
                                end)
                            end
                        end

                        if #prio1 > 0 then
                            tap(prio1)
                        elseif #prio2 > 0 then
                            tap(prio2)
                        else
                            tap(rest)
                        end
                    end
                end
            end
            RunService.Heartbeat:Wait()
        end
    end)
end

-- =========================
-- AUTO SAVE FUNCTION
-- =========================
function autoSave()
    task.spawn(function()
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local remotes = ReplicatedStorage:FindFirstChild("RemoteEvents") or ReplicatedStorage:WaitForChild("RemoteEvents", 5)
        local manual = remotes and (remotes:FindFirstChild("ManualSave") or remotes:WaitForChild("ManualSave", 5))
        while getgenv().autoSave do
            if manual and manual.FireServer then
                pcall(function() manual:FireServer() end)
            else
                remotes = ReplicatedStorage:FindFirstChild("RemoteEvents")
                manual = remotes and remotes:FindFirstChild("ManualSave")
            end
            RunService.Heartbeat:Wait()
        end
    end)
end

-- =========================
-- AUTO COMPLETE FUNCTION
-- =========================
local function findCompletionYesButton()
    local pg = player:FindFirstChildOfClass("PlayerGui") or player:WaitForChild("PlayerGui")
    local promptRoot
    for _, d in ipairs(pg:GetDescendants()) do
        if d:IsA("TextLabel") or d:IsA("TextButton") then
            local t = tostring(d.Text or ""):lower()
            if t:find("complete your tycoon") then
                promptRoot = d.Parent or d
                break
            end
        end
    end
    if not promptRoot then
        -- fallback: any YES button
        for _, d in ipairs(pg:GetDescendants()) do
            if d:IsA("TextButton") then
                local t = tostring(d.Text or ""):lower()
                if t == "yes" or t:find("yes") then
                    return d
                end
            end
        end
        return nil
    end
    -- look for a YES button near the prompt
    for _, d in ipairs(promptRoot:GetDescendants()) do
        if d:IsA("TextButton") then
            local t = tostring(d.Text or ""):lower()
            if t == "yes" or t:find("yes") then
                return d
            end
        end
    end
    -- broaden search one level up
    local parent = promptRoot.Parent
    if parent then
        for _, d in ipairs(parent:GetDescendants()) do
            if d:IsA("TextButton") then
                local t = tostring(d.Text or ""):lower()
                if t == "yes" or t:find("yes") then
                    return d
                end
            end
        end
    end
    return nil
end

local function pressGuiButton(btn)
    if not btn then return end
    local ok = false
    -- prefer VirtualInputManager for a reliable click
    local vim = (pcall(function() return game:GetService("VirtualInputManager") end) and game:GetService("VirtualInputManager")) or nil
    if vim and btn.AbsolutePosition and btn.AbsoluteSize then
        local x = btn.AbsolutePosition.X + (btn.AbsoluteSize.X/2)
        local y = btn.AbsolutePosition.Y + (btn.AbsoluteSize.Y/2)
        pcall(function()
            vim:SendMouseButtonEvent(x, y, 0, true, btn, 1)
            vim:SendMouseButtonEvent(x, y, 0, false, btn, 1)
        end)
        ok = true
    end
    if not ok then
        pcall(function() if btn.Activate then btn:Activate() end end)
    end
end

function autoComplete()
    task.spawn(function()
        local TYCOONS_FOLDER = workspace:FindFirstChild("Tycoons")
        while getgenv().autoComplete do
            local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if hrp and typeof(firetouchinterest) == "function" and TYCOONS_FOLDER then
                for _, tycoon in ipairs(TYCOONS_FOLDER:GetChildren()) do
                    if not getgenv().autoComplete then break end
                    local ch = tycoon:FindFirstChild("CompletionHandler")
                    local cp = ch and ch:FindFirstChild("CompletePart")
                    local ti = cp and cp:FindFirstChild("TouchInterest")
                    if cp and ti then
                        pcall(function()
                            firetouchinterest(hrp, cp, 0)
                            firetouchinterest(hrp, cp, 1)
                        end)
                        task.wait(0.1)
                        local yesBtn = findCompletionYesButton()
                        if yesBtn then pressGuiButton(yesBtn) end
                    end
                end
            end
            RunService.Heartbeat:Wait()
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
    if v then spamDroppers() end
end)

auto:Toggle("Auto Collect", function(v)
    getgenv().autoCollect = v
    if v then autoCollect() end
end)

auto:Toggle("Auto Crate", function(v)
    getgenv().autoCrate = v
    if v then autoCrate() end
end)

auto:Slider("Crate Delay (s)", {min = 0.05, max = 0.25, step = 0.01}, function(v)
    getgenv().autoCrateDelay = v
end)

auto:Toggle("Auto Upgrade", function(v)
    getgenv().autoUpgrade = v
    if v then autoUpgrade() end
end)

auto:Toggle("Auto Save", function(v)
    getgenv().autoSave = v
    if v then autoSave() end
end)

auto:Toggle("Auto Complete", function(v)
    getgenv().autoComplete = v
    if v then autoComplete() end
end)
