import 'package:image_picker/image_picker.dart';
import 'dart:ui';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vika1/modules/wallet/views/wallet_view.dart';
import 'package:vika1/data/repositories/gold_repository.dart';
import 'package:vika1/modules/invoice/views/invoice_viewer_view.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/controllers/theme_controller.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../digi_gold/controllers/digi_gold_controller.dart'
    show GoldController;
import '../../kyc/controllers/kyc_controller.dart' show KycController;
import '../../../data/repositories/kyc_repository.dart' show KycRepository;
import '../../wallet/controllers/wallet_controller.dart' show WalletController;
import '../../../core/services/lock_service.dart';
import '../../../routes/app_routes.dart';
import 'package:vika1/modules/profile/utils/policy_texts.dart';

const _gold = Color(0xFFD4A017);

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<KycRepository>()) {
      Get.lazyPut(() => KycRepository());
    }
    final kycCtrl = Get.isRegistered<KycController>()
        ? Get.find<KycController>()
        : Get.put(KycController());

    final walletCtrl = Get.isRegistered<WalletController>()
        ? Get.find<WalletController>()
        : Get.put(WalletController());

    return Obx(() {
      final dark = ThemeController.to.isDark.value;

      final bg = dark ? const Color(0xFF03160E) : const Color(0xFFF4F7F4);
      final textPrimary = dark ? Colors.white : const Color(0xFF03160E);
      final textSecondary = dark ? Colors.white60 : const Color(0xFF4A554F);
      final cardColor = dark ? const Color(0xFF0C2017) : Colors.white;
      final balanceCardColor = dark
          ? const Color(0xFF132F23)
          : const Color(0xFFFCF7EF);
      final listCardColor = dark ? const Color(0xFF0B1A13) : Colors.white;
      final borderSideColor = dark
          ? const Color(0xFF1E352B)
          : const Color(0xFFE2EBE5);

      final authCtrl = Get.find<AuthController>();
      final user = authCtrl.user.value;
      final initial = (user?.name?.isNotEmpty == true ? user!.name[0] : '?')
          .toUpperCase();
      final name = user?.name ?? 'Guest';
      final phone = user?.phone ?? '—';
      final email = user?.email ?? '';

      final goldGrams = GoldController.to.totalGrams;
      final goldValuation =
          GoldController.to.balance.value?.currentValue ?? 0.0;
      final totalInvested = GoldController.to.balance.value?.investedAmt ?? 0.0;
      final totalReturns = GoldController.to.balance.value?.gainLoss ?? 0.0;

      final walletBal = walletCtrl.wallet.value?.balance ?? 0.0;

      return Container(
        color: bg,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // --------- Header & Top App Bar ---------
              Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  MediaQuery.paddingOf(context).top + 10,
                  20,
                  16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'My Profile',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Row(
                      children: [
                        _circleActionIcon(
                          icon: Icons.notifications_none_outlined,
                          onTap: () => Get.toNamed(AppRoutes.notifications),
                          border: borderSideColor,
                        ),
                        const SizedBox(width: 12),
                        _circleActionIcon(
                          icon: Icons.settings_outlined,
                          onTap: () => Get.toNamed(AppRoutes.security),
                          border: borderSideColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // --------- User Profile Card ---------
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF042116),
                    borderRadius: BorderRadius.circular(24),
                    image: const DecorationImage(
                      image: AssetImage('assets/images/gold_banner.png'),
                      fit: BoxFit.cover,
                      opacity: 0.15,
                    ),
                    border: Border.all(color: const Color(0xFF1E3D30)),
                  ),
                  child: Row(
                    children: [
                                            // Interactive User Avatar with Camera / Photo Picker
                      GestureDetector(
                        onTap: () => _showProfilePhotoModal(context, authCtrl),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 76,
                              height: 76,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const RadialGradient(
                                  colors: [Color(0xFF133829), Color(0xFF042116)],
                                ),
                                border: Border.all(color: _gold, width: 2.2),
                                boxShadow: [
                                  BoxShadow(
                                    color: _gold.withValues(alpha: 0.25),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: Obx(() {
                                  if (authCtrl.isUploadingAvatar.value) {
                                    return const Center(
                                      child: SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: _gold,
                                        ),
                                      ),
                                    );
                                  }

                                  final avatarUrl = authCtrl.user.value?.avatarUrl;
                                  if (avatarUrl != null && avatarUrl.isNotEmpty) {
                                    return Image.network(
                                      avatarUrl,
                                      fit: BoxFit.cover,
                                      width: 76,
                                      height: 76,
                                      errorBuilder: (context, error, stackTrace) => Center(
                                        child: Text(
                                          initial,
                                          style: const TextStyle(
                                            color: _gold,
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      loadingBuilder: (_, child, progress) {
                                        if (progress == null) return child;
                                        return const Center(
                                          child: SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: _gold,
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  }

                                  return Center(
                                    child: Text(
                                      initial,
                                      style: const TextStyle(
                                        color: _gold,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                            // Camera Edit Badge Icon
                            Positioned(
                              bottom: -2,
                              right: -2,
                              child: Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  color: _gold,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: const Color(0xFF042116), width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.4),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.camera_alt_rounded,
                                    size: 13,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.verified,
                                  color: _gold,
                                  size: 16,
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              phone,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            if (email.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                email,
                                style: const TextStyle(
                                  color: Colors.white60,
                                  fontSize: 11,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: _gold.withOpacity(0.4),
                                ),
                                borderRadius: BorderRadius.circular(20),
                                color: _gold.withOpacity(0.08),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(
                                    Icons.workspace_premium_outlined,
                                    color: _gold,
                                    size: 12,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Gold Investor',
                                    style: TextStyle(
                                      color: _gold,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // --------- Gold Balance / Value Card ---------
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: balanceCardColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: borderSideColor),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'My Gold Balance',
                              style: TextStyle(
                                color: textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${goldGrams.toStringAsFixed(3)} g',
                              style: TextStyle(
                                color: textPrimary,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '= ₹${goldValuation.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: textSecondary,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(height: 60, width: 1, color: borderSideColor),
                      Expanded(
                        flex: 6,
                        child: Row(
                          children: [
                            Expanded(
                              child: _miniStat(
                                'Total Invested',
                                '₹${totalInvested.toStringAsFixed(0)}',
                                Icons.payments_outlined,
                                textSecondary,
                                textPrimary,
                              ),
                            ),
                            Expanded(
                              child: _miniStat(
                                'Current Value',
                                '₹${goldValuation.toStringAsFixed(0)}',
                                Icons.trending_up_rounded,
                                textSecondary,
                                textPrimary,
                              ),
                            ),
                            Expanded(
                              child: _miniStat(
                                'Total Returns',
                                '${totalReturns >= 0 ? '+' : ''}₹${totalReturns.toStringAsFixed(0)}',
                                Icons.workspace_premium_outlined,
                                textSecondary,
                                const Color(0xFF2E7D32),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // --------- Wallet Balance Card ---------
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: dark
                          ? [const Color(0xFF0F3223), const Color(0xFF081C13)]
                          : [const Color(0xFFE8F5E9), const Color(0xFFC8E6C9)],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: borderSideColor),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(dark ? 0.15 : 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.account_balance_wallet_rounded,
                                  color: _gold,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Payvika Wallet',
                                  style: TextStyle(
                                    color: textPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '₹${(walletCtrl.wallet.value?.balance ?? 0.0).toStringAsFixed(2)}',
                              style: TextStyle(
                                color: textPrimary,
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Available Balance',
                              style: TextStyle(
                                color: textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12), // gap
                      ElevatedButton.icon(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          Get.to(() => const WalletView());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _gold,
                          foregroundColor: const Color(0xFF3D2B00),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                          minimumSize: Size
                              .zero, // ← ADD: stop forced infinite/huge size
                          tapTargetSize:
                              MaterialTapTargetSize.shrinkWrap, // ← ADD
                        ),
                        icon: const Icon(Icons.arrow_forward_rounded, size: 14),
                        label: const Text(
                          'Manage',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // --------- Horizontal Quick Actions Bar ---------
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF042116),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF1E3D30)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _actionTab(
                        Icons.assignment_outlined,
                        'My Orders',
                        () => Get.toNamed(AppRoutes.transactions),
                      ),
                      _actionTab(
                        Icons.loop_outlined,
                        'SIP & Schemes',
                        () => Get.toNamed(AppRoutes.goldSchemes),
                      ),
                      _actionTab(
                        Icons.receipt_long_outlined,
                        'History',
                        () => Get.toNamed(AppRoutes.transactions),
                      ),
                      _actionTab(
                        Icons.share_outlined,
                        'My Referrals',
                        () => Get.toNamed(AppRoutes.rewards),
                      ),
                      _actionTab(Icons.headset_mic_outlined, 'Help Support', () {
                        Get.dialog(
                          AlertDialog(
                            backgroundColor: cardColor,
                            title: Text(
                              'Customer Care',
                              style: TextStyle(color: textPrimary),
                            ),
                            content: Text(
                              'Connect with our support team at info@vikaone.com.',
                              style: TextStyle(color: textSecondary),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Get.back(),
                                child: const Text(
                                  'Dismiss',
                                  style: TextStyle(color: _gold),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // --------- Settings Menu Cards List ---------
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: listCardColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: borderSideColor),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(dark ? 0.2 : 0.03),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _menuRow(
                        icon: Icons.person_outline_rounded,
                        label: 'Personal Information',
                        textPrimary: textPrimary,
                        borderSide: borderSideColor,
                        onTap: () {
                          final freshUser =
                              Get.find<AuthController>().user.value;
                          final freshName = freshUser?.name ?? 'Guest';
                          final freshEmail = freshUser?.email ?? '';
                          final freshPhone = freshUser?.phone ?? '—';

                          final nameCtrl = TextEditingController(
                            text: freshName,
                          );
                          final emailCtrl = TextEditingController(
                            text: freshEmail,
                          );
                          Get.dialog(
                            AlertDialog(
                              backgroundColor: cardColor,
                              title: Text(
                                'Edit Personal Profile',
                                style: TextStyle(
                                  color: textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextField(
                                    controller: nameCtrl,
                                    style: TextStyle(color: textPrimary),
                                    decoration: InputDecoration(
                                      labelText: 'Full Name',
                                      labelStyle: TextStyle(
                                        color: textSecondary,
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: borderSideColor,
                                        ),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: _gold),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  TextField(
                                    controller: emailCtrl,
                                    style: TextStyle(color: textPrimary),
                                    decoration: InputDecoration(
                                      labelText: 'Email Address',
                                      labelStyle: TextStyle(
                                        color: textSecondary,
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: borderSideColor,
                                        ),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: _gold),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Phone: ',
                                        style: TextStyle(
                                          color: textSecondary,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Text(
                                        freshPhone,
                                        style: TextStyle(
                                          color: textPrimary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Get.back(),
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    final ok = await Get.find<AuthController>()
                                        .updateProfile(
                                          name: nameCtrl.text.trim(),
                                          email: emailCtrl.text.trim(),
                                        );
                                    if (ok) {
                                      Get.back();
                                      Get.snackbar(
                                        'Success ✓',
                                        'Profile updated successfully',
                                        backgroundColor: const Color(
                                          0xFF2ECC71,
                                        ),
                                        colorText: Colors.white,
                                      );
                                    } else {
                                      final err = Get.find<AuthController>()
                                          .errorMsg
                                          .value;
                                      Get.snackbar(
                                        'Error',
                                        err.isNotEmpty
                                            ? err
                                            : 'Failed to update profile',
                                        backgroundColor: const Color(
                                          0xFFE53E3E,
                                        ),
                                        colorText: Colors.white,
                                      );
                                    }
                                  },
                                  child: const Text(
                                    'Save',
                                    style: TextStyle(
                                      color: _gold,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      // KYC Verification
                      Obx(() {
                        final kyc = kycCtrl.kycStatus.value;
                        final isVerified =
                            kyc == 'approved' || kyc == 'verified';
                        final isPending = kyc == 'pending';

                        String statusText = 'Not Verified';
                        Color badgeColor = Colors.grey.withOpacity(0.12);
                        Color textColor = Colors.grey;

                        if (isVerified) {
                          statusText = 'Verified';
                          badgeColor = const Color(0xFFE8F5E9);
                          textColor = const Color(0xFF2E7D32);
                        } else if (isPending) {
                          statusText = 'Pending';
                          badgeColor = const Color(0xFFFFF3E0);
                          textColor = const Color(0xFFE65100);
                        }

                        return _menuRow(
                          icon: Icons.verified_user_outlined,
                          label: 'KYC Verification',
                          textPrimary: textPrimary,
                          borderSide: borderSideColor,
                          onTap: () => Get.toNamed(AppRoutes.kyc),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: badgeColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isVerified
                                      ? Icons.check
                                      : isPending
                                      ? Icons.hourglass_empty_rounded
                                      : Icons.warning_amber_rounded,
                                  color: textColor,
                                  size: 11,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  statusText,
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),

                      _menuRow(
                        icon: Icons.account_balance_outlined,
                        label: 'Bank & Payment Details',
                        textPrimary: textPrimary,
                        borderSide: borderSideColor,
                        onTap: () => Get.toNamed(AppRoutes.bankAccounts),
                      ),
                      _menuRow(
                        icon: Icons.receipt_long_outlined,
                        label: 'Invoice Preview (Sample)',
                        textPrimary: textPrimary,
                        borderSide: borderSideColor,
                        onTap: () async {
                          HapticFeedback.lightImpact();
                          Get.dialog(
                            const Center(
                              child: CircularProgressIndicator(color: _gold),
                            ),
                            barrierDismissible: false,
                          );

                          try {
                            final repo = GoldRepository();
                            final bytes = await repo.getTransactionInvoice(
                              "sample",
                              isSample: true,
                            );
                            final dir = await getTemporaryDirectory();
                            final file = File('${dir.path}/invoice-sample.pdf');
                            await file.writeAsBytes(bytes);
                            Get.back();
                            Get.to(
                              () => InvoiceViewerView(
                                filePath: file.path,
                                title: 'Sample Invoice',
                              ),
                            );
                            return;
                          } catch (e) {
                            debugPrint(
                              "Could not load real transaction for sample: $e",
                            );
                          }

                          try {
                            const samplePdfBase64 =
                                'JVBERi0xLjQKJdPr6gogMSAwIG9iaiA8PC9UeXBlL0NhdGFsb2cvUGFnZXMgMiAwIFI+PiBlbmRvYmogMiAwIG9iaiA8PC9UeXBlL1BhZ2VzL0tpZHNbMyAwIFJdL0NvdW50IDE+PiBlbmRvYmogMyAwIG9iaiA8PC9UeXBlL1BhZ2UvUGFyZW50IDIgMCBSL1Jlc291cmNlczw8L0ZvbnQ8PC9GMTw8L1R5cGUvRm9udC9TdWJ0eXBlL1R5cGUxL0Jhc2VGb250L0hlbHZldGljYT4+Pj4+L01lZGlhQm94WzAgMCA1OTUuMjcgODQxLjg5XS9Db250ZW50cyA0IDAgUj4+IGVuZG9iaiA0IDAgb2JqIDw8L0xlbmd0aCA4NT4+IHN0cmVhbQpCVAovRjEgMjQgVGYKNzAgNzAwIFRkCihHb2xkVmlrYW9uZSAtIFNhbXBsZSBJbnZvaWNlKSBUagovRjEgMTIgVGYKMCAtNDAgVGQKKEhhdmUgYSB3b25kZXJmdWwgZGF5ISkgVGoKRVQKZW5kc3RyZWFtIGVuZG9iaiB4cmVmCjAgNQowMDAwMDAwMDAwIDY1NTM1IGYgCjAwMDAwMDAwMTUgMDAwMDAgbiAKMDAwMDAwMDA2MCAwMDAwMCBuIAowMDAwMDAwMTE1IDAwMDAwIG4gCjAwMDAwMDAyNzQgMDAwMDAgbiAKdHJhaWxlciA8PC9TaXplIDUvUm9vdCAxIDAgUj4+CnN0YXJ0eHJlZgogNDEwCiUlRU9GCg==';
                            final bytes = base64Decode(samplePdfBase64);
                            final dir = await getTemporaryDirectory();
                            final file = File(
                              '${dir.path}/invoice-sample-fallback.pdf',
                            );
                            await file.writeAsBytes(bytes);
                            Get.back();
                            Get.to(
                              () => InvoiceViewerView(
                                filePath: file.path,
                                title: 'Sample Invoice',
                              ),
                            );
                          } catch (e) {
                            Get.back();
                            Get.snackbar(
                              'Error',
                              'Failed to load sample invoice: $e',
                              backgroundColor: const Color(0xFFE53E3E),
                              colorText: Colors.white,
                            );
                          }
                        },
                      ),
                      _menuRow(
                        icon: Icons.local_shipping_outlined,
                        label: 'My Orders & Tracking',
                        textPrimary: textPrimary,
                        borderSide: borderSideColor,
                        onTap: () => Get.toNamed(AppRoutes.orders),
                      ),
                      _menuRow(
                        icon: Icons.lock_outline_rounded,
                        label: 'Security Settings',
                        textPrimary: textPrimary,
                        borderSide: borderSideColor,
                        onTap: () => Get.toNamed(AppRoutes.security),
                      ),
                      // _menuRow(
                      //   icon: Icons.star_outline_rounded,
                      //   label: 'My Benefits',
                      //   textPrimary: textPrimary,
                      //   borderSide: borderSideColor,
                      //   onTap: () => Get.toNamed(AppRoutes.rewards),
                      // ),
                      _menuRow(
                        icon: Icons.card_giftcard_rounded,
                        label: 'Refer & Earn',
                        textPrimary: textPrimary,
                        borderSide: borderSideColor,
                        onTap: () => Get.toNamed(AppRoutes.rewards),
                      ),
                      _menuRow(
                        icon: Icons.description_outlined,
                        label: 'Terms & Conditions',
                        textPrimary: textPrimary,
                        borderSide: borderSideColor,
                        onTap: () => Get.toNamed(
                          AppRoutes.policy,
                          arguments: {
                            'title': 'Terms & Conditions',
                            'content': PolicyTexts.terms,
                          },
                        ),
                      ),
                      _menuRow(
                        icon: Icons.privacy_tip_outlined,
                        label: 'Privacy Policy',
                        textPrimary: textPrimary,
                        borderSide: borderSideColor,
                        onTap: () => Get.toNamed(
                          AppRoutes.policy,
                          arguments: {
                            'title': 'Privacy Policy',
                            'content': PolicyTexts.privacy,
                          },
                        ),
                      ),
                      _menuRow(
                        icon: Icons.local_shipping_outlined,
                        label: 'Shipping Policy',
                        textPrimary: textPrimary,
                        borderSide: borderSideColor,
                        onTap: () => Get.toNamed(
                          AppRoutes.policy,
                          arguments: {
                            'title': 'Shipping Policy',
                            'content': PolicyTexts.shipping,
                          },
                        ),
                      ),
                      _menuRow(
                        icon: Icons.assignment_return_outlined,
                        label: 'Return Policy',
                        textPrimary: textPrimary,
                        borderSide: borderSideColor,
                        onTap: () => Get.toNamed(
                          AppRoutes.policy,
                          arguments: {
                            'title': 'Return Policy',
                            'content': PolicyTexts.returns,
                          },
                        ),
                      ),
                      _menuRow(
                        icon: Icons.currency_rupee_outlined,
                        label: 'Refund Policy',
                        textPrimary: textPrimary,
                        borderSide: borderSideColor,
                        onTap: () => Get.toNamed(
                          AppRoutes.policy,
                          arguments: {
                            'title': 'Refund Policy',
                            'content': PolicyTexts.refund,
                          },
                        ),
                      ),
                      _menuRow(
                        icon: dark
                            ? Icons.dark_mode_rounded
                            : Icons.wb_sunny_rounded,
                        label: dark ? 'Theme: Dark Mode' : 'Theme: Light Mode',
                        textPrimary: textPrimary,
                        borderSide: borderSideColor,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          ThemeController.to.toggle();
                        },
                        trailing: Icon(
                          dark
                              ? Icons.toggle_on_rounded
                              : Icons.toggle_off_rounded,
                          color: dark ? _gold : Colors.grey,
                          size: 32,
                        ),
                      ),
                      _menuRow(
                        icon: Icons.logout_rounded,
                        label: 'Logout',
                        textPrimary: const Color(0xFFD32F2F),
                        borderSide: Colors.transparent,
                        onTap: () {
                          Get.dialog(
                            AlertDialog(
                              backgroundColor: cardColor,
                              title: Text(
                                'Sign Out',
                                style: TextStyle(color: textPrimary),
                              ),
                              content: Text(
                                'Are you sure you want to log out of Vikaone?',
                                style: TextStyle(color: textSecondary),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Get.back(),
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Get.back();
                                    Get.find<AuthController>().logout();
                                  },
                                  child: const Text(
                                    'Log Out',
                                    style: TextStyle(color: Color(0xFFD32F2F)),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 120),
            ],
          ),
        ),
      );
    });
  }

  Widget _circleActionIcon({
    required IconData icon,
    required VoidCallback onTap,
    required Color border,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: _gold.withOpacity(0.4)),
          color: Colors.transparent,
        ),
        child: Icon(icon, color: _gold, size: 18),
      ),
    );
  }

  Widget _miniStat(
    String label,
    String value,
    IconData icon,
    Color labelColor,
    Color valColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: labelColor, size: 14),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: labelColor,
            fontSize: 8,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            color: valColor,
            fontSize: 10,
            fontWeight: FontWeight.w900,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _actionTab(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: _gold, size: 20),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuRow({
    required IconData icon,
    required String label,
    required Color textPrimary,
    required Color borderSide,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: borderSide)),
        ),
        child: Row(
          children: [
            Icon(icon, color: textPrimary.withOpacity(0.8), size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (trailing != null) ...[trailing, const SizedBox(width: 8)],
            Icon(
              Icons.chevron_right_rounded,
              color: textPrimary.withOpacity(0.4),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  void _showProfilePhotoModal(BuildContext context, AuthController authCtrl) {
    final hasExistingPhoto = authCtrl.user.value?.avatarUrl?.isNotEmpty == true;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        decoration: const BoxDecoration(
          color: Color(0xFF0F172A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: Color(0xFF1E293B), width: 1.5)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 18),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.account_circle_rounded, color: _gold, size: 22),
                SizedBox(width: 8),
                Text(
                  'Profile Photo',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Choose how you want to set your profile picture',
              style: TextStyle(color: Colors.white60, fontSize: 12.5),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () async {
                      Get.back();
                      final picker = ImagePicker();
                      final picked = await picker.pickImage(
                        source: ImageSource.camera,
                        imageQuality: 85,
                        maxWidth: 1000,
                        maxHeight: 1000,
                      );
                      if (picked != null) {
                        final success = await authCtrl.uploadProfilePicture(File(picked.path));
                        if (success) {
                          Get.snackbar(
                            'Photo Updated',
                            'Profile picture updated successfully!',
                            backgroundColor: const Color(0xFF1FAE7A),
                            colorText: Colors.white,
                            snackPosition: SnackPosition.BOTTOM,
                            margin: const EdgeInsets.all(12),
                          );
                        }
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF334155)),
                      ),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.camera_alt_rounded, color: _gold, size: 28),
                          SizedBox(height: 8),
                          Text(
                            'Take Photo',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () async {
                      Get.back();
                      final picker = ImagePicker();
                      final picked = await picker.pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 85,
                        maxWidth: 1000,
                        maxHeight: 1000,
                      );
                      if (picked != null) {
                        final success = await authCtrl.uploadProfilePicture(File(picked.path));
                        if (success) {
                          Get.snackbar(
                            'Photo Updated',
                            'Profile picture updated successfully!',
                            backgroundColor: const Color(0xFF1FAE7A),
                            colorText: Colors.white,
                            snackPosition: SnackPosition.BOTTOM,
                            margin: const EdgeInsets.all(12),
                          );
                        }
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF334155)),
                      ),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.photo_library_rounded, color: _gold, size: 28),
                          SizedBox(height: 8),
                          Text(
                            'From Gallery',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (hasExistingPhoto) ...[
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFEF4444),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    Get.back();
                    final success = await authCtrl.removeProfilePicture();
                    if (success) {
                      Get.snackbar(
                        'Photo Removed',
                        'Profile picture has been removed.',
                        backgroundColor: const Color(0xFF1E293B),
                        colorText: Colors.white,
                        snackPosition: SnackPosition.BOTTOM,
                        margin: const EdgeInsets.all(12),
                      );
                    }
                  },
                  icon: const Icon(Icons.delete_outline_rounded, size: 18),
                  label: const Text(
                    'Remove Current Photo',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

}
