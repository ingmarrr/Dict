from dataclasses import dataclass


@dataclass
class Data:
    eng: str
    swe: str

    def __str__(self) -> str:
        return f"{self.eng}: {self.swe}"


def read_file(path: str) -> list[str]:
    with open(path, "r") as f:
        raw: list[str] = [
            item.strip().replace("<td>", "").replace("</td>", "")
            for item in f.readlines()
        ]
        return raw


def main():
    path: str = "../assets/data.csv"
    raw_data: list[str] = read_file(path)
    data: list[Data] = []

    for i in range(0, raw_data.__len__(), 5):
        data.append(Data(raw_data[i + 2], raw_data[i + 3]))

    with open("../assets/eng-swe.csv", "a") as f:
        f.write("eng, swe\n")
        for item in data:
            f.write(f"{item.eng}, {item.swe}\n")


if __name__ == "__main__":
    main()
