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
        while getgenv().autoCrate do
            local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if hrp and typeof(firetouchinterest) == "function" then
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if not getgenv().autoCrate then break end
                    if obj:IsA("Model") and obj.Name == "MoneyCube" then
                        local hitbox = obj:FindFirstChild("Hitbox")
                        local ti = hitbox and hitbox:FindFirstChild("TouchInterest")
                        if hitbox and ti then
                            pcall(function()
                                firetouchinterest(hrp, hitbox, 0)
                                firetouchinterest(hrp, hitbox, 1)
                            end)
                        end
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
