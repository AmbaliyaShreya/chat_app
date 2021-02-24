import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  final Function(File pickedImage) imagePickFn;
  UserImagePicker(this.imagePickFn);
  @override
  _UserImagePickerState createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          backgroundImage: _pickedImage != null ? FileImage(_pickedImage) : null,
          radius: 50,
        ),
        FlatButton.icon(
          textColor: Theme.of(context).primaryColor,
          onPressed: (){
            _pickImage();
          },
          icon:Icon(Icons.image),
          label: Text('upload'),),

      ],
    );
  }
  File _pickedImage;
  void _pickImage() async{
    final picker=ImagePicker();
    final pickedImageFile=await picker.getImage(
        source: ImageSource.gallery,
        imageQuality: 50,
        maxWidth: 150
    );
    setState(() {
      if(pickedImageFile!=null) {
        _pickedImage = File(pickedImageFile.path);
      }else{
        print("No image selected");
      }
      widget.imagePickFn(_pickedImage);
    });
  }
}
