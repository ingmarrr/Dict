from multiprocessing.dummy import Pool
import requests
from requests import Response
from bs4 import BeautifulSoup
from bs4 import ResultSet, Tag
from dataclasses import dataclass
from script2 import extract, Row, Table

BASE_URL: str = "https://3000mostcommonwords.com/"


def fetch_soup(url: str) -> BeautifulSoup:
    page: Response = requests.get(url)
    return BeautifulSoup(page.content, "html.parser")


def fetch_language_urls() -> list[str]:
    soup: BeautifulSoup = fetch_soup(BASE_URL)
    table: ResultSet[Tag] = soup.find_all(
        "figure", class_="wp-block-table is-style-regular"
    )
    links: list[str] = [
        item.split('"')[1]
        for item in str(table).splitlines()
        if item.__contains__("<td><a")
    ]
    for link in links:
        print(link)

    return links


def visit_language_url(url: str) -> Row:
    soup: BeautifulSoup = fetch_soup(url)
    row: Row = Row.from_data(
        [
            soup.find_all("td", class_=f"column-{idx}")[0].__str__()
            for idx in range(2, 6)
        ]
    )
    return row


def fetch_data_and_write_to_file(url) -> tuple[str, Table]:
    page_data: Table = extract(url)
    url_parts: list[str] = url.split("-")
    if url_parts[1] == "most":
        name: str = url.split("-")[3]
    else:
        name: str = url.split("-")[5]
    print(name)

    # all_data[name] = page_data

    with open(f"../../assets/{name}.csv", "w") as f:
        f.write(str(page_data))
    return (name, page_data)


def main():
    all_data: dict[str, Table] = {}
    urls: list[str] = fetch_language_urls()

    with Pool() as pool:
        res = pool.imap_unordered(fetch_data_and_write_to_file, urls)

        for r in res:
            print(r)

    # for url in urls:
    # page_data: Table = extract(url)
    # url_parts: list[str] = url.split("-")
    # if url_parts[1] == "most":
    #     name: str = url.split("-")[3]
    # else:
    #     name: str = url.split("-")[5]
    # print(name)

    # # all_data[name] = page_data

    # with open(f"../../assets/{name}.csv", "w") as f:
    #     f.write(str(page_data))

    # for name, table in all_data.items():
    #     with open(name, "a") as f:
    #         f.write(f"../../assets/{str(table)}")


if __name__ == "__main__":
    main()
