import 'dart:convert';
import 'dart:math';

import 'package:comi_fast/model/db.dart';
import 'package:comi_fast/model/pedido.dart';
import 'package:comi_fast/ui/login.dart';
import 'package:comi_fast/ui/platillos_por_restaurante.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class Welcome extends StatefulWidget {
  const Welcome({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  Map<String, dynamic> datos = {};
  late Future<List<Map<String, dynamic>>?> _pedidos;
  String _filtroSeleccionado = "PEDIDO";
  bool estaBuscando = false;
  late Future<bool> termino;
  late GoogleMapController mapaController;
  String googleAPiKey = 'AIzaSyCII9AIKLCH7bWwb5ziG6VcU1W0BCNj2Gs';

  String distancia = '0 km';
  String duracion = '0 min';
  String temperatura = '';

  void recuperaToken() async {
    datos = await Datos.leeToken();

    _pedidos =
        getPedidos(context, datos['id'], _filtroSeleccionado, datos['token']);
    setState(() {});
  }

  //mapas
  Future<bool> calcularDistancia() async {
    String coordenadas = '16.9088128584562,-92.08694027811178';
    final respuesta = await http.Client().get(
      Uri.https(
        'maps.googleapis.com',
        '/maps/api/directions/json',
        {
          'key': googleAPiKey,
          'origin': '${datos['ubicacion_lat']},${datos['ubicacion_long']}',
          'destination': coordenadas,
          'mode': 'driving',
        },
      ),
    );
    print(respuesta.body);
    if (respuesta.statusCode == 200) {
      Map<String, dynamic> json = jsonDecode(respuesta.body);
      distancia = json['routes'][0]['legs'][0]['distance']['text'];
      duracion = json['routes'][0]['legs'][0]['duration']['text'];

      final respuestaJson = await http.Client().get(
        Uri.http(
            'api.weatherunlocked.com',
            '/api/current/${datos['ubicacion_lat']},${datos['ubicacion_long']}',
            {
              'app_id': '01b85b83',
              'app_key': '9d73e926abf05b9095366a9766539811',
            }),
      );
      if (respuestaJson.statusCode == 200) {
        Map<String, dynamic> clima = jsonDecode(respuestaJson.body);
        temperatura = clima['temp_c'].toString();
      }
    }
    estaBuscando = true;
    setState(() {});
    return true;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    recuperaToken();
  }

  @override
  Widget build(BuildContext context) {
    if (datos['token'] == '' || datos['token'] == null) {
      return MyHomePage(title: 'COMIDAS');
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        drawer: Drawer(
          child: ListView(
            children: <Widget>[
              UserAccountsDrawerHeader(
                currentAccountPicture: ClipOval(
                  child: Text('G'),
                ),
                accountName: Text('Gera MX'),
                accountEmail: Text('GeraMX@gmail.com'),
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text('Mi perfil'),
              ),
              ListTile(
                leading: Icon(Icons.breakfast_dining_outlined),
                title: Text('Platillos'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Platillos(datos),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.car_crash_outlined),
                title: Text('Repartidores'),
              ),
              ListTile(
                leading: Icon(Icons.logout),
                title: Text('Cerrar'),
              )
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              _filtros(),
              FutureBuilder(
                future: _pedidos,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Column(
                      children: _listaDePedidos(snapshot.data),
                    );
                  }
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    termino = calcularDistancia();
                  });
                },
                child: const Text(
                  'Ver mis secursales',
                  style: TextStyle(color: Colors.white),
                ),
                style: TextButton.styleFrom(backgroundColor: Colors.orange),
              ),
              estaBuscando == false
                  ? const Center()
                  : SizedBox(
                      height: 300,
                      child: widgetMapas(),
                    ),
            ],
          ),
        ),
      );
    }
  }

  widgetMapas() {
    return FutureBuilder(
        future: termino,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Column(
              children: <Widget>[
                Expanded(
                  child: GoogleMap(
                    mapType: MapType.normal,
                    initialCameraPosition: const CameraPosition(
                      target: LatLng(
                        16.915952376568555,
                        -92.09000935960353,
                      ),
                      zoom: 16,
                    ),
                    markers: crearMarkers(),
                    onMapCreated: onMapCreated,
                  ),
                ),
                Text('Distancia de la sucursal 1 a la sucursal 2: $distancia'),
                Text(
                    'Tiempo estimado de la sucursal 1 a la sucursal 2: $duracion'),
                Text('Temperatura: $temperatura'),
              ],
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        });
  }

  onMapCreated(GoogleMapController controller) {
    mapaController = controller;
    centerView();
  }

  centerView() async {
    await mapaController.getVisibleRegion();
    var left = min(
      double.parse(datos['ubicacion_lat']),
      16.9088128584562,
    );
    var right = max(
      double.parse(datos['ubicacion_lat']),
      16.9088128584562,
    );
    var top = max(
      double.parse(datos['ubicacion_long']),
      -92.08694027811178,
    );
    var bottom = min(
      double.parse(datos['ubicacion_long']),
      -92.08694027811178,
    );

    var bounds = LatLngBounds(
      southwest: LatLng(left, bottom),
      northeast: LatLng(right, top),
    );
    var cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 50);
    mapaController.animateCamera(cameraUpdate);
  }

  Set<Marker> crearMarkers() {
    var tmp = <Marker>{};
    tmp.add(
      Marker(
          markerId: const MarkerId('Sucursal 1'),
          position: LatLng(
            double.parse(datos['ubicacion_lat']),
            double.parse(
              datos['ubicacion_long'],
            ),
          ),
          infoWindow: InfoWindow(title: datos['nombre_contacto'])),
    );
    tmp.add(
      const Marker(
          markerId: MarkerId('Sucursal 2'),
          position: LatLng(
            16.9088128584562,
            -92.08694027811178,
          ),
          infoWindow: InfoWindow(title: 'Mi ubicación')),
    );

    return tmp;
  }

  Widget _filtros() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Radio(
          value: "PEDIDO",
          groupValue: _filtroSeleccionado,
          onChanged: (value) {
            setState(() {
              _filtroSeleccionado = "PEDIDO";
              _pedidos = getPedidos(
                  context, datos['id'], _filtroSeleccionado, datos['token']);
            });
          }),
      Text("Pedidos"),
      Radio(
          value: "PROCESO",
          groupValue: _filtroSeleccionado,
          onChanged: (value) {
            setState(() {
              _filtroSeleccionado = "PROCESO";
              _pedidos = getPedidos(
                  context, datos['id'], _filtroSeleccionado, datos['token']);
            });
          }),
      Text("En Proceso"),
    ]);
  }

  List<Widget> _listaDePedidos(data) {
    List<Widget> listTile = [];
    for (var item in data) {
      listTile.add(
        ListTile(
          title: Text(item['fecha']),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Forma de pago: ${item['formaPago']}',
              ),
              Text(
                'Total: \$${item['total']}',
              ),
            ],
          ),
        ),
      );
    }
    return listTile;
  }
}
