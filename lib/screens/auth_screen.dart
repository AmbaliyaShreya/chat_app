import 'dart:developer';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firestore_demo2/widgets/auth/auth_form.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth=FirebaseAuth.instance;
  bool _isLoading=false;

  // void _submitAuthForm(String email,String password,String username,File image,bool isLogin,context) async{
  // try {
  //   setState(() {
  //     _isLoading=true;
  //   });
  //   UserCredential authResult;
  //   if (isLogin) {
  //     authResult=await _auth.signInWithEmailAndPassword(email: email, password: password);
  //   } else {
  //
  //     authResult=await _auth.createUserWithEmailAndPassword(
  //         email: email, password: password);
  //
  //     final ref=FirebaseStorage.instance.ref().child('user_image').child(authResult.user.uid+'.jpg');
  //     await ref.putFile(image).whenComplete;
  //     final url=await ref.getDownloadURL();
  //     log('-----add user-----------');
  //     log(authResult.user.uid);
  //     await FirebaseFirestore.instance.collection('users').doc(authResult.user.uid).set({
  //       'username':username,
  //       'email':email
  //     });
  //
  //   }
  //
  // }on PlatformException catch(error){
  //   var message='An Error occured please check your credentials!';
  //   if(error.message!=null){
  //     message=error.message;
  //   }
  //   setState(() {
  //     _isLoading=false;
  //   });
  //   Scaffold.of(context).showSnackBar(SnackBar(content: Text(error.message),backgroundColor: Theme.of(context).errorColor,));
  // }catch(err){
  //   log(err.toString());
  //   setState(() {
  //     _isLoading=false;
  //   });
  //   Scaffold.of(context).showSnackBar(SnackBar(content: Text(err.toString()),backgroundColor: Theme.of(context).errorColor,));
  // }
  //
  // }

  void _submitAuthForm(
      String email,
      String password,
      String username,
      File image,
      bool isLogin,
      BuildContext ctx,
      ) async {
    UserCredential authResult;

    try {
      setState(() {
        _isLoading = true;
      });
      if (isLogin) {
        authResult = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        authResult = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        final ref = FirebaseStorage.instance
            .ref()
            .child('user_image')
            .child(authResult.user.uid + '.jpg');

        await ref.putFile(image);

        final url = await ref.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(authResult.user.uid)
            .set({
          'username': username,
          'email': email,
          'image_url': url,
        });
      }
    } on PlatformException catch (err) {
      var message = 'An error occurred, please check your credentials!';

      if (err.message != null) {
        message = err.message;
      }

      Scaffold.of(ctx).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(ctx).errorColor,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    } catch (err) {
      print(err);
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body:AuthForm(_submitAuthForm,_isLoading)
    );
  }

}
