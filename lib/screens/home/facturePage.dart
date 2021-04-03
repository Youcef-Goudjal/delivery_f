import 'package:delivery_f/models/facture.dart';
import 'package:delivery_f/models/supplier.dart';
import 'package:delivery_f/services/databaseHelpers/repository_service_factures.dart';
import 'package:delivery_f/services/databaseHelpers/repository_service_suppliers.dart';
import 'package:delivery_f/services/printer.dart';
import 'package:delivery_f/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:provider/provider.dart';

class FacturePage extends StatefulWidget {
  final Supplier supplier;

  const FacturePage({this.supplier});

  @override
  _FacturePageState createState() => _FacturePageState();
}

class _FacturePageState extends State<FacturePage> {
  List factures = [];
  @override
  void initState() {
    super.initState();

    RepositoryServiceFactures.getAllFactureofSupplier(widget.supplier)
        .then((value) {
      setState(() {
        factures = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final printer = Provider.of<PrintTest>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.supplier.fullname + translator.translate("fact_1")),
      ),
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height - 165,
            //color: Colors.red,
            child: AnimationLimiter(
              child: ListView.builder(
                itemCount: factures.length + 1,
                itemBuilder: (BuildContext context, int index) {
                  if (factures.length == 0) {
                    return Image.asset("assets/img/out-of-stock.png");
                  }
                  if (index == factures.length)
                    return Container(
                      height: 50,
                    );
                  Facture facture = factures[index];
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
                            /*if (printer.printer != null) {
                              printer.testPrint(printer.printer,
                                  facture: facture);
                            }*/
                          },
                          icon: Icon(Icons.message),
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
                                    formatDate(facture.orderDate),
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
                                    "${facture.orderDate.hour}:${facture.orderDate.minute}",
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
                                  Text(translator.translate("fact_2")),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                      ' ${facture.rest.toStringAsFixed(2)} DA'),
                                ],
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Row(
                                children: [
                                  Text('translator.translate("fact_3")'),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text('${facture.count}'),
                                ],
                              )
                            ],
                          ),
                        ),
                        leading:
                            CircleAvatar(child: Text(facture.id.toString())),
                        onTap: () async {
                          await showDialog(
                            context: context,
                            builder: (ctx) => Dialog(
                              child: UpdateFacture(
                                facture: facture,
                              ),
                            ),
                          );
                          showDialog<String>(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              title: Text(translator.translate("fact_4")),
                              content: Text(
                                translator.translate("fact_5"),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, 'Cancel'),
                                  child: Text(translator.translate("fact_6")),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, 'OK'),
                                  child: Text(translator.translate("fact_7")),
                                ),
                              ],
                            ),
                          ).then((value) {
                            if (value != null) {
                              if (value == "OK") {
                                if (printer.printer != null) {
                                  Facture o = facture;
                                  //todo printer.printCredits(printer.printer,);
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
                                child: UpdateCreditOfSupplier(
                                  supplier: widget.supplier,
                                  factures: factures,
                                ),
                              ),
                            );
                          },
                          child: Text(translator.translate("fact_8")),
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
                              await RepositoryServiceFactures
                                  .getAllFactureofDateRange(
                                supplier: widget.supplier,
                                range: value,
                              ).then((value) {
                                factures = value;
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

class UpdateFacture extends StatefulWidget {
  Facture facture;
  UpdateFacture({this.facture});
  @override
  _UpdateFactureState createState() => _UpdateFactureState();
}

class _UpdateFactureState extends State<UpdateFacture> {
  DateTime selectedDate = DateTime.now();
  TextEditingController total = TextEditingController();
  TextEditingController paid = TextEditingController();
  GlobalKey<FormState> _form = GlobalKey<FormState>();
  int clicks = 0;
  @override
  void initState() {
    super.initState();
    total.text = widget.facture.rest.toString();
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
            Text(translator.translate("fact_9")),
            SizedBox(
              height: 10,
            ),
            TextFormField(
              controller: total,
              enabled: false,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: translator.translate("fact_10"),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            TextFormField(
              controller: paid,
              validator: (input) => input == ""
                  ? translator.translate("fact_11")
                  : (double.parse(total.text) - double.parse(input) < 0)
                      ? translator.translate("fact_12")
                      : null,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: translator.translate("fact_13"),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(translator.translate("fact_14")),
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
                    widget.facture.paid += double.parse(paid.text);
                    widget.facture.paymentDate = selectedDate;
                    await RepositoryServiceFactures.updateFacture(
                            widget.facture)
                        .then((value) async {
                      Fluttertoast.showToast(
                          msg: translator.translate("fact_14"),
                          backgroundColor: Colors.green);
                      widget.facture.supplier.credits -=
                          double.parse(paid.text);
                      await RepositoryServiceSuppliers.updateSupplierCredit(
                              widget.facture.supplier)
                          .then((value) {
                        Fluttertoast.showToast(
                            msg: translator.translate("fact_15"),
                            backgroundColor: Colors.green);
                      }).catchError((e) {
                        Fluttertoast.showToast(
                            msg: translator.translate("fact_16"),
                            backgroundColor: Colors.red);
                      });
                    }).catchError((e) {
                      Fluttertoast.showToast(
                          msg: " حدث خطأ أثناء تحديث الفاتورة ",
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
                    Text(translator.translate("fact_29")),
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

class UpdateCreditOfSupplier extends StatefulWidget {
  List<Facture> factures;
  Supplier supplier;
  UpdateCreditOfSupplier({
    this.factures,
    this.supplier,
  });
  @override
  _UpdateCreditOfSupplierState createState() => _UpdateCreditOfSupplierState();
}

class _UpdateCreditOfSupplierState extends State<UpdateCreditOfSupplier> {
  DateTime selectedDate = DateTime.now();
  TextEditingController total = TextEditingController();
  TextEditingController paid = TextEditingController();
  GlobalKey<FormState> _form = GlobalKey<FormState>();
  int clicks = 0;
  @override
  void initState() {
    super.initState();
    total.text = widget.supplier.credits.toStringAsFixed(2);
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
            Text(translator.translate("fact_19")),
            SizedBox(
              height: 10,
            ),
            TextFormField(
              controller: total,
              enabled: false,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: translator.translate("fact_20"),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            TextFormField(
              controller: paid,
              validator: (input) => input == ""
                  ? translator.translate("fact_21")
                  : (double.parse(total.text) - double.parse(input) < 0)
                      ? translator.translate("fact_22")
                      : null,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: translator.translate("fact_23"),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(translator.translate("fact_24")),
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

                    await RepositoryServiceFactures.updateFactureOfSupplier(
                            widget.factures, double.parse(paid.text))
                        .then((value) async {
                      Fluttertoast.showToast(
                          msg: translator.translate("fact_25"),
                          backgroundColor: Colors.green);
                      widget.supplier.credits -= double.parse(paid.text);
                      await RepositoryServiceSuppliers.updateSupplierCredit(
                              widget.supplier)
                          .then((value) {
                        Fluttertoast.showToast(
                            msg: translator.translate("fact_26"),
                            backgroundColor: Colors.green);
                      }).catchError((e) {
                        Fluttertoast.showToast(
                            msg: translator.translate("fact_27"),
                            backgroundColor: Colors.red);
                      });
                    }).catchError((e) {
                      Fluttertoast.showToast(
                          msg: translator.translate("fact_28"),
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
                    Text(translator.translate("fact_29")),
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
