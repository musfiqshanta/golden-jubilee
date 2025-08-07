import 'package:flutter/material.dart';
import '../services/countdown_service.dart';

class DynamicCountdownWidget extends StatefulWidget {
  final bool isRegistrationCountdown;
  final Widget Function(int days, int hours, int minutes, int seconds) builder;
  
  const DynamicCountdownWidget({
    super.key,
    required this.isRegistrationCountdown,
    required this.builder,
  });

  @override
  State<DynamicCountdownWidget> createState() => _DynamicCountdownWidgetState();
}

class _DynamicCountdownWidgetState extends State<DynamicCountdownWidget> {
  final AppCountdownService _countdownService = AppCountdownService();
  Duration _countdown = Duration.zero;

  @override
  void initState() {
    super.initState();
    _countdownService.initialize();
    
    // Listen to the appropriate stream
    if (widget.isRegistrationCountdown) {
      _countdownService.registrationCountdownStream.listen((duration) {
        if (mounted) {
          setState(() {
            _countdown = duration;
          });
        }
      });
    } else {
      _countdownService.jubileeCountdownStream.listen((duration) {
        if (mounted) {
          setState(() {
            _countdown = duration;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final days = _countdown.inDays;
    final hours = _countdown.inHours % 24;
    final minutes = _countdown.inMinutes % 60;
    final seconds = _countdown.inSeconds % 60;
    
    return widget.builder(days, hours, minutes, seconds);
  }
}
