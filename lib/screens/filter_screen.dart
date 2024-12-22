import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../constants/color_palette.dart';
import '../constants/size_constants.dart';
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
      backgroundColor: ColorPalette.white,
      appBar: AppBar(
        backgroundColor: ColorPalette.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Filter Options',
          style: TextStyle(
            color: ColorPalette.black,
            fontSize: Sizes.fontTitle,
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
                      color: ColorPalette.textError,
                      fontSize: Sizes.fontBody,
                    ),
                  ),
                  const SizedBox(height: Sizes.spacing),
                  ElevatedButton(
                    onPressed: () => viewModel.fetchFilters(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorPalette.purple,
                      padding: const EdgeInsets.symmetric(
                        horizontal: Sizes.paddingHorizontal,
                        vertical: Sizes.paddingVertical,
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
                  padding: const EdgeInsets.all(Sizes.padding),
                  children: [
                    _buildSortBySection(viewModel),
                    const SizedBox(height: Sizes.spacingLarge),
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
            fontSize: Sizes.fontTitle,
            fontWeight: FontWeight.w600,
            color: ColorPalette.textPrimary,
          ),
        ),
        const SizedBox(height: Sizes.spacing),
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
      margin: const EdgeInsets.only(bottom: Sizes.spacingSmall),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Sizes.radiusMedium),
        color: viewModel.sortByDisplay == title
            ? ColorPalette.purpleOverlay
            : Colors.transparent,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: Sizes.padding),
        title: Text(
          title,
          style: TextStyle(
            fontSize: Sizes.fontBody,
            color: viewModel.sortByDisplay == title
                ? ColorPalette.purple
                : ColorPalette.textPrimary,
            fontWeight: viewModel.sortByDisplay == title
                ? FontWeight.w600
                : FontWeight.normal,
          ),
        ),
        leading: Radio<String>(
          value: title,
          groupValue: viewModel.sortByDisplay,
          onChanged: (value) => viewModel.setSortBy(value!),
          activeColor: ColorPalette.purple,
        ),
      ),
    );
  }

  Widget _buildFilterSection(
      BuildContext context, FilterSection section, FilterViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.only(bottom: Sizes.spacing),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Sizes.radiusMedium),
        border: Border.all(color: ColorPalette.borderColor),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: Sizes.padding),
            title: Text(
              section.selectedCount != null
                  ? '${section.title} (${section.selectedCount})'
                  : section.title,
              style: const TextStyle(
                fontSize: Sizes.fontSectionTitle,
                fontWeight: FontWeight.w600,
                color: ColorPalette.textPrimary,
              ),
            ),
            trailing: Icon(
              section.isExpanded ? Icons.expand_less : Icons.expand_more,
              color: ColorPalette.purple,
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
        color:
            option.isSelected ? ColorPalette.purpleOverlay : Colors.transparent,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: Sizes.padding),
        title: Text(
          option.title,
          style: TextStyle(
            fontSize: Sizes.fontBody,
            color: option.isSelected
                ? ColorPalette.purple
                : ColorPalette.textPrimary,
            fontWeight: option.isSelected ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
        leading: Checkbox(
          value: option.isSelected,
          onChanged: (value) => viewModel.toggleOption(sectionTitle, option.id),
          activeColor: ColorPalette.purple,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Sizes.radiusSmall),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButton() {
    return Consumer<FilterViewModel>(
      builder: (context, viewModel, child) {
        return Container(
          padding: const EdgeInsets.all(Sizes.padding),
          decoration: BoxDecoration(
            color: ColorPalette.white,
            boxShadow: [
              BoxShadow(
                color: ColorPalette.shadowColor,
                blurRadius: Sizes.shadowBlur,
                offset: const Offset(0, -Sizes.shadowOffset),
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
                    await FilterService().getFilteredResults(filters);

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
              backgroundColor: ColorPalette.buttonPrimary,
              minimumSize: const Size(double.infinity, Sizes.buttonHeight),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Sizes.radiusButton),
              ),
              elevation: 0,
            ),
            child: Text(
              'SHOW ${viewModel.totalResults} RESULTS',
              style: const TextStyle(
                color: ColorPalette.white,
                fontSize: Sizes.fontBody,
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
      baseColor: ColorPalette.shimmerBase,
      highlightColor: ColorPalette.shimmerHighlight,
      child: Padding(
        padding: const EdgeInsets.all(Sizes.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sort by section shimmer
            Container(
              height: Sizes.shimmerTitleHeight,
              width: Sizes.shimmerTitleWidth,
              decoration: BoxDecoration(
                color: ColorPalette.white,
                borderRadius: BorderRadius.circular(Sizes.radiusSmall),
              ),
            ),
            const SizedBox(height: Sizes.spacing),
            // Sort options shimmer
            ...List.generate(
              4,
              (index) => Container(
                margin: const EdgeInsets.only(bottom: Sizes.spacingSmall),
                height: Sizes.listTileHeight,
                decoration: BoxDecoration(
                  color: ColorPalette.white,
                  borderRadius: BorderRadius.circular(Sizes.radiusMedium),
                ),
              ),
            ),
            const SizedBox(height: Sizes.spacingLarge),
            // Filter sections shimmer
            ...List.generate(
              5,
              (index) => Container(
                margin: const EdgeInsets.only(bottom: Sizes.spacing),
                decoration: BoxDecoration(
                  color: ColorPalette.white,
                  borderRadius: BorderRadius.circular(Sizes.radiusMedium),
                ),
                child: Column(
                  children: [
                    Container(
                      height: Sizes.listTileHeight,
                      padding:
                          const EdgeInsets.symmetric(horizontal: Sizes.padding),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: Sizes.shimmerOptionWidth,
                            height: Sizes.shimmerTitleHeight,
                            decoration: BoxDecoration(
                              color: ColorPalette.white,
                              borderRadius:
                                  BorderRadius.circular(Sizes.radiusSmall),
                            ),
                          ),
                          Container(
                            width: Sizes.shimmerIconSize,
                            height: Sizes.shimmerIconSize,
                            decoration: const BoxDecoration(
                              color: ColorPalette.white,
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
                          height: Sizes.listTileHeight,
                          padding: const EdgeInsets.symmetric(
                              horizontal: Sizes.padding),
                          child: Row(
                            children: [
                              Container(
                                width: Sizes.shimmerIconSize,
                                height: Sizes.shimmerIconSize,
                                decoration: const BoxDecoration(
                                  color: ColorPalette.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: Sizes.spacing),
                              Container(
                                width: Sizes.shimmerTextWidth,
                                height: Sizes.shimmerOptionHeight,
                                decoration: BoxDecoration(
                                  color: ColorPalette.white,
                                  borderRadius:
                                      BorderRadius.circular(Sizes.radiusSmall),
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
