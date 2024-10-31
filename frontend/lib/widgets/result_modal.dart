import 'package:flutter/material.dart';

class ResultModal extends StatelessWidget {
  final Map<String, dynamic> analysisResult;

  const ResultModal({Key? key, required this.analysisResult}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Close Button
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),

            // Form Score
            Center(
              child: Column(
                children: [
                  const Text(
                    'Form Analysis',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Form Score: ${analysisResult['similarity_score']}/100',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: (analysisResult['similarity_score'] ?? 0) > 75 ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Areas to Improve Section
            const Text(
              'Areas to Improve',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            // List of Improvement Suggestions
            ..._buildAreasToImprove(),

            const SizedBox(height: 20),

            // Continue Button
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Continue",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildAreasToImprove() {
    final List<Widget> widgets = [];

    if (analysisResult['angle_differences'] != null) {
      final angleDifferences = analysisResult['angle_differences'] as Map<String, dynamic>;

      angleDifferences.forEach((joint, difference) {
        widgets.add(Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.yellow[100],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                joint,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text(
                'Adjust by ${difference.toStringAsFixed(1)}° to improve alignment',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ));
      });
    }

    if (analysisResult['suggestions'] != null) {
      final suggestions = analysisResult['suggestions'] as List<dynamic>;
      for (var suggestion in suggestions) {
        widgets.add(Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green[100],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            suggestion,
            style: const TextStyle(fontSize: 14),
          ),
        ));
      }
    }

    return widgets;
  }
}
