import json

from datetime import datetime
import utils
from pprint import pprint


class BasePortfolio:
    def __init__(self):
        """
        Base constructor:
            * total_value of portfolio
            * historical values
            * the overall portfolio: passively accumulates
        """
        self.total_value = 0
        self.historical_values = {} # {key[teamID|userID]: {'day': -1, 'month': -1, 'week': -1} }
        # self.data_by_stock = {}
        self.overall_portfolio = {} # {ticker: {quantity: int, total_value: double} }

    def get_data_for_stock(self, ticker):
        return self.overall_portfolio[ticker]

    def get_all_tickers(self):
        return [ticker for ticker in self.overall_portfolio.keys()]

    def print_portfolio(self):
        pass

    def _build_portfolio(self, teams):
        pass

    def _make_team_portfolio(self, hist_val_key, portfolio):
        """
        Returns a value for the team portfolio and also updates the overall portfolio in the process
        Also builds out historical values

        :param hist_val_key: teamID if this is a UserPortfolio or userID if it is team_portfolio
        :param portfolio: the portfolio child node from firebase of a specific team
        :return: team_portfolio_dict: {key=ticker: val=quantity, total_value}
        """

        team_portfolio = {}
        team_stocks = portfolio['stocks']
        tickers = [ticker for ticker in team_stocks]
        stock_vals = utils.get_batch_quotes(tickers)

        day, week, month = utils.get_dates()
        self.historical_values[hist_val_key] = {}
        print portfolio
        if day in portfolio:
            self.historical_values[hist_val_key]['day'] = portfolio[day]
        if week in portfolio:
            self.historical_values[hist_val_key]['week'] = portfolio[week]
        if month in portfolio:
            self.historical_values[hist_val_key]['month'] = portfolio[month]

        for ticker in tickers:
            quantity = sum([transaction_val['quantity'] for transaction_val in team_stocks[ticker].values()])
            total_value = quantity*stock_vals[ticker]
            team_portfolio[ticker] = {'quantity': quantity, 'total_value': total_value}
            self.total_value += total_value

            if ticker in self.overall_portfolio:
                self.overall_portfolio[ticker]['quantity'] += quantity
                self.overall_portfolio[ticker]['total_value'] += total_value
            else:
                self.overall_portfolio[ticker] = {'quantity': quantity, 'total_value': total_value}

        return team_portfolio


class UserPortfolio(BasePortfolio):
    def __init__(self, u_id, t_data):
        """
        Initilizes values and then builds and sets them in _build_portfolio

        :param u_id: userID
        :param t_data: team_data from main -- {key=teamID: val=team_entry_from_firebase}
        """
        BasePortfolio.__init__(self)
        self.team_portfolios = {}
        self.u_id = u_id
        self.curr_balance_per_team = {}
        self._build_portfolio(t_data)

    class Snapshot:
        def __init__(self):
            pass

    def get_portfolio_for_team(self, t_id):
        """
        :param t_id: teamID
        :return: User's team_portfolio associated with the teamID
        """
        # print self.team_portfolios
        return self.team_portfolios[t_id]

    def print_portfolio(self):
        for key, val in self.team_portfolios.iteritems():
            print '\t', key+':'
            pprint(val)
        # for key, val in

    def _build_portfolio(self, t_data):
        """
        For each team, calls the base protected function '_make_team_portfolio'
        This also aggregates the overall portfolio passively during the method

        :param t_data: t_data: team_data from main -- {key=teamID: val=team_entry_from_firebase}
        :return: None
        """
        for t_id in t_data:
            self.curr_balance_per_team[t_id] = t_data[t_id]['member_balances'][self.u_id]
            self.team_portfolios[t_id] = {}
            if 'portfolio' in t_data[t_id] and 'stocks' in t_data[t_id]['portfolio']:
                self.team_portfolios[t_id] = self._make_team_portfolio(t_id, t_data[t_id]['portfolio'])
            else:
                self.team_portfolios[t_id] = {}
                self.historical_values[t_id] = {}

# class TeamPortfolio(BasePortfolio):
#     def __init__(self, t_id, t_data):
#         BasePortfolio.__init__(self)
#         self.user_portfolios = {}
#         self.t_id = t_id
#         self.user_curr_balances = {}
#
#     def build_portfolio(self, t_data):
#         pass























    # def __build_portfolio(self, teams):
    #     for t_id in teams:
    #
    #         if 'member_balances' in teams[t_id] and self.u_id in teams[t_id]['member_balances'].keys():
    #             self.curr_balance = teams[t_id]['member_balances'][self.u_id]
    #             stocks_section = teams[t_id]['portfolio']['stocks']
    #             self.stock_values_by_team[t_id] = {}
    #             self.teams.append(t_id)
    #
    #             for ticker in stocks_section:
    #                 for transaction_key in stocks_section[ticker]:
    #                     t = stocks_section[ticker][transaction_key]
    #
    #                     if 'purchased_by' in t:
    #                         t_user = t['purchased_by']
    #                     else:
    #                         t_user = t['sold_by']
    #
    #                     if t_user == self.u_id:
    #                         t_val = t['quantity']*float(t['value'])
    #                         self.transactions.append(t)
    #                         self.total_value += t_val
    #
    #                         if ticker in self.overall_stock_values:
    #                             self.overall_stock_values[ticker] += t_val
    #                             self.stock_values_by_team[t_id][ticker] += t_val
    #                         else:
    #                             self.overall_stock_values[ticker] = t_val
    #                             self.stock_values_by_team[t_id][ticker] = t_val
    #
    #                         # print 'Curr value =', self.total_value
    #                         # print 'stock value =', self.stock_values

                # print [teams[t_id]['portfolio']['stocks'][key] for key in teams[t_id]['portfolio']['stocks']]

        # print(u_id)

    # def print_portfolio(self):
    #     print '\tU_ID:', self.u_id
    #     print '\tcurr_balance:', self.curr_balance
    #     print '\ttotal_value:', self.total_value
    #     print '\tstock_vales:', self.overall_stock_values
    #     print '\tstocks by team:', self.stock_values_by_team



