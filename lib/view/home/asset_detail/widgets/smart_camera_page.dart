import 'dart:typed_data';
import 'dart:math';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

class SmartCameraPage extends StatefulWidget {
  const SmartCameraPage({super.key});

  @override
  State<SmartCameraPage> createState() => _SmartCameraPageState();
}

class _SmartCameraPageState extends State<SmartCameraPage> {
  CameraController? _controller;
  bool _isReady = false;
  String feedback = "Initializing camera...";
  bool canCapture = false;
  List<CameraDescription> _cameras = [];

  // Quality metrics
  double currentBlur = 0;
  double currentBrightness = 0;
  double objectCoverage = 0;

  // Thresholds
  static const double minBlurScore = 100.0;
  static const double minBrightness = 60.0;
  static const double maxBrightness = 200.0;
  static const double minObjectCoverage = 0.15; // Object should cover at least 15% of frame
  static const double maxObjectCoverage = 0.95; // Object shouldn't be too close (>95%)

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  Future<void> initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        setState(() {
          feedback = "No cameras found";
        });
        return;
      }
      
      _controller = CameraController(
        _cameras[0],
        ResolutionPreset.high,
        enableAudio: false,
      );
      
      await _controller!.initialize();
      await _controller!.startImageStream(analyzeFrame);

      if (mounted) {
        setState(() {
          _isReady = true;
          feedback = "Position object in frame";
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          feedback = "Error initializing camera: $e";
        });
      }
    }
  }

  bool _isAnalyzing = false;
  void analyzeFrame(CameraImage image) async {
    if (_isAnalyzing) return;
    _isAnalyzing = true;

    try {
      // Convert to grayscale
      final imgData = convertYUV420toImage(image);

      // Calculate quality metrics
      final blurScore = calculateBlur(imgData);
      final brightness = calculateBrightness(imgData);
      final coverage = calculateObjectCoverage(imgData);

      if (mounted) {
        setState(() {
          currentBlur = blurScore;
          currentBrightness = brightness;
          objectCoverage = coverage;

          // Determine feedback based on multiple criteria
          bool isGoodQuality = true;

          if (coverage < minObjectCoverage) {
            feedback = "❌ Object too small - Move closer";
            isGoodQuality = false;
          } else if (coverage > maxObjectCoverage) {
            feedback = "❌ Too close - Move back slightly";
            isGoodQuality = false;
          } else if (brightness < minBrightness) {
            feedback = "❌ Too dark - Add more light";
            isGoodQuality = false;
          } else if (brightness > maxBrightness) {
            feedback = "❌ Too bright - Reduce light";
            isGoodQuality = false;
          } else if (blurScore < minBlurScore) {
            feedback = "❌ Image blurry - Hold steady";
            isGoodQuality = false;
          } else {
            feedback = "✅ Perfect! Tap to capture";
            isGoodQuality = true;
          }

          canCapture = isGoodQuality;
        });
      }
    } catch (e) {
      debugPrint("Error analyzing frame: $e");
    } finally {
      _isAnalyzing = false;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> captureImage() async {
    if (!canCapture || _controller == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Cannot capture - Image quality not good enough"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Stop image stream before taking picture to avoid conflict
      await _controller!.stopImageStream();
      final XFile file = await _controller!.takePicture();
      if (mounted) {
        Navigator.pop(context, file);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error capturing image: $e")),
      );
      // Restart stream if it failed
      _controller?.startImageStream(analyzeFrame);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady || _controller == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text("Smart Quality Capture"),
          backgroundColor: Colors.black87,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Colors.white),
              const SizedBox(height: 20),
              Text(feedback, style: const TextStyle(color: Colors.white)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Smart Quality Capture", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black87,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // Camera Preview
          Positioned.fill(
            child: CameraPreview(_controller!),
          ),

          // Quality Metrics Overlay (top)
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMetric("Blur Score", currentBlur, minBlurScore, 300),
                  _buildMetric("Brightness", currentBrightness, minBrightness, maxBrightness),
                  _buildMetric("Coverage", objectCoverage * 100, minObjectCoverage * 100, maxObjectCoverage * 100),
                ],
              ),
            ),
          ),

        //   // Center guideline frame
        //   Center(
        //     child: Container(
        //       width: 280,
        //       height: 280,
        //       decoration: BoxDecoration(
        //         border: Border.all(
        //           color: canCapture ? Colors.green : Colors.red,
        //           width: 3,
        //         ),
        //         borderRadius: BorderRadius.circular(12),
        //       ),
        //       child: Center(
        //         child: Text(
        //           canCapture ? "GOOD" : "ADJUST",
        //           style: TextStyle(
        //             color: canCapture ? Colors.green : Colors.red,
        //             fontSize: 24,
        //             fontWeight: FontWeight.bold,
        //           ),
        //         ),
        //       ),
        //     ),
        //   ),

          // Feedback message (bottom)
          Positioned(
            bottom: 100,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: canCapture ? Colors.green.shade700 : Colors.red.shade700,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                feedback,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // Capture button
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: captureImage,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: canCapture ? Colors.green : Colors.grey,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 35,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, double value, double min, double max) {
    final isGood = value >= min && value <= max;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          Expanded(
            child: LinearProgressIndicator(
              value: (value / max).clamp(0.0, 1.0),
              backgroundColor: Colors.grey.shade700,
              valueColor: AlwaysStoppedAnimation(
                isGood ? Colors.green : Colors.red,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value.toStringAsFixed(0),
            style: TextStyle(
              color: isGood ? Colors.green : Colors.red,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- Image Processing Functions ---------------- //

  img.Image convertYUV420toImage(CameraImage image) {
    final int width = image.width;
    final int height = image.height;

    final img.Image grayscale = img.Image(
      width: width,
      height: height,
      numChannels: 1,
    );

    final Uint8List yPlane = image.planes[0].bytes;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final int yValue = yPlane[y * width + x];
        // In image 4.x, we can set the pixel value directly
        grayscale.setPixelRgb(x, y, yValue, yValue, yValue);
      }
    }

    return grayscale;
  }

  double calculateBlur(img.Image image) {
    // Laplacian variance - measures focus quality
    double variance = 0;
    int count = 0;

    for (int y = 1; y < image.height - 1; y++) {
      for (int x = 1; x < image.width - 1; x++) {
        final centerValue = image.getPixel(x, y).r.toInt();

        int laplacian =
            (-1 * image.getPixel(x - 1, y - 1).r.toInt()) +
                (-1 * image.getPixel(x - 1, y).r.toInt()) +
                (-1 * image.getPixel(x - 1, y + 1).r.toInt()) +
                (-1 * image.getPixel(x, y - 1).r.toInt()) +
                (8 * centerValue) +
                (-1 * image.getPixel(x, y + 1).r.toInt()) +
                (-1 * image.getPixel(x + 1, y - 1).r.toInt()) +
                (-1 * image.getPixel(x + 1, y).r.toInt()) +
                (-1 * image.getPixel(x + 1, y + 1).r.toInt());

        variance += laplacian * laplacian;
        count++;
      }
    }

    return count > 0 ? variance / count : 0;
  }

  double calculateBrightness(img.Image image) {
    double sum = 0;
    int count = 0;

    for (int y = 0; y < image.height; y += 5) {
      for (int x = 0; x < image.width; x += 5) {
        final pixel = image.getPixel(x, y);
        sum += pixel.r;
        count++;
      }
    }

    return count > 0 ? sum / count : 0;
  }

  double calculateSharpness(img.Image image) {
    // Edge detection using Sobel operator
    double edgeStrength = 0;
    int count = 0;

    for (int y = 1; y < image.height - 1; y += 3) {
      for (int x = 1; x < image.width - 1; x += 3) {
        // Sobel X
        int gx =
            (-1 * image.getPixel(x - 1, y - 1).r.toInt()) +
                (0 * image.getPixel(x, y - 1).r.toInt()) +
                (1 * image.getPixel(x + 1, y - 1).r.toInt()) +
                (-2 * image.getPixel(x - 1, y).r.toInt()) +
                (0 * image.getPixel(x, y).r.toInt()) +
                (2 * image.getPixel(x + 1, y).r.toInt()) +
                (-1 * image.getPixel(x - 1, y + 1).r.toInt()) +
                (0 * image.getPixel(x, y + 1).r.toInt()) +
                (1 * image.getPixel(x + 1, y + 1).r.toInt());

        // Sobel Y
        int gy =
            (-1 * image.getPixel(x - 1, y - 1).r.toInt()) +
                (-2 * image.getPixel(x, y - 1).r.toInt()) +
                (-1 * image.getPixel(x + 1, y - 1).r.toInt()) +
                (0 * image.getPixel(x - 1, y).r.toInt()) +
                (0 * image.getPixel(x, y).r.toInt()) +
                (0 * image.getPixel(x + 1, y).r.toInt()) +
                (1 * image.getPixel(x - 1, y + 1).r.toInt()) +
                (2 * image.getPixel(x, y + 1).r.toInt()) +
                (1 * image.getPixel(x + 1, y + 1).r.toInt());

        double magnitude = sqrt(gx * gx + gy * gy);
        edgeStrength += magnitude;
        count++;
      }
    }

    return count > 0 ? edgeStrength / count : 0;
  }

  double calculateObjectCoverage(img.Image image) {
    // Calculate how much of the frame has significant content
    // Using edge detection to find object boundaries
    int significantPixels = 0;
    int totalSamples = 0;

    // Calculate average brightness first
    double avgBrightness = calculateBrightness(image);

    // Count pixels that differ significantly from background
    for (int y = 0; y < image.height; y += 4) {
      for (int x = 0; x < image.width; x += 4) {
        final pixelValue = image.getPixel(x, y).r;

        // Check if pixel is significantly different from average
        // This helps detect object vs background
        if ((pixelValue - avgBrightness).abs() > 20) {
          significantPixels++;
        }
        totalSamples++;
      }
    }

    return totalSamples > 0 ? significantPixels / totalSamples : 0;
  }
}
