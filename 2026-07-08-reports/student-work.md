# Student Work — Overview

Workshop of 2026-07-08, 30 provisioned dev environments (`vcenv-vm-1` … `vcenv-vm-30`). 20 environments show pi coding-agent activity and have a full report; 10 environments (VMs 1–4, 6–10, 12) were never used and have no report. Nearly all students worked in German, gave short plain-language prompts, and let the agent write all code.

| Student | Project outcome | Status |
|---|---|---|
| [student-5](student-5/report.md) | "Obstacle Drive" top-down driving game | ✅ working |
| [student-11](student-11/report.md) | Restaurant landing page (reverted) | ⚠️ reverted to starter |
| [student-13](student-13/report.md) | "KI Früchte-Auswahl" AI fruit shop | ✅ working |
| [student-14](student-14/report.md) | "Eileen & Alina" quiz | ✅ working |
| [student-15](student-15/report.md) | "Jump Adventure" Mario-style game | ✅ working |
| [student-16](student-16/report.md) | Luxury Chinese restaurant menu | ✅ working |
| [student-17](student-17/report.md) | Restaurant → hotel site (deleted) | ❌ lost, site down |
| [student-18](student-18/report.md) | Connect Four with win spectacle | ✅ working |
| [student-19](student-19/report.md) | "Döner-Stand" order game | ✅ working, on GitHub |
| [student-20](student-20/report.md) | "Fake Snake" | ⚠️ renders, gameplay broken |
| [student-21](student-21/report.md) | Flower grow-and-gift game | ⚠️ renders, logic crashes |
| [student-22](student-22/report.md) | Pong (after ~24 discarded ideas) | ✅ working |
| [student-23](student-23/report.md) | "Tank Battle" arcade game | ✅ working, on GitHub |
| [student-24](student-24/report.md) | Spaceship survival game | ✅ working |
| [student-25](student-25/report.md) | "Vier Gewinnt" (Connect Four) | ✅ working |
| [student-26](student-26/report.md) | "Kebap König" landing page | ✅ working |
| [student-27](student-27/report.md) | "Bumblebee Spike Run" jump-and-run | ✅ working |
| [student-28](student-28/report.md) | Tetris (last of ~9 games) | ✅ working |
| [student-29](student-29/report.md) | Three games, all reset | ⚠️ reset to starter |
| [student-30](student-30/report.md) | TicTacToe, "ultrapink" (teacher demo) | ✅ working |

---

## [Student 5](student-5/report.md) — Obstacle Drive (driving game)
In one session (6 German prompts) the student pivoted from a fruit-cutter idea via a racing game to a working top-down obstacle-dodging driver with a distance score. Classic "wish machine" usage: refinement by describing the desired feel ("make it more realistic"), never touching code. The very last request (halve the car speed) was never applied — the session ended before the agent wrote the change.

## [Student 11](student-11/report.md) — "Magenschmaus" restaurant page (reverted)
Built a gold-on-black landing page for a fictional Austrian home-cooking restaurant in a single session, notably starting by asking the agent for *ideas* rather than a finished product, then iterating on elegance and a custom SVG wordmark. All files were reverted to the starter ~9 minutes after the session; only the orphaned logo SVG remains, and the live site shows the default starter again.

## [Student 13](student-13/report.md) — "KI Früchte-Auswahl" AI fruit shop
Started with a fruit-catching game, then pivoted abruptly to an "AI" fruit shop with budget slider, recommendation logic, bite effect, and cart. Real friction in the second half: the agent corrupted the HTML twice (broken build, accidentally deleted fruit list) and the student had to insist on repairs. Final site works, with one leftover duplicate container.

## [Student 14](student-14/report.md) — "Eileen & Alina" quiz
A personalised 13-question multiple-choice quiz about two friends, built through dozens of tiny playful requests (pink clouds, floating "67"s, glitter, a falling pink bird), dictating quiz content one question at a time. Survived two real blockers — a build-crashing half-finished `if` statement left by the agent, and a stretch where the agent stopped responding — and runs correctly now.

## [Student 15](student-15/report.md) — "Jump Adventure" (Mario-style)
Highly exploratory: cake site, cat game, make-up figure, car game, and anime character all came and went before the final pink-glitter jump-and-run. Noteworthy: the student spotted and reported genuine agent failures in their own words (corrupted emoji, literal `\n`/`\"` escape sequences leaking into the page). Works, apart from a broken emoji glyph as the player sprite.

## [Student 16](student-16/report.md) — "Shanghai Luxus Speisekarte"
After an exploratory game-shopping session (horse racing, Hay Day, mini golf, UNO), the student committed to a deliberately over-the-top luxury Chinese restaurant menu and iterated dozens of times — ever more expensive, more luxurious, rainbow colors, own uploaded photos, plus a bolted-on luxury hotel ad. A rare case of sustained content/art direction rather than feature requests.

## [Student 17](student-17/report.md) — "La Tavola" → "Villa Romantica" (lost)
The most ambitious website of the group: a rich Italian restaurant page (hero, gallery, menu, wine list, Impressum) reworked into a 5-star Tuscany hotel, including an own uploaded photo. Then the student typed *"lösche alles"* — the agent obediently deleted every project file including build tooling — and the follow-up "restore the website" could only produce a minimal placeholder, since nothing was versioned. Cautionary tale: the work is gone and the site is down.

## [Student 18](student-18/report.md) — Connect Four with escalating win effects
Built a working two-player "4 Gewinnt" quickly, then spent the rest of the session escalating the win celebration: screaming German TTS, thunderstorm, screen shake, cyclops laser show. Drove the agent with bare "ja" confirmations. Hit two content refusals (violence, real person) and two empty responses at the end, so the final rule change ("win with 2 in a row") never landed.

## [Student 19](student-19/report.md) — "Döner-Stand" order game
One of the strongest results: after trying board-game and runner ideas, the student invented an original concept — assembling kebab orders from ingredient bowls against a timer for money — and refined it across 16 sessions with dozens of small, concrete change requests. Fully working, polished, and pushed to GitHub (`foodstand`) via the `gh` CLI.

## [Student 20](student-20/report.md) — "Fake Snake" (broken)
Imaginative idea-hopping (tree shredder, "find the perfect wife for Magguschhh", fishing, fake HayDay) ending in a mouse-steered snake that eats trees. Feature growth went well until a regression; the last third of the history is a failed debugging spiral where the agent added mountains of `console.log` instead of finding the actual bug (a one-character property typo that crashes the game loop). Start screen renders; gameplay is broken. Student engagement visibly faded at the end.

## [Student 21](student-21/report.md) — Flower grow-and-gift game (broken)
Two hours and 11 sessions of organic idea evolution: drawing canvas → pick flowers → plant a seed → a full multi-step game (plant, water, grow, cut, gift with confetti, collect in a book). The last hour was churn (add/remove/re-add buttons and images), and one removal request left the TypeScript referencing deleted HTML elements — the page looks polished but crashes on load. The agent's final message falsely claimed everything works; the student couldn't verify otherwise.

## [Student 22](student-22/report.md) — Pong (after ~24 game ideas)
The extreme explorer: 30 sessions in ~2 hours, nearly every one a new game idea (Connect Four, Snake, Pac-Man, horror maze, D&D, Minecraft, Uno, dino game, zombie shooters, Memory, Hello Kitty, Tetris, Geometry Dash, Roblox obbys, chess…). Eventually asked the agent "which games can I make / what should I do" — and its suggestion, Pong, became the final working app.

## [Student 23](student-23/report.md) — "Tank Battle"
Started as a Doodle Jump clone, pivoted to a top-down tank shooter that grew into a genuinely deep game: three modes (endless/wave/sandbox), mines, charged super bullet, pickups, obstacles, lobby, pause menu, high scores, godmode. Driven by a relentless stream of short, typo-laden English instructions and persistent bug-report follow-ups. Pushed to GitHub (`David463038/tankbattle`).

## [Student 24](student-24/report.md) — Spaceship survival game
The strongest example of concept drift: egoshooter → tank game → desert jeep driving game → top-down spaceship survival, with several from-scratch restarts along the way. Final game has a stopwatch, best-time persistence in localStorage, and synthesized Web-Audio music. Included one refusal-adjacent dead end (copyrighted YouTube music). Works.

## [Student 25](student-25/report.md) — "Vier Gewinnt" (Connect Four)
Built a working Connect Four quickly, then spent three of four sessions battling one stubborn CSS bug (board buttons collapsing to 0×0). Notable beginner behavior: uploaded a screenshot of the bug (`fehler.jpg`) and reported a manual workaround they had discovered themselves — real debugging collaboration. Final game is functional and polished, with names, colored discs, winner banner, and confetti.

## [Student 26](student-26/report.md) — "Kebap König" landing page
A coherent single-page site for a fictional kebab stand: menu with prices, opening hours, a World-Cup-2026 offers box, and a footballer "sponsors" box. Worked in many small, concrete visual steps and supplied their own image files for the agent to wire in. Showed persistence in nudging layout toward their mental picture when first attempts missed.

## [Student 27](student-27/report.md) — "Bumblebee Spike Run"
An elaborate 2D canvas jump-and-run (controllable bee, flower/bat hazards, flame projectiles, scoring, cooldown) built from a one-line brief and refined in taste-driven visual steps. Went furthest into real tooling: created a GitHub repo and a GitHub Pages deploy Action, hitting a Pages-not-enabled configuration error the agent could only partly resolve. Switched from English to German for the debugging/deployment sessions.

## [Student 28](student-28/report.md) — Tetris (last of ~9 games)
A rapid tour through popular-game clones (jump-and-run, Geometry Dash, Hill Climb, Slither.io, Three.js racing, Hole.io), each overwriting the last, ending with a working Tetris. Main friction was workflow, not code: repeatedly asked where to *see* the app ("wo öffnen"), with occasional frustration outbursts ("geht nichttt"). Prompts were short phonetic-German fragments.

## [Student 29](student-29/report.md) — Three games, all reset
Built a Flappy Bird clone (with a table, then a toilet, then a cucumber as the player), a Geometry Dash runner, and a lion jump-and-run — each arc ending in agent-induced breakage and the student's terse "repariere die website", which the agent often "resolved" by running a build and declaring success. Final act: "setze alles zurück" — the machine now holds only the bare starter. Also note: the public URL is blocked by the Vite `allowedHosts` config on this VM.

## [Student 30](student-30/report.md) — TicTacToe "ultrapink"
**Teacher's demonstration account** (presented on the beamer). Two clean sessions: build a TicTacToe, then restyle it "ultrapink". Served as the reference for what a smooth beginner session looks like.
