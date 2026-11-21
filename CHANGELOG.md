# Navigate Forever

Patch notes for what players can see. Newest first.

## 1.1.1

### November 20, 2026

#### Large map

- Step Daddymike reported this. Press M, drop a pin, and Navigate Forever saved it. The arrow still pointed the right way, but the mark never appeared on that map. It does now. The same gold square with the blue center from the minimap sits on the spot you clicked. Clear still removes it.

#### Quest diamond

- Step Daddymike reported this. Checking **Quest diamond** printed "This version of the game has no quest diamond," and the yellow diamond never showed over a tracked quest. Track a quest and the diamond shows in the world again. Uncheck the box to turn it off.

## 1.1.0

### November 19, 2026

#### Themes

- **Skyborne**: sky blue and pale gold. White marble wing and crescent around a wind crystal, marble corners with glowing wind runes, feathers and sparks blowing across.

#### Quest marks

- **Quest marks** on the Map page puts a pulsing gold quest icon and a gold glow on the nameplate of a creature you still need for a quest. That covers creatures you have to kill, and creatures that drop a quest item when the game's tooltip shows it. Next to the icon is your progress, such as 3/8 Kobold Vermin. The mark goes away once that objective is done.
- Friendly quest NPCs get marks too, such as one you need to talk to or escort, when the game says they're part of a quest. Their names over heads have to be on (Shift-V).
- Marks only show on creatures with a nameplate. While Quest marks is on, the addon turns enemy nameplates on when you log in. Objects such as crates and plants can't be marked, because the game doesn't let addons draw on them.
- `/nf marks` lists what the marks see on each nameplate nearby, to find out why a creature has no mark.

#### Quest diamond

- **Quest diamond** on the Map page turns on the game's yellow diamond, drawn in the world over the quest you track. It shows where an objective is or where to turn the quest in, without opening the map. It's on by default and works like typing `/console showInGameNavigation 1`.

#### Flight timer

- The time left on a flight no longer climbs at the start before counting down. If the estimate grows, the clock waits instead of going up.
- The first time you fly a route, the estimate follows the route's real path through other flight points, not a straight line to the end.
- After you land, the addon remembers how long that route took. The next time you fly it, the clock counts down from the real time.

### November 18, 2026

#### Themes

- **Theme** on the More page picks how the addon looks. **Default** is the navy and gold look.
- Every theme except Default has its own painted logo and its own corner pieces on the minimap and the settings window. All but Default and Classic UI also have drifting mist, a pulsing border, a flame behind the logo, and particles.
- **Undead**: grave black and plague green. Hooded skull, bone-and-skull corners, rising green spores.
- **Horde**: blood red and iron. War crest with crossed axes, spiked iron corners bound in red leather, rising embers.
- **Alliance**: royal blue and gold. Crowned lion shield, gold and sapphire corners, floating motes of light.
- **Night Elf**: moonlit purple and teal. Crescent moon in silver leaves, vine corners with moonstones, wandering wisps.
- **Arcane**: deep violet and cyan. Floating crystal in a rune ring, rune-etched corners, twinkling sparkles.
- **Frost**: icy blue and white. Ice crystal, frozen corners with icicles, falling snow.
- **Fire**: orange and flame. Phoenix, molten rock corners, big rising embers.
- A theme for each class, using the class color for the border:
  - **Warrior**: helm and crossed swords, riveted iron corners, quick sparks.
  - **Paladin**: holy shield and hammer, gold corners, slow falling stars.
  - **Hunter**: wolf with bow and arrows, wooden corners with leaves, leaves blowing across.
  - **Rogue**: hooded figure with poisoned daggers, leather corners, rising poison bubbles.
  - **Priest**: winged chalice, white and gold corners, drifting feathers.
  - **Shaman**: storm totem, stone corners, crackling blue lightning.
  - **Mage**: spellbook and staff, blue arcane corners, rising stars.
  - **Warlock**: horned fel skull, violet rune corners, wandering wisps.
  - **Druid**: bear in autumn leaves, branch corners, fireflies.
- **Kitty**: hot pink and lavender. Cat-eared gamer girl surrounded by five kittens, candy pink corners with three kittens climbing on them, and twice the usual particles: cat faces, hearts, and paw prints.
- **Classic UI**: made to look built into the game. The game's own dark dialog background, plain gold metal corners with a red gem, a gold compass portrait, gold titles with white highlights, and nothing animated.
- A theme for each race, alongside Undead and Night Elf:
  - **Human**: royal blue and gold. Lion shield with a crown, white stone corners, golden leaves blowing across.
  - **Dwarf**: bronze and stone. Hammer over an anvil shield, riveted granite corners, falling snow.
  - **Gnome**: teal and brass. Cog with a crystal core, brass pipe corners with gauges, spinning gears.
  - **Orc**: green and rust. Tusked iron war mask with axes, spiked log corners, blowing dust.
  - **Troll**: teal and orange. Voodoo tiki mask, bamboo corners with tusks, wandering teal wisps.
  - **Tauren**: tan and turquoise. Painted bull skull on a hide shield, totem corners with feathers, tumbling feathers.
- Four holiday themes:
  - **Hallow's End**: orange and purple. Jack-o'-lantern in a witch hat, iron fence corners with cobwebs, bats.
  - **Winter Veil**: red and green. Present and tree, snowy garland corners, falling snow.
  - **Lunar Festival**: red and gold. Red lantern and moon, lacquered corners, twinkling gold fireworks.
  - **Love is in the Air**: pink and gold. Ribboned heart and love potion, rose vine corners, rising hearts.
- A gear button to the right of Pin and Clear opens the settings window.
- Drag the zone bar, the button bar, or the coordinates bar to move the map, even while the position is locked.
- The coordinates move in from the edge on themes with corner pieces, so the art doesn't cover them.
- The theme list opens in three columns: the original themes with the holidays below them, the classes, and the races.
- Each character remembers its own theme and its menu and border colors. A character you haven't picked one on starts with the theme you used last.
- **Animations** beside the theme list turns the mist, pulse, flame, and particles off. They also rest while the map is faded and during combat.
- Picking a theme also sets the menu and border colors. You can still change those after. Reset goes back to Default.

### November 17, 2026

#### Rares

- A chat line and a raid-warning sound when a rare is close enough for a nameplate, or when a rare mark is on the minimap. The same one stays quiet until you leave and it is gone. **Rares nearby** on the Messages page turns it off.

### November 16, 2026

#### Arrow

- Navigate Forever draws its own arrow at the pin, the corpse, or a tracked quest. TomTom is no longer required for a direction.
- The arrow is a gold compass needle with a blue stone, drawn smooth instead of the old minimap triangle.
- Drag the arrow to move it. Arrow size in `/nf` changes that arrow.

#### Places

- Mail, Inn, Repair, Vendor, and Flight sit above the bar. One click points at the nearest one.
- Find, or `/nf find goldshire`, searches cities, inns, flight masters, boats, and zeppelins.
- A long trip points at the next step. That step can be a walk, a flight, a boat, a zeppelin, or your hearth when it is off cooldown.
- `/nf mail`, `/nf inn`, `/nf repair`, `/nf vendor`, and `/nf flight` do the same as the buttons.

## 1.0.0

First release for WoW Forever.

### November 15, 2026

#### Settings

- `/nf` is split into Map, Rings, Messages, and More. One group shows at a time, so the window is shorter.
- The text in that window is larger.

#### Icon

- The addon list icon, the bar, and the settings window use a gold compass with a blue pin.

### November 12, 2026

#### Resolution

- The minimap, the bar above it, and the settings window follow the screen resolution. A 1080p, 1440p, or 4K screen keeps them a similar size. The settings window also shrinks so the whole menu stays on screen. Changing the game's UI scale still changes how big they are.

#### Campfire

- A line in chat, and a sound, when the Campfire Nearby buff is on you. It plays once, then again the next time you walk up to a fire. **Campfire alert** in `/nf` turns it off. The list beside it picks the noise and plays the one you choose.

#### Gathering

- Find Herbs and Find Minerals take turns on the minimap. WoW Forever still shows only one at a time, so this swaps them for you.
- It is on by default when you have both Mining and Herbalism. The wait starts at 4 seconds. Change it in `/nf`, or with `/nf gather 4`.
- With only Mining, or only Herbalism, it does not switch tracking. Pings still mark the nodes for the profession you have.
- It stays quiet while you fight, cast, loot, or stand in a city. Pick a different tracker, such as Track Beasts, and the swap waits until you come back to herbs or ore.
- Turn it off with `/nf gather off` if another addon is already swapping them.
- A herb or ore node pings when your cursor is on its dot. Green for a herb, gold for ore. The ring draws on top of the map. Your group does not see that ping. **Ping the map** in `/nf` turns it off, and so does `/nf gather ping`.

### November 11, 2026

#### Minimap

- The leftover white ring from the round minimap no longer draws over the square corners.

#### Range rings

- Subtle circles around you on the minimap, at 20, 40, and 60 yards.
- Useful for pulls, ranged attacks, fears, and area farming.
- Each ring can be turned off, given a new distance, or given its own color in `/nf`.
- A ring hides while you are zoomed in past its distance. The rings stay visible while the map fades.
- Each ring has its yard number on it. The closest is gold, then blue, then green. Look just around your arrow. Zoom out if one is missing.
- The circles draw on top of the minimap, as a ring of dots, so the terrain cannot cover them.

#### Corpse run

- When you die, a glowing skull marks that spot. On a long corpse run it sits on the edge of the minimap and points the way. It clears when you reach the body, or when you resurrect at a spirit healer. `/nf death` removes it sooner.

#### Opacity

- The map fades on its own while you move or fight, then comes back when you stop.
- Standing still uses your normal opacity. Moving defaults to 50%. Combat defaults to 90%.
- Each of those can be changed in `/nf`, and the fade can be turned off.
- Pointing at the map, the bar, or the gold corner brings it back to full opacity.
- Dragging a slider previews that opacity on the map.

#### Bug fixes

- The addon failed to load, so `/nf` did nothing. The script had grown past the number of local variables WoW allows, and that is fixed.
- The movement fade was reading a speed value the client keeps private. That threw a Lua error every frame and the addon memory kept climbing. Movement now comes from the game's start and stop events.
- Rain notes were tied to the zone, so Elwynn and a lot of other places announced rain on a clear day. They only speak when it is actually raining.

### November 9, 2026

#### Minimap

- The minimap is a bigger square. Drag the gold corner to scale the whole square. The mouse wheel still zooms.
- Hold Right Alt and drag to move the map. The position starts locked so clicks still reach the map.
- A thin gold border sits on the map. Buttons and menus draw above it.
- Size, opacity, and position are remembered for every character.
- Opacity changes the map itself, not only the frame around it.

#### Navigation bar

- A bar above the map shows the zone, your coordinates, and the direction you are facing.
- Tracking, the calendar, the clock, and the addon button sit on the bar.
- Other addon minimap buttons are collected into that addon list instead of ringing the map.
- The bar keeps its layout when the square is resized.

#### Pins

- Ctrl-click the minimap to drop a pin. The bar shows how far away it is and which way to go.
- Ctrl-click the world map to pin a place that is not on the minimap.
- Pin and Clear do the same thing. `/nf clear` removes the pin.
- Dropping a pin prints a short line in chat.
- If TomTom is installed, its arrow points at the pin or your tracked quest. The arrow size is in `/nf`.

#### Area notes

- Entering certain places prints a short note in chat. Each kind can be turned off in `/nf`.
- Murloc territory, danger areas, PvP zones, sanctuaries, instances, elite areas, world bosses, and rain.
- Murloc notes use known murloc territories. A zone with no murlocs stays quiet.

#### Settings

- `/nf` opens size, opacity, lock, colors, area notes, and reset.
- Menu color and border color can be changed.
- `/navigate` and `/navigateforever` open the same window.
- `/nf lock`, `/nf unlock`, `/nf alpha`, `/nf size`, `/nf clear`, `/nf reset`, and `/nf buttons` work from chat.
