from genericpath import isfile
import os


def main():

    os.chdir("../../assets")
    files: list[str] = os.listdir()
    files.sort()

    with open("_info.csv", "w") as f:
        for file in files:
            if file.startswith("_"):
                continue
            f.write(file + "\n")


if __name__ == "__main__":
    main()
