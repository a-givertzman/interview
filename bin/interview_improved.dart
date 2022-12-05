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
  await parserSorted.getContent().then((result) {
    result.fold(
      (data) {
        print('content: $data');
      }, 
      (error) {
        print('while reading file error received: $error');
      }
    );
  });
  await parserSorted.getContentDecoded().then((result) {
    result.fold(
      (data) {
        print('Content Decoded');
        for (final row in data) {
          print('decoded row: $row');
        }
      }, 
      (error) {
        print('while reading file error received: $error');
      }
    );
  });
  await parserSorted.getContentSorted().then((result) {
    result.fold(
      (data) {        
        print('Content Sorted');
        for (final row in data) {
          print('decoded row: $row');
        }
      },
      (error) {
        print('while reading file error received: $error');
      }
    );
  });
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
      print('[ParserLoad.getContent] file: ${_file.absolute}');
      print('[ParserLoad.getContent] size: ${_file.lengthSync()} bytes');
      final Stream<List<int>> iStream = _file.openRead();
      List<int> output = [];
      await for (final data in iStream) {
        // print('[ParserLoad.getContent] data: $data');
        output.addAll(data);
      }
      return Result(data: output);
    } catch(err) {
      print('[ParserLoad.getContent] error: $err');
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
      return result.fold(
        (data) => Result<List<String>>(data: _parseLines(data)),
        (error) => Result<List<String>>(error: result.error)
      );
      // if (result.hasData) {
      // }
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
      return result.fold(
        (data) {
          data.sort((a, b) => a.compareTo(b));
          return Result(
            data: result.data,
          );
        }, 
        (error) => Result(error: error),
      );
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
    T? data,
    Exception? error,
  }) : 
    assert(data != null || error != null),
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
  S fold<S>(
    S Function(T data) onData,
    S Function(Exception error) onError, 
  ) {
    final data = _data;
    if (data != null) {
      return onData(data);
    } else {
      final error = _error;
      if (error != null) {
        return onError(error);
      } else {
        throw Exception('error cant be null if data is null');
      }
    }
  }
  ///
  @override
  String toString() {
    return 'Result{\n\thasData: $hasData; hasError: $hasError\n\tdata:$_data\n\terror:$_error}';
  }
}