import 'dart:async';

import 'package:flutter/material.dart';

void showIslandNotice(
  BuildContext context,
  String message, {
  IconData icon = Icons.check_circle_outline_rounded,
}) {
  final overlay = Overlay.maybeOf(context);
  if (overlay == null) {
    return;
  }

  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) => _IslandNotice(
      message: message,
      icon: icon,
      onFinished: entry.remove,
    ),
  );

  overlay.insert(entry);
}

class _IslandNotice extends StatefulWidget {
  const _IslandNotice({
    required this.message,
    required this.icon,
    required this.onFinished,
  });

  final String message;
  final IconData icon;
  final VoidCallback onFinished;

  @override
  State<_IslandNotice> createState() => _IslandNoticeState();
}

class _IslandNoticeState extends State<_IslandNotice>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
      reverseDuration: const Duration(milliseconds: 220),
    )..forward();
    _dismissTimer = Timer(const Duration(seconds: 2), _dismiss);
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    if (!mounted) {
      return;
    }
    await _controller.reverse();
    widget.onFinished();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return IgnorePointer(
      child: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 12, left: 20, right: 20),
            child: FadeTransition(
              opacity: _controller,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, -0.12),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: _controller,
                    curve: Curves.easeOutCubic,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface.withOpacity(0.96),
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.14),
                          blurRadius: 28,
                          offset: const Offset(0, 10),
                        ),
                      ],
                      border: Border.all(
                        color:
                            theme.colorScheme.outlineVariant.withOpacity(0.5),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            widget.icon,
                            size: 18,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              widget.message,
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
