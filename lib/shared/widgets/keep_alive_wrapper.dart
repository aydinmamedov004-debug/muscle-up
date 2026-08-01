import 'package:flutter/material.dart';

/// Keeps [child]'s state alive when it scrolls offscreen inside a
/// [PageView] — without this, [PageView] disposes tab pages outside its
/// cache extent and e.g. the workout timer/session would reset when
/// swiping away and back.
class KeepAliveWrapper extends StatefulWidget {
  final Widget child;

  const KeepAliveWrapper({super.key, required this.child});

  @override
  State<KeepAliveWrapper> createState() => _KeepAliveWrapperState();
}

class _KeepAliveWrapperState extends State<KeepAliveWrapper>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
