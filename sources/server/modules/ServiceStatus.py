#!/usr/bin/env python
"""
    ServiceStatus Class

    Polls service metrics on availability and latency

"""
import logging
import logging.handlers
import socket
import time
import urllib
import urllib2


class ServiceStatus:
    def __init__(self, url="https://www.geld.tech/"):
        logging.basicConfig(format='[%(asctime)-15s] [%(threadName)s] %(levelname)s %(message)s', level=logging.INFO)
        self.logger = logging.getLogger('root')
        self.hostname = self._get_server_hostname()
        self._data = {}
        self.url = url
        self.collect_metrics()

    def get(self):
        return self._data

    def poll_metrics(self):
        self.collect_metrics()
        return self._data

    def collect_metrics(self):
        self._data = self._get_metrics()

    def is_reachable(self, timeout=5):
        try:
            req = urllib2.Request(self.url)
            response = urllib2.urlopen(req, timeout=timeout)
            response.close()
            return True
        except Exception, e:
            self.logger.debug('Error reaching service (%s): %s' % (self.url, e))
            return False

    def measure_latency(self):
        try:
            req = urllib.urlopen(self.url)
            start = time.time()
            page = req.read()
            end = time.time()
            req.close()
            return float(end - start)  # time interval in seconds
        except Exception, e:
            self.logger.debug('Error retrieving latency status (%s): %s' % (self.url, e))
            return False

    def _get_metrics(self):
        try:
            req = urllib2.Request(self.url)
            response = urllib2.urlopen(req)
            response.close()
            data = {}
            return data
        except Exception, e:
            self.logger.error('Error retrieving service status (%s): %s' % (self.url, e))
            return {}

    def _get_server_hostname(self):
        try:
            hostname = socket.gethostname()
            return hostname
        except Exception, e:
            self.logger.error('Error reading hostname: %s' % e)
            return False

    def get_server_hostname(self):
        return self.hostname
