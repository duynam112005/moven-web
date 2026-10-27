import 'package:flutter/material.dart';

/// Widget hiển thị sao đánh giá với animation và tương tác
/// - Mode `display`: hiển thị sao tĩnh theo giá trị rating
/// - Mode `interactive`: cho phép khách chọn sao bằng tap/hover
class RatingStars extends StatefulWidget {
  final double rating;
  final int maxStars;
  final double size;
  final bool interactive;
  final Color? activeColor;
  final Color? inactiveColor;
  final ValueChanged<int>? onRatingChanged;

  const RatingStars({
    super.key,
    required this.rating,
    this.maxStars = 5,
    this.size = 20,
    this.interactive = false,
    this.activeColor,
    this.inactiveColor,
    this.onRatingChanged,
  });

  /// Factory cho hiển thị tĩnh nhỏ trên card đánh giá
  const RatingStars.small({
    super.key,
    required this.rating,
    this.maxStars = 5,
    this.size = 14,
    this.interactive = false,
    this.activeColor,
    this.inactiveColor,
    this.onRatingChanged,
  });

  /// Factory cho chọn sao tương tác trong modal đánh giá
  const RatingStars.interactive({
    super.key,
    required this.rating,
    required this.onRatingChanged,
    this.maxStars = 5,
    this.size = 36,
    this.interactive = true,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  State<RatingStars> createState() => _RatingStarsState();
}

class _RatingStarsState extends State<RatingStars> {
  int _hoverIndex = -1;

  @override
  Widget build(BuildContext context) {
    final active = widget.activeColor ?? const Color(0xFFF59E0B);
    final inactive = widget.inactiveColor ?? const Color(0xFFD1D5DB);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.maxStars, (index) {
        final starNumber = index + 1;

        // Determine fill level for this star
        final double fill;
        if (widget.interactive && _hoverIndex >= 0) {
          fill = starNumber <= _hoverIndex + 1 ? 1.0 : 0.0;
        } else {
          final diff = widget.rating - index;
          fill = diff >= 1.0
              ? 1.0
              : diff > 0
                  ? diff
                  : 0.0;
        }

        final icon = fill >= 0.75
            ? Icons.star_rounded
            : fill >= 0.25
                ? Icons.star_half_rounded
                : Icons.star_outline_rounded;

        final color = fill > 0 ? active : inactive;

        Widget star = AnimatedScale(
          scale: (widget.interactive && _hoverIndex == index) ? 1.25 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutBack,
          child: Icon(icon, size: widget.size, color: color),
        );

        if (widget.interactive) {
          star = MouseRegion(
            onEnter: (_) => setState(() => _hoverIndex = index),
            onExit: (_) => setState(() => _hoverIndex = -1),
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => widget.onRatingChanged?.call(starNumber),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: star,
              ),
            ),
          );
        }

        return star;
      }),
    );
  }
}
