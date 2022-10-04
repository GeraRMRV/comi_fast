import 'dart:ffi';

class Pedido {
  int id;
  DateTime fecha;
  double total;
  String cliente;
  String status;

  Pedido(
      {required this.id,
      required this.fecha,
      required this.total,
      required this.cliente,
      required this.status});
}
