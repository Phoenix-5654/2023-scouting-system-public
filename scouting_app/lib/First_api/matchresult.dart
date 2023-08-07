import 'match.dart';

class MatchResult {
  int matchNumber;
  int scoreBlueFinal;
  int scoreRedFinal;
  int scoreRedAuto;
  int scoreBlueAuto;
  int scoreBlueFoul;
  int scoreRedFoul;

  MatchResult(
      {required this.matchNumber,
      required this.scoreBlueFinal,
      required this.scoreRedFinal,
      required this.scoreRedAuto,
      required this.scoreBlueAuto,
      required this.scoreBlueFoul,
      required this.scoreRedFoul});

  int getMatchNumber() {
    return matchNumber;
  }

  int getScoreBlueFinal() {
    return scoreBlueFinal;
  }

  int getScoreRedFinal() {
    return scoreRedFinal;
  }

  int getScoreRedAuto() {
    return scoreRedAuto;
  }

  int getScoreBlueAuto() {
    return scoreBlueAuto;
  }

  int getScoreBlueFoul() {
    return scoreBlueFoul;
  }

  int getScoreRedFoul() {
    return scoreRedFoul;
  }

  int getgetScoreRedTelop() {
    return scoreRedFinal - scoreRedAuto - scoreRedFoul;
  }

  int getgetScoreBlueTelop() {
    return scoreBlueFinal - scoreBlueAuto - scoreBlueFoul;
  }

  static MatchResult fromJson(Map<String, dynamic> json) {
    // Get the match number
    int matchNumber = json['matchNumber'];

    int scoreBlueFinal = json['scoreBlueFinal'];
    int scoreRedFinal = json['scoreRedFinal'];

    int scoreRedAuto = json['scoreRedAuto'];
    int scoreBlueAuto = json['scoreBlueAuto'];

    int scoreBlueFoul = json['scoreBlueFoul'];
    int scoreRedFoul = json['scoreRedFoul'];

    return MatchResult(
        matchNumber: matchNumber,
        scoreBlueFinal: scoreBlueFinal,
        scoreRedFinal: scoreRedFinal,
        scoreRedAuto: scoreRedAuto,
        scoreBlueAuto: scoreBlueAuto,
        scoreBlueFoul: scoreBlueFoul,
        scoreRedFoul: scoreRedFoul);
  }
}
