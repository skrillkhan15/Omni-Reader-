import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/app_providers.dart';
import '../models/reading_item.dart';
import '../widgets/reading_item_card.dart';

class ItemDetailScreen extends ConsumerStatefulWidget {
  final String itemId;
  final ReadingItem? item;

  const ItemDetailScreen({
    super.key,
    required this.itemId,
    this.item,
  });

  @override
  ConsumerState<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends ConsumerState<ItemDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;
  final ScrollController _scrollController = ScrollController();
  
  bool _showAppBarTitle = false;
  ReadingItem? _currentItem;

  @override
  void initState() {
    super.initState();
    _currentItem = widget.item;
    
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeInOut,
    );

    _scrollController.addListener(_onScroll);
    _fabAnimationController.forward();
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final showTitle = _scrollController.offset > 200;
    if (showTitle != _showAppBarTitle) {
      setState(() {
        _showAppBarTitle = showTitle;
      });
    }
  }

  Future<void> _openReadingUrl() async {
    if (_currentItem?.readingUrl != null) {
      try {
        final uri = Uri.parse(_currentItem!.readingUrl!);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Cannot open reading URL')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error opening URL: $e')),
          );
        }
      }
    }
  }

  Future<void> _toggleFavorite() async {
    if (_currentItem != null) {
      await ref.read(readingItemsProvider.notifier).toggleFavorite(_currentItem!.id);
      // Update local item
      setState(() {
        _currentItem = _currentItem!.copyWith(isFavorite: !_currentItem!.isFavorite);
      });
    }
  }

  Future<void> _updateProgress() async {
    if (_currentItem == null) return;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _ProgressUpdateDialog(item: _currentItem!),
    );

    if (result != null) {
      await ref.read(readingItemsProvider.notifier).updateProgress(
        _currentItem!.id,
        result['currentChapter'],
        totalChapters: result['totalChapters'],
        newStatus: result['status'],
      );
      
      // Refresh item data
      final items = ref.read(readingItemsProvider).value ?? [];
      final updatedItem = items.firstWhere((item) => item.id == _currentItem!.id);
      setState(() {
        _currentItem = updatedItem;
      });
    }
  }

  Future<void> _updateRating() async {
    if (_currentItem == null) return;

    final result = await showDialog<double>(
      context: context,
      builder: (context) => _RatingDialog(initialRating: _currentItem!.rating),
    );

    if (result != null) {
      await ref.read(readingItemsProvider.notifier).updateRating(_currentItem!.id, result);
      
      // Update local item
      setState(() {
        _currentItem = _currentItem!.copyWith(rating: result);
      });
    }
  }

  void _shareItem() {
    if (_currentItem != null) {
      final text = '${_currentItem!.title}${_currentItem!.author != null ? ' by ${_currentItem!.author}' : ''}';
      final url = _currentItem!.readingUrl ?? '';
      Share.share('$text\n$url');
    }
  }

  Future<void> _deleteItem() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete "${_currentItem?.title}"? This action cannot be undone.'),
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

    if (confirmed == true && _currentItem != null) {
      await ref.read(readingItemsProvider.notifier).deleteItem(_currentItem!.id);
      if (mounted) {
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Get the latest item data from provider
    final itemsAsync = ref.watch(readingItemsProvider);
    itemsAsync.whenData((items) {
      final updatedItem = items.where((item) => item.id == widget.itemId).firstOrNull;
      if (updatedItem != null && updatedItem != _currentItem) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {
            _currentItem = updatedItem;
          });
        });
      }
    });

    if (_currentItem == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Item Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: colorScheme.surface,
            foregroundColor: colorScheme.onSurface,
            title: AnimatedOpacity(
              opacity: _showAppBarTitle ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Text(
                _currentItem!.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHeaderSection(),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _currentItem!.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _currentItem!.isFavorite ? Colors.red : null,
                ),
                onPressed: _toggleFavorite,
                tooltip: 'Toggle Favorite',
              ),
              PopupMenuButton(
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: const Row(
                      children: [
                        Icon(Icons.edit, size: 20),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                    onTap: () => context.push('/edit/${_currentItem!.id}', extra: _currentItem),
                  ),
                  PopupMenuItem(
                    child: const Row(
                      children: [
                        Icon(Icons.share, size: 20),
                        SizedBox(width: 8),
                        Text('Share'),
                      ],
                    ),
                    onTap: _shareItem,
                  ),
                  PopupMenuItem(
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 20, color: colorScheme.error),
                        const SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: colorScheme.error)),
                      ],
                    ),
                    onTap: _deleteItem,
                  ),
                ],
              ),
            ],
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Basic info
                _buildBasicInfoSection(),
                const SizedBox(height: 24),

                // Progress section
                _buildProgressSection(),
                const SizedBox(height: 24),

                // Rating section
                _buildRatingSection(),
                const SizedBox(height: 24),

                // Description
                if (_currentItem!.description != null) ...[
                  _buildDescriptionSection(),
                  const SizedBox(height: 24),
                ],

                // Genres and tags
                _buildGenresAndTagsSection(),
                const SizedBox(height: 24),

                // Additional info
                _buildAdditionalInfoSection(),
                const SizedBox(height: 24),

                // Related items
                _buildRelatedItemsSection(),
                const SizedBox(height: 100), // Bottom padding for FAB
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _fabAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _fabAnimation.value,
            child: _currentItem!.readingUrl != null
                ? FloatingActionButton.extended(
                    onPressed: _openReadingUrl,
                    icon: const Icon(Icons.auto_stories),
                    label: const Text('Read'),
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                  )
                : FloatingActionButton(
                    onPressed: _updateProgress,
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    child: const Icon(Icons.add),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderSection() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colorScheme.primary.withOpacity(0.1),
            colorScheme.surface,
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Cover image
              Container(
                width: 120,
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _buildCoverImage(),
                ),
              ),
              const SizedBox(width: 16),

              // Title and basic info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      _currentItem!.title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (_currentItem!.author != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'by ${_currentItem!.author}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildTypeChip(),
                        const SizedBox(width: 8),
                        _buildStatusChip(),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoverImage() {
    if (_currentItem!.localCoverPath != null) {
      return Image.asset(
        _currentItem!.localCoverPath!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
      );
    }

    if (_currentItem!.coverImageUrl != null) {
      return Image.network(
        _currentItem!.coverImageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
      );
    }

    return _buildPlaceholderImage();
  }

  Widget _buildPlaceholderImage() {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getTypeColor().withOpacity(0.3),
            _getTypeColor().withOpacity(0.1),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          _getTypeIcon(),
          size: 48,
          color: _getTypeColor(),
        ),
      ),
    );
  }

  Widget _buildTypeChip() {
    final theme = Theme.of(context);
    final typeColor = _getTypeColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: typeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: typeColor.withOpacity(0.3)),
      ),
      child: Text(
        _currentItem!.type.displayName,
        style: theme.textTheme.labelMedium?.copyWith(
          color: typeColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Text(
        _currentItem!.status.displayName,
        style: theme.textTheme.labelMedium?.copyWith(
          color: statusColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Information',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (_currentItem!.publisher != null)
              _buildInfoRow('Publisher', _currentItem!.publisher!),
            if (_currentItem!.language != null)
              _buildInfoRow('Language', _currentItem!.language!),
            _buildInfoRow('Date Added', _formatDate(_currentItem!.dateAdded)),
            _buildInfoRow('Last Updated', _formatDate(_currentItem!.lastUpdated)),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Progress',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _updateProgress,
                  child: const Text('Update'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_currentItem!.totalChapters != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Chapter ${_currentItem!.currentChapter}',
                    style: theme.textTheme.titleMedium,
                  ),
                  Text(
                    '${_currentItem!.progressPercentage.toInt()}%',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: _currentItem!.progressPercentage / 100,
                backgroundColor: colorScheme.surfaceVariant,
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                minHeight: 8,
              ),
              const SizedBox(height: 8),
              Text(
                'of ${_currentItem!.totalChapters} chapters',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ] else ...[
              Text(
                'Chapter ${_currentItem!.currentChapter}',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Total chapters unknown',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRatingSection() {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Rating',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _updateRating,
                  child: const Text('Update'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                RatingBarIndicator(
                  rating: _currentItem!.rating / 2, // Convert to 5-star scale
                  itemBuilder: (context, index) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  itemCount: 5,
                  itemSize: 32.0,
                  direction: Axis.horizontal,
                ),
                const SizedBox(width: 16),
                Text(
                  '${_currentItem!.rating.toStringAsFixed(1)}/10',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber[700],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionSection() {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Description',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _currentItem!.description!,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenresAndTagsSection() {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Genres & Tags',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (_currentItem!.genres.isNotEmpty) ...[
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
                children: _currentItem!.genres.map((genre) {
                  return Chip(
                    label: Text(genre),
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
            if (_currentItem!.tags.isNotEmpty) ...[
              Text(
                'Tags',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _currentItem!.tags.map((tag) {
                  return Chip(
                    label: Text(tag),
                    backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInfoSection() {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Additional Information',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (_currentItem!.readingUrl != null)
              _buildInfoRow(
                'Reading URL',
                _currentItem!.readingUrl!,
                isUrl: true,
              ),
            _buildInfoRow('Type', _currentItem!.type.displayName),
            _buildInfoRow('Status', _currentItem!.status.displayName),
            _buildInfoRow('Favorite', _currentItem!.isFavorite ? 'Yes' : 'No'),
          ],
        ),
      ),
    );
  }

  Widget _buildRelatedItemsSection() {
    final theme = Theme.of(context);
    final itemsAsync = ref.watch(readingItemsProvider);

    return itemsAsync.when(
      data: (items) {
        // Find related items (same author or similar genres)
        final relatedItems = items.where((item) {
          return item.id != _currentItem!.id &&
                 (item.author == _currentItem!.author ||
                  item.genres.any((genre) => _currentItem!.genres.contains(genre)));
        }).take(5).toList();

        if (relatedItems.isEmpty) {
          return const SizedBox.shrink();
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Related Items',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: relatedItems.length,
                    itemBuilder: (context, index) {
                      return Container(
                        width: 140,
                        margin: EdgeInsets.only(
                          right: index < relatedItems.length - 1 ? 12 : 0,
                        ),
                        child: ReadingItemCard(
                          item: relatedItems[index],
                          onTap: () => context.push(
                            '/item/${relatedItems[index].id}',
                            extra: relatedItems[index],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isUrl = false}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: isUrl
                ? GestureDetector(
                    onTap: () async {
                      try {
                        final uri = Uri.parse(value);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        }
                      } catch (e) {
                        // Handle error
                      }
                    },
                    child: Text(
                      value,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  )
                : Text(
                    value,
                    style: theme.textTheme.bodyMedium,
                  ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _getTypeColor() {
    switch (_currentItem!.type) {
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

  IconData _getTypeIcon() {
    switch (_currentItem!.type) {
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

  Color _getStatusColor() {
    switch (_currentItem!.status) {
      case ReadingStatus.reading:
        return Colors.blue;
      case ReadingStatus.completed:
        return Colors.green;
      case ReadingStatus.onHold:
        return Colors.orange;
      case ReadingStatus.dropped:
        return Colors.red;
      case ReadingStatus.planToRead:
        return Colors.grey;
    }
  }
}

// Progress update dialog
class _ProgressUpdateDialog extends StatefulWidget {
  final ReadingItem item;

  const _ProgressUpdateDialog({required this.item});

  @override
  State<_ProgressUpdateDialog> createState() => _ProgressUpdateDialogState();
}

class _ProgressUpdateDialogState extends State<_ProgressUpdateDialog> {
  late TextEditingController _currentChapterController;
  late TextEditingController _totalChaptersController;
  late ReadingStatus _selectedStatus;

  @override
  void initState() {
    super.initState();
    _currentChapterController = TextEditingController(
      text: widget.item.currentChapter.toString(),
    );
    _totalChaptersController = TextEditingController(
      text: widget.item.totalChapters?.toString() ?? '',
    );
    _selectedStatus = widget.item.status;
  }

  @override
  void dispose() {
    _currentChapterController.dispose();
    _totalChaptersController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Update Progress'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _currentChapterController,
            decoration: const InputDecoration(
              labelText: 'Current Chapter',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _totalChaptersController,
            decoration: const InputDecoration(
              labelText: 'Total Chapters',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<ReadingStatus>(
            value: _selectedStatus,
            decoration: const InputDecoration(
              labelText: 'Status',
              border: OutlineInputBorder(),
            ),
            items: ReadingStatus.values.map((status) {
              return DropdownMenuItem(
                value: status,
                child: Text(status.displayName),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedStatus = value;
                });
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final currentChapter = int.tryParse(_currentChapterController.text) ?? 0;
            final totalChapters = _totalChaptersController.text.isEmpty
                ? null
                : int.tryParse(_totalChaptersController.text);

            Navigator.of(context).pop({
              'currentChapter': currentChapter,
              'totalChapters': totalChapters,
              'status': _selectedStatus,
            });
          },
          child: const Text('Update'),
        ),
      ],
    );
  }
}

// Rating dialog
class _RatingDialog extends StatefulWidget {
  final double initialRating;

  const _RatingDialog({required this.initialRating});

  @override
  State<_RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<_RatingDialog> {
  late double _rating;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rate Item'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${_rating.toStringAsFixed(1)}/10',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Slider(
            value: _rating,
            min: 0.0,
            max: 10.0,
            divisions: 100,
            onChanged: (value) {
              setState(() {
                _rating = value;
              });
            },
          ),
          const SizedBox(height: 16),
          RatingBar.builder(
            initialRating: _rating / 2,
            minRating: 0,
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemCount: 5,
            itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
            itemBuilder: (context, _) => const Icon(
              Icons.star,
              color: Colors.amber,
            ),
            onRatingUpdate: (rating) {
              setState(() {
                _rating = rating * 2;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(_rating),
          child: const Text('Save'),
        ),
      ],
    );
  }
}

