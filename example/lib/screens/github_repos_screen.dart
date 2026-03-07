import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_full_router/flutter_full_router.dart';
import '../main.dart';

class GitHubReposScreen extends StatefulWidget {
  const GitHubReposScreen({super.key});

  @override
  State<GitHubReposScreen> createState() => _GitHubReposScreenState();
}

class _GitHubReposScreenState extends State<GitHubReposScreen> {
  @override
  void initState() {
    super.initState();
    log('[Rendered initState $runtimeType]');

    // Listen to state changes from the service
    gitHubReposState.addListener(_onStateChanged);

    // Trigger the fetch via the action route (service call)
    FFRNavigator.I.pushNamed('/github/fetch/faustobdls');
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    gitHubReposState.removeListener(_onStateChanged);
    super.dispose();
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null) return '';
    final date = DateTime.tryParse(isoDate);
    if (date == null) return '';
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  Color _languageColor(String? language) {
    const colors = {
      'Dart': Color(0xFF00B4AB),
      'JavaScript': Color(0xFFF1E05A),
      'TypeScript': Color(0xFF3178C6),
      'Python': Color(0xFF3572A5),
      'Java': Color(0xFFB07219),
      'Kotlin': Color(0xFFA97BFF),
      'Swift': Color(0xFFF05138),
      'C++': Color(0xFFF34B7D),
      'C#': Color(0xFF178600),
      'Go': Color(0xFF00ADD8),
      'Rust': Color(0xFFDEA584),
      'Ruby': Color(0xFF701516),
      'PHP': Color(0xFF4F5D95),
      'HTML': Color(0xFFE34C26),
      'CSS': Color(0xFF563D7C),
      'Shell': Color(0xFF89E051),
      'OpenSCAD': Color(0xFFE5CD45),
    };
    return colors[language] ?? Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GitHub Repos'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => FFRNavigator.I.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            // Refresh via action route
            onPressed: () => FFRNavigator.I.pushNamed('/github/fetch/faustobdls'),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final state = gitHubReposState;

    if (state.loading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Fetching repositories from GitHub...'),
          ],
        ),
      );
    }

    if (state.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Failed to load repositories',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                state.error!,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                // Retry via action route
                onPressed: () => FFRNavigator.I.pushNamed('/github/fetch/faustobdls'),
              ),
            ],
          ),
        ),
      );
    }

    if (state.repos.isEmpty) {
      return const Center(child: Text('No repositories found.'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with user info
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: Theme.of(
            context,
          ).colorScheme.primaryContainer.withValues(alpha: 0.3),
          child: Row(
            children: [
              const Icon(Icons.code, size: 28),
              const SizedBox(width: 12),
              Text(
                'faustobdls',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Chip(
                label: Text(
                  '${state.repos.length} repos',
                  style: const TextStyle(fontSize: 12),
                ),
                padding: EdgeInsets.zero,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),
        ),
        // Repos list
        Expanded(
          child: ListView.separated(
            itemCount: state.repos.length,
            separatorBuilder: (context, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final repo = state.repos[index];
              final name = repo['name'] as String? ?? '';
              final description = repo['description'] as String?;
              final language = repo['language'] as String?;
              final stars = repo['stargazers_count'] as int? ?? 0;
              final forks = repo['forks_count'] as int? ?? 0;
              final updatedAt = repo['updated_at'] as String?;
              final isPrivate = repo['private'] as bool? ?? false;
              final isFork = repo['fork'] as bool? ?? false;

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                title: Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (isPrivate)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.orange.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Private',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ),
                    if (isFork) ...[
                      const SizedBox(width: 4),
                      Icon(
                        Icons.call_split,
                        size: 14,
                        color: Colors.grey.shade500,
                      ),
                    ],
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (description != null && description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (language != null) ...[
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: _languageColor(language),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(language, style: const TextStyle(fontSize: 12)),
                          const SizedBox(width: 16),
                        ],
                        if (stars > 0) ...[
                          const Icon(Icons.star_border, size: 14),
                          const SizedBox(width: 2),
                          Text('$stars', style: const TextStyle(fontSize: 12)),
                          const SizedBox(width: 16),
                        ],
                        if (forks > 0) ...[
                          const Icon(Icons.call_split, size: 14),
                          const SizedBox(width: 2),
                          Text('$forks', style: const TextStyle(fontSize: 12)),
                          const SizedBox(width: 16),
                        ],
                        if (updatedAt != null)
                          Text(
                            'Updated ${_formatDate(updatedAt)}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
