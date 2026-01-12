import 'package:file_picker/file_picker.dart';

class FileService {
  static Future<List<int>?> pickPdfFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true, // Ensure we get the file data
      );

      return result?.files.first.bytes;
    } catch (e) {
      return null;
    }
  }
}