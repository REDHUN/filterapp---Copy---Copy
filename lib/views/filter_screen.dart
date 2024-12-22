import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../models/filter_option.dart';
import '../models/filter_section.dart';
import '../view_models/filter_view_model.dart';
import '../widgets/no_internet_screen.dart';

class FilterScreen extends StatelessWidget {
  const FilterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Filter Options',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 28,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: Consumer<FilterViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const LoadingShimmer();
          }

          if (viewModel.error != null) {
            return NoInternetScreen(
              onRetry: viewModel.fetchFilters,
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SelectedFiltersSection(viewModel: viewModel),
              SortBySection(viewModel: viewModel),
              const SizedBox(height: 24),
              ...viewModel.sections.map((section) =>
                  FilterSectionWidget(section: section, viewModel: viewModel)),
            ],
          );
        },
      ),
      floatingActionButton: const ResultsButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class SortBySection extends StatelessWidget {
  final FilterViewModel viewModel;

  const SortBySection({Key? key, required this.viewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sort by',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 16),
        ...[
          'Nearest to Me (default)',
          'Trending this Week',
          'Newest Added',
          'Alphabetical'
        ].map((title) => SortRadioTile(title: title, viewModel: viewModel)),
      ],
    );
  }
}

class SortRadioTile extends StatelessWidget {
  final String title;
  final FilterViewModel viewModel;

  const SortRadioTile({
    Key? key,
    required this.title,
    required this.viewModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSelected = viewModel.sortByDisplay == title;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 17,
            color: isSelected ? Colors.grey[800] : Colors.black87,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            letterSpacing: -0.3,
          ),
        ),
        leading: Theme(
          data: ThemeData(
            unselectedWidgetColor: Colors.grey[400],
          ),
          child: Radio<String>(
            value: title,
            groupValue: viewModel.sortByDisplay,
            onChanged: (value) => viewModel.setSortBy(value!),
            activeColor: Colors.grey[800],
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ),
    );
  }
}

class FilterSectionWidget extends StatelessWidget {
  final FilterSection section;
  final FilterViewModel viewModel;

  const FilterSectionWidget({
    Key? key,
    required this.section,
    required this.viewModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate selected count for this section
    final selectedCount =
        section.options.where((option) => option.isSelected).length;
    final showCount = selectedCount > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              showCount ? '${section.title} ($selectedCount)' : section.title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
                letterSpacing: -0.5,
                height: 1.2,
              ),
            ),
            trailing: Icon(
              section.isExpanded ? Icons.expand_less : Icons.expand_more,
              color: Colors.grey[600],
            ),
            onTap: () => viewModel.toggleSection(section.title),
          ),
          if (section.isExpanded)
            ...section.options.map((option) => FilterOptionTile(
                option: option,
                sectionTitle: section.title,
                viewModel: viewModel)),
        ],
      ),
    );
  }
}

class FilterOptionTile extends StatelessWidget {
  final FilterOption option;
  final String sectionTitle;
  final FilterViewModel viewModel;

  const FilterOptionTile({
    Key? key,
    required this.option,
    required this.sectionTitle,
    required this.viewModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        option.title,
        style: TextStyle(
          fontSize: 17,
          color: option.isSelected ? Colors.grey[800] : Colors.black87,
          fontWeight: option.isSelected ? FontWeight.w600 : FontWeight.w400,
          letterSpacing: -0.3,
          height: 1.2,
        ),
      ),
      leading: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => viewModel.toggleOption(sectionTitle, option.id),
        child: Theme(
          data: ThemeData(
            unselectedWidgetColor: Colors.grey[400],
          ),
          child: Radio<String>(
            value: option.id,
            groupValue: option.isSelected ? option.id : null,
            onChanged: null,
            activeColor: Colors.grey[800],
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ),
      onTap: () => viewModel.toggleOption(sectionTitle, option.id),
    );
  }
}

class LoadingShimmer extends StatelessWidget {
  const LoadingShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sort by section shimmer
            Container(
              width: 100,
              height: 28,
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
                margin: const EdgeInsets.only(bottom: 12),
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Filter sections shimmer
            ...List.generate(
              6,
              (index) => Container(
                margin: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section title
                    Container(
                      width: 200,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Section options
                    if (index == 1) // Show options for one section
                      ...List.generate(
                        5,
                        (index) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
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

class ResultsButton extends StatelessWidget {
  const ResultsButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<FilterViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.totalResults == 0) return const SizedBox.shrink();
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: FloatingActionButton.extended(
            onPressed: () async {
              // Implement results navigation
            },
            backgroundColor: const Color(0xFF4B4B4B),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(27),
            ),
            label: Text(
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
}

class SelectedFiltersSection extends StatelessWidget {
  final FilterViewModel viewModel;

  const SelectedFiltersSection({
    Key? key,
    required this.viewModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final selectedOptions = <FilterOption>[];

    // Gather all selected options
    for (var section in viewModel.sections) {
      selectedOptions.addAll(
        section.options.where((option) => option.isSelected),
      );
    }

    if (selectedOptions.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: selectedOptions.map((option) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(4),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () {
                    // Find the section this option belongs to
                    final section = viewModel.sections.firstWhere(
                      (section) => section.options.contains(option),
                    );
                    viewModel.toggleOption(section.title, option.id);
                  },
                  child: Icon(
                    Icons.close,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  option.title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[800],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
