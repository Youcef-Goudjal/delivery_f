import 'package:delivery_f/models/product.dart';
import 'package:delivery_f/services/databaseHelpers/repository_service_products.dart';
import 'package:delivery_f/widgets/loading.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class ProductsPage extends StatefulWidget {
  @override
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  List<Product> products = [];
  int pricing = 1;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset("assets/img/boxes.png"),
            SizedBox(
              width: 20,
            ),
            Text(
              translator.translate("product_1"),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              child: TypeAheadField(
                  textFieldConfiguration: TextFieldConfiguration(
                    decoration: InputDecoration(
                        labelText: translator.translate("product_2"),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        suffix: IconButton(
                          onPressed: () async {
                            String barcode =
                                await FlutterBarcodeScanner.scanBarcode(
                              "#000000",
                              translator.translate("product_3"),
                              true,
                              ScanMode.BARCODE,
                            );
                            print(barcode);
                          },
                          padding: EdgeInsets.all(0),
                          icon: Icon(Icons.qr_code),
                        )),
                  ),
                  suggestionsCallback: (input) async {
                    // TODO suggestion search for products
                    return await RepositoryServiceProducts.search(input);
                  },
                  itemBuilder: (_, Product suggestion) {
                    return ListTile(
                      title: Text(suggestion.name),
                    );
                  },
                  onSuggestionSelected: (Product suggestion) {
                    showDialog(
                      context: context,
                      builder: (ctx) => Dialog(
                          child: EditProduct(
                        update: true,
                        product: suggestion,
                      )),
                    );
                  }),
            ),
            Card(
              elevation: 5,
              margin: EdgeInsets.all(8),
              child: Container(
                height: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      flex: 5,
                      child: Text(translator.translate("product_4")),
                    ),
                    Expanded(
                      child: Text(translator.translate("product_5")),
                    ),
                    Expanded(
                      child: Text(translator.translate("product_6")),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: FutureBuilder(
                future: RepositoryServiceProducts.getAllProducts(),
                builder: (context, AsyncSnapshot<List<Product>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasData) {
                      products = snapshot.data;
                      return AnimationLimiter(
                        child: ListView.builder(
                          itemCount: products.length + 1,
                          itemBuilder: (BuildContext context, int index) {
                            if (products.length == 0) {
                              return Image.asset("assets/img/out-of-stock.png");
                            }
                            if (index == products.length)
                              return Container(
                                height: 50,
                              );
                            final product = products[index];
                            return AnimationConfiguration.staggeredList(
                              position: index,
                              duration: const Duration(milliseconds: 375),
                              child: SlideAnimation(
                                verticalOffset: 50.0,
                                child: FadeInAnimation(
                                  child: InkWell(
                                    onTap: () {
                                      //todo update product
                                      showDialog(
                                        context: context,
                                        builder: (ctx) => Dialog(
                                            child: EditProduct(
                                          update: true,
                                          product: product,
                                        )),
                                      );
                                    },
                                    onLongPress: () async {
                                      await showDialog<String>(
                                        context: context,
                                        builder: (BuildContext context) =>
                                            AlertDialog(
                                          title: Text(translator
                                              .translate("product_7")),
                                          content: Text(
                                            "${product.name}" +
                                                translator
                                                    .translate("product_8"),
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Fluttertoast.showToast(
                                                  msg: translator
                                                      .translate("product_9"),
                                                  backgroundColor: Colors.red,
                                                );
                                                Navigator.pop(
                                                    context, 'Cancel');
                                              },
                                              child: Text(translator
                                                  .translate("product_10")),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                RepositoryServiceProducts
                                                        .deleteProduct(product)
                                                    .then((value) {
                                                  Fluttertoast.showToast(
                                                    msg: translator.translate(
                                                        "product_11"),
                                                    backgroundColor:
                                                        Colors.green,
                                                  );
                                                }).catchError((e) {
                                                  Fluttertoast.showToast(
                                                    msg: translator.translate(
                                                        "product_12"),
                                                    backgroundColor: Colors.red,
                                                  );
                                                });
                                                Navigator.pop(context, 'OK');
                                              },
                                              child: Text(translator
                                                  .translate("product_13")),
                                            ),
                                          ],
                                        ),
                                      );
                                      setState(() {});
                                    },
                                    child: Card(
                                      elevation: 5,
                                      margin: EdgeInsets.all(8),
                                      child: Container(
                                        height: 50,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Expanded(
                                              flex: 5,
                                              child: Text(product.name),
                                            ),
                                            Expanded(
                                              child: Text(
                                                  product.price().toString()),
                                            ),
                                            Expanded(
                                              child: Text(
                                                  product.stock.toString()),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }
                    return Image.asset("assets/img/out-of-stock.png");
                  }
                  return Loading();
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (ctx) => Dialog(child: EditProduct()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

// ignore: must_be_immutable
class EditProduct extends StatelessWidget {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  final bool update;
  Product product;

  EditProduct({
    this.update: false,
    this.product,
  });
  final name = TextEditingController();
  final barcode = TextEditingController();
  final quantity = TextEditingController();
  final price = TextEditingController();
  final price0 = TextEditingController();
  final price2 = TextEditingController();
  final price3 = TextEditingController();
  final box = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (update) {
      name.text = product.name;
      barcode.text = product.barcode;
      quantity.text = "${product?.stock}";
      price.text = "${product?.price1}";
      price0.text = "${product?.price0}";
      price2.text = "${product?.price2}";
      price3.text = "${product?.price3}";
      box.text = "${product?.box}";
    }
    return Container(
      padding: EdgeInsets.all(16),
      //height: 300,
      child: SingleChildScrollView(
        child: Form(
          key: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: name,
                validator: (input) =>
                    input == "" ? translator.translate("product_14") : null,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: translator.translate("product_15"),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () async {
                      await FlutterBarcodeScanner.scanBarcode(
                        "#000000",
                        translator.translate("product_16"),
                        true,
                        ScanMode.BARCODE,
                      ).then((value) {
                        if (value != '-1') {
                          barcode.text = value;
                        } else {
                          Fluttertoast.showToast(
                            msg: translator.translate("product_17"),
                            backgroundColor: Colors.red,
                          );
                        }
                      });
                    },
                    padding: EdgeInsets.all(0),
                    icon: Icon(Icons.qr_code),
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: barcode,
                      validator: (input) => input == ""
                          ? translator.translate("product_14")
                          : null,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: translator.translate("product_18"),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              TextFormField(
                controller: price0,
                keyboardType: TextInputType.number,
                validator: (input) =>
                    input == "" ? translator.translate("product_14") : null,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: translator.translate("product_19"),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              TextFormField(
                controller: quantity,
                keyboardType: TextInputType.number,
                validator: (input) =>
                    input == "" ? translator.translate("product_14") : null,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: translator.translate("product_20"),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: price,
                      keyboardType: TextInputType.number,
                      validator: (input) => input == ""
                          ? translator.translate("product_14")
                          : null,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: translator.translate("product_21"),
                      ),
                      onEditingComplete: () {
                        price2.text = price.text;
                        price3.text = price.text;
                      },
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: price2,
                      keyboardType: TextInputType.number,
                      validator: (input) => input == ""
                          ? translator.translate("product_14")
                          : null,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: translator.translate("product_22"),
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: price3,
                      keyboardType: TextInputType.number,
                      validator: (input) => input == ""
                          ? translator.translate("product_14")
                          : null,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: translator.translate("product_23"),
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 5,
              ),
              TextFormField(
                controller: box,
                keyboardType: TextInputType.number,
                validator: (input) =>
                    input == "" ? translator.translate("product_14") : null,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: translator.translate("product_24"),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              ListTile(
                onTap: () async {
                  if (_form.currentState.validate()) {
                    product = Product(
                      id: (product != null) ? product.id : null,
                      name: name.text,
                      barcode: barcode.text,
                      stock: double.parse(quantity.text),
                      price0: double.parse(price0.text),
                      price1: double.parse(price.text),
                      price2: double.parse(price2.text),
                      price3: double.parse(price3.text),
                      box: int.parse(box.text),
                    );
                    if (update) {
                      print('update product ${product.id}');
                      await RepositoryServiceProducts.updateProduct(product)
                          .then((value) {
                        Fluttertoast.showToast(
                            msg: translator.translate("product_25"),
                            backgroundColor: Colors.green);
                      }).catchError((e) {
                        Fluttertoast.showToast(
                            msg: translator.translate("product_26"),
                            backgroundColor: Colors.red);
                      });
                    } else {
                      print("insert product");

                      await RepositoryServiceProducts.addProduct(product)
                          .then((value) {
                        if (value != 0) {
                          Fluttertoast.showToast(
                              msg: translator.translate("product_27"),
                              backgroundColor: Colors.green);
                        } else {
                          Fluttertoast.showToast(
                              msg: translator.translate("product_28"),
                              backgroundColor: Colors.red);
                        }
                      }).catchError((e) {
                        Fluttertoast.showToast(
                            msg: translator.translate("product_29"),
                            backgroundColor: Colors.red);
                      });
                    }
                    Navigator.of(context).pop();
                  }
                },
                title: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.save),
                      SizedBox(
                        width: 10,
                      ),
                      Text(translator.translate("product_30")),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
