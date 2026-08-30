import 'package:vika1/modules/notifications/bindings/notification_binding.dart';
import 'package:vika1/modules/notifications/views/notification_history_view.dart';
import 'package:get/get.dart';
import 'package:vika1/modules/update/views/app_update_view.dart';
import 'package:vika1/modules/home/bindings/home_binding.dart';
import 'package:vika1/modules/home/views/main_shell_view.dart';
import 'package:vika1/modules/auth/bindings/auth_binding.dart';
import 'package:vika1/modules/auth/views/login_view.dart';
import 'package:vika1/modules/auth/views/splash_view.dart';
import 'package:vika1/modules/auth/views/register_view.dart';
import 'package:vika1/modules/auth/views/forgot_password_view.dart';
import 'package:vika1/modules/kyc/bindings/kyc_binding.dart';
import 'package:vika1/modules/kyc/views/kyc_view.dart';
import 'package:vika1/modules/lock/views/passcode_setup_view.dart' show PasscodeSetupView, LockScreenView;
import 'package:vika1/modules/lock/views/security_settings_view.dart';

// Digi Gold — home + shared gold state
import 'package:vika1/modules/digi_gold/bindings/digi_gold_binding.dart';
import 'package:vika1/modules/digi_gold/views/digi_gold_view.dart';
import 'package:vika1/modules/digi_gold/views/my_gold_view.dart';
import 'package:vika1/modules/digi_gold/views/gift_view.dart';
import 'package:vika1/modules/digi_gold/views/coin_detail_view.dart';

// Buy Gold
import 'package:vika1/modules/buy_gold/bindings/buy_gold_binding.dart';
import 'package:vika1/modules/buy_gold/views/buy_gold_view.dart';

// Sell Gold
import 'package:vika1/modules/sell_gold/bindings/sell_gold_binding.dart';
import 'package:vika1/modules/sell_gold/views/sell_gold_view.dart';

// Silver
import 'package:vika1/modules/silver/bindings/silver_binding.dart';
import 'package:vika1/modules/silver/views/buy_silver_view.dart';
import 'package:vika1/modules/silver/views/sell_silver_view.dart';
import 'package:vika1/modules/silver/views/my_silver_view.dart';
import 'package:vika1/modules/silver_sip/bindings/silver_sip_binding.dart';
import 'package:vika1/modules/silver_sip/views/silver_sip_view.dart';

// Copper
import 'package:vika1/modules/copper/bindings/copper_binding.dart';
import 'package:vika1/modules/copper/views/buy_copper_view.dart';
import 'package:vika1/modules/copper/views/sell_copper_view.dart';
import 'package:vika1/modules/copper/views/my_copper_view.dart';


// Gold SIP (recurring savings)
import 'package:vika1/modules/gold_sip/bindings/gold_sip_binding.dart';
import 'package:vika1/modules/gold_sip/views/digi_gold_savings_view.dart';

// Gold Scheme (11+1 style plans)
import 'package:vika1/modules/gold_scheme/bindings/gold_scheme_binding.dart';
import 'package:vika1/modules/gold_scheme/views/gold_schemes_view.dart';

// Wallet
import '../modules/wallet/views/wallet_view.dart';
import '../modules/wallet/views/bank_accounts_view.dart';
import '../modules/wallet/views/add_bank_account_view.dart';
import '../modules/wallet/controllers/wallet_controller.dart';

import 'package:vika1/modules/profile/views/transactions_view.dart';
import 'package:vika1/modules/profile/views/rewards_view.dart';
import 'package:vika1/modules/profile/views/policy_view.dart';
import 'package:vika1/modules/orders/views/my_orders_view.dart';

abstract class AppRoutes {
  static const splash = '/splash';
  static const orders = '/orders';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const home = '/home';
  static const profile = '/profile';
  static const kyc = '/kyc';
  static const transactions = '/transactions';
  static const passcodeSetup = '/passcode-setup';
  static const lockScreen = '/lock';
  static const security = '/security';
  static const rewards = '/profile/rewards';
  static const policy = '/policy';

  static const digiGold = '/digi-gold';
  static const digiGoldSavings = '/digi-gold/savings';
  static const goldSchemes = '/digi-gold/schemes';
  static const sellGold = '/digi-gold/sell';
  static const buyGold = '/digi-gold/buy';
  static const myGold = '/digi-gold/my-gold';
  static const gift = '/digi-gold/gift';
  static const coinDetail = '/digi-gold/coin-detail';

  static const buySilver = '/silver/buy';
  static const sellSilver = '/silver/sell';
  static const mySilver = '/silver/my-silver';
  static const silverSip = '/silver/sip';

  static const buyCopper = '/copper/buy';
  static const sellCopper = '/copper/sell';
  static const myCopper = '/copper/my-copper';


  static const wallet = '/wallet';
  static const bankAccounts = '/wallet/banks';
  static const addBankAccount = '/wallet/banks/add';
  static const update = '/update';
  static const notifications = '/notifications';
}

final appPages = [
  GetPage(
    name: AppRoutes.orders,
    page: () => const MyOrdersView(),
  ),
  GetPage(
    name: AppRoutes.splash,
    page: () => const SplashView(),
  ),
  GetPage(
    name: AppRoutes.update,
    page: () => AppUpdateView(
      newVersion: Get.arguments?['newVersion'] ?? '1.0.0',
      changelog: List<String>.from(Get.arguments?['changelog'] ?? [
        'Premium Jewellery & Coins Catalog',
        'Direct Razorpay payments',
        'Calibrated Indian market rates',
        'Faster bottom navigation switching'
      ]),
      isForceUpdate: Get.arguments?['isForceUpdate'] ?? false,
      onUpdatePressed: Get.arguments?['onUpdatePressed'] ?? () {},
    ),
  ),
  GetPage(
    name: AppRoutes.login,
    page: () => const LoginView(),
    binding: AuthBinding(),
  ),
  GetPage(
    name: AppRoutes.forgotPassword,
    page: () => const ForgotPasswordView(),
    binding: AuthBinding(),
  ),
  GetPage(
    name: AppRoutes.register,
    page: () => const RegisterView(),
    binding: AuthBinding(),
  ),
  GetPage(
    name: AppRoutes.home,
    page: () => const MainShellView(),
    binding: HomeBinding(),
  ),
  GetPage(
    name: AppRoutes.kyc,
    page: () => const KycView(),
    binding: KycBinding(),
  ),
  GetPage(name: AppRoutes.passcodeSetup, page: () => const PasscodeSetupView()),
  GetPage(name: AppRoutes.lockScreen, page: () => const LockScreenView()),
  GetPage(name: AppRoutes.security, page: () => const SecuritySettingsView()),
  GetPage(name: AppRoutes.transactions, page: () => const TransactionsView()),
  GetPage(name: AppRoutes.rewards, page: () => const RewardsView()),
  GetPage(name: AppRoutes.policy, page: () => const PolicyView()),

  // ── Digi Gold (home tab + my gold) ──────────────────────────────────────
  GetPage(
    name: AppRoutes.digiGold,
    page: () => const DigiGoldView(),
    binding: DigiGoldBinding(),
  ),
  GetPage(
    name: AppRoutes.myGold,
    page: () => const MyGoldView(),
    binding: DigiGoldBinding(),
  ),
  GetPage(
    name: AppRoutes.gift,
    page: () => const GiftView(),
  ),
  GetPage(
    name: AppRoutes.coinDetail,
    page: () => const CoinDetailView(),
  ),

  // ── Buy Gold ─────────────────────────────────────────────────────────────
  GetPage(
    name: AppRoutes.buyGold,
    page: () => const BuyGoldView(),
    binding: BuyGoldBinding(),
  ),

  // ── Sell Gold ────────────────────────────────────────────────────────────
  GetPage(
    name: AppRoutes.sellGold,
    page: () => const SellGoldView(),
    binding: SellGoldBinding(),
  ),

  // ── Silver ───────────────────────────────────────────────────────────────
  GetPage(
    name: AppRoutes.buySilver,
    page: () => const BuySilverView(),
    binding: SilverBinding(),
  ),
  GetPage(
    name: AppRoutes.sellSilver,
    page: () => const SellSilverView(),
    binding: SilverBinding(),
  ),
  GetPage(
    name: AppRoutes.mySilver,
    page: () => const MySilverView(),
    binding: SilverBinding(),
  ),
  GetPage(
    name: AppRoutes.silverSip,
    page: () => const SilverSipView(),
    binding: SilverSipBinding(),
  ),

  // ── Copper ───────────────────────────────────────────────────────────────
  GetPage(
    name: AppRoutes.buyCopper,
    page: () => const BuyCopperView(),
    binding: CopperBinding(),
  ),
  GetPage(
    name: AppRoutes.sellCopper,
    page: () => const SellCopperView(),
    binding: CopperBinding(),
  ),
  GetPage(
    name: AppRoutes.myCopper,
    page: () => const MyCopperView(),
    binding: CopperBinding(),
  ),


  // ── Gold SIP ─────────────────────────────────────────────────────────────
  GetPage(
    name: AppRoutes.digiGoldSavings,
    page: () => const DigiGoldSavingsView(),
    binding: GoldSipBinding(),
  ),

  // ── Gold Scheme ──────────────────────────────────────────────────────────
  GetPage(
    name: AppRoutes.goldSchemes,
    page: () => const GoldSchemesView(),
    binding: GoldSchemeBinding(),
  ),

  // ── Wallet ───────────────────────────────────────────────────────────────
  GetPage(
    name: AppRoutes.wallet,
    page: () => const WalletView(),
    binding: BindingsBuilder(() {
      if (!Get.isRegistered<WalletController>()) Get.put(WalletController());
    }),
  ),
  GetPage(
    name: AppRoutes.bankAccounts,
    page: () => const BankAccountsView(),
    binding: BindingsBuilder(() {
      if (!Get.isRegistered<WalletController>()) Get.put(WalletController());
    }),
  ),
  GetPage(
    name: AppRoutes.addBankAccount,
    page: () => const AddBankAccountView(),
    binding: BindingsBuilder(() {
      if (!Get.isRegistered<WalletController>()) Get.put(WalletController());
    }),
  ),
  GetPage(
    name: AppRoutes.notifications,
    page: () => const NotificationHistoryView(),
    binding: NotificationBinding(),
  ),
];
