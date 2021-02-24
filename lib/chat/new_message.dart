import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class NewMessage extends StatefulWidget {
  @override
  _NewMessageState createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final _controller=new TextEditingController();

  var _enteredMessage='';
  void _sendMessage() async{
    final user=await FirebaseAuth.instance.currentUser;
    final userData = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    log('---------start-----------');
    // log(userData['username']);
    log(_controller.text);
    log(user.uid);
    log('--------------------');
    FocusScope.of(context).unfocus();
    FirebaseFirestore.instance.collection('chat').add({
      'test':_controller.text,
      'createdAt':Timestamp.now(),
      'username':userData['username'],
      'userId':user.uid,
      'userImage':userData['image_url']
    });
    _controller.clear();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top:8),
      padding: EdgeInsets.all(8),
      child: Row(
        children: <Widget>[
          Expanded(
              child:TextField(
                controller:_controller,
                decoration: InputDecoration(labelText: 'Send a message...',),
                onChanged: (value){
                  setState(() {
                    _enteredMessage=value;
                  });
                },
              )
          ),
          IconButton(
            color:Theme.of(context).primaryColor,
            icon:Icon(
              Icons.send,
            ),
            onPressed: _controller.text.isEmpty?null:_sendMessage,
          )

        ],
      ),
    );
  }
}
