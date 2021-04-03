import 'package:delivery_f/services/auth.dart';
import 'package:delivery_f/services/database_creator.dart';
import 'package:delivery_f/services/printer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:provider/provider.dart';

import 'screens/wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  DatabaseCreator().initDatabase();

  await translator.init(
    localeDefault: LocalizationDefaultType.device,
    languagesList: <String>['ar', 'en'],
    assetsDirectory: 'assets/langs/',
  );
  runApp(
    LocalizedApp(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Provider<AuthBase>(
      create: (ctx) => Auth(),
      child: ChangeNotifierProvider<PrintTest>(
        create: (ctx) {
          return PrintTest();
        },
        child: MaterialApp(
          title: 'Delivery',
          debugShowCheckedModeBanner: false,
          localizationsDelegates: translator.delegates,
          locale: translator.locale,
          supportedLocales: translator.locals(),
          home: Wrapper(),
        ),
      ),
    );
  }
}
