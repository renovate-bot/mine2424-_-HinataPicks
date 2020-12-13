import 'package:hinataPicks/notification.dart';
import 'importer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    anonymouslyLogin();
    initNotification();
    super.initState();
  }

  Future<void> anonymouslyLogin() async {
    final firebaseAuth = FirebaseAuth.instance;
    await firebaseAuth.signInAnonymously();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ひなこいチャット',
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: HomeSection(),
    );
  }
}
