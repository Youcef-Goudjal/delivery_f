import 'package:delivery_f/services/database_creator.dart';

class Supplier {
  int id;
  String fullname;
  int phone;
  double credits;

  Supplier({
    this.id,
    this.fullname,
    this.phone,
    this.credits,
  });

  Supplier.fromJson(Map<String, dynamic> json) {
    this.id = json[DatabaseCreator.suppliers_id];
    this.fullname = json[DatabaseCreator.suppliers_fullName];
    this.phone = int.parse(json[DatabaseCreator.suppliers_phone]);
    this.credits = double.parse(json[DatabaseCreator.suppliers_credit]);
  }
}
