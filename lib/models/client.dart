import 'package:delivery_f/services/database_creator.dart';

class Client {
  int id;
  String fullname;
  int phone;
  double credits;

  Client({
    this.id,
    this.fullname,
    this.phone,
    this.credits,
  });

  Client.fromJson(Map<String, dynamic> json) {
    this.id = json[DatabaseCreator.client_id];
    this.fullname = json[DatabaseCreator.client_fullName];
    this.phone = int.parse(json[DatabaseCreator.client_phone]);
    this.credits = double.parse(json[DatabaseCreator.client_credit]);
  }
}
