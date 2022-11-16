import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

List<Map<String, dynamic>> pedidos = [];

Future<List<Map<String, dynamic>>?> getPedidos(
    BuildContext context, String id, String status, String apiToken) async {
  pedidos = [];
  try {
    final respuesta = await http.Client().get(
      Uri.http(
        '192.168.0.102',
        '/pedidos/public/api/pedidos/$id/$status',
        {
          'api_token': apiToken,
        },
      ),
    );
    print(respuesta.body);
    Map<String, dynamic> data = jsonDecode(respuesta.body);
    var i = 0;
    var pedidoPlatillo = [];

    for (var item in data['datos']) {
      pedidos.add(
        {
          'id': item['id'],
          'idCliente': item['id_cliente'],
          'fecha': item['fecha'],
          'ubicacionLat': item['ubicacion_lat'],
          'ubicacionLong': item['ubicacion_long'],
          'status': item['status'],
          'iva': item['iva'],
          'formaPago': item['forma_pago'],
          'total': item['total'],
          'envios': item['envios'],
          'cliente': {
            'id': item['cliente']['id'],
            'nombre': item['cliente']['nombre'],
            'apellidos': item['cliente']['apellidos'],
            'email': item['cliente']['email'],
            'telefono': item['cliente']['telefono'],
            'telefono2': item['cliente']['telefono2'],
          },
        },
      );
      for (var itemPlatillo in item['pedido_platillo']) {
        pedidoPlatillo.add(
          {
            'id': itemPlatillo['id'],
            'idPedido': itemPlatillo['id_pedido'],
            'idPlatillo': itemPlatillo['id_platillo'],
            'idEnvio': itemPlatillo['id_envio'],
            'cantidad': itemPlatillo['cantidad'],
            'precio': itemPlatillo['precio'],
            'platillo': {
              'id': itemPlatillo['platillo']['id'],
              'nombre': itemPlatillo['platillo']['nombre'],
              'precio': itemPlatillo['platillo']['precio'],
              'imagen': itemPlatillo['platillo']['imagen'],
              'categoria': itemPlatillo['platillo']['categoria'],
            }
          },
        );
      }
      pedidos[i].putIfAbsent('pedido_platillo', () => pedidoPlatillo);
      pedidoPlatillo = [];
      i++;
    }
    return pedidos;
  } on SocketException {
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Error de conexión')));
  }
  return null;
}
