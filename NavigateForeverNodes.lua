-- Remembered herbs and ore.
-- Each herb you pick and each vein you mine is saved where you stood, and
-- shows on the minimap later as a faint dot, even while tracking is on the
-- other kind. Saved for the whole account, so every character shares them.

local F = select(2, ...).F

local HERB_SPELLS = { [2366] = true, [2368] = true, [3570] = true, [11993] = true }
local ORE_SPELLS = { [2575] = true, [2576] = true, [3564] = true, [10248] = true }
local HERB_COLOR = { 0.42, 0.95, 0.48 }
local ORE_COLOR = { 1, 0.80, 0.30 }
local SAME_YARDS = 15
local DOT_SIZE = 8
local MAX_DOTS = 120

local herbName, oreName
local pending = {}
local dots = {}
local layer
local tick = 0

local function plain(value)
    if F.Plain then
        return F.Plain(value)
    end
    return value
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

local function kindOf(spellID)
    spellID = tonumber(plain(spellID))
    if not spellID then
        return nil
    end
    if HERB_SPELLS[spellID] then
        return "herb"
    end
    if ORE_SPELLS[spellID] then
        return "ore"
    end
    herbName = herbName or spellName(2366)
    oreName = oreName or spellName(2575)
    local name = spellName(spellID)
    if name and name == herbName then
        return "herb"
    end
    if name and name == oreName then
        return "ore"
    end
    return nil
end

local function store()
    if type(NavigateForeverDB) ~= "table" then
        return nil
    end
    if type(NavigateForeverDB.nodes) ~= "table" then
        NavigateForeverDB.nodes = {}
    end
    return NavigateForeverDB.nodes
end

local function here()
    if not F.PlayerWorld then
        return nil
    end
    local x, y, instance = F.PlayerWorld()
    x, y, instance = plain(x), plain(y), tonumber(plain(instance))
    if type(x) ~= "number" or type(y) ~= "number" or not instance then
        return nil
    end
    return x, y, instance
end

local function remember(kind, name)
    local nodes = store()
    local x, y, instance = here()
    if not nodes or not x then
        return
    end
    local list = nodes[instance]
    if type(list) ~= "table" then
        list = {}
        nodes[instance] = list
    end
    for index = 1, #list do
        local node = list[index]
        if node.k == kind then
            local dx, dy = node.x - x, node.y - y
            if dx * dx + dy * dy <= SAME_YARDS * SAME_YARDS then
                node.c = (tonumber(node.c) or 1) + 1
                if name then
                    node.n = name
                end
                return
            end
        end
    end
    list[#list + 1] = { x = x, y = y, k = kind, n = name, c = 1 }
end

-- With the profession on this character, show its kind. An alt without
-- either still sees both, since it can't be told which one it wants.
local function wants(kind)
    if not F.GatherSpellKnown then
        return true
    end
    local herbs = F.GatherSpellKnown(2383)
    local ore = F.GatherSpellKnown(2580)
    if herbs == nil and ore == nil then
        return true
    end
    if not herbs and not ore then
        return true
    end
    if kind == "herb" then
        return herbs and true or false
    end
    return ore and true or false
end

local function newDot()
    local dot = CreateFrame("Frame", nil, layer)
    dot:SetSize(DOT_SIZE + 6, DOT_SIZE + 6)
    if dot.SetMouseClickEnabled then
        pcall(dot.SetMouseClickEnabled, dot, false)
    end
    if dot.SetMouseMotionEnabled then
        pcall(dot.SetMouseMotionEnabled, dot, true)
    else
        dot:EnableMouse(false)
    end
    local ring = dot:CreateTexture(nil, "ARTWORK")
    ring:SetTexture("Interface\\Cooldown\\Ping4")
    ring:SetBlendMode("ADD")
    ring:SetPoint("CENTER")
    ring:SetSize(DOT_SIZE + 6, DOT_SIZE + 6)
    dot.nfRing = ring
    local core = dot:CreateTexture(nil, "OVERLAY")
    core:SetPoint("CENTER")
    core:SetSize(DOT_SIZE - 3, DOT_SIZE - 3)
    dot.nfCore = core
    dot:SetScript("OnEnter", function(self)
        local node = self.nfNode
        if not node then
            return
        end
        local color = node.k == "herb" and HERB_COLOR or ORE_COLOR
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(node.n or (node.k == "herb" and "Herb" or "Ore"), color[1], color[2], color[3])
        local times = tonumber(node.c) or 1
        local verb = node.k == "herb" and "Picked" or "Mined"
        GameTooltip:AddLine(verb .. " here " .. (times == 1 and "once" or (times .. " times")) .. ".", 1, 1, 1, true)
        GameTooltip:Show()
    end)
    dot:SetScript("OnLeave", GameTooltip_Hide)
    dot:Hide()
    return dot
end

local function hideFrom(first)
    for index = first, #dots do
        local dot = dots[index]
        if dot:IsShown() then
            dot:Hide()
        end
        dot.nfNode = nil
    end
end

local function minimap()
    local frame = Minimap
    if type(frame) ~= "table" or not frame.IsShown or not frame:IsShown() then
        return nil
    end
    return frame
end

local function draw()
    local frame = minimap()
    if not frame or not F.Enabled("rememberNodes") or (F.IsHybrid and F.IsHybrid()) then
        if layer then
            hideFrom(1)
        end
        return
    end
    if not layer then
        layer = CreateFrame("Frame", nil, frame)
        layer:SetAllPoints(frame)
        layer:SetFrameLevel((frame:GetFrameLevel() or 0) + 8)
        layer:EnableMouse(false)
        if layer.SetIgnoreParentAlpha then
            layer:SetIgnoreParentAlpha(true)
        end
    end
    local nodes = store()
    local px, py, instance = here()
    local list = nodes and instance and nodes[instance]
    if type(list) ~= "table" or not F.MapOffset or not F.RotateOffset then
        hideFrom(1)
        return
    end
    local radius = F.ViewRadius and F.ViewRadius() or 0
    local used = 0
    for index = 1, #list do
        if used >= MAX_DOTS then
            break
        end
        local node = list[index]
        local dx, dy = px - node.x, py - node.y
        if radius <= 0 or (math.abs(dx) <= radius * 1.5 and math.abs(dy) <= radius * 1.5) then
            dx, dy = F.RotateOffset(dx, dy)
            local sx, sy, halfW, halfH = F.MapOffset(dx, dy)
            if sx and math.abs(sx) <= halfW - 4 and math.abs(sy) <= halfH - 4 and wants(node.k) then
                used = used + 1
                local dot = dots[used]
                if not dot then
                    dot = newDot()
                    dots[used] = dot
                end
                local color = node.k == "herb" and HERB_COLOR or ORE_COLOR
                if dot.nfKind ~= node.k then
                    dot.nfKind = node.k
                    dot.nfRing:SetVertexColor(color[1], color[2], color[3], 0.55)
                    dot.nfCore:SetColorTexture(color[1], color[2], color[3], 0.75)
                end
                dot.nfNode = node
                dot:ClearAllPoints()
                dot:SetPoint("CENTER", layer, "CENTER", sx, sy)
                if not dot:IsShown() then
                    dot:Show()
                end
            end
        end
    end
    hideFrom(used + 1)
end

function F.NodesRefresh()
    draw()
end

function F.NodesReport(rest)
    local nodes = store()
    local _, _, instance = here()
    local list = nodes and instance and nodes[instance]
    if string.lower(rest or "") == "clear" then
        if nodes and instance then
            nodes[instance] = nil
        end
        draw()
        F.Say("Forgot the herbs and ore saved on this continent.")
        return
    end
    local herbs, ore = 0, 0
    if type(list) == "table" then
        for index = 1, #list do
            if list[index].k == "herb" then
                herbs = herbs + 1
            else
                ore = ore + 1
            end
        end
    end
    F.Say("Saved on this continent: " .. herbs .. " herbs and " .. ore .. " ore. /nf nodes clear forgets them.")
end

local watch = CreateFrame("Frame")
watch:SetScript("OnEvent", function(_, event, unit, a2, a3, a4)
    if unit ~= "player" or not F.Enabled("rememberNodes") then
        return
    end
    if event == "UNIT_SPELLCAST_SENT" then
        -- unit, target name, cast GUID, spell
        local kind = kindOf(a4)
        local guid = plain(a3)
        if kind and type(guid) == "string" then
            local target = plain(a2)
            pending[guid] = { kind = kind, name = type(target) == "string" and target ~= "" and target or nil }
        end
        return
    end
    -- UNIT_SPELLCAST_SUCCEEDED: unit, cast GUID, spell
    local guid = plain(a2)
    local sent = type(guid) == "string" and pending[guid]
    if type(guid) == "string" then
        pending[guid] = nil
    end
    local kind = (sent and sent.kind) or kindOf(a3)
    if kind then
        remember(kind, sent and sent.name)
        draw()
    end
end)
watch:SetScript("OnUpdate", function(_, elapsed)
    tick = tick + elapsed
    if tick < 0.1 then
        return
    end
    tick = 0
    draw()
end)

local function listen(event)
    if C_EventUtils and C_EventUtils.IsEventValid and not C_EventUtils.IsEventValid(event) then
        return
    end
    pcall(watch.RegisterUnitEvent or watch.RegisterEvent, watch, event, "player")
end
listen("UNIT_SPELLCAST_SENT")
listen("UNIT_SPELLCAST_SUCCEEDED")

if F.BuildMorePage then
    local buildMore = F.BuildMorePage
    function F.BuildMorePage(page)
        page = buildMore(page)
        local check = F.CreateCheck(page, "Remember herbs and ore", 14, -290, "rememberNodes")
        check:HookScript("OnClick", draw)
        check:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText("Remember herbs and ore", F.BorderColor())
            GameTooltip:AddLine("Each herb you pick and each vein you mine is saved. Later it shows on the minimap as a faint dot, green for a herb and gold for ore, even while tracking is on the other kind. Rest the cursor on a dot for its name. Every character on this account shares them. /nf nodes clear forgets the ones on this continent.", 1, 1, 1, true)
            GameTooltip:Show()
        end)
        check:SetScript("OnLeave", GameTooltip_Hide)
        return page
    end
end
