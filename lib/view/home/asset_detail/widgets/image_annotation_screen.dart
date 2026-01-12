import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

class ImageAnnotationScreen extends StatefulWidget {
  final File imageFile;

  const ImageAnnotationScreen({
    Key? key,
    required this.imageFile,
  }) : super(key: key);

  @override
  State<ImageAnnotationScreen> createState() => _ImageAnnotationScreenState();
}

class _ImageAnnotationScreenState extends State<ImageAnnotationScreen> {
  final GlobalKey _globalKey = GlobalKey();
  final List<DrawingPoint?> _points = [];
  Color _selectedColor = Colors.red;
  double _strokeWidth = 5.0;
  bool _isHighlighter = false;
  ui.Image? _image;
  bool _imageLoaded = false;
  Size? _imageSize;

  final List<Color> _colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.black,
    Colors.yellow,
    Colors.orange,
    Colors.purple,
  ];

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    final data = await widget.imageFile.readAsBytes();
    final codec = await ui.instantiateImageCodec(data);
    final frame = await codec.getNextFrame();
    setState(() {
      _image = frame.image;
      _imageSize = Size(
        _image!.width.toDouble(),
        _image!.height.toDouble(),
      );
      _imageLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mark Asset'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: _undo,
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              setState(() {
                _points.clear();
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveImage,
          ),
        ],
      ),
      body: !_imageLoaded
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildToolbar(),
                Expanded(
                  child: Container(
                    color: Colors.grey[300],
                    child: Center(
                      child: RepaintBoundary(
                        key: _globalKey,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return GestureDetector(
                              onPanStart: (details) {
                                setState(() {
                                  _points.add(DrawingPoint(
                                    details.localPosition,
                                    _selectedColor,
                                    _strokeWidth,
                                    _isHighlighter,
                                  ));
                                });
                              },
                              onPanUpdate: (details) {
                                setState(() {
                                  _points.add(DrawingPoint(
                                    details.localPosition,
                                    _selectedColor,
                                    _strokeWidth,
                                    _isHighlighter,
                                  ));
                                });
                              },
                              onPanEnd: (details) {
                                setState(() {
                                  _points.add(null);
                                });
                              },
                              child: CustomPaint(
                                size: constraints.biggest,
                                painter: ImagePainter(_image, _points, _imageSize),
                                child: Container(),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pen/Highlighter Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildToolButton(
                'Pen',
                Icons.edit,
                !_isHighlighter,
                () {
                  setState(() {
                    _isHighlighter = false;
                    _strokeWidth = 5.0;
                  });
                },
              ),
              const SizedBox(width: 16),
              _buildToolButton(
                'Highlighter',
                Icons.highlight,
                _isHighlighter,
                () {
                  setState(() {
                    _isHighlighter = true;
                    _strokeWidth = 20.0;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Color Picker
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _colors.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = _colors[index];
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _colors[index],
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _selectedColor == _colors[index]
                            ? Colors.black
                            : Colors.grey,
                        width: _selectedColor == _colors[index] ? 3 : 1,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          // Stroke Width Slider
          Row(
            children: [
              const Text('Size: '),
              Expanded(
                child: Slider(
                  value: _strokeWidth,
                  min: _isHighlighter ? 10.0 : 2.0,
                  max: _isHighlighter ? 40.0 : 15.0,
                  divisions: 20,
                  label: _strokeWidth.round().toString(),
                  onChanged: (value) {
                    setState(() {
                      _strokeWidth = value;
                    });
                  },
                ),
              ),
              Text(_strokeWidth.round().toString()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToolButton(
      String label, IconData icon, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.black),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _undo() {
    if (_points.isEmpty) return;
    setState(() {
      int lastNullIndex = -1;
      for (int i = _points.length - 1; i >= 0; i--) {
        if (_points[i] == null) {
          lastNullIndex = i;
          break;
        }
      }
      if (lastNullIndex != -1) {
        _points.removeRange(lastNullIndex, _points.length);
      } else {
        _points.clear();
      }
    });
  }

  Future<void> _saveImage() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final boundary = _globalKey.currentContext!.findRenderObject()
          as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = File(
          '${tempDir.path}/annotated_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(pngBytes);

      Navigator.pop(context); // Close loading dialog
      Navigator.pop(context, file); // Return file
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving image: $e')),
      );
    }
  }
}

class DrawingPoint {
  final Offset offset;
  final Color color;
  final double strokeWidth;
  final bool isHighlighter;

  DrawingPoint(this.offset, this.color, this.strokeWidth, this.isHighlighter);
}

class ImagePainter extends CustomPainter {
  final ui.Image? image;
  final List<DrawingPoint?> points;
  final Size? originalImageSize;

  ImagePainter(this.image, this.points, this.originalImageSize);

  @override
  void paint(Canvas canvas, Size size) {
    if (image != null && originalImageSize != null) {
      // Calculate the aspect ratio to fit the image without stretching
      final double imageAspectRatio = originalImageSize!.width / originalImageSize!.height;
      final double canvasAspectRatio = size.width / size.height;

      double renderWidth;
      double renderHeight;
      double offsetX = 0;
      double offsetY = 0;

      if (canvasAspectRatio > imageAspectRatio) {
        // Canvas is wider - fit to height
        renderHeight = size.height;
        renderWidth = renderHeight * imageAspectRatio;
        offsetX = (size.width - renderWidth) / 2;
      } else {
        // Canvas is taller - fit to width
        renderWidth = size.width;
        renderHeight = renderWidth / imageAspectRatio;
        offsetY = (size.height - renderHeight) / 2;
      }

      // Draw the image maintaining aspect ratio
      final srcRect = Rect.fromLTWH(
        0,
        0,
        image!.width.toDouble(),
        image!.height.toDouble(),
      );
      final dstRect = Rect.fromLTWH(
        offsetX,
        offsetY,
        renderWidth,
        renderHeight,
      );
      
      // Fill background with white
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = Colors.white,
      );
      
      canvas.drawImageRect(image!, srcRect, dstRect, Paint());

      // Draw the annotations
      for (int i = 0; i < points.length - 1; i++) {
        if (points[i] != null && points[i + 1] != null) {
          final paint = Paint()
            ..color = points[i]!.isHighlighter
                ? points[i]!.color.withOpacity(0.4)
                : points[i]!.color
            ..strokeWidth = points[i]!.strokeWidth
            ..strokeCap = StrokeCap.round
            ..style = PaintingStyle.stroke;

          canvas.drawLine(points[i]!.offset, points[i + 1]!.offset, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}