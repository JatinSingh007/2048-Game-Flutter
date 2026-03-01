import 'package:flutter/material.dart';

/// Returns the background color for a tile with the given value.
/// Add or change entries in [_tileColors] to customize.
Color getTileColor(int value) {
  return _tileColors[value] ??
      const Color(0xFFCDC1B4); // default empty-tile color
}

final Map<int, Color> _tileColors = {
  0: const Color(0xFFCDC1B4), // empty
  2: const Color(0xFFEEE4DA),
  4: const Color(0xFFEDE0C8),
  8: const Color(0xFFF2B179),
  16: const Color(0xFFF59563),
  32: const Color(0xFFF67C5F),
  64: const Color(0xFFF65E3B),
  128: const Color(0xFFEDCF72),
  256: const Color(0xFFEDCC61),
  512: const Color(0xFFEDC850),
  1024: const Color(0xFFEDC53F),
  2048: const Color(0xFFEDC22E),
};

class TileWidget extends StatelessWidget {
  final int number;
  final double size;

  const TileWidget({
    super.key,
    required this.number,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final color = getTileColor(number);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.7),
        borderRadius: BorderRadius.circular(6),
      ),
      alignment: Alignment.center,
      child: Text(
        number == 0 ? '' : '$number',
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }
}
