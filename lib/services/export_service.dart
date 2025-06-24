import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

class ExportService {
  static Future<void> exportAsCSV(List<Map<String, String>> parsedAnswers) async {
    if (parsedAnswers.isEmpty) return;

    final csvData = StringBuffer();
    csvData.writeln('Frage,Antwort,LinkId');
    // separate answer and linkID
    final csvRows = parsedAnswers.map((entry) {
      final answer = entry['answer'] ?? '';
      final match = RegExp(r'^(.*?)(\s*\(([^()]*)\))?$').firstMatch(answer);
      final cleanAnswer = match?.group(1)?.trim() ?? answer;
      final linkId = match?.group(3)?.trim() ?? '';
      return [entry['text'] ?? '', cleanAnswer, linkId];
    }).toList();
    for (var row in csvRows) {
      final question = row[0].replaceAll(',', ' ');
      final answer = row[1].replaceAll(',', ' ');
      final linkId = row[2].replaceAll(',', ' ');
      csvData.writeln('$question,$answer,$linkId');
    }

    try {
      final directory = await getTemporaryDirectory();
      final now = DateTime.now();
      final timestamp =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}-${now.minute.toString().padLeft(2, '0')}';
      final fileName = 'MaxMustermann_${timestamp}_Anamnese.csv';
      final filePath = '${directory.path}/$fileName';

      final file = File(filePath);
      await file.writeAsString(csvData.toString());

      await Share.shareXFiles([XFile(filePath)]);
    } catch (e) {
      debugPrint('❌ Fehler beim Exportieren: $e');
    }
  }
}
