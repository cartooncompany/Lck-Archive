import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../app/app_dependencies_scope.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/error/app_failure.dart';
import '../../../../shared/models/news_article.dart';
import '../../../../shared/utils/news_article_launcher.dart';
import '../../../../shared/widgets/app_search_field.dart';
import '../widgets/news_article_card.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  static const int _pageSize = 20;

  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

  List<NewsArticle> _articles = const <NewsArticle>[];
  _NewsSourceFilter _selectedSource = _NewsSourceFilter.all;
  _NewsSortOrder _sortOrder = _NewsSortOrder.desc;
  String _keyword = '';
  String? _errorMessage;
  int _currentPage = 0;
  int _totalPages = 0;
  int _totalItems = 0;
  bool _hasLoaded = false;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _refreshAfterCurrentLoad = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasLoaded) {
      _hasLoaded = true;
      unawaited(_fetchNews(reset: true));
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasMore = _currentPage < _totalPages;

    return RefreshIndicator(
      onRefresh: () => _fetchNews(reset: true, force: true),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screen,
          12,
          AppSpacing.screen,
          120,
        ),
        children: [
          Text('이번 주 LCK 뉴스', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 6),
          Text(
            '검색, 소스 필터, 정렬 기준을 바꿔가며 최신 뉴스를 바로 확인할 수 있습니다.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 18),
          AppSearchField(
            controller: _searchController,
            hintText: '팀명, 선수명, 기사 제목으로 검색',
            onChanged: _handleKeywordChanged,
          ),
          const SizedBox(height: 14),
          _FilterSection(
            title: '소스',
            children: _NewsSourceFilter.values
                .map(
                  (filter) => _ChoiceFilterChip(
                    label: filter.label,
                    selected: _selectedSource == filter,
                    onSelected: () => _updateSource(filter),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 10),
          _FilterSection(
            title: '정렬',
            children: _NewsSortOrder.values
                .map(
                  (sortOrder) => _ChoiceFilterChip(
                    label: sortOrder.label,
                    selected: _sortOrder == sortOrder,
                    onSelected: () => _updateSortOrder(sortOrder),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          Text(
            _buildMetaText(),
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          if (_isLoading && _articles.isEmpty)
            const SizedBox(
              height: 240,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_errorMessage != null && _articles.isEmpty)
            _NewsStatusCard(
              message: _errorMessage!,
              actionLabel: '다시 시도',
              onActionTap: () => _fetchNews(reset: true, force: true),
            )
          else if (_articles.isEmpty)
            const _NewsStatusCard(
              message: '조건에 맞는 뉴스가 없습니다. 데이터가 비어 있다면 백엔드에서 수동 동기화를 먼저 요청해 주세요.',
            )
          else ...[
            ..._articles.map(
              (article) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: NewsArticleCard(
                  article: article,
                  onTap: () => _openArticle(article),
                ),
              ),
            ),
            if (hasMore || _isLoadingMore)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: OutlinedButton(
                  onPressed: _isLoadingMore ? null : () => _fetchNews(),
                  child: _isLoadingMore
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('더 불러오기'),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Future<void> _fetchNews({bool reset = false, bool force = false}) async {
    if (_isLoading || _isLoadingMore) {
      if (reset) {
        _refreshAfterCurrentLoad = true;
      }
      return;
    }

    final nextPage = reset ? 1 : _currentPage + 1;
    if (!reset && _currentPage >= _totalPages && _totalPages != 0) {
      return;
    }

    final dependencies = AppDependenciesScope.of(context);

    setState(() {
      if (reset) {
        _isLoading = true;
        _errorMessage = null;
        if (force || _articles.isNotEmpty) {
          _articles = const <NewsArticle>[];
        }
        _currentPage = 0;
        _totalPages = 0;
        _totalItems = 0;
      } else {
        _isLoadingMore = true;
      }
    });

    try {
      final response = await dependencies.newsRepository.getNews(
        page: nextPage,
        limit: _pageSize,
        source: _selectedSource.apiValue,
        keyword: _keyword,
        sortOrder: _sortOrder.apiValue,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _articles = reset
            ? response.items
            : <NewsArticle>[..._articles, ...response.items];
        _currentPage = response.meta.page;
        _totalPages = response.meta.totalPages;
        _totalItems = response.meta.total;
        _errorMessage = null;
      });
    } on AppFailure catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = error.message;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = '뉴스를 불러오지 못했습니다.';
      });
    } finally {
      if (mounted) {
        setState(() {
          if (reset) {
            _isLoading = false;
          } else {
            _isLoadingMore = false;
          }
        });
      }

      if (_refreshAfterCurrentLoad && mounted) {
        _refreshAfterCurrentLoad = false;
        unawaited(_fetchNews(reset: true, force: true));
      }
    }
  }

  void _handleKeywordChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) {
        return;
      }
      final nextKeyword = _searchController.text.trim();
      if (nextKeyword == _keyword) {
        return;
      }
      setState(() {
        _keyword = nextKeyword;
      });
      unawaited(_fetchNews(reset: true, force: true));
    });
  }

  void _updateSource(_NewsSourceFilter filter) {
    if (_selectedSource == filter) {
      return;
    }
    _searchDebounce?.cancel();
    setState(() {
      _selectedSource = filter;
      _keyword = _searchController.text.trim();
    });
    unawaited(_fetchNews(reset: true, force: true));
  }

  void _updateSortOrder(_NewsSortOrder sortOrder) {
    if (_sortOrder == sortOrder) {
      return;
    }
    _searchDebounce?.cancel();
    setState(() {
      _sortOrder = sortOrder;
      _keyword = _searchController.text.trim();
    });
    unawaited(_fetchNews(reset: true, force: true));
  }

  String _buildMetaText() {
    if (_isLoading && _articles.isEmpty) {
      return '뉴스를 불러오는 중입니다.';
    }
    if (_totalItems == 0) {
      return '총 0건';
    }
    return '총 $_totalItems건 · ${_currentPage == 0 ? 1 : _currentPage}/$_totalPages 페이지';
  }

  Future<void> _openArticle(NewsArticle article) {
    return openNewsArticle(context, article);
  }
}

enum _NewsSourceFilter {
  all(label: '전체', apiValue: null),
  lolEsports(label: 'LoL Esports', apiValue: 'LOLESPORTS'),
  naverEsports(label: '네이버 e스포츠', apiValue: 'NAVER_ESPORTS');

  const _NewsSourceFilter({required this.label, required this.apiValue});

  final String label;
  final String? apiValue;
}

enum _NewsSortOrder {
  desc(label: '최신순', apiValue: 'desc'),
  asc(label: '오래된순', apiValue: 'asc');

  const _NewsSortOrder({required this.label, required this.apiValue});

  final String label;
  final String apiValue;
}

class _FilterSection extends StatelessWidget {
  const _FilterSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: children),
      ],
    );
  }
}

class _ChoiceFilterChip extends StatelessWidget {
  const _ChoiceFilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      backgroundColor: AppColors.surface,
      selectedColor: AppColors.accent.withValues(alpha: 0.14),
      side: BorderSide(
        color: selected
            ? AppColors.accent.withValues(alpha: 0.36)
            : AppColors.divider,
      ),
      labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: selected ? AppColors.accent : AppColors.textSecondary,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
      ),
      onSelected: (_) => onSelected(),
    );
  }
}

class _NewsStatusCard extends StatelessWidget {
  const _NewsStatusCard({
    required this.message,
    this.actionLabel,
    this.onActionTap,
  });

  final String message;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          if (actionLabel != null) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: onActionTap,
              child: Text(
                actionLabel!,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
