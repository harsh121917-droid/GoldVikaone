import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/api_client.dart';
import '../../../data/models/mf_scheme_model.dart';
import '../controllers/mutual_funds_controller.dart';
import 'mf_scheme_detail_view.dart';
import 'widgets/mf_groww_widgets.dart';

class MfCollectionListView extends StatefulWidget {
  final String collectionId;
  final String title;
  final String? iconAsset;

  const MfCollectionListView({
    super.key,
    required this.collectionId,
    required this.title,
    this.iconAsset,
  });

  @override
  State<MfCollectionListView> createState() => _MfCollectionListViewState();
}

class _MfCollectionListViewState extends State<MfCollectionListView> {
  final MutualFundsController controller = Get.find<MutualFundsController>();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  List<MfSchemeModel> _schemes = [];
  bool _isLoading = true;
  String _returnPeriod = '3Y';
  String _searchQuery = '';
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Color get _accentColor {
    switch (widget.collectionId) {
      case 'high_return':
        return const Color(0xFF00D09C);
      case 'sip_100':
        return const Color(0xFF00B4D8);
      case 'gold_silver':
        return const Color(0xFFFFB703);
      case 'large_cap':
        return const Color(0xFF3A86FF);
      case 'mid_cap':
        return const Color(0xFF8338EC);
      case 'small_cap':
        return const Color(0xFFFF006E);
      default:
        return const Color(0xFF00D09C);
    }
  }

  String get _collectionSubtitle {
    switch (widget.collectionId) {
      case 'high_return':
        return 'Funds with consistent high historical returns';
      case 'sip_100':
        return 'Start investing with as low as ₹100 per month';
      case 'gold_silver':
        return 'Funds investing in precious commodities & ETFs';
      case 'large_cap':
        return 'Funds with investments in top 100 large cap companies';
      case 'mid_cap':
        return 'Funds with investments in mid cap companies';
      case 'small_cap':
        return 'Funds with majority investments in small cap companies';
      default:
        return 'Curated funds handpicked for you';
    }
  }

  String get _collectionIconAsset {
    if (widget.iconAsset != null && widget.iconAsset!.isNotEmpty) {
      return widget.iconAsset!;
    }
    switch (widget.collectionId) {
      case 'high_return':
        return 'assets/images/Mutual_Funds/mf_icon_high_return.jpg';
      case 'sip_100':
        return 'assets/images/Mutual_Funds/mf_wallet_sip_3d.jpg';
      case 'gold_silver':
        return 'assets/images/Mutual_Funds/mf_gold_silver_3d.jpg';
      case 'large_cap':
        return 'assets/images/Mutual_Funds/mf_icon_large_cap.jpg';
      case 'mid_cap':
        return 'assets/images/Mutual_Funds/mf_icon_mid_cap.jpg';
      case 'small_cap':
        return 'assets/images/Mutual_Funds/mf_icon_small_cap.jpg';
      default:
        return 'assets/images/Mutual_Funds/mf_icon_small_cap.jpg';
    }
  }

  IconData get _collectionIcon {
    switch (widget.collectionId) {
      case 'high_return':
        return Icons.trending_up_rounded;
      case 'sip_100':
        return Icons.savings_rounded;
      case 'gold_silver':
        return Icons.monetization_on_rounded;
      case 'large_cap':
        return Icons.business_rounded;
      case 'mid_cap':
        return Icons.show_chart_rounded;
      case 'small_cap':
        return Icons.storefront_rounded;
      default:
        return Icons.auto_awesome_rounded;
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final dio = ApiClient.instance;
      List<MfSchemeModel> fetched = [];

      switch (widget.collectionId) {
        case 'high_return':
          final res = await dio.get('/mutual-funds/schemes', queryParameters: {
            'sort': 'returns3y',
            'limit': 40,
          });
          if (res.statusCode == 200 && res.data['success'] == true) {
            fetched = (res.data['data'] as List<dynamic>?)
                    ?.map((e) => MfSchemeModel.fromJson(e as Map<String, dynamic>))
                    .toList() ??
                [];
          }
          break;

        case 'sip_100':
          final res = await dio.get('/mutual-funds/schemes', queryParameters: {
            'sort': 'popularity',
            'limit': 40,
          });
          if (res.statusCode == 200 && res.data['success'] == true) {
            fetched = (res.data['data'] as List<dynamic>?)
                    ?.map((e) => MfSchemeModel.fromJson(e as Map<String, dynamic>))
                    .toList() ??
                [];
          }
          break;

        case 'gold_silver':
          final results = await Future.wait([
            dio.get('/mutual-funds/schemes', queryParameters: {'search': 'Gold', 'limit': 30}),
            dio.get('/mutual-funds/schemes', queryParameters: {'search': 'Silver', 'limit': 30}),
          ]);
          final List<MfSchemeModel> combined = [];
          for (final res in results) {
            if (res.statusCode == 200 && res.data['success'] == true) {
              final list = (res.data['data'] as List<dynamic>?)
                      ?.map((e) => MfSchemeModel.fromJson(e as Map<String, dynamic>))
                      .toList() ??
                  [];
              combined.addAll(list);
            }
          }
          final seenCodes = <String>{};
          for (final s in combined) {
            if (seenCodes.add(s.schemeCode)) {
              fetched.add(s);
            }
          }
          break;

        case 'large_cap':
          final res = await dio.get('/mutual-funds/schemes', queryParameters: {
            'subCategory': 'Large Cap',
            'limit': 50,
          });
          if (res.statusCode == 200 && res.data['success'] == true) {
            fetched = (res.data['data'] as List<dynamic>?)
                    ?.map((e) => MfSchemeModel.fromJson(e as Map<String, dynamic>))
                    .toList() ??
                [];
          }
          break;

        case 'mid_cap':
          final res = await dio.get('/mutual-funds/schemes', queryParameters: {
            'subCategory': 'Mid Cap',
            'limit': 50,
          });
          if (res.statusCode == 200 && res.data['success'] == true) {
            fetched = (res.data['data'] as List<dynamic>?)
                    ?.map((e) => MfSchemeModel.fromJson(e as Map<String, dynamic>))
                    .toList() ??
                [];
          }
          break;

        case 'small_cap':
          final res = await dio.get('/mutual-funds/schemes', queryParameters: {
            'subCategory': 'Small Cap',
            'limit': 50,
          });
          if (res.statusCode == 200 && res.data['success'] == true) {
            fetched = (res.data['data'] as List<dynamic>?)
                    ?.map((e) => MfSchemeModel.fromJson(e as Map<String, dynamic>))
                    .toList() ??
                [];
          }
          break;

        default:
          final res = await dio.get('/mutual-funds/schemes', queryParameters: {
            'limit': 50,
          });
          if (res.statusCode == 200 && res.data['success'] == true) {
            fetched = (res.data['data'] as List<dynamic>?)
                    ?.map((e) => MfSchemeModel.fromJson(e as Map<String, dynamic>))
                    .toList() ??
                [];
          }
      }

      if (mounted) {
        setState(() {
          _schemes = _curateFlagshipSchemes(fetched);
        });
      }
    } catch (e) {
      debugPrint('[MfCollectionListView] _loadData error: $e');
      if (_schemes.isEmpty && mounted) {
        _applyLocalFallback();
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<MfSchemeModel> _curateFlagshipSchemes(List<MfSchemeModel> rawList) {
    if (widget.collectionId == 'small_cap') {
      // Exact flagship priority order matching Groww catalogue
      const growwPriorityCodes = [
        '147920', // ITI Small Cap Fund
        '147944', // Bandhan Small Cap Fund
        '145139', // Invesco India Small Cap Fund
        '145677', // Bank of India Small Cap Fund
        '100177', // Quant Small Cap Fund
        '125350', // Axis Small Cap Fund
        '113177', // Nippon India Small Cap Fund
        '152232', // Motilal Oswal Small Cap Fund
        '154102', // Groww Small Cap Fund
      ];

      final Map<String, MfSchemeModel> codeMap = {
        for (final s in rawList) s.schemeCode: s,
      };

      final List<MfSchemeModel> curated = [];
      final Set<String> seenAmcs = {};

      // 1. Add Groww flagship funds first
      for (final code in growwPriorityCodes) {
        if (codeMap.containsKey(code)) {
          final s = codeMap[code]!;
          curated.add(s);
          seenAmcs.add(s.amcName.trim().toLowerCase());
        }
      }

      // 2. Add remaining unique AMCs, sorted by 3Y returns
      final remaining = rawList
          .where((s) => !growwPriorityCodes.contains(s.schemeCode))
          .toList()
        ..sort((a, b) => b.cagr3Y.compareTo(a.cagr3Y));

      for (final s in remaining) {
        final amcKey = s.amcName.trim().toLowerCase();
        if (!seenAmcs.contains(amcKey)) {
          seenAmcs.add(amcKey);
          curated.add(s);
        }
      }

      return curated;
    }

    // For other collections, deduplicate duplicate variations for each AMC
    final Map<String, MfSchemeModel> amcMap = {};
    for (final s in rawList) {
      final key = s.amcName.trim().toLowerCase();
      if (!amcMap.containsKey(key) || s.cagr3Y > amcMap[key]!.cagr3Y) {
        amcMap[key] = s;
      }
    }
    return amcMap.values.toList();
  }

  void _applyLocalFallback() {
    final pool = <MfSchemeModel>[
      ...controller.schemes,
      ...controller.allSchemes,
      ...controller.popularSchemesList,
    ];
    List<MfSchemeModel> local = [];
    switch (widget.collectionId) {
      case 'high_return':
        local = List<MfSchemeModel>.from(pool)..sort((a, b) => b.cagr3Y.compareTo(a.cagr3Y));
        break;
      case 'sip_100':
        local = List<MfSchemeModel>.from(pool)..sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'gold_silver':
        local = pool.where((s) {
          final t = '${s.schemeName} ${s.category} ${s.subCategory}'.toLowerCase();
          return t.contains('gold') || t.contains('silver') || t.contains('commodity');
        }).toList();
        break;
      case 'large_cap':
        local = pool.where((s) => s.subCategory.toLowerCase().contains('large')).toList();
        break;
      case 'mid_cap':
        local = pool.where((s) => s.subCategory.toLowerCase().contains('mid')).toList();
        break;
      case 'small_cap':
        local = pool.where((s) => s.subCategory.toLowerCase().contains('small')).toList();
        break;
      default:
        local = pool;
    }
    setState(() {
      _schemes = _curateFlagshipSchemes(local);
    });
  }

  List<MfSchemeModel> get _filteredAndSortedSchemes {
    var list = List<MfSchemeModel>.from(_schemes);

    // Search filter
    final q = _searchQuery.trim().toLowerCase();
    if (q.isNotEmpty) {
      final tokens = q
          .replaceAll(RegExp(r'[^a-zA-Z0-9s]'), ' ')
          .split(RegExp(r's+'))
          .where((t) => t.isNotEmpty)
          .toList();
      list = list.where((s) {
        final text = '${s.schemeName} ${s.amcName} ${s.subCategory} ${s.category}'
            .replaceAll(RegExp(r'[^a-zA-Z0-9s]'), ' ')
            .toLowerCase();
        return tokens.every((t) => text.contains(t));
      }).toList();
    }

    // Sort by return period
    if (_returnPeriod == '1Y') {
      list.sort((a, b) => b.cagr1Y.compareTo(a.cagr1Y));
    } else if (_returnPeriod == '5Y') {
      list.sort((a, b) {
        final aVal = a.cagr5Y > 0 ? a.cagr5Y : a.cagr3Y;
        final bVal = b.cagr5Y > 0 ? b.cagr5Y : b.cagr3Y;
        return bVal.compareTo(aVal);
      });
    } else {
      // 3Y Returns: Maintain Groww flagship priority order for small cap
      if (widget.collectionId != 'small_cap') {
        list.sort((a, b) => b.cagr3Y.compareTo(a.cagr3Y));
      }
    }

    return list;
  }

  String _cleanSchemeName(String name) {
    var s = name
        .replaceAll(RegExp(r's*-s*Regulars+Plans*-s*Growth(s+Option)?', caseSensitive: false), '')
        .replaceAll(RegExp(r's*-s*Regulars+Plans*-s*Regulars+Growth', caseSensitive: false), '')
        .replaceAll(RegExp(r's*-s*Regulars+Plans*-s*GROWTHs*OPTION', caseSensitive: false), '')
        .replaceAll(RegExp(r's*-s*Regulars+Plans*-s*GROWTH', caseSensitive: false), '')
        .replaceAll(RegExp(r's*-s*Regulars+Plan', caseSensitive: false), '')
        .replaceAll(RegExp(r's*-s*Directs+Plans*-s*Growth(s+Option)?', caseSensitive: false), '')
        .replaceAll(RegExp(r's*-s*Directs+Plan', caseSensitive: false), '')
        .replaceAll(RegExp(r's*-s*Growths+Option', caseSensitive: false), '')
        .replaceAll(RegExp(r's*-s*Growth', caseSensitive: false), '')
        .replaceAll(RegExp(r's*(Erstwhile[^)]*)', caseSensitive: false), '')
        .trim();

    // Standardize casing for clean presentation
    if (s.startsWith('BANDHAN ')) {
      s = 'Bandhan ${s.substring(8)}';
    } else if (s.startsWith('BANK OF INDIA ')) {
      s = 'Bank of India ${s.substring(14)}';
    } else if (s.startsWith('QUANTUM ')) {
      s = 'Quantum ${s.substring(8)}';
    } else if (s.startsWith('TRUSTMF ')) {
      s = 'Trust ${s.substring(8)}';
    } else if (s.startsWith('SBI SMALL CAP FUND')) {
      s = 'SBI Small Cap Fund';
    }

    return s;
  }

  void _showReturnPeriodSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161B26),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Return Period',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...['1Y', '3Y', '5Y'].map((p) {
                  final isSelected = _returnPeriod == p;
                  return InkWell(
                    onTap: () {
                      Navigator.pop(ctx);
                      setState(() => _returnPeriod = p);
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$p Returns',
                            style: TextStyle(
                              color: isSelected ? const Color(0xFF00D09C) : Colors.white,
                              fontSize: 15,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check_rounded, color: Color(0xFF00D09C), size: 20),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayList = _filteredAndSortedSchemes;

    return Scaffold(
      backgroundColor: const Color(0xFF0E1118),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E1118),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showSearch ? Icons.close_rounded : Icons.search_rounded,
              color: Colors.white,
              size: 22,
            ),
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) {
                  _searchController.clear();
                  _searchQuery = '';
                }
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFF00D09C),
          backgroundColor: const Color(0xFF161B26),
          onRefresh: _loadData,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            slivers: [
              // ── 1. Groww-styled Top Collection Header ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _collectionSubtitle,
                              style: const TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 13,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          _collectionIconAsset,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: _accentColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(_collectionIcon, color: _accentColor, size: 28),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── 2. Expandable Search Bar (When Tapped in AppBar) ──
              if (_showSearch)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF161B26),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF2D3748)),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        cursorColor: const Color(0xFF00D09C),
                        onChanged: (val) => setState(() => _searchQuery = val),
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: 'Search within ${widget.title}...',
                          hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                          prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF64748B), size: 18),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B), size: 16),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                        ),
                      ),
                    ),
                  ),
                ),

              // ── 3. Table Header: "Mutual Funds" & "⇅ 3Y Returns" ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Mutual Funds',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      InkWell(
                        onTap: _showReturnPeriodSheet,
                        borderRadius: BorderRadius.circular(6),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.unfold_more_rounded, color: Colors.white, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                '$_returnPeriod Returns',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── 4. Mutual Funds List ──
              if (_isLoading && _schemes.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xFF00D09C)),
                  ),
                )
              else if (displayList.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.search_off_rounded, color: Color(0xFF64748B), size: 48),
                          const SizedBox(height: 12),
                          const Text(
                            'No mutual funds found',
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Try modifying your search query',
                            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final scheme = displayList[index];
                      return Column(
                        children: [
                          _buildGrowwFundRow(scheme),
                          const Divider(
                            height: 1,
                            thickness: 0.6,
                            color: Color(0xFF1E293B),
                          ),
                        ],
                      );
                    },
                    childCount: displayList.length,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGrowwFundRow(MfSchemeModel scheme) {
    double returnVal = scheme.cagr3Y;
    if (_returnPeriod == '1Y') {
      returnVal = scheme.cagr1Y;
    } else if (_returnPeriod == '5Y') {
      returnVal = scheme.cagr5Y > 0 ? scheme.cagr5Y : scheme.cagr3Y;
    }

    final String cleanName = _cleanSchemeName(scheme.schemeName);
    final String catText = scheme.category.isNotEmpty ? scheme.category : 'Equity';
    final String subCatText = scheme.subCategory.isNotEmpty ? scheme.subCategory : widget.title;

    final bool hasReturn = returnVal > 0;
    final String returnStr = hasReturn
        ? '+${returnVal.toStringAsFixed(2)}%'
        : '--';
    final Color returnColor = hasReturn ? const Color(0xFF00D09C) : const Color(0xFF94A3B8);

    return InkWell(
      onTap: () => Get.to(() => MfSchemeDetailView(scheme: scheme)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AmcBrandLogo(
              amcName: scheme.amcName,
              schemeName: scheme.schemeName,
              size: 40,
              borderRadius: 8,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    cleanName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          '$catText • $subCatText',
                          style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (scheme.rating > 0) ...[
                        const Text(
                          ' • ',
                          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                        ),
                        Text(
                          '${scheme.rating.toInt()}',
                          style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(
                          Icons.star_rounded,
                          color: Color(0xFF94A3B8),
                          size: 13,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              returnStr,
              style: TextStyle(
                color: returnColor,
                fontSize: 14.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
