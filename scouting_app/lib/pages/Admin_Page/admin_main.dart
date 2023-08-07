// ignore_for_file: non_constant_identifier_names

import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:scouting_demo/services/notification_service.dart';
import 'package:scouting_demo/widgets/loadingIndicatorWidget.dart';

import 'package:scouting_demo/widgets/orangeAppBar.dart';

class AdminMain extends StatefulWidget {
  const AdminMain({Key? key}) : super(key: key);

  @override
  State<AdminMain> createState() => _AdminMainState();
}

class _AdminMainState extends State<AdminMain> {
  @override
  void initState() {
    super.initState();

    Timer.periodic(const Duration(seconds: 30), (timer) {
      try {
        setState(() {});
      } catch (e) {
        log(e.toString());
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          foregroundColor: Color(Colors.black.value),
          backgroundColor: Color(const Color.fromARGB(255, 33, 243, 205).value),
          title: const Text('THE ADMIN PAGE'),
          titleTextStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 19, 19, 19),
            fontSize: 20,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              onPressed: () {
                NotificationService.showNotification(
                    title: "אל תחשוב על זה יותר מידי ",
                    body: "  אמא שך דניס מוכרת נפצים");
              },
            )
          ]),
      drawerScrimColor: Colors.yellow.shade200,
      backgroundColor: const Color(0x0b2a2d),
      body: Container(
        margin: const EdgeInsets.all(10),
        child: FutureBuilder(
          future: getAllUsers(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var users = snapshot.data as QuerySnapshot<Map<String, dynamic>>;

              return ListView.builder(
                itemCount: users.docs.length,
                itemBuilder: (context, index) {
                  var user = users.docs[index];

                  var role = user['role'];
                  var state = user['state'];

                  return Card(
                    color: state == 'Offline'
                        ? Color(const Color.fromARGB(222, 255, 0, 93).value)
                        : Color(const Color.fromARGB(255, 0, 158, 163).value),
                    elevation: state == 'Offline' ? 5 : 54,
                    surfaceTintColor: const Color.fromARGB(0, 249, 25, 25),
                    child: ExpansionTile(
                      children: [const ListTile()],
                      leading: CircleAvatar(
                        backgroundColor: state == 'Offline'
                            ? Color(const Color.fromARGB(255, 255, 0, 0).value)
                            : Color(
                                const Color.fromARGB(255, 0, 255, 140).value),
                        child: Center(
                          child: Text(
                            // Set the first letter of the user's name as the avatar
                            // if there are any numbers in the name, set the first
                            // letter of the name before the number as the avatar
                            user.id[0].toUpperCase(),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 0, 0, 0)),
                          ),
                        ),
                      ),
                      iconColor: state == 'Offline'
                          ? Color(Colors.red.value)
                          : Color(const Color.fromARGB(255, 104, 0, 0).value),
                      subtitle: Text(state),
                      collapsedBackgroundColor: state == 'Offline'
                          ? Color(const Color.fromARGB(255, 98, 53, 53).value)
                          : Color(const Color.fromARGB(255, 0, 99, 102).value),
                      textColor: state == 'Offline'
                          ? Color(Colors.red.value)
                          : Color(const Color.fromARGB(255, 34, 255, 0).value),
                      collapsedTextColor: state == 'Offline'
                          ? Color(Colors.red.value)
                          : Color(const Color.fromARGB(255, 64, 255, 0).value),
                      backgroundColor: state == 'Offline'
                          ? Color(const Color.fromARGB(255, 119, 17, 9).value)
                          : Color(const Color.fromARGB(255, 0, 137, 142).value),
                      collapsedIconColor:
                          const Color.fromARGB(255, 0, 255, 191),
                      title: Text(
                        user.id,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: role == 'admin'
                                ? const Color.fromARGB(255, 212, 129, 12)
                                : const Color.fromARGB(255, 189, 189, 189)),
                      ),
                    ),
                  );
                },
              );
            } else {
              return const Center(
                child: LoadingIndicator(),
              );
            }
          },
        ),
      ),
    );
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getAllUsers() async {
    log("Saving the users...", name: "Admin Panel | User Saving");
    var db = FirebaseFirestore.instance;

    // Return all the users
    var users =
        await db.collection('users').orderBy('state', descending: true).get();
    return users;
  }
}
