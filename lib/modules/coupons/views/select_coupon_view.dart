import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vika1/core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../widgets/coupon_ticket_card.dart';

class SelectCouponView extends StatefulWidget {
  final double currentAmount;
  final String metalType; // 'gold' or 'silver'
  final Map<String, dynamic>? initialSelectedCoupon;

  const SelectCouponView({
    Key? key,
    required this.currentAmount,
    this.metalType = 'gold',
    this.initialSelectedCoupon,
  }) : super(key: key);

  @override
  State<SelectCouponView> createState() => _SelectCouponViewState();
}

class _SelectCouponViewState extends State<SelectCouponView> {
  Map<String, dynamic>? _selectedCoupon;

  List<Map<String, dynamic>> _coupons = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedCoupon = widget.initialSelectedCoupon ?? _coupons.first;
    _fetchCoupons();
  }

    Future<void> _fetchCoupons() async {
    try {
      final res = await ApiClient.instance.get('/coupons');
      if (res.statusCode == 200) {
        final data = res.data;
        final list = (data['coupons'] ?? data['data'] ?? []) as List;
        final fetched = list.map((item) {
          final c = Map<String, dynamic>.from(item as Map);
          final code = c['code']?.toString() ?? 'OFFER';
          final minAmt = (c['minPurchaseAmount'] as num? ?? 100).toInt();
          final val = (c['value'] as num? ?? 15).toInt();
          return {
            "code": code,
            "title": c['title'] ?? "Add Gold Worth ₹$minAmt",
            "description": c['description'] ?? "Get Free Gold up to ₹$val",
            "type": c['type'] ?? "extra_gold",
            "value": (c['value'] as num? ?? 15.0).toDouble(),
            "minPurchaseAmount": (c['minPurchaseAmount'] as num? ?? 100.0).toDouble(),
            "expiry": "Valid till 31 Aug 2026",
            "tag": "Applicable on once per user",
            "badge": c['isPopular'] == true ? "MOST POPULAR" : "SPECIAL OFFER",
            "stubLabel": code,
            "saveText": "Up to ₹$val",
            "isPopular": c['isPopular'] == true,
          };
        }).toList();

        if (mounted) {
          setState(() {
            _coupons = fetched;
            _isLoading = false;
            if (_selectedCoupon == null && _coupons.isNotEmpty) {
              _selectedCoupon = _coupons.first;
            }
          });
        }
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final bg = dark ? const Color(0xFF0D1812) : const Color(0xFFFFFDF7);
    final textInk = dark ? const Color(0xFFEDF3EF) : const Color(0xFF1E2D24);
    final goldCol = const Color(0xFFD4A017);
    final goldGrad = const LinearGradient(
      colors: [Color(0xFFE5A93C), Color(0xFFB87E14)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final currentSaveText = _selectedCoupon != null
        ? "₹${(_selectedCoupon!['value'] as num).toInt()}"
        : "₹0";

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: dark ? const Color(0xFF1A2E22) : const Color(0xFFF7F3E9),
                        shape: BoxShape.circle,
                        border: Border.all(color: goldCol.withOpacity(0.3)),
                      ),
                      child: Icon(Icons.arrow_back_rounded, color: textInk, size: 20),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Coupon',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: textInk,
                          ),
                        ),
                        Text(
                          'Choose the best offer for you',
                          style: TextStyle(
                            fontSize: 12,
                            color: textInk.withOpacity(0.6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: goldCol.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text('🎁', style: TextStyle(fontSize: 22)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 4),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                physics: const BouncingScrollPhysics(),
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: dark ? const Color(0xFF16291C) : const Color(0xFFFFF9EE),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: goldCol.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: goldCol.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(Icons.verified_rounded, color: Color(0xFFD4A017), size: 20),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Save more on your gold purchase!',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: textInk,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Select a coupon and enjoy extra free gold.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: textInk.withOpacity(0.65),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  ..._coupons.map((c) {
                    final isSelected = _selectedCoupon != null && _selectedCoupon!['code'] == c['code'];
                    return CouponTicketCard(
                      coupon: c,
                      isSelected: isSelected,
                      onTap: () {
                        setState(() {
                          _selectedCoupon = c;
                        });
                      },
                      onApply: () {
                        setState(() {
                          _selectedCoupon = c;
                        });
                        Get.back(result: c);
                      },
                    );
                  }).toList(),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: dark ? const Color(0xFF132319) : Colors.white,
                border: Border(
                  top: BorderSide(
                    color: dark ? Colors.white12 : const Color(0xFFF0E6D2),
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'You save up to',
                        style: TextStyle(
                          fontSize: 11,
                          color: textInk.withOpacity(0.6),
                        ),
                      ),
                      Text(
                        currentSaveText,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF2ECC71),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (_selectedCoupon != null) {
                          Get.back(result: _selectedCoupon);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          gradient: goldGrad,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: goldCol.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Text(
                          'Apply Coupon',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
