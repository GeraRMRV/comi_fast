import 'dart:convert';
import 'dart:io';

import 'package:comi_fast/ui/agregar_platillos.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Platillos extends StatefulWidget {
  final Map<String, dynamic> datos;
  const Platillos(this.datos, {Key? key}) : super(key: key);

  @override
  State<Platillos> createState() => _PlatillosState();
}

class _PlatillosState extends State<Platillos> {
  get datos => widget.datos;
  TextEditingController buscar = TextEditingController();
  String filtro = 'nombre';
  Map<String, dynamic> filtrosAvan = {};
  late Future<List<Map<String, dynamic>>?> listadoPlatillos;
  List<Map<String, dynamic>> platillos = [];

  //consultamos los platillos
  Future<List<Map<String, dynamic>>?> getPlatillos(filtros) async {
    platillos = [];
    try {
      final respuesta = await http.Client().get(
        Uri.http(
          '10.0.2.2',
          '/WebSservices-Comida/public/api/search/${datos['id']}/platillo',
          filtros,
        ),
      );

      if (respuesta.statusCode == 200) {
        Map<String, dynamic> respuestaJson = jsonDecode(respuesta.body);
        for (var item in respuestaJson['datos']) {
          platillos.add({
            'id': item['id'],
            'nombre': item['nombre'],
            'descripcion': item['descripcion'],
            'precio': item['precio'],
            'imagen': item['imagen'],
            'categoria': item['categoria'],
            'status': item['status'],
          });
        }
      }
      return platillos;
    } on SocketException {
      // ignore: avoid_print
      print('error');
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    filtrosAvan.putIfAbsent('api_token', () => datos['token']);
    filtrosAvan.putIfAbsent(filtro, () => '');
    listadoPlatillos = getPlatillos(filtrosAvan);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Platillos'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AgregarPlatillos(datos),
            ),
          ).then((value) {
            setState(() {
              listadoPlatillos = getPlatillos(filtrosAvan);
            });
          });
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(
            height: 10,
          ),
          const Text('  Filtros'),
          Row(
            children: <Widget>[
              Radio(
                value: 'nombre',
                groupValue: filtro,
                onChanged: (value) {
                  setState(() {
                    filtro = 'nombre';
                  });
                },
              ),
              const Text('Platillo'),
              Radio(
                value: 'categoria',
                groupValue: filtro,
                onChanged: (value) {
                  setState(() {
                    filtro = 'categoria';
                  });
                },
              ),
              const Text('Categoria'),
              Radio(
                value: 'precio',
                groupValue: filtro,
                onChanged: (value) {
                  setState(() {
                    filtro = 'precio';
                  });
                },
              ),
              const Text('Precio'),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: buscar,
              decoration: InputDecoration(
                  labelText: 'Buscar...',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      setState(() {
                        filtrosAvan.remove('nombre');
                        filtrosAvan.remove('categoria');
                        filtrosAvan.remove('precio');
                        filtrosAvan.putIfAbsent(filtro, () => buscar.text);
                      });
                      print(filtrosAvan);

                      listadoPlatillos = getPlatillos(filtrosAvan);
                    },
                  )),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: FutureBuilder(
              future: listadoPlatillos,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView(
                    children: _listPlatillos(snapshot.data),
                  );
                } else if (snapshot.hasError) {
                  return const Center(
                    child: Text('Ocurrio un error al consultar la información'),
                  );
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _listPlatillos(data) {
    List<Widget> rowPlatillos = [];
    for (var item in data) {
      rowPlatillos.add(
        ListTile(
          leading: Image.asset(
            'assets/${item['imagen']}',
            width: 80,
          ),
          title: Text(
            item['nombre'],
          ),
          subtitle: Text(
            item['descripcion'],
          ),
          trailing: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.edit),
          ),
        ),
      );
    }
    return rowPlatillos;
  }
}
