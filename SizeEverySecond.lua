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
local Plots = workspace:WaitForChild("Plots")

getgenv().autoRebirth = false
getgenv().autoTrophy = false

function autoRebirth()
    task.spawn(function()
        while getgenv().autoRebirth do
            pcall(function()
                RS:WaitForChild("RebirthEvent"):FireServer("tier24")
            end)
            task.wait(0.1)
        end
    end)
end

function autoTrophy()
    task.spawn(function()
        while getgenv().autoTrophy do
            pcall(function()
                local folder = workspace:FindFirstChild("Folder45")
                local target = nil
                if folder then
                    local children = folder:GetChildren()
                    target = children[18] and children[18]:FindFirstChild("Part82")
                end
                if target then
                    local char = player.Character or player.CharacterAdded:Wait()
                    local hrp = char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart
                    if hrp then
                        if firetouchinterest then
                            firetouchinterest(target, hrp, 0)
                            task.wait(0.05)
                            firetouchinterest(target, hrp, 1)
                        else
                            local old = hrp.CFrame
                            hrp.CFrame = target.CFrame * CFrame.new(0, 0, 2)
                            task.wait(0.1)
                            hrp.CFrame = old
                        end
                    end
                end
            end)
            task.wait(0.1)
        end
    end)
end

local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/bardvanm/bartlib/main/bartlib.lua"))()
local win = lib:CreateWindow("SizeEverySecond")
local farm = win:CreateFolder("Farm")

farm:Toggle("autoRebirth", function(v) getgenv().autoRebirth = v if v then autoRebirth() end end)
farm:Toggle("autoTrophy", function(v) getgenv().autoTrophy = v if v then autoTrophy() end end)

