import os
import json 
import requests # to send GET requests to the server
from bs4 import BeautifulSoup # to parse HTML of the page

# user needs to input a topic and a number for number of files (max 20 images)


GOOGLE_IMAGE = \
    'https://www.google.com/search?site=&tbm=isch&source=hp&biw=1873&bih=990&'

# The User-Agent request header contains a characteristic string 
# that allows the network protocol peers to identify the application type, 
# operating system, and software version of the requesting software user agent.
# needed for google search
user_agent = {
    'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.11 (KHTML, like Gecko) Chrome/23.0.1271.64 Safari/537.11',
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
    'Accept-Charset': 'ISO-8859-1,utf-8;q=0.7,*;q=0.3',
    'Accept-Encoding': 'none',
    'Accept-Language': 'en-US,en;q=0.8',
    'Connection': 'keep-alive',
}

SAVE_FOLDER = 'images'

def main():
    if not os.path.exists(SAVE_FOLDER):
        os.mkdir(SAVE_FOLDER)
    download()
    
def download():
    # asking for user input
    data = input('What topic are you looking for? ')
    n_images = int(input('How many images do you want to download? '))

    print('Started searching...')
    
    # get url query string
    searchurl = GOOGLE_IMAGE + 'q=' + data
    

    # request url, without usr_agent the permission gets denied
    response = requests.get(searchurl, headers=user_agent)
    html = response.text
    
    # finding all divs where class='RAyV4b' as evident from inspecting the webpage
    soup = BeautifulSoup(html, 'html.parser')
    results = soup.find_all('div', class_ ="RAyV4b", limit=n_images)
    # extracting the link from the div tag
    imagelinks= []
    for re in results:
        link = re.img.get('src')
        
        imagelinks.append(link)
    print(f'found {len(imagelinks)} images')
    print('Started downloading...')

    for i, imagelink in enumerate(imagelinks):
        # open image link and save as file
        response = requests.get(imagelink)
        
        imagename = SAVE_FOLDER + '/' + data + str(i+1) + '.jpg'
        with open(imagename, 'wb') as file:
            file.write(response.content)
        

    print('Done')
    


if __name__ == '__main__':
    main()