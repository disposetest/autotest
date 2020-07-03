# #!/usr/bin/env python
from selenium import webdriver
from selenium.webdriver.chrome.options import Options as ChromeOptions
from selenium.common.exceptions import NoSuchElementException

user = "standard_user"
password = "secret_sauce"

options = ChromeOptions()
#options.add_argument("--headless") 
options.add_argument("--no-sandbox") 
options.add_argument("--disable-dev-shm-usage")
#options.add_argument("disable-infobars")
#options.add_argument("--disable-dev-shm-usage")
driver = webdriver.Chrome(options=options)

# Login
def login (user, password):
    'Login with standard_user'

    print ('Browser started successfully. Navigating to the demo page to login.')

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
        print('\"'+ user + '\" was successfully logged in.')
        return True
    print('Login failed for \"'+ user + '\".')
    exit()
    return False

def addCart():
    'Add store items to the cart'
    print('Adding items to cart')
    #items = driver.find_elements_by_css_selector("button[class='btn_primary btn_inventory']")
    items = driver.find_elements_by_css_selector("div[class='inventory_item']")

    for item in items:

        item.find_element_by_css_selector("button[class='btn_primary btn_inventory']").click()
        #test if item was added or not
        try:
            item.find_element_by_css_selector("button[class='btn_primary btn_inventory']")
        except NoSuchElementException:
            print("Added  " + item.find_element_by_css_selector("div[class='inventory_item_name']").text)
                       
        
    count = driver.find_element_by_css_selector("span[class='fa-layers-counter shopping_cart_badge']").text
    if "6" in count:
        print("All "+ count +" items where added")
    else:
        print("Only " + count + " items where added to cart")


def removeCart():
    'Remove store items from the cart'
   
    print('Removing items from cart')
    items = driver.find_elements_by_css_selector("div[class='inventory_item']")
    for item in items:

        item.find_element_by_css_selector("button[class='btn_secondary btn_inventory']").click()
        #test if item was removed or not
        try:
            item.find_element_by_css_selector("button[class='btn_secondary btn_inventory']")
        except NoSuchElementException:
            print("removed  " + item.find_element_by_css_selector("div[class='inventory_item_name']").text)

# Start
print()
print ('--------------Starting the browser-----------------')      
   
#execution
login(user, password)
addCart()
removeCart()

#end
print("-------------------------End----------------------------------")

