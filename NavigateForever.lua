-- Navigate Forever
-- A bigger square minimap for WoW Forever.
-- The game draws one square. Scale enlarges that square.
-- Changing the frame size leaves the terrain at its old size.
-- The square and the settings window also follow the screen resolution.

local F = {}

local addonName = ...
select(2, ...).F = F

local MIN_SCALE, MAX_SCALE = 0.75, 2.4
local MIN_ALPHA = 0.15
local HEADER_H = 24
local ROUND_MASK = "Textures\\MinimapMask"
local SQUARE_MASK = "Interface\\BUTTONS\\WHITE8X8"

local GOLD_R, GOLD_G, GOLD_B = 0.831, 0.686, 0.216
local NAVY_R, NAVY_G, NAVY_B = 0.059, 0.090, 0.165
local BLUE_R, BLUE_G, BLUE_B = 0.180, 0.659, 1
local ICON = "Interface\\AddOns\\NavigateForever\\Media\\icon"
local MEDIA = "Interface\\AddOns\\NavigateForever\\Media\\"

F.RING_MIN = 5
F.RING_MAX = 120
F.RING_COLORS = {
    { 0.95, 0.82, 0.40 },
    { 0.45, 0.75, 1 },
    { 0.42, 0.86, 0.55 },
}
F.ringRows = {}

F.THEMES = {
    {
        id = "default",
        label = "Default",
        menu = { NAVY_R, NAVY_G, NAVY_B },
        border = { GOLD_R, GOLD_G, GOLD_B },
        hover = { BLUE_R, BLUE_G, BLUE_B },
        bright = { 1, 0.96, 0.82 },
        track = { 0.2, 0.24, 0.32 },
        arrow = { 1, 1, 1 },
    },
    {
        id = "undead",
        label = "Undead",
        group = "race",
        menu = { 0.055, 0.045, 0.070 },
        border = { 0.52, 0.80, 0.26 },
        hover = { 0.62, 0.36, 0.86 },
        bright = { 0.86, 1, 0.70 },
        track = { 0.20, 0.16, 0.24 },
        arrow = { 0.55, 1, 0.45 },
        icon = MEDIA .. "theme-undead-logo",
        grain = "Interface\\DialogFrame\\UI-DialogBox-Background",
        grainColor = { 0.45, 0.85, 0.35, 0.22 },
        corner = MEDIA .. "theme-undead-corner",
        cornerTint = { 1, 1, 1 },
        mist = { 0.45, 0.95, 0.40, 0.22 },
        flame = { 0.45, 1, 0.35 },
        pulse = true,
        particles = { tex = "theme-spark", color = { 0.50, 1, 0.40 }, mode = "rise", speed = 9, size = { 3, 7 } },
    },
    {
        id = "horde",
        label = "Horde",
        menu = { 0.090, 0.030, 0.030 },
        border = { 0.80, 0.14, 0.10 },
        hover = { 0.66, 0.64, 0.60 },
        bright = { 1, 0.86, 0.76 },
        track = { 0.26, 0.10, 0.09 },
        arrow = { 1, 0.55, 0.45 },
        icon = MEDIA .. "theme-horde-logo",
        grain = "Interface\\DialogFrame\\UI-DialogBox-Background",
        grainColor = { 1, 0.40, 0.25, 0.20 },
        corner = MEDIA .. "theme-horde-corner",
        cornerTint = { 1, 1, 1 },
        mist = { 1, 0.35, 0.12, 0.16 },
        flame = { 1, 0.45, 0.10 },
        pulse = true,
        particles = { tex = "theme-spark", color = { 1, 0.55, 0.15 }, mode = "rise", speed = 24, size = { 2, 5 } },
    },
    {
        id = "alliance",
        label = "Alliance",
        menu = { 0.050, 0.090, 0.260 },
        border = { 0.94, 0.78, 0.32 },
        hover = { 0.42, 0.64, 1 },
        bright = { 1, 0.97, 0.86 },
        track = { 0.14, 0.20, 0.38 },
        arrow = { 1, 0.95, 0.80 },
        icon = MEDIA .. "theme-alliance-logo",
        grain = "Interface\\DialogFrame\\UI-DialogBox-Background",
        grainColor = { 0.55, 0.70, 1, 0.20 },
        corner = MEDIA .. "theme-alliance-corner",
        cornerTint = { 1, 1, 1 },
        mist = { 1, 0.85, 0.50, 0.12 },
        flame = { 1, 0.85, 0.40 },
        pulse = true,
        particles = { tex = "theme-spark", color = { 1, 0.88, 0.50 }, mode = "rise", speed = 7, size = { 3, 6 } },
    },
    {
        id = "nightelf",
        label = "Night Elf",
        group = "race",
        menu = { 0.065, 0.040, 0.120 },
        border = { 0.72, 0.58, 0.96 },
        hover = { 0.26, 0.86, 0.80 },
        bright = { 0.88, 0.96, 1 },
        track = { 0.18, 0.13, 0.28 },
        arrow = { 0.78, 0.72, 1 },
        icon = MEDIA .. "theme-nightelf-logo",
        grain = "Interface\\DialogFrame\\UI-DialogBox-Background",
        grainColor = { 0.55, 0.45, 1, 0.22 },
        corner = MEDIA .. "theme-nightelf-corner",
        cornerTint = { 1, 1, 1 },
        mist = { 0.50, 0.40, 1, 0.20 },
        flame = { 0.45, 0.95, 0.90 },
        pulse = true,
        particles = { tex = "theme-spark", color = { 0.40, 1, 0.90 }, mode = "wander", speed = 12, size = { 4, 8 } },
    },
    {
        id = "arcane",
        label = "Arcane",
        menu = { 0.055, 0.030, 0.110 },
        border = { 0.36, 0.86, 1 },
        hover = { 0.78, 0.42, 1 },
        bright = { 0.90, 0.97, 1 },
        track = { 0.16, 0.10, 0.28 },
        arrow = { 0.58, 0.90, 1 },
        icon = MEDIA .. "theme-arcane-logo",
        grain = "Interface\\DialogFrame\\UI-DialogBox-Background",
        grainColor = { 0.65, 0.40, 1, 0.22 },
        corner = MEDIA .. "theme-arcane-corner",
        cornerTint = { 1, 1, 1 },
        mist = { 0.60, 0.35, 1, 0.20 },
        flame = { 0.70, 0.45, 1 },
        pulse = true,
        particles = { tex = "theme-star", color = { 0.60, 0.85, 1 }, mode = "twinkle", speed = 2.2, size = { 8, 16 } },
    },
    {
        id = "frost",
        label = "Frost",
        menu = { 0.045, 0.085, 0.125 },
        border = { 0.72, 0.90, 1 },
        hover = { 0.34, 0.64, 1 },
        bright = { 0.94, 0.99, 1 },
        track = { 0.15, 0.22, 0.30 },
        arrow = { 0.72, 0.90, 1 },
        icon = MEDIA .. "theme-frost-logo",
        grain = "Interface\\DialogFrame\\UI-DialogBox-Background",
        grainColor = { 0.70, 0.90, 1, 0.20 },
        corner = MEDIA .. "theme-frost-corner",
        cornerTint = { 1, 1, 1 },
        mist = { 0.75, 0.90, 1, 0.20 },
        flame = { 0.55, 0.80, 1 },
        pulse = true,
        particles = { tex = "theme-snow", color = { 0.85, 0.95, 1 }, mode = "fall", speed = 14, size = { 6, 11 } },
    },
    {
        id = "fire",
        label = "Fire",
        menu = { 0.100, 0.040, 0.020 },
        border = { 1, 0.55, 0.12 },
        hover = { 1, 0.85, 0.30 },
        bright = { 1, 0.94, 0.75 },
        track = { 0.30, 0.12, 0.06 },
        arrow = { 1, 0.60, 0.25 },
        icon = MEDIA .. "theme-fire-logo",
        grain = "Interface\\DialogFrame\\UI-DialogBox-Background",
        grainColor = { 1, 0.45, 0.15, 0.22 },
        corner = MEDIA .. "theme-fire-corner",
        cornerTint = { 1, 1, 1 },
        mist = { 1, 0.40, 0.10, 0.20 },
        flame = { 1, 0.55, 0.10 },
        pulse = true,
        particles = { tex = "theme-spark", color = { 1, 0.60, 0.15 }, mode = "rise", speed = 32, size = { 3, 7 } },
    },
    {
        id = "kitty",
        label = "Kitty",
        menu = { 0.200, 0.060, 0.140 },
        border = { 1, 0.50, 0.80 },
        hover = { 0.85, 0.65, 1 },
        bright = { 1, 0.92, 0.97 },
        track = { 0.42, 0.14, 0.30 },
        arrow = { 1, 0.55, 0.85 },
        icon = MEDIA .. "theme-kitty-logo",
        grain = "Interface\\DialogFrame\\UI-DialogBox-Background",
        grainColor = { 1, 0.55, 0.85, 0.24 },
        corner = MEDIA .. "theme-kitty-corner",
        cornerBottom = MEDIA .. "theme-kitty-bottom",
        cornerTint = { 1, 1, 1 },
        mist = { 1, 0.45, 0.80, 0.26 },
        flame = { 1, 0.50, 0.80 },
        pulse = true,
        particles = { tex = "theme-cat", texs = { "theme-cat", "theme-heart", "theme-paw" }, dense = true, color = { 1, 0.62, 0.85 }, mode = "rise", speed = 10, size = { 9, 15 }, blend = "BLEND", spin = "sway" },
    },
    {
        id = "blizzard",
        label = "Classic UI",
        menu = { 0.060, 0.060, 0.060 },
        border = { 1, 0.82, 0 },
        hover = { 1, 1, 1 },
        bright = { 1, 1, 1 },
        track = { 0.22, 0.18, 0.08 },
        arrow = { 1, 0.82, 0 },
        icon = MEDIA .. "theme-blizzard-logo",
        grain = "Interface\\DialogFrame\\UI-DialogBox-Background",
        grainBlend = "BLEND",
        grainColor = { 1, 1, 1, 1 },
        corner = MEDIA .. "theme-blizzard-corner",
        cornerTint = { 1, 1, 1 },
    },
    {
        id = "warrior",
        label = "Warrior",
        group = "class",
        menu = { 0.090, 0.070, 0.050 },
        border = { 0.78, 0.61, 0.43 },
        hover = { 0.85, 0.25, 0.15 },
        bright = { 1, 0.93, 0.82 },
        track = { 0.24, 0.19, 0.14 },
        arrow = { 1, 0.85, 0.65 },
        icon = MEDIA .. "theme-warrior-logo",
        grain = "Interface\\DialogFrame\\UI-DialogBox-Background",
        grainColor = { 0.85, 0.65, 0.45, 0.20 },
        corner = MEDIA .. "theme-warrior-corner",
        cornerTint = { 1, 1, 1 },
        mist = { 0.80, 0.50, 0.25, 0.12 },
        flame = { 1, 0.55, 0.20 },
        pulse = true,
        particles = { tex = "theme-spark", color = { 1, 0.70, 0.30 }, mode = "rise", speed = 30, size = { 2, 4 } },
    },
    {
        id = "paladin",
        label = "Paladin",
        group = "class",
        menu = { 0.100, 0.070, 0.090 },
        border = { 0.96, 0.55, 0.73 },
        hover = { 1, 0.85, 0.40 },
        bright = { 1, 0.96, 0.88 },
        track = { 0.28, 0.18, 0.22 },
        arrow = { 1, 0.85, 0.90 },
        icon = MEDIA .. "theme-paladin-logo",
        grain = "Interface\\DialogFrame\\UI-DialogBox-Background",
        grainColor = { 1, 0.80, 0.60, 0.18 },
        corner = MEDIA .. "theme-paladin-corner",
        cornerTint = { 1, 1, 1 },
        mist = { 1, 0.85, 0.55, 0.12 },
        flame = { 1, 0.85, 0.45 },
        pulse = true,
        particles = { tex = "theme-star", color = { 1, 0.88, 0.55 }, mode = "fall", speed = 9, size = { 7, 13 } },
    },
    {
        id = "hunter",
        label = "Hunter",
        group = "class",
        menu = { 0.060, 0.080, 0.040 },
        border = { 0.67, 0.83, 0.45 },
        hover = { 0.85, 0.62, 0.30 },
        bright = { 0.95, 1, 0.85 },
        track = { 0.17, 0.22, 0.12 },
        arrow = { 0.85, 1, 0.70 },
        icon = MEDIA .. "theme-hunter-logo",
        grain = "Interface\\DialogFrame\\UI-DialogBox-Background",
        grainColor = { 0.60, 0.80, 0.40, 0.20 },
        corner = MEDIA .. "theme-hunter-corner",
        cornerTint = { 1, 1, 1 },
        mist = { 0.55, 0.75, 0.35, 0.14 },
        flame = { 0.75, 0.90, 0.40 },
        pulse = true,
        particles = { tex = "theme-leaf", color = { 0.60, 0.80, 0.35 }, mode = "blow", speed = 22, size = { 8, 13 }, blend = "BLEND", spin = "tumble" },
    },
    {
        id = "rogue",
        label = "Rogue",
        group = "class",
        menu = { 0.060, 0.060, 0.050 },
        border = { 1, 0.96, 0.41 },
        hover = { 0.55, 0.85, 0.25 },
        bright = { 1, 1, 0.85 },
        track = { 0.20, 0.20, 0.14 },
        arrow = { 1, 0.98, 0.60 },
        icon = MEDIA .. "theme-rogue-logo",
        grain = "Interface\\DialogFrame\\UI-DialogBox-Background",
        grainColor = { 0.70, 0.75, 0.45, 0.18 },
        corner = MEDIA .. "theme-rogue-corner",
        cornerTint = { 1, 1, 1 },
        mist = { 0.40, 0.45, 0.30, 0.14 },
        flame = { 0.80, 1, 0.30 },
        pulse = true,
        particles = { tex = "theme-bubble", color = { 0.70, 0.95, 0.30 }, mode = "rise", speed = 10, size = { 5, 10 } },
    },
    {
        id = "priest",
        label = "Priest",
        group = "class",
        menu = { 0.100, 0.100, 0.120 },
        border = { 0.98, 0.97, 0.92 },
        hover = { 1, 0.85, 0.45 },
        bright = { 1, 1, 1 },
        track = { 0.26, 0.26, 0.30 },
        arrow = { 1, 1, 0.95 },
        icon = MEDIA .. "theme-priest-logo",
        grain = "Interface\\DialogFrame\\UI-DialogBox-Background",
        grainColor = { 1, 0.95, 0.85, 0.16 },
        corner = MEDIA .. "theme-priest-corner",
        cornerTint = { 1, 1, 1 },
        mist = { 1, 0.95, 0.85, 0.12 },
        flame = { 1, 0.95, 0.75 },
        pulse = true,
        particles = { tex = "theme-feather", color = { 1, 1, 1 }, mode = "fall", speed = 10, size = { 10, 16 }, blend = "BLEND", spin = "sway" },
    },
    {
        id = "shaman",
        label = "Shaman",
        group = "class",
        menu = { 0.030, 0.060, 0.110 },
        border = { 0.15, 0.55, 1 },
        hover = { 0.95, 0.75, 0.35 },
        bright = { 0.85, 0.95, 1 },
        track = { 0.10, 0.18, 0.30 },
        arrow = { 0.60, 0.80, 1 },
        icon = MEDIA .. "theme-shaman-logo",
        grain = "Interface\\DialogFrame\\UI-DialogBox-Background",
        grainColor = { 0.40, 0.60, 1, 0.20 },
        corner = MEDIA .. "theme-shaman-corner",
        cornerTint = { 1, 1, 1 },
        mist = { 0.30, 0.55, 1, 0.16 },
        flame = { 0.45, 0.70, 1 },
        pulse = true,
        particles = { tex = "theme-star", color = { 0.55, 0.80, 1 }, mode = "twinkle", speed = 4.5, size = { 6, 12 } },
    },
    {
        id = "mage",
        label = "Mage",
        group = "class",
        menu = { 0.040, 0.070, 0.130 },
        border = { 0.25, 0.78, 0.92 },
        hover = { 0.80, 0.85, 1 },
        bright = { 0.88, 0.98, 1 },
        track = { 0.12, 0.20, 0.30 },
        arrow = { 0.60, 0.90, 1 },
        icon = MEDIA .. "theme-mage-logo",
        grain = "Interface\\DialogFrame\\UI-DialogBox-Background",
        grainColor = { 0.45, 0.70, 1, 0.20 },
        corner = MEDIA .. "theme-mage-corner",
        cornerTint = { 1, 1, 1 },
        mist = { 0.35, 0.65, 1, 0.16 },
        flame = { 0.50, 0.85, 1 },
        pulse = true,
        particles = { tex = "theme-star", color = { 0.55, 0.85, 1 }, mode = "rise", speed = 8, size = { 6, 11 } },
    },
    {
        id = "warlock",
        label = "Warlock",
        group = "class",
        menu = { 0.060, 0.040, 0.090 },
        border = { 0.53, 0.53, 0.93 },
        hover = { 0.75, 0.35, 1 },
        bright = { 0.90, 0.86, 1 },
        track = { 0.17, 0.13, 0.26 },
        arrow = { 0.75, 0.60, 1 },
        icon = MEDIA .. "theme-warlock-logo",
        grain = "Interface\\DialogFrame\\UI-DialogBox-Background",
        grainColor = { 0.60, 0.40, 1, 0.22 },
        corner = MEDIA .. "theme-warlock-corner",
        cornerTint = { 1, 1, 1 },
        mist = { 0.50, 0.25, 0.90, 0.20 },
        flame = { 0.65, 0.30, 1 },
        pulse = true,
        particles = { tex = "theme-spark", color = { 0.65, 0.35, 1 }, mode = "wander", speed = 14, size = { 4, 8 } },
    },
    {
        id = "druid",
        label = "Druid",
        group = "class",
        menu = { 0.080, 0.060, 0.030 },
        border = { 1, 0.49, 0.04 },
        hover = { 0.55, 0.85, 0.35 },
        bright = { 1, 0.93, 0.80 },
        track = { 0.24, 0.16, 0.08 },
        arrow = { 1, 0.75, 0.45 },
        icon = MEDIA .. "theme-druid-logo",
        grain = "Interface\\DialogFrame\\UI-DialogBox-Background",
        grainColor = { 0.80, 0.65, 0.35, 0.20 },
        corner = MEDIA .. "theme-druid-corner",
        cornerTint = { 1, 1, 1 },
        mist = { 0.60, 0.75, 0.30, 0.14 },
        flame = { 1, 0.70, 0.25 },
        pulse = true,
        particles = { tex = "theme-spark", color = { 0.85, 1, 0.45 }, mode = "wander", speed = 10, size = { 3, 7 } },
    },
    {
        id = "human",
        label = "Human",
        group = "race",
        menu = { 0.050, 0.070, 0.140 },
        border = { 0.62, 0.74, 1 },
        hover = { 1, 0.82, 0.35 },
        bright = { 0.94, 0.96, 1 },
        track = { 0.14, 0.18, 0.32 },
        arrow = { 0.70, 0.82, 1 },
        icon = MEDIA .. "theme-human-logo",
        grain = "Interface\\DialogFrame\\UI-DialogBox-Background",
        grainColor = { 0.60, 0.70, 1, 0.18 },
        corner = MEDIA .. "theme-human-corner",
        cornerTint = { 1, 1, 1 },
        mist = { 0.70, 0.80, 1, 0.12 },
        flame = { 1, 0.82, 0.40 },
        pulse = true,
        particles = { tex = "theme-leaf", color = { 1, 0.72, 0.30 }, mode = "blow", speed = 18, size = { 8, 12 }, blend = "BLEND", spin = "tumble" },
    },
    {
        id = "dwarf",
        label = "Dwarf",
        group = "race",
        menu = { 0.090, 0.065, 0.040 },
        border = { 0.85, 0.58, 0.28 },
        hover = { 0.55, 0.78, 1 },
        bright = { 1, 0.92, 0.78 },
        track = { 0.26, 0.18, 0.10 },
        arrow = { 1, 0.70, 0.40 },
        icon = MEDIA .. "theme-dwarf-logo",
        grain = "Interface\\DialogFrame\\UI-DialogBox-Background",
        grainColor = { 0.85, 0.65, 0.45, 0.20 },
        corner = MEDIA .. "theme-dwarf-corner",
        cornerTint = { 1, 1, 1 },
        mist = { 0.85, 0.90, 1, 0.12 },
        flame = { 1, 0.55, 0.20 },
        pulse = true,
        particles = { tex = "theme-snow", color = { 0.90, 0.95, 1 }, mode = "fall", speed = 11, size = { 5, 9 } },
    },
    {
        id = "gnome",
        label = "Gnome",
        group = "race",
        menu = { 0.040, 0.080, 0.090 },
        border = { 0.35, 0.90, 0.78 },
        hover = { 1, 0.75, 0.35 },
        bright = { 0.88, 1, 0.98 },
        track = { 0.10, 0.24, 0.24 },
        arrow = { 0.45, 1, 0.85 },
        icon = MEDIA .. "theme-gnome-logo",
        grain = "Interface\\DialogFrame\\UI-DialogBox-Background",
        grainColor = { 0.45, 0.85, 0.80, 0.18 },
        corner = MEDIA .. "theme-gnome-corner",
        cornerTint = { 1, 1, 1 },
        mist = { 0.35, 0.90, 0.80, 0.14 },
        flame = { 0.40, 1, 0.85 },
        pulse = true,
        particles = { tex = "theme-gear", color = { 0.85, 0.70, 0.40 }, mode = "wander", speed = 10, size = { 8, 14 }, blend = "BLEND", spin = "tumble" },
    },
    {
        id = "orc",
        label = "Orc",
        group = "race",
        menu = { 0.070, 0.060, 0.030 },
        border = { 0.62, 0.80, 0.28 },
        hover = { 0.90, 0.28, 0.18 },
        bright = { 0.95, 1, 0.82 },
        track = { 0.20, 0.18, 0.08 },
        arrow = { 0.75, 0.95, 0.35 },
        icon = MEDIA .. "theme-orc-logo",
        grain = "Interface\\DialogFrame\\UI-DialogBox-Background",
        grainColor = { 0.80, 0.55, 0.30, 0.22 },
        corner = MEDIA .. "theme-orc-corner",
        cornerTint = { 1, 1, 1 },
        mist = { 0.85, 0.50, 0.25, 0.16 },
        flame = { 1, 0.40, 0.15 },
        pulse = true,
        particles = { tex = "theme-spark", color = { 0.90, 0.65, 0.40 }, mode = "blow", speed = 34, size = { 2, 5 } },
    },
    {
        id = "troll",
        label = "Troll",
        group = "race",
        menu = { 0.030, 0.070, 0.070 },
        border = { 0.30, 0.82, 0.76 },
        hover = { 1, 0.55, 0.20 },
        bright = { 0.88, 1, 0.96 },
        track = { 0.08, 0.22, 0.22 },
        arrow = { 0.40, 1, 0.85 },
        icon = MEDIA .. "theme-troll-logo",
        grain = "Interface\\DialogFrame\\UI-DialogBox-Background",
        grainColor = { 0.35, 0.80, 0.75, 0.20 },
        corner = MEDIA .. "theme-troll-corner",
        cornerTint = { 1, 1, 1 },
        mist = { 0.25, 0.85, 0.75, 0.18 },
        flame = { 0.30, 1, 0.85 },
        pulse = true,
        particles = { tex = "theme-spark", color = { 0.35, 1, 0.80 }, mode = "wander", speed = 13, size = { 4, 8 } },
    },
    {
        id = "tauren",
        label = "Tauren",
        group = "race",
        menu = { 0.080, 0.055, 0.035 },
        border = { 0.88, 0.66, 0.38 },
        hover = { 0.30, 0.82, 0.82 },
        bright = { 1, 0.93, 0.82 },
        track = { 0.24, 0.16, 0.10 },
        arrow = { 1, 0.75, 0.45 },
        icon = MEDIA .. "theme-tauren-logo",
        grain = "Interface\\DialogFrame\\UI-DialogBox-Background",
        grainColor = { 0.85, 0.60, 0.40, 0.20 },
        corner = MEDIA .. "theme-tauren-corner",
        cornerTint = { 1, 1, 1 },
        mist = { 0.90, 0.70, 0.45, 0.12 },
        flame = { 1, 0.65, 0.30 },
        pulse = true,
        particles = { tex = "theme-feather", color = { 0.90, 0.65, 0.45 }, mode = "blow", speed = 16, size = { 10, 15 }, blend = "BLEND", spin = "tumble" },
    },
    {
        id = "skyborne",
        label = "Skyborne",
        group = "race",
        menu = { 0.035, 0.070, 0.120 },
        border = { 0.92, 0.84, 0.60 },
        hover = { 0.45, 0.88, 1 },
        bright = { 0.92, 0.98, 1 },
        track = { 0.10, 0.18, 0.28 },
        arrow = { 0.55, 0.88, 1 },
        icon = MEDIA .. "theme-skyborne-logo",
        grain = "Interface\\DialogFrame\\UI-DialogBox-Background",
        grainColor = { 0.55, 0.80, 1, 0.20 },
        corner = MEDIA .. "theme-skyborne-corner",
        cornerTint = { 1, 1, 1 },
        mist = { 0.60, 0.85, 1, 0.18 },
        flame = { 0.55, 0.90, 1 },
        pulse = true,
        particles = { texs = { "theme-feather", "theme-spark" }, color = { 0.85, 0.95, 1 }, mode = "blow", speed = 24, size = { 7, 13 }, blend = "BLEND", spin = "tumble" },
    },
    {
        id = "hallowsend",
        label = "Hallow's End",
        group = "holiday",
        menu = { 0.070, 0.040, 0.090 },
        border = { 1, 0.55, 0.10 },
        hover = { 0.65, 0.40, 0.95 },
        bright = { 1, 0.90, 0.70 },
        track = { 0.22, 0.12, 0.24 },
        arrow = { 1, 0.60, 0.20 },
        icon = MEDIA .. "theme-hallowsend-logo",
        grain = "Interface\\DialogFrame\\UI-DialogBox-Background",
        grainColor = { 0.60, 0.35, 0.80, 0.20 },
        corner = MEDIA .. "theme-hallowsend-corner",
        cornerTint = { 1, 1, 1 },
        mist = { 0.45, 0.25, 0.65, 0.20 },
        flame = { 1, 0.55, 0.10 },
        pulse = true,
        particles = { tex = "theme-bat", color = { 0.45, 0.30, 0.55 }, mode = "wander", speed = 18, size = { 10, 16 }, blend = "BLEND" },
    },
    {
        id = "winterveil",
        label = "Winter Veil",
        group = "holiday",
        menu = { 0.100, 0.030, 0.040 },
        border = { 1, 0.32, 0.28 },
        hover = { 0.35, 0.75, 0.40 },
        bright = { 1, 0.95, 0.90 },
        track = { 0.28, 0.08, 0.08 },
        arrow = { 1, 0.40, 0.35 },
        icon = MEDIA .. "theme-winterveil-logo",
        grain = "Interface\\DialogFrame\\UI-DialogBox-Background",
        grainColor = { 1, 0.80, 0.80, 0.15 },
        corner = MEDIA .. "theme-winterveil-corner",
        cornerTint = { 1, 1, 1 },
        mist = { 1, 1, 1, 0.12 },
        flame = { 1, 0.85, 0.50 },
        pulse = true,
        particles = { tex = "theme-snow", color = { 1, 1, 1 }, mode = "fall", speed = 12, size = { 5, 10 } },
    },
    {
        id = "lunarfestival",
        label = "Lunar Festival",
        group = "holiday",
        menu = { 0.120, 0.030, 0.030 },
        border = { 1, 0.80, 0.30 },
        hover = { 1, 0.30, 0.20 },
        bright = { 1, 0.96, 0.80 },
        track = { 0.32, 0.10, 0.06 },
        arrow = { 1, 0.75, 0.30 },
        icon = MEDIA .. "theme-lunarfestival-logo",
        grain = "Interface\\DialogFrame\\UI-DialogBox-Background",
        grainColor = { 1, 0.60, 0.30, 0.20 },
        corner = MEDIA .. "theme-lunarfestival-corner",
        cornerTint = { 1, 1, 1 },
        mist = { 1, 0.35, 0.15, 0.16 },
        flame = { 1, 0.45, 0.15 },
        pulse = true,
        particles = { tex = "theme-star", color = { 1, 0.82, 0.35 }, mode = "twinkle", speed = 3.5, size = { 8, 16 } },
    },
    {
        id = "loveintheair",
        label = "Love is in the Air",
        group = "holiday",
        menu = { 0.110, 0.030, 0.060 },
        border = { 1, 0.40, 0.60 },
        hover = { 1, 0.80, 0.40 },
        bright = { 1, 0.90, 0.94 },
        track = { 0.30, 0.08, 0.16 },
        arrow = { 1, 0.45, 0.65 },
        icon = MEDIA .. "theme-loveintheair-logo",
        grain = "Interface\\DialogFrame\\UI-DialogBox-Background",
        grainColor = { 1, 0.50, 0.70, 0.18 },
        corner = MEDIA .. "theme-loveintheair-corner",
        cornerTint = { 1, 1, 1 },
        mist = { 1, 0.35, 0.55, 0.16 },
        flame = { 1, 0.40, 0.60 },
        pulse = true,
        particles = { tex = "theme-heart", color = { 1, 0.40, 0.60 }, mode = "rise", speed = 10, size = { 7, 12 }, spin = "sway" },
    },
}

local DEFAULTS = {
    scale = 1.5,
    alpha = 1,
    point = "BOTTOM",
    relPoint = "BOTTOM",
    x = 0,
    y = 210,
    locked = true,
    hintShown = false,
    warnPin = true,
    warnArrive = true,
    warnMurloc = true,
    warnDanger = true,
    warnPvp = true,
    warnSanctuary = true,
    warnInstance = true,
    warnElite = true,
    warnBoss = true,
    warnWeather = true,
    warnQuest = true,
    warnCampfire = true,
    warnRepair = true,
    warnRare = true,
    campfireSound = "ready",
    deathMarker = true,
    deathSpirit = true,
    questDiamond = true,
    questMarks = true,
    fadeMove = true,
    alphaMove = 0.5,
    alphaCombat = 0.9,
    rings = true,
    ring1 = true,
    ring2 = true,
    ring3 = true,
    ring1Yards = 20,
    ring2Yards = 40,
    ring3Yards = 60,
    gatherSwap = true,
    gatherSeconds = 4,
    theme = "default",
    animate = true,
}

local QUIPS = {
    "Recalculating route...",
    "Avoiding murloc congestion...",
    "Searching for shortest path to loot...",
    "Estimated arrival: eventually.",
    "Route may contain hostile NPCs.",
    "Route may contain murlocs.",
    "Estimated arrival: whenever you stop pulling extra mobs.",
}

F.JOKES = {
    "Why did the route recalculate? You pulled extra mobs. It took that personally.",
    "Shortest path to loot: straight through the loot. The loot has friends.",
    "Estimated arrival: soon. Soon was last seen near a murloc.",
    "I turned the map. The continent stayed put. Uncooperative.",
    "You are not lost. You are on the scenic corpse run.",
    "Recalculating. Still murlocs. These ones brought notes.",
    "Drop a pin. Now you are lost next to a pin. Progress.",
    "The arrow knows the way. The arrow has not met the cave yet.",
    "North, south, east, and whatever that quest marker is pointing at.",
    "I plotted a safe road. You found a quest mob. The road resigned.",
    "Arrival updated. The new estimate is eventually, same as the old estimate.",
    "Follow the gold ring. If something bites you, that was the close one.",
    "A straight line is fastest. Azeroth filed a complaint.",
    "You have reached your destination. It walked off. Recalculating.",
    "The map says you are here. So do the murlocs. Worry about the murlocs.",
    "Turn left at the corpse. You will recognize it.",
}

local ROW_KEYS = {
    "QueueStatusMinimapButton",
    "InstanceDifficulty",
    "IndicatorFrame",
    "ExpansionLandingPageMinimapButton",
    "GarrisonLandingPageMinimapButton",
}

local HIDE_KEYS = {
    "MinimapBorder",
    "MinimapBorderTop",
    "MinimapCompassTexture",
    "MinimapNorthTag",
}

local db
local charDb
local cluster, container, map
local header, border, grip, brandButton, goldEdges, dock, popButton, buttonBag, driver, panel, nav
local navZone, navPlace, navRoute, pinMark, deathMark, rangeHost, mapFrame
local pinArmed = false
local lastLifeX, lastLifeY, lastLifeInstance
local widthSlider, heightSlider, alphaSlider, arrowSlider
local moveSlider, combatSlider, fadeCheck
local widthText, heightText, alphaText, arrowText, lockCheck
local moveText, combatText
local optionChecks = {}
local remembered = {}
local hiddenShown = {}
local stock = { captured = false, rings = {} }
local ready = false
local editModeHooked = false
local applying = false
local interacting = false
local dragging = false
local sizing = false
local hybrid = false
local reflowing = false
local didSetup = false
local greeted = false
local missingWarned = false
local sizeLeft, sizeTop, sizeBase = 0, 0, 220
local liveAlpha = 1
local moveState = false
local moveWant = false
local moveHold = 0
local eventMoving = false


function F.Clamp(value, minValue, maxValue)
    if value < minValue then return minValue end
    if value > maxValue then return maxValue end
    return value
end

function F.Round(value)
    return math.floor(value + 0.5)
end

function F.Nearly(a, b)
    return math.abs((a or 0) - (b or 0)) < 1.5
end

function F.Say(message)
    local r, g, b = F.BorderColor()
    local prefix = string.format("|cff%02x%02x%02xNavigate Forever|r ", F.Round(r * 255), F.Round(g * 255), F.Round(b * 255))
    print(prefix .. message)
end

function F.FrameLabel(frame)
    if not frame then
        return "nil"
    end
    if frame.GetDebugName then
        local ok, name = pcall(frame.GetDebugName, frame)
        if ok and type(name) == "string" and name ~= "" then
            return name
        end
    end
    local name = frame.GetName and frame:GetName()
    return name or "(unnamed)"
end

function F.IsInside(frame, ancestor)
    if not frame or not ancestor then
        return false
    end
    local parent = frame:GetParent()
    while parent do
        if parent == ancestor then
            return true
        end
        parent = parent:GetParent()
    end
    return false
end

function F.FindFrame(key)
    if cluster and cluster[key] then
        return cluster[key]
    end
    return _G[key]
end

function F.CapturePoints(frame)
    local points = {}
    if not frame or not frame.GetNumPoints then
        return points
    end
    for index = 1, frame:GetNumPoints() do
        points[index] = { frame:GetPoint(index) }
    end
    return points
end

function F.Remember(frame)
    if not frame or remembered[frame] then
        return
    end
    remembered[frame] = {
        parent = frame:GetParent(),
        points = F.CapturePoints(frame),
        scale = frame:GetScale(),
        strata = frame:GetFrameStrata(),
        level = frame:GetFrameLevel(),
    }
end

function F.RestoreRemembered(frame)
    local state = remembered[frame]
    if not frame or not state then
        return
    end
    pcall(function()
        if state.scale then
            frame:SetScale(state.scale)
        end
        if state.strata then
            frame:SetFrameStrata(state.strata)
        end
        if state.level then
            frame:SetFrameLevel(state.level)
        end
        if state.parent then
            frame:SetParent(state.parent)
        end
        frame:ClearAllPoints()
        for _, point in ipairs(state.points) do
            if point[1] then
                frame:SetPoint(point[1], point[2], point[3], point[4], point[5])
            end
        end
    end)
end

function F.RestoreDefaultPoints(frame)
    if not frame then
        return false
    end
    if frame.defaultFramePoints then
        frame:ClearAllPoints()
        for _, value in ipairs(frame.defaultFramePoints) do
            frame:SetPoint(value.point, value.relativeTo, value.relativePoint, value.offsetX, value.offsetY)
        end
        return true
    end
    return false
end

function F.InitDB()
    if type(NavigateForeverDB) ~= "table" then
        NavigateForeverDB = {}
    end
    db = NavigateForeverDB
    for key, value in pairs(DEFAULTS) do
        if db[key] == nil then
            db[key] = value
        end
    end
    db.scale = F.Clamp(tonumber(db.scale) or DEFAULTS.scale, MIN_SCALE, MAX_SCALE)
    db.alpha = F.Clamp(tonumber(db.alpha) or 1, MIN_ALPHA, 1)
    db.alphaMove = F.Clamp(tonumber(db.alphaMove) or DEFAULTS.alphaMove, MIN_ALPHA, 1)
    db.alphaCombat = F.Clamp(tonumber(db.alphaCombat) or DEFAULTS.alphaCombat, MIN_ALPHA, 1)
    db.fadeMove = not not db.fadeMove
    db.x = tonumber(db.x) or 0
    db.y = tonumber(db.y) or DEFAULTS.y
    if type(db.point) ~= "string" then
        db.point = DEFAULTS.point
    end
    if type(db.relPoint) ~= "string" then
        db.relPoint = DEFAULTS.relPoint
    end
    db.locked = not not db.locked
    if db.hintShown == nil then
        db.hintShown = false
    end
    local function keepColor(key, r, g, b)
        local color = db[key]
        if type(color) ~= "table" then
            db[key] = { r, g, b }
            return
        end
        color[1] = tonumber(color[1]) or r
        color[2] = tonumber(color[2]) or g
        color[3] = tonumber(color[3]) or b
    end
    if not F.ThemeById(db.theme) then
        db.theme = DEFAULTS.theme
    end
    keepColor("menuColor", NAVY_R, NAVY_G, NAVY_B)
    keepColor("borderColor", GOLD_R, GOLD_G, GOLD_B)
    F.LoadCharTheme()
    for index = 1, 3 do
        local color = F.RING_COLORS[index]
        keepColor("ringColor" .. index, color[1], color[2], color[3])
        local yardsKey = "ring" .. index .. "Yards"
        db[yardsKey] = F.Clamp(F.Round(tonumber(db[yardsKey]) or (index * 20)), F.RING_MIN, F.RING_MAX)
    end
    if tonumber(db.arrowScale) then
        db.arrowScale = F.Clamp(tonumber(db.arrowScale), 0.05, 3)
    end
    db.gatherSwap = db.gatherSwap ~= false
    db.gatherSeconds = F.Clamp(F.Round(tonumber(db.gatherSeconds) or 4), 2, 12)
    db.campfireSound = F.CampfireSoundId(db.campfireSound)
    F.gather = F.gather or {}
    if db.gatherUnmute then
        F.GatherUnmute()
    end
    if type(db.flightTimes) ~= "table" then
        db.flightTimes = {}
    end
    for route, seconds in pairs(db.flightTimes) do
        if type(route) ~= "string" or type(seconds) ~= "number" or seconds < 5 or seconds > 3600 then
            db.flightTimes[route] = nil
        end
    end
    if type(db.deaths) ~= "table" then
        db.deaths = {}
    end
    for tag, death in pairs(db.deaths) do
        local world = type(death) == "table" and tonumber(death.x) and tonumber(death.y)
        local zone = type(death) == "table" and tonumber(death.map) and tonumber(death.zx) and tonumber(death.zy)
        if type(tag) ~= "string" or not (world or zone) then
            db.deaths[tag] = nil
        else
            death.x = tonumber(death.x)
            death.y = tonumber(death.y)
            death.instance = tonumber(death.instance)
            death.map = tonumber(death.map)
            death.zx = tonumber(death.zx)
            death.zy = tonumber(death.zy)
        end
    end
    F.TidyPins()
    liveAlpha = db.alpha
end

function F.Enabled(key)
    return db == nil or db[key] ~= false
end

local function copyColor(color)
    if type(color) == "table" and tonumber(color[1]) and tonumber(color[2]) and tonumber(color[3]) then
        return { tonumber(color[1]), tonumber(color[2]), tonumber(color[3]) }
    end
    return nil
end

-- A character with no saved look of its own keeps whatever the account last used.
function F.LoadCharTheme()
    if type(NavigateForeverCharDB) ~= "table" then
        NavigateForeverCharDB = {}
    end
    charDb = NavigateForeverCharDB
    if not F.ThemeById(charDb.theme) then
        return
    end
    db.theme = charDb.theme
    db.menuColor = copyColor(charDb.menuColor) or db.menuColor
    db.borderColor = copyColor(charDb.borderColor) or db.borderColor
end

function F.SaveCharTheme()
    if not db or not charDb then
        return
    end
    charDb.theme = db.theme
    charDb.menuColor = copyColor(db.menuColor)
    charDb.borderColor = copyColor(db.borderColor)
end

function F.MenuColor()
    local color = db and db.menuColor
    if type(color) == "table" and tonumber(color[1]) then
        return tonumber(color[1]), tonumber(color[2]) or NAVY_G, tonumber(color[3]) or NAVY_B
    end
    return NAVY_R, NAVY_G, NAVY_B
end

function F.BorderColor()
    local color = db and db.borderColor
    if type(color) == "table" and tonumber(color[1]) then
        return tonumber(color[1]), tonumber(color[2]) or GOLD_G, tonumber(color[3]) or GOLD_B
    end
    return GOLD_R, GOLD_G, GOLD_B
end

function F.ThemeById(id)
    for index = 1, #F.THEMES do
        if F.THEMES[index].id == id then
            return F.THEMES[index]
        end
    end
    return nil
end

function F.Theme()
    return F.ThemeById(db and db.theme) or F.THEMES[1]
end

function F.ThemeColor(part)
    local color = F.Theme()[part] or F.THEMES[1][part]
    return color[1], color[2], color[3]
end

function F.SetTheme(id)
    local theme = F.ThemeById(id)
    if not theme or not db then
        return
    end
    db.theme = theme.id
    db.menuColor = { theme.menu[1], theme.menu[2], theme.menu[3] }
    db.borderColor = { theme.border[1], theme.border[2], theme.border[3] }
    if F.ApplyColors then
        F.ApplyColors()
    end
    if F.SyncTheme then
        F.SyncTheme()
    end
end

local paintedFrames = {}
local themedSliders = {}
local themedMarks = {}
local brandIcons = {}

function F.PaintBrandIcon(tex)
    local theme = F.Theme()
    tex:SetTexture(theme.icon or ICON)
    local coords = theme.iconCoords
    if coords then
        tex:SetTexCoord(coords[1], coords[2], coords[3], coords[4])
    else
        tex:SetTexCoord(0, 1, 0, 1)
    end
end

local brandFlames = {}

function F.BrandIcon(tex)
    table.insert(brandIcons, tex)
    F.PaintBrandIcon(tex)
    local flame = tex:GetParent():CreateTexture(nil, "ARTWORK", nil, -1)
    flame:SetTexture(MEDIA .. "theme-flame")
    flame:SetBlendMode("ADD")
    flame:SetPoint("BOTTOM", tex, "BOTTOM", 0, 0)
    flame.nfIcon = tex
    table.insert(brandFlames, flame)
    F.PaintFlame(flame, 0)
    return tex
end

function F.PaintFlame(flame, flicker)
    local tint = F.Theme().flame
    if not tint then
        flame:Hide()
        return
    end
    local wide = flame.nfIcon:GetWidth() or 0
    if wide < 1 then
        wide = 28
    end
    flame:SetSize(wide * (1.3 + 0.08 * flicker), wide * (1.7 + 0.14 * flicker))
    flame:SetVertexColor(tint[1], tint[2], tint[3])
    flame:SetAlpha(0.6 + 0.25 * flicker)
    flame:Show()
end

local MIST_TILE = 180

function F.DriftMist(frame, t)
    local mist = frame.nfMist
    if not mist or not mist:IsShown() then
        return
    end
    local wide = (frame:GetWidth() or 0) / MIST_TILE
    local high = (frame:GetHeight() or 0) / MIST_TILE
    local u = t * 0.018 + math.sin(t * 0.21) * 0.04
    local v = t * 0.007 + math.cos(t * 0.17) * 0.03
    mist:SetTexCoord(u, u + wide, v, v + high)
end

function F.PaintMist(frame)
    local mist = frame.nfMist
    if not mist then
        return
    end
    local tint = F.Theme().mist
    if not tint then
        mist:Hide()
        return
    end
    mist:SetTexture(MEDIA .. "theme-mist", "REPEAT", "REPEAT")
    mist:SetBlendMode("ADD")
    mist:SetVertexColor(tint[1], tint[2], tint[3])
    mist:SetAlpha(tint[4])
    mist:Show()
    F.DriftMist(frame, F.animFrame and F.animFrame.t or 0)
end

function F.PulseBorders(mix)
    local br, bgc, bb = F.BorderColor()
    local hr, hg, hb = F.ThemeColor("bright")
    local r = br + (hr - br) * mix
    local g = bgc + (hg - bgc) * mix
    local b = bb + (hb - bb) * mix
    if goldEdges then
        for _, edge in pairs(goldEdges) do
            if edge.tex then
                edge.tex:SetColorTexture(r, g, b, 1)
            end
        end
    end
    if mapFrame then
        for _, side in ipairs({ "top", "bottom", "left", "right" }) do
            if mapFrame[side] then
                mapFrame[side]:SetColorTexture(r, g, b, 1)
            end
        end
    end
    if border and border.SetBackdropBorderColor then
        border:SetBackdropBorderColor(r, g, b, 1)
    end
    if panel and panel.nfTop then
        panel.nfTop:SetColorTexture(r, g, b, 1)
        panel.nfBottom:SetColorTexture(r, g, b, 1)
        panel.nfLeft:SetColorTexture(r, g, b, 1)
        panel.nfRight:SetColorTexture(r, g, b, 1)
    end
end

local particleHosts = {}
local particleKey

-- Hosts hold twice their usual count so a theme marked dense can show them all.
function F.AddParticles(frame, count)
    local host = { frame = frame, dots = {}, base = count }
    for index = 1, count * 2 do
        local dot = frame:CreateTexture(nil, "ARTWORK", nil, 7)
        dot:SetBlendMode("ADD")
        dot:Hide()
        host.dots[index] = dot
    end
    table.insert(particleHosts, host)
    F.PaintParticles(true)
    return host
end

function F.PlaceParticle(dot, wide, high, spec, anywhere)
    dot.nfX = (spec.mode == "blow" and not anywhere) and 0 or math.random() * wide
    if anywhere or spec.mode == "wander" or spec.mode == "twinkle" or spec.mode == "blow" then
        dot.nfY = math.random() * high
    elseif spec.mode == "fall" then
        dot.nfY = high
    else
        dot.nfY = 0
    end
    dot.nfPace = 0.6 + math.random() * 0.8
    dot.nfPhase = math.random() * 6.283
    local low, top = spec.size[1], spec.size[2]
    dot:SetSize(low + math.random() * (top - low), low + math.random() * (top - low))
end

function F.PaintParticles(force)
    local theme = F.Theme()
    local spec = theme.particles
    local live = spec and F.AnimationsWanted()
    local key = theme.id .. (live and ":on" or ":off")
    if key == particleKey and not force then
        return
    end
    particleKey = key
    for _, host in ipairs(particleHosts) do
        local wide = math.max(host.frame:GetWidth() or 0, 1)
        local high = math.max(host.frame:GetHeight() or 0, 1)
        host.seedWide = wide
        local shown = live and (spec.dense and #host.dots or host.base) or 0
        for index, dot in ipairs(host.dots) do
            if index <= shown then
                local tex = spec.texs and spec.texs[(index - 1) % #spec.texs + 1] or spec.tex
                dot:SetTexture(MEDIA .. tex)
                dot:SetVertexColor(spec.color[1], spec.color[2], spec.color[3])
                dot:SetBlendMode(spec.blend or "ADD")
                if dot.SetRotation then
                    dot:SetRotation(0)
                end
                F.PlaceParticle(dot, wide, high, spec, true)
                dot.nfCycle = nil
                dot:SetAlpha(0)
                dot:Show()
            else
                dot:Hide()
            end
        end
    end
end

function F.StepParticles(step, t, spec)
    for _, host in ipairs(particleHosts) do
        local frame = host.frame
        if frame:IsVisible() then
            local wide = math.max(frame:GetWidth() or 0, 1)
            local high = math.max(frame:GetHeight() or 0, 1)
            if (host.seedWide or 0) < 2 and wide >= 2 then
                host.seedWide = wide
                for _, dot in ipairs(host.dots) do
                    F.PlaceParticle(dot, wide, high, spec, true)
                end
            end
            for _, dot in ipairs(host.dots) do
                if dot:IsShown() then
                    F.StepParticle(dot, frame, wide, high, step, t, spec)
                end
            end
        end
    end
end

function F.StepParticle(dot, frame, wide, high, step, t, spec)
    local x, y, phase = dot.nfX, dot.nfY, dot.nfPhase
    local alpha
    if spec.mode == "rise" or spec.mode == "fall" then
        local dir = spec.mode == "rise" and 1 or -1
        y = y + dir * spec.speed * dot.nfPace * step
        x = x + math.sin(t * 0.9 + phase) * 6 * step
        if y > high or y < 0 then
            F.PlaceParticle(dot, wide, high, spec)
            x, y = dot.nfX, dot.nfY
        end
        local flicker = spec.mode == "rise" and (0.75 + 0.25 * math.sin(t * 7 + phase)) or 1
        alpha = math.sin(math.pi * y / high) * 0.85 * flicker
    elseif spec.mode == "wander" then
        x = (x + math.cos(t * 0.5 * dot.nfPace + phase) * spec.speed * step) % wide
        y = (y + math.sin(t * 0.7 * dot.nfPace + phase * 1.3) * spec.speed * step) % high
        alpha = 0.35 + 0.5 * (0.5 + 0.5 * math.sin(t * 1.5 * dot.nfPace + phase))
    elseif spec.mode == "blow" then
        x = x + spec.speed * dot.nfPace * step
        y = y + math.sin(t * 1.3 + phase) * 10 * step
        if x > wide or y < 0 or y > high then
            F.PlaceParticle(dot, wide, high, spec)
            x, y = dot.nfX, dot.nfY
        end
        alpha = math.sin(math.pi * x / wide) * 0.85
    else
        local wave = t * spec.speed * dot.nfPace + phase
        local cycle = math.floor(wave / 6.283)
        if dot.nfCycle and dot.nfCycle ~= cycle then
            F.PlaceParticle(dot, wide, high, spec)
            x, y = dot.nfX, dot.nfY
        end
        dot.nfCycle = cycle
        alpha = math.max(0, math.sin(wave)) ^ 3
    end
    dot.nfX, dot.nfY = x, y
    dot:ClearAllPoints()
    dot:SetPoint("CENTER", frame, "BOTTOMLEFT", x, y)
    dot:SetAlpha(alpha)
    if spec.spin and dot.SetRotation then
        if spec.spin == "tumble" then
            dot:SetRotation((t * 1.6 * dot.nfPace + phase) % 6.283)
        else
            dot:SetRotation(math.sin(t * 1.1 * dot.nfPace + phase) * 0.6)
        end
    end
end

function F.AnimationsWanted()
    local theme = F.Theme()
    return F.Enabled("animate") and (theme.mist or theme.flame or theme.pulse or theme.particles) and true or false
end

function F.AnimationsPaused()
    if InCombatLockdown() then
        return true
    end
    return db and F.ShownAlpha and F.ShownAlpha() < (db.alpha or 1) - 0.01
end

function F.AnimStep(self, elapsed)
    self.wait = self.wait + (elapsed or 0)
    if self.wait < 0.05 then
        return
    end
    local step = math.min(self.wait, 0.25)
    self.wait = 0
    if F.AnimationsPaused() then
        return
    end
    self.t = self.t + step
    local t = self.t
    local theme = F.Theme()
    if theme.mist then
        for _, frame in ipairs(paintedFrames) do
            F.DriftMist(frame, t)
        end
    end
    if theme.pulse then
        F.PulseBorders(0.3 * (0.5 + 0.5 * math.sin(t * 1.6)))
    end
    if theme.particles then
        F.StepParticles(step, t, theme.particles)
    end
    if theme.flame then
        for index, flame in ipairs(brandFlames) do
            local flicker = 0.5 * math.sin(t * 9.1 + index) + 0.3 * math.sin(t * 13.7 + index * 2) + 0.2 * math.sin(t * 4.3)
            F.PaintFlame(flame, flicker)
        end
    end
end

function F.RefreshAnimations()
    local anim = F.animFrame
    if not anim then
        anim = CreateFrame("Frame")
        anim.t = 0
        anim.wait = 0
        anim:SetScript("OnUpdate", F.AnimStep)
        F.animFrame = anim
    end
    F.PaintParticles()
    if F.AnimationsWanted() then
        anim:Show()
    else
        anim:Hide()
        F.PulseBorders(0)
        for _, flame in ipairs(brandFlames) do
            F.PaintFlame(flame, 0)
        end
    end
end

function F.PaintGrain(frame)
    local grain = frame.nfGrain
    if not grain then
        return
    end
    local theme = F.Theme()
    if not theme.grain then
        grain:Hide()
        return
    end
    grain:SetTexture(theme.grain, "REPEAT", "REPEAT")
    if grain.SetHorizTile then
        grain:SetHorizTile(true)
        grain:SetVertTile(true)
    end
    grain:SetBlendMode(theme.grainBlend or "ADD")
    local color = theme.grainColor
    grain:SetVertexColor(color[1], color[2], color[3])
    grain:SetAlpha(color[4])
    grain:Show()
end

local cornerSets = {}
local CORNER_FLIPS = {
    { "TOPLEFT", 0, 1, 0, 1, -1, 1 },
    { "TOPRIGHT", 1, 0, 0, 1, 1, 1 },
    { "BOTTOMLEFT", 0, 1, 1, 0, -1, -1 },
    { "BOTTOMRIGHT", 1, 0, 1, 0, 1, -1 },
}

function F.PaintCorners()
    local theme = F.Theme()
    local r, g, b
    if theme.cornerTint then
        r, g, b = theme.cornerTint[1], theme.cornerTint[2], theme.cornerTint[3]
    else
        r, g, b = F.BorderColor()
        r, g, b = r + (1 - r) * 0.45, g + (1 - g) * 0.45, b + (1 - b) * 0.45
    end
    for _, set in ipairs(cornerSets) do
        for _, tex in ipairs(set) do
            if theme.corner then
                if theme.cornerBottom and tex.nfDirY < 0 then
                    tex:SetTexture(theme.cornerBottom)
                    tex:SetTexCoord(tex.nfFlip[1], tex.nfFlip[2], 0, 1)
                else
                    tex:SetTexture(theme.corner)
                    tex:SetTexCoord(tex.nfFlip[1], tex.nfFlip[2], tex.nfFlip[3], tex.nfFlip[4])
                end
                tex:SetVertexColor(r, g, b)
                tex:Show()
            else
                tex:Hide()
            end
        end
    end
end

-- The art hugs its own top and left edges, so each corner is pushed out by a
-- slice of its size to sit the ornament on the frame line instead of inside it.
function F.CreateCorners(parent, size)
    local set = {}
    for _, flip in ipairs(CORNER_FLIPS) do
        local tex = parent:CreateTexture(nil, "OVERLAY", nil, 7)
        tex.nfFlip = { flip[2], flip[3], flip[4], flip[5] }
        tex.nfPoint = flip[1]
        tex.nfDirX, tex.nfDirY = flip[6], flip[7]
        table.insert(set, tex)
    end
    table.insert(cornerSets, set)
    F.SizeCorners(set, parent, size)
    F.PaintCorners()
    return set
end

function F.SizeCorners(set, parent, size)
    local push = size * 0.12
    for _, tex in ipairs(set) do
        tex:SetSize(size, size)
        tex:ClearAllPoints()
        tex:SetPoint(tex.nfPoint, parent, tex.nfPoint, tex.nfDirX * push, tex.nfDirY * push)
    end
end
local accentText = {}
local colorSwatches = {}
local colorSwatchFrames = {}

function F.StoreColor(key, r, g, b)
    db[key] = { r, g, b }
    if F.ApplyColors then
        F.ApplyColors()
    end
end

function F.OpenColorPicker(key, fallbackR, fallbackG, fallbackB)
    local current = db and db[key]
    local r = (type(current) == "table" and tonumber(current[1])) or fallbackR
    local g = (type(current) == "table" and tonumber(current[2])) or fallbackG
    local b = (type(current) == "table" and tonumber(current[3])) or fallbackB
    local function apply(nr, ng, nb)
        if not nr then
            return
        end
        F.StoreColor(key, nr, ng, nb)
    end
    if not ColorPickerFrame then
        F.Say("This client has no color picker.")
        return
    end
    if ColorPickerFrame.SetupColorPickerAndShow then
        ColorPickerFrame:SetupColorPickerAndShow({
            r = r,
            g = g,
            b = b,
            hasOpacity = false,
            swatchFunc = function()
                local nr, ng, nb = ColorPickerFrame:GetColorRGB()
                apply(nr, ng, nb)
            end,
            cancelFunc = function(previous)
                local pr, pg, pb = r, g, b
                if type(previous) == "table" then
                    pr = previous.r or previous[1] or r
                    pg = previous.g or previous[2] or g
                    pb = previous.b or previous[3] or b
                end
                apply(pr, pg, pb)
            end,
        })
        return
    end
    ColorPickerFrame.hasOpacity = false
    ColorPickerFrame.previousValues = { r = r, g = g, b = b }
    ColorPickerFrame.func = function()
        local nr, ng, nb = ColorPickerFrame:GetColorRGB()
        apply(nr, ng, nb)
    end
    ColorPickerFrame.cancelFunc = function(previous)
        local pr, pg, pb = r, g, b
        if type(previous) == "table" then
            pr = previous.r or previous[1] or r
            pg = previous.g or previous[2] or g
            pb = previous.b or previous[3] or b
        end
        apply(pr, pg, pb)
    end
    ColorPickerFrame:SetColorRGB(r, g, b)
    ColorPickerFrame:Hide()
    ColorPickerFrame:Show()
end

function F.MapWidgets()
    local nextCluster = MinimapCluster
    if not nextCluster then
        return nil
    end
    local nextContainer = nextCluster.MinimapContainer
    local nextMap = (nextContainer and nextContainer.Minimap) or Minimap
    return nextCluster, nextContainer, nextMap
end

function F.RingValue(methodName)
    if not map or not map[methodName] then
        return nil
    end
    local ok, value = pcall(map[methodName], map)
    if ok then
        return value
    end
    return nil
end

function F.SetRing(methodName, alpha)
    if map and map[methodName] and type(alpha) == "number" then
        pcall(map[methodName], map, alpha)
    end
end

function F.IsHybrid()
    if C_Minimap and C_Minimap.ShouldUseHybridMinimap then
        local ok, useHybrid = pcall(C_Minimap.ShouldUseHybridMinimap)
        if ok and useHybrid then
            return true
        end
    end
    return HybridMinimap and HybridMinimap.IsShown and HybridMinimap:IsShown() and true or false
end

function F.CaptureStock()
    if stock.captured or not cluster or not map then
        return stock.captured
    end
    local width, height = cluster:GetSize()
    if not width or width < 10 or not height or height < 10 then
        return false
    end
    stock.captured = true
    stock.clusterW = width
    stock.clusterH = height
    stock.clusterPoints = F.CapturePoints(cluster)
    stock.containerScale = container and container:GetScale() or 1
    stock.containerPoints = container and F.CapturePoints(container) or nil
    stock.mapW, stock.mapH = map:GetSize()
    stock.mapPoints = F.CapturePoints(map)
    stock.mapParent = map:GetParent()
    stock.rings.quest = F.RingValue("GetQuestBlobRingAlpha")
    stock.rings.arch = F.RingValue("GetArchBlobRingAlpha")
    stock.rings.task = F.RingValue("GetTaskBlobRingAlpha")
    stock.insides = {
        quest = F.RingValue("GetQuestBlobInsideAlpha"),
        arch = F.RingValue("GetArchBlobInsideAlpha"),
        task = F.RingValue("GetTaskBlobInsideAlpha"),
    }
    if MinimapZoneText and MinimapZoneText.GetJustifyH then
        stock.zoneJustify = MinimapZoneText:GetJustifyH()
    end
    return true
end

function F.CursorOnUI()
    local x, y = GetCursorPosition()
    local scale = UIParent:GetEffectiveScale()
    return x / scale, y / scale
end

function F.Viewport()
    local width = GetScreenWidth()
    local height = GetScreenHeight()
    if type(width) ~= "number" or width < 1 then
        width = 1920
    end
    if type(height) ~= "number" or height < 1 then
        height = 1080
    end
    return width, height
end

-- Pixel height of the UI view. 1 at 1080p, so a taller or shorter screen
-- keeps the same share of the picture. UI scale still applies on top,
-- because these frames sit on UIParent.
function F.PixelHeight()
    local _, height = F.Viewport()
    local ui = 1
    if UIParent and UIParent.GetEffectiveScale then
        ui = UIParent:GetEffectiveScale() or 1
    end
    if type(ui) ~= "number" or ui < 0.01 then
        ui = 1
    end
    local pixels = height * ui
    if pixels < 1 then
        pixels = 1080
    end
    return pixels
end

function F.ResolutionScale()
    local scale = F.PixelHeight() / 1080
    if scale < 0.6 then
        scale = 0.6
    end
    if scale > 2 then
        scale = 2
    end
    return scale
end

function F.AppliedMapScale()
    local user = (db and db.scale) or 1
    local applied = user * F.ResolutionScale()
    local _, height = F.Viewport()
    local base = 220
    if stock and stock.clusterH and stock.clusterH > 40 then
        base = stock.clusterH
    end
    local limit = (height - 56) / base
    if limit < 0.5 then
        limit = 0.5
    end
    if applied > limit then
        applied = limit
    end
    if applied < 0.45 then
        applied = 0.45
    end
    return applied
end

function F.PlaceOptions()
    if not panel then
        return
    end
    local designW = panel:GetWidth() or 480
    local designH = panel:GetHeight() or 540
    if designW < 1 then
        designW = 480
    end
    if designH < 1 then
        designH = 540
    end
    local width, height = F.Viewport()
    local margin = 24
    local fitW = (width - margin * 2) / designW
    local fitH = (height - margin * 2) / designH
    local scale = F.ResolutionScale()
    if fitW < scale then
        scale = fitW
    end
    if fitH < scale then
        scale = fitH
    end
    if scale < 0.35 then
        scale = 0.35
    end
    if panel.nfScreen and math.abs(panel.nfScreen - scale) > 0.02 then
        panel.nfPlaced = nil
    end
    panel.nfScreen = scale
    panel:SetScale(scale)
    if not panel.nfPlaced then
        panel:ClearAllPoints()
        panel:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
        panel.nfPlaced = true
    end
end

function F.OnScreenMode()
    if ready and not hybrid and db then
        F.Apply()
    elseif panel then
        F.PlaceOptions()
    end
end

function F.SavePosition()
    if not cluster then
        return
    end
    local point, relativeTo, relPoint, x, y = cluster:GetPoint(1)
    if not point then
        return
    end
    if relativeTo and relativeTo ~= UIParent then
        local scale = cluster:GetEffectiveScale()
        local uiScale = UIParent:GetEffectiveScale()
        db.point = "TOPLEFT"
        db.relPoint = "BOTTOMLEFT"
        db.x = cluster:GetLeft() * scale / uiScale
        db.y = cluster:GetTop() * scale / uiScale
        return
    end
    db.point = point
    db.relPoint = relPoint or point
    db.x = x or 0
    db.y = y or 0
end

function F.PositionMatches()
    if not cluster then
        return false
    end
    local point, _, relPoint, x, y = cluster:GetPoint(1)
    return point == db.point and relPoint == db.relPoint and F.Nearly(x, db.x) and F.Nearly(y, db.y)
end

function F.ShowChrome(show)
    if header then
        header:SetShown(show)
    end
    if border then
        border:SetShown(show)
    end
    if grip then
        grip:SetShown(show)
    end
end

function F.HideRoundChrome()
    for _, key in ipairs(HIDE_KEYS) do
        local frame = F.FindFrame(key)
        if frame and frame ~= map and not F.IsInside(map, frame) then
            if hiddenShown[frame] == nil then
                hiddenShown[frame] = frame:IsShown()
            end
            frame:Hide()
        end
    end
end

function F.ShowRoundChrome()
    for frame, wasShown in pairs(hiddenShown) do
        if wasShown and frame.Show then
            frame:Show()
        end
    end
end

-- The square mask reveals the corners. The client still draws the old
-- circular edge on top of them unless this is turned off.
local forcingEdge = false

function F.SetCircularEdge(enabled)
    if not map or type(map.SetUseCircularEdge) ~= "function" then
        return
    end
    forcingEdge = true
    pcall(map.SetUseCircularEdge, map, enabled and true or false)
    forcingEdge = false
end

local BLOB_ALPHAS = {
    "SetQuestBlobRingAlpha",
    "SetArchBlobRingAlpha",
    "SetTaskBlobRingAlpha",
    "SetQuestBlobInsideAlpha",
    "SetArchBlobInsideAlpha",
    "SetTaskBlobInsideAlpha",
}

local forcingBlob = false

function F.HideBlobs()
    forcingBlob = true
    for _, method in ipairs(BLOB_ALPHAS) do
        F.SetRing(method, 0)
    end
    forcingBlob = false
end

function F.HookBlobs()
    if not map or map.nfBlobHooked or type(hooksecurefunc) ~= "function" then
        return
    end
    map.nfBlobHooked = true
    for _, method in ipairs(BLOB_ALPHAS) do
        if type(map[method]) == "function" then
            local blobMethod = method
            hooksecurefunc(map, blobMethod, function(_, alpha)
                if forcingBlob or applying or hybrid or not ready then
                    return
                end
                if alpha ~= 0 then
                    F.SetRing(blobMethod, 0)
                end
            end)
        end
    end
end

function F.HookCircularEdge()
    if not map or map.nfEdgeHooked or type(map.SetUseCircularEdge) ~= "function" or type(hooksecurefunc) ~= "function" then
        return
    end
    map.nfEdgeHooked = true
    hooksecurefunc(map, "SetUseCircularEdge", function(_, enabled)
        if forcingEdge or applying or hybrid or not ready then
            return
        end
        if enabled then
            F.SetCircularEdge(false)
        end
    end)
end

function F.ViewSize()
    local viewW = db.width
    local viewH = db.height - HEADER_H
    if viewH < 40 then
        viewH = 40
    end
    return viewW, viewH
end

function F.HookShow(frame)
    if not frame or frame.nfShowHooked or not frame.HookScript then
        return
    end
    frame.nfShowHooked = true
    frame:HookScript("OnShow", function()
        if ready and not hybrid and not applying and not reflowing then
            F.LayoutChrome()
        end
    end)
    frame:HookScript("OnSizeChanged", function()
        if ready and not hybrid and not applying and not reflowing then
            F.LayoutChrome()
        end
    end)
end

F.LayoutChrome = function()
    if not cluster or reflowing then
        return
    end
    reflowing = true

    local indicator = F.FindFrame("IndicatorFrame")
    local seen = {}
    local row = {}

    local function Add(frame)
        if not frame or seen[frame] or frame == map or frame == header or frame == border or frame == grip then
            return
        end
        if indicator and frame ~= indicator and F.IsInside(frame, indicator) then
            return
        end
        seen[frame] = true
        row[#row + 1] = frame
        F.HookShow(frame)
    end

    for _, key in ipairs(ROW_KEYS) do
        Add(F.FindFrame(key))
    end

    local x = -8
    local level = cluster:GetFrameLevel() + 8
    for _, frame in ipairs(row) do
        F.Remember(frame)
        if frame:IsShown() then
            local adopted = true
            if frame:GetParent() ~= cluster then
                adopted = pcall(frame.SetParent, frame, cluster)
            end
            if adopted then
                pcall(function()
                    frame:SetScale(1)
                    frame:SetFrameStrata("HIGH")
                    frame:SetFrameLevel(level)
                    frame:ClearAllPoints()
                    frame:SetPoint("TOPRIGHT", cluster, "TOPRIGHT", x, -1)
                    if frame.Layout then
                        frame:Layout()
                    end
                end)
                local width = frame:GetWidth() or 0
                if width < 1 then
                    width = 26
                end
                x = x - width - 4
            end
        end
    end

    local zone = F.FindFrame("ZoneTextButton") or MinimapZoneTextButton
    if zone then
        zone:Hide()
    end
    if cluster and cluster.BorderTop then
        cluster.BorderTop:Hide()
    end

    reflowing = false
end

function F.ApplyMapWindow()
    local viewW, viewH = F.ViewSize()
    -- Keep the terrain inside the gold edge. A square of the long side
    -- hangs out above and below the panel.
    local inset = 10
    local mapW = math.max(40, viewW - inset * 2)
    local mapH = math.max(40, viewH - inset * 2)

    if container.SetClipsChildren then
        container:SetClipsChildren(true)
    end
    container:SetScale(1)
    container:ClearAllPoints()
    container:SetPoint("TOPLEFT", cluster, "TOPLEFT", 0, -HEADER_H)
    container:SetPoint("BOTTOMRIGHT", cluster, "BOTTOMRIGHT", 0, 0)

    if map:GetParent() ~= container then
        pcall(map.SetParent, map, container)
    end
    map:ClearAllPoints()
    map:SetPoint("TOPLEFT", container, "TOPLEFT", inset, -inset)
    map:SetSize(mapW, mapH)
    pcall(map.SetMaskTexture, map, SQUARE_MASK)
    map:SetHitRectInsets(0, 0, 0, 0)
    F.HideBlobs()
end

F.Apply = function()
    if not cluster or not container or not map or not db then
        return
    end
    if F.IsHybrid() then
        return
    end

    applying = true
    hybrid = false

    cluster:SetMovable(true)
    cluster:SetClampedToScreen(true)
    if stock.clusterW and stock.clusterH then
        cluster:SetSize(stock.clusterW, stock.clusterH)
    end
    -- Scale the map frame the game uses for icon placement. Scaling the
    -- whole cluster enlarges the terrain and leaves herbs, ore, flight
    -- masters, mailboxes, and quest pins behind.
    cluster:SetScale(1)
    local applied = F.AppliedMapScale()
    if type(cluster.SetEditModeScale) == "function" then
        cluster.scaleMinimapHeader = true
        cluster:SetEditModeScale(applied)
    elseif container then
        container:SetScale(applied)
    end
    cluster:ClearAllPoints()
    cluster:SetPoint(db.point, UIParent, db.relPoint, db.x, db.y)
    -- The terrain ignores the cluster alpha. LayoutNav sets the map's own.

    -- Blizzard's resize keeps the round mask. A square mask shows the
    -- corners without moving the tracking icons. The circular edge is a
    -- separate ring and stays until it is turned off.
    -- Paint city maps at full opacity. A faded frame here comes back blank.
    if F.SolidTerrain() then
        cluster:SetAlpha(1)
        if container then
            container:SetAlpha(1)
        end
        map:SetAlpha(1)
    end
    pcall(map.SetMaskTexture, map, SQUARE_MASK)
    F.SetCircularEdge(false)
    F.HideBlobs()
    if container.SetClipsChildren then
        container:SetClipsChildren(false)
    end
    F.HideRoundChrome()
    if header then
        header:Hide()
    end
    if border then
        border:Hide()
    end
    if grip then
        if container and grip:GetParent() ~= container then
            grip:SetParent(container)
        end
        grip:ClearAllPoints()
        grip:SetPoint("BOTTOMRIGHT", container or cluster, "BOTTOMRIGHT", -2, 2)
        -- Inverse of the saved size only. The resolution part stays, so
        -- the gold corner grows with the screen along with the square.
        if db.scale > 0 then
            grip:SetScale(1 / db.scale)
        end
        grip:SetFrameStrata("HIGH")
        grip:SetFrameLevel(400)
        grip:Show()
    end
    F.LayoutNav()
    if F.ApplyColors then
        F.ApplyColors()
    end

    applying = false
    ready = true
    if F.SyncOptions then
        F.SyncOptions()
    end
    F.PlaceOptions()
    if C_Timer and C_Timer.After then
        C_Timer.After(0.2, F.RefreshMinimapButtons)
        C_Timer.After(1, F.RefreshMinimapButtons)
        C_Timer.After(3, F.RefreshMinimapButtons)
    else
        F.RefreshMinimapButtons()
    end
end

function F.RestoreMap()
    if not map then
        return
    end
    pcall(function()
        if stock.mapParent then
            map:SetParent(stock.mapParent)
        end
        map:ClearAllPoints()
        for _, point in ipairs(stock.mapPoints or {}) do
            if point[1] then
                map:SetPoint(point[1], point[2], point[3], point[4], point[5])
            end
        end
        if stock.mapW and stock.mapH then
            map:SetSize(stock.mapW, stock.mapH)
        end
        map:SetMaskTexture(ROUND_MASK)
        map:SetHitRectInsets(0, 0, 0, 0)
    end)
    F.SetCircularEdge(true)
    F.SetRing("SetQuestBlobRingAlpha", stock.rings.quest or 1)
    F.SetRing("SetArchBlobRingAlpha", stock.rings.arch or 1)
    F.SetRing("SetTaskBlobRingAlpha", stock.rings.task or 1)
    local insides = stock.insides or {}
    F.SetRing("SetQuestBlobInsideAlpha", insides.quest or 1)
    F.SetRing("SetArchBlobInsideAlpha", insides.arch or 1)
    F.SetRing("SetTaskBlobInsideAlpha", insides.task or 1)
    if MinimapZoneText and MinimapZoneText.SetJustifyH then
        MinimapZoneText:SetJustifyH(stock.zoneJustify or "CENTER")
    end
end

function F.Restore()
    if not cluster or not stock.captured then
        return
    end
    applying = true
    hybrid = true

    cluster:SetAlpha(1)
    cluster:SetScale(1)
    if type(cluster.SetEditModeScale) == "function" then
        cluster:SetEditModeScale(stock.containerScale or 1)
    end
    cluster:ClearAllPoints()
    for _, point in ipairs(stock.clusterPoints or {}) do
        if point[1] then
            cluster:SetPoint(point[1], point[2], point[3], point[4], point[5])
        end
    end
    if stock.clusterW and stock.clusterH then
        cluster:SetSize(stock.clusterW, stock.clusterH)
    end

    if container then
        if container.SetClipsChildren then
            container:SetClipsChildren(false)
        end
        if stock.containerScale then
            container:SetScale(stock.containerScale)
        end
        if not F.RestoreDefaultPoints(container) then
            container:ClearAllPoints()
            for _, point in ipairs(stock.containerPoints or {}) do
                if point[1] then
                    container:SetPoint(point[1], point[2], point[3], point[4], point[5])
                end
            end
        end
    end

    F.RestoreMap()
    F.ShowRoundChrome()
    if cluster.BorderTop and cluster.BorderTop.defaultFramePoints then
        F.RestoreDefaultPoints(cluster.BorderTop)
    end
    if cluster.BorderTop then
        cluster.BorderTop:Show()
    end
    if MinimapZoneTextButton then
        MinimapZoneTextButton:Show()
    end
    if cluster.InstanceDifficulty then
        F.RestoreDefaultPoints(cluster.InstanceDifficulty)
    end
    if cluster.IndicatorFrame then
        F.RestoreDefaultPoints(cluster.IndicatorFrame)
    end
    for frame in pairs(remembered) do
        F.RestoreRemembered(frame)
    end
    F.ShowChrome(false)
    if nav then
        nav:Hide()
    end
    if pinMark then
        pinMark:Hide()
    end
    if deathMark then
        deathMark:Hide()
    end
    if rangeHost then
        rangeHost:Hide()
    end
    if mapFrame then
        mapFrame:Hide()
    end
    if brandButton then
        brandButton:Hide()
    end
    if goldEdges then
        for _, edge in pairs(goldEdges) do
            edge:Hide()
        end
    end
    if F.mapCorners then
        F.mapCorners:Hide()
    end
    if dock then
        dock:Hide()
    end
    if buttonBag then
        buttonBag:Hide()
    end

    applying = false
    ready = true
end

function F.BeginSize()
    if not cluster or hybrid then
        return
    end
    interacting = true
    sizing = true
    local scale = cluster:GetEffectiveScale()
    local uiScale = UIParent:GetEffectiveScale()
    sizeLeft = cluster:GetLeft() * scale / uiScale
    sizeTop = cluster:GetTop() * scale / uiScale
    local clusterScale = cluster:GetScale()
    if not clusterScale or clusterScale < 0.05 then
        clusterScale = 1
    end
    sizeBase = cluster:GetWidth() * scale / uiScale / clusterScale
    if sizeBase < 40 then
        sizeBase = 220
    end
    db.point = "TOPLEFT"
    db.relPoint = "BOTTOMLEFT"
    db.x = sizeLeft
    db.y = sizeTop
    F.Apply()
    local cursorX = F.CursorOnUI()
    local measured = (cursorX - sizeLeft) / sizeBase
    if not measured or measured < 0.2 then
        measured = db.scale
    end
    -- Remember how the cursor reads against the saved size. Later drags
    -- scale from here, so the resolution multiplier is not stored twice.
    F.sizeUser = db.scale
    F.sizeMeasured = measured
end

function F.UpdateSizeFromCursor()
    local x = F.CursorOnUI()
    local measured = (x - sizeLeft) / sizeBase
    local user = db.scale
    if F.sizeMeasured and F.sizeMeasured > 0.05 and F.sizeUser then
        user = F.sizeUser * measured / F.sizeMeasured
    else
        local screen = F.ResolutionScale()
        if screen < 0.05 then
            screen = 1
        end
        user = measured / screen
    end
    db.scale = F.Clamp(user, MIN_SCALE, MAX_SCALE)
    F.Apply()
end

function F.FinishSize()
    if not sizing then
        return
    end
    sizing = false
    F.SavePosition()
    interacting = false
    if F.SyncOptions then
        F.SyncOptions()
    end
end

function F.StartDrag()
    if not cluster or dragging or sizing or hybrid then
        return
    end
    interacting = true
    dragging = true
    cluster:SetMovable(true)
    cluster:StartMoving()
end

function F.StopDrag()
    if not dragging then
        return
    end
    dragging = false
    if cluster then
        cluster:StopMovingOrSizing()
    end
    F.SavePosition()
    interacting = false
end

-- The bars carry no map clicks, so they move the map even while it is locked.
function F.MakeGrip(frame)
    frame:HookScript("OnMouseDown", function(_, button)
        if button == "LeftButton" then
            F.StartDrag()
        end
    end)
    frame:HookScript("OnMouseUp", function(_, button)
        if button == "LeftButton" then
            F.StopDrag()
        end
    end)
end

function F.ShouldDrag()
    if sizing or hybrid or not db then
        return false
    end
    if IsAltKeyDown() then
        return true
    end
    return not db.locked
end

local COMPASS = { "N", "NW", "W", "SW", "S", "SE", "E", "NE" }

function F.Compass(radians)
    local deg = math.deg(radians or 0) % 360
    local index = math.floor((deg + 22.5) / 45) % 8 + 1
    return COMPASS[index]
end

-- Same axis order HereBeDragons uses: UnitPosition's second value is x.
function F.PlayerWorld()
    local first, second, _, instanceID = UnitPosition("player")
    if not first or not second then
        return nil, nil, instanceID
    end
    return second, first, instanceID
end

function F.ViewRadius()
    if C_Minimap and C_Minimap.GetViewRadius then
        local ok, radius = pcall(C_Minimap.GetViewRadius)
        if ok and type(radius) == "number" and radius > 0 then
            return radius
        end
    end
    local zoom = map and map.GetZoom and map:GetZoom() or 0
    local outdoor = ({ [0] = 466 + 2 / 3, 400, 333 + 1 / 3, 266 + 2 / 6, 200, 133 + 1 / 3 })[zoom] or (466 + 2 / 3)
    return outdoor / 2
end

function F.MapFractions()
    if not map then
        return nil, nil
    end
    local cursorX, cursorY = GetCursorPosition()
    local scale = map:GetEffectiveScale()
    if not scale or scale <= 0 then
        return nil, nil
    end
    local centerX, centerY = map:GetCenter()
    if not centerX or not centerY then
        return nil, nil
    end
    local dx = cursorX / scale - centerX
    local dy = cursorY / scale - centerY
    local halfW = (map:GetWidth() or 0) / 2
    local halfH = (map:GetHeight() or 0) / 2
    if halfW < 1 or halfH < 1 then
        return nil, nil
    end
    if math.abs(dx) > halfW or math.abs(dy) > halfH then
        return nil, nil
    end
    return dx / halfW, dy / halfH
end

function F.DropPinAtCursor()
    local fracX, fracY = F.MapFractions()
    if not fracX then
        F.Say("Click on the map to drop a pin.")
        return
    end
    local px, py, instanceID = F.PlayerWorld()
    if not px or not py then
        F.Say("No position yet. Try again in a moment.")
        return
    end
    local radius = F.ViewRadius()
    local xDist = fracX * radius
    local yDist = -fracY * radius
    local dx, dy = xDist, yDist
    if GetCVar("rotateMinimap") == "1" then
        local facing = GetPlayerFacing()
        if facing then
            local cosF = math.cos(facing)
            local sinF = math.sin(facing)
            dx = xDist * cosF + yDist * sinF
            dy = -xDist * sinF + yDist * cosF
        end
    end
    db.pin = { x = px - dx, y = py - dy, instance = instanceID }
    pinArmed = false
    F.Say("Pin dropped.")
    F.SyncArrow()
    if F.RefreshWorldPin then
        F.RefreshWorldPin()
    end
end

function F.DB()
    return db
end

function F.ClearPin()
    db.pin = nil
    db.trip = nil
    pinArmed = false
    F.arrowLead = nil
    if pinMark then
        pinMark:Hide()
    end
    F.SyncArrow()
    if F.RefreshWorldPin then
        F.RefreshWorldPin()
    end
end

function F.UsePin(pin)
    pinArmed = false
    F.arrowLead = "pin"
    db.pin = pin
    if UpdateWorldClick then
        UpdateWorldClick()
    end
    F.SyncArrow()
    if F.UpdateNav then
        F.UpdateNav()
    end
    if F.RefreshWorldPin then
        F.RefreshWorldPin()
    end
end

function F.PinLabel(text)
    text = string.gsub(text or "", "^%s+", "")
    text = string.gsub(text, "%s+$", "")
    text = string.gsub(text, "%s+", " ")
    if text == "" or #text > 24 or not string.find(text, "%w") then
        return nil
    end
    return text
end

function F.CopyPoint(point, name)
    if type(point) ~= "table" then
        return nil
    end
    local world = tonumber(point.x) and tonumber(point.y)
    local zone = tonumber(point.map) and tonumber(point.zx) and tonumber(point.zy)
    if not world and not zone then
        return nil
    end
    return {
        x = tonumber(point.x),
        y = tonumber(point.y),
        instance = tonumber(point.instance),
        map = tonumber(point.map),
        zx = tonumber(point.zx),
        zy = tonumber(point.zy),
        name = name,
    }
end

function F.TidyPins()
    if not db or type(db.savedPins) ~= "table" then
        if db then
            db.savedPins = {}
        end
        return
    end
    local kept = {}
    local seen = {}
    for index = 1, #db.savedPins do
        local pin = db.savedPins[index]
        local name = type(pin) == "table" and F.PinLabel(pin.name)
        local copy = name and F.CopyPoint(pin, name)
        local key = name and string.lower(name)
        if copy and key and not seen[key] and #kept < 16 then
            seen[key] = true
            kept[#kept + 1] = copy
        end
    end
    db.savedPins = kept
end

function F.FindSavedPin(label)
    local name = F.PinLabel(label)
    if not name or type(db.savedPins) ~= "table" then
        return nil
    end
    local key = string.lower(name)
    for index = 1, #db.savedPins do
        local pin = db.savedPins[index]
        if type(pin) == "table" and type(pin.name) == "string" and string.lower(pin.name) == key then
            return pin, index
        end
    end
end

function F.SavePin(label)
    local name = F.PinLabel(label)
    if not name then
        F.Say("Usage: /nf pin bank")
        return
    end
    if string.lower(name) == "forget" or string.lower(name) == "list" then
        F.Say("That name is reserved. Pick another.")
        return
    end
    local source = db.pin
    if not source then
        local x, y, instanceID = F.PlayerWorld()
        if not x or not y then
            F.Say("No position yet. Try again in a moment.")
            return
        end
        source = { x = x, y = y, instance = instanceID }
    end
    local copy = F.CopyPoint(source, name)
    if not copy then
        F.Say("That pin has no position yet.")
        return
    end
    if type(db.savedPins) ~= "table" then
        db.savedPins = {}
    end
    local _, index = F.FindSavedPin(name)
    if index then
        db.savedPins[index] = copy
    else
        if #db.savedPins >= 16 then
            F.Say("Pin list is full. /nf pin forget bank")
            return
        end
        db.savedPins[#db.savedPins + 1] = copy
    end
    if db.pin then
        db.pin.name = name
        F.Say(name .. " saved.")
    else
        F.Say(name .. " saved. /nf go " .. name .. " follows it.")
    end
    if F.UpdateNav then
        F.UpdateNav()
    end
end

function F.ForgetPin(label)
    local name = F.PinLabel(label)
    if not name then
        F.Say("Usage: /nf pin forget bank")
        return
    end
    local saved, index = F.FindSavedPin(name)
    if not index then
        F.Say("No pin named " .. name .. ".")
        return
    end
    local savedName = saved.name or name
    table.remove(db.savedPins, index)
    F.Say(savedName .. " forgotten.")
end

function F.GoPin(label)
    local name = F.PinLabel(label)
    if not name then
        F.Say("Usage: /nf go bank")
        return
    end
    local saved = F.FindSavedPin(name)
    if not saved then
        F.Say("No pin named " .. name .. ".")
        return
    end
    local copy = F.CopyPoint(saved, saved.name)
    if not copy then
        F.Say("That pin has no position yet.")
        return
    end
    db.pin = copy
    pinArmed = false
    F.Say("Following " .. (saved.name or name) .. ".")
    F.SyncArrow()
    if F.UpdateNav then
        F.UpdateNav()
    end
    if F.RefreshWorldPin then
        F.RefreshWorldPin()
    end
end

function F.ListPins()
    local pins = db.savedPins
    local names = {}
    if type(pins) == "table" then
        for index = 1, #pins do
            local pin = pins[index]
            if type(pin) == "table" and type(pin.name) == "string" and pin.name ~= "" then
                names[#names + 1] = pin.name
            end
        end
    end
    if #names < 1 then
        F.Say("No saved pins. /nf pin bank saves this spot.")
        return
    end
    F.Say("Pins: " .. table.concat(names, ", ") .. ".")
end

function F.NotePinArrival()
    if not db or pinArmed or UnitIsDeadOrGhost("player") then
        return
    end
    if F.ArriveWalk and F.ArriveWalk() then
        return
    end
    local pin = db.pin
    if not pin then
        F.pinArrivePin = nil
        F.pinArriveNear = false
        return
    end
    local state, _, _, yards = F.PinOffset()
    yards = F.Plain(yards)
    if state ~= "ok" or type(yards) ~= "number" then
        return
    end
    local near = yards <= 20
    if pin ~= F.pinArrivePin then
        F.pinArrivePin = pin
        F.pinArriveNear = near
        return
    end
    if F.pinArriveNear then
        if yards >= 35 then
            F.pinArriveNear = false
        end
        return
    end
    if not near then
        return
    end
    F.pinArriveNear = true
    if not F.Enabled("warnArrive") then
        return
    end
    local title = type(pin.name) == "string" and pin.name or ""
    if title ~= "" then
        F.Say(title .. " reached.")
    else
        F.Say("Pin reached.")
    end
end

function F.ClearActivePin()
    local kept = db and db.pin and type(db.pin.name) == "string" and db.pin.name or ""
    F.ClearPin()
    if F.UpdateNav then
        F.UpdateNav()
    end
    if kept ~= "" then
        F.Say("Pin cleared. " .. kept .. " is still saved.")
    else
        F.Say("Pin cleared.")
    end
end

local arrowUID
local arrowKey
local arrowWarned = false
local arrowOffWarned = false

function F.TomTomAddon()
    if TomTom and TomTom.AddWaypoint and TomTom.RemoveWaypoint then
        return TomTom
    end
    return nil
end

function F.HereBeDragons()
    if not LibStub then
        return nil
    end
    local ok, lib = pcall(LibStub, "HereBeDragons-2.0", true)
    if ok and lib and lib.GetZoneCoordinatesFromWorldInstance then
        return lib
    end
    return nil
end

function F.RoundZone(value)
    return math.floor(value * 10000 + 0.5) / 10000
end

function F.ClearArrow()
    local uid = arrowUID
    arrowUID = nil
    arrowKey = nil
    local tom = F.TomTomAddon()
    if uid and tom then
        pcall(tom.RemoveWaypoint, tom, uid)
    end
end

function F.PointArrow(mapID, x, y, title)
    x = F.RoundZone(x)
    y = F.RoundZone(y)
    local key = string.format("%d:%.4f:%.4f:%s", mapID, x, y, title or "")
    local tom = F.TomTomAddon()
    if key == arrowKey and arrowUID and tom and tom:IsValidWaypoint(arrowUID) then
        return
    end
    F.ClearArrow()
    tom = F.TomTomAddon()
    if not tom then
        return
    end
    local arrival = 10
    if tom.profile and tom.profile.arrow and tonumber(tom.profile.arrow.arrival) then
        arrival = tom.profile.arrow.arrival
    end
    if tom.profile and tom.profile.arrow and tom.profile.arrow.enable == false and not arrowOffWarned then
        arrowOffWarned = true
        F.Say("Turn on the arrow in TomTom to see the direction.")
    end
    local ok, uid = pcall(tom.AddWaypoint, tom, mapID, x, y, {
        title = title or "Pin",
        persistent = false,
        minimap = false,
        world = false,
        crazy = true,
        silent = true,
        cleardistance = 0,
        arrivaldistance = arrival,
        from = "NavigateForever",
    })
    if ok and type(uid) == "table" then
        arrowUID = uid
        arrowKey = key
    end
end

-- World yards to the zone point TomTom's arrow uses. "wait" means try again.
-- "other" means the point is not on this world.
function F.ArrowTarget(point, title)
    if not point then
        return nil
    end
    title = title or "Pin"
    if point.map and point.zx and point.zy then
        return point.map, point.zx, point.zy, string.format("%s %.1f, %.1f", title, point.zx * 100, point.zy * 100)
    end
    if not point.x or not point.y then
        return nil
    end
    local rawX, rawY, rawInstance = F.PlayerWorld()
    if not rawX or not rawY then
        return "wait"
    end
    if point.instance and rawInstance and point.instance ~= rawInstance then
        return "other"
    end
    local hbd = F.HereBeDragons()
    if not hbd then
        return "wait"
    end
    local worldX, worldY, instance = hbd:GetPlayerWorldPosition()
    local mapID = hbd.GetPlayerZone and select(1, hbd:GetPlayerZone())
    if not mapID and C_Map and C_Map.GetBestMapForUnit then
        mapID = C_Map.GetBestMapForUnit("player")
    end
    if not worldX or not worldY or not instance or not mapID then
        return "wait"
    end
    local zx, zy = hbd:GetZoneCoordinatesFromWorldInstance(
        worldX + (point.x - rawX),
        worldY + (point.y - rawY),
        instance,
        mapID,
        true
    )
    if not zx or not zy then
        return "other"
    end
    return mapID, zx, zy, title
end

function F.PinArrowTarget()
    local pin = db and db.pin
    local title = pin and type(pin.name) == "string" and pin.name ~= "" and pin.name or "Pin"
    return F.ArrowTarget(pin, title)
end

local PIN_QUIPS = {
    "Murlocs ahead.",
    "Route not cleared of murlocs.",
    "Loot is this way. So are the murlocs.",
    "Shortcut found. Safety was not included.",
    "The pin is set. The murlocs were already there.",
    "Recalculating. The murlocs have not moved.",
    "Estimated arrival: after one more pull.",
    "Hostile wildlife advisory.",
}

function F.PinChat(mapID, x, y)
    local quip = PIN_QUIPS[math.random(#PIN_QUIPS)]
    local spot = string.format("%.1f, %.1f", x * 100, y * 100)
    if C_Map and C_Map.GetMapInfo then
        local ok, info = pcall(C_Map.GetMapInfo, mapID)
        if ok and info and type(info.name) == "string" and info.name ~= "" then
            spot = spot .. ", " .. info.name
        end
    end
    local hbd = F.HereBeDragons()
    if hbd and hbd.GetPlayerWorldPosition and hbd.GetWorldCoordinatesFromZone and hbd.GetWorldVector then
        local px, py, playerInstance = hbd:GetPlayerWorldPosition()
        local pinX, pinY, pinInstance = hbd:GetWorldCoordinatesFromZone(x, y, mapID)
        if px and py and pinX and pinY and playerInstance and pinInstance == playerInstance then
            local angle, yards = hbd:GetWorldVector(playerInstance, px, py, pinX, pinY)
            if yards and angle then
                return string.format("%s %d yd %s. %s.", quip, yards + 0.5, F.Compass(angle), spot)
            end
        elseif pinInstance and playerInstance and pinInstance ~= playerInstance then
            return quip .. " " .. spot .. ". Pin is on another map."
        end
    end
    return quip .. " " .. spot .. "."
end

function F.DropPinOnWorldMap()
    if not WorldMapFrame or not WorldMapFrame.GetNormalizedCursorPosition or not WorldMapFrame:IsShown() then
        F.Say("Open the world map, then Ctrl-click the spot.")
        return
    end
    local mapID = WorldMapFrame.mapID
    local x, y = WorldMapFrame:GetNormalizedCursorPosition()
    if not mapID or mapID == 0 or not x or not y or x < 0 or x > 1 or y < 0 or y > 1 then
        return
    end
    local pin = { map = mapID, zx = x, zy = y }
    local hbd = F.HereBeDragons()
    if hbd and hbd.GetWorldCoordinatesFromZone then
        local wx, wy, instance = hbd:GetWorldCoordinatesFromZone(x, y, mapID)
        if wx and wy then
            pin.x = wx
            pin.y = wy
            pin.instance = instance
        end
    end
    db.pin = pin
    pinArmed = false
    if UpdateWorldClick then
        UpdateWorldClick()
    end
    if F.Enabled("warnPin") then
        F.Say(F.PinChat(mapID, x, y))
    end
    F.SyncArrow()
    if F.UpdateNav then
        F.UpdateNav()
    end
    if F.RefreshWorldPin then
        F.RefreshWorldPin()
    end
end

local worldClick

function UpdateWorldClick()
    local handler = worldClick
    if not handler then
        return
    end
    local ctrl = IsControlKeyDown()
    if not pinArmed and not ctrl then
        if handler.SetPassThroughButtons and not InCombatLockdown() then
            handler:SetPassThroughButtons("LeftButton", "RightButton", "MiddleButton", "Button4", "Button5")
        end
        handler:Hide()
        return
    end
    if handler.SetPassThroughButtons and not InCombatLockdown() then
        if ctrl then
            handler:SetPassThroughButtons("MiddleButton", "Button4", "Button5")
        else
            handler:SetPassThroughButtons("LeftButton", "MiddleButton", "Button4", "Button5")
        end
    end
    handler:Show()
end

function F.HookWorldMap()
    if F.EnsureWorldPin then
        pcall(F.EnsureWorldPin)
    end
    if F.WatchOpenMap then
        pcall(F.WatchOpenMap)
    end
    if worldClick or not WorldMapFrame or not WorldMapFrame.ScrollContainer then
        return
    end
    local handler = CreateFrame("Frame", "NavigateForeverWorldClick", WorldMapFrame.ScrollContainer)
    handler:SetAllPoints()
    handler:EnableMouse(true)
    handler:SetFrameLevel((WorldMapFrame.ScrollContainer:GetFrameLevel() or 0) + 20)
    handler:Hide()
    handler:RegisterEvent("MODIFIER_STATE_CHANGED")
    handler:SetScript("OnEvent", UpdateWorldClick)
    handler:SetScript("OnMouseUp", function(_, button)
        if button == "RightButton" or (button == "LeftButton" and IsControlKeyDown()) then
            F.DropPinOnWorldMap()
        end
    end)
    worldClick = handler
    UpdateWorldClick()
end

-- The world map click is taken here, so the game's own pin never appears.
-- This draws Navigate Forever's pin on that map, including OpenMap's stitched view.
local WORLD_PIN = "NavigateForeverWorldPin"

function F.ActivePinMap()
    local pin = db and db.pin
    if type(pin) ~= "table" then
        return nil
    end
    local mapID = tonumber(pin.map)
    local zx = tonumber(pin.zx)
    local zy = tonumber(pin.zy)
    if mapID and zx and zy then
        return mapID, zx, zy
    end
    local resolved, x, y = F.ArrowTarget(pin, "Pin")
    resolved, x, y = tonumber(resolved), tonumber(x), tonumber(y)
    if resolved and x and y then
        return resolved, x, y
    end
    return nil
end

function F.PinCanvasXY()
    local mapID, zx, zy = F.ActivePinMap()
    if not mapID or not WorldMapFrame then
        return nil
    end
    local shown = WorldMapFrame.GetMapID and WorldMapFrame:GetMapID() or WorldMapFrame.mapID
    shown = tonumber(F.Plain(shown))
    if shown == mapID then
        return zx, zy
    end
    local api = OpenMapAPI
    if shown and type(api) == "table" and api.major == 1 and type(api.IsStitched) == "function" and api.IsStitched()
        and type(api.WorldFromMap) == "function" and type(api.MapFromWorld) == "function" then
        local ok, u, v = pcall(api.WorldFromMap, mapID, zx, zy)
        u, v = ok and F.Plain(u), ok and F.Plain(v)
        if type(u) == "number" and type(v) == "number" then
            local placed, x, y = pcall(api.MapFromWorld, shown, u, v)
            x, y = placed and F.Plain(x), placed and F.Plain(y)
            if type(x) == "number" and type(y) == "number" then
                return x, y
            end
        end
    end
    if not shown or not C_Map or not C_Map.GetWorldPosFromMapPos or not C_Map.GetMapPosFromWorldPos or not CreateVector2D then
        return nil
    end
    local ok, cont, world = pcall(C_Map.GetWorldPosFromMapPos, mapID, CreateVector2D(zx, zy))
    cont = ok and tonumber(F.Plain(cont))
    if cont == nil or type(world) ~= "table" then
        return nil
    end
    local posOK, onMap, pos = pcall(C_Map.GetMapPosFromWorldPos, cont, world, shown)
    onMap = posOK and tonumber(F.Plain(onMap))
    if onMap ~= shown or type(pos) ~= "table" or type(pos.GetXY) ~= "function" then
        return nil
    end
    local xyOK, x, y = pcall(pos.GetXY, pos)
    x, y = xyOK and F.Plain(x), xyOK and F.Plain(y)
    if type(x) ~= "number" or type(y) ~= "number" or x < 0 or x > 1 or y < 0 or y > 1 then
        return nil
    end
    return x, y
end

function F.TintWorldPin()
    local map = WorldMapFrame
    if not map or not map.EnumeratePinsByTemplate then
        return
    end
    local br, bg, bb = F.BorderColor()
    local hr, hg, hb = F.ThemeColor("hover")
    local function tint()
        for pin in map:EnumeratePinsByTemplate(WORLD_PIN) do
            if pin.nfRing then
                pin.nfRing:SetColorTexture(br, bg, bb, 1)
                pin.nfDot:SetColorTexture(hr, hg, hb, 1)
                pin.nfGlow:SetVertexColor(br, bg, bb)
            end
        end
    end
    pcall(tint)
end

local function DrawWorldPin()
    local provider = F.worldPinProvider
    if not provider then
        return
    end
    if InCombatLockdown() then
        F.worldPinDirty = true
        return
    end
    local ok = pcall(provider.RefreshAllData, provider)
    F.worldPinDirty = not ok
end

function F.RefreshWorldPin()
    if F.worldPinBusy then
        return
    end
    F.worldPinBusy = true
    if not F.worldPinProvider then
        F.EnsureWorldPin()
    end
    DrawWorldPin()
    F.worldPinBusy = false
    if F.worldPinProvider and not F.worldPinLater and C_Timer and C_Timer.After then
        F.worldPinLater = true
        C_Timer.After(0, function()
            F.worldPinLater = nil
            if F.worldPinBusy then
                return
            end
            F.worldPinBusy = true
            DrawWorldPin()
            F.worldPinBusy = false
        end)
    end
end

function F.WatchOpenMap()
    local api = OpenMapAPI
    if F.openMapWatch or type(api) ~= "table" or type(api.RegisterCallback) ~= "function" then
        return
    end
    F.openMapWatch = true
    pcall(function()
        api.RegisterCallback(F, "OpenMap_StitchedChanged", function()
            F.RefreshWorldPin()
        end)
        api.RegisterCallback(F, "OpenMap_ViewChanged", function()
            local shown = WorldMapFrame and WorldMapFrame.GetMapID and WorldMapFrame:GetMapID()
            shown = tonumber(F.Plain(shown))
            if shown ~= F.worldPinHost then
                F.worldPinHost = shown
                F.RefreshWorldPin()
            end
        end)
    end)
end

function F.EnsureWorldPin()
    if F.worldPinProvider or not WorldMapFrame then
        return
    end
    if not (MapCanvasDataProviderMixin and MapCanvasPinMixin and CreateFromMixins and Mixin) then
        return
    end
    if not (WorldMapFrame.GetCanvas and WorldMapFrame.AddDataProvider and WorldMapFrame.pinPools and CreateUnsecuredRegionPoolInstance) then
        return
    end
    local canvas = WorldMapFrame:GetCanvas()
    if not canvas then
        return
    end
    local methods = {}
    function methods:OnLoad()
        self:SetSize(28, 28)
        self:EnableMouse(false)
        if self.SetMouseClickEnabled then
            self:SetMouseClickEnabled(false)
        end
        if not pcall(self.UseFrameLevelType, self, "PIN_FRAME_LEVEL_WAYPOINT_LOCATION") then
            pcall(self.UseFrameLevelType, self, "PIN_FRAME_LEVEL_AREA_POI")
        end
        if self.SetScalingLimits then
            self:SetScalingLimits(1, 1, 1.2)
        end
        local glow = self:CreateTexture(nil, "BACKGROUND")
        glow:SetTexture("Interface\\Cooldown\\Ping4")
        glow:SetBlendMode("ADD")
        glow:SetPoint("CENTER")
        glow:SetSize(52, 52)
        local ring = self:CreateTexture(nil, "ARTWORK")
        ring:SetColorTexture(1, 0.82, 0.25, 1)
        ring:SetAllPoints()
        local dot = self:CreateTexture(nil, "OVERLAY")
        dot:SetColorTexture(0.18, 0.66, 1, 1)
        dot:SetPoint("TOPLEFT", 7, -7)
        dot:SetPoint("BOTTOMRIGHT", -7, 7)
        self.nfGlow = glow
        self.nfRing = ring
        self.nfDot = dot
    end
    function methods:OnAcquired(x, y)
        self:SetPosition(x, y)
        local top = nil
        if OpenMapAPI and OpenMapAPI.ArtTopLevel and OpenMapAPI.IsStitched and OpenMapAPI.IsStitched() then
            top = OpenMapAPI.ArtTopLevel()
        end
        if type(top) == "number" and top > 0 then
            self:SetFrameLevel(top + 30)
        end
        local br, bg, bb = F.BorderColor()
        local hr, hg, hb = F.ThemeColor("hover")
        self.nfRing:SetColorTexture(br, bg, bb, 1)
        self.nfDot:SetColorTexture(hr, hg, hb, 1)
        self.nfGlow:SetVertexColor(br, bg, bb)
        self.nfGlow:SetAlpha(0.9)
        self:EnableMouse(false)
        self:Show()
    end
    function methods:OnReleased()
    end
    local pool = CreateUnsecuredRegionPoolInstance(WORLD_PIN)
    pool.parent = canvas
    pool.creationFunc = function()
        local frame = CreateFrame("Frame", nil, canvas)
        frame:SetSize(28, 28)
        Mixin(frame, MapCanvasPinMixin)
        Mixin(frame, methods)
        return frame
    end
    pool.createFunc = pool.creationFunc
    pool.resetterFunc = function(_, pin)
        pin:Hide()
        pin:ClearAllPoints()
        if pin.OnReleased then
            pin:OnReleased()
        end
        pin.pinTemplate = nil
        pin.owningMap = nil
    end
    pool.resetFunc = pool.resetterFunc
    if not pool.SetResetDisallowedIfNew then
        function pool:SetResetDisallowedIfNew()
        end
    end
    local provider = CreateFromMixins(MapCanvasDataProviderMixin)
    function provider:RemoveAllData()
        local map = self:GetMap()
        if map and map.RemoveAllPinsByTemplate then
            map:RemoveAllPinsByTemplate(WORLD_PIN)
        end
    end
    function provider:RefreshAllData()
        if InCombatLockdown() then
            F.worldPinDirty = true
            return
        end
        self:RemoveAllData()
        local x, y = F.PinCanvasXY()
        if x == nil or y == nil then
            return
        end
        local map = self:GetMap()
        if map then
            map:AcquirePin(WORLD_PIN, x, y)
        end
    end
    function provider:OnShow()
        F.RefreshWorldPin()
    end
    function provider:OnMapChanged()
        F.RefreshWorldPin()
    end
    function provider:OnHide()
        if InCombatLockdown() then
            F.worldPinDirty = true
            return
        end
        self:RemoveAllData()
    end
    WorldMapFrame.pinPools[WORLD_PIN] = pool
    F.worldPinProvider = provider
    WorldMapFrame:AddDataProvider(provider)
    F.WatchOpenMap()
end

function F.MapPinArrowTarget()
    if not (C_Map and C_Map.GetUserWaypoint and C_SuperTrack and C_SuperTrack.IsSuperTrackingUserWaypoint) then
        return nil
    end
    local ok, tracking = pcall(C_SuperTrack.IsSuperTrackingUserWaypoint)
    if not ok or not tracking then
        return nil
    end
    local point = C_Map.GetUserWaypoint()
    if not point or not point.uiMapID or not point.position then
        return nil
    end
    local x, y = point.position.x, point.position.y
    if (not x or not y) and point.position.GetXY then
        x, y = point.position:GetXY()
    end
    if not x or not y then
        return nil
    end
    return point.uiMapID, x, y, "Map pin"
end

local function QuestOnMap(questID, mapID)
    if not (mapID and mapID > 0 and C_QuestLog and C_QuestLog.GetQuestsOnMap) then
        return nil
    end
    local listedOK, listed = pcall(C_QuestLog.GetQuestsOnMap, mapID)
    if not listedOK or type(listed) ~= "table" then
        return nil
    end
    for _, info in ipairs(listed) do
        if info.questID == questID and info.x and info.y then
            return mapID, info.x, info.y
        end
    end
    return nil
end

function F.QuestArrowTarget()
    if not (C_SuperTrack and C_SuperTrack.GetSuperTrackedQuestID and C_QuestLog) then
        return nil
    end
    if C_SuperTrack.IsSuperTrackingUserWaypoint then
        local trackOK, tracking = pcall(C_SuperTrack.IsSuperTrackingUserWaypoint)
        if trackOK and tracking then
            return nil
        end
    end
    local ok, questID = pcall(C_SuperTrack.GetSuperTrackedQuestID)
    questID = ok and tonumber(F.Plain(questID))
    if not questID or questID == 0 then
        return nil
    end
    local mapID, x, y
    if C_QuestLog.GetNextWaypoint then
        local wpOK, wpMap, wpX, wpY = pcall(C_QuestLog.GetNextWaypoint, questID)
        if wpOK then
            mapID, x, y = wpMap, wpX, wpY
        end
    end
    local playerMap
    if C_Map and C_Map.GetBestMapForUnit then
        local mapOK, id = pcall(C_Map.GetBestMapForUnit, "player")
        playerMap = mapOK and tonumber(F.Plain(id))
    end
    if not (mapID and mapID > 0 and x and y) and playerMap and C_QuestLog.GetNextWaypointForMap then
        local forOK, stepX, stepY = pcall(C_QuestLog.GetNextWaypointForMap, questID, playerMap)
        if forOK and stepX and stepY then
            mapID, x, y = playerMap, stepX, stepY
        end
    end
    if not (mapID and mapID > 0 and x and y) then
        mapID, x, y = QuestOnMap(questID, playerMap)
    end
    if not (mapID and mapID > 0 and x and y) and GetQuestUiMapID then
        local questOK, questMap = pcall(GetQuestUiMapID, questID, true)
        questMap = questOK and tonumber(F.Plain(questMap))
        if questMap and questMap ~= playerMap then
            mapID, x, y = QuestOnMap(questID, questMap)
        end
    end
    if not (mapID and mapID > 0 and x and y) and playerMap and C_TaskQuest and C_TaskQuest.GetQuestLocation then
        local taskOK, taskX, taskY = pcall(C_TaskQuest.GetQuestLocation, questID, playerMap)
        if taskOK and taskX and taskY then
            mapID, x, y = playerMap, taskX, taskY
        end
    end
    if not (mapID and mapID > 0 and x and y) then
        return nil
    end
    local title = "Quest"
    if C_QuestLog.GetTitleForQuestID then
        local nameOK, name = pcall(C_QuestLog.GetTitleForQuestID, questID)
        if nameOK and type(name) == "string" and name ~= "" then
            title = name
        end
    end
    return mapID, x, y, title
end

function F.NoteTrackedQuest()
    if not (C_SuperTrack and C_SuperTrack.GetSuperTrackedQuestID) then
        return
    end
    if C_SuperTrack.IsSuperTrackingUserWaypoint then
        local trackOK, tracking = pcall(C_SuperTrack.IsSuperTrackingUserWaypoint)
        if trackOK and tracking then
            F.arrowLead = "waypoint"
            return
        end
    end
    local ok, questID = pcall(C_SuperTrack.GetSuperTrackedQuestID)
    questID = ok and tonumber(F.Plain(questID))
    if questID and questID > 0 then
        F.arrowLead = "quest"
    end
end

function F.SyncArrow()
    if not db then
        return
    end
    if F.OnTaxi() then
        F.ClearArrow()
        if F.HideOwnArrow then
            F.HideOwnArrow()
        end
        return
    end
    local mapID, x, y, title
    local function UseCorpse()
        local first, second, third, fourth = F.DeathArrowTarget()
        if first == "wait" and F.HereBeDragons() then
            return "wait"
        end
        if type(first) == "number" then
            mapID, x, y, title = first, second, third, fourth
            return "shown"
        end
        return nil
    end
    local function UsePin()
        if not db.pin then
            return nil
        end
        if F.ArrowInstruction then
            local text = F.ArrowInstruction()
            if type(text) == "string" and text ~= "" then
                F.ClearArrow()
                if F.ShowOwnArrow then
                    F.ShowOwnArrow(nil, nil, nil, text)
                end
                return "shown"
            end
        end
        local first, second, third, fourth = F.PinArrowTarget()
        if first == "wait" then
            return "wait"
        end
        if first == "other" or type(first) ~= "number" then
            return "hide"
        end
        mapID, x, y, title = first, second, third, fourth
        return "shown"
    end
    local function UseQuest()
        local questMap, questX, questY, questTitle = F.QuestArrowTarget()
        if not questMap then
            return nil
        end
        mapID, x, y, title = questMap, questX, questY, questTitle
        return "shown"
    end
    local function UseWaypoint()
        local pinMap, pinX, pinY, pinTitle = F.MapPinArrowTarget()
        if not pinMap then
            return nil
        end
        mapID, x, y, title = pinMap, pinX, pinY, pinTitle
        return "shown"
    end
    -- A quest you are tracking leads. Mail, Find, or a pin you dropped leads
    -- after you choose it, until you track a quest again. The corpse leads while you are dead.
    local order
    if UnitIsDeadOrGhost("player") then
        order = { UseCorpse, UseQuest, UsePin, UseWaypoint }
    elseif F.arrowLead == "pin" then
        order = { UsePin, UseWaypoint, UseQuest, UseCorpse }
    elseif F.arrowLead == "waypoint" then
        order = { UseWaypoint, UseQuest, UsePin, UseCorpse }
    else
        order = { UseQuest, UseWaypoint, UsePin, UseCorpse }
    end
    for _, choose in ipairs(order) do
        local result = choose()
        if result == "wait" then
            return
        end
        if result == "hide" then
            mapID = nil
            break
        end
        if result == "shown" then
            if not mapID then
                return
            end
            break
        end
    end
    if not mapID then
        F.ClearArrow()
        if F.HideOwnArrow then
            F.HideOwnArrow()
        end
        return
    end
    F.ClearArrow()
    if F.ShowOwnArrow then
        F.ShowOwnArrow(mapID, x, y, title)
    end
end

local ARROW_MIN, ARROW_MAX = 5, 300

function F.ArrowScalePercent()
    local scale = db and tonumber(db.arrowScale) or 1
    return F.Clamp(F.Round(scale * 100), ARROW_MIN, ARROW_MAX)
end

function F.SetArrowScale(percent)
    local scale = F.Clamp(percent, ARROW_MIN, ARROW_MAX) / 100
    if db then
        db.arrowScale = scale
    end
    if F.LayoutOwnArrow then
        F.LayoutOwnArrow()
    end
    return true
end

function F.PlayerCoords()
    if not C_Map or not C_Map.GetBestMapForUnit or not C_Map.GetPlayerMapPosition then
        return nil, nil
    end
    local mapID = C_Map.GetBestMapForUnit("player")
    if not mapID then
        return nil, nil
    end
    local pos = C_Map.GetPlayerMapPosition(mapID, "player")
    if not pos then
        return nil, nil
    end
    if type(pos) == "number" then
        return pos, select(2, C_Map.GetPlayerMapPosition(mapID, "player"))
    end
    if pos.GetXY then
        return pos:GetXY()
    end
    return nil, nil
end

function F.Bearing(px, py, pin)
    local deltaX = pin.x - px
    local deltaY = pin.y - py
    local angle = math.atan2(-deltaX, deltaY)
    if angle > 0 then
        angle = (math.pi * 2) - angle
    else
        angle = -angle
    end
    return angle
end

local bagOpen = false
local placingBag = false
local buttonsReleased = false
local collected = {}
local hookedBag = {}

local BLIZZARD_BUTTONS = {
    MiniMapTracking = true,
    MiniMapTrackingButton = true,
    MiniMapTrackingDropDownButton = true,
    GameTimeFrame = true,
    TimeManagerClockButton = true,
    MinimapZoomIn = true,
    MinimapZoomOut = true,
    MiniMapMailFrame = true,
    MiniMapWorldMapButton = true,
    MiniMapInstanceDifficulty = true,
    MiniMapBattlefieldFrame = true,
    QueueStatusMinimapButton = true,
    MinimapZoneTextButton = true,
    AddonCompartmentFrame = true,
    ExpansionLandingPageMinimapButton = true,
    GarrisonLandingPageMinimapButton = true,
}

function F.BarButtonList()
    local tracking
    if cluster and cluster.Tracking then
        tracking = cluster.Tracking.Button or cluster.Tracking
    end
    tracking = tracking or F.FindFrame("MiniMapTrackingButton") or F.FindFrame("MiniMapTracking")
    return tracking, F.FindFrame("GameTimeFrame"), F.FindFrame("AddonCompartmentFrame"), F.FindFrame("TimeManagerClockButton")
end

function F.IsAddonMinimapButton(button)
    local tracking, calendar, addons, clock = F.BarButtonList()
    if button == grip or button == dock or button == popButton or button == brandButton then
        return false
    end
    if button == tracking or button == calendar or button == addons or button == clock then
        return false
    end
    if nav and button.GetParent and button:GetParent() == nav then
        return false
    end
    if not button or not button.IsObjectType or not button:IsObjectType("Button") then
        return false
    end
    local name = button.GetName and button:GetName()
    if not name or BLIZZARD_BUTTONS[name] or name:find("^NavigateForever", 1, true) then
        return false
    end
    if name:find("LibDBIcon", 1, true) or name:find("MinimapButton", 1, true) or name:find("MinimapIcon", 1, true) then
        return true
    end
    local parent = button.GetParent and button:GetParent()
    if parent == Minimap or parent == map or parent == cluster then
        return true
    end
    local above = parent and parent.GetParent and parent:GetParent()
    return above == Minimap or above == map or above == cluster
end

function F.LayoutBag()
    if not buttonBag or placingBag then
        return
    end
    placingBag = true
    local shown = {}
    for button in pairs(collected) do
        if bagOpen then
            shown[#shown + 1] = button
        else
            button:Hide()
        end
    end
    table.sort(shown, function(a, b)
        return (a:GetName() or "") < (b:GetName() or "")
    end)
    local y = -6
    for _, button in ipairs(shown) do
        button:SetParent(buttonBag)
        button:SetScale(1)
        button:ClearAllPoints()
        button:SetPoint("TOP", buttonBag, "TOP", 0, y)
        button:Show()
        y = y - (button:GetHeight() or 31) - 4
    end
    if bagOpen and dock then
        buttonBag:SetSize(46, math.max(24, -y + 6))
        buttonBag:ClearAllPoints()
        buttonBag:SetPoint("TOPLEFT", dock, "TOPRIGHT", 6, 0)
        buttonBag:Show()
    elseif buttonBag then
        buttonBag:Hide()
    end
    placingBag = false
end

function F.WatchButton(button)
    if collected[button] then
        return
    end
    collected[button] = true
    if not bagOpen then
        button:Hide()
    end
    if hookedBag[button] then
        return
    end
    hookedBag[button] = true
    button:HookScript("OnShow", function(self)
        if buttonsReleased or placingBag or bagOpen then
            return
        end
        self:Hide()
    end)
    hooksecurefunc(button, "SetPoint", function()
        if buttonsReleased or placingBag then
            return
        end
        if bagOpen then
            F.LayoutBag()
        else
            button:Hide()
        end
    end)
end

function F.ReleaseAddonButtons()
    buttonsReleased = true
    placingBag = true
    for button in pairs(collected) do
        if Minimap and button.SetParent then
            pcall(button.SetParent, button, Minimap)
        end
        button:Show()
    end
    placingBag = false
    if dock then
        dock:Hide()
    end
    if buttonBag then
        buttonBag:Hide()
    end
end

function F.OnScreenSize(frame)
    local width = frame and frame.GetWidth and frame:GetWidth() or 0
    local height = frame and frame.GetHeight and frame:GetHeight() or 0
    local scale = frame and frame.GetEffectiveScale and frame:GetEffectiveScale() or 1
    local ui = UIParent:GetEffectiveScale() or 1
    if not ui or ui == 0 then
        ui = 1
    end
    return (width or 0) * scale / ui, (height or 0) * scale / ui
end

function F.DockBarButtons(barWidth)
    if not nav then
        return
    end
    local tracking, calendar, addons, clock = F.BarButtonList()

    local function adopt(button)
        if not button then
            return false
        end
        F.Remember(button)
        if button:GetParent() ~= nav then
            pcall(button.SetParent, button, nav)
        end
        return button:GetParent() == nav
    end

    local function measure(button)
        local width = button:GetWidth() or 0
        local height = button:GetHeight() or 0
        if width < 8 then
            width = 22
        end
        if height < 8 then
            height = 22
        end
        return width, height
    end

    local function make(button, kind)
        if not adopt(button) then
            return nil
        end
        local width, height = measure(button)
        local scale = 1
        if kind == "icon" then
            scale = 28 / math.max(width, height)
        elseif kind == "clock" then
            scale = math.min(56 / width, 22 / height)
        end
        return { button = button, width = width, scale = scale }
    end

    local left = {}
    local right = {}
    local function add(list, button, kind)
        local item = make(button, kind)
        if item then
            list[#list + 1] = item
        end
    end
    add(left, nav.pinBtn, "chip")
    add(left, nav.clearBtn, "chip")
    add(left, nav.settingsBtn, "chip")
    local mail = F.FindFrame("MiniMapMailFrame")
    if not mail and MinimapCluster and MinimapCluster.IndicatorFrame then
        mail = MinimapCluster.IndicatorFrame.MailFrame
    end
    if mail and mail.IsShown and mail:IsShown() then
        add(right, mail, "icon")
        if right[#right] and right[#right].button == mail then
            right[#right].optional = true
        end
    end
    add(right, tracking, "icon")
    add(right, calendar, "icon")
    add(right, addons, "icon")
    add(right, clock, "clock")

    local gap = 6
    local edge = 10
    local function span(list)
        local total = 0
        for index = 1, #list do
            total = total + list[index].width * list[index].scale
        end
        return total
    end
    local fixed = edge * 2 + 12 + gap * math.max(0, #left - 1) + gap * math.max(0, #right - 1)
    local content = span(left) + span(right)
    local fit = 1
    local room = (barWidth or 220) - fixed
    if content > 0 and room > 0 and content > room then
        fit = math.max(0.5, room / content)
    end

    -- A scaled frame multiplies its own SetPoint offsets, so divide them back out.
    local rowY = -26
    local function seat(item, point, relative, x)
        local button = item.button
        local scale = item.scale * fit
        pcall(button.SetScale, button, scale)
        if button.SetFixedFrameStrata then
            pcall(button.SetFixedFrameStrata, button, false)
        end
        if button.SetFixedFrameLevel then
            pcall(button.SetFixedFrameLevel, button, false)
        end
        pcall(button.SetFrameStrata, button, "MEDIUM")
        pcall(button.SetFrameLevel, button, (nav:GetFrameLevel() or 10) + 2)
        button:ClearAllPoints()
        button:SetPoint(point, nav, relative, x / scale, rowY / scale)
        if not item.optional and not button:IsShown() then
            button:Show()
        end
        return item.width * scale
    end

    local x = edge
    for index = 1, #left do
        x = x + seat(left[index], "LEFT", "TOPLEFT", x) + gap
    end
    x = -edge
    for index = #right, 1, -1 do
        x = x - seat(right[index], "RIGHT", "TOPRIGHT", x) - gap
    end
end

function F.CollectAddonButtons()
    if hybrid or InCombatLockdown() then
        return
    end
    local function scan(frame, depth)
        if not frame or not frame.GetChildren or depth > 2 then
            return
        end
        if frame == nav or frame == F.navFoot or frame == F.zoneBar or frame == F.goBar or frame == dock or frame == buttonBag then
            return
        end
        for _, child in ipairs({ frame:GetChildren() }) do
            if not (child.IsForbidden and child:IsForbidden()) then
                local ok, wanted = pcall(F.IsAddonMinimapButton, child)
                if ok and wanted and not (child.IsProtected and child:IsProtected()) then
                    F.WatchButton(child)
                end
                scan(child, depth + 1)
            end
        end
    end
    scan(Minimap, 0)
    scan(map, 0)
    scan(cluster, 0)
    scan(container, 0)
    F.LayoutBag()
end

function F.PlaceDock()
    if not dock or dock.dragging then
        return
    end
    dock:SetScale(1)
    dock:SetFrameStrata("TOOLTIP")
    dock:SetFrameLevel(500)
    if db and db.dockPoint then
        if not dock.placed then
            dock:ClearAllPoints()
            dock:SetPoint(db.dockPoint, UIParent, db.dockRelPoint or "CENTER", db.dockX or 0, db.dockY or 0)
            dock.placed = true
        end
    else
        dock:ClearAllPoints()
        if container then
            dock:SetPoint("BOTTOMLEFT", map or container, "TOPLEFT", 0, 4)
        else
            dock:SetPoint("CENTER")
        end
    end
    dock:Show()
end

function F.CursorOver(frame)
    if not frame or not frame.IsMouseOver then
        return false
    end
    local ok, over = pcall(frame.IsMouseOver, frame)
    return ok and over or false
end

-- Speed is a secret value on this client. Comparing it throws every frame.
function F.Plain(value)
    if issecretvalue and issecretvalue(value) then
        return nil
    end
    return value
end

function F.Now()
    if not GetTime then
        return nil
    end
    local ok, value = pcall(GetTime)
    value = ok and F.Plain(value)
    if type(value) == "number" then
        return value
    end
    return nil
end

function F.OnTaxi()
    if not UnitOnTaxi then
        return false
    end
    local ok, flying = pcall(UnitOnTaxi, "player")
    return ok and F.Plain(flying) and true or false
end

function F.PlayerIsMoving()
    if eventMoving then
        return true
    end
    if IsPlayerMoving then
        local ok, moving = pcall(IsPlayerMoving)
        if ok and F.Plain(moving) then
            return true
        end
    end
    if GetUnitSpeed then
        local ok, speed = pcall(GetUnitSpeed, "player")
        speed = ok and F.Plain(speed)
        if type(speed) == "number" and speed > 0 then
            return true
        end
    end
    if F.OnTaxi() then
        return true
    end
    return false
end

function F.UpdateMoveState(elapsed)
    local moving = F.PlayerIsMoving()
    if moving == moveState then
        moveWant = moving
        moveHold = 0
        return
    end
    if moving ~= moveWant then
        moveWant = moving
        moveHold = 0
    end
    moveHold = moveHold + (elapsed or 0)
    -- Wait briefly so a stutter does not flash the map.
    local delay = moving and 0.15 or 0.28
    if moveHold >= delay then
        moveState = moving
        moveHold = 0
    end
end

function F.Adjusting(slider)
    if not slider then
        return false
    end
    if slider.nfHold and IsMouseButtonDown and not IsMouseButtonDown("LeftButton") then
        slider.nfHold = false
    end
    return slider.nfHold or F.CursorOver(slider)
end

-- Cursor first, then combat, then movement. Each one eases in and out.
function F.FadeTarget()
    if not db then
        return 1, false
    end
    if db.fadeMove and panel and panel:IsShown() then
        if F.Adjusting(moveSlider) then
            return db.alphaMove, true
        end
        if F.Adjusting(combatSlider) then
            return db.alphaCombat, true
        end
        if F.Adjusting(alphaSlider) then
            return db.alpha, true
        end
    end
    if not db.fadeMove then
        return db.alpha, false
    end
    if F.CursorOver(map) or F.CursorOver(nav) or F.CursorOver(F.goBar) or F.CursorOver(grip) or F.CursorOver(F.arrowFrame) then
        return db.alpha, false
    end
    if UnitAffectingCombat then
        local ok, combat = pcall(UnitAffectingCombat, "player")
        if ok and F.Plain(combat) then
            return db.alphaCombat, false
        end
    end
    if moveState then
        return db.alphaMove, false
    end
    return db.alpha, false
end

function F.UpdateFade(elapsed)
    if not db then
        return
    end
    F.UpdateMoveState(elapsed)
    local target, preview = F.FadeTarget()
    if not db.fadeMove or preview then
        liveAlpha = target
        return
    end
    -- Coming back is quicker than fading away.
    local speed = (target > liveAlpha) and 9 or 4.5
    local step = math.min(1, (elapsed or 0) * speed)
    liveAlpha = liveAlpha + (target - liveAlpha) * step
    if math.abs(liveAlpha - target) < 0.004 then
        liveAlpha = target
    end
end

function F.ShownAlpha()
    if not db then
        return 1
    end
    if not db.fadeMove then
        return db.alpha
    end
    return liveAlpha
end

-- WoW Forever draws a blank minimap in cities, buildings, dungeons, and
-- raids when the Minimap frame's alpha is below 1. The blank sticks
-- through /reload until the map is painted again at full opacity.
-- IsIndoors() misses Undercity, so the city names are checked too.
local SOLID_ZONES = {
    undercity = true,
    orgrimmar = true,
    ["thunder bluff"] = true,
    ["silvermoon city"] = true,
    ["stormwind city"] = true,
    ironforge = true,
    darnassus = true,
    ["the exodar"] = true,
    ["shattrath city"] = true,
    dalaran = true,
    ["ruins of lordaeron"] = true,
}

local function ZoneKey(text)
    if type(text) ~= "string" then
        return ""
    end
    return string.lower(text)
end

function F.SolidTerrain()
    if IsIndoors then
        local ok, indoors = pcall(IsIndoors)
        if ok and indoors then
            return true
        end
    end
    if IsInInstance then
        local ok, _, kind = pcall(IsInInstance)
        if ok and (kind == "party" or kind == "raid" or kind == "scenario") then
            return true
        end
    end
    if GetZonePVPInfo then
        local ok, pvp = pcall(GetZonePVPInfo)
        if ok and pvp == "sanctuary" then
            return true
        end
    end
    local names = {
        GetZoneText and GetZoneText(),
        GetRealZoneText and GetRealZoneText(),
        GetSubZoneText and GetSubZoneText(),
        GetMinimapZoneText and GetMinimapZoneText(),
    }
    for index = 1, #names do
        local key = ZoneKey(names[index])
        if SOLID_ZONES[key] or string.find(key, "undercity", 1, true) then
            return true
        end
    end
    return false
end

-- A flight over Undercity flips between the city and Tirisfal. Hold the
-- solid map across those gaps so the opacity does not pulse. It fades
-- again once the city has been gone for a few seconds.
function F.HeldSolid()
    local raw = F.SolidTerrain() and true or false
    local now = F.Now()
    if not now then
        return raw
    end
    if F.solidRaw ~= raw or not F.solidSince then
        F.solidRaw = raw
        F.solidSince = now
    end
    local waited = now - F.solidSince
    if F.solidOn then
        local leave = F.OnTaxi() and 5 or 0.8
        if not raw and waited >= leave then
            F.solidOn = false
        end
    elseif raw and waited >= 0.15 then
        F.solidOn = true
    end
    return F.solidOn and true or false
end

function F.RefreshIndoorMap(force)
    if not map or (not F.SolidTerrain() and not F.solidOn) then
        return
    end
    if cluster then
        cluster:SetAlpha(1)
    end
    if container then
        container:SetAlpha(1)
    end
    map:SetAlpha(1)
    if map.SetMaskTexture and (force or not map.nfIndoorPainted) then
        pcall(map.SetMaskTexture, map, ROUND_MASK)
        pcall(map.SetMaskTexture, map, SQUARE_MASK)
        F.SetCircularEdge(false)
        F.HideBlobs()
        map.nfIndoorPainted = true
    end
end

function F.PixelUnits(count)
    local physical
    if GetPhysicalScreenSize then
        local ok, _, height = pcall(GetPhysicalScreenSize)
        if ok and type(height) == "number" and height > 0 then
            physical = height
        end
    end
    local scale = UIParent and UIParent:GetEffectiveScale() or 1
    if not physical or not scale or scale <= 0 then
        return count
    end
    return count * (768 / physical) / scale
end

function F.Borderless(frame)
    if not frame then
        return
    end
    for _, key in ipairs({ "nfTop", "nfBottom", "nfLeft", "nfRight" }) do
        if frame[key] then
            frame[key]:Hide()
        end
    end
end

function F.TextIsBareCoords(value)
    value = F.Plain(value)
    if type(value) ~= "string" then
        return false
    end
    value = string.gsub(value, "|c%x%x%x%x%x%x%x%x", "")
    value = string.gsub(value, "|r", "")
    return string.match(value, "^%s*%d+%.%d+%s*,%s*%d+%.%d+%s*$") ~= nil
end

function F.HideStrayCoords(root, depth)
    if not root or (depth or 0) > 5 or root == nav or root == F.navFoot then
        return
    end
    if root.IsForbidden and root:IsForbidden() then
        return
    end
    if root.GetRegions then
        for _, region in ipairs({ root:GetRegions() }) do
            if region and region.GetObjectType and region:GetObjectType() == "FontString" and region ~= navPlace and region ~= navZone and region ~= navRoute and region ~= F.navFlight then
                local ok, text = pcall(region.GetText, region)
                if ok and F.TextIsBareCoords(text) then
                    if not region.nfCoordMuted then
                        region.nfCoordMuted = true
                        region.Show = function() end
                    end
                    region:Hide()
                end
            end
        end
    end
    if root.GetChildren then
        for _, child in ipairs({ root:GetChildren() }) do
            if not (child.IsForbidden and child:IsForbidden()) then
                F.HideStrayCoords(child, (depth or 0) + 1)
            end
        end
    end
end

function F.LayoutNav()
    if mapFrame then
        mapFrame:Hide()
    end
    if goldEdges and goldEdges.top then
        goldEdges.top:Hide()
    end
    local alpha = F.ShownAlpha()
    -- Parent alpha does not reach the minimap terrain, and stacking it
    -- on the map would fade the square twice. Keep the parents solid.
    if cluster then
        cluster:SetAlpha(1)
    end
    if container then
        container:SetAlpha(1)
    end
    if map then
        local terrain = alpha
        local solid = F.HeldSolid()
        if solid then
            terrain = 1
        end
        local entered = solid and not map.nfSolid
        map:SetAlpha(terrain)
        map.nfSolid = solid
        if not solid then
            map.nfIndoorPainted = false
        end
        if entered then
            F.RefreshIndoorMap()
        end
    end
    if grip then
        grip:SetAlpha(alpha)
    end
    local screen = F.ResolutionScale()
    if screen < 0.05 then
        screen = 1
    end
    local edgeTarget = map or container
    local barWidth = 220 * screen
    if nav and edgeTarget then
        if nav:GetParent() ~= UIParent then
            nav:SetParent(UIParent)
        end
        -- Scale the bar as a whole so its text, icon, and buttons stay
        -- in proportion with the square at this resolution.
        if math.abs((nav:GetScale() or 1) - screen) > 0.01 then
            nav:SetScale(screen)
        end
        nav:SetAlpha(alpha)
        nav:EnableMouse(true)
        nav:SetFrameStrata("MEDIUM")
        nav:SetFrameLevel(10)
        barWidth = F.OnScreenSize(edgeTarget)
        if barWidth < 160 * screen then
            barWidth = 160 * screen
        end
        local barHeight = nav:GetHeight() or 52
        if barHeight < 48 then
            barHeight = 52
        end
        nav:ClearAllPoints()
        nav:SetSize(barWidth / screen, barHeight)
        nav:SetPoint("BOTTOMLEFT", edgeTarget, "TOPLEFT", 0, 0)
        nav:Show()
        F.Borderless(nav)
        if F.goBar then
            F.goBar:ClearAllPoints()
            F.goBar:SetPoint("BOTTOMLEFT", nav, "TOPLEFT", 0, 0)
            F.goBar:SetPoint("BOTTOMRIGHT", nav, "TOPRIGHT", 0, 0)
            F.goBar:SetHeight(40)
            F.Borderless(F.goBar)
        end
        if F.zoneBar then
            local under = F.goBar or nav
            F.zoneBar:ClearAllPoints()
            F.zoneBar:SetPoint("BOTTOMLEFT", under, "TOPLEFT", 0, 0)
            F.zoneBar:SetPoint("BOTTOMRIGHT", under, "TOPRIGHT", 0, 0)
            F.zoneBar:SetHeight(44)
            F.Borderless(F.zoneBar)
            F.zoneBar:Show()
        end
    end
    if F.navFoot and edgeTarget then
        if F.navFoot:GetParent() ~= UIParent then
            F.navFoot:SetParent(UIParent)
        end
        if math.abs((F.navFoot:GetScale() or 1) - screen) > 0.01 then
            F.navFoot:SetScale(screen)
        end
        F.navFoot:SetAlpha(alpha)
        F.navFoot:EnableMouse(true)
        F.navFoot:SetFrameStrata("MEDIUM")
        F.navFoot:SetFrameLevel(10)
        local footHeight = F.navFoot:GetHeight() or 38
        if footHeight < 34 then
            footHeight = 38
        end
        F.navFoot:ClearAllPoints()
        F.navFoot:SetSize(barWidth / screen, footHeight)
        F.navFoot:SetPoint("TOPLEFT", edgeTarget, "BOTTOMLEFT", 0, 0)
        F.Borderless(F.navFoot)
        F.navFoot:Show()
    end
    F.DockBarButtons(barWidth / screen)
    local zoneButton = (cluster and cluster.ZoneTextButton) or MinimapZoneTextButton
    if zoneButton then
        zoneButton:Hide()
    end
    if cluster and cluster.BorderTop then
        cluster.BorderTop:Hide()
    end
    local dockedTracking = select(1, F.BarButtonList())
    if cluster and cluster.Tracking and cluster.Tracking ~= dockedTracking then
        cluster.Tracking:Hide()
    end
    if MiniMapTracking and MiniMapTracking ~= dockedTracking then
        MiniMapTracking:Hide()
    end
    if MiniMapTrackingButton and MiniMapTrackingButton ~= dockedTracking then
        MiniMapTrackingButton:Hide()
    end
    if MinimapBackdrop then
        MinimapBackdrop:Hide()
    end
    if cluster and cluster.GetRegions then
        for _, region in ipairs({ cluster:GetRegions() }) do
            if region.GetObjectType and region:GetObjectType() == "Texture" and region.Hide then
                region:Hide()
            end
        end
    end
    if not edgeTarget or not goldEdges then
        return
    end
    -- One gold outline around the whole stack, plus dividers between the
    -- strips. Sizes are whole screen pixels so thin lines do not vanish.
    local function edge(key)
        local line = goldEdges[key]
        if not line then
            line = CreateFrame("Frame", nil, UIParent)
            line:EnableMouse(false)
            line.tex = line:CreateTexture(nil, "ARTWORK")
            local br, bgc, bb = F.BorderColor()
            line.tex:SetColorTexture(br, bgc, bb, 1)
            line.tex:SetAllPoints()
            goldEdges[key] = line
        end
        if line:GetParent() ~= UIParent then
            line:SetParent(UIParent)
        end
        line:SetScale(1)
        line:SetAlpha(alpha)
        line:SetFrameStrata("MEDIUM")
        line:SetFrameLevel(40)
        line:ClearAllPoints()
        line:Show()
        return line
    end
    local thick = F.PixelUnits(2)
    local thin = F.PixelUnits(1)
    local top = F.zoneBar or F.goBar or nav or edgeTarget
    local bottom = F.navFoot or edgeTarget

    local line = edge("top")
    line:SetPoint("BOTTOMLEFT", top, "TOPLEFT", -thick, 0)
    line:SetPoint("BOTTOMRIGHT", top, "TOPRIGHT", thick, 0)
    line:SetHeight(thick)
    line = edge("bottom")
    line:SetPoint("TOPLEFT", bottom, "BOTTOMLEFT", -thick, 0)
    line:SetPoint("TOPRIGHT", bottom, "BOTTOMRIGHT", thick, 0)
    line:SetHeight(thick)
    line = edge("left")
    line:SetPoint("TOPRIGHT", top, "TOPLEFT", 0, 0)
    line:SetPoint("BOTTOMRIGHT", bottom, "BOTTOMLEFT", 0, 0)
    line:SetWidth(thick)
    line = edge("right")
    line:SetPoint("TOPLEFT", top, "TOPRIGHT", 0, 0)
    line:SetPoint("BOTTOMLEFT", bottom, "BOTTOMRIGHT", 0, 0)
    line:SetWidth(thick)

    local host = F.mapCorners
    if not host then
        host = CreateFrame("Frame", nil, UIParent)
        host:EnableMouse(false)
        F.mapCorners = host
    end
    host:SetScale(1)
    host:SetAlpha(alpha)
    host:SetFrameStrata("MEDIUM")
    host:SetFrameLevel(45)
    host:ClearAllPoints()
    host:SetPoint("TOPLEFT", top, "TOPLEFT", -thick, thick)
    host:SetPoint("BOTTOMRIGHT", bottom, "BOTTOMRIGHT", thick, -thick)
    host:Show()
    local mapWide = (edgeTarget:GetWidth() or 0) * edgeTarget:GetEffectiveScale() / UIParent:GetEffectiveScale()
    local cornerSize = F.Clamp(mapWide * 0.2, 40, 96)
    F.mapCornerSize = cornerSize
    F.PlaceCoords()
    if host.nfCorners then
        F.SizeCorners(host.nfCorners, host, cornerSize)
    else
        host.nfCorners = F.CreateCorners(host, cornerSize)
    end

    local function divider(key, frame, size, side)
        if not frame then
            if goldEdges[key] then
                goldEdges[key]:Hide()
            end
            return
        end
        local div = edge(key)
        if side == "bottom" then
            div:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0)
            div:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
        else
            div:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
            div:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
        end
        div:SetHeight(size)
    end
    divider("zoneLine", F.zoneBar, thin, "bottom")
    divider("goLine", F.goBar, thin, "bottom")
    divider("mapTop", nav, thick, "bottom")
    divider("mapBottom", F.navFoot, thick, "top")
    if pinMark then
        -- Scale on this frame shrinks its SetPoint offset, so the mark
        -- lands closer to the player than the click. Leave it at 1.
        pinMark:SetScale(1)
    end
    if deathMark then
        deathMark:SetScale(1)
    end
    pcall(F.HideStrayCoords, map, 0)
    pcall(F.HideStrayCoords, cluster, 0)
    if Minimap and Minimap ~= map then
        pcall(F.HideStrayCoords, Minimap, 0)
    end
end

function F.PaintPanel(frame, alpha)
    if not frame.nfBg then
        frame.nfBg = frame:CreateTexture(nil, "BACKGROUND")
        local mr, mg, mb = F.MenuColor()
        frame.nfBg:SetColorTexture(mr, mg, mb, 1)
        frame.nfBg:SetAllPoints()
        frame.nfGrain = frame:CreateTexture(nil, "BACKGROUND", nil, 1)
        frame.nfGrain:SetAllPoints()
        F.PaintGrain(frame)
        frame.nfMist = frame:CreateTexture(nil, "BACKGROUND", nil, 2)
        frame.nfMist:SetAllPoints()
        F.PaintMist(frame)
        local br, bgc, bb = F.BorderColor()
        local function line()
            local stripe = frame:CreateTexture(nil, "BORDER")
            stripe:SetColorTexture(br, bgc, bb, 1)
            return stripe
        end
        table.insert(paintedFrames, frame)
        frame.nfTop = line()
        frame.nfTop:SetPoint("TOPLEFT")
        frame.nfTop:SetPoint("TOPRIGHT")
        frame.nfTop:SetHeight(1)
        frame.nfBottom = line()
        frame.nfBottom:SetPoint("BOTTOMLEFT")
        frame.nfBottom:SetPoint("BOTTOMRIGHT")
        frame.nfBottom:SetHeight(1)
        frame.nfLeft = line()
        frame.nfLeft:SetPoint("TOPLEFT")
        frame.nfLeft:SetPoint("BOTTOMLEFT")
        frame.nfLeft:SetWidth(1)
        frame.nfRight = line()
        frame.nfRight:SetPoint("TOPRIGHT")
        frame.nfRight:SetPoint("BOTTOMRIGHT")
        frame.nfRight:SetWidth(1)
    end
    frame.nfBg:SetAlpha(alpha or 0.94)
end

function F.SetFontSize(fs, size)
    if not fs or not fs.GetFont then
        return
    end
    local font, _, flags = fs:GetFont()
    if type(font) ~= "string" or font == "" then
        font = "Fonts\\FRIZQT__.TTF"
    end
    if type(flags) ~= "string" or flags == "" then
        fs:SetFont(font, size)
    else
        fs:SetFont(font, size, flags)
    end
end

function F.Chip(parent, label, width, fontSize, height)
    local button = CreateFrame("Button", nil, parent)
    button:SetSize(width, height or 22)
    F.PaintPanel(button, 1)
    button.nfBg:SetColorTexture(0.09, 0.14, 0.22, 1)
    local text = button:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    text:SetPoint("CENTER", 0, 0)
    text:SetText(label)
    if fontSize then
        F.SetFontSize(text, fontSize)
    end
    text:SetTextColor(F.BorderColor())
    button:SetScript("OnEnter", function()
        local hr, hg, hb = F.ThemeColor("hover")
        button.nfTop:SetColorTexture(hr, hg, hb, 1)
        button.nfBottom:SetColorTexture(hr, hg, hb, 1)
        button.nfLeft:SetColorTexture(hr, hg, hb, 1)
        button.nfRight:SetColorTexture(hr, hg, hb, 1)
        text:SetTextColor(F.ThemeColor("bright"))
    end)
    button.nfLabel = text
    button:SetScript("OnLeave", function()
        local br, bgc, bb = F.BorderColor()
        button.nfTop:SetColorTexture(br, bgc, bb, 1)
        button.nfBottom:SetColorTexture(br, bgc, bb, 1)
        button.nfLeft:SetColorTexture(br, bgc, bb, 1)
        button.nfRight:SetColorTexture(br, bgc, bb, 1)
        text:SetTextColor(br, bgc, bb)
    end)
    return button
end

F.ApplyColors = function()
    F.SaveCharTheme()
    local mr, mg, mb = F.MenuColor()
    local br, bgc, bb = F.BorderColor()
    for _, frame in ipairs(paintedFrames) do
        if frame.nfBg then
            frame.nfBg:SetColorTexture(mr, mg, mb, 1)
        end
        F.PaintGrain(frame)
        F.PaintMist(frame)
        if frame.nfTop then
            frame.nfTop:SetColorTexture(br, bgc, bb, 1)
        end
        if frame.nfBottom then
            frame.nfBottom:SetColorTexture(br, bgc, bb, 1)
        end
        if frame.nfLeft then
            frame.nfLeft:SetColorTexture(br, bgc, bb, 1)
        end
        if frame.nfRight then
            frame.nfRight:SetColorTexture(br, bgc, bb, 1)
        end
        if frame.nfLabel then
            frame.nfLabel:SetTextColor(br, bgc, bb)
        end
    end
    if goldEdges then
        for _, edge in pairs(goldEdges) do
            if edge.tex then
                edge.tex:SetColorTexture(br, bgc, bb, 1)
            end
        end
    end
    if grip and grip.across then
        grip.across:SetColorTexture(br, bgc, bb, 1)
        grip.down:SetColorTexture(br, bgc, bb, 1)
    end
    if panel and panel.nfDivider then
        panel.nfDivider:SetColorTexture(br, bgc, bb, 0.85)
    end
    if panel and panel.nfTabLine then
        panel.nfTabLine:SetColorTexture(br, bgc, bb, 0.85)
    end
    for _, label in ipairs(accentText) do
        label:SetTextColor(br, bgc, bb)
    end
    local hr, hg, hb = F.ThemeColor("hover")
    if panel and panel.nfSubtitle then
        panel.nfSubtitle:SetTextColor(hr, hg, hb)
    end
    if header and header.nfTex then
        header.nfTex:SetColorTexture(mr, mg, mb, 0.78)
    end
    if border and border.SetBackdropBorderColor then
        border:SetBackdropBorderColor(br, bgc, bb, 1)
    end
    if mapFrame then
        for _, side in ipairs({ "top", "bottom", "left", "right" }) do
            if mapFrame[side] then
                mapFrame[side]:SetColorTexture(br, bgc, bb, 1)
            end
        end
    end
    if pinMark and pinMark.nfRing then
        pinMark.nfRing:SetColorTexture(br, bgc, bb, 1)
        pinMark.nfDot:SetColorTexture(hr, hg, hb, 1)
    end
    if F.TintWorldPin then
        F.TintWorldPin()
    end
    for _, mark in ipairs(themedMarks) do
        mark:SetColorTexture(br, bgc, bb, 1)
    end
    local tr, tg, tb = F.ThemeColor("track")
    for _, parts in ipairs(themedSliders) do
        if parts.solid then
            parts.thumb:SetColorTexture(br, bgc, bb, 1)
        else
            parts.thumb:SetVertexColor(br, bgc, bb)
        end
        parts.track:SetColorTexture(tr, tg, tb, 1)
    end
    for _, tex in ipairs(brandIcons) do
        F.PaintBrandIcon(tex)
    end
    for _, flame in ipairs(brandFlames) do
        F.PaintFlame(flame, 0)
    end
    F.PaintCorners()
    F.PlaceCoords()
    F.RefreshAnimations()
    if F.TintArrow then
        F.TintArrow()
    end
    if colorSwatches.menuColor then
        colorSwatches.menuColor:SetColorTexture(mr, mg, mb, 1)
    end
    if colorSwatches.borderColor then
        colorSwatches.borderColor:SetColorTexture(br, bgc, bb, 1)
    end
    for _, swatch in pairs(colorSwatchFrames) do
        if swatch.top then
            swatch.top:SetColorTexture(br, bgc, bb, 1)
        end
        if swatch.bottom then
            swatch.bottom:SetColorTexture(br, bgc, bb, 1)
        end
        if swatch.left then
            swatch.left:SetColorTexture(br, bgc, bb, 1)
        end
        if swatch.right then
            swatch.right:SetColorTexture(br, bgc, bb, 1)
        end
    end
    for index = 1, 3 do
        local tex = colorSwatches["ringColor" .. index]
        if tex then
            local r, g, b = F.RingColor(index)
            tex:SetColorTexture(r, g, b, 1)
        end
    end
    if F.UpdateRangeRings then
        F.UpdateRangeRings()
    end
    if F.RefreshOptionTabs then
        F.RefreshOptionTabs()
    end
end

function F.ZonePointOffset(point)
    if not point or not point.map or not point.zx or not point.zy then
        return nil
    end
    if not C_Map or not C_Map.GetBestMapForUnit then
        return nil
    end
    local ok, playerMap = pcall(C_Map.GetBestMapForUnit, "player")
    playerMap = ok and tonumber(F.Plain(playerMap))
    if not playerMap then
        return "wait"
    end
    local px, py = F.PosOnMap(playerMap)
    if not px then
        return "wait"
    end
    local pCont, pwx, pwy = F.MapPoint(playerMap, px, py)
    local tCont, twx, twy = F.MapPoint(point.map, point.zx, point.zy)
    if not pwx or not twx then
        return "wait"
    end
    if pCont and tCont and pCont ~= tCont then
        return "other"
    end
    local dx = pwx - twx
    local dy = pwy - twy
    return "ok", dx, dy, math.sqrt(dx * dx + dy * dy), pwx, pwy, twx, twy
end

function F.PointOffset(point)
    if not point then
        return nil
    end
    if point.map and point.zx and point.zy then
        local zoneState, zdx, zdy, zyards, zpx, zpy, ztx, zty = F.ZonePointOffset(point)
        if zoneState == "ok" or zoneState == "other" then
            return zoneState, zdx, zdy, zyards, zpx, zpy, ztx, zty
        end
        local hbd = F.HereBeDragons()
        if not hbd or not hbd.GetPlayerWorldPosition or not hbd.GetWorldCoordinatesFromZone then
            return "wait"
        end
        local px, py, playerInstance = hbd:GetPlayerWorldPosition()
        local pinX, pinY, pinInstance = hbd:GetWorldCoordinatesFromZone(point.zx, point.zy, point.map)
        if not px or not py or not pinX or not pinY then
            return "coords"
        end
        if pinInstance and playerInstance and pinInstance ~= playerInstance then
            return "other"
        end
        local dx = px - pinX
        local dy = py - pinY
        return "ok", dx, dy, math.sqrt(dx * dx + dy * dy), px, py, pinX, pinY
    end
    local px, py, playerInstance = F.PlayerWorld()
    if not point.x or not point.y or not px or not py then
        return "wait"
    end
    if point.instance and playerInstance and point.instance ~= playerInstance then
        return "other"
    end
    local dx = px - point.x
    local dy = py - point.y
    return "ok", dx, dy, math.sqrt(dx * dx + dy * dy), px, py, point.x, point.y
end

function F.PinOffset()
    return F.PointOffset(db and db.pin)
end

function F.RotateOffset(dx, dy)
    if GetCVar("rotateMinimap") == "1" then
        local facing = GetPlayerFacing()
        if facing then
            local cosF = math.cos(facing)
            local sinF = math.sin(facing)
            local ox, oy = dx, dy
            dx = ox * cosF - oy * sinF
            dy = ox * sinF + oy * cosF
        end
    end
    return dx, dy
end

function F.MapOffset(dx, dy)
    local radius = F.ViewRadius()
    if not map or radius <= 0 then
        return nil
    end
    local halfW = (map:GetWidth() or 0) / 2
    local halfH = (map:GetHeight() or 0) / 2
    if halfW < 1 or halfH < 1 then
        return nil
    end
    return dx / radius * halfW, -dy / radius * halfH, halfW, halfH
end

-- Keep a marker that is past the edge sitting on the rim, toward the target.
function F.ClampToMap(sx, sy, halfW, halfH, inset)
    local maxX = math.max(8, halfW - inset)
    local maxY = math.max(8, halfH - inset)
    local ax = math.abs(sx)
    local ay = math.abs(sy)
    if ax <= maxX and ay <= maxY then
        return sx, sy, false
    end
    local scale = math.min(maxX / math.max(ax, 0.001), maxY / math.max(ay, 0.001))
    return sx * scale, sy * scale, true
end

function F.UpdatePinMark()
    if not pinMark or not map then
        return
    end
    local state, dx, dy = F.PinOffset()
    if state ~= "ok" then
        pinMark:Hide()
        return
    end
    dx, dy = F.RotateOffset(dx, dy)
    local sx, sy, halfW, halfH = F.MapOffset(dx, dy)
    if not sx or math.abs(sx) > halfW or math.abs(sy) > halfH then
        pinMark:Hide()
        return
    end
    pinMark:SetScale(1)
    pinMark:ClearAllPoints()
    pinMark:SetPoint("CENTER", map, "CENTER", sx, sy)
    pinMark:Show()
end

local CORPSE_CLEAR_YARDS = 40
local wasGhost = false

function F.PlayerTag()
    local name, realm
    if UnitFullName then
        name, realm = UnitFullName("player")
    end
    if not name or name == "" then
        name = UnitName("player")
    end
    if not realm or realm == "" then
        realm = GetRealmName and GetRealmName() or ""
    end
    if not name or name == "" or name == "Unknown" then
        return nil
    end
    return name .. "-" .. realm
end

function F.DeathPoint()
    if not db or type(db.deaths) ~= "table" then
        return nil
    end
    local tag = F.PlayerTag()
    if not tag then
        return nil
    end
    local death = db.deaths[tag]
    if type(death) ~= "table" then
        return nil
    end
    if not ((death.x and death.y) or (death.map and death.zx and death.zy)) then
        return nil
    end
    return death
end

function F.ClearDeath()
    local tag = F.PlayerTag()
    if db and type(db.deaths) == "table" and tag then
        db.deaths[tag] = nil
    end
    if deathMark then
        deathMark:Hide()
    end
end

function F.CorpseZone()
    local mapID = C_Map and C_Map.GetBestMapForUnit and C_Map.GetBestMapForUnit("player")
    if not mapID then
        return nil
    end
    if C_DeathInfo and C_DeathInfo.GetCorpseMapPosition then
        local ok, pos = pcall(C_DeathInfo.GetCorpseMapPosition, mapID)
        if ok and pos then
            local x, y
            if type(pos) == "number" then
                x = pos
                y = select(2, C_DeathInfo.GetCorpseMapPosition(mapID))
            elseif pos.GetXY then
                local xyOK, gx, gy = pcall(pos.GetXY, pos)
                if xyOK then
                    x, y = gx, gy
                end
            elseif type(pos) == "table" then
                x, y = pos.x, pos.y
            end
            if x and y and x > 0 and y > 0 then
                return mapID, x, y
            end
        end
    end
    if GetCorpseMapPosition then
        local ok, x, y = pcall(GetCorpseMapPosition)
        if ok and type(x) == "number" and type(y) == "number" and x > 0 and y > 0 then
            return mapID, x, y
        end
    end
    return nil
end

function F.RememberDeath(point)
    local tag = F.PlayerTag()
    if not tag or type(point) ~= "table" then
        return false
    end
    if type(db.deaths) ~= "table" then
        db.deaths = {}
    end
    db.deaths[tag] = point
    return true
end

function F.MarkDeath()
    if not db or not F.Enabled("deathMarker") then
        return
    end
    -- Last living sample is the corpse. The death event can already report the graveyard.
    local x, y, instanceID
    if lastLifeX and lastLifeY then
        x, y, instanceID = lastLifeX, lastLifeY, lastLifeInstance
    else
        x, y, instanceID = F.PlayerWorld()
    end
    local saved
    if x and y then
        saved = F.RememberDeath({ x = x, y = y, instance = instanceID })
    else
        local mapID, zx, zy = F.CorpseZone()
        if mapID then
            saved = F.RememberDeath({ map = mapID, zx = zx, zy = zy })
        end
    end
    if not saved then
        F.Say("Could not mark where you died.")
        return
    end
    wasGhost = false
    if not db.deathHint then
        db.deathHint = true
        F.Say("Death marker set. It clears when you reach your body. /nf death clears it.")
    else
        F.Say("Death marker set.")
    end
    F.UpdateNav()
    F.SyncArrow()
end

function F.NoteGhost()
    if not UnitIsGhost then
        return
    end
    local ok, ghost = pcall(UnitIsGhost, "player")
    if ok and F.Plain(ghost) then
        wasGhost = true
    end
end

function F.MaybeArrive()
    F.NoteGhost()
    if not db or UnitIsDeadOrGhost("player") then
        return
    end
    local death = F.DeathPoint()
    if not death then
        wasGhost = false
        return
    end
    local state, _, _, yards = F.PointOffset(death)
    local atBody = state == "ok" and yards and yards <= CORPSE_CLEAR_YARDS
    -- A spirit healer brings you back from ghost form away from the corpse.
    local spiritRez = wasGhost and not atBody
    if spiritRez and not F.Enabled("deathSpirit") then
        wasGhost = false
        return
    end
    if not atBody and not spiritRez then
        return
    end
    wasGhost = false
    F.ClearDeath()
    F.Say("Death marker cleared.")
    F.SyncArrow()
end

function F.RecoverCorpse()
    if not db or not F.Enabled("deathMarker") or F.DeathPoint() then
        return
    end
    if not UnitIsDeadOrGhost("player") then
        return
    end
    local mapID, zx, zy = F.CorpseZone()
    if not mapID then
        return
    end
    F.RememberDeath({ map = mapID, zx = zx, zy = zy })
end

function F.DeathArrowTarget()
    if not F.Enabled("deathMarker") then
        return nil
    end
    return F.ArrowTarget(F.DeathPoint(), "Corpse")
end

function F.UpdateDeathMark()
    if not deathMark or not map then
        return
    end
    if hybrid or not F.Enabled("deathMarker") then
        deathMark:Hide()
        return
    end
    local death = F.DeathPoint()
    if not death then
        deathMark:Hide()
        return
    end
    local state, dx, dy = F.PointOffset(death)
    if state ~= "ok" then
        deathMark:Hide()
        return
    end
    dx, dy = F.RotateOffset(dx, dy)
    local sx, sy, halfW, halfH = F.MapOffset(dx, dy)
    if not sx then
        deathMark:Hide()
        return
    end
    local clamped
    sx, sy, clamped = F.ClampToMap(sx, sy, halfW, halfH, 16)
    deathMark.clamped = clamped
    deathMark:SetScale(1)
    deathMark:ClearAllPoints()
    deathMark:SetPoint("CENTER", map, "CENTER", sx, sy)
    deathMark:Show()
end

function F.FlightClock(seconds)
    seconds = tonumber(seconds) or 0
    if seconds < 0 then
        seconds = 0
    elseif seconds > 3599 then
        seconds = 3599
    end
    seconds = math.floor(seconds + 0.5)
    return string.format("%d:%02d", math.floor(seconds / 60), seconds % 60)
end

function F.ClimbContinent(mapID)
    if not mapID or not C_Map or not C_Map.GetMapInfo then
        return mapID
    end
    local guard = 0
    while mapID and guard < 8 do
        local infoOK, info = pcall(C_Map.GetMapInfo, mapID)
        if not infoOK or type(info) ~= "table" then
            return mapID
        end
        local kind = tonumber(F.Plain(info.mapType))
        if not kind or kind <= 2 then
            return mapID
        end
        local parent = tonumber(F.Plain(info.parentMapID))
        if not parent or parent == 0 or parent == mapID then
            return mapID
        end
        mapID = parent
        guard = guard + 1
    end
    return mapID
end

function F.TaxiMapID()
    local mapID
    if GetTaxiMapID then
        local ok, id = pcall(GetTaxiMapID)
        id = ok and tonumber(F.Plain(id))
        if id and id > 0 then
            mapID = id
        end
    end
    if not mapID and C_Map and C_Map.GetBestMapForUnit then
        local ok, id = pcall(C_Map.GetBestMapForUnit, "player")
        mapID = ok and tonumber(F.Plain(id))
    end
    mapID = tonumber(F.ClimbContinent(mapID))
    if mapID and mapID > 0 then
        return mapID
    end
    return nil
end

function F.PosOnMap(mapID)
    if not mapID or not C_Map or not C_Map.GetPlayerMapPosition then
        return nil
    end
    local ok, first, second = pcall(C_Map.GetPlayerMapPosition, mapID, "player")
    if not ok then
        return nil
    end
    if type(first) == "number" and type(second) == "number" then
        first, second = F.Plain(first), F.Plain(second)
        if type(first) == "number" and type(second) == "number" then
            return first, second
        end
        return nil
    end
    local point = F.Plain(first)
    if type(point) == "table" and point.GetXY then
        local xyOK, x, y = pcall(point.GetXY, point)
        x, y = xyOK and F.Plain(x), xyOK and F.Plain(y)
        if type(x) == "number" and type(y) == "number" then
            return x, y
        end
    end
    return nil
end

function F.MapPoint(mapID, x, y)
    if not mapID or type(x) ~= "number" or type(y) ~= "number" then
        return nil
    end
    if not C_Map or not C_Map.GetWorldPosFromMapPos or not CreateVector2D then
        return nil
    end
    local ok, cont, world = pcall(C_Map.GetWorldPosFromMapPos, mapID, CreateVector2D(x, y))
    if not ok or type(world) ~= "table" or not world.GetXY then
        return nil
    end
    local xyOK, north, east = pcall(world.GetXY, world)
    north, east = xyOK and F.Plain(north), xyOK and F.Plain(east)
    cont = tonumber(F.Plain(cont))
    if type(north) ~= "number" or type(east) ~= "number" then
        return nil
    end
    -- The first value runs north-south and the second runs east-west.
    -- Bearing uses east-west as x, the same order as UnitPosition.
    return cont, east, north
end

function F.MapWorld(mapID, x, y)
    local _, wx, wy = F.MapPoint(mapID, x, y)
    if type(wx) == "number" and type(wy) == "number" then
        return wx, wy
    end
    return nil
end

function F.PlayerMapWorld()
    if not C_Map or not C_Map.GetBestMapForUnit then
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
    return F.MapWorld(mapID, x, y)
end

function F.NodeXY(index)
    if not TaxiNodePosition then
        return nil
    end
    local ok, first, second = pcall(TaxiNodePosition, index)
    if not ok then
        return nil
    end
    if type(first) == "number" and type(second) == "number" then
        first, second = F.Plain(first), F.Plain(second)
        if type(first) == "number" and type(second) == "number" then
            return first, second
        end
        return nil
    end
    local point = F.Plain(first)
    if type(point) == "table" and point.GetXY then
        local xyOK, x, y = pcall(point.GetXY, point)
        x, y = xyOK and F.Plain(x), xyOK and F.Plain(y)
        if type(x) == "number" and type(y) == "number" then
            return x, y
        end
    end
    return nil
end

function F.FlightName(index)
    if not TaxiNodeName then
        return nil
    end
    local ok, name = pcall(TaxiNodeName, index)
    name = ok and F.Plain(name)
    if type(name) ~= "string" or name == "" then
        return nil
    end
    local short = string.match(name, "^([^,]+)") or name
    short = string.match(short, "^%s*(.-)%s*$") or short
    if short == "" then
        return nil
    end
    if #short > 28 then
        short = string.sub(short, 1, 28)
    end
    return short
end

function F.TaxiNorm(x, y)
    x, y = tonumber(F.Plain(x)), tonumber(F.Plain(y))
    if not x or not y then
        return nil
    end
    if x > 1.5 or y > 1.5 then
        x, y = x / 100, y / 100
    end
    if x <= 0 or y <= 0 or x >= 1 or y >= 1 then
        return nil
    end
    return x, y
end

function F.TaxiIndex(value)
    if type(value) == "number" then
        return value
    end
    value = F.Plain(value)
    if type(value) == "number" then
        return value
    end
    if type(value) == "table" and value.GetID then
        local ok, id = pcall(value.GetID, value)
        return ok and tonumber(F.Plain(id))
    end
    return tonumber(value)
end

function F.TaxiShort(name)
    name = F.Plain(name)
    if type(name) ~= "string" or name == "" then
        return nil
    end
    local short = string.match(name, "^([^,]+)") or name
    short = string.match(short, "^%s*(.-)%s*$") or short
    if short == "" then
        return nil
    end
    if #short > 28 then
        short = string.sub(short, 1, 28)
    end
    return short
end

function F.TaxiFullName(index)
    if not TaxiNodeName or not index then
        return nil
    end
    local ok, name = pcall(TaxiNodeName, index)
    name = ok and F.Plain(name)
    if type(name) == "string" and name ~= "" then
        return name
    end
    return nil
end

function F.TaxiOrigin()
    if not NumTaxiNodes or not TaxiNodeGetType then
        return nil
    end
    local ok, count = pcall(NumTaxiNodes)
    count = ok and tonumber(F.Plain(count))
    for index = 1, count or 0 do
        local typeOK, kind = pcall(TaxiNodeGetType, index)
        if typeOK and F.Plain(kind) == "CURRENT" then
            return index
        end
    end
    return nil
end

-- Flight paths bend around terrain and through other flight points, so the
-- straight line to the destination undercounts. This is the length of the
-- route's legs over the straight-line length, both in world yards.
function F.TaxiPathRatio(index, origin, mapID)
    if not mapID or not origin or not GetNumRoutes or not TaxiGetSrcX or not TaxiGetDestX then
        return nil
    end
    local function world(x, y)
        x, y = F.TaxiNorm(x, y)
        if not x then
            return nil
        end
        return F.MapWorld(mapID, x, y)
    end
    local ok, hops = pcall(GetNumRoutes, index)
    hops = ok and tonumber(F.Plain(hops))
    if not hops or hops < 1 then
        return nil
    end
    local function get(fn, hop)
        local callOK, value = pcall(fn, index, hop)
        return callOK and F.Plain(value) or nil
    end
    local path = 0
    for hop = 1, hops do
        local sx, sy = world(get(TaxiGetSrcX, hop), get(TaxiGetSrcY, hop))
        local ex, ey = world(get(TaxiGetDestX, hop), get(TaxiGetDestY, hop))
        if not sx or not ex then
            return nil
        end
        path = path + math.sqrt((ex - sx) ^ 2 + (ey - sy) ^ 2)
    end
    local ax, ay = world(F.NodeXY(origin))
    local bx, by = world(F.NodeXY(index))
    if not ax or not bx then
        return nil
    end
    local straight = math.sqrt((bx - ax) ^ 2 + (by - ay) ^ 2)
    if straight < 1 or path < straight then
        return nil
    end
    return math.min(path / straight, 4)
end

-- Remaining path is assumed to straighten out as the flight nears the end.
function F.PathFactor(dest, dist, key)
    if not dest.pathRatio or not dist then
        return 1
    end
    dest.startDist = dest.startDist or {}
    local start = dest.startDist[key]
    if not start or dist > start then
        start = dist
        dest.startDist[key] = dist
    end
    return 1 + (dest.pathRatio - 1) * (dist / start)
end

function F.FlightUnit()
    if not UnitPosition then
        return nil
    end
    local ok, first, second, _, instanceID = pcall(UnitPosition, "player")
    if not ok then
        return nil
    end
    first, second, instanceID = F.Plain(first), F.Plain(second), F.Plain(instanceID)
    if type(first) ~= "number" or type(second) ~= "number" then
        return nil
    end
    return second, first, instanceID
end

function F.FlightSpeed()
    if not GetUnitSpeed then
        return nil
    end
    local ok, speed = pcall(GetUnitSpeed, "player")
    speed = ok and tonumber(F.Plain(speed))
    if speed and speed > 1 then
        return speed
    end
    return nil
end

function F.MapIsContinentChild(mapID, continent)
    if not mapID or not continent then
        return false
    end
    local guard = 0
    while mapID and guard < 8 do
        if mapID == continent then
            return true
        end
        if not C_Map or not C_Map.GetMapInfo then
            return false
        end
        local ok, info = pcall(C_Map.GetMapInfo, mapID)
        if not ok or type(info) ~= "table" then
            return false
        end
        local kind = tonumber(F.Plain(info.mapType))
        if kind and kind >= 4 then
            return false
        end
        local name = F.Plain(info.name)
        if type(name) == "string" and string.find(string.lower(name), "undercity", 1, true) then
            return false
        end
        local parent = tonumber(F.Plain(info.parentMapID))
        if not parent or parent == 0 or parent == mapID then
            return false
        end
        mapID = parent
        guard = guard + 1
    end
    return false
end

function F.FlightLeft(now)
    if not F.flightEta or not F.flightEtaAt or not now then
        return nil
    end
    local left = F.flightEta - (now - F.flightEtaAt)
    if left < 0 then
        left = 0
    end
    return left
end

function F.AcceptEta(raw, now)
    if not raw or not now or raw < 5 or raw > 3600 then
        return false
    end
    local left = F.FlightLeft(now)
    if left and left > 20 and raw > left + 90 and raw > left * 1.75 then
        return false
    end
    -- The clock never runs backward. A longer estimate pauses it instead.
    if not left then
        F.flightEta = raw
    elseif raw >= left then
        F.flightEta = left
    else
        F.flightEta = left + (raw - left) * 0.3
    end
    F.flightEtaAt = now
    return true
end

function F.FlightSample(px, py, dx, dy, now, minMoved, minLeft, maxSpeed, dest, space)
    local distX = px - dx
    local distY = py - dy
    local dist = math.sqrt(distX * distX + distY * distY)
    local sample = F.flightSample
    if not sample or (now - (sample.t or 0)) >= 0.45 then
        local speed
        if sample then
            local movedX = px - sample.x
            local movedY = py - sample.y
            local moved = math.sqrt(movedX * movedX + movedY * movedY)
            local dt = now - sample.t
            if dt > 0 and moved >= minMoved and dist >= minLeft then
                local pace = moved / dt
                if not maxSpeed or pace <= maxSpeed then
                    speed = pace
                end
            end
        end
        F.flightSample = { x = px, y = py, t = now }
        if speed and speed > 0 then
            local factor = dest and F.PathFactor(dest, dist, space or "raw") or 1
            F.AcceptEta(dist * factor / speed, now)
        end
    end
    return F.FlightLeft(now)
end

function F.RememberFlight(index)
    index = F.TaxiIndex(index)
    if not index then
        return
    end
    local name = F.FlightName(index)
    local x, y = F.NodeXY(index)
    x, y = F.TaxiNorm(x, y)
    local mapID = F.TaxiMapID()
    if (not name or not x) and mapID and C_TaxiMap and C_TaxiMap.GetAllTaxiNodes then
        local ok, nodes = pcall(C_TaxiMap.GetAllTaxiNodes, mapID)
        if ok and type(nodes) == "table" then
            for nodeIndex = 1, #nodes do
                local node = nodes[nodeIndex]
                if type(node) == "table" then
                    local slot = tonumber(F.Plain(node.slotIndex))
                    local nodeID = tonumber(F.Plain(node.nodeID))
                    if slot == index or nodeID == index then
                        if not name then
                            name = F.TaxiShort(node.name)
                        end
                        if not x and type(node.position) == "table" then
                            local pos = node.position
                            local px, py
                            if pos.GetXY then
                                local xyOK, a, b = pcall(pos.GetXY, pos)
                                px, py = xyOK and a, xyOK and b
                            else
                                px, py = pos.x, pos.y
                            end
                            x, y = F.TaxiNorm(px, py)
                        end
                    end
                end
            end
        end
    end
    if not name then
        return
    end
    local dest = { name = name }
    local origin = F.TaxiOrigin()
    local fromName, toName = F.TaxiFullName(origin), F.TaxiFullName(index)
    if fromName and toName then
        dest.route = fromName .. " > " .. toName
    end
    dest.pathRatio = F.TaxiPathRatio(index, origin, mapID)
    if x and y and mapID then
        dest.map = mapID
        dest.zx = x
        dest.zy = y
        local mx, my = F.MapWorld(mapID, x, y)
        if mx then
            dest.mx = mx
            dest.my = my
        end
        local hbd = F.HereBeDragons()
        if hbd and hbd.GetWorldCoordinatesFromZone then
            local ok, wx, wy, instance = pcall(hbd.GetWorldCoordinatesFromZone, hbd, x, y, mapID)
            wx, wy, instance = ok and F.Plain(wx), ok and F.Plain(wy), ok and F.Plain(instance)
            if type(wx) == "number" and type(wy) == "number" then
                dest.wx = wx
                dest.wy = wy
                dest.instance = instance
            end
        end
        local ux, uy, instance = F.FlightUnit()
        local pwx, pwy
        local fx, fy = F.PosOnMap(mapID)
        if fx then
            pwx, pwy = F.MapWorld(mapID, fx, fy)
        end
        if not pwx and C_Map and C_Map.GetBestMapForUnit then
            local hereOK, here = pcall(C_Map.GetBestMapForUnit, "player")
            here = hereOK and tonumber(F.Plain(here))
            if here and F.MapIsContinentChild(here, mapID) then
                pwx, pwy = F.PlayerMapWorld()
            end
        end
        if ux and pwx and dest.mx then
            dest.ux = ux
            dest.uy = uy
            dest.ox = dest.mx - pwx
            dest.oy = dest.my - pwy
            dest.uInstance = instance
        end
    end
    local before = F.flightDest
    if before and before.name == name then
        dest.route = dest.route or before.route
        dest.pathRatio = dest.pathRatio or before.pathRatio
    end
    F.flightDest = dest
    F.flightEta = nil
    F.flightEtaAt = nil
    F.flightSample = nil
    F.flightSpace = nil
    F.flightSaid = false
    F.flightStart = nil
    F.flightLandAt = nil
end

function F.FlightTrack(dest)
    if dest.map and dest.zx and not dest.staleMap then
        local px, py = F.PosOnMap(dest.map)
        if px then
            return "map", px, py, dest.zx, dest.zy, 0.00005, 0.004, 0.05
        end
    end
    if dest.ux and dest.ox and not dest.staleUnit then
        local px, py, instance = F.FlightUnit()
        local same = not dest.uInstance or not instance or dest.uInstance == instance
        if type(px) == "number" and type(py) == "number" and same then
            return "unit", px, py, dest.ux + dest.ox, dest.uy + dest.oy, 8, 40, 120
        end
    end
    if dest.mx and dest.map and C_Map and C_Map.GetBestMapForUnit then
        local ok, mapID = pcall(C_Map.GetBestMapForUnit, "player")
        mapID = ok and tonumber(F.Plain(mapID))
        if mapID and F.MapIsContinentChild(mapID, dest.map) then
            local px, py = F.PlayerMapWorld()
            if px then
                return "cmap", px, py, dest.mx, dest.my, 8, 40, 120
            end
        end
    end
    if dest.wx and dest.wy then
        local hbd = F.HereBeDragons()
        if hbd and hbd.GetPlayerWorldPosition then
            local ok, px, py, instance = pcall(hbd.GetPlayerWorldPosition, hbd)
            px, py, instance = ok and F.Plain(px), ok and F.Plain(py), ok and F.Plain(instance)
            local same = not dest.instance or not instance or dest.instance == instance
            if type(px) == "number" and type(py) == "number" and same then
                return "hbd", px, py, dest.wx, dest.wy, 8, 40, 120
            end
        end
    end
    return nil
end

function F.FlightLine(now)
    local dest = F.flightDest
    if not dest or type(dest.name) ~= "string" or dest.name == "" then
        return nil
    end
    local known = dest.route and db and db.flightTimes and db.flightTimes[dest.route]
    if known and now and F.flightStart then
        return string.format("%s   %s", dest.name, F.FlightClock(known - (now - F.flightStart)))
    end
    if dest.map and not dest.originZX then
        local ox, oy = F.PosOnMap(dest.map)
        if ox then
            dest.originZX, dest.originZY = ox, oy
        end
    end
    if dest.map and not dest.staleMap and dest.originZX and dest.ux and now and F.flightStart and (now - F.flightStart) > 3 then
        local px, py = F.PosOnMap(dest.map)
        if px and dest.originZX and dest.ux then
            local mapMoved = math.sqrt((px - dest.originZX) ^ 2 + (py - dest.originZY) ^ 2)
            local ux, uy = F.FlightUnit()
            local unitMoved = 0
            if ux then
                unitMoved = math.sqrt((ux - dest.ux) ^ 2 + (uy - dest.uy) ^ 2)
            end
            if mapMoved < 0.00008 and unitMoved > 40 then
                dest.staleMap = true
                F.flightSample = nil
                F.flightSpace = nil
            end
        end
    end
    local space, px, py, dx, dy, minMoved, minLeft, maxSpeed = F.FlightTrack(dest)
    if space and space ~= F.flightSpace then
        F.flightSpace = space
        F.flightSample = nil
    end
    local left
    local paced
    if space and px and now then
        local dist
        if space == "map" and dest.map then
            local ax, ay = F.MapWorld(dest.map, px, py)
            local bx, by = F.MapWorld(dest.map, dx, dy)
            if ax and bx then
                local dxY = ax - bx
                local dyY = ay - by
                dist = math.sqrt(dxY * dxY + dyY * dyY)
            end
        elseif space ~= "map" then
            local dxY = px - dx
            local dyY = py - dy
            dist = math.sqrt(dxY * dxY + dyY * dyY)
        end
        local speed = dist and F.FlightSpeed()
        if speed and dist >= 40 and F.AcceptEta(dist * F.PathFactor(dest, dist, "yards") / speed, now) then
            paced = true
        end
        if not paced then
            left = F.FlightSample(px, py, dx, dy, now, minMoved, minLeft, maxSpeed, dest, space)
        end
    end
    if not left then
        left = F.FlightLeft(now)
    end
    if left then
        return string.format("%s   %s", dest.name, F.FlightClock(left))
    end
    return dest.name
end

function F.FlightRoute()
    local now = F.Now()
    if F.OnTaxi() then
        if not F.flightStart then
            F.flightStart = now
            F.flightSaid = false
        end
        F.flightLandAt = nil
        return F.FlightLine(now)
    end
    if F.flightStart and not F.flightLandAt then
        F.flightLandAt = now
    end
    if F.flightStart and F.flightLandAt and now and not F.flightSaid and (now - F.flightLandAt) >= 3 then
        local took = F.flightLandAt - F.flightStart
        local flew = took >= 3
        local name = F.flightDest and F.flightDest.name
        local route = F.flightDest and F.flightDest.route
        if route and db and db.flightTimes and took >= 5 and took <= 3600 then
            db.flightTimes[route] = math.floor(took + 0.5)
        end
        F.flightSaid = true
        F.flightStart = nil
        F.flightLandAt = nil
        F.flightDest = nil
        F.flightEta = nil
        F.flightEtaAt = nil
        F.flightSample = nil
        F.flightSpace = nil
        if flew and type(name) == "string" and name ~= "" and F.Enabled("warnArrive") then
            F.Say(name .. " reached.")
        end
        if F.NoteRepair then
            F.NoteRepair()
        end
    end
    return nil
end

function F.InstallFlight()
    if F.flightHooked or type(hooksecurefunc) ~= "function" then
        return
    end
    local hooked = false
    if type(TakeTaxiNode) == "function" then
        hooksecurefunc("TakeTaxiNode", function(index)
            F.RememberFlight(index)
        end)
        hooked = true
    end
    if type(TaxiNodeOnButtonClick) == "function" then
        hooksecurefunc("TaxiNodeOnButtonClick", function(button)
            F.RememberFlight(button)
        end)
        hooked = true
    end
    if C_TaxiMap and type(C_TaxiMap.TakeTaxiNode) == "function" then
        hooksecurefunc(C_TaxiMap, "TakeTaxiNode", function(index)
            F.RememberFlight(index)
        end)
        hooked = true
    end
    F.flightHooked = hooked
end
F.InstallFlight()

function F.RefreshNav()
    if not nav or not db then
        return
    end
    local zone = GetMinimapZoneText()
    if not zone or zone == "" then
        zone = GetZoneText() or ""
    end
    navZone:SetText(zone)
    if MinimapZoneText and MinimapZoneText.GetTextColor then
        local r, g, b = MinimapZoneText:GetTextColor()
        if r then
            navZone:SetTextColor(r, g, b)
        end
    end

    local coordX, coordY = F.PlayerCoords()
    local facing = F.Compass(GetPlayerFacing())
    local place
    if coordX and coordY then
        place = string.format("%.1f,  %.1f     %s", coordX * 100, coordY * 100, facing)
    else
        place = facing
    end

    if not UnitIsDeadOrGhost("player") then
        local lifeX, lifeY, lifeInstance = F.PlayerWorld()
        if lifeX and lifeY then
            lastLifeX, lastLifeY, lastLifeInstance = lifeX, lifeY, lifeInstance
        end
        F.MaybeArrive()
    end

    if F.WatchTrip then
        F.WatchTrip()
    end
    if F.ArriveWalk then
        F.ArriveWalk()
    end
    local pin = db.pin
    local state, _, _, yards, px, py, pinX, pinY = F.PinOffset()
    local death = F.Enabled("deathMarker") and F.DeathPoint() or nil
    local dState, dYards, dpx, dpy, deathX, deathY
    if death then
        dState, _, _, dYards, dpx, dpy, deathX, deathY = F.PointOffset(death)
    end
    local preferCorpse = death and not pinArmed and (UnitIsDeadOrGhost("player") or not pin)
    local flight = F.FlightRoute()
    local route
    if preferCorpse then
        if dState == "ok" then
            route = string.format("Corpse   %d yd", dYards + 0.5)
        elseif dState == "other" then
            route = "Corpse is on another map"
        else
            route = "Finding the corpse"
        end
    elseif pinArmed then
        route = "Click the world map"
    elseif state == "ok" then
        local instruction = F.ArrowInstruction and F.ArrowInstruction()
        if type(instruction) == "string" and instruction ~= "" then
            route = instruction
        end
        local title = pin and type(pin.name) == "string" and pin.name or ""
        if not route then
            if title ~= "" then
                route = string.format("%s   %d yd", title, yards + 0.5)
            else
                route = string.format("%d yd", yards + 0.5)
            end
        end
    elseif state == "other" then
        local instruction = F.ArrowInstruction and F.ArrowInstruction()
        if type(instruction) == "string" and instruction ~= "" then
            route = instruction
        else
            local title = pin and type(pin.name) == "string" and pin.name ~= "" and pin.name or "Pin"
            route = title .. " is on another map"
        end
    elseif pin and pin.zx and pin.zy then
        local title = type(pin.name) == "string" and pin.name ~= "" and pin.name or "Pin"
        route = string.format("%s %.1f, %.1f", title, pin.zx * 100, pin.zy * 100)
    else
        route = nil
    end
    navPlace:SetText(place)
    if F.navFlight then
        if flight then
            F.navFlight:SetText(flight)
            F.navFlight:Show()
            if F.navFoot then
                F.navFoot:SetHeight(72)
            end
        else
            F.navFlight:Hide()
            if F.navFoot then
                F.navFoot:SetHeight(38)
            end
        end
    end
    F.SyncArrow()
    if F.zoneBar then
        navZone:ClearAllPoints()
        navZone:SetPoint("LEFT", F.zoneBar, "LEFT", 46, 0)
        navZone:SetPoint("RIGHT", F.zoneBar, "RIGHT", -12, 0)
    end
    if route then
        navRoute:ClearAllPoints()
        navRoute:SetPoint("BOTTOMLEFT", nav, "BOTTOMLEFT", 12, 8)
        navRoute:SetPoint("RIGHT", nav, "RIGHT", -12, 0)
        navRoute:SetText(route)
        if preferCorpse then
            navRoute:SetTextColor(1, 0.45, 0.32)
        else
            navRoute:SetTextColor(1, 0.92, 0.55)
        end
        navRoute:Show()
        nav:SetHeight(86)
    else
        navRoute:Hide()
        nav:SetHeight(52)
    end
    F.UpdatePinMark()
    F.UpdateDeathMark()
    F.UpdateRangeRings()
    F.NotePinArrival()
end

function F.UpdateNav()
    if not nav then
        return
    end
    pcall(F.RefreshNav)
end

function F.PlaceCoords()
    if not navPlace or not F.navFlight then
        return
    end
    local inset = 10
    if F.Theme().corner then
        inset = 10 + (F.mapCornerSize or 96) * 0.5
    end
    navPlace:ClearAllPoints()
    navPlace:SetPoint("TOPLEFT", F.navFoot, "TOPLEFT", inset, -8)
    F.navFlight:ClearAllPoints()
    F.navFlight:SetPoint("TOPLEFT", F.navFoot, "TOPLEFT", inset, -36)
end

function F.CreateNav()
    if nav or not map then
        return
    end
    nav = CreateFrame("Frame", "NavigateForeverNav", UIParent)
    F.nav = nav
    nav:SetFrameStrata("MEDIUM")
    nav:SetHeight(52)
    nav:EnableMouse(true)
    F.PaintPanel(nav, 0.94)
    F.MakeGrip(nav)

    local settingsBtn = F.Chip(nav, "", 34, 14, 28)
    settingsBtn:SetPoint("RIGHT", -8, 0)
    local gear = settingsBtn:CreateTexture(nil, "ARTWORK")
    gear:SetTexture("Interface\\Icons\\INV_Misc_Gear_01")
    gear:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    gear:SetSize(20, 20)
    gear:SetPoint("CENTER")
    settingsBtn:SetScript("OnClick", function()
        F.ToggleOptions()
    end)
    settingsBtn:HookScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText("Settings", F.BorderColor())
        GameTooltip:Show()
    end)
    settingsBtn:HookScript("OnLeave", GameTooltip_Hide)
    nav.settingsBtn = settingsBtn

    local clearBtn = F.Chip(nav, "Clear", 64, 14, 28)
    clearBtn:SetPoint("RIGHT", settingsBtn, "LEFT", -6, 0)
    clearBtn:SetScript("OnClick", function()
        local kept = db and db.pin and type(db.pin.name) == "string" and db.pin.name or ""
        F.ClearPin()
        F.UpdateNav()
        if kept ~= "" then
            F.Say("Pin cleared. " .. kept .. " is still saved.")
        end
    end)
    nav.clearBtn = clearBtn

    local pinBtn = F.Chip(nav, "Pin", 52, 14, 28)
    pinBtn:SetPoint("RIGHT", clearBtn, "LEFT", -6, 0)
    nav.pinBtn = pinBtn
    pinBtn:SetScript("OnClick", function()
        pinArmed = true
        F.HookWorldMap()
        if WorldMapFrame and not WorldMapFrame:IsShown() and ToggleWorldMap then
            ToggleWorldMap()
        end
        UpdateWorldClick()
        F.Say("Right-click the world map to drop a pin. Ctrl-click works too.")
        F.UpdateNav()
    end)

    local zoneBar = CreateFrame("Frame", "NavigateForeverZone", nav)
    F.zoneBar = zoneBar
    zoneBar:SetHeight(44)
    zoneBar:EnableMouse(true)
    F.PaintPanel(zoneBar, 0.94)
    F.MakeGrip(zoneBar)

    local brand = F.BrandIcon(zoneBar:CreateTexture(nil, "ARTWORK"))
    brand:SetSize(28, 28)
    brand:SetPoint("LEFT", 10, 0)
    F.AddParticles(zoneBar, 8)

    navZone = zoneBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    navZone:SetFont("Fonts\\FRIZQT__.TTF", 22, "OUTLINE")
    navZone:SetPoint("LEFT", zoneBar, "LEFT", 46, 0)
    navZone:SetPoint("RIGHT", zoneBar, "RIGHT", -12, 0)
    navZone:SetJustifyH("LEFT")
    navZone:SetWordWrap(false)
    navZone:SetTextColor(GOLD_R, GOLD_G, GOLD_B)

    local foot = CreateFrame("Frame", "NavigateForeverFoot", UIParent)
    F.navFoot = foot
    foot:SetFrameStrata("MEDIUM")
    foot:SetHeight(38)
    foot:EnableMouse(true)
    F.PaintPanel(foot, 0.94)
    F.MakeGrip(foot)

    navPlace = foot:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    navPlace:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
    navPlace:SetHeight(22)
    navPlace:SetPoint("TOPLEFT", foot, "TOPLEFT", 10, -8)
    navPlace:SetJustifyH("LEFT")
    navPlace:SetJustifyV("TOP")
    navPlace:SetWordWrap(false)
    navPlace:SetTextColor(0.90, 0.93, 0.98)

    local flightLine = foot:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    flightLine:SetFont("Fonts\\FRIZQT__.TTF", 22, "OUTLINE")
    flightLine:SetHeight(28)
    flightLine:SetPoint("TOPLEFT", foot, "TOPLEFT", 10, -36)
    flightLine:SetJustifyH("LEFT")
    flightLine:SetJustifyV("TOP")
    flightLine:SetWordWrap(false)
    flightLine:SetTextColor(1, 0.92, 0.55)
    flightLine:Hide()
    F.navFlight = flightLine

    navRoute = nav:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    navRoute:SetFont("Fonts\\FRIZQT__.TTF", 20, "OUTLINE")
    navRoute:SetPoint("BOTTOMLEFT", nav, "BOTTOMLEFT", 12, 8)
    navRoute:SetPoint("RIGHT", nav, "RIGHT", -12, 0)
    navRoute:SetJustifyH("LEFT")
    navRoute:SetWordWrap(false)
    navRoute:SetTextColor(1, 0.92, 0.55)

    pinMark = CreateFrame("Frame", "NavigateForeverPin", map)
    pinMark:SetSize(14, 14)
    pinMark:EnableMouse(false)
    pinMark:SetFrameLevel((map:GetFrameLevel() or 0) + 20)
    local markRing = pinMark:CreateTexture(nil, "OVERLAY")
    markRing:SetColorTexture(F.BorderColor())
    markRing:SetAllPoints()
    local markDot = pinMark:CreateTexture(nil, "OVERLAY")
    markDot:SetColorTexture(F.ThemeColor("hover"))
    pinMark.nfRing = markRing
    pinMark.nfDot = markDot
    markDot:SetPoint("TOPLEFT", 3, -3)
    markDot:SetPoint("BOTTOMRIGHT", -3, 3)
    pinMark:Hide()

    deathMark = CreateFrame("Frame", "NavigateForeverDeath", map)
    deathMark:SetSize(20, 20)
    deathMark:SetFrameStrata("HIGH")
    deathMark:EnableMouse(false)
    if deathMark.SetIgnoreParentAlpha then
        deathMark:SetIgnoreParentAlpha(true)
    end
    deathMark:SetFrameLevel((map:GetFrameLevel() or 0) + 22)
    local glow = deathMark:CreateTexture(nil, "BACKGROUND")
    glow:SetTexture("Interface\\Cooldown\\Ping4")
    glow:SetBlendMode("ADD")
    glow:SetPoint("CENTER")
    glow:SetSize(36, 36)
    glow:SetVertexColor(1, 0.72, 0.2)
    local halo = deathMark:CreateTexture(nil, "ARTWORK")
    halo:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
    halo:SetTexCoord(0.75, 1, 0.25, 0.5)
    halo:SetBlendMode("ADD")
    halo:SetPoint("CENTER")
    halo:SetSize(26, 26)
    halo:SetVertexColor(1, 0.28, 0.12)
    local skull = deathMark:CreateTexture(nil, "OVERLAY")
    skull:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
    skull:SetTexCoord(0.75, 1, 0.25, 0.5)
    skull:SetPoint("CENTER")
    skull:SetSize(16, 16)
    skull:SetVertexColor(1, 0.94, 0.82)
    deathMark.glow = glow
    deathMark.halo = halo
    deathMark.pulse = 0
    deathMark:SetScript("OnUpdate", function(self, elapsed)
        self.pulse = self.pulse + (elapsed or 0) * (self.clamped and 5.5 or 3.2)
        local wave = 0.5 + 0.5 * math.sin(self.pulse)
        self.glow:SetAlpha(0.25 + 0.75 * wave)
        local span = 28 + 14 * wave
        self.glow:SetSize(span, span)
        self.halo:SetAlpha(0.35 + 0.65 * wave)
        skull:SetAlpha(0.85 + 0.15 * wave)
    end)
    deathMark:Hide()

    mapFrame = CreateFrame("Frame", "NavigateForeverFrame", UIParent)
    mapFrame:SetFrameStrata("DIALOG")
    mapFrame:SetFrameLevel(20)
    mapFrame:EnableMouse(false)
    local function edge()
        local line = mapFrame:CreateTexture(nil, "OVERLAY")
        line:SetColorTexture(F.BorderColor())
        return line
    end
    mapFrame.top = edge()
    mapFrame.top:SetPoint("TOPLEFT", mapFrame, "TOPLEFT", 0, 0)
    mapFrame.top:SetPoint("TOPRIGHT", mapFrame, "TOPRIGHT", 0, 0)
    mapFrame.top:SetHeight(2)
    mapFrame.bottom = edge()
    mapFrame.bottom:SetPoint("BOTTOMLEFT", mapFrame, "BOTTOMLEFT", 0, 0)
    mapFrame.bottom:SetPoint("BOTTOMRIGHT", mapFrame, "BOTTOMRIGHT", 0, 0)
    mapFrame.bottom:SetHeight(2)
    mapFrame.left = edge()
    mapFrame.left:SetPoint("TOPLEFT", mapFrame, "TOPLEFT", 0, 0)
    mapFrame.left:SetPoint("BOTTOMLEFT", mapFrame, "BOTTOMLEFT", 0, 0)
    mapFrame.left:SetWidth(2)
    mapFrame.right = edge()
    mapFrame.right:SetPoint("TOPRIGHT", mapFrame, "TOPRIGHT", 0, 0)
    mapFrame.right:SetPoint("BOTTOMRIGHT", mapFrame, "BOTTOMRIGHT", 0, 0)
    mapFrame.right:SetWidth(2)
    F.CreateRangeRings()
end

function F.RingColor(index)
    local fallback = F.RING_COLORS[index] or F.RING_COLORS[1]
    local color = db and db["ringColor" .. index]
    local r = (type(color) == "table" and tonumber(color[1])) or fallback[1]
    local g = (type(color) == "table" and tonumber(color[2])) or fallback[2]
    local b = (type(color) == "table" and tonumber(color[3])) or fallback[3]
    return r, g, b
end

function F.PlaceDot(tex, x, y, size, r, g, b, alpha)
    tex:SetSize(size, size)
    tex:SetColorTexture(r, g, b, alpha)
    tex:ClearAllPoints()
    tex:SetPoint("CENTER", tex:GetParent(), "CENTER", x, y)
    tex:Show()
end

-- Prefer a yard value that puts the 40-yard ring on the map. A bad view
-- radius was hiding every circle.
function F.RingView(half)
    local function usable(view)
        if not view or view <= 0 or not db then
            return false
        end
        for index = 1, 3 do
            if F.Enabled("ring" .. index) then
                local yards = tonumber(db["ring" .. index .. "Yards"]) or 0
                local pixel = (yards / view) * half
                if pixel >= 8 and pixel <= half * 0.92 then
                    return true
                end
            end
        end
        return false
    end
    local reported = F.ViewRadius()
    if usable(reported) then
        return reported
    end
    local zoom = map and map.GetZoom and map:GetZoom() or 0
    local listed = ({ [0] = 466 + 2 / 3, 400, 333 + 1 / 3, 266 + 2 / 6, 200, 133 + 1 / 3 })[zoom] or (466 + 2 / 3)
    if usable(listed) then
        return listed
    end
    if usable(listed / 2) then
        return listed / 2
    end
    return reported or (listed / 2)
end

function F.LayoutRing(ring, pixel, half, r, g, b)
    local parts = ring.parts
    local count = #parts
    local step = (math.pi * 2) / count
    local dot = 2 * pixel * math.sin(step * 0.5) + 1
    if dot < 3 then
        dot = 3
    end
    for n, part in ipairs(parts) do
        local angle = (n - 0.5) * step
        local x = math.cos(angle) * pixel
        local y = math.sin(angle) * pixel
        if math.abs(x) > half - 2 or math.abs(y) > half - 2 then
            part.shade:Hide()
            part.line:Hide()
        else
            F.PlaceDot(part.shade, x, y, dot + 2, 0, 0, 0, 0.85)
            F.PlaceDot(part.line, x, y, dot, r, g, b, 1)
        end
    end
    ring.pixel = pixel
    ring.r, ring.g, ring.b = r, g, b
end

function F.CreateRangeRings()
    if rangeHost or not map then
        return
    end
    -- On top of the minimap. A child of the map was drawing under the terrain.
    rangeHost = CreateFrame("Frame", "NavigateForeverRings", UIParent)
    rangeHost:SetFrameStrata("HIGH")
    rangeHost:SetFrameLevel(40)
    rangeHost:EnableMouse(false)
    rangeHost:SetPoint("TOPLEFT", map, "TOPLEFT", 0, 0)
    rangeHost:SetPoint("BOTTOMRIGHT", map, "BOTTOMRIGHT", 0, 0)
    rangeHost.rings = {}
    local count = 48
    for index = 1, 3 do
        local ring = CreateFrame("Frame", nil, rangeHost)
        ring:SetAllPoints(rangeHost)
        ring:EnableMouse(false)
        ring.parts = {}
        for n = 1, count do
            ring.parts[n] = {
                shade = ring:CreateTexture(nil, "ARTWORK"),
                line = ring:CreateTexture(nil, "OVERLAY"),
            }
        end
        local label = ring:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        pcall(label.SetFont, label, "Fonts\\FRIZQT__.TTF", 13, "OUTLINE")
        label:SetJustifyH("CENTER")
        ring.label = label
        ring:Hide()
        rangeHost.rings[index] = ring
    end
    local function hookWheel(frame)
        if frame and frame.HookScript and not frame.nfRingWheel then
            frame.nfRingWheel = true
            frame:HookScript("OnMouseWheel", function()
                F.UpdateRangeRings()
            end)
        end
    end
    hookWheel(map)
    hookWheel(cluster)
    rangeHost:Hide()
end

function F.UpdateRangeRings()
    if not map then
        return
    end
    if not rangeHost then
        F.CreateRangeRings()
    end
    if not rangeHost then
        return
    end
    if hybrid or not db or not F.Enabled("rings") or not map:IsShown() then
        rangeHost:Hide()
        return
    end
    local half = math.min(rangeHost:GetWidth() or 0, rangeHost:GetHeight() or 0) * 0.5
    if half < 8 then
        half = math.min(map:GetWidth() or 0, map:GetHeight() or 0) * 0.5
    end
    local view = F.RingView(half)
    if not view or view <= 0 or half < 8 then
        rangeHost:Hide()
        return
    end
    local screen = F.ResolutionScale()
    if rangeHost.nfScreen ~= screen then
        rangeHost.nfScreen = screen
        local fontSize = F.Round(13 * screen)
        if fontSize < 8 then
            fontSize = 8
        end
        for _, ring in ipairs(rangeHost.rings) do
            if ring.label then
                pcall(ring.label.SetFont, ring.label, "Fonts\\FRIZQT__.TTF", fontSize, "OUTLINE")
            end
        end
    end
    local shown = false
    for index, ring in ipairs(rangeHost.rings) do
        local yards = tonumber(db["ring" .. index .. "Yards"]) or 0
        local pixel = (yards / view) * half
        local r, g, b = F.RingColor(index)
        local viewKey = math.floor(view * 10 + 0.5)
        local halfKey = math.floor(half * 2 + 0.5)
        local visible = F.Enabled("ring" .. index) and yards >= 1 and pixel >= 4
        if not visible then
            ring:Hide()
        else
            if ring.viewKey ~= viewKey or ring.halfKey ~= halfKey or ring.yards ~= yards or ring.r ~= r or ring.g ~= g or ring.b ~= b then
                F.LayoutRing(ring, pixel, half, r, g, b)
                ring.viewKey = viewKey
                ring.halfKey = halfKey
                ring.yards = yards
            end
            if ring.label then
                local labelY = pixel + 2
                local inset = 16 * screen
                if labelY > half - inset then
                    labelY = half - inset
                end
                ring.label:SetText(tostring(yards))
                ring.label:SetTextColor(r, g, b)
                if ring.labelPixel ~= labelY then
                    ring.label:ClearAllPoints()
                    ring.label:SetPoint("BOTTOM", ring, "CENTER", 0, labelY)
                    ring.labelPixel = labelY
                end
            end
            ring:Show()
            shown = true
        end
    end
    if shown then
        rangeHost:Show()
        if not db.ringHint then
            db.ringHint = true
            F.Say("Range rings are on. Look around your arrow for 20, 40, and 60.")
        end
    else
        rangeHost:Hide()
    end
end

function F.HookMapMouse()
    if not map or map.nfMouseHooked or not map.HookScript then
        return
    end
    map.nfMouseHooked = true
    map:HookScript("OnMouseDown", function(_, button)
        if button == "LeftButton" and IsControlKeyDown() then
            F.DropPinAtCursor()
            return
        end
        if button == "LeftButton" and F.ShouldDrag() then
            F.StartDrag()
        end
    end)
    map:HookScript("OnMouseUp", function(_, button)
        if button == "LeftButton" then
            F.StopDrag()
        end
    end)
end

function F.HookCluster()
    if cluster.nfHooked then
        return
    end
    cluster.nfHooked = true

    hooksecurefunc(cluster, "SetSize", function(_, width, height)
        if applying or interacting or not ready or hybrid or not db then
            return
        end
        if stock.clusterW and F.Nearly(width, stock.clusterW) and F.Nearly(height, stock.clusterH) then
            return
        end
        F.Apply()
    end)

    hooksecurefunc(cluster, "SetPoint", function()
        if applying or interacting or not ready or hybrid or not db then
            return
        end
        if F.PositionMatches() then
            return
        end
        F.Apply()
    end)

    if container and container.SetScale then
        hooksecurefunc(container, "SetScale", function(_, scale)
            if applying or interacting or not ready or hybrid then
                return
            end
            local expected = F.AppliedMapScale()
            if math.abs((scale or 1) - expected) < 0.02 then
                return
            end
            F.Apply()
        end)
    end

    local function Reapply()
        if applying or interacting or not ready or hybrid then
            return
        end
        F.Apply()
    end

    if type(cluster.SetEditModeScale) == "function" then
        hooksecurefunc(cluster, "SetEditModeScale", Reapply)
    end
    if type(cluster.SetHeaderUnderneath) == "function" then
        hooksecurefunc(cluster, "SetHeaderUnderneath", Reapply)
    end
    if type(MiniMapIndicatorFrame_UpdatePosition) == "function" then
        hooksecurefunc("MiniMapIndicatorFrame_UpdatePosition", function()
            if applying or interacting or not ready or hybrid or reflowing then
                return
            end
            F.LayoutChrome()
        end)
    end
end

local originalGetMinimapShape = GetMinimapShape
function GetMinimapShape()
    if hybrid then
        if originalGetMinimapShape then
            return originalGetMinimapShape()
        end
        return "ROUND"
    end
    return "SQUARE"
end

function F.RefreshMinimapButtons()
    if hybrid or not LibStub then
        return
    end
    local ok, lib = pcall(LibStub, "LibDBIcon-1.0", true)
    if not ok or not lib or not lib.GetButtonList or not lib.Refresh then
        return
    end
    for _, name in ipairs(lib:GetButtonList()) do
        pcall(lib.Refresh, lib, name)
    end
end

function F.SetSliderSilent(slider, value)
    if not slider then
        return
    end
    slider.silent = true
    slider:SetValue(value)
    slider.silent = false
end

F.SyncOptions = function()
    if not db or not panel then
        return
    end
    F.SetSliderSilent(widthSlider, F.Round(db.scale * 100))
    F.SetSliderSilent(alphaSlider, F.Round(db.alpha * 100))
    F.SetSliderSilent(moveSlider, F.Round(db.alphaMove * 100))
    F.SetSliderSilent(combatSlider, F.Round(db.alphaCombat * 100))
    F.SetSliderSilent(arrowSlider, F.ArrowScalePercent())
    if widthText then
        widthText:SetText(tostring(F.Round(db.scale * 100)) .. "%")
    end
    if alphaText then
        alphaText:SetText(tostring(F.Round(db.alpha * 100)) .. "%")
    end
    if moveText then
        moveText:SetText(tostring(F.Round(db.alphaMove * 100)) .. "%")
    end
    if combatText then
        combatText:SetText(tostring(F.Round(db.alphaCombat * 100)) .. "%")
    end
    if arrowText then
        arrowText:SetText(tostring(F.ArrowScalePercent()) .. "%")
    end
    if F.gatherSlider then
        local seconds = F.Clamp(F.Round(tonumber(db.gatherSeconds) or 4), 2, 12)
        F.SetSliderSilent(F.gatherSlider, seconds)
    end
    if F.gatherText then
        F.gatherText:SetText(tostring(F.Clamp(F.Round(tonumber(db.gatherSeconds) or 4), 2, 12)) .. " s")
    end
    if lockCheck then
        lockCheck:SetChecked(db.locked)
    end
    if fadeCheck then
        fadeCheck:SetChecked(db.fadeMove)
    end
    for key, check in pairs(optionChecks) do
        check:SetChecked(F.Enabled(key))
    end
    if F.SyncCampfireSound then
        F.SyncCampfireSound()
    end
    if F.SyncTheme then
        F.SyncTheme()
    end
    for index = 1, 3 do
        local row = F.ringRows[index]
        if row and row.slider then
            local yards = tonumber(db["ring" .. index .. "Yards"]) or (index * 20)
            F.SetSliderSilent(row.slider, yards)
            if row.text then
                row.text:SetText(tostring(yards) .. " yd")
            end
        end
    end
end

function F.ResetSettings()
    F.GatherUnmute()
    local hintShown = db.hintShown
    for key, value in pairs(DEFAULTS) do
        db[key] = value
    end
    db.hintShown = hintShown
    db.menuColor = { NAVY_R, NAVY_G, NAVY_B }
    db.borderColor = { GOLD_R, GOLD_G, GOLD_B }
    for index = 1, 3 do
        local color = F.RING_COLORS[index]
        db["ringColor" .. index] = { color[1], color[2], color[3] }
    end
    db.arrowScale = 1
    db.pin = nil
    pinArmed = false
    if F.RefreshWorldPin then
        F.RefreshWorldPin()
    end
    interacting = false
    sizing = false
    dragging = false
    F.Apply()
    F.SetArrowScale(100)
    if F.gather then
        F.gather.held = false
        F.gather.blocked = false
        F.gather.fails = 0
        F.gather.want = nil
        F.gather.next = nil
        F.gather.death = false
        F.gather.resume = false
        F.gather.prefer = nil
        F.gather.remember = nil
    end
    F.SyncOptions()
    F.Say("Settings reset.")
end

function F.SetLocked(locked)
    db.locked = not not locked
    if lockCheck then
        lockCheck:SetChecked(db.locked)
    end
    if db.locked then
        F.Say("Position locked. Hold Right Alt and drag to move the map.")
    else
        F.Say("Position unlocked. Drag the map to move it.")
    end
end

function F.PrepareSlider(slider)
    slider:SetOrientation("HORIZONTAL")
    slider:SetValueStep(1)
    slider:SetObeyStepOnDrag(true)
    local thumb
    local thumbSet = pcall(slider.SetThumbTexture, slider, "Interface\\Buttons\\UI-SliderBar-Button-Horizontal")
    if thumbSet then
        local ok, existing = pcall(slider.GetThumbTexture, slider)
        if ok then
            thumb = existing
        end
    end
    local solid = not thumb
    if solid then
        thumb = slider:CreateTexture(nil, "OVERLAY")
        thumb:SetColorTexture(F.BorderColor())
        thumb:SetSize(14, 14)
        slider:SetThumbTexture(thumb)
    else
        thumb:SetSize(16, 16)
        thumb:SetVertexColor(F.BorderColor())
    end
    local track = slider:CreateTexture(nil, "BACKGROUND")
    local tr, tg, tb = F.ThemeColor("track")
    track:SetColorTexture(tr, tg, tb, 1)
    table.insert(themedSliders, { thumb = thumb, track = track, solid = solid })
    track:SetPoint("LEFT", 0, 0)
    track:SetPoint("RIGHT", 0, 0)
    track:SetHeight(4)
    slider:EnableMouseWheel(true)
    slider:SetScript("OnMouseWheel", function(self, delta)
        self:SetValue(self:GetValue() + delta)
    end)
end

function F.CreateSlider(parent, label, minValue, maxValue, y, onChanged, left, right)
    left = left or 18
    right = right or -18
    local name = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    name:SetPoint("TOPLEFT", left, y)
    name:SetText(label)
    name:SetWordWrap(false)
    F.SetFontSize(name, 16)

    local value = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    value:SetPoint("TOPRIGHT", right, y)
    value:SetText("")
    value:SetWordWrap(false)
    F.SetFontSize(value, 16)

    local slider = CreateFrame("Slider", nil, parent)
    slider:SetPoint("TOPLEFT", left, y - 18)
    slider:SetPoint("TOPRIGHT", right, y - 18)
    slider:SetHeight(16)
    slider:SetMinMaxValues(minValue, maxValue)
    F.PrepareSlider(slider)
    slider:SetScript("OnValueChanged", function(self, newValue)
        if self.silent then
            return
        end
        onChanged(F.Round(newValue), value)
    end)
    return slider, value
end

function F.SectionLabel(parent, text, y)
    local label = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("TOPLEFT", 18, y)
    label:SetText(text)
    label:SetWordWrap(false)
    F.SetFontSize(label, 18)
    local br, bgc, bb = F.BorderColor()
    label:SetTextColor(br, bgc, bb)
    table.insert(accentText, label)
    return label
end

function F.CreateColorRow(parent, label, y, key, fallbackR, fallbackG, fallbackB)
    local name = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    name:SetPoint("TOPLEFT", 18, y - 4)
    name:SetText(label)
    name:SetWordWrap(false)
    F.SetFontSize(name, 16)
    local swatch = CreateFrame("Button", nil, parent)
    swatch:SetSize(96, 22)
    swatch:SetPoint("TOPRIGHT", -18, y)
    local tex = swatch:CreateTexture(nil, "ARTWORK")
    tex:SetAllPoints()
    colorSwatches[key] = tex
    colorSwatchFrames[key] = swatch
    local function edge(point, x, offY, width, height)
        local line = swatch:CreateTexture(nil, "OVERLAY")
        local br, bgc, bb = F.BorderColor()
        line:SetColorTexture(br, bgc, bb, 1)
        line:SetSize(width, height)
        line:SetPoint(point, x, offY)
        return line
    end
    swatch.top = edge("TOPLEFT", 0, 0, 96, 1)
    swatch.bottom = edge("BOTTOMLEFT", 0, 0, 96, 1)
    swatch.left = edge("TOPLEFT", 0, 0, 1, 22)
    swatch.right = edge("TOPRIGHT", 0, 0, 1, 22)
    swatch:SetScript("OnClick", function()
        F.OpenColorPicker(key, fallbackR, fallbackG, fallbackB)
    end)
    return swatch
end

function F.CreateCheck(parent, label, x, y, key)
    local check = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    check:SetPoint("TOPLEFT", x, y)
    check:SetScript("OnClick", function(self)
        db[key] = not not self:GetChecked()
    end)
    if check.Text then
        check.Text:SetText("")
        check.Text:Hide()
    end
    local text = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    text:SetPoint("LEFT", check, "RIGHT", 2, 0)
    text:SetText(label)
    text:SetWordWrap(false)
    F.SetFontSize(text, 16)
    optionChecks[key] = check
    return check
end

function F.CreateRingRow(parent, index, y)
    local yardsKey = "ring" .. index .. "Yards"
    local colorKey = "ringColor" .. index
    local check = F.CreateCheck(parent, "", 14, y, "ring" .. index)
    check:HookScript("OnClick", function()
        F.UpdateRangeRings()
    end)
    check:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Show this ring", F.BorderColor())
        GameTooltip:Show()
    end)
    check:SetScript("OnLeave", GameTooltip_Hide)

    local swatch = CreateFrame("Button", nil, parent)
    swatch:SetSize(36, 20)
    swatch:SetPoint("TOPRIGHT", -16, y - 6)
    local tex = swatch:CreateTexture(nil, "ARTWORK")
    tex:SetAllPoints()
    colorSwatches[colorKey] = tex
    colorSwatchFrames[colorKey] = swatch
    local function edge(point, width, height)
        local line = swatch:CreateTexture(nil, "OVERLAY")
        local br, bgc, bb = F.BorderColor()
        line:SetColorTexture(br, bgc, bb, 1)
        line:SetSize(width, height)
        line:SetPoint(point, 0, 0)
        return line
    end
    swatch.top = edge("TOPLEFT", 36, 1)
    swatch.bottom = edge("BOTTOMLEFT", 36, 1)
    swatch.left = edge("TOPLEFT", 1, 20)
    swatch.right = edge("TOPRIGHT", 1, 20)
    swatch:SetScript("OnClick", function()
        local fallback = F.RING_COLORS[index]
        F.OpenColorPicker(colorKey, fallback[1], fallback[2], fallback[3])
    end)
    swatch:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Ring color", F.BorderColor())
        GameTooltip:AddLine("Color for this circle.", 1, 1, 1, true)
        GameTooltip:Show()
    end)
    swatch:SetScript("OnLeave", GameTooltip_Hide)

    local value = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    value:SetPoint("RIGHT", swatch, "LEFT", -8, 0)
    value:SetWidth(64)
    value:SetJustifyH("RIGHT")
    value:SetWordWrap(false)
    value:SetTextColor(0.90, 0.93, 0.98)
    F.SetFontSize(value, 16)

    local slider = CreateFrame("Slider", nil, parent)
    slider:SetPoint("LEFT", check, "RIGHT", 8, 0)
    slider:SetPoint("RIGHT", value, "LEFT", -8, 0)
    slider:SetHeight(16)
    slider:SetMinMaxValues(F.RING_MIN, F.RING_MAX)
    F.PrepareSlider(slider)
    slider:SetScript("OnValueChanged", function(self, newValue)
        if self.silent then
            return
        end
        local yards = F.Clamp(F.Round(newValue), F.RING_MIN, F.RING_MAX)
        db[yardsKey] = yards
        value:SetText(tostring(yards) .. " yd")
        F.UpdateRangeRings()
    end)
    slider:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Ring distance", F.BorderColor())
        GameTooltip:AddLine("Yards from you to this circle. It hides when you zoom in past it.", 1, 1, 1, true)
        GameTooltip:Show()
    end)
    slider:SetScript("OnLeave", GameTooltip_Hide)

    local yards = tonumber(db[yardsKey]) or (index * 20)
    F.SetSliderSilent(slider, yards)
    value:SetText(tostring(yards) .. " yd")
    F.ringRows[index] = { slider = slider, text = value }
end

function F.RegisterGameOptions()
    if panel.nfGameOptions then
        return
    end
    panel.nfGameOptions = true
    local page = CreateFrame("Frame")
    page.name = "Navigate Forever"
    local brand = F.BrandIcon(page:CreateTexture(nil, "ARTWORK"))
    brand:SetSize(36, 36)
    brand:SetPoint("TOPLEFT", 16, -16)
    local title = page:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", brand, "TOPRIGHT", 12, -2)
    title:SetText("Navigate Forever")
    title:SetTextColor(F.BorderColor())
    table.insert(accentText, title)
    local note = page:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    note:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
    note:SetJustifyH("LEFT")
    note:SetText("Size, fade, range rings, gathering, and chat notes. Each group has its own page.")
    local open = CreateFrame("Button", nil, page, "UIPanelButtonTemplate")
    open:SetSize(180, 26)
    open:SetPoint("TOPLEFT", note, "BOTTOMLEFT", 0, -16)
    open:SetText("Open options")
    open:SetScript("OnClick", function()
        if SettingsPanel and SettingsPanel.Hide then
            SettingsPanel:Hide()
        elseif InterfaceOptionsFrame and InterfaceOptionsFrame.Hide then
            InterfaceOptionsFrame:Hide()
        end
        if panel and not panel:IsShown() then
            panel:Show()
        end
    end)
    if Settings and Settings.RegisterCanvasLayoutCategory and Settings.RegisterAddOnCategory then
        local ok, category = pcall(Settings.RegisterCanvasLayoutCategory, page, "Navigate Forever")
        if ok and category then
            pcall(Settings.RegisterAddOnCategory, category)
            return
        end
    end
    if InterfaceOptions_AddCategory then
        InterfaceOptions_AddCategory(page)
    end
end

function F.ToggleOptions()
    if not panel then
        F.Say("Still loading.")
        return
    end
    if panel:IsShown() then
        panel:Hide()
    else
        panel:Show()
    end
end

F.CAMPFIRE_SOUNDS = {
    { id = "ready", label = "Ready check", kit = "READY_CHECK" },
    { id = "raid", label = "Raid warning", kit = "RAID_WARNING" },
    { id = "ping", label = "Map ping", kit = "MAP_PING" },
    { id = "level", label = "Level up", kit = "LEVEL_UP" },
    { id = "alarm", label = "Alarm clock", kit = "ALARM_CLOCK_WARNING_3" },
    { id = "whisper", label = "Whisper", kit = "TELL_MESSAGE" },
    { id = "queue", label = "Queue", kit = "PVP_ENTER_QUEUE" },
    { id = "coin", label = "Coins", kit = "LOOT_WINDOW_COIN_SOUND" },
}

function F.CampfireSoundId(id)
    for index = 1, #F.CAMPFIRE_SOUNDS do
        local sound = F.CAMPFIRE_SOUNDS[index]
        if sound.id == id and SOUNDKIT and SOUNDKIT[sound.kit] then
            return sound.id
        end
    end
    for index = 1, #F.CAMPFIRE_SOUNDS do
        local sound = F.CAMPFIRE_SOUNDS[index]
        if SOUNDKIT and SOUNDKIT[sound.kit] then
            return sound.id
        end
    end
    return "ready"
end

function F.CampfireSoundById(id)
    local fallback
    for index = 1, #F.CAMPFIRE_SOUNDS do
        local sound = F.CAMPFIRE_SOUNDS[index]
        local kit = SOUNDKIT and SOUNDKIT[sound.kit]
        if kit then
            if not fallback then
                fallback = sound
            end
            if sound.id == id then
                return sound, kit
            end
        end
    end
    if fallback then
        return fallback, SOUNDKIT[fallback.kit]
    end
end

function F.PlayCampfireSound()
    local _, kit = F.CampfireSoundById(db and db.campfireSound)
    if kit then
        pcall(PlaySound, kit)
    end
end

function F.CreateCampfireSounds(parent, x, y)
    local label = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    label:SetPoint("TOPLEFT", x, y - 6)
    label:SetText("Sound")
    label:SetWordWrap(false)
    F.SetFontSize(label, 16)
    local button = F.Chip(parent, "Ready check", 156, 16)
    button:SetHeight(26)
    button:SetPoint("TOPLEFT", x + 52, y + 2)
    local menu = CreateFrame("Frame", nil, parent)
    menu:SetFrameStrata("DIALOG")
    menu:SetFrameLevel((parent:GetFrameLevel() or 1) + 30)
    menu:SetWidth(156)
    menu:SetPoint("BOTTOMLEFT", button, "TOPLEFT", 0, 2)
    F.PaintPanel(menu, 1)
    menu:EnableMouse(true)
    menu:Hide()
    local shown = {}
    for index = 1, #F.CAMPFIRE_SOUNDS do
        local sound = F.CAMPFIRE_SOUNDS[index]
        if SOUNDKIT and SOUNDKIT[sound.kit] then
            shown[#shown + 1] = sound
        end
    end
    menu:SetHeight(math.max(26, #shown * 22 + 8))
    for index = 1, #shown do
        local sound = shown[index]
        local row = CreateFrame("Button", nil, menu)
        row:SetSize(146, 22)
        row:SetPoint("TOPLEFT", 5, -4 - (index - 1) * 22)
        local text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        text:SetPoint("LEFT", 6, 0)
        text:SetText(sound.label)
        text:SetWordWrap(false)
        F.SetFontSize(text, 16)
        text:SetTextColor(F.BorderColor())
        table.insert(accentText, text)
        row:SetScript("OnEnter", function()
            text:SetTextColor(F.ThemeColor("bright"))
        end)
        row:SetScript("OnLeave", function()
            text:SetTextColor(F.BorderColor())
        end)
        row:SetScript("OnClick", function()
            db.campfireSound = sound.id
            button.nfLabel:SetText(sound.label)
            menu:Hide()
            F.PlayCampfireSound()
        end)
    end
    if #shown == 0 then
        label:Hide()
        button:Hide()
    end
    button:SetScript("OnClick", function()
        if menu:IsShown() then
            menu:Hide()
        else
            menu:Show()
        end
    end)
    parent:HookScript("OnHide", function()
        menu:Hide()
    end)
    function F.SyncCampfireSound()
        local sound = F.CampfireSoundById(db and db.campfireSound)
        if sound and button.nfLabel then
            button.nfLabel:SetText(sound.label)
        end
    end
end

function F.CreateThemePicker(parent, y)
    local label = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    label:SetPoint("TOPLEFT", 18, y - 4)
    label:SetText("Theme")
    label:SetWordWrap(false)
    F.SetFontSize(label, 16)
    local button = F.Chip(parent, F.Theme().label, 156, 16)
    button:SetHeight(26)
    button:SetPoint("TOPRIGHT", -18, y + 2)
    local menu = CreateFrame("Frame", nil, parent)
    menu:SetFrameStrata("DIALOG")
    menu:SetFrameLevel((parent:GetFrameLevel() or 1) + 30)
    menu:SetPoint("TOPRIGHT", button, "BOTTOMRIGHT", 0, -2)
    F.PaintPanel(menu, 1)
    menu:EnableMouse(true)
    menu:Hide()
    local columns = { class = 2, race = 3 }
    local depth = { 0, 0, 0 }
    local lastGroup = {}
    for index = 1, #F.THEMES do
        local theme = F.THEMES[index]
        local column = columns[theme.group] or 1
        local group = theme.group or ""
        if depth[column] > 0 and lastGroup[column] ~= group then
            depth[column] = depth[column] + 10
        end
        lastGroup[column] = group
        local row = CreateFrame("Button", nil, menu)
        row:SetSize(146, 22)
        row:SetPoint("TOPLEFT", 5 + (column - 1) * 150, -4 - depth[column])
        depth[column] = depth[column] + 22
        local text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        text:SetPoint("LEFT", 6, 0)
        text:SetText(theme.label)
        text:SetWordWrap(false)
        F.SetFontSize(text, 16)
        text:SetTextColor(F.BorderColor())
        table.insert(accentText, text)
        row:SetScript("OnEnter", function()
            text:SetTextColor(F.ThemeColor("bright"))
        end)
        row:SetScript("OnLeave", function()
            text:SetTextColor(F.BorderColor())
        end)
        row:SetScript("OnClick", function()
            menu:Hide()
            F.SetTheme(theme.id)
        end)
    end
    local used = depth[3] > 0 and 3 or (depth[2] > 0 and 2 or 1)
    menu:SetSize(used * 150 + 6, math.max(depth[1], depth[2], depth[3]) + 8)
    button:SetScript("OnClick", function()
        if menu:IsShown() then
            menu:Hide()
        else
            menu:Show()
        end
    end)
    button:HookScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Theme", F.BorderColor())
        GameTooltip:AddLine("Changes the colors, the logo, and the corner pieces on the window and the minimap. Most themes also have their own mist, flame, and drifting particles. Default and Classic UI stay still, like the game's own windows. It sets the menu and border colors below, which you can still change after. Each character remembers its own theme and colors.", 1, 1, 1, true)
        GameTooltip:Show()
    end)
    button:HookScript("OnLeave", GameTooltip_Hide)
    parent:HookScript("OnHide", function()
        menu:Hide()
    end)
    function F.SyncTheme()
        if button.nfLabel then
            button.nfLabel:SetText(F.Theme().label)
        end
    end
end

function F.PaintOptionTab(button, selected)
    local br, bgc, bb = F.BorderColor()
    local mr, mg, mb = F.MenuColor()
    local hot = selected or button.nfHover
    local r, g, b = br, bgc, bb
    local tr, tg, tb = br, bgc, bb
    if hot then
        r, g, b = F.ThemeColor("hover")
        tr, tg, tb = F.ThemeColor("bright")
    end
    button.nfBg:SetColorTexture(mr, mg, mb, 1)
    button.nfTop:SetColorTexture(r, g, b, 1)
    button.nfLeft:SetColorTexture(r, g, b, 1)
    button.nfRight:SetColorTexture(r, g, b, 1)
    if selected then
        button.nfBottom:SetColorTexture(mr, mg, mb, 1)
    else
        button.nfBottom:SetColorTexture(r, g, b, 1)
    end
    if button.nfLabel then
        button.nfLabel:SetTextColor(tr, tg, tb)
    end
end

function F.RefreshOptionTabs()
    local tabs = F.optionTabs
    if not tabs then
        return
    end
    for index = 1, #tabs do
        local button = tabs[index]
        F.PaintOptionTab(button, button.nfPage == F.optionPage)
    end
end

function F.ShowOptionsPage(id)
    if not F.optionPages or not F.optionPages[id] then
        return
    end
    F.optionPage = id
    for key, page in pairs(F.optionPages) do
        if key == id then
            page:Show()
        else
            page:Hide()
        end
    end
    if GameTooltip then
        GameTooltip:Hide()
    end
    F.RefreshOptionTabs()
end

function F.CreateOptionsPage()
    local page = CreateFrame("Frame", nil, panel)
    page:SetPoint("TOPLEFT", 0, -102)
    page:SetPoint("BOTTOMRIGHT", 0, 88)
    return page
end

function F.OptionsTab(label, tip, x, id)
    local button = F.Chip(panel, label, 106, 16)
    button:SetSize(106, 26)
    button:SetPoint("TOPLEFT", x, -76)
    button.nfPage = id
    button:SetScript("OnClick", function()
        F.ShowOptionsPage(id)
    end)
    button:SetScript("OnEnter", function(self)
        self.nfHover = true
        F.PaintOptionTab(self, F.optionPage == id)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(label, F.BorderColor())
        GameTooltip:AddLine(tip, 1, 1, 1, true)
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function(self)
        self.nfHover = false
        F.PaintOptionTab(self, F.optionPage == id)
        GameTooltip:Hide()
    end)
    F.optionTabs[#F.optionTabs + 1] = button
    return button
end

function F.NavIsTracked()
    if not C_SuperTrack then
        return false
    end
    if C_SuperTrack.GetSuperTrackedQuestID then
        local ok, id = pcall(C_SuperTrack.GetSuperTrackedQuestID)
        if ok and not (issecretvalue and issecretvalue(id)) then
            id = tonumber(id)
            if id and id > 0 then
                return true
            end
        end
    end
    if C_SuperTrack.IsSuperTrackingUserWaypoint then
        local ok, on = pcall(C_SuperTrack.IsSuperTrackingUserWaypoint)
        if ok and on == true then
            return true
        end
    end
    if C_SuperTrack.IsSuperTrackingAnything then
        local ok, on = pcall(C_SuperTrack.IsSuperTrackingAnything)
        if ok and on == true then
            return true
        end
    end
    return false
end

-- The game draws the diamond on a frame from C_Navigation.GetFrame, then fades that
-- artwork out while showInGameNavigation is off. Addon code cannot flip that setting
-- on this client, so keep the artwork visible and follow the same frame.
function F.RevealQuestDiamond()
    local frame = SuperTrackedFrame
    if not frame or frame.nfDiamondHook then
        return
    end
    frame.nfDiamondHook = true
    frame:HookScript("OnUpdate", function(self)
        if not F.Enabled("questDiamond") or not F.NavIsTracked() then
            return
        end
        if not self:IsShown() then
            self:Show()
        end
        self:SetAlpha(1)
        if self.Icon then
            self.Icon:Show()
            self.Icon:SetAlpha(1)
        end
    end)
end

function F.QuestNavFrame()
    if C_Navigation and C_Navigation.GetFrame then
        local ok, frame = pcall(C_Navigation.GetFrame)
        if ok and type(frame) == "table" then
            return frame
        end
    end
    return SuperTrackedFrame
end

function F.EnsureQuestDiamond()
    F.RevealQuestDiamond()
    if F.diamondMark or not UIParent then
        return
    end
    local mark = CreateFrame("Frame", nil, UIParent)
    mark:SetSize(36, 36)
    mark:SetFrameStrata("HIGH")
    mark:EnableMouse(false)
    local glow = mark:CreateTexture(nil, "BACKGROUND")
    glow:SetTexture("Interface\\Cooldown\\Ping4")
    glow:SetBlendMode("ADD")
    glow:SetPoint("CENTER")
    glow:SetSize(56, 56)
    glow:SetVertexColor(1, 0.86, 0.2)
    local icon = mark:CreateTexture(nil, "ARTWORK")
    icon:SetSize(32, 32)
    icon:SetPoint("CENTER")
    local usedAtlas = icon.SetAtlas and pcall(icon.SetAtlas, icon, "Navigation-Tracked-Icon", true)
    if not usedAtlas then
        icon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
        icon:SetTexCoord(0.5, 0.75, 0, 0.25)
    end
    mark:Hide()
    mark:SetScript("OnUpdate", function(self)
        if not F.Enabled("questDiamond") or not F.NavIsTracked() then
            self:Hide()
            return
        end
        F.RevealQuestDiamond()
        local nav = F.QuestNavFrame()
        if not nav then
            self:Hide()
            return
        end
        if not nav:IsShown() then
            nav:Show()
        end
        pcall(nav.SetAlpha, nav, 1)
        local readOK, x, y = pcall(nav.GetCenter, nav)
        local secret = readOK and issecretvalue and (issecretvalue(x) or issecretvalue(y))
        if not readOK or (not secret and (x == nil or y == nil)) then
            self:ClearAllPoints()
            self:SetPoint("CENTER", nav, "CENTER")
            self:Show()
            return
        end
        local scale = 1
        pcall(function()
            scale = (nav:GetEffectiveScale() or 1) / (UIParent:GetEffectiveScale() or 1)
        end)
        local placed = pcall(function()
            self:ClearAllPoints()
            self:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x * scale, y * scale)
        end)
        if not placed then
            self:ClearAllPoints()
            self:SetPoint("CENTER", nav, "CENTER")
        end
        self:Show()
    end)
    F.diamondMark = mark
end

function F.ApplyQuestDiamond(announce)
    local name = "showInGameNavigation"
    local want = F.Enabled("questDiamond") and "1" or "0"
    local function plain(value)
        value = F.Plain(value)
        if value == true then
            return "1"
        end
        if value == false then
            return "0"
        end
        if type(value) == "number" then
            return tostring(value)
        end
        if type(value) == "string" and value ~= "" then
            return value
        end
        return nil
    end
    local function readSetting()
        if C_CVar and C_CVar.GetCVar then
            local ok, value = pcall(C_CVar.GetCVar, name)
            value = ok and plain(value)
            if value then
                return value
            end
        end
        if GetCVar then
            local ok, value = pcall(GetCVar, name)
            value = ok and plain(value)
            if value then
                return value
            end
        end
        if C_CVar and C_CVar.GetCVarBool then
            local ok, value = pcall(C_CVar.GetCVarBool, name)
            value = ok and plain(value)
            if value then
                return value
            end
        end
        if GetCVarBool then
            local ok, value = pcall(GetCVarBool, name)
            value = ok and plain(value)
            if value then
                return value
            end
        end
        return nil
    end
    local function accepted(ok, result)
        return ok and result ~= false
    end
    local function writeSetting()
        local tried = false
        if C_CVar and C_CVar.SetCVar then
            tried = accepted(pcall(C_CVar.SetCVar, name, want)) or tried
            if readSetting() == want then
                return true
            end
        end
        if SetCVar then
            tried = accepted(pcall(SetCVar, name, want)) or tried
            if readSetting() == want then
                return true
            end
        end
        if ConsoleExec and pcall(ConsoleExec, name .. " " .. want) then
            tried = true
            if readSetting() == want then
                return true
            end
        end
        local edit = DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.editBox
        if edit and ChatEdit_SendText and not (IsSecureCmd and IsSecureCmd("/console")) then
            local wasShown = edit:IsShown()
            local previous = edit:GetText() or ""
            if not wasShown then
                edit:Show()
            end
            edit:SetText("/console " .. name .. " " .. want)
            if pcall(ChatEdit_SendText, edit, 0) then
                tried = true
            end
            edit:SetText(previous)
            if not wasShown then
                edit:Hide()
            end
            if edit.ClearFocus then
                edit:ClearFocus()
            end
            if readSetting() == want then
                return true
            end
        end
        -- This client can take the console command and still refuse to tell an addon the value.
        return tried and readSetting() == nil
    end
    local wrote = readSetting() == want or writeSetting()
    if want == "1" then
        F.EnsureQuestDiamond()
    elseif F.diamondMark then
        F.diamondMark:Hide()
    end
    if not wrote then
        if announce and want ~= "1" then
            F.Say("This version of the game has no quest diamond.")
        end
        if want ~= "1" then
            return false
        end
    end
    if announce then
        F.Say(want == "1" and "Quest diamond on. Track a quest to see it in the world." or "Quest diamond off.")
    end
    return true
end

function F.ShowEnemyPlates(announce)
    if not F.Enabled("questMarks") or (InCombatLockdown and InCombatLockdown()) then
        return
    end
    local ok, current = pcall(GetCVar, "nameplateShowEnemies")
    current = ok and F.Plain(current)
    if current == nil or current == "1" then
        return
    end
    if pcall(SetCVar, "nameplateShowEnemies", "1") and announce then
        F.Say("Enemy nameplates turned on, so quest marks can show. V turns them off.")
    end
end

function F.BuildMapPage(page)
    F.SectionLabel(page, "Map", -8)
    widthSlider, widthText = F.CreateSlider(page, "Size", F.Round(MIN_SCALE * 100), F.Round(MAX_SCALE * 100), -30, function(value, valueText)
        value = F.Clamp(value, F.Round(MIN_SCALE * 100), F.Round(MAX_SCALE * 100))
        valueText:SetText(tostring(value) .. "%")
        local scale = value / 100
        if math.abs(scale - db.scale) > 0.01 then
            db.scale = scale
            F.Apply()
        end
    end)
    widthSlider:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Size", F.BorderColor())
        GameTooltip:AddLine("How big the square is. A higher resolution draws it larger, so it stays a similar size on the screen.", 1, 1, 1, true)
        GameTooltip:Show()
    end)
    widthSlider:SetScript("OnLeave", GameTooltip_Hide)

    alphaSlider, alphaText = F.CreateSlider(page, "Standing", F.Round(MIN_ALPHA * 100), 100, -78, function(value, valueText)
        value = F.Clamp(value, F.Round(MIN_ALPHA * 100), 100)
        valueText:SetText(tostring(value) .. "%")
        local alpha = value / 100
        if math.abs(alpha - db.alpha) > 0.001 then
            db.alpha = alpha
            F.Apply()
        end
    end)

    fadeCheck = CreateFrame("CheckButton", nil, page, "UICheckButtonTemplate")
    fadeCheck:SetPoint("TOPLEFT", 14, -128)
    fadeCheck:SetScript("OnClick", function(self)
        db.fadeMove = not not self:GetChecked()
        liveAlpha = db.alpha
    end)
    if fadeCheck.Text then
        fadeCheck.Text:SetText("")
        fadeCheck.Text:Hide()
    end
    local fadeLabel = page:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    fadeLabel:SetPoint("LEFT", fadeCheck, "RIGHT", 2, 0)
    fadeLabel:SetText("Fade while moving")
    fadeLabel:SetWordWrap(false)
    F.SetFontSize(fadeLabel, 16)
    fadeCheck:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Fade while moving", F.BorderColor())
        GameTooltip:AddLine("The map eases down while you move, and comes back when you stop, enter combat, or rest the cursor on it.", 1, 1, 1, true)
        GameTooltip:Show()
    end)
    fadeCheck:SetScript("OnLeave", GameTooltip_Hide)

    local fadeMin = F.Round(MIN_ALPHA * 100)
    moveSlider, moveText = F.CreateSlider(page, "Moving", fadeMin, 100, -170, function(value, valueText)
        value = F.Clamp(value, fadeMin, 100)
        valueText:SetText(tostring(value) .. "%")
        db.alphaMove = value / 100
    end, 18, -250)
    combatSlider, combatText = F.CreateSlider(page, "Combat", fadeMin, 100, -170, function(value, valueText)
        value = F.Clamp(value, fadeMin, 100)
        valueText:SetText(tostring(value) .. "%")
        db.alphaCombat = value / 100
    end, 250, -18)

    local function watchSlider(slider)
        if slider and slider.HookScript then
            slider:HookScript("OnMouseDown", function(self)
                self.nfHold = true
            end)
            slider:HookScript("OnMouseUp", function(self)
                self.nfHold = false
            end)
        end
    end
    watchSlider(alphaSlider)
    watchSlider(moveSlider)
    watchSlider(combatSlider)

    lockCheck = CreateFrame("CheckButton", nil, page, "UICheckButtonTemplate")
    lockCheck:SetPoint("TOPLEFT", 14, -214)
    lockCheck:SetScript("OnClick", function(self)
        F.SetLocked(self:GetChecked())
    end)
    if lockCheck.Text then
        lockCheck.Text:SetText("")
        lockCheck.Text:Hide()
    end
    local lockLabel = page:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    lockLabel:SetPoint("LEFT", lockCheck, "RIGHT", 2, 0)
    lockLabel:SetText("Lock position")
    lockLabel:SetWordWrap(false)
    F.SetFontSize(lockLabel, 16)

    local diamondCheck = F.CreateCheck(page, "Quest diamond", 240, -214, "questDiamond")
    diamondCheck:HookScript("OnClick", function()
        F.ApplyQuestDiamond(true)
    end)
    diamondCheck:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Quest diamond", F.BorderColor())
        GameTooltip:AddLine("The game's own yellow diamond, drawn in the world over the quest you track. It shows where to go for an objective with a set place, or where to turn the quest in. This is the same as typing /console showInGameNavigation 1.", 1, 1, 1, true)
        GameTooltip:Show()
    end)
    diamondCheck:SetScript("OnLeave", GameTooltip_Hide)

    local marksCheck = F.CreateCheck(page, "Quest marks", 14, -246, "questMarks")
    marksCheck:HookScript("OnClick", function(self)
        if F.QuestMarkSoon then
            F.QuestMarkSoon()
        end
        if self:GetChecked() then
            F.Say("Quest marks on. Creatures you still need for a quest get a gold mark on their nameplate.")
            F.ShowEnemyPlates(true)
        else
            F.Say("Quest marks off.")
        end
    end)
    marksCheck:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Quest marks", F.BorderColor())
        GameTooltip:AddLine("A pulsing gold quest icon and glow on the nameplate of a creature you still need for a quest, with your progress next to it, such as 3/8 Kobold Vermin. Enemy nameplates have to be on (V turns them on). Objects such as crates and plants can't be marked, because the game doesn't let addons draw on them.", 1, 1, 1, true)
        GameTooltip:Show()
    end)
    marksCheck:SetScript("OnLeave", GameTooltip_Hide)

    F.SectionLabel(page, "Arrow", -286)
    arrowSlider, arrowText = F.CreateSlider(page, "Arrow size", ARROW_MIN, ARROW_MAX, -308, function(value, valueText)
        value = F.Clamp(value, ARROW_MIN, ARROW_MAX)
        valueText:SetText(tostring(value) .. "%")
        F.SetArrowScale(value)
    end)
    return page
end

function F.BuildRingsPage(page)
    F.SectionLabel(page, "Range rings", -8)
    local ringCheck = F.CreateCheck(page, "Show rings", 14, -30, "rings")
    ringCheck:HookScript("OnClick", function()
        F.UpdateRangeRings()
    end)
    ringCheck:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Range rings", F.BorderColor())
        GameTooltip:AddLine("Circles around you on the minimap. Useful for pulls, ranged attacks, fears, and area spells. A ring hides while you are zoomed in past its distance.", 1, 1, 1, true)
        GameTooltip:Show()
    end)
    ringCheck:SetScript("OnLeave", GameTooltip_Hide)
    F.CreateRingRow(page, 1, -66)
    F.CreateRingRow(page, 2, -102)
    F.CreateRingRow(page, 3, -138)
    return page
end

function F.BuildMessagesPage(page)
    F.SectionLabel(page, "Messages", -8)
    F.CreateCheck(page, "Pin dropped", 14, -30, "warnPin")
    F.CreateCheck(page, "Danger areas", 240, -30, "warnDanger")
    F.CreateCheck(page, "Murloc areas", 14, -58, "warnMurloc")
    F.CreateCheck(page, "PvP zones", 240, -58, "warnPvp")
    F.CreateCheck(page, "Sanctuary cities", 14, -86, "warnSanctuary")
    F.CreateCheck(page, "Dungeons and raids", 240, -86, "warnInstance")
    F.CreateCheck(page, "Elite areas", 14, -114, "warnElite")
    F.CreateCheck(page, "World bosses", 240, -114, "warnBoss")
    F.CreateCheck(page, "Rain", 14, -142, "warnWeather")
    local questCheck = F.CreateCheck(page, "Quest items", 240, -142, "warnQuest")
    questCheck:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Quest items", F.BorderColor())
        GameTooltip:AddLine("Chat counts quest drops as they come in. 1/10 Bear Hearts, then 2/10, up to the last one. Uncheck this to turn those lines off.", 1, 1, 1, true)
        GameTooltip:Show()
    end)
    questCheck:SetScript("OnLeave", GameTooltip_Hide)
    local arriveCheck = F.CreateCheck(page, "Arrival", 14, -170, "warnArrive")
    arriveCheck:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Arrival", F.BorderColor())
        GameTooltip:AddLine("One chat line when you get within 20 yards of the pin, and when a flight lands. The bar counts down that flight. A pin stays quiet until you walk off and come back. A saved pin uses its name.", 1, 1, 1, true)
        GameTooltip:Show()
    end)
    arriveCheck:SetScript("OnLeave", GameTooltip_Hide)
    local repairCheck = F.CreateCheck(page, "Repair", 240, -170, "warnRepair")
    repairCheck:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Repair", F.BorderColor())
        GameTooltip:AddLine("When your gear is yellow or red, one chat line names a town that can repair it. It stays quiet until you leave that place. Uncheck this to turn the line off.", 1, 1, 1, true)
        GameTooltip:Show()
    end)
    repairCheck:SetScript("OnLeave", GameTooltip_Hide)
    local campfireCheck = F.CreateCheck(page, "Campfire alert", 14, -198, "warnCampfire")
    campfireCheck:HookScript("OnClick", function(self)
        F.campfireOn = false
        if self:GetChecked() and F.WarnCampfire then
            F.WarnCampfire()
        end
    end)
    campfireCheck:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Campfire alert", F.BorderColor())
        GameTooltip:AddLine("Uncheck this to turn off the chat line and the sound. After one alert it stays quiet for 8 minutes, so a fire left in a quest area does not keep announcing itself. The list beside it picks the noise. With cooking, and raw fish or meat in the bag, the line names what can go on the fire.", 1, 1, 1, true)
        GameTooltip:Show()
    end)
    campfireCheck:SetScript("OnLeave", GameTooltip_Hide)
    F.CreateCampfireSounds(page, 220, -198)
    local rareCheck = F.CreateCheck(page, "Rares nearby", 14, -226, "warnRare")
    rareCheck:HookScript("OnClick", function()
        if F.rare then
            F.rare.known = nil
            F.rare.names = nil
        end
    end)
    rareCheck:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Rares nearby", F.BorderColor())
        GameTooltip:AddLine("A chat line and a sound when a rare is close enough for a nameplate, or when a rare mark is on the minimap. The same one stays quiet until you leave and it is gone. Uncheck this to turn it off.", 1, 1, 1, true)
        GameTooltip:Show()
    end)
    rareCheck:SetScript("OnLeave", GameTooltip_Hide)
    return page
end

function F.BuildMorePage(page)
    F.SectionLabel(page, "Colors", -8)
    F.CreateThemePicker(page, -30)
    local animateCheck = F.CreateCheck(page, "Animations", 90, -28, "animate")
    animateCheck:HookScript("OnClick", F.RefreshAnimations)
    animateCheck:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Animations", F.BorderColor())
        GameTooltip:AddLine("Drifting mist, a pulsing border, a flickering flame behind the logo, and particles such as embers or snow, for themes that have them. They rest while the map is faded and in combat. Uncheck this to keep everything still.", 1, 1, 1, true)
        GameTooltip:Show()
    end)
    animateCheck:SetScript("OnLeave", GameTooltip_Hide)
    F.CreateColorRow(page, "Menu color", -64, "menuColor", NAVY_R, NAVY_G, NAVY_B)
    F.CreateColorRow(page, "Border color", -94, "borderColor", GOLD_R, GOLD_G, GOLD_B)

    F.SectionLabel(page, "Death", -138)
    local deathCheck = F.CreateCheck(page, "Death marker", 14, -160, "deathMarker")
    deathCheck:HookScript("OnClick", function()
        F.UpdateNav()
        F.SyncArrow()
    end)
    local spiritCheck = F.CreateCheck(page, "Clear at spirit healer", 14, -188, "deathSpirit")
    spiritCheck:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Clear at spirit healer", F.BorderColor())
        GameTooltip:AddLine("Remove the skull when you resurrect at a spirit healer. Leave this off to keep the marker and walk back to where you died.", 1, 1, 1, true)
        GameTooltip:Show()
    end)
    spiritCheck:SetScript("OnLeave", GameTooltip_Hide)

    F.SectionLabel(page, "Gathering", -232)
    local gatherCheck = F.CreateCheck(page, "Swap herbs and ore", 14, -254, "gatherSwap")
    gatherCheck:HookScript("OnClick", function(self)
        F.SetGatherEnabled(self:GetChecked(), true)
    end)
    gatherCheck:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Swap herbs and ore", F.BorderColor())
        GameTooltip:AddLine("WoW Forever shows one of these at a time. This turns Find Herbs and Find Minerals on in turn, so both kinds of node show up as you move. It only does that when you have both Herbalism and Mining. With one of them, tracking stays as you set it. It waits while you fight, cast, loot, or stand in a city, and it leaves tracking alone when you pick something else. After you resurrect, Find Herbs or Find Minerals turns back on.", 1, 1, 1, true)
        GameTooltip:Show()
    end)
    gatherCheck:SetScript("OnLeave", GameTooltip_Hide)
    F.gatherSlider, F.gatherText = F.CreateSlider(page, "Every", 2, 12, -254, function(value, valueText)
        value = F.Clamp(value, 2, 12)
        valueText:SetText(tostring(value) .. " s")
        db.gatherSeconds = value
        if F.gather then
            F.gather.next = nil
        end
    end, 250, -18)
    F.gatherSlider:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Time on each", F.BorderColor())
        GameTooltip:AddLine("How long Find Herbs or Find Minerals stays on before the other takes a turn.", 1, 1, 1, true)
        GameTooltip:Show()
    end)
    F.gatherSlider:SetScript("OnLeave", GameTooltip_Hide)
    return page
end

function F.CreateOptions()
    if panel then
        return
    end

    panel = CreateFrame("Frame", "NavigateForeverOptions", UIParent)
    panel:SetSize(480, 540)
    panel:SetPoint("CENTER")
    panel:SetFrameStrata("DIALOG")
    panel:SetClampedToScreen(true)
    panel:SetMovable(true)
    panel:EnableMouse(true)
    panel:RegisterForDrag("LeftButton")
    panel:SetScript("OnDragStart", panel.StartMoving)
    panel:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        self.nfPlaced = true
    end)
    F.PaintPanel(panel, 0.96)
    panel:Hide()
    tinsert(UISpecialFrames, "NavigateForeverOptions")

    local brand = F.BrandIcon(panel:CreateTexture(nil, "ARTWORK"))
    brand:SetSize(42, 42)
    brand:SetPoint("TOPLEFT", 16, -14)

    F.CreateCorners(panel, 96)
    F.AddParticles(panel, 22)

    local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", brand, "TOPRIGHT", 10, -2)
    title:SetText("Navigate Forever")
    F.SetFontSize(title, 22)
    local br, bgc, bb = F.BorderColor()
    title:SetTextColor(br, bgc, bb)
    table.insert(accentText, title)

    local subtitle = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -2)
    subtitle:SetText("Navigate Azeroth Your Way")
    subtitle:SetWordWrap(false)
    F.SetFontSize(subtitle, 15)
    subtitle:SetTextColor(F.ThemeColor("hover"))
    panel.nfSubtitle = subtitle

    local divider = panel:CreateTexture(nil, "ARTWORK")
    divider:SetColorTexture(br, bgc, bb, 0.85)
    panel.nfDivider = divider
    divider:SetPoint("TOPLEFT", 16, -66)
    divider:SetPoint("TOPRIGHT", -16, -66)
    divider:SetHeight(1)

    local tabLine = panel:CreateTexture(nil, "ARTWORK")
    tabLine:SetColorTexture(br, bgc, bb, 0.85)
    panel.nfTabLine = tabLine
    tabLine:SetPoint("TOPLEFT", 16, -101)
    tabLine:SetPoint("TOPRIGHT", -16, -101)
    tabLine:SetHeight(1)

    F.optionTabs = {}
    F.optionPages = {
        map = F.BuildMapPage(F.CreateOptionsPage()),
        rings = F.BuildRingsPage(F.CreateOptionsPage()),
        messages = F.BuildMessagesPage(F.CreateOptionsPage()),
        more = F.BuildMorePage(F.CreateOptionsPage()),
    }
    F.OptionsTab("Map", "Size, opacity, lock, the direction arrow, the quest diamond, and quest marks.", 16, "map")
    F.OptionsTab("Rings", "The circles around you, and how far out they sit.", 130, "rings")
    F.OptionsTab("Messages", "Chat notes for pins, areas, rares, campfires, and quest items.", 244, "messages")
    F.OptionsTab("More", "Theme, colors, the death marker, and gathering.", 358, "more")
    F.ShowOptionsPage("map")

    local hint = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    hint:SetPoint("BOTTOMLEFT", 20, 46)
    hint:SetPoint("BOTTOMRIGHT", -20, 46)
    hint:SetJustifyH("CENTER")
    hint:SetTextColor(0.75, 0.75, 0.75)
    hint:SetText("Ctrl-click the world map to drop a pin. Hold Right Alt and drag to move the minimap.")
    F.SetFontSize(hint, 15)

    local reset = F.Chip(panel, "Reset", 88, 16)
    reset:SetHeight(26)
    reset:SetPoint("BOTTOMLEFT", 16, 14)
    reset:SetScript("OnClick", F.ResetSettings)

    local close = F.Chip(panel, "Close", 88, 16)
    close:SetHeight(26)
    close:SetPoint("BOTTOMRIGHT", -16, 14)
    close:SetScript("OnClick", function()
        panel:Hide()
    end)

    panel:SetScript("OnShow", function()
        F.PlaceOptions()
        F.SyncOptions()
    end)
    F.PlaceOptions()
    F.RegisterGameOptions()
    F.ApplyColors()
end

function F.CreateChrome()
    header = CreateFrame("Frame", "NavigateForeverHeader", cluster)
    header:EnableMouse(false)
    local headerTex = header:CreateTexture(nil, "BACKGROUND")
    headerTex:SetAllPoints()
    local mr, mg, mb = F.MenuColor()
    headerTex:SetColorTexture(mr, mg, mb, 0.78)
    header.nfTex = headerTex

    border = CreateFrame("Frame", "NavigateForeverBorder", cluster, "BackdropTemplate")
    border:EnableMouse(false)
    border:SetBackdrop({
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
    })
    border:SetBackdropBorderColor(F.BorderColor())

    grip = CreateFrame("Button", "NavigateForeverGrip", cluster)
    grip:SetSize(18, 18)
    grip:SetPoint("BOTTOMRIGHT", cluster, "BOTTOMRIGHT", -2, 2)
    local gripAcross = grip:CreateTexture(nil, "ARTWORK")
    grip.across = gripAcross
    local br, bgc, bb = F.BorderColor()
    gripAcross:SetColorTexture(br, bgc, bb, 1)
    gripAcross:SetPoint("BOTTOMLEFT", 0, 0)
    gripAcross:SetPoint("BOTTOMRIGHT", 0, 0)
    gripAcross:SetHeight(3)
    local gripDown = grip:CreateTexture(nil, "ARTWORK")
    grip.down = gripDown
    gripDown:SetColorTexture(br, bgc, bb, 1)
    gripDown:SetPoint("TOPRIGHT", 0, 0)
    gripDown:SetPoint("BOTTOMRIGHT", 0, 0)
    gripDown:SetWidth(3)
    grip:SetScript("OnMouseDown", function(_, button)
        if button == "LeftButton" then
            F.BeginSize()
        end
    end)
    grip:SetScript("OnMouseUp", function(_, button)
        if button == "LeftButton" then
            F.FinishSize()
        end
    end)
    local function MakeGoldEdge()
        local edge = CreateFrame("Frame", nil, UIParent)
        edge:SetFrameStrata("LOW")
        edge:SetFrameLevel(1)
        edge:EnableMouse(false)
        local tex = edge:CreateTexture(nil, "ARTWORK")
        local br, bgc, bb = F.BorderColor()
        tex:SetColorTexture(br, bgc, bb, 1)
        tex:SetAllPoints()
        edge.tex = tex
        edge:Hide()
        return edge
    end
    goldEdges = {
        top = MakeGoldEdge(),
        bottom = MakeGoldEdge(),
        left = MakeGoldEdge(),
        right = MakeGoldEdge(),
    }

    dock = CreateFrame("Button", "NavigateForeverDock", UIParent)
    dock:SetSize(58, 28)
    dock:SetFrameStrata("TOOLTIP")
    dock:SetFrameLevel(500)
    dock:SetMovable(true)
    dock:SetClampedToScreen(true)
    dock:EnableMouse(true)
    dock:RegisterForDrag("LeftButton")
    dock:RegisterForClicks("LeftButtonUp")
    F.PaintPanel(dock, 0.96)
    local brandIcon = F.BrandIcon(dock:CreateTexture(nil, "ARTWORK"))
    brandIcon:SetSize(22, 22)
    brandIcon:SetPoint("LEFT", 3, 0)
    brandButton = dock

    popButton = CreateFrame("Button", "NavigateForeverPop", dock)
    popButton:SetSize(22, 22)
    popButton:SetPoint("RIGHT", -3, 0)
    F.PaintPanel(popButton, 1)
    for _, offset in ipairs({ 5, 0, -5 }) do
        local mark = popButton:CreateTexture(nil, "OVERLAY")
        mark:SetColorTexture(F.BorderColor())
        mark:SetSize(12, 2)
        table.insert(themedMarks, mark)
        mark:SetPoint("CENTER", 0, offset)
    end
    popButton:SetScript("OnClick", function()
        bagOpen = not bagOpen
        F.CollectAddonButtons()
    end)
    popButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Addon buttons")
        GameTooltip:AddLine("Open or close the list.", 1, 0.96, 0.82)
        GameTooltip:Show()
    end)
    popButton:SetScript("OnLeave", GameTooltip_Hide)
    popButton:RegisterForDrag("LeftButton")
    popButton:SetScript("OnDragStart", function()
        dock.dragging = true
        dock:StartMoving()
    end)
    popButton:SetScript("OnDragStop", function()
        dock:StopMovingOrSizing()
        dock.dragging = false
        local point, _, relPoint, x, y = dock:GetPoint(1)
        if point and db then
            db.dockPoint = point
            db.dockRelPoint = relPoint
            db.dockX = x
            db.dockY = y
            dock.placed = true
        end
    end)

    buttonBag = CreateFrame("Frame", "NavigateForeverButtonBag", UIParent)
    buttonBag:SetFrameStrata("TOOLTIP")
    buttonBag:SetFrameLevel(490)
    F.PaintPanel(buttonBag, 0.96)
    buttonBag:Hide()

    dock:SetScript("OnClick", function()
        if not panel then
            return
        end
        if panel:IsShown() then
            panel:Hide()
        else
            panel:Show()
        end
    end)
    dock:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Navigate Forever")
        GameTooltip:AddLine("Drag to move. Click for settings.", 1, 0.96, 0.82)
        GameTooltip:Show()
    end)
    dock:SetScript("OnLeave", GameTooltip_Hide)
    dock:SetScript("OnDragStart", function(self)
        self.dragging = true
        self:StartMoving()
    end)
    dock:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        self.dragging = false
        local point, _, relPoint, x, y = self:GetPoint(1)
        if point and db then
            db.dockPoint = point
            db.dockRelPoint = relPoint
            db.dockX = x
            db.dockY = y
            self.placed = true
        end
    end)
    dock:Hide()

    grip:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Size", F.BorderColor())
        GameTooltip:AddLine("Drag to make the square minimap bigger or smaller.", 1, 1, 1, true)
        GameTooltip:Show()
    end)
    grip:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
end

function F.DumpButtons()
    if not cluster then
        F.Say("Minimap is not available yet.")
        return
    end
    F.Say(string.format(
        "size %d%%, opacity %d%%, %s",
        F.Round(db.scale * 100),
        F.Round(db.alpha * 100),
        db.locked and "locked" or "unlocked"
    ))

    local function DumpChildren(frame, label)
        F.Say(label)
        local children = { frame:GetChildren() }
        for index = 1, #children do
            local child = children[index]
            local name = F.FrameLabel(child)
            if not string.find(name, "NavigateForever", 1, true) then
                F.Say(string.format(
                    "  %s shown=%s %.0fx%.0f",
                    name,
                    child:IsShown() and "yes" or "no",
                    child:GetWidth() or 0,
                    child:GetHeight() or 0
                ))
            end
        end
    end

    DumpChildren(cluster, "MinimapCluster:")
    if container and container ~= cluster then
        DumpChildren(container, "MinimapContainer:")
    end
end

function F.ParseAlpha(text)
    local value = tonumber(text)
    if not value then
        return nil
    end
    if value > 1 then
        value = value / 100
    end
    return F.Clamp(value, MIN_ALPHA, 1)
end

-- WoW Forever keeps one tracking spell at a time. Find Herbs and Find Minerals
-- take turns through the same call the tracking menu uses.
function F.GatherWait()
    return F.Clamp(F.Round(tonumber(db and db.gatherSeconds) or 4), 2, 12)
end

function F.GatherUnmute()
    local state = F.gather
    local flagged = (state and state.muted) or (db and db.gatherUnmute)
    if not flagged then
        return
    end
    pcall(SetCVar, "Sound_EnableSFX", "1")
    if state then
        state.muted = nil
    end
    if db then
        db.gatherUnmute = nil
    end
end

function F.GatherMute()
    local state = F.gather
    if not state or state.muted or not db then
        return
    end
    local ok, value = pcall(GetCVar, "Sound_EnableSFX")
    if not ok or tostring(value) ~= "1" then
        return
    end
    if pcall(SetCVar, "Sound_EnableSFX", "0") then
        state.muted = GetTime()
        db.gatherUnmute = true
    end
end

function F.GatherScan()
    local found = {}
    if not (C_Minimap and C_Minimap.GetNumTrackingTypes and C_Minimap.GetTrackingInfo) then
        return found
    end
    local ok, count = pcall(C_Minimap.GetNumTrackingTypes)
    if not ok or type(count) ~= "number" then
        return found
    end
    for index = 1, count do
        local infoOk, info = pcall(C_Minimap.GetTrackingInfo, index)
        if infoOk and type(info) == "table" and (info.spellID or info.type == "spell") then
            local spell = tonumber(info.spellID)
            local name = info.name
            local treasure = spell == 2481 or name == "Find Treasure"
            local slot = {
                index = index,
                active = info.active and true or false,
            }
            if spell == 2383 or name == "Find Herbs" then
                found.herbs = found.herbs or slot
            elseif spell == 2580 or name == "Find Minerals" then
                found.ore = found.ore or slot
            elseif info.active and not treasure then
                found.other = found.other or name or "another tracker"
            end
        end
    end
    return found
end

function F.GatherApply(slot, key)
    local state = F.gather
    if not slot or not state or not C_Minimap or not C_Minimap.SetTracking then
        return
    end
    F.GatherMute()
    state.want = key
    state.wantUntil = GetTime() + 1
    pcall(C_Minimap.SetTracking, slot.index, true)
end

function F.SetGatherEnabled(enabled, announce)
    if not db then
        return
    end
    db.gatherSwap = not not enabled
    F.gather = F.gather or {}
    local state = F.gather
    if db.gatherSwap then
        state.held = false
        state.blocked = false
        state.fails = 0
        state.want = nil
        state.next = nil
        state.left = 0
    else
        F.GatherUnmute()
    end
    if optionChecks.gatherSwap then
        optionChecks.gatherSwap:SetChecked(db.gatherSwap)
    end
    if not announce then
        return
    end
    if not db.gatherSwap then
        F.Say("Gathering swap is off.")
        return
    end
    local found = F.GatherScan()
    if not found.herbs or not found.ore then
        F.Say("Gathering swap is on. It starts when this character has both Herbalism and Mining.")
        return
    end
    if found.other then
        F.Say("Gathering swap is on. It waits while you are tracking " .. found.other .. ".")
        return
    end
    F.Say("Gathering swap is on. Herbs and ore take turns every " .. F.GatherWait() .. " seconds.")
end

function F.GatherOwns(key)
    local spell = key == "ore" and 2580 or 2383
    local known = F.GatherSpellKnown(spell)
    if known ~= nil then
        return known
    end
    if key == "ore" then
        return F.GatherProfession(186, "Mining")
    end
    return F.GatherProfession(182, "Herbalism")
end

function F.GatherNoteLive(found)
    local state = F.gather
    if not state or not found or state.death or state.resume then
        return
    end
    if found.herbs and found.herbs.active then
        state.live = "herbs"
    elseif found.ore and found.ore.active then
        state.live = "ore"
    elseif found.other then
        state.live = false
    end
end

function F.GatherOnTracking()
    local state = F.gather
    if not state or not db then
        return
    end
    local found = F.GatherScan()
    F.GatherNoteLive(found)
    if state.want or state.resume or db.gatherSwap == false then
        return
    end
    if found.other then
        state.held = true
        state.next = nil
        state.seen = nil
        return
    end
    local active
    if found.herbs and found.herbs.active then
        active = "herbs"
    elseif found.ore and found.ore.active then
        active = "ore"
    end
    if active then
        state.held = false
        if state.seen ~= active then
            state.seen = active
            state.next = GetTime() + F.GatherWait()
        end
        return
    end
    state.seen = nil
    if not state.death then
        state.held = true
        state.next = nil
    end
end

function F.GatherOnDead()
    local state = F.gather or {}
    F.gather = state
    state.death = true
    state.resume = nil
    local found = F.GatherScan()
    if found.herbs and found.herbs.active then
        state.remember = "herbs"
        state.live = "herbs"
    elseif found.ore and found.ore.active then
        state.remember = "ore"
        state.live = "ore"
    elseif found.other then
        state.remember = false
        state.live = false
    elseif state.live == "herbs" or state.live == "ore" or state.live == false then
        state.remember = state.live
    else
        state.remember = "auto"
    end
end

function F.GatherOnAlive()
    local state = F.gather
    if not state or not state.death or UnitIsDeadOrGhost("player") then
        return
    end
    state.death = false
    local remember = state.remember
    state.remember = nil
    if remember == false or not db then
        state.held = true
        state.resume = nil
        return
    end
    local herbs = F.GatherOwns("herbs")
    local ore = F.GatherOwns("ore")
    if herbs == false and ore == false then
        state.held = true
        state.resume = nil
        return
    end
    local key
    if remember == "herbs" and herbs ~= false then
        key = "herbs"
    elseif remember == "ore" and ore ~= false then
        key = "ore"
    elseif herbs == true and ore ~= true then
        key = "herbs"
    elseif ore == true and herbs ~= true then
        key = "ore"
    elseif herbs == true or ore == true then
        key = herbs == true and "herbs" or "ore"
    elseif remember == "ore" then
        key = "ore"
    else
        key = "herbs"
    end
    state.held = false
    state.fails = 0
    state.resume = true
    state.prefer = key
    state.want = nil
    state.next = GetTime()
    state.left = 0
    state.resumeUntil = GetTime() + 10
end

function F.GatherRestoreBusy()
    if UnitIsDeadOrGhost("player") or UnitAffectingCombat("player") or InCombatLockdown() or UnitOnTaxi("player") then
        return true
    end
    local casting = false
    pcall(function()
        casting = (UnitCastingInfo and UnitCastingInfo("player")) or (UnitChannelInfo and UnitChannelInfo("player"))
    end)
    if casting then
        return true
    end
    if LootFrame and LootFrame.IsShown and LootFrame:IsShown() then
        return true
    end
    return false
end

function F.GatherResume()
    local state = F.gather
    if not state or not state.resume then
        return
    end
    local found = F.GatherScan()
    local first = state.prefer == "ore" and "ore" or "herbs"
    local second = first == "ore" and "herbs" or "ore"
    local function try(key)
        if F.GatherOwns(key) == false then
            return false
        end
        local slot = found[key]
        if not slot then
            return false
        end
        if slot.active then
            state.resume = false
            state.prefer = nil
            state.want = nil
            state.held = false
            state.seen = key
            state.live = key
            state.fails = 0
            state.next = GetTime() + F.GatherWait()
            return true
        end
        if state.want == key and GetTime() < (state.wantUntil or 0) then
            return true
        end
        if state.want == key then
            state.want = nil
            F.GatherUnmute()
        end
        state.held = false
        F.GatherApply(slot, key)
        return true
    end
    if try(first) or try(second) then
        return
    end
end

function F.GatherOnBlocked(name)
    local state = F.gather
    if name and addonName and name ~= addonName then
        return
    end
    if not state or not state.want then
        return
    end
    state.blocked = true
    state.want = nil
    F.GatherUnmute()
    F.Say("The game blocked the gathering swap. /reload tries again. /nf gather off leaves tracking as you set it.")
end

function F.GatherBusy()
    if UnitIsDeadOrGhost("player") or UnitAffectingCombat("player") or InCombatLockdown() or UnitOnTaxi("player") then
        return true
    end
    if IsResting() then
        return true
    end
    if UIDROPDOWNMENU_OPEN_MENU then
        return true
    end
    local casting = false
    pcall(function()
        casting = (UnitCastingInfo and UnitCastingInfo("player")) or (UnitChannelInfo and UnitChannelInfo("player"))
    end)
    if casting then
        return true
    end
    if LootFrame and LootFrame.IsShown and LootFrame:IsShown() then
        return true
    end
    return false
end

function F.GatherSpellKnown(spellID)
    if IsPlayerSpell then
        local ok, known = pcall(IsPlayerSpell, spellID)
        if ok then
            return not not known
        end
    end
    if IsSpellKnown then
        local ok, known = pcall(IsSpellKnown, spellID, false)
        if ok then
            return not not known
        end
    end
    if C_SpellBook and C_SpellBook.IsSpellInSpellBook then
        local ok, known = pcall(C_SpellBook.IsSpellInSpellBook, spellID)
        if ok then
            return not not known
        end
    end
    return nil
end

function F.GatherProfession(skillLine, professionName)
    if not GetProfessions or not GetProfessionInfo then
        return nil
    end
    local first, second, third, fourth, fifth = GetProfessions()
    local saw = false
    local function holds(slot)
        if not slot then
            return false
        end
        local ok, name, _, _, _, _, _, line = pcall(GetProfessionInfo, slot)
        if not ok then
            return false
        end
        saw = true
        return line == skillLine or name == professionName
    end
    if holds(first) or holds(second) or holds(third) or holds(fourth) or holds(fifth) then
        return true
    end
    if not saw then
        return nil
    end
    return false
end

function F.GatherHasBoth()
    local herbsSpell = F.GatherSpellKnown(2383)
    local oreSpell = F.GatherSpellKnown(2580)
    if herbsSpell == false or oreSpell == false then
        return false
    end
    local herbsProf = F.GatherProfession(182, "Herbalism")
    local oreProf = F.GatherProfession(186, "Mining")
    if herbsProf == false or oreProf == false then
        return false
    end
    if herbsSpell == nil and oreSpell == nil and herbsProf == nil and oreProf == nil then
        return nil
    end
    return true
end

function F.GatherStep()
    local state = F.gather
    if not F.gatherReady or not state or not db then
        return
    end
    if state.death and not UnitIsDeadOrGhost("player") then
        F.GatherOnAlive()
    end
    if state.resume then
        if F.GatherRestoreBusy() then
            return
        end
        if GetTime() > (state.resumeUntil or 0) then
            state.resume = false
            state.prefer = nil
            if state.want then
                state.want = nil
                F.GatherUnmute()
            end
        else
            F.GatherResume()
        end
        return
    end
    if db.gatherSwap == false or state.blocked then
        if not UnitIsDeadOrGhost("player") then
            F.GatherNoteLive(F.GatherScan())
        end
        return
    end
    if F.GatherBusy() then
        return
    end
    local found = F.GatherScan()
    F.GatherNoteLive(found)
    if F.GatherHasBoth() == false or not found.herbs or not found.ore then
        if state.want then
            state.want = nil
            F.GatherUnmute()
        end
        return
    end
    if state.want then
        local slot = found[state.want]
        if slot and slot.active then
            state.seen = state.want
            state.want = nil
            state.fails = 0
            state.next = GetTime() + F.GatherWait()
            return
        end
        if GetTime() < (state.wantUntil or 0) then
            return
        end
        state.want = nil
        state.fails = (state.fails or 0) + 1
        F.GatherUnmute()
        state.next = GetTime() + F.GatherWait()
        if state.fails >= 3 then
            state.blocked = true
            F.Say("The gathering swap did not take. /reload tries again. /nf gather off leaves tracking as you set it.")
        end
        return
    end
    if found.other then
        state.held = true
        return
    end
    local active
    if found.herbs.active then
        active = "herbs"
    elseif found.ore.active then
        active = "ore"
    end
    if active then
        state.held = false
    elseif state.held and not state.resume then
        return
    end
    local now = GetTime()
    if not state.next then
        if active then
            state.next = now + F.GatherWait()
            return
        end
    elseif now < state.next then
        return
    end
    local key = state.prefer
    state.prefer = nil
    state.resume = false
    if key ~= "herbs" and key ~= "ore" then
        if active == "herbs" then
            key = "ore"
        else
            key = "herbs"
        end
    end
    F.GatherApply(found[key], key)
end

function F.GatherTick(elapsed)
    F.gather = F.gather or {}
    local state = F.gather
    if state.muted and GetTime() - state.muted >= 0.4 then
        F.GatherUnmute()
    end
    if not db then
        return
    end
    state.left = (state.left or 0) - (elapsed or 0)
    if state.left > 0 then
        return
    end
    state.left = 0.25
    F.GatherStep()
end

function F.TellJoke()
    local jokes = F.JOKES
    local count = jokes and #jokes or 0
    if count < 1 then
        F.Say("Estimated arrival: eventually.")
        return
    end
    local pick = math.random(count)
    if pick == F.jokeLast and count > 1 then
        pick = (pick % count) + 1
    end
    F.jokeLast = pick
    F.Say(jokes[pick])
end

function F.SlashCommand(message)
    if not db then
        F.Say("Still loading.")
        return
    end
    local text = string.gsub(message or "", "^%s+", "")
    text = string.gsub(text, "%s+$", "")
    local command, rest = string.match(text, "^(%S*)%s*(.-)$")
    command = string.lower(command or "")

    if command == "" then
        F.ToggleOptions()
    elseif command == "lock" then
        local mode = string.lower(rest or "")
        if mode == "on" then
            F.SetLocked(true)
        elseif mode == "off" then
            F.SetLocked(false)
        else
            F.SetLocked(not db.locked)
        end
    elseif command == "unlock" then
        F.SetLocked(false)
    elseif command == "reset" then
        F.ResetSettings()
    elseif command == "clear" then
        F.ClearActivePin()
    elseif command == "pin" then
        local sub, extra = string.match(rest or "", "^(%S*)%s*(.-)$")
        sub = string.lower(sub or "")
        if sub == "" then
            F.Say("Usage: /nf pin bank, /nf go bank, /nf pins, /nf pin forget bank.")
        elseif sub == "list" then
            F.ListPins()
        elseif sub == "forget" then
            F.ForgetPin(extra)
        else
            F.SavePin(rest)
        end
    elseif command == "go" then
        F.GoPin(rest)
    elseif command == "find" or command == "where" then
        if F.FindPlace then
            F.FindPlace(rest)
        end
    elseif command == "mail" or command == "inn" or command == "repair" or command == "vendor" or command == "flight" or command == "fly" then
        if F.GoNearest then
            F.GoNearest(command == "fly" and "flight" or command)
        end
    elseif command == "pins" then
        F.ListPins()
    elseif command == "marks" then
        if F.QuestMarkReport then
            F.QuestMarkReport()
        end
    elseif command == "death" then
        if F.DeathPoint() then
            F.ClearDeath()
            F.UpdateNav()
            F.SyncArrow()
            F.Say("Death marker cleared.")
        else
            F.Say("No death marker.")
        end
    elseif command == "alpha" then
        local alpha = F.ParseAlpha(rest)
        if not alpha then
            F.Say("Usage: /nf alpha 80")
            return
        end
        db.alpha = alpha
        F.Apply()
        F.Say("Opacity set to " .. Round(alpha * 100) .. "%.")
    elseif command == "size" then
        local value = tonumber(rest)
        if not value then
            F.Say("Usage: /nf size 150")
            return
        end
        if value <= MAX_SCALE then
            value = value * 100
        end
        db.scale = F.Clamp(value / 100, MIN_SCALE, MAX_SCALE)
        F.Apply()
        F.Say("Size set to " .. Round(db.scale * 100) .. "%.")
    elseif command == "joke" then
        F.TellJoke()
    elseif command == "buttons" then
        F.DumpButtons()
    elseif command == "gather" then
        local mode = string.lower(rest or "")
        local seconds = tonumber(mode)
        if mode == "on" then
            F.SetGatherEnabled(true, true)
        elseif mode == "off" then
            F.SetGatherEnabled(false, true)
        elseif seconds then
            db.gatherSeconds = F.Clamp(F.Round(seconds), 2, 12)
            if F.gather then
                F.gather.next = nil
            end
            F.SyncOptions()
            F.Say("Herbs and ore swap every " .. db.gatherSeconds .. " seconds.")
        elseif mode == "" then
            F.SetGatherEnabled(db.gatherSwap == false, true)
        else
            F.Say("Usage: /nf gather, /nf gather on, /nf gather off, or /nf gather 4.")
        end
    else
        F.Say("Commands: /nf opens options. Also /nf lock, /nf unlock, /nf reset, /nf clear, /nf death, /nf gather, /nf joke, /nf pin bank, /nf go bank, /nf find goldshire, /nf mail, /nf inn, /nf repair, /nf vendor, /nf flight, /nf alpha 80, /nf size 150.")
    end
end

function F.Setup()
    if didSetup then
        return cluster ~= nil
    end
    cluster, container, map = F.MapWidgets()
    if not cluster or not map then
        return false
    end
    if not container then
        container = CreateFrame("Frame", "NavigateForeverClip", cluster)
        if container.SetClipsChildren then
            container:SetClipsChildren(true)
        end
    end
    F.CreateChrome()
    F.CreateNav()
    F.CreateOptions()
    F.HookCircularEdge()
    F.HookBlobs()
    F.HookCluster()
    F.HookMapMouse()
    F.HookWorldMap()
    didSetup = true
    return true
end

function F.TryApply()
    if not F.Setup() then
        if not missingWarned and db then
            missingWarned = true
            F.Say("MinimapCluster was not found. This addon needs the WoW Forever client.")
        end
        return
    end
    if not stock.captured and not F.CaptureStock() then
        return
    end
    if F.IsHybrid() then
        if not hybrid then
            F.Restore()
        end
        return
    end
    hybrid = false
    F.Apply()
end

function F.Greet()
    if greeted or not db then
        return
    end
    greeted = true
    local quip = QUIPS[math.random(#QUIPS)]
    F.Say("loaded. " .. quip)
    if db.hintShown ~= 8 then
        db.hintShown = 8
        F.Say("Ctrl-click the world map to drop a pin. Hold Right Alt and drag to move the minimap.")
    end
end

driver = CreateFrame("Frame", "NavigateForeverDriver", UIParent)
driver:SetSize(1, 1)
driver:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 0, 0)
driver:EnableMouse(false)
driver:Show()

local hybridTimer = 0
local navTimer = 0
local bagTimer = 0
driver:SetScript("OnUpdate", function(_, elapsed)
    F.GatherTick(elapsed)
    if F.RareTick then
        F.RareTick(elapsed)
    end
    if F.QuestMarkTick then
        F.QuestMarkTick(elapsed)
    end
    F.NoteGhost()
    if wasGhost then
        F.MaybeArrive()
    end
    if sizing then
        if not IsMouseButtonDown("LeftButton") then
            F.FinishSize()
        else
            F.UpdateSizeFromCursor()
        end
    elseif dragging then
        if not IsMouseButtonDown("LeftButton") then
            F.StopDrag()
        end
    end

    if ready and not hybrid then
        F.UpdateFade(elapsed)
        local ok, err = pcall(F.LayoutNav)
        if not ok and not F.layoutErrorShown then
            F.layoutErrorShown = true
            F.Say("The bar could not lay out. " .. tostring(err))
        end
    end

    navTimer = navTimer + elapsed
    if navTimer >= 0.1 then
        navTimer = 0
        F.UpdateNav()
        if not F.ringErrorShown then
            local ok, err = pcall(F.UpdateRangeRings)
            if not ok then
                F.ringErrorShown = true
                F.Say("Range rings could not draw. " .. tostring(err))
            end
        else
            pcall(F.UpdateRangeRings)
        end
    end

    bagTimer = bagTimer + elapsed
    if bagTimer >= 1 then
        bagTimer = 0
        if ready and not hybrid then
            pcall(F.CollectAddonButtons)
        end
    end

    hybridTimer = hybridTimer + elapsed
    if hybridTimer < 0.5 then
        return
    end
    hybridTimer = 0
    if not ready or not cluster then
        return
    end
    if F.IsHybrid() then
        if not hybrid then
            F.Restore()
        end
    elseif hybrid then
        hybrid = false
        F.Apply()
    end
end)

function F.InstallWarnings()
-- Subzones from the known murloc territories list. Whole coasts are not included.
local FISH_AREAS = {
    ["crystal lake"] = "murloc",
    ["northshire river"] = "murloc",
    ["stone cairn lake"] = "murloc",
    ["mirror lake"] = "murloc",
    ["longshore"] = "murloc",
    ["westfall lighthouse"] = "murloc",
    ["lake everstill"] = "murloc",
    ["alther's mill"] = "murloc",
    ["the golden strand"] = "murloc",
    ["tranquil shore"] = "murloc",
    ["the north coast"] = "murloc",
    ["whispering shore"] = "murloc",
    ["brightwater lake"] = "murloc",
    ["stillwater pond"] = "murloc",
    ["north tide's hollow"] = "murloc",
    ["north tide's run"] = "murloc",
    ["fenris isle"] = "murloc",
    ["the dawning isles"] = "murloc",
    ["western strand"] = "murloc",
    ["bluegill marsh"] = "murloc",
    ["sundown marsh"] = "murloc",
    ["menethil bay"] = "murloc",
    ["the loch"] = "murloc",
    ["the vile reef"] = "murloc",
    ["lake nazferiti"] = "murloc",
    ["misty reed strand"] = "murloc",
    ["pool of tears"] = "murloc",
    ["the red reaches"] = "murloc",
    ["greengill coast"] = "murloc",
    ["the long wash"] = "murloc",
    ["cliffspring river"] = "murloc",
    ["twilight shore"] = "murloc",
    ["blackfathom deeps"] = "murloc",
    ["silvermyst isle"] = "murloc",
    ["ammen ford"] = "murloc",
    ["blacksilt shore"] = "murloc",
    ["the hidden reef"] = "murloc",
    ["dreadmurk shore"] = "murloc",
    ["tidefury cove"] = "murloc",
    ["beezil's wreck"] = "murloc",
    ["scuttle coast"] = "murloc",
    ["chillmere coast"] = "murloc",
    ["daggercap bay"] = "murloc",
    ["winterfin village"] = "murloc",
    ["winterfin retreat"] = "murloc",
    ["winterfin caverns"] = "murloc",
}

local FISH_LINES = {
    murloc = {
        "Murlocs ahead.",
        "The murlocs were already here.",
        "Route not cleared of murlocs.",
        "Murloc congestion ahead.",
    },
    gorloc = {
        "Gorlocs ahead. Close enough to murlocs.",
        "Gorlocs ahead. They brought the family.",
    },
    deep = {
        "Murlocs ahead. The whole zone is theirs.",
        "Open water. The murlocs live here.",
    },
    capital = {
        "Murlocs ahead. This is their capital.",
        "Murloc territory. You are the visitor.",
    },
}

local DANGER_LINES = {
    "Hostile territory. %s. This is not a sightseeing area.",
    "Danger ahead. %s is enemy ground.",
    "Red on the map. %s.",
}

local PVP_LINES = {
    contested = {
        "Contested ground. %s. Someone else is armed too.",
        "PvP zone. %s. Keep walking, and keep looking.",
    },
    combat = {
        "Active combat zone. %s.",
        "Fight in progress. %s.",
    },
    arena = {
        "Arena. %s. Everyone here came to fight.",
    },
    ffa = {
        "Free for all. %s. No one is on your side.",
    },
}

local ELITE_AREAS = {
    ["jintha'alor"] = true,
    ["stromgarde keep"] = true,
    ["blackrock mountain"] = true,
    ["draco'dar"] = true,
    ["altar of storms"] = true,
    ["hive'regal"] = true,
    ["hive'ashi"] = true,
    ["hive'zora"] = true,
    ["tyr's hand"] = true,
    ["hearthglen"] = true,
    ["scholomance"] = true,
    ["andorhal"] = true,
    ["dire maul"] = true,
    ["ymirheim"] = true,
    ["isle of thunder"] = true,
    ["the maw"] = true,
    ["korthia"] = true,
    ["zaralek cavern"] = true,
    ["the slithering scar"] = true,
    ["the cauldron"] = true,
}

local BOSS_AREAS = {
    ["the tainted scar"] = true,
    ["bitter reaches"] = true,
    ["forlorn ridge"] = true,
    ["lake mennar"] = true,
    ["bough shadow"] = true,
    ["dream bough"] = true,
    ["seradane"] = true,
    ["twilight grove"] = true,
    ["throne of kil'jaeden"] = true,
    ["ata'mal terrace"] = true,
    ["isle of giants"] = true,
    ["timeless isle"] = true,
    ["tanaan jungle"] = true,
    ["broken shore"] = true,
}

local ELITE_LINES = {
    "Elite area. %s. They hit harder than they look.",
    "Elites ahead. %s. Bring friends or a plan.",
}

local BOSS_LINES = {
    "World boss territory. %s. Something here eats groups.",
    "Boss ground. %s. This one is not a quest mob.",
}

local SANCTUARY_LINES = {
    "Sanctuary. %s. Weapons stay sheathed.",
    "Safe ground. %s. The guards are already watching.",
}

local DUNGEON_LINES = {
    "Dungeon. %s. Watch the pulls.",
    "Dungeon. %s. Pull small.",
}

local RAID_LINES = {
    "Raid. %s. This is not a shortcut.",
    "Raid. %s. Bring the group.",
}

local RAIN_LINES = {
    "It's raining. %s. The murlocs consider this an invitation.",
    "Rain in %s. The road is softer than it looks.",
    "Wet forecast. %s. Cloak optional, regret included.",
    "Rain check. %s is doing this on purpose.",
}

local CAMPFIRE_LINES = {
    "Campfire nearby. Someone left the kettle on.",
    "Campfire nearby. Warm ground, and a place to sit.",
    "A campfire is close. The buff is already on you.",
}
local CAMPFIRE_QUIET = 8 * 60

local lastRainZone

local function LiveRain()
    local function raining(value)
        if type(value) ~= "string" then
            return false
        end
        local text = string.lower(value)
        if string.find(text, "sand", 1, true) or string.find(text, "snow", 1, true) or string.find(text, "clear", 1, true) then
            return false
        end
        return string.find(text, "rain", 1, true) or string.find(text, "drizzle", 1, true) or string.find(text, "downpour", 1, true) or string.find(text, "thunder", 1, true)
    end
    if C_Weather and C_Weather.GetWeather then
        local ok, weather = pcall(C_Weather.GetWeather)
        if ok and raining(weather) then
            return true
        end
    end
    if GetWeather then
        local ok, weather = pcall(GetWeather)
        if ok and raining(weather) then
            return true
        end
    end
    return false
end

local lastAreaSignature

local function AreaName(name)
    if not name or name == "" then
        return nil
    end
    return string.lower((name:gsub("’", "'")))
end

local function Listed(sub, zone, minimap, areas)
    for _, name in ipairs({ sub, zone, minimap }) do
        local key = AreaName(name)
        if key and areas[key] then
            return true
        end
    end
    return false
end

local function FishKind(sub, zone, minimap)
    for _, name in ipairs({ sub, zone, minimap }) do
        local key = AreaName(name)
        if key and FISH_AREAS[key] then
            return FISH_AREAS[key]
        end
    end
    return nil
end

local function PlaceName(zone, sub)
    if sub ~= "" and zone ~= "" and sub ~= zone then
        return sub .. ", " .. zone
    end
    if sub ~= "" then
        return sub
    end
    return zone
end

local function Pick(list)
    return list[math.random(#list)]
end

local function MaybeRain(zone, sub, minimapName, place)
    if not F.Enabled("warnWeather") then
        return
    end
    local raining = LiveRain()
    if not raining then
        lastRainZone = nil
        return
    end
    if lastRainZone == zone then
        return
    end
    lastRainZone = zone
    F.Say(string.format(Pick(RAIN_LINES), place ~= "" and place or zone))
end

local function AuraNameIsCampfire(value)
    value = F.Plain(value)
    if type(value) ~= "string" then
        return false
    end
    local text = string.lower(value)
    return string.find(text, "campfire", 1, true) and string.find(text, "nearby", 1, true)
end

local function AuraEnded(ok, value)
    if not ok then
        return true
    end
    if issecretvalue and issecretvalue(value) then
        return false
    end
    return value == nil
end

function F.CampfireNearby()
    if C_UnitAuras and C_UnitAuras.GetAuraDataByIndex then
        for index = 1, 40 do
            local ok, aura = pcall(C_UnitAuras.GetAuraDataByIndex, "player", index, "HELPFUL")
            if AuraEnded(ok, aura) then
                break
            end
            local plain = F.Plain(aura)
            if type(plain) == "table" and AuraNameIsCampfire(plain.name) then
                return true
            end
        end
    end
    if AuraUtil and AuraUtil.FindAuraByName then
        local ok, name = pcall(AuraUtil.FindAuraByName, "Campfire Nearby", "player", "HELPFUL")
        if ok and AuraNameIsCampfire(name) then
            return true
        end
    end
    if UnitBuff then
        for index = 1, 40 do
            local ok, name = pcall(UnitBuff, "player", index)
            if AuraEnded(ok, name) then
                break
            end
            if AuraNameIsCampfire(name) then
                return true
            end
        end
    end
    return false
end

local function CookTitle(value)
    if type(value) ~= "string" then
        return nil
    end
    local named = string.match(value, "%[(.-)%]")
    if named and named ~= "" then
        return named
    end
    if not string.find(value, "|", 1, true) then
        return value
    end
    return nil
end

local function CookWord(text, word)
    local start = 1
    while true do
        local at = string.find(text, word, start, true)
        if not at then
            return false
        end
        local before = at == 1 or string.sub(text, at - 1, at - 1) == " "
        local after = string.sub(text, at + #word, at + #word)
        if before and (after == "" or after == " ") then
            return true
        end
        start = at + 1
    end
end

local function CookKind(link)
    if type(link) ~= "string" then
        return nil
    end
    local info = GetItemInfo
    if type(info) ~= "function" and C_Item and type(C_Item.GetItemInfo) == "function" then
        info = C_Item.GetItemInfo
    end
    if type(info) ~= "function" then
        return nil
    end
    local ok, _, _, _, _, _, class, subclass = pcall(info, link)
    if not ok then
        return nil
    end
    class = F.Plain(class)
    subclass = F.Plain(subclass)
    if type(class) ~= "string" then
        class = nil
    else
        class = string.lower(class)
    end
    if type(subclass) ~= "string" then
        subclass = nil
    else
        subclass = string.lower(subclass)
    end
    return class, subclass
end

local function CookFood(title, kind, subclass)
    local text = string.lower(title)
    local raw = string.find(text, "^raw ") ~= nil
    if subclass == "food & drink" or subclass == "food and drink" then
        return nil
    end
    if kind == "consumable" and not raw then
        return nil
    end
    if string.find(text, "recipe", 1, true) or string.find(text, "spice", 1, true) or string.find(text, "salt", 1, true) or string.find(text, "potion", 1, true) or string.find(text, "elixir", 1, true) or string.find(text, " oil", 1, true) or string.find(text, "dye", 1, true) or string.find(text, "cooked", 1, true) or string.find(text, "boiled", 1, true) or string.find(text, "roasted", 1, true) or string.find(text, "grilled", 1, true) or string.find(text, "pickled", 1, true) or string.find(text, "smoked", 1, true) or string.find(text, "stew", 1, true) or string.find(text, "gumbo", 1, true) or string.find(text, "soup", 1, true) or string.find(text, "delight", 1, true) then
        return nil
    end
    if string.find(text, "poached", 1, true) or string.find(text, "baked", 1, true) or string.find(text, "broiled", 1, true) or string.find(text, "blackened", 1, true) or string.find(text, "barbecued", 1, true) or string.find(text, "charred", 1, true) or string.find(text, "crispy", 1, true) or string.find(text, "jerky", 1, true) or string.find(text, "kabob", 1, true) or string.find(text, "kebab", 1, true) or string.find(text, "fillet", 1, true) or string.find(text, "filet", 1, true) or string.find(text, "biscuit", 1, true) or string.find(text, "omelet", 1, true) or string.find(text, "feast", 1, true) or string.find(text, "basted", 1, true) then
        return nil
    end
    local meats = { "meat", "flank", "haunch", "flesh", "clam", "lobster", "crawdad", "egg", "wing", "rib" }
    local fish = { "fish", "snapper", "salmon", "sagefish", "trout", "grouper", "eel", "mightfish", "redgill", "blackmouth", "albacore", "yellowtail", "sculpin", "guppy", "lurker", "sporefish", "catfish", "cod", "bass" }
    local goods = kind == "trade goods" or kind == "tradegoods" or kind == "reagent" or subclass == "meat & fish" or subclass == "cooking"
    local hit = raw
    if not hit then
        for index = 1, #meats do
            if CookWord(text, meats[index]) or string.find(text, meats[index], 1, true) and #meats[index] >= 5 then
                hit = true
                break
            end
        end
    end
    if not hit and goods then
        for index = 1, #fish do
            if CookWord(text, fish[index]) or string.find(text, fish[index], 1, true) and #fish[index] >= 5 then
                hit = true
                break
            end
        end
    end
    if not hit then
        return nil
    end
    text = string.gsub(text, "^raw ", "")
    text = string.gsub(text, "^large ", "")
    text = string.gsub(text, "^small ", "")
    text = string.gsub(text, "^giant ", "")
    text = string.gsub(text, "^huge ", "")
    if #text > 36 then
        text = string.sub(text, 1, 36)
    end
    if text == "" then
        return nil
    end
    return text
end

local function CookLink(bag, slot)
    if C_Container and C_Container.GetContainerItemLink then
        local ok, value = pcall(C_Container.GetContainerItemLink, bag, slot)
        value = ok and F.Plain(value)
        if type(value) == "string" then
            return value
        end
    end
    if C_Container and C_Container.GetContainerItemInfo then
        local ok, info = pcall(C_Container.GetContainerItemInfo, bag, slot)
        info = ok and F.Plain(info)
        if type(info) == "table" then
            if type(info.hyperlink) == "string" then
                return info.hyperlink
            end
            if type(info.itemName) == "string" then
                return info.itemName
            end
        end
    end
    if GetContainerItemLink then
        local ok, value = pcall(GetContainerItemLink, bag, slot)
        value = ok and F.Plain(value)
        if type(value) == "string" then
            return value
        end
    end
    return nil
end

local function CookSlots(bag)
    if C_Container and C_Container.GetContainerNumSlots then
        local ok, count = pcall(C_Container.GetContainerNumSlots, bag)
        count = ok and F.Plain(count)
        if type(count) == "number" then
            return count
        end
    end
    if GetContainerNumSlots then
        local ok, count = pcall(GetContainerNumSlots, bag)
        count = ok and F.Plain(count)
        if type(count) == "number" then
            return count
        end
    end
    return 0
end

local function CookBite()
    if F.GatherProfession(185, "Cooking") ~= true then
        return nil
    end
    local bags = NUM_BAG_SLOTS
    if type(bags) ~= "number" or bags < 0 or bags > 12 then
        bags = 4
    end
    local meat
    for bag = 0, bags do
        local count = CookSlots(bag)
        for slot = 1, count do
            local link = CookLink(bag, slot)
            local title = CookTitle(link)
            local kind, subclass = CookKind(link)
            local name = title and CookFood(title, kind, subclass)
            if name then
                if string.find(name, "fish", 1, true) or string.find(name, "snapper", 1, true) or string.find(name, "salmon", 1, true) or string.find(name, "trout", 1, true) or string.find(name, "lobster", 1, true) or string.find(name, "eel", 1, true) or string.find(name, "clam", 1, true) then
                    return name
                end
                if not meat then
                    meat = name
                end
            end
        end
    end
    return meat
end

function F.WarnCampfire()
    if not db or not F.Enabled("warnCampfire") then
        F.campfireOn = false
        return
    end
    local on = F.CampfireNearby()
    if on and not F.campfireOn then
        local now
        if GetTime then
            local ok, value = pcall(GetTime)
            value = ok and F.Plain(value)
            if type(value) == "number" then
                now = value
            end
        end
        if not now or not F.campfireNext or now >= F.campfireNext then
            local line = Pick(CAMPFIRE_LINES)
            local bite = CookBite()
            if bite then
                line = "Campfire nearby. The " .. bite .. " will cook."
            end
            F.Say(line)
            F.PlayCampfireSound()
            if now then
                F.campfireNext = now + CAMPFIRE_QUIET
            end
        end
    end
    F.campfireOn = on and true or false
end

function F.WarnArea()
    local zone = GetZoneText() or ""
    local sub = GetSubZoneText() or ""
    if zone == "" and sub == "" then
        return
    end
    local pvpType, isFFA
    if GetZonePVPInfo then
        pvpType, isFFA = GetZonePVPInfo()
    end
    local minimapName = GetMinimapZoneText()
    local fish = FishKind(sub, zone, minimapName)
    local boss = Listed(sub, zone, minimapName, BOSS_AREAS)
    local elite = Listed(sub, zone, minimapName, ELITE_AREAS)
    local _, instanceType = false, nil
    if IsInInstance then
        _, instanceType = IsInInstance()
    end
    local pvpZone = isFFA or pvpType == "arena" or pvpType == "combat" or pvpType == "contested"
    local kind = "none"
    if (instanceType == "party" or instanceType == "raid") and F.Enabled("warnInstance") then
        kind = instanceType
    elseif boss and F.Enabled("warnBoss") then
        kind = "boss"
    elseif elite and F.Enabled("warnElite") then
        kind = "elite"
    elseif fish and F.Enabled("warnMurloc") then
        kind = "fish"
    elseif pvpZone and F.Enabled("warnPvp") then
        kind = "pvp"
    elseif pvpType == "hostile" and F.Enabled("warnDanger") then
        kind = "danger"
    elseif pvpType == "sanctuary" and F.Enabled("warnSanctuary") then
        kind = "sanctuary"
    end
    local signature = zone .. "\0" .. sub .. "\0" .. tostring(pvpType) .. "\0" .. tostring(isFFA) .. "\0" .. kind
    if kind == "party" or kind == "raid" then
        signature = "instance\0" .. zone .. "\0" .. kind
    end
    if signature == lastAreaSignature then
        return
    end
    lastAreaSignature = signature
    local place = PlaceName(zone, sub)
    if place == "" then
        return
    end
    MaybeRain(zone, sub, minimapName, place)
    if kind == "party" then
        F.Say(string.format(Pick(DUNGEON_LINES), place))
        return
    end
    if kind == "raid" then
        F.Say(string.format(Pick(RAID_LINES), place))
        return
    end
    if kind == "boss" then
        F.Say(string.format(Pick(BOSS_LINES), place))
        return
    end
    if kind == "elite" then
        F.Say(string.format(Pick(ELITE_LINES), place))
        return
    end
    if kind == "sanctuary" then
        F.Say(string.format(Pick(SANCTUARY_LINES), place))
        return
    end
    if fish and F.Enabled("warnMurloc") then
        local extra = ""
        if pvpZone and F.Enabled("warnPvp") then
            extra = " Also a PvP zone."
        elseif pvpType == "hostile" and F.Enabled("warnDanger") then
            extra = " Enemy ground too."
        end
        F.Say(Pick(FISH_LINES[fish]) .. " " .. place .. "." .. extra)
        return
    end
    if isFFA and F.Enabled("warnPvp") then
        F.Say(string.format(Pick(PVP_LINES.ffa), place))
        return
    end
    if F.Enabled("warnPvp") and (pvpType == "arena" or pvpType == "combat" or pvpType == "contested") then
        F.Say(string.format(Pick(PVP_LINES[pvpType]), place))
        return
    end
    if pvpType == "hostile" and F.Enabled("warnDanger") then
        F.Say(string.format(Pick(DANGER_LINES), place))
    end
end
end
F.InstallWarnings()

function F.InstallQuestItems()
    -- Item objectives such as 10 bear hearts. Kill counts stay on the quest tracker.
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

    local function itemName(text)
        if type(text) ~= "string" or text == "" then
            return nil
        end
        local name = string.gsub(text, "|c%x%x%x%x%x%x%x%x", "")
        name = string.gsub(name, "|r", "")
        name = string.gsub(name, "|T.-|t", "")
        name = string.gsub(name, "|H.-|h%[(.-)%]|h", "%1")
        name = string.gsub(name, "|H.-|h(.-)|h", "%1")
        name = string.gsub(name, "%d+%s*/%s*%d+", "")
        name = string.gsub(name, "^%s*[Cc]ollect%s+%d+%s+", "")
        name = string.gsub(name, "^%s*[Gg]ather%s+%d+%s+", "")
        name = string.gsub(name, "^%s*[Rr]ecover%s+%d+%s+", "")
        name = string.gsub(name, "^[%s%.:%(%)%[%]]+", "")
        name = string.gsub(name, "[%s%.:%(%)%[%]]+$", "")
        name = string.gsub(name, "%s+[Cc]ollected$", "")
        name = string.gsub(name, "%s+[Oo]btained$", "")
        name = string.gsub(name, "%s+", " ")
        if name == "" then
            return nil
        end
        local lower = string.lower(name)
        if string.find(lower, "slain", 1, true) or string.find(lower, "killed", 1, true) or string.find(lower, "destroyed", 1, true) or string.find(lower, "defeated", 1, true) then
            return nil
        end
        return name
    end

    local function push(rows, key, have, need, text, kind)
        kind = F.Plain(kind)
        if type(kind) ~= "string" or kind == "" then
            kind = nil
        end
        if kind and kind ~= "item" then
            return
        end
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
        if type(have) ~= "number" or type(need) ~= "number" or need < 2 or have < 0 then
            return
        end
        if kind ~= "item" and need > 200 then
            return
        end
        local name = itemName(text)
        if not name and kind ~= "item" then
            return
        end
        rows[#rows + 1] = {
            key = key,
            have = have,
            need = need,
            name = name,
        }
    end

    local function fromLog(rows)
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
            if type(info) == "table" then
                local questID = countOf(info.questID)
                if not F.Plain(info.isHeader) and questID and questID > 0 then
                    local objOK, objectives = pcall(C_QuestLog.GetQuestObjectives, questID)
                    objectives = objOK and F.Plain(objectives)
                    if type(objectives) == "table" then
                        for objIndex, objective in ipairs(objectives) do
                            objective = F.Plain(objective)
                            if type(objective) == "table" then
                                local text = F.Plain(objective.text)
                                push(rows, questID .. ":" .. objIndex, countOf(objective.numFulfilled), countOf(objective.numRequired), text, objective.type)
                            end
                        end
                    end
                end
            end
        end
        return true
    end

    local function fromBoard(rows)
        if not (GetNumQuestLogEntries and GetQuestLogTitle and GetNumQuestLeaderBoards and GetQuestLogLeaderBoard) then
            return
        end
        local ok, num = pcall(GetNumQuestLogEntries)
        num = ok and countOf(num)
        if not num then
            return
        end
        for index = 1, num do
            local titleOK, _, _, _, isHeader, _, _, _, questID = pcall(GetQuestLogTitle, index)
            if titleOK and not F.Plain(isHeader) then
                questID = countOf(questID) or index
                local boardsOK, boards = pcall(GetNumQuestLeaderBoards, index)
                boards = boardsOK and countOf(boards) or 0
                for objIndex = 1, boards do
                    local lineOK, text, kind = pcall(GetQuestLogLeaderBoard, objIndex, index)
                    if lineOK then
                        push(rows, questID .. ":" .. objIndex, nil, nil, F.Plain(text), kind)
                    end
                end
            end
        end
    end

    local function rowsOf()
        local rows = {}
        fromLog(rows)
        if #rows == 0 then
            fromBoard(rows)
        end
        return rows
    end

    local function lineFor(have, need, name)
        local shown = have
        if shown > need then
            shown = need
        end
        local line = shown .. "/" .. need
        if name then
            line = line .. " " .. name
        end
        line = line .. "."
        if have >= need then
            line = line .. " That one is done."
        end
        return line
    end

    function F.NoteQuestItems(seedOnly)
        if not db then
            return
        end
        local seen = F.questItemSeen or {}
        local nextSeen = {}
        local talk = not seedOnly and F.questItemsLive and F.Enabled("warnQuest")
        for _, row in ipairs(rowsOf()) do
            local prev = seen[row.key]
            if talk and type(prev) == "number" and row.have > prev and prev < row.need then
                F.Say(lineFor(row.have, row.need, row.name))
            end
            nextSeen[row.key] = row.have
        end
        F.questItemSeen = nextSeen
    end

    function F.QuietQuestItems()
        F.questItemsLive = false
        F.questItemsQuiet = (F.questItemsQuiet or 0) + 1
        local token = F.questItemsQuiet
        if not C_Timer or not C_Timer.After then
            F.NoteQuestItems(true)
            F.questItemsLive = true
            return
        end
        C_Timer.After(2, function()
            if F.questItemsQuiet ~= token then
                return
            end
            F.NoteQuestItems(true)
            F.questItemsLive = true
        end)
    end
end
F.InstallQuestItems()

function F.InstallQuestMarks()
    -- Addons cannot draw on objects in the world, only on nameplates, so the
    -- marks only reach creatures that have one.
    local pool = {}
    local used = 0
    local shown = false

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

    local function cleanName(text)
        local name = string.gsub(text, "|c%x%x%x%x%x%x%x%x", "")
        name = string.gsub(name, "|r", "")
        name = string.gsub(name, "|T.-|t", "")
        name = string.gsub(name, "|H.-|h%[(.-)%]|h", "%1")
        name = string.gsub(name, "|H.-|h(.-)|h", "%1")
        name = string.gsub(name, "%d+%s*/%s*%d+", "")
        name = string.gsub(name, "^%s*[Cc]ollect%s+%d+%s+", "")
        name = string.gsub(name, "^%s*[Gg]ather%s+%d+%s+", "")
        name = string.gsub(name, "^%s*[Rr]ecover%s+%d+%s+", "")
        name = string.gsub(name, "^[%s%.:%-]+", "")
        name = string.gsub(name, "[%s%.:%-]+$", "")
        name = string.gsub(name, "%s+[Cc]ollected$", "")
        name = string.gsub(name, "%s+[Oo]btained$", "")
        name = string.gsub(name, "%s+", " ")
        if name == "" then
            return nil
        end
        return name
    end

    local function isKill(text)
        local lower = string.lower(text)
        return string.find(lower, "slain", 1, true)
            or string.find(lower, "killed", 1, true)
            or string.find(lower, "destroyed", 1, true)
            or string.find(lower, "defeated", 1, true)
    end

    local function killName(text)
        local clean = string.gsub(text, "|c%x%x%x%x%x%x%x%x", "")
        clean = string.gsub(clean, "|r", "")
        local name = string.match(clean, "^(.-)%s+[Ss]lain:?%s*%d+%s*/%s*%d+")
            or string.match(clean, "^(.-):%s*%d+%s*/%s*%d+")
            or string.match(clean, "^%d+%s*/%s*%d+%s+(.+)$")
        if not name then
            return nil
        end
        name = string.gsub(name, "%s+[Ss]lain$", "")
        name = string.gsub(name, "^%s+", "")
        name = string.gsub(name, "%s+$", "")
        if name == "" then
            return nil
        end
        return name
    end

    local function addRow(seen, items, objects, kills, have, need, text, kind)
        kind = F.Plain(kind)
        if type(kind) == "string" then
            kind = string.lower(kind)
        else
            kind = nil
        end
        text = F.Plain(text)
        if type(text) ~= "string" or text == "" then
            return
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
        if type(have) ~= "number" or type(need) ~= "number" or need < 1 or have < 0 or have >= need then
            return
        end
        if kind == "monster" or (kind == nil and isKill(text)) then
            local name = killName(text)
            local key = name and ("kill:" .. string.lower(name))
            if key and not seen[key] then
                seen[key] = true
                kills[#kills + 1] = {
                    name = name,
                    lower = string.lower(name),
                    text = string.lower(text),
                    have = have,
                    need = need,
                }
            end
            return
        end
        local object = kind == "object" or kind == "gameobject"
        if not object and kind ~= "item" and kind ~= nil then
            return
        end
        if not object and isKill(text) then
            return
        end
        if not object and kind ~= "item" and need > 200 then
            return
        end
        local name = cleanName(text)
        if not name or isKill(name) then
            return
        end
        local lower = string.lower(name)
        if seen[lower] then
            return
        end
        seen[lower] = true
        local row = {
            name = name,
            lower = lower,
            text = string.lower(text),
            have = have,
            need = need,
        }
        if object then
            objects[#objects + 1] = row
        else
            items[#items + 1] = row
        end
    end

    local function objectives()
        local items, objects, kills, seen = {}, {}, {}, {}
        local function take(have, need, text, kind, finished)
            if F.Plain(finished) == true then
                return
            end
            addRow(seen, items, objects, kills, have, need, text, kind)
        end
        local usedLog = false
        if C_QuestLog and C_QuestLog.GetNumQuestLogEntries and C_QuestLog.GetInfo and C_QuestLog.GetQuestObjectives then
            local ok, count = pcall(C_QuestLog.GetNumQuestLogEntries)
            count = ok and countOf(count)
            if count then
                usedLog = true
                for index = 1, count do
                    local infoOK, info = pcall(C_QuestLog.GetInfo, index)
                    info = infoOK and F.Plain(info)
                    if type(info) == "table" and not F.Plain(info.isHeader) then
                        local questID = countOf(info.questID)
                        if questID and questID > 0 then
                            local objOK, rows = pcall(C_QuestLog.GetQuestObjectives, questID)
                            rows = objOK and F.Plain(rows)
                            if type(rows) == "table" then
                                for _, objective in ipairs(rows) do
                                    objective = F.Plain(objective)
                                    if type(objective) == "table" then
                                        take(countOf(objective.numFulfilled), countOf(objective.numRequired), objective.text, objective.type, objective.finished)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        if usedLog then
            return items, objects, kills
        end
        if not (GetNumQuestLogEntries and GetQuestLogTitle and GetNumQuestLeaderBoards and GetQuestLogLeaderBoard) then
            return items, objects, kills
        end
        local ok, num = pcall(GetNumQuestLogEntries)
        num = ok and countOf(num)
        if not num then
            return items, objects, kills
        end
        for index = 1, num do
            local titleOK, _, _, _, isHeader = pcall(GetQuestLogTitle, index)
            if titleOK and not F.Plain(isHeader) then
                local boardsOK, boards = pcall(GetNumQuestLeaderBoards, index)
                boards = boardsOK and countOf(boards) or 0
                for objIndex = 1, boards do
                    local lineOK, text, kind, finished = pcall(GetQuestLogLeaderBoard, objIndex, index)
                    if lineOK then
                        take(nil, nil, text, kind, finished)
                    end
                end
            end
        end
        return items, objects, kills
    end

    local function progress(row)
        local have = row.have
        if have > row.need then
            have = row.need
        end
        local line = have .. "/" .. row.need
        if row.name then
            line = line .. " " .. row.name
        end
        if #line > 48 then
            line = string.sub(line, 1, 45) .. "..."
        end
        return line
    end

    local function hasWord(hay, needle)
        if type(hay) ~= "string" or type(needle) ~= "string" or #needle < 4 then
            return false
        end
        local startAt = 1
        while startAt <= #hay do
            local from, to = string.find(hay, needle, startAt, true)
            if not from then
                return false
            end
            local prev = from > 1 and string.sub(hay, from - 1, from - 1) or ""
            local nextc = to < #hay and string.sub(hay, to + 1, to + 1) or ""
            local function edge(ch)
                return ch == "" or string.match(ch, "[^%a]") ~= nil
            end
            if edge(prev) and edge(nextc) then
                return true
            end
            startAt = to + 1
        end
        return false
    end

    local function findInTip(tip, rows)
        local found, count = nil, 0
        if type(tip) ~= "string" or tip == "" then
            return nil, 0
        end
        for index = 1, #rows do
            local row = rows[index]
            if hasWord(tip, row.lower) then
                count = count + 1
                found = row
                if count > 1 then
                    return nil, count
                end
            end
        end
        return found, count
    end

    local scanTip

    local function tipLines(unit)
        local parts = {}
        local function piece(value)
            value = F.Plain(value)
            if type(value) ~= "string" or value == "" then
                return
            end
            value = string.gsub(value, "|c%x%x%x%x%x%x%x%x", "")
            value = string.gsub(value, "|r", "")
            parts[#parts + 1] = value
        end
        if C_TooltipInfo and C_TooltipInfo.GetUnit then
            local ok, data = pcall(C_TooltipInfo.GetUnit, unit)
            data = ok and F.Plain(data)
            local lines = type(data) == "table" and F.Plain(data.lines)
            if type(lines) == "table" then
                for index = 2, #lines do
                    local line = F.Plain(lines[index])
                    if type(line) == "table" then
                        piece(line.leftText)
                        piece(line.text)
                        piece(line.rightText)
                    end
                end
                return parts
            end
        end
        if not scanTip then
            local ok, tip = pcall(CreateFrame, "GameTooltip", "NavigateForeverMarkTip", nil, "GameTooltipTemplate")
            if not ok or not tip then
                return parts
            end
            scanTip = tip
        end
        scanTip:SetOwner(WorldFrame, "ANCHOR_NONE")
        if pcall(scanTip.SetUnit, scanTip, unit) then
            for index = 2, scanTip:NumLines() do
                local left = _G["NavigateForeverMarkTipTextLeft" .. index]
                if left then
                    piece(left:GetText())
                end
            end
        end
        scanTip:Hide()
        return parts
    end

    local function tooltipText(lines)
        local parts = {}
        for index = 1, #lines do
            parts[index] = string.lower(lines[index])
        end
        return table.concat(parts, "\n")
    end

    local function progressLine(lines)
        for index = 1, #lines do
            local have, need = countsFrom(lines[index])
            if have and need and need > 0 and have < need then
                local line = string.gsub(lines[index], "^[%s%-]+", "")
                if #line > 48 then
                    line = string.sub(line, 1, 45) .. "..."
                end
                return line
            end
        end
        return nil
    end

    local function related(unit)
        if not (C_QuestLog and C_QuestLog.UnitIsRelatedToActiveQuest) then
            return nil
        end
        local ok, value = pcall(C_QuestLog.UnitIsRelatedToActiveQuest, unit)
        if not ok then
            return nil
        end
        value = F.Plain(value)
        if value == nil then
            return nil
        end
        return value and true or false
    end

    local function friendly(unit)
        if not UnitIsFriend then
            return false
        end
        local ok, value = pcall(UnitIsFriend, "player", unit)
        return ok and F.Plain(value) and true or false
    end

    local function skipUnit(unit)
        if not UnitExists then
            return true
        end
        local existsOK, exists = pcall(UnitExists, unit)
        if not existsOK or not F.Plain(exists) then
            return true
        end
        if UnitIsUnit then
            local sameOK, same = pcall(UnitIsUnit, unit, "player")
            if sameOK and F.Plain(same) then
                return true
            end
        end
        if UnitIsPlayer then
            local playerOK, player = pcall(UnitIsPlayer, unit)
            if playerOK and F.Plain(player) then
                return true
            end
        end
        if UnitPlayerControlled then
            local controlledOK, controlled = pcall(UnitPlayerControlled, unit)
            if controlledOK and F.Plain(controlled) then
                return true
            end
        end
        if UnitIsDead then
            local deadOK, dead = pcall(UnitIsDead, unit)
            if deadOK and F.Plain(dead) then
                return true
            end
        end
        return false
    end

    local function byName(rows, unitName, allowContains)
        if type(unitName) ~= "string" then
            return nil
        end
        local lower = string.lower(unitName)
        for index = 1, #rows do
            if rows[index].lower == lower then
                return rows[index]
            end
        end
        if allowContains and #lower >= 8 then
            for index = 1, #rows do
                local row = rows[index]
                if row.text and string.find(row.text, lower, 1, true) then
                    return row
                end
            end
        end
        return nil
    end

    local function labelFor(unit, items, objects, kills)
        local name
        if UnitName then
            local nameOK, value = pcall(UnitName, unit)
            name = F.RareName(nameOK and value)
        end
        local kill = byName(kills, name, false)
        if kill then
            return progress(kill)
        end
        local named = byName(objects, name, true) or byName(items, name, false)
        if named then
            return progress(named)
        end
        local tie = related(unit)
        if tie == false then
            return nil
        end
        local lines = tipLines(unit)
        local line = progressLine(lines)
        if line then
            return line
        end
        local rows = {}
        for index = 1, #items do
            rows[#rows + 1] = items[index]
        end
        for index = 1, #objects do
            rows[#rows + 1] = objects[index]
        end
        if #rows > 0 and #lines > 0 and not friendly(unit) then
            local found, count = findInTip(tooltipText(lines), rows)
            if count == 1 and found then
                return progress(found)
            end
            if count > 1 then
                return "Quest item"
            end
        end
        if tie == true then
            if #items == 1 then
                return progress(items[1])
            end
            return "Quest"
        end
        return nil
    end

    local function box(owner, thick)
        local lines = {}
        local function stripe(anchor1, anchor2, horizontal)
            local line = owner:CreateTexture(nil, "OVERLAY")
            line:SetColorTexture(GOLD_R, GOLD_G, GOLD_B, 1)
            line:SetPoint(anchor1)
            line:SetPoint(anchor2)
            if horizontal then
                line:SetHeight(thick)
            else
                line:SetWidth(thick)
            end
            lines[#lines + 1] = line
        end
        stripe("TOPLEFT", "TOPRIGHT", true)
        stripe("BOTTOMLEFT", "BOTTOMRIGHT", true)
        stripe("TOPLEFT", "BOTTOMLEFT", false)
        stripe("TOPRIGHT", "BOTTOMRIGHT", false)
        return lines
    end

    local function newMark()
        local frame = CreateFrame("Frame", nil, UIParent)
        frame:EnableMouse(false)
        if frame.SetMouseClickEnabled then
            pcall(frame.SetMouseClickEnabled, frame, false)
        end
        if frame.SetMouseMotionEnabled then
            pcall(frame.SetMouseMotionEnabled, frame, false)
        end
        local glow = frame:CreateTexture(nil, "BACKGROUND")
        glow:SetTexture(MEDIA .. "theme-spark")
        glow:SetBlendMode("ADD")
        glow:SetVertexColor(GOLD_R, GOLD_G, GOLD_B)
        glow:SetPoint("TOPLEFT", -16, 10)
        glow:SetPoint("BOTTOMRIGHT", 16, -10)
        frame.nfGlow = glow
        frame.nfLines = box(frame, 1.5)
        local tag = CreateFrame("Frame", nil, frame)
        tag:SetHeight(24)
        tag:EnableMouse(false)
        if tag.SetMouseClickEnabled then
            pcall(tag.SetMouseClickEnabled, tag, false)
        end
        tag:SetPoint("BOTTOM", frame, "TOP", 0, 14)
        local icon = tag:CreateTexture(nil, "ARTWORK")
        icon:SetSize(20, 20)
        icon:SetPoint("LEFT", 0, 0)
        frame.nfIcon = icon
        local painted = false
        if icon.SetAtlas then
            local atlasOK = pcall(icon.SetAtlas, icon, "QuestNormal")
            if atlasOK and icon.GetAtlas then
                local got, atlas = pcall(icon.GetAtlas, icon)
                painted = got and atlas == "QuestNormal"
            end
        end
        if not painted then
            icon:SetTexture("Interface\\GossipFrame\\AvailableQuestIcon")
        end
        local text = tag:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        text:SetPoint("LEFT", 24, 0)
        text:SetJustifyH("LEFT")
        text:SetTextColor(GOLD_R, GOLD_G, GOLD_B)
        pcall(text.SetFont, text, "Fonts\\FRIZQT__.TTF", 13, "OUTLINE")
        frame.nfTag = tag
        frame.nfText = text
        frame:Hide()
        return frame
    end

    local function hostOf(plate)
        local ok, child = pcall(function()
            return plate.UnitFrame
        end)
        if ok and type(child) == "table" then
            return child
        end
        return plate
    end

    local function visible(frame)
        if type(frame) ~= "table" or not frame.IsVisible then
            return false
        end
        local ok, value = pcall(frame.IsVisible, frame)
        return ok and F.Plain(value) and true or false
    end

    local function barOf(host)
        local ok, bar = pcall(function()
            return host.healthBar or (host.HealthBarsContainer and host.HealthBarsContainer.healthBar)
        end)
        if ok and visible(bar) then
            return bar
        end
        return host
    end

    -- A nameplate addon can hide Blizzard's UnitFrame, so the mark hangs off
    -- the plate itself and only lines up with the health bar when it shows.
    local function anchorOf(plate)
        local unitFrame = hostOf(plate)
        if unitFrame ~= plate and visible(unitFrame) then
            return barOf(unitFrame)
        end
        return plate
    end

    local function usable(host)
        local widthOK, width = pcall(host.GetWidth, host)
        local heightOK, height = pcall(host.GetHeight, host)
        width = widthOK and F.Plain(width)
        height = heightOK and F.Plain(height)
        if type(width) ~= "number" or type(height) ~= "number" then
            return true
        end
        return width >= 12 and height >= 8 and width <= 400 and height <= 200
    end

    local function plateFor(unit)
        if C_NamePlate and C_NamePlate.GetNamePlateForUnit then
            local ok, plate = pcall(C_NamePlate.GetNamePlateForUnit, unit)
            if ok and type(plate) == "table" then
                return plate
            end
        end
        local index = type(unit) == "string" and string.match(unit, "^nameplate(%d+)$")
        if not index then
            return nil
        end
        local foundOK, frame = pcall(function()
            return _G["NamePlate" .. index]
        end)
        if foundOK and type(frame) == "table" then
            return frame
        end
        return nil
    end

    local function showMark(host, label)
        used = used + 1
        local frame = pool[used]
        if not frame then
            frame = newMark()
            pool[used] = frame
        end
        local bar = anchorOf(host)
        frame:SetParent(host)
        frame:ClearAllPoints()
        frame:SetPoint("TOPLEFT", bar, "TOPLEFT", -2, 2)
        frame:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", 2, -2)
        local text = frame.nfText
        text:SetText(label)
        local width = #label * 7
        if width < 72 then
            width = 72
        end
        local measuredOK, measured = pcall(text.GetStringWidth, text)
        measured = measuredOK and F.Plain(measured)
        if type(measured) == "number" and measured > 8 then
            width = measured
        end
        if width > 220 then
            width = 220
        end
        frame.nfTag:SetWidth(width + 26)
        local levelOK, level = pcall(host.GetFrameLevel, host)
        level = levelOK and F.Plain(level)
        if type(level) == "number" then
            frame:SetFrameLevel(level + 20)
            frame.nfTag:SetFrameLevel(level + 22)
        end
        frame:Show()
        shown = true
    end

    function F.QuestMarkHide()
        if not shown then
            return
        end
        shown = false
        used = 0
        for index = 1, #pool do
            pool[index]:Hide()
            pool[index]:SetParent(UIParent)
        end
    end

    local function eachUnit(visit)
        local seen = {}
        local found = false
        local function consider(unit, plate)
            unit = F.Plain(unit)
            if type(unit) ~= "string" or seen[unit] then
                return
            end
            seen[unit] = true
            found = true
            visit(unit, plate)
        end
        if C_NamePlate and C_NamePlate.GetNamePlates then
            local ok, plates = pcall(C_NamePlate.GetNamePlates, false)
            if ok and type(plates) == "table" then
                for index = 1, #plates do
                    local plate = plates[index]
                    if type(plate) == "table" then
                        local unit = F.Plain(plate.namePlateUnitToken)
                        if type(unit) ~= "string" then
                            unit = F.Plain(plate.unit)
                        end
                        if type(unit) ~= "string" and plate.GetAttribute then
                            local attrOK, attr = pcall(plate.GetAttribute, plate, "unit")
                            unit = attrOK and F.Plain(attr)
                        end
                        consider(unit, plate)
                    end
                end
                if found then
                    return
                end
            end
        end
        for index = 1, 40 do
            local unit = "nameplate" .. index
            local existsOK, exists = pcall(UnitExists, unit)
            if existsOK and F.Plain(exists) then
                consider(unit, nil)
            end
        end
    end

    local function noteNames()
        if F.questMarkNamesNoted or not GetCVar then
            return
        end
        local ok, value = pcall(GetCVar, "nameplateShowEnemies")
        value = ok and F.Plain(value)
        if value == nil then
            return
        end
        F.questMarkNamesNoted = true
        if value == "0" or value == 0 or value == false then
            F.Say("Quest marks sit on nameplates. Turn on enemy names to see them.")
        end
    end

    local function scan()
        used = 0
        local items, objects, kills = objectives()
        local canTie = C_QuestLog and C_QuestLog.UnitIsRelatedToActiveQuest
        if #items == 0 and #objects == 0 and #kills == 0 and not canTie then
            F.QuestMarkHide()
            return
        end
        noteNames()
        eachUnit(function(unit, knownPlate)
            if skipUnit(unit) then
                return
            end
            local ok, err = pcall(function()
                local label = labelFor(unit, items, objects, kills)
                if not label then
                    return
                end
                local plate = knownPlate or plateFor(unit)
                if type(plate) ~= "table" then
                    return
                end
                if not usable(plate) then
                    return
                end
                showMark(plate, label)
            end)
            if not ok and not F.questMarkErrorShown then
                F.questMarkErrorShown = true
                F.Say("Quest marks could not be drawn. " .. tostring(err))
            end
        end)
        if used == 0 then
            F.QuestMarkHide()
            return
        end
        for index = used + 1, #pool do
            pool[index]:Hide()
            pool[index]:SetParent(UIParent)
        end
    end

    function F.QuestMarkReport()
        local items, objects, kills = objectives()
        F.Say("Quest marks: " .. (F.Enabled("questMarks") and "on" or "off") .. ". Objectives: " .. #kills .. " to kill, " .. #items .. " items, " .. #objects .. " objects.")
        for index = 1, math.min(#kills, 5) do
            F.Say("  Kill: " .. kills[index].name .. " (" .. kills[index].have .. "/" .. kills[index].need .. ")")
        end
        local function cvar(name)
            local ok, value = pcall(GetCVar, name)
            value = ok and F.Plain(value)
            return value == nil and "?" or tostring(value)
        end
        F.Say("Enemy names: " .. cvar("nameplateShowEnemies") .. ", friendly names: " .. cvar("nameplateShowFriends") .. ". Quest link check: " .. ((C_QuestLog and C_QuestLog.UnitIsRelatedToActiveQuest) and "yes" or "no") .. ". Tooltip reader: " .. ((C_TooltipInfo and C_TooltipInfo.GetUnit) and "new" or "old") .. ".")
        local listed = 0
        eachUnit(function(unit)
            if listed >= 8 then
                return
            end
            listed = listed + 1
            local nameOK, name = pcall(UnitName, unit)
            name = F.RareName(nameOK and name) or unit
            if skipUnit(unit) then
                F.Say("  " .. name .. ": skipped (player, pet, or dead).")
                return
            end
            local okLabel, label = pcall(labelFor, unit, items, objects, kills)
            local tie = related(unit)
            local lines = tipLines(unit)
            local plate = plateFor(unit)
            local plateState = type(plate) ~= "table" and "no plate frame"
                or ("plate " .. (visible(plate) and "visible" or "hidden") .. ", bars " .. (visible(hostOf(plate)) and "visible" or "hidden"))
            F.Say("  " .. name .. ": " .. (okLabel and label and ("mark \"" .. label .. "\"") or (okLabel and "no mark" or ("error " .. tostring(label))))
                .. ", quest link " .. tostring(tie) .. ", " .. plateState .. ", tooltip lines " .. #lines
                .. (progressLine(lines) and (", progress \"" .. progressLine(lines) .. "\"") or (lines[1] and (", first \"" .. lines[1] .. "\"") or "")) .. ".")
        end)
        if listed == 0 then
            F.Say("  No nameplates in view. Press V to show enemy nameplates, and Shift-V for friendly ones.")
        end
    end

    function F.QuestMarkSoon()
        local state = F.questMark or {}
        F.questMark = state
        state.left = 0
    end

    function F.QuestMarkTick(elapsed)
        if not db or not F.Enabled("questMarks") then
            F.QuestMarkHide()
            return
        end
        local state = F.questMark or {}
        F.questMark = state
        if shown then
            state.clock = (state.clock or 0) + (elapsed or 0)
            local wave = 0.5 + 0.5 * math.sin(state.clock * 4)
            local size = 18 + 4 * wave
            for index = 1, used do
                local frame = pool[index]
                frame.nfGlow:SetAlpha(0.35 + 0.45 * wave)
                frame.nfIcon:SetSize(size, size)
                for _, line in ipairs(frame.nfLines) do
                    line:SetAlpha(0.55 + 0.45 * wave)
                end
            end
        end
        state.left = (state.left or 0) - (elapsed or 0)
        if state.left > 0 then
            return
        end
        local now = F.Now()
        if now and state.ran and (now - state.ran) < 0.2 then
            state.left = 0.2 - (now - state.ran)
            return
        end
        state.left = 0.35
        state.ran = now
        if F.questMarkErrorShown then
            pcall(scan)
            return
        end
        local ok, err = pcall(scan)
        if not ok then
            F.questMarkErrorShown = true
            F.Say("Quest marks could not be drawn. " .. tostring(err))
        end
    end
end
F.InstallQuestMarks()

F.REPAIR_AREAS = {
    ["stormwind city"] = true, ironforge = true, darnassus = true, ["the exodar"] = true,
    orgrimmar = true, ["thunder bluff"] = true, undercity = true, ["silvermoon city"] = true,
    ["shattrath city"] = true, dalaran = true, ["ruins of lordaeron"] = true,
    goldshire = true, ["sentinel hill"] = true, lakeshire = true, darkshire = true,
    ["menethil harbor"] = true, thelsamar = true, kharanos = true, astranaar = true,
    auberdine = true, ["feathermoon stronghold"] = true, ["nijel's point"] = true,
    ["theramore isle"] = true, gadgetzan = true, ["marshal's refuge"] = true,
    ["cenarion hold"] = true, ratchet = true, ["booty bay"] = true, everlook = true,
    ["light's hope chapel"] = true, ["chillwind camp"] = true, southshore = true,
    ["refuge pointe"] = true, ["aerie peak"] = true, ["morgan's vigil"] = true,
    ["nethergarde keep"] = true, ["the harborage"] = true, ["talonbranch glade"] = true,
    ["honor hold"] = true, ["temple of telhamat"] = true, telredor = true, telaar = true,
    ["allerian stronghold"] = true, sylvanaar = true, ["toshley's station"] = true,
    ["area 52"] = true, ["wildhammer stronghold"] = true, ["valiance keep"] = true,
    valgarde = true, ["westguard keep"] = true, ["fort wildervar"] = true,
    ["amberpine lodge"] = true, ["stars' rest"] = true, ["fizzcrank airstrip"] = true,
    ["wyrmrest temple"] = true, ["razor hill"] = true, ["bloodhoof village"] = true,
    ["the crossroads"] = true, ["camp taurajo"] = true, ["sun rock retreat"] = true,
    ["splintertree post"] = true, ["the sepulcher"] = true, ["tarren mill"] = true,
    hammerfall = true, kargath = true, ["grom'gol base camp"] = true, stonard = true,
    ["shadowprey village"] = true, ["freewind post"] = true, ["camp mojache"] = true,
    valormok = true, ["bloodvenom post"] = true, ["revantusk village"] = true,
    ["thorium point"] = true, mudsprocket = true, thrallmar = true, ["falcon watch"] = true,
    ["swamprat post"] = true, ["zabra'jin"] = true, ["stonebreaker hold"] = true,
    garadar = true, ["shadowmoon village"] = true, ["mok'nathal village"] = true,
    ["thunderlord stronghold"] = true, ["warsong hold"] = true, ["vengeance landing"] = true,
    ["camp winterhoof"] = true, ["conquest hold"] = true, ["agmar's hammer"] = true,
    venomspite = true, ["taunka'le village"] = true, ["moa'ki harbor"] = true,
}

function F.RepairLevel()
    local worst = 0
    if GetInventoryAlertStatus then
        for index = 1, 11 do
            local ok, status = pcall(GetInventoryAlertStatus, index)
            status = ok and tonumber(F.Plain(status))
            if status and status > worst then
                worst = status
            end
        end
    end
    if worst >= 2 then
        return "red"
    end
    if worst == 1 then
        return "yellow"
    end
    if not GetInventoryItemDurability then
        return nil
    end
    local slots = { 1, 3, 5, 6, 7, 8, 9, 10, 16, 17, 18 }
    local worn = false
    for index = 1, #slots do
        local ok, current, maximum = pcall(GetInventoryItemDurability, slots[index])
        current = ok and tonumber(F.Plain(current))
        maximum = ok and tonumber(F.Plain(maximum))
        if current and maximum and maximum > 0 then
            local pct = current / maximum
            if current == 0 or pct <= 0.1 then
                return "red"
            end
            if pct <= 0.25 then
                worn = true
            end
        end
    end
    if worn then
        return "yellow"
    end
    return nil
end

function F.RepairPlace()
    local zone = GetZoneText() or ""
    local sub = GetSubZoneText() or ""
    local mini = GetMinimapZoneText() or ""
    local function key(text)
        if type(text) ~= "string" then
            return ""
        end
        return string.lower(text)
    end
    local areas = F.REPAIR_AREAS
    if areas[key(sub)] then
        return sub
    end
    if areas[key(mini)] and mini ~= zone then
        return mini
    end
    if areas[key(zone)] then
        return zone
    end
    if GetZonePVPInfo then
        local ok, pvp = pcall(GetZonePVPInfo)
        if ok and F.Plain(pvp) == "sanctuary" and zone ~= "" then
            return zone
        end
    end
    return nil
end

function F.PlayRareSound()
    local kit = SOUNDKIT and (SOUNDKIT.RAID_WARNING or SOUNDKIT.READY_CHECK)
    if kit then
        pcall(PlaySound, kit)
    end
end

function F.RareName(name)
    name = F.Plain(name)
    if type(name) ~= "string" then
        return nil
    end
    name = string.gsub(name, "|c%x%x%x%x%x%x%x%x", "")
    name = string.gsub(name, "|r", "")
    name = string.gsub(name, "^%s+", "")
    name = string.gsub(name, "%s+$", "")
    if name == "" then
        return nil
    end
    if #name > 48 then
        name = string.sub(name, 1, 48)
    end
    return name
end

function F.RareNote(key, name, elite)
    local state = F.rare
    if not state or type(key) ~= "string" or not name then
        return
    end
    state.found = state.found or {}
    local row = state.found[key]
    if row then
        if elite then
            row.elite = true
        end
        return
    end
    state.found[key] = { name = name, elite = elite and true or false }
end

function F.RareUnit(unit)
    if type(unit) ~= "string" or not UnitExists or not UnitClassification or not UnitName then
        return
    end
    local existsOK, exists = pcall(UnitExists, unit)
    if not existsOK or not F.Plain(exists) then
        return
    end
    if UnitIsUnit then
        local sameOK, same = pcall(UnitIsUnit, unit, "player")
        if sameOK and F.Plain(same) then
            return
        end
    end
    if UnitIsPlayer then
        local playerOK, player = pcall(UnitIsPlayer, unit)
        if playerOK and F.Plain(player) then
            return
        end
    end
    if UnitPlayerControlled then
        local controlledOK, controlled = pcall(UnitPlayerControlled, unit)
        if controlledOK and F.Plain(controlled) then
            return
        end
    end
    if UnitIsDead then
        local deadOK, dead = pcall(UnitIsDead, unit)
        if deadOK and F.Plain(dead) then
            return
        end
    end
    if UnitIsFriend then
        local friendOK, friend = pcall(UnitIsFriend, "player", unit)
        if friendOK and F.Plain(friend) then
            return
        end
    end
    local classOK, class = pcall(UnitClassification, unit)
    class = classOK and F.Plain(class)
    if class ~= "rare" and class ~= "rareelite" then
        return
    end
    local nameOK, name = pcall(UnitName, unit)
    name = F.RareName(nameOK and name)
    if not name then
        return
    end
    local guid
    if UnitGUID then
        local guidOK, value = pcall(UnitGUID, unit)
        guid = guidOK and F.Plain(value)
    end
    local id
    if type(guid) == "string" then
        id = string.match(guid, "%-(%d+)%-%x+$")
    end
    local key = id and ("id:" .. id) or ("name:" .. string.lower(name))
    F.RareNote(key, name, class == "rareelite")
end

function F.RarePlates()
    if C_NamePlate and C_NamePlate.GetNamePlates then
        local ok, plates = pcall(C_NamePlate.GetNamePlates, false)
        if ok and type(plates) == "table" then
            for index = 1, #plates do
                local plate = plates[index]
                if type(plate) == "table" then
                    local unit = plate.namePlateUnitToken or plate.unit
                    if type(unit) ~= "string" and plate.GetAttribute then
                        local attrOK, attr = pcall(plate.GetAttribute, plate, "unit")
                        unit = attrOK and F.Plain(attr)
                    end
                    if type(unit) == "string" then
                        F.RareUnit(unit)
                    end
                end
            end
            return
        end
    end
    for index = 1, 40 do
        F.RareUnit("nameplate" .. index)
    end
end

function F.RareVignettes()
    if not (C_VignetteInfo and C_VignetteInfo.GetVignettes and C_VignetteInfo.GetVignetteInfo) then
        return
    end
    local listOK, list = pcall(C_VignetteInfo.GetVignettes)
    if not listOK or type(list) ~= "table" then
        return
    end
    for index = 1, #list do
        local infoOK, info = pcall(C_VignetteInfo.GetVignetteInfo, list[index])
        info = infoOK and F.Plain(info)
        local onMap = type(info) == "table" and F.Plain(info.onMinimap)
        local dead = type(info) == "table" and F.Plain(info.isDead)
        if type(info) == "table" and onMap ~= false and not dead then
            local atlas = F.Plain(info.atlasName)
            local elite = false
            local rare = false
            if type(atlas) == "string" and not string.find(atlas, "Loot", 1, true) then
                if string.find(atlas, "Kill", 1, true) or string.find(atlas, "Rare", 1, true) then
                    rare = true
                    elite = string.find(atlas, "Elite", 1, true) and true or false
                end
            end
            if not rare and Enum and Enum.VignetteType then
                local kind = F.Plain(info.type)
                if Enum.VignetteType.Rare and kind == Enum.VignetteType.Rare then
                    rare = true
                elseif Enum.VignetteType.RareElite and kind == Enum.VignetteType.RareElite then
                    rare = true
                    elite = true
                end
            end
            local name = rare and F.RareName(info.name)
            if name then
                local object = F.Plain(info.objectGUID)
                local id
                if type(object) == "string" then
                    id = string.match(object, "%-(%d+)%-%x+$")
                end
                local key = id and ("id:" .. id) or ("name:" .. string.lower(name))
                F.RareNote(key, name, elite)
            end
        end
    end
end

function F.RareFlush()
    local state = F.rare
    if not state then
        return
    end
    local found = state.found or {}
    state.found = nil
    state.known = state.known or {}
    state.names = state.names or {}
    local now = F.Now() or 0
    local sound = false
    local function cooling(row)
        return row and row.away and (now - row.away) < 180
    end
    local function here(row)
        return row and not row.away
    end
    for key, info in pairs(found) do
        local lower = string.lower(info.name)
        local known = state.known[key]
        local byName = state.names[lower]
        if here(known) or cooling(known) or here(byName) or cooling(byName) then
            state.known[key] = known or {}
            state.known[key].away = nil
            state.known[key].name = lower
            state.names[lower] = byName or {}
            state.names[lower].away = nil
        else
            if info.elite then
                F.Say("Rare elite nearby. " .. info.name .. ".")
            else
                F.Say("Rare nearby. " .. info.name .. ".")
            end
            sound = true
            state.known[key] = { name = lower }
            state.names[lower] = {}
        end
    end
    for key, known in pairs(state.known) do
        if not found[key] then
            if not known.away then
                known.away = now
            elseif (now - known.away) > 600 then
                state.known[key] = nil
            end
        end
    end
    for lower, row in pairs(state.names) do
        local still = false
        for _, info in pairs(found) do
            if string.lower(info.name) == lower then
                still = true
                break
            end
        end
        if not still then
            if not row.away then
                row.away = now
            elseif (now - row.away) > 600 then
                state.names[lower] = nil
            end
        end
    end
    if sound then
        F.PlayRareSound()
    end
end

function F.RareIndoors()
    if not IsInInstance then
        return false
    end
    local ok, inside, kind = pcall(IsInInstance)
    if not ok or not F.Plain(inside) then
        return false
    end
    kind = F.Plain(kind)
    return kind == "party" or kind == "raid" or kind == "arena" or kind == "pvp"
end

function F.RareScan()
    if not db or not F.Enabled("warnRare") or F.RareIndoors() then
        return
    end
    local state = F.rare or {}
    F.rare = state
    state.found = {}
    F.RarePlates()
    F.RareUnit("target")
    F.RareUnit("mouseover")
    F.RareUnit("focus")
    F.RareUnit("softenemy")
    F.RareUnit("softinteract")
    F.RareVignettes()
    F.RareFlush()
end

function F.RareSoon()
    if not db or not F.Enabled("warnRare") then
        return
    end
    local state = F.rare or {}
    F.rare = state
    local now = F.Now()
    if now and state.ran and (now - state.ran) < 0.4 then
        return
    end
    state.left = 0
end

function F.RareTick(elapsed)
    if not db or not F.Enabled("warnRare") then
        return
    end
    local state = F.rare or {}
    F.rare = state
    state.left = (state.left or 0) - (elapsed or 0)
    if state.left > 0 then
        return
    end
    state.left = 0.5
    state.ran = F.Now()
    if F.rareErrorShown then
        pcall(F.RareScan)
        return
    end
    local ok, err = pcall(F.RareScan)
    if not ok then
        F.rareErrorShown = true
        F.Say("Rare warning could not be read. " .. tostring(err))
    end
end

function F.NoteRepair()
    if not db or not F.Enabled("warnRepair") then
        return
    end
    if UnitIsDeadOrGhost("player") or F.OnTaxi() then
        return
    end
    local status = F.RepairLevel()
    if not status then
        F.repairPlace = nil
        return
    end
    local place = F.RepairPlace()
    if not place then
        F.repairPlace = nil
        return
    end
    if F.repairPlace == place then
        return
    end
    F.repairPlace = place
    if status == "red" then
        F.Say("Armor is failing. A repair is in " .. place .. ".")
    else
        F.Say("Armor is worn. A repair is in " .. place .. ".")
    end
end

local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("PLAYER_LOGIN")
events:RegisterEvent("PLAYER_ENTERING_WORLD")
events:RegisterEvent("EDIT_MODE_LAYOUTS_UPDATED")
events:RegisterEvent("ZONE_CHANGED")
events:RegisterEvent("ZONE_CHANGED_INDOORS")
events:RegisterEvent("ZONE_CHANGED_NEW_AREA")
events:RegisterEvent("PLAYER_DEAD")
events:RegisterEvent("PLAYER_ALIVE")
events:RegisterEvent("PLAYER_UNGHOST")
function F.WatchArrowEvent(event)
    if C_EventUtils and C_EventUtils.IsEventValid and not C_EventUtils.IsEventValid(event) then
        return
    end
    pcall(events.RegisterEvent, events, event)
end
F.WatchArrowEvent("SUPER_TRACKING_CHANGED")
F.WatchArrowEvent("QUEST_LOG_UPDATE")
F.WatchArrowEvent("QUEST_WATCH_UPDATE")
F.WatchArrowEvent("UNIT_QUEST_LOG_CHANGED")
F.WatchArrowEvent("QUEST_POI_UPDATE")
F.WatchArrowEvent("USER_WAYPOINT_UPDATED")
F.WatchArrowEvent("WAYPOINT_UPDATE")
F.WatchArrowEvent("PLAYER_STARTED_MOVING")
F.WatchArrowEvent("PLAYER_STOPPED_MOVING")
F.WatchArrowEvent("AREA_POIS_UPDATED")
F.WatchArrowEvent("MINIMAP_UPDATE_TRACKING")
F.WatchArrowEvent("ADDON_ACTION_BLOCKED")
F.WatchArrowEvent("ADDON_ACTION_FORBIDDEN")
F.WatchArrowEvent("PLAYER_LOGOUT")
F.WatchArrowEvent("UNIT_AURA")
F.WatchArrowEvent("DISPLAY_SIZE_CHANGED")
F.WatchArrowEvent("UI_SCALE_CHANGED")
F.WatchArrowEvent("UPDATE_INVENTORY_DURABILITY")
F.WatchArrowEvent("NAME_PLATE_UNIT_ADDED")
F.WatchArrowEvent("NAME_PLATE_UNIT_REMOVED")
F.WatchArrowEvent("PLAYER_TARGET_CHANGED")
F.WatchArrowEvent("UPDATE_MOUSEOVER_UNIT")
F.WatchArrowEvent("VIGNETTES_UPDATED")
F.WatchArrowEvent("VIGNETTE_MINIMAP_UPDATED")
F.WatchArrowEvent("PLAYER_REGEN_ENABLED")
events:SetScript("OnEvent", function(_, event, arg1)
    if event == "PLAYER_REGEN_ENABLED" then
        if F.worldPinDirty and F.RefreshWorldPin then
            F.RefreshWorldPin()
        end
        return
    end
    if event == "PLAYER_STARTED_MOVING" then
        eventMoving = true
        return
    end
    if event == "PLAYER_STOPPED_MOVING" then
        eventMoving = false
        return
    end
    if event == "MINIMAP_UPDATE_TRACKING" then
        F.GatherOnTracking()
        return
    end
    if event == "ADDON_ACTION_BLOCKED" or event == "ADDON_ACTION_FORBIDDEN" then
        F.GatherOnBlocked(arg1)
        return
    end
    if event == "PLAYER_LOGOUT" then
        F.GatherUnmute()
        return
    end
    if event == "UPDATE_INVENTORY_DURABILITY" then
        if F.NoteRepair then
            F.NoteRepair()
        end
        return
    end
    if event == "NAME_PLATE_UNIT_ADDED" or event == "NAME_PLATE_UNIT_REMOVED" or event == "PLAYER_TARGET_CHANGED" or event == "UPDATE_MOUSEOVER_UNIT" or event == "VIGNETTES_UPDATED" or event == "VIGNETTE_MINIMAP_UPDATED" then
        if F.RareSoon then
            F.RareSoon()
        end
        if event == "NAME_PLATE_UNIT_ADDED" or event == "NAME_PLATE_UNIT_REMOVED" then
            if F.QuestMarkSoon then
                F.QuestMarkSoon()
            end
        end
        return
    end
    if event == "UNIT_AURA" then
        if arg1 == nil or arg1 == "player" then
            F.WarnCampfire()
        end
        return
    end
    if event == "ADDON_LOADED" then
        if arg1 == addonName then
            F.InitDB()
        elseif arg1 == "TomTom" and db then
            C_Timer.After(0.5, F.SyncArrow)
        elseif arg1 == "Blizzard_WorldMap" then
            F.HookWorldMap()
        elseif arg1 == "OpenMap" then
            F.WatchOpenMap()
            if F.RefreshWorldPin then
                F.RefreshWorldPin()
            end
        end
        return
    end
    if not db then
        return
    end
    if event == "DISPLAY_SIZE_CHANGED" or event == "UI_SCALE_CHANGED" then
        F.OnScreenMode()
        return
    end
    if event == "PLAYER_LOGIN" or event == "PLAYER_ENTERING_WORLD" then
        F.gatherReady = true
        if F.QuietQuestItems then
            F.QuietQuestItems()
        end
    end
    if event == "PLAYER_DEAD" then
        F.GatherOnDead()
        F.MarkDeath()
        return
    end
    if event == "PLAYER_ALIVE" or event == "PLAYER_UNGHOST" then
        F.GatherOnAlive()
        F.MaybeArrive()
        F.UpdateNav()
        if F.NoteRepair then
            F.NoteRepair()
        end
        return
    end
    if event == "ZONE_CHANGED" or event == "ZONE_CHANGED_INDOORS" or event == "ZONE_CHANGED_NEW_AREA" or event == "PLAYER_ENTERING_WORLD" or event == "AREA_POIS_UPDATED" then
        if event ~= "AREA_POIS_UPDATED" then
            F.WarnArea()
            F.RecoverCorpse()
            if F.NoteRepair then
                F.NoteRepair()
            end
        end
        F.RefreshIndoorMap()
        if event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED_NEW_AREA" then
            C_Timer.After(0, function()
                F.RefreshIndoorMap(true)
            end)
            C_Timer.After(0.5, function()
                F.RefreshIndoorMap(true)
            end)
            C_Timer.After(1.5, function()
                F.RefreshIndoorMap(true)
            end)
        end
    end
    if event == "PLAYER_LOGIN" then
        F.InstallFlight()
        F.ApplyQuestDiamond()
        F.ShowEnemyPlates(true)
        F.TryApply()
        F.Greet()
        C_Timer.After(0, F.TryApply)
        C_Timer.After(0.5, F.TryApply)
        C_Timer.After(1.5, F.TryApply)
        C_Timer.After(1, F.SyncArrow)
        C_Timer.After(2, F.SyncArrow)
        C_Timer.After(2, F.WarnArea)
        C_Timer.After(2, F.WarnCampfire)
        C_Timer.After(1, F.RecoverCorpse)
        C_Timer.After(2, function()
            if db and tonumber(db.arrowScale) then
                F.SetArrowScale(F.Round(tonumber(db.arrowScale) * 100))
            end
        end)
        if not editModeHooked and EventRegistry and EventRegistry.RegisterCallback then
            editModeHooked = true
            pcall(function()
                EventRegistry:RegisterCallback("EditMode.Exit", function()
                    C_Timer.After(0, F.TryApply)
                end, addonName)
            end)
        end
        return
    end
    if event == "SUPER_TRACKING_CHANGED" or event == "USER_WAYPOINT_UPDATED" or event == "WAYPOINT_UPDATE" then
        if F.NoteTrackedQuest then
            F.NoteTrackedQuest()
        end
        if F.SyncArrow then
            F.SyncArrow()
        end
    end
    if event == "QUEST_LOG_UPDATE" or event == "QUEST_WATCH_UPDATE" or (event == "UNIT_QUEST_LOG_CHANGED" and (arg1 == nil or arg1 == "player")) then
        if F.NoteQuestItems then
            local ok, err = pcall(F.NoteQuestItems)
            if not ok and not F.questItemErrorShown then
                F.questItemErrorShown = true
                F.Say("Quest item tally could not be read. " .. tostring(err))
            end
        end
        if F.QuestMarkSoon then
            F.QuestMarkSoon()
        end
        if event ~= "QUEST_LOG_UPDATE" then
            return
        end
    end
    F.TryApply()
end)

SLASH_NAVIGATEFOREVER1 = "/nf"
SLASH_NAVIGATEFOREVER2 = "/navigate"
SLASH_NAVIGATEFOREVER3 = "/navigateforever"
SlashCmdList.NAVIGATEFOREVER = F.SlashCommand
SLASH_NAVIGATEFOREVERJOKE1 = "/nfjoke"
SlashCmdList.NAVIGATEFOREVERJOKE = function()
    F.TellJoke()
end
