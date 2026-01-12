import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfService {
  static Future<String?> extractText(List<int> bytes) async {
    try {
      final document = PdfDocument(inputBytes: bytes);
      String text = '';
      
      for (int i = 0; i < document.pages.count; i++) {
        text += PdfTextExtractor(document).extractText(startPageIndex: i);
      }
      
      document.dispose();
      return text.isNotEmpty ? text : null;
    } catch (e) {
      return null;
    }
  }
}