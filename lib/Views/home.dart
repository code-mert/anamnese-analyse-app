import 'package:flutter/material.dart';
import '../../services/gpt_service.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../../services/export_service.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, String>> _parsedAnswers = [];
  bool _isLoading = false;

  String? findQuestionTextByLinkId(List<dynamic> items, String linkId) {
    for (var item in items) {
      if (item['linkId'] == linkId && item['text'] != null) {
        return item['text'];
      }
      if (item['item'] != null && item['item'] is List) {
        final result = findQuestionTextByLinkId(item['item'], linkId);
        if (result != null) return result;
      }
    }
    return null;
  }

//Questionnaire
  Future<String> loadFragebogenJson() async {
    return await rootBundle.loadString('assets/2025-03-26 NursIT Anamnesis FHIR Questionnaire with detailed descriptions.json');
  }


  Future<void> _analyzeTranscript() async {
    if (_controller.text.trim().isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final fhirFragebogen = await loadFragebogenJson();
      final resultJson = await GPTService.analyzeTranscript(_controller.text, fhirFragebogen);
      // Parse the JSON answer from GPT
      List<dynamic> parsed = jsonDecode(resultJson);
      final parsedAnswers = parsed.map<Map<String, String>>((item) {
        return {
          'text': item['text']?.toString() ?? '',
          'answer': item['answer']?.toString() ?? '',
          //'linkId': item['linkId']?.toString() ?? '',
        };
      }).toList();
      setState(() {
        _parsedAnswers = parsedAnswers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _parsedAnswers = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () async {
              try {
                await ExportService.exportAsCSV(_parsedAnswers);
              } catch (e) {
                debugPrint('❌ Fehler beim Exportieren: $e');
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              setState(() {
                _controller.clear();
                _parsedAnswers = [];
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _analyzeTranscript,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Container( // Textbox
                    decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: TextField(
                      controller: _controller,
                      maxLines: 6,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.all(12.0),
                        border: InputBorder.none,
                        hintText: 'Schreibe oder spreche deinen Text hier ...',
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_parsedAnswers.isNotEmpty)
                    // Neue Darstellung der GPT-Antwort als Liste
                    Expanded(
                      child: ListView.builder(
                        itemCount: _parsedAnswers.length,
                        itemBuilder: (context, index) {
                          final item = _parsedAnswers[index];
                          final question = item['text'] ?? 'Keine Frage';
                          final answer = item['answer'] ?? 'Keine Angabe';
                          //final linkId = item['linkId'] ?? '';

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  question,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(answer), //($linkId)'),
                                const Divider()
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}