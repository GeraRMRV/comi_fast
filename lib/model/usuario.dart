import 'dart:io';

import 'package:http/http.dart' as http;

class Usuario {
  String api_key;
  String email;
  String password;

  Usuario(this.api_key, this.email, this.password);

  static Future<String> valida(String e, String c) async {
    try {
      final respuesta = await http.Client().get(Uri.http(
          '10.0.2.2',
          '/WebSservices-Comida/public/api/login',
          {'email': e, 'password': c}));
      return respuesta.body.toString();
    } on Exception catch (e) {
      //print('ERROR: ' + e.toString());
      return "{'respuesta': 'Error de conexión'}";
    }
  }
}
