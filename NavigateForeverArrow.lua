-- Waypoint arrow, built the way TomTom's modern crazy arrow works.
-- One sheet, 9 by 12, 108 pictures. The picture is
-- (direction to the pin - the way you face). No spinning of a single image.

local F = select(2, ...).F

local SHEET = "Interface\\AddOns\\NavigateForever\\Media\\arrow-nav"
local TEX_W, TEX_H = 2304, 3072
local CELL = 256
local COLS = 9
local ROWS = 12
local CELLS = COLS * ROWS
local TWOPI = math.pi * 2
local ARRIVE = 15
local FAR = 3000

local frame

-- TomTom core/utils.lua GetSpriteRotateTexCoordsResolver, padding 0.
local function NavCoords(angle)
    local cell = math.floor(angle / TWOPI * CELLS + 0.5) % CELLS
    local column = cell % COLS
    local row = math.floor(cell / COLS)
    local left = (column * CELL) / TEX_W
    local right = ((column + 1) * CELL) / TEX_W
    local top = (row * CELL) / TEX_H
    local bottom = ((row + 1) * CELL) / TEX_H
    return left, right, top, bottom
end

local function ShowCell(texture, angle)
    texture:SetTexCoord(NavCoords(angle))
end

-- TomTom takes GetDirectionToWaypoint() - GetPlayerFacing().
-- On this sheet a positive angle turns the picture clockwise, which put a pin
-- on the left over on the right. Subtracting the other way keeps the tip up
-- when the pin is straight ahead and swings it to the correct side.
local function TomTomAngle(mapID, x, y)
    local player = GetPlayerFacing()
    if type(player) ~= "number" then
        return nil
    end
    local hbd = F.HereBeDragons and F.HereBeDragons()
    if hbd and hbd.GetPlayerWorldPosition and hbd.GetWorldCoordinatesFromZone and hbd.GetWorldVector then
        local ok, angle, yards, other = pcall(function()
            local px, py, instance = hbd:GetPlayerWorldPosition()
            local tx, ty, targetInstance = hbd:GetWorldCoordinatesFromZone(x, y, mapID)
            if not (px and tx) then
                return nil
            end
            if instance and targetInstance and instance ~= targetInstance then
                return nil, nil, true
            end
            local world, dist = hbd:GetWorldVector(instance, px, py, tx, ty)
            if type(world) ~= "number" then
                return nil
            end
            return player - world, dist, false
        end)
        if ok and (type(angle) == "number" or other) then
            return angle, yards, other
        end
    end
    if not (F.PointOffset and F.Bearing) then
        return nil
    end
    local ok, state, _, _, dist, px, py, tx, ty = pcall(F.PointOffset, {
        map = mapID,
        zx = x,
        zy = y,
    })
    if not ok then
        return nil
    end
    if state == "other" then
        return nil, nil, true
    end
    if state ~= "ok" or type(px) ~= "number" or type(tx) ~= "number" then
        return nil
    end
    local world = F.Bearing(px, py, { x = tx, y = ty })
    if type(world) ~= "number" then
        return nil
    end
    return player - world, dist, false
end

local function saved()
    if F.DB then
        return F.DB()
    end
    return nil
end

function F.LayoutOwnArrow()
    if not frame then
        return
    end
    local db = saved()
    local scale = db and tonumber(db.arrowScale) or 1
    if scale < 0.05 then
        scale = 0.05
    elseif scale > 3 then
        scale = 3
    end
    frame:SetScale(scale)
end

function F.TintArrow()
    if frame and frame.arrow and F.ThemeColor then
        frame.arrow:SetVertexColor(F.ThemeColor("arrow"))
    end
end

function F.EnsureArrow()
    if frame then
        return frame
    end
    frame = CreateFrame("Button", "NavigateForeverArrow", UIParent)
    F.arrowFrame = frame
    frame:SetSize(200, 150)
    frame:SetFrameStrata("HIGH")
    frame:SetFrameLevel(80)
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local db = saved()
        if not db then
            return
        end
        local point, _, relPoint, x, y = self:GetPoint(1)
        db.arrowPoint = point
        db.arrowRel = relPoint
        db.arrowX = x
        db.arrowY = y
    end)

    local arrow = frame:CreateTexture(nil, "OVERLAY")
    arrow:SetTexture(SHEET)
    arrow:SetSize(80, 80)
    arrow:SetPoint("TOP", 0, 0)
    ShowCell(arrow, 0)
    frame.arrow = arrow
    F.TintArrow()

    local mark = frame:CreateTexture(nil, "OVERLAY")
    mark:SetTexture("Interface\\AddOns\\NavigateForever\\Media\\icon")
    mark:SetSize(48, 48)
    mark:SetPoint("TOP", 0, -16)
    mark:Hide()
    frame.mark = mark

    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    title:SetPoint("TOP", arrow, "BOTTOM", 0, -2)
    title:SetWidth(180)
    title:SetJustifyH("CENTER")
    title:SetWordWrap(true)
    title:SetTextColor(0.95, 0.93, 0.86)
    frame.title = title

    local status = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    status:SetPoint("TOP", title, "BOTTOM", 0, 0)
    status:SetJustifyH("CENTER")
    status:SetTextColor(1, 0.82, 0.2)
    frame.status = status

    frame:SetScript("OnUpdate", function(self)
        if self.instruction then
            return
        end
        if not (self.mapID and self.x and self.y) then
            return
        end
        local angle, yards, other = TomTomAngle(self.mapID, self.x, self.y)
        if other then
            self.status:SetText("Other map")
            return
        end
        if type(yards) == "number" and yards > FAR then
            self:Hide()
            return
        end
        if type(yards) == "number" then
            self.status:SetText(string.format("%d yards", math.floor(yards + 0.5)))
            if yards <= ARRIVE then
                ShowCell(self.arrow, math.pi)
                return
            end
        end
        if type(angle) == "number" then
            ShowCell(self.arrow, angle)
        end
    end)

    local db = saved()
    if db and db.arrowPoint and db.arrowRel and tonumber(db.arrowX) and tonumber(db.arrowY) then
        frame:SetPoint(db.arrowPoint, UIParent, db.arrowRel, db.arrowX, db.arrowY)
    else
        frame:SetPoint("CENTER", UIParent, "CENTER", 0, 140)
    end
    F.LayoutOwnArrow()
    frame:Hide()
    return frame
end

function F.HideOwnArrow()
    if frame then
        frame:Hide()
    end
end

function F.ShowOwnArrow(mapID, x, y, title)
    local widget = F.EnsureArrow()
    widget.mapID = mapID
    widget.x = x
    widget.y = y
    widget.instruction = not mapID
    widget.title:SetText(title or "")
    if widget.instruction then
        widget.arrow:Hide()
        widget.mark:Show()
        widget.status:SetText("")
    else
        widget.arrow:Show()
        widget.mark:Hide()
        widget.status:SetText("")
    end
    F.LayoutOwnArrow()
    if not widget.instruction then
        local _, yards = TomTomAngle(mapID, x, y)
        if type(yards) == "number" and yards > FAR then
            widget:Hide()
            return
        end
    end
    widget:Show()
end
