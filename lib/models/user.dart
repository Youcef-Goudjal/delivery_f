import 'package:flutter/foundation.dart';

class User {
  final String uid;
  final String email;
  String phone, address, companyname, logo;

  User({
    @required this.uid,
    @required this.email,
    this.phone,
    this.address,
    this.companyname,
    this.logo,
  });
}
