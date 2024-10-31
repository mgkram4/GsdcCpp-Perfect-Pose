import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

Future<void> analyzePose(String category, String poseName, File imageFile) async {
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
      // Use the result in your app
      print('Analysis Result: $result');
    } else {
      print('Error: ${responseData.reasonPhrase}');
    }
  } catch (e) {
    print('Exception: $e');
  }
}
