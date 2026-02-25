import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/providers/index.dart';

/// Search Screen - Search and filter schemes
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late TextEditingController _searchController;
  String _selectedCategory = '';
  String _selectedState = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch search results
    final searchResults = ref.watch(searchResultsProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final isLoading = ref.watch(searchLoadingProvider);
    final categories = ref.watch(schemseCategoriesProvider);
    final states = ref.watch(schemesStatesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Search Schemes'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search input
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search schemes...',
                prefixIcon: Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    ref.read(searchProvider.notifier).clearSearch();
                  },
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (query) {
                setState(() {});
                if (query.isNotEmpty) {
                  ref.read(searchProvider.notifier).search(query);
                } else {
                  ref.read(searchProvider.notifier).clearSearch();
                }
              },
            ),
          ),

          // Filters
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: categories.when(
                    data: (cats) => DropdownButton<String>(
                      value: _selectedCategory.isEmpty ? null : _selectedCategory,
                      hint: Text('Category'),
                      isExpanded: true,
                      items: [
                        DropdownMenuItem(
                          value: '',
                          child: Text('All Categories'),
                        ),
                        ...cats.map((cat) {
                          return DropdownMenuItem(
                            value: cat,
                            child: Text(cat),
                          );
                        }).toList(),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedCategory = value ?? '');
                      },
                    ),
                    loading: () => CircularProgressIndicator(),
                    error: (e, s) => Text('Error'),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: states.when(
                    data: (stateList) => DropdownButton<String>(
                      value: _selectedState.isEmpty ? null : _selectedState,
                      hint: Text('State'),
                      isExpanded: true,
                      items: [
                        DropdownMenuItem(
                          value: '',
                          child: Text('All States'),
                        ),
                        ...stateList.map((state) {
                          return DropdownMenuItem(
                            value: state,
                            child: Text(state),
                          );
                        }).toList(),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedState = value ?? '');
                      },
                    ),
                    loading: () => CircularProgressIndicator(),
                    error: (e, s) => Text('Error'),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16),

          // Results
          if (isLoading)
            Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (searchQuery.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('Search for schemes'),
                  ],
                ),
              ),
            )
          else if (searchResults.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('No schemes found for "$searchQuery"'),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16),
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  final scheme = searchResults[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
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
                            children: [
                              Chip(label: Text(scheme.stateName)),
                              SizedBox(width: 8),
                              Chip(label: Text(scheme.categoryName)),
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
              ),
            ),
        ],
      ),
    );
  }
}
