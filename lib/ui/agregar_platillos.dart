import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class AgregarPlatillos extends StatefulWidget {
  final Map<String, dynamic> datos;
  const AgregarPlatillos(this.datos, {Key? key}) : super(key: key);

  @override
  State<AgregarPlatillos> createState() => _AgregarPlatillosState();
}

class _AgregarPlatillosState extends State<AgregarPlatillos> {
  get datos => widget.datos;
  final formKey = GlobalKey<FormState>();
  TextEditingController platillo = TextEditingController();
  TextEditingController desc = TextEditingController();
  TextEditingController precio = TextEditingController();
  TextEditingController foto = TextEditingController();
  String imagen64 = '';
  String categoria = 'Categoría';
  List<String> categorias = [
    'Desayunos',
    'Comidas',
    'Cenas',
    'Postres',
    'Helados',
    'Bebidas',
    'Licores',
  ];
  String path = '';
  String validaPath = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar platillos'),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  controller: platillo,
                  decoration: const InputDecoration(
                    labelText: 'Platillo',
                  ),
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Escribe el nombre del platillo';
                    } else if (value.length < 4) {
                      return 'El nombre debe tener mas de 3 letras';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                DropdownButtonFormField(
                  hint: categoria == ''
                      ? const Text('Cargando')
                      : Text(categoria),
                  items: categorias.map<DropdownMenuItem<String>>(
                    (String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    },
                  ).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      categoria = value!;
                    });
                  },
                  validator: (value) {
                    if (value == null || value == '') {
                      return 'Elige una opción';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: precio,
                  decoration: const InputDecoration(
                    labelText: 'Precio',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Escribe el precio del platillo';
                    } else if (double.parse(value) < 1) {
                      return 'Escribe un número positivo';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: desc,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Escribe alguna descripción';
                    } else if (value.length < 6) {
                      return 'La descripción debe tener mas de 5 letras';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text(
                    'Elegir foto',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? imagen = await picker.pickImage(
                      source: ImageSource.gallery,
                    );
                    setState(() {
                      path = imagen!.path;
                    });
                    List<int> bytes = File(path).readAsBytesSync();
                    imagen64 = base64.encode(bytes);
                  },
                ),
                const SizedBox(
                  height: 3,
                ),
                Text(
                  '    $validaPath',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.red,
                  ),
                ),
                path == ''
                    ? Container()
                    : Image.file(
                        File(path),
                        width: 100,
                      ),
                const SizedBox(
                  height: 20,
                ),
                Center(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    child: const Text(
                      'REGISTRAR',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        try {
                          var data = {
                            'id_restaurant': datos['id'],
                            'nombre': platillo.text,
                            'descripcion': desc.text,
                            'precio': precio.text,
                            'imagen': imagen64,
                            'categoria': categoria,
                            'status': 'Disponible',
                          };
                          final respuesta = await http.Client().post(
                            Uri.http(
                              '10.0.2.2',
                              '/WebSservices-Comida/public/api/create/platillo',
                              {
                                'api_token': datos['token'],
                              },
                            ),
                            body: jsonEncode(data),
                            headers: {
                              'Content-type': 'application/json',
                              'Accept': 'application/json',
                              'Charset': 'utf-8',
                            },
                          );
                          if (respuesta.statusCode == 200) {
                            Map<String, dynamic> datos =
                                jsonDecode(respuesta.body);
                            // ignore: use_build_context_synchronously
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Platillo registrado'),
                              ),
                            );
                            if (datos['resp'] == 'success') {
                              // ignore: use_build_context_synchronously
                              Navigator.pop(context);
                            }
                          }
                        } on SocketException {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Error de conexión'),
                            ),
                          );
                        }
                      }
                      path == '' ? validaPath = 'Agrega una imagen' : '';
                      setState(() {});
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
