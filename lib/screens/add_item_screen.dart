import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/app_providers.dart';
import '../models/reading_item.dart';
import '../services/image_service.dart';

class AddItemScreen extends ConsumerStatefulWidget {
  final String? itemId;
  final ReadingItem? item;
  final String? initialType;

  const AddItemScreen({
    super.key,
    this.itemId,
    this.item,
    this.initialType,
  });

  @override
  ConsumerState<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends ConsumerState<AddItemScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TabController _tabController;

  // Form controllers
  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late TextEditingController _descriptionController;
  late TextEditingController _publisherController;
  late TextEditingController _languageController;
  late TextEditingController _coverImageUrlController;
  late TextEditingController _readingUrlController;
  late TextEditingController _currentChapterController;
  late TextEditingController _totalChaptersController;
  late TextEditingController _tagsController;

  // Form state
  ReadingType _selectedType = ReadingType.manga;
  ReadingStatus _selectedStatus = ReadingStatus.planToRead;
  double _rating = 0.0;
  List<String> _selectedGenres = [];
  List<String> _tags = [];
  String? _localCoverPath;
  bool _isFavorite = false;
  bool _isLoading = false;

  // Available options
  final List<String> _availableGenres = [
    'Action', 'Adventure', 'Comedy', 'Drama', 'Fantasy', 'Horror',
    'Mystery', 'Romance', 'Sci-Fi', 'Slice of Life', 'Sports',
    'Supernatural', 'Thriller', 'Historical', 'Psychological',
    'School', 'Shounen', 'Shoujo', 'Seinen', 'Josei', 'Isekai',
    'Mecha', 'Military', 'Music', 'Parody', 'Police', 'Samurai',
    'Super Power', 'Vampire', 'Yaoi', 'Yuri', 'Ecchi', 'Harem',
    'Martial Arts', 'Medical', 'Game', 'Cooking', 'Magic',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeControllers();
    _loadItemData();
  }

  void _initializeControllers() {
    _titleController = TextEditingController();
    _authorController = TextEditingController();
    _descriptionController = TextEditingController();
    _publisherController = TextEditingController();
    _languageController = TextEditingController();
    _coverImageUrlController = TextEditingController();
    _readingUrlController = TextEditingController();
    _currentChapterController = TextEditingController();
    _totalChaptersController = TextEditingController();
    _tagsController = TextEditingController();
  }

  void _loadItemData() {
    if (widget.item != null) {
      final item = widget.item!;
      _titleController.text = item.title;
      _authorController.text = item.author ?? '';
      _descriptionController.text = item.description ?? '';
      _publisherController.text = item.publisher ?? '';
      _languageController.text = item.language ?? '';
      _coverImageUrlController.text = item.coverImageUrl ?? '';
      _readingUrlController.text = item.readingUrl ?? '';
      _currentChapterController.text = item.currentChapter.toString();
      _totalChaptersController.text = item.totalChapters?.toString() ?? '';
      _tagsController.text = item.tags.join(', ');

      _selectedType = item.type;
      _selectedStatus = item.status;
      _rating = item.rating;
      _selectedGenres = List.from(item.genres);
      _tags = List.from(item.tags);
      _localCoverPath = item.localCoverPath;
      _isFavorite = item.isFavorite;
    } else if (widget.initialType != null) {
      switch (widget.initialType!.toLowerCase()) {
        case 'manga':
          _selectedType = ReadingType.manga;
          break;
        case 'manhwa':
          _selectedType = ReadingType.manhwa;
          break;
        case 'manhua':
          _selectedType = ReadingType.manhua;
          break;
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _authorController.dispose();
    _descriptionController.dispose();
    _publisherController.dispose();
    _languageController.dispose();
    _coverImageUrlController.dispose();
    _readingUrlController.dispose();
    _currentChapterController.dispose();
    _totalChaptersController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final item = ReadingItem(
        id: widget.item?.id ?? '',
        title: _titleController.text.trim(),
        author: _authorController.text.trim().isEmpty ? null : _authorController.text.trim(),
        type: _selectedType,
        status: _selectedStatus,
        rating: _rating,
        genres: _selectedGenres,
        coverImageUrl: _coverImageUrlController.text.trim().isEmpty ? null : _coverImageUrlController.text.trim(),
        localCoverPath: _localCoverPath,
        readingUrl: _readingUrlController.text.trim().isEmpty ? null : _readingUrlController.text.trim(),
        currentChapter: int.tryParse(_currentChapterController.text) ?? 0,
        totalChapters: _totalChaptersController.text.trim().isEmpty ? null : int.tryParse(_totalChaptersController.text),
        description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        tags: _tags,
        publisher: _publisherController.text.trim().isEmpty ? null : _publisherController.text.trim(),
        language: _languageController.text.trim().isEmpty ? null : _languageController.text.trim(),
        isFavorite: _isFavorite,
        dateAdded: widget.item?.dateAdded ?? DateTime.now(),
        lastUpdated: DateTime.now(),
        statistics: widget.item?.statistics ?? const ReadingStatistics(),
      );

      if (widget.item != null) {
        await ref.read(readingItemsProvider.notifier).updateItem(item);
      } else {
        await ref.read(readingItemsProvider.notifier).addItem(item);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.item != null ? 'Item updated successfully' : 'Item added successfully',
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
        context.pop();
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving item: $error'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Camera'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image = await picker.pickImage(source: ImageSource.camera);
                if (image != null) {
                  setState(() {
                    _localCoverPath = image.path;
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                if (image != null) {
                  setState(() {
                    _localCoverPath = image.path;
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('URL'),
              onTap: () {
                Navigator.pop(context);
                _showUrlDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showUrlDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cover Image URL'),
        content: TextField(
          controller: _coverImageUrlController,
          decoration: const InputDecoration(
            hintText: 'Enter image URL',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.url,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _localCoverPath = null;
              });
            },
            child: const Text('Set'),
          ),
        ],
      ),
    );
  }

  void _showGenreDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Genres'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: StatefulBuilder(
            builder: (context, setState) {
              return ListView(
                children: _availableGenres.map((genre) {
                  final isSelected = _selectedGenres.contains(genre);
                  return CheckboxListTile(
                    title: Text(genre),
                    value: isSelected,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _selectedGenres.add(genre);
                        } else {
                          _selectedGenres.remove(genre);
                        }
                      });
                    },
                  );
                }).toList(),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {});
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _updateTags() {
    final tagsText = _tagsController.text;
    _tags = tagsText
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();
  }

  Future<void> _testUrl() async {
    final url = _readingUrlController.text.trim();
    if (url.isNotEmpty) {
      try {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Cannot open this URL')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Invalid URL: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isEditing = widget.item != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Item' : 'Add Item'),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        actions: [
          if (isEditing)
            IconButton(
              icon: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                color: _isFavorite ? Colors.red : null,
              ),
              onPressed: () {
                setState(() {
                  _isFavorite = !_isFavorite;
                });
              },
              tooltip: 'Toggle Favorite',
            ),
          TextButton(
            onPressed: _isLoading ? null : _saveItem,
            child: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Basic', icon: Icon(Icons.info_outline)),
            Tab(text: 'Details', icon: Icon(Icons.description_outlined)),
            Tab(text: 'Progress', icon: Icon(Icons.track_changes_outlined)),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildBasicTab(),
            _buildDetailsTab(),
            _buildProgressTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover image section
          _buildCoverImageSection(),
          const SizedBox(height: 24),

          // Title
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Title *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.title),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Title is required';
              }
              return null;
            },
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),

          // Author
          TextFormField(
            controller: _authorController,
            decoration: const InputDecoration(
              labelText: 'Author',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),

          // Type and Status
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<ReadingType>(
                  value: _selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: ReadingType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type.displayName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedType = value;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<ReadingStatus>(
                  value: _selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.bookmark),
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
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Rating
          _buildRatingSection(),
          const SizedBox(height: 16),

          // Genres
          _buildGenresSection(),
        ],
      ),
    );
  }

  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Description
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.description),
              alignLabelWithHint: true,
            ),
            maxLines: 4,
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 16),

          // Publisher and Language
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _publisherController,
                  decoration: const InputDecoration(
                    labelText: 'Publisher',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.business),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _languageController,
                  decoration: const InputDecoration(
                    labelText: 'Language',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.language),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Reading URL
          TextFormField(
            controller: _readingUrlController,
            decoration: InputDecoration(
              labelText: 'Reading URL',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.link),
              suffixIcon: IconButton(
                icon: const Icon(Icons.open_in_new),
                onPressed: _testUrl,
                tooltip: 'Test URL',
              ),
            ),
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: 16),

          // Tags
          TextFormField(
            controller: _tagsController,
            decoration: const InputDecoration(
              labelText: 'Tags (comma separated)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.tag),
              helperText: 'e.g., action, adventure, fantasy',
            ),
            onChanged: (_) => _updateTags(),
          ),
          const SizedBox(height: 16),

          // Tags display
          if (_tags.isNotEmpty) _buildTagsDisplay(),
        ],
      ),
    );
  }

  Widget _buildProgressTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Current and Total Chapters
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _currentChapterController,
                  decoration: const InputDecoration(
                    labelText: 'Current Chapter',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.bookmark_outline),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _totalChaptersController,
                  decoration: const InputDecoration(
                    labelText: 'Total Chapters',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.library_books),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Progress indicator
          _buildProgressIndicator(),
          const SizedBox(height: 24),

          // Quick actions
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildCoverImageSection() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cover Image',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // Image preview
            Container(
              width: 100,
              height: 140,
              decoration: BoxDecoration(
                border: Border.all(color: colorScheme.outline),
                borderRadius: BorderRadius.circular(8),
                color: colorScheme.surfaceVariant,
              ),
              child: _buildImagePreview(),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.add_photo_alternate),
                    label: const Text('Add Image'),
                  ),
                  const SizedBox(height: 8),
                  if (_localCoverPath != null || _coverImageUrlController.text.isNotEmpty)
                    OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _localCoverPath = null;
                          _coverImageUrlController.clear();
                        });
                      },
                      icon: const Icon(Icons.delete),
                      label: const Text('Remove'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImagePreview() {
    if (_localCoverPath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          _localCoverPath!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Icon(Icons.broken_image, size: 32),
            );
          },
        ),
      );
    }

    if (_coverImageUrlController.text.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          _coverImageUrlController.text,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Icon(Icons.broken_image, size: 32),
            );
          },
        ),
      );
    }

    return const Center(
      child: Icon(Icons.image, size: 32),
    );
  }

  Widget _buildRatingSection() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rating: ${_rating.toStringAsFixed(1)}/10',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
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
      ],
    );
  }

  Widget _buildGenresSection() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Genres',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: _showGenreDialog,
              child: const Text('Select'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_selectedGenres.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: _selectedGenres.map((genre) {
              return Chip(
                label: Text(genre),
                onDeleted: () {
                  setState(() {
                    _selectedGenres.remove(genre);
                  });
                },
              );
            }).toList(),
          )
        else
          Text(
            'No genres selected',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
      ],
    );
  }

  Widget _buildTagsDisplay() {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: _tags.map((tag) {
        return Chip(
          label: Text(tag),
          onDeleted: () {
            setState(() {
              _tags.remove(tag);
              _tagsController.text = _tags.join(', ');
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildProgressIndicator() {
    final currentChapter = int.tryParse(_currentChapterController.text) ?? 0;
    final totalChapters = int.tryParse(_totalChaptersController.text);

    if (totalChapters == null || totalChapters == 0) {
      return const SizedBox.shrink();
    }

    final progress = (currentChapter / totalChapters).clamp(0.0, 1.0);
    final percentage = (progress * 100).toInt();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progress',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '$percentage%',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              minHeight: 8,
            ),
            const SizedBox(height: 8),
            Text(
              'Chapter $currentChapter of $totalChapters',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ActionChip(
                  label: const Text('+1 Chapter'),
                  onPressed: () {
                    final current = int.tryParse(_currentChapterController.text) ?? 0;
                    _currentChapterController.text = (current + 1).toString();
                  },
                ),
                ActionChip(
                  label: const Text('+5 Chapters'),
                  onPressed: () {
                    final current = int.tryParse(_currentChapterController.text) ?? 0;
                    _currentChapterController.text = (current + 5).toString();
                  },
                ),
                ActionChip(
                  label: const Text('Mark as Reading'),
                  onPressed: () {
                    setState(() {
                      _selectedStatus = ReadingStatus.reading;
                    });
                  },
                ),
                ActionChip(
                  label: const Text('Mark as Completed'),
                  onPressed: () {
                    setState(() {
                      _selectedStatus = ReadingStatus.completed;
                      final total = int.tryParse(_totalChaptersController.text);
                      if (total != null) {
                        _currentChapterController.text = total.toString();
                      }
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
