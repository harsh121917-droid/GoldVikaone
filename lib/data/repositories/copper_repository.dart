import 'package:dio/dio.dart';
import 'package:vika1/core/network/api_client.dart';

// ─── Models ───────────────────────────────────────────────────────────────────
class CopperRateModel {
  final double buyRate, sellRate, change24h, changePct;
  final String purity;
  final double gstPct;
  final DateTime updatedAt;
  final String source;
  bool get isStale => source != 'gold-api.com';

  const CopperRateModel({
    required this.buyRate,
    required this.sellRate,
    required this.change24h,
    required this.changePct,
    required this.purity,
    required this.gstPct,
    required this.updatedAt,
    this.source = 'gold-api.com',
  });

  factory CopperRateModel.fromJson(Map<String, dynamic> j) => CopperRateModel(
    buyRate: (j['buyRate'] ?? 1.36) * 1.0,
    sellRate: (j['sellRate'] ?? 1.35) * 1.0,
    change24h: (j['change24h'] ?? 0) * 1.0,
    changePct: (j['changePct'] ?? 0) * 1.0,
    purity: j['purity'] ?? '999',
    gstPct: (j['gstPct'] ?? 3.0) * 1.0,
    updatedAt: DateTime.tryParse(j['updatedAt'] ?? '') ?? DateTime.now(),
    source: j['source'] ?? 'gold-api.com',
  );

  String get formattedBuyRate => '₹${buyRate.toStringAsFixed(2)}/g';
  String get formattedSellRate => '₹${sellRate.toStringAsFixed(2)}/g';
  String get formattedChange =>
      '${changePct >= 0 ? '+' : ''}${changePct.toStringAsFixed(2)}%';
  bool get isPositive => changePct >= 0;
}

class CopperBalanceModel {
  final double totalGrams, availableGrams, lockedGrams;
  final double investedAmt, currentValue, gainLoss, gainLossPct;
  final double avgBuyRate, currentBuyRate, currentSellRate;

  const CopperBalanceModel({
    required this.totalGrams,
    required this.availableGrams,
    required this.lockedGrams,
    required this.investedAmt,
    required this.currentValue,
    required this.gainLoss,
    required this.gainLossPct,
    required this.avgBuyRate,
    required this.currentBuyRate,
    required this.currentSellRate,
  });

  factory CopperBalanceModel.fromJson(Map<String, dynamic> j) =>
      CopperBalanceModel(
        totalGrams: (j['totalGrams'] ?? 0) * 1.0,
        availableGrams: (j['availableGrams'] ?? 0) * 1.0,
        lockedGrams: (j['lockedGrams'] ?? 0) * 1.0,
        investedAmt: (j['investedAmt'] ?? 0) * 1.0,
        currentValue: (j['currentValue'] ?? 0) * 1.0,
        gainLoss: (j['gainLoss'] ?? 0) * 1.0,
        gainLossPct: (j['gainLossPct'] ?? 0) * 1.0,
        avgBuyRate: (j['avgBuyRate'] ?? 0) * 1.0,
        currentBuyRate: (j['currentBuyRate'] ?? 0) * 1.0,
        currentSellRate: (j['currentSellRate'] ?? 0) * 1.0,
      );

  String fmt(double n) {
    if (n >= 10000000) return '₹${(n / 10000000).toStringAsFixed(2)}Cr';
    if (n >= 100000) return '₹${(n / 100000).toStringAsFixed(1)}L';
    return '₹${n.toStringAsFixed(2)}';
  }

  String get formattedValue => fmt(currentValue);
  String get formattedInvested => fmt(investedAmt);
  String get formattedGain => '${gainLoss >= 0 ? '+' : ''}${fmt(gainLoss)}';
  String get formattedGainPct =>
      '${gainLossPct >= 0 ? '+' : ''}${gainLossPct.toStringAsFixed(2)}%';
  String get formattedGrams => '${totalGrams.toStringAsFixed(4)}g';
  bool get isProfit => gainLoss >= 0;
}

class CopperTxnModel {
  final String id, type, status;
  final String? invoiceNo;
  final double grams, ratePerGram, copperValue, gstAmt, totalAmt;
  final String? note;
  final DateTime createdAt;

  const CopperTxnModel({
    required this.id,
    required this.type,
    required this.status,
    required this.grams,
    required this.ratePerGram,
    required this.copperValue,
    required this.gstAmt,
    required this.totalAmt,
    required this.createdAt,
    this.invoiceNo,
    this.note,
  });

  String get displayInvoiceNo =>
      invoiceNo ??
      'TX-${id.length >= 8 ? id.substring(id.length - 8).toUpperCase() : id.toUpperCase()}';

  factory CopperTxnModel.fromJson(Map<String, dynamic> j) => CopperTxnModel(
    id: j['id']?.toString() ?? '',
    invoiceNo: j['invoiceNo'] as String?,
    type: j['type'] ?? 'buy',
    status: j['status'] ?? 'pending',
    grams: (j['grams'] ?? 0) * 1.0,
    ratePerGram: (j['ratePerGram'] ?? 0) * 1.0,
    copperValue: (j['copperValue'] ?? 0) * 1.0,
    gstAmt: (j['gstAmt'] ?? 0) * 1.0,
    totalAmt: (j['totalAmt'] ?? 0) * 1.0,
    note: j['note'],
    createdAt: DateTime.tryParse(j['createdAt'] ?? '') ?? DateTime.now(),
  );

  bool get isSuccess => status == 'success';
  bool get isBuy => type == 'buy';
  String get typeLabel => isBuy ? 'Copper Purchased' : 'Copper Sold';
}

// ─── Repository ───────────────────────────────────────────────────────────────
class CopperRepository {
  final _dio = ApiClient.instance;
  static const _rateBase = '/gold';
  static const _base = '/copper';

  // 1. Rate
  Future<CopperRateModel> getRate() async {
    final res = await _dio.get('$_rateBase/rate');
    final data = res.data['data'] as Map<String, dynamic>;
    final copper = (data['copper'] ?? {}) as Map<String, dynamic>;
    return CopperRateModel.fromJson({
      ...copper,
      'updatedAt': data['updatedAt'],
      'source': data['source'],
    });
  }

  Future<List<Map<String, dynamic>>> getPriceHistory(String symbol, String period) async {
    final res = await _dio.get('$_rateBase/history', queryParameters: {
      'symbol': symbol,
      'period': period,
    });
    return List<Map<String, dynamic>>.from(res.data['data']);
  }

  // 2. Balance
  Future<CopperBalanceModel> getBalance() async {
    final res = await _dio.get('$_base/balance');
    return CopperBalanceModel.fromJson(res.data['data']);
  }

  // 3. Transactions
  Future<List<CopperTxnModel>> getTransactions({
    int page = 1,
    String? type,
  }) async {
    final res = await _dio.get(
      '$_base/transactions',
      queryParameters: {'page': page, if (type != null) 'type': type},
    );
    return (res.data['data'] as List)
        .map((e) => CopperTxnModel.fromJson(e))
        .toList();
  }

  Future<CopperTxnModel> getTransactionDetail(String id) async {
    final res = await _dio.get('$_base/transactions/$id');
    return CopperTxnModel.fromJson(res.data['data']);
  }

  Future<List<int>> getTransactionInvoice(String txnId, {bool isSample = false}) async {
    final res = await _dio.get<List<int>>(
      '$_base/transactions/$txnId/invoice',
      queryParameters: isSample ? {'sample': 'true'} : null,
      options: Options(responseType: ResponseType.bytes),
    );
    return res.data!;
  }
}
