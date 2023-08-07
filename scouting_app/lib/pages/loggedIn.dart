import 'dart:async';
import 'dart:developer';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:scouting_demo/First_api/first_api.dart';
import 'package:scouting_demo/data/scheduleData.dart';
import 'package:scouting_demo/services/notification_service.dart';
import 'package:scouting_demo/widgets/orangeAppBar.dart';
import 'package:scouting_demo/widgets/userManager.dart';
import 'package:scouting_demo/widgets/userStateManager.dart';

import '../First_api/team.dart';
import '../widgets/navigationDrawer.dart' as nav;

class LoggedIn extends StatefulWidget {
  LoggedIn({super.key, required this.api});

  FIRST_API api;

  @override
  State<LoggedIn> createState() => _LoggedInState();
}

class _LoggedInState extends State<LoggedIn> with WidgetsBindingObserver {
  var imagePaths = [
    "assets/Images/propoganda_1.jpg",
    "assets/Images/propoganda_2.webp",
    "assets/Images/propoganda_3.jpg",
    "assets/Images/propoganda_4.jpg",
    "assets/Images/propoganda_5.JpG",
    "assets/Images/propoganda_6.jpg",
  ];

  ValueNotifier<Map<String, List<dynamic>>> schedule = ValueNotifier({});

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    UserStateManager.setUserState(UserStates.Online);

    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );

    NotificationService.initializeNotifications();

    // Set the schedule to update every so often
    Timer.periodic(const Duration(seconds: 60), (Timer t) {
      try {
        log("Updating schedule", name: "LoggedIn - Schedule Updates");
        ScheduleData().getSchedule(schedule);
        notifyCloseMatches(schedule);
      } on CastError catch (e) {
        // On cast error, the schedule is not ready yet. Log it and continue
        log("Error updating schedule: $e | ${e.runtimeType} - Schedule not ready, continuing",
            name: "LoggedIn - Schedule Updates");
      } catch (e) {
        log("Error updating schedule: $e | ${e.runtimeType}",
            name: "LoggedIn - Schedule Updates");
        t.cancel();
        return;
      }
    });
  }

  @override
  dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Change the user state to online when the app is resumed
    // but if user is in a match, don't change the state

    if (state == AppLifecycleState.resumed) {
      if (UserManager().user!.displayName != 'משתמש זמני') {
        UserStateManager.setUserState(UserStates.Online);
      }
    } else if (state == AppLifecycleState.paused) {
      UserStateManager.setUserState(UserStates.Offline);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: orangeAppBar(''),
      drawer: nav.NavigationDrawer(
        api: widget.api,
        schedule: schedule,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(25, 50, 25, 50),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              DelayedDisplay(
                fadeIn: true,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('שלום '),
                    Text(
                      UserManager().user!.displayName!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              AnimatedTextKit(
                animatedTexts: [
                  TypewriterAnimatedText(
                    curve: Curves.easeInOut,
                    'ברוכים הבאים\nלאפליקציית הסקאוטינג של פניקס',
                    textAlign: TextAlign.center,
                    textStyle: const TextStyle(
                      fontSize: 20,
                      color: Colors.orange,
                      fontFamily: 'typeWriter-3',
                      fontWeight: FontWeight.bold,
                    ),
                    speed: const Duration(milliseconds: 125),
                    cursor: '|',
                  ),
                ],
                isRepeatingAnimation: false,
              ),
              Container(
                height: 50,
                child: DelayedDisplay(
                  delay: const Duration(seconds: 5),
                  fadeIn: true,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      DefaultTextStyle(
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.black12,
                          fontSize: 25.0,
                        ),
                        child: AnimatedTextKit(
                          animatedTexts: [
                            FadeAnimatedText(
                                'Globally Avilable Data Interface'),
                            RotateAnimatedText('aka'),
                            FlickerAnimatedText('Project G.A.D.I',
                                entryEnd: 0.5),
                          ],
                          isRepeatingAnimation: true,
                          repeatForever: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Center(
                child: CarouselSlider.builder(
                    itemCount: imagePaths.length,
                    itemBuilder: (context, index, realIndex) {
                      return Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(imagePaths[index]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                    options: CarouselOptions(
                      autoPlay: true,
                      autoPlayInterval: const Duration(seconds: 5),
                      autoPlayAnimationDuration:
                          const Duration(milliseconds: 800),
                      autoPlayCurve: Curves.fastOutSlowIn,
                      enlargeCenterPage: true,
                      aspectRatio: 1,
                      onPageChanged: (index, reason) {
                        setState(() {});
                      },
                    )),
              )
            ],
          ),
        ),
      ),
    );
  }

  void notifyCloseMatches(ValueNotifier<Map<String, List>> schedule) {
    // Get the current time
    var now = DateTime.now();

    for (var match in schedule.value.values) {
      var matchTime = DateTime.fromMillisecondsSinceEpoch(
          ((double.parse(match[0]) - 25569) * 86400000).toInt(),
          isUtc: true);

      // set the date to be the same as the current date
      matchTime = DateTime(now.year, now.month, now.day, matchTime.hour,
          matchTime.minute, matchTime.second);

      // log the match time, and the difference between the match time and now
      log("Match time: $matchTime | Difference: ${matchTime.difference(now)}",
          name: "LoggedIn - Schedule Updates");

      // Clear all Notifications before scheduling new ones
      NotificationService.clearNotifications();

      var schedule_30_before = NotificationCalendar.fromDate(
          date: matchTime.subtract(const Duration(minutes: 30)));

      var schedule_10_before = NotificationCalendar.fromDate(
          date: matchTime.subtract(const Duration(minutes: 10)));

      var schedule_5_before = NotificationCalendar.fromDate(
          date: matchTime.subtract(const Duration(minutes: 5)));

      var schedule_1_before = NotificationCalendar.fromDate(
          date: matchTime.subtract(const Duration(minutes: 1)));

      // Log all the times
      log("30 minutes before: ${schedule_30_before.hour} : ${schedule_30_before.minute} | 10 minutes before: ${schedule_10_before.hour} : ${schedule_10_before.minute} | 5 minutes before: ${schedule_5_before.hour} : ${schedule_5_before.minute} | 1 minute before: ${schedule_1_before.hour} : ${schedule_1_before.minute}",
          name: "LoggedIn - Schedule Updates");

      // Schedule the notification
      NotificationService.showNotification(
        title: "התראת מקצה",
        body: "יש לך מקצה בעוד בעוד 30 דקות",
        scheduled: true,
        schedule: schedule_30_before,
      );

      NotificationService.showNotification(
        title: "התראת מקצה",
        body: "יש לך מקצה בעוד בעוד 10 דקות",
        scheduled: true,
        schedule: schedule_10_before,
      );

      NotificationService.showNotification(
        title: "התראת מקצה",
        body: "יש לך מקצה בעוד בעוד 5 דקות",
        scheduled: true,
        schedule: schedule_5_before,
      );

      NotificationService.showNotification(
        title: "התראת מקצה",
        body: "יש לך מקצה בעוד בעוד 1 דקות",
        scheduled: true,
        schedule: schedule_1_before,
      );
    }
  }
}
