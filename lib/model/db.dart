import 'package:shared_preferences/shared_preferences.dart';

class Datos {
  static void registraToken(String token, List restautante) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString('token', token);
    pref.setString('id', restautante[0]['id'].toString());
  }

  static Future<Map<String, String?>> leeToken() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var datos = {
      'token': pref.getString('token'),
      'id': pref.getString('id'),
    };
    return datos;
  }
}
