import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/mutual_funds_controller.dart';
import 'widgets/mf_groww_widgets.dart';

/// Dedicated Full-Screen Filter View with Groww-style dual-column layout
/// Supports Sort by (Popularity, 1Y, 3Y, 5Y Returns, Rating),
/// Collapsible Category Dropdowns with auto-select subcategories,
/// Risk levels, and Rating filters.
class MfFilterView extends StatefulWidget {
  const MfFilterView({Key? key}) : super(key: key);

  @override
  State<MfFilterView> createState() => _MfFilterViewState();
}

class _MfFilterViewState extends State<MfFilterView> {
  final MutualFundsController controller = Get.find<MutualFundsController>();
  int _activeTabIndex = 0; // 0: Sort by, 1: Category, 2: Risk, 3: Ratings

  // Local draft copies so changes apply only when user taps "Apply"
  late String _draftSort;
  late Set<String> _draftCategories;
  late Set<String> _draftSubCategories;
  late Set<String> _draftRisks;
  late Set<int> _draftRatings;

  // Track expanded category dropdowns - initially empty so all dropdowns start collapsed
  final Set<String> _expandedCategories = <String>{};

  final Map<String, List<String>> _categorySubCategories = const {
    'Equity': [
      'Flexi Cap',
      'Large Cap',
      'Mid Cap',
      'Small Cap',
      'International',
      'ELSS Tax Saver (Sec 80C)',
      'Equity Fund',
    ],
    'Debt': [
      'Liquid Fund',
      'Debt / Fixed Income',
    ],
    'Hybrid': [
      'Dynamic Asset Allocation',
    ],
    'Gold & Commodity': [
      'Gold ETF FoF',
    ],
    'Index': [
      'Index / Passive ETF',
    ],
  };

  final List<String> _risksList = const [
    'Low',
    'Moderately Low',
    'Moderate',
    'Moderately High',
    'High',
    'Very High',
  ];

  final List<int> _ratingsList = const [5, 4, 3];

  final List<String> _sortOptions = const [
    'Popularity',
    '1Y Returns',
    '3Y Returns',
    '5Y Returns',
    'Rating',
  ];

  @override
  void initState() {
    super.initState();
    _draftSort = controller.allMfSort.value;
    _draftCategories = Set<String>.from(controller.allMfCategories);
    _draftSubCategories = Set<String>.from(controller.allMfSubCategories);
    _draftRisks = Set<String>.from(controller.allMfRisks);
    _draftRatings = Set<int>.from(controller.allMfRatings);
  }

  void _applyFilters() {
    controller.allMfSort.value = _draftSort;
    controller.allMfCategories.assignAll(_draftCategories);
    controller.allMfSubCategories.assignAll(_draftSubCategories);
    controller.allMfRisks.assignAll(_draftRisks);
    controller.allMfRatings.assignAll(_draftRatings);
    controller.fetchAllSchemes(isRefresh: true);
    Get.back();
  }

  void _clearAll() {
    setState(() {
      _draftSort = 'Popularity';
      _draftCategories.clear();
      _draftSubCategories.clear();
      _draftRisks.clear();
      _draftRatings.clear();
      _expandedCategories.clear(); // Re-collapse all dropdowns on clear
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GrowwColors.background,
      appBar: AppBar(
        backgroundColor: GrowwColors.cardElevated,
        elevation: 0,
        title: const Text(
          'Filters',
          style: TextStyle(
            color: GrowwColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: GrowwColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        actions: [
          TextButton(
            onPressed: _clearAll,
            child: const Text(
              'Clear all',
              style: TextStyle(
                color: GrowwColors.mintTeal,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Row(
        children: [
          // ── Left Column: Categories Navigation ──
          Container(
            width: 130,
            decoration: const BoxDecoration(
              color: GrowwColors.card,
              border: Border(right: BorderSide(color: GrowwColors.border)),
            ),
            child: ListView(
              children: [
                _buildLeftTab(
                  0,
                  'Sort by',
                  badge: _draftSort != 'Popularity' ? '1' : null,
                ),
                _buildLeftTab(
                  1,
                  'Category',
                  badge: (_draftCategories.length + _draftSubCategories.length) > 0
                      ? '${_draftCategories.length + _draftSubCategories.length}'
                      : null,
                ),
                _buildLeftTab(
                  2,
                  'Risk',
                  badge: _draftRisks.isNotEmpty ? '${_draftRisks.length}' : null,
                ),
                _buildLeftTab(
                  3,
                  'Ratings',
                  badge: _draftRatings.isNotEmpty ? '${_draftRatings.length}' : null,
                ),
              ],
            ),
          ),

          // ── Right Column: Options Panel ──
          Expanded(
            child: Container(
              color: GrowwColors.background,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: _buildRightOptions(),
            ),
          ),
        ],
      ),

      // ── Bottom Bar: Fully Inset-Safe Sticky Apply Button ──
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: GrowwColors.cardElevated,
          border: Border(top: BorderSide(color: GrowwColors.border, width: 1)),
        ),
        child: SafeArea(
          top: false,
          bottom: true,
          child: Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: MediaQuery.of(context).padding.bottom > 0 ? 8 : 16,
            ),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: GrowwColors.mintTeal,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                onPressed: _applyFilters,
                child: const Text(
                  'Apply Filters',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeftTab(int index, String title, {String? badge}) {
    final isSelected = _activeTabIndex == index;
    return InkWell(
      onTap: () => setState(() => _activeTabIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
        decoration: BoxDecoration(
          color: isSelected ? GrowwColors.background : GrowwColors.card,
          border: Border(
            left: BorderSide(
              color: isSelected ? GrowwColors.mintTeal : Colors.transparent,
              width: 3.5,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isSelected ? GrowwColors.textPrimary : GrowwColors.textSecondary,
                  fontSize: 13.5,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: GrowwColors.mintTeal,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRightOptions() {
    switch (_activeTabIndex) {
      case 0:
        return _buildSortOptions();
      case 1:
        return _buildCategoryOptions();
      case 2:
        return _buildRiskOptions();
      case 3:
        return _buildRatingOptions();
      default:
        return const SizedBox.shrink();
    }
  }

  // ── 1. Sort By Radio Options (Includes Popularity) ──
  Widget _buildSortOptions() {
    return ListView(
      children: _sortOptions.map((opt) {
        final isSelected = _draftSort == opt;
        return RadioListTile<String>(
          value: opt,
          groupValue: _draftSort,
          activeColor: GrowwColors.mintTeal,
          contentPadding: EdgeInsets.zero,
          title: Text(
            opt,
            style: TextStyle(
              color: isSelected ? GrowwColors.mintTeal : GrowwColors.textPrimary,
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
          onChanged: (val) {
            if (val != null) {
              setState(() => _draftSort = val);
            }
          },
        );
      }).toList(),
    );
  }

  // ── 2. Collapsible Category & Sub-Category Checkboxes ──
  Widget _buildCategoryOptions() {
    return ListView(
      children: _categorySubCategories.entries.map((entry) {
        final cat = entry.key;
        final subCats = entry.value;
        final isExpanded = _expandedCategories.contains(cat);

        // Check if all subcategories are currently selected
        final allSubsSelected = subCats.isNotEmpty && subCats.every((s) => _draftSubCategories.contains(s));
        final isCatSelected = _draftCategories.contains(cat) || allSubsSelected;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Header Row with Checkbox & Dropdown arrow
            InkWell(
              onTap: () {
                // Tapping row toggles collapse / expand
                setState(() {
                  if (isExpanded) {
                    _expandedCategories.remove(cat);
                  } else {
                    _expandedCategories.add(cat);
                  }
                });
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                child: Row(
                  children: [
                    Checkbox(
                      value: isCatSelected,
                      activeColor: GrowwColors.mintTeal,
                      checkColor: Colors.black,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                      onChanged: (val) {
                        setState(() {
                          if (val == true) {
                            _draftCategories.add(cat);
                            // When user selects category (e.g. Equity), select all of its subcategories!
                            _draftSubCategories.addAll(subCats);
                            // Auto-expand so the user immediately sees all selected subcategories
                            _expandedCategories.add(cat);
                          } else {
                            _draftCategories.remove(cat);
                            // Unselect all its subcategories
                            _draftSubCategories.removeAll(subCats);
                          }
                        });
                      },
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        cat,
                        style: TextStyle(
                          color: isCatSelected ? GrowwColors.mintTeal : GrowwColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Dropdown chevron icon (down when collapsed, up when expanded)
                    IconButton(
                      icon: Icon(
                        isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                        color: isExpanded ? GrowwColors.mintTeal : GrowwColors.textSecondary,
                        size: 22,
                      ),
                      onPressed: () {
                        setState(() {
                          if (isExpanded) {
                            _expandedCategories.remove(cat);
                          } else {
                            _expandedCategories.add(cat);
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Indented Sub-categories shown only when dropdown is expanded
            if (isExpanded) ...[
              Padding(
                padding: const EdgeInsets.only(left: 28, bottom: 8),
                child: Column(
                  children: subCats.map((sub) {
                    final isSubSelected = _draftSubCategories.contains(sub);
                    return InkWell(
                      onTap: () {
                        setState(() {
                          if (isSubSelected) {
                            _draftSubCategories.remove(sub);
                            if (!subCats.any((s) => _draftSubCategories.contains(s))) {
                              _draftCategories.remove(cat);
                            }
                          } else {
                            _draftSubCategories.add(sub);
                            _draftCategories.add(cat);
                          }
                        });
                      },
                      borderRadius: BorderRadius.circular(6),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Checkbox(
                              value: isSubSelected,
                              activeColor: GrowwColors.mintTeal,
                              checkColor: Colors.black,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                              onChanged: (val) {
                                setState(() {
                                  if (val == true) {
                                    _draftSubCategories.add(sub);
                                    _draftCategories.add(cat);
                                  } else {
                                    _draftSubCategories.remove(sub);
                                    if (!subCats.any((s) => _draftSubCategories.contains(s))) {
                                      _draftCategories.remove(cat);
                                    }
                                  }
                                });
                              },
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                sub,
                                style: TextStyle(
                                  color: isSubSelected ? GrowwColors.mintTeal : GrowwColors.textSecondary,
                                  fontSize: 12.5,
                                  fontWeight: isSubSelected ? FontWeight.bold : FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
            const Divider(color: GrowwColors.border, height: 1),
          ],
        );
      }).toList(),
    );
  }

  // ── 3. Risk Level Checkboxes ──
  Widget _buildRiskOptions() {
    return ListView(
      children: _risksList.map((risk) {
        final isSelected = _draftRisks.contains(risk);
        return CheckboxListTile(
          value: isSelected,
          activeColor: GrowwColors.mintTeal,
          checkColor: Colors.black,
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          title: Text(
            risk,
            style: TextStyle(
              color: isSelected ? GrowwColors.mintTeal : GrowwColors.textPrimary,
              fontSize: 13.5,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
          onChanged: (val) {
            setState(() {
              if (val == true) {
                _draftRisks.add(risk);
              } else {
                _draftRisks.remove(risk);
              }
            });
          },
        );
      }).toList(),
    );
  }

  // ── 4. Rating Checkboxes ──
  Widget _buildRatingOptions() {
    return ListView(
      children: _ratingsList.map((r) {
        final isSelected = _draftRatings.contains(r);
        return CheckboxListTile(
          value: isSelected,
          activeColor: GrowwColors.mintTeal,
          checkColor: Colors.black,
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          title: Row(
            children: [
              Text(
                r == 5 ? '5 Star' : '$r+ Star',
                style: TextStyle(
                  color: isSelected ? GrowwColors.mintTeal : GrowwColors.textPrimary,
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              Row(
                children: List.generate(5, (i) {
                  return Icon(
                    i < r ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: const Color(0xFFF5A623),
                    size: 16,
                  );
                }),
              ),
            ],
          ),
          onChanged: (val) {
            setState(() {
              if (val == true) {
                _draftRatings.add(r);
              } else {
                _draftRatings.remove(r);
              }
            });
          },
        );
      }).toList(),
    );
  }
}
