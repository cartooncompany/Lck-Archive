class NewsItemDto {
  const NewsItemDto({
    required this.id,
    required this.title,
    required this.summary,
    required this.thumbnailUrl,
    required this.articleUrl,
    required this.publisher,
    required this.source,
    required this.publishedAt,
    required this.publishedAtText,
  });

  factory NewsItemDto.fromJson(Map<String, dynamic> json) {
    return NewsItemDto(
      id: json['id'] as String,
      title: json['title'] as String,
      summary: json['summary'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      articleUrl: json['articleUrl'] as String,
      publisher: json['publisher'] as String?,
      source: json['source'] as String,
      publishedAt: _parseDateTime(json['publishedAt']),
      publishedAtText: json['publishedAtText'] as String?,
    );
  }

  final String id;
  final String title;
  final String? summary;
  final String? thumbnailUrl;
  final String articleUrl;
  final String? publisher;
  final String source;
  final DateTime? publishedAt;
  final String? publishedAtText;

  static DateTime? _parseDateTime(dynamic value) {
    if (value is! String || value.trim().isEmpty) {
      return null;
    }
    return DateTime.tryParse(value);
  }
}
