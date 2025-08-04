import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/app_providers.dart';
import '../models/reading_item.dart';
import '../widgets/statistics_card.dart';
import '../widgets/section_header.dart';

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              title: const Text('Statistics'),
              floating: true,
              pinned: true,
              backgroundColor: colorScheme.surface,
              foregroundColor: colorScheme.onSurface,
              bottom: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Overview', icon: Icon(Icons.dashboard)),
                  Tab(text: 'Progress', icon: Icon(Icons.trending_up)),
                  Tab(text: 'Insights', icon: Icon(Icons.analytics)),
                ],
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
            _buildOverviewTab(),
            _buildProgressTab(),
            _buildInsightsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    final statisticsAsync = ref.watch(statisticsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(statisticsProvider);
        ref.invalidate(readingItemsProvider);
      },
      child: statisticsAsync.when(
        data: (stats) => _buildOverviewContent(stats),
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
              Text('Error loading statistics: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(statisticsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewContent(Map<String, dynamic> stats) {
    return AnimationLimiter(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: AnimationConfiguration.toStaggeredList(
            duration: const Duration(milliseconds: 375),
            childAnimationBuilder: (widget) => SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(child: widget),
            ),
            children: [
              // Main statistics grid
              _buildMainStatisticsGrid(stats),
              const SizedBox(height: 24),

              // Type distribution
              _buildTypeDistribution(stats),
              const SizedBox(height: 24),

              // Status distribution
              _buildStatusDistribution(stats),
              const SizedBox(height: 24),

              // Recent activity
              _buildRecentActivity(),
              const SizedBox(height: 24),

              // Top genres
              _buildTopGenres(stats),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainStatisticsGrid(Map<String, dynamic> stats) {
    return AnimatedStatisticsGrid(
      cards: [
        StatisticsCard(
          title: 'Total Items',
          value: stats['totalItems'].toString(),
          icon: Icons.library_books,
          color: Colors.blue,
          subtitle: 'In your library',
          showTrend: true,
          trendValue: 12.5,
          isPositiveTrend: true,
        ),
        StatisticsCard(
          title: 'Reading',
          value: stats['readingItems'].toString(),
          icon: Icons.auto_stories,
          color: Colors.orange,
          subtitle: 'Currently reading',
        ),
        StatisticsCard(
          title: 'Completed',
          value: stats['completedItems'].toString(),
          icon: Icons.check_circle,
          color: Colors.green,
          subtitle: 'Finished reading',
        ),
        StatisticsCard(
          title: 'Favorites',
          value: stats['favoriteItems'].toString(),
          icon: Icons.favorite,
          color: Colors.red,
          subtitle: 'Marked as favorite',
        ),
        StatisticsCard(
          title: 'Average Rating',
          value: stats['averageRating'].toStringAsFixed(1),
          icon: Icons.star,
          color: Colors.amber,
          subtitle: 'Out of 10',
        ),
        StatisticsCard(
          title: 'Total Chapters',
          value: stats['totalChaptersRead'].toString(),
          icon: Icons.bookmark,
          color: Colors.purple,
          subtitle: 'Chapters read',
        ),
      ],
    );
  }

  Widget _buildTypeDistribution(Map<String, dynamic> stats) {
    final theme = Theme.of(context);
    final typeData = stats['typeDistribution'] as Map<String, int>? ?? {};

    if (typeData.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: 'Type Distribution',
              subtitle: 'Breakdown by content type',
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: _buildPieChartSections(typeData, _getTypeColors()),
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildLegend(typeData, _getTypeColors()),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusDistribution(Map<String, dynamic> stats) {
    final statusData = stats['statusDistribution'] as Map<String, int>? ?? {};

    if (statusData.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: 'Reading Status',
              subtitle: 'Current reading progress',
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: statusData.values.isEmpty ? 10 : statusData.values.reduce((a, b) => a > b ? a : b).toDouble() + 2,
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final statuses = statusData.keys.toList();
                          if (value.toInt() < statuses.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                _getShortStatusName(statuses[value.toInt()]),
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: Theme.of(context).textTheme.labelSmall,
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: _buildBarGroups(statusData, _getStatusColors()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    final recentlyUpdatedAsync = ref.watch(recentlyUpdatedProvider);

    return recentlyUpdatedAsync.when(
      data: (items) {
        if (items.isEmpty) {
          return const SizedBox.shrink();
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(
                  title: 'Recent Activity',
                  subtitle: 'Recently updated items',
                ),
                const SizedBox(height: 16),
                ...items.take(5).map((item) => _buildActivityItem(item)),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildTopGenres(Map<String, dynamic> stats) {
    final genreData = stats['topGenres'] as Map<String, int>? ?? {};

    if (genreData.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: 'Top Genres',
              subtitle: 'Most popular genres in your library',
            ),
            const SizedBox(height: 16),
            ...genreData.entries.take(10).map((entry) => _buildGenreItem(entry)),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressTab() {
    final itemsAsync = ref.watch(readingItemsProvider);

    return itemsAsync.when(
      data: (items) => _buildProgressContent(items),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error loading progress data: $error'),
      ),
    );
  }

  Widget _buildProgressContent(List<ReadingItem> items) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Reading progress overview
          _buildReadingProgressOverview(items),
          const SizedBox(height: 24),

          // Progress by type
          _buildProgressByType(items),
          const SizedBox(height: 24),

          // Completion rate
          _buildCompletionRate(items),
          const SizedBox(height: 24),

          // Reading goals
          _buildReadingGoals(),
        ],
      ),
    );
  }

  Widget _buildInsightsTab() {
    final itemsAsync = ref.watch(readingItemsProvider);

    return itemsAsync.when(
      data: (items) => _buildInsightsContent(items),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error loading insights: $error'),
      ),
    );
  }

  Widget _buildInsightsContent(List<ReadingItem> items) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Reading habits
          _buildReadingHabits(items),
          const SizedBox(height: 24),

          // Rating analysis
          _buildRatingAnalysis(items),
          const SizedBox(height: 24),

          // Recommendations
          _buildRecommendations(items),
        ],
      ),
    );
  }

  // Helper methods for building specific sections
  List<PieChartSectionData> _buildPieChartSections(Map<String, int> data, Map<String, Color> colors) {
    final total = data.values.fold(0, (sum, value) => sum + value);
    
    return data.entries.map((entry) {
      final percentage = (entry.value / total * 100);
      return PieChartSectionData(
        color: colors[entry.key] ?? Colors.grey,
        value: entry.value.toDouble(),
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  List<BarChartGroupData> _buildBarGroups(Map<String, int> data, Map<String, Color> colors) {
    return data.entries.toList().asMap().entries.map((entry) {
      final index = entry.key;
      final statusEntry = entry.value;
      
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: statusEntry.value.toDouble(),
            color: colors[statusEntry.key] ?? Colors.grey,
            width: 20,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();
  }

  Widget _buildLegend(Map<String, int> data, Map<String, Color> colors) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: data.entries.map((entry) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: colors[entry.key] ?? Colors.grey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${entry.key} (${entry.value})',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildActivityItem(ReadingItem item) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getTypeColor(item.type).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getTypeIcon(item.type),
              size: 20,
              color: _getTypeColor(item.type),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Updated ${_formatRelativeTime(item.lastUpdated)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Text(
            'Ch. ${item.currentChapter}',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenreItem(MapEntry<String, int> entry) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              entry.key,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              entry.value.toString(),
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadingProgressOverview(List<ReadingItem> items) {
    final totalChapters = items
        .where((item) => item.totalChapters != null)
        .fold(0, (sum, item) => sum + item.totalChapters!);
    final readChapters = items
        .fold(0, (sum, item) => sum + item.currentChapter);

    return LargeStatisticsCard(
      title: 'Reading Progress',
      value: '$readChapters',
      subtitle: 'of $totalChapters chapters',
      icon: Icons.auto_stories,
      color: Colors.blue,
      details: [
        StatisticItem(
          label: 'Total Progress',
          value: totalChapters > 0 ? '${(readChapters / totalChapters * 100).toStringAsFixed(1)}%' : '0%',
          color: Colors.blue,
        ),
        StatisticItem(
          label: 'Average per Item',
          value: items.isNotEmpty ? (readChapters / items.length).toStringAsFixed(1) : '0',
          color: Colors.green,
        ),
      ],
    );
  }

  Widget _buildProgressByType(List<ReadingItem> items) {
    final progressByType = <ReadingType, double>{};
    
    for (final type in ReadingType.values) {
      final typeItems = items.where((item) => item.type == type).toList();
      if (typeItems.isNotEmpty) {
        final totalProgress = typeItems.fold(0.0, (sum, item) => sum + item.progressPercentage);
        progressByType[type] = totalProgress / typeItems.length;
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: 'Progress by Type',
              subtitle: 'Average completion percentage',
            ),
            const SizedBox(height: 16),
            ...progressByType.entries.map((entry) {
              return ProgressStatisticsCard(
                title: entry.key.displayName,
                progress: entry.value / 100,
                progressText: '${entry.value.toStringAsFixed(1)}%',
                icon: _getTypeIcon(entry.key),
                color: _getTypeColor(entry.key),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionRate(List<ReadingItem> items) {
    final completedItems = items.where((item) => item.status == ReadingStatus.completed).length;
    final completionRate = items.isNotEmpty ? (completedItems / items.length * 100) : 0.0;

    return ProgressStatisticsCard(
      title: 'Completion Rate',
      progress: completionRate / 100,
      progressText: '${completionRate.toStringAsFixed(1)}%',
      subtitle: '$completedItems of ${items.length} items completed',
      icon: Icons.check_circle,
      color: Colors.green,
    );
  }

  Widget _buildReadingGoals() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: 'Reading Goals',
              subtitle: 'Track your reading targets',
            ),
            const SizedBox(height: 16),
            ProgressStatisticsCard(
              title: 'Monthly Goal',
              progress: 0.65,
              progressText: '65%',
              subtitle: '13 of 20 chapters this month',
              icon: Icons.calendar_month,
              color: Colors.orange,
            ),
            const SizedBox(height: 12),
            ProgressStatisticsCard(
              title: 'Yearly Goal',
              progress: 0.42,
              progressText: '42%',
              subtitle: '21 of 50 items this year',
              icon: Icons.calendar_today,
              color: Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadingHabits(List<ReadingItem> items) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: 'Reading Habits',
              subtitle: 'Your reading patterns',
            ),
            const SizedBox(height: 16),
            _buildHabitItem('Most Read Type', _getMostReadType(items), Icons.category),
            _buildHabitItem('Favorite Genre', _getFavoriteGenre(items), Icons.tag),
            _buildHabitItem('Average Rating', _getAverageRating(items), Icons.star),
            _buildHabitItem('Reading Streak', '7 days', Icons.local_fire_department),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingAnalysis(List<ReadingItem> items) {
    final ratedItems = items.where((item) => item.rating > 0).toList();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: 'Rating Analysis',
              subtitle: 'Your rating patterns',
            ),
            const SizedBox(height: 16),
            if (ratedItems.isNotEmpty) ...[
              _buildRatingDistribution(ratedItems),
            ] else ...[
              const Text('No rated items yet'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendations(List<ReadingItem> items) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: 'Recommendations',
              subtitle: 'Based on your reading habits',
            ),
            const SizedBox(height: 16),
            _buildRecommendationItem(
              'Try more Fantasy',
              'You seem to enjoy fantasy genres',
              Icons.auto_awesome,
            ),
            _buildRecommendationItem(
              'Complete ongoing series',
              'You have 5 series on hold',
              Icons.play_arrow,
            ),
            _buildRecommendationItem(
              'Explore new authors',
              'Diversify your reading list',
              Icons.explore,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitItem(String label, String value, IconData icon) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingDistribution(List<ReadingItem> items) {
    // Implementation for rating distribution chart
    return const SizedBox(
      height: 100,
      child: Center(child: Text('Rating distribution chart')),
    );
  }

  Widget _buildRecommendationItem(String title, String subtitle, IconData icon) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  Map<String, Color> _getTypeColors() {
    return {
      'Manga': Colors.blue,
      'Manhwa': Colors.pink,
      'Manhua': Colors.orange,
      'Novel': Colors.green,
      'Webtoon': Colors.purple,
      'Light Novel': Colors.teal,
    };
  }

  Map<String, Color> _getStatusColors() {
    return {
      'Reading': Colors.blue,
      'Completed': Colors.green,
      'On Hold': Colors.orange,
      'Dropped': Colors.red,
      'Plan to Read': Colors.grey,
    };
  }

  Color _getTypeColor(ReadingType type) {
    switch (type) {
      case ReadingType.manga:
        return Colors.blue;
      case ReadingType.manhwa:
        return Colors.pink;
      case ReadingType.manhua:
        return Colors.orange;
      case ReadingType.novel:
        return Colors.green;
      case ReadingType.webtoon:
        return Colors.purple;
      case ReadingType.lightNovel:
        return Colors.teal;
    }
  }

  IconData _getTypeIcon(ReadingType type) {
    switch (type) {
      case ReadingType.manga:
        return Icons.book;
      case ReadingType.manhwa:
        return Icons.auto_stories;
      case ReadingType.manhua:
        return Icons.menu_book;
      case ReadingType.novel:
        return Icons.library_books;
      case ReadingType.webtoon:
        return Icons.web_stories;
      case ReadingType.lightNovel:
        return Icons.article;
    }
  }

  String _getShortStatusName(String status) {
    switch (status) {
      case 'Reading':
        return 'Reading';
      case 'Completed':
        return 'Done';
      case 'On Hold':
        return 'Hold';
      case 'Dropped':
        return 'Drop';
      case 'Plan to Read':
        return 'Plan';
      default:
        return status;
    }
  }

  String _formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  String _getMostReadType(List<ReadingItem> items) {
    if (items.isEmpty) return 'None';
    
    final typeCount = <ReadingType, int>{};
    for (final item in items) {
      typeCount[item.type] = (typeCount[item.type] ?? 0) + 1;
    }
    
    final mostRead = typeCount.entries.reduce((a, b) => a.value > b.value ? a : b);
    return mostRead.key.displayName;
  }

  String _getFavoriteGenre(List<ReadingItem> items) {
    if (items.isEmpty) return 'None';
    
    final genreCount = <String, int>{};
    for (final item in items) {
      for (final genre in item.genres) {
        genreCount[genre] = (genreCount[genre] ?? 0) + 1;
      }
    }
    
    if (genreCount.isEmpty) return 'None';
    
    final favorite = genreCount.entries.reduce((a, b) => a.value > b.value ? a : b);
    return favorite.key;
  }

  String _getAverageRating(List<ReadingItem> items) {
    final ratedItems = items.where((item) => item.rating > 0).toList();
    if (ratedItems.isEmpty) return '0.0';
    
    final average = ratedItems.fold(0.0, (sum, item) => sum + item.rating) / ratedItems.length;
    return average.toStringAsFixed(1);
  }
}

