import 'package:delivery_f/models/facture.dart';
import 'package:delivery_f/models/orderDetail.dart';
import 'package:delivery_f/models/supplier.dart';
import 'package:delivery_f/services/databaseHelpers/repository_service_factureDetail.dart';
import 'package:delivery_f/services/databaseHelpers/repository_service_products.dart';
import 'package:flutter/material.dart';

import '../database_creator.dart';

class RepositoryServiceFactures {
  // get All orders of this client
  static Future<List<Facture>> getAllFactureofSupplier(
      Supplier supplier) async {
    final sql = '''SELECT * FROM ${DatabaseCreator.fact_tbl}
    WHERE ${DatabaseCreator.fact_supplierID} = ?  ''';
    List<dynamic> params = [
      supplier.id,
    ];
    final data = await db.rawQuery(sql, params);
    List<Facture> factures = List();
    for (final node in data) {
      final facture = Facture.fromJson(node);
      facture.supplier = supplier;
      // here add products of this order from fact Detail tbl
      facture.products =
          await RepositoryServiceFactureDetail.getAllProductsOfFacture(
              facture.id);
      factures.add(facture);
    }
    return factures;
  }

  // insert Order
  static Future<int> addFacture(Facture facture) async {
    final sql = '''INSERT INTO ${DatabaseCreator.fact_tbl}
    (
      ${DatabaseCreator.fact_supplierID},
      ${DatabaseCreator.fact_paid},
      ${DatabaseCreator.fact_orderDate},
      ${DatabaseCreator.fact_paymentDate},
      ${DatabaseCreator.orders_isDeleted}
    )
    VALUES (?,?,?,?,0)''';
    List<dynamic> params = [
      facture.supplier.id,
      facture.paid,
      facture.orderDate.millisecondsSinceEpoch,
      facture.paymentDate.millisecondsSinceEpoch,
    ];
    final result = await db.rawInsert(sql, params);
    facture.id = result;
    for (final product in facture.products) {
      product.stock = product.stock + product.quantity;
      await RepositoryServiceProducts.updateProduct(product);
      final orderDetail = OrderDetail(
        orderid: facture.id,
        productid: product.id,
        quantity: product.quantity,
      );
      await RepositoryServiceFactureDetail.addProduct(orderDetail);
    }
    await RepositoryServiceProducts.updateAllStockProduct(facture.products);
    DatabaseCreator.databaseLog('Add facture', sql, null, result, params);
    return result;
  }

  // update Order
  static Future<int> updateFacture(Facture facture) async {
    final sql = '''UPDATE ${DatabaseCreator.fact_tbl}
      SET ${DatabaseCreator.fact_paid}   = ? ,
          ${DatabaseCreator.fact_paymentDate}= ? 
      WHERE  ${DatabaseCreator.fact_id}  = ?
    
    ''';
    List<dynamic> params = [
      facture.paid,
      facture.paymentDate.millisecondsSinceEpoch,
      facture.id,
    ];

    final result = await db.rawUpdate(sql, params);

    DatabaseCreator.databaseLog('Update facture', sql, null, result, params);
    return result;
  }

  // update all facture of one Supplier
  static Future updateFactureOfSupplier(
      List<Facture> orders, double val) async {
    if (orders.length > 0) {
      final client = orders.first.supplier;
      if (val <= client.credits) {
        for (final facture in orders) {
          if (val == 0) break;
          if (val >= facture.rest) {
            val -= facture.rest;
            facture.paid += facture.rest;
          } else {
            facture.paid += val;
            val = 0;
          }

          updateFacture(facture);
        }
      }
    }
  }

  // get facture By date time range
  static Future<List<Facture>> getAllFactureofDateRange(
      {Supplier supplier, DateTimeRange range}) async {
    final sql = '''SELECT * FROM ${DatabaseCreator.fact_tbl}
    WHERE ${DatabaseCreator.fact_supplierID} = ? 
          AND ( ${DatabaseCreator.fact_orderDate} > ?
          AND ${DatabaseCreator.fact_orderDate} < ? ) 
          OR  ( ${DatabaseCreator.fact_paymentDate} > ?
          AND ${DatabaseCreator.fact_paymentDate} < ? )  ''';
    List<dynamic> params = [
      supplier.id,
      range.start.millisecondsSinceEpoch,
      range.end.millisecondsSinceEpoch,
      range.start.millisecondsSinceEpoch,
      range.end.millisecondsSinceEpoch,
    ];
    final data = await db.rawQuery(sql, params);
    List<Facture> factures = List();
    for (final node in data) {
      final facture = Facture.fromJson(node);
      facture.supplier = supplier;
      // here add products of this order from order Detail tbl
      facture.products =
          await RepositoryServiceFactureDetail.getAllProductsOfFacture(
              facture.id);
      factures.add(facture);
    }
    return factures;
  }
}
