import os
import sys
sys.path.append(os.path.dirname(os.path.abspath(__file__))+'/../sources/server/')
import unittest

from modules.ServiceStatus import ServiceStatus


class TestServiceStatus(unittest.TestCase):
    """ServiceStatus Unit Tests"""

    def test_true(self):
        """Stub test"""
        self.assertTrue(True)


if __name__ == '__main__':
    unittest.main()
