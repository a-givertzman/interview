import 'dart:io';

import 'rav_data.dart';

void main(List<String> arguments) async {
  final parser = Parser();
  parser.setFile(
    File('file.txt'),
  );
  final content = await parser.getContentUnicode();
  final contentDecoded = await parser.getContentUnicode();
  print('content: $content');
  print('decoded: $contentDecoded');
  parser.saveContent(
    rawData
  );
}


class Parser {
  late File _file;
  ///
  void setFile(File f) {
    _file = f;
  }
  ///
  File getFile() {
    return _file;
  }
  ///
  Future<List?> getContent() async {
    final Stream<List> iStream = _file.openRead();
    List output = [];
    await for (final data in iStream) {
      // print('data: $data\n');
      output.addAll(data);
    }
    return output;
  }
  ///
  Future<List?> getContentSorted() async {
    final Stream<List<int>> iStream = _file.openRead();
    List<String> output = [];
    await for (final data in iStream) {
      print('data: $data\n');
      output.add(String.fromCharCodes(data));
    }
    output.sort(((a, b) => a.compareTo(b)));
    return output;
  }
  ///
  Future<List<String>?> getContentUnicode() async {
    final Stream<List<int>> iStream = _file.openRead();
    List<String> output = [];
    await for (final data in iStream) {
      print('data: $data\n');
      output.add(String.fromCharCodes(data));
    }
    return output;
  }
  ///
  void saveContent(List<int> content) async {
    final oStream = _file.openWrite();
    oStream.add(content);
  }
}