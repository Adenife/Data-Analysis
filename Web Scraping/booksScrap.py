# import libraries to use
from bs4 import BeautifulSoup
import requests


# define selectors to use. VALIES ARE HTML TAGS OR ELEMENTS
price_selector = ".price_color"
title_selector = ".product_pod h3 a"
rating_selector = ".star-rating"


rating_mapping = {
    "One": 1,
    "Two": 2,
    "Three": 3,
    "Four": 4,
    "Five": 5
}


def get_rating(tag):
    for term, rating in rating_mapping.items():
        if term in tag['class']:
            return rating


for i in range(2,10,1):
    data = requests.get("http://books.toscrape.com/catalogue/page-" +str(i)+ ".html").content
    # data = requests.get("http://books.toscrape.com").content
    soup = BeautifulSoup(data, "html.parser")


    prices = soup.select(price_selector)
    titles = soup.select(title_selector)
    ratings = soup.select(rating_selector)


    for price, title, rating in zip(prices, titles, ratings):
        print(f"{title['title']} costs {price.string} with a rating of {get_rating(rating)}")
    # with open("books.csv", "a", encoding="utf-8") as book_file:
    #     for price, title, rating in zip(prices, titles, ratings):
    #         book_file.write(f"{title['title']},{price.string},{get_rating(rating)}\n")