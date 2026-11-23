-- Item tooltips: which quest a drop is for, and which cooking dish uses it.
-- Own file so these locals do not count toward the main script's 200.

local F = select(2, ...).F

function F.InstallItemUses()
    -- Vanilla cooking, lowest skill first. A reagent maps to the dishes that use it.
    local COOKING = {
        "Brilliant Smallfish=Raw Brilliant Smallfish",
        "Crispy Bat Wing=Meaty Bat Wing,Mild Spices",
        "Gingerbread Cookie=Small Egg,Holiday Spices",
        "Herb Baked Egg=Small Egg,Mild Spices",
        "Slitherskin Mackerel=Raw Slitherskin Mackerel",
        "Charred Wolf Meat=Stringy Wolf Meat",
        "Roasted Boar Meat=Chunk of Boar Meat",
        "Kaldorei Spider Kabob=Small Spider Leg",
        "Spiced Wolf Meat=Stringy Wolf Meat,Mild Spices",
        "Scorpid Surprise=Scorpid Stinger",
        "Beer Basted Boar Ribs=Crag Boar Rib,Rhapsody Malt",
        "Egg Nog=Small Egg,Ice Cold Milk,Holiday Spirits,Holiday Spices",
        "Roasted Kodo Meat=Kodo Meat,Mild Spices",
        "Smoked Bear Meat=Bear Meat",
        "Boiled Clams=Clam Meat,Refreshing Spring Water",
        "Coyote Steak=Coyote Meat",
        "Fillet of Frenzy=Soft Frenzy Flesh,Mild Spices",
        "Goretusk Liver Pie=Goretusk Liver,Mild Spices",
        "Loch Frenzy Delight=Raw Loch Frenzy,Mild Spices",
        "Longjaw Mud Snapper=Raw Longjaw Mud Snapper",
        "Rainbow Fin Albacore=Raw Rainbow Fin Albacore",
        "Strider Stew=Strider Meat,Shiny Red Apple",
        "Blood Sausage=Bear Meat,Boar Intestines,Spider Ichor",
        "Thistle Tea=Swiftthistle,Refreshing Spring Water",
        "Crab Cake=Crawler Meat,Mild Spices",
        "Westfall Stew=Stringy Vulture Meat,Murloc Eye,Goretusk Snout",
        "Crocolisk Steak=Crocolisk Meat,Mild Spices",
        "Dry Pork Ribs=Boar Ribs,Mild Spices",
        "Smoked Sagefish=Raw Sagefish,Mild Spices",
        "Cooked Crab Claw=Crawler Claw,Mild Spices",
        "Savory Deviate Delight=Deviate Fish,Mild Spices",
        "Clam Chowder=Clam Meat,Ice Cold Milk,Mild Spices",
        "Dig Rat Stew=Dig Rat",
        "Murloc Fin Soup=Murloc Fin,Hot Spices",
        "Redridge Goulash=Crisp Spider Meat,Tough Condor Meat",
        "Bristle Whisker Catfish=Raw Bristle Whisker Catfish",
        "Crispy Lizard Tail=Thunder Lizard Tail,Hot Spices",
        "Seasoned Wolf Kabob=Lean Wolf Meat,Stormwind Seasoning Herbs",
        "Succulent Pork Ribs=Boar Ribs,Hot Spices",
        "Big Bear Steak=Big Bear Meat,Hot Spices",
        "Gooey Spider Cake=Gooey Spider Leg,Hot Spices",
        "Lean Venison=Stag Meat,Mild Spices",
        "Crocolisk Gumbo=Tender Crocolisk Meat,Hot Spices",
        "Goblin Deviled Clams=Tangy Clam Meat,Hot Spices",
        "Lean Wolf Steak=Lean Wolf Meat,Mild Spices",
        "Hot Lion Chops=Lion Meat,Hot Spices",
        "Curiously Tasty Omelet=Raptor Egg,Hot Spices",
        "Heavy Crocolisk Stew=Tender Crocolisk Meat,Soothing Spices",
        "Tasty Lion Steak=Lion Meat,Soothing Spices",
        "Barbecued Buzzard Wing=Buzzard Wing,Hot Spices",
        "Rockscale Cod=Raw Rockscale Cod",
        "Carrion Surprise=Mystery Meat,Hot Spices",
        "Giant Clam Scorcho=Giant Clam Meat,Hot Spices",
        "Goldthorn Tea=Goldthorn,Refreshing Spring Water",
        "Hot Wolf Ribs=Red Wolf Meat,Hot Spices",
        "Jungle Stew=Tiger Meat,Refreshing Spring Water,Shiny Red Apple",
        "Mithril Head Trout=Raw Mithril Head Trout",
        "Mystery Stew=Mystery Meat,Skin of Dwarven Stout",
        "Roast Raptor=Raptor Flesh,Hot Spices",
        "Sagefish Delight=Raw Greater Sagefish,Hot Spices",
        "Soothing Turtle Bisque=Turtle Meat,Soothing Spices",
        "Dragonbreath Chili=Mystery Meat,Small Flame Sac,Hot Spices",
        "Heavy Kodo Stew=Heavy Kodo Meat,Soothing Spices,Refreshing Spring Water",
        "Spider Sausage=White Spider Meat",
        "Cooked Glossy Mightfish=Raw Glossy Mightfish,Soothing Spices",
        "Filet of Redgill=Raw Redgill",
        "Monster Omelet=Giant Egg,Soothing Spices",
        "Spiced Chili Crab=Tender Crab Meat,Hot Spices",
        "Spotted Yellowtail=Raw Spotted Yellowtail",
        "Tender Wolf Steak=Tender Wolf Meat,Soothing Spices",
        "Undermine Clam Chowder=Zesty Clam Meat,Hot Spices,Ice Cold Milk",
        "Grilled Squid=Winter Squid,Soothing Spices",
        "Hot Smoked Bass=Raw Summer Bass,Hot Spices",
        "Nightfin Soup=Raw Nightfin Snapper,Refreshing Spring Water",
        "Poached Sunscale Salmon=Raw Sunscale Salmon",
        "Baked Salmon=Raw Whitescale Salmon,Soothing Spices",
        "Lobster Stew=Darkclaw Lobster,Refreshing Spring Water",
        "Mightfish Steak=Large Raw Mightfish,Hot Spices,Soothing Spices",
        "Runn Tum Tuber Surprise=Runn Tum Tuber,Soothing Spices",
        "Crystal Flake Throat Lozenge=Deeprock Salt",
        "Dirge's Kickin' Chimaerok Chops=Goblin Rocket Fuel,Deeprock Salt,Chimaerok Tenderloin",
        "Smoked Desert Dumplings=Sandworm Meat,Soothing Spices",
    }

    local cookBy = {}
    local questBy = {}

    local function norm(name)
        name = string.lower(name)
        name = string.gsub(name, "^%s+", "")
        name = string.gsub(name, "%s+$", "")
        name = string.gsub(name, "%s+", " ")
        return name
    end

    -- "Chunks of Boar Meat" and "Chunk of Boar Meat" land on the same key.
    local function singular(name)
        local key = norm(name)
        key = string.gsub(key, "^(%a+)ies ", "%1y ")
        key = string.gsub(key, "^(%a+)s ", "%1 ")
        key = string.gsub(key, "ies$", "y")
        key = string.gsub(key, "([^s])s$", "%1")
        return key
    end

    local function addCook(reagent, recipe)
        local key = norm(reagent)
        if key == "" then
            return
        end
        local list = cookBy[key]
        if not list then
            list = {}
            cookBy[key] = list
        end
        for index = 1, #list do
            if list[index] == recipe then
                return
            end
        end
        list[#list + 1] = recipe
    end

    for index = 1, #COOKING do
        local recipe, reagents = string.match(COOKING[index], "^(.-)=(.+)$")
        if recipe and reagents then
            for reagent in string.gmatch(reagents, "[^,]+") do
                addCook(reagent, recipe)
            end
        end
    end

    local function countOf(value)
        value = F.Plain(value)
        if type(value) == "number" then
            return value
        end
        if type(value) == "string" then
            return tonumber(value)
        end
        return nil
    end

    local function countsFrom(text)
        if type(text) ~= "string" then
            return nil, nil
        end
        local have, need = string.match(text, "(%d+)%s*/%s*(%d+)")
        return tonumber(have), tonumber(need)
    end

    local function objectiveName(text)
        if type(text) ~= "string" or text == "" then
            return nil
        end
        local name = string.gsub(text, "|c%x%x%x%x%x%x%x%x", "")
        name = string.gsub(name, "|r", "")
        name = string.gsub(name, "|T.-|t", "")
        name = string.gsub(name, "|H.-|h%[(.-)%]|h", "%1")
        name = string.gsub(name, "|H.-|h(.-)|h", "%1")
        local lower = string.lower(name)
        if string.find(lower, "slain", 1, true) or string.find(lower, "killed", 1, true) or string.find(lower, "destroyed", 1, true) or string.find(lower, "defeated", 1, true) then
            return nil
        end
        name = string.gsub(name, "%d+%s*/%s*%d+", "")
        name = string.gsub(name, "^%s*[Cc]ollect%s+%d*%s*", "")
        name = string.gsub(name, "^%s*[Gg]ather%s+%d*%s*", "")
        name = string.gsub(name, "^%s*[Rr]ecover%s+%d*%s*", "")
        name = string.gsub(name, "^[%s%.:%(%)%[%]-]+", "")
        name = string.gsub(name, "[%s%.:%(%)%[%]-]+$", "")
        name = string.gsub(name, "%s+[Cc]ollected$", "")
        name = string.gsub(name, "%s+[Oo]btained$", "")
        name = string.gsub(name, "%s+", " ")
        if name == "" then
            return nil
        end
        return name
    end

    local function addQuest(name, title, have, need)
        name = F.Plain(name)
        title = F.Plain(title)
        if type(name) ~= "string" or type(title) ~= "string" or name == "" or title == "" then
            return
        end
        title = string.gsub(title, "|c%x%x%x%x%x%x%x%x", "")
        title = string.gsub(title, "|r", "")
        local key = singular(name)
        if key == "" then
            return
        end
        local rows = questBy[key]
        if not rows then
            rows = {}
            questBy[key] = rows
        end
        for index = 1, #rows do
            if rows[index].title == title then
                if type(have) == "number" and (type(rows[index].have) ~= "number" or have > rows[index].have) then
                    rows[index].have = have
                    rows[index].need = need
                end
                return
            end
        end
        rows[#rows + 1] = { title = title, have = have, need = need }
    end

    local function take(title, have, need, text, kind)
        kind = F.Plain(kind)
        if type(kind) == "string" then
            kind = string.lower(kind)
        else
            kind = nil
        end
        text = F.Plain(text)
        if type(text) ~= "string" then
            text = nil
        end
        if type(have) ~= "number" or type(need) ~= "number" then
            local parsedHave, parsedNeed = countsFrom(text)
            if type(have) ~= "number" then
                have = parsedHave
            end
            if type(need) ~= "number" then
                need = parsedNeed
            end
        end
        local name = objectiveName(text)
        if not name then
            return
        end
        if kind == "monster" or kind == "reputation" or kind == "event" or kind == "log" or kind == "player" then
            return
        end
        if kind ~= "item" and kind ~= nil and kind ~= "object" then
            return
        end
        if type(need) == "number" and (need < 1 or need > 200) and kind ~= "item" then
            return
        end
        title = F.Plain(title)
        if type(title) ~= "string" or title == "" then
            return
        end
        addQuest(name, title, have, need)
    end

    local function fromLog()
        if not (C_QuestLog and C_QuestLog.GetNumQuestLogEntries and C_QuestLog.GetInfo and C_QuestLog.GetQuestObjectives) then
            return false
        end
        local ok, count = pcall(C_QuestLog.GetNumQuestLogEntries)
        count = ok and countOf(count)
        if not count then
            return false
        end
        for index = 1, count do
            local infoOK, info = pcall(C_QuestLog.GetInfo, index)
            info = infoOK and F.Plain(info)
            if type(info) == "table" and not F.Plain(info.isHeader) then
                local questID = countOf(info.questID)
                local title = F.Plain(info.title)
                if (type(title) ~= "string" or title == "") and questID and C_QuestLog.GetTitleForQuestID then
                    local titleOK, value = pcall(C_QuestLog.GetTitleForQuestID, questID)
                    title = titleOK and F.Plain(value)
                end
                if questID and questID > 0 and type(title) == "string" then
                    local objOK, rows = pcall(C_QuestLog.GetQuestObjectives, questID)
                    rows = objOK and F.Plain(rows)
                    if type(rows) == "table" then
                        for _, objective in ipairs(rows) do
                            objective = F.Plain(objective)
                            if type(objective) == "table" then
                                take(title, countOf(objective.numFulfilled), countOf(objective.numRequired), objective.text, objective.type)
                            end
                        end
                    end
                end
            end
        end
        return true
    end

    local function fromBoard()
        if not (GetNumQuestLogEntries and GetQuestLogTitle and GetNumQuestLeaderBoards and GetQuestLogLeaderBoard) then
            return
        end
        local ok, num = pcall(GetNumQuestLogEntries)
        num = ok and countOf(num)
        if not num then
            return
        end
        for index = 1, num do
            local titleOK, title, _, _, isHeader = pcall(GetQuestLogTitle, index)
            if titleOK and not F.Plain(isHeader) then
                title = F.Plain(title)
                local boardsOK, boards = pcall(GetNumQuestLeaderBoards, index)
                boards = boardsOK and countOf(boards) or 0
                for objIndex = 1, boards do
                    local lineOK, text, kind = pcall(GetQuestLogLeaderBoard, objIndex, index)
                    if lineOK then
                        take(title, nil, nil, text, kind)
                    end
                end
            end
        end
    end

    local function refresh()
        questBy = {}
        fromLog()
        fromBoard()
    end

    local function plainName(text)
        text = F.Plain(text)
        if type(text) ~= "string" then
            return nil
        end
        text = string.gsub(text, "|c%x%x%x%x%x%x%x%x", "")
        text = string.gsub(text, "|r", "")
        local bracket = string.match(text, "%[(.-)%]")
        if bracket and bracket ~= "" then
            text = bracket
        else
            text = string.gsub(text, "|H.-|h(.-)|h", "%1")
        end
        text = string.gsub(text, "^%d+%s*x%s+", "")
        text = string.gsub(text, "%s*%(%d+%)$", "")
        text = string.gsub(text, "^%s+", "")
        text = string.gsub(text, "%s+$", "")
        if text == "" or string.find(text, "|", 1, true) then
            return nil
        end
        return text
    end

    local function tipName(tooltip)
        if tooltip.GetItem then
            local ok, name, link = pcall(tooltip.GetItem, tooltip)
            if ok then
                local fromLink = plainName(link)
                if fromLink then
                    return fromLink
                end
                local fromName = plainName(name)
                if fromName then
                    return fromName
                end
            end
        end
        local frameName = tooltip.GetName and tooltip:GetName()
        if not frameName then
            return nil
        end
        local line = _G[frameName .. "TextLeft1"]
        if not line or not line.GetText then
            return nil
        end
        return plainName(line:GetText())
    end

    local function tipHas(tooltip, prefix)
        local frameName = tooltip.GetName and tooltip:GetName()
        if not frameName or not tooltip.NumLines then
            return false
        end
        local ok, lines = pcall(tooltip.NumLines, tooltip)
        lines = ok and lines or 0
        for index = 1, lines do
            local left = _G[frameName .. "TextLeft" .. index]
            local text = left and left.GetText and left:GetText()
            text = F.Plain(text)
            if type(text) == "string" and string.sub(text, 1, #prefix) == prefix then
                return true
            end
        end
        return false
    end

    local function questLine(row)
        local line = "Quest: " .. row.title
        if type(row.have) == "number" and type(row.need) == "number" and row.need > 0 then
            if row.have >= row.need then
                line = line .. " (done)"
            else
                local have = row.have
                if have < 0 then
                    have = 0
                end
                line = line .. " (" .. have .. "/" .. row.need .. ")"
            end
        end
        return line
    end

    local function cookLine(list)
        if #list > 3 then
            return "Cooking: used in " .. #list .. " recipes"
        end
        local line = "Cooking: " .. list[1]
        for index = 2, #list do
            line = line .. ", " .. list[index]
        end
        return line
    end

    local function paint(tooltip)
        if not tooltip or tooltip.nfUseBusy or not F.Enabled("itemUses") then
            return
        end
        if tipHas(tooltip, "Quest: ") or tipHas(tooltip, "Cooking: ") then
            return
        end
        local name = tipName(tooltip)
        if not name then
            return
        end
        local quests = questBy[singular(name)]
        local foods = cookBy[norm(name)]
        if not quests and not foods then
            return
        end
        tooltip.nfUseBusy = true
        local added = 0
        if quests then
            for index = 1, #quests do
                if index > 3 then
                    break
                end
                pcall(tooltip.AddLine, tooltip, questLine(quests[index]), 1, 0.82, 0, true)
                added = added + 1
            end
        end
        if foods then
            pcall(tooltip.AddLine, tooltip, cookLine(foods), 1, 0.72, 0.35, true)
            added = added + 1
        end
        local shown = false
        if added > 0 and tooltip.IsShown then
            local ok, value = pcall(tooltip.IsShown, tooltip)
            shown = ok and value and true or false
        end
        if shown and tooltip.GetHeight and tooltip.SetHeight then
            local ok, height = pcall(tooltip.GetHeight, tooltip)
            if ok and type(height) == "number" and height > 0 then
                pcall(tooltip.SetHeight, tooltip, height + added * 16)
            end
        end
        tooltip.nfUseBusy = nil
    end

    local function hookOne(tooltip)
        if not tooltip or tooltip.nfUseHooked then
            return
        end
        tooltip.nfUseHooked = true
        if tooltip.HookScript then
            pcall(tooltip.HookScript, tooltip, "OnTooltipSetItem", function(self)
                paint(self)
            end)
        end
        -- Bags and loot on this client set the tooltip by method. The script
        -- above covers the same path when the client has it. A second pass
        -- sees the line already there and leaves it.
        local methods = {
            "SetBagItem",
            "SetLootItem",
            "SetHyperlink",
            "SetInventoryItem",
            "SetQuestItem",
            "SetQuestLogItem",
            "SetMerchantItem",
            "SetBuybackItem",
            "SetAuctionItem",
            "SetInboxItem",
            "SetSendMailItem",
            "SetCraftItem",
            "SetTradePlayerItem",
            "SetTradeTargetItem",
        }
        for index = 1, #methods do
            local method = methods[index]
            local orig = tooltip[method]
            if type(orig) == "function" then
                tooltip[method] = function(self, ...)
                    local a, b, c, d, e, f, g, h = orig(self, ...)
                    pcall(paint, self)
                    return a, b, c, d, e, f, g, h
                end
            end
        end
    end

    hookOne(GameTooltip)
    hookOne(ItemRefTooltip)
    if TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall and Enum and Enum.TooltipDataType and Enum.TooltipDataType.Item then
        pcall(TooltipDataProcessor.AddTooltipPostCall, Enum.TooltipDataType.Item, function(tooltip)
            paint(tooltip)
        end)
    end

    local watch = CreateFrame("Frame")
    local function listen(event)
        pcall(watch.RegisterEvent, watch, event)
    end
    listen("PLAYER_LOGIN")
    listen("PLAYER_ENTERING_WORLD")
    listen("QUEST_LOG_UPDATE")
    listen("QUEST_ACCEPTED")
    listen("QUEST_REMOVED")
    watch:SetScript("OnEvent", function()
        hookOne(GameTooltip)
        hookOne(ItemRefTooltip)
        refresh()
    end)
    refresh()

    if F.BuildMessagesPage then
        local buildMessages = F.BuildMessagesPage
        function F.BuildMessagesPage(page)
            page = buildMessages(page)
            local check = F.CreateCheck(page, "Item uses", 14, -254, "itemUses")
            check:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText("Item uses", F.BorderColor())
                GameTooltip:AddLine("On an item in your bags, in loot, or on a chat link. A quest drop names the quest and your progress, such as 3/8. Meat, fish, and other cooking goods name the dish. A spice used in many dishes says how many. Uncheck this to turn the lines off.", 1, 1, 1, true)
                GameTooltip:Show()
            end)
            check:SetScript("OnLeave", GameTooltip_Hide)
            return page
        end
    end
end

F.InstallItemUses()
