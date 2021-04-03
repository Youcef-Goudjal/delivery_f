import 'package:delivery_f/services/database_creator.dart';

class Product {
  int id;
  String name;
  double price0, price1, price2, price3;
  String barcode;
  double quantity, stock;
  int box = 1;
  int pricing = 1;

  double price() {
    if (pricing == 0) return price0;
    if (pricing == 2) return price2;
    if (pricing == 3) return price3;
    return price1;
  }

  double get total => price() * quantity * box;

  Product({
    this.id,
    this.name,
    this.price0,
    this.price1,
    this.price2,
    this.price3,
    this.quantity = 0,
    this.stock,
    this.barcode,
    this.box,
  });

  Product.fromJson(Map<String, dynamic> json) {
    this.id = json[DatabaseCreator.products_id];
    this.name = json[DatabaseCreator.products_name];
    this.barcode = json[DatabaseCreator.products_barcode];
    this.price0 = double.parse(json[DatabaseCreator.products_price0] ?? "0");
    this.price1 = double.parse(json[DatabaseCreator.products_price]);
    this.price2 = double.parse(json[DatabaseCreator.products_price2]);
    this.price3 = double.parse(json[DatabaseCreator.products_price3]);
    this.stock = double.parse(json[DatabaseCreator.products_stock]);
    this.box = json[DatabaseCreator.products_box];
  }
}
