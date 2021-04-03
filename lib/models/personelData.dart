import 'package:delivery_f/services/localstorage.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image/image.dart';

class PersonelData with ChangeNotifier {
  String fullName;
  String CompanyName;
  String Phone;
  bool logo;
  Image image;
  String printerName;
  String imgAsString;

  PersonelData({
    String fullname,
    String company,
    String phone,
    bool logo,
    Image image,
    String printername,
  }) {
    this.fullName = fullName ?? "";
    this.CompanyName = company ?? "";
    this.Phone = phone ?? "";
    this.logo = logo ?? false;
    this.image = image;
    this.printerName = printername ?? "";
  }

  getLocalData() async {
    try {
      fullName = storage.getItem("fullName") ?? "";
      CompanyName = storage.getItem("company") ?? "";
      Phone = storage.getItem("phone") ?? "";
      printerName = storage.getItem("printer") ?? "";
      logo = storage.getItem("logo") ?? false;
      image = storage.getItem("image");
      imgAsString = storage.getItem("imageAsString");
      Fluttertoast.showToast(msg: "تم جلب المعلومات الشخصية بنجاح");
    } catch (e) {
      Fluttertoast.showToast(
        msg: "أنت تحتاج لتحديث المعلومات الشخصية $e",
        toastLength: Toast.LENGTH_LONG,
      );
    }
  }
}
