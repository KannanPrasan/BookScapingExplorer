import requests
import json
import pandas as pd
from sqlalchemy import create_engine, Table, Column, String, Integer, Float, Boolean, Text, MetaData
from sqlalchemy.dialects.mysql import VARCHAR
import sys


API_KEY = "AIzaSyAYEM-BVrBQbyUx0fFjXgaMEzWS7Ncb4UQ"
BASE_URL = "https://www.googleapis.com/books/v1/volumes"


username = "jup1user"
password = "Jup12user"
host = "localhost"
database = "BookScape"


engine = create_engine(f"mysql+pymysql://{username}:{password}@{host}/{database}")


metadata = MetaData()


query = sys.argv[1]
max_results = 40  # Max allowed by the API
total_records = int(sys.argv[2])  # Adjust based on your requirement
all_books = []


for start_index in range(0, total_records, max_results):
    params = {
        "q": query,
        "startIndex": start_index,
        "maxResults": max_results,
        "key": API_KEY
    }
    response = requests.get(BASE_URL, params=params)
    if response.status_code == 200:
        data = response.json()
        all_books.extend(data.get("items", []))
        book_list = []
        for book in data["items"]:
            volume_info = book.get("volumeInfo", {})
            sale_info = book.get("saleInfo", {})

            book_dict = {
                "book_id": book.get("id"),
                "search_key": query,  # Replace with your search key logic
                "book_title": volume_info.get("title"),
                "book_subtitle": volume_info.get("subtitle"),
                "book_authors": ", ".join(volume_info.get("authors", [])),
                "book_description": volume_info.get("description"),
                "industryIdentifiers": ", ".join(
                    f"{iden['type']}: {iden['identifier']}" for iden in volume_info.get("industryIdentifiers", [])
                ),
                "text_readingModes": volume_info.get("readingModes", {}).get("text"),
                "image_readingModes": volume_info.get("readingModes", {}).get("image"),
                "pageCount": volume_info.get("pageCount"),
                "categories": ", ".join(volume_info.get("categories", [])),
                "language": volume_info.get("language"),
                "imageLinks": volume_info.get("imageLinks", {}).get("thumbnail"),
                "ratingsCount": volume_info.get("ratingsCount"),
                "averageRating": volume_info.get("averageRating"),
                "country": sale_info.get("country"),
                "saleability": sale_info.get("saleability"),
                "isEbook": sale_info.get("isEbook"),
                "amount_listPrice": sale_info.get("listPrice", {}).get("amount"),
                "currencyCode_listPrice": sale_info.get("listPrice", {}).get("currencyCode"),
                "amount_retailPrice": sale_info.get("retailPrice", {}).get("amount"),
                "currencyCode_retailPrice": sale_info.get("retailPrice", {}).get("currencyCode"),
                "buyLink": sale_info.get("buyLink"),
                "year": volume_info.get("publishedDate"),
                "publisher": volume_info.get("publisher"),
            }

            book_list.append(book_dict)


        df = pd.DataFrame(book_list)




        for col in df.select_dtypes(include=['object']).columns:
            df[col] = df[col].fillna("NA")


        df["ratingsCount"] = pd.to_numeric(df["ratingsCount"], errors="coerce").fillna(0.0)
        df["averageRating"] = pd.to_numeric(df["averageRating"], errors="coerce").fillna(0.0)
        df["amount_listPrice"] = pd.to_numeric(df["amount_listPrice"], errors="coerce").fillna(0.0)
        df["amount_retailPrice"] = pd.to_numeric(df["amount_retailPrice"], errors="coerce").fillna(0.0)

        df.to_sql("books", con=engine, if_exists="append", index=False)
        print("Data inserted into the 'books' table.")
        print ("Scrapped and loaded ",len(all_books), " records")
    else:
        print(f"Error: {response.status_code}, {response.text}")
        break

print(f"Fetched {len(all_books)} books.")
engine.dispose()
print("Database connection closed.")
