import 'package:delivery_f/services/auth.dart';
import 'package:delivery_f/services/localstorage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth/sign_in_page.dart';
import 'home/home.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);
    storage.ready;
    return StreamBuilder<User>(
      stream: auth.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final User user = snapshot.data;
          if (user == null) {
            return SignInPage();
          }

          return HomePage();
        }
        return Container(
          color: Colors.blue,
          child: Center(
            child: CircularProgressIndicator(
                backgroundColor: Colors.orange, strokeWidth: 2),
          ),
        );
      },
    );
  }
}
