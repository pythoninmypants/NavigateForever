-- A gold compass on your fishing bobber.
-- The game never tells an addon which bobber just moved, and every splash
-- uses the same sound. The compass stays still, so the splash is the part
-- that moves. Face the bobber: the game only draws it while you look at it.

local addonName = ...
local F = select(2, ...).F

local ICON = "Interface\\AddOns\\NavigateForever\\Media\\icon"
local BOBBER_ID = "35591"
local FISHING = {
    [7620] = true,
    [7731] = true,
    [7732] = true,
    [18248] = true,
    [33095] = true,
    [51294] = true,
    [62734] = true,
    [88868] = true,
    [110410] = true,
    [131474] = true,
    [131476] = true,
    [131490] = true,
}

-- The game draws a bobber only while you face it, and only with these on.
-- Each one is raised just for the cast, then put back. A value already high
-- enough is left alone, so another fishing addon can keep its own setting.
local PLATE = {
    SoftTargetInteract = "3",
    SoftTargetNameplateInteract = "1",
    SoftTargetInteractRange = "30",
    SoftTargetInteractArc = "2",
}

local fishing = false
local mine
local previous
local before
local sawChannel = false
local held
local fishingName
local warned = false
local restoreAt
local watch

local marker = CreateFrame("Frame", nil, UIParent)
marker:SetSize(26, 26)
marker:SetFrameStrata("HIGH")
marker:EnableMouse(false)
if marker.SetMouseClickEnabled then
    pcall(marker.SetMouseClickEnabled, marker, false)
end
if marker.SetMouseMotionEnabled then
    pcall(marker.SetMouseMotionEnabled, marker, false)
end
local icon = marker:CreateTexture(nil, "ARTWORK")
icon:SetAllPoints()
icon:SetTexture(ICON)
marker:Hide()

local function plain(value)
    if F.Plain then
        return F.Plain(value)
    end
    return value
end

local function saved()
    if type(NavigateForeverDB) ~= "table" then
        return nil
    end
    if type(NavigateForeverDB.bobberSaved) ~= "table" then
        NavigateForeverDB.bobberSaved = {}
    end
    return NavigateForeverDB.bobberSaved
end

local function readCVar(name)
    if C_CVar and C_CVar.GetCVar then
        local ok, value = pcall(C_CVar.GetCVar, name)
        value = ok and plain(value)
        if type(value) == "string" or type(value) == "number" then
            return tostring(value)
        end
    end
    if GetCVar then
        local ok, value = pcall(GetCVar, name)
        value = ok and plain(value)
        if type(value) == "string" or type(value) == "number" then
            return tostring(value)
        end
    end
    return nil
end

local function writeCVar(name, value)
    if C_CVar and C_CVar.SetCVar then
        if pcall(C_CVar.SetCVar, name, value) then
            return true
        end
    end
    if SetCVar then
        return pcall(SetCVar, name, value)
    end
    return false
end

local function same(a, b)
    local left, right = tonumber(a), tonumber(b)
    if left and right then
        return left == right
    end
    return a == b
end

local function enough(current, want)
    local left, right = tonumber(current), tonumber(want)
    if left and right then
        return left >= right
    end
    return current == want
end

local function spellName(spellID)
    if not (C_Spell and C_Spell.GetSpellName) then
        return nil
    end
    local ok, name = pcall(C_Spell.GetSpellName, spellID)
    name = ok and plain(name)
    if type(name) == "string" and name ~= "" then
        return name
    end
    return nil
end

local function isFishingSpell(spellID)
    spellID = tonumber(plain(spellID))
    if spellID and FISHING[spellID] then
        return true
    end
    if not fishingName then
        fishingName = spellName(7620)
    end
    if fishingName and spellID then
        return spellName(spellID) == fishingName
    end
    return false
end

local function channelFishing()
    if not UnitChannelInfo then
        return false
    end
    local ok, name, _, _, _, _, _, _, spellID = pcall(UnitChannelInfo, "player")
    if not ok then
        return false
    end
    if isFishingSpell(spellID) then
        return true
    end
    name = plain(name)
    if not fishingName then
        fishingName = spellName(7620)
    end
    return type(name) == "string" and fishingName ~= nil and name == fishingName
end

local function eventFishing(...)
    for index = 1, select("#", ...) do
        if isFishingSpell(select(index, ...)) then
            return true
        end
    end
    return false
end

local function unitGUID(unit)
    if not UnitGUID then
        return nil
    end
    local ok, guid = pcall(UnitGUID, unit)
    guid = ok and plain(guid)
    if type(guid) == "string" and guid ~= "" then
        return guid
    end
    return nil
end

local function unitName(unit)
    if not UnitName then
        return nil
    end
    local ok, name = pcall(UnitName, unit)
    name = ok and plain(name)
    if type(name) == "string" and name ~= "" then
        return name
    end
    return nil
end

local function isBobber(guid)
    if type(guid) ~= "string" then
        return false
    end
    local kind, _, _, _, _, id = strsplit("-", guid)
    if kind ~= "GameObject" then
        return false
    end
    if id == BOBBER_ID then
        return true
    end
    if unitGUID("softinteract") ~= guid then
        return false
    end
    local name = unitName("softinteract")
    if not name then
        return true
    end
    return string.find(string.lower(name), "bobber", 1, true) ~= nil
end

local function plateToken(plate)
    if type(plate) ~= "table" then
        return nil
    end
    local token = plain(plate.namePlateUnitToken)
    if type(token) ~= "string" and plate.UnitFrame then
        token = plain(plate.UnitFrame.unit)
    end
    if type(token) ~= "string" then
        token = plain(plate.unit)
    end
    if type(token) == "string" then
        return token
    end
    return nil
end

local function forbidden(plate)
    if type(plate) ~= "table" or not plate.IsForbidden then
        return false
    end
    local ok, value = pcall(plate.IsForbidden, plate)
    return ok and plain(value) and true or false
end

local function plateFor(guid)
    if not (C_NamePlate and C_NamePlate.GetNamePlateForUnit) then
        return nil
    end
    if unitGUID("softinteract") == guid then
        local ok, plate = pcall(C_NamePlate.GetNamePlateForUnit, "softinteract")
        if ok and type(plate) == "table" and not forbidden(plate) then
            return plate
        end
    end
    if not C_NamePlate.GetNamePlates then
        return nil
    end
    local ok, plates = pcall(C_NamePlate.GetNamePlates, false)
    if not ok or type(plates) ~= "table" then
        return nil
    end
    for index = 1, #plates do
        local plate = plates[index]
        local token = plateToken(plate)
        if token and unitGUID(token) == guid and not forbidden(plate) then
            return plate
        end
    end
    return nil
end

-- The first new bobber after this cast is yours. The one you were already
-- looking at, and the one from the cast before, belong to someone else.
local function claim(guid)
    if not isBobber(guid) then
        return nil
    end
    if not mine then
        if guid == before or guid == previous then
            return nil
        end
        mine = guid
    elseif guid ~= mine then
        return nil
    end
    return guid
end

local function hideMark()
    held = nil
    marker:Hide()
    if marker:GetParent() ~= UIParent then
        marker:SetParent(UIParent)
    end
end

local function showMark(plate)
    if held == plate and marker:IsShown() then
        return
    end
    local ok, err = pcall(function()
        marker:SetParent(plate)
        marker:ClearAllPoints()
        marker:SetPoint("CENTER", plate, "CENTER", 0, 18)
        local levelOK, level = pcall(plate.GetFrameLevel, plate)
        level = levelOK and plain(level)
        if type(level) == "number" then
            marker:SetFrameLevel(level + 20)
        end
        held = plate
        marker:Show()
    end)
    if not ok and not warned then
        warned = true
        hideMark()
        F.Say("The bobber mark could not be drawn. " .. tostring(err))
    end
end

local function refresh()
    if not fishing or not F.Enabled("bobberMark") then
        hideMark()
        return
    end
    local guid = claim(unitGUID("softinteract"))
    local plate = guid and plateFor(guid)
    if not plate then
        hideMark()
        return
    end
    showMark(plate)
end

local function applyPlates()
    if not fishing or not F.Enabled("bobberMark") then
        return
    end
    local store = saved()
    if not store then
        return
    end
    for name, want in pairs(PLATE) do
        local current = readCVar(name)
        if current ~= nil and not enough(current, want) and writeCVar(name, want) then
            if store[name] == nil then
                store[name] = current
            end
        end
    end
end

local function restorePlates()
    if type(NavigateForeverDB) ~= "table" then
        return
    end
    local store = NavigateForeverDB.bobberSaved
    if type(store) ~= "table" then
        return
    end
    for name, old in pairs(store) do
        local want = PLATE[name] or "1"
        if same(readCVar(name), want) then
            writeCVar(name, old)
        end
    end
    NavigateForeverDB.bobberSaved = nil
end

local function arm()
    if watch then
        watch:Show()
    end
end

local function disarm()
    if watch then
        watch:Hide()
    end
end

function F.BobberClear()
    fishing = false
    mine = nil
    sawChannel = false
    restoreAt = nil
    hideMark()
    disarm()
    restorePlates()
end

local function beginCast()
    if not F.Enabled("bobberMark") then
        return
    end
    previous = mine or previous
    mine = nil
    before = unitGUID("softinteract")
    fishing = true
    sawChannel = false
    restoreAt = nil
    applyPlates()
    arm()
    refresh()
end

local function finishCast()
    if not fishing then
        return
    end
    previous = mine or previous
    mine = nil
    fishing = false
    hideMark()
    -- A few seconds covers the gap before the next cast.
    restoreAt = (GetTime and GetTime() or 0) + 4
    arm()
end

function F.BobberSync()
    if not F.Enabled("bobberMark") then
        F.BobberClear()
        return
    end
    if channelFishing() then
        if not fishing then
            beginCast()
        else
            applyPlates()
            refresh()
        end
        return
    end
    if type(NavigateForeverDB) == "table" and NavigateForeverDB.bobberSaved then
        restorePlates()
    end
end

local function onEvent(self, event, ...)
    if event == "ADDON_LOADED" then
        if ... == addonName then
            F.BobberSync()
        end
        return
    end
    if event == "PLAYER_LOGOUT" then
        F.BobberClear()
        return
    end
    if event == "PLAYER_LOGIN" or event == "PLAYER_ENTERING_WORLD" then
        F.BobberSync()
        return
    end
    if not F.Enabled("bobberMark") then
        return
    end
    local unit = ...
    if event == "UNIT_SPELLCAST_CHANNEL_START" then
        if unit == "player" and eventFishing(...) then
            beginCast()
        end
        return
    end
    if event == "UNIT_SPELLCAST_START" then
        if unit == "player" and not fishing and eventFishing(...) then
            beginCast()
        end
        return
    end
    if unit == "player" and fishing then
        if event == "UNIT_SPELLCAST_CHANNEL_STOP" then
            finishCast()
            return
        end
        -- A failed cast of something else shares these events. Only end the
        -- line when that cast was Fishing and the channel is already gone.
        if (event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_INTERRUPTED" or event == "UNIT_SPELLCAST_FAILED") and eventFishing(...) and not channelFishing() then
            finishCast()
            return
        end
    end
    if fishing then
        applyPlates()
        refresh()
    end
end

watch = CreateFrame("Frame")
watch:Hide()
watch:SetScript("OnEvent", onEvent)
watch:SetScript("OnUpdate", function(_, elapsed)
    watch.t = (watch.t or 0) + elapsed
    if watch.t < 0.2 then
        return
    end
    watch.t = 0
    if fishing then
        applyPlates()
        refresh()
        -- Once the channel has been seen, it going away means the line came in.
        if channelFishing() then
            sawChannel = true
        elseif sawChannel then
            finishCast()
        end
        return
    end
    if restoreAt and GetTime and GetTime() >= restoreAt then
        local now = GetTime()
        -- A stale channel report can outlive the cast. Don't leave the
        -- bobber settings changed if the line has been in for a while.
        if not channelFishing() or now >= restoreAt + 8 then
            restoreAt = nil
            restorePlates()
            disarm()
        end
    end
end)

local function listen(event)
    if C_EventUtils and C_EventUtils.IsEventValid and not C_EventUtils.IsEventValid(event) then
        return
    end
    pcall(watch.RegisterEvent, watch, event)
end

listen("ADDON_LOADED")
listen("PLAYER_LOGIN")
listen("PLAYER_ENTERING_WORLD")
listen("PLAYER_LOGOUT")
listen("UNIT_SPELLCAST_CHANNEL_START")
listen("UNIT_SPELLCAST_CHANNEL_STOP")
listen("UNIT_SPELLCAST_START")
listen("UNIT_SPELLCAST_STOP")
listen("UNIT_SPELLCAST_INTERRUPTED")
listen("UNIT_SPELLCAST_FAILED")
listen("PLAYER_SOFT_INTERACT_CHANGED")
listen("NAME_PLATE_UNIT_ADDED")
listen("NAME_PLATE_UNIT_REMOVED")

if F.BuildMapPage then
    local buildMap = F.BuildMapPage
    function F.BuildMapPage(page)
        page = buildMap(page)
        local check = F.CreateCheck(page, "Your bobber", 240, -246, "bobberMark")
        check:HookScript("OnClick", function(self)
            if self:GetChecked() then
                F.Say("Your bobber gets a gold compass while you fish. Face it to see the mark.")
                F.BobberSync()
            else
                F.Say("Bobber mark off.")
                F.BobberClear()
            end
        end)
        check:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText("Your bobber", F.BorderColor())
            GameTooltip:AddLine("A gold compass on your fishing bobber, so you can tell it from the ones around you. Face the bobber. The game only draws it while you look at it, and the compass stays still, so the splash is the part that moves. While the line is out, the game is allowed to show that bobber. That goes back a few seconds after you stop. Uncheck this to turn the compass off.", 1, 1, 1, true)
            GameTooltip:Show()
        end)
        check:SetScript("OnLeave", GameTooltip_Hide)
        return page
    end
end
