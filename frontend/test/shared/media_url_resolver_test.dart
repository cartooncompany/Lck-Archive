import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/network/media_url_resolver.dart';

void main() {
  group('resolveMediaUrl', () {
    test('upgrades remote http media urls to https', () {
      expect(
        resolveMediaUrl('http://static.lolesports.com/teams/t1.png'),
        'https://static.lolesports.com/teams/t1.png',
      );
    });

    test('keeps remote https media urls as-is', () {
      expect(
        resolveMediaUrl(
          'https://imgnews.pstatic.net/image/origin/382/2026/03/30/1265180.jpg',
        ),
        'https://imgnews.pstatic.net/image/origin/382/2026/03/30/1265180.jpg',
      );
    });
  });
}
