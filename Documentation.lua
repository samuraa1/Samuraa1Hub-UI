--[[
================================================================================
  MentalityUI Rewrite — Library documentation (reference)
  Style: API reference similar in spirit to Obsidian / Linoria-style hubs.
  This file is plain Lua comments; load in your editor or publish as reference.
================================================================================

  LOAD (executor with HTTP)
  --------------------------------------------------------------------------------
    local Library = loadstring(game:HttpGet("YOUR_RAW_LIBRARY_URL"))()

  Optional modules (same repo):
    local SaveManager = loadstring(game:HttpGet(".../SaveManager.lua"))()
    local ThemeManager = loadstring(game:HttpGet(".../ThemeManager.lua"))()

--------------------------------------------------------------------------------
  WINDOW
  --------------------------------------------------------------------------------
  Library:CreateWindow({
      Title       = string,          -- Hub title (top bar)
      SubTitle    = string?,         -- Subtitle under title
      Logo        = string?,         -- rbx asset id (numbers only, no rbxassetid://)
      Size        = UDim2?,          -- Optional; library sets defaults
      MenuKey     = Enum.KeyCode?,   -- Toggle UI (also keybind in settings)
  }) -> Window

  Window methods:
    Window:Page({ Name = string, Icon = string }) -> Page
      Icon: Lucide name or custom asset id string (see Library:SetIcon).

    Window:DashboardPage({ ... }) -> DashPage
      Extended dashboard with welcome, stats, cards, links.

    Window:Category(name)          -- Sidebar category label
    Window:TabDivider()            -- Thin divider between sidebar groups

    Window:SetOpen(boolean)        -- Show / hide main frame
    Window:Toggle()                -- Flip open state
    Window:Init()                  -- Call after building pages (first tab, tweens)

  Floating button:
    A draggable round button (logo) toggles the UI. Controlled by settings flag
    "FloatingButtonVisible" and theme transparency.

--------------------------------------------------------------------------------
  PAGES (normal)
  --------------------------------------------------------------------------------
  local Page = Window:Page({ Name = "Main", Icon = "gamepad-2" })

  Page:Section({ Name, Icon?, Side = 1 | 2 }) -> Section
    Side 1 = left column, Side 2 = right column (two-column layout).

--------------------------------------------------------------------------------
  DASHBOARD PAGE
  --------------------------------------------------------------------------------
  Window:DashboardPage({
      Name, Icon,
      WelcomeText, HubName, StatusText, Badge,
      GameName, GameDescription,
      Links = { { Icon, Tooltip, Callback }, ... },
      Stats = { { Name, Icon, GetValue = function() return "..." end }, ... },
      Credits = { { Name = "", Role = "" }, ... },
      QuickAccess = {}
  })

  DashPage:AddCard({ Name, Description, Icon, Tab = Page })  -- jump to tab

--------------------------------------------------------------------------------
  SECTION ELEMENTS
  --------------------------------------------------------------------------------
  All created from Section:

    Section:Toggle({
        Name, Flag, Default = bool,
        Tooltip = string?,
        Callback = function(value: boolean) end
    })

    Section:Slider({
        Name, Flag, Min, Max, Default, Decimals?,
        Suffix = string?,
        Callback = function(number) end
    })
    -- Value label is editable (click to type).

    Section:Dropdown({
        Name, Flag, Items = { "a", "b" },
        Default = string?, Multi = bool?,
        Search = bool?,              -- search box inside dropdown list
        Size, OptionHolderSize,
        Callback = function(value) end
    })

    Section:Button({ Name, Icon?, Callback = function() end })
    Section:Label(text) | Section:Label("text"):Colorpicker({ ... })
    Section:Keybind({ Name, Flag, Default = Enum.KeyCode, Callback = function() end })
    Section:Textbox({ Flag, Placeholder, Finished = bool, Callback = function(s) end })
    Section:Divider() | Section:Divider("optional label")

--------------------------------------------------------------------------------
  SETTINGS PAGE (built-in)
  --------------------------------------------------------------------------------
  Library:CreateSettingsPage(Window, KeybindList) -> Page
    Adds "UI Settings" with:
      - Accent / gradient colorpickers, font weight, background transparency
      - DPI Scale (UIScale on main frame)
      - Show Floating Toggle Button
      - Custom Cursor (separate top ScreenGui; hides default mouse icon)
      - Keybind list visibility, menu keybind enable, Toggle UI key
      - Config list (if file API available)

--------------------------------------------------------------------------------
  FLAGS & PERSISTENCE
  --------------------------------------------------------------------------------
  Library.Flags[flagName]     -- current values (toggles, sliders, etc.)
  Library:SetFlag(name, val)  -- where exposed
  SaveManager / writefile     -- optional external config saving

--------------------------------------------------------------------------------
  THEME
  --------------------------------------------------------------------------------
  Library.Theme               -- Accent, AccentGradient, Background, etc.
  Library:ChangeTheme(key, Color3)
  ThemeManager:SetLibrary(Library); ThemeManager:SetFolder("MyHub")
  ThemeManager:BuildThemeSection(SettingsPage)

--------------------------------------------------------------------------------
  ICONS
  --------------------------------------------------------------------------------
  Library:SetIcon(ImageLabel, "lucide-name")
  Library:ResolveIcon(name)   -- internal; strips "-2" suffix, fallbacks

--------------------------------------------------------------------------------
  CLEANUP
  --------------------------------------------------------------------------------
  Library:Unload()
    Disconnects connections, destroys ScreenGuis, restores MouseIconEnabled.

================================================================================
  NOTES FOR SCRIPT AUTHORS
  ================================================================================
  - Use unique Flag names across the UI so configs do not collide.
  - firetouchinterest / fireproximityprompt are executor globals in most
    environments; keep pcall around game-specific remotes.
  - Custom Cursor requires a mouse; on pure touch devices the OS cursor may
    not apply — the setting is mainly for PC / hybrid.

================================================================================
]]

return "MentalityUI-Rewrite Documentation (see block comment above)."
