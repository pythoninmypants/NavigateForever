-- Boat and zeppelin times.
-- The game never tells an addon where a ship is. A ride shows up another way:
-- your position keeps changing while you stand still, near a town a boat or
-- zeppelin serves. Each ride saves its pier, how long the trip took, and when
-- it left. Three departures from one pier give the time between ships, and
-- then the bar counts down to the next one while you wait there.

local F = select(2, ...).F

local SAMPLE = 0.25
local DRIFT_SPEED = 2.5
local STILL_SPEED = 0.4
local CONFIRM_SECONDS = 6
local CONFIRM_YARDS = 20
local STOP_SECONDS = 8
local DOCK_YARDS = 40
local NEAR_DOCK = 45
local FIT_TOLERANCE = 6
local RECENT = 6 * 3600
local NEEDED = 3

local prevX, prevY, prevI, prevT
local drift
local ride
local tick = 0

local function plain(value)
    if F.Plain then
        return F.Plain(value)
    end
    return value
end

local function now()
    return GetTime and GetTime() or 0
end

local function serverNow()
    if GetServerTime then
        local ok, value = pcall(GetServerTime)
        value = ok and tonumber(plain(value))
        if value then
            return value
        end
    end
    return time and time() or 0
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

local function docks()
    if type(NavigateForeverDB) ~= "table" then
        return nil
    end
    if type(NavigateForeverDB.docks) ~= "table" then
        NavigateForeverDB.docks = {}
    end
    return NavigateForeverDB.docks
end

local function clock(seconds)
    seconds = math.max(0, math.floor(seconds + 0.5))
    return string.format("%d:%02d", math.floor(seconds / 60), seconds % 60)
end

local function flag(fn, unit)
    if not fn then
        return false
    end
    local ok, value = pcall(fn, unit)
    return ok and plain(value) and true or false
end

local function selfMoving()
    if F.PlayerIsMoving and F.PlayerIsMoving() then
        return true
    end
    return flag(IsFalling, "player") or flag(IsFlying, "player")
end

local function busy()
    if F.OnTaxi and F.OnTaxi() then
        return true
    end
    if flag(UnitAffectingCombat, "player") then
        return true
    end
    return flag(UnitIsDeadOrGhost, "player")
end

-- The town at one end of a boat or zeppelin link, nearest to where you are.
local function nearestEnd(limitTo)
    local links = F.TRANSPORT_LINKS
    if type(links) ~= "table" or not F.Here or not F.PlaceByName or not F.Locate or not F.YardsBetween then
        return nil
    end
    local spot = F.Here()
    if not spot then
        return nil
    end
    local best, bestYards, bestKind, bestLink
    for index = 1, #links do
        local link = links[index]
        for side = 1, 2 do
            local name = link[side]
            if not limitTo or limitTo == link[3 - side] then
                local place = F.PlaceByName(name)
                if place and F.Locate(place) then
                    local yards = F.YardsBetween(spot, place)
                    local reach = link[3] == "zep" and 700 or 400
                    if limitTo then
                        reach = math.huge
                    end
                    if yards and yards <= reach and (not bestYards or yards < bestYards) then
                        best, bestYards, bestKind, bestLink = place.name, yards, link[3], link
                    end
                end
            end
        end
    end
    return best, bestKind, bestLink
end

-- Orgrimmar's and Undercity's towers send zeppelins two ways from platforms
-- a few yards apart, so a pier is its spot and where it goes.
local function dockAt(x, y, instance, to)
    local list = docks()
    if not list then
        return nil
    end
    local best, bestYards
    for index = 1, #list do
        local dock = list[index]
        if dock.i == instance and (not to or dock.to == to) then
            local dx, dy = dock.x - x, dock.y - y
            local yards = math.sqrt(dx * dx + dy * dy)
            if yards <= DOCK_YARDS and (not bestYards or yards < bestYards) then
                best, bestYards = dock, yards
            end
        end
    end
    return best, bestYards
end

local function fits(times, period, base)
    for index = 1, #times do
        local offset = (times[index] - base) % period
        if math.min(offset, period - offset) > FIT_TOLERANCE then
            return false
        end
    end
    return true
end

-- Every departure since a restart is a whole number of trips apart. Look for
-- the one gap between ships, no shorter than a round trip, that fits them all.
local function solve(dock)
    local ride = tonumber(dock.ride)
    if not ride or type(dock.deps) ~= "table" then
        return
    end
    local latest = dock.deps[#dock.deps]
    local recent = {}
    for index = 1, #dock.deps do
        if latest - dock.deps[index] <= RECENT then
            recent[#recent + 1] = dock.deps[index]
        end
    end
    if #recent < NEEDED then
        return
    end
    local low = math.max(60, ride * 1.8)
    local high = ride * 2 + 300
    local groups = {}
    local open
    local period = low
    while period <= high do
        if fits(recent, period, latest) then
            if open and period - open.last <= 0.5 then
                open.last = period
            else
                open = { first = period, last = period }
                groups[#groups + 1] = open
            end
        end
        period = period + 0.25
    end
    if #groups == 1 then
        dock.period = (groups[1].first + groups[1].last) / 2
    end
end

local function finishRide(stoppedAt)
    local done = ride
    ride = nil
    drift = nil
    if not done then
        return
    end
    local seconds = stoppedAt - done.startT
    if seconds < 20 then
        return
    end
    local list = docks()
    if not list then
        return
    end
    local to = done.from and nearestEnd(done.from)
    if not to and done.link and done.from then
        to = done.link[1] == done.from and done.link[2] or done.link[1]
    end
    local dock = dockAt(done.startX, done.startY, done.startI, to)
    if not dock then
        dock = { x = done.startX, y = done.startY, i = done.startI, deps = {}, to = to }
        list[#list + 1] = dock
    end
    dock.from = done.from or dock.from
    dock.kind = done.kind or dock.kind
    local old = tonumber(dock.ride)
    dock.ride = old and (old * 0.6 + seconds * 0.4) or seconds
    if type(dock.deps) ~= "table" then
        dock.deps = {}
    end
    local left = serverNow() - (now() - done.startT)
    dock.deps[#dock.deps + 1] = left
    while #dock.deps > 12 do
        table.remove(dock.deps, 1)
    end
    dock.phase = left
    solve(dock)
    if F.Enabled("boatTimes") then
        local word = dock.kind == "zep" and "Zeppelin" or "Boat"
        if dock.period then
            F.Say(word .. " to " .. (dock.to or "the other dock") .. " took " .. clock(seconds) .. ". Ships leave " .. (dock.from or "that dock") .. " every " .. clock(dock.period) .. ".")
        else
            local seen = 0
            for index = 1, #dock.deps do
                if dock.deps[#dock.deps] - dock.deps[index] <= RECENT then
                    seen = seen + 1
                end
            end
            F.Say(word .. " to " .. (dock.to or "the other dock") .. " took " .. clock(seconds) .. ". Learning when it leaves, ride " .. math.min(seen, NEEDED) .. " of " .. NEEDED .. ".")
        end
    end
end

local function step()
    local t = now()
    local x, y, instance = here()
    if not x then
        prevX = nil
        if not ride then
            drift = nil
        end
        return
    end
    local speed
    if prevX and prevI == instance and t > prevT then
        local dx, dy = x - prevX, y - prevY
        speed = math.sqrt(dx * dx + dy * dy) / (t - prevT)
    end
    local moving = selfMoving()
    prevX, prevY, prevI, prevT = x, y, instance, t
    if ride then
        -- The ship stopping marks the arrival. Walking off afterward doesn't
        -- move that time; only the ship pulling away again cancels it.
        if speed and not moving then
            if speed < STILL_SPEED then
                ride.stillT = ride.stillT or t
            elseif speed > DRIFT_SPEED then
                ride.stillT = nil
            end
        end
        if ride.stillT and t - ride.stillT >= STOP_SECONDS then
            finishRide(ride.stillT)
        elseif t - ride.startT > 900 then
            ride = nil
        end
        return
    end
    if not F.Enabled("boatTimes") or busy() then
        drift = nil
        return
    end
    if speed and not moving and speed > DRIFT_SPEED then
        if not drift then
            drift = { x = x, y = y, i = instance, t = t - SAMPLE }
        end
        drift.last = t
    elseif drift and t - (drift.last or t) > 1 then
        drift = nil
    end
    if drift and drift.i == instance and t - drift.t >= CONFIRM_SECONDS then
        local dx, dy = x - drift.x, y - drift.y
        if dx * dx + dy * dy >= CONFIRM_YARDS * CONFIRM_YARDS then
            local from, kind, link = nearestEnd()
            if from then
                ride = { startX = drift.x, startY = drift.y, startI = drift.i, startT = drift.t, from = from, kind = kind, link = link }
            end
            drift = nil
        end
    end
end

function F.BoatRiding()
    return ride ~= nil
end

function F.BoatLine()
    if not F.Enabled("boatTimes") then
        return nil
    end
    if ride then
        local dock = dockAt(ride.startX, ride.startY, ride.startI)
        local word = ride.kind == "zep" and "Zeppelin" or "Boat"
        local to = dock and dock.to
        local left = dock and tonumber(dock.ride) and (dock.ride - (now() - ride.startT))
        if left and left > 0 then
            return word .. (to and (" to " .. to) or "") .. "   about " .. clock(left)
        end
        return "On the " .. string.lower(word) .. (to and (" to " .. to) or "")
    end
    local x, y, instance = here()
    local list = docks()
    if not x or not list then
        return nil
    end
    -- Two piers side by side: show whichever ship leaves first.
    local soonest, soonestWait, learning
    local clockNow = serverNow()
    for index = 1, #list do
        local dock = list[index]
        if dock.i == instance then
            local dx, dy = dock.x - x, dock.y - y
            if dx * dx + dy * dy <= NEAR_DOCK * NEAR_DOCK then
                local period, phase = tonumber(dock.period), tonumber(dock.phase)
                if period and phase then
                    local wait = (phase - clockNow) % period
                    if wait > period - 15 then
                        wait = 0
                    end
                    if not soonestWait or wait < soonestWait then
                        soonest, soonestWait = dock, wait
                    end
                else
                    learning = learning or dock
                end
            end
        end
    end
    local dock = soonest or learning
    if not dock then
        return nil
    end
    local word = dock.kind == "zep" and "Zeppelin" or "Boat"
    local to = dock.to and (" to " .. dock.to) or ""
    if soonest then
        if soonestWait == 0 then
            return word .. to .. "   leaving now"
        end
        return word .. to .. "   leaves in " .. clock(soonestWait)
    end
    return word .. to .. "   learning when it leaves"
end

function F.BoatReport(rest)
    local list = docks() or {}
    if string.lower(rest or "") == "clear" then
        if type(NavigateForeverDB) == "table" then
            NavigateForeverDB.docks = {}
        end
        F.Say("Forgot every boat and zeppelin time.")
        return
    end
    if #list == 0 then
        F.Say("No boat or zeppelin learned yet. Ride one and stand still on deck as it leaves.")
        return
    end
    for index = 1, #list do
        local dock = list[index]
        local word = dock.kind == "zep" and "Zeppelin" or "Boat"
        local line = word .. " from " .. (dock.from or "?") .. " to " .. (dock.to or "?")
        if tonumber(dock.ride) then
            line = line .. ": ride " .. clock(dock.ride)
        end
        if tonumber(dock.period) then
            line = line .. ", one every " .. clock(dock.period)
        else
            line = line .. ", still learning when it leaves"
        end
        F.Say(line .. ".")
    end
end

if F.FlightRoute then
    local flightRoute = F.FlightRoute
    function F.FlightRoute(...)
        local line = flightRoute(...)
        if line then
            return line
        end
        local ok, boat = pcall(F.BoatLine)
        if ok then
            return boat
        end
        return nil
    end
end

local watch = CreateFrame("Frame")
watch:SetScript("OnUpdate", function(_, elapsed)
    tick = tick + elapsed
    if tick < SAMPLE then
        return
    end
    tick = 0
    step()
end)

if F.BuildRingsPage then
    local buildRings = F.BuildRingsPage
    function F.BuildRingsPage(page)
        page = buildRings(page)
        local check = F.CreateCheck(page, "Boat and zeppelin times", 240, -208, "boatTimes")
        check:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText("Boat and zeppelin times", F.BorderColor())
            GameTooltip:AddLine("Ride a boat or zeppelin and stand still on deck as it leaves. The addon saves that pier and how long the trip took. After three rides from the same pier within a few hours, it knows how often ships leave, and the bar counts down to the next one while you wait there. A server restart moves the times, and the next ride fixes them. /nf boats lists what it has learned.", 1, 1, 1, true)
            GameTooltip:Show()
        end)
        check:SetScript("OnLeave", GameTooltip_Hide)
        return page
    end
end
