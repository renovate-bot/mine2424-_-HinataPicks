import '../importer.dart';

// ignore: must_be_immutable
class BottomAddCommentButton extends StatefulWidget {
  var chatLength;
  String collection;
  String sendUser;
  BottomAddCommentButton(
      {Key key, @required this.collection, this.chatLength, this.sendUser})
      : super(key: key);
  @override
  _BottomAddCommentButtonState createState() => _BottomAddCommentButtonState();
}

class _BottomAddCommentButtonState extends State<BottomAddCommentButton> {
  String name, content;
  int like;
  Timestamp createAt;
  var customerModel;
  final approbation = 'https://hinatapicks.web.app/';

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  addComment(collection, customerModel) async {
    if (_formKey.currentState.validate()) {
      String userName, userImage = '';
      final _firebaseAuth = FirebaseAuth.instance.currentUser.uid;
      _formKey.currentState.save();
      // 各boardのcollectionを取得
      final sendComment = FirebaseFirestore.instance.collection(collection);
      // boradのコメントの個数を取得
      final commentLength =
          await FirebaseFirestore.instance.collection(collection).get();
      // 各Userのdocを取得
      final sendUserInfoDoc = await FirebaseFirestore.instance
          .collection('customerInfo')
          .doc(_firebaseAuth)
          .get();
      //投稿するユーザーの画像の判別
      if (sendUserInfoDoc.data()['imagePath'] == null) {
        FirebaseFirestore.instance
            .collection('customerInfo')
            .doc(_firebaseAuth)
            .update({'imagePath': ''});
      } else {
        userImage = sendUserInfoDoc.data()['imagePath'];
      }
      //投稿するユーザーの名前の判別
      if (customerModel.name == '') {
        userName =
            '匿名おひさまさん(${sendUserInfoDoc.data()['uid'].toString().substring(0, 7)})';
      } else {
        userName = customerModel.name;
      }

      sendComment.doc((commentLength.docs.length + 1).toString()).set({
        'userUid': _firebaseAuth,
        'name': userName,
        'context': content,
        'like': 0,
        'imagePath': userImage,
        'createAt': Timestamp.now(),
      });

      Navigator.push(
          context, MaterialPageRoute(builder: (context) => HomeSection()));
    }
  }

  //外部URLへページ遷移(webviewではない)
  static _launchURL(String link) async {
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

  TapGestureRecognizer _recognizer = TapGestureRecognizer()
    ..onTap = () {
      _launchURL('https://hinatapicks.web.app/');
    };

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UserModel>(
        create: (_) => UserModel()..fetchCustomerInfo(),
        child: Consumer<UserModel>(builder: (context, model, child) {
          customerModel = model.customerInfo;
          return (model.isLoading)
              ? const SizedBox()
              : Container(
                  margin: const EdgeInsets.only(bottom: 55),
                  child: FloatingActionButton(
                    heroTag: (widget.collection == 'friendChats')
                        ? 'hero1'
                        : 'hero2',
                    onPressed: () {
                      return showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                                title: const Text('投稿'),
                                content: SingleChildScrollView(
                                  child: Form(
                                    key: _formKey,
                                    child: Column(
                                      children: [
                                        (customerModel.name == '')
                                            ? Text('匿名おひさまさん')
                                            : Text(customerModel.name),
                                        TextFormField(
                                          keyboardType: TextInputType.multiline,
                                          maxLines: null,
                                          validator: (input) {
                                            for (var i = 0;
                                                i < prohibisionWords.length;
                                                i++) {
                                              if (input.contains(
                                                  prohibisionWords[i])) {
                                                return '不適切な言葉が含まれています';
                                              }
                                              if (input.isEmpty) {
                                                return '投稿内容を入力してください';
                                              }
                                            }
                                            return null;
                                          },
                                          onSaved: (input) => content = input,
                                          decoration: const InputDecoration(
                                              labelText: '投稿内容'),
                                        ),
                                        const SizedBox(height: 15),
                                        RichText(
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text: '投稿すると',
                                                style: TextStyle(
                                                    color: Colors.grey[800]),
                                              ),
                                              TextSpan(
                                                text: '利用規約',
                                                style: TextStyle(
                                                    color: Colors.lightBlue),
                                                recognizer: _recognizer,
                                              ),
                                              TextSpan(
                                                text: 'に同意したものとみなします。',
                                                style: TextStyle(
                                                    color: Colors.grey[800]),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                actions: [
                                  FlatButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('キャンセル')),
                                  FlatButton(
                                      onPressed: () {
                                        if (_formKey.currentState.validate()) {
                                          // TextFormFieldのonSavedが呼び出される
                                          _formKey.currentState.save();
                                          addComment(
                                              widget.collection, customerModel);
                                        }
                                      },
                                      child: const Text('投稿'))
                                ],
                              ));
                    },
                    child: Icon(Icons.add),
                    backgroundColor: Color(0xff7cc8e9),
                  ),
                );
        }));
  }
}
