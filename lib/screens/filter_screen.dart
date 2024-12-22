import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../models/filter_option.dart';
import '../models/filter_section.dart';
import '../screens/results_screen.dart';
import '../services/filter_service.dart';
import '../view_models/filter_view_model.dart';

class FilterScreen extends StatelessWidget {
  const FilterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Filter Options',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Consumer<FilterViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return _buildLoadingShimmer();
          }

          if (viewModel.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${viewModel.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => viewModel.fetchFilters(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildSortBySection(viewModel),
                    const SizedBox(height: 24),
                    ...viewModel.sections.map((section) =>
                        _buildFilterSection(context, section, viewModel)),
                  ],
                ),
              ),
              _buildBottomButton(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSortBySection(FilterViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sort by',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        ...[
          'Nearest to Me (default)',
          'Trending this Week',
          'Newest Added',
          'Alphabetical'
        ].map((title) => _buildRadioTile(title, viewModel)),
      ],
    );
  }

  Widget _buildRadioTile(String title, FilterViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: viewModel.sortByDisplay == title
            ? Colors.purple.withOpacity(0.1)
            : Colors.transparent,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            color: viewModel.sortByDisplay == title
                ? Colors.purple
                : Colors.black87,
            fontWeight: viewModel.sortByDisplay == title
                ? FontWeight.w600
                : FontWeight.normal,
          ),
        ),
        leading: Radio<String>(
          value: title,
          groupValue: viewModel.sortByDisplay,
          onChanged: (value) => viewModel.setSortBy(value!),
          activeColor: Colors.purple,
        ),
      ),
    );
  }

  Widget _buildFilterSection(
      BuildContext context, FilterSection section, FilterViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            title: Text(
              section.selectedCount != null
                  ? '${section.title} (${section.selectedCount})'
                  : section.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            trailing: Icon(
              section.isExpanded ? Icons.expand_less : Icons.expand_more,
              color: Colors.purple,
            ),
            onTap: () => viewModel.toggleSection(section.title),
          ),
          if (section.isExpanded) ...[
            const Divider(height: 1),
            ...section.options.map(
              (option) => _buildCheckboxTile(option, section.title, viewModel),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCheckboxTile(
    FilterOption option,
    String sectionTitle,
    FilterViewModel viewModel,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: option.isSelected
            ? Colors.purple.withOpacity(0.1)
            : Colors.transparent,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        title: Text(
          option.title,
          style: TextStyle(
            fontSize: 16,
            color: option.isSelected ? Colors.purple : Colors.black87,
            fontWeight: option.isSelected ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
        leading: Checkbox(
          value: option.isSelected,
          onChanged: (value) => viewModel.toggleOption(sectionTitle, option.id),
          activeColor: Colors.purple,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButton() {
    return Consumer<FilterViewModel>(
      builder: (context, viewModel, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () async {
              final filters = viewModel.getFiltersForApi();
              try {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ResultsScreen(
                      results: [],
                      isLoading: true,
                    ),
                  ),
                );

                final results =
                    await FilterService().fetchFilteredResults(filters);

                if (context.mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ResultsScreen(
                        results: results,
                        isLoading: false,
                      ),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4B4B4B),
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(27),
              ),
              elevation: 0,
            ),
            child: Text(
              'SHOW ${viewModel.totalResults} RESULTS',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sort by section shimmer
            Container(
              height: 24,
              width: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 16),
            // Sort options shimmer
            ...List.generate(
              4,
              (index) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Filter sections shimmer
            ...List.generate(
              5,
              (index) => Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Container(
                      height: 56,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 120,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (index == 1) ...[
                      // Show some option items for one section
                      ...List.generate(
                        4,
                        (index) => Container(
                          height: 56,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Container(
                                width: 150,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
