import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPassScreen extends StatefulWidget {
  @override
  _ForgotPassScreenState createState() => _ForgotPassScreenState();
}

class _ForgotPassScreenState extends State<ForgotPassScreen> {
  final _formKey = GlobalKey<FormState>();
  var _userEmail = '';
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  void initState() {
    _userEmail='';
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Forgot Password"),),
        body: Center(
            child: Card(
      margin: EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Padding(
            padding: EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    key: ValueKey('email'),
                    validator: (value) {
                      if (value.isEmpty || !value.contains('@')) {
                        return 'Email is required';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                    ),
                    onSaved: (value) {
                      _userEmail = value;
                    },
                  ),
                  RaisedButton(
                    child: Text("Submit"),
                    onPressed: () {
                      sendPasswordResetEmail();
                      // showDialog(
                      //     context: context,
                      //     AlertDialog(
                      //       title:Text(
                      //           "Mail is sent to your email for password reset "),
                      //       actions: [
                      //         RaisedButton(
                      //           onPressed: () {
                      //             Navigator.of(context).pop();
                      //           },
                      //           child: Text("Ok"),
                      //         )
                      //       ],
                      //     ));
                    },
                  ),
                ],
              ),
            )),
      ),
    )));
  }

  Future sendPasswordResetEmail() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      return _firebaseAuth.sendPasswordResetEmail(email: _userEmail);
    }
  }
}
