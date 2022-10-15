import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class InfoPlatillo extends StatefulWidget {
  final Map<String, dynamic> datos;
  final Map<String, dynamic> info;
  const InfoPlatillo(this.datos, this.info, {Key? key}) : super(key: key);

  @override
  State<InfoPlatillo> createState() => _InfoPlatilloState();
}

class _InfoPlatilloState extends State<InfoPlatillo> {
  get datos => widget.datos;
  get info => widget.info;
  late bool disponible;

  @override
  void initState() {
    super.initState();
    info['status'] == 'disponible' ? disponible = true : disponible = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Información'),
      ),
      body: Container(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Image.asset('assets/${info['imagen']}'),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              info['nombre'],
              style: const TextStyle(fontSize: 20),
            ),
            Text(
              info['descripcion'],
            ),
            Text(
              'Categoría: ${info['categoria']}',
            ),
            Text(
              '\$${info['precio']}',
              style: const TextStyle(fontSize: 20),
            ),
            Row(
              children: <Widget>[
                disponible == true
                    ? const Text('Disponible')
                    : const Text('No disponible'),
                Switch(
                  value: disponible,
                  onChanged: (bool value) async {
                    try {
                      final respuesta = await http.Client().put(
                        Uri.http(
                          '10.0.2.2',
                          '/WebSservices-Comida/public/api/platillo/${info['id']}/${value == true ? 'disponible' : 'no disponible'}',
                        ),
                        body: '',
                        headers: {
                          'Content-type': 'application/json',
                          'Accept': 'application/json',
                          'Charset': 'utf-8',
                        },
                      );
                      if (respuesta.statusCode == 200) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Status actualizado'),
                          ),
                        );
                      }
                    } on SocketException {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Error de conexión'),
                        ),
                      );
                    }
                    setState(() {
                      disponible = value;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
