from dataclasses import dataclass
from typing import Any, Tuple
import requests
from bs4 import BeautifulSoup as bs
from bs4.element import Tag
from bs4 import ResultSet
from itertools import zip_longest


URL: str = (
    "https://3000mostcommonwords.com/list-of-3000-most-common-swedish-words-in-english/"
)


RowData = Tuple[str, str, str, str]


@dataclass()
class Row:
    word: str
    word_type: str
    lvl: str
    translation: str

    def __str__(self) -> str:
        return f"{self.word};{self.word_type};{self.lvl};{self.translation}\n"

    @staticmethod
    def empty() -> "Row":
        return Row("", "", "", "")

    @staticmethod
    def from_data(data: list[Any]) -> "Row":
        if len(data) != 4:
            return Row.empty()
        return Row(word=data[0], word_type=data[1], lvl=data[2], translation=data[3])


@dataclass
class Table:
    rows: list[Row]

    def add_row(self, row: Row) -> None:
        self.rows.append(row)

    def __str__(self) -> str:
        return "".join([str(row) for row in self.rows])

    @staticmethod
    def empty() -> "Table":
        return Table([])


def extract(url: str) -> Table:
    # det = '<td class="column-1">'
    page = requests.get(url)
    soup = bs(page.content, "html.parser")
    cols: list[list[str]] = []
    for i in range(2, 6):
        res: ResultSet[Tag] = soup.find_all("td", class_=f"column-{i}")
        contents: list[str] = []
        for tag in res:
            # print(tag.contents)

            try:
                contents.append(tag.contents[0].__str__())
            except IndexError:
                contents.append(" ")
        cols.append(contents)

    table: Table = Table([])
    for i in range(max([len(item) for item in cols])):
        table.add_row(
            row=Row(
                word=cols[0][i],
                word_type=cols[1][i],
                lvl=cols[2][i],
                translation=cols[3][i],
            )
        )

    return table


def main():
    t1: Table = extract(URL)

    with open("../../assets/3k.csv", "a") as f:
        f.write(str(t1))


if __name__ == "__main__":
    main()
