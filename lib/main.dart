import 'package:firestore_demo2/screens/auth_screen.dart';
import 'package:firestore_demo2/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:developer';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  //
  // Future<void> getFruit() async {
  //   HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('listFruit');
  //   final results = await callable();
  //   List fruit = results.data;  // ["Apple", "Banana", "Cherry", "Date", "Fig", "Grapes"]
  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
            primaryColor: Colors.pink,
            backgroundColor: Colors.redAccent,
            accentColor: Colors.deepPurple,
            accentColorBrightness: Brightness.dark,
            buttonTheme: ButtonTheme.of(context).copyWith(
                buttonColor: Colors.pink,
                textTheme: ButtonTextTheme.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)))),
        home: Scaffold(
          body:
          //Notification related
          // Container(
          //   child:Center(
          //     child: RaisedButton(
          //   child: Text('click'),
          //   onPressed: _saveToken,
          // ))),

        StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (ctx,userSnapShot){
            if(userSnapShot.hasData){
              return ChatScreen();
            }else{
              return AuthScreen();
            }
          },
        ))
        );
  }
}

Future<Map<String, dynamic>> _saveToken() async {
  final FirebaseMessaging _fcm = new FirebaseMessaging();
  final _serverToken =
      'AAAAoGqVXPc:APA91bEXkslrd2Crw2Lp57wDonxopIKa3VkB3bLKAtosI-wzFXGnnL7RC-xIDQWTxLdkC1NB-DDVGf-Pl8g_ahdC1rNF3-O71PazsSOyGz ekVOoIWStHbk0twf3wf9MvIxzAdoPK8Ir_';
  // String uid=FirebaseAuth.instance.currentUser.uid;
  String _token = await _fcm.getToken();
  log('token ----------');
  log(_token);
  log('token ----------');

  await http.post(
    'https://fcm.googleapis.com/fcm/send',
    headers: <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'key=$_serverToken',
    },
    body: jsonEncode(
      <String, dynamic>{
        'notification': <String, dynamic>{
          'body': 'this is a body',
          'title': 'this is a title'
        },
        'priority': 'high',
        'data': <String, dynamic>{
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'id': '1',
          'status': 'done'
        },
        'to': await _fcm.getToken(),
      },
    ),
  );
  final Completer<Map<String, dynamic>> completer =
      Completer<Map<String, dynamic>>();

  _fcm.configure(
    onMessage: (Map<String, dynamic> message) async {
      completer.complete(message);
    },
    onLaunch:(Map<String, dynamic> message) async {
      completer.complete(message);
    },
    onResume:(Map<String, dynamic> message) async {
    completer.complete(message);
  },
  );
  // final _fcm = FirebaseMessaging();
  // _fcm.requestNotificationPermissions();
  // print("notification-----------------");
  // _fcm.configure(onMessage: (msg) {
  //   print(msg);
  //   return;
  // }, onLaunch: (msg) {
  //   print(msg);
  //   return;
  // }, onResume: (msg) {
  //   print(msg);
  //   return;
  // });
  // print("notification-----------------");
  return completer.future;
}
