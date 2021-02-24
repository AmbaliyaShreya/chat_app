import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  final bool _isMe;
  final String userImage;
  final String userId;
  MessageBubble(this.message, this._isMe, this.userImage, this.userId);
  @override
  Widget build(BuildContext context) {
    return Stack(
      overflow: Overflow.visible,
      children: [
        Row(
          mainAxisAlignment:
              _isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: <Widget>[
            Container(
                decoration: BoxDecoration(
                  color:
                      _isMe ? Colors.grey[300] : Theme.of(context).accentColor,
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(12),
                      topLeft: Radius.circular(12),
                      bottomRight:
                          _isMe ? Radius.circular(0) : Radius.circular(12),
                      bottomLeft:
                          !_isMe ? Radius.circular(0) : Radius.circular(12)),
                ),
                width: 130,
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                margin: EdgeInsets.symmetric(vertical: 15, horizontal: 8),
                child: Column(
                  crossAxisAlignment:
                      _isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: <Widget>[
                    FutureBuilder(
                        future: FirebaseFirestore.instance
                            .collection('users')
                            .doc(userId)
                            .get(),
                        builder: (ctx, snapshot) => snapshot.connectionState ==
                                ConnectionState.waiting
                            ? Text('Loading',
                                style: TextStyle(
                                    color: !_isMe ? Colors.white : Colors.black,
                                    fontWeight: FontWeight.bold))
                            : Text(snapshot.data['username'],
                                textAlign:
                                    _isMe ? TextAlign.end : TextAlign.start,
                                style: TextStyle(
                                  color: !_isMe ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.bold,
                                ))),
                    Text(
                      message,
                      style: TextStyle(
                        color: !_isMe ? Colors.white : Colors.black,
                      ),
                      textAlign: _isMe ? TextAlign.end : TextAlign.start,
                    )
                  ],
                ))
          ],
        ),
        Positioned(
          top: 0,
          left: _isMe?null:120,
          right:_isMe?120:null,
          child: CircleAvatar(
            backgroundImage: NetworkImage(
              userImage,
            ),
          ),
        )
      ],
    );
  }
}
