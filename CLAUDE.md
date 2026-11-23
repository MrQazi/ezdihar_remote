# Ezdihar Remote (Mashael Al Fursan)

Flutter app implementing the Figma file
`7U3uK1v7FRA0dMmKdOSF97` (Ezdihar _ Mashael Al Fursan). Designs are authored on a
1920x1080 canvas (landscape tablet/desktop), Arabic (RTL) is the default locale.

**Target device:** 16:9 landscape (e.g. 1920x1080), fullscreen. `main()` locks
landscape + `SystemUiMode.immersiveSticky`; the manifest uses `sensorLandscape` (iOS Info.plist lists
landscape only + `UIRequiresFullScreen`). The Figma frames (1920x1080) fill the screen exactly:
nothing is cropped.

**One canvas for every screen:** `AppCanvas` (`lib/widgets/app_canvas.dart`, mounted in
`MaterialApp.builder` around everything) lays the whole app out on a fixed 1920x1080 logical canvas
(the Figma frame, so sizes in code are Figma pixels) and scales it uniformly to the
screen, so every 16:9
resolution/density shows the identical layout; other aspects (e.g. a 16:10 tablet) are letterboxed
(`AppColors.letterbox`), never reflowed. System text scaling is ignored. All logical sizes in code are
canvas pixels: never size things from the real screen or `devicePixelRatio`. `test/app_canvas_test.dart`
checks every screen is identical and text does not overlap at 1280x720 / 1920x1080 / 2560x1440 x 1,
1.5, 2.

**Image assets at their original resolution:** take Figma images from the asset URLs that
`get_design_context` returns (the original upload, e.g. 3840x2160 renders, 4096x2304 masterplan),
never from screenshots/exports (those are capped at the frame size). Keep the source resolution and
let the layout scale them (`BoxFit.cover` / `FittedBox`); compress (JPEG q92 for opaque photos) but do
not downscale. A Figma export rendered above its source size (a vector with an image fill comes back
at 2x) is stored at the fill's source size. Downloading needs www.figma.com, which the `ezdihar_remote`
cloud environment allows. Full-size stills decode to ~33 MB each: precache only what is needed next.

## Sources (links shared by the client)
- Figma file: https://www.figma.com/design/7U3uK1v7FRA0dMmKdOSF97/Ezdihar-_-Mashael-Al-Fursan
  - App flow, screens left to right / states top to bottom, from Splash
    https://www.figma.com/design/7U3uK1v7FRA0dMmKdOSF97/Ezdihar-_-Mashael-Al-Fursan?node-id=3-391&m=dev
    to the thank-you screen https://www.figma.com/design/7U3uK1v7FRA0dMmKdOSF97/Ezdihar-_-Mashael-Al-Fursan?node-id=100-143&m=dev
  - Building views + floor highlights (A1..A3, B1..B3, C1..C4; "A1" = view 1 of type A):
    https://www.figma.com/design/7U3uK1v7FRA0dMmKdOSF97/Ezdihar-_-Mashael-Al-Fursan?node-id=652-2&m=dev
- Transition videos (Building A / B / C subfolders, "Frame n.mp4" = view n -> n+1, plus a
  "Complete Building X Orbit" of all frames): https://drive.google.com/drive/folders/1Mgj190kdfRQNlmUGu3u4VwiIWF49gT2H
- Exterior stills e1..e9 (first link given for the videos; holds only JPEG renders, not used):
  https://drive.google.com/drive/folders/1E8GYBkBW4C1YqJ2whp9Q3ZQ-8kJRyIcq
- Floor plans (3D, one per building type + unit type): https://drive.google.com/drive/folders/1DYwiqcwQXYNPTUsr61zN9RYmiJuHDEzq
  - Type A https://drive.google.com/drive/folders/1Zg_H1PlaU1mQmqU_5ZUymp4TkWk1l-o1
  - Type B https://drive.google.com/drive/folders/1_947HYnb48cu3DgsoTpicYucQ1Uf01eL
  - Type C https://drive.google.com/drive/folders/1_8B5QlX7hiP52qooEZfyVqmDortp957g
- EN/AR content (names, landmark descriptions, amenity and room names; wins over Figma for copy):
  https://docs.google.com/document/d/1n60BtryCBPATok7z3AW-tyGkK63FqliPlZL5VVUOl4M/edit
- Project data sheet "Ezdihar _ Data" (Building / Floor / Apartment tabs, mirrored by
  `assets/data/*.json`): https://docs.google.com/spreadsheets/d/1p8khdWDAgjdXNpKbSPwz9Q6aHbsSHQcdprNkjJGVSxs/edit
- Main screen player: https://github.com/Qazi-Narsun/NarsunPlayer (branch `ezdhar_main`).

## Workflow: Figma -> Flutter
1. Load the `figma:figma-design-to-code` skill, then `create_session` (fileKey) and
   `get_design_context` (nodeId with `-` -> `:`, `skillNames: figma-design-to-code`).
2. The returned React/Tailwind is a reference only: translate to Flutter, never copy
   absolute positioning blindly. Use the screenshot as the visual target.
3. Download every static asset (URLs expire in 7 days) into `assets/images/<screen>/`
   with descriptive snake_case names. No Figma URLs in code. Skip duplicates
   (identical SVGs get one file).
4. Check existing code first (below) and reuse before creating anything.
5. Verify against the screenshot: assets present, sizes, positions, RTL.
6. Before writing/replacing a screen, read "Intentional overrides of the Figma design" below:
   the screenshot is NOT the target where an override applies. Update existing screens by
   editing them (new visuals in, overrides kept), never by regenerating the whole file.

## Project map
- `lib/screens/` one file per screen. `lib/widgets/` reusable pieces.
  `lib/theme/app_colors.dart` colour tokens. `lib/l10n/app_strings.dart` strings.
- Reusable: `OverlayBackground` (image + tint/gradient), `PillButton`,
  `LanguageToggle`, `GlassIconButton` (optional `color` fill), `BrandTitle`, `MapTile` (`lib/widgets/map_tile.dart`).
- Flow: `InitialScreen` -> (Start Journey, `Navigator.push`) -> `CityContextScreen`
  -> (tap project logo card or the highlighted site polygon, hit-tested on its outline via
  `_SitePolygonClipper`) -> `MasterplanScreen`; back button pops.
- City context (Figma 415:2868 = base layout, the source of truth for the map, tile positions, site
  polygon, callout and header; the state frames 401:2 .. 401:2018 under it only define the open
  state, their background tiles are stale): night map `map_background.jpg` (original 3840x2160)
  under Figma's radial darkening (black 20% -> 59%), site polygon `site_polygon.png` at (1303, 253),
  logo callout at (1421, 193). The 8 landmarks
  (`_landmarks`, in the state frames' order) are `MapTile`s (square tile + name box) at the
  415:2868 positions. Tapping one opens
  its state: the whole screen dims and blurs (`AppColors.scrim` + vignette), the landmark's own
  tile is drawn above the dim layer, `_LandmarkCard` (photo, name, distance, description)
  sits bottom-start and Previous / Next (bottom-end, arrow keys too) cycle the landmarks with
  wrap-around. X, a tap on the dimmed map, Back (`PopScope`) or Esc close it. Photos are
  `assets/images/city/landmarks/<id>.jpg`; each landmark's name and description come from the content
  doc (`AppStrings.landmarkDescription(id)`); the distance (28 km / 26 min) is still a Figma
  placeholder shared by every landmark (`_Landmark.km/minutes`).
- `MasterplanScreen` (Figma 24:1403 + Filters 49:5630 + Gallery 49:6205): bottom nav
  = Filters|Gallery tabs; rotate-left / rotate-right buttons sit at the screen sides,
  vertically centred (Figma 225:542 / 225:526, as on the building screen). Tabs are mutually exclusive
  panel toggles (tap active tab or X closes). Rotate buttons slide the zoomed
  aerial image (placeholder for 360 frames); reset button (bottom-end) is the Restart
  button: pops the stack to the first page (`InitialScreen`). Filter state is held locally (no unit data yet).
  Assets in `assets/images/masterplan/`.
- Masterplan buildings (Figma 648:1892 en / 648:1344 ar): the aerial render
  `background.jpg` (Figma's image, only 1376x789 at the source) on the 1920x1080 frame, inside
  `RotatingView` so everything moves with it. `lib/data/masterplan_data.dart` holds the Figma
  placement: `masterplanBuildings` (22, real ids A01..A05 / B01..B15 / C01 / C02, each an orange
  traced outline `OutlineShape` + id label box; B08 and A05 share Figma's Vector 67, one
  sub-path each) and `masterplanAmenities` (Green Area 1-9, Children's Playground 1-7 = Figma's
  "Play Area", Padel Court 1-3, Water Fountain, Basketball and Volleyball Court: non-interactive
  copper pills, names in `AppStrings.amenity` per the content doc). Tapping a building's outline or id label opens it. Figma's
  Amenities nav tab is hidden in the frame, so it is not built. Types/counts
  come from `assets/data/building_details.json` via `BuildingType.loadAll()`
  (`lib/data/building_data.dart`), which also attaches each type's floors
  (`assets/data/floor_details.json`, `FloorDetails`, GF..6F bottom to top) and apartment
  types (`assets/data/apartment_details.json`, `ApartmentDetails`: one area + availability per
  unit type). The three JSON files mirror the project sheet's Building / Floor / Apartment
  tabs; values are copied as they are (C's GF has 0 apartments, A's floor areas don't sum to
  the building total). `BuildingType.buildingIds` (A01..A05, B01..B15, C01, C02) must match the
  Figma ids (`test/building_views_test.dart`). Tap opens `BuildingDetailScreen`.
- `BuildingDetailScreen` (Figma 81:2 panel open, 225:184 panel closed): the type's exterior
  views (`lib/data/building_views.dart`, Figma "Group 8" 652:2: A1..A3, B1..B3, C1..C4 on
  3840x2160 frames, laid out on a 1920x1080 canvas = frame / 2, cover) with each view's floor
  outlines, info panel (X closes, info button bottom-start reopens), Restart pops to the first page.
  Stills are `assets/images/building/views/<type>_<n>.jpg`: the Figma frames' own renders (image
  layer only, exported at 1920x1080), never frames grabbed from the clips, so the outlines align;
  they match the clips' first frames (A3 -> A1 and B3 -> B1 clips end slightly off view 1). Rotate
  buttons / arrow keys play the transition clips (`video_player`, bundled 1080p H.264 in
  `assets/videos/building/`): view n -> n+1 plays `<type>_<n>.mp4`, n+1 -> n plays
  `<type>_<n>_reverse.mp4` (pre-reversed with ffmpeg), wrapping (A3 -> A1 = clip 3). Clip n is the
  source "Frame n.mp4" (Drive "transition videos" / Building A|B|C). While a clip plays, input
  to rotate is ignored and the outlines are hidden; it lands on the next still (also when the clip
  fails to load, e.g. in tests). Rotate buttons are hidden while a floor is selected.
- Floor selection (Figma 35:2647): the floor data is the source of truth. The selection indexes
  the type's floors top first (6F..GF); the floor stepper and arrow keys cover every floor in the
  data. Every view has one traced outline per floor (`BuildingView.floors`, top first; C2's
  Vector 51 traces five floors and is split per sub-path), hit-tested on the shape itself
  (`_PathClipper`); on some views the bottom-centre Apartments panel covers the lowest outlines,
  which the stepper still reaches. Tap empty space clears. Floors are labelled everywhere (title, breadcrumb, stepper, tooltips,
  panels, masterplan floor filter) with the sheet's names via `AppStrings.floorName` /
  `floorNameOfLevel`: English "GF", "1F".."6F", Arabic "الأرضي", "ط1".."ط6". Selected floor swaps
  the "Building Details" info panel for "Floor Details" (`buildingDetails` / `floorDetails`; the
  floor's name is in its Floor row; that floor's apartments, types and area) and opens the `_ApartmentsPanel`
  (bottom-centre): a drag-scrollable row of cards (plan + bedrooms label), one per apartment
  type on that floor (hidden entirely on a floor with no apartments, e.g. type C's GF), loaded from
  `BuildingType.planAsset`: `assets/images/apartments/<building type>_<unit type>.png` (a_1br ..
  c_3br, the 3D plans from the Drive "floorplans" folder, one per building type + unit type,
  scaled to 1200px). Floor Details X only
  collapses the panel (info button reopens); Apartments X clears the selection.
- Apartment details (Figma 59:454): tapping an apartment card replaces both panels with
  `_ApartmentDetailsPanel` (bottom-start: floor, type, area, availability from
  `apartment_details.json`, plan image, Brochure / Register Interest placeholders; availability is a
  badge: green "Available" 59:520 / red "Not Available" 221:35, `_AvailabilityRow`). Its X clears
  the apartment and brings the panels back.
- Brochure: the apartment details Brochure button calls `BrochureScreen.open(context)`
  (`lib/screens/brochure_screen.dart`), a transparent full-screen modal showing
  `assets/pdfs/brochure.pdf` via `pdfx` (`PdfView`, portrait page centred in a padded, bordered frame sized to the page aspect, swipe + start/end arrow
  buttons, pinch zoom, page counter, X closes).
- Register Interest (Figma 41:3055 form, 100:17 thank-you; `lib/screens/register_interest_screen.dart`):
  the apartment details Register Interest button calls `RegisterInterestScreen.open(context)`, a
  transparent modal route with the "Your Information" form (name/email/phone validated, nothing
  sent anywhere yet). On submit it pushes `InterestRegisteredScreen` (blurred exterior view A1, logo,
  Restart Experience = popUntil first, dismissible toast top-end). Assets in `assets/images/register/`.
- Convention: every Restart button on a screen (this and future ones) ends in
  `Navigator.popUntil((r) => r.isFirst)`, not a local state reset. Restart buttons on the
  masterplan/building screens go through `confirmRestart(context)` (`restart_dialog.dart`);
  the thank-you screen restarts directly (it auto-restarts after 30s).
  Assets in `assets/images/building/`.
- UX layer (added after the UX review):
  - `IdleReset` (`lib/widgets/idle_reset.dart`, mounted in `MaterialApp.builder` with the app
    `navigatorKey`): 90s without input off the first page -> "Still there?" 15s countdown ->
    `popUntil(first)`. `LocaleFade` cross-fades on language change (state is kept).
  - Masterplan: building id labels have a 48px-high touch target (and the outline is tappable), hover/press feedback, a first-visit
    pulse + "Tap a building" hint (`StatusChip`, gone after 12s or first interaction), and are
    dimmed when filtered out (building type, plus floor / size / availability select apartments:
    a building is lit when one of its apartments passes all of them; slider bounds come from the floor
    levels and apartment areas in the data). Chip shows "N of 22 match" / no-match with Clear filters / load error with Retry.
    Drag the map (pans 1:1 with the finger, snaps to the nearest step on release) or hold a
    rotate button (`GlassIconButton.repeatEvery`) to rotate; arrow keys rotate, Esc closes the
    panel. Pinch zooms 1x..3x around the fingers, double-tap toggles 2x at that point / 1x, and
    while zoomed one finger pans freely (no rotation); the zoom wraps the map so building buttons
    stay put and tappable. Rotate buttons/keys and opening a building reset to 1x
    (`RotatingViewState.resetZoom`). Double-tap is detected on raw pointers so building taps
    are not delayed. The Restart button (bottom-end) is an icon + "Restart" pill, as on the building screen.
    The Filters panel always reserves the Clear filters slot so it does not resize (QA #03).
  - Building detail: `_Breadcrumb` (Masterplan > Building > Floor), `_FloorStepper` (up/down
    while a floor is selected, arrow keys too; centre-end, opposite the start-side panels),
    selected floor outline is filled semi-transparent orange (60%, as in Figma 35:2647; others
    a 3% fill + 2px `AppColors.floorOutline` stroke, `_OutlinePainter`), selecting a floor or closing Apartment
    Details reopens a collapsed info panel, floor outlines have tooltips, panels swap with
    `AnimatedSwitcher`. Back/system back/Esc close the topmost layer first (apartment, floor)
    via `PopScope`. Floor Details/Building panel uses a collapse chevron (not X); X still means
    "clear selection" on Apartments and Apartment Details. Apartment cards show a bedrooms
    label; the row fades at scrollable edges and has arrow buttons.
  - Register form: errors show on blur/submit with messages, autofill hints, next/done
    actions, country-code picker (`+966` default), digits-only phone.
  - Shared: `PanelCloseButton` (32px icon, 48px target; use it for every panel X), `FitPanel`
    (first scales a glass panel by the constant `FitPanel.designScale` = canvas / 1920x1080 (= 1 on the 16:9 canvas)
    Figma frame, so it takes the same share of the screen as in Figma; then
    scales it down to a max screen fraction so the background stays visible; wrap every
    glass panel/toast in it),
    `FadeInAsset`, `StatusChip`, `appText()` (`lib/theme/app_text.dart`). Haptic
    `selectionClick` on glass/pill buttons.
  - Background visibility: initial screen tint is a radial gradient (64% -> 25%), modal scrim
    80% -> 64% (the city map now uses Figma's own lighter darkening). `AppColors.textSecondary` (white @ 72%)
    replaces white @ 64% for secondary text.
- Main screen link (NarsunPlayer, `ezdhar_main` branch of Qazi-Narsun/NarsunPlayer): the player shows a QR
  of its WebSocket URL (`ws://<lan-ip>:3737/`) on the main screen while no remote is connected (it accepts
  one remote at a time). `PlayerConnection` (`lib/services/player_connection.dart`, app-wide
  `PlayerConnection.instance`, loaded in `main()`) saves the paired URL in `shared_preferences` and
  reconnects on its own (1..30s backoff); `send(event, payload)` writes the player's
  `{"Event": ..., "Payload": ...}` JSON (player events: `StartExperience {id}`, `StartState {id}`,
  `GetCurrentExperience`, `GetCurrentState`). `ScreenLinkButton` (initial screen, next to the language
  toggle) shows the link state and opens `PairScreen` (`mobile_scanner` camera window, accepts only
  `ws://host:port` codes, camera errors/permission denied shown in the window with Try again; plus a manual
  IP/host + port bar, port default 3737, validated, prefilled from the saved pairing). Android needs INTERNET/CAMERA and cleartext traffic.
- Main screen mirroring: screens drive states of the player's `ezdihar` experience (each plays its
  video, then holds on its hero image). `MirrorState(state:, tag:)` (`lib/widgets/mirror_state.dart`,
  its `routeObserver` is on `MaterialApp.navigatorObservers`) sends `StartState {id, experience, tag}`
  while its route is on top, and again when the route above pops. States: `splash` (initial),
  `city_context`, `masterplan`, and on the building screen `building_details` (tag = building type),
  `floor_details` (tag = floor code, also with the panel collapsed), `apartment_details` (tag = unit
  type), `exterior` (building panel collapsed). The building screen's states also send `details`
  (`building` id, `buildingType`, `view` number of the exterior view on screen, resent after each
  rotation, plus `floor` code + `floorNumber` once a floor is selected and
  `apartmentType` once an apartment is). The player shows them on its placeholder screen (a state
  without media); how they pick media is not decided yet. The register form and thank-you screen have no
  MirrorState, so the main screen keeps the previous state. Modals: a gallery tile tap sends
  `ShowModal {kind: gallery, id: gallery_N}`, closing/leaving the gallery sends `HideModal`; the
  brochure sends `ShowModal {kind: brochure, page}` on open and every page change, `HideModal` on
  close; an open city landmark sends `ShowModal {kind: landmark, id, title, description, metadata,
  locale}` (the card's texts in the current language, re-sent on language change; the player shows
  `Landmarks/<id>` in the gallery modal's frame, text centred at its bottom, metadata top-end, RTL for `ar`),
  `HideModal` on close. A new state also closes the modal. `PlayerConnection` drops repeats and resends the state
  + modal on every (re)connect. New screens/panels: wrap them in `MirrorState` and add the state to
  the player's `Assets/Experiences/ezdihar/config.json`.
- `RotatingView` (`lib/widgets/rotating_view.dart`) is the shared slide/zoom
  stand-in for 360 frames. `GlassIconButton` takes `padding` for a pill with
  icon + label.

## Intentional overrides of the Figma design (UX review, 2026-10)
These deviate from Figma ON PURPOSE. When a screen is re-implemented or synced from an updated
Figma, keep every override below unless the user explicitly says to drop it. Do not "fix" them
back to the Figma values, and do not remove the behaviours when regenerating a screen from
`get_design_context`: merge the new visuals into the existing code instead of replacing it.
If Figma changes something an override touches, apply the new design *around* the override
and mention the conflict to the user.

Visual (background visibility):
- Initial screen tint: radial gradient 60% -> 25% black (Figma: flat 64%).
- Modal scrim `AppColors.scrim`: 64% black (Figma 80%).
- Glass panels are capped by `FitPanel` (max ~60% of screen height, gallery 50%, info/apartment
  panels 45% width); apartment details panel spacing is 32 (Figma 48) and plan image 190 high.
- Secondary text on glass uses `AppColors.textSecondary` (white @ 72%), not Figma's 64%.

Sizing / touch:
- All icon buttons >= 48px touch target (rotate buttons 48, not 40; `PanelCloseButton` 48 target
  around the 32px X; masterplan id labels 48px-high target around the 24px pill).

Behaviour (not in Figma):
- `IdleReset` (90s + 15s countdown) and `LocaleFade`; thank-you screen auto-restart (30s) and toast
  auto-dismiss (8s); extra "Browse more units" button on the thank-you screen.
- `confirmRestart` dialog before Restart on masterplan and building screens.
- Masterplan: first-visit pulse + "Tap a building" hint chip, filter-driven dimming and
  match-count / no-match / error chip, "Clear filters" in the Filters panel, drag-to-rotate,
  hold-to-spin, arrow/Esc keys, pinch / double-tap zoom with free pan.
- Building detail: breadcrumb in the header, floor stepper (up/down) while a floor is selected,
  floor tooltips, "Tap a floor" hint, collapse chevron (not X) on the Building/Floor info panel,
  layered Back/Esc via `PopScope`, animated panel swaps, bedrooms label on apartment cards,
  fading edges + arrow buttons on the apartment row.
- Register form: validate-on-blur with error messages, autofill hints, next/done actions,
  country-code picker, digits-only phone, focus first invalid field.
- Haptic + subtle sound on every interaction via `UiFeedback` (`lib/services/ui_feedback.dart`).

## Rules
- Content source of truth for names and copy (EN/AR): the Google Doc "Mashael Al Fursan_ Arabic
  Content" (`1n60BtryCBPATok7z3AW-tyGkK63FqliPlZL5VVUOl4M`). Where it and Figma disagree, the doc wins.
- Interaction feedback: call `UiFeedback.tap/select/dismiss/step/success/error()` (haptic + a
  quiet sound synthesised in code, no audio assets, `audioplayers`); never call `HapticFeedback`
  directly. `GlassIconButton`, `PillButton`, `PanelCloseButton` and `LanguageToggle` already do
  it; hold-to-spin buttons (`repeatEvery`) stay silent and their callback plays `step`.
- Reuse existing widgets/tokens; extend them (new optional param) instead of duplicating.
- Colours go in `AppColors`; no repeated hex literals in screens/widgets.
- Every user-visible string goes in `AppStrings` with both `_en` and `_ar` entries.
- Layout must follow ambient `Directionality` (use `Row`, `EdgeInsetsDirectional`,
  start/end). Exceptions: geography (maps) is physical and must not mirror; flip
  directional icons (e.g. back arrow) in RTL.
- Fonts: Rubik for English, Noto Sans Arabic for Arabic (via `google_fonts`).
- Fixed-canvas screens (maps): lay out on the Figma canvas inside
  `FittedBox(cover)`, keep header/controls outside it in a `SafeArea`.
- New asset folders must be listed in `pubspec.yaml` (`assets/images/` is not recursive).
- Language is app-level state: `LocaleController` (`lib/l10n/locale_controller.dart`)
  is loaded in `main()` and persists the choice via `shared_preferences` (default `ar`).
  Change language only through it (`setLocale`), never with local state.
- Pushed routes get `onLocaleChanged` only; read the current locale from
  `AppStrings.of(context)`, never from a stale constructor value.
- Always make code/file changes with direct edits (the Edit/Write tools), never
  with ad-hoc scripts (Python, sed, PowerShell rewrites, etc.).
- Run `flutter analyze` before finishing.
- CI (`.github/workflows/android.yml`, Flutter pinned by `FLUTTER_VERSION`) runs analyze + test +
  release APK build on every push to `main`, every PR into `main` and every push to `release`; only
  a `release` push publishes a GitHub release (each run uses a build number), and it refuses a
  commit without a successful `main` run. "Make a release" = push to `main`, wait for that run to
  pass, then fast-forward `release` to that commit and push it. Bumping Flutter means bumping
  Gradle / AGP / Kotlin in `android/` to its minimums (Flutter 3.50: Gradle 9.5.0, AGP 9.3.1,
  Kotlin 2.4.20) in the same change. Still run `flutter analyze` and `flutter test` locally first.

## Keep this file current
When a screen, shared widget, token or convention is added, update the sections above.
