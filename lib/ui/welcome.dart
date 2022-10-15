import 'package:comi_fast/main.dart';
import 'package:comi_fast/model/db.dart';
import 'package:comi_fast/model/pedido.dart';
import 'package:comi_fast/ui/login.dart';
import 'package:comi_fast/ui/platillos_por_restaurante.dart';
import 'package:flutter/material.dart';

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

  void recuperaToken() async {
    datos = await Datos.leeToken();

    _pedidos =
        getPedidos(context, datos['id'], _filtroSeleccionado, datos['token']);
    setState(() {});
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
        body: Column(
          children: [
            _filtros(),
            Expanded(
              child: FutureBuilder(
                future: _pedidos,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView(
                      children: _listaDePedidos(snapshot.data),
                    );
                  }
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            )
          ],
        ),
      );
    }
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
