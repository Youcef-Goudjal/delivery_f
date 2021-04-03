import 'package:delivery_f/models/client.dart';
import 'package:delivery_f/screens/home/ordersPage.dart';
import 'package:delivery_f/services/databaseHelpers/repository_service_clients.dart';
import 'package:delivery_f/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class ClientsPage extends StatefulWidget {
  @override
  _ClientsPageState createState() => _ClientsPageState();
}

class _ClientsPageState extends State<ClientsPage> {
  List<Client> clients = List();
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
              translator.translate("client_1"),
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
              future: RepositoryServiceClients.getAllClients(),
              builder: (ctx, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  clients = snapshot.data;
                  return AnimationLimiter(
                    child: ListView.builder(
                      itemCount: clients.length + 1,
                      itemBuilder: (BuildContext context, int index) {
                        if (clients.length == 0) {
                          return Image.asset("assets/img/out-of-stock.png");
                        }
                        if (index == clients.length)
                          return Container(
                            height: 50,
                          );

                        Client client = clients[index];
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 375),
                          delay: Duration(milliseconds: 300),
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                                child: ListTile(
                              title: Text(client.fullname),
                              subtitle: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('0${client.phone}'),
                                  Text('${client.credits.toStringAsFixed(2)}')
                                ],
                              ),
                              leading:
                                  CircleAvatar(child: Text(index.toString())),
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (ctx) => OrdersPage(
                                          client: client,
                                        )));
                              },
                              onLongPress: () async {
                                await showDialog(
                                  context: context,
                                  builder: (ctx) => Dialog(
                                      child: EditClient(
                                    update: true,
                                    client: client,
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
                            translator.translate("client_2"),
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
                              labelText: translator.translate("client_3"),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
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
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (ctx) => OrdersPage(
                                      client: suggestion,
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
            builder: (ctx) => Dialog(child: EditClient()),
          );
          setState(() {});
        },
        child: Icon(Icons.person_add_alt),
      ),
    );
  }
}

class EditClient extends StatelessWidget {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  Client client;
  final bool update;
  final name = TextEditingController();
  final phone = TextEditingController();
  final credit = TextEditingController();

  EditClient({
    this.update: false,
    this.client,
  });
  @override
  Widget build(BuildContext context) {
    if (update) {
      name.text = client.fullname;
      phone.text = "0${client.phone}";
      credit.text = "${client.credits}";
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
                  input == "" ? translator.translate("client_4") : null,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: translator.translate("client_5"),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            TextFormField(
              controller: phone,
              keyboardType: TextInputType.phone,
              validator: (input) => input == ""
                  ? translator.translate("client_4")
                  : input.length != 10
                      ? translator.translate("client_6")
                      : null,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: translator.translate("client_7"),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            TextFormField(
              controller: credit,
              keyboardType: TextInputType.number,
              validator: (input) =>
                  input == "" ? translator.translate("client_4") : null,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: translator.translate("client_8"),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            ListTile(
              trailing: (update)
                  ? IconButton(
                      icon: Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        showDialog<bool>(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                content: Text(translator.translate("client_9")),
                                actions: <Widget>[
                                  TextButton(
                                    child:
                                        Text(translator.translate("client_10")),
                                    onPressed: () {
                                      Navigator.of(context).pop(false);
                                    },
                                  ),
                                  TextButton(
                                    child:
                                        Text(translator.translate("client_11")),
                                    onPressed: () {
                                      Navigator.of(context).pop(true);
                                    },
                                  ),
                                ],
                              );
                            }).then((value) {
                          if (value) {
                            RepositoryServiceClients.deleteClient(client.id)
                                .then((value) {
                              Fluttertoast.showToast(
                                  msg: translator.translate("client_12"),
                                  backgroundColor: Colors.green);
                              Navigator.pop(context);
                            }).catchError((e) {
                              Fluttertoast.showToast(
                                  msg: translator.translate("client_13"),
                                  backgroundColor: Colors.red);
                            });
                          }
                        });
                      },
                    )
                  : null,
              onTap: () async {
                if (_form.currentState.validate()) {
                  client = Client(
                    id: (client != null) ? client.id : null,
                    fullname: name.text,
                    phone: int.parse(phone.text),
                    credits: double.parse(credit.text),
                  );
                  if (update) {
                    print("update client ${client.id}");
                    //todo update client info
                    await RepositoryServiceClients.updateClient(client)
                        .then((value) {
                      Fluttertoast.showToast(
                          msg: translator.translate("client_14"),
                          backgroundColor: Colors.green);
                    }).catchError((e) {
                      print(e);
                      Fluttertoast.showToast(
                          msg: translator.translate("client_15"),
                          backgroundColor: Colors.red);
                    });
                    Navigator.pop(context);
                  } else {
                    print("insert client ");
                    // todo insert new client
                    await RepositoryServiceClients.addClient(client)
                        .then((value) async {
                      Fluttertoast.showToast(
                          msg: translator.translate("client_16"),
                          backgroundColor: Colors.green);
                      client.id = value;

                      Navigator.pop(context);
                    }).catchError((e) {
                      Fluttertoast.showToast(
                          msg: translator.translate("client_17"),
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
                    Text(translator.translate("client_18")),
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
