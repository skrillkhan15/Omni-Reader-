import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/reading_item.dart';
import '../services/image_service.dart';

class ReadingItemCard extends StatelessWidget {
  final ReadingItem item;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool showProgress;
  final bool showRating;
  final bool showGenres;
  final bool isSelected;
  final double? width;
  final double? height;

  const ReadingItemCard({
    super.key,
    required this.item,
    this.onTap,
    this.onLongPress,
    this.showProgress = true,
    this.showRating = true,
    this.showGenres = true,
    this.isSelected = false,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: width,
      height: height,
      child: Card(
        elevation: isSelected ? 8 : 2,
        shadowColor: isSelected 
            ? colorScheme.primary.withOpacity(0.3)
            : colorScheme.shadow.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isSelected
              ? BorderSide(color: colorScheme.primary, width: 2)
              : BorderSide.none,
        ),
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover Image
              Expanded(
                flex: 3,
                child: _buildCoverImage(context),
              ),
              
              // Content
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        item.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      if (item.author != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          item.author!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.7),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      
                      const Spacer(),
                      
                      // Progress
                      if (showProgress && item.totalChapters != null) ...[
                        _buildProgressIndicator(context),
                        const SizedBox(height: 8),
                      ],
                      
                      // Rating
                      if (showRating && item.rating > 0) ...[
                        _buildRating(context),
                        const SizedBox(height: 8),
                      ],
                      
                      // Status and Type
                      Row(
                        children: [
                          _buildStatusChip(context),
                          const Spacer(),
                          _buildTypeIcon(context),
                        ],
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

  Widget _buildCoverImage(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Stack(
      children: [
        // Main image
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(12),
            ),
            color: colorScheme.surfaceVariant,
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(12),
            ),
            child: _buildImage(context),
          ),
        ),
        
        // Favorite indicator
        if (item.isFavorite)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.favorite,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        
        // Selection indicator
        if (isSelected)
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.check,
                size: 16,
                color: colorScheme.onPrimary,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildImage(BuildContext context) {
    if (item.localCoverPath != null) {
      return Image.asset(
        item.localCoverPath!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildNetworkImage(context);
        },
      );
    }
    
    return _buildNetworkImage(context);
  }

  Widget _buildNetworkImage(BuildContext context) {
    if (item.coverImageUrl != null && item.coverImageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: item.coverImageUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildPlaceholder(context),
        errorWidget: (context, url, error) => _buildPlaceholder(context),
      );
    }
    
    return _buildPlaceholder(context);
  }

  Widget _buildPlaceholder(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      height: double.infinity,
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

  Widget _buildProgressIndicator(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final progress = item.progressPercentage / 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Chapter ${item.currentChapter}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            Text(
              '${item.progressPercentage.toInt()}%',
              style: theme.textTheme.labelSmall?.copyWith(
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
  }

  Widget _buildRating(BuildContext context) {
    return Row(
      children: [
        RatingBarIndicator(
          rating: item.rating,
          itemBuilder: (context, index) => const Icon(
            Icons.star,
            color: Colors.amber,
          ),
          itemCount: 5,
          itemSize: 14.0,
          direction: Axis.horizontal,
        ),
        const SizedBox(width: 4),
        Text(
          item.rating.toStringAsFixed(1),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Colors.amber[700],
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        item.statusDisplayName,
        style: theme.textTheme.labelSmall?.copyWith(
          color: statusColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTypeIcon(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _getTypeColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(
        _getTypeIcon(),
        size: 16,
        color: _getTypeColor(),
      ),
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
}

// Compact version for list view
class ReadingItemListTile extends StatelessWidget {
  final ReadingItem item;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isSelected;

  const ReadingItemListTile({
    super.key,
    required this.item,
    this.onTap,
    this.onLongPress,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: isSelected ? 4 : 1,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: ListTile(
        onTap: onTap,
        onLongPress: onLongPress,
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 60,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: colorScheme.surfaceVariant,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _buildCoverImage(context),
          ),
        ),
        title: Text(
          item.title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.author != null) ...[
              const SizedBox(height: 4),
              Text(
                item.author!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                _buildStatusChip(context),
                const SizedBox(width: 8),
                if (item.totalChapters != null)
                  Text(
                    '${item.currentChapter}/${item.totalChapters}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (item.isFavorite)
              Icon(
                Icons.favorite,
                size: 20,
                color: Colors.red,
              ),
            if (item.rating > 0) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.star,
                    size: 16,
                    color: Colors.amber,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    item.rating.toStringAsFixed(1),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.amber[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCoverImage(BuildContext context) {
    if (item.coverImageUrl != null && item.coverImageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: item.coverImageUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildPlaceholder(context),
        errorWidget: (context, url, error) => _buildPlaceholder(context),
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

  Widget _buildStatusChip(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        item.statusDisplayName,
        style: theme.textTheme.labelSmall?.copyWith(
          color: statusColor,
          fontWeight: FontWeight.w600,
        ),
      ),
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
}

