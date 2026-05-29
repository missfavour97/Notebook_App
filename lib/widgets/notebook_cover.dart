import 'dart:math' as math;

import 'package:flutter/material.dart';

class NotebookCoverOption {
  final String name;
  final Color color;
  final Color accentColor;
  final String pattern;

  const NotebookCoverOption({
    required this.name,
    required this.color,
    required this.accentColor,
    required this.pattern,
  });
}

class NotebookCoverStyles {
  static const List<NotebookCoverOption> options = [
    NotebookCoverOption(
      name: 'Lagoon',
      color: Color(0xFF28A9A7),
      accentColor: Color(0xFFF3C945),
      pattern: 'stripe',
    ),
    NotebookCoverOption(
      name: 'Coral',
      color: Color(0xFFE65F7A),
      accentColor: Color(0xFF51364E),
      pattern: 'band',
    ),
    NotebookCoverOption(
      name: 'Graphite',
      color: Color(0xFF4B4F4A),
      accentColor: Color(0xFFA9C0A5),
      pattern: 'spine',
    ),
    NotebookCoverOption(
      name: 'Rose',
      color: Color(0xFFC48F9A),
      accentColor: Color(0xFFF5D7B8),
      pattern: 'ribbon',
    ),
    NotebookCoverOption(
      name: 'Evergreen',
      color: Color(0xFF1F6F68),
      accentColor: Color(0xFFE5C36B),
      pattern: 'stripe',
    ),
    NotebookCoverOption(
      name: 'Violet',
      color: Color(0xFF6D5DD3),
      accentColor: Color(0xFFFFB86B),
      pattern: 'dots',
    ),
    NotebookCoverOption(
      name: 'Sage',
      color: Color(0xFF89A86F),
      accentColor: Color(0xFFF7EFE0),
      pattern: 'grid',
    ),
    NotebookCoverOption(
      name: 'Sunset',
      color: Color(0xFFE7824A),
      accentColor: Color(0xFF2F4858),
      pattern: 'band',
    ),
  ];

  static NotebookCoverOption fallbackFor(String seed) {
    if (seed.isEmpty) return options.first;

    final index = seed.codeUnits.fold<int>(0, (value, unit) => value + unit);

    return options[index % options.length];
  }

  static NotebookCoverOption fromSubject(Map<String, dynamic> subject) {
    final option = fallbackFor(subject['title']?.toString() ?? '');
    final coverColor = _colorFromValue(subject['coverColor']);
    final coverPattern = subject['coverPattern']?.toString();

    if (coverColor == null && (coverPattern == null || coverPattern.isEmpty)) {
      return option;
    }

    return NotebookCoverOption(
      name: option.name,
      color: coverColor == null ? option.color : Color(coverColor),
      accentColor: option.accentColor,
      pattern: coverPattern == null || coverPattern.isEmpty
          ? option.pattern
          : coverPattern,
    );
  }

  static NotebookCoverOption byColorAndPattern(
    int? coverColor,
    String? coverPattern,
    String fallbackSeed,
  ) {
    final fallback = fallbackFor(fallbackSeed);

    if (coverColor == null && (coverPattern == null || coverPattern.isEmpty)) {
      return fallback;
    }

    final matched = options.firstWhere(
      (option) =>
          option.color.toARGB32() == coverColor &&
          option.pattern == coverPattern,
      orElse: () => fallback,
    );

    return NotebookCoverOption(
      name: matched.name,
      color: coverColor == null ? matched.color : Color(coverColor),
      accentColor: matched.accentColor,
      pattern: coverPattern == null || coverPattern.isEmpty
          ? matched.pattern
          : coverPattern,
    );
  }

  static int? _colorFromValue(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);

    return null;
  }
}

class NotebookCover extends StatelessWidget {
  final String title;
  final String subtitle;
  final NotebookCoverOption cover;
  final double height;
  final bool compact;

  const NotebookCover({
    super.key,
    required this.title,
    required this.subtitle,
    required this.cover,
    this.height = 190,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final titleStyle = compact
        ? Theme.of(context).textTheme.labelLarge
        : Theme.of(context).textTheme.titleMedium;
    final radius = compact ? 10.0 : 14.0;

    return Container(
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: cover.color,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: compact
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.10),
                  blurRadius: 12,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: NotebookPatternPainter(
                pattern: cover.pattern,
                color: Colors.white.withValues(alpha: 0.13),
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: compact ? 12 : 18,
            child: Container(color: Colors.black.withValues(alpha: 0.12)),
          ),
          Positioned(
            right: compact ? 10 : 16,
            top: 0,
            bottom: 0,
            width: compact ? 8 : 12,
            child: Container(color: cover.accentColor),
          ),
          Positioned(
            left: compact ? 24 : 34,
            right: compact ? 24 : 42,
            bottom: compact ? 14 : 22,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title.isEmpty ? 'Untitled' : title,
                  maxLines: compact ? 2 : 3,
                  overflow: TextOverflow.ellipsis,
                  style: titleStyle?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    height: 1.05,
                  ),
                ),
                if (!compact) ...[
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.84),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NotebookCoverSwatch extends StatelessWidget {
  final NotebookCoverOption cover;
  final bool isSelected;
  final VoidCallback onTap;

  const NotebookCoverSwatch({
    super.key,
    required this.cover,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 84,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            NotebookCover(
              title: '',
              subtitle: '',
              cover: cover,
              height: 74,
              compact: true,
            ),
            const SizedBox(height: 4),
            Text(
              cover.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}

class NotebookPatternPainter extends CustomPainter {
  final String pattern;
  final Color color;

  NotebookPatternPainter({required this.pattern, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    if (pattern == 'dots') {
      for (double y = 14; y < size.height; y += 20) {
        for (double x = 26; x < size.width; x += 20) {
          canvas.drawCircle(Offset(x, y), 1.5, paint);
        }
      }
      return;
    }

    if (pattern == 'grid') {
      for (double x = 24; x < size.width; x += 26) {
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
      }

      for (double y = 20; y < size.height; y += 26) {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      }
      return;
    }

    if (pattern == 'band') {
      final bandPaint = Paint()..color = color.withValues(alpha: 0.34);
      canvas.drawRect(
        Rect.fromLTWH(0, size.height * 0.26, size.width, size.height * 0.14),
        bandPaint,
      );
      return;
    }

    if (pattern == 'ribbon') {
      final ribbonPaint = Paint()..color = color.withValues(alpha: 0.40);
      final path = Path()
        ..moveTo(size.width * 0.65, 0)
        ..lineTo(size.width * 0.80, 0)
        ..lineTo(size.width * 0.60, size.height)
        ..lineTo(size.width * 0.45, size.height)
        ..close();
      canvas.drawPath(path, ribbonPaint);
      return;
    }

    if (pattern == 'spine') {
      for (double y = 16; y < size.height; y += 18) {
        canvas.drawLine(
          Offset(26, y),
          Offset(size.width * 0.42, y + math.sin(y) * 3),
          paint,
        );
      }
      return;
    }

    final stripePaint = Paint()
      ..color = color.withValues(alpha: 0.38)
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round;

    for (double x = -size.height; x < size.width; x += 38) {
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x + size.height, 0),
        stripePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant NotebookPatternPainter oldDelegate) {
    return oldDelegate.pattern != pattern || oldDelegate.color != color;
  }
}
