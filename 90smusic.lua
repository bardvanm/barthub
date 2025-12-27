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

-- =========================
-- FIND YOUR TYCOON (used for spam + teleport)
-- =========================
local function getMyTycoon()
    local TYCOONS_FOLDER = workspace:FindFirstChild("Tycoons")
    if not TYCOONS_FOLDER then return nil end
    
    for _, tycoon in ipairs(TYCOONS_FOLDER:GetChildren()) do
        -- Check "Owner" StringValue directly in tycoon
        local owner = tycoon:FindFirstChild("Owner")
        if owner and owner:IsA("StringValue") and owner.Value == player.Name then
            return tycoon
        end
        
        -- Check inside "Values" folder (very common)
        local values = tycoon:FindFirstChild("Values")
        if values then
            owner = values:FindFirstChild("Owner")
            if owner and owner:IsA("StringValue") and owner.Value == player.Name then
                return tycoon
            end
        end
    end
    
    return nil
end

-- =========================
-- SPAM FUNCTION (your original one – only changed to use your tycoon)
-- =========================
function spamDroppers()
    task.spawn(function()
        while getgenv().spamDroppers do
            local myTycoon = getMyTycoon()
            if myTycoon then
                local dropper = myTycoon:FindFirstChild("F1ManualDropper", true)
                if dropper then
                    local clickPart = dropper:FindFirstChild("ClickPart") or dropper:FindFirstChildWhichIsA("BasePart", true)
                    local cd = clickPart and (clickPart:FindFirstChildOfClass("ClickDetector") or clickPart:FindFirstChild("ClickDetector"))
                    if cd then
                        pcall(function() fireclickdetector(cd) end)
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
local misc = win:CreateFolder("Misc")  -- new folder for teleport button

auto:Toggle("Spam Droppers", function(v)
    getgenv().spamDroppers = v
    if v then spamDroppers() end
end)

misc:Button("Teleport to My Plot", function()
    local myTycoon = getMyTycoon()
    if myTycoon then
        -- Find a good spot to teleport (top of tycoon or any part)
        local root = myTycoon:FindFirstChildWhichIsA("BasePart", true)
        if root and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = root.CFrame + Vector3.new(0, 5, 0)  -- 5 studs above
            print("Teleported to your tycoon!")
        else
            print("Couldn't find a spot to teleport – claim your tycoon first!")
        end
    else
        print("No tycoon found! Claim your plot first.")
    end
end)

print("Script loaded! Claim your tycoon → Press 'Teleport to My Plot' to test → Toggle Spam ON")