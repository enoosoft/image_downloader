import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:convert' show utf8;
import 'package:args/args.dart';
import 'package:csv/csv.dart';

import 'models/abc.dart';
import 'models/columns.dart';

final usage = '''
# 사용법
image_downloader.exe  --csv image_source3.csv --fileName A  --category1 B --category2 C --url D

# 매개변수
--csv       : 입력정보 엑셀 csv 파일
--fileName  : 이미지파일명이 들어있는 컬럼ID
--category1 : 분류1 컬럼ID
--category2 : 분류2 컬럼ID
--url       : 네트워크이미지 URL이 들어있는 컬럼ID
''';
Future<void> main(List<String> arguments) async {
  exitCode = 0; // presume success
  var parser = ArgParser();
  parser.addOption('csv', abbr: 'v', mandatory: true);
  parser.addOption('fileName', abbr: 'f', mandatory: true);
  parser.addOption('category1', abbr: 'c', mandatory: true);
  parser.addOption('category2', abbr: 'd', mandatory: true);
  parser.addOption('url', abbr: 'u', mandatory: true);

  Columns cols;
  ArgResults args;
  try {
    args = parser.parse(arguments);
    cols = Columns(
      csv: args['csv'],
      fileName: ABC.ofString(args['fileName']),
      category1: ABC.ofString(args['category1']),
      category2: ABC.ofString(args['category2']),
      url: ABC.ofString(args['url']),
    );
  } catch (e) {
    print(usage);
    print(e);
    exit(1);
  }

  if (cols.invalid()) {
    print(usage);
    exit(1);
  }

  final input = File(cols.csv).openRead();

  final fields = await input.transform(utf8.decoder).transform(CsvToListConverter()).toList();

  File logger = File("image_downloader.log");
  int count = 0, failCount = 0;
  for (int i = 0; i < fields.length; i++) {
    final line = fields[i];
    if (i == 0) {
      continue;
    }
    String uri = line[cols.url.index].toString().trim();
    if (uri.isEmpty || !uri.startsWith('http')) {
      log('$i   ${line[cols.fileName.index]}  ${line[cols.category1.index]}  ${line[cols.category2.index]}  ${line[cols.url.index]} INVALID IMAGE ADDRESS...');
      logger.writeAsString(
          '$i   ${line[0]}  ${line[cols.category1.index]}  ${line[cols.category2.index]}  ${line[cols.url.index]} INVALID IMAGE ADDRESS...\n',
          mode: FileMode.append);
      failCount++;
      continue;
    }

    String extension = line[cols.url.index].toString().substring(line[cols.url.index].toString().lastIndexOf('.') + 1);
    String targetFileName =
        imageFullFileName(line[cols.category1.index], line[cols.category2.index], line[0].toString(), extension);

    var newDirectory = Directory(imagePath(line[cols.category1.index], line[cols.category2.index]));
    newDirectory.createSync(recursive: true);
    String logString =
        '$i   ${line[0]}  ${line[cols.category1.index]}  ${line[cols.category2.index]} ${line[cols.url.index].toString().trim()} $targetFileName ';
    await download(line[cols.url.index].toString().trim(), targetFileName).then((success) {
      if (success) {
        log('SUCCESS $logString');
        logger.writeAsString('SUCCESS $logString\n', mode: FileMode.append);

        count++;
      } else {
        log('FAIL... $logString');
        logger.writeAsString('FAIL... $logString\n', mode: FileMode.append);
        failCount++;
      }
    });
  }

  log('SUCCESS = $count/${fields.length - 1}'); //minus header row count
  log('FAIL = $failCount/${fields.length - 1}');
  logger.writeAsString('SUCCESS = $count/${fields.length - 1}\n', mode: FileMode.append);
  logger.writeAsString('FAIL = $failCount/${fields.length - 1}\n', mode: FileMode.append);
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
