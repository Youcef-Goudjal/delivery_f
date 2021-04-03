import 'package:delivery_f/screens/home/buyspage.dart';
import 'package:delivery_f/screens/home/clientsPage.dart';
import 'package:delivery_f/screens/home/productsPage.dart';
import 'package:delivery_f/screens/home/salesPage.dart';
import 'package:delivery_f/screens/home/settings.dart';
import 'package:delivery_f/screens/home/supplierPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        actions: [
          IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                // Go to setting page
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (ctx) => Settings()));
              })
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.2,
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.045),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                            MaterialPageRoute(builder: (ctx) => SalesPage()));
                      },
                      borderRadius: BorderRadius.circular(20),
                      splashColor: Colors.orange,
                      child: Card(
                        elevation: 5,
                        child: Ink(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              //Image.asset("assets/img/sales.png"),

                              Text(
                                translator.translate("home_1"),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                            MaterialPageRoute(builder: (ctx) => BuyPage()));
                      },
                      borderRadius: BorderRadius.circular(20),
                      splashColor: Colors.orange,
                      child: Card(
                        elevation: 5,
                        child: Ink(
                          padding: EdgeInsets.all(20),
                          //height: 100,
                          decoration: BoxDecoration(
                            //color: Colors.orangeAccent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            translator.translate("home_2"),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.045),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                            MaterialPageRoute(builder: (ctx) => ClientsPage()));
                      },
                      borderRadius: BorderRadius.circular(20),
                      splashColor: Colors.orange,
                      child: Card(
                        elevation: 5,
                        child: Ink(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                translator.translate("home_3"),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (ctx) => SupplierPage()));
                      },
                      borderRadius: BorderRadius.circular(20),
                      splashColor: Colors.orange,
                      child: Card(
                        elevation: 5,
                        child: Ink(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                translator.translate("home_4"),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            InkWell(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (ctx) => ProductsPage()));
              },
              borderRadius: BorderRadius.circular(20),
              splashColor: Colors.orange,
              child: Card(
                elevation: 5,
                child: Ink(
                  padding: EdgeInsets.all(8),
                  height: 100,
                  width: width * 0.9,
                  decoration: BoxDecoration(
                    // color: Colors.yellow,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Image.asset("assets/img/boxes.png"),
                      SizedBox(
                        width: 20,
                      ),
                      Text(
                        translator.translate("home_5"),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
