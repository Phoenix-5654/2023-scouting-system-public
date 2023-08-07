import asyncio
import json

import pandas as pd
import numpy as np
import sklearn
from scipy.special import softmax
from sklearn.ensemble import RandomForestRegressor, GradientBoostingRegressor
import httpx
from tabulate import tabulate
from tqdm import tqdm


class Team_Data:
    def __init__(self, teleop_cone_total, teleop_cube_total, avg_pcs_low, avg_pcs_mid, avg_pcs_high, avg_pcs_match,
                 avg_pts_match, team_num):
        self.teleop_cone_total = teleop_cone_total
        self.teleop_cube_total = teleop_cube_total
        self.avg_pcs_low = avg_pcs_low
        self.avg_pcs_mid = avg_pcs_mid
        self.avg_pcs_high = avg_pcs_high
        self.avg_pcs_match = avg_pcs_match
        self.avg_pts_match = avg_pts_match
        self.team_num = team_num


class Match_Entry:
    def __init__(self, b1=None, b2=None, b3=None, r1=None, r2=None, r3=None, b_res=None, r_res=None):
        self.b1 = b1
        self.b2 = b2
        self.b3 = b3
        self.r1 = r1
        self.r2 = r2
        self.r3 = r3
        self.b_res = b_res
        self.r_res = r_res

    def result_included(self):
        return self.b_res is not None and self.r_res is not None

    def is_full_data(self):
        return self.b1 is not None and self.b2 is not None and self.b3 is not None and self.r1 is not None and self.r2 is not None and self.r3 is not None and self.result_included()

    def get_X_data(self):
        return [self.b1, self.b2, self.b3, self.r1, self.r2, self.r3]

    def get_y_data(self):
        return [self.b_res, self.r_res]


def read_excel(path=r"C:\Users\denis\Downloads\Scouting Report 2023.xlsx", print_toggle=False):
    # Read the sheet using 'pandas'
    df = pd.read_excel(path, sheet_name="DataProccessing_ISRAEL")

    teams = {}

    # Iterate through the rows, using tqdm to show a progress bar
    for index, row in tqdm(df.iterrows(), total=len(df.index), desc="Loading teams", ncols=100):
        # Save team number (always on the first column)
        try:
            team_number = int(row[0])

            teleop_cone_total = row[58]  # Saving the value in 'BG' column
            teleop_cube_total = row[59]  # Saving the value in 'BH' column
            avg_pcs_low = row[60]  # Saving the value in 'BI' column
            avg_pcs_mid = row[61]  # Saving the value in 'BJ' column
            avg_pcs_high = row[62]  # Saving the value in 'BK' column
            avg_pcs_match = row[63]  # Saving the value in 'BL' column
            avg_pts_match = row[64]  # Saving the value in 'BM' column

            # Create a new team data object
            team_data = Team_Data(teleop_cone_total, teleop_cube_total, avg_pcs_low, avg_pcs_mid, avg_pcs_high,
                                  avg_pcs_match, avg_pts_match, team_number)

            # Add the team data to the teams dictionary
            teams[team_number] = team_data
        except ValueError:
            pass

    return teams


async def create_matches(teams, path=r"C:\Users\denis\Downloads\Scouting Report 2023.xlsx"):
    df = pd.read_excel(path, sheet_name="RegResponsesBackup")

    matches = read_matches_from_json()

    # Iterate through the rows, using tqdm to show a progress bar
    for index, row in tqdm(df.iterrows(), total=len(df.index), desc="Creating matches", ncols=100):
        if index > 5:
            break
        try:
            team_number = int(row['Team Number'])

            match_name = row['Match Data'][:row['Match Data'].find(" -")]
            author = row['Match Data'][row['Match Data'].find(" -") + 3:]

            if "Match" in match_name:
                continue

            if match_name.find("Qualification") != -1:
                match_number = int(match_name[match_name.find("Qualification") + 14:match_name.find("|") - 1])
                if "iscmp" in match_name:
                    event_key = "iscmp"
                else:
                    event_key = "isde3"
            else:
                match_number = int(match_name)
                event_key = "isde1"

            score, station = await get_api_result(match_number, team_number, event_key=event_key)

            if score is None:
                continue

            if match_name not in matches:
                matches[match_name] = Match_Entry()

            if station == "Red1":
                matches[match_name].r1 = teams[team_number]
                matches[match_name].r_res = score

            elif station == "Red2":
                matches[match_name].r2 = teams[team_number]
                matches[match_name].r_res = score

            elif station == "Red3":
                matches[match_name].r3 = teams[team_number]
                matches[match_name].r_res = score

            elif station == "Blue1":
                matches[match_name].b1 = teams[team_number]
                matches[match_name].b_res = score

            elif station == "Blue2":
                matches[match_name].b2 = teams[team_number]
                matches[match_name].b_res = score

            elif station == "Blue3":
                matches[match_name].b3 = teams[team_number]
                matches[match_name].b_res = score

        except AttributeError as e:
            continue

        except ValueError as e:
            continue

    # Saving the matches to a json file
    with open("matches_1.json", "w") as f:
        json.dump(matches, f, default=lambda o: o.__dict__, indent=4)


def read_matches_from_json(path="matches.json"):
    with open(path, "r", encoding="utf16") as f:
        matches = json.load(f)

    return matches


async def get_api_result(match_number, team_number, event_key="iscmp",
                         key="cGhvZW5peDU2NTQ6MGExNGEzMjAtNjY0ZS00ZjVkLWE2ZGUtN2UwNDZjZWYwMDg1", ):
    """
    Gets the result of a match from the API
    :param match_number:
    :param key:
    :return:
    """
    # Get the match data from the API

    url = f"https://frc-api.firstinspires.org/v3.0/2023/matches/{event_key}?matchNumber={match_number}&tournamentLevel=qual"

    # Get the match data from the API async using httpx
    async with httpx.AsyncClient() as client:
        response = await client.get(url, headers={"Authorization": f'Basic {key}'}, timeout=None)
        response = response.json()

    match_data = response['Matches'][match_number - 1]
    alliance = ""
    score = 0

    # Find the team in the match
    for entry in match_data['teams']:
        if entry['teamNumber'] == team_number:
            alliance = entry['station'][0]
            break

    # If the team is in the red alliance, return the red alliance score
    if alliance == "R":
        score = match_data['scoreRedFinal'] - match_data['scoreRedFoul']

    # If the team is in the blue alliance, return the blue alliance score
    elif alliance == "B":
        score = match_data['scoreBlueFinal'] - match_data['scoreBlueFoul']

    return (score, entry['station'])


def create_model(matches, result_included=False, print_toggle=False):
    """
    Creates a Linear Regression model using the matches
    :param matches:
    :return:
    """

    # Create the X and Y arrays
    X = []
    Y = []

    # Iterate through the matches using tqdm to show a progress bar
    for match in tqdm(matches.values(), desc="Creating model", ncols=100):
        # If the match is not complete, skip it
        if match['b1'] is None or match['b2'] is None or match['b3'] is None or match['r1'] is None or match[
            'r2'] is None or match['r3'] is None:
            continue

        # If the result is not included, skip it
        if match['b_res'] is None or match['r_res'] is None:
            continue

        # Iterate through the teams in the match
        for team in [match['b1'], match['b2'], match['b3'], match['r1'], match['r2'], match['r3']]:
            # If the team is not complete, skip it
            if team is None:
                continue

            # Find match name by the key in the matches dictionary
            match_name = list(matches.keys())[list(matches.values()).index(match)]

            # Find team's alliance (if he is in 'r1' key, he is in the red alliance)
            if team == match['r1'] or team == match['r2'] or team == match['r3']:
                alliance = "r"
            else:
                alliance = "b"

            res = 0

            # Create the Y array
            if alliance == "r":
                res = match['r_res']
            else:
                res = match['b_res']

            Y.append(res)

            # Create the X array
            X.append([
                team['teleop_cone_total'],
                team['teleop_cube_total'],
                team['avg_pcs_low'],
                team['avg_pcs_mid'],
                team['avg_pcs_high'],
                team['avg_pcs_match'],
                team['avg_pts_match'],
                match_name,
                res,
            ])

    # Create the model using ElasticNet
    # model = RandomForestRegressor(n_estimators=100, random_state=0, max_depth=2)
    # RMCE
    model = GradientBoostingRegressor(n_estimators=100, learning_rate=0.1, max_depth=1, random_state=0,
                                      loss='squared_error')

    t = pd.DataFrame(X, columns=['teleop_cone_total', 'teleop_cube_total', 'avg_pcs_low', 'avg_pcs_mid', 'avg_pcs_high',
                                 'avg_pcs_match', 'avg_pts_match', 'match_name', 'result'])
    t = t.groupby(['match_name', 'result']).sum()
    t.to_csv("X.csv")

    X = t.values
    Y = t.index.get_level_values(1).values

    model.fit(X, Y)

    return model


def predict(model, teams_in_match, print_toggle=False):
    # Create the X array
    X = [
        [
            teams_in_match['b1'].teleop_cone_total,
            teams_in_match['b1'].teleop_cube_total,
            teams_in_match['b1'].avg_pcs_low,
            teams_in_match['b1'].avg_pcs_mid,
            teams_in_match['b1'].avg_pcs_high,
            teams_in_match['b1'].avg_pcs_match,
            teams_in_match['b1'].avg_pts_match,
        ],
        [
            teams_in_match['b2'].teleop_cone_total,
            teams_in_match['b2'].teleop_cube_total,
            teams_in_match['b2'].avg_pcs_low,
            teams_in_match['b2'].avg_pcs_mid,
            teams_in_match['b2'].avg_pcs_high,
            teams_in_match['b2'].avg_pcs_match,
            teams_in_match['b2'].avg_pts_match,
        ],
        [
            teams_in_match['b3'].teleop_cone_total,
            teams_in_match['b3'].teleop_cube_total,
            teams_in_match['b3'].avg_pcs_low,
            teams_in_match['b3'].avg_pcs_mid,
            teams_in_match['b3'].avg_pcs_high,
            teams_in_match['b3'].avg_pcs_match,
            teams_in_match['b3'].avg_pts_match,
        ],
        [
            teams_in_match['r1'].teleop_cone_total,
            teams_in_match['r1'].teleop_cube_total,
            teams_in_match['r1'].avg_pcs_low,
            teams_in_match['r1'].avg_pcs_mid,
            teams_in_match['r1'].avg_pcs_high,
            teams_in_match['r1'].avg_pcs_match,
            teams_in_match['r1'].avg_pts_match,
        ],
        [
            teams_in_match['r2'].teleop_cone_total,
            teams_in_match['r2'].teleop_cube_total,
            teams_in_match['r2'].avg_pcs_low,
            teams_in_match['r2'].avg_pcs_mid,
            teams_in_match['r2'].avg_pcs_high,
            teams_in_match['r2'].avg_pcs_match,
            teams_in_match['r2'].avg_pts_match,
        ],
        [
            teams_in_match['r3'].teleop_cone_total,
            teams_in_match['r3'].teleop_cube_total,
            teams_in_match['r3'].avg_pcs_low,
            teams_in_match['r3'].avg_pcs_mid,
            teams_in_match['r3'].avg_pcs_high,
            teams_in_match['r3'].avg_pcs_match,
            teams_in_match['r3'].avg_pts_match,
        ],
    ]

    # Predict the result
    return model.predict(X)


if __name__ == '__main__':
    model = create_model(read_matches_from_json(), result_included=True, print_toggle=True)
    teams = read_excel()
    matches = read_matches_from_json()

    for match in matches.values():
        r1 = match['r1']
        r2 = match['r2']
        r3 = match['r3']

        b1 = match['b1']
        b2 = match['b2']
        b3 = match['b3']

        teams_in_match = {
            'r1': r1,
            'r2': r2,
            'r3': r3,
            'b1': b1,
            'b2': b2,
            'b3': b3,
        }

        print(predict(model, teams_in_match, print_toggle=True))