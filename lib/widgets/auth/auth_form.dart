import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
// import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:firestore_demo2/screens/forgot_pass_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firestore_demo2/pickers/user_image_picker.dart';
import 'package:flutter/material.dart';

class AuthForm extends StatefulWidget {
  final bool isLoading;
  final void Function(String email, String password, String username,
      File imageFile, bool isLogin, BuildContext context) submitFn;

  AuthForm(this.submitFn, this.isLoading);

  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  var _userEmail = '';
  var _userPassword = '';
  var _isLogin = true;
  var _username = '';
  File _userImageFile;

  void _pickedImage(File image) {
    _userImageFile = image;
  }

  Future<UserCredential> signInWithGoogle() async {
    // print("-----------in login with google");
    // Trigger the authentication flow
    final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // Create a new credential
    final GoogleAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    print("--------in login with google sign in method");
    UserCredential userData =
        await FirebaseAuth.instance.signInWithCredential(credential);
    print(userData.additionalUserInfo);

    if (userData.additionalUserInfo.isNewUser) {
      print("---------=new user sign up");
      // final ref = FirebaseStorage.instance
      //     .ref()
      //     .child('user_image')
      //     .child(userData.additionalUserInfo.profile['picture']);
      //
      // await ref.putFile(userData.additionalUserInfo.profile['picture']);

      // final url = await ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser.uid)
          .set({
        'username': userData.additionalUserInfo.profile['name'],
        'email': userData.additionalUserInfo.profile['email'],
        'image_url': userData.additionalUserInfo.profile['picture'],
      });
    }
    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }
  // final FacebookLogin facebookSignIn = new FacebookLogin();
  void _showMessage(String message) {
    setState(() {
      _message = message;
    });
  }
  String _message = 'Log in/out by pressing the buttons below.';
  Future<UserCredential> signInWithFacebook() async {
    print("--------in login with facebook method");
    // final FacebookLoginResult result = await facebookSignIn.logIn(['email']);
    //
    // print("facebook login status ----");
    // print(result);
    // switch (result.status) {
    //   case FacebookLoginStatus.loggedIn:
    //     final FacebookAccessToken accessToken = result.accessToken;
    //     print('''
    //      Logged in!
    //      Token: ${accessToken.token}
    //      User id: ${accessToken.userId}
    //      Expires: ${accessToken.expires}
    //      Permissions: ${accessToken.permissions}
    //      Declined permissions: ${accessToken.declinedPermissions}
    //      ''');
    //     break;
    //   case FacebookLoginStatus.cancelledByUser:
    //     print('Login cancelled by the user.');
    //     break;
    //   case FacebookLoginStatus.error:
    //     print('Something went wrong with the login process.\n'
    //         'Here\'s the error Facebook gave us: ${result.errorMessage}');
    //     break;
    // }
    // Trigger the sign-in flow
    print("facebook auth login result");
    try {
      final AccessToken result = await FacebookAuth.instance.login();
      print("=*******************");
      print(result.toString());
      // Create a credential from the access token
      final FacebookAuthCredential facebookAuthCredential = FacebookAuthProvider.credential(result.toString());
      final token = result.token;
      final graphResponse = await http.get(
          'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email&access_token=${token}');
      final profile = JSON.decode(graphResponse.body);
      print("in facebook log in");
      print(profile);
      // Once signed in, return the UserCredential
      return await FirebaseAuth.instance
          .signInWithCredential(facebookAuthCredential);
    }on FacebookAuthException catch (e) {
        print("error message");
        print(e.message);
    }
    return null;
  }

  void _trySubmit() {
    final isValid = _formKey.currentState.validate();
    FocusScope.of(context).unfocus();
    if (_userImageFile == null && !_isLogin) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Select an image"),
        backgroundColor: Theme.of(context).errorColor,
      ));
      return;
    }
    if (isValid) {
      _formKey.currentState.save();
      print(_userEmail);
      _formKey.currentState.save();
      widget.submitFn(_userEmail.trim(), _userPassword.trim(), _username.trim(),
          _userImageFile, _isLogin, context);
      //send values to auth request
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
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
                  if (!_isLogin) UserImagePicker(_pickedImage),
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
                  if (!_isLogin)
                    TextFormField(
                      key: ValueKey('username'),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Username is required';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelText: 'Username',
                      ),
                      onSaved: (value) {
                        _username = value;
                      },
                    ),
                  TextFormField(
                    key: ValueKey('password'),
                    onSaved: (value) {
                      _userPassword = value;
                    },
                    validator: (value) {
                      if (value.isEmpty || value.length < 7) {
                        return 'Please enter at least 7 characters long';
                      }
                      return null;
                    },
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                    ),
                  ),
                  SizedBox(height: 12),
                  if (widget.isLoading)
                    Center(child: CircularProgressIndicator()),
                  if (!widget.isLoading)
                    RaisedButton(
                      child: Text(_isLogin ? 'login' : 'Signup'),
                      onPressed: _trySubmit,
                    ),
                  FlatButton(
                    textColor: Theme.of(context).primaryColor,
                    child: Text(_isLogin
                        ? 'Create new Account'
                        : 'I already have an account'),
                    onPressed: () {
                      setState(() {
                        _isLogin = !_isLogin;
                      });
                    },
                  ),
                  FlatButton(
                    textColor: Theme.of(context).primaryColor,
                    child: Text("Forgot Password?"),
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ForgotPassScreen(),
                      ));
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FlatButton(
                          child: Text('Google', style: TextStyle(fontSize: 20)),
                          onPressed: signInWithGoogle),
                      SizedBox(
                        width: 10,
                      ),
                      FlatButton(
                          child:
                              Text('Facebook', style: TextStyle(fontSize: 20)),
                          onPressed: () {
                            signInWithFacebook();
                          })
                    ],
                  )
                ],
              ),
            )),
      ),
    ));
  }
}
