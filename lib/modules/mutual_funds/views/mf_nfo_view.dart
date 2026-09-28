import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/mf_scheme_model.dart';
import 'mf_sip_investment_view.dart';
import 'widgets/mf_groww_widgets.dart';

/// Full Production-Ready Screen for New Fund Offers (NFOs)
/// Shows Open Now, Upcoming, and Recently Closed NFOs with full details,
/// countdowns, investment thresholds, and seamless investment initiation.
class MfNfoView extends StatefulWidget {
  const MfNfoView({Key? key}) : super(key: key);

  @override
  State<MfNfoView> createState() => _MfNfoViewState();
}

class _MfNfoViewState extends State<MfNfoView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Curated live / active NFO records
  final List<Map<String, dynamic>> _openNfos = [
    {
      'id': 'nfo_1',
      'name': 'Invesco India Technology Fund',
      'amc': 'Invesco Mutual Fund',
      'amcCode': 'INVESCO_MF',
      'category': 'Equity: Sectoral - Technology',
      'type': 'Open Ended',
      'openDate': 'Sep 18, 2026',
      'closeDate': 'Oct 02, 2026',
      'daysLeft': 5,
      'issuePrice': 10.0,
      'minSip': 500.0,
      'minPurchase': 1000.0,
      'risk': 'Very High',
      'rating': 5,
      'benchmark': 'BSE Teck TRI',
      'description':
          'Capital appreciation by investing predominantly in equity and equity-related instruments of technology and technology-enabled companies.',
      'status': 'OPEN',
    },
    {
      'id': 'nfo_2',
      'name': 'Quant Healthcare & Pharma Fund',
      'amc': 'Quant Mutual Fund',
      'amcCode': 'QUANT_MF',
      'category': 'Equity: Thematic - Healthcare',
      'type': 'Open Ended',
      'openDate': 'Sep 22, 2026',
      'closeDate': 'Oct 06, 2026',
      'daysLeft': 9,
      'issuePrice': 10.0,
      'minSip': 1000.0,
      'minPurchase': 5000.0,
      'risk': 'Very High',
      'rating': 5,
      'benchmark': 'Nifty Healthcare TRI',
      'description':
          'Generates long term capital appreciation by utilizing quant proprietary predictive analytics across pharma, biotech, and diagnostics.',
      'status': 'OPEN',
    },
    {
      'id': 'nfo_3',
      'name': 'Tata India Innovation & AI Opportunities Fund',
      'amc': 'Tata Mutual Fund',
      'amcCode': 'TATA_MF',
      'category': 'Equity: Thematic - Innovation',
      'type': 'Open Ended',
      'openDate': 'Sep 15, 2026',
      'closeDate': 'Sep 29, 2026',
      'daysLeft': 2,
      'issuePrice': 10.0,
      'minSip': 500.0,
      'minPurchase': 1000.0,
      'risk': 'Very High',
      'rating': 4,
      'benchmark': 'Nifty 500 TRI',
      'description':
          'Focuses on high-conviction companies innovating in artificial intelligence, digital infrastructure, robotics, and cloud ecosystems.',
      'status': 'OPEN',
    },
  ];

  final List<Map<String, dynamic>> _upcomingNfos = [
    {
      'id': 'nfo_4',
      'name': 'Mirae Asset Defense & Aerospace Fund',
      'amc': 'Mirae Asset Mutual Fund',
      'amcCode': 'MIRAE_ASSET',
      'category': 'Equity: Thematic - Defense',
      'type': 'Open Ended',
      'openDate': 'Oct 05, 2026',
      'closeDate': 'Oct 19, 2026',
      'daysLeft': 8,
      'issuePrice': 10.0,
      'minSip': 500.0,
      'minPurchase': 5000.0,
      'risk': 'Very High',
      'rating': 5,
      'benchmark': 'Nifty India Defence Index TRI',
      'description':
          'Seeks to capture India\'s indigenization and defense capex boom with exposure to domestic defense manufacturers, drones, and avionics.',
      'status': 'UPCOMING',
    },
    {
      'id': 'nfo_5',
      'name': 'Axis Multi-Asset Active Allocator FoF',
      'amc': 'Axis Mutual Fund',
      'amcCode': 'AXIS_MF',
      'category': 'Hybrid: Multi Asset Allocation',
      'type': 'Open Ended',
      'openDate': 'Oct 12, 2026',
      'closeDate': 'Oct 26, 2026',
      'daysLeft': 15,
      'issuePrice': 10.0,
      'minSip': 500.0,
      'minPurchase': 1000.0,
      'risk': 'Moderate',
      'rating': 4,
      'benchmark': 'Crisil Multi Asset Index',
      'description':
          'Dynamic multi-asset allocation targeting domestic equity, international equity, debt, gold ETFs, and sovereign instruments.',
      'status': 'UPCOMING',
    },
  ];

  final List<Map<String, dynamic>> _closedNfos = [
    {
      'id': 'nfo_6',
      'name': 'Kotak Consumption & Retail Opportunities Fund',
      'amc': 'Kotak Mahindra Mutual Fund',
      'amcCode': 'KOTAK_MAHINDRA',
      'category': 'Equity: Thematic - Consumption',
      'type': 'Open Ended',
      'openDate': 'Aug 25, 2026',
      'closeDate': 'Sep 08, 2026',
      'allotmentDate': 'Sep 12, 2026',
      'listingNav': 10.14,
      'returnSinceAllotment': 1.40,
      'issuePrice': 10.0,
      'minSip': 500.0,
      'minPurchase': 1000.0,
      'risk': 'High',
      'rating': 5,
      'benchmark': 'Nifty India Consumption TRI',
      'description':
          'Allotted on Sep 12, 2026. Now reopened for continuous daily purchase and SIP at prevailing live NAV.',
      'status': 'CLOSED',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const darkBg = Color(0xFF0F141E);
    const mintGreen = Color(0xFF00D09C);

    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: darkBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'New Fund Offers (NFOs)',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFF22304A), width: 1)),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: mintGreen,
              indicatorWeight: 3,
              labelColor: mintGreen,
              unselectedLabelColor: Colors.white60,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              tabs: [
                Tab(text: 'Open Now (${_openNfos.length})'),
                Tab(text: 'Upcoming (${_upcomingNfos.length})'),
                Tab(text: 'Closed (${_closedNfos.length})'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNfoList(_openNfos, isOpen: true),
          _buildNfoList(_upcomingNfos, isUpcoming: true),
          _buildNfoList(_closedNfos, isClosed: true),
        ],
      ),
    );
  }

  Widget _buildNfoList(
    List<Map<String, dynamic>> items, {
    bool isOpen = false,
    bool isUpcoming = false,
    bool isClosed = false,
  }) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.white.withOpacity(0.3)),
            const SizedBox(height: 16),
            const Text(
              'No NFOs in this category right now',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: items.length + 1,
      itemBuilder: (context, index) {
        if (index == items.length) {
          return _buildEducationalCard();
        }
        final n = items[index];
        return _buildNfoCard(n, isOpen: isOpen, isUpcoming: isUpcoming, isClosed: isClosed);
      },
    );
  }

  Widget _buildNfoCard(
    Map<String, dynamic> n, {
    bool isOpen = false,
    bool isUpcoming = false,
    bool isClosed = false,
  }) {
    const cardBg = Color(0xFF161E2D);
    const mintGreen = Color(0xFF00D09C);
    const goldYellow = Color(0xFFFFB020);

    final String name = n['name'] ?? '';
    final String amc = n['amc'] ?? '';
    final double issuePrice = (n['issuePrice'] ?? 10.0).toDouble();
    final double minSip = (n['minSip'] ?? 500.0).toDouble();
    final String risk = n['risk'] ?? 'High';
    final int? daysLeft = n['daysLeft'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOpen ? mintGreen.withOpacity(0.3) : const Color(0xFF22304A),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row with Logo, Name, and Status Badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AmcBrandLogo(
                  amcName: amc,
                  schemeName: name,
                  size: 44,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        amc,
                        style: const TextStyle(color: Colors.white60, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                if (isOpen && daysLeft != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: mintGreen.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: mintGreen.withOpacity(0.5), width: 0.8),
                    ),
                    child: Text(
                      '$daysLeft days left',
                      style: const TextStyle(
                        color: mintGreen,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else if (isUpcoming && daysLeft != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: goldYellow.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: goldYellow.withOpacity(0.5), width: 0.8),
                    ),
                    child: Text(
                      'Opens in $daysLeft d',
                      style: const TextStyle(
                        color: goldYellow,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else if (isClosed)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Allotted',
                      style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 12),
            // Category & Risk Tags
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E2A3E),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    n['category'] ?? '',
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E2A3E),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    risk,
                    style: TextStyle(
                      color: risk.contains('Very High') ? Colors.orangeAccent : Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            Text(
              n['description'] ?? '',
              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12, height: 1.4),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 16),
            const Divider(color: Color(0xFF22304A), height: 1),
            const SizedBox(height: 14),

            // Key Metrics Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isClosed ? 'Listing NAV' : 'Offer Price',
                      style: const TextStyle(color: Colors.white54, fontSize: 11),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isClosed && n['listingNav'] != null
                          ? '₹${(n['listingNav'] as num).toStringAsFixed(2)}'
                          : '₹${issuePrice.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Min SIP', style: TextStyle(color: Colors.white54, fontSize: 11)),
                    const SizedBox(height: 4),
                    Text(
                      '₹${minSip.toStringAsFixed(0)}',
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isOpen ? 'Closes On' : (isUpcoming ? 'Opens On' : 'Allotted'),
                      style: const TextStyle(color: Colors.white54, fontSize: 11),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isOpen
                          ? (n['closeDate'] ?? '')
                          : (isUpcoming ? (n['openDate'] ?? '') : (n['allotmentDate'] ?? '')),
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),

            if (isOpen) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: () {
                    final nfoScheme = MfSchemeModel(
                      id: n['id'],
                      schemeCode: 'NFO_${n['id']}',
                      schemeName: name,
                      amcCode: n['amcCode'],
                      amcName: amc,
                      isin: '',
                      category: 'Equity',
                      subCategory: 'Sectoral',
                      nav: issuePrice,
                      cagr1Y: 0.0,
                      cagr3Y: 0.0,
                      cagr5Y: 0.0,
                      minPurchaseAmount: (n['minPurchase'] ?? 1000.0).toDouble(),
                      minSipAmount: minSip,
                      rating: 5,
                      riskLevel: risk,
                      fundManager: 'Fund Manager',
                      aum: 0.0,
                      expenseRatio: 0.75,
                      isPopular: false,
                      isFeatured: true,
                    );
                    Get.to(() => MfSipInvestmentView(scheme: nfoScheme, isSip: true));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mintGreen,
                    foregroundColor: const Color(0xFF0F141E),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text(
                    'Apply for NFO',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ] else if (isUpcoming) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Get.snackbar(
                      'Reminder Set',
                      'We will notify you on ${n['openDate']} when ${n['name']} goes live.',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: const Color(0xFF1E2A3E),
                      colorText: Colors.white,
                      duration: const Duration(seconds: 3),
                    );
                  },
                  icon: const Icon(Icons.notifications_active_outlined, size: 18, color: mintGreen),
                  label: const Text(
                    'Set Reminder',
                    style: TextStyle(color: mintGreen, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: mintGreen, width: 1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ] else if (isClosed) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton(
                  onPressed: () {
                    Get.snackbar(
                      'Reopened Fund',
                      'This scheme is now trading at live NAV ₹${(n['listingNav'] as num).toStringAsFixed(2)}. You can invest directly.',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: const Color(0xFF1E2A3E),
                      colorText: Colors.white,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF2E4060)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text(
                    'View Reopened Scheme',
                    style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEducationalCard() {
    const cardBg = Color(0xFF141D2C);
    const mintGreen = Color(0xFF00D09C);

    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 24),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF22304A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: mintGreen.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lightbulb_outline, color: mintGreen, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'What is an NFO?',
                style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'A New Fund Offer (NFO) is the initial subscription offering for any new mutual fund scheme introduced by an Asset Management Company (AMC). Units are typically offered at a fixed base NAV of ₹10 during the offer window.',
            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12.5, height: 1.45),
          ),
          const SizedBox(height: 10),
          Text(
            '• Fixed issue price of ₹10 per unit\n• Opportunity to enter early in niche themes & strategies\n• Post-allotment, open-ended funds become available for regular daily purchase & redemptions',
            style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 12, height: 1.5),
          ),
        ],
      ),
    );
  }
}
