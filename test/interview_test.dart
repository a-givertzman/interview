import 'dart:io';

import 'package:interview/interview.dart';
import 'package:test/test.dart';

import '../bin/interview_improved.dart';

void main() {
  test('calculate', () {
    expect(calculate(), 42);
  });

  group('ParserLoad', () {
    test('getContent', () async {
      await ParserLoad(
        file: File('file.txt'),
      ).getContent().then((result) {
        print('content: $result.data');
        expect(
          result,
          isA<Result<List<int>>>(),
        );
      });
    });
  });
}
