# Sources and provenance

Consulted 2026-09-29. These upstream links are mutable; this package is a development preview, not a claim of compatibility with every game or loader release.

- Lovely official manifest documentation: https://github.com/ethangreen-dev/lovely-injector/blob/master/README.md — module registration before `main.lua` and copy-append bootstrap mechanism.
- VanillaRemade reference mod: https://github.com/nh6574/VanillaRemade/blob/main/src/jokers.lua — factual Joker keys and rarity categories.
- VanillaRemade English localization: https://github.com/nh6574/VanillaRemade/blob/main/localization/en-us.lua — factual English names. Reference-mod prefix `j_vremade_` is mapped to vanilla `j_`; implementation code and descriptions are not distributed.
- Modding reference: https://github.com/nh6574/VanillaRemadeWiki/blob/main/Home.md — `G.P_CENTERS`, rarity indices, and localized names.
- Steamodded's UI integration: https://github.com/Steamodded/smods/blob/main/src/ui.lua — native `G.FUNCS.overlay_menu`, `create_UIBox_generic_options`, and `UIBox_button` usage patterns. Steamodded is not a dependency of this package.

The installed game's center registry remains authoritative for availability. This package preserves vanilla spellings such as `j_gluttenous_joker`, `j_selzer`, and `j_caino`. Baseline rarity filters are fixed to vanilla rarities even when another mod rebalances a center.

Version 0.2.0: shop factory, new-shop/reroll call sites, and CardArea.emplace were inspected directly in the user's installed Balatro executable. Game source stayed in local scratch files and is not distributed.
