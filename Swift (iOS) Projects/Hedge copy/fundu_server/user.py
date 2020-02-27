from portfolio import UserPortfolio
from math import fabs


class User:
    def __init__(self, u_id, t_data, u_name, teams):
        """

        :param u_id: user_id
        :param t_data: team_data from main -- {key=teamID: val=team_entry_from_firebase}
        :param u_name: username
        :param teams: list of teams the user is on
        """
        self.u_id = u_id
        self.username = u_name
        self.portfolio = None
        self.update_portfolio(t_data)
        self.teams = teams

    def update_portfolio(self, t_data):
        """

        :param t_data: same as above
        :return: no return value, just set portfolio value
        """
        self.portfolio = UserPortfolio(self.u_id, t_data)

    def check_triggers(self, t_id):
        """
        Returns all events that would trigger a notification
        Currently these triggers include:
            * increase/decrease of portfolio greater than amount specified in thresholds
        Thresholds: day: 15%, week: 30%, month: 30%

        TODO:
            - watchlist percentage changes (user)
            - portfolio percent changes (user)
            - indiv stock changes (user)
            - new public leagues are created (???)
            - team rank in league changes by a bunch (team)
            - a team jumps into first place (team)


        :param t_id: teamID
        :return: [(length_of_time, percent change) if there is a trigger]
        """

        thresholds = {'day': .15, 'week': .3, 'month': .3}
        if t_id not in self.teams:
            print 'Error User.check_triggers - passed in a t_id that is not registered to user'
            return

        team_historical_values = self.portfolio.historical_values[t_id]
        team_total_value = self.portfolio.total_value

        changes = {}
        for key, val in team_historical_values.iteritems():
            changes[key] = (team_total_value-val)/val

        print 'Changes:', changes

        return [(key, val) for key, val in changes.iteritems() if fabs(val) > thresholds[key]]

    def get_all_tickers(self):
        return self.portfolio.get_all_tickers()

    def print_portfolio(self):
        self.portfolio.print_portfolio()

    def print_user(self):
        print self.username
        print '\t', 'u_id:', self.u_id
        print '\t', 'teams:', self.teams
        self.print_portfolio()
        print ''

    def curr_balance(self):
        return self.portfolio.curr_balance




