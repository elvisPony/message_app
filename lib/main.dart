import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:message_app/shared/constants.dart';

import 'page/home.dart';
import 'page/login.dart';

// TODO 製作快取快速讀取用戶資訊及朋友以及聊天資訊
// TODO 串接後端 以及資料庫 儲存必要文件

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  _MyApp createState() => _MyApp();
}

class _MyApp extends State<MyApp> {
  // This widget is the root of your application.
  void initState() {
    super.initState();
  }

  ThemeMode themeMode = ThemeMode.light;
  int themeIndex = 6;

//TODO 主題可透過這邊作變更
  //TODO 可套用package https://pub.dev/packages/flex_color_scheme
  @override
  Widget build(BuildContext context) {
    print("myApp build");
    const FlexScheme usedFlexScheme = FlexScheme.green;
    print(usedFlexScheme);
    return MaterialApp(
      builder: EasyLoading.init(),
      title: 'Flutter Demo',
      theme: FlexColorScheme.light(
        colors: myFlexSchemes[themeIndex].light,
        surfaceStyle: FlexSurface.medium,
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        fontFamily: AppFonts.mainFont,
      ).toTheme,
      darkTheme: FlexColorScheme.dark(
        colors: myFlexSchemes[themeIndex].dark,
        surfaceStyle: FlexSurface.medium,
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        fontFamily: AppFonts.mainFont,
      ).toTheme,
      themeMode: themeMode,
      home: InitialPage(
        themeMode: themeMode,
        onThemeModeChanged: (ThemeMode mode) {
          setState(() {
            themeMode = mode;
          });
        },
        schemeIndex: themeIndex,
        onSchemeChanged: (int index) {
          setState(() {
            themeIndex = index;
          });
        },
        flexSchemeData: myFlexSchemes[themeIndex],
      ),
    );
  }
}

class InitialPage extends StatefulWidget {
  InitialPage({
    @required this.themeMode,
    @required this.onThemeModeChanged,
    @required this.schemeIndex,
    @required this.onSchemeChanged,
    @required this.flexSchemeData,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final int schemeIndex;
  final ValueChanged<int> onSchemeChanged;
  final FlexSchemeData flexSchemeData;

  _InitialPage createState() => _InitialPage(
      themeMode: themeMode,
      onThemeModeChanged: onThemeModeChanged,
      flexSchemeData: flexSchemeData,
      schemeIndex: schemeIndex,
      onSchemeChanged: onSchemeChanged);
}

class _InitialPage extends State<InitialPage> {
  _InitialPage(
      {@required this.themeMode,
      @required this.onThemeModeChanged,
      @required this.schemeIndex,
      @required this.onSchemeChanged,
      @required this.flexSchemeData});

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final int schemeIndex;
  final ValueChanged<int> onSchemeChanged;
  final FlexSchemeData flexSchemeData;
  bool notLogin = false;
  String nowState = 'Loading...';
  User user;
  CollectionReference users;
  DocumentSnapshot userData;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initialFirebase();
  }

  Future<void> initialFirebase() async {
    setState(() {
      nowState = "正在初始化...";
    });
    await Firebase.initializeApp().whenComplete(() {
      setState(() {
        nowState = "初始化完成";
      });
    });

    FirebaseAuth.instance.authStateChanges().listen((User _user) async {
      if (_user == null) {
        print('User is currently signed out!');
        user = null;
        setState(() {
          notLogin = true;
        });
      } else {
        print('User is sign in!');
        setState(() {
          user = _user;
          notLogin = false;
          nowState = "登入成功 請稍後...";
        });

        await Future.delayed(Duration(milliseconds: 60));

        setState(() {
          nowState = "正在獲取使用者資料...";
        });
        await Future.delayed(Duration(milliseconds: 60));
        users = FirebaseFirestore.instance.collection('users');
        userData = await users.doc(user.email).get();
        print(userData.data());
        setState(() {
          nowState = "即將進入主畫面...";
        });
        await Future.delayed(Duration(milliseconds: 60));
        // print(user);
        Navigator.of(context).pop();
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => MyHomePage(
                user: user,
                userData: userData,
                themeMode: themeMode,
                onThemeModeChanged: onThemeModeChanged,
                flexSchemeData: flexSchemeData,
                schemeIndex: schemeIndex,
                onSchemeChanged: onSchemeChanged)));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    //print("initial build");
    return Scaffold(
        body: GestureDetector(
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
            child: Column(children: [
          Container(
              height: MediaQuery.of(context).size.height / 1.8,
              child:
                  Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                Container(
                  // color: Colors.black,
                  // alignment: Alignment(0, -0.5),
                  child: FaIcon(
                    FontAwesomeIcons.connectdevelop,
                    color: Colors.white,
                    size: MediaQuery.of(context).size.width / 2,
                  ),
                ),
                Container(
                    child: Center(
                  child: Text("聊天go",
                      style: TextStyle(fontSize: 60, color: Colors.white)),
                ))
              ])),
          (notLogin == false)
              ? Container(
                  height: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).size.height / 1.8,
                  alignment: Alignment(0, 0.5),
                  child: AnimatedTextKit(
                    animatedTexts: [
                      TypewriterAnimatedText(
                        nowState,
                        textStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 22.0,
                          fontWeight: FontWeight.bold,
                        ),
                        speed: const Duration(milliseconds: 50),
                      ),
                    ],
                    repeatForever: true,
                    //totalRepeatCount: 4,
                    // pause: const Duration(milliseconds: 1),
                    displayFullTextOnTap: true,
                    stopPauseOnTap: true,
                  ))
              : Container(
                  alignment: Alignment(0, 1.3),
                  height: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).size.height / 1.8,
                  //color: Colors.red,
                  child: LoginPage(
                    loginChange: (bool login) {
                      setState(() {
                        notLogin = login;
                      });
                    },
                  ))
        ])),
        color: Colors.black,
      ),
      onTap: () => FocusScope.of(context).unfocus(),
    ));
  }
}

const FlexSchemeColor myScheme1Light = FlexSchemeColor(
  primary: Color(0xFF4E0028),
  primaryVariant: Color(0xFF320019),
  secondary: Color(0xFF003419),
  secondaryVariant: Color(0xFF002411),
  appBarColor: Color(0xFF002411),
);

const FlexSchemeColor myScheme1Dark = FlexSchemeColor(
  primary: Color(0xFF9E7389),
  primaryVariant: Color(0xFF775C69),
  secondary: Color(0xFF738F81),
  secondaryVariant: Color(0xFF5C7267),
  appBarColor: Color(0xFF5C7267),
);

final FlexSchemeColor myScheme2Light =
    FlexSchemeColor.from(primary: const Color(0xFF4C4E06));
final FlexSchemeColor myScheme2Dark =
    FlexSchemeColor.from(primary: const Color(0xFF9D9E76));

final FlexSchemeColor myScheme3Light = FlexSchemeColor.from(
  primary: const Color(0xFF993200),
  secondary: const Color(0xFF1B5C62),
);

final List<FlexSchemeData> myFlexSchemes = <FlexSchemeData>[
  ...FlexColor.schemesList,
  const FlexSchemeData(
    name: 'Toledo purple',
    description: 'Purple theme, created from full custom defined color scheme.',
    light: myScheme1Light,
    dark: myScheme1Dark,
  ),
  FlexSchemeData(
    name: 'Olive green',
    description:
        'Olive green theme, created from primary light and dark colors.',
    light: myScheme2Light,
    dark: myScheme2Dark,
  ),
  FlexSchemeData(
    name: 'Oregon orange',
    description: 'Custom orange and blue theme, from only light scheme colors.',
    light: myScheme3Light,
    dark: myScheme3Light.toDark(),
  ),
];
