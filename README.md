# Market Catalog 0.3.0

Lovely-only Balatro mod. Browse all 150 vanilla Jokers and request one for the next ordinary shop slot, including Legendaries. Steamodded is not required.

## Update / install

Close Balatro. Extract the ZIP and replace the existing MarketCatalog folder in `%APPDATA%\Balatro\Mods` with this folder. Keep only one installed copy. The file should be `Mods\MarketCatalog\lovely.toml`. Restart Balatro after updating.

Lovely itself remains in the game installation directory. The user configuration remains in the Balatro save directory and is not overwritten by this update.

## Use

1. Start or continue a run and press F1.
2. Select a Joker; the menu displays its name beside Queued.
3. Close the menu. Enter the next shop, or reroll if you are already in a shop.
4. The next ordinary generated slot contains the requested Joker. Buy it using the normal shop controls and price.

Selecting a Joker does not immediately replace a visible card. Rerolls still cost their normal amount. One request delivers one card, then clears. A new selection replaces the previous request. Clear request cancels it.

Tutorial-forced cards and Tag-created cards have priority. If they occupy every generated slot, the request waits for another shop or reroll. Loading an existing saved shop does not replace its cards. Shop expansion that generates an ordinary slot can also fulfill the request.

The catalog exposes locked and undiscovered names and allows forced requests for those Jokers without modifying their unlock flags. Run-banned Jokers remain blocked and queued; choose another Joker or clear the request. Random mode preserves normal edition rolls and shop-modification Tags. Explicit editions skip ordinary shop-modification Tags for the requested card, preserving those Tags for other eligible cards; stickers and discounts still apply. The ordinary creation path handles pricing; no custom Legendary surcharge is added. Buying or using cards can affect normal game progression.

## Configuration

Edit `%APPDATA%\Balatro\market_catalog.cfg`, created on the first keyboard event after initialization:

```ini
hotkey = f1
```

Supported values are f1 through f12, case-insensitive. Restart after editing. Invalid values fall back to F1. This is a data-only file; Lua is never evaluated.

## Architecture

| File | Responsibility |
| --- | --- |
| src/data.lua | Explicit vanilla IDs, names, and baseline rarities |
| src/registry.lua | Lookup, runtime availability, localization, filters |
| src/config.lua | Config parsing and loading |
| src/core.lua | Run-owned queue and compare-and-clear acknowledgement |
| src/ui.lua | Native UI, filters, paging, queued status |
| src/shop.lua | Area/banned-key checks, reservation, placement acknowledgement |
| bootstrap.lua | Chained keyboard hook and idempotent initialization |
| lovely.toml | Module registration and surgical ordinary-shop creation patch |

The shop patch targets one create_card call in functions/UI_definitions.lua, shared by normal shop generation and rerolls in the inspected installation. It changes the selected slot's type to Joker and supplies the requested forced key before the original shop UI and Tag processing. It does not discard a randomly generated card or alter global center/rarity pools. The first eligible slot is used, avoiding additional RNG calls to select a slot.

A chained CardArea.emplace wrapper confirms placement before clearing the request. Unrelated areas and original return values are preserved. Requests belong to G.GAME and can be included in normal saves; menu selection does not force an immediate save. Baseline rarity filters remain fixed even if another mod rebalances cards. Modded Jokers are not included.

## Validation

Passed using the installed Balatro Lua runtime: registry, config, queue lifecycle, menu pagination/ownership, hotkey chaining, banned keys, reservation, acknowledgement, and wrapper return values. The Lovely pattern matched exactly once in the installed game source. Tests exercised the patched installed shop factory with mocked game objects, including Legendary creation, conversion of a playing-card slot, Tag priority, and tutorial priority.

To run portable mocked tests from this directory with Lua 5.1 or LuaJIT:

```text
luajit -e "dofile('tests/test.lua'); dofile('tests/shop.lua'); dofile('tests/editions.lua')"
```

The prior menu version was shown working in-game by the user. Version 0.2.0 shop delivery was confirmed working by the user. **Version 0.3.0 edition selection still needs an in-game check.** Before publication, verify new-shop and reroll delivery, purchase/pricing, save/load, controller navigation, all five Legendaries, and compatibility with the intended mod set. Another mod replacing the patched creation line or replacing hooks without chaining may conflict. Inspect Lovely logs for patch warnings after updates.

No game source or art is distributed. Choose a distribution license and author/release metadata before publication. See SOURCES.md and JOKER_IDS.md.

## Edition selection (0.3.0)

Click the Edition button to cycle through Normal, Foil, Holographic, Polychrome, Negative, and Random. Select your Joker, close the menu, and reroll or enter the next shop. You can also change the edition after selecting a Joker: the queued request updates immediately. The queued status shows both choices.

Normal guarantees no edition. Random uses vanilla edition rolls. Explicit choices use the game's edition setter and pricing, including the Negative edition behavior when purchased. Requests saved by older versions retain Random behavior. The selected edition is saved alongside the requested Joker in run state when the game saves.

An additional scoped creation patch selects the edition before the game's edition-animation events are scheduled. This avoids stale random-edition animation callbacks when requesting Normal. Automated checks cover all six choices, cost recalculation, Tag preservation, and queued-edition changes using the installed game's edition setter.
