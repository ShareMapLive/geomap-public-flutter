import 'dart:async';
import 'package:flutter/material.dart';

/// A widget that displays real-time clock updates
class RealtimeClockText extends StatefulWidget {
  final TextStyle? style;
  final String Function(DateTime)? formatter;

  const RealtimeClockText({
    super.key,
    this.style,
    this.formatter,
  });

  @override
  State<RealtimeClockText> createState() => _RealtimeClockTextState();
}

class _RealtimeClockTextState extends State<RealtimeClockText> {
  late Timer _timer;
  DateTime _currentTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Update every second
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatTime(DateTime time) {
    if (widget.formatter != null) {
      return widget.formatter!(time);
    }

    // Default Vietnamese format: "2:33 Chiều"
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = hour < 12 ? 'Sáng' : 'Chiều';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);

    return '$displayHour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _formatTime(_currentTime),
      style: widget.style,
    );
  }
}
