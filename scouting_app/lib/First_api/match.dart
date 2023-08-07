import 'team.dart';

class match {
  // Lists to store the red and blue alliances (map int to string)
  List<int> redAlliance;
  List<int> blueAlliance;

  // The match number for this match
  int matchNumber;
  String description;
  String time;

  // Constructor for the Match class
  // All of the following arguments are required
  match(
      {this.redAlliance = const [],
      this.blueAlliance = const [],
      this.matchNumber = 0,
      this.description = "",
      this.time = ""});
  // Getter method for the red team's auto score

  // Getter method for
  int getMatchNumber() {
    return matchNumber;
  }

  // Getter method for the red teams
  List<int> getRedTeams() {
    return redAlliance;
  }

  // Getter method for the blue teams
  List<int> getBlueTeams() {
    return blueAlliance;
  }

  static match fromJson(Map<String, dynamic> json) {
    // Get the match number
    int matchNumber = json['matchNumber'];

    // Get the description
    String description = json['description'];
    String time = json['startTime'];

    List<int> redAllianceInt = [];
    List<int> blueAllianceInt = [];

    // Get all of the teams
    for (var team in json["teams"]) {
      // Check if the team is on the red alliance (station parameter contains "Red")
      if (team["station"].contains("Red")) {
        // Add the team to the red alliance list
        redAllianceInt.add(team["teamNumber"] ?? -1);
      } else {
        // Add the team to the blue alliance list
        blueAllianceInt.add(team["teamNumber"] ?? -1);
      }
    }

    // Return the match
    return match(
        redAlliance: redAllianceInt,
        blueAlliance: blueAllianceInt,
        matchNumber: matchNumber,
        description: description,
        time: time);
  }
}
