import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
class PushNotificationManager{
  final FirebaseMessaging _fcm= new FirebaseMessaging();

  Future<Map<String, dynamic>> _saveToken() async{
    // String uid=FirebaseAuth.instance.currentUser.uid;
    String _token=await _fcm.getToken();
    log('token ----------');
    log(_token);
    await http.post(
      'https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$_token',
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
    final Completer<Map<String, dynamic>> completer =Completer<Map<String, dynamic>>();

    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        completer.complete(message);
      },
    );

    return completer.future;
  }
}