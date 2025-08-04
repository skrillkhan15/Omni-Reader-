import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_providers.dart';
import '../models/reading_item.dart';
import '../widgets/reading_item_card.dart';
import '../widgets/reading_item_list_tile.dart' as list_tile;

class SearchScreen extends ConsumerStatefulWidget {
  final String? initialQuery;

  const SearchScreen({super.key, this.initialQuery});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TextEditingController _searchController;
  late AnimationController _filterAnimationController;
  late Animation<double> _filterAnimation;

  bool _showFilters = false;
  bool _isSearching = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery);

    _filterAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _filterAnimation = CurvedAnimation(
      parent: _filterAnimationController,
      curve: Curves.easeInOut,
    );

    // Set initial search query if provided
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(searchQueryProvider.notifier).state = widget.initialQuery!;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _filterAnimationController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    ref.read(searchQueryProvider.notifier).state = query;
    setState(() {
      _isSearching = query.isNotEmpty;
    });
  }

  void _toggleFilters() {
    setState(() {
      _showFilters = !_showFilters;
    });

    if (_showFilters) {
      _filterAnimationController.forward();
    } else {
      _filterAnimationController.reverse();
    }
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(searchQueryProvider.notifier).state = '';
    setState(() {
      _isSearching = false;
    });
  }

  void _clearAllFilters() {
    ref.read(selectedTypesProvider.notifier).state = {};
    ref.read(selectedStatusesProvider.notifier).state = {};
    ref.read(selectedGenresProvider.notifier).state = {};
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final searchQuery = ref.watch(searchQueryProvider);
    final filteredItemsAsync = ref.watch(filteredReadingItemsProvider);
    final viewMode = ref.watch(viewModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          onChanged: _onSearchChanged,
          decoration: InputDecoration(
            hintText: 'Search manga, manhwa, manhua...',
            border: InputBorder.none,
            hintStyle: TextStyle(
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          style: theme.textTheme.titleMedium,
          autofocus: widget.initialQuery == null,
        ),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        actions: [
          if (_isSearching)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearSearch,
              tooltip: 'Clear search',
            ),
          IconButton(
            icon: Icon(
              _showFilters ? Icons.filter_list : Icons.filter_list_outlined,
              color: _showFilters ? colorScheme.primary : null,
            ),
            onPressed: _toggleFilters,
            tooltip: 'Filters',
          ),
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
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters section
          AnimatedBuilder(
            animation: _filterAnimation,
            builder: (context, child) {
              return SizeTransition(
                sizeFactor: _filterAnimation,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant.withOpacity(0.5),
                    border: Border(
                      bottom: BorderSide(
                        color: colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                  ),
                  child: _buildFiltersSection(),
                ),
              );
            },
          ),

          // Search results
          Expanded(
            child: _buildSearchResults(filteredItemsAsync, searchQuery),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersSection() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final selectedTypes = ref.watch(selectedTypesProvider);
    final selectedStatuses = ref.watch(selectedStatusesProvider);
    final selectedGenres = ref.watch(selectedGenresProvider);
    final sortOption = ref.watch(sortOptionProvider);
    final sortAscending = ref.watch(sortAscendingProvider);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter header
          Row(
            children: [
              Text(
                'Filters',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: _clearAllFilters,
                child: const Text('Clear All'),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Type filter
          _buildFilterSection(
            'Type',
            ReadingType.values.map((type) => type.displayName).toList(),
            selectedTypes,
            (selected) {
              ref.read(selectedTypesProvider.notifier).state = selected;
            },
          ),

          const SizedBox(height: 16),

          // Status filter
          _buildFilterSection(
            'Status',
            ReadingStatus.values.map((status) => status.displayName).toList(),
            selectedStatuses,
            (selected) {
              ref.read(selectedStatusesProvider.notifier).state = selected;
            },
          ),

          const SizedBox(height: 16),

          // Genre filter
          _buildGenreFilter(),

          const SizedBox(height: 16),

          // Sort options
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<SortOption>(
                  value: sortOption,
                  decoration: InputDecoration(
                    labelText: 'Sort by',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: SortOption.values.map((option) {
                    return DropdownMenuItem(
                      value: option,
                      child: Text(option.displayName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(sortOptionProvider.notifier).state = value;
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: Icon(
                  sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                ),
                onPressed: () {
                  ref.read(sortAscendingProvider.notifier).state = !sortAscending;
                },
                tooltip: sortAscending ? 'Ascending' : 'Descending',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(
    String title,
    List<String> options,
    Set<String> selected,
    Function(Set<String>) onChanged,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: options.map((option) {
            final isSelected = selected.contains(option);
            return FilterChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (isSelected) {
                final newSelected = Set<String>.from(selected);
                if (isSelected) {
                  newSelected.add(option);
                } else {
                  newSelected.remove(option);
                }
                onChanged(newSelected);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildGenreFilter() {
    final theme = Theme.of(context);
    final selectedGenres = ref.watch(selectedGenresProvider);
    final allItemsAsync = ref.watch(readingItemsProvider);

    return allItemsAsync.when(
      data: (items) {
        final allGenres = items
            .expand((item) => item.genres)
            .toSet()
            .toList()
          ..sort();

        if (allGenres.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Genres',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: allGenres.map((genre) {
                final isSelected = selectedGenres.contains(genre);
                return FilterChip(
                  label: Text(genre),
                  selected: isSelected,
                  onSelected: (selected) {
                    final newSelected = Set<String>.from(selectedGenres);
                    if (selected) {
                      newSelected.add(genre);
                    } else {
                      newSelected.remove(genre);
                    }
                    ref.read(selectedGenresProvider.notifier).state = newSelected;
                  },
                );
              }).toList(),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildSearchResults(
    AsyncValue<List<ReadingItem>> filteredItemsAsync,
    String searchQuery,
  ) {
    return filteredItemsAsync.when(
      data: (items) {
        if (searchQuery.isEmpty && !_hasActiveFilters()) {
          return _buildSearchSuggestions();
        }

        if (items.isEmpty) {
          return _buildNoResults(searchQuery);
        }

        return _buildResultsList(items);
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
            Text('Error searching items: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.invalidate(filteredReadingItemsProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSuggestions() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final recentlyAddedAsync = ref.watch(recentlyAddedProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search tips
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Search Tips',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildSearchTip('Search by title, author, or genre'),
                  _buildSearchTip('Use filters to narrow down results'),
                  _buildSearchTip('Long press items to select multiple'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Quick search suggestions
          Text(
            'Quick Search',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildQuickSearchChip('Reading', () {
                ref.read(selectedStatusesProvider.notifier).state = {ReadingStatus.reading.displayName};
              }),
              _buildQuickSearchChip('Completed', () {
                ref.read(selectedStatusesProvider.notifier).state = {ReadingStatus.completed.displayName};
              }),
              _buildQuickSearchChip('Favorites', () {
                _searchController.text = '';
                ref.read(searchQueryProvider.notifier).state = '';
                // Navigate to favorites tab in library
                context.go('/library?type=favorites');
              }),
              _buildQuickSearchChip('Manga', () {
                ref.read(selectedTypesProvider.notifier).state = {ReadingType.manga.displayName};
              }),
              _buildQuickSearchChip('Manhwa', () {
                ref.read(selectedTypesProvider.notifier).state = {ReadingType.manhwa.displayName};
              }),
              _buildQuickSearchChip('Manhua', () {
                ref.read(selectedTypesProvider.notifier).state = {ReadingType.manhua.displayName};
              }),
            ],
          ),

          const SizedBox(height: 24),

          // Recently added
          recentlyAddedAsync.when(
            data: (items) {
              if (items.isNotEmpty) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recently Added',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          return Container(
                            width: 140,
                            margin: EdgeInsets.only(
                              right: index < items.length - 1 ? 12 : 0,
                            ),
                            child: ReadingItemCard(
                              item: items[index],
                              onTap: () => context.push('/item/${items[index].id}', extra: items[index]),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchTip(String tip) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            Icons.circle,
            size: 6,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tip,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSearchChip(String label, VoidCallback onTap) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      backgroundColor: colorScheme.primaryContainer,
      labelStyle: TextStyle(
        color: colorScheme.onPrimaryContainer,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildNoResults(String query) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              query.isNotEmpty
                  ? 'No items match "$query"'
                  : 'No items match your filters',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (query.isNotEmpty)
                  OutlinedButton(
                    onPressed: _clearSearch,
                    child: const Text('Clear Search'),
                  ),
                if (query.isNotEmpty && _hasActiveFilters())
                  const SizedBox(width: 12),
                if (_hasActiveFilters())
                  OutlinedButton(
                    onPressed: _clearAllFilters,
                    child: const Text('Clear Filters'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsList(List<ReadingItem> items) {
    final viewMode = ref.watch(viewModeProvider);

    return AnimationLimiter(
      child: viewMode == ViewMode.grid
          ? GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return AnimationConfiguration.staggeredGrid(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  columnCount: 2,
                  child: ScaleAnimation(
                    child: FadeInAnimation(
                      child: ReadingItemCard(
                        item: items[index],
                        onTap: () => context.push('/item/${items[index].id}', extra: items[index]),
                      ),
                    ),
                  ),
                );
              },
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: list_tile.ReadingItemListTile(
                        item: items[index],
                        onTap: () => context.push('/item/${items[index].id}', extra: items[index]),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  bool _hasActiveFilters() {
    final selectedTypes = ref.read(selectedTypesProvider);
    final selectedStatuses = ref.read(selectedStatusesProvider);
    final selectedGenres = ref.read(selectedGenresProvider);

    return selectedTypes.isNotEmpty ||
           selectedStatuses.isNotEmpty ||
           selectedGenres.isNotEmpty;
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
}
