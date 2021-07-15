import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/screens/welcome_screen.dart';
import  'package:flash_chat/screens/login_screen.dart';
import 'package:flash_chat/screens/registration_screen.dart';
import 'package:flash_chat/screens/chat_screen.dart';

void main() => runApp(App());

class App extends StatefulWidget {
  const App({Key key}) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  final Future <FirebaseApp> _initialization = Firebase.initializeApp();

  String checkUser() {
    FirebaseAuth _auth = FirebaseAuth.instance;
    try{
      var user = _auth.currentUser;
      if (user != null) {
        return ChatScreen.id;
      }
    }catch(e){
      print(e);
    }
      return WelcomeScreen.id;
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _initialization,
        builder: (context,snapshot){
      if(snapshot.connectionState == ConnectionState.done){
        return FlashChat(route: checkUser(),);
      }
      return MaterialApp(home : SafeArea(child: Scaffold(body: Container(child: Center(child: Text("Loading....."),),),)));
    });
  }
}


class FlashChat extends StatelessWidget {
  FlashChat({@required this.route});
  final String route;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: route,
      routes: {
        WelcomeScreen.id:(context) => WelcomeScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        RegistrationScreen.id : (context) => RegistrationScreen(),
        ChatScreen.id : (context) => ChatScreen(),
      },
    );
  }
}
