import 'dart:convert';

import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warehouse/static_classes/start_application_data.dart';

class StartApplication {
  Future<void> _saveValue({required String key, required String value}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<Response> start() async {
    var url = Uri.parse('http://127.0.0.1:8000/api/start_application');
    Map requestData = {
      'name': StartApplicationData.name,
      'email': StartApplicationData.email,
      'password': StartApplicationData.password,
      'phone_number': StartApplicationData.phone_number,
      'salary': StartApplicationData.salary,
      'birth_day': StartApplicationData.birth_day.toString(),
      'country': StartApplicationData.country,
      'start_time':
          '${StartApplicationData.start_time!.hour.toString().padLeft(2, '0')}:${StartApplicationData.start_time!.minute.toString().padLeft(2, '0')}',
      'work_hours': StartApplicationData.work_hours,
    };
    dynamic response;
    try {
      response = await post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      );
      if (response.statusCode == 201) {
        var data = jsonDecode(response.body);
        await _saveValue(key: 'token', value: data['token']);
        print('start application done successfully \n body=${response.body}');
        return response;
      } else {
        print(
          'start application failed \n statusCode=${response.statusCode} \n body=${response.body}',
        );
        return response;
      }
    } catch (e) {
      print('e=$e');
      return response;
    }
  }
}
