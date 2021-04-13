import 'package:delivery_f/models/client.dart';
import 'package:delivery_f/models/order.dart';
import 'package:delivery_f/models/orderDetail.dart';
import 'package:delivery_f/services/databaseHelpers/repository_service_orderDetail.dart';
import 'package:delivery_f/services/databaseHelpers/repository_service_products.dart';
import 'package:flutter/material.dart';

import '../database_creator.dart';

class RepositoryServiceOrders {
  // get All orders of this client
  static Future<List<Order>> getAllOrderofClient(Client client) async {
    final sql = '''SELECT * FROM ${DatabaseCreator.orders_tbl}
    WHERE ${DatabaseCreator.orders_clientID} = ?  ''';
    List<dynamic> params = [
      client.id,
    ];
    final data = await db.rawQuery(sql, params);
    List<Order> orders = List();
    for (final node in data) {
      final order = Order.fromJson(node);
      order.client = client;
      // here add products of this order from order Detail tbl
      order.products =
          await RepositoryServiceOrderDetail.getAllProductsOfOrder(order.id);
      orders.add(order);
    }
    return orders;
  }

  // insert Order
  static Future<int> addOrder(Order order) async {
    final sql = '''INSERT INTO ${DatabaseCreator.orders_tbl}
    (
      ${DatabaseCreator.orders_clientID},
      ${DatabaseCreator.orders_paid},
      ${DatabaseCreator.orders_orderDate},
      ${DatabaseCreator.orders_paymentDate},
      ${DatabaseCreator.orders_pricing},
      ${DatabaseCreator.orders_isDeleted}
    )
    VALUES (?,?,?,?,?,0)''';
    List<dynamic> params = [
      order.client.id,
      order.paid,
      order.orderDate.millisecondsSinceEpoch,
      order.paymentDate.millisecondsSinceEpoch,
      order.pricing,
    ];
    final result = await db.rawInsert(sql, params);
    order.id = result;
    for (final product in order.products) {
      product.stock = product.stock - product.quantity;
      final orderDetail = OrderDetail(
        orderid: order.id,
        productid: product.id,
        quantity: product.quantity,
      );
      await RepositoryServiceOrderDetail.addProduct(orderDetail);
    }
    await RepositoryServiceProducts.updateAllStockProduct(order.products);
    DatabaseCreator.databaseLog('Add order', sql, null, result, params);
    return result;
  }

  // update Order
  static Future<int> updateOrder(Order order) async {
    final sql = '''UPDATE ${DatabaseCreator.orders_tbl}
      SET ${DatabaseCreator.orders_paid}   = ? ,
          ${DatabaseCreator.orders_paymentDate}= ? 
      WHERE  ${DatabaseCreator.orders_id}  = ?
    
    ''';
    List<dynamic> params = [
      order.paid,
      order.paymentDate.millisecondsSinceEpoch,
      order.id,
    ];

    final result = await db.rawUpdate(sql, params);

    DatabaseCreator.databaseLog('Update Order', sql, null, result, params);
    return result;
  }

  static Future updateOrdersOfClient(List<Order> orders, double val) async {
    if (orders.length > 0) {
      final client = orders.first.client;
      if (val <= client.credits) {
        for (final order in orders) {
          if (val == 0) break;
          if (val >= order.rest) {
            val -= order.rest;
            order.paid += order.rest;
          } else {
            order.paid += val;
            val = 0;
          }

          updateOrder(order);
        }
      }
    }
  }

  // get Orders By date time range
  static Future<List<Order>> getAllOrderofDateRange(
      {Client client, DateTimeRange range}) async {
    final sql = '''SELECT * FROM ${DatabaseCreator.orders_tbl}
    WHERE ${DatabaseCreator.orders_clientID} = ? 
          AND ( ${DatabaseCreator.orders_orderDate} > ?
          AND ${DatabaseCreator.orders_orderDate} < ? ) 
          OR  ( ${DatabaseCreator.orders_paymentDate} > ?
          AND ${DatabaseCreator.orders_paymentDate} < ? )  ''';
    List<dynamic> params = [
      client.id,
      range.start.millisecondsSinceEpoch,
      range.end.millisecondsSinceEpoch,
      range.start.millisecondsSinceEpoch,
      range.end.millisecondsSinceEpoch,
    ];
    final data = await db.rawQuery(sql, params);
    List<Order> orders = List();
    for (final node in data) {
      final order = Order.fromJson(node);
      order.client = client;
      // here add products of this order from order Detail tbl
      order.products =
          await RepositoryServiceOrderDetail.getAllProductsOfOrder(order.id);
      orders.add(order);
    }
    return orders;
  }

  // update Order
  static Future updateOrderOfClient(Order oldOrder, Order newOrder) async {
    for (final product in oldOrder.products) {
      product.stock = product.quantity + product.stock;
    }
    await RepositoryServiceProducts.updateAllStockProduct(oldOrder.products);
    await RepositoryServiceOrderDetail.deleteProductsOfOrder(oldOrder.id);

    for (final product in newOrder.products) {
      product.stock = product.stock - product.quantity;
      final orderDetail = OrderDetail(
        orderid: newOrder.id,
        productid: product.id,
        quantity: product.quantity,
      );
      await RepositoryServiceOrderDetail.addProduct(orderDetail);
    }
    await RepositoryServiceProducts.updateAllStockProduct(newOrder.products);

    final sql = '''UPDATE ${DatabaseCreator.orders_tbl}
      SET ${DatabaseCreator.orders_paid}   = ? ,
          ${DatabaseCreator.orders_paymentDate}= ? ,
          ${DatabaseCreator.orders_pricing} = ?
      WHERE  ${DatabaseCreator.orders_id}  = ?
    
    ''';
    List<dynamic> params = [
      newOrder.paid,
      newOrder.paymentDate.millisecondsSinceEpoch,
      newOrder.pricing,
      newOrder.id,
    ];

    final result = await db.rawUpdate(sql, params);

    DatabaseCreator.databaseLog('Update Order', sql, null, result, params);
    return result;
  }
}
