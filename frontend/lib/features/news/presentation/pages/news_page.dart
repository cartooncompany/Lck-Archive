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
    if (_hasLoaded) {
      return;
    }
    _hasLoaded = true;
    unawaited(_fetchNews(reset: true));
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  bool get _hasActiveFilters {
    return _keyword.isNotEmpty ||
        _selectedSource != _NewsSourceFilter.all ||
        _sortOrder != _NewsSortOrder.desc;
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
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 920),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeroCard(context),
                  const SizedBox(height: 16),
                  _buildControlsCard(context),
                  const SizedBox(height: 20),
                  _buildResultsHeader(context),
                  const SizedBox(height: 12),
                  if (_errorMessage != null && _articles.isNotEmpty) ...[
                    _NewsStatusCard(
                      title: '불러오기에 일부 실패했습니다',
                      message: _errorMessage!,
                      icon: Icons.wifi_off_rounded,
                      actionLabel: '다시 시도',
                      onActionTap: () => _fetchNews(reset: true, force: true),
                      dense: true,
                    ),
                    const SizedBox(height: 12),
                  ],
                  _buildResults(context, hasMore),
                ],
              ),
            ),
          ),
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

  void _clearKeyword() {
    if (_keyword.isEmpty && _searchController.text.trim().isEmpty) {
      return;
    }
    _searchDebounce?.cancel();
    FocusManager.instance.primaryFocus?.unfocus();
    _searchController.clear();
    setState(() {
      _keyword = '';
    });
    unawaited(_fetchNews(reset: true, force: true));
  }

  void _resetFilters() {
    _searchDebounce?.cancel();
    FocusManager.instance.primaryFocus?.unfocus();
    _searchController.clear();
    setState(() {
      _keyword = '';
      _selectedSource = _NewsSourceFilter.all;
      _sortOrder = _NewsSortOrder.desc;
    });
    unawaited(_fetchNews(reset: true, force: true));
  }

  String _buildMetaText() {
    if (_isLoading && _articles.isEmpty) {
      return '선택한 조건의 최신 뉴스를 정리하고 있습니다.';
    }
    if (_articles.isEmpty) {
      return _hasActiveFilters ? '조건을 조정해 다시 탐색해 보세요.' : '표시할 뉴스가 없습니다.';
    }
    if (_totalPages <= 1) {
      return '총 $_totalItems건';
    }
    return '총 $_totalItems건 중 ${_articles.length}건 확인 중 · ${_currentPage == 0 ? 1 : _currentPage}/$_totalPages 페이지';
  }

  Future<void> _openArticle(NewsArticle article) {
    return openNewsArticle(context, article);
  }

  Widget _buildHeroCard(BuildContext context) {
    final subtitle = _keyword.isEmpty
        ? '팀, 선수, 기사 제목을 기준으로 빠르게 좁혀서 현재 LCK 흐름을 확인할 수 있습니다.'
        : '"$_keyword"와 관련된 기사 흐름을 정리하고 있습니다.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.divider),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.accentStrong.withValues(alpha: 0.24),
            AppColors.accent.withValues(alpha: 0.14),
            AppColors.surfaceElevated,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.textPrimary.withValues(alpha: 0.08),
                  ),
                ),
                child: const Icon(
                  Icons.newspaper_rounded,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LCK 뉴스 브리핑',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _NewsMetricPill(
                icon: Icons.article_outlined,
                label: '기사 수',
                value: _totalItems == 0 && _isLoading
                    ? '불러오는 중'
                    : '$_totalItems건',
              ),
              _NewsMetricPill(
                icon: Icons.hub_rounded,
                label: '소스',
                value: _selectedSource.label,
              ),
              _NewsMetricPill(
                icon: Icons.swap_vert_rounded,
                label: '정렬',
                value: _sortOrder.label,
              ),
              if (_keyword.isNotEmpty)
                _NewsMetricPill(
                  icon: Icons.search_rounded,
                  label: '검색어',
                  value: _keyword,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlsCard(BuildContext context) {
    final hasKeywordText =
        _keyword.isNotEmpty || _searchController.text.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '검색과 필터',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '소스와 정렬 기준을 조합해 원하는 기사 흐름만 남길 수 있습니다.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (_hasActiveFilters)
                OutlinedButton.icon(
                  onPressed: _resetFilters,
                  icon: const Icon(Icons.restart_alt_rounded, size: 18),
                  label: const Text('초기화'),
                ),
            ],
          ),
          const SizedBox(height: 16),
          AppSearchField(
            controller: _searchController,
            hintText: '팀명, 선수명, 기사 제목으로 검색',
            textInputAction: TextInputAction.search,
            suffixIcon: hasKeywordText
                ? IconButton(
                    tooltip: '검색어 지우기',
                    onPressed: _clearKeyword,
                    icon: const Icon(Icons.close_rounded),
                  )
                : null,
            onChanged: _handleKeywordChanged,
          ),
          if (_hasActiveFilters) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (_keyword.isNotEmpty)
                  _ActiveFilterPill(
                    icon: Icons.search_rounded,
                    label: _keyword,
                  ),
                if (_selectedSource != _NewsSourceFilter.all)
                  _ActiveFilterPill(
                    icon: Icons.hub_rounded,
                    label: _selectedSource.label,
                  ),
                if (_sortOrder != _NewsSortOrder.desc)
                  _ActiveFilterPill(
                    icon: Icons.swap_vert_rounded,
                    label: _sortOrder.label,
                  ),
              ],
            ),
          ],
          const SizedBox(height: 16),
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
          const SizedBox(height: 12),
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
        ],
      ),
    );
  }

  Widget _buildResultsHeader(BuildContext context) {
    final description = _articles.isNotEmpty
        ? '첫 번째 카드는 대표 기사로 강조하고, 이후 카드는 빠르게 훑을 수 있게 압축했습니다.'
        : '당겨서 새로고침하면 최신 상태를 다시 가져옵니다.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.view_agenda_rounded,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('결과 보기', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  _buildMetaText(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (_isLoadingMore)
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        ],
      ),
    );
  }

  Widget _buildResults(BuildContext context, bool hasMore) {
    if (_isLoading && _articles.isEmpty) {
      return const _NewsStatusCard(
        title: '뉴스를 불러오는 중입니다',
        message: '선택한 조건에 맞는 최신 기사를 정리하고 있습니다.',
        icon: Icons.newspaper_rounded,
      );
    }

    if (_errorMessage != null && _articles.isEmpty) {
      return _NewsStatusCard(
        title: '뉴스를 불러오지 못했습니다',
        message: _errorMessage!,
        icon: Icons.wifi_off_rounded,
        actionLabel: '다시 시도',
        onActionTap: () => _fetchNews(reset: true, force: true),
      );
    }

    if (_articles.isEmpty) {
      return _NewsStatusCard(
        title: '조건에 맞는 뉴스가 없습니다',
        message: _hasActiveFilters
            ? '검색어를 줄이거나 소스를 전체로 바꿔 보세요.'
            : '데이터가 비어 있다면 백엔드에서 수동 동기화를 먼저 요청해 주세요.',
        icon: Icons.filter_alt_off_rounded,
        actionLabel: _hasActiveFilters ? '필터 초기화' : null,
        onActionTap: _hasActiveFilters ? _resetFilters : null,
      );
    }

    final featuredArticle = _articles.first;
    final remainingArticles = _articles.skip(1).toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NewsArticleCard(
          article: featuredArticle,
          highlighted: true,
          onTap: () => _openArticle(featuredArticle),
        ),
        if (remainingArticles.isNotEmpty) ...[
          const SizedBox(height: 22),
          Text('추가 기사', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            '핵심만 빠르게 읽을 수 있도록 요약형 카드로 배치했습니다.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          ...remainingArticles.map(
            (article) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: NewsArticleCard(
                article: article,
                compact: true,
                onTap: () => _openArticle(article),
              ),
            ),
          ),
        ],
        if (hasMore || _isLoadingMore)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.divider),
              ),
              child: OutlinedButton.icon(
                onPressed: _isLoadingMore ? null : () => _fetchNews(),
                icon: _isLoadingMore
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.expand_more_rounded),
                label: Text(_isLoadingMore ? '불러오는 중...' : '기사 더 불러오기'),
              ),
            ),
          ),
      ],
    );
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
      backgroundColor: AppColors.surfaceMuted,
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
    required this.title,
    required this.message,
    required this.icon,
    this.actionLabel,
    this.onActionTap,
    this.dense = false,
  });

  final String title;
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onActionTap;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(dense ? 16 : 18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: dense ? 40 : 48,
            height: dense ? 40 : 48,
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 14),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
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

class _NewsMetricPill extends StatelessWidget {
  const _NewsMetricPill({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.textPrimary.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.textPrimary),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(color: AppColors.textPrimary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActiveFilterPill extends StatelessWidget {
  const _ActiveFilterPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.28)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.accent),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
