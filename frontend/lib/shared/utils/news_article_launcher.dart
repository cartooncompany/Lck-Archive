import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/news_article.dart';

Future<void> openNewsArticle(BuildContext context, NewsArticle article) async {
  final uri = Uri.tryParse(article.articleUrl);
  if (uri == null || !uri.hasScheme) {
    _showFailure(context, '유효하지 않은 기사 링크입니다.');
    return;
  }

  try {
    final launched = await launchUrl(uri, webOnlyWindowName: '_blank');
    if (!launched && context.mounted) {
      _showFailure(context, '기사 링크를 열지 못했습니다.');
    }
  } catch (_) {
    if (context.mounted) {
      _showFailure(context, '기사 링크를 열지 못했습니다.');
    }
  }
}

void _showFailure(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
