import 'package:flutter/material.dart';

class SearchProvider extends ChangeNotifier {
  String _searchQuery = '';
  String _sortOrder = 'Newest';
  String _selectedCategory = 'All';
  DateTime? _startDate;
  DateTime? _endDate;

  String get searchQuery => _searchQuery;
  String get sortOrder => _sortOrder;
  String get selectedCategory => _selectedCategory;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void updateSortOrder(String order) {
    _sortOrder = order;
    notifyListeners();
  }

  void updateCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void updateDateRange(DateTime? start, DateTime? end) {
    _startDate = start;
    _endDate = end;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _sortOrder = 'Newest';
    _selectedCategory = 'All';
    _startDate = null;
    _endDate = null;
    notifyListeners();
  }

  bool get hasActiveFilters =>
      _searchQuery.isNotEmpty ||
      _selectedCategory != 'All' ||
      _startDate != null ||
      _endDate != null;

  List<String> get availableCategories => [
        'All',
        'Technology',
        'Business',
        'Sports',
        'Entertainment',
        'Health',
        'Science',
        'Politics',
        'Education',
        'World',
        'Local'
      ];

  List<String> get sortOptions => ['Newest', 'Oldest', 'Most Popular', 'A-Z'];
}
