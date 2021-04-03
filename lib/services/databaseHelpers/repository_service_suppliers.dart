import 'package:delivery_f/models/facture.dart';
import 'package:delivery_f/models/supplier.dart';
import 'package:delivery_f/services/databaseHelpers/repository_service_factures.dart';

import '../database_creator.dart';

class RepositoryServiceSuppliers {
  //get All Suppliers
  static Future<List<Supplier>> getAllSuppliers() async {
    final sql = '''SELECT * FROM ${DatabaseCreator.suppliers_tbl}
    WHERE 1 ''';
    final data = await db.rawQuery(sql);
    List<Supplier> suppliers = List();
    for (final node in data) {
      final supplier = Supplier.fromJson(node);
      suppliers.add(supplier);
    }
    return suppliers;
  }

  // add new Client
  static Future<int> addSupplier(Supplier supplier) async {
    final sql = '''INSERT INTO ${DatabaseCreator.suppliers_tbl}
    (
      ${DatabaseCreator.suppliers_fullName},
      ${DatabaseCreator.suppliers_phone},
      ${DatabaseCreator.suppliers_credit}
    )
    VALUES (?,?,?)''';
    List<dynamic> params = [
      supplier.fullname,
      supplier.phone.toString(),
      supplier.credits.toString(),
    ];
    final result = await db.rawInsert(sql, params);
    DatabaseCreator.databaseLog('Add supplier', sql, null, result, params);
    return result;
  }

  // updating client
  static Future<int> updateSupplier(Supplier supplier) async {
    final sql = '''UPDATE ${DatabaseCreator.suppliers_tbl}
      SET ${DatabaseCreator.suppliers_fullName}  = ? ,
          ${DatabaseCreator.suppliers_phone}     = ? ,
          ${DatabaseCreator.suppliers_credit}    = ? 
      WHERE  ${DatabaseCreator.suppliers_id}     = ?
    
    ''';
    List<dynamic> params = [
      supplier.fullname,
      supplier.phone.toString(),
      supplier.credits.toString(),
      supplier.id,
    ];

    final result = await db.rawUpdate(sql, params);

    DatabaseCreator.databaseLog('Update supplier', sql, null, result, params);
    return result;
  }

  // updating client
  static Future<int> updateSupplierCredit(Supplier supplier) async {
    final sql = '''UPDATE ${DatabaseCreator.suppliers_tbl}
      SET 
          ${DatabaseCreator.suppliers_credit}    = ? 
      WHERE  ${DatabaseCreator.suppliers_id}     = ?
    
    ''';
    List<dynamic> params = [
      supplier.credits.toString(),
      supplier.id,
    ];

    final result = await db.rawUpdate(sql, params);

    DatabaseCreator.databaseLog('Update supplier', sql, null, result, params);
    return result;
  }

  // search for clients
  static Future<List<Supplier>> search(String input) async {
    String phone = (input != "") ? input.substring(1) : "";
    print(phone);

    final sql = '''SELECT * FROM ${DatabaseCreator.suppliers_tbl}
    WHERE   ${DatabaseCreator.suppliers_fullName} LIKE '%$input%' 
         OR ${DatabaseCreator.suppliers_phone} LIKE '%$phone%'  ''';
    final data = await db.rawQuery(sql);
    List<Supplier> suppliers = [];

    for (final node in data) {
      final supplier = Supplier.fromJson(node);
      suppliers.add(supplier);
    }

    return suppliers;
  }

  // updating supplier credits
  Future updateCredits(Supplier supplier, double val) async {
    List<Facture> factures =
        await RepositoryServiceFactures.getAllFactureofSupplier(supplier);
    if (supplier.credits >= val) {
      supplier.credits -= val;
      double v = val;
      for (final facture in factures) {
        if (facture.rest <= v) {
          v -= facture.rest;
          facture.paid = facture.rest;
        }
      }
    }
  }
}
