import 'dart:convert';

import 'package:chemobile/models/eln_user.dart';
import 'package:chemobile/models/exception.dart';
import 'package:http/http.dart' as http;

class LoginService {
  Future<ElnUser> authenticate(String identifier, String password, String elnUrl) async {
    var url = Uri.parse("$elnUrl/api/v1/public/token");
    var response = await http.post(
      url,
      body: {
        'username': identifier,
        'password': password,
      },
    );

    if (response.statusCode == 201) {
      var jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      var token = jsonResponse['token'];
      return ElnUser.fromLogin(token, elnUrl);
    } else {
      throw UserNotFoundException();
    }
  }
}
