-- Gathering HUD, the way FarmHud works.
-- One key spreads the minimap's icons around your character. The ground
-- drawing is hidden, so the world stays in view and only what you track
-- floats over it: herbs, ore, quest marks, party, your saved spots, the
-- trail, and the pin. A faint ring and N, E, S, W letters show the edge
-- and the way north. The same key puts the minimap back.

local F = select(2, ...).F

local ROUND_MASK = "Textures\\MinimapMask"
local SQUARE_MASK = "Interface\\BUTTONS\\WHITE8X8"
local DOT = "Interface\\BUTTONS\\WHITE8X8"
local SCREEN_SHARE = 0.62
local RING_DOTS = 72

BINDING_HEADER_NAVIGATEFOREVER = "Navigate Forever"
BINDING_NAME_NAVIGATEFOREVER_HUD = "Gathering HUD"

local hud
local saved
local letters = {}

local function cvar(name)
    if C_CVar and C_CVar.GetCVar then
        local ok, value = pcall(C_CVar.GetCVar, name)
        if ok then
            return F.Plain and F.Plain(value) or value
        end
    end
    if GetCVar then
        local ok, value = pcall(GetCVar, name)
        if ok then
            return value
        end
    end
    return nil
end

local function setCVar(name, value)
    if C_CVar and C_CVar.SetCVar and pcall(C_CVar.SetCVar, name, value) then
        return
    end
    if SetCVar then
        pcall(SetCVar, name, value)
    end
end

local function facing()
    local ok, value = pcall(GetPlayerFacing)
    if not ok then
        return nil
    end
    value = F.Plain and F.Plain(value) or value
    if type(value) ~= "number" then
        return nil
    end
    return value
end

local function placeLetters()
    if not hud then
        return
    end
    local f = facing() or 0
    local radius = hud:GetWidth() / 2 + 14
    for _, letter in ipairs(letters) do
        -- Clockwise screen angle from straight up. North sits at the
        -- facing angle because the HUD turns with the player.
        local angle = letter.bearing + f
        letter:ClearAllPoints()
        letter:SetPoint("CENTER", hud, "CENTER", radius * math.sin(angle), radius * math.cos(angle))
    end
end

local function frame()
    if hud then
        return hud
    end
    hud = CreateFrame("Frame", "NavigateForeverHUD", UIParent)
    hud:SetFrameStrata("BACKGROUND")
    hud:SetFrameLevel(1)
    hud:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    hud:EnableMouse(false)
    hud:Hide()

    local r, g, b = 0.831, 0.686, 0.216
    if F.ThemeColor then
        local tr, tg, tb = F.ThemeColor("hover")
        if tr then
            r, g, b = tr, tg, tb
        end
    end

    hud.ring = {}
    for index = 1, RING_DOTS do
        local dot = hud:CreateTexture(nil, "OVERLAY")
        dot:SetTexture(DOT)
        dot:SetSize(2, 2)
        dot:SetVertexColor(r, g, b, 0.35)
        dot.angle = (index - 1) / RING_DOTS * math.pi * 2
        hud.ring[index] = dot
    end

    local marks = { { "N", 0 }, { "E", math.pi / 2 }, { "S", math.pi }, { "W", math.pi * 1.5 } }
    for _, mark in ipairs(marks) do
        local letter = hud:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        letter:SetText(mark[1])
        letter.bearing = mark[2]
        if mark[1] == "N" then
            letter:SetTextColor(1, 0.25, 0.2, 0.9)
        else
            letter:SetTextColor(r, g, b, 0.7)
        end
        letters[#letters + 1] = letter
    end

    local elapsed = 0
    hud:SetScript("OnUpdate", function(_, delta)
        elapsed = elapsed + delta
        if elapsed >= 0.03 then
            elapsed = 0
            placeLetters()
            -- The fade layout must not paint the ground back over the world.
            local map = Minimap
            if F.hudOn and map and map.GetAlpha and map:GetAlpha() > 0 then
                map:SetAlpha(0)
            end
        end
    end)
    return hud
end

local function sizeRing(size)
    local radius = size / 2
    for _, dot in ipairs(hud.ring) do
        dot:ClearAllPoints()
        dot:SetPoint("CENTER", hud, "CENTER", radius * math.sin(dot.angle), radius * math.cos(dot.angle))
    end
end

local function open()
    local map = Minimap
    if type(map) ~= "table" then
        return false, "The minimap was not found."
    end
    if F.IsHybrid and F.IsHybrid() then
        return false, "The gathering HUD can't open while the game uses its small indoor map."
    end
    local holder = frame()
    local points = {}
    for index = 1, map:GetNumPoints() do
        points[index] = { map:GetPoint(index) }
    end
    local width, height = map:GetSize()
    saved = {
        parent = map:GetParent(),
        points = points,
        width = width,
        height = height,
        scale = map:GetScale(),
        alpha = map:GetAlpha(),
        strata = map:GetFrameStrata(),
        level = map:GetFrameLevel(),
        zoom = map.GetZoom and map:GetZoom() or nil,
        mouse = map:IsMouseEnabled(),
        wheel = map.IsMouseWheelEnabled and map:IsMouseWheelEnabled() or nil,
        rotate = cvar("rotateMinimap"),
        clusterShown = MinimapCluster and MinimapCluster:IsShown(),
    }
    local size = math.floor((UIParent:GetHeight() or 768) * SCREEN_SHARE)
    F.hudOn = true
    holder:SetSize(size, size)
    sizeRing(size)
    holder:Show()
    pcall(map.SetParent, map, holder)
    map:ClearAllPoints()
    map:SetPoint("CENTER", holder, "CENTER", 0, 0)
    -- Resized, not scaled, so the game's icons keep their normal size.
    map:SetScale(1)
    map:SetSize(size, size)
    map:SetFrameStrata("BACKGROUND")
    -- Alpha 0 drops the ground drawing and leaves the tracking dots.
    -- A round mask keeps those dots in a circle instead of a big square.
    map:SetAlpha(0)
    pcall(map.SetMaskTexture, map, ROUND_MASK)
    map:EnableMouse(false)
    if map.EnableMouseWheel then
        map:EnableMouseWheel(false)
    end
    if map.SetZoom then
        pcall(map.SetZoom, map, 0)
    end
    -- Up on the HUD is the way you face, so a dot ahead is a node ahead.
    setCVar("rotateMinimap", "1")
    if MinimapCluster then
        MinimapCluster:Hide()
    end
    placeLetters()
    if F.LayoutNav then
        F.LayoutNav()
    end
    return true
end

local function close()
    local map = Minimap
    F.hudOn = false
    if hud then
        hud:Hide()
    end
    if type(map) ~= "table" or not saved then
        saved = nil
        return
    end
    if MinimapCluster and saved.clusterShown then
        MinimapCluster:Show()
    end
    if saved.parent then
        pcall(map.SetParent, map, saved.parent)
    end
    map:ClearAllPoints()
    for index = 1, #saved.points do
        local point = saved.points[index]
        if point[1] then
            pcall(map.SetPoint, map, point[1], point[2], point[3], point[4], point[5])
        end
    end
    if saved.width and saved.height then
        map:SetSize(saved.width, saved.height)
    end
    map:SetScale(saved.scale or 1)
    map:SetFrameStrata(saved.strata or "LOW")
    map:SetFrameLevel(saved.level or 1)
    -- WoW Forever can leave the ground blank after it was hidden, until
    -- the map is drawn again at full opacity.
    map:SetAlpha(1)
    pcall(map.SetMaskTexture, map, ROUND_MASK)
    pcall(map.SetMaskTexture, map, SQUARE_MASK)
    map:SetAlpha(saved.alpha or 1)
    map:EnableMouse(saved.mouse ~= false)
    if map.EnableMouseWheel and saved.wheel ~= nil then
        map:EnableMouseWheel(saved.wheel)
    end
    if map.SetZoom and saved.zoom then
        pcall(map.SetZoom, map, saved.zoom)
    end
    if saved.rotate ~= nil then
        setCVar("rotateMinimap", tostring(saved.rotate))
    end
    saved = nil
    if F.TryApply then
        F.TryApply()
    end
end

function F.ToggleHUD()
    if F.hudOn then
        close()
        F.Say("Gathering HUD closed.")
        return
    end
    local ok, why = open()
    if ok then
        F.Say("Gathering HUD open. Press the same key, or type /nf hud, to close it.")
    else
        F.Say(why or "The gathering HUD could not open.")
    end
end

function NavigateForever_ToggleHUD()
    F.ToggleHUD()
end

local watch = CreateFrame("Frame")
local function listen(event)
    if C_EventUtils and C_EventUtils.IsEventValid and not C_EventUtils.IsEventValid(event) then
        return
    end
    pcall(watch.RegisterEvent, watch, event)
end
listen("PLAYER_LOGOUT")
listen("PLAYER_ENTERING_WORLD")
watch:SetScript("OnEvent", function(_, event)
    if not F.hudOn then
        return
    end
    -- Put rotation back before logout so it isn't saved on.
    if event == "PLAYER_LOGOUT" or (F.IsHybrid and F.IsHybrid()) then
        close()
    end
end)
