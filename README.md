# XboxUI for Roblox

An original Xbox-inspired dashboard: dark green backdrop, quick-access tabs, large feature panel, game tiles, green focus outlines, settings controls, and toast notifications. No external dependencies or executor required.

## Install

1. In Roblox Studio, add a **ModuleScript** to **ReplicatedStorage**, name it **XboxUI**, and paste `XboxUI.luau` into it.
2. Add a **LocalScript** to **StarterPlayer > StarterPlayerScripts** and paste `Example.client.luau` into it.
3. Press **Play**. Use mouse/touch, or a controller's directional navigation and A button. B closes; Start reopens. Right Shift toggles on keyboard.

The example callbacks show notifications/print values. Connect them to your own game's actions and audio. Validate gameplay-changing requests on the server.

## API

```lua
local window = XboxUI.new({
    Title = "MY GAME",
    Accent = Color3.fromRGB(144, 232, 66),
    -- ProfileName, BackgroundImage, Parent, DisplayOrder, ToggleKey are optional.
})
local page = window:AddPage("Home")
page:AddSection("Featured")
page:AddHero({Title = "Welcome", Description = "Ready?", Callback = function() end})
page:AddTiles({{Title = "Play", Description = "Start here", Callback = function() end}})
page:AddButton({Title = "Launch", Callback = function() end})
local toggle = page:AddToggle({Title = "Music", Default = true, Callback = print})
local slider = page:AddSlider({Title = "Volume", Min = 0, Max = 100, Step = 5, Default = 50, Callback = print})
toggle:Set(false) -- Second argument true suppresses callback.
print(slider:Get())
window:SelectPage(page)
window:Notify("Saved", 3)
window:SetVisible(false)
window:Destroy() -- Disconnects listeners and removes GUI.
```

Heroes support `Tag`, `ActionText`, `Image`, and `Color`. Tiles support `Icon`, `Image`, and `Color`. Images use your Roblox asset strings, such as `rbxassetid://123456789`. Text-only artwork works without uploaded assets.

The dashboard scales a 1200×720 canvas to fit the available screen. Pages scroll vertically, tabs scroll horizontally, and tiles wrap to four columns. Phone portrait layouts shrink the console canvas; landscape is recommended. Sliders use minus/plus buttons for mouse, touch, and controller accessibility.

## Validation

Source reviewed locally; Roblox Studio runtime and device emulation have not been run. Verify controller focus, image permissions, small-screen readability, and your callbacks in Studio before publishing.

Design reference: https://www.xbox.com/en-GB/consoles/experience
Roblox controller API: https://create.roblox.com/docs/reference/engine/classes/GuiService/SelectedObject

This is an independent inspired design, with no Microsoft branding or bundled Xbox artwork.
