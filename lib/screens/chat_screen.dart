import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firestore_demo2/chat/messages.dart';
import 'package:firestore_demo2/chat/new_message.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

final GoogleSignIn googleSignIn = GoogleSignIn();

final FacebookLogin facebookSignIn = new FacebookLogin();
class _ChatScreenState extends State<ChatScreen> {
  @override
  void initState() {
    final fbm = FirebaseMessaging();
    fbm.requestNotificationPermissions();
    print("notification-----------------");
    fbm.configure(onMessage: (msg) {
      print(msg);
      return;
    }, onLaunch: (msg) {
      print(msg);
      return;
    }, onResume: (msg) {
      print(msg);
      return;
    });
    print("notification-----------------");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Chat'),
        actions: <Widget>[
          Container(
            // color: Colors.white,
            child: Row(
              children: <Widget>[
                RaisedButton.icon(
                    color: Colors.white,
                    onPressed: () async{
                      // log('logged out');
                      await facebookSignIn.logOut();
                      print('Logged out facebook.');
                      FirebaseAuth.instance.signOut();
                      await googleSignIn.signOut();
                      print("User Signed Out");
                    },
                    icon: Icon(
                      Icons.exit_to_app,
                      color: Colors.black,
                    ),
                    label:
                        Text('Logout', style: TextStyle(color: Colors.black)))
              ],
            ),
          ),
        ],
      ),
      body: Container(
          child: Column(
        children: <Widget>[
          Expanded(child: Messages()),
          NewMessage(),
        ],
      )),
      // floatingActionButton: FloatingActionButton(
      //   child: Icon(Icons.add),
      //   onPressed: () {
      //     FirebaseFirestore.instance
      //         .collection('chat')
      //         .add({'test': 'added!'});
      //   },
      // ),
    );
  }
}
