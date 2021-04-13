import 'package:delivery_f/models/client.dart';
import 'package:delivery_f/models/order.dart';
import 'package:delivery_f/screens/home/updateOrderPage.dart';
import 'package:delivery_f/services/databaseHelpers/repository_service_clients.dart';
import 'package:delivery_f/services/databaseHelpers/repository_service_orders.dart';
import 'package:delivery_f/services/printer.dart';
import 'package:delivery_f/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:provider/provider.dart';

class OrdersPage extends StatefulWidget {
  final Client client;

  const OrdersPage({this.client});

  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  List orders = [];
  @override
  void initState() {
    super.initState();

    RepositoryServiceOrders.getAllOrderofClient(widget.client).then((value) {
      setState(() {
        orders = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final printer = Provider.of<PrintTest>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text(translator.translate("order_1")),
      ),
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height - 165,
            //color: Colors.red,
            child: AnimationLimiter(
              child: ListView.builder(
                itemCount: orders.length + 1,
                itemBuilder: (BuildContext context, int index) {
                  if (orders.length == 0) {
                    return Image.asset("assets/img/out-of-stock.png");
                  }
                  if (index == orders.length)
                    return Container(
                      height: 50,
                    );
                  Order order = orders[index];
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 375),
                    delay: Duration(milliseconds: 300),
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                          child: ListTile(
                        trailing: IconButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => UpdateOrderPage(
                                          order: order,
                                        )));
                          },
                          icon: Icon(Icons.edit),
                        ),
                        title: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    formatDate(order.orderDate),
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(Icons.timer_rounded),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    "${order.orderDate.hour}:${order.orderDate.minute}",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        subtitle: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(translator.translate("order_2")),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(' ${order.rest.toStringAsFixed(2)}'),
                                ],
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Row(
                                children: [
                                  Text(translator.translate("order_3")),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text('${order.count}'),
                                ],
                              )
                            ],
                          ),
                        ),
                        leading: CircleAvatar(child: Text(order.id.toString())),
                        onTap: () async {
                          await showDialog(
                            context: context,
                            builder: (ctx) => Dialog(
                              child: UpdateOrder(
                                order: order,
                              ),
                            ),
                          );
                          showDialog<String>(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              title: Text(translator.translate("order_4")),
                              content: Text(
                                translator.translate("order_5"),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, 'Cancel'),
                                  child: Text(translator.translate("order_6")),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, 'OK'),
                                  child: Text(translator.translate("order_7")),
                                ),
                              ],
                            ),
                          ).then((value) {
                            if (value != null) {
                              if (value == "OK") {
                                if (printer.printer != null) {
                                  Order o = order;
                                  printer.printCredits(printer.printer, o);
                                }
                              }
                            }
                          });
                        },
                      )),
                    ),
                  );
                },
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 100,
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.orange),
                  color: Colors.white),
              child: Column(
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () async {
                            await showDialog(
                              context: context,
                              builder: (ctx) => Dialog(
                                child: UpdateCreditOfClient(
                                  client: widget.client,
                                  orders: orders,
                                ),
                              ),
                            );
                          },
                          child: Text(translator.translate("order_8")),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.calendar_today_outlined),
                        onPressed: () {
                          int year = DateTime.now().year;
                          int month = DateTime.now().month;
                          int day = DateTime.now().day + 1;
                          showDateRangePicker(
                            context: context,
                            firstDate: DateTime(2018),
                            lastDate: DateTime(year, month, day),
                          ).then((DateTimeRange value) async {
                            if (value != null) {
                              await RepositoryServiceOrders
                                  .getAllOrderofDateRange(
                                client: widget.client,
                                range: value,
                              ).then((value) {
                                orders = value;
                                setState(() {});
                              });
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class UpdateOrder extends StatefulWidget {
  Order order;
  UpdateOrder({this.order});
  @override
  _UpdateOrderState createState() => _UpdateOrderState();
}

class _UpdateOrderState extends State<UpdateOrder> {
  DateTime selectedDate = DateTime.now();
  TextEditingController total = TextEditingController();
  TextEditingController paid = TextEditingController();
  GlobalKey<FormState> _form = GlobalKey<FormState>();
  int clicks = 0;
  @override
  void initState() {
    super.initState();
    total.text = widget.order.rest.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      //height: 300,
      child: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(translator.translate("order_9")),
            SizedBox(
              height: 10,
            ),
            TextFormField(
              controller: total,
              enabled: false,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: translator.translate("order_10"),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            TextFormField(
              controller: paid,
              validator: (input) => input == ""
                  ? translator.translate("order_11")
                  : (double.parse(total.text) - double.parse(input) < 0)
                      ? translator.translate("order_12")
                      : null,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: translator.translate("order_13"),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(translator.translate("order_14")),
                SizedBox(
                  width: 10,
                ),
                TextButton(
                  onPressed: () {
                    int year = DateTime.now().year;
                    int month = DateTime.now().month;
                    int day = DateTime.now().day + 1;
                    showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2018),
                      lastDate: DateTime(year, month, day),
                    ).then((value) {
                      selectedDate = value;
                      setState(() {});
                    });
                  },
                  child: Text(
                    formatDate(selectedDate),
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
                    widget.order.paid += double.parse(paid.text);
                    widget.order.paymentDate = selectedDate;
                    await RepositoryServiceOrders.updateOrder(widget.order)
                        .then((value) async {
                      Fluttertoast.showToast(
                          msg: translator.translate("order_15"),
                          backgroundColor: Colors.green);
                      widget.order.client.credits -= double.parse(paid.text);
                      await RepositoryServiceClients.updateClientCredit(
                              widget.order.client)
                          .then((value) {
                        Fluttertoast.showToast(
                            msg: translator.translate("order_16"),
                            backgroundColor: Colors.green);
                      }).catchError((e) {
                        Fluttertoast.showToast(
                            msg: translator.translate("order_17"),
                            backgroundColor: Colors.red);
                      });
                    }).catchError((e) {
                      Fluttertoast.showToast(
                          msg: translator.translate("order_18"),
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
                    Text(translator.translate("order_29")),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class UpdateCreditOfClient extends StatefulWidget {
  List<Order> orders;
  Client client;
  UpdateCreditOfClient({
    this.orders,
    this.client,
  });
  @override
  _UpdateCreditOfClientState createState() => _UpdateCreditOfClientState();
}

class _UpdateCreditOfClientState extends State<UpdateCreditOfClient> {
  DateTime selectedDate = DateTime.now();
  TextEditingController total = TextEditingController();
  TextEditingController paid = TextEditingController();
  GlobalKey<FormState> _form = GlobalKey<FormState>();
  int clicks = 0;
  @override
  void initState() {
    super.initState();
    total.text = widget.client.credits.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      //height: 300,
      child: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(translator.translate("order_19")),
            SizedBox(
              height: 10,
            ),
            TextFormField(
              controller: total,
              enabled: false,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: translator.translate("order_20"),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            TextFormField(
              controller: paid,
              validator: (input) => input == ""
                  ? translator.translate("order_11")
                  : (double.parse(total.text) - double.parse(input) < 0)
                      ? translator.translate("order_22")
                      : null,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: translator.translate("order_23"),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(translator.translate("order_24")),
                SizedBox(
                  width: 10,
                ),
                TextButton(
                  onPressed: () {
                    int year = DateTime.now().year;
                    int month = DateTime.now().month;
                    int day = DateTime.now().day + 1;
                    showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2018),
                      lastDate: DateTime(year, month, day),
                    ).then((value) {
                      selectedDate = value;
                      setState(() {});
                    });
                  },
                  child: Text(
                    formatDate(selectedDate),
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

                    await RepositoryServiceOrders.updateOrdersOfClient(
                            widget.orders, double.parse(paid.text))
                        .then((value) async {
                      Fluttertoast.showToast(
                          msg: translator.translate("order_25"),
                          backgroundColor: Colors.green);
                      widget.client.credits -= double.parse(paid.text);
                      await RepositoryServiceClients.updateClientCredit(
                              widget.client)
                          .then((value) {
                        Fluttertoast.showToast(
                            msg: translator.translate("order_26"),
                            backgroundColor: Colors.green);
                      }).catchError((e) {
                        Fluttertoast.showToast(
                            msg: translator.translate("order_27"),
                            backgroundColor: Colors.red);
                      });
                    }).catchError((e) {
                      Fluttertoast.showToast(
                          msg: translator.translate("order_28"),
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
                    Text(translator.translate("order_29")),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
