# Navigate Forever

A bigger square minimap for WoW Forever, by BigBrandDeluxe.

Navigate Azeroth Your Way.

The game draws one square minimap. Dragging the corner scales that whole square, so the terrain and the border grow together. The mouse wheel still zooms.

## Features

- Navigation bar with the zone, your coordinates, the direction you are facing, and a pin
- Glowing skull on the minimap where you died, for corpse runs and hardcore
- Bigger square minimap that follows your resolution, so it stays a similar size on a 1080p, 1440p, or 4K screen
- Drag the gold corner to scale it
- The map fades while you move or fight, then comes back when you stop
- Hold Right Alt and drag to reposition, then lock it so clicks still reach the map
- Three range rings, at 20, 40, and 60 yards, each with its own distance and color
- Find Herbs and Find Minerals take turns, so both show up while you gather
- A ping on the minimap when your cursor is on a herb or ore dot
- A chat line and a sound when you stand at a campfire
- Short notes when you enter places such as murloc territory, danger areas, and PvP zones
- A chat line and a sound when a rare is close enough to show a nameplate, or when a rare mark is on the minimap
- A gold arrow that points at your pin, your corpse, or a tracked quest. Drag it to move it
- The game's yellow quest diamond, shown in the world over your tracked quest. Turn it off on the Map page
- A pulsing gold quest icon and glow on the nameplate of a creature you still need for a quest, with your progress next to it. Enemy nameplates have to be on. Objects such as crates can't be marked
- One click for the nearest mailbox, inn, repair vendor, general vendor, or flight master
- Find a city, inn, flight master, boat, or zeppelin by name
- On a flight, the bar counts down the time left. After you fly a route once, it uses that route's real time
- A long route can walk you to a flight, boat, zeppelin, or hearth instead of pointing across the ocean
- Thirty themes under **Theme** on the More page: Default, Classic UI, Horde, Alliance, Arcane, Frost, Fire, Kitty, one for each class (Warrior, Paladin, Hunter, Rogue, Priest, Shaman, Mage, Warlock, and Druid), one for each race (Human, Dwarf, Gnome, Night Elf, Orc, Troll, Tauren, Undead, and Skyborne), and four holidays (Hallow's End, Winter Veil, Lunar Festival, and Love is in the Air). Each one past Default has its own painted logo, corner pieces, and animated effects
- Settings saved between sessions

## Install

The CurseForge app installs it for you. In the app, select the **Forever** version of World of Warcraft, then install Navigate Forever. The file is for game version **1.60.1**.

To install the zip by hand:

1. Close the WoW Forever client.
2. Extract the zip so the TOC sits here:

`World of Warcraft\_forever_\Interface\AddOns\NavigateForever\NavigateForever.toc`

3. Start the client. A new addon is picked up on a full start.

## Use

The minimap starts a bit bigger than normal, at full opacity, with the position locked so clicks still reach the map.

- The bar above the map shows the zone, your coordinates, and the direction you are facing.
- Ctrl-click the map to drop a pin. The bar then shows how far away it is, and which way to go. The arrow points there. Pin and Clear do the same thing.
- Mail, Inn, Repair, Vendor, and Flight sit above the bar. One click points you at the nearest one your faction can use.
- Find asks for a name. `/nf find goldshire` does the same. Cities, inns, flight masters, boats, and zeppelins are in that list.
- If the place is far, the arrow points at the next step. That can be a walk to a flight master, a flight, a boat, a zeppelin, or your hearth when it is ready. Drag the arrow if it covers the middle of the screen.
- When you die, a glowing skull marks that spot. On a long corpse run it sits on the edge of the minimap and points the way. The bar shows the distance. It clears when you reach the body. **Clear at spirit healer** on the More page also removes it if you resurrect there. `/nf death` removes it sooner.
- Drag the gold corner to make the square bigger or smaller. The square, the bar above it, and the settings window follow your resolution, so they stay a similar size on a 1080p, 1440p, or 4K screen. The window also shrinks to stay on screen.
- Hold the Right Alt key and drag the map to move it. Right Alt is the Alt key on the right side of the space bar.
- `/nf`, or the gear button beside Pin and Clear, opens four pages: Map, Rings, Messages, and More. Reset sits at the bottom of every page.
- **Theme** on the More page changes the colors, the logo, and the corner pieces. **Default** is navy and gold. **Classic UI** looks like part of the game itself: the game's own dark dialog background, gold metal corners, gold titles, and no animation. **Undead** has bone corners and green spores, **Horde** has iron corners and embers, **Alliance** has gold corners and motes of light, **Night Elf** has vine corners and wisps, **Arcane** has rune corners and sparkles, **Frost** has icicle corners and snow, and **Fire** has molten corners and embers. The class themes use the class colors: **Warrior** has riveted iron and sparks, **Paladin** has holy gold and falling stars, **Hunter** has a wolf and blowing leaves, **Rogue** has daggers and poison bubbles, **Priest** has winged gold and drifting feathers, **Shaman** has a totem and crackling lightning, **Mage** has a spellbook and rising stars, **Warlock** has a fel skull and wandering wisps, and **Druid** has a bear in autumn leaves and fireflies. **Kitty** is hot pink, with a cat-eared gamer girl buried in kittens, three kittens playing on every corner, and a stream of cat faces, hearts, and paw prints. The races each have their homeland: **Human** has a lion crest and golden Elwynn leaves, **Dwarf** has a hammer and anvil and Dun Morogh snow, **Gnome** has brass pipes and spinning gears, **Orc** has a tusked war mask and Durotar dust, **Troll** has a voodoo mask and teal wisps, **Tauren** has a painted bull skull and tumbling feathers, and **Skyborne** has a marble wing around a wind crystal and feathers on the wind. The holidays have their own looks too: **Hallow's End** has a jack-o'-lantern and bats, **Winter Veil** has presents and snow, **Lunar Festival** has a red lantern and gold fireworks, and **Love is in the Air** has a ribboned heart and rising hearts. A theme also sets the menu and border colors, and you can still change those after. Each character remembers its own theme and colors, so your Hunter and your Paladin can each keep their own look. A character you haven't picked a theme on starts with the one you used last. Uncheck **Animations** to keep everything still.
- Uncheck **Lock position** if you want a plain left-drag to move the map.
- **Quest diamond**, beside it, shows or hides the game's yellow diamond over your tracked quest.
- **Quest marks**, under the lock, puts a gold quest icon and glow on the nameplate of a creature you still need for a quest, with your progress, such as 3/8 Kobold Vermin. While it's on, enemy nameplates turn on when you log in. Uncheck it to turn the marks off.
- Drag any of the bars above or below the map to move it. That works even while the position is locked.
- Mouse wheel still zooms.
- Three range rings sit around you on the minimap, at 20, 40, and 60 yards. In `/nf`, each ring can be turned off, set to a new distance, or given its own color.
- With both Mining and Herbalism, Find Herbs and Find Minerals take turns so both kinds of node show on the minimap. The game still allows only one at a time. The swap starts at every 4 seconds. Change it under **Gathering** on the More page. `/nf gather off` turns it off. With only one of those professions, tracking stays as you set it.
- A herb or ore node pings when your cursor is on its dot, green for a herb and gold for ore. **Ping the map** in `/nf` turns that off. `/nf gather ping` does the same. The ping is only on your map.

Opacity, size, position, and range rings are remembered for every character.

## Slash commands

| Command | What it does |
| --- | --- |
| `/nf` | Open or close the settings window. `/navigate` and `/navigateforever` do the same. |
| `/nf lock` | Toggle the position lock. `/nf lock on` and `/nf lock off` set it. |
| `/nf unlock` | Allow left-drag to move the map. |
| `/nf alpha 80` | Set opacity to 80%. |
| `/nf size 150` | Set the size to 150%. |
| `/nf clear` | Remove the pin. |
| `/nf mail` | Point at the nearest mailbox. `/nf inn`, `/nf repair`, `/nf vendor`, and `/nf flight` do the same for those. |
| `/nf find goldshire` | Point at a city, inn, flight master, boat, or zeppelin by name. |
| `/nf death` | Remove the death marker. |
| `/nf marks` | List what quest marks see on the nameplates around you, to find out why a creature has no mark. |
| `/nf gather` | Turn the herb and ore swap on or off. `/nf gather 4` sets how many seconds each one stays on. `/nf gather ping` turns the node ping on or off. |
| `/nf reset` | Restore the original size, opacity, position, range rings, and gathering swap. |
| `/nf buttons` | Print the minimap frames. Use this if a button sits in the wrong place. |

## What you should see

After the first install, fully restart the client, then:

- The minimap is a bigger square, and the player arrow stays centered.
- The gold corner changes the size of that square. The mouse wheel still zooms.
- `/nf` changes opacity. A `/reload` keeps the size, opacity, position, and range rings.
- Three rings sit around you. In `/nf`, a ring can be turned off, moved to a new distance, or recolored.
- The zone name, tracking button, and mail icon are visible and clickable.
- With both Mining and Herbalism, the tracking icon swaps between herbs and ore. `/nf gather off` stops it.
- A herb or ore node pings when your cursor is on its dot. **Ping the map** in `/nf` turns that off.
- Standing near a campfire prints a line and plays a sound when the Campfire Nearby buff is on you. **Campfire alert** on the Messages page turns that off. The list beside it picks the noise.
- A rare nearby prints a line and plays a raid warning. **Rares nearby** on the Messages page turns that off. The same rare stays quiet until you leave and it is gone.
- If a button is missing or covering the map, run `/nf buttons` and keep the chat text.
