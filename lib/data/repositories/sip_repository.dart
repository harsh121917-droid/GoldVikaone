import 'package:vika1/core/network/api_client.dart';

class SipInstallmentModel {
  final int installmentNo;
  final double amount;
  final double ratePerGram;
  final double grams;
  final String paymentMethod;
  final String txnId;
  final DateTime paidAt;

  const SipInstallmentModel({
    required this.installmentNo,
    required this.amount,
    required this.ratePerGram,
    required this.grams,
    required this.paymentMethod,
    required this.txnId,
    required this.paidAt,
  });

  factory SipInstallmentModel.fromJson(Map<String, dynamic> j) =>
      SipInstallmentModel(
        installmentNo: (j['installmentNo'] ?? 0) as int,
        amount: (j['amount'] ?? 0) * 1.0,
        ratePerGram: (j['ratePerGram'] ?? 0) * 1.0,
        grams: (j['grams'] ?? 0) * 1.0,
        paymentMethod: j['paymentMethod'] ?? 'wallet',
        txnId: j['txnId'] ?? '',
        paidAt: DateTime.tryParse(j['paidAt'] ?? '') ?? DateTime.now(),
      );
}

class SipMilestoneModel {
  final int cycleNo;
  final String status; // 'completed', 'upcoming', 'future'
  final double amount;
  final double ratePerGram;
  final double grams;
  final DateTime? date;
  final DateTime? dueDate;
  final String label;
  final String paymentMethod;
  final String txnId;

  const SipMilestoneModel({
    required this.cycleNo,
    required this.status,
    required this.amount,
    required this.ratePerGram,
    required this.grams,
    this.date,
    this.dueDate,
    required this.label,
    this.paymentMethod = 'wallet',
    this.txnId = '',
  });

  bool get isCompleted => status == 'completed';
  bool get isUpcoming => status == 'upcoming';
  bool get isFuture => status == 'future';

  factory SipMilestoneModel.fromJson(Map<String, dynamic> j) =>
      SipMilestoneModel(
        cycleNo: (j['cycleNo'] ?? 0) as int,
        status: j['status'] ?? 'future',
        amount: (j['amount'] ?? 0) * 1.0,
        ratePerGram: (j['ratePerGram'] ?? 0) * 1.0,
        grams: (j['grams'] ?? 0) * 1.0,
        date: j['date'] != null ? DateTime.tryParse(j['date']) : null,
        dueDate: j['dueDate'] != null ? DateTime.tryParse(j['dueDate']) : null,
        label: j['label'] ?? '',
        paymentMethod: j['paymentMethod'] ?? 'wallet',
        txnId: j['txnId'] ?? '',
      );
}

class SipModel {
  final String id;
  final String metal;
  final String frequency;
  final double installmentAmount;
  final int durationMonths;
  final int totalCycles;
  final int cyclesCompleted;
  final double totalInvested;
  final double totalGrams;
  final String status;
  final DateTime startDate;
  final DateTime? nextDueDate;
  final DateTime? completedAt;
  final double currentLiveRate;
  final double currentValuation;
  final double returnsAmt;
  final double returnsPct;
  final double progressPct;
  final bool isDue;
  final List<SipInstallmentModel> installments;

  const SipModel({
    required this.id,
    required this.metal,
    required this.frequency,
    required this.installmentAmount,
    required this.durationMonths,
    required this.totalCycles,
    required this.cyclesCompleted,
    required this.totalInvested,
    required this.totalGrams,
    required this.status,
    required this.startDate,
    this.nextDueDate,
    this.completedAt,
    this.currentLiveRate = 0.0,
    this.currentValuation = 0.0,
    this.returnsAmt = 0.0,
    this.returnsPct = 0.0,
    this.progressPct = 0.0,
    this.isDue = false,
    this.installments = const [],
  });

  bool get isActive => status == 'active';
  bool get isPaused => status == 'paused';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
  bool get isGold => metal.toLowerCase() == 'gold';
  bool get isSilver => metal.toLowerCase() == 'silver';
  bool get isCopper => metal.toLowerCase() == 'copper';

  factory SipModel.fromJson(Map<String, dynamic> j) {
    final rawInst = j['installments'] as List? ?? [];
    return SipModel(
      id: j['_id']?.toString() ?? j['id']?.toString() ?? '',
      metal: (j['metal'] ?? 'gold').toString().toLowerCase(),
      frequency: (j['frequency'] ?? 'monthly').toString().toLowerCase(),
      installmentAmount: (j['installmentAmount'] ?? 0) * 1.0,
      durationMonths: (j['durationMonths'] ?? 12) as int,
      totalCycles: (j['totalCycles'] ?? 12) as int,
      cyclesCompleted: (j['cyclesCompleted'] ?? 0) as int,
      totalInvested: (j['totalInvested'] ?? 0) * 1.0,
      totalGrams: (j['totalGrams'] ?? 0) * 1.0,
      status: (j['status'] ?? 'active').toString().toLowerCase(),
      startDate: DateTime.tryParse(j['startDate'] ?? '') ?? DateTime.now(),
      nextDueDate: j['nextDueDate'] != null ? DateTime.tryParse(j['nextDueDate']) : null,
      completedAt: j['completedAt'] != null ? DateTime.tryParse(j['completedAt']) : null,
      currentLiveRate: (j['currentLiveRate'] ?? 0) * 1.0,
      currentValuation: (j['currentValuation'] ?? 0) * 1.0,
      returnsAmt: (j['returnsAmt'] ?? 0) * 1.0,
      returnsPct: (j['returnsPct'] ?? 0) * 1.0,
      progressPct: (j['progressPct'] ?? 0) * 1.0,
      isDue: j['isDue'] ?? false,
      installments: rawInst.map((i) => SipInstallmentModel.fromJson(i as Map<String, dynamic>)).toList(),
    );
  }
}

class SipPortfolioSummary {
  final int totalSipsCount;
  final int activeSipsCount;
  final double totalInvested;
  final double totalCurrentValue;
  final double overallReturnsAmt;
  final double overallReturnsPct;
  final double totalGramsGold;
  final double totalGramsSilver;
  final double totalGramsCopper;

  const SipPortfolioSummary({
    this.totalSipsCount = 0,
    this.activeSipsCount = 0,
    this.totalInvested = 0.0,
    this.totalCurrentValue = 0.0,
    this.overallReturnsAmt = 0.0,
    this.overallReturnsPct = 0.0,
    this.totalGramsGold = 0.0,
    this.totalGramsSilver = 0.0,
    this.totalGramsCopper = 0.0,
  });

  factory SipPortfolioSummary.fromJson(Map<String, dynamic> j) =>
      SipPortfolioSummary(
        totalSipsCount: (j['totalSipsCount'] ?? 0) as int,
        activeSipsCount: (j['activeSipsCount'] ?? 0) as int,
        totalInvested: (j['totalInvested'] ?? 0) * 1.0,
        totalCurrentValue: (j['totalCurrentValue'] ?? 0) * 1.0,
        overallReturnsAmt: (j['overallReturnsAmt'] ?? 0) * 1.0,
        overallReturnsPct: (j['overallReturnsPct'] ?? 0) * 1.0,
        totalGramsGold: (j['totalGramsGold'] ?? 0) * 1.0,
        totalGramsSilver: (j['totalGramsSilver'] ?? 0) * 1.0,
        totalGramsCopper: (j['totalGramsCopper'] ?? 0) * 1.0,
      );
}

class SipRepository {
  final _client = ApiClient.instance;

  Future<SipModel> createSip({
    required String metal,
    required String frequency,
    required double installmentAmount,
    required int durationMonths,
    String paymentMethod = 'wallet',
  }) async {
    final res = await _client.post('/sip/create', data: {
      'metal': metal.toLowerCase(),
      'frequency': frequency.toLowerCase(),
      'installmentAmount': installmentAmount,
      'durationMonths': durationMonths,
      'paymentMethod': paymentMethod,
    });
    if (res.data['success'] == true && res.data['data'] != null) {
      return SipModel.fromJson(res.data['data'] as Map<String, dynamic>);
    }
    throw Exception(res.data['message'] ?? 'Failed to start SIP');
  }

  Future<Map<String, dynamic>> getMySips() async {
    final res = await _client.get('/sip/my');
    if (res.data['success'] == true && res.data['data'] != null) {
      final d = res.data['data'] as Map<String, dynamic>;
      final summary = SipPortfolioSummary.fromJson((d['portfolio'] as Map<String, dynamic>?) ?? {});
      final sipsRaw = (d['sips'] as List?) ?? [];
      final sips = sipsRaw.map((s) => SipModel.fromJson(s as Map<String, dynamic>)).toList();
      return {'portfolio': summary, 'sips': sips};
    }
    return {'portfolio': const SipPortfolioSummary(), 'sips': <SipModel>[]};
  }

  Future<Map<String, dynamic>> getSipDetail(String id) async {
    final res = await _client.get('/sip/$id');
    if (res.data['success'] == true && res.data['data'] != null) {
      final d = res.data['data'] as Map<String, dynamic>;
      final sip = SipModel.fromJson((d['sip'] as Map<String, dynamic>?) ?? {});
      final journeyRaw = (d['journey'] as List?) ?? [];
      final journey = journeyRaw.map((j) => SipMilestoneModel.fromJson(j as Map<String, dynamic>)).toList();
      return {'sip': sip, 'journey': journey};
    }
    throw Exception(res.data['message'] ?? 'Failed to fetch SIP details');
  }

  Future<SipModel> payInstallment(String id) async {
    final res = await _client.post('/sip/$id/pay', data: {});
    if (res.data['success'] == true && res.data['data'] != null) {
      return SipModel.fromJson(res.data['data'] as Map<String, dynamic>);
    }
    throw Exception(res.data['message'] ?? 'Failed to pay installment');
  }

  Future<SipModel> toggleSipStatus(String id) async {
    final res = await _client.post('/sip/$id/toggle-status', data: {});
    if (res.data['success'] == true && res.data['data'] != null) {
      return SipModel.fromJson(res.data['data'] as Map<String, dynamic>);
    }
    throw Exception(res.data['message'] ?? 'Failed to update SIP status');
  }

  Future<SipModel> cancelSip(String id) async {
    final res = await _client.post('/sip/$id/cancel', data: {});
    if (res.data['success'] == true && res.data['data'] != null) {
      return SipModel.fromJson(res.data['data'] as Map<String, dynamic>);
    }
    throw Exception(res.data['message'] ?? 'Failed to cancel SIP');
  }
}
