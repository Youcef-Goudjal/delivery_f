import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_f/screens/auth/sign_in_page.dart';
import 'package:delivery_f/services/auth.dart';
import 'package:delivery_f/services/buckup.dart';
import 'package:delivery_f/services/localstorage.dart';
import 'package:delivery_f/services/printer.dart';
import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image/image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:provider/provider.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text(translator.translate("setting_1")),
      ),
      body: Stack(
        children: [
          Center(
            child: Card(
              margin: EdgeInsets.all(20),
              child: Container(
                //height: 300,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      title: Text(translator.translate("setting_2")),
                      trailing: Icon(Icons.arrow_drop_down_sharp),
                      onTap: () {
                        final p =
                            Provider.of<PrintTest>(context, listen: false);
                        showDialog(
                            context: context,
                            builder: (ctx) => Dialog(
                                  child: SelectPrinter(
                                    p: p,
                                  ),
                                ));
                      },
                    ),
                    ListTile(
                      title: Text(translator.translate("setting_3")),
                      trailing: Icon(Icons.arrow_drop_down_sharp),
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (_) => Dialog(
                                  child: PersonelD(),
                                ));
                      },
                    ),
                    Text(translator.translate("setting_4")),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {
                            translator.setNewLanguage(context,
                                newLanguage: "ar");
                            setState(() {});
                          },
                          child: Text("العربية"),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text("Français"),
                        ),
                        TextButton(
                          onPressed: () {
                            translator.setNewLanguage(context,
                                newLanguage: "en");
                          },
                          child: Text("English"),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    ListTile(
                        onTap: () async {
                          Backup.create(auth);
                        },
                        trailing: Icon(Icons.cloud_upload_outlined),
                        title: Text(translator.translate("setting_5"))),
                    FutureBuilder(
                        future: FirebaseFirestore.instance
                            .collection("users")
                            .doc(auth.currentUser.uid)
                            .get(),
                        builder: (context,
                            AsyncSnapshot<DocumentSnapshot> snapshot) {
                          bool val = false;
                          if (snapshot.hasData) {
                            if (snapshot.data.exists &&
                                snapshot.data.data()["enable"] == true) {
                              val = true;
                            } else {
                              val = false;
                            }
                          }
                          return ListTile(
                              trailing: Icon(Icons.cloud_download),
                              onTap: () async {
                                if (val) {
                                  final v = await showDialog(
                                      context: context,
                                      builder: (_) {
                                        final f = TextEditingController();
                                        return Dialog(
                                          child: Container(
                                            padding: EdgeInsets.all(16),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                TextFormField(
                                                  controller: f,
                                                  decoration: InputDecoration(
                                                    border:
                                                        OutlineInputBorder(),
                                                    labelText: translator
                                                        .translate("setting_6"),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 15,
                                                ),
                                                Center(
                                                  child: IconButton(
                                                    icon: Icon(Icons.save),
                                                    onPressed: () {
                                                      Navigator.pop(
                                                          context, "${f.text}");
                                                    },
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        );
                                      });
                                  if (v != null) {
                                    Backup.download(auth, "$v");
                                  }
                                } else {
                                  Fluttertoast.showToast(
                                    msg: translator.translate("setting_7"),
                                    toastLength: Toast.LENGTH_LONG,
                                  );
                                }
                              },
                              title: Text(translator.translate("setting_8")));
                        })
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -15,
            left: -15,
            child: Container(
              width: 80,
              height: 80,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: 5,
            left: 5,
            child: IconButton(
              icon: Icon(
                Icons.power_settings_new,
                color: Colors.white,
              ),
              onPressed: () async {
                //log out
                await Auth().signOut(false);
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (ctx) => SignInPage()));
              },
            ),
          )
        ],
      ),
    );
  }
}

class PersonelD extends StatefulWidget {
  @override
  _PersonelDState createState() => _PersonelDState();
}

class _PersonelDState extends State<PersonelD> {
  GlobalKey<FormState> _form = GlobalKey<FormState>();
  final name = TextEditingController();
  final companyname = TextEditingController();
  final phone = TextEditingController();

  @override
  void initState() {
    super.initState();
    name.text = storage.getItem("fullName");
    companyname.text = storage.getItem("company");
    phone.text = storage.getItem("phone");
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder(
            future: Future.delayed(Duration(
              seconds: 1,
            )),
            builder: (context, snapshot) {
              return Form(
                key: _form,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      translator.translate("setting_9"),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    TextFormField(
                      controller: companyname,
                      validator: (input) => input == ""
                          ? translator.translate("setting_10")
                          : null,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: translator.translate("setting_11"),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    TextFormField(
                      controller: name,
                      validator: (input) => input == ""
                          ? translator.translate("setting_10")
                          : null,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: translator.translate("setting_12"),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    TextFormField(
                      controller: phone,
                      keyboardType: TextInputType.phone,
                      validator: (input) => input == ""
                          ? translator.translate("setting_10")
                          : null,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: translator.translate("setting_13"),
                      ),
                    ),
                    ListTile(
                      title: Text(
                        (storage.getItem("logo")) ?? false
                            ? translator.translate("setting_15")
                            : translator.translate("setting_14"),
                      ),
                      onTap: () {
                        storage.setItem(
                            "logo",
                            (storage.getItem("logo") == null
                                ? false
                                : (storage.getItem("logo") == false)
                                    ? true
                                    : false));
                        setState(() {});
                      },
                    ),
                    ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(translator.translate("setting_16")),
                          SizedBox(
                            width: 5,
                          ),
                          Icon(Icons.image),
                        ],
                      ),
                      onTap: () {
                        ImagePicker.pickImage(source: ImageSource.gallery)
                            .then((File value) {
                          final Uint8List d = value.readAsBytesSync();
                          Image img = decodeImage(d);

                          storage.setItem("image", img);
                        });
                      },
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(translator.translate("setting_17")),
                          SizedBox(
                            width: 5,
                          ),
                          Icon(Icons.save),
                        ],
                      ),
                      onTap: () async {
                        if (_form.currentState.validate()) {
                          try {
                            if (storage.getItem("image") == null) {
                              Fluttertoast.showToast(
                                  msg: translator.translate("setting_18"));
                            }

                            await storage.setItem("fullName", name.text);
                            await storage.setItem("company", companyname.text);
                            await storage.setItem("phone", phone.text);

                            Fluttertoast.showToast(
                                msg: translator.translate("setting_19"),
                                backgroundColor: Colors.green);
                            Navigator.pop(context);
                          } catch (e) {
                            Fluttertoast.showToast(
                                msg: translator.translate("setting_20"),
                                backgroundColor: Colors.red);
                          }
                        }
                      },
                    )
                  ],
                ),
              );
            }),
      ),
    );
  }
}

class SelectPrinter extends StatefulWidget {
  final p;

  SelectPrinter({this.p});

  @override
  _SelectPrinterState createState() => _SelectPrinterState();
}

class _SelectPrinterState extends State<SelectPrinter> {
  PrinterBluetoothManager printerManager = PrinterBluetoothManager();
  List<PrinterBluetooth> _devices = [];

  @override
  void initState() {
    super.initState();
    printerManager.scanResults.listen((devices) async {
      print('UI: Devices found ${devices.length}');
      setState(() {
        _devices = devices;
      });
    });
  }

  void _startScanDevices() {
    setState(() {
      _devices = [];
    });
    printerManager.startScan(Duration(seconds: 4));
  }

  void _stopScanDevices() {
    printerManager.stopScan();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text("الطابعات"),
        ),
        body: ListView.builder(
          itemCount: _devices.length,
          itemBuilder: (_, int index) {
            return ListTile(
              onTap: () {
                try {
                  storage.setItem("printer", _devices[index].name);

                  widget.p.setPrinter(_devices[index]);
                  _stopScanDevices();
                  Fluttertoast.showToast(
                      msg: "printer selected", backgroundColor: Colors.green);
                } catch (e) {
                  Fluttertoast.showToast(
                      msg: "error $e", backgroundColor: Colors.red);
                }
              },
              title: Text(_devices[index].name ?? ""),
              subtitle: Text(_devices[index].address ?? ""),
            );
          },
        ),
        floatingActionButton: StreamBuilder<bool>(
          stream: printerManager.isScanningStream,
          initialData: false,
          builder: (c, snapshot) {
            if (snapshot.data) {
              return FloatingActionButton(
                child: Icon(Icons.stop),
                onPressed: _stopScanDevices,
                backgroundColor: Colors.red,
              );
            } else {
              return FloatingActionButton(
                child: Icon(Icons.search),
                onPressed: _startScanDevices,
              );
            }
          },
        ),
      ),
    );
  }
}
