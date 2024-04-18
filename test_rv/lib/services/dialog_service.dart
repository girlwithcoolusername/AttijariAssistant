import 'dart:convert';
import 'package:http/http.dart' as http;

class DialogService {

  Future<String> getDialog(String message) async {
    var headers = {'Content-Type': 'application/json'};
        var request = http.Request(
            'POST', Uri.parse('http://192.168.116.145:8000/get_response'));
        request.body = json.encode({"text": message});
        request.headers.addAll(headers);

        http.StreamedResponse response = await request.send();

        if (response.statusCode == 200) {
          final responseBody = await response.stream.bytesToString();
          return responseBody;
        } else {
          final reasonPhrase = await response.reasonPhrase.toString();
          return reasonPhrase;
        }
      }
    }