import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  final GenerativeModel model;

  GeminiService({required String apiKey})
      : model = GenerativeModel(
          model: 'gemini-pro',
          apiKey: apiKey,
        );

  Future<String?> generateSummary(String text) async {
    try {
      final prompt = 'Please provide a concise summary of the following text: $text';
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      return response.text;
    } catch (e) {
      return null;
    }
  }
}