import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:imei_plugin/imei_plugin.dart';

abstract class AuthBase {
  User get currentUser;

  Stream<User> authStateChanges();

  Future<User> signInWithEmailAndPassword(String email, String password);

  Future<void> signOut(bool t);
}

class Auth implements AuthBase {
  final _firebaseAuth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  @override
  Stream<User> authStateChanges() => _firebaseAuth.authStateChanges();

  @override
  User get currentUser => _firebaseAuth.currentUser;

  @override
  Future<User> signInWithEmailAndPassword(String email, String password) async {
    final userCredential = await _firebaseAuth.signInWithCredential(
      EmailAuthProvider.credential(email: email, password: password),
    );
    checkUser(userCredential.user);
    return userCredential.user;
  }

  Future<void> checkUser(User user) async {
    if (user != null) {
      DocumentSnapshot doc =
          await firestore.collection("users").doc(user.uid).get();
      String imei = await ImeiPlugin.getImei();
      if (doc.exists) {
        String s = doc.data()["imei"];
        print("test ------------$s");
        if (s == "") {
          await firestore.collection("users").doc(user.uid).set({
            "imei": imei,
            "enable": false,
          });
        } else {
          if (s != imei) {
            Fluttertoast.showToast(
                msg: "الرجاء تسجيل الخروج من الأجهزة الأخري",
                backgroundColor: Colors.red);
            await signOut(true);
          }
        }
      } else {
        await firestore.collection("users").doc(user.uid).set({
          "imei": imei,
          "enable": false,
        });
      }
    }
  }

  @override
  Future<void> signOut(bool t) async {
    if (!t) {
      try {
        await firestore.collection("users").doc(currentUser.uid).update({
          "imei": "",
        });
      } catch (e) {}
    }
    await _firebaseAuth.signOut();
  }

  Future changePassword(String email) async {
    return await _firebaseAuth.sendPasswordResetEmail(email: email);
  }
}
