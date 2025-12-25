-- bart hub is open source :)

local PLACES = {
    [79388437164798] = "https://raw.githubusercontent.com/bardvanm/barthub/main/Raise1MillionBees.lua",
}

local function httpGet(url)
    local ok, res
    if type(syn) == "table" and type(syn.request) == "function" then
        ok, res = pcall(function() return syn.request({Url = url, Method = "GET"}) end)
        if ok and res and res.Body then return res.Body end
    end

    if type(http_request) == "function" then
        ok, res = pcall(function() return http_request({Url = url, Method = "GET"}) end)
        if ok and res and res.Body then return res.Body end
    end

    if type(request) == "function" then
        ok, res = pcall(function() return request({Url = url, Method = "GET"}) end)
        if ok and res and res.Body then return res.Body end
    end

    -- fallback to built-in (may error depending on environment)
    ok, res = pcall(function() return game:HttpGet(url) end)
    if ok then return res end

    return nil
end

local function loadRemoteScript(url)
    local body = httpGet(url)
    if not body then
        warn(("loader.lua: failed to fetch %s"):format(url))
        return false
    end
    local fn, compileErr = loadstring(body)
    if not fn then
        warn("loader.lua: compile error:", compileErr)
        return false
    end
    local ok, runErr = pcall(fn)
    if not ok then
        warn("loader.lua: runtime error:", runErr)
        return false
    end
    return true
end

local placeId = (game and game.PlaceId) or 0
local url = PLACES[placeId]

if url then
    print(("loader.lua: detected supported placeId %d, loading %s"):format(placeId, url))
    if not loadRemoteScript(url) then
        warn("loader.lua: failed to load remote script for placeId", placeId)
    end
    return
end

-- Not a supported place: optionally redirect users to a hub or show message.
print(("loader.lua: placeId %d not registered in PLACES; nothing loaded."):format(placeId))