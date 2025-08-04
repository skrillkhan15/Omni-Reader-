import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_providers.dart';
import '../models/reading_item.dart';
import '../widgets/reading_item_card.dart';
import '../widgets/statistics_card.dart';
import '../widgets/quick_action_button.dart';
import '../widgets/section_header.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
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

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(readingItemsProvider.notifier).refresh();
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 120,
              floating: true,
              pinned: true,
              backgroundColor: colorScheme.surface,
              foregroundColor: colorScheme.onSurface,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'OmniReader',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colorScheme.primary.withOpacity(0.1),
                        colorScheme.secondary.withOpacity(0.1),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => context.push('/search'),
                  tooltip: 'Search',
                ),
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {
                    // Show notifications
                  },
                  tooltip: 'Notifications',
                ),
              ],
            ),

            // Content
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Welcome Section
                  _buildWelcomeSection(),
                  const SizedBox(height: 24),

                  // Quick Actions
                  _buildQuickActions(),
                  const SizedBox(height: 24),

                  // Statistics Overview
                  _buildStatisticsSection(),
                  const SizedBox(height: 24),

                  // Continue Reading
                  _buildContinueReadingSection(),
                  const SizedBox(height: 24),

                  // Recently Added
                  _buildRecentlyAddedSection(),
                  const SizedBox(height: 24),

                  // Reading Goals
                  _buildReadingGoalsSection(),
                  const SizedBox(height: 24),

                  // Recommendations
                  _buildRecommendationsSection(),
                  const SizedBox(height: 100), // Bottom padding for FAB
                ]),
              ),
            ),
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

  Widget _buildWelcomeSection() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final now = DateTime.now();
    final hour = now.hour;
    
    String greeting;
    IconData greetingIcon;
    
    if (hour < 12) {
      greeting = 'Good Morning';
      greetingIcon = Icons.wb_sunny;
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
      greetingIcon = Icons.wb_sunny_outlined;
    } else {
      greeting = 'Good Evening';
      greetingIcon = Icons.nights_stay;
    }

    return AnimationConfiguration.staggeredList(
      position: 0,
      duration: const Duration(milliseconds: 375),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      greetingIcon,
                      size: 32,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          greeting,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Ready to continue your reading journey?',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return AnimationConfiguration.staggeredList(
      position: 1,
      duration: const Duration(milliseconds: 375),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: Column(
            children: [
              SectionHeader(
                title: 'Quick Actions',
                onSeeAll: () {},
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: QuickActionButton(
                      icon: Icons.book,
                      label: 'Add Manga',
                      color: Colors.blue,
                      onTap: () => context.pushAddWithType('manga'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: QuickActionButton(
                      icon: Icons.auto_stories,
                      label: 'Add Manhwa',
                      color: Colors.pink,
                      onTap: () => context.pushAddWithType('manhwa'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: QuickActionButton(
                      icon: Icons.menu_book,
                      label: 'Add Manhua',
                      color: Colors.orange,
                      onTap: () => context.pushAddWithType('manhua'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: QuickActionButton(
                      icon: Icons.search,
                      label: 'Search',
                      color: Colors.green,
                      onTap: () => context.push('/search'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticsSection() {
    final statisticsAsync = ref.watch(statisticsProvider);

    return AnimationConfiguration.staggeredList(
      position: 2,
      duration: const Duration(milliseconds: 375),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: Column(
            children: [
              SectionHeader(
                title: 'Your Library',
                onSeeAll: () => context.push('/statistics'),
              ),
              const SizedBox(height: 12),
              statisticsAsync.when(
                data: (stats) => _buildStatisticsGrid(stats),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Text('Error loading statistics: $error'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticsGrid(Map<String, dynamic> stats) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        StatisticsCard(
          title: 'Total Items',
          value: stats['totalItems'].toString(),
          icon: Icons.library_books,
          color: Colors.blue,
        ),
        StatisticsCard(
          title: 'Completed',
          value: stats['completedItems'].toString(),
          icon: Icons.check_circle,
          color: Colors.green,
        ),
        StatisticsCard(
          title: 'Reading',
          value: stats['readingItems'].toString(),
          icon: Icons.auto_stories,
          color: Colors.orange,
        ),
        StatisticsCard(
          title: 'Favorites',
          value: stats['favoriteItems'].toString(),
          icon: Icons.favorite,
          color: Colors.red,
        ),
      ],
    );
  }

  Widget _buildContinueReadingSection() {
    final currentlyReadingAsync = ref.watch(currentlyReadingProvider);

    return AnimationConfiguration.staggeredList(
      position: 3,
      duration: const Duration(milliseconds: 375),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: Column(
            children: [
              SectionHeader(
                title: 'Continue Reading',
                onSeeAll: () => context.pushLibraryWithType('reading'),
              ),
              const SizedBox(height: 12),
              currentlyReadingAsync.when(
                data: (items) {
                  if (items.isEmpty) {
                    return _buildEmptyState(
                      'No items currently reading',
                      'Add some items to your reading list to see them here.',
                      Icons.auto_stories,
                    );
                  }
                  return _buildHorizontalItemList(items.take(5).toList());
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Text('Error loading reading items: $error'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentlyAddedSection() {
    final recentlyAddedAsync = ref.watch(recentlyAddedProvider);

    return AnimationConfiguration.staggeredList(
      position: 4,
      duration: const Duration(milliseconds: 375),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: Column(
            children: [
              SectionHeader(
                title: 'Recently Added',
                onSeeAll: () => context.push('/library'),
              ),
              const SizedBox(height: 12),
              recentlyAddedAsync.when(
                data: (items) {
                  if (items.isEmpty) {
                    return _buildEmptyState(
                      'No items added yet',
                      'Start building your library by adding your first item.',
                      Icons.add_circle_outline,
                    );
                  }
                  return _buildHorizontalItemList(items);
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Text('Error loading recent items: $error'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReadingGoalsSection() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimationConfiguration.staggeredList(
      position: 5,
      duration: const Duration(milliseconds: 375),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: Column(
            children: [
              SectionHeader(
                title: 'Reading Goals',
                onSeeAll: () => context.push('/statistics'),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.track_changes,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Daily Reading Goal',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '15 minutes of 30 minutes',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurface.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '50%',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: 0.5,
                        backgroundColor: colorScheme.surfaceVariant,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendationsSection() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimationConfiguration.staggeredList(
      position: 6,
      duration: const Duration(milliseconds: 375),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: Column(
            children: [
              SectionHeader(
                title: 'Recommendations',
                onSeeAll: () {},
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.psychology,
                            color: colorScheme.secondary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'AI Recommendations',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'Enable AI features to get personalized recommendations',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurface.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => context.push('/settings'),
                        child: const Text('Enable AI Features'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHorizontalItemList(List<ReadingItem> items) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              horizontalOffset: 50.0,
              child: FadeInAnimation(
                child: Container(
                  width: 140,
                  margin: EdgeInsets.only(
                    right: index < items.length - 1 ? 12 : 0,
                  ),
                  child: ReadingItemCard(
                    item: items[index],
                    onTap: () => context.pushItemDetail(items[index]),
                    showProgress: true,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        children: [
          Icon(
            icon,
            size: 64,
            color: colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Extension for navigation helpers
extension HomeScreenNavigation on BuildContext {
  void pushAddWithType(String type) {
    push('/add?type=$type');
  }

  void pushLibraryWithType(String type) {
    push('/library?type=$type');
  }

  void pushItemDetail(ReadingItem item) {
    push('/item/${item.id}', extra: item);
  }
}

