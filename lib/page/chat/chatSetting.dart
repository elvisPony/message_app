import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_storage/firebase_storage.dart'as firebase_storage;

class ChatSetting extends StatefulWidget {
  final String docId;
  final String photoURL;
  final String roomName;
  final List member;

  ChatSetting(
      {@required this.docId,
      @required this.photoURL,
      @required this.roomName,
      @required this.member});

  _ChatSetting createState() => _ChatSetting(
      docId: docId, photoURL: photoURL, roomName: roomName, member: member);
}

class _ChatSetting extends State<ChatSetting> {
  final String docId;
  String photoURL;
  String roomName;
  List member;

  //TODO 未來問題 更改明子後這邊也得更改

  bool modifyName = false;
  final TextEditingController controller = TextEditingController();

  _ChatSetting(
      {@required this.docId,
        @required this.photoURL,
        @required this.roomName,
        @required this.member});

  @override
  Widget build(BuildContext context) {
    controller.text = roomName;
    // print('chatSetting');
    // print(photoURL);
    return Scaffold(
        appBar: AppBar(
          title: Text("Chat Setting"),
        ),
        body: Stack(children: [
          Container(
            color: Theme.of(context).primaryColor,
          ),
          ListView(
            children: [
              Stack(children: [
                photoURL != null
                    ? Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 2,
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      image: DecorationImage(
                          image: NetworkImage(photoURL),
                          fit: BoxFit.cover)),
                )
                    : Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 2,
                  color: Theme.of(context).colorScheme.secondary,
                  child: Center(
                    child: Text(
                      "no picture",
                      style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width / 5,
                          color: Theme.of(context).backgroundColor),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: GestureDetector(
                    onTap: () => myBottomSheet(context),
                    child: Container(
                      padding: EdgeInsets.all(10),
                      height: 60,
                      width: 60,
                      // color: Colors.yellow,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.black38,
                        child: FaIcon(
                          FontAwesomeIcons.camera,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),

              ]),
              modifyName == false
                  ? Container(
                padding: EdgeInsets.all(15),
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width,
                height: 100,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        roomName,
                        style: TextStyle(
                            color: Theme.of(context).backgroundColor,
                            fontSize: 35),
                      ),
                      IconButton(
                          icon: FaIcon(FontAwesomeIcons.pencilAlt),
                          onPressed: () {
                            setState(() {
                              modifyName = true;
                            });
                          })
                    ]),
              )
                  : Container(
                  padding: EdgeInsets.all(15),
                  alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width,
                  height: 100,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          height: 100,
                          width: MediaQuery.of(context).size.width / 1.5,
                          child: TextField(
                            controller: controller,
                          )),
                      IconButton(
                          icon: FaIcon(FontAwesomeIcons.check),
                          onPressed: () {
                            //TODO 更改當前葉面 所有member 的 chatroom ID 等等
                            changeRoomName();
                          })
                    ],
                  )),
              Container(
                height: 50,
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.only(right: 20),
                child: Text(
                  'member',
                  style: TextStyle(
                      color: Theme.of(context).backgroundColor, fontSize: 20),
                ),
                alignment: Alignment.bottomCenter,
              ),
              Divider(
                  height: 4.0,
                  indent: 20.0,
                  endIndent: 20,
                  color: Colors.orangeAccent),
              Container(
                height: 100,
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.only(right: 20),
              )
              //TODO 放個 grid存放到底有些誰
            ],
          ),
        ]));
  }

  void uploadPhoto(_source) async {
    //changeWhere 0改背景 1改大頭貼
    // 先從 _source 獲取照片資訊並上傳至
    File _image;
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: _source);
    if(pickedFile==null) return ;
    EasyLoading.show(status: 'loading...');
    String subTitle = pickedFile.path.toString().split('.').last;
    File file = File(pickedFile.path);
    // print(pickedFile.runtimeType);
    String download;
    try {
      TaskSnapshot snapshot = await firebase_storage.FirebaseStorage.instance
          .ref('chatRoom/' +
          '/' +
          docId)
          .putFile(file);
      download = await snapshot.ref.getDownloadURL();
      //_submitContent(download, 'image');
    } catch (e) {
      EasyLoading.dismiss();
      print(e);
      // e.g, e.code == 'canceled'
    }
    print(download);
    //修改firestore內部使用者資料

    CollectionReference chatRoom = FirebaseFirestore.instance.collection('chatRoom');
    chatRoom
        .doc(docId)
        .update({"photoURL": download});
    print('update success');
    DocumentSnapshot data = await chatRoom.doc(docId).get();
    member = data.data()['member'];
    print("chatRoom change success");
    // print(member[0].runtimeType);
    CollectionReference user = FirebaseFirestore.instance.collection('users');
    for (int i = 0; i < member.length; i++) {
      DocumentSnapshot userData = await user.doc(member[i]).get();
      List chatRoom = userData.data()['chatRoom'];
      int rom = chatRoom.indexWhere((element) {
        return (element['roomID'] == docId);
      });
      chatRoom[rom]['photoUrl'] = download;
      user.doc(member[i]).update({"chatRoom": chatRoom});
    }
    print("user change success");
    EasyLoading.dismiss();
    setState(() {
      photoURL = download;
    });
    EasyLoading.dismiss();
    //從新刷新
    Navigator.of(context).pop();
    setState(() {});
  }

  void myBottomSheet(BuildContext context) {
    // showBottomSheet || showModalBottomSheet
    showModalBottomSheet<void>(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 120,
            child: ListView(
              children: [
                ListTile(
                  title: Text(
                    "從相片挑選",
                  ),
                  onTap: () => uploadPhoto(ImageSource.gallery),
                ),
                ListTile(
                  title: Text("相機拍照"),
                  onTap: () => uploadPhoto(ImageSource.camera),
                ),
              ],
            ),
          );
        });
  }

  void changeRoomName() async {
    EasyLoading.show(status: 'loading...');
    String newName = controller.text;
    CollectionReference chatRoom =
    FirebaseFirestore.instance.collection('chatRoom');
    chatRoom.doc(docId).update({"roomName": newName});
    DocumentSnapshot data = await chatRoom.doc(docId).get();
    member = data.data()['member'];
    print("chatRoom change success");
    // print(member[0].runtimeType);
    CollectionReference user = FirebaseFirestore.instance.collection('users');
    for (int i = 0; i < member.length; i++) {
      DocumentSnapshot userData = await user.doc(member[i]).get();
      List chatRoom = userData.data()['chatRoom'];
      int rom = chatRoom.indexWhere((element) {
        return (element['roomID'] == docId);
      });
      chatRoom[rom]['roomName'] = newName;
      user.doc(member[i]).update({"chatRoom": chatRoom});
    }
    print("user change success");
    EasyLoading.dismiss();
    setState(() {
      roomName = newName;
      modifyName = false;
    });
  }

}