import 'dart:io';

import 'rav_data.dart';




void main(List<String> arguments) async {
  final parserSorted = ParserSorted(
    parser: ParserDecode(
      parser: ParserLoad(
        file: File('file.txt'),
      ),
    ),
  );
  final content = await parserSorted.getContent();
  final contentDecoded = await parserSorted.getContentDecoded();
  final contentSorted = await parserSorted.getContentSorted();
  if (content.hasData) {
    print('content: ${content.data}');
  } else {
    print('while reading file error received: ${content.error}');
  }
  if (contentDecoded.hasData) {
    print('Content Decoded');
    for (final row in contentDecoded.data) {
      print('decoded row: ${row}');
    }
  } else {
    print('while reading file error received: ${contentDecoded.error}');
  }
  if (contentSorted.hasData) {
    print('Content Sorted');
    for (final row in contentSorted.data) {
      print('decoded row: ${row}');
    }
  } else {
    print('while reading file error received: ${contentSorted.error}');
  }
  parserSorted.saveContent(
    rawData,
  );
}


///
abstract class ParserBase {
  Future<Result<List<int>>> getContent();
  Future<Result<bool>> saveContent(List<int> content);
}


///
class ParserLoad implements ParserBase {
  final File _file;
  ///
  ParserLoad({
    required File file,
  }) : _file = file;
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
  Future<Result<bool>> saveContent(List<int> content) async {
    try {
      final oStream = _file.openWrite();
      oStream.add(content);
      return Result(data: true);
    } catch (e) {
      return Result(error: Exception(e));
    }
  }
}


///
class ParserDecode implements ParserBase {
  final ParserBase _parser;
  ///
  ParserDecode({
    required ParserBase parser,
  }) : _parser = parser;
  ///
  @override
  Future<Result<List<int>>> getContent() async {
    return _parser.getContent();
  }
  ///
  @override
  Future<Result<bool>> saveContent(List<int> content) {
    return _parser.saveContent(content);
  }
  ///
  Future<Result<List<String>>> getContentDecoded() async {
    return _parser.getContent().then((result) {
      if (result.hasData) {
        return Result(
          data: _parseLines(result.data),
        );
      }
      return Result(error: result.error);
    });
  }
  ///
  List<String> _parseLines(List<int> data) {
    final lines = <String>[];
    String line = '';
    for (final code in data) {
      if (code == 10) {
        lines.add(line);
        line = '';
      } else {
        line += String.fromCharCode(code);
      }
    }
    if (line.isNotEmpty) {
      lines.add(line);
    }
    return lines;
  }
}


///
class ParserSorted implements ParserBase, ParserDecode {
  final ParserDecode _parser;
  ///
  ParserSorted({
    required ParserDecode parser
  }) : _parser = parser;
  ///
  Future<Result<List<int>>> getContent() async {
    return _parser.getContent();
  }
  ///
  @override
  Future<Result<List<String>>> getContentDecoded() {
    return _parser.getContentDecoded();
  }
  @override
  Future<Result<bool>> saveContent(List<int> content) {
    return _parser.saveContent(content);
  }
  ///
  Future<Result<List<String>>> getContentSorted() async {
    return _parser.getContentDecoded().then((result) {
      if (result.hasData) {
        result.data.sort((a, b) => a.compareTo(b));
        return Result(
          data: result.data,
        );
      }
      return result;
    });
  }
  ///
  @override
  List<String> _parseLines(List<int> data) {
    throw UnimplementedError();
  }
}


///
class Result<T> {
  final T? _data;
  final Exception? _error;
  Result({
    data,
    Exception? error,
  }) : 
    _data = data,
    _error = error;
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
  Exception get error {
    final e = _error;
    if (e != null) {
      return e;
    } else {
      throw Exception('data is null');
    }
  }
  ///
  bool get hasData => data != null;
  ///
  bool get hasError => _error != null;
  ///
  @override
  String toString() {
    return 'Result{\n\thasData: $hasData; hasError: $hasError\n\tdata:$_data\n\terror:$_error}';
  }
}