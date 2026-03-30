import '../extensions/date_extensions.dart';

class NewsArticle {
  const NewsArticle({
    required this.id,
    required this.title,
    required this.articleUrl,
    required this.source,
    this.summary,
    this.thumbnailUrl,
    this.publisher,
    this.publishedAt,
    this.publishedAtText,
  });

  final String id;
  final String title;
  final String? summary;
  final String? thumbnailUrl;
  final String articleUrl;
  final String? publisher;
  final String source;
  final DateTime? publishedAt;
  final String? publishedAtText;

  String get sourceLabel {
    switch (source.toUpperCase()) {
      case 'LOLESPORTS':
        return 'LoL Esports';
      case 'NAVER_ESPORTS':
        return '네이버 e스포츠';
      default:
        return source;
    }
  }

  String get publishedLabel {
    final text = _normalizedValue(publishedAtText);
    if (text != null) {
      return text;
    }

    final date = publishedAt;
    if (date != null) {
      return date.toKoreanDate();
    }

    return '발행일 미정';
  }

  String get summaryOrPlaceholder {
    return _normalizedValue(summary) ?? '요약 정보가 아직 없습니다.';
  }

  String get publisherOrSource {
    return _normalizedValue(publisher) ?? sourceLabel;
  }

  bool get hasThumbnail => _normalizedValue(thumbnailUrl) != null;

  String get normalizedSource => source.toUpperCase();

  bool get isNaverEsports => normalizedSource == 'NAVER_ESPORTS';

  bool get mentionsLck {
    return _containsLck(title) || _containsLck(summary);
  }

  bool get isVisibleNews {
    return !isNaverEsports || mentionsLck;
  }

  bool matchesKeyword(String keyword) {
    final normalizedKeyword = keyword.trim().toLowerCase();
    if (normalizedKeyword.isEmpty) {
      return true;
    }

    return title.toLowerCase().contains(normalizedKeyword) ||
        (summary?.toLowerCase().contains(normalizedKeyword) ?? false) ||
        (publisher?.toLowerCase().contains(normalizedKeyword) ?? false);
  }

  static String? _normalizedValue(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }

  static bool _containsLck(String? value) {
    final normalizedValue = _normalizedValue(value);
    return normalizedValue?.toLowerCase().contains('lck') ?? false;
  }
}
