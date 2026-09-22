# Hackathon coding report — 2026-09-13 SSH snapshot

The 30 redeemed environments were inspected over SSH for Pi conversations (`~/.pi/agent/sessions`) and the current `~/website` source. Five session files were found on two VMs; three websites differ from the starter, while 27 retain it. The recovered conversations are dated 11 September, and environment 22's website was modified on 12 September. The report date is the inspection date, not an attendance count. None of the 30 website folders is a Git repository.

| Environment | Pi history | Current website | Build check |
|---|---|---|---|
| 20 | 2 sessions | Pink and black Tic-Tac-Toe | Passed; proxy styling remains unverified |
| 22 | No session files | “AI That Judges Your Idea” | Passed; authoring history unavailable |
| 28 | 3 sessions | Linz events viewer | Passed; API loading failed in the transcript |

## Environment 20: Tic-Tac-Toe

The student asked for an “ultra pink and black” Tic-Tac-Toe game. The current source has a nine-cell board, alternating turns, win and draw detection, reset behavior, and the requested hot-pink styling. After viewing it through the dev-server proxy, the student reported seeing only black and white. The agent said it had corrected Vite's base path to `/proxy/8080/`, but the final `vite.config.ts` still sets `base: '/'`. The transcript contains no later successful visual check, so the proxy styling issue remains unresolved. A fresh remote `npm run build` succeeded.

## Environment 22: idea judge

The modified site has a 500-character idea form, character counter, verdict panel, scores, progress bars, and responsive styling. Its five verdicts cycle deterministically in `index.ts`; the available source does not show an AI-backed evaluation. A `dist/` directory existed before inspection, and a fresh remote build succeeded. The Pi sessions directory is empty, so there is no conversation evidence to explain how the site was made or to attribute it to Pi.

## Environment 28: Linz events viewer

Across three Pi sessions on 11 September (18 user prompts), the project moved from a dark-themed starter to a Three.js Linz terrain view, DXF/GML/STL model experiments, map and routing features, and finally a Boudicca.Events viewer. The current page fetches event data through four API endpoint variants and renders cards from the responses. The user reported API connection failure twice at the end of the transcript; successful data loading was not observed. Three.js dependencies, model assets, and some menu CSS remain although the final page no longer uses the model viewer. A fresh remote build succeeded.

## User mood and frustration

- **Environment 20:** The user started with an energetic, direct request for a “Bold design!” They became dissatisfied with the first visual result, writing, “It does not look great. Just black, white, no styling. Fix it!” They then supplied their access path to help troubleshoot. The frustration was specific to the missing pink styling; the short exchange does not support a broader claim of anger or disengagement.
- **Environment 28:** The user remained curious and persistent while trying 3D formats, maps, routing, and event data. They reported that the model view showed nothing, that a Linz overlay blocked visibility, and later pasted the event API connection error twice. Those are concrete sources of likely frustration. Requests to remove tabs and reverse changes may also reflect dissatisfaction with the growing interface, though they could simply be normal iteration; the transcript does not explicitly label the user's emotion.
- **Environment 22:** No Pi conversation is available, so the user's mood cannot be assessed.

**Dissatisfaction with the agent specifically:** Neither available transcript contains an explicit complaint about the agent's competence, behavior, reliability, or replies. Environment 20's “It does not look great” targets the rendered site; environment 28's complaints target blank views, an obstructing overlay, and failed event loading. The users were dissatisfied with some results the agent produced, but the evidence does not show that they were dissatisfied with the agent itself. Environment 22 cannot be assessed without conversation history.

All three modified websites passed `npm run build` on their VMs with Vite 8.3.0. Those checks generated or replaced `dist/`; they establish that the source bundles, not that the interface or external API works in a browser. Twenty-eight environments have no Pi session files (26 have no sessions directory and two have an empty one). Missing history does not prove that an environment was never used. Access codes, passwords, hosts, and raw transcripts are excluded.
