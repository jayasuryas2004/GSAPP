import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/providers/index.dart';

/// Saved Schemes Screen - Show user's bookmarked schemes
class SavedSchemesScreen extends ConsumerWidget {
  const SavedSchemesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch saved scheme IDs
    final savedIds = ref.watch(savedSchemeIdsListProvider);
    
    // Watch all schemes
    final allSchemes = ref.watch(schemesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Saved Schemes'),
        centerTitle: true,
      ),
      body: allSchemes.when(
        data: (schemes) {
          // Filter to only saved schemes
          final savedSchemes = schemes
              .where((scheme) => savedIds.contains(scheme.id))
              .toList();

          if (savedSchemes.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: savedSchemes.length,
            itemBuilder: (context, index) {
              final scheme = savedSchemes[index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  title: Text(
                    scheme.title,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8),
                      Text(
                        scheme.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Chip(label: Text(scheme.categoryName)),
                          IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () {
                              ref
                                  .read(savedSchemeIdsProvider.notifier)
                                  .removeSavedScheme(scheme.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Removed from saved'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: Icon(Icons.arrow_forward),
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      '/scheme-details',
                      arguments: scheme.id,
                    );
                  },
                ),
              );
            },
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading saved schemes'),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bookmark, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No Saved Schemes',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          SizedBox(height: 8),
          Text(
            'Save schemes to view them here',
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/home');
            },
            child: Text('Explore Schemes'),
          ),
        ],
      ),
    );
  }
}
