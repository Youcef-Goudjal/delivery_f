import 'package:delivery_f/models/client.dart';
import 'package:delivery_f/models/order.dart';
import 'package:delivery_f/models/product.dart';
import 'package:delivery_f/services/databaseHelpers/repository_service_clients.dart';
import 'package:delivery_f/services/databaseHelpers/repository_service_orders.dart';
import 'package:delivery_f/services/databaseHelpers/repository_service_products.dart';
import 'package:delivery_f/services/printer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:provider/provider.dart';

class SalesPage extends StatefulWidget {
  @override
  _SalesPageState createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  List<Product> suggestionproducts = List();
  Order _order = Order(
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
    final printer = Provider.of<PrintTest>(context, listen: false);
    return WillPopScope(
      onWillPop: () async {
        final value = await showDialog<bool>(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: Text(translator.translate("sale_1")),
                actions: <Widget>[
                  TextButton(
                    child: Text(translator.translate("sale_2")),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                  ),
                  TextButton(
                    child: Text(translator.translate("sale_3")),
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
          actions: [
            InkWell(
                onTap: () {
                  setState(() {
                    _order.pricing = 1;
                  });
                },
                child: CircleAvatar(child: Text("1"))),
            InkWell(
                onTap: () {
                  setState(() {
                    _order.pricing = 2;
                  });
                },
                child: CircleAvatar(child: Text("2"))),
            InkWell(
                onTap: () {
                  setState(() {
                    _order.pricing = 3;
                  });
                },
                child: CircleAvatar(child: Text("3"))),
          ],
          title: Text(
            translator.translate("sale_4"),
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
                            child: Text(translator.translate("sale_5")),
                          ),
                          Expanded(
                            child: Text(translator.translate("sale_6")),
                          ),
                          Expanded(
                            child: Text(translator.translate("sale_7")),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(translator.translate("sale_8")),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: AnimationLimiter(
                      child: ListView.builder(
                        itemCount: _order.products.length + 1,
                        itemBuilder: (BuildContext context, int index) {
                          if (_order.products.length == 0) {
                            return Image.asset("assets/img/out-of-stock.png");
                          }
                          if (index == _order.products.length)
                            return Container(
                              height: MediaQuery.of(context).size.height * 0.5,
                            );
                          Product product = _order.products[index];
                          return AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: 375),
                            child: SlideAnimation(
                              verticalOffset: 50.0,
                              child: FadeInAnimation(
                                child: InkWell(
                                  onTap: () {
                                    final quantity = TextEditingController();
                                    final GlobalKey<FormState> _form =
                                        GlobalKey<FormState>();
                                    showDialog(
                                        context: context,
                                        builder: (ctx) => Dialog(
                                              child: Container(
                                                padding: EdgeInsets.all(16),
                                                child: Form(
                                                  key: _form,
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      TextFormField(
                                                        controller: quantity,
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        validator: (input) =>
                                                            input == ""
                                                                ? translator
                                                                    .translate(
                                                                        "sale_24")
                                                                : null,
                                                        decoration:
                                                            InputDecoration(
                                                          border:
                                                              OutlineInputBorder(),
                                                          labelText: translator
                                                              .translate(
                                                                  "sale_7"),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 15,
                                                      ),
                                                      ListTile(
                                                        onTap: () async {
                                                          if (_form.currentState
                                                              .validate()) {
                                                            product.quantity =
                                                                double.parse(
                                                                    quantity
                                                                        .text);
                                                            Navigator.of(
                                                                    context)
                                                                .pop("save");
                                                          }
                                                        },
                                                        title: Center(
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Icon(Icons.save),
                                                              SizedBox(
                                                                width: 10,
                                                              ),
                                                              Text(translator
                                                                  .translate(
                                                                      "sale_37")),
                                                            ],
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ));
                                  },
                                  onLongPress: () async {
                                    //todo delete this product
                                    await showDialog<String>(
                                      context: context,
                                      builder: (BuildContext context) =>
                                          AlertDialog(
                                        title: Text(
                                            translator.translate("sale_9")),
                                        content: Text(
                                          "${product.name}" +
                                              translator.translate("sale_10"),
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () {
                                              Fluttertoast.showToast(
                                                msg: translator
                                                    .translate("sale_11"),
                                                backgroundColor: Colors.red,
                                              );
                                              Navigator.pop(context, 'Cancel');
                                            },
                                            child: Text(translator
                                                .translate("sale_12")),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              _order.products.removeWhere(
                                                  (element) =>
                                                      element.id == product.id);
                                              Navigator.pop(context, 'OK');
                                            },
                                            child: Text(translator
                                                .translate("sale_13")),
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
                                    _order.insertProduct(p);
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
                            '${translator.translate("sale_14")} ${_order.total.toStringAsFixed(2)} \$ ',
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
                                if (_order.products.length != 0) {
                                  _order.paid = 0;
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => Dialog(
                                        child: SubmitOrder(
                                      order: _order,
                                    )),
                                  ).then((value) {
                                    if (value != null) {
                                      showDialog<String>(
                                        context: context,
                                        builder: (BuildContext context) =>
                                            AlertDialog(
                                          title: Text(
                                              translator.translate("sale_15")),
                                          content: Text(
                                            translator.translate("sale_16"),
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () => Navigator.pop(
                                                  context, 'Cancel'),
                                              child: Text(translator
                                                  .translate("sale_17")),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, 'OK'),
                                              child: Text(translator
                                                  .translate("sale_18")),
                                            ),
                                          ],
                                        ),
                                      ).then((value) {
                                        if (value != null) {
                                          if (value == "OK") {
                                            if (printer.printer != null) {
                                              Order o = _order;
                                              printer.testPrint(printer.printer,
                                                  order: o);
                                            }
                                          }
                                          setState(() {
                                            _order = Order(
                                              products: new List(),
                                            );
                                          });
                                        }
                                      });
                                    }
                                  });
                                } else {
                                  Fluttertoast.showToast(
                                      msg: translator.translate("sale_19"),
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
                              translator.translate("sale_20"),
                              true,
                              ScanMode.BARCODE,
                            ).then((value) async {
                              await RepositoryServiceProducts.search(value)
                                  .then((p) {
                                p.first.quantity = 1;
                                _order.insertProduct(p.first);
                              }).catchError((e) {
                                print(e);
                                // error in database product not founded
                                Fluttertoast.showToast(
                                    msg: translator.translate("sale_21"),
                                    backgroundColor: Colors.red);
                              });
                            }).catchError((e) {
                              // error in scanning
                              Fluttertoast.showToast(
                                  msg: translator.translate("sale_22"),
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
                                  labelText: translator.translate("sale_23"),
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
                                _order.insertProduct(suggestion);
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

class SubmitOrder extends StatefulWidget {
  Order order;

  SubmitOrder({
    this.order,
  });

  @override
  _SubmitOrderState createState() => _SubmitOrderState();
}

class _SubmitOrderState extends State<SubmitOrder> {
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
    total.text = widget.order.total.toString();
    paid.text = widget.order.paid.toString();
    rest.text = widget.order.rest.toString();
    credit.text = "0";
    if (widget.order.client != null) {
      clientfiled.text = widget.order.client.fullname;
      credit.text = widget.order.client.credits.toString();
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
                    input == "" ? translator.translate("sale_24") : null,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: translator.translate("sale_25"),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              TextFormField(
                controller: paid,
                keyboardType: TextInputType.number,
                validator: (input) => input == ""
                    ? translator.translate("sale_24")
                    : (double.parse(input) > widget.order.total)
                        ? translator.translate("sale_26")
                        : null,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: translator.translate("sale_27"),
                ),
                onChanged: (input) {
                  try {
                    final restvalue = widget.order.total - double.parse(input);
                    rest.text = restvalue.toString();
                  } catch (e) {
                    Fluttertoast.showToast(
                        msg: translator.translate("sale_28"),
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
                        labelText: translator.translate("sale_29"),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: rest,
                      enabled: false,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: translator.translate("sale_30"),
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
                    flex: 3,
                    child: TypeAheadFormField(
                      validator: (input) {
                        print(widget.order.client);
                        if (widget.order.client == null) {
                          return translator.translate("sale_31");
                        } else {
                          return null;
                        }
                      },
                      direction: AxisDirection.up,
                      suggestionsBoxVerticalOffset: 5,
                      textFieldConfiguration: TextFieldConfiguration(
                        controller: clientfiled,
                        decoration: InputDecoration(
                          labelText: translator.translate("sale_32"),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                      suggestionsCallback: (input) async {
                        return await RepositoryServiceClients.search(input);
                      },
                      itemBuilder: (_, Client suggestion) {
                        return ListTile(
                          title: Text(suggestion.fullname),
                          subtitle: Text("0${suggestion.phone}"),
                        );
                      },
                      onSuggestionSelected: (Client suggestion) {
                        widget.order.client = suggestion;
                        credit.text = suggestion.credits.toString();
                        clientfiled.text = suggestion.fullname;
                      },
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: credit,
                      enabled: false,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: translator.translate("sale_33"),
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
                      widget.order.paid = double.parse(paid.text);
                      widget.order.orderDate = DateTime.now();
                      widget.order.paymentDate = DateTime.now();

                      await RepositoryServiceOrders.addOrder(widget.order)
                          .then((value) async {
                        if (double.parse(rest.text) > 0) {
                          widget.order.client.credits +=
                              double.parse(rest.text);

                          await RepositoryServiceClients.updateClientCredit(
                                  widget.order.client)
                              .then((value) {
                            Fluttertoast.showToast(
                                msg: translator.translate("sale_34"),
                                backgroundColor: Colors.green);
                          }).catchError((e) {
                            Fluttertoast.showToast(
                                msg: translator.translate("sale_35"),
                                backgroundColor: Colors.red);
                          });
                        }
                      }).catchError((e) {
                        Fluttertoast.showToast(
                            msg: translator.translate("sale_36"),
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
                      Text(translator.translate("sale_37")),
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
