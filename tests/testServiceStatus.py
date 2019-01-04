import os
import sys
sys.path.append(os.path.dirname(os.path.abspath(__file__))+'/../sources/server/')
import unittest

from modules.ServiceStatus import ServiceStatus


class TestServiceStatus(unittest.TestCase):
    """ServiceStatus Unit Tests"""

    def test_init(self):
        """Instatiation"""
        service_status = ServiceStatus()

    def test_get(self):
        """Data getter"""
        service_status = ServiceStatus()
        self.assertEqual({}, service_status.get())

    def test_poll_metrics(self):
        """Poll Metrics"""
        service_status = ServiceStatus()
        self.assertEqual({}, service_status.poll_metrics({}))

    def test_collect_metrics(self):
        """Collect Metrics"""
        service_status = ServiceStatus()
        service_status.collect_metrics({})
        self.assertEqual({}, service_status.get())


if __name__ == '__main__':
    unittest.main()
