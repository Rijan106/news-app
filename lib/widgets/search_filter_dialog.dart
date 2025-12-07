import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum DateFilter {
  all,
  today,
  thisWeek,
  thisMonth,
}

class SearchFilterDialog extends StatefulWidget {
  final DateFilter currentDateFilter;
  final List<String> selectedCategories;
  final List<String> availableCategories;

  const SearchFilterDialog({
    super.key,
    required this.currentDateFilter,
    required this.selectedCategories,
    required this.availableCategories,
  });

  @override
  State<SearchFilterDialog> createState() => _SearchFilterDialogState();
}

class _SearchFilterDialogState extends State<SearchFilterDialog> {
  late DateFilter _selectedDateFilter;
  late List<String> _selectedCategories;

  @override
  void initState() {
    super.initState();
    _selectedDateFilter = widget.currentDateFilter;
    _selectedCategories = List.from(widget.selectedCategories);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filters',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Date Filter Section
            Text(
              'Date Range',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _buildDateChip('All Time', DateFilter.all),
                _buildDateChip('Today', DateFilter.today),
                _buildDateChip('This Week', DateFilter.thisWeek),
                _buildDateChip('This Month', DateFilter.thisMonth),
              ],
            ),

            const SizedBox(height: 24),

            // Category Filter Section
            Text(
              'Categories',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),

            // Categories list
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: widget.availableCategories.map((category) {
                    final isSelected = _selectedCategories.contains(category);
                    return CheckboxListTile(
                      title: Text(
                        category,
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                      value: isSelected,
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            _selectedCategories.add(category);
                          } else {
                            _selectedCategories.remove(category);
                          }
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      dense: true,
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedDateFilter = DateFilter.all;
                      _selectedCategories.clear();
                    });
                  },
                  child: const Text('Clear All'),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, {
                          'dateFilter': _selectedDateFilter,
                          'categories': _selectedCategories,
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                      ),
                      child: const Text('Apply'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateChip(String label, DateFilter filter) {
    final isSelected = _selectedDateFilter == filter;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedDateFilter = filter;
        });
      },
      selectedColor: Theme.of(context).colorScheme.primary,
      labelStyle: TextStyle(
        color: isSelected
            ? Theme.of(context).colorScheme.onPrimary
            : Theme.of(context).colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
}

// Helper function to get date range
DateTime? getDateFromFilter(DateFilter filter) {
  final now = DateTime.now();
  switch (filter) {
    case DateFilter.today:
      return DateTime(now.year, now.month, now.day);
    case DateFilter.thisWeek:
      return now.subtract(const Duration(days: 7));
    case DateFilter.thisMonth:
      return DateTime(now.year, now.month, 1);
    case DateFilter.all:
      return null;
  }
}
