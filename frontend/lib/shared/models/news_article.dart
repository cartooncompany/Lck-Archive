class NewsArticle {
  const NewsArticle({
    required this.id,
    required this.title,
    required this.publishedAt,
    required this.summary,
    required this.tags,
    required this.sourceLabel,
    required this.link,
  });

  final String id;
  final String title;
  final DateTime publishedAt;
  final String summary;
  final List<String> tags;
  final String sourceLabel;
  final String link;
}
