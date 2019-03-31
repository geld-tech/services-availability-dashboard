# -*- coding: utf-8 -*-
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support.ui import Select
from selenium.common.exceptions import NoSuchElementException
from selenium.common.exceptions import NoAlertPresentException
import unittest, time, re

class Config(unittest.TestCase):
    proto = "http"
    host = "0.0.0.0"
    port = 5000
    delay = 30
    def setUp(self):
        self.driver = webdriver.Firefox()
        self.driver.implicitly_wait(30)
        self.base_url = "https://geld.tech/"
        self.verificationErrors = []
        self.accept_next_alert = True
    
    def test_config(self):
        driver = self.driver
        url = "%s://%s:%d" % (self.proto, self.host, self.port)
        driver.get(url)
        driver.refresh()
        url = "%s://%s:%d/#/Config" % (self.proto, self.host, self.port)
        driver.get(url)
        driver.find_element_by_id("adminPassword").click()
        driver.find_element_by_id("adminPassword").clear()
        driver.find_element_by_id("adminPassword").send_keys("password123")
        driver.find_element_by_id("adminSubmitButton").click()
        driver.find_element_by_id("services-tab___BV_tab_button__").click()
        driver.find_element_by_id("analytics-tab___BV_tab_button__").click()
        driver.find_element_by_id("admin-password-tab___BV_tab_button__").click()
        driver.find_element_by_id("adminLogoutButton").click()
        driver.find_element_by_xpath("//html").click()
        try:
                self.assertEqual("Login",
                        driver.find_element_by_xpath("(.//*[normalize-space(text()) and normalize-space(.)='localdev'])[2]/following::h2[1]").text)
        except AssertionError as e:
                self.verificationErrors.append(str(e))
        time.sleep(self.delay)
    
    def is_element_present(self, how, what):
        try: self.driver.find_element(by=how, value=what)
        except NoSuchElementException as e: return False
        return True
    
    def is_alert_present(self):
        try: self.driver.switch_to_alert()
        except NoAlertPresentException as e: return False
        return True
    
    def close_alert_and_get_its_text(self):
        try:
            alert = self.driver.switch_to_alert()
            alert_text = alert.text
            if self.accept_next_alert:
                alert.accept()
            else:
                alert.dismiss()
            return alert_text
        finally: self.accept_next_alert = True
    
    def tearDown(self):
        self.driver.quit()
        self.assertEqual([], self.verificationErrors)

if __name__ == "__main__":
    from optparse import OptionParser

    # Parse the input options
    parser = OptionParser()
    parser.add_option("--proto", dest="proto", default="http", help="Protocol")
    parser.add_option("--host", dest="host", default="0.0.0.0", help="Host")
    parser.add_option("--port", dest="port", default=5000, type=int, help="Port")
    parser.add_option("--delay", dest="delay", default=30, type="int", help="Default delay after steps to keep browser open")
    (options, args) = parser.parse_args()

    # Set parameters
    FirstSetup.proto = options.proto
    FirstSetup.host = options.host
    FirstSetup.port = options.port
    FirstSetup.delay = options.delay

    # Remove parameters from argv to not pass them to unittest
    sys.argv = [sys.argv[0]]

    # Execute test
    unittest.main()

