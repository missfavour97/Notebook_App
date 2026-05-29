import 'dart:convert';
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

  Color selectedPenColor = Colors.black;
  double selectedStrokeWidth = 2.5;

  List<DrawingStroke> strokes = [];
  DrawingStroke? currentStroke;

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

  @override
  void initState() {
    super.initState();
    loadSavedNote();
  }

  String encodeStrokes() {
    final encoded = strokes.map((stroke) {
      return {
        'color': stroke.color.toARGB32(),
        'width': stroke.strokeWidth,
        'points': stroke.points.map((point) {
          return {'x': point.dx, 'y': point.dy};
        }).toList(),
      };
    }).toList();

    return jsonEncode(encoded);
  }

  List<DrawingStroke> decodeStrokes(String drawingData) {
    final decoded = jsonDecode(drawingData);

    if (decoded is! List) return [];

    return decoded.map<DrawingStroke>((stroke) {
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
        );
      }

      return DrawingStroke(points: [], color: Colors.black, strokeWidth: 2.5);
    }).toList();
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
        setState(() {
          strokes = decodeStrokes(savedDrawing);
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

    if (selectedTool != 'Pen' && selectedTool != 'Highlighter') return;

    final strokeColor = selectedTool == 'Highlighter'
        ? selectedPenColor.withValues(alpha: 0.35)
        : selectedPenColor;

    final width = selectedTool == 'Highlighter'
        ? selectedStrokeWidth * 3
        : selectedStrokeWidth;

    setState(() {
      currentStroke = DrawingStroke(
        points: [point],
        color: strokeColor,
        strokeWidth: width,
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
    currentStroke = null;
  }

  void eraseAt(Offset point) {
    setState(() {
      strokes.removeWhere((stroke) {
        return stroke.points.any((strokePoint) {
          return (strokePoint - point).distance < 22;
        });
      });
    });
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
    final isSelected = selectedStrokeWidth == width;

    return InkWell(
      onTap: () {
        setState(() {
          selectedStrokeWidth = width;
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

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final templates = getTemplates();

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
                  buildToolButton(Icons.highlight, 'Highlighter'),
                  const SizedBox(width: 10),
                  buildToolButton(Icons.auto_fix_off, 'Eraser'),
                  const SizedBox(width: 10),
                  buildToolButton(Icons.text_fields, 'Text'),
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
            const SizedBox(height: 14),
            Row(
              children: [
                const Text(
                  'Color:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 12),
                ...penColors.map(buildColorButton),
                const SizedBox(width: 20),
                const Text(
                  'Thickness:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 12),
                ...strokeWidths.map(buildStrokeButton),
              ],
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
                child: Stack(
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
                    if (selectedTool == 'Pen' ||
                        selectedTool == 'Highlighter' ||
                        selectedTool == 'Eraser')
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DrawingStroke {
  final List<Offset> points;
  final Color color;
  final double strokeWidth;

  DrawingStroke({
    required this.points,
    required this.color,
    required this.strokeWidth,
  });
}

class DrawingPainter extends CustomPainter {
  final List<DrawingStroke> strokes;

  DrawingPainter(this.strokes);

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      final paint = Paint()
        ..color = stroke.color
        ..strokeWidth = stroke.strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      for (int i = 0; i < stroke.points.length - 1; i++) {
        canvas.drawLine(stroke.points[i], stroke.points[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
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
