import 'package:delivery_f/models/facture.dart';
import 'package:delivery_f/models/product.dart';
import 'package:delivery_f/models/supplier.dart';
import 'package:delivery_f/services/databaseHelpers/repository_service_factures.dart';
import 'package:delivery_f/services/databaseHelpers/repository_service_products.dart';
import 'package:delivery_f/services/databaseHelpers/repository_service_suppliers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class BuyPage extends StatefulWidget {
  @override
  _BuyPageState createState() => _BuyPageState();
}

class _BuyPageState extends State<BuyPage> {
  List<Product> suggestionproducts = List();
  Facture _facture = Facture(
    products: new List(),
  );

  @override
  void initState() {
    super.initState();
    RepositoryServiceProducts.getAllProducts().then((value) {
      suggestionproducts = value;
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final value = await showDialog<bool>(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: Text(translator.translate("buy_1")),
                actions: <Widget>[
                  TextButton(
                    child: Text(translator.translate("buy_2")),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                  ),
                  TextButton(
                    child: Text(translator.translate("buy_3")),
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                  ),
                ],
              );
            });

        return value == true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            translator.translate("buy_4"),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ),
        body: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height - 310,
              //color: Colors.red,
              child: Column(
                children: [
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
                            flex: 4,
                            child: Text(translator.translate("buy_5")),
                          ),
                          Expanded(
                            child: Text(translator.translate("buy_6")),
                          ),
                          Expanded(
                            child: Text(translator.translate("buy_7")),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(translator.translate("buy_8")),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: AnimationLimiter(
                      child: ListView.builder(
                        itemCount: _facture.products.length + 1,
                        itemBuilder: (BuildContext context, int index) {
                          if (_facture.products.length == 0) {
                            return Image.asset("assets/img/out-of-stock.png");
                          }
                          if (index == _facture.products.length)
                            return Container(
                              height: MediaQuery.of(context).size.height * 0.5,
                            );
                          Product product = _facture.products[index];
                          return AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: 375),
                            child: SlideAnimation(
                              verticalOffset: 50.0,
                              child: FadeInAnimation(
                                child: InkWell(
                                  onTap: () {
                                    showDialog(
                                        context: context,
                                        builder: (ctx) => Dialog(
                                              child: Container(
                                                padding: EdgeInsets.all(16),
                                                child: updateProduct(product),
                                              ),
                                            ));
                                  },
                                  onLongPress: () async {
                                    //todo delete this product
                                    await showDialog<String>(
                                      context: context,
                                      builder: (BuildContext context) =>
                                          AlertDialog(
                                        title:
                                            Text(translator.translate("buy_9")),
                                        content: Text(
                                          "${product.name}" +
                                              translator.translate("buy_10"),
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () {
                                              Fluttertoast.showToast(
                                                msg: translator
                                                    .translate("buy_11"),
                                                backgroundColor: Colors.red,
                                              );
                                              Navigator.pop(context, 'Cancel');
                                            },
                                            child: Text(
                                                translator.translate("buy_12")),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              _facture.products.removeWhere(
                                                  (element) =>
                                                      element.id == product.id);
                                              Navigator.pop(context, 'OK');
                                            },
                                            child: Text(
                                                translator.translate("buy_13")),
                                          ),
                                        ],
                                      ),
                                    ).then((value) {
                                      setState(() {});
                                    });
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
                                            flex: 4,
                                            child: Text("${product.name}"),
                                          ),
                                          Expanded(
                                            child: Text("${product.price()}"),
                                          ),
                                          Expanded(
                                            child: Text("${product.quantity}"),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                                "${product.total.toStringAsFixed(2)}"),
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
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                //height: 210,
                decoration: BoxDecoration(
                  color: Colors.white54,
                  border: Border.all(
                    color: Colors.orange,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.all(8),
                //color: Colors.green,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      constraints: BoxConstraints(
                        maxHeight: 200,
                      ),
                      child: SingleChildScrollView(
                        child: Wrap(
                          //alignment: WrapAlignment.start,
                          spacing: 8,
                          //runSpacing: 4,
                          children: suggestionproducts
                              .map(
                                (Product p) => InkWell(
                                  onTap: () {
                                    //p.quantity = 1;
                                    _facture.insertProduct(p);
                                    setState(() {});
                                  },
                                  child: Chip(label: Text(p.name)),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Text(
                            translator.translate("buy_14") +
                                '${_facture.total.toStringAsFixed(2)} \$ ',
                            style: TextStyle(fontSize: 22),
                          ),
                        ),
                        Expanded(
                          child: IconButton(
                              icon: Image.asset(
                                "assets/img/basket.png",
                                fit: BoxFit.fill,
                              ),
                              onPressed: () {
                                if (_facture.products.length != 0) {
                                  _facture.paid = 0;
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => Dialog(
                                        child: SubmitFacture(
                                      facture: _facture,
                                    )),
                                  ).then((value) {
                                    if (value != null) {
                                      showDialog<String>(
                                        context: context,
                                        builder: (BuildContext context) =>
                                            AlertDialog(
                                          title: Text(
                                              translator.translate("buy_15")),
                                          content: Text(
                                            translator.translate("buy_16"),
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () => Navigator.pop(
                                                  context, 'Cancel'),
                                              child: Text(translator
                                                  .translate("buy_17")),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, 'OK'),
                                              child: Text(translator
                                                  .translate("buy_18")),
                                            ),
                                          ],
                                        ),
                                      ).then((value) {
                                        if (value != null) {
                                          if (value == "OK") {
                                            /*if (printer.printer != null) {
                                              Facture o = _facture;
                                              printer.testPrint(printer.printer,
                                                  );
                                            }*/
                                          }
                                          setState(() {
                                            _facture = Facture(
                                              products: new List(),
                                            );
                                          });
                                        }
                                      });
                                    }
                                  });
                                } else {
                                  Fluttertoast.showToast(
                                      msg: translator.translate("buy_19"),
                                      backgroundColor: Colors.red);
                                }
                              }),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () async {
                            await FlutterBarcodeScanner.scanBarcode(
                              "#000000",
                              translator.translate("buy_20"),
                              true,
                              ScanMode.BARCODE,
                            ).then((value) async {
                              await RepositoryServiceProducts.search(value)
                                  .then((p) {
                                p.first.quantity = 1;
                                _facture.insertProduct(p.first);
                              }).catchError((e) {
                                print(e);
                                // error in database product not founded
                                Fluttertoast.showToast(
                                    msg: translator.translate("buy_21"),
                                    backgroundColor: Colors.red);
                              });
                            }).catchError((e) {
                              // error in scanning
                              Fluttertoast.showToast(
                                  msg: translator.translate("buy_22"),
                                  backgroundColor: Colors.red);
                            });
                            setState(() {});
                          },
                          padding: EdgeInsets.all(0),
                          icon: Icon(Icons.qr_code),
                        ),
                        Expanded(
                          child: TypeAheadField(
                              suggestionsBoxVerticalOffset: 5,
                              direction: AxisDirection.up,
                              textFieldConfiguration: TextFieldConfiguration(
                                decoration: InputDecoration(
                                  labelText: translator.translate("buy_23"),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              ),
                              suggestionsCallback: (input) async {
                                return await RepositoryServiceProducts.search(
                                    input);
                              },
                              itemBuilder: (_, Product suggestion) {
                                return ListTile(
                                  title: Text(suggestion.name),
                                );
                              },
                              onSuggestionSelected: (Product suggestion) {
                                suggestion.quantity = 1;
                                _facture.insertProduct(suggestion);
                                setState(() {});
                              }),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SubmitFacture extends StatefulWidget {
  Facture facture;

  SubmitFacture({
    this.facture,
  });

  @override
  _SubmitFactureState createState() => _SubmitFactureState();
}

class _SubmitFactureState extends State<SubmitFacture> {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();

  final total = TextEditingController();

  final paid = TextEditingController();

  final rest = TextEditingController();
  final clientfiled = TextEditingController();

  final credit = TextEditingController();
  final discount = TextEditingController();
  int clicks = 0;

  @override
  void initState() {
    total.text = widget.facture.total.toStringAsFixed(2);
    paid.text = widget.facture.paid.toStringAsFixed(2);
    rest.text = widget.facture.rest.toStringAsFixed(2);
    credit.text = "0";
    if (widget.facture.supplier != null) {
      clientfiled.text = widget.facture.supplier.fullname;
      credit.text = widget.facture.supplier.credits.toStringAsFixed(2);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.7,
      padding: EdgeInsets.all(16),
      //height: 300,
      child: SingleChildScrollView(
        child: Form(
          key: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: total,
                enabled: false,
                validator: (input) =>
                    input == "" ? translator.translate("buy_24") : null,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: translator.translate("buy_25"),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              TextFormField(
                controller: paid,
                keyboardType: TextInputType.number,
                validator: (input) => input == ""
                    ? translator.translate("buy_24")
                    : (double.parse(input) > widget.facture.total)
                        ? translator.translate("buy_26")
                        : null,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: translator.translate("buy_27"),
                ),
                onChanged: (input) {
                  try {
                    final restvalue =
                        widget.facture.total - double.parse(input);
                    rest.text = restvalue.toString();
                  } catch (e) {
                    Fluttertoast.showToast(
                        msg: translator.translate("buy_28"),
                        backgroundColor: Colors.red);
                  }
                },
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: discount,
                      enabled: false,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: translator.translate("buy_29"),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: rest,
                      enabled: false,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: translator.translate("buy_30"),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TypeAheadFormField(
                      validator: (input) {
                        print(widget.facture.supplier);
                        if (widget.facture.supplier == null) {
                          return translator.translate("buy_31");
                        } else {
                          return null;
                        }
                      },
                      direction: AxisDirection.up,
                      suggestionsBoxVerticalOffset: 5,
                      textFieldConfiguration: TextFieldConfiguration(
                        controller: clientfiled,
                        decoration: InputDecoration(
                          labelText: translator.translate("buy_32"),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                      suggestionsCallback: (input) async {
                        return await RepositoryServiceSuppliers.search(input);
                      },
                      itemBuilder: (_, Supplier suggestion) {
                        return ListTile(
                          title: Text(suggestion.fullname),
                          subtitle: Text("0${suggestion.phone}"),
                        );
                      },
                      onSuggestionSelected: (Supplier suggestion) {
                        widget.facture.supplier = suggestion;
                        credit.text = suggestion.credits.toString();
                        clientfiled.text = suggestion.fullname;
                      },
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: credit,
                      enabled: false,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: translator.translate("buy_33"),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              ListTile(
                onTap: () async {
                  if (_form.currentState.validate()) {
                    if (clicks == 0) {
                      clicks++;
                      widget.facture.paid = double.parse(paid.text);
                      widget.facture.orderDate = DateTime.now();
                      widget.facture.paymentDate = DateTime.now();

                      await RepositoryServiceFactures.addFacture(widget.facture)
                          .then((value) async {
                        if (double.parse(rest.text) > 0) {
                          widget.facture.supplier.credits +=
                              double.parse(rest.text);

                          await RepositoryServiceSuppliers.updateSupplierCredit(
                                  widget.facture.supplier)
                              .then((value) {
                            Fluttertoast.showToast(
                                msg: translator.translate("buy_34"),
                                backgroundColor: Colors.green);
                          }).catchError((e) {
                            Fluttertoast.showToast(
                                msg: translator.translate("buy_35"),
                                backgroundColor: Colors.red);
                          });
                        }
                      }).catchError((e) {
                        Fluttertoast.showToast(
                            msg: translator.translate("buy_36"),
                            backgroundColor: Colors.red);
                      });

                      Navigator.of(context).pop("save");
                    }
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
                      Text(translator.translate("buy_37")),
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

class updateProduct extends StatelessWidget {
  Product product;
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  updateProduct(this.product);
  final quantity = TextEditingController();
  final quantity1 = TextEditingController();
  final price0 = TextEditingController();
  final price01 = TextEditingController();
  final price = TextEditingController();
  final price2 = TextEditingController();
  final price3 = TextEditingController();
  @override
  Widget build(BuildContext context) {
    quantity.text = product.stock.toString();
    price0.text = product.price0.toString();
    price01.text = product.price0.toString();
    price.text = product.price1.toString();
    price2.text = product.price2.toString();
    price3.text = product.price3.toString();

    return Form(
      key: _form,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            enabled: false,
            controller: quantity,
            keyboardType: TextInputType.number,
            validator: (input) =>
                input == "" ? translator.translate("buy_24") : null,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: translator.translate("buy_38"),
            ),
          ),
          SizedBox(
            height: 15,
          ),
          TextFormField(
            controller: quantity1,
            keyboardType: TextInputType.number,
            validator: (input) =>
                input == "" ? translator.translate("buy_24") : null,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: translator.translate("buy_39"),
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  enabled: false,
                  controller: price0,
                  keyboardType: TextInputType.number,
                  validator: (input) =>
                      input == "" ? translator.translate("buy_24") : null,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: translator.translate("buy_40"),
                  ),
                ),
              ),
              SizedBox(
                width: 15,
              ),
              Expanded(
                child: TextFormField(
                  controller: price01,
                  keyboardType: TextInputType.number,
                  validator: (input) =>
                      input == "" ? translator.translate("buy_24") : null,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: translator.translate("buy_41"),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 15,
          ),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: price,
                  keyboardType: TextInputType.number,
                  validator: (input) =>
                      input == "" ? translator.translate("buy_24") : null,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: translator.translate("buy_42"),
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
                  validator: (input) =>
                      input == "" ? translator.translate("buy_24") : null,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: translator.translate("buy_43"),
                  ),
                ),
              ),
              Expanded(
                child: TextFormField(
                  controller: price3,
                  keyboardType: TextInputType.number,
                  validator: (input) =>
                      input == "" ? translator.translate("buy_24") : null,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: translator.translate("buy_44"),
                  ),
                ),
              )
            ],
          ),
          ListTile(
            onTap: () async {
              if (_form.currentState.validate()) {
                product.quantity = double.parse(quantity.text);
                product.price0 = double.parse(price01.text);
                product.price1 = double.parse(price.text);
                product.price2 = double.parse(price2.text);
                product.price3 = double.parse(price3.text);
                product.quantity = double.parse(quantity1.text);

                Navigator.of(context).pop("save");
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
                  Text(translator.translate("buy_37")),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
