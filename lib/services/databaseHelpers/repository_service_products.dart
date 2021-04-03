import 'package:delivery_f/models/product.dart';

import '../database_creator.dart';

class RepositoryServiceProducts {
  //get All Products
  static Future<List<Product>> getAllProducts() async {
    final sql = '''SELECT * FROM ${DatabaseCreator.products_tbl}
    WHERE 1 ''';
    final data = await db.rawQuery(sql);
    List<Product> products = List();
    //print(data.first.keys);
    for (final node in data) {
      final product = Product.fromJson(node);
      products.add(product);
    }
    return products;
  }

  // add product to stock
  static Future<int> addProduct(Product product) async {
    final sql = '''INSERT INTO ${DatabaseCreator.products_tbl}
    (
      ${DatabaseCreator.products_name},
      ${DatabaseCreator.products_barcode},
      ${DatabaseCreator.products_stock},
      ${DatabaseCreator.products_price0},
      ${DatabaseCreator.products_price},
      ${DatabaseCreator.products_price2},
      ${DatabaseCreator.products_price3},
      ${DatabaseCreator.products_box}
    )
    VALUES (?,?,?,?,?,?,?,?)''';
    List<dynamic> params = [
      product.name,
      product.barcode,
      product.stock ?? 0,
      product.price0.toString() ?? "0",
      product.price1.toString() ?? "0",
      product.price2.toString() ?? "0",
      product.price3.toString() ?? "0",
      product.box ?? 1,
    ];
    final result = await db.rawInsert(sql, params);
    DatabaseCreator.databaseLog('Add product', sql, null, result, params);
    return result;
  }

  // updating product
  static Future<int> updateProduct(Product product) async {
    final sql = '''UPDATE ${DatabaseCreator.products_tbl}
      SET ${DatabaseCreator.products_name}   = ? ,
          ${DatabaseCreator.products_barcode}= ? ,
          ${DatabaseCreator.products_stock}  = ? ,
          ${DatabaseCreator.products_price0}  = ? ,
          ${DatabaseCreator.products_price}  = ? ,
          ${DatabaseCreator.products_price2} = ? ,
          ${DatabaseCreator.products_price3} = ? ,
          ${DatabaseCreator.products_box}    = ? 
      WHERE  ${DatabaseCreator.products_id}  = ?
    
    ''';
    List<dynamic> params = [
      product.name,
      product.barcode,
      product.stock ?? 0,
      product.price0.toString() ?? "0",
      product.price1.toString() ?? "0",
      product.price2.toString() ?? "0",
      product.price3.toString() ?? "0",
      product.box ?? 1,
      product.id,
    ];
    final result = await db.rawUpdate(sql, params);

    DatabaseCreator.databaseLog('Update product', sql, null, result, params);
    return result;
  }

  // update stock
  static Future<int> updateStock(Product product) async {
    final sql = '''UPDATE ${DatabaseCreator.products_tbl}
      SET ${DatabaseCreator.products_stock}   = ? 
      WHERE  ${DatabaseCreator.products_id}  = ?
    ''';
    List<dynamic> params = [
      product.stock ?? 0,
      product.id,
    ];
    final result = await db.rawUpdate(sql, params);

    DatabaseCreator.databaseLog(
        'Update stock of a product', sql, null, result, params);
    return result;
  }

  // update a list of product
  static Future<void> updateAllStockProduct(List<Product> products) {
    for (final product in products) {
      updateStock(product);
    }
  }

  // deleting product
  static Future<int> deleteProduct(Product product) async {
    print(product.id);
    final sql = '''DELETE FROM ${DatabaseCreator.products_tbl}
    WHERE ${DatabaseCreator.products_id} = ?
    ''';
    List<dynamic> params = [product.id];
    final result = await db.rawDelete(sql, params);
    DatabaseCreator.databaseLog('Delete product', sql, null, result, params);
    return result;
  }

  // search for products
  static Future<List<Product>> search(String input) async {
    final sql = '''SELECT * FROM ${DatabaseCreator.products_tbl}
    WHERE ${DatabaseCreator.products_name} LIKE '%$input%' OR ${DatabaseCreator.products_barcode} LIKE '%$input%'  ''';
    final data = await db.rawQuery(sql);
    List<Product> products = [];

    for (final node in data) {
      final product = Product.fromJson(node);
      products.add(product);
    }

    return products;
  }

  // get most frequent product
  static Future<List<Product>> getMostproducts() async {
    final sql =
        '''SELECT * , COUNT(${DatabaseCreator.orderDetail_productID}) AS MOST_FREQUENT
                   FROM ${DatabaseCreator.orderDetail_tbl} , ${DatabaseCreator.products_tbl} 
                   ON ${DatabaseCreator.orderDetail_tbl}.${DatabaseCreator.orderDetail_productID} = ${DatabaseCreator.products_tbl}.${DatabaseCreator.products_id}
                   GROUP BY ${DatabaseCreator.orderDetail_productID}
                   ORDER BY MOST_FREQUENT DESC
                   LIMIT 10
                     ''';
    final data = await db.rawQuery(sql);
    List<Product> products = List();
    for (final node in data) {
      final product = Product.fromJson(node);
      products.add(product);
    }
    return products;
  }
}
