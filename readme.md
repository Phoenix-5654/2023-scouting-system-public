# Scouting System 2023

## Data gathering system, for the 2023 FRC season. Includes a Flutter App with Firebase integration, and a Google Sheets backend.

This project is a data gathering system for the 2023 FRC season. In the repository you will find a Flutter App, connected to Firebase, and the Google Sheets file, downloaded as a .XLSX file.

Repository contains:

* Scouting App: Flutter App, with Firebase integration. The front-end of the system. Used to gather the data for each match.
* Google Sheets: Google Sheets file, downloaded as a .XLSX file. The back-end of the system. Used to store and calculate the data gathered by the app.
* Prediction Model: Experimental prediction model, used to predict the outcome of a match, based on the data gathered by the app.

## Scouting App

The app is built using Flutter, and it's connected to Firebase. The app is used to gather data for each match. The data is then sent to Firebase, and stored in the Firestore database. Additionally, the data is being sent to the Google Sheets file, using the Google Sheets API.

**IMPORTANT NOTES:**
- All the sensitive data (API keys, etc.) was removed from the repository. To run the app, you will need to add your own API keys, and connect the app to your own Firebase project.
- The FIRST API integration is currently not updated to the new version, therefore, a lot of the app's functionality is missing. The proper integration may be added in the future.

Data gathered in the 'matchScoutingAutonomous' and 'matchScoutings' pages &rarr; Sent to Firebase (as backup) &rarr; Sent to Google Sheets 


## Google Sheets

**IMPORTANT NOTES:**

- The Google Sheets file is downloaded as a .XLSX file, and we advise to open and use it in Google Sheets. The behavior of the file in other programs is not guaranteed.
- The file attached to this repository is a copy of the original file, with all the sensetive data removed. The original file is stored in the team's Google Drive, and is not public.


The main pages, which actually were used during the season are:
- **Team Data**: Contains the gathered data for each team. For a selected team, the page shows the overall statistics (such as average points per match, average points per match in the autonomous period, etc.), and the data for each match seperately. The main data is displayed in few diagrams in the page. Additionally, the page contains a pit scouting table, with the data gathered in the pit scouting process, including an image of the robot.

![Alt text](/readme/team_data_1.gif?raw=true "Team Data")

- **Alliance Compare**: Contains the summary of main data for each team in a selected match. Used for displating the most important data for each team, and comparing the teams in the alliance. Additionally, the page contains a parking station calculator, where, based on the data gathered on the pit-scouting process, the user can calculate the best robot to place in each parking station.

![Alt text](/readme/alliance_compare_1.png?raw=true "Alliance Compare")

- **Pick List**: Perhaps the most important page in the file. Contains the final score for each team in the competition, with the ability to sort the teams by different scores: Their overall score, their score in the autonomous period, their score in the teleop period, and their score in the endgame. The scores are calculated regarding the robot profile, which means that whilst one team can be the best choice for the first pick, it wont necessarily be the best choice for the second pick.

![Alt text](/readme/pick_list_1.png?raw=true "Pick List")