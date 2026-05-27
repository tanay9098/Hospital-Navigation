from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.desired_capabilities import DesiredCapabilities
import time
import json

options = Options()
options.add_argument('--headless')
options.set_capability('goog:loggingPrefs', {'browser': 'ALL'})

driver = webdriver.Chrome(options=options)
driver.get("http://localhost:8080")
time.sleep(3)

logs = driver.get_log('browser')
for log in logs:
    if log['level'] == 'SEVERE':
        print(log)

driver.quit()
