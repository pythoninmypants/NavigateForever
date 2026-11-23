# Navigate Forever

Patch notes for what players can see. Newest first.

## 1.1.9

### November 22, 2026

#### Gathering HUD
- The HUD no longer paints a bigger copy of the minimap over the middle of the screen. The ground stays visible while you walk. Herbs, ore, and your marks float around your character, and the bars stay in the corner.

## 1.1.8

### November 21, 2026

#### Gathering HUD
- One key spreads the minimap over the middle of the screen around your character, with the ground see-through, so herbs, ore, and your remembered spots float around you while you ride. It works like FarmHud, so you won't need FarmHud too.
- The HUD turns with you, so a node ahead of you shows above your character. A faint ring marks its edge, and N, E, S, W letters circle it with north in red. Icons stay their normal size.
- The minimap goes back how it was when you close it.

#### Suggestions page
- A new Suggest tab in the settings has a link to Navigate Forever's comments on CurseForge. Click Copy link, press Ctrl+C, and paste it into your browser.
- There is also a box to write your idea in while you play. It is saved until you clear it, and Select all makes it easy to copy into the comment.

#### OpenMap
- With OpenMap installed, Alt-click the world map to drop Navigate Forever's pin. Ctrl-click is left to OpenMap for its own pins, which Navigate Forever used to block. Without OpenMap, Ctrl-click still works.
- Set the key under Key Bindings, then AddOns, then Navigate Forever, or type `/nf hud`. Clicks go through the HUD to the world.

## 1.1.7

### November 21, 2026

#### Breadcrumb trail

- Faint dots on the minimap show where you walked, the newest brightest. Follow them back out of a cave or a winding path.
- It keeps about the last mile, and starts over after a hearth, a portal, or a flight. The game hides your position inside dungeons and raids, so there is no trail in them.
- **Breadcrumb trail** under Travel on the Rings page turns it off. `/nf trail clear` wipes it.

#### Boat and zeppelin times

- Ride a boat or zeppelin and stand still on deck as it leaves. The addon saves that pier and how long the trip took, and the bar counts down the ride.
- After three rides from the same pier within a few hours, it knows how often ships leave. Stand on that pier and the bar counts down to the next one, such as "Boat to Auberdine   leaves in 1:20".
- A server restart moves the times. The next ride from that pier fixes them.
- **Boat and zeppelin times** under Travel on the Rings page turns it off. `/nf boats` lists what it has learned.

## 1.1.6

### November 21, 2026

#### Remembered herbs and ore

- Each herb you pick and each vein you mine is saved where you stood. Later it shows on the minimap as a faint dot, green for a herb and gold for ore. That works even while tracking is on the other kind, or off.
- Rest the cursor on a dot for the name, such as Peacebloom or Copper Vein, and how many times you gathered there.
- Every character on your account shares them. A character with only Herbalism sees the herbs, and one with only Mining sees the ore.
- **Remember herbs and ore**, under Gathering on the More page, turns the dots off. `/nf nodes` counts what's saved on this continent, and `/nf nodes clear` forgets them.

## 1.1.5

### November 21, 2026

#### Flight timer

- The clock on a route you have flown before was still guessing. It reads the route while the flight map is open, then counts down from how long that route actually took.
- One trip that ends early does not replace a good time. The clock uses the middle of your last few trips on that route.
- The first time on a route, the clock follows the path the bird flies, including the stops in between. If that first guess is short, it can catch up instead of sitting at 0:00.

## 1.1.4

### November 21, 2026

#### Your bobber

- A gold compass sits on your fishing bobber, so you can tell it from the ones around you. The splashes all sound the same, and the game never says which bobber moved, so the compass is how you pick out yours.
- Face the bobber. The game only draws it while you look at it. The compass stays still, and the splash is still the part that moves.
- While the line is out, the game is allowed to show that bobber. A few seconds after you stop, that goes back to how you had it.
- **Your bobber** on the Map page turns the compass off.

## 1.1.3

### November 21, 2026

#### Item uses

- Rest the mouse on an item in your bags, in loot, or on a chat link. If a quest in your log still needs it, the tooltip names that quest and your progress, such as 3/8. Once you have enough and the quest is still in your log, it says done.
- Meat, fish, eggs, and other cooking goods name the dish. Stringy Wolf Meat says Charred Wolf Meat and Spiced Wolf Meat. A spice used in a lot of dishes says how many, instead of listing every one.
- **Item uses** on the Messages page turns those lines off.

#### Timer

- The timer message can go to Say, Yell, General chat, Trade chat, or Whispers. General and Trade only show when that channel is open where you are.
- Choose Whispers and type up to three full character names, such as Nek Thane. The alarm whispers those people on its own.
- If the name belongs to a Battle.net friend's character, the timer sends a Battle.net whisper, so it reaches them on any realm. For anyone else on another realm, add the realm, like Nek Thane-RealmName.
- The game only lets an addon post in Say, Yell, General, or Trade after a click. When the alarm goes off, a window shows your message with a Send button. Click it to post.
- The timer only says a message was sent once it shows in chat. If a name is wrong or that person is offline, it tells you.
- The timer window, its buttons, and the Send window use the colors and border of your theme.

## 1.1.2

### November 21, 2026

#### Timer

- A Timer button sits on the bar, to the right of the settings gear. The mail icon stays on the right side of that bar.
- Click it to set hours, minutes, and seconds. The window uses the same theme as the rest of Navigate Forever. Drag it to move it. The button counts down, then plays an alarm. Right-click the button to stop it.
- You can type a message for the alarm to send. The list only shows channels that are open where you are, such as Say, Yell, Party, Raid, Guild, and the zone channels you have joined. General and Trade change as you move. The message is sent the same way as if you typed it in chat. If that channel is gone when the alarm goes off, the message stays on your screen.
- Repeat starts the same timer again after each alarm.
- `/nf timer` opens it. `/nf timer 5` starts five minutes. `/nf timer 1:30` starts one minute and thirty seconds. `/nf timer stop` cancels it.

## 1.1.1

### November 20, 2026

#### Boats and zeppelins

- The zeppelin between Undercity and Grom'gol, and the boat between Feathermoon and Feathermoon Dock, never finished. After you landed, the arrow stayed on the boarding step and the walk after the dock never started. Both stops are on the same continent, and the route was waiting for the continent to change. It moves on now, once you reach the other stop. The ride back does the same.

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
