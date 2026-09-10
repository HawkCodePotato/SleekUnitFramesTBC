Sleek Unit Frames - TBC Anniversary
Version 0.22.41

0.22.41 FOCUS + COMBO POINTS + PREVIEW CONTENT
------------------------------------------------
- Adds a full Focus unit frame using the same compact visual language as Target of Target, with independent width, scale, position, profile persistence and Edit Mode participation.
- Adds target combo-point visualization for Rogue/Feral gameplay using TBC Anniversary's GetComboPoints API.
- Adds configurable preview counts for target buffs, debuffs, emphasized DoTs, party buffs/debuffs and combo points so layout testing can expose more real-world states.
- Refines the level-badge inner tint into a lower-opacity top-to-bottom gradient that fades darker toward the bottom.

0.22.40 LEVEL BADGE ACCENT VISIBILITY FIX
------------------------------------------
- Fixes the subtle difficulty-color wash added in 0.22.39 by anchoring the accent layer to the inner level pill and avoiding double alpha multiplication.
- Uses a restrained 14% difficulty-color tint so the effect is visible without overpowering the level badge.

0.22.40 LEVEL BADGE ACCENT TINT
--------------------------------
- Adds a very subtle difficulty-tinted inner wash to the level badge so it stands out a little more without becoming loud or glowy.

0.22.40 LEVEL BADGE FRAME MATCH
---------------------------------
- Replaces the brighter level-pill shadow treatment with a compact border derived from the selected portrait ring style.
- Keeps only a very faint 3px ambient shadow outside the harder 2px style-matched edge.
- Difficulty colors remain on the level text and existing level-pill accent; this change only improves separation from bright portrait rings.

0.22.40 LEVEL BADGE SHADOW POLISH
---------------------------------
- Adds a restrained two-stage shadow around the level indicator for better separation from bright portrait rings.
- Uses a tighter 2px core shadow plus a faint 4px soft shadow so the effect reads as depth rather than glow.

0.22.40 PORTRAIT RING WEIGHT + LEVEL PALETTE
--------------------------------------------
- Increases the visible portrait-ring accent to a consistent 3px radial weight so it visually matches the Simple player-corner ornament.
- Keeps the portrait background behind the avatar unchanged while only the ring colors follow Sleek dark / Retail gold / Cool silver.
- Normalizes level-badge difficulty colors into a SleekUF palette while still using Blizzard's TBC difficulty calculation for category thresholds.
- Yellow difficulty now uses the exact same gold as unit names; red/orange/green/gray are slightly tuned to sit more naturally with the addon's palette.

0.22.40 ORNAMENT THICKNESS + RING SCOPE
----------------------------------------
- Makes the Simple player-corner ornament evenly proportioned, with matching horizontal/vertical arms and a slightly thicker stroke.
- Restricts portrait ring style recoloring to the actual ring so the avatar background fill stays unchanged.

0.22.40 CORNER ORNAMENT + RESTING TUNE
------------------------------------
- Retires the larger image ornament and keeps only the cleaner Simple player-corner detail.
- Rebuilds the Simple ornament as a padded, straight L-shape and makes it inherit the selected portrait ring style.
- When resting, the Simple ornament now follows the same warm resting treatment as the portrait ring.
- Moves the Retail-inspired ZZZ sequence lower and nudges the large Z slightly right.

0.22.40 RESTING Z + CORNER ORNAMENT POLISH
-----------------------------------------
- Pulls the Retail-style sleeping Z sequence closer to the Player portrait and gives the three letters deliberately irregular final positions/sizes.
- Adds a tiny smooth curved drift to each Z's rise so the sequence feels more organic while preserving the staged Z, Z, Z timing and group pause/fade.
- Repositions/rotates the Simple Player corner ornament into the actual lower body-facing corner, forming a compact tilted chevron along the bottom/straight portrait edges.
- Nudges the Image ornament left and upward so it sits more naturally in the Player portrait corner.

0.22.40 RETAIL RESTING SEQUENCE + PLAYER CORNER STYLES
-----------------------------------------------------
- Refines the Retail floating-Z resting animation into a staged Z -> Z -> Z sequence: each letter rises in turn, all three pause briefly, then fade together before a very short restart gap.
- Replaces the Player corner ornament checkbox with None / Simple / Image ornament styles.
- Adds a procedural small tilted gold V detail for the Simple corner style while retaining the existing larger image ornament as an optional third style.
- Migrates the old v0.22.30 boolean ornament preference without changing existing saved-profile behavior.

0.22.40 EDIT MODE + RESTING + PORTRAIT STYLE PASS
--------------------------------------------------
- Integrates Sleek Unit Frames with the Blizzard Edit Mode lifecycle on TBC Anniversary 2.5.6: opening Edit Mode unlocks/preview-displays SleekUF frames and closing it safely restores the previous lock/preview state.
- Unlocked Player, Target, Target of Target and Pet movers can now be scaled with the mouse wheel; the Party Group mover scales all Party frames together. Shift+wheel uses a larger step.
- Adds a Retail-inspired resting indicator style with three animated floating gold Zs while retaining the existing gold glow/spark treatment. The original compact resting icon remains selectable.
- Adds portrait-ring style presets: Sleek dark, Retail gold and Cool silver.
- Adds an optional Player-only polished-gold lower corner ornament.
- All new options participate in the complete profile snapshot system automatically.

0.22.29 INDIVIDUAL MOVER RESTORE FIX
----------------------------------
- Fixes Player, Target, Target of Target and Pet movers not responding after the v0.22.28 persistence hardening.
- Returns individual dragging to Blizzard's native StartMoving/StopMovingOrSizing path while explicitly disabling user-placed layout-cache persistence.
- Normalizes every drag back into SleekUF's canonical TOPLEFT/UIParent SavedVariables coordinates immediately on release, preserving the hardened profile storage model.
- Party Group movement remains on its existing scale-safe custom mover.

0.22.29 PROFILE + POSITION PERSISTENCE HARDENING
-----------------------------------------------
- Replaces individual Frame:StartMoving() persistence with a scale-aware cursor-delta mover that keeps every unit frame anchored canonically to UIParent TOPLEFT at all times.
- Explicitly disables WoW's separate user-placed/layout-cache ownership for SleekUF unit frames so the client layout cache can no longer compete with SavedVariables after login.
- Fixes the v0.22.12-v0.22.27 scaled-position regression and deterministically repairs existing Pet and Target-of-Target anchors that were altered by that migration/save path.
- Restores the pre-regression scale-safe SavePosition conversion as a defensive fallback, while normal moves now save exact SetPoint offsets directly.
- Reasserts saved frame anchors after PLAYER_ENTERING_WORLD and performs a final layout flush on logout.
- Saving a profile now flushes the live frame anchors first, then rebuilds the snapshot from the complete supported settings schema so all positions, sizes, appearance, aura, portrait, PvP, combat, party and behavior settings are copied together.
- Loading older snapshots migrates their position storage into the canonical layout format without modifying the original saved snapshot.

0.22.27 COMBAT FLAIR LOAD FIX
----------------------------
- Fixes a TBC Anniversary UI error introduced by the new combat glow: a BACKGROUND texture used sublevel -9, but WoW only allows texture sublevels from -8 through 7.
- Moves the combat outer/inner glow layers to valid -8/-7 sublevels, restoring all unit-frame creation while preserving the new red resting-style combat glow and pet combat badge.

0.22.26 REST-STYLE RED COMBAT GLOW
--------------------------------
- Reuses the resting-state visual language for combat by adding layered red outer/inner portrait glows plus animated red sparks around Player and Pet portraits.
- Preserves the stronger red portrait-ring combat pulse restored in v0.22.25 and keeps the improved larger combat badge.
- Pet combat now uses the same red glow/spark treatment and combat badge, including a slightly stronger effect when the pet is actively targeted.
- Resting visuals remain gold and automatically stay hidden while the player is in combat.

0.22.25 COMBAT INDICATOR REFINEMENT
----------------------------------
- Restores the stronger pre-v0.22.24 red portrait-ring combat glow and pulse while keeping the improved larger combat badge styling.
- Adds the same combat badge to the Pet frame whenever the existing Pet combat indicator is active.
- Keeps Pet combat glow/targeting behavior intact and ties the new badge to the same Pet combat indicator setting.

0.22.25 WRAPPER BORDERS + LAYOUT PREVIEW + COMBAT BADGE POLISH
----------------------------------------------------------------
- Adds a neutral thin wrapper border to Player, Pet and Party frames with its own opacity control.
- Unlock + move automatically enables Preview missing units; locking automatically disables preview again.
- Enlarges and cleans up the player combat badge while reducing the pulse width and portrait combat-glow footprint.

0.22.25 FULL PARTY-MEMBER TARGET FRAMES
--------------------------------------
- Replaces the old portrait-only Party 1-4 target indicator with a compact full unit frame using the same Sleek Unit Frames portrait/body/bar language.
- Party target frames now show unit name, health percentage/value and the target's active mana/rage/energy/etc. resource bar.
- Party target portraits follow the global Animated 3D portraits option and use the same PlayerModel/static fallback logic as the primary unit frames.
- Party target frames are SecureUnitButtonTemplate buttons bound to party1target-party4target, so left-clicking them targets that unit even during combat.
- Uses secure unit watches for target-frame visibility and refreshes the mini frame from UNIT_TARGET plus health/power/name/portrait events.
- Right-side party auras reserve room for the complete mini target frame; below-frame aura layout remains unchanged.


0.22.22 PARTY FRAME EXPANSION
-----------------------------
- Adds optional custom/default PvP faction crests to PvP-flagged Party 1-4 members, without a countdown timer.
- Adds optional compact party-member target portraits using party1target through party4target and UNIT_TARGET updates.
- Adds a Party aura position setting with Right of frame and Below power bar layouts.
- Right-side party auras automatically reserve space for the mini target portrait when that feature is enabled.
- Below-frame party auras dynamically calculate icons per row from the party power-bar width.
- Party vertical spacing automatically reserves enough room for the configured below-frame buff/debuff limits, preventing Party 2-4 from overlapping aura rows.
- The unlocked Party Group mover now includes visible party target portraits and aura holders in its measured outline.

0.22.21 TARGET RELATION BORDER VISIBILITY FIX
---------------------------------------------
- Rebuilds all Target/Target-of-Target relation-border masks as a true 2 px perimeter ring around the complete wrapper, including top, bottom and straight edges.
- Moves the relation border to its own overlay frame above the header/health/power child frames but below the portrait, preventing the border from being hidden by child-frame draw order.
- Keeps background tint opacity and border opacity fully independent.

0.22.20 INDEPENDENT TARGET TINT + BORDER LAYERS
------------------------------------------------
- Fixes Target relation tint opacity so 0% now completely removes only the background relation tint.
- Fixes Target relation border opacity so it controls only the dark relation border and can no longer alter the background tint.
- Adds dedicated masked relation-tint and relation-border overlay layers instead of reusing BodyEdge, whose full rectangular surface could bleed its color through the semi-transparent wrapper interior.
- Adds corner-style-aware border-ring masks for Tight, Medium and Soft wrapper styles on both mirrored and non-mirrored frames.

0.22.20 TARGET RELATION BORDER
------------------------------
- Adds a darker relation-colored border around the complete Target and Target of Target parent wrapper.
- Reuses the wrapper's existing masked edge, giving an approximately 1 px border that follows the same rounded silhouette instead of adding a separate floating rectangle.
- Adds a dedicated Target relation border opacity setting, independent from the existing wrapper relation-tint opacity.
- Keeps the border substantially darker than the wrapper tint for clearer separation from the world background.

0.22.18 TARGET WRAPPER REACTION TINT
------------------------------------
- Replaces the isolated target-name reaction strip with a subtle reaction tint applied to the entire Target and Target of Target wrapper.
- Keeps the reaction cue visually integrated with the unit card so the portrait-side curve and wrapper silhouette remain coherent.
- Retains the existing Target relation tint opacity setting, now controlling the whole wrapper tint instead of only the old header fill.

0.22.18 FULL-WIDTH TARGET RELATION TINT
--------------------------------------
- Replaces the pill-shaped Target / Target of Target reaction strip with a full-width rectangular tint across the complete name area.
- Keeps the existing Blizzard-style friendly / neutral / hostile reaction hue logic while translating it into a darker, subtler Sleek Unit Frames treatment.
- Adds Target relation tint opacity (0-100%) under Target extras; 0% disables the tint. Default is 45%.
- Keeps target names gold so relationship is communicated by the background rather than changing the name text color.

0.22.16 TARGET REACTION HEADER TINTS
-----------------------------------
- Adds Blizzard-inspired reaction coloring to the Target and Target of Target name-bar backgrounds for faster at-a-glance identification.
- Uses UnitSelectionColor on BCC Anniversary, preserving the familiar blue player-controlled friendly/non-attackable state, green friendly NPC state, yellow neutral state, red hostile state and gray tap-denied state.
- Keeps Target and Target of Target names in the addon's gold text instead of coloring the name itself by reaction.
- Fixes player-controlled pets in sanctuary/city situations incorrectly receiving a hostile red name treatment.

0.22.15 FRIENDLY TARGET LEVEL COLOR CORRECTION
----------------------------------------------
- Friendly Target and Target-of-Target units now use the same normal gold level treatment as friendly party units instead of red/orange/yellow/green/gray difficulty colors.
- Difficulty colors are now reserved for neutral/unfriendly/hostile Target and Target-of-Target units outside safe areas.
- Target of Target evaluates its own friendliness independently, so it correctly switches to gold when the target's target is friendly.
- Keeps the city/resting/sanctuary suppression from 0.22.13/0.22.14 for non-friendly units.

0.22.14 FRIENDLY SAFE-ZONE LEVEL COLOR FIX
------------------------------------------
- Refines the 0.22.13 city/sanctuary level-color behavior so only neutral and unfriendly Target/Target-of-Target units collapse to the normal gold treatment.
- Friendly targets continue to use the normal red/orange/yellow/green/gray level-difficulty colors even while the player is resting or inside a sanctuary.

0.22.13 PVP TIMER + SAFE-ZONE LEVEL COLOR POLISH
------------------------------------------------
- Nudges the PvP countdown 2 px to the right for better visual centering over the custom crest.
- Adds a PvP timer text-color setting with Soft white and Gold choices; Soft white is the new default.
- Uses the normal gold level-badge treatment for Target/Target-of-Target while the player is resting in a city/inn or inside a sanctuary zone.
- Refreshes target level colors on resting and zone transitions.
- Moves the resting icon from the portrait corner to the far-right side of the player name bar.

0.22.12 PVP CREST POLISH + SCALED FRAME POSITION FIX
-----------------------------------------------------
- Moves the custom PvP crests slightly farther outward and down, mirrored between Player and Target, while keeping the 48px custom crest size.
- Moves the local PvP clear countdown from the name bar to the center of the PvP crest and uses pale high-contrast text with a thicker black outline/shadow.
- Fixes scaled-frame mover position saving by converting GetLeft/GetTop values from the frame's effective scale into UIParent coordinates before storing them.
- Adds a one-time repair for previously saved Pet and Target-of-Target positions that were most visibly affected by the scale-space bug; saved profile loads receive the same repair.

0.22.11 UNIT FRAME STARTUP HOTFIX
--------------------------------
- Fixes a regression in 0.22.10 where the PvP crest layout referenced a missing CUSTOM_PVP_ICON_TUNING table, causing ApplyUnitFrameLayout to abort and leaving all custom unit frames blank.
- Restores the intended ~75% custom PvP crest size and adjusted corner placement.
- Adds a defensive fallback tuning table so a missing PvP layout constant cannot prevent unit frames from loading again.

0.22.10 CUSTOM PVP ICON ROUTING FIX
----------------------------------
- Fixes the live PvP icon assignment so the custom/default style selector is actually used by Player and Target frames.
- Uses the custom Alliance, Horde and FFA 32-bit TGA assets from the addon's Media folder.
- Keeps the existing PvP placement and timer behavior unchanged.

0.22.8 CUSTOM PVP ASSET REPACK + CLIENT-RESTART NOTE
--------------------------------------------------
- Rebuilds the Alliance, Horde and free-for-all custom PvP textures directly from the final supplied artwork as 256x256 uncompressed 32-bit RGBA TGA files.
- Keeps the existing Custom PvP icon style toggle and fallback to Blizzard's original PvP icons unchanged.
- Important: newly added addon texture files are discovered when the WoW client starts; /reload alone cannot discover brand-new files. Fully restart the game after installing this version.

0.22.7 CUSTOM PVP CRESTS
------------------------
- Integrates the new custom PvP crest artwork directly into the addon for Alliance, Horde and free-for-all PvP states.
- Adds a new |cffffd200Custom PvP icon style|r setting so players can switch between the Sleek Unit Frames crests and the original in-game PvP icons.
- Defaults custom PvP icon style to enabled for new and migrated profiles.
- Preserves the existing PvP timer behavior and frame placement while swapping only the icon art.

0.22.6 ANIMATED PORTRAIT VIEWPORT ALIGNMENT
-------------------------------------------
- Reverts the experimental lower-corner cover that could create visible dark/solid artifacts around 3D portraits.
- Reverts the experimental animated-model viewport insets and returns PlayerModel to an uncropped viewport.
- Sizes the 3D PlayerModel viewport to the same inner square as the static portrait (portraitSize - 8) and centers it on the portrait.
- Adds a small ANIMATED_PORTRAIT_TUNING block near the top of UnitFrames.lua so width, height, X and Y can be adjusted quickly before /reload.

0.22.2 TRANSPARENT 3D PORTRAIT VIEWPORT
--------------------------------------
- Restores full-size animated portraits instead of the small inscribed-square viewport.
- Removes the rectangular animated-model glass layer that could tint the world outside the round portrait.
- Explicitly clears PlayerModel fog when supported so the model scene remains transparent.
- Slightly tightens the portrait camera and nudges the model upward so heads fill the available portrait height better.
- The 3D character itself may extend beyond the round ring; only the unwanted square background treatment is removed.


0.22.2 SAVED PROFILE SNAPSHOTS + AURA CONTROL + PARTY AURAS
----------------------------------------------------------------
- Profiles now separate the character's live working configuration from an
  explicit saved snapshot. The new Save current profile button stores the
  COMPLETE setup for the current character and can overwrite that restore point.
- Any saved character snapshot, including the current character's own snapshot,
  can be loaded later. Loading copies every Sleek Unit Frames setting: positions,
  sizes, scales, appearance, portrait options, aura behavior, combat indicators,
  text settings, visibility options and all other profile values.
- Existing character profiles are converted into initial saved snapshots once
  on upgrade, so the new workflow starts without throwing away prior layouts.
- Target aura limits are now configurable independently for buffs, regular
  debuffs and prioritized personal DoTs. Defaults remain 8 / 8 / 6.
- Aura corner roundness is configurable from 0% (square) to 50% (fully rounded),
  and the selected mask is shared by icon, border and cooldown swipe.
- Added optional buffs/debuffs beside Party 1-4 frames, with configurable icon
  size and independent buff/debuff limits. Timers continue to appear only on
  effects applied by the player/pet and follow the existing timer-category rules.
- Reworked animated 3D portrait containment. PlayerModel widgets cannot receive
  true circular texture masks, so their rectangular viewport is now fitted inside
  the portrait circle instead of using an opaque inverse cover. This prevents the
  black square from spilling outside the avatar ring.

WHAT CHANGED IN 0.9
-------------------
This pass focuses on matching the Retail reference silhouette much more closely.

- Player, Target and Pet now use a D-shaped portrait:
  - rounded on the outside
  - a hard vertical edge where the bars meet the portrait
  - no rounded bottom corner on the body-facing side
- Health and power no longer run behind the portrait. They begin at the portrait
  separator line.
- Name header is now genuinely translucent and uses a much more rounded capsule
  silhouette instead of the old opaque rectangular panel.
- Health/power bars have a square portrait-facing edge and rounded outer edge.
- Level display is now a compact modern pill on the rounded outer side of each
  portrait and is enabled by default.
- Added a player combat indicator:
  - red portrait-edge accent
  - separator turns red
  - small COMBAT text appears in the name header
- Added a Combat indicator toggle to /suf settings.
- The shape work uses bundled TGA alpha masks, so no external texture pack is
  required.



0.21.3 TARGET RAID MARKER
-------------------------
- Added the active raid/party target marker (star, circle, diamond, triangle,
  moon, square, cross or skull) to the custom Target portrait.
- The marker updates immediately when RAID_TARGET_UPDATE fires, without
  requiring a retarget.
- The marker sits on the upper inner corner of the Target portrait to avoid
  colliding with the leader crown, PvP badge and level tablet.

0.21.1 CLEAN 3D PORTRAITS + NEUTRAL POSE
-------------------------------------------
- Removed the opaque inverse portrait cover that caused a visible black square
  around every 3D portrait. PlayerModel is now allowed to render transparently
  against the game world while the existing frame border remains on top.
- Added a 3D portrait idle movement option under Appearance. It defaults off.
- With idle movement disabled, the model is frozen in animation 0 at frame 0
  for a calm neutral pose; if FreezeAnimation is unavailable, the addon safely
  falls back to SetPaused.
- Static fallback behavior for offline/unavailable units is unchanged.

0.21.0 FRAME RECOVERY + OPTIONAL ANIMATED 3D PORTRAITS
------------------------------------------------------
- Fixes the v0.20.2 regression that stopped all custom unit frames from being
  created. The name-bound helper is now declared before initial layout uses it.
- Long unit names are safely constrained to the header and remain single-line.
- Adds an opt-in Appearance setting: Animated 3D portraits.
- Uses PlayerModel/SetUnit to render live animated unit models for Player,
  Target, Target of Target, Pet and Party frames when the client can load them.
- Falls back instantly to the existing static 2D portrait for preview units,
  offline players, non-visible units, or any model that fails to load.
- A lightweight 2-second retry handles units becoming locally available after
  zoning or moving into the client's loaded world area.
- Animated models keep the existing custom portrait silhouette via matching
  inverse cover textures rather than becoming square model windows.
- The option defaults OFF for existing profiles.

0.20.1 PROFILE POSITION RESTORE FIX
-----------------------------------
- Fixed scaled Player/Target/Target-of-Target/Pet mover coordinates being saved
  in the wrong coordinate space.
- Fixes copied profiles where Pet and Target of Target could jump toward the top
  of the screen instead of restoring where they were placed on the source character.
- Legacy non-default individual-frame positions are repaired once on upgrade.
- Loading an older character profile also repairs its legacy coordinates before
  copying it into the active character profile.
- No profile reset is required.

0.20.0 PER-FRAME WIDTHS + SETTINGS REORGANIZATION
----------------------------------------------------
- Added independent width controls for Player, Pet, Target, Target of Target,
  and the shared Party 1-4 frames.
- Existing profiles inherit their old shared bar width for every frame type, so
  updating does not visually change an already tuned layout.
- Reorganized layout settings into a dedicated Frame dimensions card, pairing
  each main unit frame's width and scale.
- Moved Party width, Party scale and vertical gap into their own Party layout
  card to keep party-specific geometry together.
- Appearance now focuses on visual styling such as wrapper opacity, corners,
  health coloring, portrait size and fonts instead of layout dimensions.

0.19.5 PARTY GROUP SCALE-SPACE FIX
----------------------------------
- Fixed the Party Group mover using UIParent cursor deltas directly as offsets
  on scaled Party frames. Drag distance is now converted through each frame's
  effective scale, so the party stack follows the mouse 1:1.
- The Party Group outline is now measured from the actual rendered Party 1-4
  rectangles after converting their geometry into UIParent coordinates. This
  keeps every visible party frame inside the shared mover at any party scale.
- Party 1-4 still move as one group and retain their relative spacing.


0.19.4 PARTY MOVER COORDINATE FIX + COMPACT UNLOCK PANEL
---------------------------------------------------------
- Fixed the shared Party Group mover using scaled frame coordinates for its
  bounding box. The mover now follows the actual Party 1-4 stack exactly.
- Party dragging now uses cursor movement converted directly into UIParent
  coordinates and commits all four positions together on drag stop.
- Replaced the ornate unlock dialog with a smaller tooltip-style control panel:
  compact title/status row, concise instructions, clean divider and lock button.


0.19.3 PARTY GROUP MOVER + UNLOCK PANEL FIX
---------------------------------------------
- Party 1-4 now use one shared Party Group mover while frames are unlocked.
  Dragging that mover keeps the complete party stack together and preserves the
  relative spacing between all four party members.
- Individual Party 1/2/3/4 mover overlays are no longer shown.
- Increased Party vertical gap range from 0-60 px to 0-120 px.
- Rebuilt the floating unlock/Lock Frames helper panel with more breathing room,
  a proper lower action row and no overlapping hint/button text.

0.19.2 PARTY SPACING + CLASS COLOR SEPARATION
----------------------------------------------
- Added a Party vertical gap slider (0-60 px) in Frame scale. Party 1 remains
  the anchor while Party 2-4 are re-stacked below it.
- Existing profiles derive an initial spacing value from their current Party 1
  and Party 2 positions so updating does not unexpectedly move the frames.
- Hunter, Rogue and Shaman class-health colors are now more deliberately
  separated from each other and from green health / yellow energy / blue mana.

0.18.0 CHARACTER PROFILES
-------------------------
- Settings are now stored in an independent profile for each Character - Realm.
- The existing pre-0.18 settings are automatically preserved as the profile of
  the first character used after updating.
- Logging into another character automatically creates that character's profile.
- A new Profiles card in /suf settings lists other character profiles.
- "Load selected profile" copies all settings, scales and frame positions from
  another character into the current character after confirmation.
- Copied profiles are snapshots: changing one character afterward does not change
  the character it was copied from.

SETTINGS
--------
/suf                Open settings
/suf unlock         Unlock all custom frames
/suf lock           Lock all custom frames
/suf test           Toggle Target/Pet preview mode
/suf reset          Reset everything

The settings page includes Player/Target/Pet enable toggles and scales, smooth
bars, preview mode, level display, combat indicator, proportions, fonts, target
auras/castbar and bar text controls.

INSTALL / UPDATE
----------------
1. Close WoW or log out to character selection.
2. Replace the existing SleekUnitFramesTBC folder with the folder in this ZIP.
3. Install to:
   World of Warcraft\_anniversary_\Interface\AddOns\SleekUnitFramesTBC\
4. Start WoW and enable the addon.

V0.3 MIGRATION
--------------
Existing Player/Target/Pet positions, sizes and scales are preserved. v0.4 turns
the new level display and combat indicator on by default.

NOTES
-----
- Interface version: 20506 (TBC Anniversary 2.5.6).
- Secure unit buttons remain in use for Player, Target and Pet.
- PLAYER_REGEN_DISABLED / PLAYER_REGEN_ENABLED drive the player combat cue.
- Layout changes remain blocked/deferred during combat where protected frame
  operations would be unsafe.


0.5 REFINEMENTS
---------------
- Portrait shape now has a rounded top body-facing corner and square lower body-facing corner.
- Bar and header masks were regenerated with smoother anti-aliased edges.
- Added soft outer-end bar glow/highlight for a closer Retail feel.


0.6 REFINEMENTS
---------------
- Removed the hard portrait drop shadow.
- Health and mana now use separate trailing-corner masks for a closer Retail silhouette.
- Header is tighter and reaches back behind the portrait.
- Health and mana are stacked closer together with only a narrow separator.


0.7 REFINEMENTS
---------------
- Lowered the header/health/power stack slightly for a closer Retail alignment.
- Added a soft parent wrapper behind the whole frame cluster.
- Removed the visible portrait/header seam and hidden the old separator line.
- Tightened the health/power spacing and reduced the hard outer-end glow.


0.8 REFINEMENTS
---------------
- Parent wrapper now extends behind the portrait instead of starting exactly at the seam.
- Parent wrapper background and edging are more transparent.
- Name bar no longer draws its own background; it now relies on the shared parent wrapper.
- Header, health and mana are aligned within the same wrapped cluster and sit slightly lower.


0.9 REFINEMENTS
---------------
- Added adjustable parent-wrapper opacity (0-100%).
- Health bars now default to classic green.
- Added native dropdown for automatic/fixed WoW class health colors.
- Removed the 1px highlight/shadow hairlines from status bars.
- Rebuilt the settings page with Blizzard's native Vertical Settings layout, checkboxes, sliders, dropdown and buttons.


0.9.1 QUALITY-OF-LIFE
---------------------
- Unlocking frames now shows a native WoW "Lock Frames" button directly below the Player frame.
- The button follows the Player frame while it is moved and disappears immediately after locking.
- If combat starts while frames are unlocked, the button is disabled until combat ends.


0.10 REFINEMENTS
----------------
- Health/power containers now own the rounded silhouette; partial fills have a clean square moving edge.
- Removed the moving bright spark from partially depleted bars.
- Combat no longer prints COMBAT in the header; the portrait border pulses red instead.
- Target level badge follows Blizzard/Classic difficulty colors.
- Player PvP status now shows the native Alliance/Horde/FFA crest and optional clear timer.


0.11 REFINEMENTS
----------------
- PvP faction badge moved to the top-left of the portrait and enlarged.
- PvP badge now appears on PvP-flagged player targets too.
- PvP badge has no tooltip/hover interaction; the player clear timer remains visible beneath it.
- Player-applied target debuffs get a dedicated larger row.
- Player-applied target debuffs can show live written duration timers for DoT tracking.
- Added native settings for emphasized target debuffs, timers and icon size.


0.11.1 REFINEMENTS
------------------
- Enlarged the portrait PvP badge for Player and Target.
- Moved the player PvP clear timer back to the right side of the name bar.
- Target keeps only the PvP badge, without a timer.


0.12 REFINEMENTS
----------------
- PvP portrait badge enlarged substantially and tucked closer to the rounded portrait edge.
- Player and raid-member targets can now show a compact raid subgroup number in the header.
- Added a native Corner roundness setting with Soft / Medium / Tight options.


0.12.1 DETAIL PASS
------------------
- Tightened the gap between portrait and bars.
- Forced the name header textures fully transparent/hidden.
- Refined the Tight/Medium/Soft mask radiuses so the wrapper corners read more evenly.


0.12.2 DETAIL PASS
------------------
- Removed the remaining wrapper padding on the far-right and bottom edges so the frame hugs the bars more tightly.
- Aligned the target aura rows to the left instead of centering them.


0.12.3 COMBAT BADGE
-------------------
- Added a dedicated circular combat badge with a sword icon, positioned just left of the level badge.
- The combat badge pulses red while in combat for much stronger visual feedback.


0.12.4 PVP BADGE POSITION
------------------------
- Moved the player PvP badge further left and slightly downward so it sits more naturally on the outer portrait ring.
- Mirrored and corrected the target PvP badge placement so it no longer looks awkward on the target portrait.


0.12.5 STATUS + AURAS
---------------------
- Fixed the mirrored target PvP badge placement so it sits naturally on the target portrait ring.
- Reworked the combat badge to be slimmer, clearer and actually show a sword icon.
- Emphasized player-applied debuffs now use a thinner rounded border and the size slider now goes much larger.
- Dead targets now show Dead on the health text instead of 0%.


0.12.6 TARGET PVP BADGE FIX
---------------------------
- Corrected the mirrored target PvP badge anchor so the icon sits on the outer top-right edge of the target portrait instead of intruding into the portrait art.


0.12.7 TARGET PVP NUDGE
-----------------------
- Nudged the mirrored target PvP badge inward so it sits much closer to the target portrait ring instead of floating too far out on the side.


0.12.8 COMBAT INDICATOR REFINEMENT
---------------------------------
- Moved the combat badge to the lower-right of the player portrait for a clearer status cue.
- Slimmed the combat badge border/ring so it feels lighter and less bulky.
- Strengthened the red pulsing glow around the portrait while in combat.


0.12.9 TARGET PVP BADGE RE-FIX
------------------------------
- Adjusted the mirrored target PvP badge back toward the portrait's outer top-right edge so it no longer sits awkwardly over the target face.


0.13.0 TARGET CLASSIFICATION
----------------------------
- Added Blizzard-style target classification dragons around the custom Target portrait.
- Elite and world-boss targets use the gold dragon artwork.
- Rare and rare-elite targets use Blizzard's silver/grey dragon variants.
- Added a native Target setting to toggle the classification dragon artwork.


0.13.1 ELITE/RARE DRAGON FIX
----------------------------
- Tightened the mirrored rare/elite dragon crop and reduced its size so it wraps the target portrait instead of drawing a long ugly strip across the unit frame.


0.13.2 CUSTOM ELITE / RARE RINGS
--------------------------------
- Replaced the ugly Blizzard-derived elite/rare overlay with custom dragon ring artwork.
- Uses gold elite, gold boss, silver elite and silver rare rings around the target portrait.
- The ring now stays tightly wrapped to the portrait instead of stretching across the frame.


0.13.3 CLASSIFICATION RING FIT
------------------------------
- Increased the custom elite/rare ring size slightly and nudged it down a touch so it wraps the target portrait more cleanly.


0.13.4 CLASSIFICATION RING EDGE FIT
-----------------------------------
- Increased the custom elite/rare ring size again and moved it to ride the outer edge of the target portrait more clearly.


0.13.5 CLASSIFICATION RING NUDGE
--------------------------------
- Moved the custom elite/rare ring farther right and increased it slightly so it better matches the outer circle of the target portrait.


0.13.6 WINGED DRAGON FIX
------------------------
- Preserves the user-tuned dragon placement: X +16, Y 0, size portrait +45.
- Re-extracted the custom sprite sheet using the actual dragon bounds instead of four equal-width cells.
- Added transparent padding around each extracted dragon so the wing tips are not clipped by the texture edge.


0.13.7 USER-SPLIT CLASSIFICATION ART
------------------------------------
- Replaced the classification dragon textures with the user-provided individually split, equal-sized images.
- This keeps elite/boss/rare variants aligned consistently without horizontal shifting when switching between winged and non-winged rings.
- Preserved the manually tuned placement values: offset X=16, Y=0 and size = portraitSize + 45.


0.13.8 CORRECTED 1:1 CLASSIFICATION ART
---------------------------------------
- Replaced the classification dragon textures with the corrected 1:1 (199x199) user-provided images.
- This prevents the dragon ring from appearing oval / squished and keeps the circular ring shape intact.
- Preserved the manually tuned placement values: offset X=16, Y=0 and size = portraitSize + 45.


0.13.9 BOSS CLASSIFICATION POLISH
---------------------------------
- Boss/worldboss targets now use the winged gold dragon ring, matching the classic Blizzard target-frame treatment more closely.
- Boss/high-level targets with UnitLevel < 0 now show Blizzard's UI-TargetingFrame-Skull icon instead of ?? in the level badge area.
- Preserved the user-tuned dragon placement exactly: X=20, Y=0 and size = portraitSize + 63.


0.14.0 BOSS LEVEL TABLET + NPC PVP
----------------------------------
- Boss/world-boss skull now renders inside the existing level tablet/pill rather than floating alone.
- Skull is intentionally slightly taller than the pill and may protrude a few pixels vertically.
- PvP-flagged NPC targets are no longer filtered out and can show the same PvP badge as players.
- Preserves the final classification dragon placement: X=20, Y=0, size=portraitSize+63.


0.14.1 PLAYER TARGET HEALTH FIX
-------------------------------
- TBC Anniversary/Classic only exposes percentage-scale health (0-100) for player targets outside your party/raid.
- The addon now detects that case and shows a dash for the unavailable absolute HP value instead of misleadingly displaying 100, 79, etc.
- Exact health remains visible for yourself and party/raid members where the API provides it.


0.15.0 TARGET OF TARGET
-----------------------
- Added a secure Target of Target frame using the targettarget unit token.
- Shows/hides automatically when the target has a target.
- Added saved position, independent scale, preview support and native settings controls.
- Supports normal health/power/name/level updates and the same hidden-player-health safeguards as the Target frame.


0.15.1 TARGET AURA CLOCK WIPE
------------------------------
- Added native radial cooldown/clock wipes to target buffs and debuffs applied by you or your pet.
- Target aura timer text now counts entirely in seconds.
- Only the final 5 seconds use one decimal place for precise DoT refresh timing.
- Helpful buffs applied by you/pet now get the same timer + clock-wipe treatment as your debuffs.
- Added a native Clock wipe on my target auras setting.


0.15.2 OWN-AURAS-ONLY FILTER
----------------------------
- Target aura rows now show only buffs/debuffs applied by the player or their pet.
- Other players' raid/party buffs and debuffs are filtered out entirely.
- Existing timer text and radial clock-wipe behavior remains enabled for the player's own auras.


0.15.3 AURA TIMER FORMATTING
---------------------------
- Aura timers above 60 seconds now display as minutes:seconds (for example 27:00).
- Timers from 60 down to 6 seconds display whole seconds.
- The final 5 seconds retain one decimal place for precise refresh timing.


0.15.4 AURA TIMER FALLBACKS
---------------------------
- Above 5 minutes: show whole minutes only (e.g. 27m).
- 1 to 5 minutes: show minutes:seconds (e.g. 2:34).
- Under 60 seconds: show whole seconds.
- Final 5 seconds: keep one decimal for precise refresh timing.


0.15.5 HIDDEN HP + CAST BAR
---------------------------
- When exact HP is unavailable for a non-group player target, the default fallback now hides the dash and centers the health percentage.
- Added a native setting to disable that centered fallback and retain the previous dash behavior.
- Target cast bar now uses the full health/power width and is slightly taller for better readability.


0.15.6 RESTING STATUS
---------------------
- Added a Player resting indicator using Blizzard's classic UI-StateIcon rest/Zzz artwork.
- Added three layered gold pulse glows around the custom Player portrait while resting.
- Added a native Resting indicator setting.
- Preserves v0.15.5's centered hidden-HP percentage fallback and wider target cast bar.


0.16.0 SETTINGS UI OVERHAUL
---------------------------
- Rebuilt the settings page as a Blizzard Canvas Layout instead of the single-column Vertical Layout.
- Options are now grouped into two logical columns: Frames, Status, Target, Appearance, Scale, Bar Text and Actions.
- Uses native TBC/Classic checkbox, slider, dropdown and button templates inside the Blizzard Settings window.
- Fixed the Health bar color dropdown showing literal WoW color-code/hex escape strings by using clean plain-text class names.


0.16.1 SETTINGS + RESTING FIX
-----------------------------
- Fixed the blank Settings canvas by assigning deterministic initial scroll-child/column widths and using the documented two-argument Canvas registration.
- Added Canvas refresh/default callbacks for better Anniversary compatibility.
- Strengthened resting visuals with a larger Zzz badge, a broad pulsing gold aura, a brighter portrait rim and eight animated gold glints.


0.16.2 MOVE / LOCK WORKFLOW
---------------------------
- Replaced the small Player-attached Lock Frames button with a movable dialog-style unlock panel.
- The unlock panel remembers its own screen position and can be dragged out of the way.
- Increased unlocked-frame overlay visibility with a stronger green tint, bright outline and clear unit labels.
- Fixed the Settings Lock frames checkbox to run the same lock/unlock workflow as the slash command/action button.


0.16.3 SETTINGS CARD LAYOUT
---------------------------
- Rebuilt the settings canvas as a single stack of full-width card wrappers.
- Each card uses at most two internal columns for its controls, preventing the right side from overflowing the native Options canvas.
- Frames, status, appearance, scale, target options, bar text and actions are grouped into logical full-width sections.


0.16.4 SETTINGS WIDTH FIX
-------------------------
- Settings cards now size from the actual visible Blizzard scroll viewport instead of enforcing an oversized minimum width.
- Reserves room for the native scrollbar gutter and adds a small horizontal card inset.
- Recalculates the canvas width after Blizzard completes its Settings layout, improving behavior across UI scale/resolution changes.


0.16.5 TARGET EFFECT TIMER REFINEMENT
-------------------------------------
- Added separate Show my buffs and Buff timers settings; both default off so DoT/debuff tracking stays the focus.
- DoT/debuff timers remain independently toggleable and enabled by default.
- Removed the translucent timer strip/background from aura icons.
- Aura timer text is now centered both horizontally and vertically directly over the icon.


0.16.6 TARGET AURA TIMER CONTROL
--------------------------------
- Restored normal target aura visibility: buffs/debuffs from all casters are shown again.
- Timer text and radial clock wipes remain exclusive to effects applied by the player/pet.
- Added independent timer toggles for own buffs, own debuffs and own DoTs.
- Own DoTs can still be emphasized in the larger priority row.
- DoT classification uses the spell description to identify periodic damage/drain effects; ordinary harmful effects remain debuffs.


0.16.7 ROUNDER AURA ICONS
-------------------------
- Increased the target aura/DoT corner radius substantially for a smoother rounded-card look.
- The radial cooldown swipe now uses the same rounded alpha texture when supported, so it follows the icon shape instead of drawing square corners over it.


0.16.8 PET COMBAT FEEDBACK
--------------------------
- Added a red pulsing portrait glow for the player's pet/demon while it is in combat.
- The glow becomes stronger when the player's current target is specifically targeting the pet.
- Added Blizzard-style UNIT_COMBAT feedback over the pet portrait for damage, healing, dodge, parry, block, miss, resist and similar results.
- Added native settings for Pet combat glow and Pet combat feedback.


0.16.9 AURA TIMER SCALING
-------------------------
- Aura countdown text now scales proportionally with the aura icon size instead of staying fixed at 11px.
- Small standard target auras remain compact, while larger prioritized DoT/buff icons receive larger, easier-to-read timers.


0.17.0 TARGET AURA SCALING
--------------------------
- Added a Regular aura icon size setting for normal target buffs, debuffs and non-prioritized DoTs.
- Regular aura size can be adjusted from 18 to 40 px independently of prioritized DoTs.
- Aura rows now wrap automatically when larger icons no longer fit across the target bar width.
- Aura timer font sizes continue to scale with the icon size.


0.17.1 NPC NAME REACTION COLORS
--------------------------------
- Friendly NPC target names are green.
- Neutral NPC target names are yellow.
- Hostile/unfriendly NPC target names are red.
- Applies to Target and Target of Target NPC names while player/pet names keep the addon gold styling.


0.17.2 TAP-DENIED NPC COLOR
---------------------------
- NPC names now turn gray when UnitIsTapDenied() reports that the mob is tagged by somebody else and the player/group is not eligible for the tap.
- Added UNIT_FLAGS refresh handling so the color changes immediately as tap ownership changes.


0.17.3 LOW HEALTH PULSE
-----------------------
- Added an optional subtle red pulsing glow around the player frame at low health.
- Added a Low health threshold slider (10-60%, default 30%).
- The warning disappears on death or once health rises above the threshold.


0.17.4 NEUTRAL -> HOSTILE NAME COLOR
-----------------------------------
- Neutral NPC names now turn red immediately when the NPC becomes hostile after being engaged.
- Live UnitIsEnemy state takes priority over a stale neutral reaction value.


0.17.5 CLASS COLOR TUNING
-------------------------
- Brightened Hunter class-health green so it is more distinct from the normal green health bar.
- Brightened/lightened Shaman blue so it is more distinct from the mana bar.


0.17.6 LEADER + OFFLINE TARGET STATE
-----------------------------------
- Added the Blizzard party/raid leader crown above the Player portrait when you lead the group.
- Added the same leader crown above the Target portrait when the targeted player is your party/raid leader.
- Offline player targets now show a centered "Offline" health status, empty health/power bars, a gray name and a dimmed/desaturated portrait.
- Added UNIT_CONNECTION handling so an already-targeted group member updates immediately when they disconnect/reconnect.


0.17.7 DEAD / GHOST STATUS
---------------------------
- Health status text now distinguishes Dead from Ghost instead of treating both as one state.
- Applies to Player, Target, Target of Target and Pet where relevant.
- Offline remains the higher-priority state for disconnected player targets.


0.17.8 ADDON IDENTITY + CATEGORY
--------------------------------
- Added a custom Sleek Unit Frames addon icon.
- The icon is exposed through the TOC IconTexture field for Blizzard's AddOns list.
- Added the native Unit Frames addon category metadata so the addon is grouped with other unit-frame addons.
- The same custom icon is shown in the header of the Sleek Unit Frames settings panel.
- Settings header version text now reads the TOC Version dynamically instead of being hard-coded.


v0.19.0 adds secure Party 1-4 frames in the same visual style, with shared scale, individual movement, preview support, leader/offline/dead/ghost handling, and optional replacement of Blizzard party frames.


v0.19.1 hardens replacement of Blizzard's stock unit frames across zoning/loading transitions. Stock frames are now transparently suppressed as well as parented to the hidden container, guarded by OnShow hooks, and re-asserted during the short post-load UI rebuild window to prevent occasional ghost copies (notably the Blizzard PetFrame) from appearing behind Sleek Unit Frames.
