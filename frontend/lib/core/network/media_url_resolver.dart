import 'api_base_url.dart';

String? resolveMediaUrl(String? rawUrl) {
  final normalizedUrl = rawUrl?.trim();
  if (normalizedUrl == null || normalizedUrl.isEmpty) {
    return null;
  }

  final baseOrigin = Uri.parse(_originFromApiBaseUrl(resolveApiBaseUrl()));

  if (normalizedUrl.startsWith('//')) {
    return '${baseOrigin.scheme}:$normalizedUrl';
  }

  final parsedUrl = Uri.tryParse(normalizedUrl);
  if (parsedUrl == null) {
    return null;
  }

  if (!parsedUrl.hasScheme) {
    return _rebaseToApiOrigin(baseOrigin, parsedUrl).toString();
  }

  if (_isLoopbackHost(parsedUrl.host)) {
    return _rebaseToApiOrigin(baseOrigin, parsedUrl).toString();
  }

  if (parsedUrl.scheme == 'http') {
    return parsedUrl.replace(scheme: 'https').toString();
  }

  return parsedUrl.toString();
}

String _originFromApiBaseUrl(String apiBaseUrl) {
  final apiUri = Uri.parse(apiBaseUrl);
  return '${apiUri.scheme}://${apiUri.authority}';
}

Uri _rebaseToApiOrigin(Uri baseOrigin, Uri source) {
  final normalizedPath = switch (source.path) {
    '' => '/',
    final path when path.startsWith('/') => path,
    final path => '/$path',
  };

  return baseOrigin.replace(
    path: normalizedPath,
    query: source.hasQuery ? source.query : null,
    fragment: source.fragment.isNotEmpty ? source.fragment : null,
  );
}

bool _isLoopbackHost(String host) {
  final normalizedHost = host.toLowerCase();
  return normalizedHost == 'localhost' ||
      normalizedHost == '127.0.0.1' ||
      normalizedHost == '0.0.0.0' ||
      normalizedHost == '10.0.2.2' ||
      normalizedHost == '::1' ||
      normalizedHost == '[::1]';
}
