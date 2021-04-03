import 'package:delivery_f/models/orderDetail.dart';
import 'package:delivery_f/models/product.dart';

import '../database_creator.dart';

class RepositoryServiceFactureDetail {
  static Future<List<Product>> getAllProductsOfFacture(int id) async {
    final sql =
        '''SELECT * From ${DatabaseCreator.factDetail_tbl}, ${DatabaseCreator.products_tbl} 
    WHERE ${DatabaseCreator.factDetail_tbl}.${DatabaseCreator.factDetail_productID}
           =    ${DatabaseCreator.products_tbl}.${DatabaseCreator.products_id} 
        AND ${DatabaseCreator.factDetail_tbl}.${DatabaseCreator.factDetail_productID} = $id ''';
    final data = await db.rawQuery(sql);
    List<Product> products = List();
    for (final node in data) {
      final product = Product.fromJson(node);

      product.id = node[DatabaseCreator.factDetail_productID];
      product.quantity =
          double.parse(node[DatabaseCreator.factDetail_quantity]);
      products.add(product);
    }
    return products;
  }

  // add product to stock
  static Future<int> addProduct(OrderDetail orderDetail) async {
    final sql = '''INSERT INTO ${DatabaseCreator.factDetail_tbl}
    (
      ${DatabaseCreator.factDetail_factID},
      ${DatabaseCreator.factDetail_productID},
      ${DatabaseCreator.factDetail_quantity}
    )
    VALUES (?,?,?)''';
    List<dynamic> params = [
      orderDetail.orderid,
      orderDetail.productid,
      orderDetail.quantity,
    ];
    final result = await db.rawInsert(sql, params);
    DatabaseCreator.databaseLog(
        'Add product to factDetail tbl', sql, null, result, params);
    return result;
  }

  // updating product
  static Future<int> updateProduct(OrderDetail orderDetail) async {
    final sql = '''UPDATE ${DatabaseCreator.factDetail_tbl}
      SET ${DatabaseCreator.factDetail_quantity}   = ? 
      WHERE     ${DatabaseCreator.factDetail_factID}      = ? 
            AND ${DatabaseCreator.factDetail_productID}  = ?
    
    ''';
    List<dynamic> params = [
      orderDetail.quantity,
      orderDetail.orderid,
      orderDetail.productid,
    ];

    final result = await db.rawUpdate(sql, params);

    DatabaseCreator.databaseLog(
        'Update product in fact Detail tbl', sql, null, result, params);
    return result;
  }

  // deleting product
  static Future<int> deleteProductfromFactDeatil(int id) async {
    final sql = '''DELETE FROM ${DatabaseCreator.factDetail_tbl}
    WHERE ${DatabaseCreator.factDetail_id} = ?
    ''';
    List<dynamic> params = [id];
    final result = await db.rawDelete(sql, params);
    DatabaseCreator.databaseLog(
        'Delete fact Detail row', sql, null, result, params);
    return result;
  }
}
