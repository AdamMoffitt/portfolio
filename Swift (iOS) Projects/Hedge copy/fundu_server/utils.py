import pyrebase
import requests
import json

from user import User
from league import League
from team import Team
from datetime import datetime, timedelta


def get_batch_quotes(batch):
    r = requests.get('https://api.iextrading.com/1.0/stock/market/batch?symbols='+','.join(batch)+'&types=quote')
    data = r.json()
    stock_values = {}
    for ticker in batch:
        stock_values[ticker] = {}
        temp_price = data[ticker.upper()]['quote']['iexRealtimePrice']
        if temp_price == 0 or not temp_price:
            temp_price = data[ticker.upper()]['quote']['latestPrice']

        stock_values[ticker] = temp_price

    return stock_values


def jsonify(db_instance):
    return json.loads(json.dumps(db_instance.val()))


def get_db_ref():
    config = {
        "apiKey": "AIzaSyANiFgFpcnXlUZEyrmTv6Zi51ecoNDowx8",
        "authDomain": "hedge-beta.firebaseapp.com",
        "databaseURL": "https://hedge-beta.firebaseio.com/",
        "storageBucket": "hedge-beta.appspot.com"
    }
    firebase = pyrebase.initialize_app(config)
    auth = firebase.auth()
    db = firebase.database()
    return db, auth


def get_teams_data(t_ids):
    """
    Returns a dictionary containing the team child nodes from firebase that the user is a part of
    :param t_ids:
    :return: dict{key=t_id: val=teams_entry_in_firebase}
    """
    db, auth = get_db_ref()
    team_data = {}
    for t_id in t_ids:
        team_data[t_id] = jsonify(db.child('teams/'+t_id).get())
    return team_data


def get_users():
    """
    Pretty self explanatory
    :return: array of all user objects
    """
    db, auth = get_db_ref()
    user_data = jsonify(db.child('users').get())

    user_IDs = [u_id for u_id in user_data]
    usernames = [user_data[u_id]['username'] for u_id in user_IDs]

    team_data = {}
    for u_id in user_data:
        curr_team_data = get_teams_data(user_data[u_id]['teamIDs'])
        team_data[u_id] = curr_team_data
        # print curr_team_data

    # stock_vals = get_batch_quotes(inital_stocks)
    return [User(u_id, team_data[u_id], u_name, user_data[u_id]['teamIDs']) for u_id, u_name in zip(user_IDs, usernames)]


def get_leagues():
    """
    :return: dictionary -- {leagueID: League}
    """

    db, auth = get_db_ref()
    league_data = jsonify(db.child('leagues').get())
    league_IDs = [l_id for l_id in league_data]

    leagues = {}
    for l_id in league_IDs:
        leagues[l_id] = League(league_data[l_id])

    return leagues


def get_teams():
    db, auth = get_db_ref()
    team_data = jsonify(db.child('teams').get())
    team_IDs = [t_id for t_id in team_data]

    teams = {}
    for t_id in team_IDs:
        teams[t_id] = Team(team_data[t_id])

    return teams


def get_dates():
    date = datetime.now()
    if date.month == 1:
        month = str(12) + '_' + str(date.day) + '_' + str(date.year-1)
        if date.day <= 7:
            week = str(12) + '_' + str(date.day+24) + '_' +str(date.year-1)
        else:
            week = str(12) + '_' + str(date.day-7) + '_' + str(date.year - 1)
        if date.day == 1:
            day = str(12) + '_' + str(31) + '_' + str(date.year-1)
        else:
            day = str(12) + '_' + str(date.day-1) + '_' + str(date.year - 1)

    else:
        month = str(date.month - 1) + '_' + str(date.day) + '_' + str(date.year)
        if date.day <= 7:
            week = str(date.month - 1) + '_' + str(date.day + 24) + '_' + str(date.year)
        else:
            week = str(date.month) + '_' + str(date.day - 7) + '_' + str(date.year)
        if date.day == 1:
            day = str(date.month) + '_' + str(30) + '_' + str(date.year)
        else:
            day = str(date.month) + '_' + str(date.day - 1) + '_' + str(date.year)

    for date in [day, week, month]:

        s = day.split('_')
        if len(s[1]) == 1:
            s[1] = '0'+s[1]
        day = '_'.join(s)

        s = week.split('_')
        if len(s[1]) == 1:
            s[1] = '0' + s[1]
        week = '_'.join(s)

        s = month.split('_')
        if len(s[1]) == 1:
            s[1] = '0' + s[1]
        month = '_'.join(s)

    print day, week, month
    return day, week, month


def get_curr_date():
    now = datetime.now()

    if len(str(now.day)) == 1:
        date = str(now.month) + '_' + '0' + str(now.day) + '_' + str(now.year)
    else:
        date = str(now.month) + '_' + str(now.day) + '_' + str(now.year)

    return date


def send_notification(u_id, notif_type, text):
    """
    :param u_id:
    :param notif_type:
    :param text:
    :return:
    """
    db, auth = get_db_ref()
    notification = {'type': notif_type, 'text': text, 'time': str(datetime.now())}
    db.child('users/' + u_id + '/notifications').push(notification)


def write_snapshot_to_db(t_id, snapshot):
    """
    :param t_id: teamID
    :param snapshot: snapshot from 'push_daily_snapshot' => dict
    :return:
    """

    db, auth = get_db_ref()
    db.child('teams/'+t_id+'/portfolio/snapshots').child(get_curr_date()).set(snapshot)
    # db.child('test').push({get_curr_date(): snapshot})


def get_user_portfolio_values(stocks, batch_quotes):
    """
    :param stocks: the stocks node from a team in firebase db
    :param batch_quotes: current prices for each stock that is passed in
    :return: {u_id: portfolio_val => double}
    """
    values = {}
    for ticker, transactions in stocks.iteritems():
        for transaction, v in transactions.iteritems():
            if 'purchased_by' in v:
                u_id = v['purchased_by']
            else:
                u_id = v['sold_by']
            if u_id in values:
                values[u_id] += float(format(v['quantity'] * batch_quotes[ticker], '.2f'))
            else:
                values[u_id] = float(format(v['quantity'] * batch_quotes[ticker], '.2f'))
    return values


def get_percentages(team, user_values):
    """
    :param team: Team Class Object
    :param user_values: current total value for each user
    :return: percentages: {
                userID: {
                    daily: double, weekly: double, monthly: double, yearly: double, overall: double} TODO
                }
                overall: {
                    daily: double, weekly: double, monthly: double, yearly: double, overall: double} TODO
                }
            }
    """
    def get_nearest_snapshot(snapshot_dict, transaction_period):
        """
        :param snapshot_dict: an array of all of the snapshots that have been posted for the team
        :param transaction_period: the length of time -- daily/weekly/monthly/yearly/overall
        :return: the most accurate snapshot to the period requested
        """
        if not snapshot_dict:
            return None
        now = datetime.now() - timedelta(days=0)
        dd = now.day
        mm = now.month
        yyyy = now.year

        if transaction_period == 'daily':
            if now.day == 1:
                if now.month == 1:
                    yyyy -= 1
                    mm = 13
                if now.month == 3:
                    dd = 28
                elif mm == 4 or mm == 6 or mm == 9 or mm == 11:
                    dd = 30
                else:
                    dd = 31
                mm -= 1
            else:
                dd -= 1

        elif transaction_period == 'weekly':
            if dd <= 7:
                if mm == 1:
                    yyyy -= 1
                    mm = 13
                mm -= 1
                if mm == 2:
                    dd += 21
                elif mm == 4 or mm == 6 or mm == 9 or mm == 11:
                    dd += 23
                else:
                    dd += 24
            else:
                dd -= 7

        elif transaction_period == 'monthly':
            if mm == 1:
                mm = 12
                yyyy -= 1
            else:
                mm -= 1

        elif transaction_period == 'yearly':
            yyyy -= 1

        elif transaction_period == 'overall':
            return snapshot_dict[sorted(snapshot_dict)[0]]

        if len(str(dd)) == 1:
            date = str(mm) + '_' + '0' + str(dd) + '_' + str(yyyy)
        else:
            date = str(mm) + '_' + str(dd) + '_' + str(yyyy)

        if date in snapshot_dict:
            return snapshot_dict[date]
        else:
            return snapshot_dict[sorted(snapshot_dict)[0]]

    percentages = dict()

    transactions_by_user = dict()
    for ticker, transactions in team.stocks.iteritems():
        for t in transactions.values():
            if 'purchased_by' in t:
                u_id = t['purchased_by']
            else:
                u_id = t['sold_by']
            if u_id in transactions_by_user:
                transactions_by_user[u_id].append(t)
            else:
                transactions_by_user[u_id] = [t]
    percentages['overall'] = {}
    for tp in ['daily', 'weekly', 'monthly', 'yearly', 'overall']:
        s = get_nearest_snapshot(team.snapshots, tp)
        percentages['overall'][tp] = [0, 0]

        for u_id, transaction_array in transactions_by_user.iteritems():
            if u_id not in percentages:
                percentages[u_id] = {}
            if not s:
                percentages[u_id][tp] = {
                    'daily': 0,
                    'weekly': 0,
                    'monthly': 0,
                    'yearly': 0,
                    'overall': 0
                }
            else:
                print s['member_balances'][team.t_id], s['portfolio_values'][team.t_id]
                tp_val = s['member_balances'][team.t_id] + s['portfolio_values'][team.t_id]
                curr_val = user_values[u_id]
                percentages[u_id][tp] = float(format((curr_val-tp_val)/tp_val, '.2f'))
                percentages['overall'][tp][0] += float(tp_val)
                percentages['overall'][tp][1] += float(curr_val)
                # float(format(v['quantity'] * batch_quotes[ticker], '.2f'))
    for tp_val in percentages['overall']:
        try:
            percentages['overall'][tp_val] = float(format((percentages['overall'][tp_val][1]-percentages['overall'][tp_val][0])/percentages['overall'][tp_val][0], '.2f'))
        except ZeroDivisionError as e:
            print ''
            # team.print_team()
            print e
            print 'percentages[\'overall\'][tp_val][1]:', percentages['overall'][tp_val][1]
            print 'percentages[\'overall\'][tp_val][0]:', percentages['overall'][tp_val][0]
            print ''
            percentages['overall'][tp_val] = 0
    print percentages
    return percentages