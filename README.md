# Image (in CSV) downloader

It is a program that downloads the network image url of the Excel (csv) file in bulk and stores it in a folder by category in Excel.

## How to run

```shell
image_down.exe  --csv image_source3.csv --fileName A  --category1 B --category2 C --url D
```

## Arguments

- csv : Input Excel csv file
- fileName : Column ID containing image file name. ex) A
- category1: Category 1 column ID. ex) B
- category2 : Category 2 column ID. ex) C
- url : Column ID containing the network image URL. ex) D
