import utils
import os.path

from datetime import datetime

# db, auth = get_db_ref()


def check_for_triggers(user):
    """
    finds any triggers on the user and then prints them out to an output file

    :param user: user object
    :return: None
    """
    print user.username

    fname = 'notifications_filter.txt'
    if not os.path.isfile(fname):
        open(fname, 'w').close()

    log_file = open('logs.txt', 'a')
    user_file = open(fname, 'r+a')
    users_who_have_already_been_notified_today = [userID.rstrip() for userID in user_file]
    if user.u_id in users_who_have_already_been_notified_today:
        user_file.close()
        log_file.close()
        return

    for t_id, t_name in user.teams.iteritems():

        triggers = user.check_triggers(t_id)  # type list of tuples: [(length_of_time, percent change)]

        if triggers:
            print "USERS_WHO_HAVE_ALREADY", users_who_have_already_been_notified_today
            print >> log_file, datetime.now(), triggers
            print >> user_file, user.u_id
            notif_type = 'stock_performance'
            notif_text = "your stock is doing some stuff, here's your change percentages:"+str(triggers)
            print "************************"
            print user.u_id, notif_type, notif_text
            print "************************"
            utils.send_notification(user.u_id, notif_type, notif_text)

        utils.send_notification(user.u_id, "test_notification", "This is a test Notification")

    user_file.close()
    log_file.close()


def main():
    users = utils.get_users()

    for user in users:
        check_for_triggers(user)


if __name__ == '__main__':
    main()
