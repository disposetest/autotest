# #!/usr/bin/env python
from selenium import webdriver
#from selenium.webdriver.chrome.options import Options as ChromeOptions
from webdriver_manager.chrome import ChromeDriverManager
from selenium.common.exceptions import NoSuchElementException

user = "performance_glitch_user"
password = "secret_sauce"
# Start the Browser

print ('Starting the browser...')

#options = ChromeOptions()
#options.add_argument("--headless") 
#driver = webdriver.Chrome(options=options)
driver = webdriver.Chrome()
print ('Browser started successfully. Navigating to the demo page to login.')

# Login with standard_user
def login (user, password):
    'Login with standard_user'
    driver.get('https://www.saucedemo.com/')

    print('filling in the user name')
    driver.find_element_by_css_selector("input[id='user-name']").send_keys(user)
    print('filling in the password')
    driver.find_element_by_css_selector("input[id='password']").send_keys(password)
    print('Signing in')
    driver.find_element_by_css_selector("input[value='LOGIN']").click()
    #login confirmation
    try:
        driver.find_element_by_css_selector("input[value='LOGIN']")
    except NoSuchElementException: 
        return True
    print('Login failed')
    exit()

    page = driver.find_element_by_css_selector("div[class='product_label']").text
    assert "Products" in page
    if page == "Products":
        print ("we are logged in")
    else:
        print("Login failed")

def addCart():
    print('Adding all items to cart')
    items = driver.find_elements_by_xpath("//button[@class='btn_primary btn_inventory']")
    for item in items:
        item.click()
    count = driver.find_element_by_css_selector("span[class='fa-layers-counter shopping_cart_badge']").text
    if "6" in count:
        print("All items where added")
    else:
        print(count + " Items where added to cart")


def removeCart():
    count = 0
    print('Removing items from cart')
    items = driver.find_elements_by_xpath("//button[@class='btn_secondary btn_inventory']")
    for item in items:
        item.click()
    try:
        driver.find_element_by_xpath("//span[@class='btn_primary btn_inventory']")
    except NoSuchElementException:
        print('All items where removed')
        return False
    print('All Items where not removed')
    return True

#execution
login(user, password)
addCart()
removeCart()

