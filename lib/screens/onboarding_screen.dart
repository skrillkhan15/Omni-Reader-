import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import '../providers/app_providers.dart';
import '../services/notification_service.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLastPage = false;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Welcome to OmniReader',
      description: 'Your ultimate companion for managing manga, manhwa, and manhua collections with advanced features and AI integration.',
      icon: Icons.auto_stories,
      gradient: [Colors.blue, Colors.purple],
    ),
    OnboardingPage(
      title: 'Organize Your Library',
      description: 'Keep track of your reading progress, rate your favorites, and organize by genres, status, and custom tags.',
      icon: Icons.library_books,
      gradient: [Colors.purple, Colors.pink],
    ),
    OnboardingPage(
      title: 'Smart Notifications',
      description: 'Never miss an update! Get personalized reminders and notifications for new chapters and reading goals.',
      icon: Icons.notifications_active,
      gradient: [Colors.pink, Colors.orange],
    ),
    OnboardingPage(
      title: 'Reading Analytics',
      description: 'Track your reading habits, view detailed statistics, and discover insights about your reading journey.',
      icon: Icons.analytics,
      gradient: [Colors.orange, Colors.green],
    ),
    OnboardingPage(
      title: 'AI-Powered Features',
      description: 'Get smart recommendations, auto-generated tags, and AI-assisted organization for your collection.',
      icon: Icons.psychology,
      gradient: [Colors.green, Colors.teal],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      final page = _pageController.page?.round() ?? 0;
      if (page != _currentPage) {
        setState(() {
          _currentPage = page;
          _isLastPage = page == _pages.length - 1;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_isLastPage) {
      _completeOnboarding();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  Future<void> _completeOnboarding() async {
    // Request permissions
    await _requestPermissions();
    
    // Navigate to home
    if (mounted) {
      context.pushReplacement('/');
    }
  }

  Future<void> _requestPermissions() async {
    // Request notification permissions
    final notificationService = ref.read(notificationServiceProvider);
    await notificationService.requestPermissions();
    
    // Request storage permissions
    await Permission.storage.request();
    
    // Request camera permissions (for cover images)
    await Permission.camera.request();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary.withOpacity(0.1),
              colorScheme.secondary.withOpacity(0.1),
              colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Page Indicator
                    Row(
                      children: List.generate(
                        _pages.length,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: index == _currentPage ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: index == _currentPage
                                ? colorScheme.primary
                                : colorScheme.outline.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    
                    // Skip Button
                    if (!_isLastPage)
                      TextButton(
                        onPressed: _skipOnboarding,
                        child: Text(
                          'Skip',
                          style: TextStyle(
                            color: colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Page View
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return _buildPage(_pages[index]);
                  },
                ),
              ),

              // Bottom Navigation
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    // Previous Button
                    if (_currentPage > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _previousPage,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Previous'),
                        ),
                      )
                    else
                      const Expanded(child: SizedBox()),

                    const SizedBox(width: 16),

                    // Next/Get Started Button
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _nextPage,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                        ),
                        child: Text(
                          _isLastPage ? 'Get Started' : 'Next',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
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

  Widget _buildPage(OnboardingPage page) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: page.gradient,
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: page.gradient.first.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              page.icon,
              size: 60,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 48),

          // Title
          Text(
            page.title,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          // Description
          Text(
            page.description,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 48),

          // Additional content for specific pages
          if (_currentPage == 2) _buildNotificationPermissionCard(),
          if (_currentPage == 4) _buildAIFeaturesCard(),
        ],
      ),
    );
  }

  Widget _buildNotificationPermissionCard() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(
              Icons.notifications_active,
              size: 32,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              'Enable Notifications',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Allow notifications to get reminders and updates about your reading progress.',
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final notificationService = ref.read(notificationServiceProvider);
                await notificationService.requestPermissions();
              },
              child: const Text('Allow Notifications'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIFeaturesCard() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(
              Icons.psychology,
              size: 32,
              color: colorScheme.secondary,
            ),
            const SizedBox(height: 12),
            Text(
              'AI Features',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enable AI-powered recommendations and smart organization features.',
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // Skip AI features for now
                    },
                    child: const Text('Maybe Later'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      // Enable AI features
                      final settingsNotifier = ref.read(appSettingsProvider.notifier);
                      await settingsNotifier.toggleAIFeatures();
                    },
                    child: const Text('Enable AI'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final IconData icon;
  final List<Color> gradient;

  const OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.gradient,
  });
}

