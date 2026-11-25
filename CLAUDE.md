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
Screens are dark underneath (`ThemeData.scaffoldBackgroundColor` = `AppColors.screenBackground`), so
a photo still decoding never flashes white; the masterplan decodes a building's first still (up to
1.5 s) before opening it, and the city context warms the masterplan photo.

## Sources (links shared by the client)
- Figma file: https://www.figma.com/design/7U3uK1v7FRA0dMmKdOSF97/Ezdihar-_-Mashael-Al-Fursan
  - App flow, screens left to right / states top to bottom, from Splash
    https://www.figma.com/design/7U3uK1v7FRA0dMmKdOSF97/Ezdihar-_-Mashael-Al-Fursan?node-id=3-391&m=dev
    to the thank-you screen https://www.figma.com/design/7U3uK1v7FRA0dMmKdOSF97/Ezdihar-_-Mashael-Al-Fursan?node-id=100-143&m=dev
  - Building views + floor highlights (A1..A3, B1..B3, C1..C4; "A1" = view 1 of type A):
    https://www.figma.com/design/7U3uK1v7FRA0dMmKdOSF97/Ezdihar-_-Mashael-Al-Fursan?node-id=652-2&m=dev
- Transition videos (Building A / B / C subfolders, "Frame n.mp4" = view n -> n+1, plus a
  "Complete Building X Orbit" of all frames): https://drive.google.com/drive/folders/1Mgj190kdfRQNlmUGu3u4VwiIWF49gT2H
- Gallery images e1..e9 (project renders: e1 7680x4320, e2..e9 3840x2160; the masterplan Gallery
  panel shows them as `assets/images/masterplan/gallery_<n>.jpg`; e1 is over the Drive connector's
  10 MB download limit, so the client sent it in chat): https://drive.google.com/drive/folders/1E8GYBkBW4C1YqJ2whp9Q3ZQ-8kJRyIcq
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
  doc (`AppStrings.landmarkDescription(id)`); the drive time (`_Landmark.minutes`, shown
  as "N min", no km) is from the client's web equivalent of this screen,
  https://xyz.narsunstudios.com/riyadh/projects (Equestrian Club 10, King Salman / King Khalid
  airports 15, Horse Racing Track 5, Khuzam 20, Expo 2030 15, both universities 20).
- `MasterplanScreen` (Figma 24:1403 + Filters 49:5630 + Gallery 49:6205): bottom nav
  = Filters|Gallery tabs (the Gallery panel scrolls one tile per client render, Drive e1..e9 at
  full size: e1 is `background.jpg` (the map), e2..e9 `gallery_2..9.jpg`; decoded at 768px wide for
  the tiles via `ResizeImage`; modal ids `gallery_1..9`). No rotation (the new Figma frame has no
  rotate buttons): the map is zoom/pan only. Tabs are mutually exclusive
  panel toggles (tap active tab or X closes). The reset button (bottom-end) is the Restart
  button: pops the stack to the first page (`InitialScreen`). Filter state is held locally (no unit data yet).
  Assets in `assets/images/masterplan/`.
- Masterplan buildings (Figma 648:1892 en / 648:1344 ar): the aerial render
  `background.jpg` (Drive gallery "e1", 7680x4320, the same framing as Figma's 4096x2304 render at
  twice the resolution, cover-scaled) on the 1920x1080 frame, inside `ZoomView`
  (`lib/widgets/zoom_view.dart`) so everything zooms with it; at 1x it is exactly Figma 648:1892.
  Amenity pills and building id pills use a grouped 40px backdrop blur (`BackdropGroup` +
  `BackdropFilter.grouped`), as in Figma. Text and icons on the light tiles (amenity
  pills, selected nav tab, pressed id pill, checked boxes, selected language segment) are white,
  as in Figma (a dark-text variant was tried and dropped by the client). The image cache is raised to 400 MB in `main()` so the ~133 MB decoded map stays cached. `lib/data/masterplan_data.dart` holds the Figma
  placement: `masterplanBuildings` (22, real ids A01..A05 / B01..B15 / C01 / C02, each an orange
  traced outline `OutlineShape` + id label box; B08 and A05 share Figma's Vector 67, one
  sub-path each) and `masterplanAmenities` (Green Area 1-9, Children's Playground 1-7 = Figma's
  "Play Area", Padel Court 1-3, Water Fountain, Basketball and Volleyball Court: copper pills,
  names in `AppStrings.amenity` per the content doc; tapping one opens its kind's photo in `ImageModal`,
  one photo per `AmenityKind` = `assets/images/masterplan/amenities/<kind id>.jpg`, the client's
  3840x2160 renders sent in chat). Tapping a building's outline or id label opens it. Figma's
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
  Stills are `assets/images/building/views/<type>_<n>.jpg`: the Figma frames' own renders (the
  original 3840x2160 uploads), never frames grabbed from the clips, so the outlines align;
  they match the clips' first frames (A3 -> A1 and B3 -> B1 clips end slightly off view 1). Rotate
  buttons / arrow keys play the transition clips (`video_player`, bundled 1080p H.264 Main@4.1 in
  `assets/videos/building/`): view n -> n+1 plays `<type>_<n>.mp4`, n+1 -> n plays
  `<type>_<n>_reverse.mp4` (pre-reversed with ffmpeg), wrapping (A3 -> A1 = clip 3). The Drive
  sources are 2560x1440 at ~10 fps (30-46 frames), which stutters, so the bundled clips are
  motion-interpolated to 30 fps (ffmpeg `minterpolate` mci; fast foreground motion shows some
  blending). Known source issue: the black stripes on type A's view 2 <-> 3 orbit are in the
  client's source video; the arts department re-renders it, nothing to fix in the app. The two clips a view can play next are loaded ahead (`_prepareClips`), and a clip is
  drawn over the still only once its first frame is up (a video surface is black until then). Clip n is the
  source "Frame n.mp4" (Drive "transition videos" / Building A|B|C). While a clip plays, input
  to rotate is ignored and the outlines are hidden; it lands on the next still (also when the clip
  fails to load, e.g. in tests). Rotate buttons are hidden while a floor is selected.
- Floor selection (Figma 35:2647): the floor data is the source of truth. The selection indexes
  the type's floors top first (6F..GF); the floor stepper and arrow keys cover every floor in the
  data. Every view has one traced outline per floor (`BuildingView.floors`, top first; C2's
  Vector 51 traces five floors and is split per sub-path), hit-tested on the shape itself
  (`_PathClipper`); a tap or a long press selects (the floor tooltip is hover-only,
  `TooltipTriggerMode.manual`: its touch long-press used to swallow slow taps); on some views the bottom-centre Apartments panel covers the lowest outlines,
  which the stepper still reaches. Tap empty space clears. Floors are labelled everywhere (title, breadcrumb, stepper, tooltips,
  panels, masterplan floor filter) with the sheet's names via `AppStrings.floorName` /
  `floorNameOfLevel`: English "GF", "1F".."6F", Arabic "الأرضي", "ط1".."ط6". Selected floor swaps
  the "Building Details" info panel for "Floor Details" (`buildingDetails` / `floorDetails`; the
  floor's name is in its Floor row; that floor's apartments, types and area) and opens the `_ApartmentsPanel`
  (bottom-centre): a drag-scrollable row of cards (plan + bedrooms label), one per apartment
  type on that floor (hidden entirely on a floor with no apartments, e.g. type C's GF), loaded from
  `BuildingType.planAsset`: `assets/images/apartments/<building type>_<unit type>.png` (a_1br ..
  c_3br, the 3D plans from the Drive "floorplans" folder, one per building type + unit type,
  at their original size). Floor Details X only
  collapses the panel (info button reopens); Apartments X clears the selection.
- Apartment details (Figma 59:454): tapping an apartment card replaces both panels with
  `_ApartmentDetailsPanel` (bottom-start: floor, type, area, availability from
  `apartment_details.json`, plan image, Brochure / Register Interest buttons; availability is a
  badge: green "Available" 59:520 / red "Not Available" 221:35, `_AvailabilityRow`). Its X clears
  the apartment and brings the panels back.
- Compare (Figma 688:2955 button; 688:3008 one card, 689:3207 Select Building, 689:3472 Apartment
  Type, 689:4463 two cards, 689:3932 full; Arabic 689:4720 .. 689:5362;
  `lib/screens/compare_screen.dart`, `CompareScreen.open(context, initial:)`, a transparent modal
  route): the "Compare Apartment" pill (`icon_compare.svg`) sits bottom-end next to Restart on the
  building screen in all three views. From the building or floor view it opens empty, straight on
  Select Building; from the apartment view it opens with that apartment (building id + floor).
  Up to `CompareScreen.maxApartments` (3) `ComparedApartment`s (`lib/data/compared_apartment.dart`:
  building type + unit type, optional floor / building id), one card each (plan, Building Type,
  Apartment, Area, Floor, Status) plus an "Add apartment to compare" slot that turns into a
  two-step picker (Select Building tiles A/B/C from the exterior views, then Apartment Type tiles
  from `assets/images/compare/interior_1|2.jpg`: 1-2BR -> interior_1, 3BR+ -> interior_2; an
  already compared type is greyed "Added" and cannot be picked; picker back arrow / Back / Esc step
  back). A type picked in the comparison has no floor: its card lists the floors that have it
  ("GF – 5F" when contiguous). All slots match the tallest card (`IntrinsicHeight`). When full the
  title is "Apartments Comparison" and each card has Register Interest (opens the form with that
  apartment). Each card's X removes it. Assets in `assets/images/compare/`.
- Brochure: the apartment details Brochure button calls `BrochureScreen.open(context)`
  (`lib/screens/brochure_screen.dart`), a transparent full-screen modal showing
  `assets/pdfs/brochure.pdf` via `pdfx` (`PdfView`, portrait page centred in a padded, bordered frame sized to the page aspect, swipe + start/end arrow
  buttons, pinch zoom, page counter, X closes).
- `ImageModal` (`lib/screens/image_modal.dart`, `ImageModal.open(context, images:, initialIndex:)`):
  the brochure's layout for pictures (16:9 picture in the same bordered frame, Close top-end,
  caption + "n / N" at the bottom, arrows / swipe / arrow keys when there are several, Esc closes);
  each `ModalImage` carries its main-screen modal. Used by masterplan gallery tiles (all 9 renders,
  opened at the tapped one) and amenity labels.
- Every modal (brochure, image modal, restart dialog, idle prompt, register form, city landmark, compare)
  sits on a frosted backdrop: the screen behind is blurred and darkened. Use `ModalBackdrop`
  (`lib/widgets/modal_backdrop.dart`, blur 16 + `AppColors.scrim`, takes no taps) for new ones.
- Register Interest (Figma 41:3055 form, 100:17 thank-you; `lib/screens/register_interest_screen.dart`):
  the apartment details and comparison Register Interest buttons call
  `RegisterInterestScreen.open(context, target: InterestTarget(...))`, a transparent modal route with
  the "Your Information" form (name/email/phone validated). On submit the lead is saved on the tablet
  (`LeadStore`, below); if that fails the form stays open with `saveError`, otherwise it pushes
  `InterestRegisteredScreen` (blurred exterior view A1, logo, Restart Experience = popUntil first,
  dismissible toast top-end). Nothing is sent anywhere. Assets in `assets/images/register/`.
- Leads (`lib/services/lead_store.dart`, `LeadStore.instance`): every submission (time, name, email,
  phone as "+966 0512345678", language, building type / unit type / building id / floor / source
  `apartment_details` | `compare`) is appended to `register_interest.jsonl` (the record, never
  rewritten; a line cut short is skipped) and `register_interest.xlsx` is rebuilt from it after each
  one (sheet "Leads", every cell text so `+` and leading zeros survive, temp file + rename). Folder
  (`LeadStore.folderName`): Android `Internal storage/Ezdihar-Mashael Al Fursan` at the root of the
  shared storage (outlives an uninstall, visible in the Files app and over USB), elsewhere app
  documents. Edits to the xlsx in place are overwritten by the next submission: copy it off first.
  Writes are queued one at a time. Data is not encrypted. Build 42 kept the leads in
  `Android/data/com.narsun.ezdihar_remote/files/leads/`; `prepare()` (run at startup once access is
  granted) moves them in, skipping lines already there, and deletes that folder.
- Storage access gate (`StorageAccess`, `lib/services/storage_access.dart`, loaded in `main()`; uses
  `permission_handler`): Android 11+ needs "All files access" (`MANAGE_EXTERNAL_STORAGE`, the app's
  system settings page), Android 10 and below the storage permission (+ `requestLegacyExternalStorage`
  on 10). Until granted, `MyApp`'s builder shows `StorageAccessScreen` instead of the navigator (no
  route, idle reset or main-screen state yet): where the leads go + "Allow access". Refused -> the app
  closes (`SystemNavigator.pop`) and asks again on the next open; after "Don't ask again" (Android
  10 and below) it opens the app's settings first. `MyApp(storageAccess: null)` skips the gate (tests).
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
    dimmed and not tappable (`IgnorePointer`) when filtered out (building type, plus floor / size / availability select apartments:
    a building is lit when one of its apartments passes all of them; slider bounds come from the floor
    levels and apartment areas in the data). Chip shows "N of 22 match" / no-match with Clear filters / load error with Retry.
    Esc closes the panel. Pinch zooms 1x..3x around the fingers, double-tap toggles 2x at that
    point / 1x, and while zoomed one finger pans freely (at 1x a one-finger drag does nothing); the
    zoom wraps the map so building buttons stay put and tappable. Opening a building resets to 1x
    (`ZoomViewState.resetZoom`). Double-tap is detected on raw pointers so building taps
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
  IP/host + port bar, port default 3737, validated, prefilled from the saved pairing). Android needs INTERNET/CAMERA and cleartext traffic
  (and storage access for the leads, above).
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
  MirrorState, so the main screen keeps the previous state. Modals: the gallery image modal sends
  `ShowModal {kind: gallery, id: gallery_N}` for the render on screen, `HideModal` on close; an
  amenity's image modal sends `ShowModal {kind: amenity, id: <kind id, e.g. padel_court>, title,
  locale}` (the player does not handle `amenity` yet), `HideModal` on close; the
  brochure sends `ShowModal {kind: brochure, page}` on open and every page change, `HideModal` on
  close; an open city landmark sends `ShowModal {kind: landmark, id, title, description, metadata,
  locale}` (the card's texts in the current language, re-sent on language change; the player shows
  `Landmarks/<id>` in the gallery modal's frame, text centred at its bottom, metadata top-end, RTL for `ar`),
  `HideModal` on close; the comparison sends `ShowModal {kind: compare, apartments: [{buildingType,
  apartmentType, building?, floor?}]}` on open and on every add/remove (the player does not handle
  `compare` yet), `HideModal` on close. A new state also closes the modal. `PlayerConnection` drops repeats and resends the state
  + modal on every (re)connect. New screens/panels: wrap them in `MirrorState` and add the state to
  the player's `Assets/Experiences/ezdihar/config.json`.
- `ZoomView` (`lib/widgets/zoom_view.dart`): pinch / double-tap zoom with free pan for a
  full-screen child, exact layout at 1x. `GlassIconButton` takes `padding` for a pill with
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
- Masterplan building outlines: solid 2px `AppColors.floorOutline` stroke + 12% fill (40% when
  matching active filters, 60% on press), like the building screen's floors; Figma's 28% fill +
  hairline did not show on the photo. Filtered-out buildings dim via colours, not an opacity
  layer around the id pills' grouped backdrop blur (that drops the pills).
- Glass panels are capped by `FitPanel` (max ~60% of screen height, gallery 50%, info/apartment
  panels 45% width); apartment details panel spacing is 32 (Figma 48) and plan image 190 high.
- Secondary text on glass uses `AppColors.textSecondary` (white @ 72%), not Figma's 64%.

Sizing / touch:
- All icon buttons >= 48px touch target (rotate buttons 48, not 40; `PanelCloseButton` 48 target
  around the 32px X; masterplan id labels 48px-high target around the 24px pill).

Behaviour (not in Figma):
- Storage access screen before the app (client's request: no access -> app closes).
- `IdleReset` (90s + 15s countdown) and `LocaleFade`; thank-you screen auto-restart (30s) and toast
  auto-dismiss (8s); extra "Browse more units" button on the thank-you screen.
- `confirmRestart` dialog before Restart on masterplan and building screens.
- Masterplan: first-visit pulse + "Tap a building" hint chip, filter-driven dimming and
  match-count / no-match / error chip, "Clear filters" in the Filters panel, Esc key,
  pinch / double-tap zoom with free pan.
- Building detail: breadcrumb in the header, floor stepper (up/down) while a floor is selected,
  floor tooltips, "Tap a floor" hint, collapse chevron (not X) on the Building/Floor info panel,
  layered Back/Esc via `PopScope`, animated panel swaps, bedrooms label on apartment cards,
  fading edges + arrow buttons on the apartment row.
- Register form: validate-on-blur with error messages, autofill hints, next/done actions,
  country-code picker, digits-only phone, focus first invalid field; "could not save" message.
- Compare: an X on each card removes it; an empty comparison opens straight on Select Building;
  compared types show greyed "Added" in the picker; extra "Building Type" row on each card (types
  from different buildings are compared); floor range text for a type picked by type; picker back
  arrow; building type letters stay Latin in Arabic ("المبنى من النوع A").
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
  commit without a successful `main` run. Every passing `main` push replaces the single `main-latest`
  pre-release (never marked Latest) with its APK: the newest main build is always at
  https://github.com/Qazi-Narsun/ezdihar_remote/releases/tag/main-latest (also in README.md). The app is never
  published, so every build (debug and release, local and CI) is signed with the debug key
  committed at `android/app/debug.keystore` (standard `android` / `androiddebugkey` credentials):
  any build installs over any other. No signing secrets. "Make a release" = push to `main`, wait for that run to
  pass, then fast-forward `release` to that commit and push it. Bumping Flutter means bumping
  Gradle / AGP / Kotlin in `android/` to its minimums (Flutter 3.50: Gradle 9.5.0, AGP 9.3.1,
  Kotlin 2.4.20) in the same change. Still run `flutter analyze` and `flutter test` locally first.

## Keep this file current
When a screen, shared widget, token or convention is added, update the sections above.
