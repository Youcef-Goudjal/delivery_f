import 'package:delivery_f/models/orderDetail.dart';
import 'package:delivery_f/models/product.dart';

import '../database_creator.dart';

class RepositoryServiceOrderDetail {
  static Future<List<Product>> getAllProductsOfOrder(int id) async {
    final sql =
        '''SELECT * From ${DatabaseCreator.orderDetail_tbl}, ${DatabaseCreator.products_tbl} 
    WHERE ${DatabaseCreator.orderDetail_tbl}.${DatabaseCreator.orderDetail_productID}
           =    ${DatabaseCreator.products_tbl}.${DatabaseCreator.products_id} 
        AND ${DatabaseCreator.orderDetail_tbl}.${DatabaseCreator.orderDetail_orderID} = $id ''';
    final data = await db.rawQuery(sql);
    List<Product> products = List();
    for (final node in data) {
      final product = Product.fromJson(node);

      product.id = node[DatabaseCreator.orderDetail_productID];
      product.quantity =
          double.parse(node[DatabaseCreator.orderDetail_quantity]);
      products.add(product);
    }
    return products;
  }

  // add product to stock
  static Future<int> addProduct(OrderDetail orderDetail) async {
    final sql = '''INSERT INTO ${DatabaseCreator.orderDetail_tbl}
    (
      ${DatabaseCreator.orderDetail_orderID},
      ${DatabaseCreator.orderDetail_productID},
      ${DatabaseCreator.orderDetail_quantity}
    )
    VALUES (?,?,?)''';
    List<dynamic> params = [
      orderDetail.orderid,
      orderDetail.productid,
      orderDetail.quantity,
    ];
    final result = await db.rawInsert(sql, params);
    DatabaseCreator.databaseLog(
        'Add product to OrderDetail tbl', sql, null, result, params);
    return result;
  }

  // updating product
  static Future<int> updateProduct(OrderDetail orderDetail) async {
    final sql = '''UPDATE ${DatabaseCreator.orderDetail_tbl}
      SET ${DatabaseCreator.orderDetail_quantity}   = ? 
      WHERE  ${DatabaseCreator.orderDetail_orderID}  = ? AND ${DatabaseCreator.orderDetail_productID}  = ?
    
    ''';
    List<dynamic> params = [
      orderDetail.quantity,
      orderDetail.orderid,
      orderDetail.productid,
    ];

    final result = await db.rawUpdate(sql, params);

    DatabaseCreator.databaseLog(
        'Update product in Order Detail tbl', sql, null, result, params);
    return result;
  }

  // deleting products on order
  static Future<int> deleteProductsOfOrder(int id) async {
    final sql = '''DELETE FROM ${DatabaseCreator.orderDetail_tbl}
    WHERE ${DatabaseCreator.orderDetail_orderID} = ?
    ''';
    List<dynamic> params = [id];
    final result = await db.rawDelete(sql, params);
    DatabaseCreator.databaseLog('Delete product', sql, null, result, params);
    return result;
  }
}
