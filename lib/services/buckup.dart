import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_f/services/auth.dart';
import 'package:delivery_f/services/database_creator.dart';
import 'package:excel/excel.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class Backup {
  static create(AuthBase auth) async {
    Fluttertoast.showToast(
      msg: "start file uploaded",
      backgroundColor: Colors.green,
    );
    final tab = DatabaseCreator.dbtbl;
    var excel = Excel.createExcel();
    try {
      for (final tbl in tab) {
        Sheet sheet = excel['$tbl'];
        String sql = ''' SELECT * FROM $tbl ''';
        final data = await db.rawQuery(sql);
        if (data.isNotEmpty) {
          final keys = data.first.keys;
          sheet.insertRowIterables(keys.toList(), 0);
          int i = 1;
          for (final node in data) {
            sheet.insertRowIterables(node.values.toList(), i);
            i++;
          }
        }
      }
      final tmp = await getTemporaryDirectory();
      String path = join(tmp.path, "excel.xlsx");
      var file;
      await excel.encode().then((value) {
        file = File(path)
          ..createSync(recursive: true)
          ..writeAsBytesSync(value);
      });
      await FirebaseStorage.instance
          .ref(
              "${auth.currentUser.uid}-${DateTime.now().month}-${DateTime.now().day}.xlsx")
          .putFile(file);
      Fluttertoast.showToast(
        msg: "file uploaded",
        backgroundColor: Colors.green,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: "error while uploading file $e",
        backgroundColor: Colors.red,
      );
    }
  }

  static download(AuthBase auth, String val) async {
    final tabs = DatabaseCreator.dbtbl;
    final tmp = await getTemporaryDirectory();
    Fluttertoast.showToast(
      msg: "بدأ عملية التحميل",
      backgroundColor: Colors.green,
    );
    String path = "${tmp.path}/excel.xlsx";
    File downloadToFile = File(path);

    try {
      print("---------------${auth.currentUser.uid}-$val.xlsx");
      await FirebaseStorage.instance
          .ref("${auth.currentUser.uid}-$val.xlsx")
          .writeToFile(downloadToFile);
      Fluttertoast.showToast(
        msg: "تمت عملية التحميل بنجاح \n جاري إدخال المعلومات",
        backgroundColor: Colors.green,
      );
      var bytes = downloadToFile.readAsBytesSync();
      var excel = Excel.decodeBytes(bytes);
      final xc = 0;
      for (final tab in tabs) {
        final sheet = excel.tables[tab];
        //print(cols);
        int i = 0;

        if (sheet.maxRows > 1) {
          final cols = sheet.rows.first;
          for (var row in sheet.rows) {
            if (i == 0) {
              i++;
            } else {
              insert(cols, row, tab);
            }
          }
        }
      }
      downloadToFile.delete();
      await FirebaseFirestore.instance
          .collection("users")
          .doc(auth.currentUser.uid)
          .update({
        "enable": false,
      });
    } catch (e) {
      print(e);
      Fluttertoast.showToast(
        msg: "الملف غير موجود",
        backgroundColor: Colors.red,
      );
    }
  }

  static Future insert(List<dynamic> col, List<dynamic> row, String tab) async {
    String sql = '''INSERT INTO $tab  
    ${col.map((e) => e)}
    
    VALUES ${row.map((e) => "?")}
    ''';
    try {
      await db.rawInsert(sql, row);
    } catch (e) {
      Fluttertoast.showToast(
        msg: "تكرار في المعلومات",
        backgroundColor: Colors.red,
      );
    }
    print(sql);
  }
}
