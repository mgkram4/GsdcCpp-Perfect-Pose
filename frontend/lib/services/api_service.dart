import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:perfect_pose/widgets/result_modal.dart';

Future<void> analyzePose(BuildContext context, String category, String poseName, File imageFile) async {
  final uri = Uri.parse('http://your-server-ip:5000/analyze_pose');

  // Create a multipart request
  var request = http.MultipartRequest('POST', uri);

  // Add form data fields
  request.fields['category'] = category;
  request.fields['pose_name'] = poseName;

  // Attach the image file
  request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

  try {
    // Send the request
    var response = await request.send();

    // Get the response
    var responseData = await http.Response.fromStream(response);

    if (responseData.statusCode == 200) {
      // Parse the JSON response
      var result = jsonDecode(responseData.body);

      // Show ResultModal with the result
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return ResultModal(analysisResult: result);
        },
      );
    } else {
      // Handle error response
      print('Error: ${responseData.reasonPhrase}');
      _showErrorDialog(context, 'Error: ${responseData.reasonPhrase}');
    }
  } catch (e) {
    print('Exception: $e');
    _showErrorDialog(context, 'Exception: $e');
  }
}

// Helper function to show an error dialog
void _showErrorDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      );
    },
  );
}
