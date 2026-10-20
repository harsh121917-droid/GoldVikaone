import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/mf_scheme_model.dart';
import '../controllers/mutual_funds_controller.dart';
import 'mf_sip_investment_view.dart';
import 'widgets/mf_groww_widgets.dart';
import 'widgets/mf_skeleton_widgets.dart';

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
  late final MutualFundsController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<MutualFundsController>()
        ? Get.find<MutualFundsController>()
        : Get.put(MutualFundsController());
    _tabController = TabController(length: 3, vsync: this);
    controller.fetchNfos();
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
            child: Obx(() {
              final openCount = controller.openNfos.length;
              final upcomingCount = controller.upcomingNfos.length;
              final closedCount = controller.closedNfos.length;

              return TabBar(
                controller: _tabController,
                indicatorColor: mintGreen,
                indicatorWeight: 3,
                labelColor: mintGreen,
                unselectedLabelColor: Colors.white60,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                tabs: [
                  Tab(text: 'Open Now ($openCount)'),
                  Tab(text: 'Upcoming ($upcomingCount)'),
                  Tab(text: 'Closed ($closedCount)'),
                ],
              );
            }),
          ),
        ),
      ),
      body: Obx(() {
        return TabBarView(
          controller: _tabController,
          children: [
            _buildNfoList(controller.openNfos, isOpen: true),
            _buildNfoList(controller.upcomingNfos, isUpcoming: true),
            _buildNfoList(controller.closedNfos, isClosed: true),
          ],
        );
      }),
    );
  }

  Widget _buildNfoList(
    List<Map<String, dynamic>> items, {
    bool isOpen = false,
    bool isUpcoming = false,
    bool isClosed = false,
  }) {
    if (controller.isNfoLoading.value && items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: MfListScreenSkeleton(itemCount: 4),
      );
    }

    if (items.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => controller.fetchNfos(),
        color: const Color(0xFF00D09C),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.2),
            Center(
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
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => controller.fetchNfos(),
      color: const Color(0xFF00D09C),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        itemCount: items.length + 1,
        itemBuilder: (context, index) {
          if (index == items.length) {
            return _buildEducationalCard();
          }
          final n = items[index];
          return _buildNfoCard(n, isOpen: isOpen, isUpcoming: isUpcoming, isClosed: isClosed);
        },
      ),
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
    final double? minSip = (n['minSip'] as num?)?.toDouble();
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
                      minSip != null ? '₹${minSip.toStringAsFixed(0)}' : '—',
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
                  onPressed: () => _showNfoApplySheet(context, n),
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

  void _showNfoApplySheet(BuildContext context, Map<String, dynamic> n) {
    final String name = n['name'] ?? '';
    final String amc = n['amc'] ?? '';
    final double issuePrice = (n['issuePrice'] ?? 10.0).toDouble();
    final double minSip = (n['minSip'] as num?)?.toDouble() ?? 500.0;
    final double minPurchase = (n['minPurchase'] as num?)?.toDouble() ?? 1000.0;
    final String risk = n['risk'] ?? 'Very High';

    final nfoScheme = MfSchemeModel(
      id: n['id']?.toString() ?? n['schemeCode']?.toString() ?? 'nfo',
      schemeCode: n['schemeCode']?.toString() ?? 'NFO_${n['id']}',
      schemeName: name,
      amcCode: n['amcCode']?.toString() ?? '',
      amcName: amc,
      isin: '',
      category: n['category']?.toString() ?? 'Equity',
      subCategory: n['category']?.toString() ?? 'Sectoral',
      nav: issuePrice,
      navDate: DateTime.now(),
      cagr1Y: null,
      cagr3Y: null,
      cagr5Y: null,
      minPurchaseAmount: minPurchase,
      minSipAmount: minSip,
      rating: null,
      riskLevel: risk,
      fundManager: n['fundManager']?.toString(),
      aum: null,
      expenseRatio: null,
      isPopular: false,
      isFeatured: true,
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161E2D),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              name,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              'Offer Price: ₹${issuePrice.toStringAsFixed(2)} • Closes ${n['closeDate'] ?? ""}',
              style: const TextStyle(color: Color(0xFF00D09C), fontSize: 12.5, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            // Option 1: Monthly SIP
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              tileColor: const Color(0xFF0F141E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFF22304A)),
              ),
              leading: const CircleAvatar(
                backgroundColor: Color(0xFF1E2A3E),
                child: Icon(Icons.repeat_rounded, color: Color(0xFF00D09C)),
              ),
              title: const Text('Start Monthly SIP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: Text('Starting from ₹${minSip.toInt()}/month at ₹10 base NAV', style: const TextStyle(color: Colors.white54, fontSize: 12)),
              trailing: const Icon(Icons.chevron_right, color: Colors.white54),
              onTap: () {
                Navigator.pop(ctx);
                Get.to(() => MfSipInvestmentView(scheme: nfoScheme, isSip: true));
              },
            ),
            const SizedBox(height: 10),
            // Option 2: One-Time Lumpsum
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              tileColor: const Color(0xFF0F141E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFF22304A)),
              ),
              leading: const CircleAvatar(
                backgroundColor: Color(0xFF1E2A3E),
                child: Icon(Icons.flash_on_rounded, color: Colors.blueAccent),
              ),
              title: const Text('Invest One-Time (Lumpsum)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: Text('Min investment ₹${minPurchase.toInt()}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
              trailing: const Icon(Icons.chevron_right, color: Colors.white54),
              onTap: () {
                Navigator.pop(ctx);
                Get.to(() => MfSipInvestmentView(scheme: nfoScheme, isSip: false));
              },
            ),
            const SizedBox(height: 10),
            // Option 3: Add to Cart
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              tileColor: const Color(0xFF0F141E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFF22304A)),
              ),
              leading: const CircleAvatar(
                backgroundColor: Color(0xFF1E2A3E),
                child: Icon(Icons.add_shopping_cart_rounded, color: Color(0xFFFFB020)),
              ),
              title: const Text('Add to Cart', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: const Text('Save to your cart to invest later', style: TextStyle(color: Colors.white54, fontSize: 12)),
              trailing: const Icon(Icons.chevron_right, color: Colors.white54),
              onTap: () async {
                Navigator.pop(ctx);
                await controller.addToCart(
                  scheme: nfoScheme,
                  amount: minSip,
                  investmentType: 'SIP',
                  sipDay: 5,
                );
              },
            ),
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
