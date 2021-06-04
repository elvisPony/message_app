import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'register.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key, @required this.loginChange}) : super(key: key);
  final ValueChanged<bool> loginChange;

  @override
  _LoginPage createState() => _LoginPage(loginChange: loginChange);
}

//TODO 回傳登入資訊
class _LoginPage extends State<LoginPage> {
  _LoginPage({this.loginChange});

  // Initially password is obscure
  bool _obscureText = true;
  IconData _iconForPassword = Icons.visibility_off;

  final ValueChanged<bool> loginChange;
  final TextEditingController accountController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String errorText;
  String errorPasswordText;

  // GoogleSignInAccount _currentUser;
  UserCredential userCredential;

  @mustCallSuper
  void initState() {
    super.initState();
    errorText = null;
    errorPasswordText = null;
    accountController.text = "henry890811@gmail.com";
    passwordController.text = "123456789";
  }

  void _loginButton(String text1, String text2) async {
//    print(text1);
//    print(text2);
//  print("button");
    try {
      userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: text1, password: text2);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        Fluttertoast.showToast(
          backgroundColor: Colors.grey,
          msg: 'No user found for that email.',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
        );
        setState(() {
          errorText = "No user found for that email.";
          errorPasswordText = errorText;
        });
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        Fluttertoast.showToast(
          backgroundColor: Colors.grey,
          msg: "Wrong password provided for that user.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
        );
        setState(() {
          errorPasswordText = "Wrong password provided for that user.";
        });
        print('Wrong password provided for that user.');
      }
    }
    print(userCredential);
    if (userCredential != null) loginChange(false);
  }

  Future<UserCredential> signInWithGoogle() async {
    Fluttertoast.showToast(msg: "不知為啥會有問題");
    //TODO 可用但資料庫得處理
    //   print("0");
    //   // Trigger the authentication flow
    //   final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();
    //
    //   print("1");
    //   // Obtain the auth details from the request
    //   final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    //
    //   print("2");
    //   // Create a new credential
    //   final GoogleAuthCredential credential = GoogleAuthProvider.credential(
    //     accessToken: googleAuth.accessToken,
    //     idToken: googleAuth.idToken,
    //   );
    // print("123");
    //   // Once signed in, return the UserCredential
    //   return await FirebaseAuth.instance.signInWithCredential(credential)
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height / 2,
        padding: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              //, vertical: 3.0),
              child: TextField(
                style: TextStyle(color: Colors.white),
                controller: accountController,
                decoration: InputDecoration(
                  labelStyle: TextStyle(color: Colors.grey),
                  helperStyle: TextStyle(color: Colors.grey),
                  border: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.red)),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white)),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white)),
                  // fillColor: Colors.white,
                  prefixIcon: Icon(
                    Icons.person,
                    color: Colors.white,
                  ),
                  labelText: "帳號",
                  helperText: "請輸入帳號",
                  // hintText: "使用者帳號",
                  errorText: errorText,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              //, vertical: 3.0),
              child: TextField(
                style: TextStyle(color: Colors.white),
                controller: passwordController,
                obscureText: _obscureText,
                decoration: InputDecoration(
                  border: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.red)),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white)),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white)),
                  // fillColor: Colors.white,
                  errorText: errorPasswordText,
                  prefixIcon: Icon(
                    Icons.lock,
                    color: Colors.white,
                  ),
                  suffixIcon: IconButton(
                      icon: Icon(_iconForPassword, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                          if (_obscureText)
                            _iconForPassword = Icons.visibility_off;
                          else
                            _iconForPassword = Icons.remove_red_eye;
                        });
                      }),
                  //remove_red_eye)
                  labelStyle: TextStyle(color: Colors.grey),
                  helperStyle: TextStyle(color: Colors.grey),
                  labelText: "密碼",
                  helperText: "請輸入密碼，嘗試登入一次",
                  // hintText: "使用者密碼",
                ),
              ),
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary: Colors.white, onPrimary: Colors.black),
                  child: Text("註冊帳號"),
                  onPressed: () {
                    Navigator.of(context).push(PageRouteBuilder(
                      transitionDuration: Duration(milliseconds: 800),
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          RegisterPage(),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        var begin = Offset(0.0, 1.0);
                        var end = Offset.zero;
                        var curve = Curves.ease;

                        var tween = Tween(begin: begin, end: end)
                            .chain(CurveTween(curve: curve));
                        return SlideTransition(
                          position: animation.drive(tween),
                          child: child,
                        );
                      },
                    ));
                  },
                ),
                VerticalDivider(),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary: Colors.white, onPrimary: Colors.black),
                  child: Text("登入"),
                  onPressed: () {
                    _loginButton(
                        accountController.text, passwordController.text);
                  },
                ),
              ],
            ),
            // SizedBox(
            //   width: MediaQuery.of(context).size.width - 48.0,
            //   height: 48.0,
            //   child: ElevatedButton(
            //     child: Text("登入"),
            //     onPressed: () {
            //       _loginButton(accountController.text, passwordController.text);
            //     },
            //   ),
            // ),
            // SizedBox(
            //   height: 10.0,
            // ),
            // SizedBox(
            //   width: MediaQuery.of(context).size.width - 48.0,
            //   height: 48.0,
            //   child: ElevatedButton(
            //     child: Text("註冊帳號"),
            //     onPressed: () {
            //       Navigator.of(context).push(PageRouteBuilder(
            //         transitionDuration: Duration(milliseconds: 800),
            //         pageBuilder: (context, animation, secondaryAnimation) =>
            //             RegisterPage(),
            //         transitionsBuilder:
            //             (context, animation, secondaryAnimation, child) {
            //           var begin = Offset(0.0, 1.0);
            //           var end = Offset.zero;
            //           var curve = Curves.ease;
            //
            //           var tween = Tween(begin: begin, end: end)
            //               .chain(CurveTween(curve: curve));
            //           return SlideTransition(
            //             position: animation.drive(tween),
            //             child: child,
            //           );
            //         },
            //       ));
            //     },
            //   ),
            // ),
            // Divider(),
            // SignInButton(
            //   Buttons.Google,
            //   onPressed: () => print('1'),
            // )
          ],
        ));
  }
}
