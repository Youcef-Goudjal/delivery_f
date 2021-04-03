import 'package:delivery_f/models/product.dart';
import 'package:delivery_f/models/supplier.dart';
import 'package:delivery_f/services/database_creator.dart';

class Facture {
  int id;
  Supplier supplier = Supplier();
  DateTime orderDate, paymentDate;
  double paid = 0;
  List<Product> products = [];
  int pricing = 0;
  double get rest {
    return total - paid;
  }

  double count;

  Facture({
    this.id,
    this.supplier,
    this.products,
    this.paid: 0,
    this.orderDate,
    this.paymentDate,
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

  Facture.fromJson(Map<String, dynamic> json) {
    this.id = json[DatabaseCreator.fact_id];
    this.paid = double.parse(json[DatabaseCreator.fact_paid]);
    this.orderDate = DateTime.fromMillisecondsSinceEpoch(
        json[DatabaseCreator.fact_orderDate]);
    this.paymentDate = DateTime.fromMillisecondsSinceEpoch(
        json[DatabaseCreator.fact_paymentDate]);
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
