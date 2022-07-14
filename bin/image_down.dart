import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:convert' show utf8;
import 'package:csv/csv.dart';

Future<void> main(List<String> arguments) async {
  final input = File('assets/image_sample.csv').openRead();

  final fields = await input.transform(utf8.decoder).transform(CsvToListConverter()).toList();

  File logger = File("image_downloader.log");
  int count = 0, failCount = 0;
  for (int i = 0; i < fields.length; i++) {
    final line = fields[i];
    if (i == 0) {
      continue;
    }  
    String uri = line[Cols.imageUrl.index].toString().trim();
    if (uri.isEmpty || !uri.startsWith('http')) {
      log('$i   ${line[Cols.prdcd.index]}  ${line[Cols.category1.index]}  ${line[Cols.category2.index]}  ${line[Cols.imageUrl.index]} INVALID IMAGE ADDRESS...');
      logger.writeAsString(
          '$i   ${line[0]}  ${line[Cols.category1.index]}  ${line[Cols.category2.index]}  ${line[Cols.imageUrl.index]} INVALID IMAGE ADDRESS...\n',
          mode: FileMode.append);
      failCount++;
      continue;
    }

    String extension = line[Cols.imageUrl.index]
        .toString()
        .substring(line[Cols.imageUrl.index].toString().lastIndexOf('.') + 1);
    String targetFileName = imageFullFileName(
        line[Cols.category1.index], line[Cols.category2.index], line[0].toString(), extension);

    var newDirectory = Directory(imagePath(line[Cols.category1.index], line[Cols.category2.index]));
    newDirectory.createSync(recursive: true);

    await download(line[Cols.imageUrl.index].toString().trim(), targetFileName).then((success) {
      if (success) {
        log('$i   ${line[0]}  ${line[Cols.category1.index]}  ${line[Cols.category2.index]}  ${line[Cols.imageUrl.index]} $targetFileName SUCCESS.');
        logger.writeAsString(
            '$i   ${line[0]}  ${line[Cols.category1.index]}  ${line[Cols.category2.index]}  ${line[Cols.imageUrl.index].toString().trim()} $targetFileName SUCCESS.\n',
            mode: FileMode.append);

        count++;
      } else {
        log('$i   ${line[0]}  ${line[Cols.category1.index]}  ${line[Cols.category2.index]}  ${line[Cols.imageUrl.index]} $targetFileName FAIL...');
        logger.writeAsString(
            '$i   ${line[0]}  ${line[Cols.category1.index]}  ${line[Cols.category2.index]}  ${line[Cols.imageUrl.index].toString().trim()} $targetFileName FAIL...\n',
            mode: FileMode.append);
        failCount++;
      }
    });
  }

  log('SUCCESS = $count/${fields.length}');
  log('FAIL = $failCount/${fields.length}');
  logger.writeAsString('SUCCESS = $count/${fields.length}\n', mode: FileMode.append);
  logger.writeAsString('FAIL = $failCount/${fields.length}\n', mode: FileMode.append);
}

String imagePath(String category1, String category2) {
  return 'target/${category1.replaceAll(RegExp(r'[/\s]'), '')}_${category2.replaceAll(RegExp(r'[/\s]'), '')}';
}

String imageFullFileName(String category1, String category2, String prdcd, String extension) {
  return '${imagePath(category1, category2)}/of_$prdcd.$extension';
}

Future<bool> download(String uri, String targetFileName) async {
  final request = await HttpClient().getUrl(Uri.parse(uri));
  final response = await request.close();
  await response.pipe(File(targetFileName).openWrite());
  return true;
}

enum Cols {
  prdcd,
  prdnm,
  category1,
  category2,
  category3,
  customerPrice,
  shopMallPrice,
  ourPrice,
  dcrt,
  imageUrl,
  desc,
  infomation
}
