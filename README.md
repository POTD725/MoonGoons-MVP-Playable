# MoonGoons MVP Playable

A self-contained Godot 4.7 playable MVP of MoonGoons.

This repository focuses on the active station-management loop:

- Repair and upgrade station rooms
- Persistent real-time operations that continue while closed
- Construction Bay capacity: start with 1 and unlock up to 4 through Chief Office and Research levels
- Dedicated permanent 1/1 Research Lab
- Troop training, healing, patrols, and alliance rallies
- Player Store with in-game Credit purchases
- Daily and Weekly Alliance Stores with Alliance Tokens
- 1, 5, 30, and 60-minute category and universal speedups

## Open and play

1. Install Godot 4.7.
2. Clone or download this repository.
3. Import `project.godot` in Godot.
4. Press **Play**.

## Important scope

This is an offline/local playable MVP. Credits, Alliance Tokens, timer state, store claims, and progression are stored locally in `user://moongoons_mvp_save.json`. It does not contain real-money checkout, multiplayer, accounts, or cloud synchronization.
