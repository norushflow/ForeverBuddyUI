-- Load the production dictionaries for standalone module tests.
GetLocale = GetLocale or function() return "deDE" end
C_AddOns = C_AddOns or {}
C_AddOns.GetAddOnMetadata = C_AddOns.GetAddOnMetadata or function(name, key)
    local toc = assert(io.open(name .. ".toc"))
    local value = toc:read("*a"):match("## " .. key .. ": ([^\r\n]+)")
    toc:close()
    return value
end
local originalLoadfile = loadfile
local function loadfile(path)
    local chunk, err = originalLoadfile(path)
    if not chunk then return nil, err end
    return function(name, addon, ...)
        if type(addon)=="table" and not addon.L then
            assert(originalLoadfile("Locales/enUS.lua"))(name, addon)
            assert(originalLoadfile("Locales/deDE.lua"))(name, addon)
        end
        return chunk(name, addon, ...)
    end
end

return loadfile
