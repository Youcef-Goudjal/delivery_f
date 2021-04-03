import 'package:delivery_f/models/supplier.dart';
import 'package:delivery_f/screens/home/facturePage.dart';
import 'package:delivery_f/services/databaseHelpers/repository_service_suppliers.dart';
import 'package:delivery_f/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class SupplierPage extends StatefulWidget {
  @override
  _SupplierPageState createState() => _SupplierPageState();
}

class _SupplierPageState extends State<SupplierPage> {
  List<Supplier> suppliers = List();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(Icons.person),
            SizedBox(
              width: 20,
            ),
            Text(
              translator.translate("supplier_1"),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height - 165,
            //color: Colors.red,
            child: FutureBuilder(
              future: RepositoryServiceSuppliers.getAllSuppliers(),
              builder: (ctx, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  suppliers = snapshot.data;
                  return AnimationLimiter(
                    child: ListView.builder(
                      itemCount: suppliers.length + 1,
                      itemBuilder: (BuildContext context, int index) {
                        if (suppliers.length == 0) {
                          return Image.asset("assets/img/out-of-stock.png");
                        }
                        if (index == suppliers.length)
                          return Container(
                            height: 50,
                          );

                        Supplier supplier = suppliers[index];
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 375),
                          delay: Duration(milliseconds: 300),
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                                child: ListTile(
                              title: Text(supplier.fullname),
                              subtitle: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('0${supplier.phone}'),
                                  Text('${supplier.credits.toStringAsFixed(2)}')
                                ],
                              ),
                              leading:
                                  CircleAvatar(child: Text(index.toString())),
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (ctx) => FacturePage(
                                          supplier: supplier,
                                        )));
                              },
                              onLongPress: () async {
                                await showDialog(
                                  context: context,
                                  builder: (ctx) => Dialog(
                                      child: EditSupplier(
                                    update: true,
                                    supplier: supplier,
                                  )),
                                );
                                setState(() {});
                              },
                            )),
                          ),
                        );
                      },
                    ),
                  );
                }
                return Loading();
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 90,
              padding: EdgeInsets.all(8),
              //color: Colors.green,
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
                      IconButton(
                        onPressed: () async {
                          String barcode =
                              await FlutterBarcodeScanner.scanBarcode(
                            "#000000",
                            translator.translate("supplier_2"),
                            true,
                            ScanMode.BARCODE,
                          );
                          Fluttertoast.showToast(
                            msg: barcode,
                            backgroundColor: Colors.green,
                          );
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
                              labelText: translator.translate("supplier_3"),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                          suggestionsCallback: (input) async {
                            return await RepositoryServiceSuppliers.search(
                                input);
                          },
                          itemBuilder: (_, Supplier suggestion) {
                            return ListTile(
                              title: Text(suggestion.fullname),
                              subtitle: Text("0${suggestion.phone}"),
                            );
                          },
                          onSuggestionSelected: (Supplier suggestion) {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (ctx) => FacturePage(
                                      supplier: suggestion,
                                    )));
                          },
                        ),
                      ),
                      SizedBox(
                        width: 65,
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // adding client
          await showDialog(
            context: context,
            builder: (ctx) => Dialog(child: EditSupplier()),
          );
          setState(() {});
        },
        child: Icon(Icons.person_add_alt),
      ),
    );
  }
}

class EditSupplier extends StatelessWidget {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  Supplier supplier;
  final bool update;
  final name = TextEditingController();
  final phone = TextEditingController();
  final credit = TextEditingController();

  EditSupplier({
    this.update: false,
    this.supplier,
  });
  @override
  Widget build(BuildContext context) {
    if (update) {
      name.text = supplier.fullname;
      phone.text = "0${supplier.phone}";
      credit.text = "${supplier.credits}";
    }
    return Container(
      padding: EdgeInsets.all(16),
      //height: 300,
      child: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: name,
              validator: (input) =>
                  input == "" ? translator.translate("supplier_4") : null,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: translator.translate("supplier_5"),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            TextFormField(
              controller: phone,
              keyboardType: TextInputType.phone,
              validator: (input) => input == ""
                  ? translator.translate("supplier_4")
                  : input.length != 10
                      ? translator.translate("supplier_6")
                      : null,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: translator.translate("supplier_7"),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            TextFormField(
              controller: credit,
              keyboardType: TextInputType.number,
              validator: (input) =>
                  input == "" ? translator.translate("supplier_4") : null,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: translator.translate("supplier_8"),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            ListTile(
              onTap: () async {
                if (_form.currentState.validate()) {
                  supplier = Supplier(
                    id: (supplier != null) ? supplier.id : null,
                    fullname: name.text,
                    phone: int.parse(phone.text),
                    credits: double.parse(credit.text),
                  );
                  if (update) {
                    print("update client ${supplier.id}");
                    //todo update client info
                    await RepositoryServiceSuppliers.updateSupplier(supplier)
                        .then((value) {
                      Fluttertoast.showToast(
                          msg: translator.translate("supplier_14"),
                          backgroundColor: Colors.green);
                    }).catchError((e) {
                      print(e);
                      Fluttertoast.showToast(
                          msg: translator.translate("supplier_15"),
                          backgroundColor: Colors.red);
                    });
                    Navigator.pop(context);
                  } else {
                    print("insert supplier ");
                    // todo insert new client
                    await RepositoryServiceSuppliers.addSupplier(supplier)
                        .then((value) async {
                      Fluttertoast.showToast(
                          msg: translator.translate("supplier_16"),
                          backgroundColor: Colors.green);
                      supplier.id = value;
                      Navigator.pop(context);
                    }).catchError((e) {
                      Fluttertoast.showToast(
                          msg: translator.translate("supplier_17"),
                          backgroundColor: Colors.red);
                    });
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
                    Text(translator.translate("supplier_18")),
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
