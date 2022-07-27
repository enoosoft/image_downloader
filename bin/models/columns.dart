import 'dart:convert';

import 'abc.dart';

class Columns {
  String csv;
  ABC fileName;
  ABC category1;
  ABC category2;
  ABC url;
  Columns({
    required this.csv,
    required this.fileName,
    required this.category1,
    required this.category2,
    required this.url,
  });

  Columns copyWith({
    String? csv,
    ABC? fileName,
    ABC? category1,
    ABC? category2,
    ABC? url,
  }) {
    return Columns(
      csv: csv ?? this.csv,
      fileName: fileName ?? this.fileName,
      category1: category1 ?? this.category1,
      category2: category2 ?? this.category2,
      url: url ?? this.url,
    );
  }

  @override
  String toString() {
    return 'Columns(csv: $csv, fileName: $fileName, category1: $category1, category2: $category2, url: $url)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Columns &&
        other.csv == csv &&
        other.fileName == fileName &&
        other.category1 == category1 &&
        other.category2 == category2 &&
        other.url == url;
  }

  @override
  int get hashCode {
    return csv.hashCode ^ fileName.hashCode ^ category1.hashCode ^ category2.hashCode ^ url.hashCode;
  }

  bool invalid() {
    return csv.isEmpty ||
        fileName == ABC.NOT_FOUND ||
        category1 == ABC.NOT_FOUND ||
        category2 == ABC.NOT_FOUND ||
        url == ABC.NOT_FOUND;
  }
}
