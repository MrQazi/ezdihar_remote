import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../data/building_data.dart';
import '../data/building_views.dart';
import '../data/compared_apartment.dart';
import '../l10n/app_strings.dart';
import '../services/lead_store.dart';
import '../services/player_connection.dart';
import '../services/ui_feedback.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../widgets/fit_panel.dart';
import '../widgets/modal_backdrop.dart';
import '../widgets/panel_close_button.dart';
import 'register_interest_screen.dart';

const _assets = 'assets/images/compare';

/// Apartment comparison (Figma 688:3008, 689:3207, 740:6332 / 740:6533,
/// 740:6964, 689:3472, 689:4463, 689:3932), a modal over the building screen,
/// opened by its Compare Apartment button (Figma 688:2955).
///
/// Up to [maxApartments] apartment cards side by side (plan, building type,
/// apartment type, area, floor, building number, status). While there is
/// room, one more slot adds an apartment: "Add apartment to compare", then
/// Select Building (type), Select Building Number, Select Floor and Apartment
/// Type, all from the data (Figma's numbers are placeholders). Full, the panel
/// is "Apartments Comparison" and every card has a Register Interest button.
/// A card's X takes it out again.
///
/// X or Esc closes it; Back first steps out of the picker.
class CompareScreen extends StatefulWidget {
  const CompareScreen({super.key, this.initial = const []});

  /// In the comparison when it opens: the apartment of the open apartment
  /// details, or none (opened from the building or floor view).
  final List<ComparedApartment> initial;

  static const maxApartments = 3;

  static Future<void> open(BuildContext context, {List<ComparedApartment> initial = const []}) {
    return Navigator.of(context).push<void>(
      PageRouteBuilder<void>(
        opaque: false,
        pageBuilder: (_, _, _) => CompareScreen(initial: initial),
        transitionsBuilder: (_, animation, _, child) => FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  State<CompareScreen> createState() => _CompareScreenState();
}

/// What the add slot shows.
enum _Step { prompt, building, buildingNumber, floor, apartmentType }

/// Figma sizes: 357-wide cards 8 apart; a card without its button is 377 high.
const _slotWidth = 357.0;
const _slotGap = 8.0;
const _minSlotHeight = 377.0;

/// Tile pictures are decoded small: the stills are 3840x2160.
ImageProvider _tileImage(String asset) =>
    ResizeImage(AssetImage(asset), width: 640, policy: ResizeImagePolicy.fit);

/// Select Building pictures (Figma 689:3402): the exterior stills Figma uses,
/// framed as there. Another type would show its first view.
const _buildingPhotos = {
  'A': ('assets/images/building/views/a_1.jpg', Alignment.center),
  'B': ('assets/images/building/views/b_1.jpg', Alignment.centerLeft),
  'C': ('assets/images/building/views/c_2.jpg', Alignment.topCenter),
};

(String, Alignment)? _buildingPhoto(String type) {
  if (_buildingPhotos[type] case final photo?) return photo;
  final views = BuildingView.of(type);
  return views.isEmpty ? null : (views.first.image, Alignment.center);
}

/// Apartment Type pictures (Figma 689:3683): Figma has one interior for 1BR
/// and 2BR and another for 3BR, which the larger types share.
String _interior(String unitType) => switch (unitType.replaceAll(RegExp(r'\D'), '')) {
      '1' || '2' => '$_assets/interior_1.jpg',
      _ => '$_assets/interior_2.jpg',
    };

class _CompareScreenState extends State<CompareScreen> {
  late final List<ComparedApartment> _apartments = widget.initial.take(CompareScreen.maxApartments).toList();

  /// Opened empty, the picker shows at once.
  late _Step _step = _apartments.isEmpty ? _Step.building : _Step.prompt;

  /// The choices made so far in the picker: building type (Select Building),
  /// building id (Select Building Number) and floor (Select Floor).
  BuildingType? _pickedType;
  String? _pickedBuilding;
  FloorDetails? _pickedFloor;

  /// Every building type, for the picker (null while loading).
  List<BuildingType>? _types;
  bool _loadFailed = false;

  bool get _full => _apartments.length >= CompareScreen.maxApartments;

  @override
  void initState() {
    super.initState();
    _load();
    _mirror();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    for (final (asset, _) in _buildingPhotos.values) {
      precacheImage(_tileImage(asset), context);
    }
    for (final interior in ['$_assets/interior_1.jpg', '$_assets/interior_2.jpg']) {
      precacheImage(_tileImage(interior), context);
    }
  }

  @override
  void dispose() {
    PlayerConnection.instance.hideModal();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final types = await BuildingType.loadAll();
      if (mounted) setState(() => _types = types);
    } catch (_) {
      if (mounted) setState(() => _loadFailed = true);
    }
  }

  void _retry() {
    setState(() => _loadFailed = false);
    _load();
  }

  /// The main screen is told which apartments are being compared.
  void _mirror() => PlayerConnection.instance.showModal({
        'kind': 'compare',
        'apartments': [for (final a in _apartments) a.mirror],
      });

  /// Back in the picker, one step at a time: Apartment Type -> Select Floor ->
  /// Select Building Number -> Select Building -> the prompt.
  void _back() => setState(() {
        switch (_step) {
          case _Step.apartmentType:
            _pickedFloor = null;
            _step = _Step.floor;
          case _Step.floor:
            _pickedBuilding = null;
            _step = _Step.buildingNumber;
          case _Step.buildingNumber:
            _pickedType = null;
            _step = _Step.building;
          case _Step.building || _Step.prompt:
            _step = _Step.prompt;
        }
      });

  void _pickType(BuildingType type) => setState(() {
        _pickedType = type;
        _step = _Step.buildingNumber;
      });

  void _pickBuilding(String id) => setState(() {
        _pickedBuilding = id;
        _step = _Step.floor;
      });

  void _pickFloor(FloorDetails floor) => setState(() {
        _pickedFloor = floor;
        _step = _Step.apartmentType;
      });

  void _add(String unitType) {
    setState(() {
      _apartments.add(ComparedApartment(
        type: _pickedType!,
        unitType: unitType,
        floor: _pickedFloor!.code,
        buildingId: _pickedBuilding!,
      ));
      _pickedType = null;
      _pickedBuilding = null;
      _pickedFloor = null;
      _step = _Step.prompt;
    });
    _mirror();
  }

  void _remove(ComparedApartment apartment) {
    setState(() => _apartments.remove(apartment));
    _mirror();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return PopScope(
      canPop: _step == _Step.prompt,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.escape): () {
            UiFeedback.dismiss();
            Navigator.of(context).maybePop();
          },
        },
        child: Focus(
          autofocus: true,
          child: Material(
            type: MaterialType.transparency,
            child: ModalBackdrop(
              child: SafeArea(
                minimum: const EdgeInsets.all(32),
                child: Center(
                  child: FitPanel(
                    maxHeightFactor: 0.85,
                    alignment: Alignment.center,
                    child: _panel(strings),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _panel(AppStrings strings) {
    final radius = BorderRadius.circular(40);
    final slots = _apartments.length + (_full ? 0 : 1);
    final subtitle = _full
        ? null
        : _apartments.isEmpty
            ? strings.compareSelectFirst
            : strings.compareSelectMore;
    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
        child: Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(color: AppColors.glass, borderRadius: radius),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            child: SizedBox(
              width: slots * _slotWidth + (slots - 1) * _slotGap,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _full ? strings.apartmentsComparison : strings.compareApartments,
                              style: appText(strings, 24, FontWeight.w500, spacing: -0.24),
                            ),
                            if (subtitle != null) ...[
                              const SizedBox(height: 12),
                              Text(
                                subtitle,
                                style: appText(strings, 16, FontWeight.w400,
                                    color: AppColors.panelSubtitle, spacing: -0.16),
                              ),
                            ],
                          ],
                        ),
                      ),
                      PanelCloseButton(tooltip: strings.close, onPressed: () => Navigator.of(context).pop()),
                    ],
                  ),
                  SizedBox(height: _full ? 40 : 24),
                  // Every slot as tall as the tallest card (at least Figma's 377).
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final (i, apartment) in _apartments.indexed) ...[
                          if (i > 0) const SizedBox(width: _slotGap),
                          _ApartmentCard(
                            key: ObjectKey(apartment),
                            apartment: apartment,
                            registerInterest: _full,
                            onRemove: () => _remove(apartment),
                          ),
                        ],
                        if (!_full) ...[
                          if (_apartments.isNotEmpty) const SizedBox(width: _slotGap),
                          _addSlot(strings),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// The empty slot: the "Add apartment to compare" prompt or a picker step.
  Widget _addSlot(AppStrings strings) {
    final Widget child = switch (_step) {
      _Step.prompt => InkWell(
          key: const ValueKey('prompt'),
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            UiFeedback.tap();
            setState(() => _step = _Step.building);
          },
          child: Padding(
            padding: const EdgeInsets.all(64),
            child: Center(
              child: Text(
                strings.addApartmentToCompare,
                textAlign: TextAlign.center,
                style: appText(strings, 18, FontWeight.w400),
              ),
            ),
          ),
        ),
      _Step.building => _PickerStep(
          key: const ValueKey('building'),
          title: strings.selectBuilding,
          onBack: _back,
          labelSize: 12,
          labelGap: 7.381,
          tiles: _buildingTiles(strings),
          loading: _types == null && !_loadFailed,
          failed: _loadFailed,
          onRetry: _retry,
        ),
      _Step.buildingNumber => _PickerStep(
          key: ValueKey('number ${_pickedType!.type}'),
          title: strings.selectBuildingNumber,
          onBack: _back,
          labelSize: 12,
          labelGap: 0,
          choices: [
            for (final id in _pickedType!.buildingIds) _Choice(label: id, onTap: () => _pickBuilding(id)),
          ],
        ),
      _Step.floor => _PickerStep(
          key: ValueKey('floor $_pickedBuilding'),
          title: strings.selectFloor,
          onBack: _back,
          labelSize: 12,
          labelGap: 0,
          // Top floor first, as in Figma; only floors with apartments.
          singleColumn: true,
          choices: [
            for (final floor in _pickedType!.floorDetails.reversed)
              if (floor.apartmentTypes.isNotEmpty)
                _Choice(label: strings.floorName(floor.code), onTap: () => _pickFloor(floor)),
          ],
        ),
      _Step.apartmentType => _PickerStep(
          key: ValueKey('type $_pickedBuilding ${_pickedFloor!.code}'),
          title: strings.apartmentType,
          onBack: _back,
          labelSize: 14,
          labelGap: 16,
          tiles: [
            for (final unitType in _pickedFloor!.apartmentTypes)
              _Tile(
                image: _interior(unitType),
                label: strings.unitTypeName(unitType),
                compared: _apartments.any((a) => a.isSame(_pickedBuilding!, _pickedFloor!.code, unitType)),
                onTap: () => _add(unitType),
              ),
          ],
        ),
    };
    return SizedBox(
      width: _slotWidth,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: _minSlotHeight),
        child: Material(
          color: AppColors.compareCard,
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: child,
          ),
        ),
      ),
    );
  }

  List<_Tile> _buildingTiles(AppStrings strings) => [
        for (final type in _types ?? const <BuildingType>[])
          if (_buildingPhoto(type.type) case (final image, final alignment))
            _Tile(
              image: image,
              alignment: alignment,
              label: strings.buildingTypeName(type.type),
              onTap: () => _pickType(type),
            ),
      ];
}

/// One apartment of the comparison (Figma 688:3142; with its Register
/// Interest button once the comparison is full, 689:4107).
class _ApartmentCard extends StatelessWidget {
  const _ApartmentCard({
    super.key,
    required this.apartment,
    required this.registerInterest,
    required this.onRemove,
  });

  final ComparedApartment apartment;
  final bool registerInterest;
  final VoidCallback onRemove;

  /// Figma: the plan is 259:146 across the card's 293 inner width.
  static const _planHeight = 293 * 146 / 259;

  /// Figma rows are 24 apart between cap-height-trimmed text.
  static const _rowGap = 16.0;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final details = apartment.details;
    final style = appText(strings, 16, FontWeight.w400, color: AppColors.textSecondary, spacing: -0.16);
    final rows = [
      (strings.buildingType, Text(apartment.type.type, style: style)),
      (strings.apartment, Text(strings.unitTypeName(apartment.unitType), style: style)),
      (strings.area, Text(details == null ? '-' : '${details.area} ${strings.areaUnit}', style: style)),
      (strings.floor, Text(strings.floorName(apartment.floor), style: style)),
      (strings.buildingNo, Text(apartment.buildingId, style: style)),
      if (details != null) (strings.status, _Status(available: details.available, style: style)),
    ];
    return SizedBox(
      width: _slotWidth,
      child: DecoratedBox(
        decoration: BoxDecoration(color: AppColors.compareCard, borderRadius: BorderRadius.circular(16)),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: _planHeight,
                    width: double.infinity,
                    child: Image.asset(apartment.plan, fit: BoxFit.contain),
                  ),
                  const SizedBox(height: 32),
                  for (final (i, (label, value)) in rows.indexed) ...[
                    if (i > 0) const SizedBox(height: _rowGap),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: Text(label, style: style)),
                        const SizedBox(width: 18),
                        value,
                      ],
                    ),
                  ],
                  if (registerInterest) ...[
                    const SizedBox(height: 40),
                    SizedBox(width: double.infinity, child: _RegisterButton(apartment: apartment)),
                  ],
                ],
              ),
            ),
            PositionedDirectional(
              top: 0,
              end: 0,
              child: PanelCloseButton(
                tooltip: strings.removeFromCompare,
                onPressed: onRemove,
                child: SvgPicture.asset('assets/images/masterplan/icon_close.svg', width: 20, height: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Status dot and text (Figma 688:3164).
class _Status extends StatelessWidget {
  const _Status({required this.available, required this.style});

  final bool available;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: available ? AppColors.statusAvailable : AppColors.unavailableBadge,
          ),
        ),
        const SizedBox(width: 8),
        Text(available ? strings.available : strings.unavailable, style: style),
      ],
    );
  }
}

/// Light Register Interest button of a full comparison (Figma 689:4141).
class _RegisterButton extends StatelessWidget {
  const _RegisterButton({required this.apartment});

  final ComparedApartment apartment;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final radius = BorderRadius.circular(8);
    return Material(
      color: AppColors.compareButton,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: () {
          UiFeedback.select();
          RegisterInterestScreen.open(
            context,
            target: InterestTarget(
              buildingType: apartment.type.type,
              unitType: apartment.unitType,
              buildingId: apartment.buildingId,
              floor: apartment.floor,
              source: InterestTarget.fromCompare,
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Center(
            child: Text(
              strings.registerInterest,
              style: appText(strings, 18, FontWeight.w500, color: AppColors.compareButtonText, spacing: -0.18),
            ),
          ),
        ),
      ),
    );
  }
}

/// A picker step in the add slot (Figma 689:3402 / 689:3683): back arrow and
/// title, then the tiles two to a row (an odd last one spans the row), or
/// a list of text buttons ([choices], Figma 740:6475 / 740:6676 / 740:7107).
class _PickerStep extends StatelessWidget {
  const _PickerStep({
    super.key,
    required this.title,
    required this.onBack,
    this.tiles = const [],
    this.choices,
    this.singleColumn = false,
    required this.labelSize,
    required this.labelGap,
    this.loading = false,
    this.failed = false,
    this.onRetry,
  });

  final String title;
  final VoidCallback onBack;
  final List<_Tile> tiles;

  /// Text buttons instead of picture tiles.
  final List<_Choice>? choices;

  /// Keep [choices] in one column however many there are.
  final bool singleColumn;
  final double labelSize;
  final double labelGap;
  final bool loading;
  final bool failed;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final rows = (tiles.length / 2).ceil();
    // The arrow's 48 touch target reaches 12 past its 24 icon, so the edges
    // are 12 in where Figma has 24.
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                tooltip: strings.back,
                onPressed: () {
                  UiFeedback.dismiss();
                  onBack();
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(width: 48, height: 48),
                icon: Transform.flip(
                  flipX: rtl,
                  child: SvgPicture.asset('$_assets/arrow_left.svg', width: 24, height: 24),
                ),
              ),
              Expanded(
                child: Text(title, textAlign: TextAlign.center, style: appText(strings, 18, FontWeight.w400)),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: failed
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(strings.loadError,
                              textAlign: TextAlign.center, style: appText(strings, 16, FontWeight.w400)),
                          TextButton(
                            onPressed: onRetry,
                            child: Text(strings.retry,
                                style: appText(strings, 16, FontWeight.w500, color: AppColors.accent)),
                          ),
                        ],
                      ),
                    )
                  : loading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
                      : choices != null
                      ? _ChoiceList(choices: choices!, labelSize: labelSize, singleColumn: singleColumn)
                      : Column(
                          children: [
                            for (var r = 0; r < rows; r++) ...[
                              if (r > 0) const SizedBox(height: 16),
                              Expanded(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    for (var c = 0; c < 2 && r * 2 + c < tiles.length; c++) ...[
                                      if (c > 0) const SizedBox(width: 8),
                                      Expanded(
                                        child: _TileFrame(
                                          tile: tiles[r * 2 + c],
                                          labelSize: labelSize,
                                          labelGap: labelGap,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A text choice of the picker (a building number or a floor).
class _Choice {
  const _Choice({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;
}

/// The text choices filling the picker's height (Figma 740:6475 / 740:7107:
/// one column, 8 apart; 740:6676: more than six go two to a row, 4 apart,
/// an odd last one spanning the row).
class _ChoiceList extends StatelessWidget {
  const _ChoiceList({required this.choices, required this.labelSize, required this.singleColumn});

  final List<_Choice> choices;
  final double labelSize;

  /// Always one column (floors: at most seven, Figma 740:7107).
  final bool singleColumn;

  static const _maxSingleColumn = 6;

  @override
  Widget build(BuildContext context) {
    final columns = singleColumn || choices.length <= _maxSingleColumn ? 1 : 2;
    final gap = columns == 1 ? 8.0 : 4.0;
    final rows = (choices.length / columns).ceil();
    return Column(
      children: [
        for (var r = 0; r < rows; r++) ...[
          if (r > 0) SizedBox(height: gap),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var c = 0; c < columns && r * columns + c < choices.length; c++) ...[
                  if (c > 0) SizedBox(width: gap),
                  Expanded(child: _ChoiceButton(choice: choices[r * columns + c], labelSize: labelSize)),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// Figma 740:6733: white @ 10%, 8 rounded, the label centred.
class _ChoiceButton extends StatelessWidget {
  const _ChoiceButton({required this.choice, required this.labelSize});

  final _Choice choice;
  final double labelSize;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final radius = BorderRadius.circular(8);
    return Material(
      color: AppColors.compareChoice,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: () {
          UiFeedback.select();
          choice.onTap();
        },
        child: Center(
          child: Text(
            choice.label,
            textAlign: TextAlign.center,
            maxLines: 1,
            style: appText(strings, labelSize, FontWeight.w400),
          ),
        ),
      ),
    );
  }
}

/// A picker choice: a picture and its label.
class _Tile {
  const _Tile({
    required this.image,
    required this.label,
    required this.onTap,
    this.alignment = Alignment.center,
    this.compared = false,
  });

  final String image;

  /// Framing of the picture (physical: photos do not mirror in RTL).
  final Alignment alignment;
  final String label;
  final VoidCallback onTap;

  /// Already in the comparison: dimmed, marked and not tappable.
  final bool compared;
}

class _TileFrame extends StatelessWidget {
  const _TileFrame({required this.tile, required this.labelSize, required this.labelGap});

  final _Tile tile;
  final double labelSize;
  final double labelGap;

  void _tap() {
    UiFeedback.select();
    tile.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final radius = BorderRadius.circular(8);
    return Semantics(
      button: !tile.compared,
      label: tile.compared ? '${tile.label}, ${strings.alreadyCompared}' : tile.label,
      excludeSemantics: true,
      // The label takes taps too; the picture shows the ripple.
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: tile.compared ? null : _tap,
        child: Column(
        children: [
          // Ink, not Image: a decoration reports no intrinsic height, so the
          // slot keeps the cards' height whatever the picture's size.
          Expanded(
            child: Opacity(
              opacity: tile.compared ? 0.4 : 1,
              child: Material(
                type: MaterialType.transparency,
                child: Ink(
                  decoration: BoxDecoration(
                    borderRadius: radius,
                    image: DecorationImage(
                      image: _tileImage(tile.image),
                      fit: BoxFit.cover,
                      alignment: tile.alignment,
                    ),
                  ),
                  child: InkWell(
                    borderRadius: radius,
                    onTap: tile.compared ? null : _tap,
                    child: tile.compared
                        ? const Center(child: Icon(Icons.check_circle_rounded, color: Colors.white, size: 32))
                        : null,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: labelGap),
          Text(
            tile.compared ? '${tile.label} · ${strings.alreadyCompared}' : tile.label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: appText(strings, labelSize, FontWeight.w400),
          ),
        ],
        ),
      ),
    );
  }
}
