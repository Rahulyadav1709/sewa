import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:sewa/model/gemini_response_model.dart';
import 'dart:convert';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfController extends GetxController {

    static late String gemini_key;
  @override
  void onInit() {
    super.onInit();
    gemini_key = dotenv.get("OPEN_API");
  }

  String? _pdfText;
  String? _summary;
  bool _isLoading = false;
  File? _selectedFile;

  String? get pdfText => _pdfText;
  String? get summary => _summary;
  bool get isLoading => _isLoading;
  File? get selectedFile => _selectedFile;
  set setSelectedFile(File file) {
    _selectedFile = file;
  }
  Future<void> pickPDF() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        _selectedFile = File(result.files.single.path!);
        await extractText();
        update();
      }
    } catch (e) {
      debugPrint('Error picking PDF: $e');
    }
  }

  Future<void> extractText() async {
    if (_selectedFile == null) return;

    try {
      _isLoading = true;
      update();

      final PdfDocument document =
          PdfDocument(inputBytes: await _selectedFile!.readAsBytes());
      PdfTextExtractor extractor = PdfTextExtractor(document);
      _pdfText = extractor.extractText();
      document.dispose();

      await generateSummary();
    } catch (e) {
      debugPrint('Error extracting text: $e');
    } finally {
      _isLoading = false;
      update();
    }
  }

  Future<void> generateSummary() async {
    // ignore: unused_local_variable
    GeminiResponseModel? geminiResponseModel;
    if (_pdfText == null) return;

    try {
      _isLoading = true;
      update();

      final response = await http.post(
        Uri.parse(
            'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$gemini_key'), // Replace with Gemini AI's endpoint
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {
                  "text":
                      "Generate a concise summary of the following text: $_pdfText'"
                }
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
      //  geminiResponseModel = GeminiResponseModel.fromJson(data);
        log(data["candidates"][0]["content"]["parts"][0]["text"]);
        // Adjust this based on the structure of Gemini AI's response
        _summary = data["candidates"][0]["content"]["parts"][0]["text"];
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
            'Failed to generate summary: ${errorData['error']['message']}');
      }
    } catch (e) {
      debugPrint('Error generating summary: $e');
    } finally {
      _isLoading = false;
      update();
    }
  }
}
