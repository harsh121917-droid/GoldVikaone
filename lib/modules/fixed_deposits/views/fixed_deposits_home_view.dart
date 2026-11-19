import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../controllers/fixed_deposits_controller.dart';

class FixedDepositsHomeView extends StatelessWidget {
  const FixedDepositsHomeView({super.key});

  // ── Modern Clean Theme Colors ───────────────────────────────
  static const Color _bgLight = Color(0xFFF8F9FE);
  static const Color _cardBg = Colors.white;
  static const Color _cardBorder = Color(0xFFE2E8F0);
  static const Color _accentGold = Color(0xFFD4A017);
  static const Color _accentGreen = Color(0xFF059669);
  static const Color _textDark = Color(0xFF0F172A);
  static const Color _textMuted = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FixedDepositsController());

    return Scaffold(
      backgroundColor: _bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _textDark, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Corporate Fixed Deposits',
          style: TextStyle(
            color: _textDark,
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          Obx(() {
            final count = controller.myApplications.length;
            return Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Center(
                child: InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    Get.toNamed(AppRoutes.myFdApplications);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _cardBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.receipt_long_rounded, color: _accentGold, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          count > 0 ? 'My FDs ($count)' : 'My FDs',
                          style: const TextStyle(
                            color: _textDark,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: _accentGold),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Modern Hero Banner
              _buildTopHeroBanner(),
              const SizedBox(height: 20),

              // 2. Issuing Companies Selector
              const Text(
                'Select FD Issuer (IRIS Approved)',
                style: TextStyle(
                  color: _textDark,
                  fontSize: 15.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 10),
              _buildCompanyCards(controller),
              const SizedBox(height: 22),

              // 3. Interactive FD Return Calculator
              _buildReturnCalculator(controller),
              const SizedBox(height: 22),

              // 4. Issuer Highlights & Safety Rating
              _buildIssuerHighlights(controller),
              const SizedBox(height: 22),

              // 5. Why Corporate FDs with IRIS
              _buildWhyInvestSection(),
              const SizedBox(height: 32),

              // 6. Action Button (Bottom)
              _buildApplyButton(controller),
              const SizedBox(height: 24),
            ],
          ),
        );
      }),
    );
  }

  // ── Top Hero Banner ─────────────────────────────────────────
  Widget _buildTopHeroBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _cardBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: const Text(
                    'HIGH YIELD • UP TO 8.85% P.A.',
                    style: TextStyle(
                      color: Color(0xFFB45309),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Guaranteed Fixed Income',
                  style: TextStyle(
                    color: _textDark,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '100% paperless IRIS application with top CRISIL AAA/AA+ rated corporate leaders.',
                  style: TextStyle(
                    color: _textMuted,
                    fontSize: 12.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFFFBEB),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: const Icon(Icons.account_balance_rounded, color: _accentGold, size: 28),
          ),
        ],
      ),
    );
  }

  // ── Company Selector Cards ──────────────────────────────────
  Widget _buildCompanyCards(FixedDepositsController controller) {
    return Column(
      children: controller.companies.map((comp) {
        final isSelected = controller.selectedCompany.value?.code == comp.code;

        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            controller.selectCompany(comp);
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFFFFDF5) : _cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? _accentGold : _cardBorder,
                width: isSelected ? 1.8 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected ? const Color(0x1AD4A017) : const Color(0x06000000),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                // Radio indicator
                Icon(
                  isSelected ? Icons.check_circle_rounded : Icons.radio_button_off_rounded,
                  color: isSelected ? _accentGold : const Color(0xFF94A3B8),
                  size: 22,
                ),
                const SizedBox(width: 12),

                // Company Logo Avatar
                Container(
                  width: 44,
                  height: 44,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _cardBorder),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      comp.logoAsset,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: const Color(0xFFFFFBEB),
                        child: const Icon(Icons.account_balance_rounded, color: _accentGold, size: 22),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Company Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              comp.name,
                              style: const TextStyle(
                                color: _textDark,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w900,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFFA7F3D0)),
                            ),
                            child: Text(
                              '${comp.ratingAgency} ${comp.creditRating}',
                              style: const TextStyle(
                                color: _accentGreen,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        comp.tagline,
                        style: const TextStyle(color: _textMuted, fontSize: 11.5),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Min: ₹${comp.minAmount.toStringAsFixed(0)} • Tenures: 12 - 60 Mos',
                        style: const TextStyle(
                          color: _textDark,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

                // Max Rate
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${comp.maxRate}%',
                      style: const TextStyle(
                        color: _accentGold,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Text(
                      'p.a. max',
                      style: TextStyle(color: _textMuted, fontSize: 10.5, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Return Calculator ───────────────────────────────────────
  Widget _buildReturnCalculator(FixedDepositsController controller) {
    final comp = controller.selectedCompany.value;
    final calc = controller.calculationResult;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _cardBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'FD Calculator',
                style: TextStyle(
                  color: _textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Text(
                  '${calc.interestRate}% p.a.',
                  style: const TextStyle(
                    color: Color(0xFFB45309),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 1. Amount selection
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Deposit Amount', style: TextStyle(color: _textMuted, fontSize: 12.5)),
              Text(
                '₹${controller.depositAmount.value.toStringAsFixed(0)}',
                style: const TextStyle(color: _textDark, fontSize: 16, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(Get.context!).copyWith(
              activeTrackColor: _accentGold,
              inactiveTrackColor: const Color(0xFFE2E8F0),
              thumbColor: _accentGold,
              overlayColor: _accentGold.withValues(alpha: 0.2),
            ),
            child: Slider(
              min: comp?.minAmount ?? 5000.0,
              max: 2000000.0,
              divisions: 40,
              value: controller.depositAmount.value.clamp(comp?.minAmount ?? 5000.0, 2000000.0),
              onChanged: (val) {
                controller.depositAmount.value = (val / 1000).round() * 1000.0;
              },
            ),
          ),

          // Quick Amount Chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [25000, 50000, 100000, 500000].map((amt) {
              final isCur = controller.depositAmount.value == amt.toDouble();
              return InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  controller.depositAmount.value = amt.toDouble();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isCur ? _accentGold : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isCur ? _accentGold : _cardBorder,
                    ),
                  ),
                  child: Text(
                    '₹${amt >= 100000 ? '${amt ~/ 100000} Lakh' : '$amt'}',
                    style: TextStyle(
                      color: isCur ? Colors.white : _textDark,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 18),

          // 2. Tenure Selection
          const Text('Investment Tenure', style: TextStyle(color: _textMuted, fontSize: 12.5)),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: (comp?.tenuresMonths ?? [12, 24, 36, 48, 60]).map((ten) {
                final isCur = controller.selectedTenureMonths.value == ten;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      controller.selectedTenureMonths.value = ten;
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isCur ? _accentGold : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isCur ? _accentGold : _cardBorder,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '$ten Mos',
                            style: TextStyle(
                              color: isCur ? Colors.white : _textDark,
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '${(ten / 12).toStringAsFixed(ten % 12 == 0 ? 0 : 1)} Yr',
                            style: TextStyle(
                              color: isCur ? const Color(0xFFFFFBEB) : _textMuted,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 18),

          // 3. Deposit Type (Cumulative vs Non-Cumulative)
          const Text('Interest Payout Option', style: TextStyle(color: _textMuted, fontSize: 12.5)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    controller.depositType.value = 'CUMULATIVE';
                    controller.payoutFrequency.value = 'CUMULATIVE';
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: controller.depositType.value == 'CUMULATIVE'
                          ? const Color(0xFFFFFBEB)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: controller.depositType.value == 'CUMULATIVE'
                            ? _accentGold
                            : _cardBorder,
                        width: controller.depositType.value == 'CUMULATIVE' ? 1.6 : 1.0,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Cumulative (At Maturity)',
                      style: TextStyle(
                        color: controller.depositType.value == 'CUMULATIVE'
                            ? const Color(0xFFB45309)
                            : _textDark,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    controller.depositType.value = 'NON_CUMULATIVE';
                    controller.payoutFrequency.value = 'QUARTERLY';
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: controller.depositType.value == 'NON_CUMULATIVE'
                          ? const Color(0xFFFFFBEB)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: controller.depositType.value == 'NON_CUMULATIVE'
                            ? _accentGold
                            : _cardBorder,
                        width: controller.depositType.value == 'NON_CUMULATIVE' ? 1.6 : 1.0,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Non-Cumulative (Periodic)',
                      style: TextStyle(
                        color: controller.depositType.value == 'NON_CUMULATIVE'
                            ? const Color(0xFFB45309)
                            : _textDark,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Periodic frequency selector if Non-Cumulative
          if (controller.depositType.value == 'NON_CUMULATIVE') ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: ['MONTHLY', 'QUARTERLY', 'HALF_YEARLY', 'ANNUALLY'].map((freq) {
                final isCur = controller.payoutFrequency.value == freq;
                return InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    controller.payoutFrequency.value = freq;
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: isCur ? _accentGold : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: isCur ? _accentGold : _cardBorder),
                    ),
                    child: Text(
                      freq.replaceAll('_', ' '),
                      style: TextStyle(
                        color: isCur ? Colors.white : _textDark,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 18),

          // 4. Rate Boosters (Senior Citizen / Women Investor)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _cardBorder),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Senior Citizen (Age 60+)',
                          style: TextStyle(color: _textDark, fontSize: 13, fontWeight: FontWeight.w800),
                        ),
                        Text(
                          '+${comp?.seniorCitizenBonus ?? 0.25}% extra return',
                          style: const TextStyle(color: _accentGold, fontSize: 11, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    Switch(
                      value: controller.isSeniorCitizen.value,
                      activeColor: _accentGold,
                      onChanged: (val) {
                        HapticFeedback.selectionClick();
                        controller.isSeniorCitizen.value = val;
                      },
                    ),
                  ],
                ),
                if ((comp?.womenInvestorBonus ?? 0.0) > 0) ...[
                  const Divider(color: _cardBorder),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Women Investor Benefit',
                            style: TextStyle(color: _textDark, fontSize: 13, fontWeight: FontWeight.w800),
                          ),
                          Text(
                            '+${comp?.womenInvestorBonus}% extra return',
                            style: const TextStyle(color: _accentGreen, fontSize: 11, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      Switch(
                        value: controller.isWomenInvestor.value,
                        activeColor: _accentGreen,
                        onChanged: (val) {
                          HapticFeedback.selectionClick();
                          controller.isWomenInvestor.value = val;
                        },
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 18),

          // 5. Projected Returns Summary Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFDF5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Deposit Amount:', style: TextStyle(color: _textMuted, fontSize: 12.5)),
                    Text(
                      '₹${calc.depositAmount.toStringAsFixed(0)}',
                      style: const TextStyle(color: _textDark, fontWeight: FontWeight.w800, fontSize: 13.5),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      controller.depositType.value == 'CUMULATIVE' ? 'Interest Earned:' : 'Periodic Payout:',
                      style: const TextStyle(color: _textMuted, fontSize: 12.5),
                    ),
                    Text(
                      controller.depositType.value == 'CUMULATIVE'
                          ? '+₹${calc.totalInterestEarned.toStringAsFixed(0)}'
                          : '₹${calc.periodicPayoutAmount.toStringAsFixed(0)} / ${calc.payoutFrequency.toLowerCase()}',
                      style: const TextStyle(color: _accentGreen, fontWeight: FontWeight.w900, fontSize: 13.5),
                    ),
                  ],
                ),
                const Divider(color: Color(0xFFFDE68A), height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Maturity Value:',
                      style: TextStyle(color: _textDark, fontSize: 14.5, fontWeight: FontWeight.w900),
                    ),
                    Text(
                      '₹${calc.maturityAmount.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: _accentGold,
                        fontSize: 18.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Issuer Highlights ───────────────────────────────────────
  Widget _buildIssuerHighlights(FixedDepositsController controller) {
    final comp = controller.selectedCompany.value;
    if (comp == null || comp.highlights.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified_user_rounded, color: _accentGreen, size: 20),
              const SizedBox(width: 8),
              Text(
                'Key Highlights — ${comp.shortName}',
                style: const TextStyle(color: _textDark, fontSize: 14, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...comp.highlights.map((h) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle_rounded, color: _accentGold, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        h,
                        style: const TextStyle(color: _textMuted, fontSize: 12.5, height: 1.35),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  // ── Why Corporate FDs with IRIS ─────────────────────────────
  Widget _buildWhyInvestSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Why Invest via VikaOne IRIS Integration?',
            style: TextStyle(color: _textDark, fontSize: 14.5, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 14),
          _featureRow(
            Icons.speed_rounded,
            'Fast Paperless Application',
            'Pre-fills with your verified KYC and bank details for swift IRIS punching.',
          ),
          _featureRow(
            Icons.security_rounded,
            'CRISIL AAA Highest Safety',
            'Issued by India’s largest conglomerates with proven financial discipline.',
          ),
          _featureRow(
            Icons.trending_up_rounded,
            'Higher Returns than Bank FDs',
            'Earn up to 8.85% p.a., beating regular commercial bank rates.',
          ),
          _featureRow(
            Icons.support_agent_rounded,
            'Dedicated Relationship Desk',
            'End-to-end operational assistance from punching to FDR certificate dispatch.',
          ),
        ],
      ),
    );
  }

  Widget _featureRow(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: _accentGold, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: _textDark, fontSize: 13, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(color: _textMuted, fontSize: 11.5, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Apply CTA Button ─────────────────────────────────────────
  Widget _buildApplyButton(FixedDepositsController controller) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          HapticFeedback.mediumImpact();
          controller.currentStep.value = 0;
          controller.applyPrefillData();
          Get.toNamed(AppRoutes.fdApply);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _accentGold,
          foregroundColor: const Color(0xFF1A2340),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 2,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Apply for ${controller.selectedCompany.value?.shortName ?? 'FD'} (IRIS Form)',
              style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w900),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_rounded, color: Color(0xFF1A2340), size: 18),
          ],
        ),
      ),
    );
  }
}
