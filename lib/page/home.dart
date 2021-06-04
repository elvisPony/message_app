import 'package:animations/animations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kumi_popup_window/kumi_popup_window.dart';
import 'package:message_app/main.dart';
import 'package:message_app/page/chat/chat.dart';

import 'chat/chat.dart';
import 'person.dart';
import 'setting.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';


class MyHomePage extends StatefulWidget {
  MyHomePage({
    Key key,
    this.userData,
    this.user,
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
  final DocumentSnapshot userData;
  final User user;


  @override
  _MyHomePageState createState() => _MyHomePageState(
      user: user,
      userData: userData,
      themeMode: themeMode,
      onThemeModeChanged: onThemeModeChanged,
      flexSchemeData: flexSchemeData,
      schemeIndex: schemeIndex,
      onSchemeChanged: onSchemeChanged);


}

class _MyHomePageState extends State<MyHomePage> {
  _MyHomePageState({
    this.user,
    this.userData,
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

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  int _selectedIndex = 1;
  int allMessageindex = 21;
  int beenTaped = 999;
  List<Widget> friendList = [];
  List<Widget> chatList = [];
  List<Widget> chatGroupList = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Widget> _widgetOptions(BuildContext context, ThemeData theme) =>
      <Widget>[friendPage(theme), chatRoomPage(theme)];

  CollectionReference users;
  FirebaseAuth auth;
  User user;
  DocumentSnapshot userData;

  void initFirebase() async {
    await Firebase.initializeApp().whenComplete(() {
      print("initial completed");
    });

    auth = FirebaseAuth.instance;

    users = FirebaseFirestore.instance.collection('users');
  }

  @override
  @protected
  @mustCallSuper
  void initState() {
    initFirebase();
    super.initState();


    EasyLoading.addStatusCallback((status) {
      print('EasyLoading Status $status');
    });
    //_checkFinePosPermission();
//    messageDetail.add(MessageDetail(friend: none, message: "12"));
//    messageDetail.add(MessageDetail(friend: none, message: "12"));
//    messageDetail.add(MessageDetail(friend: none, message: "12"));
    //TODO 處理login前的資訊
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    var then = messaging.getToken().then((value) {
      print(value);
    });
    FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      print("message recieved");
      print(event.notification.body);
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Notification"),
              content: Text(event.notification.body),
              actions: [
                TextButton(
                  child: Text("Ok"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
    });
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('Message clicked!');
    });

  }

  Future<void> _messageHandler(RemoteMessage message) async {
    print('background message ${message.notification.body}');
  }

  void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_messageHandler);
    runApp(MyApp());
  }









  @override
  Widget build(BuildContext context) {
    print(
        "start build main page------------------------------------------------");
    final ThemeData theme = Theme.of(context);
    // print(userData.data());
    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: _scaffoldKey,
      drawer: Drawer(
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                child: MyDrawerHeader(
                  userData: userData,
                ),
              ),
            ),
            Expanded(
              child: ListView(children: [
                ListTile(
                  title: Text("Home"),
                  leading: Icon(Icons.home_outlined),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  title: Text("Setting"),
                  leading: Icon(Icons.settings_outlined),
                  onTap: () async {
                    await Navigator.of(context).push(PageRouteBuilder(
                      transitionDuration: Duration(milliseconds: 800),
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          SettingPage(
                              backGroundURL: userData['backGroundURL'],
                              userPhotoURL: userData['photoURL'],
                              themeMode: themeMode,
                              onThemeModeChanged: onThemeModeChanged,
                              flexSchemeData: flexSchemeData,
                              schemeIndex: schemeIndex,
                              onSchemeChanged: onSchemeChanged),
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
                    reloadUserDate();
                  },
                ),
                ListTile(
                  title: Text("Logout"),
                  leading: Icon(Icons.login_outlined),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('確定登出?'),
                          content: SingleChildScrollView(
                            child: ListBody(
                              children: <Widget>[
                                Text('你正在登出'),
                                Text("請確認是否要登出"),
                              ],
                            ),
                          ),
                          //TODO 處理一下登出的部分
                          actions: <Widget>[
                            TextButton(
                              child: Text('確定'),
                              onPressed: () async {
                                Navigator.of(context).pop();
                                await FirebaseAuth.instance.signOut();
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => InitialPage(
                                        themeMode: themeMode,
                                        onThemeModeChanged: onThemeModeChanged,
                                        flexSchemeData: flexSchemeData,
                                        schemeIndex: schemeIndex,
                                        onSchemeChanged: onSchemeChanged)));
                              },
                            ),
                            TextButton(
                              child: Text("取消"),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                )
              ]),
            )
          ],
        ),
      ),
      body: Stack(children: [
        Container(
          alignment: Alignment(0, 0.3),
          color: theme.primaryColorLight,
          child: FaIcon(
            FontAwesomeIcons.connectdevelop,
            color: theme.primaryColorDark,
            size: MediaQuery.of(context).size.width / 1.5,
          ),
        ),
        IndexedStack(
            index: _selectedIndex, children: _widgetOptions(context, theme))
      ]),
      bottomNavigationBar: ConvexAppBar(
        color: theme.bottomAppBarColor,
        activeColor: theme.bottomAppBarColor,
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            theme.primaryColorDark,
            theme.primaryColorLight,
            theme.primaryColorDark,
            theme.primaryColorLight,
            theme.primaryColorDark
          ],
          tileMode: TileMode.repeated,
        ),
        initialActiveIndex: _selectedIndex,
        style: TabStyle.reactCircle,
        items: [
          TabItem(icon: Icon(Icons.home), title: "Home"),
          TabItem(
            icon: Icon(Icons.comment),
            title: "Comment",
          ),
          // TabItem(icon: Icon(Icons.person),title:"myself")
        ],
        onTap: _onItemTapped,
      ),
    );
  }

  List<Widget> createFContainer(BuildContext context, List friendDetail) {
    List<Widget> list = [];
    for (int i = 0; i < friendDetail.length; i++) {
      list.add(OpenContainer(
        closedBuilder: (BuildContext context, VoidCallback openContainer) {
          final ThemeData theme = Theme.of(context);
          return Container(
            color: theme.colorScheme.secondary,
            alignment: Alignment.center,
            height: 100,
            child: Stack(
              children: [
                Container(
                    alignment: Alignment(0, -0.3),
                    child: FaceImage(
                      faceURL: friendDetail.elementAt(i)['photoUrl'],
                    )),
                Container(
                  alignment: Alignment.bottomCenter,
                  child: NameText(
                    userName: friendDetail.elementAt(i)['username'],
                    siz: 20,
                  ),
                ),
              ],
            ),
          );
          // ShortCutFriend(
          //   photoURL: friendDetail.elementAt(i)['photoURL'],
          //   username: friendDetail.elementAt(i)['username'],
          //   i: i);
        },
        openBuilder: (BuildContext context, VoidCallback openContainer) {
          return PersonDetailPage(
            friendEmail: friendDetail.elementAt(i)['email'],
          );
        },
        onClosed: (List list) {
          //TODO 開聊天房間
          // print(list);
          if (list != null) {
            //print(list);
            if (list[0] == 'sendMessage') _createChat(list);
          }
        },
      ));
    }
    return list;
  }




  List<Widget> createChatContainer(BuildContext context, List snapshot) {
    List<Widget> list = [];
    for (int i = 0; i < snapshot.length; i++) {
      Slidable con = Slidable(
          actionPane: SlidableScrollActionPane(),
          secondaryActions: <Widget>[
            IconSlideAction(
                caption: 'delete',
                color: Colors.white,
                icon: Icons.delete_outline,
                onTap: () => Fluttertoast.showToast(msg: "尚未開發")
                // _deleteMessage(i),
                )
          ],
          actionExtentRatio: 1 / 4,
          child: OpenContainer(
            closedBuilder: (BuildContext context, VoidCallback openContainer) {
              ThemeData theme = Theme.of(context);
              return ListTile(
                tileColor: theme.colorScheme.secondary,
                leading:snapshot[i]['photoUrl']==null?Container(
                    height: 90,
                    width: 90,
                    child: CircleAvatar(
                        backgroundColor: theme.primaryColor,
                        radius: 60,
                        child: Icon(
                          //TODO 未來支援圖片
                          Icons.person,
                          size: 45,
                          color: theme.secondaryHeaderColor,
                        ))):Container(
                  height: 90,
                  width: 90,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(image:NetworkImage(snapshot[i]['photoUrl']),)),
                ),
                title: Text(
                  snapshot[i]['roomName'],
                  style: TextStyle(fontSize: 30, color: theme.backgroundColor),
                ),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 15.0, horizontal: 0.0),
                subtitle: Text(
                  "壓著往左滑看看",
                  style: TextStyle(color: theme.backgroundColor),
                ),
              );
              //TODO 修正 shortCutChatRoom
              // ShortCutChatRoom(
              // name: snapshot[i]['roomName'],
              // i: i,
              // photoURL: snapshot[i]['photoURL'],
              // );
            },
            openBuilder: (BuildContext context, VoidCallback openContainer) {
              return ChatPage(
                  photoURL: snapshot[i]['photoUrl'],
                  roomId: snapshot[i]['roomID'],
                  roomName: snapshot[i]['roomName'],
                  user: userData);
            },
            onClosed: (element) {
              print('ad');
              setState(() {});
            },
          ));
      list.add(con);
    }
    return list;
  }

  Widget friendPage(ThemeData theme) {
    try {
      return CustomScrollView(
        key: ValueKey<int>(0),
        shrinkWrap: true,
        slivers: <Widget>[
          SliverAppBar(
              backgroundColor: theme.primaryColorDark,
              pinned: true,
              snap: true,
              floating: true,
              flexibleSpace: const FlexibleSpaceBar(
                title: Text('Friend'),
              ),
              leading: IconButton(
                icon: Icon(Icons.menu, size: 28),
                onPressed: () {
                  _scaffoldKey.currentState.openDrawer();
                },
              ),
              actions: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: IconButton(
                    alignment: Alignment.centerRight,
                    icon:
                        const Icon(Icons.person_add_alt, size: 24),
                    tooltip: 'Add Friend',
                    onPressed: () async {
                      // print("-------add---------");
                      // print(myself.account);
                      await Navigator.of(context).push(PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            AddFriendPage(),
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
                      setState(() {});
                    },
                  ),
                ),
              ]),
          FutureBuilder(
            future: users.doc(user.email).get(),
            builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.hasError) {
                return SliverGrid(
                  //用來建list 裡面再放東西
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 160.0,
                    childAspectRatio: 1.0,
                  ),
                  delegate: SliverChildListDelegate(<Widget>[
                    Container(
                      color: Colors.white,
                      alignment: Alignment.center,
                      child: Text("Something went wrong"),
                    )
                  ]),
                );
              }

              if (snapshot.connectionState == ConnectionState.done) {
                Map<String, dynamic> data = snapshot.data.data();
                friendList = createFContainer(context, data['friend']);
                return SliverGrid(
                  //用來建list 裡面再放東西
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 160.0,
                    childAspectRatio: 1.0,
                  ),
                  delegate: SliverChildListDelegate(
                    friendList,
                  ),
                );
              }

              return SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  childAspectRatio: 1.0,
                ),
                delegate: SliverChildListDelegate(<Widget>[
                  Container(alignment: Alignment.center, color: Colors.white10)
                ]),
              );
            },
          )
        ],
      );
    } catch (e) {
      //print('build friend page error');
      Map<String, dynamic> data = userData.data();
      print(data);
      friendList = createFContainer(context, data['friend']);
      return CustomScrollView(
          key: ValueKey<int>(0),
          shrinkWrap: true,
          slivers: <Widget>[
            SliverAppBar(
                backgroundColor: theme.primaryColorDark,
                pinned: true,
                snap: true,
                floating: true,
                expandedHeight: 80.0,
                flexibleSpace: const FlexibleSpaceBar(
                  title: Text('Friend'),
                ),
                leading: IconButton(
                  icon: Icon(Icons.menu, size: 30),
                  onPressed: () {
                    _scaffoldKey.currentState.openDrawer();
                  },
                ),
                actions: <Widget>[
                  IconButton(
                    alignment: Alignment.centerRight,
                    icon: const Icon(Icons.person_add_alt, size: 30),
                    tooltip: 'Add Friend',
                    onPressed: () async {
                      // print("-------add---------");
                      // print(myself.account);
                      await Navigator.of(context).push(PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            AddFriendPage(),
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
                      await reloadUserDate();
                    },
                  ),
                ]),
            SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.0,
              ),
              delegate: SliverChildListDelegate(
                friendList,
              ),
            )
          ]);
    }
  }

  Widget chatRoomPage(ThemeData theme) {
    try {
      Map<String, dynamic> map = userData.data();
      return CustomScrollView(
        key: ValueKey<int>(3),
        shrinkWrap: true,
        slivers: <Widget>[
          SliverAppBar(
            backgroundColor: theme.primaryColorDark,
            leading: IconButton(
              icon: Icon(Icons.menu, size: 28),
              onPressed: () {
                _scaffoldKey.currentState.openDrawer();
              },
            ),
            pinned: true,
            snap: true,
            floating: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Message',
              ),
            ),

            actions: [
              IconButton(
                  icon: Icon(Icons.more_vert_outlined),
                  onPressed: () {
                    showPopupWindow(
                      context,
                      offsetX: 5,
                      offsetY: 70,
                      //childSize:Size(240, 800),
                      gravity: KumiPopupGravity.rightTop,
                      //curve: Curves.elasticOut,
                      duration: Duration(milliseconds: 300),
                      bgColor: Colors.black.withOpacity(0),
                      onShowStart: (pop) {
                        print("showStart");
                      },
                      onShowFinish: (pop) {
                        print("showFinish");
                      },
                      onDismissStart: (pop) {
                        print("dismissStart");
                      },
                      onDismissFinish: (pop) {
                        print("dismissFinish");
                      },
                      onClickOut: (pop) {
                        print("onClickOut");
                      },
                      onClickBack: (pop) {
                        print("onClickBack");
                      },
                      childFun: (pop) {
                        return StatefulBuilder(

                            key: GlobalKey(),
                            builder: (popContext, popState) {
                              return Container(
                                padding: EdgeInsets.all(10),
                                height: 160,
                                width: 200,
                                color: Colors.black,
                                alignment: Alignment.center,
                                child: Column(
                                  children: <Widget>[
                                    ListTile(
                                        leading: Icon(
                                          Icons.add_circle,
                                          color: Colors.white,
                                        ),
                                        onTap: () {
                                          //Fluttertoast.showToast(msg: "尚未實作");
                                          // _cleanMessage();
                                          /*Navigator.of(context).pop([
                                            "sendMessage",
                                            user.email,
                                            map['username']
                                          ]);*/
                                          List group = ["sendMessage",user.email,map['username']];
                                          createGroupChat(group);
                                        },
                                        title: Text(
                                          "創建群組",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                    ),
                                    ListTile(

                                      leading: Icon(
                                        Icons.delete,
                                        color: Colors.white,
                                      ),
                                      onTap: () {
                                        Fluttertoast.showToast(msg: "尚未實作");
                                        // _cleanMessage();
                                        Navigator.of(context).pop();
                                      },
                                      title: Text(
                                        "全部刪除",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            });
                      },
                    );
                  })
            ],
          ),
          StreamBuilder(
              stream: users.doc(user.email).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  print("error snapshot");
                  return SliverList(
                      delegate: SliverChildListDelegate([
                    Container(
                      height: 100,
                      child: Text('Something went wrong'),
                    )
                  ]));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  print("loading");
                }
                if (snapshot.hasData) {
                  Map<String, dynamic> map = snapshot.data.data();
                  List _chatList = map['chatRoom'];
                  chatList = createChatContainer(context, _chatList);
                }

                // print(snapshot.data);
                return SliverList(
                  //用來建list 裡面再放東西
                  delegate: SliverChildListDelegate(
                    chatList,
                  ),
                );
              }),
        ],
      );
    } catch (e) {
      Map<String, dynamic> map = userData.data();
      List _chatList = map['chatRoom'];
      chatList = createChatContainer(context, _chatList);
      return CustomScrollView(
        key: ValueKey<int>(3),
        shrinkWrap: true,
        slivers: <Widget>[
          SliverAppBar(
            leading: IconButton(
              icon: Icon(Icons.menu, size: 30),
              onPressed: () {
                _scaffoldKey.currentState.openDrawer();
              },
            ),
            backgroundColor: theme.primaryColorDark,
            pinned: true,
            snap: true,
            floating: true,
            expandedHeight: 80.0,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Message',
                style: TextStyle(color: theme.backgroundColor),
              ),
            ),
            actions: [
              IconButton(
                  icon: Icon(Icons.more_vert),
                  onPressed: () {
                    showPopupWindow(
                      context,
                      offsetX: 5,
                      offsetY: 70,
                      //childSize:Size(240, 800),
                      gravity: KumiPopupGravity.rightTop,
                      //curve: Curves.elasticOut,
                      duration: Duration(milliseconds: 300),
                      bgColor: Colors.black.withOpacity(0),
                      onShowStart: (pop) {
                        print("showStart");
                      },
                      onShowFinish: (pop) {
                        print("showFinish");
                      },
                      onDismissStart: (pop) {
                        print("dismissStart");
                      },
                      onDismissFinish: (pop) {
                        print("dismissFinish");
                      },
                      onClickOut: (pop) {
                        print("onClickOut");
                      },
                      onClickBack: (pop) {
                        print("onClickBack");
                      },
                      childFun: (pop) {
                        return StatefulBuilder(
                            key: GlobalKey(),
                            builder: (popContext, popState) {
                              return Container(
                                padding: EdgeInsets.all(10),
                                height: 76,
                                width: 200,
                                color: Colors.black,
                                alignment: Alignment.center,
                                child: Column(
                                  children: <Widget>[
                                    ListTile(
                                      leading: Icon(
                                        Icons.add_circle,
                                        color: Colors.white,
                                      ),
                                      onTap: () {
                                        //Fluttertoast.showToast(msg: "尚未實作");
                                        // _cleanMessage();
                                        /*Navigator.of(context).pop([
                                          "sendMessage",
                                          user.email,
                                          map['username'],
                                          //print( map['username']),
                                        ]);*/
                                        List group = ["sendMessage",user.email,map['username']];
                                        createGroupChat(group);
                                      },
                                      title: Text(
                                        "創建群組",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    ListTile(
                                        leading: Icon(
                                          Icons.delete,
                                          color: Colors.white,
                                        ),
                                        onTap: () {
                                          Fluttertoast.showToast(msg: "尚未實作");
                                          // _cleanMessage();
                                          Navigator.of(context).pop();
                                        },
                                        title: Text(
                                          "全部刪除",
                                          style: TextStyle(color: Colors.white),
                                        ))
                                  ],
                                ),
                              );
                            });
                      },
                    );
                  })
            ],
          ),
          SliverList(
            //用來建list 裡面再放東西
            delegate: SliverChildListDelegate(
              chatList,
            ),
          )
        ],
      );
    }
  }

  void addChatRoom(String _email, String _id, String _roomName) async {
    DocumentSnapshot document = await users.doc(_email).get();
    List<Map<String, dynamic>> list = List.from(document.data()['chatRoom']);
    var addThing = {
      "roomName": _roomName,
      "roomID": _id,
      "photoUrl": null,
    };
    list.add(addThing);
    users.doc(_email).update({"chatRoom": list});

    // FirebaseFirestore.instance.runTransaction((transaction) async {
    //   DocumentSnapshot freshSnap =
    //   await transaction.get(document.reference);
    //   List<Map<String, dynamic>> list =
    //   List.from(freshSnap.data()['chatRoom']);
    //   var addThing = {
    //     "roomName": _roomName,
    //     "roomID": _id,
    //     "photoUrl": null,
    //   };
    //   list.add(addThing);
    //   transaction.update(freshSnap.reference, {
    //     "chatRoom": list,
    //   });
    // });
  }

  void _createChat(List list) async {
    CollectionReference chatRoom =
        FirebaseFirestore.instance.collection("chatRoom");
    String _roomName = "${userData['username']},${list[2]} Chat";

    DocumentReference reference = await chatRoom.add({
      'member': [list[1], user.email], // John Doe
      'roomName': _roomName, // Stokes and Sons
      'friendChat': true,
      'photoURL': null,
    });
    //reference.get().then((value) => value.data()['username']);
    //TODO 把雙方的聊天室增加這個剛健的聊天室
    //用function才會跑得比較快 同時跑兩個
    addChatRoom(user.email, reference.id, _roomName);

    //TODO 跳轉道 辣個 chatRoom
    //TODO 現有作法 創建後須等待幾秒才會出現
    Navigator.of(context).push(PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 800),
      pageBuilder: (context, animation, secondaryAnimation) => ChatPage(
          roomName: _roomName,
          roomId: reference.id,
          photoURL: null,
          user: userData),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(0.0, 1.0);
        var end = Offset.zero;
        var curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    ));

    addChatRoom(list[1], reference.id, _roomName);
  }

  void createGroupChat(List list) async {
    CollectionReference chatRoom =
    FirebaseFirestore.instance.collection("chatRoom");
    String _roomName = "${userData['username']} Chat";
    DocumentReference reference = await chatRoom.add({
      'member': [ user.email], // John Doe
      'roomName': _roomName, // Stokes and Sons
      'friendChat': true,
      'photoURL': null,
    });

    //TODO 把雙方的聊天室增加這個剛健的聊天室
    //用function才會跑得比較快 同時跑兩個
    addChatRoom(user.email, reference.id, _roomName);

    //TODO 跳轉道 辣個 chatRoom
    //TODO 現有作法 創建後須等待幾秒才會出現
    Navigator.of(context).push(PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 800),
      pageBuilder: (context, animation, secondaryAnimation) => ChatPage(
          roomName: _roomName,
          roomId: reference.id,
          photoURL: null,
          user: userData),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(0.0, 1.0);
        var end = Offset.zero;
        var curve = Curves.ease;

        var tween =
        Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    ));

    //addChatRoom(list[1], reference.id, _roomName);
  }

  void _cleanMessage() {}

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _deleteMessage(int index) {}

  Future<void> reloadUserDate() async {
    EasyLoading.show(status: 'loading...');
    DocumentSnapshot data = await users.doc(user.email).get();
    setState(() {
      userData = data;
    });
    EasyLoading.dismiss();
  }
}

class MyDrawerHeader extends StatelessWidget {
  final DocumentSnapshot userData;

  MyDrawerHeader({this.userData});

  @override
  Widget build(BuildContext context) {
    return userData['backGroundURL'] != null
        ? DrawerHeader(
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                image: DecorationImage(
                    image: NetworkImage(userData['backGroundURL']),
                    fit: BoxFit.cover)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                FaceImage(
                  faceURL: userData['photoURL'],
                ),
                Divider(),
                NameText(
                  userName: userData['username'],
                  siz: 30,
                )
              ],
            ),
          )
        : DrawerHeader(
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("images/2.jpg"), fit: BoxFit.cover)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                FaceImage(
                  faceURL: userData['photoURL'],
                ),
                Divider(),
                NameText(
                  userName: userData['username'],
                  siz: 30,
                )
              ],
            ));
  }
}
