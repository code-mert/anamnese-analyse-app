import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

class GPTService {
  static Future<String> analyzeTranscript(String transcript, String fhirJson) async {
    final apiKey = dotenv.env['OPENAI_API_KEY'];
    final uri = Uri.parse("https://api.openai.com/v1/chat/completions");

    final prompt = '''
“Du analysierst das folgende Interview-Transkript basierend auf dem Fragebogen im JSON-Format.

Gehe wie folgt vor:
- Wenn im Fragebogen (JSON) eine Frage eine Antwort im Feld „valueString“ hat, übernimm den vollständigen Inhalt dieses Feldes als Antwort (inkl. eventueller Klammerausdrücke).
- Wenn es keinen valueString gibt, leite die Antwort selbst aus dem Anamnesetext ab und gib zusätzlich die `linkId` dieser Frage in Klammern hinter der Antwort an.
Gib ausschließlich eine JSON-Antwort zurück – eine Liste von Objekten mit den Feldern:
- "text": Fragetext aus dem Fragebogen
- "answer": Die Antwort (siehe oben)

Berücksichtige alle Fragen, zu denen sich aus dem Transkript eine Antwort ableiten lässt.

Beispielausgabe:
[
  {
    "text": "Art der Aufnahme auf die Station",
    "answer": "Notfall (NIT_SVAn_08_03)"
  }
]
”

Interview:
$transcript

Fragebogen:
$fhirJson
''';

    final body = jsonEncode({
      "model": "gpt-4-1106-preview",
      "messages": [
        {"role": "system", "content": "Du bist eine medizinische KI, die Pflegeanamnesen anhand von FHIR-Fragebögen strukturiert auswertet."},
        {"role": "user", "content": prompt}
      ],
      "temperature": 0
    });

    try {
      final response = await http.post(  
        uri,
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/json"
        },
        body: body,
      ).timeout(const Duration(seconds: 300));

      debugPrint("Antwort von GPT:");
      debugPrint(response.body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data["choices"][0]["message"]["content"];
        final cleanedContent = content
            .replaceAll('```json', '')
            .replaceAll('```', '')
            .trim();
        if (cleanedContent == null || cleanedContent.trim().isEmpty) {
          throw Exception("GPT-Antwort ist leer oder null.");
        }
        return cleanedContent;
      } else {
        throw Exception("GPT API Fehler: ${response.statusCode} \n${response.body}");
      }
    } catch (e) {
      rethrow;
    }
  }
}