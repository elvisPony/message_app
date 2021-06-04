import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:message_app/page/person.dart';

import '../all_shared_imports.dart';

// Create a custom flex scheme color for a light theme.
const FlexSchemeColor myScheme1Light = FlexSchemeColor(
  primary: Color(0xFF4E0028),
  primaryVariant: Color(0xFF320019),
  secondary: Color(0xFF003419),
  secondaryVariant: Color(0xFF002411),
  // The built in schemes use their secondary variant color as their
  // custom app bar color, it could of course be any color, but for consistency
  // we will do the same in this custom FlexSchemeColor.
  appBarColor: Color(0xFF002411),
);
// Create a corresponding custom flex scheme color for a dark theme.
const FlexSchemeColor myScheme1Dark = FlexSchemeColor(
  primary: Color(0xFF9E7389),
  primaryVariant: Color(0xFF775C69),
  secondary: Color(0xFF738F81),
  secondaryVariant: Color(0xFF5C7267),
  // Again we use same secondaryVariant color as optional custom app bar color.
  appBarColor: Color(0xFF5C7267),
);

// You can build a scheme the long way, by specifying all the required hand
// picked scheme colors, like above, or can also build schemes from a
// single primary color. With the [.from] factory, then the only required color
// is the primary color, the other colors will be computed. You can optionally
// also provide the primaryVariant, secondary and secondaryVariant colors with
// the factory, but any color that is not provided will always be computed for
// the full set of required colors in a FlexSchemeColor.

// In this example we create our 2nd scheme from just a primary color
// for the light and dark schemes. The custom app bar color will in this case
// also receive the same color value as the one that is computed for
// secondaryVariant color, this is the default with the [from] factory.
final FlexSchemeColor myScheme2Light =
    FlexSchemeColor.from(primary: const Color(0xFF4C4E06));
final FlexSchemeColor myScheme2Dark =
    FlexSchemeColor.from(primary: const Color(0xFF9D9E76));

// For our 3rd custom scheme we will define primary and secondary colors, but no
// variant colors, we will not make any dark scheme definitions either.
final FlexSchemeColor myScheme3Light = FlexSchemeColor.from(
  primary: const Color(0xFF993200),
  secondary: const Color(0xFF1B5C62),
);

// Create a list with all color schemes we will use, starting with all
// the built-in ones and then adding our custom ones at the end.
final List<FlexSchemeData> myFlexSchemes = <FlexSchemeData>[
  // Use the built in FlexColor schemes, but exclude the placeholder for custom
  // scheme, a selection that would typically be used to compose a theme
  // interactively in the app using a color picker, we won't be doing that in
  // this example.
  ...FlexColor.schemesList,
  // Then add our first custom FlexSchemeData to the list, we give it a name
  // and description too.
  const FlexSchemeData(
    name: 'Toledo purple',
    description: 'Purple theme, created from full custom defined color scheme.',
    // FlexSchemeData holds separate defined color schemes for light and
    // matching dark theme colors. Dark theme colors need to be much less
    // saturated than light theme. Using the same colors in light and dark
    // theme modes does not look nice.
    light: myScheme1Light,
    dark: myScheme1Dark,
  ),
  // Do the same for our second custom scheme.
  FlexSchemeData(
    name: 'Olive green',
    description:
        'Olive green theme, created from primary light and dark colors.',
    light: myScheme2Light,
    dark: myScheme2Dark,
  ),
  // We also do the same for our 3rd custom scheme, BUT we create its matching
  // dark colors, from the light FlexSchemeColor with the toDark method.
  FlexSchemeData(
    name: 'Oregon orange',
    description: 'Custom orange and blue theme, from only light scheme colors.',
    light: myScheme3Light,
    // We create the dark desaturated colors from the light scheme.
    dark: myScheme3Light.toDark(),
  ),
];

class SettingPage extends StatelessWidget {
  SettingPage(
      {@required this.themeMode,
      @required this.onThemeModeChanged,
      @required this.schemeIndex,
      @required this.onSchemeChanged,
      @required this.flexSchemeData,
      @required this.userPhotoURL,
      @required this.backGroundURL});

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final int schemeIndex;
  final ValueChanged<int> onSchemeChanged;
  final FlexSchemeData flexSchemeData;

  final String backGroundURL;
  final String userPhotoURL;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: FaIcon(
            FontAwesomeIcons.times,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Container(
          alignment: Alignment(-0.2, 0),
          child: Text(
            "設定",
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ListTile(
              title: Text("個人設定"),
              leading: Icon(
                Icons.account_circle_outlined,
              ),
              onTap: () => Navigator.of(context).push(PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    PersonSettingPage(
                        backGroundURL: backGroundURL,
                        userPhotoURL: userPhotoURL),
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
              )),
            ),
            ListTile(
              title: Text("主題設定"),
              leading: Icon(Icons.color_lens_outlined),
              onTap: () => Navigator.of(context).push(PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    ThemePage(
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
              )),
            ),
          ],
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class PersonSettingPage extends StatefulWidget {
  String backGroundURL;
  String userPhotoURL;

  PersonSettingPage(
      {@required this.backGroundURL, @required this.userPhotoURL});

  _PersonSettingPage createState() => _PersonSettingPage();
}

class _PersonSettingPage extends State<PersonSettingPage> {
  FirebaseAuth auth;

  _PersonSettingPage();

  @override
  void initState() {
    Firebase.initializeApp();
    super.initState();
    auth = FirebaseAuth.instance;
  }

  void uploadPhoto(_source, int changeWhere) async {
    //changeWhere 0改背景 1改大頭貼
    // 先從 _source 獲取照片資訊並上傳至
    File _image;
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: _source);

    EasyLoading.show(status: 'loading...');
    String subTitle = pickedFile.path.toString().split('.').last;
    File file = File(pickedFile.path);
    // print(pickedFile.runtimeType);
    String download;
    String changeWhereString =
        (changeWhere == 0) ? 'backGroundURL' : 'photoURL';
    try {
      TaskSnapshot snapshot = await firebase_storage.FirebaseStorage.instance
          .ref('user/' +
              changeWhereString +
              '/' +
              auth.currentUser.email.toString())
          .putFile(file);
      download = await snapshot.ref.getDownloadURL();
      //_submitContent(download, 'image');
    } catch (e) {
      print(e);
      // e.g, e.code == 'canceled'
    }
    print(download);
    //修改firestore內部使用者資料
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    await users
        .doc(auth.currentUser.email)
        .update({changeWhereString: download});

    EasyLoading.dismiss();
    //從新刷新
    Navigator.of(context).pop();
    setState(() {});
  }

  void myBottomSheet(BuildContext context, int changeWhere) {
    //type 0改背景 1改大頭貼

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
                  onTap: () => uploadPhoto(ImageSource.gallery, changeWhere),
                ),
                ListTile(
                  title: Text("相機拍照"),
                  onTap: () => uploadPhoto(ImageSource.camera, changeWhere),
                ),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(auth.currentUser.email)
            .get(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            EasyLoading.dismiss();
            return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: FaIcon(
                    FontAwesomeIcons.times,
                    color: Colors.black,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                title: Center(
                  child: Text(
                    "個人資料",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                backgroundColor: Colors.white,
              ),
              body: ListView(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height / 2,
                    width: MediaQuery.of(context).size.width,
                    child: Stack(
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.height / 2,
                          width: MediaQuery.of(context).size.width,
                          // alignment: Alignment.center,
                          child: GestureDetector(
                            onTap: () => myBottomSheet(context, 0),
                            child: BackGroundImage(
                              imageURL: snapshot.data.data()['backGroundURL'],
                              siz: MediaQuery.of(context).size.width / 1.5,
                            ),
                          ),
                        ),
                        Center(
                          child: GestureDetector(
                            onTap: () => myBottomSheet(context, 1),
                            child: FaceImage(
                              faceURL: snapshot.data.data()['photoURL'],
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: GestureDetector(
                            onTap: () => myBottomSheet(context, 0),
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
                        Align(
                          alignment: Alignment(0.2, 0.2),
                          child: GestureDetector(
                            onTap: () => myBottomSheet(context, 1),
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
                      ],
                    ),
                  ),
                  //BIO
                  Container(
                    height: MediaQuery.of(context).size.height / 2,
                    child: Center(
                      child: TextField(),
                    ),
                  ),
                ],
              ),
            );
          }
          EasyLoading.show(status: 'loading...');
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: FaIcon(
                  FontAwesomeIcons.times,
                  color: Colors.black,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Center(
                child: Text(
                  "個人資料",
                  style: TextStyle(color: Colors.black),
                ),
              ),
              backgroundColor: Colors.white,
            ),
            body: ListView(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height / 2,
                  child: Stack(
                    children: [
                      GestureDetector(
                          onTap: () => myBottomSheet(context, 0),
                          child: Container(
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: AssetImage("images/2.jpg"),
                                      fit: BoxFit.cover)))),
                      Center(
                        child: GestureDetector(
                          onTap: () => myBottomSheet(context, 1),
                          child: FaceImage(
                            faceURL: null,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: GestureDetector(
                          onTap: () => myBottomSheet(context, 0),
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
                      Align(
                        alignment: Alignment(0.2, 0.2),
                        child: GestureDetector(
                          onTap: () => myBottomSheet(context, 1),
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
                    ],
                  ),
                ),
                //BIO
                Container(
                  height: MediaQuery.of(context).size.height / 2,
                  child: Center(
                    child: TextField(),
                  ),
                ),
              ],
            ),
          );
        });
  }
}

class ThemePage extends StatelessWidget {
  const ThemePage({
    Key key,
    @required this.themeMode,
    @required this.onThemeModeChanged,
    @required this.schemeIndex,
    @required this.onSchemeChanged,
    @required this.flexSchemeData,
  }) : super(key: key);
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final int schemeIndex;
  final ValueChanged<int> onSchemeChanged;
  final FlexSchemeData flexSchemeData;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;
    final TextStyle headline4 = textTheme.headline4;
    final bool isLight = Theme.of(context).brightness == Brightness.light;
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    final PageController previewController = PageController(initialPage: 0);
    List<Widget> lis = <Widget>[
      Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
        child: previewSVGChatRoom(theme),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
        child: previewSVGChatPage(theme),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
        child: previewSVGHomePage(theme),
      ),
    ];

    return Row(
      children: <Widget>[
        const SizedBox(width: 0.01),
        Expanded(
          child: Scaffold(
            appBar: AppBar(
              title: const Text('主題設定'),
              actions: const <Widget>[AboutIconButton()],
            ),
            body: PageBody(
              child: ListView(
                padding: const EdgeInsets.all(AppConst.edgePadding),
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: FlexThemeModeSwitch(
                      title: Text(
                        "顯示模式",
                        style: textTheme.subtitle1,
                      ),
                      themeMode: themeMode,
                      onThemeModeChanged: onThemeModeChanged,
                      flexSchemeData: flexSchemeData,
                      showSystemMode: false,
                      optionButtonBorderRadius: 50,
                      optionButtonMargin: EdgeInsets.all(12.0),
                    ),
                  ),
                  const Divider(),
                  // Popup menu button to select color scheme.
                  PopupMenuButton<int>(
                    padding: const EdgeInsets.all(0),
                    onSelected: onSchemeChanged,
                    itemBuilder: (BuildContext context) => <PopupMenuItem<int>>[
                      for (int i = 0; i < myFlexSchemes.length; i++)
                        PopupMenuItem<int>(
                          value: i,
                          child: ListTile(
                            leading: Icon(Icons.lens,
                                color: isLight
                                    ? myFlexSchemes[i].light.primary
                                    : myFlexSchemes[i].dark.primary,
                                size: 35),
                            title: Text(myFlexSchemes[i].name),
                          ),
                        )
                    ],
                    child: ListTile(
                      // title: Text('${myFlexSchemes[schemeIndex].name} theme123'),
                      // subtitle: Text(myFlexSchemes[schemeIndex].description),
                      title: Text(
                        '主題顏色',
                        style: textTheme.subtitle1,
                      ),
                      subtitle: Text('選擇主題配色'),
                      trailing: Icon(
                        Icons.lens,
                        color: colorScheme.primary,
                        size: 40,
                      ),
                    ),
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
                    child: Text(
                      'Preview',
                      style: textTheme.subtitle1,
                    ),
                  ),
                  Container(
                    height: height / 3 * 2,
                    alignment: Alignment.center,
                    child: Swiper(
                      // autoplay: true,
                      itemCount: 3,
                      itemBuilder: (BuildContext context, int index) {
                        return lis.elementAt(index);
                      },
                      itemWidth: 300.0,
                      layout: SwiperLayout.STACK,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Theme Page Theme Preview SVG (不直接使用 SVG 因為 flutter 無法對 svg element 修改)
  // <defs> 對 SVG 檔案定義變數
  Widget previewSVGChatPage(ThemeData theme) {
    return SvgPicture.string('''
      <svg height="667" viewBox="0 0 375 667" width="375" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <clipPath id="clip-ChatPage_1">
      <rect height="667" width="375" />
    </clipPath>
  </defs>
  <g clip-path="url(#clip-ChatPage_1)" data-name="ChatPage – 1" id="ChatPage_1">
    <rect fill="#''' +
        theme.backgroundColor.hexCode +
        '''" height="667" width="375" />
        <path id="connectdevelop-brands" d="M268.126,122.639l-23.74-41.133a7.627,7.627,0,0,0,.889-3.428,7.242,7.242,0,0,0-6.982-7.11L212.013,25.52a7.408,7.408,0,0,0,.508-2.285,7.22,7.22,0,0,0-12.822-4.57H149.172a6.922,6.922,0,0,0-10.918,0H87.981a7.22,7.22,0,0,0-12.822,4.57,6.676,6.676,0,0,0,.508,2.285L49.133,71.6a7.1,7.1,0,0,0-4.316,6.475c0,.254.127.508.127.762L19.68,122.513a7.222,7.222,0,0,0-5.967,7.109,7.33,7.33,0,0,0,5.713,7.109l26.152,45.2a6.635,6.635,0,0,0-.381,2.285,7.086,7.086,0,0,0,5.713,6.982l24.5,42.529a8.2,8.2,0,0,0-.508,2.539,7.233,7.233,0,0,0,7.236,7.236,7.01,7.01,0,0,0,5.459-2.539h50.654a7.138,7.138,0,0,0,10.918,0h50.781a7.091,7.091,0,0,0,5.2,2.285,7.233,7.233,0,0,0,7.236-7.236,5.258,5.258,0,0,0-.381-2.031l24.5-42.783a7.086,7.086,0,0,0,5.713-6.982,7.184,7.184,0,0,0-.381-2.285l26.025-45.2a7.232,7.232,0,0,0,5.84-7.109A7.1,7.1,0,0,0,268.126,122.639Zm-188.144,99.4L59.289,186.116H79.982Zm0-39.736H59.289a7.8,7.8,0,0,0-.635-1.523l21.328-22.47Zm0-29.58L56.115,177.991a11.863,11.863,0,0,0-1.9-.762l-26.405-45.7a4.941,4.941,0,0,0,.254-1.9,6.7,6.7,0,0,0-.127-1.65L52.561,85.315a8,8,0,0,0,3.682-1.27l23.74,24.629v44.052Zm0-48.5L58.274,81.761a6.941,6.941,0,0,0,1.016-3.681c0-.127-.127-.381-.127-.508l20.82-7.49Zm0-38.213-20.693,7.49,20.693-35.8ZM234.738,84.554l.381.635-16.758,79.218-30.215-31.865,46.465-48.115ZM145.49,176.721l5.459,5.586H140.158Zm-.127-5.332-39.482-40.5,37.7-39.99,39.355,41.513Zm2.539,2.793,37.578-38.974,31.992,33.769-2.793,13.33H155.9ZM201.73,29.456a6.367,6.367,0,0,0,1.65.635L230.8,77.826v.254a6.937,6.937,0,0,0,1.016,3.681l-46.211,47.988L146.252,88.235Zm-4.316-1.016-53.828,57L116.545,56.878l78.837-28.437h2.032Zm-58.525,0a6.746,6.746,0,0,0,9.649,0h35.547l-70.332,25.39L89.631,28.441Zm-55.1,2.666.508-1.015q.642-.164,1.27-.381l24.248,25.518L83.792,64.623Zm0,37.578,28.818-10.41,28.31,29.961-37.7,39.863L83.792,108.167Zm0,43.925,17.265,17.9L83.792,148.665V112.61Zm0,41.641,19.931-21.074,39.228,40.752-8.125,8.379H83.792Zm3.3,76.806a6.818,6.818,0,0,0-2.793-1.65l-.508-.762V186.116h47.353L87.727,231.057Zm61.572,0a7.051,7.051,0,0,0-9.9,0h-45.7l43.418-44.941H154.63l43.418,44.941H148.664Zm56.875-5.586-2.031,3.555a6.381,6.381,0,0,0-1.65.635l-42.275-43.545h54.209l-8.253,39.355Zm6.093-10.537,6.094-28.818h10.41Zm16.5-32.627h-9.648l2.158-10.029,8.125,8.633a4.7,4.7,0,0,0-.635,1.4ZM259.493,131.4l-26.279,45.83a12.8,12.8,0,0,0-1.9.888l-9.775-10.41,16.377-77.695,21.709,37.578a9.646,9.646,0,0,0-.381,2.031A8.57,8.57,0,0,0,259.493,131.4Z" transform="translate(44.287 204.001)" fill="#''' +
        theme.primaryColorDark.hexCode +
        '''"/>
    <g data-name="Friend Chat-1" id="Friend_Chat-1" transform="translate(-17 -31)">
      <rect data-name="Rectangle 10" fill="#''' +
        theme.cardColor.hexCode +
        '''" height="79" id="Rectangle_10"
          transform="translate(17 99)" width="375" />
      <text data-name="Jeff / 打球群" font-family="SegoeUI, Segoe UI" font-size="21" id="Jeff_打球群"
          letter-spacing="0.033em" transform="translate(177 148)" fill="#''' +
        theme.colorScheme.onBackground.hexCode +
        '''">
        <tspan x="-60.305" y="0">Jeff / 打球群</tspan>
      </text>
      <g id="jeff" transform="translate(42 114)">
        <circle cx="25" cy="25" data-name="Ellipse 3" fill="#0d8abc" id="Ellipse_3" r="25" />
        <text fill="#fff" font-family="SegoeUI, Segoe UI" font-size="22" id="JE"
            transform="translate(25 34)">
          <tspan x="-12.491" y="0">JE</tspan>
        </text>
      </g>
    </g>
    <g data-name="Friend Chat-2" id="Friend_Chat-2" transform="translate(-17 48)">
      <rect data-name="Rectangle 10" fill="#''' +
        theme.cardColor.hexCode +
        '''" height="79" id="Rectangle_10-2"
          transform="translate(17 99)" width="375" />
      <text data-name="Jeff / 古蹟文化交流" font-family="SegoeUI, Segoe UI" font-size="21" id="Jeff_古蹟文化交流"
          letter-spacing="0.033em" transform="translate(210 148)" fill="#''' +
        theme.colorScheme.onBackground.hexCode +
        '''">
        <tspan x="-92.855" y="0">Jeff / 古蹟文化交流</tspan>
      </text>
      <g data-name="jeff" id="jeff-2" transform="translate(42 114)">
        <circle cx="25" cy="25" data-name="Ellipse 3" fill="#0d8abc" id="Ellipse_3-2" r="25" />
        <text data-name="JE" fill="#fff" font-family="SegoeUI, Segoe UI" font-size="22" id="JE-2"
            transform="translate(25 34)">
          <tspan x="-12.491" y="0">JE</tspan>
        </text>
      </g>
    </g>
    <g data-name="Friend Chat-3" id="Friend_Chat-3" transform="translate(-17 127)">
      <rect data-name="Rectangle 10" fill="#''' +
        theme.cardColor.hexCode +
        '''" height="79" id="Rectangle_10-3"
          transform="translate(17 99)" width="375" />
      <text data-name="Zhon / o敏捷o" font-family="SegoeUI, Segoe UI" font-size="21" id="Zhon_o敏捷o"
          letter-spacing="0.033em" transform="translate(188 148)" fill="#''' +
        theme.colorScheme.onBackground.hexCode +
        '''">
        <tspan x="-70.673" y="0">Zhon / o 敏捷 o</tspan>
      </text>
      <g id="zhon" transform="translate(42 114)">
        <circle cx="25" cy="25" data-name="Ellipse 2" fill="#b4f8c8" id="Ellipse_2" r="25" />
        <text font-family="SegoeUI, Segoe UI" font-size="22" id="ZH"
            transform="translate(25 33.741)">
          <tspan x="-14.083" y="0">ZH</tspan>
        </text>
      </g>
    </g>
    <g id="AppBar">
      <rect data-name="Rectangle 1" fill="#''' +
        theme.primaryColor.hexCode +
        '''" height="68" id="Rectangle_1" width="375" />
      <text fill="#f2f2f7" font-family="SegoeUI, Segoe UI" font-size="26" id="Message"
          transform="translate(68 43)">
        <tspan x="0" y="0">Message</tspan>
      </text>
      <g id="baseline-menu-24px" transform="translate(22 20)">
        <path d="M0,0H28V28H0Z" data-name="Path 2012" fill="none" id="Path_2012" />
        <path d="M3,21.6H23.2V19H3Zm0-6.5H23.2V12.5H3ZM3,6V8.6H23.2V6Z" data-name="Path 2013"
            fill="#f2f2f7"
            id="Path_2013" transform="translate(0.899 0.201)" />
      </g>
      <g id="baseline-more_vert-24px" transform="translate(333 22)">
        <path d="M0,0H24V24H0Z" data-name="Path 2016" fill="none" id="Path_2016" />
        <path d="M12,8a2,2,0,1,0-2-2A2.006,2.006,0,0,0,12,8Zm0,2a2,2,0,1,0,2,2A2.006,2.006,0,0,0,12,10Zm0,6a2,2,0,1,0,2,2A2.006,2.006,0,0,0,12,16Z" data-name="Path 2017"
            fill="#f2f2f7"
            id="Path_2017" />
      </g>
    </g>
    <g id="BottomNavBar">
      <rect data-name="Rectangle 128" fill="#''' +
        theme.primaryColorDark.hexCode +
        '''" height="68" id="Rectangle_128"
          transform="translate(0 599)" width="375" />
      <circle cx="54" cy="54" data-name="Ellipse 5" fill="#''' +
        theme.primaryColorDark.hexCode +
        '''" id="Ellipse_5"
          r="54" transform="translate(215 579)" />
      <circle cx="39" cy="39" data-name="Ellipse 4" fill="#''' +
        theme.backgroundColor.hexCode +
        '''" id="Ellipse_4"
          r="39" transform="translate(230 585)" />
      <g id="baseline-message-24px" transform="translate(255 611)">
        <path d="M4.4,2H23.6a2.4,2.4,0,0,1,2.388,2.4L26,26l-4.8-4.8H4.4A2.407,2.407,0,0,1,2,18.8V4.4A2.407,2.407,0,0,1,4.4,2ZM6.8,16.4H21.2V14H6.8Zm0-3.6H21.2V10.4H6.8Zm0-3.6H21.2V6.8H6.8Z" data-name="Path 853"
            id="Path_853" fill="#''' +
        theme.colorScheme.onBackground.hexCode +
        '''"/>
        <path d="M28,0H0V28H28Z" data-name="Path 854" fill="none" id="Path_854" />
      </g>
      <g id="baseline-home-24px" transform="translate(99 610)">
        <path d="M11.6,24V16.588h4.8V24h6V14.118H26L14,3,2,14.118H5.6V24Z" data-name="Path 304"
            id="Path_304" fill="#''' +
        theme.colorScheme.onBackground.hexCode +
        '''"/>
        <path d="M0,0H28V28H0Z" data-name="Path 305" fill="none" id="Path_305" />
      </g>
      <text font-family="SegoeUI, Segoe UI" font-size="15" id="Home" letter-spacing="0.033em"
          transform="translate(113 660)" fill="#''' +
        theme.colorScheme.onBackground.hexCode +
        '''">
        <tspan x="-20.851" y="0">Home</tspan>
      </text>
    </g>
  </g>
</svg>

      
      ''');
  }

  Widget previewSVGHomePage(ThemeData theme) {
    return SvgPicture.string('''
    
    <svg xmlns="http://www.w3.org/2000/svg" width="375" height="667" viewBox="0 0 375 667">
  <defs>
    <clipPath id="clip-HomePage_1">
      <rect width="375" height="667" />
    </clipPath>
  </defs>
  <g id="HomePage_1" data-name="HomePage – 1" clip-path="url(#clip-HomePage_1)">
    <rect width="375" height="667" fill="#''' +
        theme.backgroundColor.hexCode +
        '''" />
        <path id="connectdevelop-brands" d="M268.126,122.639l-23.74-41.133a7.627,7.627,0,0,0,.889-3.428,7.242,7.242,0,0,0-6.982-7.11L212.013,25.52a7.408,7.408,0,0,0,.508-2.285,7.22,7.22,0,0,0-12.822-4.57H149.172a6.922,6.922,0,0,0-10.918,0H87.981a7.22,7.22,0,0,0-12.822,4.57,6.676,6.676,0,0,0,.508,2.285L49.133,71.6a7.1,7.1,0,0,0-4.316,6.475c0,.254.127.508.127.762L19.68,122.513a7.222,7.222,0,0,0-5.967,7.109,7.33,7.33,0,0,0,5.713,7.109l26.152,45.2a6.635,6.635,0,0,0-.381,2.285,7.086,7.086,0,0,0,5.713,6.982l24.5,42.529a8.2,8.2,0,0,0-.508,2.539,7.233,7.233,0,0,0,7.236,7.236,7.01,7.01,0,0,0,5.459-2.539h50.654a7.138,7.138,0,0,0,10.918,0h50.781a7.091,7.091,0,0,0,5.2,2.285,7.233,7.233,0,0,0,7.236-7.236,5.258,5.258,0,0,0-.381-2.031l24.5-42.783a7.086,7.086,0,0,0,5.713-6.982,7.184,7.184,0,0,0-.381-2.285l26.025-45.2a7.232,7.232,0,0,0,5.84-7.109A7.1,7.1,0,0,0,268.126,122.639Zm-188.144,99.4L59.289,186.116H79.982Zm0-39.736H59.289a7.8,7.8,0,0,0-.635-1.523l21.328-22.47Zm0-29.58L56.115,177.991a11.863,11.863,0,0,0-1.9-.762l-26.405-45.7a4.941,4.941,0,0,0,.254-1.9,6.7,6.7,0,0,0-.127-1.65L52.561,85.315a8,8,0,0,0,3.682-1.27l23.74,24.629v44.052Zm0-48.5L58.274,81.761a6.941,6.941,0,0,0,1.016-3.681c0-.127-.127-.381-.127-.508l20.82-7.49Zm0-38.213-20.693,7.49,20.693-35.8ZM234.738,84.554l.381.635-16.758,79.218-30.215-31.865,46.465-48.115ZM145.49,176.721l5.459,5.586H140.158Zm-.127-5.332-39.482-40.5,37.7-39.99,39.355,41.513Zm2.539,2.793,37.578-38.974,31.992,33.769-2.793,13.33H155.9ZM201.73,29.456a6.367,6.367,0,0,0,1.65.635L230.8,77.826v.254a6.937,6.937,0,0,0,1.016,3.681l-46.211,47.988L146.252,88.235Zm-4.316-1.016-53.828,57L116.545,56.878l78.837-28.437h2.032Zm-58.525,0a6.746,6.746,0,0,0,9.649,0h35.547l-70.332,25.39L89.631,28.441Zm-55.1,2.666.508-1.015q.642-.164,1.27-.381l24.248,25.518L83.792,64.623Zm0,37.578,28.818-10.41,28.31,29.961-37.7,39.863L83.792,108.167Zm0,43.925,17.265,17.9L83.792,148.665V112.61Zm0,41.641,19.931-21.074,39.228,40.752-8.125,8.379H83.792Zm3.3,76.806a6.818,6.818,0,0,0-2.793-1.65l-.508-.762V186.116h47.353L87.727,231.057Zm61.572,0a7.051,7.051,0,0,0-9.9,0h-45.7l43.418-44.941H154.63l43.418,44.941H148.664Zm56.875-5.586-2.031,3.555a6.381,6.381,0,0,0-1.65.635l-42.275-43.545h54.209l-8.253,39.355Zm6.093-10.537,6.094-28.818h10.41Zm16.5-32.627h-9.648l2.158-10.029,8.125,8.633a4.7,4.7,0,0,0-.635,1.4ZM259.493,131.4l-26.279,45.83a12.8,12.8,0,0,0-1.9.888l-9.775-10.41,16.377-77.695,21.709,37.578a9.646,9.646,0,0,0-.381,2.031A8.57,8.57,0,0,0,259.493,131.4Z" transform="translate(44.287 204.001)" fill="#''' +
        theme.primaryColorDark.hexCode +
        '''"/>
    <g id="Friend_TItle-1" data-name="Friend TItle-1" transform="translate(-7 -23)">
      <g id="Rectangle_10" data-name="Rectangle 10" transform="translate(17 99)" fill="#''' +
        theme.backgroundColor.hexCode +
        '''"
          stroke="#e6e6e6" stroke-width="1">
        <rect width="120" height="120" rx="10" stroke="none" />
        <rect x="0.5" y="0.5" width="119" height="119" rx="9.5" fill="none" />
      </g>
      <g id="jeff" transform="translate(54.188 125.25)">
        <circle id="Ellipse_3" data-name="Ellipse 3" cx="25" cy="25" r="25" fill="#0d8abc" />
        <text id="JE" transform="translate(25 34)" fill="#fff" font-size="22"
            font-family="SegoeUI, Segoe UI">
          <tspan x="-9.491" y="0">JE</tspan>
        </text>
      </g>
      <text id="Jeff-2" data-name="Jeff" transform="translate(77 209)" font-size="15"
          font-family="SegoeUI, Segoe UI" letter-spacing="0.033em" fill="#''' +
        theme.colorScheme.onBackground.hexCode +
        '''">
        <tspan x="-12.044" y="0">Jeff</tspan>
      </text>
    </g>
    <g id="Friend_Title-2" data-name="Friend Title-2" transform="translate(4 -23)">
      <g id="Rectangle_11" data-name="Rectangle 11" transform="translate(131 99)" fill="#''' +
        theme.backgroundColor.hexCode +
        '''"
          stroke="#eaeaea" stroke-width="1">
        <rect width="120" height="120" rx="10" stroke="none" />
        <rect x="0.5" y="0.5" width="119" height="119" rx="9.5" fill="none" />
      </g>
      <text id="Zhon" transform="translate(191 208)" font-size="15" font-family="SegoeUI, Segoe UI"
          letter-spacing="0.033em" fill="#''' +
        theme.colorScheme.onBackground.hexCode +
        '''">
        <tspan x="-17.911" y="0">Zhon</tspan>
      </text>
      <g id="zhon-2" data-name="zhon" transform="translate(164.906 125.25)">
        <circle id="Ellipse_2" data-name="Ellipse 2" cx="25" cy="25" r="25" fill="#b4f8c8" />
        <text id="ZH" transform="translate(25 33.741)" font-size="22"
            font-family="SegoeUI, Segoe UI">
          <tspan x="-14.083" y="0">ZH</tspan>
        </text>
      </g>
    </g>
    <g id="AppBar">
      <rect id="Rectangle_1" data-name="Rectangle 1" width="375" height="68" fill="#''' +
        theme.primaryColor.hexCode +
        '''" />
      <text id="Friends" transform="translate(68 43)" fill="#f2f2f7" font-size="26"
          font-family="SegoeUI, Segoe UI">
        <tspan x="0" y="0">Friends</tspan>
      </text>
      <g id="baseline-menu-24px" transform="translate(22 20)">
        <path id="Path_2012" data-name="Path 2012" d="M0,0H28V28H0Z" fill="none" />
        <path id="Path_2013" data-name="Path 2013"
            d="M3,21.6H23.2V19H3Zm0-6.5H23.2V12.5H3ZM3,6V8.6H23.2V6Z"
            transform="translate(0.899 0.201)" fill="#f2f2f7" />
      </g>
      <g id="outline-person_add-24px" transform="translate(333 22)">
        <g id="Bounding_Boxes">
          <path id="Path_3495" data-name="Path 3495" d="M0,0H24V24H0Z" fill="none" />
        </g>
        <g id="Outline">
          <g id="Group_390" data-name="Group 390">
            <path id="Path_3496" data-name="Path 3496"
                d="M15,12a4,4,0,1,0-4-4A4,4,0,0,0,15,12Zm0-6a2,2,0,1,1-2,2A2.006,2.006,0,0,1,15,6Z"
                fill="#f2f2f7" />
            <path id="Path_3497" data-name="Path 3497"
                d="M15,14c-2.67,0-8,1.34-8,4v2H23V18C23,15.34,17.67,14,15,14ZM9,18c.22-.72,3.31-2,6-2s5.8,1.29,6,2Z"
                fill="#f2f2f7" />
            <path id="Path_3498" data-name="Path 3498" d="M6,15V12H9V10H6V7H4v3H1v2H4v3Z"
                fill="#f2f2f7" />
          </g>
        </g>
      </g>
    </g>
    <g id="BottomNavBar">
      <rect id="Rectangle_128" data-name="Rectangle 128" width="375" height="68"
          transform="translate(0 599)" fill="#''' +
        theme.primaryColorDark.hexCode +
        '''" />
      <circle id="Ellipse_5" data-name="Ellipse 5" cx="54" cy="54" r="54"
          transform="translate(59 579)" fill="#''' +
        theme.primaryColorDark.hexCode +
        '''" />
      <circle id="Ellipse_4" data-name="Ellipse 4" cx="39" cy="39" r="39"
          transform="translate(74 585)" fill="#''' +
        theme.backgroundColor.hexCode +
        '''" />
      <g id="baseline-message-24px" transform="translate(255 611)">
        <path id="Path_853" data-name="Path 853"  fill="#''' +
        theme.colorScheme.onBackground.hexCode +
        '''"
            d="M4.4,2H23.6a2.4,2.4,0,0,1,2.388,2.4L26,26l-4.8-4.8H4.4A2.407,2.407,0,0,1,2,18.8V4.4A2.407,2.407,0,0,1,4.4,2ZM6.8,16.4H21.2V14H6.8Zm0-3.6H21.2V10.4H6.8Zm0-3.6H21.2V6.8H6.8Z" />
        <path id="Path_854" data-name="Path 854" d="M28,0H0V28H28Z" fill="none" />
      </g>
      <g id="baseline-home-24px" transform="translate(99 610)">
        <path id="Path_304" data-name="Path 304"
            d="M11.6,24V16.588h4.8V24h6V14.118H26L14,3,2,14.118H5.6V24Z"  fill="#''' +
        theme.colorScheme.onBackground.hexCode +
        '''"/>
        <path id="Path_305" data-name="Path 305" d="M0,0H28V28H0Z" fill="none" />
      </g>
      <text id="Comment" transform="translate(271 660)" font-size="15"
          font-family="SegoeUI, Segoe UI" letter-spacing="0.033em"  fill="#''' +
        theme.colorScheme.onBackground.hexCode +
        '''">
        <tspan x="-34.166" y="0">Comment</tspan>
      </text>
    </g>
  </g>
</svg>

    
    ''');
  }

  Widget previewSVGChatRoom(ThemeData theme) {
    return SvgPicture.string('''
    <svg xmlns="http://www.w3.org/2000/svg" width="375" height="667" viewBox="0 0 375 667">
  <defs>
    <clipPath id="clip-ChatRoom_1">
      <rect width="375" height="667" />
    </clipPath>
  </defs>
  <g id="ChatRoom_1" data-name="ChatRoom – 1" clip-path="url(#clip-ChatRoom_1)">
    <rect width="375" height="667" fill="#''' +
        theme.backgroundColor.hexCode +
        '''" />
    <g id="Bottom">
      <g id="Rectangle_2" data-name="Rectangle 2" transform="translate(60 602)" fill="#'''+ theme.backgroundColor.hexCode +'''"
          stroke="#b0b0b0" stroke-width="1">
        <rect width="256" height="47" rx="10" stroke="none" />
        <rect x="0.5" y="0.5" width="255" height="46" rx="9.5" fill="none" />
      </g>
      <g id="outline-send-24px" transform="translate(334 612)">
        <g id="Bounding_Boxes">
          <path id="Path_2825" data-name="Path 2825" d="M0,0H28V28H0Z" fill="none" />
        </g>
        <g id="Outline" transform="translate(2 3)">
          <path id="XMLID_1127_"
              d="M4.393,6.7l8.94,3.936L4.381,9.417,4.393,6.7m8.929,10.658L4.381,21.3V18.583l8.94-1.222M2.012,3,2,11.556,19.857,14,2,16.444,2.012,25,27,14,2.012,3Z"
              transform="translate(-2 -3)" fill="#''' +
        theme.colorScheme.onBackground.hexCode +
        '''" />
        </g>
      </g>
      <g id="baseline-expand_less-24px" transform="translate(17 612)">
        <path id="Path_2000" data-name="Path 2000" fill="#''' +
        theme.colorScheme.onBackground.hexCode +
        '''"
            d="M12,8,6,14l1.41,1.41L12,10.83l4.59,4.58L18,14Z" transform="translate(2 1.929)" />
        <path id="Path_2001" data-name="Path 2001" d="M0,0H28V28H0Z" fill="none" />
      </g>
      <text id="Type_Some_Text" data-name="Type Some Text" transform="translate(75 631)"
          fill="#e3e3e3" font-size="18" font-family="SegoeUI, Segoe UI">
        <tspan x="0" y="0">Type Some Text</tspan>
      </text>
    </g>
    <g id="Message_4" data-name="Message 4">
      <g id="Chat" transform="translate(0 168)">
        <rect id="Rectangle_3" data-name="Rectangle 3" width="86" height="48" rx="10"
            transform="translate(212 228)" fill="#''' +
        theme.primaryColor.blend(theme.backgroundColor, 70).hexCode +
        '''" />
        <text id="Slipper_" data-name="Slipper?" transform="translate(255 258)" fill="#fff"
            font-size="15" font-family="SegoeUI, Segoe UI" letter-spacing="0.033em">
          <tspan x="-28.077" y="0">Slipper?</tspan>
        </text>
      </g>
      <text id="PM_5:49" data-name="PM 5:49" transform="translate(188 436)" fill="#666"
          font-size="10" font-family="SegoeUI, Segoe UI" letter-spacing="0.033em">
        <tspan x="-18.83" y="0">PM 5:49</tspan>
      </text>
      <g id="jeff" transform="translate(307 394)">
        <circle id="Ellipse_3" data-name="Ellipse 3" cx="25" cy="25" r="25" fill="#0d8abc" />
        <text id="JE" transform="translate(25 34)" fill="#fff" font-size="22"
            font-family="SegoeUI, Segoe UI">
          <tspan x="-12.491" y="0">JE</tspan>
        </text>
      </g>
    </g>
    <g id="Message_3" data-name="Message 3">
      <rect id="Rectangle_12" data-name="Rectangle 12" width="224" height="80" rx="10"
          transform="translate(77 292)" fill="#''' +
        theme.colorScheme.secondary.hexCode +
        '''" />
      <text id="What_do_u_call_a_shoe_made_out_of_a_banana_" data-name="What do u call a shoe made
out of a banana?" transform="translate(91 323)" font-size="15" font-family="SegoeUI, Segoe UI"
          letter-spacing="0.033em">
        <tspan x="0" y="0">What do u call a shoe made</tspan>
        <tspan x="0" y="32">out of a banana?</tspan>
      </text>
      <g id="Message_stamp" transform="translate(133 228)">
        <text id="PM_5:51" data-name="PM 5:51" transform="translate(195 139)" fill="#666"
            font-size="10" font-family="SegoeUI, Segoe UI" letter-spacing="0.033em">
          <tspan x="-18.83" y="0">PM 5:51</tspan>
        </text>
        <text id="Read" transform="translate(176 125)" fill="#666" font-size="11"
            font-family="SegoeUI, Segoe UI" letter-spacing="0.033em">
          <tspan x="0" y="0">Read</tspan>
        </text>
      </g>
      <g id="zhon" transform="translate(15 322)">
        <circle id="Ellipse_2" data-name="Ellipse 2" cx="25" cy="25" r="25" fill="#b4f8c8" />
        <text id="ZH" transform="translate(25 33.741)" font-size="22"
            font-family="SegoeUI, Segoe UI">
          <tspan x="-14.083" y="0">ZH</tspan>
        </text>
      </g>
    </g>
    <g id="Message_2" data-name="Message 2">
      <g id="Chat-2" data-name="Chat">
        <rect id="Rectangle_3-2" data-name="Rectangle 3" width="62" height="48" rx="10"
            transform="translate(236 228)" fill="#''' +
        theme.primaryColor.blend(theme.backgroundColor, 70).hexCode +
        '''" />
        <text id="Sure" transform="translate(267 258)" fill="#fff" font-size="15"
            font-family="SegoeUI, Segoe UI" letter-spacing="0.033em">
          <tspan x="-15.508" y="0">Sure</tspan>
        </text>
      </g>
      <text id="PM_5:49-2" data-name="PM 5:49" transform="translate(209 268)" fill="#666"
          font-size="10" font-family="SegoeUI, Segoe UI" letter-spacing="0.033em">
        <tspan x="-18.83" y="0">PM 5:49</tspan>
      </text>
      <g id="jeff-2" data-name="jeff" transform="translate(307 226)">
        <circle id="Ellipse_3-2" data-name="Ellipse 3" cx="25" cy="25" r="25" fill="#0d8abc" />
        <text id="JE-2" data-name="JE" transform="translate(25 34)" fill="#fff" font-size="22"
            font-family="SegoeUI, Segoe UI">
          <tspan x="-12.491" y="0">JE</tspan>
        </text>
      </g>
    </g>
    <g id="Message_1" data-name="Message 1">
      <rect id="Rectangle_4" data-name="Rectangle 4" width="90" height="48" rx="10"
          transform="translate(77 102)" fill="#''' +
        theme.colorScheme.secondary.hexCode +
        '''" />
      <rect id="Rectangle_5" data-name="Rectangle 5" width="198" height="48" rx="10"
          transform="translate(77 159)" fill="#''' +
        theme.colorScheme.secondary.hexCode +
        '''" />
      <text id="Hey_Jeff" data-name="Hey, Jeff" transform="translate(122 132)" font-size="15"
          font-family="SegoeUI, Segoe UI" letter-spacing="0.033em">
        <tspan x="-29.85" y="0">Hey, Jeff</tspan>
      </text>
      <text id="I_wanna_ask_u_a_question" data-name="I wanna ask u a question"
          transform="translate(179 189)" font-size="15" font-family="SegoeUI, Segoe UI"
          letter-spacing="0.033em">
        <tspan x="-87.107" y="0">I wanna ask u a question</tspan>
      </text>
      <g id="Message_stamp-2" data-name="Message_stamp">
        <text id="PM_5:47" data-name="PM 5:47" transform="translate(195 139)" fill="#666"
            font-size="10" font-family="SegoeUI, Segoe UI" letter-spacing="0.033em">
          <tspan x="-18.83" y="0">PM 5:47</tspan>
        </text>
        <text id="Read-2" data-name="Read" transform="translate(176 125)" fill="#666" font-size="11"
            font-family="SegoeUI, Segoe UI" letter-spacing="0.033em">
          <tspan x="0" y="0">Read</tspan>
        </text>
      </g>
      <g id="Message_stamp-3" data-name="Message_stamp" transform="translate(106 61)">
        <text id="PM_5:48" data-name="PM 5:48" transform="translate(195 139)" fill="#666"
            font-size="10" font-family="SegoeUI, Segoe UI" letter-spacing="0.033em">
          <tspan x="-18.83" y="0">PM 5:48</tspan>
        </text>
        <text id="Read-3" data-name="Read" transform="translate(176 125)" fill="#666" font-size="11"
            font-family="SegoeUI, Segoe UI" letter-spacing="0.033em">
          <tspan x="0" y="0">Read</tspan>
        </text>
      </g>
      <g id="zhon-2" data-name="zhon" transform="translate(15 157)">
        <circle id="Ellipse_2-2" data-name="Ellipse 2" cx="25" cy="25" r="25" fill="#b4f8c8" />
        <text id="ZH-2" data-name="ZH" transform="translate(25 33.741)" font-size="22"
            font-family="SegoeUI, Segoe UI">
          <tspan x="-14.083" y="0">ZH</tspan>
        </text>
      </g>
    </g>
    <g id="AppBar">
      <rect id="Rectangle_1" data-name="Rectangle 1" width="375" height="68" fill="#''' +
        theme.primaryColor.hexCode +
        '''" />
      <g id="baseline-arrow_back-24px" transform="translate(22 21)">
        <path id="Path_1968" data-name="Path 1968" d="M0,0H26V26H0Z" fill="none" />
        <path id="Path_1969" data-name="Path 1969" fill="#f2f2f7"
            d="M22,11.875H8.309L14.6,5.586,13,4,4,13l9,9,1.586-1.586L8.309,14.125H22Z" />
      </g>
      <text id="Zhon-3" data-name="Zhon" transform="translate(68 43)" font-size="26"
          font-family="SegoeUI, Segoe UI" fill="#f2f2f7">
        <tspan x="0" y="0">Zhon</tspan>
      </text>
      <g id="Setting_Icon" data-name="Setting Icon" transform="translate(-5 -652)">
        <path id="Path_439" data-name="Path 439" d="M0,0H28V28H0Z" transform="translate(336 672)"
            fill="none" />
        <path id="Path_440" data-name="Path 440"
            d="M19.48,12.975A8.113,8.113,0,0,0,19.543,12a6.131,6.131,0,0,0-.075-.975l2.125-1.65a.515.515,0,0,0,.126-.637L19.706,5.275a.513.513,0,0,0-.616-.225l-2.5,1a7.376,7.376,0,0,0-1.7-.975l-.377-2.65a.5.5,0,0,0-.5-.425H9.989a.488.488,0,0,0-.49.425l-.377,2.65a7.573,7.573,0,0,0-1.7.975l-2.5-1a.5.5,0,0,0-.616.225L2.295,8.737a.483.483,0,0,0,.126.638l2.125,1.65a5.858,5.858,0,0,0-.013,1.95l-2.125,1.65a.515.515,0,0,0-.126.638l2.011,3.463a.513.513,0,0,0,.616.225l2.5-1a7.376,7.376,0,0,0,1.7.975l.377,2.65a.511.511,0,0,0,.5.425h4.023a.479.479,0,0,0,.49-.425l.377-2.65a7.573,7.573,0,0,0,1.7-.975l2.5,1a.5.5,0,0,0,.616-.225l2.011-3.462a.483.483,0,0,0-.126-.638l-2.1-1.65ZM12,15.75A3.75,3.75,0,1,1,15.771,12,3.772,3.772,0,0,1,12,15.75Z"
            transform="translate(337.778 674)" fill="#f2f2f7" />
      </g>
    </g>
  </g>
</svg>

 ''');
  }
}
