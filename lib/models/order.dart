import 'package:delivery_f/models/product.dart';
import 'package:delivery_f/services/database_creator.dart';

import 'client.dart';

class Order {
  int id;
  Client client = Client();
  DateTime orderDate, paymentDate;
  double paid = 0;
  List<Product> products = [];
  int pricing = 1;
  double get rest {
    return total - paid;
  }

  double count;

  Order({
    this.id,
    this.client,
    this.products,
    this.paid: 0,
    this.orderDate,
    this.paymentDate,
    this.pricing,
  });
  double get total {
    double sum = 0;
    double q = 0;

    for (Product p in products) {
      p.pricing = pricing;
      sum += p.total;
      q += p.quantity;
    }

    count = q;
    return sum;
  }

  Order.fromJson(Map<String, dynamic> json) {
    this.id = json[DatabaseCreator.orders_id];
    this.paid = double.parse(json[DatabaseCreator.orders_paid]);
    this.orderDate = DateTime.fromMillisecondsSinceEpoch(
        json[DatabaseCreator.orders_orderDate]);
    this.paymentDate = DateTime.fromMillisecondsSinceEpoch(
        json[DatabaseCreator.orders_paymentDate]);
    this.pricing = json[DatabaseCreator.orders_pricing];
  }
  insertProduct(Product p) {
    int i = products.indexWhere((e) => e.id == p.id);
    if (i == -1) {
      p.quantity = 1;
      products.add(p);
    } else {
      products[i].quantity++;
    }
  }
}
