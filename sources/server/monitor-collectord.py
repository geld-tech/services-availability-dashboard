#!/usr/bin/env python
import atexit
from daemon import runner
import datetime
import os
import sys
import time
from modules.ServiceStatus import ServiceStatus
from modules.Models import Base, Server, Service, Metrics
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker


class MetricsCollector():
    def __init__(self, pid_file, db_path, config_file, poll_interval=60):
        self.stdin_path = '/dev/null'
        self.stdout_path = '/dev/tty'
        self.stderr_path = '/dev/tty'
        self.pidfile_timeout = 5
        self.pidfile_path = pid_file
        self.poll_interval = poll_interval
        self.db_path = db_path
        self.config_file = config_file
        self.db_session = None
        self.server = None
        self.services = []
        atexit.register(self.db_close)

    def run(self):
        print "Running..."
        if os.path.isfile(self.config_file):
            print "creating DB..."
            # Initialise object to collect metrics
            services_status = ServiceStatus()
            # Connect to database
            self.db_open(services_status.get_server_hostname())
            # First metrics poll to instantiate system information
            while True:
                print "Polling ..."
                # Poll and store
                dt = datetime.datetime.utcnow()
                data = services_status.poll_metrics()
                self.store_status(dt, data)
                time.sleep(self.poll_interval)
        else:
            print "Sleeping as no %s" % self.config_file
            time.sleep(3*self.poll_interval)

    def db_open(self, hostname='localhost'):
        engine = create_engine('sqlite:///'+self.db_path)
        Base.metadata.bind = engine
        Base.metadata.create_all(engine)
        DBSession = sessionmaker(bind=engine)
        self.db_session = DBSession()

        self.server = Server(hostname=hostname)
        self.db_session.add(self.server)
        self.db_session.commit()

    def db_close(self):
        if self.db_session:
            self.db_session.close()

    def db_rollback(self):
        self.db_session.rollback()

    def get_services(self):
        try:
            now = datetime.datetime.utcnow()
            last_2_hours = now - datetime.timedelta(hours=2)
            self.services = self.db_session.query(Service).filter_by(server=self.server).filter(Service.timestamp >= last_2_hours.strftime('%s')).order_by(Service.id)
        except Exception:
            print "Error accessing services status"

    def store_status(self, date_time, data):
        try:
            service_status = Metrics(timestamp=date_time.strftime('%s'),
                                     service=self.service[0])
            self.db_session.add(service_status)
            self.db_session.commit()
        except Exception:
            print "Error accessing services status"
        finally:
            self.db_close()


def is_running(pid_file):
    try:
        with file(pid_file, 'r') as pf:
            pid = int(pf.read().strip())
    except IOError:
        pid = None
    except SystemExit:
        pid = None

    if pid:
        return True, pid
    else:
        return False, -1


# Main
DB_PATH = os.path.abspath(os.path.dirname(__file__))+'/data/metrics.sqlite3'
PID_FILE = '/tmp/sla-monitor-collectord.pid'
CONFIG_FILE = 'config/settings.cfg'
POLL_INTERVAL = 30

if __name__ == "__main__":
    if len(sys.argv) == 2:
        if 'status' == sys.argv[1]:
            running, pid = is_running(PID_FILE)
            if running:
                print '%s is running as pid %s' % (sys.argv[0], pid)
            else:
                print '%s is not running.' % sys.argv[0]
        elif 'stop' == sys.argv[1] and not is_running(PID_FILE)[0]:
            print '%s is not running.' % sys.argv[0]
        else:
            collector = MetricsCollector(PID_FILE, DB_PATH, CONFIG_FILE, poll_interval=POLL_INTERVAL)
            daemon = runner.DaemonRunner(collector)
            daemon.do_action()  # start|stop|restart as sys.argv[1]
            running, pid = is_running(PID_FILE)
            sys.exit(0)
    else:
        print "Usage: %s start|stop|restart|status" % sys.argv[0]
        sys.exit(2)
else:
    print "%s can't be included in another program." % sys.argv[0]
    sys.exit(1)
