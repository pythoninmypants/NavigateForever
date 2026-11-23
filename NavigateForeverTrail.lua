-- Breadcrumb trail.
-- Faint dots on the minimap where you walked, newest brightest, so a cave or
-- a winding path can be walked back out. The game hides your position inside
-- dungeons and raids, so the trail rests there.

local F = select(2, ...).F

local STEP_YARDS = 4
local MAX_POINTS = 400
local DOT_SIZE = 4

local points = {}
local first = 1
local count = 0
local lastX, lastY, lastInstance
local layer
local dots = {}
local sample = 0
local paint = 0

local function plain(value)
    if F.Plain then
        return F.Plain(value)
    end
    return value
end

local function here()
    if not F.PlayerWorld then
        return nil
    end
    local x, y, instance = F.PlayerWorld()
    x, y, instance = plain(x), plain(y), plain(instance)
    if type(x) ~= "number" or type(y) ~= "number" then
        return nil
    end
    return x, y, instance
end

local function clear()
    points = {}
    first = 1
    count = 0
    lastX, lastY, lastInstance = nil, nil, nil
end

local function push(x, y, instance)
    local slot = first + count
    if count >= MAX_POINTS then
        points[first] = nil
        first = first + 1
        slot = first + count - 1
    else
        count = count + 1
    end
    points[slot] = { x = x, y = y, i = instance }
end

local function riding()
    if F.OnTaxi and F.OnTaxi() then
        return true
    end
    return F.BoatRiding and F.BoatRiding() or false
end

local function record()
    if not F.Enabled("trail") or riding() then
        return
    end
    local x, y, instance = here()
    if not x then
        return
    end
    if instance ~= lastInstance then
        clear()
    end
    if lastX then
        local dx, dy = x - lastX, y - lastY
        local moved = dx * dx + dy * dy
        if moved < STEP_YARDS * STEP_YARDS then
            return
        end
        -- A jump this big is a hearth, a portal, or a loading screen, not a walk.
        if moved > 200 * 200 then
            clear()
        end
    end
    lastX, lastY, lastInstance = x, y, instance
    push(x, y, instance)
end

local function hideFrom(index)
    for slot = index, #dots do
        if dots[slot]:IsShown() then
            dots[slot]:Hide()
        end
    end
end

local function draw()
    local frame = Minimap
    if type(frame) ~= "table" or not frame:IsShown() or not F.Enabled("trail") or (F.IsHybrid and F.IsHybrid()) then
        if layer then
            hideFrom(1)
        end
        return
    end
    if not layer then
        layer = CreateFrame("Frame", nil, frame)
        layer:SetAllPoints(frame)
        layer:SetFrameLevel((frame:GetFrameLevel() or 0) + 6)
        layer:EnableMouse(false)
        if layer.SetIgnoreParentAlpha then
            layer:SetIgnoreParentAlpha(true)
        end
    end
    local px, py, instance = here()
    if not px or count == 0 or not F.MapOffset or not F.RotateOffset then
        hideFrom(1)
        return
    end
    local r, g, b = 1, 0.92, 0.55
    if F.ThemeColor then
        local tr, tg, tb = F.ThemeColor("hover")
        if type(tr) == "number" then
            r, g, b = tr, tg, tb
        end
    end
    local used = 0
    local last = first + count - 1
    for slot = first, last do
        local point = points[slot]
        if point and point.i == instance then
            local dx, dy = F.RotateOffset(px - point.x, py - point.y)
            local sx, sy, halfW, halfH = F.MapOffset(dx, dy)
            if sx and math.abs(sx) <= halfW - 3 and math.abs(sy) <= halfH - 3 and (sx * sx + sy * sy) > 36 then
                used = used + 1
                local dot = dots[used]
                if not dot then
                    dot = layer:CreateTexture(nil, "OVERLAY")
                    dot:SetSize(DOT_SIZE, DOT_SIZE)
                    dots[used] = dot
                end
                local age = (last - slot) / MAX_POINTS
                dot:SetColorTexture(r, g, b, 0.85 - age * 0.6)
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

function F.TrailCommand(rest)
    if string.lower(rest or "") == "clear" then
        clear()
        draw()
        F.Say("Trail cleared.")
        return
    end
    F.Say("Trail: " .. (F.Enabled("trail") and "on" or "off") .. ", " .. count .. " steps. /nf trail clear wipes it.")
end

local watch = CreateFrame("Frame")
watch:SetScript("OnUpdate", function(_, elapsed)
    sample = sample + elapsed
    paint = paint + elapsed
    if sample >= 0.5 then
        sample = 0
        record()
    end
    if paint >= 0.1 then
        paint = 0
        draw()
    end
end)

if F.BuildRingsPage then
    local buildRings = F.BuildRingsPage
    function F.BuildRingsPage(page)
        page = buildRings(page)
        F.SectionLabel(page, "Travel", -186)
        local check = F.CreateCheck(page, "Breadcrumb trail", 14, -208, "trail")
        check:HookScript("OnClick", function(self)
            if not self:GetChecked() then
                clear()
            end
            draw()
        end)
        check:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText("Breadcrumb trail", F.BorderColor())
            GameTooltip:AddLine("Faint dots on the minimap where you walked, the newest brightest. Follow them back out of a cave or a winding path. It keeps about the last mile you walked, and starts over after a hearth, a portal, or a flight. The game hides your position in dungeons and raids, so there is no trail inside them. /nf trail clear wipes it.", 1, 1, 1, true)
            GameTooltip:Show()
        end)
        check:SetScript("OnLeave", GameTooltip_Hide)
        return page
    end
end
