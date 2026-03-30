import 'pagination_meta.dart';

class PagedResponse<T> {
  const PagedResponse({required this.items, required this.meta});

  factory PagedResponse.fromJson(
    Map<String, dynamic> json, {
    required T Function(Map<String, dynamic> json) itemDecoder,
  }) {
    final rawItems = (json['items'] as List<dynamic>? ?? const <dynamic>[]);
    return PagedResponse(
      items: rawItems
          .map((item) => itemDecoder(item as Map<String, dynamic>))
          .toList(),
      meta: PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );
  }

  final List<T> items;
  final PaginationMeta meta;
}
