import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

Database db;

class DatabaseCreator {
  // tables
  static const dbtbl = [
    client_tbl,
    orders_tbl,
    products_tbl,
    orderDetail_tbl,
    suppliers_tbl,
    fact_tbl,
    factDetail_tbl,
  ];
  // client table
  static const client_tbl = "clients";
  static const client_id = "id";
  static const client_fullName = "fullName";
  static const client_phone = "phone";
  static const client_credit = "credit";

  // orders table
  static const orders_tbl = "orders";
  static const orders_id = "id";
  static const orders_clientID = "customerID";
  static const orders_orderDate = "orderDate";
  static const orders_paid = "paid";
  static const orders_paymentDate = "paymentDate";
  static const orders_pricing = "pricing";
  static const orders_isDeleted = "isDeleted";

  // products table
  static const products_tbl = "products";
  static const products_id = "id";
  static const products_name = "name";
  static const products_price0 = "price0";
  static const products_price = "price";
  static const products_price2 = "price2";
  static const products_price3 = "price3";
  static const products_barcode = "barcode";
  static const products_stock = "stock";
  static const products_box = "box";

  // OrderDetail table columns
  static const orderDetail_tbl = 'orderDetail';
  static const orderDetail_id = 'id';
  static const orderDetail_orderID = 'orderID';
  static const orderDetail_productID = 'productID';
  static const orderDetail_quantity = 'quantity';

  // FactDetail table columns
  static const factDetail_tbl = 'factDetail';
  static const factDetail_id = 'id';
  static const factDetail_factID = 'factID';
  static const factDetail_productID = 'productID';
  static const factDetail_quantity = 'quantity';

  // facture table
  static const fact_tbl = "facts";
  static const fact_id = "id";
  static const fact_supplierID = "supplierID";
  static const fact_orderDate = "factDate";
  static const fact_paid = "paid";
  static const fact_paymentDate = "paymentDate";
  static const fact_isDeleted = "isDeleted";

  // suppliers table
  static const suppliers_tbl = "suppliers";
  static const suppliers_id = "id";
  static const suppliers_fullName = "fullName";
  static const suppliers_phone = "phone";
  static const suppliers_credit = "credit";

  static void databaseLog(String functionName, String sql,
      [List<Map<String, dynamic>> selectQueryResult,
      int insertAndUpdateQueryResult,
      List<dynamic> params]) {
    print(functionName);
    print(sql);
    if (params != null) {
      print(params);
    }
    if (selectQueryResult != null) {
      print(selectQueryResult);
    } else if (insertAndUpdateQueryResult != null) {
      print(insertAndUpdateQueryResult);
    }
  }

  static Future<String> getDatabasePath(String dbName) async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, dbName);

    //make sure the folder exists
    if (await Directory(dirname(path)).exists()) {
      //await deleteDatabase(path);
    } else {
      await Directory(dirname(path)).create(recursive: true);
    }
    return path;
  }

  Future<void> initDatabase() async {
    final path = await getDatabasePath('delivery_db');
    db = await openDatabase(path, version: 1, onCreate: onCreate);
    print("init Database :" + db.toString());
  }

  Future<void> onCreate(Database db, int version) async {
    await createClientTbl(db);
    await createOrdersTable(db);
    await createProductsTable(db);
    await createOrdersDetailTable(db);
    await createSupplierTbl(db);
    await createfactursTable(db);
    await createFactsDetailTable(db);
  }

  Future<void> createClientTbl(Database db) async {
    final customerSql = '''CREATE TABLE $client_tbl
    (
      $client_id INTEGER PRIMARY KEY,
      $client_fullName TEXT,
      $client_phone TEXT UNIQUE,
      $client_credit TEXT
    )''';

    await db.execute(customerSql);
  }

  Future<void> createSupplierTbl(Database db) async {
    final customerSql = '''CREATE TABLE $suppliers_tbl
    (
      $suppliers_id INTEGER PRIMARY KEY,
      $suppliers_fullName TEXT,
      $suppliers_phone TEXT UNIQUE,
      $suppliers_credit TEXT
    )''';

    await db.execute(customerSql);
  }

  Future<void> createOrdersTable(Database db) async {
    final ordersSql = '''CREATE TABLE $orders_tbl
    (
      $orders_id INTEGER PRIMARY KEY,
      $orders_clientID INTEGER,
      $orders_orderDate INTEGER,
      $orders_paid TEXT,
      $orders_paymentDate INTEGER,
      $orders_pricing INTEGER,
      $orders_isDeleted BIT NOT NULL,
      FOREIGN KEY ($orders_clientID) 
      REFERENCES $client_tbl ($client_id) 
         ON DELETE CASCADE 
         ON UPDATE CASCADE
    )''';

    await db.execute(ordersSql);
  }

  Future<void> createfactursTable(Database db) async {
    final ordersSql = '''CREATE TABLE $fact_tbl
    (
      $fact_id INTEGER PRIMARY KEY,
      $fact_supplierID INTEGER,
      $fact_orderDate INTEGER,
      $fact_paid TEXT,
      $fact_paymentDate INTEGER,
      $fact_isDeleted BIT NOT NULL,
      FOREIGN KEY ($fact_supplierID) 
      REFERENCES $suppliers_tbl ($suppliers_id) 
         ON DELETE CASCADE 
         ON UPDATE CASCADE
    )''';

    await db.execute(ordersSql);
  }

  Future<void> createProductsTable(Database db) async {
    final productSql = '''CREATE TABLE $products_tbl
    (
      $products_id INTEGER PRIMARY KEY,
      $products_name TEXT,
      $products_price0 TEXT,
      $products_price TEXT,
      $products_price2 TEXT,
      $products_price3 TEXT,
      $products_box INTEGER,
      $products_stock TEXT,
      $products_barcode TEXT UNIQUE
    )''';

    await db.execute(productSql);
  }

  Future<void> createOrdersDetailTable(Database db) async {
    final ordersDetailSql = '''CREATE TABLE $orderDetail_tbl
    (
      $orderDetail_id INTEGER ,
      $orderDetail_orderID INTEGER,
      $orderDetail_productID INTEGER,
      $orderDetail_quantity TEXT,
      FOREIGN KEY ($orderDetail_orderID) 
      REFERENCES $orders_tbl ($orders_id) 
         ON DELETE CASCADE          
         ON UPDATE CASCADE,
      FOREIGN KEY ($orderDetail_productID) 
      REFERENCES $products_tbl ($products_id)
         ON DELETE CASCADE          
         ON UPDATE CASCADE,
      PRIMARY KEY( $orderDetail_orderID , $orderDetail_productID)
    )''';

    await db.execute(ordersDetailSql);
  }

  Future<void> createFactsDetailTable(Database db) async {
    final ordersDetailSql = '''CREATE TABLE $factDetail_tbl
    (
      $factDetail_id INTEGER ,
      $factDetail_factID INTEGER,
      $factDetail_productID INTEGER,
      $factDetail_quantity TEXT,
      FOREIGN KEY ($factDetail_factID) 
      REFERENCES $fact_tbl ($fact_id) 
         ON DELETE CASCADE          
         ON UPDATE CASCADE,
      FOREIGN KEY ($factDetail_productID) 
      REFERENCES $products_tbl ($products_id)
         ON DELETE CASCADE          
         ON UPDATE CASCADE,
      PRIMARY KEY( $factDetail_factID , $factDetail_productID)
    )''';

    await db.execute(ordersDetailSql);
  }
}
