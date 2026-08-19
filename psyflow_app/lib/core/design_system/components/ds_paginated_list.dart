/// Design System Paginated List Component
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../tokens/tokens.dart';

typedef PaginatedItemBuilder<T> = Widget Function(BuildContext context, T item, int index);
typedef PaginatedFetcher<T> = Future<List<T>> Function({int limit, DocumentSnapshot? startAfter});
typedef PaginatedEmptyBuilder = Widget Function(BuildContext context);
typedef PaginatedErrorBuilder = Widget Function(BuildContext context, String error, VoidCallback onRetry);

class DSPaginatedList<T> extends StatefulWidget {
  final PaginatedFetcher<T> fetcher;
  final PaginatedItemBuilder<T> itemBuilder;
  final PaginatedEmptyBuilder? emptyBuilder;
  final PaginatedErrorBuilder? errorBuilder;
  final int pageSize;
  final bool enablePullToRefresh;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;

  const DSPaginatedList({
    super.key,
    required this.fetcher,
    required this.itemBuilder,
    this.emptyBuilder,
    this.errorBuilder,
    this.pageSize = 20,
    this.enablePullToRefresh = true,
    this.padding,
    this.physics,
    this.shrinkWrap = false,
  });

  @override
  State<DSPaginatedList<T>> createState() => _DSPaginatedListState<T>();
}

class _DSPaginatedListState<T> extends State<DSPaginatedList<T>> {
  final List<T> _items = [];
  DocumentSnapshot? _lastDocument;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _error;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadInitial();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitial() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final items = await widget.fetcher(limit: widget.pageSize);
      _items.clear();
      _items.addAll(items);
      _hasMore = items.length >= widget.pageSize;
      _lastDocument = null; // Would need to be tracked from the query
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() => _isLoadingMore = true);

    try {
      // Note: In a real implementation, you'd pass _lastDocument to fetcher
      final items = await widget.fetcher(
        limit: widget.pageSize,
        startAfter: _lastDocument,
      );
      
      if (items.isEmpty) {
        _hasMore = false;
      } else {
        _items.addAll(items);
        _hasMore = items.length >= widget.pageSize;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) {
        setState(() => _isLoadingMore = false);
      }
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _onRefresh() async {
    await _loadInitial();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DSLoading.large(),
            if (_items.isEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                'Carregando...',
                style: AppTypography.bodyMedium.copyWith(
                  color: isDark ? Colors.white.withOpacity(0.7) : AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      );
    }

    if (_error != null && _items.isEmpty) {
      return Center(
        child: DSEmptyState.error(
          title: 'Erro ao carregar',
          subtitle: _error!,
          action: DSButton(
            label: 'Tentar novamente',
            variant: DSButtonVariant.outlined,
            onPressed: _loadInitial,
          ),
        ),
      );
    }

    if (_items.isEmpty) {
      return Center(
        child: widget.emptyBuilder?.call(context) ??
            DSEmptyState.noData(),
      );
    }

    final listView = ListView.separated(
      controller: _scrollController,
      padding: widget.padding,
      physics: widget.physics,
      shrinkWrap: widget.shrinkWrap,
      itemCount: _items.length + (_hasMore || _isLoadingMore ? 1 : 0),
      separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        if (index >= _items.length) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: DSLoading.small(),
            ),
          );
        }
        return widget.itemBuilder(context, _items[index], index);
      },
    );

    if (widget.enablePullToRefresh) {
      return RefreshIndicator(
        onRefresh: _onRefresh,
        color: AppColors.primary,
        child: listView,
      );
    }

    return listView;
  }
}

/// Stream-based paginated list for real-time updates
class DSStreamPaginatedList<T> extends StatefulWidget {
  final Stream<List<T>> stream;
  final PaginatedItemBuilder<T> itemBuilder;
  final PaginatedEmptyBuilder? emptyBuilder;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;

  const DSStreamPaginatedList({
    super.key,
    required this.stream,
    required this.itemBuilder,
    this.emptyBuilder,
    this.padding,
    this.physics,
    this.shrinkWrap = false,
  });

  @override
  State<DSStreamPaginatedList<T>> createState() => _DSStreamPaginatedListState<T>();
}

class _DSStreamPaginatedListState<T> extends State<DSStreamPaginatedList<T>> {
  String? _error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return StreamBuilder<List<T>>(
      stream: widget.stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DSLoading.large(),
                if (!snapshot.hasData) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Carregando...',
                    style: AppTypography.bodyMedium.copyWith(
                      color: isDark ? Colors.white.withOpacity(0.7) : AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          );
        }

        if (snapshot.hasError) {
          _error = snapshot.error.toString();
          return Center(
            child: DSEmptyState.error(
              title: 'Erro ao carregar',
              subtitle: _error!,
              action: DSButton(
                label: 'Tentar novamente',
                variant: DSButtonVariant.outlined,
                onPressed: () => setState(() {}),
              ),
            ),
          );
        }

        final items = snapshot.data ?? [];

        if (items.isEmpty) {
          return Center(
            child: widget.emptyBuilder?.call(context) ??
                DSEmptyState.noData(),
          );
        }

        return ListView.separated(
          padding: widget.padding,
          physics: widget.physics,
          shrinkWrap: widget.shrinkWrap,
          itemCount: items.length,
          separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, index) {
            return widget.itemBuilder(context, items[index], index);
          },
        );
      },
    );
  }
}