import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/providers/index.dart';

/// Scheme Details Screen - Full details of a single scheme
class SchemeDetailsScreen extends ConsumerWidget {
  final String schemeId;

  const SchemeDetailsScreen({
    Key? key,
    required this.schemeId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch scheme details
    final schemeAsync = ref.watch(schemeByIdProvider(schemeId));
    
    // Watch if scheme is saved
    final isSaved = ref.watch(isSchemeSlvedProvider(schemeId));
    
    // Watch match score
    final matchScore = ref.watch(schemeMatchScoreProvider(schemeId));

    return Scaffold(
      appBar: AppBar(title: Text('Scheme Details')),
      body: schemeAsync.when(
        data: (scheme) {
          if (scheme == null) {
            return Center(child: Text('Scheme not found'));
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with title and match score
                Container(
                  color: Colors.blue[50],
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              scheme.title,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          ),
                          matchScore.whenData((score) {
                            return Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _getScoreColor(score),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Match: $score%',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }).value ?? SizedBox.shrink(),
                        ],
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Chip(label: Text(scheme.stateName)),
                          SizedBox(width: 8),
                          Chip(label: Text(scheme.categoryName)),
                        ],
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Description
                      _buildSection(
                        context,
                        'Description',
                        scheme.description,
                      ),

                      SizedBox(height: 24),

                      // Benefits
                      if (scheme.benefits != null)
                        _buildSection(
                          context,
                          'Benefits',
                          scheme.benefits!,
                        ),

                      SizedBox(height: 24),

                      // Eligibility
                      _buildEligibilitySection(context, scheme),

                      SizedBox(height: 24),

                      // Application Info
                      _buildApplicationSection(context, scheme),

                      SizedBox(height: 24),

                      // Last date to apply
                      if (scheme.lastDate != null)
                        _buildSection(
                          context,
                          'Last Date to Apply',
                          scheme.lastDate.toString().split(' ')[0],
                        ),

                      SizedBox(height: 32),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                ref
                                    .read(savedSchemeIdsProvider.notifier)
                                    .toggleSaveScheme(schemeId);
                              },
                              icon: Icon(
                                isSaved ? Icons.favorite : Icons.favorite_border,
                              ),
                              label: Text(
                                isSaved ? 'Saved' : 'Save Scheme',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isSaved ? Colors.red : null,
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // TODO: Open apply link
                              },
                              icon: Icon(Icons.open_in_browser),
                              label: Text('Apply Now'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text('Error loading scheme details'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        SizedBox(height: 8),
        Text(
          content,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildEligibilitySection(BuildContext context, dynamic scheme) {
    final eligibilities = <String>[];

    if (scheme.eligibilityAgeMin != null || scheme.eligibilityAgeMax != null) {
      eligibilities.add(
        'Age: ${scheme.eligibilityAgeMin ?? '18'} - ${scheme.eligibilityAgeMax ?? 'No limit'}',
      );
    }

    if (scheme.eligibilityGender != null) {
      eligibilities.add('Gender: ${scheme.eligibilityGender}');
    }

    if (eligibilities.isEmpty) {
      eligibilities.add('Check official website for eligibility');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Eligibility',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        SizedBox(height: 8),
        ...eligibilities.map((e) => Padding(
          padding: EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Icon(Icons.check_circle, size: 16, color: Colors.green),
              SizedBox(width: 8),
              Expanded(child: Text(e)),
            ],
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildApplicationSection(BuildContext context, dynamic scheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How to Apply',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.link, color: Colors.blue),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Visit official website',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ],
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }
}
