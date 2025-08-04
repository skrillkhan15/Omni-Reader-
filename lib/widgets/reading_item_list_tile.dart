import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../models/reading_item.dart';

class ReadingItemListTile extends StatelessWidget {
  final ReadingItem item;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isSelected;
  final Widget? trailing;

  const ReadingItemListTile({
    super.key,
    required this.item,
    this.onTap,
    this.onLongPress,
    this.isSelected = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: isSelected ? 4 : 1,
      color: isSelected ? colorScheme.primaryContainer : null,
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: _buildCoverImage(context),
        title: _buildTitle(context),
        subtitle: _buildSubtitle(context),
        trailing: trailing ?? _buildTrailing(context),
        onTap: onTap,
        onLongPress: onLongPress,
        selected: isSelected,
      ),
    );
  }

  Widget _buildCoverImage(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      width: 50,
      height: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: colorScheme.surfaceVariant,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: _buildImage(context),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    if (item.localCoverPath != null) {
      return Image.asset(
        item.localCoverPath!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(context),
      );
    }

    if (item.coverImageUrl != null) {
      return Image.network(
        item.coverImageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(context),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
      );
    }

    return _buildPlaceholder(context);
  }

  Widget _buildPlaceholder(BuildContext context) {
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
          size: 24,
          color: _getTypeColor(),
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (item.author != null) ...[
          const SizedBox(height: 2),
          Text(
            'by ${item.author}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildSubtitle(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        
        // Type and Status chips
        Row(
          children: [
            _buildTypeChip(context),
            const SizedBox(width: 8),
            _buildStatusChip(context),
            if (item.isFavorite) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.favorite,
                size: 16,
                color: Colors.red,
              ),
            ],
          ],
        ),
        
        const SizedBox(height: 8),
        
        // Progress and rating
        Row(
          children: [
            Expanded(
              child: _buildProgressInfo(context),
            ),
            if (item.rating > 0) ...[
              const SizedBox(width: 12),
              _buildRating(context),
            ],
          ],
        ),
        
        // Genres
        if (item.genres.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            item.genres.take(3).join(' • '),
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildTypeChip(BuildContext context) {
    final theme = Theme.of(context);
    final typeColor = _getTypeColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: typeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: typeColor.withOpacity(0.3)),
      ),
      child: Text(
        item.type.displayName,
        style: theme.textTheme.labelSmall?.copyWith(
          color: typeColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Text(
        item.status.displayName,
        style: theme.textTheme.labelSmall?.copyWith(
          color: statusColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildProgressInfo(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (item.totalChapters != null) {
      final progress = item.progressPercentage / 100;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Ch. ${item.currentChapter}',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                ' / ${item.totalChapters}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const Spacer(),
              Text(
                '${item.progressPercentage.toInt()}%',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: colorScheme.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            minHeight: 3,
          ),
        ],
      );
    } else {
      return Text(
        'Chapter ${item.currentChapter}',
        style: theme.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      );
    }
  }

  Widget _buildRating(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        RatingBarIndicator(
          rating: item.rating / 2, // Convert to 5-star scale
          itemBuilder: (context, index) => const Icon(
            Icons.star,
            color: Colors.amber,
          ),
          itemCount: 5,
          itemSize: 12.0,
          direction: Axis.horizontal,
        ),
        const SizedBox(width: 4),
        Text(
          item.rating.toStringAsFixed(1),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.amber[700],
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildTrailing(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (item.readingUrl != null)
          Icon(
            Icons.open_in_new,
            size: 16,
            color: colorScheme.primary,
          ),
        const SizedBox(height: 4),
        Text(
          _formatDate(item.lastUpdated),
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  Color _getTypeColor() {
    switch (item.type) {
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
    switch (item.type) {
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
    switch (item.status) {
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

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
}

