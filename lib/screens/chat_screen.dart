import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bubble/bubble.dart';

class ChatScreen extends StatefulWidget {
  static String id = "ChatScreen";
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User user;
  String text;
  void intialize() async {
    try {
      user = _auth.currentUser;
      if (user != null) {
        print(user.email);
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    intialize();
  }

  void getMessageStream() async {
    await for (var snapshot in _firestore.collection("messages").snapshots()) {
      for (var messages in snapshot.docs) print(messages.data());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _auth.signOut();
                Navigator.popAndPushNamed(context, WelcomeScreen.id);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 10,
              child: Container(
                child: StreamBuilder(
                  stream: _firestore.collection('messages').snapshots(),
                  builder: (context, AsyncSnapshot<dynamic> snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(
                          backgroundColor: Colors.lightBlueAccent,
                        ),
                      );
                    }
                    List<Bubble> messagesWidget = [];
                    snapshot.data.docs.forEach((doc) {
                      final messageText = doc.data()["text"];
                      final messageSender = doc.data()["sender"];
                      print('$messageText from $messageSender');
                      final messageWidget = Bubble(
                        stick: true,
                        color: (messageSender.toString() == user.email)
                            ? Color.fromRGBO(225, 255, 199, 1.0)
                            : Color(0xFFFFFFFF),
                        nip: (messageSender.toString() == user.email)
                            ? BubbleNip.rightBottom
                            : BubbleNip.leftBottom,
                        margin: BubbleEdges.all(8.0),
                        alignment: (messageSender.toString() == user.email)?Alignment.topRight:Alignment.topLeft,
                        padding: BubbleEdges.all(12.0),
                        child: Container(
                          child: Column(
                            crossAxisAlignment: (messageSender.toString() == user.email)?CrossAxisAlignment.end:CrossAxisAlignment.start,
                            children: [
                              Text(
                                messageSender.toString(),
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.normal),
                              ),
                              Text(
                                messageText.toString(),
                                style: TextStyle(
                                    color: Colors.black, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      );
                      messagesWidget.add(messageWidget);
                    });
                      List <Bubble> rev = new List.from(messagesWidget.reversed);
                    return ListView(
                      children: rev,
                    );
                  },
                ),
              ),
            ),
            Expanded(
              child: Container(
                decoration: kMessageContainerDecoration,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        onChanged: (value) {
                          text = value;
                          //Do something with the user input.
                        },
                        decoration: kMessageTextFieldDecoration,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        _firestore.collection('messages').add({
                          'text': text,
                          'sender': user.email,
                        });
                        //Implement send functionality.
                      },
                      child: Text(
                        'Send',
                        style: kSendButtonTextStyle,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

    );
  }
}
