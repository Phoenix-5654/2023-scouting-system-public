import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scouting_demo/widgets/orangeAppBar.dart';

class RobotPhotoWidget extends StatefulWidget {
  const RobotPhotoWidget({super.key, required this.teamNumber});

  final teamNumber;

  @override
  State<RobotPhotoWidget> createState() => _RobotPhotoWidgetState();
}

class _RobotPhotoWidgetState extends State<RobotPhotoWidget> {
  @override
  String imageURL = '';
  bool canSubmit = false;
  Widget build(BuildContext context) {
    GlobalKey<FormState> key = GlobalKey<FormState>();
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        child: Form(
          key: key,
          child: Column(
            children: [
              IconButton(
                  onPressed: () async {
                    ImagePicker imagePicker = ImagePicker();
                    XFile? file =
                        await imagePicker.pickImage(source: ImageSource.camera);
                    log('File path: ${file?.path}');

                    if (file == null) return;

                    Reference referenceRoot = FirebaseStorage.instance.ref();
                    Reference referenceDirImage = referenceRoot.child('Images');
                    Reference referenceImageToUpload = referenceDirImage
                        .child(widget.teamNumber + ' robot image');

                    try {
                      await referenceImageToUpload.putFile(File(file.path));
                      // Sleep for 5 seconds to allow the image to upload
                      await Future.delayed(const Duration(seconds: 5));
                      imageURL = await referenceImageToUpload.getDownloadURL();

                      log('imageURL: $imageURL');

                      var db = FirebaseFirestore.instance;

                      // Add the data to the 'teams/<teamNumber>' collection,
                      // in 'imageUrl' field

                      db.collection('teams').doc(widget.teamNumber).update({
                        'imageUrl': imageURL,
                      });

                      log("Uploaded image to Firebase Storage: $imageURL");

                      // Erase the image
                      imageURL = '';
                      setState(() {
                        canSubmit = false;
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('התמונה נשמרה בהצלחה'),
                        ),
                      );
                    } catch (error) {
                      log('Error: $error');
                    }
                  },
                  icon: const Icon(Icons.camera_alt)),
            ],
          ),
        ),
      ),
    );
  }
}
