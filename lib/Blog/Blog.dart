import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:getwidget/getwidget.dart';
import 'package:hinataPicks/Blog/BlogCard.dart';
import 'package:hinataPicks/Blog/blogWebview.dart';
import 'package:hinataPicks/Blog/personalBlog.dart';
import 'package:hinataPicks/classes/member.dart';
import 'package:hinataPicks/models/mainModels.dart';
import 'package:hinataPicks/setting/setting.dart';
import 'package:hinataPicks/tutorial/tutorial.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class BlogPage extends StatefulWidget {
  @override
  _BlogPageState createState() => _BlogPageState();
}

class _BlogPageState extends State<BlogPage> {
  final ValueNotifier<double> notifier = ValueNotifier(0);
  int pageCount = 3;

  var allHinataBlog;
  var memberList;

  //外部URLへページ遷移(webviewではない)
  Future<void> _launchURL(String link) async {
    if (await canLaunch(link)) {
      await launch(
        link,
        universalLinksOnly: true,
        forceSafariVC: true,
        forceWebView: false,
      );
    } else {
      throw 'サイトを開くことが出来ません。。。 $link';
    }
  }

  // 最初の起動ならチュートリアル表示
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final preference = await SharedPreferences.getInstance();
      if (preference.getBool('isFirstLaunch') != true) {
        await showDialog(
          context: context,
          builder: (_) {
            return Tutorialpage();
          },
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("HinataPicks", style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
        brightness: Brightness.light,
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const SizedBox(
              height: 30,
            ),
            Center(
                child: Column(
              children: [
                const Text('アプリについて'),
              ],
            )),
            Divider(),
            ListTile(
              title: const Text(
                'お問い合わせ',
                style: TextStyle(fontSize: 20),
              ),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SettingPage()));
              },
            ),
            ListTile(
              title: const Text(
                '利用規約',
                style: TextStyle(fontSize: 20),
              ),
              onTap: () {
                _launchURL('https://hinatapicks.web.app/');
              },
            ),
            const ListTile(
              title: const Text(
                'version 1.0.0',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
      ),
      body: ChangeNotifierProvider<MainModel>(
        create: (_) => MainModel()..fetchHinataBlog(),
        child: Consumer<MainModel>(builder: (context, model, child) {
          this.allHinataBlog = model.allHinataBlog;
          return SingleChildScrollView(
              // TODO お気に入りメンバーの登録 || それのみ表示
              // TODO 匿名ログインが必要になる
              child: Column(
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "New Blog",
                      style: TextStyle(fontSize: 36.0, letterSpacing: 1.0),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 25),
              SizedBox(
                height: 320,
                child: ListView.builder(
                  key: GlobalKey(),
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: 12,
                  itemBuilder: (BuildContext context, int index) {
                    return allHinataBlog.length == 0
                        ? Center(child: const CircularProgressIndicator())
                        : Padding(
                            padding: const EdgeInsets.only(left: 0),
                            child: FlatButton(
                              onPressed: () => setState(() {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => BlogWebView(
                                            blogData: allHinataBlog[index])));
                              }),
                              child: BlogCardWidget(
                                allHinataBlog: allHinataBlog[index],
                              ),
                            ),
                          );
                  },
                ),
              ),
              const SizedBox(height: 50),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Search Member",
                        style: TextStyle(fontSize: 36.0, letterSpacing: 1.0),
                      )
                    ],
                  )),
              const SizedBox(height: 11),
              StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('memberLists')
                      .orderBy('id', descending: false)
                      .limit(22)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data.docs.length == 0) {
                      return Container(
                        child: const Center(
                          child: GFLoader(type: GFLoaderType.circle),
                        ),
                      );
                    } else {
                      memberList = snapshot.data.docs;
                      return Column(
                        children: [
                          eachMemberSemester(1),
                          eachMemberListView(memberList.length - 13, 0),
                          eachMemberSemester(2),
                          eachMemberListView(memberList.length - 13, 9),
                          eachMemberSemester(3),
                          eachMemberListView(memberList.length - 18, 18),
                        ],
                      );
                    }
                  }),
              const SizedBox(
                height: 70,
              )
            ],
          ));
        }),
      ),
    );
  }

  Padding eachMemberSemester(memberPremier) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 46),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "${memberPremier}期生",
              style: TextStyle(fontSize: 24.0, letterSpacing: 0.7),
            )
          ],
        ));
  }

  Column eachMemberListView(itemCounts, memberListsIndex) {
    return Column(
      children: [
        SizedBox(
            height: 140,
            child: ListView.builder(
              key: GlobalKey(),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: itemCounts,
              itemBuilder: (context, int index) {
                return Padding(
                  padding: const EdgeInsets.only(left: 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FlatButton(
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PersonalBlogPage(
                                    profile:
                                        memberLists[index + memberListsIndex],
                                    allHinataBlog: allHinataBlog))),
                        child: Container(
                          width: 97,
                          height: 100,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: NetworkImage(
                                    memberList[index + memberListsIndex]
                                        .get('profile_img'),
                                  ))),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ))
      ],
    );
  }
}
