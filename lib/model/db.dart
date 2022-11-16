import 'package:shared_preferences/shared_preferences.dart';

class Datos {
  static void registraToken(String token, List restautante) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString('token', token);
    pref.setString('id', restautante[0]['id'].toString());
    pref.setString(
        'nombre_contacto', restautante[0]['nombre_contacto'].toString());
    pref.setString('ubicacion_lat', restautante[0]['ubicacion_lat'].toString());
    pref.setString(
        'ubicacion_long', restautante[0]['ubicacion_long'].toString());
  }

  static Future<Map<String, String?>> leeToken() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var datos = {
      'token': pref.getString('token'),
      'id': pref.getString('id'),
      'nombre_contacto': pref.getString('nombre_contacto'),
      'ubicacion_lat': pref.getString('ubicacion_lat'),
      'ubicacion_long': pref.getString('ubicacion_long'),
    };
    return datos;
  }
}
