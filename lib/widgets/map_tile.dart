import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/ui_feedback.dart';
import '../theme/app_colors.dart';

/// Which side of the tile the name label sits on (physical, not directional,
/// because the map is geography and must not mirror in RTL).
enum TileLabelSide { left, right }

/// A landmark as a square tile (Figma 415:2868) with its name in a box that the
/// tile overlaps; tap it to open the landmark. The open landmark is drawn as
/// the same tile above the dimmed screen (Figma 401:2 .. 401:2018).
///
/// Must be a child of a [Stack]; [tileLeft]/[tileTop] place the 56px tile in
/// the parent's coordinate space.
class MapTile extends StatelessWidget {
  const MapTile({
    super.key,
    required this.tileLeft,
    required this.tileTop,
    required this.label,
    required this.labelWidth,
    required this.icon,
    required this.isArabic,
    required this.onTap,
    this.labelSide = TileLabelSide.left,
  });

  static const tileSize = 56.0;
  static const _height = 70.0; // 56 tile + 6 gap + 8 dot
  static const _overlap = 8.0;

  final double tileLeft;
  final double tileTop;
  final String label;
  final double labelWidth;

  /// Glyph drawn in the middle of the tile, laid out in a 24x24 box.
  final Widget icon;
  final bool isArabic;
  final VoidCallback onTap;
  final TileLabelSide labelSide;

  @override
  Widget build(BuildContext context) {
    final labelOnLeft = labelSide == TileLabelSide.left;
    final tileX = labelOnLeft ? labelWidth - _overlap : 0.0;
    final labelX = labelOnLeft ? 0.0 : tileSize - _overlap;
    final radius = BorderRadius.circular(8);
    return Positioned(
      left: tileLeft - tileX,
      top: tileTop,
      width: labelWidth + tileSize - _overlap,
      height: _height,
      child: Semantics(
        button: true,
        label: label,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              UiFeedback.select();
              onTap();
            },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: labelX,
                  top: 6,
                  width: labelWidth,
                  height: 44,
                  child: ClipRRect(
                    borderRadius: radius,
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        alignment: AlignmentDirectional.centerStart,
                        decoration: BoxDecoration(
                          color: AppColors.glass,
                          borderRadius: radius,
                          border: Border.all(color: AppColors.glassBorder, width: 0.48),
                        ),
                        child: Text(
                          label,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: _labelStyle(isArabic),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: tileX,
                  top: 0,
                  width: tileSize,
                  height: tileSize,
                  child: ClipRRect(
                    borderRadius: radius,
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.mapTile,
                          borderRadius: radius,
                          border: Border.all(color: AppColors.glassBorder, width: 0.32),
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Positioned(
                              left: 3,
                              top: 3,
                              width: 50,
                              height: 50,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: AppColors.mapTileInner,
                                  borderRadius: BorderRadius.circular(7),
                                ),
                              ),
                            ),
                            Positioned(left: 16, top: 16, width: 24, height: 24, child: icon),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: tileX + 24,
                  top: 62,
                  child: SvgPicture.asset('assets/images/city/tile_dot.svg'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

TextStyle _labelStyle(bool isArabic) => isArabic
    ? GoogleFonts.notoSansArabic(
        fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.mapLabelText, letterSpacing: 0.24, height: 1.3)
    : GoogleFonts.rubik(
        fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.mapLabelText, letterSpacing: 0.24, height: 1.2);

