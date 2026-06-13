import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../controllers/note_controller.dart';

class SubjectNoteScreen extends StatefulWidget {
  final String subjectTitle;
  final String selectedField;
  final String noteType;

  const SubjectNoteScreen({
    super.key,
    required this.subjectTitle,
    required this.selectedField,
    required this.noteType,
  });

  @override
  State<SubjectNoteScreen> createState() => _SubjectNoteScreenState();
}

class _SubjectNoteScreenState extends State<SubjectNoteScreen> {
  final TextEditingController noteController = TextEditingController();
  final NoteController noteDbController = NoteController();

  String selectedTool = 'Pen';
  String selectedTemplate = 'Algorithm';
  String selectedPenType = PenTypeCatalog.defaultLabel;
  bool showPenTray = true;

  Color selectedPenColor = Colors.black;
  double selectedStrokeWidth = 2.5;
  double selectedEraserWidth = 24.0;

  List<DrawingStroke> strokes = [];
  List<NotePageElement> pageElements = [];
  DrawingStroke? currentStroke;
  Offset? eraserPreviewPoint;
  int nextPageElementId = 1;
  int nextStickyColorIndex = 0;
  final Map<int, TextEditingController> pageElementControllers = {};

  final List<Color> penColors = [
    Colors.black,
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.purple,
    Colors.orange,
    Colors.pink,
  ];

  final List<double> strokeWidths = [2.0, 4.0, 6.0, 8.0];
  final List<double> eraserWidths = [12.0, 24.0, 36.0, 52.0];
  final List<Color> stickyColors = const [
    Color(0xFFFFF3A3),
    Color(0xFFFFC9DE),
    Color(0xFFC9EDFF),
    Color(0xFFD7F7C2),
    Color(0xFFFFD6A5),
  ];
  final List<String> stickerOptions = const [
    '⭐',
    '💡',
    '✅',
    '❗',
    '📌',
    '🎯',
    '🧠',
    '🔥',
    '❤️',
    '⚠️',
    '❓',
    '📚',
    '✨',
    '🔖',
    '📝',
    '📎',
  ];

  @override
  void initState() {
    super.initState();
    loadSavedNote();
  }

  String encodeStrokes() {
    final encodedStrokes = strokes.map((stroke) {
      return {
        'color': stroke.color.toARGB32(),
        'width': stroke.strokeWidth,
        'penType': stroke.penType,
        'points': stroke.points.map((point) {
          return {'x': point.dx, 'y': point.dy};
        }).toList(),
      };
    }).toList();

    return jsonEncode({
      'version': 2,
      'strokes': encodedStrokes,
      'pageElements': pageElements.map((element) => element.toJson()).toList(),
    });
  }

  List<DrawingStroke> decodeStrokes(String drawingData) {
    final decoded = decodeDrawingPayload(drawingData);
    final strokeData = decoded is Map ? decoded['strokes'] : decoded;

    if (strokeData is! List) return [];

    return strokeData.map<DrawingStroke>((stroke) {
      // New format
      if (stroke is Map) {
        final pointsData = stroke['points'] as List;

        return DrawingStroke(
          points: pointsData.map<Offset>((point) {
            return Offset(
              (point['x'] as num).toDouble(),
              (point['y'] as num).toDouble(),
            );
          }).toList(),
          color: Color(stroke['color'] as int),
          strokeWidth: (stroke['width'] as num).toDouble(),
          penType: stroke['penType'] as String? ?? PenTypeCatalog.defaultLabel,
        );
      }

      // Old format support
      if (stroke is List) {
        return DrawingStroke(
          points: stroke.map<Offset>((point) {
            return Offset(
              (point['x'] as num).toDouble(),
              (point['y'] as num).toDouble(),
            );
          }).toList(),
          color: Colors.black,
          strokeWidth: 2.5,
          penType: PenTypeCatalog.defaultLabel,
        );
      }

      return DrawingStroke(
        points: [],
        color: Colors.black,
        strokeWidth: 2.5,
        penType: PenTypeCatalog.defaultLabel,
      );
    }).toList();
  }

  List<NotePageElement> decodePageElements(String drawingData) {
    final decoded = decodeDrawingPayload(drawingData);

    if (decoded is! Map) return [];

    final elementData = decoded['pageElements'];

    if (elementData is! List) return [];

    return elementData
        .whereType<Map>()
        .map((element) => NotePageElement.fromJson(element))
        .whereType<NotePageElement>()
        .toList();
  }

  Object? decodeDrawingPayload(String drawingData) {
    try {
      return jsonDecode(drawingData);
    } catch (_) {
      return null;
    }
  }

  Future<void> loadSavedNote() async {
    final result = await noteDbController.loadNote(
      widget.subjectTitle,
      widget.selectedField,
    );

    if (result != null) {
      noteController.text = result['content'] as String? ?? '';

      final savedDrawing = result['drawing'] as String?;

      if (savedDrawing != null && savedDrawing.isNotEmpty) {
        final loadedElements = decodePageElements(savedDrawing);

        setState(() {
          strokes = decodeStrokes(savedDrawing);
          pageElements = loadedElements;
          nextPageElementId = loadedElements.isEmpty
              ? 1
              : loadedElements.fold<int>(
                      0,
                      (highestId, element) =>
                          math.max(highestId, element.id).toInt(),
                    ) +
                    1;
        });
      }
    }
  }

  Future<void> saveNote() async {
    await noteDbController.saveNote(
      widget.subjectTitle,
      widget.selectedField,
      noteController.text,
      widget.noteType,
      encodeStrokes(),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Note saved')));
  }

  void startStroke(Offset point) {
    if (selectedTool == 'Eraser') {
      eraseAt(point);
      return;
    }

    if (selectedTool != 'Pen') return;

    final penType = PenTypeCatalog.byLabel(selectedPenType);
    final strokeColor = selectedPenColor.withValues(alpha: penType.opacity);
    final width = selectedStrokeWidth * penType.widthMultiplier;

    setState(() {
      currentStroke = DrawingStroke(
        points: [point],
        color: strokeColor,
        strokeWidth: width,
        penType: penType.label,
      );

      strokes.add(currentStroke!);
    });
  }

  void updateStroke(Offset point) {
    if (selectedTool == 'Eraser') {
      eraseAt(point);
      return;
    }

    if (currentStroke == null) return;

    setState(() {
      currentStroke!.points.add(point);
    });
  }

  void endStroke() {
    setState(() {
      currentStroke = null;
      eraserPreviewPoint = null;
    });
  }

  void eraseAt(Offset point) {
    setState(() {
      eraserPreviewPoint = point;
      strokes = eraseStrokes(strokes, point, selectedEraserWidth / 2);
    });
  }

  List<DrawingStroke> eraseStrokes(
    List<DrawingStroke> source,
    Offset center,
    double radius,
  ) {
    final remainingStrokes = <DrawingStroke>[];

    for (final stroke in source) {
      final segments = splitStrokeAroundEraser(stroke, center, radius);
      remainingStrokes.addAll(segments);
    }

    return remainingStrokes;
  }

  List<DrawingStroke> splitStrokeAroundEraser(
    DrawingStroke stroke,
    Offset center,
    double radius,
  ) {
    final points = stroke.points;

    if (points.length < 2) {
      final shouldKeep = points.every(
        (point) =>
            (point - center).distance >
            radius + math.max(1, stroke.strokeWidth / 2),
      );

      return shouldKeep ? [stroke] : [];
    }

    final splitStrokes = <DrawingStroke>[];
    var currentSegment = <Offset>[];
    final effectiveRadius = radius + math.max(1, stroke.strokeWidth / 2);

    for (var index = 0; index < points.length; index++) {
      final shouldErase = pointTouchesEraser(
        points,
        index,
        center,
        effectiveRadius,
      );

      if (shouldErase) {
        if (currentSegment.length > 1) {
          splitStrokes.add(stroke.copyWith(points: currentSegment));
        }

        currentSegment = [];
      } else {
        currentSegment.add(points[index]);
      }
    }

    if (currentSegment.length > 1) {
      splitStrokes.add(stroke.copyWith(points: currentSegment));
    }

    return splitStrokes;
  }

  bool pointTouchesEraser(
    List<Offset> points,
    int index,
    Offset center,
    double radius,
  ) {
    final point = points[index];

    if ((point - center).distance <= radius) return true;

    if (index > 0 &&
        distanceToSegment(center, points[index - 1], point) <= radius) {
      return true;
    }

    if (index < points.length - 1 &&
        distanceToSegment(center, point, points[index + 1]) <= radius) {
      return true;
    }

    return false;
  }

  double distanceToSegment(Offset point, Offset start, Offset end) {
    final segment = end - start;
    final segmentLengthSquared =
        segment.dx * segment.dx + segment.dy * segment.dy;

    if (segmentLengthSquared == 0) {
      return (point - start).distance;
    }

    final pointVector = point - start;
    final projection =
        (pointVector.dx * segment.dx + pointVector.dy * segment.dy) /
        segmentLengthSquared;
    final clampedProjection = projection.clamp(0.0, 1.0);
    final closestPoint = Offset(
      start.dx + segment.dx * clampedProjection,
      start.dy + segment.dy * clampedProjection,
    );

    return (point - closestPoint).distance;
  }

  void undoStroke() {
    if (strokes.isEmpty) return;

    setState(() {
      strokes.removeLast();
    });
  }

  void clearDrawing() {
    setState(() {
      strokes.clear();
    });
  }

  void addStickyNote() {
    FocusManager.instance.primaryFocus?.unfocus();

    final color = stickyColors[nextStickyColorIndex % stickyColors.length];

    setState(() {
      selectedTool = 'Text';
      showPenTray = false;
      nextStickyColorIndex++;
      pageElements.add(
        NotePageElement(
          id: nextPageElementId++,
          type: NotePageElementType.sticky,
          position: Offset(36 + (pageElements.length % 3) * 24, 42),
          size: const Size(190, 150),
          text: 'New note',
          color: color,
        ),
      );
    });
  }

  Future<void> showStickerPicker() async {
    final selectedSticker = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        final colorScheme = Theme.of(dialogContext).colorScheme;

        return Dialog(
          insetPadding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Choose Sticker',
                        style: Theme.of(dialogContext).textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    itemCount: stickerOptions.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 8,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                        ),
                    itemBuilder: (context, index) {
                      final sticker = stickerOptions[index];

                      return InkWell(
                        onTap: () => Navigator.of(dialogContext).pop(sticker),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: colorScheme.outlineVariant,
                            ),
                          ),
                          child: Text(
                            sticker,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (selectedSticker == null) return;

    addSticker(selectedSticker);
  }

  void addSticker(String sticker) {
    FocusManager.instance.primaryFocus?.unfocus();

    setState(() {
      selectedTool = 'Text';
      showPenTray = false;
      pageElements.add(
        NotePageElement(
          id: nextPageElementId++,
          type: NotePageElementType.sticker,
          position: Offset(70 + (pageElements.length % 4) * 18, 70),
          size: const Size(70, 70),
          text: sticker,
          color: Colors.transparent,
        ),
      );
    });
  }

  void movePageElement(
    NotePageElement element,
    DragUpdateDetails details,
    Size canvasSize,
  ) {
    setState(() {
      element.position = clampElementPosition(
        element.position + details.delta,
        canvasSize,
        element.size,
      );
    });
  }

  Offset clampElementPosition(Offset position, Size canvasSize, Size itemSize) {
    final maxX = math.max(0.0, canvasSize.width - itemSize.width);
    final maxY = math.max(0.0, canvasSize.height - itemSize.height);

    return Offset(position.dx.clamp(0.0, maxX), position.dy.clamp(0.0, maxY));
  }

  void deletePageElement(NotePageElement element) {
    setState(() {
      pageElements.removeWhere((item) => item.id == element.id);
      pageElementControllers.remove(element.id)?.dispose();
    });
  }

  TextEditingController controllerForPageElement(NotePageElement element) {
    return pageElementControllers.putIfAbsent(
      element.id,
      () => TextEditingController(text: element.text),
    );
  }

  List<String> getTemplates() {
    if (widget.subjectTitle.toLowerCase().contains('data structure')) {
      return ['Algorithm', 'Pseudocode', 'Diagram', 'Revision'];
    }

    return ['Summary', 'Revision', 'Study Note', 'Diagram'];
  }

  Widget buildToolButton(IconData icon, String label) {
    final isSelected = selectedTool == label;

    return InkWell(
      onTap: () {
        if (label == 'Undo') {
          undoStroke();
          return;
        }

        if (label == 'Clear') {
          clearDrawing();
          return;
        }

        if (label != 'Text') {
          FocusManager.instance.primaryFocus?.unfocus();
        }

        setState(() {
          selectedTool = label;

          if (label == 'Pen') {
            showPenTray = true;
          } else {
            showPenTray = false;
          }
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade100 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 8),
            Text(label),
          ],
        ),
      ),
    );
  }

  Widget buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 8),
            Text(label),
          ],
        ),
      ),
    );
  }

  void selectPenType(PenTypeOption option) {
    FocusManager.instance.primaryFocus?.unfocus();

    setState(() {
      selectedPenType = option.label;
      showPenTray = true;
      selectedTool = 'Pen';
    });
  }

  Widget buildPenTray(ColorScheme colorScheme) {
    return Container(
      height: 86,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final option in PenTypeCatalog.options) ...[
              buildPenTrayItem(option, colorScheme),
              const SizedBox(width: 8),
            ],
          ],
        ),
      ),
    );
  }

  Widget buildPenTrayItem(PenTypeOption option, ColorScheme colorScheme) {
    final isSelected = option.label == selectedPenType;

    return Tooltip(
      message: option.label,
      child: InkWell(
        onTap: () => selectPenType(option),
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: 62,
          padding: const EdgeInsets.fromLTRB(6, 5, 6, 6),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primaryContainer.withValues(alpha: 0.72)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.outlineVariant.withValues(alpha: 0.58),
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: PenCaseIcon(
                  option: option,
                  selectedColor: selectedPenColor,
                  isSelected: isSelected,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                option.shortLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isSelected
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurfaceVariant,
                  fontSize: 9.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTemplateChip(String template) {
    final isSelected = selectedTemplate == template;

    return InkWell(
      onTap: () {
        setState(() {
          selectedTemplate = template;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepPurple.shade100 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          template,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget buildColorButton(Color color) {
    final isSelected = selectedPenColor == color;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPenColor = color;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey.shade300,
            width: isSelected ? 3 : 1,
          ),
        ),
      ),
    );
  }

  Widget buildStrokeButton(double width) {
    final isEraser = selectedTool == 'Eraser';

    if (isEraser) {
      return buildEraserSizeButton(width);
    }

    final isSelected = isEraser
        ? selectedEraserWidth == width
        : selectedStrokeWidth == width;

    return InkWell(
      onTap: () {
        setState(() {
          if (isEraser) {
            selectedEraserWidth = width;
          } else {
            selectedStrokeWidth = width;
          }
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade100 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
          ),
        ),
        child: Text('${width.toInt()} px'),
      ),
    );
  }

  Widget buildEraserSizeButton(double width) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = selectedEraserWidth == width;
    final diameter = width.clamp(12.0, 42.0);

    return Tooltip(
      message: '${width.toInt()} px eraser',
      child: Semantics(
        label: '${width.toInt()} pixel eraser',
        selected: isSelected,
        button: true,
        child: InkWell(
          onTap: () {
            setState(() {
              selectedEraserWidth = width;
            });
          },
          borderRadius: BorderRadius.circular(18),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            margin: const EdgeInsets.only(right: 10),
            width: 58,
            height: 50,
            decoration: BoxDecoration(
              color: isSelected
                  ? colorScheme.primaryContainer.withValues(alpha: 0.72)
                  : colorScheme.surfaceContainerHighest.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.outlineVariant,
              ),
            ),
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: diameter,
                height: diameter,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? colorScheme.primary.withValues(alpha: 0.16)
                      : colorScheme.onSurfaceVariant.withValues(alpha: 0.08),
                  border: Border.all(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant.withValues(alpha: 0.52),
                    width: isSelected ? 2 : 1.3,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildPageElement(NotePageElement element, Size canvasSize) {
    return switch (element.type) {
      NotePageElementType.sticky => buildStickyNote(element, canvasSize),
      NotePageElementType.sticker => buildSticker(element, canvasSize),
    };
  }

  Widget buildStickyNote(NotePageElement element, Size canvasSize) {
    final controller = controllerForPageElement(element);
    final position = clampElementPosition(
      element.position,
      canvasSize,
      element.size,
    );

    return Positioned(
      left: position.dx,
      top: position.dy,
      width: element.size.width,
      height: element.size.height,
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: element.color,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.14),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanUpdate: (details) {
                  movePageElement(element, details, canvasSize);
                },
                child: Container(
                  height: 34,
                  padding: const EdgeInsets.only(left: 10, right: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.28),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(8),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.drag_indicator, size: 17),
                      const SizedBox(width: 4),
                      const Expanded(
                        child: Text(
                          'Sticky',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Delete sticky note',
                        onPressed: () => deletePageElement(element),
                        icon: const Icon(Icons.close, size: 16),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints.tightFor(
                          width: 30,
                          height: 30,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
                  child: TextField(
                    controller: controller,
                    onChanged: (value) {
                      element.text = value;
                    },
                    maxLines: null,
                    expands: true,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isCollapsed: true,
                      hintText: 'Write here...',
                    ),
                    style: const TextStyle(
                      color: Color(0xFF2E2A1F),
                      fontSize: 14,
                      height: 1.25,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSticker(NotePageElement element, Size canvasSize) {
    final position = clampElementPosition(
      element.position,
      canvasSize,
      element.size,
    );

    return Positioned(
      left: position.dx,
      top: position.dy,
      width: element.size.width,
      height: element.size.height,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanUpdate: (details) {
          movePageElement(element, details, canvasSize);
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Center(
              child: Container(
                width: element.size.width,
                height: element.size.height,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.78),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.black.withValues(alpha: 0.07),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Text(
                  element.text,
                  style: TextStyle(fontSize: element.size.width * 0.5),
                ),
              ),
            ),
            Positioned(
              right: -6,
              top: -6,
              child: Material(
                color: Colors.white,
                shape: const CircleBorder(),
                elevation: 2,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => deletePageElement(element),
                  child: const SizedBox(
                    width: 22,
                    height: 22,
                    child: Icon(Icons.close, size: 14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (final controller in pageElementControllers.values) {
      controller.dispose();
    }

    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final templates = getTemplates();
    final colorScheme = Theme.of(context).colorScheme;
    final widthOptions = selectedTool == 'Eraser' ? eraserWidths : strokeWidths;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subjectTitle),
        actions: [
          IconButton(onPressed: saveNote, icon: const Icon(Icons.save)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  buildToolButton(Icons.edit, 'Pen'),
                  const SizedBox(width: 10),
                  buildToolButton(Icons.auto_fix_off, 'Eraser'),
                  const SizedBox(width: 10),
                  buildToolButton(Icons.text_fields, 'Text'),
                  const SizedBox(width: 10),
                  buildActionButton(
                    Icons.sticky_note_2_outlined,
                    'Sticky',
                    addStickyNote,
                  ),
                  const SizedBox(width: 10),
                  buildActionButton(
                    Icons.emoji_emotions_outlined,
                    'Sticker',
                    showStickerPicker,
                  ),
                  const SizedBox(width: 10),
                  buildToolButton(Icons.undo, 'Undo'),
                  const SizedBox(width: 10),
                  buildToolButton(Icons.delete_outline, 'Clear'),
                  const SizedBox(width: 20),
                  ...templates.expand(
                    (template) => [
                      buildTemplateChip(template),
                      const SizedBox(width: 10),
                    ],
                  ),
                ],
              ),
            ),
            if (showPenTray) ...[
              const SizedBox(height: 12),
              buildPenTray(colorScheme),
            ],
            const SizedBox(height: 14),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  if (selectedTool != 'Eraser') ...[
                    const Text(
                      'Color:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 12),
                    ...penColors.map(buildColorButton),
                    const SizedBox(width: 20),
                  ],
                  Text(
                    selectedTool == 'Eraser' ? 'Eraser size:' : 'Thickness:',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 12),
                  ...widthOptions.map(buildStrokeButton),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Note Type: ${widget.noteType}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final canvasSize = Size(
                      constraints.maxWidth,
                      constraints.maxHeight,
                    );

                    return Stack(
                      children: [
                        if (widget.noteType == 'Lined Note')
                          CustomPaint(
                            size: Size.infinite,
                            painter: LinedPagePainter(),
                          ),
                        if (widget.noteType == 'Grid Note')
                          CustomPaint(
                            size: Size.infinite,
                            painter: GridPagePainter(),
                          ),
                        CustomPaint(
                          size: Size.infinite,
                          painter: DrawingPainter(strokes),
                        ),
                        if (selectedTool == 'Eraser' &&
                            eraserPreviewPoint != null)
                          CustomPaint(
                            size: Size.infinite,
                            painter: EraserPreviewPainter(
                              center: eraserPreviewPoint!,
                              diameter: selectedEraserWidth,
                              color: colorScheme.primary,
                            ),
                          ),
                        IgnorePointer(
                          ignoring: selectedTool != 'Text',
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: TextField(
                              controller: noteController,
                              maxLines: null,
                              expands: true,
                              keyboardType: TextInputType.multiline,
                              textInputAction: TextInputAction.newline,
                              enableSuggestions: true,
                              autocorrect: true,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: noteController.text.isEmpty
                                    ? 'Write your $selectedTemplate note...'
                                    : null,
                              ),
                              style: TextStyle(
                                fontSize: 16,
                                color: selectedPenColor,
                              ),
                            ),
                          ),
                        ),
                        if (selectedTool == 'Pen' || selectedTool == 'Eraser')
                          GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onPanStart: (details) {
                              startStroke(details.localPosition);
                            },
                            onPanUpdate: (details) {
                              updateStroke(details.localPosition);
                            },
                            onPanEnd: (_) {
                              endStroke();
                            },
                            child: Container(),
                          ),
                        ...pageElements.map(
                          (element) => buildPageElement(element, canvasSize),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum PenRenderStyle {
  regular,
  fountain,
  pencil,
  highlighter,
  dotted,
  wavy,
  doubleLine,
  watercolor,
}

class PenTypeOption {
  final String label;
  final String shortLabel;
  final IconData icon;
  final PenRenderStyle style;
  final double widthMultiplier;
  final double opacity;
  final Color accentColor;

  const PenTypeOption({
    required this.label,
    required this.shortLabel,
    required this.icon,
    required this.style,
    required this.widthMultiplier,
    required this.opacity,
    required this.accentColor,
  });
}

class PenTypeCatalog {
  static const defaultLabel = 'Gel Pen';
  static const highlighterLabel = 'Highlighter';

  static const options = <PenTypeOption>[
    PenTypeOption(
      label: 'Fountain',
      shortLabel: 'Fountain',
      icon: Icons.edit_note,
      style: PenRenderStyle.fountain,
      widthMultiplier: 1.15,
      opacity: 1,
      accentColor: Color(0xFFE55335),
    ),
    PenTypeOption(
      label: defaultLabel,
      shortLabel: 'Gel',
      icon: Icons.draw,
      style: PenRenderStyle.regular,
      widthMultiplier: 1,
      opacity: 1,
      accentColor: Color(0xFF2F80ED),
    ),
    PenTypeOption(
      label: 'Fine Pen',
      shortLabel: 'Fine',
      icon: Icons.border_color,
      style: PenRenderStyle.regular,
      widthMultiplier: 0.7,
      opacity: 1,
      accentColor: Color(0xFF7B61FF),
    ),
    PenTypeOption(
      label: 'Pencil',
      shortLabel: 'Pencil',
      icon: Icons.create,
      style: PenRenderStyle.pencil,
      widthMultiplier: 0.9,
      opacity: 0.72,
      accentColor: Color(0xFFD98B32),
    ),
    PenTypeOption(
      label: 'Monoline',
      shortLabel: 'Mono',
      icon: Icons.horizontal_rule,
      style: PenRenderStyle.regular,
      widthMultiplier: 1.35,
      opacity: 1,
      accentColor: Color(0xFF1C7CFF),
    ),
    PenTypeOption(
      label: highlighterLabel,
      shortLabel: 'High',
      icon: Icons.highlight,
      style: PenRenderStyle.highlighter,
      widthMultiplier: 3,
      opacity: 0.35,
      accentColor: Color(0xFFF2C94C),
    ),
    PenTypeOption(
      label: 'Dotted',
      shortLabel: 'Dotted',
      icon: Icons.more_horiz,
      style: PenRenderStyle.dotted,
      widthMultiplier: 1.1,
      opacity: 1,
      accentColor: Color(0xFF56CCF2),
    ),
    PenTypeOption(
      label: 'Wavy',
      shortLabel: 'Wavy',
      icon: Icons.waves,
      style: PenRenderStyle.wavy,
      widthMultiplier: 1,
      opacity: 1,
      accentColor: Color(0xFFEB5757),
    ),
    PenTypeOption(
      label: 'Double Line',
      shortLabel: 'Double',
      icon: Icons.density_medium,
      style: PenRenderStyle.doubleLine,
      widthMultiplier: 0.72,
      opacity: 1,
      accentColor: Color(0xFF27AE60),
    ),
    PenTypeOption(
      label: 'Watercolor',
      shortLabel: 'Water',
      icon: Icons.water_drop,
      style: PenRenderStyle.watercolor,
      widthMultiplier: 3.2,
      opacity: 0.28,
      accentColor: Color(0xFF9B51E0),
    ),
    PenTypeOption(
      label: 'Brush Pen',
      shortLabel: 'Brush',
      icon: Icons.brush,
      style: PenRenderStyle.fountain,
      widthMultiplier: 1.8,
      opacity: 0.92,
      accentColor: Color(0xFFF2994A),
    ),
    PenTypeOption(
      label: 'Marker',
      shortLabel: 'Marker',
      icon: Icons.format_paint,
      style: PenRenderStyle.highlighter,
      widthMultiplier: 2.2,
      opacity: 0.62,
      accentColor: Color(0xFFEB5757),
    ),
  ];

  static PenTypeOption byLabel(String label) {
    return options.firstWhere(
      (option) => option.label == label,
      orElse: () =>
          options.firstWhere((option) => option.label == defaultLabel),
    );
  }
}

class PenCaseIcon extends StatelessWidget {
  final PenTypeOption option;
  final Color selectedColor;
  final bool isSelected;

  const PenCaseIcon({
    super.key,
    required this.option,
    required this.selectedColor,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: PenCaseIconPainter(
        option: option,
        selectedColor: selectedColor,
        isSelected: isSelected,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class PenCaseIconPainter extends CustomPainter {
  final PenTypeOption option;
  final Color selectedColor;
  final bool isSelected;

  PenCaseIconPainter({
    required this.option,
    required this.selectedColor,
    required this.isSelected,
  });

  @override
  void paint(Canvas canvas, Size size) {
    switch (option.label) {
      case 'Fountain':
        _drawFountain(canvas, size);
      case 'Pencil':
        _drawPencil(canvas, size);
      case PenTypeCatalog.highlighterLabel:
        _drawMarker(canvas, size, chiselWidth: 21, translucent: true);
      case 'Watercolor':
        _drawWatercolor(canvas, size);
      case 'Brush Pen':
        _drawBrush(canvas, size);
      case 'Marker':
        _drawMarker(canvas, size, chiselWidth: 18, translucent: false);
      default:
        _drawStandardPen(canvas, size);
    }

    if (isSelected) {
      final selectedPaint = Paint()
        ..color = option.accentColor.withValues(alpha: 0.95)
        ..strokeWidth = 3.2
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(size.width * 0.28, size.height - 2.2),
        Offset(size.width * 0.72, size.height - 2.2),
        selectedPaint,
      );
    }
  }

  void _drawStandardPen(Canvas canvas, Size size) {
    final center = size.width / 2;
    final top = 3.0;
    final bottom = size.height - 5;
    final bodyWidth = option.label == 'Fine Pen' ? 10.0 : 14.0;
    final accent = option.accentColor;
    final bodyPaint = Paint()
      ..color = Color.lerp(const Color(0xFF2E3036), accent, 0.16)!;
    final darkPaint = Paint()..color = const Color(0xFF111217);
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.14)
      ..strokeWidth = 1.1
      ..strokeCap = StrokeCap.round;

    final nib = Path()
      ..moveTo(center, top)
      ..lineTo(center - bodyWidth / 2, top + 15)
      ..lineTo(center + bodyWidth / 2, top + 15)
      ..close();
    canvas.drawPath(nib, darkPaint);
    canvas.drawLine(
      Offset(center, top + 4),
      Offset(center, top + 14),
      highlightPaint,
    );

    final bodyRect = Rect.fromLTWH(
      center - bodyWidth / 2,
      top + 14,
      bodyWidth,
      bottom - top - 22,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect, const Radius.circular(4)),
      bodyPaint,
    );

    final bandPaint = Paint()..color = selectedColor;
    final bandRect = Rect.fromLTWH(
      center - bodyWidth / 2,
      bottom - 15,
      bodyWidth,
      8,
    );
    canvas.drawRect(bandRect, bandPaint);

    if (option.label == 'Dotted') {
      final dotPaint = Paint()..color = accent;
      for (var index = 0; index < 4; index++) {
        canvas.drawCircle(Offset(center, top + 21 + index * 6), 1.5, dotPaint);
      }
    } else if (option.label == 'Wavy') {
      final wavePaint = Paint()
        ..color = accent
        ..strokeWidth = 1.4
        ..style = PaintingStyle.stroke;
      final path = Path()..moveTo(center - 4, top + 22);
      for (var index = 0; index < 18; index++) {
        final y = top + 22 + index * 1.6;
        final x = center + math.sin(index * 0.9) * 4;
        path.lineTo(x, y);
      }
      canvas.drawPath(path, wavePaint);
    } else if (option.label == 'Double Line') {
      final linePaint = Paint()
        ..color = accent
        ..strokeWidth = 1.2
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(center - 3, top + 21),
        Offset(center - 3, bottom - 17),
        linePaint,
      );
      canvas.drawLine(
        Offset(center + 3, top + 21),
        Offset(center + 3, bottom - 17),
        linePaint,
      );
    }
  }

  void _drawFountain(Canvas canvas, Size size) {
    final center = size.width / 2;
    final top = 1.0;
    final bottom = size.height - 5;
    final accent = option.accentColor;
    final bodyPaint = Paint()..color = const Color(0xFF15161A);
    final accentPaint = Paint()..color = accent;
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    final nib = Path()
      ..moveTo(center, top)
      ..lineTo(center - 10, top + 24)
      ..lineTo(center, top + 31)
      ..lineTo(center + 10, top + 24)
      ..close();
    canvas.drawPath(nib, bodyPaint);
    canvas.drawCircle(Offset(center, top + 20), 2, accentPaint);
    canvas.drawLine(
      Offset(center, top + 5),
      Offset(center, top + 27),
      linePaint,
    );

    final bodyRect = Rect.fromLTWH(
      center - 11,
      top + 28,
      22,
      bottom - top - 34,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect, const Radius.circular(6)),
      Paint()..color = Color.lerp(const Color(0xFF272931), accent, 0.14)!,
    );
    canvas.drawRect(
      Rect.fromLTWH(center - 11, bottom - 15, 22, 9),
      Paint()..color = selectedColor,
    );
  }

  void _drawPencil(Canvas canvas, Size size) {
    final center = size.width / 2;
    final top = 2.0;
    final bottom = size.height - 5;
    final woodPaint = Paint()..color = const Color(0xFFE8B26B);
    final bodyPaint = Paint()..color = option.accentColor;
    final graphitePaint = Paint()..color = const Color(0xFF1F2025);
    final stripePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.28)
      ..strokeWidth = 1.2;

    final tip = Path()
      ..moveTo(center, top)
      ..lineTo(center - 9, top + 18)
      ..lineTo(center + 9, top + 18)
      ..close();
    canvas.drawPath(tip, woodPaint);
    final graphite = Path()
      ..moveTo(center, top)
      ..lineTo(center - 3, top + 7)
      ..lineTo(center + 3, top + 7)
      ..close();
    canvas.drawPath(graphite, graphitePaint);

    final bodyRect = Rect.fromLTWH(center - 9, top + 17, 18, bottom - top - 24);
    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect, const Radius.circular(3)),
      bodyPaint,
    );
    canvas.drawLine(
      Offset(center - 3, top + 20),
      Offset(center - 3, bottom - 9),
      stripePaint,
    );
    canvas.drawLine(
      Offset(center + 3, top + 20),
      Offset(center + 3, bottom - 9),
      stripePaint,
    );
  }

  void _drawMarker(
    Canvas canvas,
    Size size, {
    required double chiselWidth,
    required bool translucent,
  }) {
    final center = size.width / 2;
    final top = 4.0;
    final bottom = size.height - 5;
    final bodyWidth = translucent ? 21.0 : 18.0;
    final accent = option.accentColor;
    final bodyPaint = Paint()
      ..color = translucent
          ? accent.withValues(alpha: 0.42)
          : Color.lerp(const Color(0xFF30323A), accent, 0.22)!;
    final darkPaint = Paint()..color = const Color(0xFF17181D);

    final chisel = Path()
      ..moveTo(center - chiselWidth / 2, top + 12)
      ..lineTo(center + chiselWidth / 2, top + 5)
      ..lineTo(center + chiselWidth / 2, top + 17)
      ..lineTo(center - chiselWidth / 2, top + 24)
      ..close();
    canvas.drawPath(chisel, Paint()..color = accent);

    final bodyRect = Rect.fromLTWH(
      center - bodyWidth / 2,
      top + 21,
      bodyWidth,
      bottom - top - 28,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect, const Radius.circular(5)),
      bodyPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(center - bodyWidth / 2, bottom - 15, bodyWidth, 7),
      darkPaint,
    );
  }

  void _drawWatercolor(Canvas canvas, Size size) {
    final center = size.width / 2;
    final top = 4.0;
    final bottom = size.height - 5;
    final bodyPaint = Paint()
      ..color = option.accentColor.withValues(alpha: 0.42);
    final washPaint = Paint()
      ..color = selectedColor.withValues(alpha: 0.28)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final tip = Path()
      ..moveTo(center, top)
      ..lineTo(center - 10, top + 22)
      ..lineTo(center + 10, top + 22)
      ..close();
    canvas.drawPath(tip, bodyPaint);
    final bodyRect = Rect.fromLTWH(
      center - 11,
      top + 20,
      22,
      bottom - top - 27,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect, const Radius.circular(7)),
      bodyPaint,
    );
    canvas.drawLine(
      Offset(center - 8, bottom - 10),
      Offset(center + 8, bottom - 15),
      washPaint,
    );
  }

  void _drawBrush(Canvas canvas, Size size) {
    final center = size.width / 2;
    final top = 2.0;
    final bottom = size.height - 5;
    final accent = option.accentColor;
    final brushPaint = Paint()..color = selectedColor;
    final bodyPaint = Paint()
      ..color = Color.lerp(const Color(0xFF2A2C33), accent, 0.24)!;

    final brush = Path()
      ..moveTo(center + 4, top)
      ..quadraticBezierTo(center - 13, top + 9, center - 5, top + 23)
      ..quadraticBezierTo(center + 8, top + 19, center + 4, top)
      ..close();
    canvas.drawPath(brush, brushPaint);

    final bodyRect = Rect.fromLTWH(
      center - 10,
      top + 20,
      20,
      bottom - top - 27,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect, const Radius.circular(5)),
      bodyPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(center - 10, bottom - 16, 20, 8),
      Paint()..color = accent,
    );
  }

  @override
  bool shouldRepaint(covariant PenCaseIconPainter oldDelegate) {
    return oldDelegate.option != option ||
        oldDelegate.selectedColor != selectedColor ||
        oldDelegate.isSelected != isSelected;
  }
}

enum NotePageElementType { sticky, sticker }

class NotePageElement {
  final int id;
  final NotePageElementType type;
  Offset position;
  Size size;
  String text;
  Color color;

  NotePageElement({
    required this.id,
    required this.type,
    required this.position,
    required this.size,
    required this.text,
    required this.color,
  });

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'type': type.name,
      'x': position.dx,
      'y': position.dy,
      'width': size.width,
      'height': size.height,
      'text': text,
      'color': color.toARGB32(),
    };
  }

  static NotePageElement? fromJson(Map<dynamic, dynamic> data) {
    final id = data['id'];
    final typeValue = data['type'];
    final x = data['x'];
    final y = data['y'];
    final width = data['width'];
    final height = data['height'];
    final text = data['text'];
    final colorValue = data['color'];

    if (id is! num ||
        typeValue is! String ||
        x is! num ||
        y is! num ||
        width is! num ||
        height is! num) {
      return null;
    }

    final type = NotePageElementType.values.firstWhere(
      (value) => value.name == typeValue,
      orElse: () => NotePageElementType.sticky,
    );

    return NotePageElement(
      id: id.toInt(),
      type: type,
      position: Offset(x.toDouble(), y.toDouble()),
      size: Size(width.toDouble(), height.toDouble()),
      text: text?.toString() ?? '',
      color: colorValue is int ? Color(colorValue) : const Color(0xFFFFF3A3),
    );
  }
}

class DrawingStroke {
  final List<Offset> points;
  final Color color;
  final double strokeWidth;
  final String penType;

  DrawingStroke({
    required this.points,
    required this.color,
    required this.strokeWidth,
    this.penType = PenTypeCatalog.defaultLabel,
  });

  DrawingStroke copyWith({
    List<Offset>? points,
    Color? color,
    double? strokeWidth,
    String? penType,
  }) {
    return DrawingStroke(
      points: points ?? this.points,
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      penType: penType ?? this.penType,
    );
  }
}

class DrawingPainter extends CustomPainter {
  final List<DrawingStroke> strokes;

  DrawingPainter(this.strokes);

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      drawStyledStroke(canvas, stroke);
    }
  }

  static void drawStyledStroke(Canvas canvas, DrawingStroke stroke) {
    if (stroke.points.isEmpty) return;

    final penType = PenTypeCatalog.byLabel(stroke.penType);

    switch (penType.style) {
      case PenRenderStyle.fountain:
        _drawFountain(canvas, stroke);
      case PenRenderStyle.pencil:
        _drawPencil(canvas, stroke);
      case PenRenderStyle.highlighter:
        _drawNormal(
          canvas,
          stroke,
          paint: _strokePaint(stroke, cap: StrokeCap.square),
        );
      case PenRenderStyle.dotted:
        _drawDotted(canvas, stroke);
      case PenRenderStyle.wavy:
        _drawWavy(canvas, stroke);
      case PenRenderStyle.doubleLine:
        _drawDoubleLine(canvas, stroke);
      case PenRenderStyle.watercolor:
        _drawWatercolor(canvas, stroke);
      case PenRenderStyle.regular:
        _drawNormal(canvas, stroke);
    }
  }

  static Paint _strokePaint(
    DrawingStroke stroke, {
    Color? color,
    double? width,
    StrokeCap cap = StrokeCap.round,
  }) {
    return Paint()
      ..color = color ?? stroke.color
      ..strokeWidth = width ?? stroke.strokeWidth
      ..strokeCap = cap
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
  }

  static Paint _fillPaint(Color color) {
    return Paint()
      ..color = color
      ..style = PaintingStyle.fill;
  }

  static Path _pathFor(List<Offset> points) {
    final path = Path()..moveTo(points.first.dx, points.first.dy);

    for (final point in points.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }

    return path;
  }

  static void _drawNormal(Canvas canvas, DrawingStroke stroke, {Paint? paint}) {
    final activePaint = paint ?? _strokePaint(stroke);

    if (stroke.points.length == 1) {
      canvas.drawCircle(
        stroke.points.first,
        activePaint.strokeWidth / 2,
        _fillPaint(activePaint.color),
      );
      return;
    }

    canvas.drawPath(_pathFor(stroke.points), activePaint);
  }

  static void _drawFountain(Canvas canvas, DrawingStroke stroke) {
    _drawNormal(canvas, stroke);
    _drawNormal(
      canvas,
      stroke,
      paint: _strokePaint(
        stroke,
        color: stroke.color.withValues(alpha: 0.55),
        width: math.max(1, stroke.strokeWidth * 0.36),
      ),
    );
  }

  static void _drawPencil(Canvas canvas, DrawingStroke stroke) {
    final sketchOffsets = const [Offset(0.7, -0.45), Offset(-0.6, 0.5)];

    for (final offset in sketchOffsets) {
      final sketchStroke = stroke.copyWith(
        points: stroke.points.map((point) => point + offset).toList(),
        color: stroke.color.withValues(alpha: 0.24),
        strokeWidth: math.max(1, stroke.strokeWidth * 0.82),
      );
      _drawNormal(canvas, sketchStroke);
    }

    _drawNormal(canvas, stroke);
  }

  static void _drawDotted(Canvas canvas, DrawingStroke stroke) {
    final dotPaint = _fillPaint(stroke.color);
    final dotRadius = math.max(1.4, stroke.strokeWidth * 0.5);
    final spacing = math.max(7, stroke.strokeWidth * 2.8);

    if (stroke.points.length == 1) {
      canvas.drawCircle(stroke.points.first, dotRadius, dotPaint);
      return;
    }

    for (var index = 0; index < stroke.points.length - 1; index++) {
      final start = stroke.points[index];
      final end = stroke.points[index + 1];
      final length = (end - start).distance;
      final steps = math.max(1, (length / spacing).floor());

      for (var step = 0; step <= steps; step++) {
        final point = Offset.lerp(start, end, step / steps)!;
        canvas.drawCircle(point, dotRadius, dotPaint);
      }
    }
  }

  static void _drawWavy(Canvas canvas, DrawingStroke stroke) {
    if (stroke.points.length < 2) {
      _drawNormal(canvas, stroke);
      return;
    }

    final path = Path();
    var hasStarted = false;
    var distanceAlong = 0.0;
    final amplitude = math.max(2.2, stroke.strokeWidth * 1.2);
    const wavelength = 26.0;

    for (var index = 0; index < stroke.points.length - 1; index++) {
      final start = stroke.points[index];
      final end = stroke.points[index + 1];
      final delta = end - start;
      final length = delta.distance;

      if (length == 0) continue;

      final normal = Offset(-delta.dy / length, delta.dx / length);
      final steps = math.max(1, (length / 4).ceil());

      for (var step = 0; step <= steps; step++) {
        final t = step / steps;
        final base = Offset.lerp(start, end, t)!;
        final wave = math.sin(
          ((distanceAlong + length * t) / wavelength) * math.pi * 2,
        );
        final point = base + normal * wave * amplitude;

        if (!hasStarted) {
          path.moveTo(point.dx, point.dy);
          hasStarted = true;
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }

      distanceAlong += length;
    }

    canvas.drawPath(_pathFor(stroke.points), _strokePaint(stroke, width: 0.7));
    canvas.drawPath(path, _strokePaint(stroke));
  }

  static void _drawDoubleLine(Canvas canvas, DrawingStroke stroke) {
    if (stroke.points.length < 2) {
      _drawNormal(canvas, stroke);
      return;
    }

    final paint = _strokePaint(stroke);
    final offsetDistance = math.max(2.4, stroke.strokeWidth * 1.35);

    for (var index = 0; index < stroke.points.length - 1; index++) {
      final start = stroke.points[index];
      final end = stroke.points[index + 1];
      final delta = end - start;
      final length = delta.distance;

      if (length == 0) continue;

      final normal = Offset(-delta.dy / length, delta.dx / length);
      final offset = normal * offsetDistance;

      canvas.drawLine(start + offset, end + offset, paint);
      canvas.drawLine(start - offset, end - offset, paint);
    }
  }

  static void _drawWatercolor(Canvas canvas, DrawingStroke stroke) {
    _drawNormal(
      canvas,
      stroke,
      paint: _strokePaint(
        stroke,
        color: stroke.color.withValues(alpha: 0.16),
        width: stroke.strokeWidth * 1.22,
      ),
    );
    _drawNormal(
      canvas,
      stroke,
      paint: _strokePaint(
        stroke,
        color: stroke.color.withValues(alpha: 0.24),
        width: stroke.strokeWidth * 0.78,
      ),
    );
    _drawNormal(
      canvas,
      stroke,
      paint: _strokePaint(
        stroke,
        color: stroke.color.withValues(alpha: 0.34),
        width: stroke.strokeWidth * 0.42,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class EraserPreviewPainter extends CustomPainter {
  final Offset center;
  final double diameter;
  final Color color;

  EraserPreviewPainter({
    required this.center,
    required this.diameter,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final radius = diameter / 2;
    final fillPaint = Paint()
      ..color = color.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = color.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawCircle(center, radius, fillPaint);
    canvas.drawCircle(center, radius, strokePaint);
  }

  @override
  bool shouldRepaint(covariant EraserPreviewPainter oldDelegate) {
    return oldDelegate.center != center ||
        oldDelegate.diameter != diameter ||
        oldDelegate.color != color;
  }
}

class LinedPagePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blueGrey.withValues(alpha: 0.25)
      ..strokeWidth = 1;

    const gap = 32.0;

    for (double y = gap; y < size.height; y += gap) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class GridPagePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blueGrey.withValues(alpha: 0.18)
      ..strokeWidth = 1;

    const gap = 28.0;

    for (double y = gap; y < size.height; y += gap) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    for (double x = gap; x < size.width; x += gap) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
