import 'package:flutter/material.dart';

class CouponTicketCard extends StatelessWidget {
  final Map<String, dynamic> coupon;
  final bool isSelected;
  final bool isApplied;
  final VoidCallback? onApply;
  final VoidCallback? onRemove;
  final VoidCallback? onTap;
  final VoidCallback? onViewDetails;
  final String? customButtonText;
  final EdgeInsetsGeometry? margin;

  const CouponTicketCard({
    Key? key,
    required this.coupon,
    this.isSelected = false,
    this.isApplied = false,
    this.onApply,
    this.onRemove,
    this.onTap,
    this.onViewDetails,
    this.customButtonText,
    this.margin,
  }) : super(key: key);

  void _showDetailsSheet(BuildContext context) {
    if (onViewDetails != null) {
      onViewDetails!();
      return;
    }

    final code = coupon['code'] as String? ?? 'OFFER';
    final title = coupon['title'] as String? ?? 'Coupon Offer';
    final desc = coupon['description'] as String? ?? '';
    final minAmt = (coupon['minPurchaseAmount'] as num? ?? 100).toDouble();
    final val = (coupon['value'] as num? ?? 15).toDouble();
    final expiry = coupon['expiry'] as String? ?? '31 Aug 2026';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final dark = Theme.of(ctx).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: dark ? const Color(0xFF132319) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7E6),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFD4A017)),
                    ),
                    child: Text(
                      code,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFB87E14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: dark ? Colors.white : const Color(0xFF1E2D24),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                desc,
                style: TextStyle(
                  fontSize: 13,
                  color: dark ? Colors.white70 : Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Divider(color: Colors.grey.withOpacity(0.2)),
              const SizedBox(height: 8),
              _detailRow(Icons.check_circle_outline, 'Minimum purchase: ₹${minAmt.toInt()}'),
              const SizedBox(height: 6),
              _detailRow(Icons.card_giftcard, 'Reward: Free Gold up to ₹${val.toInt()}'),
              const SizedBox(height: 6),
              _detailRow(Icons.person_outline, 'Usage: Once per user'),
              const SizedBox(height: 6),
              _detailRow(Icons.calendar_today_outlined, 'Expiry: $expiry'),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFFB87E14)),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final textInk = dark ? const Color(0xFFEDF3EF) : const Color(0xFF1E2D24);
    final goldCol = const Color(0xFFD4A017);
    final goldGrad = const LinearGradient(
      colors: [Color(0xFFE5A93C), Color(0xFFB87E14)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final title = coupon['title'] as String? ?? 'Add Gold Offer';
    final desc = coupon['description'] as String? ?? 'Get Free Gold';
    final expiry = coupon['expiry'] as String? ?? 'Valid till 31 May 2026';
    final tag = coupon['tag'] as String? ?? 'Applicable on once per user';
    final badge = coupon['badge'] as String? ?? 'MOST POPULAR';
    final stubLabel = coupon['stubLabel'] as String? ?? 'FREE GOLD';
    final saveText = coupon['saveText'] as String? ?? 'Up to ₹15';

    String buttonLabel = customButtonText ?? (isApplied ? 'Applied ✓' : (isSelected ? 'Selected' : 'Apply Coupon'));

    const double stubWidth = 114.0;
    final borderColor = (isSelected || isApplied) ? const Color(0xFFB87E14) : const Color(0xFFE8DBB8);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: margin ?? const EdgeInsets.only(bottom: 16),
        child: CustomPaint(
          foregroundPainter: TicketVoucherBorderPainter(
            color: borderColor,
            stubWidth: stubWidth,
            strokeWidth: (isSelected || isApplied) ? 1.8 : 1.0,
          ),
          child: ClipPath(
            clipper: TicketVoucherClipper(stubWidth: stubWidth),
            child: Container(
              decoration: BoxDecoration(
                color: dark ? const Color(0xFF132319) : const Color(0xFFFFFDF5),
              ),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Left Ticket Stub ──────────────────────────────────────────
                    Container(
                      width: stubWidth,
                      padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
                      decoration: BoxDecoration(
                        color: dark ? const Color(0xFF192C20) : const Color(0xFFFFF7E6),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Top Flame Badge
                          if (badge.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFB87E14), Color(0xFF8A5408)],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.local_fire_department_rounded,
                                      size: 10, color: Colors.white),
                                  const SizedBox(width: 2),
                                  Text(
                                    badge,
                                    style: const TextStyle(
                                      fontSize: 7.5,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            const SizedBox(height: 14),

                          // 3D Gold Bars Stack Graphic
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Column(
                              children: [
                                // Top Ingot
                                Container(
                                  width: 36,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFFFFEA9F), Color(0xFFD49E24)],
                                    ),
                                    borderRadius: BorderRadius.circular(3),
                                    border: Border.all(color: const Color(0xFFB87E14), width: 0.8),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                // Bottom Twin Ingots
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 25,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [Color(0xFFFFEA9F), Color(0xFFD49E24)],
                                        ),
                                        borderRadius: BorderRadius.circular(3),
                                        border: Border.all(color: const Color(0xFFB87E14), width: 0.8),
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    Container(
                                      width: 25,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [Color(0xFFFFEA9F), Color(0xFFD49E24)],
                                        ),
                                        borderRadius: BorderRadius.circular(3),
                                        border: Border.all(color: const Color(0xFFB87E14), width: 0.8),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Bottom Stub Label
                          Column(
                            children: [
                              Text(
                                stubLabel,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w900,
                                  color: dark ? const Color(0xFFFFD700) : const Color(0xFF3D2E14),
                                  letterSpacing: 0.4,
                                ),
                              ),
                              const SizedBox(height: 1),
                              Text(
                                saveText,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  color: dark ? Colors.white70 : const Color(0xFF6E5628),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Vertical Dashed Divider Line (from top notch to bottom notch)
                    CustomPaint(
                      size: const Size(1, double.infinity),
                      painter: _DashedLinePainter(
                        color: dark ? Colors.white24 : const Color(0xFFD4A017),
                        topOffset: 10.0,
                        bottomOffset: 10.0,
                      ),
                    ),

                    // ── Right Main Details Section ───────────────────────────────
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 10, 14, 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Header Row: Title & Info Icon
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    title,
                                    style: TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w900,
                                      color: textInk,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => _showDetailsSheet(context),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 4),
                                    child: Icon(Icons.info_outline_rounded,
                                        size: 18, color: dark ? Colors.white54 : const Color(0xFFB87E14)),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 2),

                            // Subtitle
                            Text(
                              desc,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: textInk.withOpacity(0.7),
                              ),
                            ),

                            const SizedBox(height: 4),

                            // Validity Row
                            Row(
                              children: [
                                const Icon(Icons.calendar_month_outlined,
                                    size: 12, color: Color(0xFF8A6A32)),
                                const SizedBox(width: 4),
                                Text(
                                  expiry,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF8A6A32),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 4),

                            // Once Per User Tag
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: dark ? Colors.white10 : const Color(0xFFFFFDF5),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFFF7EED9)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.person_outline_rounded,
                                      size: 11, color: Color(0xFF8A6A32)),
                                  const SizedBox(width: 4),
                                  Text(
                                    tag,
                                    style: const TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF8A6A32),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 8),

                            // Bottom Actions: View Details & Apply
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () => _showDetailsSheet(context),
                                  child: Row(
                                    children: const [
                                      Text(
                                        'View Details',
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF9C6B14),
                                        ),
                                      ),
                                      SizedBox(width: 2),
                                      Icon(Icons.keyboard_arrow_down_rounded,
                                          size: 13, color: Color(0xFF9C6B14)),
                                    ],
                                  ),
                                ),

                                // Apply Button
                                GestureDetector(
                                  onTap: () {
                                    if (isApplied && onRemove != null) {
                                      onRemove!();
                                    } else if (onApply != null) {
                                      onApply!();
                                    } else if (onTap != null) {
                                      onTap!();
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 7),
                                    decoration: BoxDecoration(
                                      gradient: isApplied
                                          ? const LinearGradient(
                                              colors: [Color(0xFF27AE60), Color(0xFF2ECC71)],
                                            )
                                          : goldGrad,
                                      borderRadius: BorderRadius.circular(9),
                                      boxShadow: [
                                        BoxShadow(
                                          color: (isApplied ? const Color(0xFF2ECC71) : goldCol).withOpacity(0.3),
                                          blurRadius: 5,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      buttonLabel,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Precise ticket voucher clipper with:
/// - Left & Right edge semicircular cutouts (notches)
/// - Top & Bottom divider semicircular cutouts (notches)
/// - 4 Rounded corners
class TicketVoucherClipper extends CustomClipper<Path> {
  final double stubWidth;
  final double cornerRadius;
  final double edgeNotchRadius;
  final double dividerNotchRadius;

  TicketVoucherClipper({
    required this.stubWidth,
    this.cornerRadius = 16.0,
    this.edgeNotchRadius = 9.0,
    this.dividerNotchRadius = 8.0,
  });

  @override
  Path getClip(Size size) {
    return _createTicketPath(
      size: size,
      stubWidth: stubWidth,
      cornerRadius: cornerRadius,
      edgeNotchRadius: edgeNotchRadius,
      dividerNotchRadius: dividerNotchRadius,
    );
  }

  @override
  bool shouldReclip(covariant TicketVoucherClipper oldClipper) =>
      oldClipper.stubWidth != stubWidth;
}

class TicketVoucherBorderPainter extends CustomPainter {
  final Color color;
  final double stubWidth;
  final double strokeWidth;
  final double cornerRadius;
  final double edgeNotchRadius;
  final double dividerNotchRadius;

  TicketVoucherBorderPainter({
    required this.color,
    required this.stubWidth,
    this.strokeWidth = 1.0,
    this.cornerRadius = 16.0,
    this.edgeNotchRadius = 9.0,
    this.dividerNotchRadius = 8.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = _createTicketPath(
      size: size,
      stubWidth: stubWidth,
      cornerRadius: cornerRadius,
      edgeNotchRadius: edgeNotchRadius,
      dividerNotchRadius: dividerNotchRadius,
    );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..isAntiAlias = true;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant TicketVoucherBorderPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.stubWidth != stubWidth ||
      oldDelegate.strokeWidth != strokeWidth;
}

Path _createTicketPath({
  required Size size,
  required double stubWidth,
  required double cornerRadius,
  required double edgeNotchRadius,
  required double dividerNotchRadius,
}) {
  final path = Path();
  final w = size.width;
  final h = size.height;

  // Start top-left after corner
  path.moveTo(cornerRadius, 0);

  // Top edge to top divider notch
  path.lineTo(stubWidth - dividerNotchRadius, 0);
  path.arcToPoint(
    Offset(stubWidth + dividerNotchRadius, 0),
    radius: Radius.circular(dividerNotchRadius),
    clockwise: false,
  );

  // Top edge to top-right corner
  path.lineTo(w - cornerRadius, 0);
  path.arcToPoint(
    Offset(w, cornerRadius),
    radius: Radius.circular(cornerRadius),
    clockwise: true,
  );

  // Right edge to middle notch
  path.lineTo(w, h / 2 - edgeNotchRadius);
  path.arcToPoint(
    Offset(w, h / 2 + edgeNotchRadius),
    radius: Radius.circular(edgeNotchRadius),
    clockwise: false,
  );

  // Right edge to bottom-right corner
  path.lineTo(w, h - cornerRadius);
  path.arcToPoint(
    Offset(w - cornerRadius, h),
    radius: Radius.circular(cornerRadius),
    clockwise: true,
  );

  // Bottom edge to bottom divider notch
  path.lineTo(stubWidth + dividerNotchRadius, h);
  path.arcToPoint(
    Offset(stubWidth - dividerNotchRadius, h),
    radius: Radius.circular(dividerNotchRadius),
    clockwise: false,
  );

  // Bottom edge to bottom-left corner
  path.lineTo(cornerRadius, h);
  path.arcToPoint(
    Offset(0, h - cornerRadius),
    radius: Radius.circular(cornerRadius),
    clockwise: true,
  );

  // Left edge to middle notch
  path.lineTo(0, h / 2 + edgeNotchRadius);
  path.arcToPoint(
    Offset(0, h / 2 - edgeNotchRadius),
    radius: Radius.circular(edgeNotchRadius),
    clockwise: false,
  );

  // Left edge to top-left corner
  path.lineTo(0, cornerRadius);
  path.arcToPoint(
    Offset(cornerRadius, 0),
    radius: Radius.circular(cornerRadius),
    clockwise: true,
  );

  path.close();
  return path;
}

class _DashedLinePainter extends CustomPainter {
  final Color color;
  final double topOffset;
  final double bottomOffset;

  _DashedLinePainter({
    required this.color,
    this.topOffset = 0.0,
    this.bottomOffset = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double dashHeight = 4, dashSpace = 3.5;
    double startY = topOffset;
    final endY = size.height - bottomOffset;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2;

    while (startY < endY) {
      final curDashHeight = (startY + dashHeight > endY) ? (endY - startY) : dashHeight;
      canvas.drawLine(Offset(0, startY), Offset(0, startY + curDashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}


// ─── Animated Coupon Ticket Skeleton Loader ───────────────────────────────────
class CouponTicketSkeletonCard extends StatefulWidget {
  final double width;
  final double height;
  final EdgeInsetsGeometry margin;

  const CouponTicketSkeletonCard({
    Key? key,
    this.width = double.infinity,
    this.height = 145,
    this.margin = const EdgeInsets.only(bottom: 16),
  }) : super(key: key);

  @override
  State<CouponTicketSkeletonCard> createState() => _CouponTicketSkeletonCardState();
}

class _CouponTicketSkeletonCardState extends State<CouponTicketSkeletonCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) {
        final shimmer = _anim.value;
        final baseColor = dark ? const Color(0xFF1B2A20) : const Color(0xFFEDE8DD);
        final highlightColor = dark ? const Color(0xFF2C4233) : const Color(0xFFFAF7F0);
        final color = Color.lerp(baseColor, highlightColor, shimmer)!;

        return Container(
          width: widget.width,
          height: widget.height,
          margin: widget.margin,
          decoration: BoxDecoration(
            color: dark ? const Color(0xFF111E16) : const Color(0xFFFDFBF7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: dark ? const Color(0x33D4A017) : const Color(0x33B8860B),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Left Stub Box
                Container(
                  width: 52,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: 12),
                // Divider line
                Container(
                  width: 1,
                  height: double.infinity,
                  color: dark ? Colors.white10 : Colors.black12,
                ),
                const SizedBox(width: 12),
                // Right offer details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 75,
                        height: 12,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 150,
                        height: 15,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 110,
                        height: 11,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 65,
                            height: 10,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          Container(
                            width: 60,
                            height: 24,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
