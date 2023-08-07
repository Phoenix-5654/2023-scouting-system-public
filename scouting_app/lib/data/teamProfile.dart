import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:scouting_demo/First_api/first_api.dart';
import 'package:scouting_demo/widgets/globalDataManager.dart';
import 'package:scouting_demo/widgets/userManager.dart';

import '../pages/Pit_Scouting/teamSelectionPage.dart';

class QuestionData {
  QuestionData({
    required this.text,
    required this.answers,
    required this.isMultiple,
    required this.isTextOnly,
    required this.isTitle,
  });

  String text;
  Map<String, dynamic> answers;
  bool isMultiple;
  bool isTextOnly;
  bool isTitle;
}

class AutonomusPattern {
  Map<List<int>, String> data = {};
  Map<List<int>, TextEditingController> comments = {};

  AutonomusPattern({required this.data, required this.comments});
}

class AutonomusData {
  /// --- Autonomous Data ---
  /// Containts the data about the autonomus period of the match
  ///
  /// # Variables:
  /// - cycleAmount: The amount of cycles the robot can do in autonomous
  /// - patternAmount: The amount of different autonomous patterns the robot can do
  /// - isEngaded: If the robot is able to engage during the autonomous period
  ///

  late int patternAmount;

  List<AutonomusPattern> patterns = [];
}

class Comment {
  /// --- Comment ---
  /// Containts the data about a comment
  ///
  /// # Variables:
  /// - comment: The comment itself
  /// - time: The time the comment was made
  ///

  late String comment;
  late DateTime time;
  late String author;

  // Constructor
  Comment({required this.comment, required this.time, required this.author});

  // Get comment
  String getComment() {
    if (comment.isNotEmpty) {
      return comment;
    } else {
      return 'N/A';
    }
  }

  // Get time
  String getTime() {
    // Returning the time in the format: %H:%M %d/%m/%Y
    return '${time.toString().substring(11, 16)}  ${time.toString().substring(8, 10)}/${time.toString().substring(5, 7)}/${time.toString().substring(0, 4)}';
  }

  String getAuthor() {
    return author;
  }
}

class TeamProfile {
  /// --- Team Profile ---
  /// Contains the collected general data about a certain team.
  ///
  /// # Variables:
  /// - doesExist: If the team exists in the database (Purely code use, not actual team data)
  /// - teamNum: The team number
  /// - autonomusData: The data about the autonomus period of the match
  /// - comments: The comments about the team
  /// - teamData: The data about the team (General data according to questions)
  ///
  /// # Methods:
  /// - updateTeam: Updates the team profile with the data from the firestore database
  /// - doesTeamExists (static): Checks whether a certain team exists in the dataset
  ///

  final teamNum;

  final bool isMatch;

  late bool doesExist = false;

  late AutonomusData autonomusData = AutonomusData();
  final comments = ValueNotifier(<Comment>[]);

  final teamData = ValueNotifier(<QuestionData, dynamic>{});
  final autonomusQuestions = ValueNotifier(<QuestionData>[]);
  final mainQuestions = ValueNotifier(<QuestionData>[]);

  TeamProfile(this.teamNum, {this.isMatch = false});

  Future<TeamProfile> synchronizeTeam() async {
    if (await doesTeamExist(teamNum)) {
      doesExist = true;

      // Saving the questions using getQuestions()
      var questions = await getQuestions();

      var db = FirebaseFirestore.instance;

      // Accessing the team's data (/teams/<teamNum>/history/<doc>)
      await db
          .collection('teams')
          .doc(teamNum.toString())
          // Get 'history' collection, order by time, get the last document
          .collection('pit_history')
          .orderBy('time', descending: true)
          .limit(1)
          .get()
          .then((doc) {
        // Save question answers in a loop, if don't exist, set to N/A

        for (var question in questions) {
          // Check if the question exists
          try {
            teamData.value[question] = doc.docs[0][question];
          } catch (e) {
            // If the question doesn't exist, set it to N/A
            teamData.value[question] = 'N/A';
          }
        }
      });

      await db.collection('teams').doc(teamNum.toString()).get().then((doc) {
        if (doc.exists) {
          // Save question answers in a loop, if don't exist, set to N/A
          // Question format: <teamNum>/<answer>

          for (var question in questions) {
            // Check if the question exists
            try {
              teamData.value[question] = doc[question];
            } catch (e) {
              // If the question doesn't exist, set it to N/A
              teamData.value[question] = 'N/A';
            }
          }
        }
      }).onError((error, stackTrace) {
        log("Error while getting team data: $error");
      });

      // Saving the comments (/teams/<teamNum>/comments)
      var comments = List<Comment>.empty(growable: true);

      // Get the comments from the database, if the 'comments' collection exists
      synchronizeComments();

      // Saving the autonomus data (/teams/<teamNum>/pit_history/autonomus/autonomus/<doc>)
      // Save all the data in a loop
      var patterns = List<AutonomusPattern>.empty(growable: true);

      db
          .collection('teams')
          .doc(teamNum.toString())
          .collection('pit_history')
          .doc('autonomus')
          .collection('autonomus')
          .get()
          .then((doc) {
        int i = 0;
        Map<List<int>, String> data = {};
        Map<List<int>, TextEditingController> comments = {};

        var keys = doc.docs[0].data().keys.toList();
        var vals = doc.docs[0].data().values.toList();

        for (var key in keys) {
          var val = vals[i];

          List<int> coords = [val[0], val[1]];

          var iconData = val[2];
          String comment = val[3];

          data[coords] = iconData;
          comments[coords] = TextEditingController(text: comment);

          i++;
        }

        patterns.add(AutonomusPattern(data: data, comments: comments));
      }).onError((error, stackTrace) {
        log("Error while getting autonomus data: $error");
      });

      autonomusData.patterns = patterns;
      autonomusData.patternAmount = patterns.length;
    } else {
      doesExist = false;

      autonomusData = AutonomusData();
      // Save question answers in a loop (set to N/A)
      var questions = await getQuestions();
      for (var question in questions) {
        teamData.value[question] = 'N/A';
      }

      updateTeamData(addTeam: true);
    }

    // Save autonomous questions (all questions between 'autonomus' and 'endgame')
    var autonomusQuestions = List<QuestionData>.empty(growable: true);
    var mainQuestions = List<QuestionData>.empty(growable: true);
    bool isAutonomus = false;
    bool isEndgame = false;

    log("Saving autonomus and main questions...");

    for (var entry in teamData.value.entries) {
      log("Question: ${entry.key.text} (${entry.key.isTitle ? 'Title' : 'Question'})");
      if (entry.key.isTitle && entry.key.text == 'אוטונומי') {
        log("Found autonomus title");
        isAutonomus = true;
      } else if (entry.key.isTitle && entry.key.text == 'שלב ה-endgame') {
        log("Found endgame title");
        isEndgame = true;
      }

      if (isAutonomus && !isEndgame) {
        autonomusQuestions.add(entry.key);
        log("Added autonomus question: ${entry.key.text}");
      }

      if (isAutonomus && isEndgame) {
        mainQuestions.add(entry.key);
        log("Added main question: ${entry.key.text}");
      }
    }

    this.autonomusQuestions.value = autonomusQuestions;
    this.mainQuestions.value = mainQuestions;

    return this;
  }

  Future<void> synchronizeComments() async {
    var comments = List<Comment>.empty(growable: true);
    var db = FirebaseFirestore.instance;
    // Get the comments from the database, if the 'comments' collection exists
    await db
        .collection('teams')
        .doc(teamNum.toString())
        .collection('comments')
        .get()
        .then((value) {
      value.docs.forEach((element) {
        comments.add(Comment(
            comment: element['comment'],
            time: element['time'].toDate(),
            author: element['author']));
        log("Added comment: ${element['comment']}");
      });

      this.comments.value = comments;
    }).onError((error, stackTrace) {
      log("Error while getting comments: $error");
    });
  }

  // Function that returns valueNotifier with the team's data, but only the questions
  // that are between the 'autonomous' and 'endgame' data

  ValueNotifier<Map<QuestionData, dynamic>> getAutonomousQuestions() {
    var res = ValueNotifier<Map<QuestionData, dynamic>>({});

    bool isAutonomous = false;
    bool isEndgame = false;

    for (var entry in teamData.value.entries) {
      log("Checking: ${entry.key.text} - ${entry.value}");
      if (entry.key.isTitle && entry.key.text == 'אוטונומי') {
        log("Found autonomus");
        isAutonomous = true;
      } else if (entry.key.isTitle && entry.key.text == 'שלב ה-endgame') {
        log("Found endgame");
        isEndgame = true;
      }

      if (isAutonomous && !isEndgame && !entry.key.isTitle) {
        res.value[entry.key] = entry.value;
        log("Autonomus: ${entry.key.text} - ${entry.value}");
      }
    }

    // Show 'res'
    log("Autonomus questions:");
    for (var entry in res.value.entries) {
      log("${entry.key.text} - ${entry.value}");
    }

    return res;
  }

  // Function that returns valueNotifier with the team's data, but only the questions
  // that are after the 'endgame' data
  ValueNotifier<Map<QuestionData, dynamic>> getMainQuestions() {
    var res = ValueNotifier<Map<QuestionData, dynamic>>({});

    bool isEndgame = false;

    for (var entry in teamData.value.entries) {
      log("Checking: ${entry.key.text} - ${entry.value}");
      if (entry.key.isTitle && entry.key.text == 'שלב ה-endgame') {
        log("Found endgame");
        isEndgame = true;
      }

      if (isEndgame) {
        res.value[entry.key] = entry.value;
        log("Endgame: ${entry.key.text} - ${entry.value}");
      }
    }

    // Show 'res'
    log("Endgame questions:");
    for (var entry in res.value.entries) {
      log("${entry.key.text} - ${entry.value}");
    }

    return res;
  }

  // Function that returns a list of questions
  Future<List<QuestionData>> getQuestions() async {
    // Accessing the questions from firestore
    var db = FirebaseFirestore.instance;
    var res = List<QuestionData>.empty(growable: true);

    // Get questions from: /questions/pit_scouting/<question>
    // Each question is a document with the following fields:
    // - ID: The question
    // - answers: List of answers (string)
    // - isMultiple: Whether the question is multiple choice or not
    // - isAnother: Whether the question has an 'other' option or not

    if (isMatch) {
      await db
          .collection('questions')
          .doc((isMatch) ? 'scouting' : 'pit_scouting')
          .collection('questions')
          .orderBy('order', descending: false)
          .get()
          .then((value) {
        value.docs.forEach((element) {
          res.add(QuestionData(
            text: element.id,
            // Save the answers as a map (answer: false), if there are no answers, set to empty map
            answers: Map.fromIterable(
                element['isTitle'] ? [] : element['answers'],
                key: (e) => e,
                value: (e) => false),
            isMultiple: element['isTitle'] ? false : element['isMultiple'],
            isTextOnly: element['isTitle'] ? false : element['isTextOnly'],
            isTitle: element['isTitle'],
          ));
        });
      });
    } else {
      await db
          .collection('questions')
          .doc('pit_scouting')
          .collection('questions')
          .get()
          .then((value) {
        value.docs.forEach((element) {
          res.add(QuestionData(
            text: element.id,
            // Save the answers as a map (answer: false), if there are no answers, set to empty map
            answers: Map.fromIterable(element['answers'],
                key: (e) => e, value: (e) => false),
            isMultiple: element['isMultiple'],
            isTextOnly: element['isTextOnly'],
            isTitle: false,
          ));
        });
      });
    }

    // Log the questions
    for (var question in res) {
      log("Question: ${question.text}");
    }

    return res;
  }

  static Future<bool> doesTeamExist(int teamNum) async {
    // Check if certain team exists
    var db = FirebaseFirestore.instance;
    var res = false;

    await db.collection('teams').doc(teamNum.toString()).get().then((doc) {
      if (doc.exists) {
        res = true;
        print("Team indeed exists.");
      }
    });

    return res;
  }

  // Getter for 'baseData'
  Map<QuestionData, dynamic> getBaseData() {
    return teamData.value;
  }

  Future<void> addCommment(String text) async {
    var db = FirebaseFirestore.instance;

    // If there is logged user - the author is the mail,
    // if not - author is 'ERROR'

    String author = 'ERROR';

    if (UserManager().user != null) {
      author = UserManager().user!.email!;
    }

    db
        .collection('teams')
        .doc(TeamSelectionPage.selectedTeam.value.teamNum.toString())
        .collection('comments')
        .add({
      'comment': text,
      'time': DateTime.now(),
      'author': author,
    });

    var temp = comments.value;

    temp.add(Comment(
      comment: text,
      time: DateTime.now(),
      author: author,
    ));
    temp.sort((a, b) => a.time.compareTo(b.time)); // Sorting the comment
    comments.value = temp;

    // Update the team profile
    await synchronizeTeam();
  }

  Future<void> updateTeamData({bool addTeam = false}) async {
    // Upload new entry to the /teams/<teamNum>/history/<autogenerated id>
    // with the updated data

    var db = FirebaseFirestore.instance;

    // If the team doesn't exist, create it

    var eventYear = ValueNotifier(DateTime.now().year.toString());
    var eventKey = ValueNotifier('jcmp');

    var api = FIRST_API();
    api.init(eventCode: eventKey.value, year: eventYear.value);

    eventYear.addListener(() {
      if (eventYear.value != '') {
        api.setYear(eventYear.value);
      }
    });

    eventKey.addListener(() {
      if (eventKey.value != '') {
        api.setEventCode(eventKey.value);
      }
    });

    if (addTeam) {
      await db.collection('teams').doc(teamNum.toString()).set({
        'team_num': teamNum,
        'team_nickname': await api.getTeam(teamNum).then((value) {
          return value.teamNickname;
        }),
      });
    }

    // Log all data
    log(" -- Team data --\nUPDATE: $addTeam");
    for (var entry in teamData.value.entries) {
      log("${entry.key.text}: ${entry.value.toString()}");
    }

    // Get the current time
    var now = DateTime.now();

    // Saving the data in the format: <question>: <answer as string>
    // If the answer is a list, it will be converted to a string (e.g. 1, 2, 3)
    // If the answer is a map, it will be converted to a string containing the
    // true answers only (e.g. 1, 3), without '[]' or '{}' or '()'
    // And save answers only if they are not 'N/A'

    // For 'אחר' (other), the passed data will be the text in the text field
    // and not the boolean value

    Map<String, dynamic> data = {};

    for (var entry in teamData.value.entries) {
      if (entry.key.isTitle) {
        continue;
      }
      if (entry.value != "N/A") {
        if (entry.value is Map) {
          // Iterate over the map, and add it to the data as a string
          String temp = '';

          for (var mapEntry in entry.value.entries) {
            if (mapEntry.value is bool && mapEntry.value) {
              temp += '${mapEntry.key}, ';
            } else if (mapEntry.value is String) {
              temp += '${mapEntry.value}, ';
            }
          }

          // Remove the last ', '
          temp = temp.substring(0, temp.length - 2);

          data[entry.key.text] = temp;
        } else {
          data[entry.key.text] = entry.value.toString();
        }
      } else {
        log("Question ${entry.key.text} is N/A", name: 'Team Data Saving');
      }
    }
    // Add the time to the data
    data['time'] = now;

    // Log the data
    log(" -- Data to upload -- ");
    for (var entry in data.entries) {
      log("${entry.key}: ${entry.value.toString()}");
    }

    // Add the data to the database
    await db
        .collection('teams')
        .doc(teamNum.toString())
        .collection('pit_history')
        .add(data);

    log("Data uploaded", name: 'Team Data Saving');

    doesExist = true;
  }
}
