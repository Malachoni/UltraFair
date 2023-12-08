--thanks to DekuDimz and Anyx, used some of their script for some help 
getgenv().Get = setmetatable({}, {__index = function(Self, Idx) return game:GetService(Idx) end})

getgenv().Toggles = {
    Farm = false,
    KillAura = false,
    MobAura = false,
    AutoRoll = false,
    Store = false,
    FarmBoss = false,
    BreakBarrier = false
}

getgenv().FarmSettings = {
    AuraDistance = 6,
    FarmDistance = 3,
    KillPlayers = true,
    SelectedQuest = nil
}

getgenv().AuraSettings = {
    PunchSpeed = 0.15,
    KillDistance = 12,
    Mode = "Punch (Lowest 150ms)"
}


getgenv().RollSettings = {
    Amount = 25,
    Threshold = 15,
    Hide = false
}


local Players = Get.Players
local Player = Players.LocalPlayer
local Workspace = Get.Workspace
local RunService = Get.RunService
local Rep = Get.ReplicatedStorage
local HttpService = Get.HttpService


local function Save(File, Table)
    if (writefile) then
        local json = HttpService:JSONEncode(Table)
        writefile("UU_"..File..".txt", json)
    else
        print("Saving Not Supported")
    end
end

local function Load(File)
    if not (readfile and isfile) then
        print("Loading Not Supported")
        --File Reading Not supported
        return
    end
    if isfile("UU_"..File..".txt") then
        print("Found File")
        Table = HttpService:JSONDecode(readfile("UU_"..File..".txt"))
        print("Settings Loaded")
        return(Table)
    end
end

AuraSettings = Load("AuraSettings")
RollSettings = Load("RollSettings")
FarmSettings = Load("FarmSettings")

local VirtualUser=game:service'VirtualUser'
game:service'Players'.LocalPlayer.Idled:connect(function()
VirtualUser:CaptureController()
VirtualUser:ClickButton2(Vector2.new())
end)


local Old = getsenv(Player.PlayerScripts.MoveHandler)

hookfunction(Old.camshake, function()
    return
end)

hookfunction(Old._G.knockback, function()
    return
end)

hookfunction(Old._G.HitEffect, function()
    return
end)
hookfunction(Old._G.flasheffect, function()
    return
end)

hookfunction(Old.addparticle, function()
    return
end)


function HideName()
    for i,v in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
        if v.ClassName == "BillboardGui" then
            v:Destroy()
        end
    end
end


A = require(Workspace.EnemyStats) --Get enemy names and stats
local MobList = {}
for i, v in pairs(A) do
    table.insert(MobList, i) --append name to list
end


RunService.Stepped:Connect(
   function()
       if Toggles.Farm then
           for i, v in pairs(Player.Character:GetChildren()) do
               if v:IsA("BasePart") then
                   v.CanCollide = false
               end
           end
       end
   end
)


local function ActivateAbility()
    local args = {[1] = false} 
    Rep.ToggleAbility:InvokeServer(unpack(args))
end


local function getNearestMobs(Type)
    local LowestDistance = math.huge
    local Target
    for i, v in ipairs(Workspace:GetChildren()) do
        if v:IsA("Model")  then
            if Toggles.Farm then
                if not(table.find(Type, v.Name)) then
                    continue
                end
            elseif Toggles.MobAura then
                if not(table.find(MobList, v.Name)) then
                    continue
                end
            elseif Toggles.KillAura then
                if not(v:FindFirstChildWhichIsA("Humanoid")) or v.Name == Player.Name then
                    continue
                end
            end
            
            local Enemy = v:FindFirstChildWhichIsA("Humanoid")
            if Enemy and Enemy.Health ~= 0 then
                local CurrentDistance = (Player.Character.HumanoidRootPart.Position - v:GetModelCFrame().Position).Magnitude
                if CurrentDistance < LowestDistance then
                    LowestDistance = CurrentDistance
                    Target = v
                end
            end
        end
    end
    return Target
end

local function getNearestObstacles(barrierOnly)
    local LowestDistance = math.huge
    local Target
    for i, v in ipairs(Workspace:GetChildren()) do
        if v:IsA("Model") and (not(table.find(MobList, v.Name)) or v.Name == "Barrier") and v.Name ~= Player.Name then
            local Enemy = v:FindFirstChildWhichIsA("Humanoid")
            if barrierOnly and not v.Name == "Barrier" then
                continue
            end
            if Enemy and Enemy.Health ~= 0 then
                local CurrentDistance = (Player.Character.HumanoidRootPart.Position - v:GetModelCFrame().Position).Magnitude
                if CurrentDistance < LowestDistance then
                    LowestDistance = CurrentDistance
                    Target = v
                end
            end
        end
    end
    return Target
end





local function check(e)
    local script = game:GetService("Players").LocalPlayer.PlayerGui.MainClient.LocalScript
    if getfenv(e) and getfenv(e).script and getfenv(e).script.Name and getfenv(e).script == script then
        return true
    else
        return false
    end
end

getgenv().Attack = nil
local CurrentEnemy = nil
local PunchCounter = 0

local function AttackFuncGet()
    for _,v in pairs(getgc()) do
        if type(v) == 'function' and check(v) then
            if(debug.getinfo(v).numparams) == 4 then
                getgenv().Attack = v
            end
        end
    end
end


local function Punch(Enemy)
    if CurrentEnemy ~= nil and CurrentEnemy == Enemy then
        PunchCounter += 1
    else
        CurrentEnemy = Enemy
        PunchCounter = 0
    end
    --some script i edited for attack (from Anyx)
    if PunchCounter >= 5 then
        wait(1)
        PunchCounter = 0
    end


    if getgenv().Attack then
        getgenv().Attack(Vector3.new(AuraSettings.KillDistance, AuraSettings.KillDistance, AuraSettings.KillDistance),CFrame.new(0,0,0),6,nil)
    else
        AttackFuncGet()
    end
end

local function ArbiterHit(Enemy)
    local args = {
        [1] = "Dark Blade",
        [2] = Enemy:FindFirstChildWhichIsA("Humanoid")
    }
    Rep.Damage:FireServer(unpack(args))
end

-- local function ArbiterUlt(Enemy)
--     local args = {
--         [1] = "Dark Blade",
--         [2] = Enemy:FindFirstChildWhichIsA("Humanoid"),
--         [4] = {["Ultimate"] = true}
--     }
--     Rep.Damage:FireServer(unpack(args))
-- end

local function EnergyBlade(Enemy)
    local args = {
        [1] = "DualSwordHeavy",
        [2] = Enemy:FindFirstChildWhichIsA("Humanoid"),
        [3] = Player.Character.Cancellations.Value,
        [4] = {
            [1] = Enemy:FindFirstChildWhichIsA("Humanoid")
        }
    }
    Rep.Damage:FireServer(unpack(args))
end



local function Hit(Enemy)
    if AuraSettings.Mode == "Punch" then
        Punch(Enemy)
        wait(AuraSettings.PunchSpeed)
    elseif AuraSettings.Mode == "Dark Blade (Arbiter Only)" then
        ArbiterHit(Enemy)
        wait(AuraSettings.PunchSpeed)
    elseif AuraSettings.Mode == "Energy Blade" then
        EnergyBlade(Enemy)
        wait(AuraSettings.PunchSpeed)
    end
end


local function Quest(Quest)
    local args = {
        [1] = Quest
    } 
    Rep.TakeQuest:FireServer(unpack(args))
end


local function GetQuestMobs(quest)
    if quest == "Real Amgogus" then 
        EnemyType = {"Cripple"}
    elseif quest == "Gaming Disorder" then 
        EnemyType = {"Crail"}
    elseif quest == "Kingdom" then 
        EnemyType = {"Blyke", "Isen", "Remi", "Zeke"}
    elseif quest == "Rigged Game" then 
        EnemyType = {"Arlo", "John", "Seraphina"}
    elseif quest == "Trouble in the backrooms" then 
        EnemyType = {"Seer", "John", "Seraphina"}
    elseif quest == "Something is in the sewers" then 
        EnemyType = {"Cultist"}
    elseif quest == "Cooking some crossovers" then 
        EnemyType = {"Thunderclap"}
    elseif quest == "Troubles from another timeline" then 
        EnemyType = {"Roku"}
    end
    return(EnemyType)
end



local function GetOffsetVector(Enemy)
    local Vector = Player.Character.HumanoidRootPart.Position - Enemy:GetModelCFrame().Position
    local Distance = (Vector).Magnitude
    local Normal = Vector3.new(Vector.x/Distance, Vector.y/Distance, Vector.z/Distance)
    local Offset = Normal * FarmSettings.FarmDistance
    local NewPosition = Enemy:GetModelCFrame().Position + Offset
    return NewPosition
end

getgenv().BossFight = false
local EnemyBarrier = false

local function Farm()
    spawn(function()
        while wait() do
            if not BossFight then
                if Toggles.Farm then
                    
                    pcall(function()
                        if not Player.PlayerGui.MainClient.Quest.visible then
                            Quest(FarmSettings.SelectedQuest)
                        else
                            local QuestCount = Player.PlayerGui.MainClient.Quest.Folder.Objective.progress.text:split("/")
                            if QuestCount[1] == QuestCount[2] then
                                Quest("Completed")
                            end
                        end
            

                        if not Player.Character:FindFirstChild("Head"):FindFirstChild("LeftGlow") then
                            ActivateAbility()
                        end

                        local EnemyType = GetQuestMobs(FarmSettings.SelectedQuest)
                        local Enemy = getNearestMobs(EnemyType)
                        local CurrentDistance = (Player.Character.HumanoidRootPart.Position - Enemy:GetModelCFrame().Position).Magnitude

                        local Obstacle
                        Obstacle = getNearestObstacles(false)
                        if Obstacle.Name ~= "Barrier" and not ((Player.Character.HumanoidRootPart.Position - Obstacle:GetModelCFrame().Position).Magnitude < AuraSettings.KillDistance) then
                            EnemyBarrier = false
                        end
                        if CurrentDistance < FarmSettings.AuraDistance then
                            local Hp1 = Enemy:FindFirstChildWhichIsA("Humanoid").Health
                            Hit(Enemy)
                            if (Hp1 - Enemy:FindFirstChildWhichIsA("Humanoid").Health) == 0 then
                                EnemyBarrier = true
                            end
                        elseif FarmSettings.KillPlayers and Obstacle and (Player.Character.HumanoidRootPart.Position - Obstacle:GetModelCFrame().Position).Magnitude < AuraSettings.KillDistance then
                            Hit(Obstacle)
                        else
                            Player.Character.Humanoid:MoveTo(GetOffsetVector(Enemy))
                        end
                        if Obstacle.Name == "Barrier" and CurrentDistance < FarmSettings.AuraDistance and EnemyBarrier then
                            Hit(Obstacle)
                        end
                    end
                    )

                elseif (Toggles.KillAura or Toggles.MobAura) and not Toggles.Farm then

                    pcall(function()
                        local Enemy = getNearestMobs()
                        if (Player.Character.HumanoidRootPart.Position - Enemy:GetModelCFrame().Position).Magnitude < AuraSettings.KillDistance then
                            Hit(Enemy)
                        end
                    end)

                end
            end
        end
    end)
end



B = Workspace:FindFirstChild("BossSpawns") --Get enemy names and stats
local BossList = {}
local BossPosition = B:GetChildren()[1].CFrame.Position
for i, v in pairs(B:GetChildren()) do
    table.insert(BossList, v.Name) --append name to list
end

local function LocateBoss()
    for i, v in ipairs(Workspace:GetChildren()) do
        if v:IsA("Model") and table.find(BossList , v.Name) then
            if (v:GetModelCFrame().Position - BossPosition).Magnitude < 30 then
                return v
            end
        end
    end    
end


local function BossFarm()
    spawn(function()
        while wait() and Toggles.FarmBoss do
            pcall(function()
                if Player.PlayerGui.Boss.Enabled == true then
                    BossFight = true
                    local Boss = LocateBoss()
                    wait(0.1)
                    for i,v in pairs(getconnections(Player.PlayerGui.Reroll.bosstp.Yes.MouseButton1Click)) do
                        v.Function()
                    end
                    
                    pcall(function()
                        while Boss.Humanoid.Health > 0 and Toggles.FarmBoss and Boss do
                            Boss = LocateBoss()
                            if not Player.Character:FindFirstChild("Head"):FindFirstChild("LeftGlow") then
                                ActivateAbility()
                            end

                            if (Player.Character.HumanoidRootPart.Position - Boss:GetModelCFrame().Position).Magnitude  < AuraSettings.KillDistance then
                                Hit(Boss)
                            else 
                                Player.Character.Humanoid:MoveTo(GetOffsetVector(Boss))
                                wait(0.1)
                            end
                            if Toggles.BreakBarrier then
                                local Barrier = getNearestObstacles(true)
                                if (Player.Character.HumanoidRootPart.Position - Barrier:GetModelCFrame().Position).Magnitude < AuraSettings.KillDistance  then
                                    Hit(Barrier)
                                end
                            end
                        end
                    end)
                    BossFight = false
                end
                wait(0.1)
            end)
        end
    end)
end


getgenv().AbilityDict = {}
getgenv().ReplaceAbility = nil
local RerollPath = Player.PlayerGui.Reroll
local AbilityList = {}
local AbilityStore = {}
local StoredNames = {}


AbilityDict = Load("AbilityFilter")
for i, v in pairs(RerollPath.Prompt.Prompt.ScrollingFrame:GetChildren()) do
    if v:IsA("TextButton") then
        table.insert(AbilityList, v.Name)
        if not (AbilityDict[v.Name]) then
            AbilityDict[v.Name] = 0
        end
    end
end

local function ConvertFloat(stri)
    local number = stri:split(".")
    local decimal = tonumber(number[2])/10
    local float = number[1] + decimal
    return (float)
end

local function no()
    for i,v in pairs(getconnections(RerollPath.Question.no.MouseButton1Click)) do
        v.Function()
    end
end
local function yes()
    for i,v in pairs(getconnections(RerollPath.Question.yes.MouseButton1Click)) do
        v.Function()
    end
end


local function AutoRoll()
    spawn(function()
        while wait() and Toggles.AutoRoll do
            RerollPath.Enabled = not RollSettings.Hide
            spawn(function()
                local Rolled

                repeat
                    wait()
                until RerollPath.Question.Visible == true
                Rolled = RerollPath.Rerolling.Ability.TextLabel.Text

                local Level = Rolled:split("(")[2]:split(")")[1]
                local Ability = string.gsub(Rolled:split("(")[1], "%s+$", "")

                print("Rolled ".. Ability.. " " .. Level .. " | out of minimum | ".. AbilityDict[Ability])
                Level = ConvertFloat(Level)
            
                if (Level >= RollSettings.Threshold) or (Level>= AbilityDict[Ability] and AbilityDict[Ability] ~= 0) then
                    print("Found Ability")
                    RerollPath.Enabled = true

                    if Toggles.Store then

                        repeat
                            wait()
                        until RerollPath.Question.Visible and RerollPath.Question.Title.Text == "Switch Ability"

                        repeat
                            no()
                            wait()
                        until RerollPath.Question.Visible and RerollPath.Question.Title.Text == "Store Ability"

                        while RerollPath.Question.Visible and RerollPath.Question.Title.Text == "Store Ability" do
                            yes()
                            wait()
                        end

                        repeat
                            wait()
                        until RerollPath.AbilityStorage.Visible == true

                        for i, v in AbilityStore do
                            if ReplaceAbility == v.TextLabel.Text then
                                spawn(function()
                                    for i2,v2 in pairs(getconnections(v.MouseButton1Click)) do
                                            v2.Function()
                                    end
                                end)

                                repeat
                                    wait()
                                until RerollPath.Question.Visible and RerollPath.Question.Title.Text == "Replace" == true
                                yes()
                                Toggles.AutoRoll = false
                            end
                        end
                        
                    end
                    Toggles.AutoRoll = false
                else
                    while RerollPath.Question.Visible == true do
                        no()
                        wait(0.2)
                    end
                end
            end)

            repeat
                wait()
            until RerollPath.Question.Visible== false and RerollPath.Rerolling.Visible == false
            
            Rep.Reroll:InvokeServer()
            wait(3)
        end
    end)
end

spawn(function()
	while wait() do
		game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function(character)
            local Players = Get.Players
            local Player = Players.LocalPlayer
            getgenv().Attack = nil
		end)
		game:GetService("Players").LocalPlayer.Character:WaitForChild("Humanoid").Died()
	end
end)


Farm()






local UILibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/Malachoni/UltraFair/main/GUI.lua", true))()

local MainUI = UILibrary.Load("Ultra Fair")

local PageFarm = MainUI.AddPage("Farm", false)
    
local FarmToggle = PageFarm.AddToggle("Auto Farm (Set Aura Hit Mode)", false, function(value)
    Toggles.Farm = value
end)

local SliderFarmDistance = PageFarm.AddSlider("Farm Distance", {Min = 0, Max = 15, Def = FarmSettings.FarmDistance}, function(value)
    FarmSettings.FarmDistance = value
    Save("FarmSettings", FarmSettings)
end)

local SliderAuraDistance = PageFarm.AddSlider("Farm Aura Distance", {Min = 0, Max = 20, Def = FarmSettings.AuraDistance}, function(value)
    FarmSettings.AuraDistance = value
    Save("FarmSettings", FarmSettings)
end)

local KillToggle = PageFarm.AddToggle("Kill Players while Farming (Uses Kill Aura Distance)", FarmSettings.KillPlayers, function(value)
    FarmSettings.KillPlayers = value
    Save("FarmSettings", FarmSettings)
end)

local BossToggle = PageFarm.AddToggle("Auto Boss Kill", false, function(value)
    Toggles.FarmBoss = value
    if value then
        BossFarm()
    end
end)

local QuestSelect = PageFarm.AddDropdown("Quest Select", {
    "Real Amgogus",
    "Gaming Disorder",
    "Kingdom",
    "Rigged Game",
    "Trouble in the backrooms",
    "Something is in the sewers",
    "Cooking some crossovers",
    "Troubles from another timeline"
    }, function(value)
        FarmSettings.SelectedQuest = value
        Save("FarmSettings", FarmSettings)
end, FarmSettings.SelectedQuest)



local PageKillAura = MainUI.AddPage("Kill Aura", false)

local KillAuraToggle = PageKillAura.AddToggle("Kill Aura", false, function(value)
    Toggles.KillAura = value
end)

local MobAuraToggle = PageKillAura.AddToggle("Only Mob Kill Aura (Overrides Kill Aura)", false, function(value)
    Toggles.MobAura = value    
end)

local SliderKillDistance = PageKillAura.AddSlider("Kill Aura Distance", {Min = 0, Max = 30, Def = AuraSettings.KillDistance}, function(value)
    AuraSettings.KillDistance = value
    Save("AuraSettings", AuraSettings)
end)

local SliderPunchSpeed = PageKillAura.AddSlider("Hit Speed (ms)", {Min = 15, Max = 3000, Def = AuraSettings.PunchSpeed * 1000}, function(value)
    AuraSettings.PunchSpeed = value/1000
    Save("AuraSettings", AuraSettings)
end)

-- local Label1 = PageKillAura.AddLabel("Choose Aura Mode")

local AuraMode = PageKillAura.AddDropdown("Aura Hit Mode",
    {   
    "Punch",
    "Dark Blade (Arbiter Only)",
    "Energy Blade"
    }, function(value)
        AuraSettings.Mode = value
        Save("AuraSettings", AuraSettings)
end, AuraSettings.Mode)



local PageRoll = MainUI.AddPage("Roll", false)

local RollAbility = PageRoll.AddButton("Roll Ability", function()
    Rep.Reroll:InvokeServer()
end)

local ToggleAutoRoll = PageRoll.AddToggle("Auto Roll Ability", false, function(value)
    Toggles.AutoRoll = value
    RerollPath.Enabled = true
    if value then
        AutoRoll()
    end
end)

local ToggleAutoRoll = PageRoll.AddToggle("Hide GUI when Auto", false, function(value)
    RollSettings.Hide = value
    RerollPath.Enabled = true
end)


local RollThreshold = PageRoll.AddSlider("Roll Minimum Level (Global)", {Min = 0, Max = 30, Def = RollSettings.Threshold}, function(value)
    RollSettings.Threshold = value
    Save("RollSettings", RollSettings)
end)

 
local ReplaceSelect = PageRoll.AddDropdown("Replace Ability",
    {
        "LOAD"
    }, function(value)
        ReplaceAbility = value
        

end)


spawn(function()
    while true do
        StoredNames = {}
        for i, v in pairs(RerollPath.AbilityStorage.ScrollingFrame:GetChildren()) do
            if v:IsA("TextButton") and v then
                AbilityStore[i] = v
                table.insert(StoredNames, v.TextLabel.Text)
            end
        end
        ReplaceSelect.SetArray(StoredNames)
        wait(0.3)
    end
end)




local AutoStore = PageRoll.AddToggle("Auto Replace Ability", false, function(value)
    Toggles.Store = value
end)


local LabelRoll = PageRoll.AddLabel("Equipment Roll")

local RollFist = PageRoll.AddButton("Roll Fist", function()
    for i = 1, RollSettings.Amount do
        local args = {
            [1] = "Fist"
        }

        game:GetService("ReplicatedStorage").RollGear:InvokeServer(unpack(args))
    end
end)

local RollStyle = PageRoll.AddButton("Roll Style", function()
    for i = 1, RollSettings.Amount do
        local args = {
            [1] = "Relic"
        }

        game:GetService("ReplicatedStorage").RollGear:InvokeServer(unpack(args))
    end
end)

local SliderGear = PageRoll.AddSlider("Equipment Roll Amount", {Min = 0, Max = 100, Def = RollSettings.Amount}, function(value)
    RollSettings.Amount = value
    Save("RollSettings", RollSettings)
end)



local PageAutoRoll = MainUI.AddPage("Auto Config", true)

local Button1 = PageAutoRoll.AddButton("Set Minimum Levels (Overrides Global, 0 is OFF)", function()
    for i, v in pairs(AbilityDict) do
        print("key: "..i.. " value: ".. v)
    end
end)

local AbilitySliders = {}

for i, v in pairs(AbilityList) do
    table.insert(AbilitySliders, (PageAutoRoll.AddSlider(v, {Min = 0, Max = 30, Def = AbilityDict[v]}, function(value)
        AbilityDict[v] = value
        Save("AbilityFilter", AbilityDict)
    end)))
end



local PageMisc = MainUI.AddPage("Misc", false)

local HideName = PageMisc.AddButton("Hide Identity (Continuous)", function()
	spawn(function()
		while true do
    		HideName()
    		wait(1)
    	end
	end)
end)

local AttackBarrier = PageMisc.AddToggle("Damage Arlo Boss Barrier", false, function(value)
    Toggles.BreakBarrier = value
end)

local Reset = PageMisc.AddButton("Reset Character", function()
    Player.Character.Humanoid.Health = 0
end)
