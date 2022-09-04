from email.mime import base
from multiprocessing.dummy import Pool
import requests
from requests import Response
from bs4 import BeautifulSoup
from bs4 import ResultSet, Tag
from dataclasses import dataclass
from script3 import fetch_soup


def japan_urls() -> list[str]:
    return [
        "https://app.memrise.com/course/2022732/japanese-1/",
        "https://app.memrise.com/course/2021170/japanese-2/",
        "https://app.memrise.com/course/1389173/japanese-3/",
        "https://app.memrise.com/course/1891003/japanese-4/",
        "https://app.memrise.com/course/1891054/japanese-5/",
        "https://app.memrise.com/course/1891011/japanese-6/",
    ]


def korean_urls() -> list[str]:
    return [
        "https://app.memrise.com/course/2141906/korean-1/",
        "https://app.memrise.com/course/2141908/korean-2/",
        "https://app.memrise.com/course/1125956/korean-3/",
        "https://app.memrise.com/course/5732757/korean-4/",
        "https://app.memrise.com/course/5732758/korean-5/",
        "https://app.memrise.com/course/5732759/korean-6/",
        "https://app.memrise.com/course/5732760/korean-7/",
    ]


def base_url(idx: int) -> str:
    if idx == 1:
        return f"https://app.memrise.com/course/99412/8000-most-common-swedish-words-part-1-of-four/1/"
    return f"https://app.memrise.com/course/113511{idx-1}/swedish-{idx}/"


@dataclass
class DataSc5:
    eng: str
    swe: str

    def __str__(self) -> str:
        return f"{self.swe};{self.eng}\n"


@dataclass
class TableSc5:
    items: list[DataSc5]

    @staticmethod
    def empty() -> "TableSc5":
        return TableSc5([])

    def __str__(self) -> str:
        return "".join([str(item) for item in self.items])

    def __len__(self):
        return len(self.items)


def visit_lvl_page(url: str) -> TableSc5:
    soup: BeautifulSoup = fetch_soup(url)
    col_a: ResultSet[Tag] = soup.find_all("div", class_="col_a col text")
    col_b: ResultSet[Tag] = soup.find_all("div", class_="col_b col text")
    zipped: list[tuple[Tag, Tag]] = list(zip(col_a, col_b))

    delim: str = '<div class="text">'

    return TableSc5(
        [
            DataSc5(
                i2.contents[0].getText().replace(",", "-").replace(";", "-"),
                i1.contents[0].getText(),
            )
            for i1, i2 in zipped
        ]
    )


def fetch_lvls() -> None:
    # for i in range(2, 8):
    # soup: BeautifulSoup = fetch_soup(base_url(i))
    for url in japan_urls():
        soup: BeautifulSoup = fetch_soup(url)
        content: ResultSet[Tag] = soup.find_all("a", class_="level clearfix")
        print(content)
        links = [
            f'https://app.memrise.com{content[i]["href"]}' for i in range(len(content))
        ]
        tables: list[TableSc5] = []

        with Pool() as pool:
            res = pool.imap_unordered(visit_lvl_page, links)

            for r in res:
                tables.append(r)

        name: str = url.split("/")[-2]
        with open(f"../../assets/memrise/{name}.csv", "a") as f:
            for table in tables:
                f.write(str(table))


def main():
    fetch_lvls()


if __name__ == "__main__":
    main()
