import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const MaterialApp(home: DetectionScreen()));

class DetectionScreen extends StatefulWidget {
  const DetectionScreen({super.key});

  @override
  State<DetectionScreen> createState() => _DetectionScreenState();
}

class _DetectionScreenState extends State<DetectionScreen> {
  File? _image;
  Size? _originalImageSize;
  List<List<Offset>> _polygons = [];
  bool _loading = false;

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile == null) return;

    final imageFile = File(pickedFile.path);

    final decoded = await decodeImageFromList(await imageFile.readAsBytes());
    _originalImageSize = Size(
      decoded.width.toDouble(),
      decoded.height.toDouble(),
    );

    setState(() {
      _loading = true;
      _polygons.clear();
    });

    final response = await _sendToApi(imageFile);

    setState(() {
      _image = imageFile;
      _polygons = response;
      _loading = false;
    });
  }

  Future<List<List<Offset>>> _sendToApi(File imageFile) async {
    final url = Uri.parse('http://192.168.1.6:5001/detect-teeth');
    final request = http.MultipartRequest('POST', url);
    request.files.add(
      await http.MultipartFile.fromPath('image', imageFile.path),
    );

    final streamedResponse = await request.send();
    final responseBody = await streamedResponse.stream.bytesToString();

    if (streamedResponse.statusCode == 200) {
      final data = jsonDecode(responseBody);
      final List polygonsRaw = data['polygons'];
      return polygonsRaw.map<List<Offset>>((poly) {
        return poly
            .map<Offset>(
              (point) => Offset(point[0].toDouble(), point[1].toDouble()),
            )
            .toList();
      }).toList();
    } else {
      throw Exception('API Error: $responseBody');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Teeth Segmentation')),
      body: Center(
        child:
            _loading
                ? const CircularProgressIndicator()
                : _image == null
                ? const Text('No image selected')
                : LayoutBuilder(
                  builder: (context, constraints) {
                    return ImageWithPolygons(
                      image: _image!,
                      originalSize: _originalImageSize!,
                      polygons: _polygons,
                      maxWidth: constraints.maxWidth,
                    );
                  },
                ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "camera",
            onPressed: () => _pickImage(ImageSource.camera),
            child: const Icon(Icons.camera_alt),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: "gallery",
            onPressed: () => _pickImage(ImageSource.gallery),
            child: const Icon(Icons.photo_library),
          ),
        ],
      ),
    );
  }
}

class ImageWithPolygons extends StatelessWidget {
  final File image;
  final Size originalSize;
  final List<List<Offset>> polygons;
  final double maxWidth;

  const ImageWithPolygons({
    super.key,
    required this.image,
    required this.originalSize,
    required this.polygons,
    required this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    final scale = maxWidth / originalSize.width;
    final scaledHeight = originalSize.height * scale;

    final scaledPolygons =
        polygons
            .map(
              (poly) =>
                  poly.map((p) => Offset(p.dx * scale, p.dy * scale)).toList(),
            )
            .toList();

    return SizedBox(
      width: maxWidth,
      height: scaledHeight,
      child: Stack(
        children: [
          Image.file(
            image,
            width: maxWidth,
            height: scaledHeight,
            fit: BoxFit.cover,
          ),
          CustomPaint(
            painter: TeethPainter(polygons: scaledPolygons),
            size: Size(maxWidth, scaledHeight),
          ),
        ],
      ),
    );
  }
}

class TeethPainter extends CustomPainter {
  final List<List<Offset>> polygons;

  TeethPainter({required this.polygons});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0
          ..color = Colors.green;

    for (final poly in polygons) {
      if (poly.isNotEmpty) {
        final path = Path()..moveTo(poly.first.dx, poly.first.dy);
        for (final point in poly.skip(1)) {
          path.lineTo(point.dx, point.dy);
        }
        path.close();
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
