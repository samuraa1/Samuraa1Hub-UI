local ThemeManager = {}
ThemeManager.__index = ThemeManager

local HttpService = game:GetService("HttpService")

local Library

local DEFAULT_THEMES = {
    ["Blue"] = {
        Accent = Color3.fromRGB(100, 149, 255),
        AccentGradient = Color3.fromRGB(70, 110, 200),
    },
    ["Purple"] = {
        Accent = Color3.fromRGB(160, 100, 255),
        AccentGradient = Color3.fromRGB(120, 70, 200),
    },
    ["Cyan"] = {
        Accent = Color3.fromRGB(60, 200, 230),
        AccentGradient = Color3.fromRGB(40, 160, 190),
    },
    ["Green"] = {
        Accent = Color3.fromRGB(80, 200, 120),
        AccentGradient = Color3.fromRGB(60, 160, 90),
    },
    ["Red"] = {
        Accent = Color3.fromRGB(220, 80, 80),
        AccentGradient = Color3.fromRGB(180, 50, 50),
    },
    ["Orange"] = {
        Accent = Color3.fromRGB(255, 160, 50),
        AccentGradient = Color3.fromRGB(220, 120, 30),
    },
    ["Pink"] = {
        Accent = Color3.fromRGB(255, 100, 180),
        AccentGradient = Color3.fromRGB(200, 60, 140),
    },
}

function ThemeManager:SetLibrary(Lib)
    Library = Lib
end

function ThemeManager:SetFolder(FolderName)
    self.Folder = FolderName
    if not isfolder(FolderName) then
        makefolder(FolderName)
    end
end

function ThemeManager:GetThemePath(Name)
    return (self.Folder or "ThemeManager") .. "/" .. Name .. ".json"
end

function ThemeManager:ListThemes()
    local list = {}
    for name in next, DEFAULT_THEMES do
        table.insert(list, name)
    end
    local folder = self.Folder or "ThemeManager"
    if isfolder(folder) then
        for _, f in ipairs(listfiles(folder)) do
            local name = f:match("([^/\\]+)%.json$")
            if name then table.insert(list, name) end
        end
    end
    return list
end

function ThemeManager:ApplyTheme(ThemeData)
    if not Library then return end
    if ThemeData.Accent then
        Library.Theme.Accent = ThemeData.Accent
        Library:ChangeTheme("Accent", ThemeData.Accent)
    end
    if ThemeData.AccentGradient then
        Library.Theme.AccentGradient = ThemeData.AccentGradient
        Library:ChangeTheme("AccentGradient", ThemeData.AccentGradient)
    end
end

function ThemeManager:LoadTheme(Name)
    if DEFAULT_THEMES[Name] then
        self:ApplyTheme(DEFAULT_THEMES[Name])
        return true
    end
    local path = self:GetThemePath(Name)
    if not isfile(path) then return false, "Theme not found: " .. Name end
    local ok, data = pcall(function()
        local raw = HttpService:JSONDecode(readfile(path))
        return {
            Accent = raw.Accent and Color3.new(raw.Accent.r, raw.Accent.g, raw.Accent.b),
            AccentGradient = raw.AccentGradient and Color3.new(raw.AccentGradient.r, raw.AccentGradient.g, raw.AccentGradient.b),
        }
    end)
    if not ok then return false, "Failed to parse theme" end
    self:ApplyTheme(data)
    return true
end

function ThemeManager:SaveTheme(Name)
    if not Library then return false, "Library not set" end
    local folder = self.Folder or "ThemeManager"
    if not isfolder(folder) then makefolder(folder) end
    local c1 = Library.Theme.Accent
    local c2 = Library.Theme.AccentGradient
    local data = {
        Accent = c1 and {r = c1.R, g = c1.G, b = c1.B},
        AccentGradient = c2 and {r = c2.R, g = c2.G, b = c2.B},
    }
    local ok, err = pcall(function()
        writefile(self:GetThemePath(Name), HttpService:JSONEncode(data))
    end)
    return ok, err
end

function ThemeManager:BuildThemeSection(Tab)
    if not Tab then return end

    local ThemeSection = Tab:Section({Name = "Themes", Side = 1})

    local selectedTheme = nil
    local customName = ""

    local ThemeList = ThemeSection:Listbox({
        Flag = "_ThemeManagerList",
        Items = self:ListThemes(),
        Callback = function(v)
            selectedTheme = v
        end
    })

    ThemeSection:Button({
        Name = "Apply Theme",
        Callback = function()
            if selectedTheme then
                local ok, err = self:LoadTheme(selectedTheme)
                if ok then
                    Library:Notification({Title = "ThemeManager", Description = "Applied theme '" .. selectedTheme .. "'.", Duration = 3})
                else
                    Library:Notification({Title = "Error", Description = tostring(err), Duration = 3})
                end
            end
        end
    })

    ThemeSection:Textbox({
        Flag = "_ThemeManagerName",
        Placeholder = "Custom theme name...",
        Finished = true,
        Callback = function(v)
            customName = v
        end
    })

    ThemeSection:Button({
        Name = "Save Current Theme",
        Callback = function()
            if customName and customName ~= "" then
                local ok, err = self:SaveTheme(customName)
                if ok then
                    Library:Notification({Title = "ThemeManager", Description = "Saved theme '" .. customName .. "'.", Duration = 3})
                    ThemeList:Refresh(self:ListThemes())
                else
                    Library:Notification({Title = "Error", Description = tostring(err), Duration = 3})
                end
            end
        end
    })
end

return ThemeManager
