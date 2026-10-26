import 'package:flutter/material.dart';
import 'package:moven/core/constants/app_dimensions.dart';
import 'package:moven/features/orders/domain/models/order_status.dart';

/// Badge hiển thị trạng thái đơn hàng sinh động với animation và hover tooltip
class OrderStatusBadge extends StatefulWidget {
  final OrderStatus status;
  final bool isLarge;

  const OrderStatusBadge({
    super.key,
    required this.status,
    this.isLarge = false,
  });

  @override
  State<OrderStatusBadge> createState() => _OrderStatusBadgeState();
}

class _OrderStatusBadgeState extends State<OrderStatusBadge> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final status = widget.status;
    final bgColor = status.badgeBackgroundColor;
    final textColor = status.badgeTextColor;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.basic,
      child: Tooltip(
        message: status.description,
        waitDuration: const Duration(milliseconds: 300),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(
            horizontal: widget.isLarge ? AppDimensions.space12 : AppDimensions.space8,
            vertical: widget.isLarge ? AppDimensions.space6 : AppDimensions.space4,
          ),
          decoration: BoxDecoration(
            color: _isHovered ? bgColor.withValues(alpha: 0.9) : bgColor,
            borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
            border: Border.all(
              color: textColor.withValues(alpha: _isHovered ? 0.35 : 0.15),
              width: 1,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: textColor.withValues(alpha: 0.12),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                status.icon,
                size: widget.isLarge ? 16 : 14,
                color: textColor,
              ),
              const SizedBox(width: AppDimensions.space4),
              Flexible(
                fit: FlexFit.loose,
                child: Text(
                  status.displayName,
                  style: TextStyle(
                    color: textColor,
                    fontSize: widget.isLarge ? 13 : 12,
                    fontWeight: FontWeight.w600,
                    height: 1.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
