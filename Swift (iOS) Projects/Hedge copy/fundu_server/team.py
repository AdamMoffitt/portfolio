
class Team:
    def __init__(self, indiv_team_data):
        # print indiv_team_data
        self.t_id = indiv_team_data['teamID']
        self.member_balances = indiv_team_data['member_balances']
        self.members = indiv_team_data['members']
        self.stocks = None
        self.snapshots = None
        if 'portfolio' in indiv_team_data:
            self.stocks = indiv_team_data['portfolio']['stocks']
            if 'snapshots' in indiv_team_data['portfolio']:
                self.snapshots = indiv_team_data['portfolio']['snapshots']

        # self.leagues = {} # {leagueID: {curr_rank: int, max_rank: int, min_rank: int, sentNotification: bool}

    def set_league_ranks(self, ranks):
        pass

    def print_team(self):
        print "Team ID:", self.t_id
        print 'Member Balances:', self.member_balances
        print 'Members', self.members
        print 'Stocks:', self.stocks

