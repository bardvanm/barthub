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

-- =========================
-- GLOBALS
-- =========================
getgenv().Plot = 3
getgenv().autoClick = false
getgenv().autoHive = false
getgenv().autoShipping = false
getgenv().autoFactory = false
getgenv().autoRebirth = false
getgenv().autoBuy = false
getgenv().autoEquipPlant = false
getgenv().autoPlace = false

-- =========================
-- HELPERS
-- =========================
local function getPlot()
    return Plots:WaitForChild("Plot"..getgenv().Plot)
end

local function getCharacter()
    return player.Character or player.CharacterAdded:Wait()
end

-- =========================
-- AUTO FUNCTIONS
-- =========================
function autoClick()
    task.spawn(function()
        local plot = getPlot()
        local button = plot.BeeButton.ButtonPart
        local cd = button:FindFirstChildOfClass("ClickDetector")
        local filler = button.ProgressGui.ProgressBar.FillerFrame
        if not cd or not filler then return end

        while getgenv().autoClick do
            while filler.Size.X.Scale <= 0.97 and getgenv().autoClick do task.wait() end
            while filler.Size.X.Scale > 0 and getgenv().autoClick do
                fireclickdetector(cd)
                task.wait()
            end
        end
    end)
end

function autoHive()
    task.spawn(function()
        while getgenv().autoHive do
            RS.Remotes.RequestUpgrade:FireServer("Hive", getPlot().HiveSign)
            task.wait(0.6)
        end
    end)
end

function autoShipping()
    task.spawn(function()
        while getgenv().autoShipping do
            RS.Remotes.RequestUpgrade:FireServer("Shipping", getPlot().TruckSign)
            task.wait(0.6)
        end
    end)
end

function autoFactory()
    task.spawn(function()
        while getgenv().autoFactory do
            RS.Remotes.RequestUpgrade:FireServer(
                "Factory",
                getPlot().ItemContainer:WaitForChild("HoneyFactory")
            )
            task.wait(0.8)
        end
    end)
end

function autoRebirth()
    task.spawn(function()
        while getgenv().autoRebirth do
            RS.Remotes.RebirthEvent:FireServer()
            task.wait(1)
        end
    end)
end

function autoBuy()
    task.spawn(function()
        while getgenv().autoBuy do
            RS.Remotes.BuyItemFunction:InvokeServer("FlowerFrame9")
            task.wait(0.5)
        end
    end)
end

function autoEquipPlant()
    task.spawn(function()
        while getgenv().autoEquipPlant do
            local backpack = player:WaitForChild("Backpack")
            local char = getCharacter()
            local seed = backpack:FindFirstChild("Yellow Tulip Seed")
                or char:FindFirstChild("Yellow Tulip Seed")
            if seed and seed.Parent == backpack then
                char.Humanoid:EquipTool(seed)
            end
            task.wait(0.5)
        end
    end)
end

-- =========================
-- AUTO PLACE HONEY CRATES
-- =========================
function autoPlace()
    task.spawn(function()
        while getgenv().autoPlace do
            local plot = getPlot()
            local char = getCharacter()
            local hrp = char:WaitForChild("HumanoidRootPart")
            local humanoid = char:WaitForChild("Humanoid")

            -- collect crates
            for i = 1, 6 do
                local hive = plot.ItemContainer:FindFirstChild("Hive_"..i)
                if hive and hive:FindFirstChild("HoneyCrate") then
                    local prompt = hive.HoneyCrate:FindFirstChildWhichIsA("ProximityPrompt", true)
                    if prompt then
                        hrp.CFrame = prompt.Parent.CFrame * CFrame.new(0,0,-2)
                        task.wait(0.4)
                        fireproximityprompt(prompt)
                        task.wait(0.4)
                    end
                end
            end

            -- sell all crates
            local sellPoint = plot.SellingArea:WaitForChild("PromptPart")
            local sellPrompt = sellPoint:FindFirstChildWhichIsA("ProximityPrompt", true)

            hrp.CFrame = sellPoint.CFrame * CFrame.new(0,0,-2)
            task.wait(0.5)

            while true do
                local crate
                for _,tool in ipairs(player.Backpack:GetChildren()) do
                    if tool:IsA("Tool") and tool.Name:find("Honey Crate") then
                        crate = tool
                        break
                    end
                end
                if not crate then break end
                humanoid:EquipTool(crate)
                task.wait(0.2)
                fireproximityprompt(sellPrompt)
                task.wait(0.3)
            end

            task.wait(1)
        end
    end)
end

-- =========================
-- GUI
-- =========================
local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/bardvanm/bartlib/main/bartlib.lua"))()
--local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/wall%20v3"))()
local win = lib:CreateWindow("Bee")
local farm = win:CreateFolder("Farm")
local buy = win:CreateFolder("Buy")

farm:Toggle("autoClick",function(v)getgenv().autoClick=v if v then autoClick() end end)
farm:Toggle("autoHive",function(v)getgenv().autoHive=v if v then autoHive() end end)
farm:Toggle("autoShipping",function(v)getgenv().autoShipping=v if v then autoShipping() end end)
farm:Toggle("autoFactory",function(v)getgenv().autoFactory=v if v then autoFactory() end end)
farm:Toggle("autoRebirth",function(v)getgenv().autoRebirth=v if v then autoRebirth() end end)
farm:Toggle("autoPlace",function(v)getgenv().autoPlace=v if v then autoPlace() end end)

farm:Button("Switch Plot",function()
    getgenv().Plot = (getgenv().Plot % 4) + 1
end)

buy:Toggle("autoBuy",function(v)getgenv().autoBuy=v if v then autoBuy() end end)
buy:Toggle("autoEquipPlant",function(v)getgenv().autoEquipPlant=v if v then autoEquipPlant() end end)
buy:Button("Infinite Yield", function()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
    end)
end)

-- =====================================================================
-- ================== DISCORD LEADERBOARD WEBHOOK =======================
-- =====================================================================

task.spawn(function()
    local HttpService = game:GetService("HttpService")
    local WEBHOOK = "https://discord.com/api/webhooks/1453554254856851507/ekc138GEpr0TcqBvFlNf3ZTw_CZww7Tpqe2kYDY8TDBlv-OaESXSdbQOHdOrml9c3AfC"
    local INTERVAL = 300 -- 5 minutes

    local board = workspace.Leaderboards.LeaderboardMoney.ScoreBlock.SurfaceGui
    local last = nil

    local function parse(txt)
        local num, suffix = txt:match("[%$]?([%d%.]+)([KMB]?)")
        num = tonumber(num) or 0
        if suffix == "K" then num = num * 1e3
        elseif suffix == "M" then num = num * 1e6
        elseif suffix == "B" then num = num * 1e9 end
        return num
    end

    local function post(msg)
        local data = HttpService:JSONEncode({content=msg})
        local req = http_request or request or HttpPost or syn.request
        req({Url = WEBHOOK, Body = data, Method = "POST", Headers = {["Content-Type"]="application/json"}})
    end

    while true do
        local current = {}
        for i=1,10 do
            current[i] = {
                name = board.Names["Name"..i].Text,
                score = parse(board.Score["Score"..i].Text),
                raw = board.Score["Score"..i].Text
            }
        end

        local msg = "**Top Money**\n"
        for i=1,10 do
            local extra = i==1 and " 🏆" or ""
            msg ..= ("#%d %s : %s%s\n"):format(i,current[i].name,current[i].raw, extra)
        end

        if last then
            local changesExist = false
            local changesMsg = "\n**Changes**\n"

            for i=1,10 do
                local diff = current[i].score - (last[i] and last[i].score or 0)
                if diff ~= 0 then
                    local pct = last[i].score>0 and (diff/last[i].score*100) or 0
                    changesExist = true
                    changesMsg ..= ("#%d %s : %+d (%.2f%%)\n"):format(i,current[i].name,diff,pct)
                end
            end

            for i=1,10 do
                if last[i] and not table.find((function()
                    local t={}
                    for j=1,10 do t[j]=current[j].name end
                    return t
                end)(), last[i].name) then
                    changesExist = true
                    changesMsg ..= ("❌ %s left the top 10\n"):format(last[i].name)
                end
            end

            if changesExist then
                msg ..= changesMsg
            end
        end

        post(msg)
        last = current
        task.wait(INTERVAL)
    end
end)