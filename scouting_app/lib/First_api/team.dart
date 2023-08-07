class Team {
  int teamNum;
  String teamName;
  String teamNickname;
  String encodedAvatar;

  //constructor all variables are required
  Team(
      {required this.teamNum,
      required this.teamName,
      required this.teamNickname,
      required this.encodedAvatar});

  String getTeamName() {
    return teamName;
  }

  String getTeamNickname() {
    return teamNickname;
  }

  int getTeam() {
    return teamNum;
  }

  factory Team.fromJson(Map<String, dynamic> json, String encodedAvatar) {
    //chaek if the string "teamNumber" is in the json
    if (json.containsKey("teamNumber")) {
      return Team(
          teamNum: json['teamNumber'],
          teamName: json['nameFull'],
          teamNickname: json['nameShort'],
          encodedAvatar: encodedAvatar);
    } else {
      var team = json['teams'];
      team = team[0];
      return Team(
          teamNum: team['teamNumber'],
          teamName: team['nameFull'],
          teamNickname: team['nameShort'],
          encodedAvatar: encodedAvatar);
    }
  }
}
