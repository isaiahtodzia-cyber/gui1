-- Place XboxUI ModuleScript in ReplicatedStorage; this LocalScript in StarterPlayerScripts.
local XboxUI = require(game:GetService("ReplicatedStorage"):WaitForChild("XboxUI"))
local window = XboxUI.new({Title = "NEXUS", ProfileName = "Player  •  Online"})
local home = window:AddPage("Home")
local library = window:AddPage("My library")
local settings = window:AddPage("Settings")
home:AddHero({
    Tag = "YOUR WORLD. YOUR WAY.", Title = "Jump back in.",
    Description = "Discover something new. Build something extraordinary.",
    ActionText = "LET'S PLAY  →",
    Callback = function() window:Notify("Connect this button to your game's play flow.") end,
    -- Image = "rbxassetid://YOUR_UPLOADED_IMAGE_ID",
})
home:AddSection("Made for you")
home:AddTiles({
    {Title = "My library", Description = "All your favorites", Icon = "▦", Color = Color3.fromRGB(30, 68, 47),
        Callback = function() window:SelectPage(library) end},
    {Title = "Discover", Description = "Find your next adventure", Icon = "◇", Color = Color3.fromRGB(41, 52, 82),
        Callback = function() window:Notify("Discover selected") end},
    {Title = "Achievements", Description = "Make every moment count", Icon = "★", Color = Color3.fromRGB(80, 61, 32),
        Callback = function() window:Notify("Achievements selected") end},
    {Title = "Settings", Description = "Make it yours", Icon = "☷", Color = Color3.fromRGB(48, 46, 60),
        Callback = function() window:SelectPage(settings) end},
})
library:AddSection("Your collection")
library:AddTiles({
    {Title = "Adventure", Description = "Ready to play", Callback = function() window:Notify("Adventure selected") end},
    {Title = "Racing", Description = "Ready to play", Callback = function() window:Notify("Racing selected") end},
})
settings:AddSection("Preferences")
settings:AddToggle({Title = "Music", Default = true, Callback = function(enabled)
    window:Notify("Music " .. (enabled and "enabled" or "disabled"))
    -- Set your game's SoundGroup volume here.
end})
settings:AddSlider({Title = "Volume", Min = 0, Max = 100, Default = 70, Step = 5,
    Callback = function(value) print("Volume:", value) end})
settings:AddButton({Title = "Return home", Callback = function() window:SelectPage(home) end})
