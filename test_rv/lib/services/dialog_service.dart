import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DialogService {
  Future<String> getDialog(String message) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('userId');
    String? token = prefs.getString('token');

    if (userId == null) {
      return 'User ID not found in preferences';
    }

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    var request = http.Request(
      'POST',
      Uri.parse('http://192.168.100.35:8000/'),
    );

    // Include the user's ID in the request body
    request.body = json.encode({"text": message, "userId": userId});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      // Parse the JSON response
      final jsonData = jsonDecode(responseBody);
      // Extract the value associated with the "response" key
      final jsonResponse = jsonData['response'];
      return jsonResponse != null ? jsonResponse.toString() : 'Response not found';
    } else {
      final reasonPhrase = await response.reasonPhrase.toString();
      return reasonPhrase;
    }
  }

}
