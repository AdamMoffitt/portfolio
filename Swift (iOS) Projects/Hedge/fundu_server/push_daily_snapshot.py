import utils
import sys

from pprint import pprint


def create_snapshot(team_object):
    """

    :param team_object: Team Class Object
    :return: snapshot
    {
        member_balances: {current member balances node},
        stocks: {
            ticker: {
                quantity_team_owns: int,
                curr_price: double
            }
        },
        portfolio_values: {u_id: double},
        percentages: {
            # percentages for each user and the overall team
            userID: {
                daily: double, weekly: double, monthly: double, yearly: double, overall: double} TODO
            }
            overall: {
                daily: double, weekly: double, monthly: double, yearly: double, overall: double} TODO
            }
        }
        curr_league_ranks: {l_id, int} TODO
    }
    """
    snapshot = {}
    print "snapshot:"
    # team_object.print_team()
    # print '\n'

    if not team_object.stocks:
        return
    tickers = team_object.stocks.keys()
    batch_quotes = utils.get_batch_quotes(tickers)

    stocks = {}
    for ticker, price in batch_quotes.iteritems():
        stocks[ticker] = {'curr_price': price}
        stocks[ticker]['quantity_team_owns'] = sum([transaction['quantity'] for transaction in team_object.stocks[ticker].values()])
        if stocks[ticker]['quantity_team_owns'] == 0:
            del stocks[ticker]
    # print "hallo", utils.get_user_portfolio_values(team_object.stocks, batch_quotes)

    user_values = {}
    portfolio_values = utils.get_user_portfolio_values(team_object.stocks, batch_quotes)
    for u_id, balance in team_object.member_balances.iteritems():
        user_values[u_id] = balance
    for u_id, val in portfolio_values.iteritems():
        user_values[u_id] += val

    snapshot['member_balances'] = team_object.member_balances
    snapshot['stocks'] = stocks
    snapshot['portfolio_values'] = portfolio_values
    snapshot['percentages'] = utils.get_percentages(team_object, user_values)
    return snapshot


def main():
    teams_dict = utils.get_teams()

    for t_id, team_object in teams_dict.iteritems():
        # print t_id, team_object
        snap = create_snapshot(team_object)
        # print 'in loop currently'
        # print 'snap:', snap
        utils.write_snapshot_to_db(t_id, snap)


if __name__ == '__main__':
    main()

    