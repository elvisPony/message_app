import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class MySelfPage extends StatefulWidget {
  _MySelfPage createState() => _MySelfPage();
}

class _MySelfPage extends State<MySelfPage> {
  initState() {
    Firebase.initializeApp();
    super.initState();
  }

  bool writing = false;

  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
