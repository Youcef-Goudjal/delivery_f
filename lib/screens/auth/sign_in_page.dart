import 'package:delivery_f/services/auth.dart';
import 'package:delivery_f/widgets/fade_animation.dart';
import 'package:delivery_f/widgets/loading.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _auth = Auth();
  final _formKey = GlobalKey<FormState>();
  String error = '';
  bool loading = false;
  bool hidePassword = true;

  // text field state
  String email = '';
  String password = '';
  _login() async {
    if (_formKey.currentState.validate()) {
      setState(() => loading = true);
      dynamic result = await _auth.signInWithEmailAndPassword(email, password);
      if (result == null) {
        setState(() {
          loading = false;
          error = "الرجاء محاولة مرة أخرى";
        });
      } else {
        error = "";
        loading = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Container(
                child: Column(
                  children: <Widget>[
                    Container(
                      height: 400,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                        image: AssetImage('assets/img/van.gif'),
                        //fit: BoxFit.fill
                      )),
                      child: Stack(
                        children: <Widget>[
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: FadeAnimation(
                                1.6,
                                Container(
                                  margin: EdgeInsets.only(top: 50),
                                  child: Center(
                                    child: Text(
                                      translator.translate("l_login"),
                                      style: TextStyle(
                                          //color: Colors.white,
                                          fontSize: 40,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                )),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(30.0),
                      child: Column(
                        children: <Widget>[
                          FadeAnimation(
                              1.8,
                              Container(
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                          color:
                                              Color.fromRGBO(143, 148, 251, .2),
                                          blurRadius: 20.0,
                                          offset: Offset(0, 10))
                                    ]),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    children: <Widget>[
                                      Container(
                                        padding: EdgeInsets.all(8.0),
                                        decoration: BoxDecoration(
                                            border: Border(
                                                bottom: BorderSide(
                                                    color: Colors.grey[100]))),
                                        child: TextFormField(
                                          validator: (val) => !EmailValidator
                                                  .validate(val)
                                              ? translator.translate(
                                                  "l_email_validation") //"الرجاء ادخال إيمايل صحيح" //tr("l_email_validation")
                                              : null,
                                          onChanged: (val) => email = val,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          decoration: InputDecoration(
                                              border: InputBorder.none,
                                              hintText: translator.translate(
                                                  "l_email_labelhint"), // "بريد الالكتروني ", // tr("l_email_labelhint"),
                                              hintStyle: TextStyle(
                                                  color: Colors.grey[400])),
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.all(8.0),
                                        child: TextFormField(
                                          obscureText: hidePassword,
                                          /*validator: (val) => val.length < 6
                                              ? "l_password_validation"كلمة السر أقل من 6 حروف
                                              : null,*/
                                          onChanged: (val) => password = val,
                                          decoration: InputDecoration(
                                              suffixIcon: IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    hidePassword =
                                                        !hidePassword;
                                                  });
                                                },
                                                icon: hidePassword
                                                    ? const Icon(
                                                        Icons.lock_open)
                                                    : const Icon(Icons
                                                        .lock_outline_rounded),
                                              ),
                                              border: InputBorder.none,
                                              hintText: translator.translate(
                                                  "l_password_hint"), // "كلمة السر", //tr("l_password_hint"),
                                              hintStyle: TextStyle(
                                                  color: Colors.grey[400])),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              )),
                          SizedBox(
                            height: 30,
                          ),
                          FadeAnimation(
                              2,
                              InkWell(
                                onTap: _login,
                                child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      gradient: LinearGradient(colors: [
                                        Colors.orange,
                                        Colors.orangeAccent,
                                      ])),
                                  child: Center(
                                    child: Text(
                                      translator.translate(
                                          "l_btn_txt"), //"سجل دخولك", //tr("l_btn_txt"),
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              )),
                          Text(
                            error,
                            style: TextStyle(color: Colors.red),
                          ),
                          SizedBox(
                            height: 10,
                          ),
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
                            height: 30,
                          ),
                          FadeAnimation(
                            1.5,
                            InkWell(
                                onTap: () async {
                                  if (_formKey.currentState.validate()) {
                                    await _auth
                                        .changePassword(email)
                                        .then((val) {
                                      Fluttertoast.showToast(
                                        msg:
                                            "Email sent to change your password",
                                        backgroundColor: Colors.green,
                                      );
                                    }).catchError((e) {
                                      Fluttertoast.showToast(
                                        msg: "user does not exist",
                                        backgroundColor: Colors.red,
                                      );
                                    });
                                  }
                                },
                                child: Text(
                                  translator.translate(
                                      "forgotpwd"), //"نسيت كلمة السر ؟", // tr("forgotpwd"),
                                  style: TextStyle(
                                    color: Colors.orange,
                                  ),
                                )),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            loading ? Loading() : Container(),
          ],
        ));
  }
}
