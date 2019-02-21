# -*- coding: utf-8 -*-
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support.ui import Select
from selenium.common.exceptions import NoSuchElementException
from selenium.common.exceptions import NoAlertPresentException
import unittest, time, re

class FirstSetup(unittest.TestCase):
    def setUp(self):
        self.driver = webdriver.Chrome()
        self.driver.implicitly_wait(30)
        self.base_url = "https://geld.tech/"
        self.verificationErrors = []
        self.accept_next_alert = True
    
    def test_first_setup(self):
        driver = self.driver
        driver.get("http://0.0.0.0:5000/#/Setup")
        driver.find_element_by_id("nextButton").click()
        driver.find_element_by_id("adminPassword").click()
        driver.find_element_by_id("adminPassword").clear()
        driver.find_element_by_id("adminPassword").send_keys("password123")
        driver.find_element_by_id("adminPasswordRepeat").clear()
        driver.find_element_by_id("adminPasswordRepeat").send_keys("password123")
        driver.find_element_by_id("adminSubmitButton").click()
        driver.find_element_by_id("nextButton").click()
        driver.find_element_by_id("uaIdInput").click()
        driver.find_element_by_id("uaIdInput").clear()
        driver.find_element_by_id("uaIdInput").send_keys("UA-123456-ID")
        driver.find_element_by_id("uaidAdminButton").click()
        driver.find_element_by_id("nextButton").click()
        driver.find_element_by_id("serviceName").click()
        driver.find_element_by_id("serviceName").clear()
        driver.find_element_by_id("serviceName").send_keys("newrelic")
        driver.find_element_by_id("serviceUrl").click()
        driver.find_element_by_id("serviceUrl").clear()
        driver.find_element_by_id("serviceUrl").send_keys("https://www.newrelic.com")
        driver.find_element_by_id("servicePort").click()
        driver.find_element_by_id("servicePort").clear()
        driver.find_element_by_id("servicePort").send_keys("443")
        driver.find_element_by_id("addRowButton").click()
        driver.find_element_by_id("serviceName").click()
        driver.find_element_by_id("serviceName").clear()
        driver.find_element_by_id("serviceName").send_keys("wikipedia")
        driver.find_element_by_id("serviceUrl").click()
        driver.find_element_by_id("serviceUrl").clear()
        driver.find_element_by_id("serviceUrl").send_keys("https://en.wikipedia.org")
        driver.find_element_by_id("servicePort").click()
        driver.find_element_by_id("servicePort").clear()
        driver.find_element_by_id("servicePort").send_keys("443")
        driver.find_element_by_id("addRowButton").click()
        driver.find_element_by_id("serviceName").click()
        driver.find_element_by_id("serviceName").clear()
        driver.find_element_by_id("serviceName").send_keys("StackOverflow")
        driver.find_element_by_id("serviceUrl").click()
        driver.find_element_by_id("serviceUrl").clear()
        driver.find_element_by_id("serviceUrl").send_keys("https://stackoverflow.com")
        driver.find_element_by_id("servicePort").click()
        driver.find_element_by_id("servicePort").clear()
        driver.find_element_by_id("servicePort").send_keys("443")
        driver.find_element_by_id("addRowButton").click()
        driver.find_element_by_id("servicesSubmitButton").click()
        driver.find_element_by_id("startButton").click()
        time.sleep(30)
    
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
    unittest.main()
