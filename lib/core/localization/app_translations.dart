import 'package:get/get.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': enUS,
        'mr_IN': mrIN,
      };

  static const Map<String, String> enUS = {
    // ── App Shell & Drawer ───────────────────────────────────────────────────
    'app_name': 'Vikaone',
    'app_tagline': 'Digital Gold & Silver',
    'nav_home': 'Home',
    'nav_schemes': 'Schemes',
    'nav_jewellery': 'Jewellery',
    'nav_rewards': 'Rewards',
    'nav_profile': 'Profile',
    'nav_mutual_funds': 'Mutual Funds',
    'live_badge': 'LIVE',
    'change_language': 'Language / भाषा',

    // ── Greetings & Top Bar ──────────────────────────────────────────────────
    'greeting_morning': 'Good Morning',
    'greeting_afternoon': 'Good Afternoon',
    'greeting_evening': 'Good Evening',
    'welcome_back': 'Welcome Back',

    // ── Hero Cards & Balances ────────────────────────────────────────────────
    'gold_balance': 'GOLD BALANCE',
    'silver_balance': 'SILVER BALANCE',
    'copper_balance': 'COPPER BALANCE',
    'current_value': 'Current Value',
    'details': 'Details',
    'buy_gold': 'Buy Gold',
    'sell_gold': 'Sell Gold',
    'buy_silver': 'Buy Silver',
    'sell_silver': 'Sell Silver',
    'buy_copper': 'Buy Copper',
    'sell_copper': 'Sell Copper',
    'view_chart': 'View Chart',

    // ── Quick Actions ────────────────────────────────────────────────────────
    'transactions': 'Transactions',
    'sip_plan': 'SIP Plan',
    'mutual_funds': 'Mutual Funds',
    'add_money': 'Add Money',
    'sell': 'Sell',
    'price_chart': 'Price Chart',
    'gift': 'Gift',
    'refer_earn': 'Refer & Earn',
    'show_more': 'Show More',
    'show_less': 'Show Less',
    'start_savings_plan_sip': 'Start Savings Plan (SIP)',
    'gold_sip': 'Gold SIP',
    'silver_sip': 'Silver SIP',
    'sell_assets': 'Sell Assets',

    // ── Live Market Rates ────────────────────────────────────────────────────
    'live_market_rates': 'Live Market Rates',
    'tap_to_refresh': 'Tap to refresh',
    'updated': 'Updated',
    'gold_24k': 'Gold (24K)',
    'silver_999': 'Silver (999)',
    'platinum_950': 'Platinum (950)',
    'copper': 'Copper',
    'per_gram': '/g',

    // ── Promo Banner ─────────────────────────────────────────────────────────
    'coming_soon_badge': '🚀 COMING SOON',
    'promo_title': 'More ways to grow your wealth!',
    'promo_subtitle': 'Mutual Funds, Fixed Deposits, SIP & more powerful investment options coming soon.',
    'explore_whats_coming': "Explore What's Coming",

    // ── Home Coupons & Offers ────────────────────────────────────────────────
    'exclusive_offers_coupons': 'Exclusive Offers & Coupons',
    'view_all': 'View All',
    'free_gold': 'FREE GOLD',
    'most_popular': 'MOST POPULAR',

    // ── Recommended Goals ────────────────────────────────────────────────────
    'your_goals': 'Your Goals',
    'tap_goal_invest': 'Tap any goal to start investing ✨',
    'goal_soldier': 'Veer Jawan',
    'goal_education': 'Education',
    'goal_home': 'Dream Home',
    'goal_wealth': 'Retirement',
    'goal_wedding': 'Wedding Gold',
    'start_saving': 'Start Saving',

    // ── SIP Promo Card ───────────────────────────────────────────────────────
    'setup_sip_in': 'Set up SIP in ',
    'gold': 'Gold',
    'or': ' or ',
    'silver': 'Silver',
    'sip_tagline': 'Build wealth regularly with small investments.',
    'flexible_amount': 'Flexible Amount',
    'secure_investment': 'Secure Investment',
    'wealth_growth': 'Wealth Growth',
    'start_sip': 'Start SIP',
    'choose_sip_asset': 'Choose SIP Asset',

    // ── Physical Delivery Banner ─────────────────────────────────────────────
    'physical_delivery': 'PHYSICAL DELIVERY',
    'doorstep_gold_delivery': 'Doorstep Gold Delivery',
    'doorstep_delivery_desc': 'Convert your digital savings into 999.9 pure certified physical coins safely delivered to your home.',
    'order_gold_coins': 'Order Gold Coins',
    'get_delivery': 'Get Delivery',

    // ── Trust & Security ─────────────────────────────────────────────────────
    'trust_security_cert': 'Trust & Security Certifications',
    'bis_hallmarked': 'BIS Hallmarked',
    'bis_badge': '24K 99.9% PURE',
    'bis_desc': 'Government-approved hallmark purity guarantee for 99.9% 24K Gold & Silver.',
    'pure_24k': '🥇 24K Pure',
    'govt_approved': '🏛️ Govt. Approved',
    'backed_100': '🔒 100% Backed',
    'iso_certified': 'ISO 27001:2022 Certified',
    'bank_grade': '🛡️ Bank-Grade',
    'ssl_256': '🔐 256-Bit SSL',
    'privacy_first': '👁️ Privacy First',

    // ── Strategic Alliances / Partnerships ───────────────────────────────────
    'strategic_alliances': 'STRATEGIC ALLIANCES',
    'active_network': 'Active Network',
    'in_partnership_with': 'In Partnership With',
    'alliances_desc': "Integrated with India's premier banking, AMC & exchange institutions",

    // ── Profile Screen ───────────────────────────────────────────────────────
    'my_profile': 'My Profile',
    'personal_info': 'Personal Information',
    'kyc_verification': 'KYC Verification',
    'bank_payment_details': 'Bank & Payment Details',
    'orders_tracking': 'My Orders & Tracking',
    'security_settings': 'Security Settings',
    'app_language': 'App Language',
    'terms_conditions': 'Terms & Conditions',
    'privacy_policy': 'Privacy Policy',

    // ── Language Selector ────────────────────────────────────────────────────
    'select_language': 'Select Language',
    'language_settings': 'Language Settings',
    'choose_preferred_language': 'Choose your preferred language',
    'choose_app_language': 'Choose App Language',
    'language_subtitle': 'Select the language you are most comfortable with. All key terms and menus will update instantly.',
    'preview_label': 'Live Preview',
    'preview_gold_balance': 'Gold Balance',
    'preview_live_rate': 'Live Market Rate',
    'apply_language': 'Apply & Continue',
    'popular_badge': 'POPULAR',
    'active_badge': 'ACTIVE',
    'lang_english': 'English',
    'lang_marathi': 'मराठी (Marathi)',
    'lang_switched_toast': 'Language changed to English',
  };

  static const Map<String, String> mrIN = {
    // ── App Shell & Drawer ───────────────────────────────────────────────────
    'app_name': 'विकासवन',
    'app_tagline': 'डिजिटल सोने आणि चांदी',
    'nav_home': 'होम',
    'nav_schemes': 'योजना',
    'nav_jewellery': 'दागिने',
    'nav_rewards': 'रिवॉर्ड्स',
    'nav_profile': 'प्रोफाइल',
    'nav_mutual_funds': 'म्युच्युअल फंड',
    'live_badge': 'लाइव्ह',
    'change_language': 'भाषा बदला (Language)',

    // ── Greetings & Top Bar ──────────────────────────────────────────────────
    'greeting_morning': 'शुभ सकाळ',
    'greeting_afternoon': 'शुभ दुपार',
    'greeting_evening': 'शुभ संध्याकाळ',
    'welcome_back': 'स्वागत आहे',

    // ── Hero Cards & Balances ────────────────────────────────────────────────
    'gold_balance': 'सोन्याची शिल्लक',
    'silver_balance': 'चांदीची शिल्लक',
    'copper_balance': 'तांब्याची शिल्लक',
    'current_value': 'चालू मूल्य',
    'details': 'तपशील',
    'buy_gold': 'सोने खरेदी',
    'sell_gold': 'सोने विक्री',
    'buy_silver': 'चांदी खरेदी',
    'sell_silver': 'चांदी विक्री',
    'buy_copper': 'तांबे खरेदी',
    'sell_copper': 'तांबे विक्री',
    'view_chart': 'चार्ट पहा',

    // ── Quick Actions ────────────────────────────────────────────────────────
    'transactions': 'व्यवहार',
    'sip_plan': 'SIP योजना',
    'mutual_funds': 'म्युच्युअल फंड',
    'add_money': 'पैसे जोडा',
    'sell': 'विक्री',
    'price_chart': 'दर चार्ट',
    'gift': 'गिफ्ट',
    'refer_earn': 'रेफर करा',
    'show_more': 'अधिक पहा',
    'show_less': 'कमी पहा',
    'start_savings_plan_sip': 'बचत योजना सुरू करा (SIP)',
    'gold_sip': 'गोल्ड SIP',
    'silver_sip': 'सिल्व्हर SIP',
    'sell_assets': 'विक्री करा',

    // ── Live Market Rates ────────────────────────────────────────────────────
    'live_market_rates': 'लाइव्ह बाजार दर',
    'tap_to_refresh': 'रिफ्रेश करण्यासाठी टॅप करा',
    'updated': 'अपडेट केले',
    'gold_24k': 'सोने (24K)',
    'silver_999': 'चांदी (999)',
    'platinum_950': 'प्लॅटिनम (950)',
    'copper': 'तांबे',
    'per_gram': '/ग्रॅम',

    // ── Promo Banner ─────────────────────────────────────────────────────────
    'coming_soon_badge': '🚀 लवकरच येत आहे',
    'promo_title': 'संपत्ती वाढवण्याचे नवे पर्याय!',
    'promo_subtitle': 'म्युच्युअल फंड, फिक्स डिपॉझिट, SIP आणि इतर गुंतवणुकीचे पर्याय लवकरच.',
    'explore_whats_coming': 'अधिक जाणून घ्या',

    // ── Home Coupons & Offers ────────────────────────────────────────────────
    'exclusive_offers_coupons': 'खास ऑफर्स आणि कूपन्स',
    'view_all': 'सर्व पहा',
    'free_gold': 'मोफत सोने',
    'most_popular': 'सर्वात लोकप्रिय',

    // ── Recommended Goals ────────────────────────────────────────────────────
    'your_goals': 'तुमची उद्दिष्टे',
    'tap_goal_invest': 'गुंतवणूक करण्यासाठी उद्दिष्ट निवडा ✨',
    'goal_soldier': 'वीर जवान',
    'goal_education': 'शिक्षण',
    'goal_home': 'स्वप्नातील घर',
    'goal_wealth': 'निवृत्ती',
    'goal_wedding': 'लग्नाचे सोने',
    'start_saving': 'बचत सुरू करा',

    // ── SIP Promo Card ───────────────────────────────────────────────────────
    'setup_sip_in': 'मध्ये SIP सुरू करा: ',
    'gold': 'सोने',
    'or': ' किंवा ',
    'silver': 'चांदी',
    'sip_tagline': 'लहान गुंतवणुकीतून नियमित मोठी संपत्ती निर्माण करा.',
    'flexible_amount': 'लवचिक रक्कम',
    'secure_investment': 'सुरक्षित गुंतवणूक',
    'wealth_growth': 'संपत्ती वाढ',
    'start_sip': 'SIP सुरू करा',
    'choose_sip_asset': 'SIP चा प्रकार निवडा',

    // ── Physical Delivery Banner ─────────────────────────────────────────────
    'physical_delivery': 'घरी डिलिव्हरी',
    'doorstep_gold_delivery': 'घरोघरी सोने डिलिव्हरी',
    'doorstep_delivery_desc': 'तुमचे डिजिटल सोने 999.9 शुद्ध प्रमाणित नाण्यांमध्ये रूपांतरित करून सुरक्षितपणे घरी मिळवा.',
    'order_gold_coins': 'सोन्याची नाणी मागवा',
    'get_delivery': 'घरी मिळवा',

    // ── Trust & Security ─────────────────────────────────────────────────────
    'trust_security_cert': 'विश्वास आणि सुरक्षा प्रमाणपत्रे',
    'bis_hallmarked': 'BIS हॉलमार्क प्रमाणित',
    'bis_badge': '24K 99.9% शुद्ध',
    'bis_desc': '९९.९% २४ कॅरेट सोने व चांदीसाठी सरकारमान्य हॉलमार्क शुद्धतेची हमी.',
    'pure_24k': '🥇 २४K शुद्ध',
    'govt_approved': '🏛️ शासनमान्य',
    'backed_100': '🔒 १००% सुरक्षित',
    'iso_certified': 'ISO 27001 प्रमाणित',
    'bank_grade': '🛡️ बँक दर्जाची सुरक्षा',
    'ssl_256': '🔐 २५६-बिट SSL',
    'privacy_first': '👁️ पूर्ण गोपनीयता',

    // ── Strategic Alliances / Partnerships ───────────────────────────────────
    'strategic_alliances': 'अधिकृत भागीदारी',
    'active_network': 'सक्रिय नेटवर्क',
    'in_partnership_with': 'यांच्यासोबत भागीदारी',
    'alliances_desc': 'भारतातील अग्रगण्य बँका आणि वित्तीय संस्थांशी थेट जोडलेले',

    // ── Profile Screen ───────────────────────────────────────────────────────
    'my_profile': 'माझी प्रोफाइल',
    'personal_info': 'वैयक्तिक माहिती',
    'kyc_verification': 'KYC पडताळणी',
    'bank_payment_details': 'बँक आणि पेमेंट तपशील',
    'orders_tracking': 'माझे ऑर्डर्स आणि ट्रॅकिंग',
    'security_settings': 'सुरक्षा सेटिंग्ज',
    'app_language': 'अ‍ॅपची भाषा',
    'terms_conditions': 'नियम आणि अटी',
    'privacy_policy': 'गोपनीयता धोरण',

    // ── Language Selector ────────────────────────────────────────────────────
    'select_language': 'भाषा निवडा',
    'language_settings': 'भाषा सेटिंग्ज',
    'choose_preferred_language': 'तुमची पसंतीची भाषा निवडा',
    'choose_app_language': 'अ‍ॅपची भाषा निवडा',
    'language_subtitle': 'तुमच्या सोयीची भाषा निवडा. सर्व मुख्य शब्द आणि मेनू त्वरित बदलतील.',
    'preview_label': 'थेट पूर्वावलोकन',
    'preview_gold_balance': 'सोन्याची शिल्लक',
    'preview_live_rate': 'लाइव्ह बाजार दर',
    'apply_language': 'लागू करा आणि पुढे जा',
    'popular_badge': 'लोकप्रिय',
    'active_badge': 'सक्रिय',
    'lang_english': 'English',
    'lang_marathi': 'मराठी (Marathi)',
    'lang_switched_toast': 'भाषा मराठीमध्ये बदलली',
  };
}
