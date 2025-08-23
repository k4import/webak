import 'package:flutter/material.dart';
import 'package:webak/core/theme/app_theme.dart';
import 'package:webak/shared/widgets/app_loader.dart';

/// Paginated ListView with lazy loading and infinite scroll
/// Provides efficient memory usage and smooth scrolling experience
class PaginatedListView<T> extends StatefulWidget {
  final Future<List<T>> Function(int page, int limit) onLoadMore;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Widget Function(BuildContext context)? emptyBuilder;
  final Widget Function(BuildContext context)? loadingBuilder;
  final Widget Function(BuildContext context, String error)? errorBuilder;
  final int itemsPerPage;
  final double loadMoreThreshold;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;
  final Widget? separator;
  final bool reverse;
  final ScrollController? controller;
  final String? emptyMessage;
  final String? errorMessage;

  const PaginatedListView({
    super.key,
    required this.onLoadMore,
    required this.itemBuilder,
    this.emptyBuilder,
    this.loadingBuilder,
    this.errorBuilder,
    this.itemsPerPage = 20,
    this.loadMoreThreshold = 200.0,
    this.shrinkWrap = false,
    this.physics,
    this.padding,
    this.separator,
    this.reverse = false,
    this.controller,
    this.emptyMessage,
    this.errorMessage,
  });

  @override
  State<PaginatedListView<T>> createState() => _PaginatedListViewState<T>();
}

class _PaginatedListViewState<T> extends State<PaginatedListView<T>> {
  final List<T> _items = [];
  late ScrollController _scrollController;
  
  bool _isLoading = false;
  bool _hasMore = true;
  bool _hasError = false;
  String? _errorMessage;
  int _currentPage = 1;
  
  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
    _scrollController.addListener(_onScroll);
    _loadInitialData();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _scrollController.dispose();
    } else {
      _scrollController.removeListener(_onScroll);
    }
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - widget.loadMoreThreshold) {
      _loadMore();
    }
  }

  Future<void> _loadInitialData() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      final newItems = await widget.onLoadMore(1, widget.itemsPerPage);
      
      if (mounted) {
        setState(() {
          _items.clear();
          _items.addAll(newItems);
          _currentPage = 1;
          _hasMore = newItems.length >= widget.itemsPerPage;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadMore() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final newItems = await widget.onLoadMore(_currentPage + 1, widget.itemsPerPage);
      
      if (mounted) {
        setState(() {
          _items.addAll(newItems);
          _currentPage++;
          _hasMore = newItems.length >= widget.itemsPerPage;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          // Don't show error for load more, just stop loading
        });
      }
    }
  }

  Future<void> refresh() async {
    await _loadInitialData();
  }

  @override
  Widget build(BuildContext context) {
    // Error state
    if (_hasError && _items.isEmpty) {
      return widget.errorBuilder?.call(context, _errorMessage ?? 'حدث خطأ') ??
          _buildDefaultError();
    }

    // Loading state (initial)
    if (_isLoading && _items.isEmpty) {
      return widget.loadingBuilder?.call(context) ?? _buildDefaultLoading();
    }

    // Empty state
    if (_items.isEmpty && !_isLoading) {
      return widget.emptyBuilder?.call(context) ?? _buildDefaultEmpty();
    }

    // List with items
    return RefreshIndicator(
      onRefresh: refresh,
      child: ListView.separated(
        controller: _scrollController,
        shrinkWrap: widget.shrinkWrap,
        physics: widget.physics,
        padding: widget.padding,
        reverse: widget.reverse,
        itemCount: _items.length + (_hasMore || _isLoading ? 1 : 0),
        separatorBuilder: (context, index) {
          if (index >= _items.length) return const SizedBox.shrink();
          return widget.separator ?? const SizedBox.shrink();
        },
        itemBuilder: (context, index) {
          // Loading indicator at the end
          if (index >= _items.length) {
            return _buildLoadMoreIndicator();
          }

          return widget.itemBuilder(context, _items[index], index);
        },
      ),
    );
  }

  Widget _buildDefaultLoading() {
    return const Center(
      child: AppLoader(
        message: 'جاري التحميل...',
      ),
    );
  }

  Widget _buildDefaultEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: AppTheme.md),
          Text(
            widget.emptyMessage ?? 'لا توجد عناصر',
            style: AppTheme.body1.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.shade400,
          ),
          const SizedBox(height: AppTheme.md),
          Text(
            widget.errorMessage ?? _errorMessage ?? 'حدث خطأ',
            style: AppTheme.body1.copyWith(
              color: Colors.red.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.md),
          ElevatedButton(
            onPressed: _loadInitialData,
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.all(AppTheme.md),
        alignment: Alignment.center,
        child: const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (!_hasMore) {
      return Container(
        padding: const EdgeInsets.all(AppTheme.md),
        alignment: Alignment.center,
        child: Text(
          'تم عرض جميع العناصر',
          style: AppTheme.caption.copyWith(
            color: Colors.grey.shade600,
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

/// Paginated Grid View with lazy loading
class PaginatedGridView<T> extends StatefulWidget {
  final Future<List<T>> Function(int page, int limit) onLoadMore;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Widget Function(BuildContext context)? emptyBuilder;
  final Widget Function(BuildContext context)? loadingBuilder;
  final Widget Function(BuildContext context, String error)? errorBuilder;
  final int itemsPerPage;
  final double loadMoreThreshold;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;
  final ScrollController? controller;
  final String? emptyMessage;
  final String? errorMessage;

  const PaginatedGridView({
    super.key,
    required this.onLoadMore,
    required this.itemBuilder,
    this.emptyBuilder,
    this.loadingBuilder,
    this.errorBuilder,
    this.itemsPerPage = 20,
    this.loadMoreThreshold = 200.0,
    this.shrinkWrap = false,
    this.physics,
    this.padding,
    this.crossAxisCount = 2,
    this.mainAxisSpacing = 8.0,
    this.crossAxisSpacing = 8.0,
    this.childAspectRatio = 1.0,
    this.controller,
    this.emptyMessage,
    this.errorMessage,
  });

  @override
  State<PaginatedGridView<T>> createState() => _PaginatedGridViewState<T>();
}

class _PaginatedGridViewState<T> extends State<PaginatedGridView<T>> {
  final List<T> _items = [];
  late ScrollController _scrollController;
  
  bool _isLoading = false;
  bool _hasMore = true;
  bool _hasError = false;
  String? _errorMessage;
  int _currentPage = 1;
  
  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
    _scrollController.addListener(_onScroll);
    _loadInitialData();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _scrollController.dispose();
    } else {
      _scrollController.removeListener(_onScroll);
    }
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - widget.loadMoreThreshold) {
      _loadMore();
    }
  }

  Future<void> _loadInitialData() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      final newItems = await widget.onLoadMore(1, widget.itemsPerPage);
      
      if (mounted) {
        setState(() {
          _items.clear();
          _items.addAll(newItems);
          _currentPage = 1;
          _hasMore = newItems.length >= widget.itemsPerPage;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadMore() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final newItems = await widget.onLoadMore(_currentPage + 1, widget.itemsPerPage);
      
      if (mounted) {
        setState(() {
          _items.addAll(newItems);
          _currentPage++;
          _hasMore = newItems.length >= widget.itemsPerPage;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> refresh() async {
    await _loadInitialData();
  }

  @override
  Widget build(BuildContext context) {
    // Error state
    if (_hasError && _items.isEmpty) {
      return _buildDefaultError();
    }

    // Loading state (initial)
    if (_isLoading && _items.isEmpty) {
      return _buildDefaultLoading();
    }

    // Empty state
    if (_items.isEmpty && !_isLoading) {
      return _buildDefaultEmpty();
    }

    // Grid with items
    return RefreshIndicator(
      onRefresh: refresh,
      child: CustomScrollView(
        controller: _scrollController,
        shrinkWrap: widget.shrinkWrap,
        physics: widget.physics,
        slivers: [
          SliverPadding(
            padding: widget.padding ?? EdgeInsets.zero,
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: widget.crossAxisCount,
                mainAxisSpacing: widget.mainAxisSpacing,
                crossAxisSpacing: widget.crossAxisSpacing,
                childAspectRatio: widget.childAspectRatio,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return widget.itemBuilder(context, _items[index], index);
                },
                childCount: _items.length,
              ),
            ),
          ),
          if (_hasMore || _isLoading)
            SliverToBoxAdapter(
              child: _buildLoadMoreIndicator(),
            ),
        ],
      ),
    );
  }

  Widget _buildDefaultLoading() {
    return const Center(
      child: AppLoader(
        message: 'جاري التحميل...',
      ),
    );
  }

  Widget _buildDefaultEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.grid_view_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: AppTheme.md),
          Text(
            widget.emptyMessage ?? 'لا توجد عناصر',
            style: AppTheme.body1.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.shade400,
          ),
          const SizedBox(height: AppTheme.md),
          Text(
            widget.errorMessage ?? _errorMessage ?? 'حدث خطأ',
            style: AppTheme.body1.copyWith(
              color: Colors.red.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.md),
          ElevatedButton(
            onPressed: _loadInitialData,
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.all(AppTheme.md),
        alignment: Alignment.center,
        child: const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (!_hasMore) {
      return Container(
        padding: const EdgeInsets.all(AppTheme.md),
        alignment: Alignment.center,
        child: Text(
          'تم عرض جميع العناصر',
          style: AppTheme.caption.copyWith(
            color: Colors.grey.shade600,
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}