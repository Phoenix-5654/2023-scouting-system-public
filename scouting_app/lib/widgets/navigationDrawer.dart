import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:scouting_demo/First_api/first_api.dart';
import 'package:scouting_demo/data/scheduleData.dart';
import 'package:scouting_demo/pages/Admin_Page/admin_main.dart';
import 'package:scouting_demo/pages/Scouting/matchSelection.dart';
import 'package:scouting_demo/services/googleSheetsAPI.dart';
import 'package:scouting_demo/widgets/googleSignIn.dart';
import 'package:scouting_demo/pages/loggedIn.dart';
import 'package:scouting_demo/pages/Pit_Scouting/teamSelectionPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:scouting_demo/widgets/userManager.dart';
import '../First_api/team.dart';
import '../pages/snake.dart';

class NavigationDrawer extends StatefulWidget {
  /// --- Navigation Drawer ---
  /// This is the navigation widget that is used in the app.
  /// Used to navigate between pages.
  ///
  /// --- Usage ---
  /// Used to navigate to various pages:
  /// - Home
  /// - Super Scouting
  /// - Snake
  /// - Log Out
  ///
  NavigationDrawer({super.key, required api, required schedule})
      : api = api,
        schedule = schedule;

  FIRST_API api;
  ValueNotifier<Map<String, List<dynamic>>> schedule;

  @override
  State<NavigationDrawer> createState() => _NavigationDrawerState();
}

class _NavigationDrawerState extends State<NavigationDrawer> {
  // Passing user's info
  UserInfo _userInfo = const UserInfo(
      username: "Loading...", email: "Loading...", photoURL: "Loading...");

  late Future<List<Team>> _futureTeams;

  @override
  void initState() {
    // When initialized, update the user's info
    super.initState();
    updateUserInfo();
  }

  void updateUserInfo() {
    /// --- updateUserInfo() ---
    /// This function updates the user's info.
    /// Information source is from Firebase, the login from the GoogleSignIn class.
    ///
    /// -------------------------

    UserManager().instance.authStateChanges().listen((User? user) {
      if (user == null) {
        // If user is not signed in, print it (for debugging)
        log('User is currently signed out!');
      } else {
        // Print the username in the format: "Signed in as <username>" (for debugging)
        log('Signed in as ${user.displayName}');
        setState(() {
          // Update the user's info
          _userInfo = UserInfo(
            username: user.displayName!,
            email: user.email!,
            photoURL: user.photoURL!,
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          // The column that contains the navigation drawer
          crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch the column
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top, // Padding for the top
              ),
            ),
            Wrap(
              // Wrapint the info and the list
              runSpacing: 10,
              children: [
                _userInfo, // The user's info - username, email, and photo
                ListTile(
                    // => Home
                    leading: const Icon(Icons.home),
                    title: const Text("עמוד הבית",
                        style: TextStyle(
                            color: Color.fromARGB(255, 108, 108, 108))),
                    onTap: () {
                      // If currently on the home page, do nothing
                      Navigator.popUntil(context, (route) => route.isFirst);
                    }),

                ListTile(
                    leading: const Icon(Icons.flag_rounded),
                    title: const Text("סקאוטינג",
                        style: TextStyle(
                            color: Color.fromARGB(255, 108, 108, 108))),
                    onTap: () {
                      // If currently on home page - regular push
                      if (ModalRoute.of(context)!.settings.name == "/") {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => Directionality(
                                textDirection: TextDirection.rtl,
                                child: MatchSelectionPage(
                                  api: widget.api,
                                  schedule: widget.schedule,
                                )),
                          ),
                        );
                      } else {
                        // If not on home page - replace the current page with pit scouting
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => Directionality(
                                textDirection: TextDirection.rtl,
                                child: MatchSelectionPage(
                                  api: widget.api,
                                  schedule: widget.schedule,
                                )),
                          ),
                        );
                      }
                    }),

                ListTile(
                    // => Super Scouting
                    leading: const Icon(Icons.info_rounded),
                    title: const Text("סקאוטינג פיטים",
                        style: TextStyle(
                            color: Color.fromARGB(255, 108, 108, 108))),
                    onTap: () {
                      // If currently pit scouting, do nothing
                      if (ModalRoute.of(context)!.settings.name ==
                          "/pitScouting") {
                        Navigator.pop(context);

                        // If currently on the home page, push pit scouting
                      } else if (ModalRoute.of(context)!.settings.name == "/") {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => Directionality(
                                textDirection: TextDirection.rtl,
                                child: TeamSelectionPage(
                                  api: widget.api,
                                  schedule: widget.schedule,
                                )),
                          ),
                        );
                      } else {
                        // If not on the pit scouting page, close the drawer and navigate to the pit scouting page
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => Directionality(
                                textDirection: TextDirection.rtl,
                                child: TeamSelectionPage(
                                  api: widget.api,
                                  schedule: widget.schedule,
                                )),
                          ),
                        );
                      }
                    }),

                ListTile(
                  // => Snake
                  leading: const Icon(Icons.videogame_asset_rounded),
                  title: const Text("נחש",
                      style:
                          TextStyle(color: Color.fromARGB(255, 108, 108, 108))),
                  onTap: () {
                    // If currently on home page - regular push
                    if (ModalRoute.of(context)!.settings.name == "/") {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const Snake(),
                        ),
                      );
                    } else {
                      // If not on home page - replace the current page with snake
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const Snake(),
                        ),
                      );
                    }
                  },
                ),
                const Divider(
                  color: Color.fromARGB(255, 108, 108, 108),
                  thickness: 0.5,
                ),

                FutureBuilder(
                  future: UserManager().checkAdmin(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data == true) {
                        return ListTile(
                          // => Admin
                          leading:
                              const Icon(Icons.admin_panel_settings_rounded),
                          title: const Text("אדמין",
                              style: TextStyle(
                                  color: Color.fromARGB(255, 108, 108, 108))),
                          onTap: () {
                            // If currently on home page - regular push
                            if (ModalRoute.of(context)!.settings.name == "/") {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => Directionality(
                                    textDirection: TextDirection.rtl,
                                    child: AdminMain(),
                                  ),
                                ),
                              );
                            } else {
                              // If not on home page - replace the current page with admin page
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => Directionality(
                                    textDirection: TextDirection.rtl,
                                    child: AdminMain(),
                                  ),
                                ),
                              );
                            }
                          },
                        );
                      } else {
                        return Container();
                      }
                    } else {
                      return Container();
                    }
                  },
                ),

                Align(
                    alignment: Alignment.bottomCenter,
                    child: ListTile(
                      // Logging out from the account
                      leading: const Icon(Icons.logout),
                      title: const Text("יציאה מהחשבון",
                          style: TextStyle(
                              color: Color.fromARGB(255, 108, 108, 108))),
                      onTap: () async {
                        UserManager().signOut();
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class UserInfo extends StatefulWidget {
  /// --- UserInfo ---
  /// This is the widget that displays the user's info.
  ///
  /// --- Contents ---
  /// - Username
  /// - Email
  /// - Photo
  ///
  /// -----------------

  final String username;
  final String email;
  final String photoURL;

  const UserInfo(
      {Key? key,
      required this.username,
      required this.email,
      required this.photoURL})
      : super(key: key);

  @override
  State<UserInfo> createState() => _UserInfoState();
}

class _UserInfoState extends State<UserInfo> {
  @override
  Widget build(BuildContext context) {
    String accountName = widget.username;
    String accountEmail = widget.email;
    CachedNetworkImage accountPhoto = CachedNetworkImage(
      placeholder: (context, url) => Image.asset('assets/Images/loading.gif'),
      imageUrl: widget.photoURL,
    );

    return FutureBuilder(
      future: UserManager().checkAdmin(),
      builder: ((context, snapshot) {
        bool isAdmin = false;
        if (snapshot.hasData) {
          isAdmin = snapshot.data!;
        }

        return UserAccountsDrawerHeader(
            // Returning 'UserAccountsDrawerHeader' widget
            accountName: Text(
              isAdmin ? "$accountName ★" : accountName,
              style: TextStyle(color: isAdmin ? Colors.purple : Colors.white),
            ),
            accountEmail: Text(
              accountEmail,
              style: TextStyle(color: isAdmin ? Colors.purple : Colors.white),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.orange[600],
              child: accountPhoto,
            ),
            decoration: BoxDecoration(
                gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                Colors.orange,
                Colors.orange.shade600,
                Colors.orange.shade700,
                Colors.orange.shade800,
                Colors.orange.shade900,
              ],
            )));
      }),
    );
  }
}
