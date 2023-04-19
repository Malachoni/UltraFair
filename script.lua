for i,v in pairs(getconnections(game.Players.LocalPlayer.Idled)) do
	v:Disable()
end
local tools = {}

for i,v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
	if v:IsA("Tool") then
		table.insert(tools, v.Name)
	end
end
local ui = loadstring(game:HttpGet("https://raw.githubusercontent.com/Malachoni/First-Gui/main/First.lua"))()

local window = ui.CreateLib("One Fruit Simulator", getgenv().ThemeOption)

local customColors = {
    SchemeColor = Color3.fromRGB(0,255,255),
    Background = Color3.fromRGB(0, 0, 0),
    Header = Color3.fromRGB(0, 0, 0),
    TextColor = Color3.fromRGB(255,255,255),
    ElementColor = Color3.fromRGB(20, 20, 20)
}

local plr = game:GetService("Players").LocalPlayer
------------------------------
getgenv().SkillZ = false
getgenv().SkillC = false
getgenv().SkillX = false
getgenv().SkillV = false
getgenv().SkillB = false
getgenv().Noclip = false
-------------------------------
local mainTab = window:NewTab("Main")
local plrTab = window:NewTab("Player")
--local mainSection = mainTab:NewSection("Auto Skills")
local plrSection = plrTab:NewSection("Player")
local creditsTab = window:NewTab("Do not OPEN!")

local sanincredit = creditsTab:NewSection("Kalika When you Gay.. You Gay...")

plrSection:NewToggle("Noclip", "Enables Noclip", function(state)
    getgenv().Noclip = state
end)



local skillsSection = mainTab:NewSection("Skills")

skillsSection:NewToggle("Auto Skill: Z", "Uses Skill Z", function(state)
    getgenv().SkillZ = state
end)

skillsSection:NewToggle("Auto Skill: X", "Uses Skill X", function(state)
    getgenv().SkillX = state
end)

skillsSection:NewToggle("Auto Skill: C", "Uses Skill C", function(state)
    getgenv().SkillC = state
end)

skillsSection:NewToggle("Auto Skill: V", "Uses Skill V", function(state)
    getgenv().SkillV = state
end)

skillsSection:NewToggle("Auto Skill: B", "Uses Skill B", function(state)
    getgenv().SkillB = state
end)

game:GetService("RunService").Stepped:Connect(function()
    if getgenv().getgenv().Noclip then
        pcall(function()
            plr.Character.Humanoid:ChangeState(11)
        end)
    end
    if getgenv().AutoFarm or getgenv().Noclip then
        pcall(function()
            plr.Character.Humanoid:ChangeState(11)
	    local useTool = game.Players.LocalPlayer.Backpack[getgenv().CurrentWeapon]
            plr.Character.Humanoid:EquipTool(useTool)
        end)
    end
    if getgenv().SkillX then
        pcall(function()
            keypress(0x58)
            wait(0.01)
            keyrelease(0x58)
        wait(5)
        end)
    end
    if getgenv().SkillC then
        pcall(function()
            keypress(0x43)
            wait(0.01)
            keyrelease(0x43)
        wait(5)
        end)
    end
    if getgenv().SkillB then
        pcall(function()
            keypress(0x42)
            wait(0.01)
            keyrelease(0x42)
        wait(5)
        end)
    end
    if getgenv().SkillV then
        pcall(function()
            keypress(0x56)
            wait(0.01)
            keyrelease(0x56)
        wait(5)
        end)
    end
    if getgenv().SkillZ then
        pcall(function()
            keypress(0x5A)
            wait(0.01)
            keyrelease(0x5A)
        wait(5)
        end)
    end
end)
