# Student Work: Overview

Workshop of 2026-07-14 (afternoon), 20 provisioned dev environments (`vcenv-vm-1` … `vcenv-vm-20`). **15 environments (VMs 1–15) show pi coding-agent activity and have a full report**; VMs 16–18 were never used, and VMs 19–20 were the teachers' machines (excluded). Roughly 15 teenagers (ages 12–14, little to no prior coding experience) drove the pi agent to build small Vite + TypeScript sites and games. Almost all worked in German (vm-11 in English), gave short plain-language prompts, and let the agent write every line of code.

Compared with the July-8 group, this cohort leaned heavily toward **games**, especially Minecraft/voxel worlds (five of them: 2D block games, and full Three.js 3D worlds) and shooters, and pushed the agent into much larger single-file programs (several 400–600-line engines, two real Three.js 3D worlds). Twelve of the fifteen apps are fully working; three are partial (one broken game, one broken-image site, one that renders unstyled), and (unlike July 8) **nothing was lost to a "delete everything" reset**. One student (vm-12) even took their work to GitHub, authenticating the CLI and pushing to their own repo. The most common friction was the agent hitting its **output-length limit** on big rewrites (leaving files half-written), broken remote/placeholder images, and CSS edits that didn't cleanly land.

| Student | Project outcome | Status |
|---|---|---|
| [student-1](student-1/report.md) | "F1 Hub" Formula 1 info website | ⚠️ renders, driver photos broken |
| [student-2](student-2/report.md) | "Bot Messenger" rule-based multi-bot chat | ✅ working |
| [student-3](student-3/report.md) | "Lipizzaner Memory" (Spanish Riding School) | ✅ working |
| [student-4](student-4/report.md) | "Katzen Memory" cat memory game | ✅ working |
| [student-5](student-5/report.md) | "Blockcraft Lite" 2D Minecraft | ⚠️ shell renders, game crashes |
| [student-6](student-6/report.md) | "Block-Spiel" platformer / level-builder | ✅ working |
| [student-7](student-7/report.md) | Top-down arena shooter (after ~22 wiped ideas) | ✅ working |
| [student-8](student-8/report.md) | "Ranma 1/2" turn-based anime fighter | ✅ working |
| [student-9](student-9/report.md) | "Runner Dash" Geometry-Dash runner | ✅ working |
| [student-10](student-10/report.md) | "Rubbel-Los" scratch-card game | ⚠️ logic works, renders unstyled |
| [student-11](student-11/report.md) | "Neon Outpost" top-down shooter | ✅ working |
| [student-12](student-12/report.md) | "Blockwelt" 2D Minecraft (pushed to GitHub) | ✅ working |
| [student-13](student-13/report.md) | Three.js 3D voxel world | ✅ working |
| [student-14](student-14/report.md) | "Minecraft 3D" three.js world | ✅ working |
| [student-15](student-15/report.md) | Apple-device catalog with fuzzy search | ✅ working |

---

## [Student 1](student-1/report.md): "F1 Hub" Formula 1 website
After a discarded Tic-Tac-Toe and a brief race-simulator experiment, the student committed to a 2026-season Formula 1 information site: race results with podiums, team points with their own local logos, a tyre guide, and driver profiles. Worked in German with concrete visual requests. It renders and the logos/results work, but all 22 driver photos are broken (a missing `placeholder-driver.webp`) and the "open profile" popup is wired to nothing (the two features they pushed hardest for).

## [Student 2](student-2/report.md): "Bot Messenger"
A WhatsApp-style chat app with three distinct rule-based bots (Luna, Max, Sara) that "remember" the conversation using local reply logic. Built across seven short German sessions with steady refinement of the seeded answers. Fully working: asking a bot a question returns its scripted reply, and the personas/reset all behave.

## [Student 3](student-3/report.md): "Lipizzaner Memory"
A two-player memory game themed on the Spanish Riding School Vienna, using 13 of the student's own real horse photos. Session 1 used disliked stock placeholders, session 2 was a full reset to "hello world", and session 3 (33 turns) was the real rebuild. Fully working: turn-taking with keep-turn-on-match, scoring, a winner/draw screen, and auto-reshuffle.

## [Student 4](student-4/report.md): "Katzen Memory"
A polished 2-player cat-memory card game with real photos, a neon-pink theme, scoreboard, turn indicator, and confetti, built in one focused 34-turn German session. A clean, working single-screen game with no notable blockers.

## [Student 5](student-5/report.md): "Blockcraft Lite" (broken)
One very intense single session: an ambitious Space-Invaders build (operator login, shop, gems, leaderboard) that repeatedly hit the agent's output-length limit and broke, then a pivot to a genuinely elaborate 2D Minecraft (inventory, hotbar, crafting, caves, ores, biomes). The shipped game crashes on every render frame (`fillWorld()` places `snow`/`clay` blocks the `blockData` table doesn't define), so the UI shell shows but the game canvas stays blank. A lot of real code, but the final artifact is broken.

## [Student 6](student-6/report.md): "Block-Spiel"
A canvas platformer with a build mode: place red blocks, a gravity-bound player that can jump and lift, numbered pickups 1–10, and a goal platform. Four German sessions (a tic-tac-toe detour was abandoned). Fully working and playable.

## [Student 7](student-7/report.md): Top-down arena shooter
The busiest environment of the day: 23 sessions over ~4 hours, almost every one a fresh game idea (a refused "twerking Spider-Man", a refused Mario Wonder clone, several Minecraft attempts, a 3D voxel world, Flappy Bird, a labyrinth chase), with a "mach hello world" reset between most of them. The end state on disk is a coherent top-down arena shooter with genuinely non-trivial enemy AI (line-of-sight, strafing, lead-target prediction). Fully working; hit content guardrails four times and the output-length limit repeatedly.

## [Student 8](student-8/report.md): "Ranma 1/2" anime fighter
A turn-based one-vs-AI fighting game with a five-character Ranma 1/2 roster, eight skills, a battle log, and animated red attack effects, built in one persistent 90-minute session. The dominant struggle (the last third of the session) was character portraits failing to load (hotlinked wiki images); the agent added a "kein bild" fallback but never moved to local files. Fully playable.

## [Student 9](student-9/report.md): "Runner Dash"
Three back-to-back concepts (neon chess vs. AI → a 2D/3D Minecraft → a flight simulator) before a Geometry-Dash-style runner, which is what survives. The session's signature friction was a dozen-round loop trying to make touching a spike actually trigger "GAME OVER!", which does work in the final on-disk version. Fully working (with a duplicated CSS block as a visible scar of the edit struggle).

## [Student 10](student-10/report.md): "Rubbel-Los" (unstyled)
A scratch-card mini-game: hover the nine fields to reveal numbers, three matching = win. The game logic works, but the polished "gold ticket" `style.css` does not apply on the running site; the live page renders as plain unstyled HTML (a narrow single-column strip of cells). The student's final request (real left-click scratching over a lottery image) was proposed by the agent but never built.

## [Student 11](student-11/report.md): "Neon Outpost"
A top-down shooter (English throughout, 10 sessions) that grew into a genuinely deep game: enemies, a boss, stacking upgrades, and a local scoreboard. Fully working. (The live page carries a stray `type html>` at the top from a malformed doctype in the student's HTML.)

## [Student 12](student-12/report.md): "Blockwelt" 2D Minecraft
A depth-first builder: one project iterated across two sessions into a 2D Minecraft with mining/placing, a survival inventory, 2×2 crafting, and a second "crystal biome", with strikingly precise art direction from the student. They demanded the agent self-check its fixes, pasted real console errors for diagnosis, authenticated the GitHub CLI themselves, and pushed the game to their own repo (`Felix48692/minecraft-kinder_uni`). Fully working.

## [Student 13](student-13/report.md): Three.js 3D voxel world
Eight short false starts (2D Mario, flat Minecraft attempts, resets to Hello World), then one hour-long final session where the student opened with an explicit plan and technology choice and incrementally built a real Three.js 3D voxel world: WASD movement, mouse-look, first/third person, chunked infinite terrain, grass/sand biomes, trees, puddles, cacti, pyramids, and a step counter. Unusually systematic for a beginner. Fully working.

## [Student 14](student-14/report.md): "Minecraft 3D"
A three.js 3D world with a third-person red character on a grass-block field and a tree, built over two German sessions (one debugging turn phrased by an adult/mentor, and a late session at 18:20 UTC). Fully working: press Play and the character drops into the scene.

## [Student 15](student-15/report.md): Apple-device catalog
The most tooling-ambitious single session (60 turns, ~95 min): a fire-brigade site, an Express/SQLite API, and a multi-shop price comparison were all built and then removed, before the student settled on a German Apple-device catalog with typo-tolerant fuzzy search and category/price filters. The catalog and search work; leftover dead code makes a table-row click throw a (harmless) console error and `tsc` no longer passes.
