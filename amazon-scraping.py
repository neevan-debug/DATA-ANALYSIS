#importing the libraries
import csv
from selenium import webdriver
from bs4 import BeautifulSoup


#function to get the url of specific page in amazon website
def get_url(search_term):
    """To generate a url from search term"""
    template = "https://www.amazon.in/s?k={}&ref=nb_sb_noss_2"
    search_term = search_term.replace(" ","+")

    #add page query to url
    url = template.format(search_term)
    url += '&page{}'

    return url


#generalizing the pattern
def extract(item):
    #description and url
    atag = item.h2.a
    description = atag.text.strip()
    url = 'https://www.amazon.com' + atag.get('href')

    #price
    try:
        price_parent = item.find('span', 'a-price')
        price = price_parent.find('span','a-offscreen').text
    except AttributeError:
        return

    #rating and count
    try:
        rating = item.i.text
        review_count = item.find('span',{'class':'a-size-base','dir':'auto'}).text
    except AttributeError:
        rating = " "
        review_count = " "

    result = (description,url,price,rating,review_count)

    return result


def main(search_term):
    
    #pointer to the path of chrome driver to scrape the web pages
    PATH = r"C:\Program Files (x86)\chromedriver.exe"
    driver = webdriver.Chrome(executable_path= PATH)

    records = []
    url = get_url(search_term)

    for page in range(1,21):
        driver.get(url.format(page))

        #to get all the html data
        soup = BeautifulSoup(driver.page_source,'html.parser')

        # finding the property which generalises the search results using inspect in the web-page
        results = soup.find_all('div',{'data-component-type': "s-search-result"})

        

        for item in results:
            record = extract(item)
            if record:
                records.append(record)

        with open('results.csv','w', newline="",encoding='utf-8') as f:
            writer = csv.writer(f)
            writer.writerow({'Description','URL','Price','Rating','Review_count'})
            writer.writerows(records)

main("mobile")
