import 'package:flutter/material.dart';
import 'package:geomap_package/geomap_package.dart';
import 'package:get/get.dart';
import 'card_container.dart';
import 'realtime_clock_text.dart';

class GeoMapStatusCard extends StatelessWidget {
  final GeoMapController controller;
  final String geoMapCode;
  final FontConfig fontConfig;
  final bool centerReload;
  final bool showCloseButton;
  final VoidCallback? onClosePressed;
  final VoidCallback? onReloadPressed;

  const GeoMapStatusCard({
    super.key,
    required this.controller,
    required this.geoMapCode,
    required this.fontConfig,
    this.centerReload = false,
    this.showCloseButton = false,
    this.onClosePressed,
    this.onReloadPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (centerReload) {
      return CardContainer(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: [
            Align(alignment: Alignment.centerLeft, child: _buildReloadButton()),
            const SizedBox(width: 12),
            Expanded(child: _buildTopContent()),
            if (showCloseButton) _buildCloseButton(),
          ],
        ),
      );
    }

    return CardContainer(
      child: Row(
        children: [
          _buildReloadButton(),
          const SizedBox(width: 12),
          Expanded(child: _buildTopContent()),
          if (showCloseButton) _buildCloseButton(),
        ],
      ),
    );
  }

  /// Shows the dropdown when multi-day, otherwise shows the realtime clock.
  Widget _buildTopContent() {
    return Obx(() {
      if (controller.isMultiDay) {
        final days = controller.availableDays;
        final selected = controller.selectedDay;
        return Container(
          margin: const EdgeInsets.only(right: 16),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<DateTime>(
              value: selected,
              isExpanded: true,
              dropdownColor: Colors.white,
              focusColor: Colors.transparent,
              icon: const Icon(Icons.keyboard_arrow_down,
                  color: Colors.green, size: 18),
              style: fontConfig.titleStyle(
                  fontWeight: FontWeight.bold, fontSize: 15),
              selectedItemBuilder: (BuildContext context) {
                return days.map<Widget>((DateTime day) {
                  final label =
                      '${day.day.toString().padLeft(2, '0')}/${day.month.toString().padLeft(2, '0')}/${day.year}';
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.calendar_today,
                          size: 14, color: Colors.green),
                      const SizedBox(width: 6),
                      Text(label,
                          style: const TextStyle(color: Colors.black87)),
                    ],
                  );
                }).toList();
              },
              items: days.map((day) {
                final label =
                    '${day.day.toString().padLeft(2, '0')}/${day.month.toString().padLeft(2, '0')}/${day.year}';
                return DropdownMenuItem(
                  value: day,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.calendar_today,
                          size: 14, color: Colors.green),
                      const SizedBox(width: 6),
                      Text(label),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (day) {
                if (day != null) {
                  controller.selectDay(day, geoMapCode);
                }
              },
            ),
          ),
        );
      }
      return RealtimeClockText(
        style: fontConfig.titleStyle(fontWeight: FontWeight.bold, fontSize: 16),
      );
    });
  }

  Widget _buildCloseButton() {
    return Tooltip(
      message: 'Đóng',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onClosePressed,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.08),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.red.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.close_rounded,
              size: 20,
              color: Colors.red[700],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReloadButton() {
    return Obx(() {
      final isLoading = controller.isLoadingData;
      return Tooltip(
        message: 'Làm mới dữ liệu',
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isLoading
                ? null
                : () {
                    controller.getAllData(geoMapCode, force: true);
                    onReloadPressed?.call();
                  },
            borderRadius: BorderRadius.circular(30),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isLoading
                    ? Colors.grey[100]
                    : Colors.blue.withValues(alpha: 0.08),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isLoading
                      ? Colors.grey[300]!
                      : Colors.blue.withValues(alpha: 0.2),
                  width: 1,
                ),
                boxShadow: [
                  if (!isLoading)
                    BoxShadow(
                      color: Colors.blue.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.blue),
                        ),
                      )
                    : Icon(
                        Icons.refresh_rounded,
                        key: const ValueKey('refresh_icon'),
                        size: 20,
                        color: Colors.blue[700],
                      ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

// Animated Chevron Line Widget
class _AnimatedChevronLine extends StatefulWidget {
  const _AnimatedChevronLine();

  @override
  State<_AnimatedChevronLine> createState() => _AnimatedChevronLineState();
}

class _AnimatedChevronLineState extends State<_AnimatedChevronLine>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _ChevronLinePainter(offset: _controller.value),
        );
      },
    );
  }
}

class _ChevronLinePainter extends CustomPainter {
  final double offset;

  _ChevronLinePainter({this.offset = 0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xff3B82F6)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    double chevronWidth = 3;
    double spacing = 8;
    double patternWidth = chevronWidth + spacing;

    // Calculate animated offset (positive to move left-to-right)
    double animatedOffset = offset * patternWidth;
    double startX = animatedOffset;

    // Draw chevrons with animation offset
    while (startX < size.width) {
      if (startX + chevronWidth >= 0) {
        // Only draw visible chevrons
        Path path = Path();
        path.moveTo(startX, 0);
        path.lineTo(startX + chevronWidth / 2, size.height / 2);
        path.lineTo(startX, size.height);

        canvas.drawPath(path, paint);
      }
      startX += patternWidth;
    }
  }

  @override
  bool shouldRepaint(_ChevronLinePainter oldDelegate) =>
      oldDelegate.offset != offset;
}
