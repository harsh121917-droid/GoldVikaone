import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../data/models/mf_profile_model.dart';
import '../controllers/mutual_funds_controller.dart';
import 'widgets/mf_groww_widgets.dart';

class MfProfileView extends StatefulWidget {
  const MfProfileView({super.key});

  @override
  State<MfProfileView> createState() => _MfProfileViewState();
}

class _MfProfileViewState extends State<MfProfileView> {
  final MutualFundsController controller = Get.find<MutualFundsController>();
  bool _isPersonalDetailsExpanded = false;
  String _orderFilter = 'ALL'; // ALL, PASSED, FAILED, PENDING

  @override
  void initState() {
    super.initState();
    controller.fetchMfProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GrowwColors.background,
      appBar: AppBar(
        backgroundColor: GrowwColors.card,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: GrowwColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Mutual Funds Profile',
          style: TextStyle(
            color: GrowwColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: GrowwColors.textSecondary),
            onPressed: () => controller.fetchMfProfile(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isProfileLoading.value && controller.mfProfile.value == null) {
          return const Center(
            child: CircularProgressIndicator(color: GrowwColors.mintTeal),
          );
        }

        final profile = controller.mfProfile.value;
        final name = profile?.investorName.isNotEmpty == true ? profile!.investorName : 'Investor';
        final email = profile?.email ?? '';
        final phone = profile?.phone ?? '';
        final acc = profile?.accountDetails;
        final pers = profile?.personalDetails;
        final banks = profile?.bankAccounts ?? [];
        final orders = profile?.orders ?? [];

        return RefreshIndicator(
          color: GrowwColors.mintTeal,
          backgroundColor: GrowwColors.cardElevated,
          onRefresh: () => controller.fetchMfProfile(),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            children: [
              // ── 1. Top Identity Card ──
              _buildIdentityCard(name, email, phone),
              const SizedBox(height: 16),

              // ── 2. Account Details Card (Showing UCC) ──
              _buildAccountDetailsCard(acc, pers),
              const SizedBox(height: 20),

              // ── 3. Bank Accounts Section ──
              _buildBankAccountsSection(banks),
              const SizedBox(height: 20),

              // ── 4. Orders History Section ──
              _buildOrdersSection(orders),
              const SizedBox(height: 32),
            ],
          ),
        );
      }),
    );
  }

  // ── Identity Card ──
  Widget _buildIdentityCard(String name, String email, String phone) {
    final initials = name.trim().split(' ').map((p) => p.isNotEmpty ? p[0].toUpperCase() : '').take(2).join('');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GrowwColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GrowwColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF00D09C), Color(0xFF059669)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initials.isNotEmpty ? initials : 'MF',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: GrowwColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (email.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    email,
                    style: const TextStyle(color: GrowwColors.textSecondary, fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (phone.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    phone,
                    style: const TextStyle(color: GrowwColors.textTertiary, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Account Details Card with Unique Client Code (UCC) ──
  Widget _buildAccountDetailsCard(MfAccountDetails? acc, MfPersonalDetails? pers) {
    final clientCode = acc?.clientCode ?? 'NOT_REGISTERED';
    final isRegistered = acc?.isUccRegistered == true && clientCode != 'NOT_REGISTERED';
    final status = acc?.status.toUpperCase() ?? 'INACTIVE';
    final isActive = status == 'ACTIVE';

    return Container(
      decoration: BoxDecoration(
        color: GrowwColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GrowwColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Account Details',
                      style: TextStyle(
                        color: GrowwColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isActive
                            ? GrowwColors.mintTeal.withOpacity(0.15)
                            : Colors.orange.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isActive ? GrowwColors.mintTeal : Colors.orange,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isActive ? Icons.check_circle_rounded : Icons.pending_rounded,
                            color: isActive ? GrowwColors.mintTeal : Colors.orange,
                            size: 13,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isActive ? 'NSE Active' : status,
                            style: TextStyle(
                              color: isActive ? GrowwColors.mintTeal : Colors.orange,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Unique Client Code Display
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: GrowwColors.cardElevated,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: GrowwColors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: GrowwColors.mintTeal.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.badge_rounded,
                          color: GrowwColors.mintTeal,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Unique Client Code (UCC)',
                              style: TextStyle(
                                color: GrowwColors.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              clientCode,
                              style: const TextStyle(
                                color: GrowwColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isRegistered)
                        IconButton(
                          icon: const Icon(Icons.copy_rounded, color: GrowwColors.textSecondary, size: 18),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: clientCode));
                            Get.snackbar(
                              'Copied',
                              'UCC copied to clipboard',
                              backgroundColor: GrowwColors.cardElevated,
                              colorText: GrowwColors.mintTeal,
                              snackPosition: SnackPosition.BOTTOM,
                              duration: const Duration(seconds: 2),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: GrowwColors.border),

          // Personal Details Expandable Button
          InkWell(
            onTap: () {
              setState(() {
                _isPersonalDetailsExpanded = !_isPersonalDetailsExpanded;
              });
            },
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  const Icon(Icons.person_pin_rounded, color: GrowwColors.mintTeal, size: 20),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Personal Details',
                      style: TextStyle(
                        color: GrowwColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    _isPersonalDetailsExpanded ? 'Hide' : 'View',
                    style: const TextStyle(
                      color: GrowwColors.mintTeal,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _isPersonalDetailsExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: GrowwColors.mintTeal,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),

          if (_isPersonalDetailsExpanded && pers != null) ...[
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: GrowwColors.cardElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: GrowwColors.border),
                ),
                child: Column(
                  children: [
                    _buildDetailRow('Full Name', pers.fullName),
                    _buildDetailRow('PAN Number', pers.pan),
                    _buildDetailRow('Date of Birth', pers.dob.isNotEmpty ? pers.dob : 'Not provided'),
                    _buildDetailRow('Gender', pers.gender.isNotEmpty ? pers.gender : 'Not specified'),
                    _buildDetailRow('Occupation', pers.occupation.isNotEmpty ? pers.occupation : 'Not specified'),
                    _buildDetailRow('Holding Nature', pers.holdingNature),
                    _buildDetailRow('Communication Address', pers.formattedAddress),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(color: GrowwColors.textSecondary, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : '-',
              style: const TextStyle(
                color: GrowwColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Bank Accounts Section ──
  Widget _buildBankAccountsSection(List<MfBankItem> banks) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Bank Accounts',
              style: TextStyle(
                color: GrowwColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: () => _showAddBankSheet(context),
              icon: const Icon(Icons.add_rounded, color: GrowwColors.mintTeal, size: 18),
              label: const Text(
                'Add Bank',
                style: TextStyle(color: GrowwColors.mintTeal, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        if (banks.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: GrowwColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: GrowwColors.border),
            ),
            child: Center(
              child: Column(
                children: [
                  const Icon(Icons.account_balance_outlined, color: GrowwColors.textSecondary, size: 36),
                  const SizedBox(height: 8),
                  const Text(
                    'No bank account linked yet',
                    style: TextStyle(color: GrowwColors.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => _showAddBankSheet(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GrowwColors.mintTeal,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Add Primary Bank', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: banks.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final b = banks[index];
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: GrowwColors.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: b.isDefault ? GrowwColors.mintTeal.withOpacity(0.5) : GrowwColors.border,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: GrowwColors.cardElevated,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: GrowwColors.border),
                      ),
                      child: const Icon(Icons.account_balance_rounded, color: GrowwColors.mintTeal, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  b.bankName,
                                  style: const TextStyle(
                                    color: GrowwColors.textPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (b.isDefault)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: GrowwColors.mintTeal.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'Primary',
                                    style: TextStyle(color: GrowwColors.mintTeal, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${b.maskedAccountNumber} • IFSC: ${b.ifsc}',
                            style: const TextStyle(color: GrowwColors.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  // ── Orders History Section ──
  Widget _buildOrdersSection(List<MfOrderItem> orders) {
    // Apply client filter
    final filtered = orders.where((o) {
      if (_orderFilter == 'PASSED') return o.isPassed;
      if (_orderFilter == 'FAILED') return o.isFailed;
      if (_orderFilter == 'PENDING') return o.isPending;
      return true;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text(
                  'Orders History',
                  style: TextStyle(
                    color: GrowwColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: GrowwColors.cardElevated,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${orders.length}',
                    style: const TextStyle(color: GrowwColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Filter chips: All, Passed, Failed, Pending
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip('All', 'ALL', orders.length),
              _buildFilterChip('Passed', 'PASSED', orders.where((o) => o.isPassed).length),
              _buildFilterChip('Failed', 'FAILED', orders.where((o) => o.isFailed).length),
              _buildFilterChip('In Process', 'PENDING', orders.where((o) => o.isPending).length),
            ],
          ),
        ),
        const SizedBox(height: 12),

        if (filtered.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: GrowwColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: GrowwColors.border),
            ),
            child: Center(
              child: Column(
                children: [
                  const Icon(Icons.receipt_long_outlined, color: GrowwColors.textSecondary, size: 36),
                  const SizedBox(height: 8),
                  Text(
                    _orderFilter == 'ALL'
                        ? 'No mutual fund orders yet'
                        : 'No ${_orderFilter.toLowerCase()} orders found',
                    style: const TextStyle(color: GrowwColors.textSecondary, fontSize: 13),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filtered.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final o = filtered[index];
              return _buildOrderCard(o);
            },
          ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String code, int count) {
    final isSelected = _orderFilter == code;
    return GestureDetector(
      onTap: () {
        setState(() {
          _orderFilter = code;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? GrowwColors.mintTeal.withOpacity(0.18) : GrowwColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? GrowwColors.mintTeal : GrowwColors.border,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? GrowwColors.mintTeal : GrowwColors.textSecondary,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 4),
              Text(
                '($count)',
                style: TextStyle(
                  color: isSelected ? GrowwColors.mintTeal : GrowwColors.textTertiary,
                  fontSize: 11,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(MfOrderItem o) {
    Color badgeColor;
    Color badgeBg;
    String badgeText;
    IconData badgeIcon;

    if (o.isPassed) {
      badgeColor = GrowwColors.mintTeal;
      badgeBg = GrowwColors.mintTeal.withOpacity(0.15);
      badgeText = 'Passed';
      badgeIcon = Icons.check_circle_rounded;
    } else if (o.isFailed) {
      badgeColor = GrowwColors.negativeRed;
      badgeBg = GrowwColors.negativeRed.withOpacity(0.15);
      badgeText = 'Failed';
      badgeIcon = Icons.cancel_rounded;
    } else {
      badgeColor = Colors.orange;
      badgeBg = Colors.orange.withOpacity(0.15);
      badgeText = 'In Process';
      badgeIcon = Icons.timelapse_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: GrowwColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: GrowwColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  o.schemeName,
                  style: const TextStyle(
                    color: GrowwColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: badgeColor.withOpacity(0.5), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(badgeIcon, color: badgeColor, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      badgeText,
                      style: TextStyle(
                        color: badgeColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Order Amount',
                    style: TextStyle(color: GrowwColors.textSecondary, fontSize: 11),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '₹${o.amount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: GrowwColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    o.orderType,
                    style: const TextStyle(color: GrowwColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    o.createdAt != null
                        ? '${o.createdAt!.day}/${o.createdAt!.month}/${o.createdAt!.year}'
                        : 'Recent',
                    style: const TextStyle(color: GrowwColors.textTertiary, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),

          if (o.isFailed && o.rejectionReason.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: GrowwColors.negativeRed.withOpacity(0.08),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: GrowwColors.negativeRed.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: GrowwColors.negativeRed, size: 14),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      o.rejectionReason,
                      style: const TextStyle(color: GrowwColors.negativeRed, fontSize: 11),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Add Bank Modal Bottom Sheet ──
  void _showAddBankSheet(BuildContext context) {
    final accCtrl = TextEditingController();
    final ifscCtrl = TextEditingController();
    final bankNameCtrl = TextEditingController();
    String accountType = 'savings';
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              decoration: const BoxDecoration(
                color: GrowwColors.card,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Add Bank Account',
                        style: TextStyle(
                          color: GrowwColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: GrowwColors.textSecondary),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Account Number
                  _buildInputField(
                    controller: accCtrl,
                    label: 'Bank Account Number',
                    hint: 'e.g. 1300182100001716',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),

                  // IFSC Code
                  _buildInputField(
                    controller: ifscCtrl,
                    label: 'IFSC Code',
                    hint: 'e.g. BKID0001300',
                    textCapitalization: TextCapitalization.characters,
                  ),
                  const SizedBox(height: 12),

                  // Bank Name
                  _buildInputField(
                    controller: bankNameCtrl,
                    label: 'Bank Name (Optional)',
                    hint: 'e.g. Bank of India',
                  ),
                  const SizedBox(height: 14),

                  // Account Type
                  const Text('Account Type', style: TextStyle(color: GrowwColors.textSecondary, fontSize: 12)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _buildTypeRadio('Savings', 'savings', accountType, (val) => setModalState(() => accountType = val)),
                      const SizedBox(width: 12),
                      _buildTypeRadio('Current', 'current', accountType, (val) => setModalState(() => accountType = val)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              final acc = accCtrl.text.trim();
                              final ifsc = ifscCtrl.text.trim().toUpperCase();
                              if (acc.isEmpty || ifsc.isEmpty) {
                                Get.snackbar('Required Fields', 'Please enter Account Number and IFSC Code.',
                                    backgroundColor: Colors.redAccent, colorText: Colors.white);
                                return;
                              }
                              setModalState(() => isSubmitting = true);
                              final ok = await controller.addBank(
                                accountNumber: acc,
                                ifsc: ifsc,
                                bankName: bankNameCtrl.text.trim().isNotEmpty ? bankNameCtrl.text.trim() : 'Bank Account',
                                accountType: accountType,
                              );
                              setModalState(() => isSubmitting = false);
                              if (ok && ctx.mounted) {
                                Navigator.pop(ctx);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: GrowwColors.mintTeal,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: isSubmitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                            )
                          : const Text(
                              'Add Bank Account',
                              style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: GrowwColors.textSecondary, fontSize: 12)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          style: const TextStyle(color: GrowwColors.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: GrowwColors.textTertiary, fontSize: 13),
            filled: true,
            fillColor: GrowwColors.cardElevated,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: GrowwColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: GrowwColors.mintTeal),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTypeRadio(String label, String value, String groupValue, Function(String) onSelect) {
    final isSelected = value == groupValue;
    return GestureDetector(
      onTap: () => onSelect(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? GrowwColors.mintTeal.withOpacity(0.15) : GrowwColors.cardElevated,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? GrowwColors.mintTeal : GrowwColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? GrowwColors.mintTeal : GrowwColors.textSecondary,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
