import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_providers.dart';
import '../models/reading_item.dart';
import '../widgets/reading_item_card.dart';
import '../widgets/section_header.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  final String? initialType;

  const LibraryScreen({super.key, this.initialType});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;

  @override
  bool get wantKeepAlive => true;

  final List<Tab> _tabs = [
    const Tab(text: 'All', icon: Icon(Icons.library_books)),
    const Tab(text: 'Manga', icon: Icon(Icons.book)),
    const Tab(text: 'Manhwa', icon: Icon(Icons.auto_stories)),
    const Tab(text: 'Manhua', icon: Icon(Icons.menu_book)),
    const Tab(text: 'Favorites', icon: Icon(Icons.favorite)),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _scrollController.addListener(_onScroll);

    // Set initial tab based on type
    if (widget.initialType != null) {
      switch (widget.initialType!.toLowerCase()) {
        case 'manga':
          _tabController.index = 1;
          break;
        case 'manhwa':
          _tabController.index = 2;
          break;
        case 'manhua':
          _tabController.index = 3;
          break;
        case 'favorites':
          _tabController.index = 4;
          break;
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final showScrollToTop = _scrollController.offset > 200;
    if (showScrollToTop != _showScrollToTop) {
      setState(() {
        _showScrollToTop = showScrollToTop;
      });
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final viewMode = ref.watch(viewModeProvider);

    return Scaffold(
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            // App Bar
            SliverAppBar(
              title: const Text('Library'),
              floating: true,
              pinned: true,
              snap: true,
              backgroundColor: colorScheme.surface,
              foregroundColor: colorScheme.onSurface,
              actions: [
                // Search button
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => context.push('/search'),
                  tooltip: 'Search',
                ),
                // View mode toggle
                PopupMenuButton<ViewMode>(
                  icon: Icon(_getViewModeIcon(viewMode)),
                  onSelected: (mode) {
                    ref.read(viewModeProvider.notifier).state = mode;
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: ViewMode.grid,
                      child: Row(
                        children: [
                          Icon(Icons.grid_view, size: 20),
                          const SizedBox(width: 8),
                          const Text('Grid'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: ViewMode.list,
                      child: Row(
                        children: [
                          Icon(Icons.view_list, size: 20),
                          const SizedBox(width: 8),
                          const Text('List'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: ViewMode.card,
                      child: Row(
                        children: [
                          Icon(Icons.view_agenda, size: 20),
                          const SizedBox(width: 8),
                          const Text('Card'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: ViewMode.compact,
                      child: Row(
                        children: [
                          Icon(Icons.view_compact, size: 20),
                          const SizedBox(width: 8),
                          const Text('Compact'),
                        ],
                      ),
                    ),
                  ],
                ),
                // More options
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: Row(
                        children: [
                          Icon(Icons.sort, size: 20),
                          const SizedBox(width: 8),
                          const Text('Sort'),
                        ],
                      ),
                      onTap: () => _showSortDialog(),
                    ),
                    PopupMenuItem(
                      child: Row(
                        children: [
                          Icon(Icons.filter_list, size: 20),
                          const SizedBox(width: 8),
                          const Text('Filter'),
                        ],
                      ),
                      onTap: () => _showFilterDialog(),
                    ),
                    PopupMenuItem(
                      child: Row(
                        children: [
                          Icon(Icons.select_all, size: 20),
                          const SizedBox(width: 8),
                          const Text('Select All'),
                        ],
                      ),
                      onTap: () => _selectAll(),
                    ),
                  ],
                ),
              ],
              bottom: TabBar(
                controller: _tabController,
                tabs: _tabs,
                isScrollable: true,
                indicatorColor: colorScheme.primary,
                labelColor: colorScheme.primary,
                unselectedLabelColor: colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildAllItemsTab(),
            _buildMangaTab(),
            _buildManhwaTab(),
            _buildManhuaTab(),
            _buildFavoritesTab(),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (_showScrollToTop)
            FloatingActionButton.small(
              onPressed: _scrollToTop,
              heroTag: 'scroll_to_top',
              backgroundColor: colorScheme.surfaceVariant,
              foregroundColor: colorScheme.onSurfaceVariant,
              child: const Icon(Icons.keyboard_arrow_up),
            ),
          if (_showScrollToTop) const SizedBox(height: 8),
          FloatingActionButton.extended(
            onPressed: () => context.push('/add'),
            icon: const Icon(Icons.add),
            label: const Text('Add Item'),
            heroTag: 'add_item',
          ),
        ],
      ),
    );
  }

  Widget _buildAllItemsTab() {
    final filteredItemsAsync = ref.watch(filteredReadingItemsProvider);
    final selectedItems = ref.watch(selectedItemsProvider);
    final isSelectionMode = ref.watch(isSelectionModeProvider);

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(readingItemsProvider.notifier).refresh();
      },
      child: filteredItemsAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return _buildEmptyState(
              'No items in your library',
              'Start building your collection by adding your first item.',
              Icons.library_books,
            );
          }

          return Column(
            children: [
              // Selection toolbar
              if (isSelectionMode) _buildSelectionToolbar(),

              // Items
              Expanded(
                child: _buildItemsList(items, selectedItems, isSelectionMode),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text('Error loading items: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(readingItemsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMangaTab() {
    final mangaItemsAsync = ref.watch(mangaItemsProvider);
    return _buildTypeTab(mangaItemsAsync, 'manga');
  }

  Widget _buildManhwaTab() {
    final manhwaItemsAsync = ref.watch(manhwaItemsProvider);
    return _buildTypeTab(manhwaItemsAsync, 'manhwa');
  }

  Widget _buildManhuaTab() {
    final manhuaItemsAsync = ref.watch(manhuaItemsProvider);
    return _buildTypeTab(manhuaItemsAsync, 'manhua');
  }

  Widget _buildFavoritesTab() {
    final favoriteItemsAsync = ref.watch(favoriteItemsProvider);
    return _buildTypeTab(favoriteItemsAsync, 'favorites');
  }

  Widget _buildTypeTab(AsyncValue<List<ReadingItem>> itemsAsync, String type) {
    final selectedItems = ref.watch(selectedItemsProvider);
    final isSelectionMode = ref.watch(isSelectionModeProvider);

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(readingItemsProvider.notifier).refresh();
      },
      child: itemsAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return _buildEmptyState(
              'No ${type} items',
              'Add some ${type} to see them here.',
              _getTypeIcon(type),
            );
          }

          return Column(
            children: [
              // Selection toolbar
              if (isSelectionMode) _buildSelectionToolbar(),

              // Items
              Expanded(
                child: _buildItemsList(items, selectedItems, isSelectionMode),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading ${type} items: $error'),
        ),
      ),
    );
  }

  Widget _buildItemsList(
    List<ReadingItem> items,
    Set<String> selectedItems,
    bool isSelectionMode,
  ) {
    final viewMode = ref.watch(viewModeProvider);

    switch (viewMode) {
      case ViewMode.grid:
        return _buildGridView(items, selectedItems, isSelectionMode);
      case ViewMode.list:
        return _buildListView(items, selectedItems, isSelectionMode);
      case ViewMode.card:
        return _buildCardView(items, selectedItems, isSelectionMode);
      case ViewMode.compact:
        return _buildCompactView(items, selectedItems, isSelectionMode);
    }
  }

  Widget _buildGridView(
    List<ReadingItem> items,
    Set<String> selectedItems,
    bool isSelectionMode,
  ) {
    return AnimationLimiter(
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final isSelected = selectedItems.contains(item.id);

          return AnimationConfiguration.staggeredGrid(
            position: index,
            duration: const Duration(milliseconds: 375),
            columnCount: 2,
            child: ScaleAnimation(
              child: FadeInAnimation(
                child: ReadingItemCard(
                  item: item,
                  isSelected: isSelected,
                  onTap: () => _onItemTap(item, isSelectionMode),
                  onLongPress: () => _onItemLongPress(item),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildListView(
    List<ReadingItem> items,
    Set<String> selectedItems,
    bool isSelectionMode,
  ) {
    return AnimationLimiter(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final isSelected = selectedItems.contains(item.id);

          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: ReadingItemListTile(
                  item: item,
                  isSelected: isSelected,
                  onTap: () => _onItemTap(item, isSelectionMode),
                  onLongPress: () => _onItemLongPress(item),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardView(
    List<ReadingItem> items,
    Set<String> selectedItems,
    bool isSelectionMode,
  ) {
    return AnimationLimiter(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final isSelected = selectedItems.contains(item.id);

          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  height: 200,
                  child: ReadingItemCard(
                    item: item,
                    isSelected: isSelected,
                    onTap: () => _onItemTap(item, isSelectionMode),
                    onLongPress: () => _onItemLongPress(item),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCompactView(
    List<ReadingItem> items,
    Set<String> selectedItems,
    bool isSelectionMode,
  ) {
    return AnimationLimiter(
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.6,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final isSelected = selectedItems.contains(item.id);

          return AnimationConfiguration.staggeredGrid(
            position: index,
            duration: const Duration(milliseconds: 375),
            columnCount: 3,
            child: ScaleAnimation(
              child: FadeInAnimation(
                child: ReadingItemCard(
                  item: item,
                  isSelected: isSelected,
                  showProgress: false,
                  showRating: false,
                  showGenres: false,
                  onTap: () => _onItemTap(item, isSelectionMode),
                  onLongPress: () => _onItemLongPress(item),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSelectionToolbar() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final selectedItems = ref.watch(selectedItemsProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            '${selectedItems.length} selected',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () => _toggleFavoriteSelected(),
            tooltip: 'Toggle Favorite',
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editSelected(),
            tooltip: 'Edit',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deleteSelected(),
            tooltip: 'Delete',
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => _clearSelection(),
            tooltip: 'Clear Selection',
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.push('/add'),
              icon: const Icon(Icons.add),
              label: const Text('Add Item'),
            ),
          ],
        ),
      ),
    );
  }

  void _onItemTap(ReadingItem item, bool isSelectionMode) {
    if (isSelectionMode) {
      _toggleItemSelection(item.id);
    } else {
      context.push('/item/${item.id}', extra: item);
    }
  }

  void _onItemLongPress(ReadingItem item) {
    _toggleItemSelection(item.id);
  }

  void _toggleItemSelection(String itemId) {
    final selectedItems = ref.read(selectedItemsProvider);
    final newSelection = Set<String>.from(selectedItems);

    if (newSelection.contains(itemId)) {
      newSelection.remove(itemId);
    } else {
      newSelection.add(itemId);
    }

    ref.read(selectedItemsProvider.notifier).state = newSelection;
  }

  void _selectAll() {
    final items = ref.read(filteredReadingItemsProvider).value ?? [];
    final allIds = items.map((item) => item.id).toSet();
    ref.read(selectedItemsProvider.notifier).state = allIds;
  }

  void _clearSelection() {
    ref.read(selectedItemsProvider.notifier).state = {};
  }

  void _toggleFavoriteSelected() async {
    final selectedItems = ref.read(selectedItemsProvider);
    for (final itemId in selectedItems) {
      await ref.read(readingItemsProvider.notifier).toggleFavorite(itemId);
    }
    _clearSelection();
  }

  void _editSelected() {
    final selectedItems = ref.read(selectedItemsProvider);
    if (selectedItems.length == 1) {
      final itemId = selectedItems.first;
      final items = ref.read(readingItemsProvider).value ?? [];
      final item = items.firstWhere((item) => item.id == itemId);
      context.push('/edit/${item.id}', extra: item);
    }
    _clearSelection();
  }

  void _deleteSelected() async {
    final selectedItems = ref.read(selectedItemsProvider);
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Items'),
        content: Text(
          'Are you sure you want to delete ${selectedItems.length} item(s)? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      for (final itemId in selectedItems) {
        await ref.read(readingItemsProvider.notifier).deleteItem(itemId);
      }
      _clearSelection();
    }
  }

  void _showSortDialog() {
    // Implementation for sort dialog
  }

  void _showFilterDialog() {
    // Implementation for filter dialog
  }

  IconData _getViewModeIcon(ViewMode mode) {
    switch (mode) {
      case ViewMode.grid:
        return Icons.grid_view;
      case ViewMode.list:
        return Icons.view_list;
      case ViewMode.card:
        return Icons.view_agenda;
      case ViewMode.compact:
        return Icons.view_compact;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'manga':
        return Icons.book;
      case 'manhwa':
        return Icons.auto_stories;
      case 'manhua':
        return Icons.menu_book;
      case 'favorites':
        return Icons.favorite;
      default:
        return Icons.library_books;
    }
  }
}

