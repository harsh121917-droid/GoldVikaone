import 'widgets/mf_support_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../data/models/mf_scheme_model.dart';
import '../controllers/mutual_funds_controller.dart';

class MfSipInvestmentView extends StatefulWidget {
  final MfSchemeModel scheme;
  final bool isSip;

  const MfSipInvestmentView({
    super.key,
    required this.scheme,
    this.isSip = true,
  });

  @override
  State<MfSipInvestmentView> createState() => _MfSipInvestmentViewState();
}

class _MfSipInvestmentViewState extends State<MfSipInvestmentView> {
  final MutualFundsController controller = Get.find<MutualFundsController>();

  late bool _isSip;
  String _amountStr = '1000';
  int _selectedDay = 25; // Default 25th of every month as shown in screenshot
  String _paymentMethod = 'NSE_GATEWAY';
  String _vpa = '';

  String _selectedFrequency = 'MONTHLY';
  List<String> _supportedFrequencies = const ['MONTHLY'];
  List<Map<String, dynamic>> _sipOptions = const [];

  @override
  void initState() {
    super.initState();
    _isSip = widget.isSip;
    try {
      _vpa = GetStorage().read('mf_saved_vpa')?.toString() ?? '';
    } catch (_) {}
    _paymentMethod = 'NSE_GATEWAY';

    final initialFreqs = widget.scheme.supportedFrequencies;
    if (initialFreqs.isNotEmpty) {
      _supportedFrequencies = initialFreqs
          .toSet()
          .where((f) => ['DAILY', 'WEEKLY', 'MONTHLY', 'QUARTERLY'].contains(f))
          .toList();
      _selectedFrequency = _supportedFrequencies.contains('MONTHLY') ? 'MONTHLY' : _supportedFrequencies.first;
    }
    if (widget.scheme.sipOptions != null) {
      _sipOptions = List<Map<String, dynamic>>.from(widget.scheme.sipOptions!);
    }
    final minAmount = _isSip ? _currentMinSipAmount : widget.scheme.minPurchaseAmount;
    _amountStr = minAmount != null ? minAmount.toInt().toString() : '';
    controller.ensureInvestorReadiness();
    _loadSchemeSipOptions();
  }

  double get _amount => double.tryParse(_amountStr) ?? 0.0;

  String _formatCurrency(String s) {
    if (s.isEmpty) return '0';
    int? n = int.tryParse(s.replaceAll(',', ''));
    if (n == null) return s;
    if (n < 1000) return n.toString();
    String str = n.toString();
    String lastThree = str.substring(str.length - 3);
    String otherNumbers = str.substring(0, str.length - 3);
    if (otherNumbers.isNotEmpty) {
      otherNumbers = otherNumbers.replaceAllMapped(
        RegExp(r'(\d)(?=(\d{2})+(?!\d))'),
        (Match m) => '${m[1]},',
      );
      return '$otherNumbers,$lastThree';
    }
    return lastThree;
  }

  void _onKeypadTap(String value) {
    setState(() {
      if (value == '⌫') {
        if (_amountStr.isNotEmpty) {
          _amountStr = _amountStr.substring(0, _amountStr.length - 1);
        }
      } else if (value == '.') {
        if (!_amountStr.contains('.')) {
          _amountStr = _amountStr.isEmpty ? '0.' : '$_amountStr.';
        }
      } else {
        if (_amountStr == '0') {
          _amountStr = value;
        } else if (_amountStr.length < 9) {
          _amountStr = '$_amountStr$value';
        }
      }
    });
  }

  void _addIncrement(int inc) {
    setState(() {
      int curr = int.tryParse(_amountStr.replaceAll(',', '')) ?? 0;
      curr += inc;
      _amountStr = curr.toString();
    });
  }

  void _clearAmount() {
    setState(() {
      _amountStr = '';
    });
  }

  Future<void> _loadSchemeSipOptions() async {
    if (!mounted) return;
    try {
      final data = await controller.fetchSchemeSipOptions(widget.scheme.schemeCode);
      if (data != null && mounted) {
        final rawFreqs = (data['supportedFrequencies'] as List<dynamic>?)?.map((e) => e.toString().toUpperCase()).toList();
        final opts = (data['options'] as List<dynamic>?)?.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        if (rawFreqs != null && rawFreqs.isNotEmpty) {
          final freqs = rawFreqs
              .toSet()
              .where((f) => ['DAILY', 'WEEKLY', 'MONTHLY', 'QUARTERLY'].contains(f))
              .toList();
          setState(() {
            _supportedFrequencies = freqs;
            if (opts != null) _sipOptions = opts;
            if (!_supportedFrequencies.contains(_selectedFrequency)) {
              _selectedFrequency = _supportedFrequencies.contains('MONTHLY') ? 'MONTHLY' : _supportedFrequencies.first;
            }
            final allowed = _currentAllowedDates;
            if (!allowed.contains(_selectedDay)) {
              _selectedDay = allowed.isNotEmpty ? allowed.first : 25;
            }
            _adjustMinAmountForFrequency();
          });
        }
      }
    } catch (_) {} 
  }

    Map<String, dynamic>? _getOptionForFrequency(String freq) {
    for (final opt in _sipOptions) {
      if (opt['frequency']?.toString().toUpperCase() == freq.toUpperCase()) {
        return opt;
      }
    }
    return null;
  }

  double get _currentMinSipAmount {
    if (!_isSip) return widget.scheme.minPurchaseAmount ?? 500.0;
    final opt = _getOptionForFrequency(_selectedFrequency);
    if (opt != null && opt['minAmount'] != null) {
      return (opt['minAmount'] as num).toDouble();
    }
    if (_selectedFrequency == 'DAILY') return 100.0;
    if (_selectedFrequency == 'WEEKLY') return 500.0;
    return widget.scheme.minSipAmount ?? 500.0;
  }

  void _adjustMinAmountForFrequency() {
    final minAmt = _currentMinSipAmount;
    if (_amount < minAmt) {
      _amountStr = minAmt.toInt().toString();
    }
  }

  List<int> get _currentAllowedDates {
    if (_selectedFrequency == 'DAILY') return const [];
    if (_selectedFrequency == 'WEEKLY') {
      final opt = _getOptionForFrequency(_selectedFrequency);
      if (opt != null && opt['allowedDates'] is List) {
        final list = (opt['allowedDates'] as List).map((e) => int.tryParse(e.toString())).whereType<int>().toList();
        final validWeekdays = list.where((d) => d >= 1 && d <= 5).toList();
        if (validWeekdays.isNotEmpty) return validWeekdays;
      }
      return const [1, 2, 3, 4, 5]; // Mon to Fri
    }
    final opt = _getOptionForFrequency(_selectedFrequency);
    if (opt != null && opt['allowedDates'] is List) {
      final list = (opt['allowedDates'] as List).map((e) => int.tryParse(e.toString())).whereType<int>().toList();
      if (list.isNotEmpty) return list;
    }
    return const [1, 5, 10, 15, 20, 25, 28];
  }

  String _getWeekdayName(int d) {
    switch (d) {
      case 1: return 'Monday';
      case 2: return 'Tuesday';
      case 3: return 'Wednesday';
      case 4: return 'Thursday';
      case 5: return 'Friday';
      default: return 'Day $d';
    }
  }

  String _formatDateSelectionLabel(int d) {
    if (_selectedFrequency == 'WEEKLY') {
      return 'Every ${_getWeekdayName(d)}';
    }
    return '$d${_getDaySuffix(d)} of month';
  }

  bool _isNseMarketHours() {
    final now = DateTime.now().toUtc();
    final ist = now.add(const Duration(hours: 5, minutes: 30));
    if (ist.weekday == DateTime.saturday || ist.weekday == DateTime.sunday) return false;
    final minutes = ist.hour * 60 + ist.minute;
    return minutes >= 9 * 60 && minutes < 15 * 60; // 09:00 AM - 03:00 PM IST
  }

  String _getDaySuffix(int day) {
    if (day >= 11 && day <= 13) return 'th';
    switch (day % 10) {
      case 1: return 'st';
      case 2: return 'nd';
      case 3: return 'rd';
      default: return 'th';
    }
  }

  Widget _buildFrequencySelector(Color surface, Color mintGreen) {
    if (!_isSip || _supportedFrequencies.length <= 1) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFF131824),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF222B3D)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _supportedFrequencies.map((freq) {
          final isSel = _selectedFrequency == freq;
          String label;
          if (freq == 'DAILY') {
            label = 'Daily';
          } else if (freq == 'WEEKLY') {
            label = 'Weekly';
          } else if (freq == 'QUARTERLY') {
            label = 'Quarterly';
          } else {
            label = 'Monthly';
          }
          return GestureDetector(
            onTap: () {
              if (_selectedFrequency != freq) {
                setState(() {
                  _selectedFrequency = freq;
                  final allowed = _currentAllowedDates;
                  if (!allowed.contains(_selectedDay)) {
                    _selectedDay = allowed.isNotEmpty ? allowed.first : 25;
                  }
                  _adjustMinAmountForFrequency();
                });
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: isSel ? mintGreen : Colors.transparent,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: isSel ? Colors.black : const Color(0xFF94A3B8),
                  fontSize: 12.5,
                  fontWeight: isSel ? FontWeight.bold : FontWeight.w600,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _openDatePickerSheet(Color bg, Color surface, Color textPrimary, Color mintGreen) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _selectedFrequency == 'WEEKLY'
                    ? 'Select Weekly SIP Debit Day'
                    : (_selectedFrequency == 'QUARTERLY'
                        ? 'Select Quarterly SIP Debit Date'
                        : 'Select Monthly SIP Debit Date'),
                style: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _selectedFrequency == 'WEEKLY'
                    ? 'Your investment will be deducted automatically on this day of each week.'
                    : 'Your investment will be deducted automatically on this date every cycle.',
                style: const TextStyle(color: Color(0xFF8B949E), fontSize: 12),
              ),
              const SizedBox(height: 20),
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _currentAllowedDates.map((d) {
                      final isSel = _selectedDay == d;
                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedDay = d);
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSel ? mintGreen : const Color(0xFF1E2533),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            _formatDateSelectionLabel(d),
                            style: TextStyle(
                              color: isSel ? Colors.black : Colors.white,
                              fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _openVpaInputDialog({bool thenSubmit = false}) {
    const bg = Color(0xFF10141E);
    const surface = Color(0xFF181F2E);
    const mintGreen = Color(0xFF00D09C);

    final TextEditingController vpaCtrl = TextEditingController(text: _vpa);
    final List<String> commonSuffixes = ['@okaxis', '@okhdfcbank', '@ybl', '@paytm', '@ibl'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(sheetCtx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: mintGreen.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.flash_on_rounded, color: mintGreen, size: 22),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Enter UPI ID', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                          SizedBox(height: 2),
                          Text('Google Pay / PhonePe / Paytm / BHIM', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'A collect request will be sent to this UPI ID by NSE Clearing Limited.',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: vpaCtrl,
                  autofocus: true,
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    hintText: 'e.g. 9997143005@okaxis or name@upi',
                    hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
                    filled: true,
                    fillColor: surface,
                    prefixIcon: const Icon(Icons.alternate_email_rounded, color: mintGreen, size: 20),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF222B3D))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF222B3D))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: mintGreen, width: 1.5)),
                  ),
                  onChanged: (_) => setSheetState(() {}),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: commonSuffixes.map((suffix) {
                    return GestureDetector(
                      onTap: () {
                        final current = vpaCtrl.text.trim();
                        final prefix = current.contains('@') ? current.split('@')[0] : current;
                        vpaCtrl.text = '$prefix$suffix';
                        vpaCtrl.selection = TextSelection.fromPosition(TextPosition(offset: vpaCtrl.text.length));
                        setSheetState(() {});
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E2535),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF2D384E)),
                        ),
                        child: Text(suffix, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.w500)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: vpaCtrl.text.trim().contains('@') && vpaCtrl.text.trim().length >= 4
                        ? () {
                            final val = vpaCtrl.text.trim();
                            setState(() {
                              _vpa = val;
                              _paymentMethod = 'NSE_GATEWAY';
                            });
                            try {
                              GetStorage().write('mf_saved_vpa', val);
                            } catch (_) {}
                            Navigator.pop(sheetCtx);
                            if (thenSubmit) {
                              _submitOrder();
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mintGreen,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      thenSubmit ? 'Confirm & Send Request' : 'Save UPI ID',
                      style: const TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openBankSelector(Color surface, Color textPrimary, Color mintGreen) {
    final ucc = controller.userUcc.value;
    final bName = (ucc != null && ucc.bankName.isNotEmpty) ? ucc.bankName : 'Verified Bank';
    final accNo = (ucc != null && ucc.accountNo.isNotEmpty)
        ? (ucc.accountNo.length > 4 ? ucc.accountNo.substring(ucc.accountNo.length - 4) : ucc.accountNo)
        : '••••';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Select Payment Mode', style: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.account_balance_rounded, color: Color(0xFF3B82F6), size: 22),
              ),
              title: const Text('Official NSE Gateway', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
              subtitle: const Text('Official NSE Clearing Limited payment portal • Pay via UPI (GPay/PhonePe/Paytm), NetBanking or NEFT', style: TextStyle(color: Color(0xFF3B82F6), fontSize: 12, fontWeight: FontWeight.w500)),
              trailing: Icon(Icons.check_circle_rounded, color: mintGreen),
              onTap: () {
                setState(() => _paymentMethod = 'NSE_GATEWAY');
                Navigator.pop(context);
              },
            ),
            if (_isSip) ...[
              const Divider(color: Color(0xFF1E2638)),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: mintGreen.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.verified_user_rounded, color: mintGreen, size: 22),
                ),
                title: Text('$bName (AutoPay Mandate)', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                subtitle: Text('A/C ••••$accNo • Recurring ${_selectedFrequency.toLowerCase()} debit via NPCI e-NACH${_selectedFrequency == "DAILY" ? " (business days)" : " on $_selectedDay${_getDaySuffix(_selectedDay)}"}', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: mintGreen.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text('LINKED', style: TextStyle(color: mintGreen, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
            const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitOrder() async {
    if (!controller.hasUcc.value || controller.onboardingStep.value == 1) {
      controller.showUccRequiredDialog();
      return;
    }

    final double minAmount = _isSip ? _currentMinSipAmount : (widget.scheme.minPurchaseAmount ?? 500.0);
    if (_amount <= 0) {
      Get.snackbar('Invalid Amount', 'Please enter an investment amount', backgroundColor: Colors.redAccent, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (_amount < minAmount) {
      Get.snackbar(
        'Minimum Amount Required',
        'Minimum ${_isSip ? "SIP" : "investment"} amount for this fund is ₹${minAmount.toInt()}',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (_isSip) {
      // Pre-check for Bank AutoPay Mandate (Step 2 of Onboarding)
      if (controller.onboardingStep.value == 2) {
        await controller.fetchOnboardingStatus();
      if (!mounted) return;
      }
      if (controller.onboardingStep.value == 2) {
        controller.showMandateRequiredDialog(
          context,
          onSwitchToLumpSum: () {
            setState(() {
              _isSip = false;
              _paymentMethod = 'NSE_GATEWAY';
              final minAmt = widget.scheme.minPurchaseAmount;
              if (minAmt != null && _amount < minAmt) {
                _amountStr = minAmt.toInt().toString();
              }
            });
            Get.snackbar(
              'Switched to One-Time Lump Sum',
              'You can now invest immediately via UPI / NetBanking without waiting for a bank mandate.',
              backgroundColor: const Color(0xFF00D09C),
              colorText: Colors.black,
              duration: const Duration(seconds: 4),
            );
          },
        );
        return;
      }

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      DateTime startDate;
      if (_selectedFrequency == 'DAILY') {
        startDate = today.add(const Duration(days: 1));
        if (startDate.weekday == DateTime.saturday) {
          startDate = startDate.add(const Duration(days: 2));
        } else if (startDate.weekday == DateTime.sunday) {
          startDate = startDate.add(const Duration(days: 1));
        }
      } else if (_selectedFrequency == 'WEEKLY') {
        // Next occurrence of selected weekday (1=Mon ... 5=Fri) with at least 7-day mandate buffer
        final targetWeekday = (_selectedDay >= 1 && _selectedDay <= 5) ? _selectedDay : DateTime.monday;
        final minAllowedDate = today.add(const Duration(days: 7));
        DateTime candidate = minAllowedDate;
        while (candidate.weekday != targetWeekday) {
          candidate = candidate.add(const Duration(days: 1));
        }
        startDate = candidate;
      } else {
        final candidate = DateTime(now.year, now.month, _selectedDay);
        final daysDiff = candidate.difference(today).inDays;
        startDate = daysDiff < 7 ? DateTime(now.year, now.month + 1, _selectedDay) : candidate;
      }






      final success = await controller.registerSipOrder(
        schemeCode: widget.scheme.schemeCode,
        schemeName: widget.scheme.schemeName,
        installmentAmount: _amount,
        frequency: _selectedFrequency,
        startDate: startDate,
        paymentMode: _paymentMethod,
        firstOrderToday: _isNseMarketHours(),
      );
      if (success) {
        if (!mounted) return;
        Navigator.pop(context);
      }
    } else {
      final success = await controller.createPurchaseOrder(
        schemeCode: widget.scheme.schemeCode,
        schemeName: widget.scheme.schemeName,
        orderAmount: _amount,
        paymentMode: 'NSE_GATEWAY',
      );
      if (success) {
        if (!mounted) return;
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF0A0D14);
    const surface = Color(0xFF121620);
    const textPrimary = Color(0xFFF1F5F9);
    const textSecondary = Color(0xFF8B949E);
    const mintGreen = Color(0xFF00D09C);

    final double minAmount = _isSip ? _currentMinSipAmount : (widget.scheme.minPurchaseAmount ?? 500.0);
    final bool isValidAmount = _amount >= minAmount;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.headset_mic_rounded, color: Colors.white70, size: 21),
            tooltip: 'MF Support',
            onPressed: () => MfSupportBottomSheet.show(context, initialCategory: 'FIRST_SIP_NOT_CUT'),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  _isSip = !_isSip;
                  _paymentMethod = 'NSE_GATEWAY';
                  final minAmt = _isSip ? widget.scheme.minSipAmount : widget.scheme.minPurchaseAmount;
                  if (minAmt != null && _amount < minAmt) {
                    _amountStr = minAmt.toInt().toString();
                  }
                });
              },
              icon: Icon(
                _isSip ? Icons.swap_horiz_rounded : Icons.autorenew_rounded,
                size: 16,
                color: mintGreen,
              ),
              label: Text(
                _isSip ? 'One-time' : 'Switch to SIP',
                style: TextStyle(color: mintGreen, fontSize: 12, fontWeight: FontWeight.bold),
              ),
              style: TextButton.styleFrom(
                backgroundColor: mintGreen.withValues(alpha: 0.12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              ),
            ),
          ),
        ],
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isSip ? 'SIP' : 'One-time Investment',
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              widget.scheme.schemeName,
              style: const TextStyle(color: textSecondary, fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Investment amount',
                        style: TextStyle(color: textSecondary, fontSize: 13),
                      ),
                      const SizedBox(height: 8),

                      // Large Amount Display with Clear (x) Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '₹${_formatCurrency(_amountStr)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 38,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                          if (_amountStr.isNotEmpty) ...[
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: _clearAmount,
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF222838),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close_rounded, color: Colors.white70, size: 15),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Quick Increment Chips (+ ₹1,000, + ₹2,000, + ₹5,000)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildIncrementChip('+ ₹1,000', () => _addIncrement(1000)),
                          const SizedBox(width: 8),
                          _buildIncrementChip('+ ₹2,000', () => _addIncrement(2000)),
                          const SizedBox(width: 8),
                          _buildIncrementChip('+ ₹5,000', () => _addIncrement(5000)),
                        ],
                      ),
                      const SizedBox(height: 12),

                      if (_isSip) _buildFrequencySelector(surface, mintGreen),

                      // Frequency / Date Dropdown Pill
                      if (_isSip)
                        GestureDetector(
                          onTap: _selectedFrequency == 'DAILY' ? null : () => _openDatePickerSheet(bg, surface, textPrimary, mintGreen),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF131824),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF222B3D)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.calendar_today_outlined, color: Colors.white, size: 15),
                                const SizedBox(width: 8),
                                Text(
                                  _selectedFrequency == 'DAILY'
                                      ? 'Daily (Mon - Fri)'
                                      : (_selectedFrequency == 'WEEKLY'
                                          ? 'Every ${_getWeekdayName(_selectedDay)}'
                                          : '${_selectedFrequency == "QUARTERLY" ? "Quarterly" : "Monthly"} on $_selectedDay${_getDaySuffix(_selectedDay)}'),
                                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                                if (_selectedFrequency != 'DAILY') ...[
                                  const SizedBox(width: 6),
                                  const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white70, size: 18),
                                ],
                              ],
                            ),
                          ),
                        ),
                      if (_isSip) _buildSipScheduleInfoCard(mintGreen),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Payment Method Row (Above Keypad) ──
          Builder(
            builder: (_) {
              final ucc = controller.userUcc.value;
              final bName = (ucc != null && ucc.bankName.isNotEmpty) ? ucc.bankName : 'Bank Account';
              final accNo = (ucc != null && ucc.accountNo.isNotEmpty)
                  ? (ucc.accountNo.length > 4 ? ucc.accountNo.substring(ucc.accountNo.length - 4) : ucc.accountNo)
                  : '••••';

              IconData icon;
              Color iconColor;
              String title;
              String badgeText;
              String subtitle;

              icon = Icons.account_balance_rounded;
              iconColor = const Color(0xFF3B82F6);
              title = 'Official NSE Gateway';
              badgeText = 'NSE MFSS';
              final marketOpen = _isNseMarketHours();
              subtitle = _isSip
                  ? (marketOpen
                      ? 'First order today on NSE • Recurring debit from $bName (••••$accNo)'
                      : 'Market closed • Recurring debit starting next trading day')
                  : 'Direct payment via UPI (GPay/PhonePe), NetBanking & NEFT';

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: const BoxDecoration(
                  color: Color(0xFF0F131D),
                  border: Border(top: BorderSide(color: Color(0xFF1A2230), width: 1)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E2535),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        icon,
                        color: iconColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (_paymentMethod == 'UPI' && _vpa.isEmpty) {
                            _openVpaInputDialog();
                          } else {
                            _openBankSelector(surface, textPrimary, mintGreen);
                          }
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    title,
                                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: mintGreen.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    badgeText,
                                    style: TextStyle(
                                      color: _paymentMethod == 'NSE_GATEWAY' ? const Color(0xFF3B82F6) : mintGreen,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              subtitle,
                              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _openBankSelector(surface, textPrimary, mintGreen),
                      child: Row(
                        children: [
                          const Text(
                            'NSE Gateway',
                            style: TextStyle(color: Color(0xFF3B82F6), fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 2),
                          const Icon(Icons.verified_rounded, color: Color(0xFF3B82F6), size: 18),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // ── Custom In-App Numeric Keypad ──
          Container(
            color: const Color(0xFF090C12),
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                Row(
                  children: [
                    _buildKeypadKey('1'),
                    _buildKeypadKey('2'),
                    _buildKeypadKey('3'),
                  ],
                ),
                Row(
                  children: [
                    _buildKeypadKey('4'),
                    _buildKeypadKey('5'),
                    _buildKeypadKey('6'),
                  ],
                ),
                Row(
                  children: [
                    _buildKeypadKey('7'),
                    _buildKeypadKey('8'),
                    _buildKeypadKey('9'),
                  ],
                ),
                Row(
                  children: [
                    _buildKeypadKey('.'),
                    _buildKeypadKey('0'),
                    _buildKeypadKey('⌫'),
                  ],
                ),
              ],
            ),
          ),

          // ── Bottom Action Buttons (Add to cart & Start SIP) ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: bg,
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () async {
                          final amt = _amount;
                          if (amt <= 0) {
                            Get.snackbar(
                              'Enter Amount',
                              'Please enter an amount before adding to cart.',
                              backgroundColor: const Color(0xFF1E2535),
                              colorText: Colors.white,
                              snackPosition: SnackPosition.BOTTOM,
                            );
                            return;
                          }
                          await controller.addToCart(
                            scheme: widget.scheme,
                            amount: amt,
                            investmentType: _isSip ? 'SIP' : 'LUMPSUM',
                            frequency: _selectedFrequency,
                            sipDay: _selectedDay,
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: const Color(0xFF121622),
                          side: const BorderSide(color: Color(0xFF1E2638)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Add to cart', style: TextStyle(color: Color(0xFF8B949E), fontSize: 14, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: Obx(
                        () => ElevatedButton(
                          onPressed: (isValidAmount && !controller.isSubmittingOrder.value) ? _submitOrder : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isValidAmount ? mintGreen : const Color(0xFF1A2A24),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: controller.isSubmittingOrder.value
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                              : Text(
                                  _isSip ? 'Start SIP' : 'Invest Now',
                                  style: TextStyle(
                                    color: isValidAmount ? Colors.black : const Color(0xFF3B564C),
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncrementChip(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF101520),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF222B3D)),
        ),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildKeypadKey(String text) {
    return Expanded(
      child: InkWell(
        onTap: () => _onKeypadTap(text),
        child: Container(
          height: 52,
          alignment: Alignment.center,
          child: text == '⌫'
              ? const Icon(Icons.backspace_outlined, color: Colors.white, size: 20)
              : Text(
                  text,
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
        ),
      ),
    );
  }

  Widget _buildSipScheduleInfoCard(Color mintGreen) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final candidate = DateTime(now.year, now.month, _selectedDay);
    final daysDiff = candidate.difference(today).inDays;
    final bool bufferApplied = daysDiff < 7;
    final DateTime nextDebit = bufferApplied
        ? DateTime(now.year, now.month + 1, _selectedDay)
        : candidate;

    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final nextDebitStr = '${nextDebit.day} ${months[nextDebit.month - 1]} ${nextDebit.year}';
    final marketOpen = _isNseMarketHours();

    return Container(
      margin: const EdgeInsets.only(top: 10, left: 18, right: 18),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF101726),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1E2D4A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded, color: mintGreen, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 11.5, height: 1.38, color: Color(0xFF94A3B8)),
                    children: [
                      TextSpan(
                        text: marketOpen ? 'Installment #1: ' : 'First AutoPay Debit: ',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: marketOpen
                            ? 'Invest today via NSE Gateway.\r\n'
                            : 'Starting on $nextDebitStr.\r\n',
                        style: TextStyle(color: marketOpen ? mintGreen : const Color(0xFF38BDF8), fontWeight: FontWeight.w600),
                      ),
                      const TextSpan(
                        text: 'Recurring AutoPay: ',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: 'Deductions on $nextDebitStr (7-day bank mandate setup buffer applies).\r\n',
                        style: const TextStyle(color: Color(0xFFCBD5E1)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.mark_email_unread_rounded, color: Color(0xFFEAB308), size: 15),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    'Check your SMS/Email for official NSE OTP verification link.',
                    style: TextStyle(color: Color(0xFFF1F5F9), fontSize: 11, fontWeight: FontWeight.w500),
                  ),
                ),
                GestureDetector(
                  onTap: () => MfSupportBottomSheet.show(context, initialCategory: 'FIRST_SIP_NOT_CUT'),
                  child: Text(
                    'Help',
                    style: TextStyle(color: mintGreen, fontSize: 11, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
