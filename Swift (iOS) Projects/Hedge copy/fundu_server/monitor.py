import pyrebase
import json
import sys
import os
from datetime import datetime
from portfolio import Portfolio
from user import User
from pprint import pprint


def fprint(data):
    print(json.dumps(data, indent=4))


config = {
    "apiKey": "AIzaSyAcdq4cvW7PNOM0tC_p4WZKZJlrnUYcJrE",
    "authDomain": "csci-420-fundu.firebaseapp.com",
    "databaseURL": "https://csci-420-fundu.firebaseio.com/",
    "storageBucket": "csci-420-fundu.appspot.com"
}
firebase = pyrebase.initialize_app(config)
auth = firebase.auth()
db = firebase.database()


def get_users():
    fb_users = db.child('users').get()
    user_data = json.loads(json.dumps(fb_users.val()))

    user_IDs = [u_id for u_id in user_data]
    usernames = [user_data[u_id]['username'] for u_id in user_IDs]

    teams = db.child('teams').get()
    teams = json.loads(json.dumps(teams.val()))

    return [User(u_id, teams, u_name) for u_id, u_name in zip(user_IDs, usernames)]


def get_indiv_teams():
    test = db.child('teams').get()
    data = json.loads(json.dumps(test.val()))
    teamIDs = [t for t in data]
    for t_id in teamIDs:
        pass
    print(len(teamIDs))


def test_func():
    test = db.child('teams').get()
    # print(type(test.val()))
    data = json.loads(json.dumps(test.val()))
    # print(test.key())
    teams = [t for t in data]
    fprint(teams)
    # fprint(test.child(teams[0]).val())
    # fprint(data)
    print(type(data))


def main():
    # get_indiv_teams()
    # try:
    users = get_users()
    for u in users:
        if u.curr_balance() > 0: u.print_portfolio()
    # except Exception as e:
    #     with open('logs.out', 'a') as log_file:
    #         exc_type, exc_obj, exc_tb = sys.exc_info()
    #         fname = os.path.split(exc_tb.tb_frame.f_code.co_filename)[1]
    #         print >> log_file, str(datetime.now()), e.__class__.__name__, e.message, fname, exc_tb.tb_lineno


if __name__ == '__main__':
    main()
