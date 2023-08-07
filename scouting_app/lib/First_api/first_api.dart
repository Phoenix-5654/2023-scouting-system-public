///this is a TBA API wrapper for Dart

import 'dart:io';
import 'dart:math';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:http/http.dart' as http;

import 'dart:convert';

import 'team.dart';
import 'match.dart';
import 'matchresult.dart';

class FIRST_API {
  var headers;

  String _baseURL = "https://frc-api.firstinspires.org/v3.0/";
  String _year = "";

  String _eventCode = "jcmp";
  //cashe
  //maches cashe
  Map<String, List<match>> matchesCashe = {};
  //team cashe
  Map<int, Team> teamCashe = {};
  //team avatars cashe
  Map<int, String> teamAvatarsCashe = {};

  void init({required String year, required String eventCode}) {
    var key =
        'CLASSIFIED';
    var temp = {'Authorization': 'Basic $key', 'If-Modified-Since': ''};
    headers = temp;
    setYear(year);

    matchesCashe = {'Practice': [], 'Qualification': [], 'Playoff': []};
    teamCashe = {};
    teamAvatarsCashe = {};
  }

  //set the year
  void setYear(String year) {
    _year = year;
  }

  String getYear() {
    return _year;
  }

  void setEventCode(String eventCode) {
    _eventCode = eventCode;
  }

  String getEventCode() {
    return _eventCode;
  }

  Future<String?> getKey() async {
    var res;

    print("Attempting to get key...");

    // Saving the key (/API_key/first_API/key)
    var db = FirebaseFirestore.instance;
    await db.collection('API_key').doc('first_API').get().then((doc) {
      if (doc.exists) {
        res = doc['key'];
      }
    });

    print("Result is: " + res.toString());

    return res;
  }

  //get a list of all the Avatars for the teams in the event
  Future<Map<int, String>> getEventAvatars() async {
    //get the list of teams for the event
    //check if the teams are in the cashe
    if (teamAvatarsCashe.isNotEmpty) {
      return teamAvatarsCashe;
    }
    var request = http.Request(
        'GET',
        Uri.parse('https://frc-api.firstinspires.org/v3.0/' +
            _year +
            '/avatars?eventCode=' +
            _eventCode));

    request.headers.addAll(headers);

    var response = await request.send();
    Map<int, String> Avatars = {};
    if (response.statusCode == 200) {
      //decode the response
      var a = await response.stream.bytesToString();
      var decoded = jsonDecode(a);
      //create a Team object

      for (var team in decoded['teams']) {
        Avatars[team['teamNumber']] = team['encodedAvatar'];
        teamAvatarsCashe[team['teamNumber']] = team['encodedAvatar'];
      }

      return Avatars;
    } else if (response.statusCode == 404) {
      return Avatars;
    } else {
      //throw Exception("Failed to load teams");
      return getEventAvatars();
    }
  }

  //get team avatar
  Future<String> getTeamAvatar(int teamNumber) async {
    //check if the team is in the cashe
    if (teamAvatarsCashe.containsKey(teamNumber)) {
      return teamAvatarsCashe[teamNumber]!;
    }

    //get a Team from the FIRST_EVENTS API
    var request = http.Request(
        'GET',
        Uri.parse('https://frc-api.firstinspires.org/v3.0/' +
            _year +
            '/avatars?teamNumber=' +
            teamNumber.toString()));

    request.headers.addAll(headers);

    request.headers.addAll(headers);

    var response = await request.send();
    if (response.statusCode == 200) {
      //decode the response
      var a = await response.stream.bytesToString();
      var decoded = jsonDecode(a);
      //create a Team object
      //if the team is not in the cashe, add it
      if (!teamAvatarsCashe.containsKey(teamNumber)) {
        teamAvatarsCashe[teamNumber] = decoded['teams']['encodedAvatar'];
      }
      return decoded['teams']['encodedAvatar'];
    }
    //if the request 404s, return an empty list
    else if (response.statusCode == 404) {
      return "";
    } else {
      //throw Exception("Failed to load team");
      return getTeamAvatar(teamNumber);
    }
  }

  Future<List<match>> getMatches(int type) async {
    //get the list of teams for the event
    String typeString = "";
    if (type == 0) {
      typeString = "Practice";
    } else if (type == 1) {
      typeString = "Qualification";
    } else if (type == 2) {
      typeString = "Playoff";
    }
    //check if the matches are in the cashe
    if (matchesCashe.containsKey(typeString)) {
      if (matchesCashe[typeString]!.isNotEmpty) {
        developer.log("Getting matches from cashe", name: "FIRST_API - Cashe");
        return matchesCashe[typeString]!;
      }
    }

    var request = http.Request(
        'GET',
        Uri.parse('https://frc-api.firstinspires.org/v3.0/' +
            _year +
            '/schedule/' +
            _eventCode +
            '?tournamentLevel=' +
            typeString));

    request.headers.addAll(headers);

    var response = await request.send();
    List<match> Matches = [];
    if (response.statusCode == 200) {
      //decode the response
      var a = await response.stream.bytesToString();
      var decoded = jsonDecode(a);
      //create a Team object

      for (var Match in decoded['Schedule']) {
        Matches.add(match.fromJson(Match));

        matchesCashe[typeString]!.add(Matches.last);
      }
      return Matches;
    } else if (response.statusCode == 404) {
      return Matches;
    } else {
      //throw Exception("Failed to load matches");
      sleep(const Duration(seconds: 30));
      return getMatches(type);
    }
  }

  Future<Team> getTeam(int teamNumber) async {
    //check if the team is in the cashe
    if (teamCashe.containsKey(teamNumber)) {
      developer.log("Getting team from cashe");
      return teamCashe[teamNumber]!;
    }
    //get a Team from the FIRST_EVENTS API
    var request = http.Request(
        'GET',
        Uri.parse('https://frc-api.firstinspires.org/v3.0/' +
            _year +
            '/teams?teamNumber=' +
            teamNumber.toString()));

    request.headers.addAll(headers);

    var response = await request.send();
    if (response.statusCode == 200) {
      //decode the response
      var a = await response.stream.bytesToString();
      var decoded = jsonDecode(a);

      //get the team picture
      //dynamic avatar = await getTeamAvatar(teamNumber);
      //create a Team object
      Team team = Team.fromJson(decoded, '');
      //add the team to the cashe
      teamCashe[teamNumber] = team;
      return team;
    }
    //if the request 404s, return an empty list
    else if (response.statusCode == 404) {
      return Team(
          teamNum: -1,
          teamName: "Team Not Found",
          teamNickname: "Team Not Found",
          encodedAvatar: "");
    } else {
      //throw Exception("Failed to load team");
      sleep(const Duration(seconds: 30));
      return getTeam(teamNumber);
    }
  }

  //get a list of teams for an event
  Future<List<Team>> getTeams() async {
    //check if teamscashe is empty
    if (teamCashe.isNotEmpty) {
      developer.log("Getting teams from cashe");
      return teamCashe.values.toList();
    }

    List<Team> teams = [];

    //get the list of teams for the event
    var request = http.Request(
        'GET',
        Uri.parse('https://frc-api.firstinspires.org/v3.0/' +
            _year +
            '/teams?eventCode=' +
            _eventCode));

    request.headers.addAll(headers);

    var response = await request.send();

    if (response.statusCode == 200) {
      //decode the response
      var a = await response.stream.bytesToString();
      var decoded = jsonDecode(a);
      //get all the avatars
      Map<int, String> avatars = await getEventAvatars();

      for (var team in decoded['teams']) {
        int teamNum = team['teamNumber'] ?? 0;
        if (avatars.containsKey(teamNum)) {
          teams.add(Team.fromJson(team, avatars[teamNum]!));
        } else {
          teams.add(Team.fromJson(team, ""));
        }
        //add the team to the cashe if it is not already there
        if (!teamCashe.containsKey(teamNum)) {
          developer.log("Adding team to cashe");
          teamCashe[teamNum] = teams.last;
        }
      }
    }
    //if the request 404s, return an empty list
    else if (response.statusCode == 404) {
      return teams;
    } else {
      // throw Exception("Failed to load team");
      sleep(const Duration(seconds: 30));
      return getTeams();
    }

    //get the list of teams for the event
    request = http.Request(
        'GET',
        Uri.parse('https://frc-api.firstinspires.org/v3.0/' +
            _year +
            '/teams?eventCode=' +
            _eventCode +
            "&page=2"));

    request.headers.addAll(headers);

    response = await request.send();

    if (response.statusCode == 200) {
      //decode the response
      var a = await response.stream.bytesToString();
      var decoded = jsonDecode(a);
      //get all the avatars
      Map<int, String> avatars = await getEventAvatars();

      for (var team in decoded['teams']) {
        int teamNum = team['teamNumber'] ?? 0;
        if (avatars.containsKey(teamNum)) {
          teams.add(Team.fromJson(team, avatars[teamNum]!));
        } else {
          teams.add(Team.fromJson(team, ""));
        }
        //add the team to the cashe if it is not already there
        if (!teamCashe.containsKey(teamNum)) {
          developer.log("Adding team to cashe");
          teamCashe[teamNum] = teams.last;
        }
      }
    }

    return teams;
  }

  Future<MatchResult> getMatchResult(int matchNumber, int type) async {
    //get the list of teams for the event
    String typeString = "";
    if (type == 0) {
      typeString = "Practice";
    } else if (type == 1) {
      typeString = "Qualification";
    } else if (type == 2) {
      typeString = "Playoff";
    }

    var request = http.Request(
        'GET',
        Uri.parse('https://frc-api.firstinspires.org/v3.0/' +
            _year +
            '/matches/' +
            _eventCode +
            '?tournamentLevel=' +
            typeString +
            '&matchNumber=' +
            matchNumber.toString()));
    request.headers.addAll(headers);

    var response = await request.send();
    if (response.statusCode == 200) {
      //decode the response
      var a = await response.stream.bytesToString();
      var decoded = jsonDecode(a);
      decoded = decoded['Matches'];
      //get the match with the correct match number
      for (var match in decoded) {
        if (match['matchNumber'] == matchNumber) {
          return MatchResult.fromJson(match);
        }
      }
      MatchResult matchResult = MatchResult(
          matchNumber: -1,
          scoreBlueFinal: -1,
          scoreRedFinal: -1,
          scoreRedAuto: -1,
          scoreBlueAuto: -1,
          scoreBlueFoul: -1,
          scoreRedFoul: -1);
      return matchResult;
    }
    //if the request 404s, return an empty list
    else if (response.statusCode == 404) {
      MatchResult matchResult = MatchResult(
          matchNumber: -1,
          scoreBlueFinal: -1,
          scoreRedFinal: -1,
          scoreRedAuto: -1,
          scoreBlueAuto: -1,
          scoreBlueFoul: -1,
          scoreRedFoul: -1);
      return matchResult;
    } else {
      //throw Exception("Failed to load match");
      sleep(const Duration(seconds: 30));
      return getMatchResult(matchNumber, type);
    }
  }
}
