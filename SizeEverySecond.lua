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
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

getgenv().autoRebirth = false
getgenv().autoTrophy = false

function autoRebirth()
    task.spawn(function()
        while getgenv().autoRebirth do
            pcall(function()
                RS:WaitForChild("RebirthEvent"):FireServer("tier24")
            end)
            task.wait(0.01)
        end
    end)
end

function autoTrophy()
    task.spawn(function()
        while getgenv().autoTrophy do
            local parts = {}
            for _, v in ipairs(workspace:GetDescendants()) do
                if v:IsA("BasePart") and string.lower(v.Name) == "part82" then
                    table.insert(parts, v)
                end
            end

            local char = player.Character or player.CharacterAdded:Wait()
            local hrp = char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart
            if hrp and #parts > 0 then
                for _, part in ipairs(parts) do
                    if not getgenv().autoTrophy then break end
                    pcall(function()
                        if firetouchinterest then
                            firetouchinterest(part, hrp, 0)
                            firetouchinterest(part, hrp, 1)
                        end
                    end)
                    RunService.Heartbeat:Wait() -- one part per render frame
                end
            else
                RunService.Heartbeat:Wait()
            end
        end
    end)
end

local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/bardvanm/bartlib/main/bartlib.lua"))()
local win = lib:CreateWindow("SizeEverySecond")
local farm = win:CreateFolder("Farm")

farm:Toggle("autoRebirth", function(v) getgenv().autoRebirth = v if v then autoRebirth() end end)
farm:Toggle("autoTrophy", function(v) getgenv().autoTrophy = v if v then autoTrophy() end end)

