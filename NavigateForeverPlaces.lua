-- Places, nearest services, and routes that can walk, fly, sail, or hearth.
-- One coordinate per place. Quest and NPC spawns stay in Questie.

local F = select(2, ...).F

F.places = {}
F.landByZone = {}

local function add(land, zone, name, x, y, side, flags, alias)
    local place = {
        land = land,
        zone = zone,
        name = name,
        x = x / 100,
        y = y / 100,
        faction = side,
        alias = alias and string.lower(alias) or nil,
        mail = string.find(flags, "m", 1, true) ~= nil,
        inn = string.find(flags, "i", 1, true) ~= nil,
        repair = string.find(flags, "r", 1, true) ~= nil,
        vendor = string.find(flags, "v", 1, true) ~= nil,
        fly = string.find(flags, "f", 1, true) ~= nil,
    }
    F.places[#F.places + 1] = place
    local key = string.lower(zone)
    if not F.landByZone[key] then
        F.landByZone[key] = land
    end
    local stripped = string.gsub(key, "^the ", "")
    if not F.landByZone[stripped] then
        F.landByZone[stripped] = land
    end
end

-- Eastern Kingdoms. Coordinates are the percent on that zone's map.
add("ek", "Stormwind City", "Stormwind", 70.9, 72.9, "A", "f", "stormwind city")
add("ek", "Stormwind City", "Stormwind Inn", 60.4, 75.3, "A", "i", "stormwind city|trade district|the trade district")
add("ek", "Stormwind City", "Stormwind Mailbox", 62.6, 72.0, "A", "m")
add("ek", "Stormwind City", "Stormwind Vendor", 63.2, 68.8, "A", "rv")
add("ek", "Ironforge", "Ironforge", 55.9, 47.8, "A", "f", "ironforge")
add("ek", "Ironforge", "Ironforge Inn", 18.1, 51.5, "A", "mirv", "the commons|commons")
add("ek", "Dun Morogh", "Kharanos", 47.3, 52.4, "A", "mirv")
add("ek", "Dun Morogh", "Tidegear Coast", 19.0, 15.2, "A", "fmirv")
add("ek", "Loch Modan", "Thelsamar", 33.9, 50.8, "A", "fmirv")
add("ek", "Wetlands", "Menethil Harbor", 9.5, 59.6, "A", "fmirv")
add("ek", "Elwynn Forest", "Goldshire", 42.4, 65.8, "A", "mirv")
add("ek", "Westfall", "Sentinel Hill", 56.6, 52.7, "A", "fmirv")
add("ek", "Redridge Mountains", "Lakeshire", 30.6, 59.4, "A", "fmirv")
add("ek", "Duskwood", "Darkshire", 77.5, 44.3, "A", "fmirv")
add("ek", "Stranglethorn Vale", "Rebel Camp", 38.0, 4.0, "A", "f")
add("ek", "Stranglethorn Vale", "Booty Bay", 27.5, 77.7, "A", "fmirv")
add("ek", "Stranglethorn Vale", "Booty Bay", 26.8, 77.0, "H", "fmirv")
add("ek", "Stranglethorn Vale", "Grom'gol", 32.5, 29.3, "H", "fmirv", "grom'gol base camp|gromgol")
add("ek", "Swamp of Sorrows", "Stonard", 46.0, 54.6, "H", "fmirv")
add("ek", "Blasted Lands", "Nethergarde Keep", 65.5, 24.3, "A", "fmirv")
add("ek", "Burning Steppes", "Morgan's Vigil", 84.4, 68.3, "A", "fmirv")
add("ek", "Burning Steppes", "Flame Crest", 65.6, 24.2, "H", "fmirv")
add("ek", "Searing Gorge", "Thorium Point", 37.9, 30.5, "A", "fmirv")
add("ek", "Searing Gorge", "Thorium Point", 34.9, 30.6, "H", "fmirv")
add("ek", "Badlands", "Kargath", 4.0, 44.8, "H", "fmirv")
add("ek", "Hillsbrad Foothills", "Southshore", 49.5, 52.1, "A", "fmirv")
add("ek", "Hillsbrad Foothills", "Tarren Mill", 59.4, 18.5, "H", "fmirv")
add("ek", "Arathi Highlands", "Refuge Pointe", 45.7, 46.1, "A", "fmirv")
add("ek", "Arathi Highlands", "Hammerfall", 73.0, 32.6, "H", "fmirv")
add("ek", "The Hinterlands", "Aerie Peak", 11.1, 46.1, "A", "fmirv")
add("ek", "The Hinterlands", "Revantusk Village", 81.7, 81.9, "H", "fmirv")
add("ek", "Western Plaguelands", "Chillwind Camp", 42.9, 85.1, "A", "fmirv")
add("ek", "Eastern Plaguelands", "Light's Hope Chapel", 71.7, 49.5, "A", "fmirv", "lights hope chapel|light's hope")
add("ek", "Eastern Plaguelands", "Light's Hope Chapel", 70.5, 47.5, "H", "fmirv", "lights hope chapel|light's hope")
add("ek", "Tirisfal Glades", "Brill", 61.7, 52.0, "H", "mirv")
add("ek", "Silverpine Forest", "The Sepulcher", 45.6, 42.4, "H", "fmirv", "sepulcher")
add("ek", "Undercity", "Undercity", 63.1, 48.1, "H", "fmirv")
add("ek", "Riverglades", "Farholde Keep", 60.6, 81.6, "A", "fmirv")
add("ek", "Riverglades", "Powderfuse Port", 76.8, 53.0, "A", "fmirv")
add("ek", "Riverglades", "Powderfuse Port", 79.0, 52.3, "H", "fmirv")
add("ek", "Riverglades", "Rog'mar", 59.6, 45.1, "H", "fmirv", "rogmar")

-- Teldrassil is its own island. The boat to Auberdine is the way off.
add("tel", "Teldrassil", "Dolanaar", 55.6, 59.8, "A", "mirv")
add("tel", "Teldrassil", "Rut'theran Village", 58.4, 93.9, "A", "fmirv", "ruttheran village|rut theran")
add("tel", "Darnassus", "Darnassus", 67.4, 15.6, "A", "mirv")

-- Kalimdor.
add("kal", "Darkshore", "Auberdine", 36.3, 45.6, "A", "fmirv")
add("kal", "Ashenvale", "Astranaar", 34.4, 48.0, "A", "fmirv")
add("kal", "Ashenvale", "Splintertree Post", 73.2, 61.6, "H", "fmirv")
add("kal", "Ashenvale", "Zoram'gar Outpost", 12.2, 33.8, "H", "fmirv", "zoramgar|zoram'gar")
add("kal", "Stonetalon Mountains", "Stonetalon Peak", 36.5, 7.2, "A", "f")
add("kal", "Stonetalon Mountains", "Sun Rock Retreat", 45.1, 59.8, "H", "fmirv")
add("kal", "Desolace", "Nijel's Point", 64.7, 10.4, "A", "fmirv", "nijels point")
add("kal", "Desolace", "Shadowprey Village", 21.6, 74.0, "H", "fmirv")
add("kal", "Feralas", "Feathermoon", 30.3, 43.3, "A", "fmirv", "feathermoon stronghold")
add("kal", "Feralas", "Feathermoon Dock", 31.0, 39.6, "A", "")
add("kal", "Feralas", "Thalanaar", 89.5, 45.9, "A", "fmirv")
add("kal", "Feralas", "Camp Mojache", 75.4, 44.3, "H", "fmirv")
add("kal", "Thousand Needles", "Freewind Post", 45.0, 49.1, "H", "fmirv")
add("kal", "Dustwallow Marsh", "Theramore", 67.4, 51.2, "A", "fmirv", "theramore isle")
add("kal", "Dustwallow Marsh", "Brackenwall Village", 35.5, 31.8, "H", "fmirv")
add("kal", "The Barrens", "Ratchet", 63.1, 37.1, "N", "fmirv")
add("kal", "The Barrens", "The Crossroads", 51.5, 30.3, "H", "fmirv", "crossroads")
add("kal", "The Barrens", "Camp Taurajo", 44.4, 59.1, "H", "fmirv")
add("kal", "Durotar", "Razor Hill", 51.5, 41.6, "H", "mirv")
add("kal", "Orgrimmar", "Orgrimmar", 45.3, 63.7, "H", "f")
add("kal", "Orgrimmar", "Orgrimmar Inn", 54.1, 68.4, "H", "mirv", "valley of strength|the valley of strength")
add("kal", "Mulgore", "Bloodhoof Village", 46.6, 60.2, "H", "mirv")
add("kal", "Thunder Bluff", "Thunder Bluff", 46.7, 49.8, "H", "fmirv")
add("kal", "Tanaris", "Gadgetzan", 51.0, 29.3, "A", "fmirv")
add("kal", "Tanaris", "Gadgetzan", 51.6, 25.5, "H", "fmirv")
add("kal", "Azshara", "Talrendis Point", 11.9, 77.5, "A", "fv")
add("kal", "Azshara", "Valormok", 22.0, 49.6, "H", "fmirv")
add("kal", "Felwood", "Talonbranch Glade", 62.5, 24.2, "A", "fmirv")
add("kal", "Felwood", "Bloodvenom Post", 34.4, 53.9, "H", "fmirv")
add("kal", "Un'Goro Crater", "Marshal's Refuge", 45.2, 5.8, "N", "fmirv", "marshals refuge")
add("kal", "Silithus", "Cenarion Hold", 50.6, 34.5, "A", "fmirv")
add("kal", "Silithus", "Cenarion Hold", 48.7, 36.7, "H", "fmirv")
add("kal", "Winterspring", "Everlook", 62.3, 36.6, "A", "fmirv")
add("kal", "Winterspring", "Everlook", 60.5, 36.3, "H", "fmirv")
add("kal", "Moonglade", "Nighthaven", 44.3, 45.4, "A", "fi")
add("kal", "Moonglade", "Nighthaven", 44.3, 45.7, "H", "fi")
add("kal", "Mount Hyjal", "Summit of Eternity", 68.7, 44.1, "N", "fmirv")
add("kal", "Mount Hyjal", "Tainted Foothills", 55.1, 82.6, "N", "fmirv")
F.landByZone.hyjal = "kal"

-- Boat and zeppelin links. Seconds is the ride, not the walk to the dock.
local LINKS = {
    { "Menethil Harbor", "Auberdine", "boat", 180 },
    { "Menethil Harbor", "Theramore", "boat", 180 },
    { "Booty Bay", "Ratchet", "boat", 200 },
    { "Rut'theran Village", "Auberdine", "boat", 90 },
    { "Feathermoon", "Feathermoon Dock", "boat", 40 },
    { "Orgrimmar", "Undercity", "zep", 180 },
    { "Orgrimmar", "Grom'gol", "zep", 180 },
    { "Undercity", "Grom'gol", "zep", 210 },
}
F.TRANSPORT_LINKS = LINKS

local KIND_FIELD = {
    mail = "mail",
    inn = "inn",
    repair = "repair",
    vendor = "vendor",
    flight = "fly",
}

local KIND_LABEL = {
    mail = "Mailbox",
    inn = "Inn",
    repair = "Repair",
    vendor = "Vendor",
    flight = "Flight master",
}

function F.PlayerSide()
    if not UnitFactionGroup then
        return nil
    end
    local ok, side = pcall(UnitFactionGroup, "player")
    side = ok and F.Plain(side)
    if side == "Horde" then
        return "H"
    end
    if side == "Alliance" then
        return "A"
    end
    return nil
end

function F.CanUse(place)
    if not place or not place.faction or place.faction == "" or place.faction == "N" then
        return true
    end
    local mine = F.PlayerSide()
    if not mine then
        return true
    end
    return place.faction == mine
end

local function rememberMap(id, info)
    if type(info) ~= "table" or type(info.name) ~= "string" or info.name == "" then
        return
    end
    local key = string.lower(info.name)
    local prev = F.mapByName[key]
    if not prev then
        F.mapByName[key] = id
        return
    end
    local rank = { [3] = 1, [4] = 2, [5] = 3 }
    local prevInfo
    local ok, looked = pcall(C_Map.GetMapInfo, prev)
    if ok then
        prevInfo = looked
    end
    local prevRank = prevInfo and rank[prevInfo.mapType] or 9
    local thisRank = rank[info.mapType] or 9
    if thisRank < prevRank then
        F.mapByName[key] = id
    end
end

function F.EnsureMaps()
    if F.mapByName then
        return
    end
    F.mapByName = {}
    if not C_Map or not C_Map.GetMapInfo or not C_Map.GetBestMapForUnit then
        return
    end
    local ok, start = pcall(C_Map.GetBestMapForUnit, "player")
    start = ok and tonumber(F.Plain(start))
    local root = start
    local guard = 0
    while root and guard < 12 do
        local infoOk, info = pcall(C_Map.GetMapInfo, root)
        if not infoOk or type(info) ~= "table" or not info.parentMapID or info.parentMapID == 0 then
            break
        end
        root = info.parentMapID
        guard = guard + 1
    end
    local function walk(id, depth)
        if not id or depth > 8 then
            return
        end
        local infoOk, info = pcall(C_Map.GetMapInfo, id)
        if infoOk then
            rememberMap(id, info)
        end
        if not C_Map.GetMapChildrenInfo then
            return
        end
        local childOk, children = pcall(C_Map.GetMapChildrenInfo, id)
        if not childOk or type(children) ~= "table" then
            return
        end
        for index = 1, #children do
            walk(children[index].mapID, depth + 1)
        end
    end
    if root then
        walk(root, 0)
    end
end

function F.ScanMaps()
    if F.mapScanned or not C_Map or not C_Map.GetMapInfo then
        F.mapScanned = true
        return
    end
    F.mapScanned = true
    F.EnsureMaps()
    for id = 1, 2500 do
        local ok, info = pcall(C_Map.GetMapInfo, id)
        if ok then
            rememberMap(id, info)
        end
    end
end

function F.MapForZone(zone)
    if type(zone) ~= "string" or zone == "" then
        return nil
    end
    F.EnsureMaps()
    local key = string.lower(zone)
    local id = F.mapByName and F.mapByName[key]
    if not id then
        local stripped = string.gsub(key, "^the ", "")
        id = F.mapByName and F.mapByName[stripped]
    end
    if not id and not F.mapScanned then
        F.ScanMaps()
        id = F.mapByName and (F.mapByName[key] or F.mapByName[string.gsub(key, "^the ", "")])
    end
    return id
end

function F.LandForMap(mapID)
    if not mapID or not C_Map or not C_Map.GetMapInfo then
        return nil
    end
    local id = mapID
    local guard = 0
    while id and guard < 8 do
        local ok, info = pcall(C_Map.GetMapInfo, id)
        if not ok or type(info) ~= "table" then
            break
        end
        local land = type(info.name) == "string" and F.landByZone[string.lower(info.name)]
        if land then
            return land
        end
        id = info.parentMapID
        guard = guard + 1
    end
    return nil
end

function F.Locate(place)
    if place.wx and place.wy then
        return true
    end
    local mapID = place.map or F.MapForZone(place.zone)
    if not mapID or not F.MapPoint then
        return false
    end
    local wcont, wx, wy = F.MapPoint(mapID, place.x, place.y)
    if type(wx) ~= "number" or type(wy) ~= "number" then
        return false
    end
    place.map = mapID
    place.wx = wx
    place.wy = wy
    place.wcont = wcont
    if place.land and wcont then
        F.wcontLand = F.wcontLand or {}
        F.wcontLand[wcont] = place.land
    end
    if not place.land and wcont and F.wcontLand and F.wcontLand[wcont] then
        place.land = F.wcontLand[wcont]
    end
    return true
end

function F.Here()
    if not C_Map or not C_Map.GetBestMapForUnit or not F.MapPoint then
        return nil
    end
    local ok, mapID = pcall(C_Map.GetBestMapForUnit, "player")
    mapID = ok and tonumber(F.Plain(mapID))
    if not mapID then
        return nil
    end
    local x, y = F.PosOnMap(mapID)
    if not x then
        return nil
    end
    local wcont, wx, wy = F.MapPoint(mapID, x, y)
    local land = F.LandForMap(mapID)
    if not land and wcont and F.wcontLand then
        land = F.wcontLand[wcont]
    end
    return { map = mapID, x = x, y = y, wx = wx, wy = wy, wcont = wcont, land = land, name = "You" }
end

function F.YardsBetween(from, to)
    if not from or not to or not from.wx or not to.wx then
        return nil
    end
    if from.land and to.land and from.land ~= to.land then
        return nil
    end
    if from.wcont and to.wcont and from.wcont ~= to.wcont then
        return nil
    end
    local dx = from.wx - to.wx
    local dy = from.wy - to.wy
    return math.sqrt(dx * dx + dy * dy)
end

function F.PlaceByName(name)
    local key = string.lower(name or "")
    local fallback
    for index = 1, #F.places do
        local place = F.places[index]
        if string.lower(place.name) == key then
            if F.CanUse(place) then
                return place
            end
            fallback = fallback or place
        end
    end
    return fallback
end

local function nearestFly(from, land)
    local best, bestYards
    for index = 1, #F.places do
        local place = F.places[index]
        if place.fly and place.land == land and F.CanUse(place) and F.Locate(place) then
            local yards = F.YardsBetween(from, place)
            if yards and (not bestYards or yards < bestYards) then
                best = place
                bestYards = yards
            end
        end
    end
    return best, bestYards
end

-- Walk, or walk to a flight master and fly, when both ends share a land.
function F.Approach(from, place)
    if not from or not place or not F.Locate(place) then
        return nil
    end
    if from.land and place.land and from.land ~= place.land then
        return nil
    end
    local walkYards = F.YardsBetween(from, place)
    if not walkYards then
        return nil
    end
    local bestTime = walkYards / 7
    local best = {
        { kind = "walk", place = place, title = place.name },
    }
    if place.land == "tel" or from.land == "tel" then
        return bestTime, best
    end
    local depart = nearestFly(from, place.land or from.land)
    local arrive = place.fly and place or nearestFly(place, place.land or from.land)
    if not depart or not arrive or depart == arrive then
        return bestTime, best
    end
    if place.fly and arrive == place and depart ~= place then
        local leg = F.YardsBetween(from, depart)
        local flight = F.YardsBetween(depart, place)
        if leg and flight then
            local time = leg / 7 + flight / 28 + 20
            if time + 30 < bestTime then
                return time, {
                    { kind = "walk", place = depart, title = depart.name },
                    { kind = "fly", place = depart, title = "Fly to " .. place.name, dest = place, destLand = place.land, srcLand = depart.land },
                }
            end
        end
        return bestTime, best
    end
    if not place.fly and depart ~= arrive then
        local leg = F.YardsBetween(from, depart)
        local flight = F.YardsBetween(depart, arrive)
        local after = F.YardsBetween(arrive, place)
        if leg and flight and after then
            local time = leg / 7 + flight / 28 + 20 + after / 7
            if time + 30 < bestTime then
                return time, {
                    { kind = "walk", place = depart, title = depart.name },
                    { kind = "fly", place = depart, title = "Fly to " .. arrive.name, dest = arrive, destLand = arrive.land, srcLand = depart.land },
                    { kind = "walk", place = place, title = place.name },
                }
            end
        end
    end
    return bestTime, best
end

local function appendSteps(into, steps)
    for index = 1, #steps do
        into[#into + 1] = steps[index]
    end
end

function F.HearthReady()
    if not GetItemCount or not GetItemCooldown then
        return false
    end
    local countOk, count = pcall(GetItemCount, 6948)
    count = countOk and tonumber(F.Plain(count))
    if not count or count < 1 then
        return false
    end
    local coolOk, start, duration = pcall(GetItemCooldown, 6948)
    start = coolOk and tonumber(F.Plain(start)) or 0
    duration = coolOk and tonumber(F.Plain(duration)) or 0
    if not start or not duration then
        return false
    end
    return duration == 0 or start == 0
end

function F.BoundInn()
    if not GetBindLocation then
        return nil
    end
    local ok, bind = pcall(GetBindLocation)
    bind = ok and F.Plain(bind)
    if type(bind) ~= "string" or bind == "" then
        return nil
    end
    bind = string.lower(bind)
    for index = 1, #F.places do
        local place = F.places[index]
        if place.inn and F.CanUse(place) then
            if string.lower(place.name) == bind or string.lower(place.zone) == bind then
                return place
            end
            if place.alias and string.find(place.alias, bind, 1, true) then
                return place
            end
        end
    end
    return nil
end

function F.BuildTrip(from, place)
    if not from or not place then
        return nil
    end
    F.Locate(place)
    local bestTime, bestSteps = F.Approach(from, place)
    for index = 1, #LINKS do
        local link = LINKS[index]
        local kind = link[3]
        local ride = link[4]
        local ends = {
            { F.PlaceByName(link[1]), F.PlaceByName(link[2]) },
            { F.PlaceByName(link[2]), F.PlaceByName(link[1]) },
        }
        for way = 1, 2 do
            local src, dst = ends[way][1], ends[way][2]
            if src and dst and F.CanUse(src) and F.CanUse(dst) and F.Locate(src) and F.Locate(dst) then
                if not from.land or from.land == src.land then
                    local toSrc, srcSteps = F.Approach(from, src)
                    local dock = {
                        land = dst.land,
                        wx = dst.wx,
                        wy = dst.wy,
                        wcont = dst.wcont,
                        map = dst.map,
                        x = dst.x,
                        y = dst.y,
                        name = dst.name,
                    }
                    local after, afterSteps = F.Approach(dock, place)
                    if toSrc and after and srcSteps and afterSteps then
                        local time = toSrc + ride + after
                        if not bestTime or time + 20 < bestTime then
                            local steps = {}
                            appendSteps(steps, srcSteps)
                            local word = kind == "zep" and "Zeppelin to " or "Boat to "
                            steps[#steps + 1] = {
                                kind = kind,
                                place = src,
                                title = word .. dst.name,
                                dest = dst,
                                destLand = dst.land,
                                srcLand = src.land,
                                zone = dst.zone,
                            }
                            appendSteps(steps, afterSteps)
                            bestTime = time
                            bestSteps = steps
                        end
                    end
                end
            end
        end
    end
    if F.HearthReady() then
        local inn = F.BoundInn()
        if inn and F.Locate(inn) then
            local home = {
                land = inn.land,
                wx = inn.wx,
                wy = inn.wy,
                wcont = inn.wcont,
                map = inn.map,
                x = inn.x,
                y = inn.y,
                name = inn.name,
            }
            local after, afterSteps = F.Approach(home, place)
            if after and afterSteps then
                local time = 12 + after
                if not bestTime or time + 15 < bestTime then
                    local steps = {
                        {
                            kind = "hearth",
                            place = inn,
                            title = "Hearth to " .. inn.name,
                            dest = inn,
                            destLand = inn.land,
                            zone = inn.zone,
                        },
                    }
                    appendSteps(steps, afterSteps)
                    bestTime = time
                    bestSteps = steps
                end
            end
        end
    end
    if not bestSteps then
        return nil
    end
    return { dest = place.name, steps = bestSteps, index = 1, seconds = bestTime or 0 }
end

function F.PinFromPlace(place, title)
    if not place or not F.Locate(place) then
        return nil
    end
    return {
        map = place.map,
        zx = place.x,
        zy = place.y,
        name = title or place.name,
    }
end

function F.ApplyTripStep()
    local db = F.DB and F.DB()
    local trip = db and db.trip
    if not trip then
        return
    end
    local step = trip.steps[trip.index]
    if not step then
        db.trip = nil
        return
    end
    local title = step.kind == "walk" and step.place.name or step.title
    local pin = F.PinFromPlace(step.place, title)
    if not pin or not F.UsePin then
        return
    end
    F.routing = true
    F.UsePin(pin)
    F.routing = false
end

function F.TripSummary(trip, place)
    local bits = {}
    local first = trip.steps[1]
    if first and first.kind == "walk" and first.place ~= place then
        bits[#bits + 1] = "Walk to " .. first.place.name
    end
    for index = 1, #trip.steps do
        local step = trip.steps[index]
        if step.kind ~= "walk" and step.title then
            bits[#bits + 1] = step.title
        end
    end
    if #bits == 0 then
        return place.name
    end
    return place.name .. ". " .. table.concat(bits, ". ")
end

function F.GoPlace(place, lead)
    if not place then
        return
    end
    local here = F.Here()
    if not here or not here.wx then
        F.Say("No position yet. Try again in a moment.")
        return
    end
    if not F.Locate(place) then
        F.Say(place.name .. " is not on a map this client has loaded.")
        return
    end
    local trip = F.BuildTrip(here, place)
    if not trip then
        F.Say("No route to " .. place.name .. ".")
        return
    end
    local db = F.DB()
    if db then
        db.trip = trip
    end
    F.ApplyTripStep()
    local line = F.TripSummary(trip, place)
    if type(lead) == "string" and lead ~= "" then
        line = lead .. ". " .. line
    end
    F.Say(line .. ".")
end

function F.GoNearest(kind)
    local field = KIND_FIELD[kind] or kind
    local here = F.Here()
    if not here or not here.wx then
        F.Say("No position yet. Try again in a moment.")
        return
    end
    local best, bestTime
    for index = 1, #F.places do
        local place = F.places[index]
        if place[field] and F.CanUse(place) and F.Locate(place) then
            local trip = F.BuildTrip(here, place)
            if trip and (not bestTime or trip.seconds < bestTime) then
                best = place
                bestTime = trip.seconds
            end
        end
    end
    if not best then
        F.Say("No " .. string.lower(KIND_LABEL[kind] or "place") .. " within reach.")
        return
    end
    F.GoPlace(best, KIND_LABEL[kind])
end

local function fold(text)
    text = string.lower(text or "")
    text = string.gsub(text, "'", "")
    return text
end

function F.FindPlace(query)
    query = string.gsub(query or "", "^%s+", "")
    query = string.gsub(query, "%s+$", "")
    if query == "" then
        F.Say("Usage: /nf find goldshire")
        return
    end
    local needle = fold(query)
    local hits = {}
    for index = 1, #F.places do
        local place = F.places[index]
        if F.CanUse(place) then
            local name = fold(place.name)
            local alias = fold(place.alias or "")
            if string.find(name, needle, 1, true) or (alias ~= "" and string.find(alias, needle, 1, true)) then
                hits[#hits + 1] = place
            end
        end
    end
    if #hits == 0 then
        F.Say("No place named " .. query .. ".")
        return
    end
    local exact
    for index = 1, #hits do
        if fold(hits[index].name) == needle then
            exact = hits[index]
            break
        end
    end
    if exact then
        F.GoPlace(exact)
        return
    end
    if #hits == 1 then
        F.GoPlace(hits[1])
        return
    end
    local names = {}
    local limit = #hits
    if limit > 6 then
        limit = 6
    end
    for index = 1, limit do
        names[#names + 1] = hits[index].name
    end
    local extra = #hits > 6 and " ..." or ""
    F.Say("Several places: " .. table.concat(names, ", ") .. extra .. ". /nf find " .. query)
end

function F.ArrowInstruction()
    local db = F.DB and F.DB()
    local trip = db and db.trip
    if not trip then
        return nil
    end
    local step = trip.steps[trip.index]
    if not step or step.kind == "walk" then
        return nil
    end
    return step.title
end

function F.ArriveWalk()
    if F.stepping then
        return false
    end
    local db = F.DB and F.DB()
    local trip = db and db.trip
    if not trip or not db.pin then
        return false
    end
    local step = trip.steps[trip.index]
    if not step or step.kind ~= "walk" then
        return false
    end
    local state, _, _, yards = F.PinOffset()
    yards = F.Plain(yards)
    if state ~= "ok" or type(yards) ~= "number" or yards > 20 then
        return false
    end
    if trip.index >= #trip.steps then
        db.trip = nil
        return false
    end
    trip.index = trip.index + 1
    F.stepping = true
    F.ApplyTripStep()
    F.stepping = false
    local nextStep = trip.steps[trip.index]
    if nextStep then
        if nextStep.kind == "walk" then
            F.Say("Walk to " .. nextStep.place.name .. ".")
        elseif nextStep.title then
            F.Say(nextStep.title .. ".")
        end
    end
    return true
end

local function sameText(a, b)
    return type(a) == "string" and type(b) == "string" and a ~= "" and string.lower(a) == string.lower(b)
end

-- A boat or zeppelin whose ends share a land never changes `land`.
-- Undercity and Grom'gol are both Eastern Kingdoms. Feathermoon and its dock are both Kalimdor.
-- The boarding pin stays on the dock you left, so distance to that pin cannot mean arrival.
local function rideArrived(step, here)
    if here.land and step.destLand and step.origin and here.land == step.destLand and here.land ~= step.origin then
        return true
    end
    local zone = GetZoneText and GetZoneText() or ""
    local sub = GetSubZoneText and GetSubZoneText() or ""
    local boarded
    if step.place and F.Locate(step.place) then
        boarded = F.YardsBetween(here, step.place)
    end
    if not step.rideSeen then
        step.rideSeen = true
        step.originZone = zone
        step.originSub = sub
        step.originMap = here.map
    elseif boarded and boarded <= 80 then
        -- Zone text can be empty for a moment at the dock. Keep the boarding labels until the ride leaves.
        if zone ~= "" then
            step.originZone = zone
        end
        if sub ~= "" then
            step.originSub = sub
        end
        if here.map then
            step.originMap = here.map
        end
    end
    local dest = step.dest
    if dest and F.Locate(dest) then
        if here.map and step.originMap and here.map == dest.map and here.map ~= step.originMap then
            return true
        end
        local yards = F.YardsBetween(here, dest)
        -- Within a dock's width of the destination, and closer to it than to where you boarded.
        if yards and yards <= 80 and boarded and boarded > yards then
            return true
        end
    end
    if step.originZone and step.originZone ~= "" and sameText(zone, step.zone) and zone ~= step.originZone then
        return true
    end
    if dest and step.originSub and step.originSub ~= "" and sameText(sub, dest.name) and sub ~= step.originSub then
        return true
    end
    return false
end

function F.WatchTrip()
    if F.stepping then
        return
    end
    local db = F.DB and F.DB()
    local trip = db and db.trip
    if not trip then
        return
    end
    local step = trip.steps[trip.index]
    if not step or step.kind == "walk" then
        return
    end
    local advance = false
    if step.kind == "fly" then
        if F.OnTaxi() then
            step.rode = true
        elseif step.rode then
            advance = true
        end
    elseif step.kind == "boat" or step.kind == "zep" or step.kind == "hearth" then
        local here = F.Here()
        if here and not step.origin then
            step.origin = here.land
        end
        if here and (step.kind == "boat" or step.kind == "zep") then
            advance = rideArrived(step, here)
        elseif here and here.land and step.destLand and here.land == step.destLand and here.land ~= step.origin then
            advance = true
        end
        if step.kind == "hearth" and not advance then
            local state, _, _, yards = F.PinOffset()
            yards = F.Plain(yards)
            if state == "ok" and type(yards) == "number" then
                if yards > 80 then
                    step.far = true
                elseif step.far and yards < 40 then
                    advance = true
                end
            end
            local zone = GetZoneText and GetZoneText() or ""
            local sub = GetSubZoneText and GetSubZoneText() or ""
            if not step.originZone then
                step.originZone = zone
            end
            local arrivedName = string.lower(sub) == string.lower(step.place.name) or string.lower(zone) == string.lower(step.zone or "")
            if step.far and arrivedName and zone ~= step.originZone then
                advance = true
            end
        end
    end
    if not advance then
        return
    end
    if trip.index >= #trip.steps then
        db.trip = nil
        return
    end
    trip.index = trip.index + 1
    F.stepping = true
    F.ApplyTripStep()
    F.stepping = false
    local nextStep = trip.steps[trip.index]
    if nextStep and nextStep.kind == "walk" then
        F.Say("Walk to " .. nextStep.place.name .. ".")
    elseif nextStep and nextStep.title then
        F.Say(nextStep.title .. ".")
    end
end

function F.RouteCurrentPin()
    if F.routing then
        return
    end
    local db = F.DB and F.DB()
    local pin = db and db.pin
    if not pin or not pin.map or not pin.zx or not pin.zy then
        return
    end
    local here = F.Here()
    if not here or not here.wx then
        return
    end
    local place = {
        name = type(pin.name) == "string" and pin.name ~= "" and pin.name or "Pin",
        map = pin.map,
        x = pin.zx,
        y = pin.zy,
        land = F.LandForMap(pin.map),
    }
    if not F.Locate(place) then
        return
    end
    local trip = F.BuildTrip(here, place)
    if not trip then
        return
    end
    local only = trip.steps[1]
    if only and only.kind == "walk" and #trip.steps == 1 then
        db.trip = nil
        return
    end
    db.trip = trip
    F.ApplyTripStep()
    F.Say(F.TripSummary(trip, place) .. ".")
end

local function hook(name, after)
    local original = F[name]
    if type(original) ~= "function" then
        return
    end
    F[name] = function(...)
        original(...)
        after()
    end
end

local function hookWhenPinChanges(name)
    local original = F[name]
    if type(original) ~= "function" then
        return
    end
    F[name] = function(...)
        local db = F.DB and F.DB()
        local before = db and db.pin
        original(...)
        local now = db and db.pin
        if now and now ~= before then
            F.RouteCurrentPin()
        end
    end
end

hookWhenPinChanges("DropPinOnWorldMap")
hookWhenPinChanges("DropPinAtCursor")
hookWhenPinChanges("GoPin")

local goBar
local goButtons

local function showFind()
    if not goBar or not goBar.find then
        return
    end
    goBar.find:Show()
    goBar.find:SetFocus()
end

function F.LayoutGoBar()
    if not goBar or not F.nav or not goButtons then
        return
    end
    local width = F.nav:GetWidth() or 0
    if width < 40 then
        return
    end
    local pad = 10
    local gap = 5
    local count = #goButtons
    local buttonWidth = (width - pad * 2 - gap * (count - 1)) / count
    if buttonWidth < 28 then
        buttonWidth = 28
    end
    for index = 1, count do
        local button = goButtons[index]
        button:ClearAllPoints()
        button:SetSize(buttonWidth, 28)
        if index == 1 then
            button:SetPoint("LEFT", goBar, "LEFT", pad, 0)
        else
            button:SetPoint("LEFT", goButtons[index - 1], "RIGHT", gap, 0)
        end
    end
end

function F.CreateGoBar()
    if goBar or not F.nav or not F.Chip then
        return
    end
    goBar = CreateFrame("Frame", "NavigateForeverGo", F.nav)
    F.goBar = goBar
    goBar:SetHeight(40)
    goBar:SetPoint("BOTTOMLEFT", F.nav, "TOPLEFT", 0, 0)
    goBar:SetPoint("BOTTOMRIGHT", F.nav, "TOPRIGHT", 0, 0)
    goBar:EnableMouse(true)
    if F.PaintPanel then
        F.PaintPanel(goBar, 0.94)
    end
    local labels = {
        { "Mail", "mail" },
        { "Inn", "inn" },
        { "Repair", "repair" },
        { "Vendor", "vendor" },
        { "Flight", "flight" },
        { "Find", "find" },
    }
    goButtons = {}
    for index = 1, #labels do
        local label, kind = labels[index][1], labels[index][2]
        local button = F.Chip(goBar, label, 48, 14, 28)
        button.kind = kind
        if kind == "find" then
            button:SetScript("OnClick", showFind)
        else
            button:SetScript("OnClick", function()
                F.GoNearest(kind)
            end)
        end
        local tip = KIND_LABEL[kind] or "Find a place by name"
        button:SetScript("OnEnter", function(self)
            local hr, hg, hb = F.ThemeColor("hover")
            self.nfTop:SetColorTexture(hr, hg, hb, 1)
            self.nfBottom:SetColorTexture(hr, hg, hb, 1)
            self.nfLeft:SetColorTexture(hr, hg, hb, 1)
            self.nfRight:SetColorTexture(hr, hg, hb, 1)
            self.nfLabel:SetTextColor(F.ThemeColor("bright"))
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            if kind == "find" then
                GameTooltip:SetText("Find", F.BorderColor())
                GameTooltip:AddLine("Type a city, inn, flight master, boat, or zeppelin.", 1, 1, 1, true)
            else
                GameTooltip:SetText(tip, F.BorderColor())
                GameTooltip:AddLine("Point the arrow at the nearest one. A long trip can use a flight, boat, or hearth.", 1, 1, 1, true)
            end
            GameTooltip:Show()
        end)
        button:SetScript("OnLeave", function(self)
            local br, bgc, bb = F.BorderColor()
            self.nfTop:SetColorTexture(br, bgc, bb, 1)
            self.nfBottom:SetColorTexture(br, bgc, bb, 1)
            self.nfLeft:SetColorTexture(br, bgc, bb, 1)
            self.nfRight:SetColorTexture(br, bgc, bb, 1)
            self.nfLabel:SetTextColor(br, bgc, bb)
            GameTooltip:Hide()
        end)
        goButtons[index] = button
    end
    local find = CreateFrame("EditBox", "NavigateForeverFind", goBar)
    find:SetAllPoints()
    find:SetFrameLevel((goBar:GetFrameLevel() or 1) + 5)
    find:SetAutoFocus(false)
    find:SetFont("Fonts\\FRIZQT__.TTF", 16, "")
    find:SetTextInsets(8, 8, 0, 0)
    local bg = find:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    local function paintFind()
        local mr, mg, mb = F.MenuColor()
        bg:SetColorTexture(mr, mg, mb, 0.96)
        find:SetTextColor(F.ThemeColor("bright"))
    end
    paintFind()
    find:HookScript("OnShow", paintFind)
    find:SetScript("OnEnterPressed", function(self)
        local text = self:GetText() or ""
        self:SetText("")
        self:Hide()
        self:ClearFocus()
        F.FindPlace(text)
    end)
    find:SetScript("OnEscapePressed", function(self)
        self:SetText("")
        self:Hide()
        self:ClearFocus()
    end)
    find:Hide()
    goBar.find = find
    F.LayoutGoBar()
end

hook("CreateNav", function()
    F.CreateGoBar()
end)
hook("LayoutNav", function()
    F.LayoutGoBar()
end)
