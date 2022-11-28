import 'dart:io';

import 'rav_data.dart';




void main(List<String> arguments) async {
  final parserSorted = ParserSorted(
    parser: Parser(file: File('file.txt'),),
  );
  final content = await parserSorted.getContent();
  if (content.hasData) {
    print('content: ${content.data}');
  } else {
    print('while reading file error received: ${content.error}');
  }
  // parser.saveContent(
  //   rawData,
  // );
}


abstract class ParserI {
  Future<Result<List<int>>> getContent();
  Future<Result<List<String>>> getContentUnicode();
}


class Parser {
  final File _file;
  ///
  Parser({
    required File file,
  }) : _file = file.existsSync() ? file : throw Exception();
  ///
  File? getFile() {
    return _file;
  }
  ///
  Future<Result<List<int>>> getContent() async {
    try {
      final Stream<List<int>> iStream = _file.openRead();
      List<int> output;
      output = [];
      List<int> data;
      await for (data in iStream) {
        // print('data: $data\n');
        output.addAll(data);
      }
      return Result(data: output);
    } catch(err) {
      print(err);
      return Result(error: Exception(err));
    }
  }
  ///
  Future<String?> getContentUnicode() async {
    final Stream<List<int>> iStream = _file.openRead();
    String? output;
    int data;
    if (await iStream.length > 0) {
      output = '';
      await for (final data in iStream) {
        print('data: $data\n');
        output = output! + String.fromCharCodes(data);
      }
    }
    return output;
  }
  ///
  void saveContent(List<int> content) async {
    final oStream = _file.openWrite();
    oStream.add(content);
  }
}

class ParserSorted {
  final Parser _parser;
  ParserSorted({
    required Parser parser
  }) : _parser = parser;
  Future<Result<List<int>>> getContent() async {
    return _parser.getContent();
  }
    Future<Result<List<int>>> getContentSorted() async {
    return _parser.getContent().then((value) {
      if (value.hasData) {
        value.data.sort((a, b) => a.compareTo(b));
        return Result(
          data: value.data,
        );
      }
      return value;
    });
  }
}


class Result<T> {
  final T? _data;
  final Exception? error;
  Result({
    data,
    this.error,
  }) : _data = data;
  ///
  T get data {
    final d = _data;
    if (d != null) {
      return d;
    } else {
      throw Exception('data is null');
    }
  }
  ///
  bool get hasData {
    if (data != null) {
      return true;
    } else {
      return false;
    }
  }
  ///
}