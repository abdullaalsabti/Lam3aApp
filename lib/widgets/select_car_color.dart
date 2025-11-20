import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ColorButton extends ConsumerStatefulWidget {
  const ColorButton({required this.selectedColor, required this.onTap, required this.isSelected, super.key});
  final Color selectedColor;
  final VoidCallback onTap;
  final bool isSelected;

  @override
  ConsumerState<ColorButton> createState() => _ColorButton();
}

class _ColorButton extends ConsumerState<ColorButton> {

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: widget.selectedColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: widget.onTap,
        child: Container(
          width: 48,
          height: 48,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.isSelected ? scheme.primary : Colors.transparent,
              width: 3,
            ),
          ),
        ),
      ),
    );
  }
}