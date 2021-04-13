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

class UpdateOrderPage extends StatefulWidget {
  Order oldOrder;
  UpdateOrderPage({this.oldOrder});
  @override
  _UpdateOrderPageState createState() => _UpdateOrderPageState();
}

class _UpdateOrderPageState extends State<UpdateOrderPage> {
  List<Product> suggestionproducts = List();
  Order newOrder;

  @override
  void initState() {
    super.initState();
    newOrder = Order.clone(widget.oldOrder);
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
                    newOrder.pricing = 1;
                  });
                },
                child: CircleAvatar(child: Text("1"))),
            InkWell(
                onTap: () {
                  setState(() {
                    newOrder.pricing = 2;
                  });
                },
                child: CircleAvatar(child: Text("2"))),
            InkWell(
                onTap: () {
                  setState(() {
                    newOrder.pricing = 3;
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
                        itemCount: newOrder.products.length + 1,
                        itemBuilder: (BuildContext context, int index) {
                          if (newOrder.products.length == 0) {
                            return Image.asset("assets/img/out-of-stock.png");
                          }
                          if (index == newOrder.products.length)
                            return Container(
                              height: MediaQuery.of(context).size.height * 0.5,
                            );
                          Product product = newOrder.products[index];
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
                                              newOrder.products.removeWhere(
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
                                    newOrder.insertProduct(p);
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
                            '${translator.translate("sale_14")} ${newOrder.total.toStringAsFixed(2)} \$ ',
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
                                if (newOrder.products.length != 0) {
                                  newOrder.paid = 0;
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => Dialog(
                                        child: SubmitOrder(
                                      oldOrder: widget.oldOrder,
                                      newOrder: newOrder,
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
                                              Order o = newOrder;
                                              printer.testPrint(printer.printer,
                                                  order: o);
                                            }
                                          }
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
                                newOrder.insertProduct(p.first);
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
                                newOrder.insertProduct(suggestion);
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
  Order newOrder;
  Order oldOrder;

  SubmitOrder({
    this.newOrder,
    this.oldOrder,
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
    total.text = widget.newOrder.total.toStringAsFixed(2);
    paid.text = widget.oldOrder.paid.toStringAsFixed(2);
    rest.text = widget.newOrder.rest.toStringAsFixed(2);
    credit.text = "0";
    if (widget.newOrder.client != null) {
      clientfiled.text = widget.newOrder.client.fullname;
      credit.text = widget.newOrder.client.credits.toString();
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
                    : (double.parse(input) > widget.newOrder.total)
                        ? translator.translate("sale_26")
                        : null,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: translator.translate("sale_27"),
                ),
                onChanged: (input) {
                  try {
                    final restvalue =
                        widget.newOrder.total - double.parse(input);
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
                        print(widget.newOrder.client);
                        if (widget.newOrder.client == null) {
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
                        widget.newOrder.client = suggestion;
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
                      widget.newOrder.paid = double.parse(paid.text);
                      widget.newOrder.orderDate = DateTime.now();
                      widget.newOrder.paymentDate = DateTime.now();

                      await RepositoryServiceOrders.updateOrderOfClient(
                              widget.oldOrder, widget.newOrder)
                          .then((value) async {
                        if (double.parse(rest.text) > 0) {
                          widget.newOrder.client.credits =
                              widget.oldOrder.client.credits -
                                  widget.oldOrder.rest;
                          widget.newOrder.client.credits +=
                              double.parse(rest.text);

                          await RepositoryServiceClients.updateClientCredit(
                                  widget.newOrder.client)
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
