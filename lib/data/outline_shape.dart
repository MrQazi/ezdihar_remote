import 'dart:ui';

/// A straight-edged outline traced in Figma: its vector path data (`M x y L x y ... Z`,
/// possibly several closed sub-paths) relative to the vector's top-left corner at
/// ([dx], [dy]) in the Figma frame. [path] maps it onto a canvas [scale] times
/// the frame's size.
class OutlineShape {
  const OutlineShape(this.dx, this.dy, this.data);

  final double dx;
  final double dy;

  /// Figma `vectorPaths` data; only M, L and Z commands.
  final String data;

  Path path([double scale = 1]) {
    final path = Path();
    final tokens = RegExp(r'[MLZ]|-?\d+(?:\.\d+)?(?:e-?\d+)?').allMatches(data).map((m) => m[0]!).toList();
    var command = 'M';
    for (var i = 0; i < tokens.length;) {
      final token = tokens[i];
      if (token == 'Z') {
        path.close();
        i++;
        continue;
      }
      if (token == 'M' || token == 'L') {
        command = token;
        i++;
        continue;
      }
      final x = (dx + double.parse(tokens[i])) * scale;
      final y = (dy + double.parse(tokens[i + 1])) * scale;
      command == 'M' ? path.moveTo(x, y) : path.lineTo(x, y);
      // Coordinates after a moveto without a command are linetos (SVG rule).
      command = 'L';
      i += 2;
    }
    return path;
  }
}
