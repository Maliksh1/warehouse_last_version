import 'dart:convert';

import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warehouse/static_classes/login_employee_data.dart';

class LoginEmployee {
  Future<void> _saveValue({required String key, required String value}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<Response> login() async {
    var url = Uri.parse('http://127.0.0.1:8000/api/login_employe');
    Map requestData = {
      'email': LoginEmployeeData.email,
      'password': LoginEmployeeData.password,
      'phone_number': LoginEmployeeData.phone_number,
    };
    var response = await post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestData),
    );
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      await _saveValue(key: 'token', value: data['token']);
      print('LoginEmployee done successfully \n body=${response.body}');
      return response;
    } else {
      print(
        'LoginEmployee failed \n statusCode=${response.statusCode} \n body=${response.body}',
      );
      return response;
    }
  }
}
