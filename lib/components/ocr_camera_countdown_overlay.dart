import 'dart:async';

import 'package:flutter/material.dart';

class OcrCameraCountdownOverlay extends StatefulWidget {
  final int duration;
  final Function() onZero;
  const OcrCameraCountdownOverlay({
    Key? key,
    required this.onZero,
    this.duration = 3,
  }) : super(key: key);

  @override
  State<OcrCameraCountdownOverlay> createState() => _OcrCameraCountdownOverlayState();
}

class _OcrCameraCountdownOverlayState extends State<OcrCameraCountdownOverlay> {
  Timer? _countdownTimer;
  int? _remainingTime;

  @override
  void initState() {
    super.initState();
    startCountdown();
  }

  void startCountdown() {
    _remainingTime = widget.duration;
    _countdownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _countDown(),
    );
  }

  void stopCountdown() {
    if (!mounted) {
      return;
    }
    setState(() => _countdownTimer!.cancel());
  }

  void _countDown() {
    const int interval = 1;
    if (!mounted) {
      return;
    }

    setState(() {
      final int seconds = _remainingTime! - interval;
      if (seconds < 0) {
        _countdownTimer!.cancel();
        widget.onZero();
      } else {
        _remainingTime = seconds;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    String displayText;
    if (_remainingTime! == 0) {
      displayText = 'Go';
    } else {
      displayText = '$_remainingTime';
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Column(
          children: [
            Container(
              width: 96.0,
              height: 96.0,
              decoration: const BoxDecoration(color: Colors.white54, shape: BoxShape.circle),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: Text(
                  displayText,
                  // This key causes the AnimatedSwitcher to interpret this as a "new"
                  // child each time the count changes, so that it will begin its animation
                  // when the count changes.
                  key: ValueKey<int>(_remainingTime!),
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
