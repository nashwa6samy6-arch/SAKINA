import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sakina/core/theme/app_colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ─── Models ───────────────────────────────────────────────────────────────────

class Plan {
  final String id;
  final String name;
  final int price;
  final String duration;
  final int durationDays;
  final List<String> perks;
  final bool popular;

  const Plan({
    required this.id,
    required this.name,
    required this.price,
    required this.duration,
    required this.durationDays,
    required this.perks,
    this.popular = false,
  });
}

const List<Plan> plans = [
  Plan(
    id: 'monthly',
    name: '1 Property',
    price: 200,
    duration: '1 month',
    durationDays: 30,
    perks: ['Top placement in search', 'Premium badge on listing'],
  ),
  Plan(
    id: 'quarterly',
    name: '3 Properties',
    price: 500,
    duration: '1 month',
    durationDays: 30,
    perks: ['Top placement in search', 'Premium badge on listing'],
    popular: true,
  ),
  Plan(
    id: 'annual',
    name: '6 Properties',
    price: 920,
    duration: '1 month',
    durationDays: 365,
    perks: ['Top placement in search', 'Premium badge on listing', 'Save 8%'],
  ),
];

enum PremiumStep { select, payment, processing, success, failed }

// ─── Screen ───────────────────────────────────────────────────────────────────

class PremiumScreen extends StatefulWidget {
  final String landlordId;

  const PremiumScreen({super.key, required this.landlordId});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  final _supabase = Supabase.instance.client;

  List<Map<String, dynamic>> _listings = [];
  PremiumStep _step = PremiumStep.select;
  Plan _selectedPlan = plans[1];
  bool _simulateFail = false;

  final _cardNameController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  // ── Theme ──────────────────────────────────────────────────────────────────
  static const Color _bg = Color(0xFFF7F6F3);
  static const Color _fg = Color(0xFF14213D);
  static const Color _card = Color(0xFFFFFFFF);
  static const Color _accent = Color(0xFFC9922A);
  static const Color _muted = Color(0xFF6B7280);
  static const Color _border = Color(0x1E14213D);
  static const Color _inputBg = Color(0xFFF0F1F5);
  static const Color _destructive = Color(0xFFC53030);

  @override
  void initState() {
    super.initState();
    _loadListings();
  }

  @override
  void dispose() {
    _cardNameController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  Future<void> _loadListings() async {
    try {
      final response = await _supabase
          .from('property_listings')
          .select()
          .eq('landlord_id', widget.landlordId)
          .eq('status', 'available')
          .order('created_at', ascending: false);

      setState(() {
        _listings = List<Map<String, dynamic>>.from(response);
      });
    } catch (_) {}
  }

  bool get _paymentFieldsFilled =>
      _cardNameController.text.isNotEmpty &&
      _cardNumberController.text.isNotEmpty &&
      _expiryController.text.isNotEmpty &&
      _cvvController.text.isNotEmpty;

  void _handlePay() {
    if (!_paymentFieldsFilled) return;

    setState(() => _step = PremiumStep.processing);

    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        setState(() {
          _step = _simulateFail ? PremiumStep.failed : PremiumStep.success;
        });
      }
    });
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.themeColor,
      appBar: AppBar(
        backgroundColor: AppColors.appbarColor,
        elevation: 0,
        leadingWidth: 200,
        leading: TextButton.icon(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: _muted, size: 16),
          label: const Text(
            'Back to Dashboard',
            style: TextStyle(color: _muted, fontSize: 14),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 32),
                _buildMainCard(),
                if (_listings.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  _buildListingsSection(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    final (title, subtitle) = switch (_step) {
      PremiumStep.select => (
          'Elevate Your Listing',
          'Choose a premium plan to prioritize your property in search results and attract high-quality tenants faster.',
        ),
      PremiumStep.payment => (
          'Elevate Your Listing',
          'Enter your payment details to securely activate your premium subscription.',
        ),
      PremiumStep.processing => (
          'Elevate Your Listing',
          'We are securely processing your payment...',
        ),
      PremiumStep.success => (
          "You're all set!",
          'Your property is now featured at the top of search results with a premium badge.',
        ),
      PremiumStep.failed => (
          'Payment Failed',
          'We couldn\'t process your payment. Please check your card details and try again.',
        ),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _accent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _accent.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.auto_awesome, color: _accent, size: 14),
              const SizedBox(width: 8),
              const Text(
                'PREMIUM UPGRADE',
                style: TextStyle(
                  color: _accent,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: GoogleFonts.playfairDisplay(
            color: _fg,
            fontSize: 32,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          subtitle,
          style: const TextStyle(color: _muted, fontSize: 16, height: 1.5),
        ),
      ],
    );
  }

  // ─── Main card ─────────────────────────────────────────────────────────────

  Widget _buildMainCard() {
    final wide = MediaQuery.of(context).size.width > 600;
    return Container(
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      padding: EdgeInsets.all(wide ? 32 : 20),
      child: switch (_step) {
        PremiumStep.select => _buildSelectStep(),
        PremiumStep.payment => _buildPaymentStep(),
        PremiumStep.processing => _buildProcessingStep(),
        PremiumStep.success => _buildSuccessStep(),
        PremiumStep.failed => _buildFailedStep(),
      },
    );
  }

  // ─── Step: Select plan ─────────────────────────────────────────────────────

  Widget _buildSelectStep() {
    return Column(
      children: [
        ...plans.map((plan) {
          final selected = _selectedPlan.id == plan.id;
          return GestureDetector(
            onTap: () => setState(() => _selectedPlan = plan),
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: selected ? _accent.withOpacity(0.05) : _card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected ? _accent : _border,
                  width: selected ? 2 : 1,
                ),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  if (plan.popular)
                    Positioned(
                      top: -32,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: _accent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'MOST POPULAR',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final wide = constraints.maxWidth > 550;

                      final radio = Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selected
                                ? _accent
                                : _muted.withOpacity(0.5),
                            width: 2,
                          ),
                        ),
                        child: selected
                            ? Center(
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: const BoxDecoration(
                                    color: _accent,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              )
                            : null,
                      );

                      final header = Row(
                        children: [
                          radio,
                          const SizedBox(width: 12),
                          Text(
                            plan.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: _fg,
                            ),
                          ),
                        ],
                      );

                      final price = Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'EGP ${plan.price}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: _fg,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '/ ${plan.duration}',
                            style: const TextStyle(
                                fontSize: 14, color: _muted),
                          ),
                        ],
                      );

                      if (wide) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  header,
                                  const SizedBox(height: 12),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 32),
                                    child: _buildPerks(plan.perks, wide: true),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            price,
                          ],
                        );
                      } else {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            header,
                            const SizedBox(height: 12),
                            Padding(
                              padding: const EdgeInsets.only(left: 32),
                              child: _buildPerks(plan.perks, wide: false),
                            ),
                            const SizedBox(height: 12),
                            Padding(
                              padding: const EdgeInsets.only(left: 32),
                              child: price,
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () => setState(() => _step = PremiumStep.payment),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2C2005),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Continue to Payment',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPerks(List<String> perks, {required bool wide}) {
    if (wide) {
      final mid = (perks.length / 2).ceil();
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: perks
                  .sublist(0, mid)
                  .map(_buildPerkItem)
                  .toList(),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: perks
                  .sublist(mid)
                  .map(_buildPerkItem)
                  .toList(),
            ),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: perks.map(_buildPerkItem).toList(),
    );
  }

  Widget _buildPerkItem(String perk) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: _accent, size: 14),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              perk,
              style: const TextStyle(color: _muted, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Step: Payment ─────────────────────────────────────────────────────────

  Widget _buildPaymentStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary banner
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _accent.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _accent.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.star, color: _accent, size: 20),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_selectedPlan.name} Plan',
                        style: const TextStyle(
                          color: _fg,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Text(
                        'Billed now',
                        style: TextStyle(color: _muted, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              Text(
                'EGP ${_selectedPlan.price}',
                style: const TextStyle(
                  color: _fg,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildTextField('Cardholder Name', _cardNameController, 'Jane Smith'),
        const SizedBox(height: 16),
        _buildTextField(
          'Card Number',
          _cardNumberController,
          '4242 4242 4242 4242',
          icon: Icons.credit_card,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                  'Expiry Date', _expiryController, 'MM/YY'),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField('CVV', _cvvController, '•••',
                  obscureText: true),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Checkbox(
              value: _simulateFail,
              onChanged: (val) =>
                  setState(() => _simulateFail = val ?? false),
              activeColor: _accent,
            ),
            const Text(
              'Simulate payment failure (demo)',
              style: TextStyle(color: _muted, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              flex: 1,
              child: SizedBox(
                height: 56,
                child: OutlinedButton(
                  onPressed: () =>
                      setState(() => _step = PremiumStep.select),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: _border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Back',
                    style: TextStyle(
                        color: _fg,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _handlePay,
                  icon: const Icon(Icons.lock, size: 18),
                  label: Text(
                    'Pay EGP ${_selectedPlan.price}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBrown,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    String hint, {
    IconData? icon,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _fg,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: _muted),
            filled: true,
            fillColor: _inputBg,
            prefixIcon: icon != null
                ? Icon(icon, color: _muted, size: 18)
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: _fg.withOpacity(0.2), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Step: Processing ──────────────────────────────────────────────────────

  Widget _buildProcessingStep() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 80),
      child: Center(
        child: Column(
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(_accent),
            ),
            SizedBox(height: 24),
            Text(
              'Processing Payment',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: _fg),
            ),
            SizedBox(height: 8),
            Text(
              'Please do not close this window...',
              style: TextStyle(color: _muted, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Step: Success ─────────────────────────────────────────────────────────

  Widget _buildSuccessStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: _accent.withOpacity(0.1),
                shape: BoxShape.circle,
                border:
                    Border.all(color: _accent.withOpacity(0.05), width: 8),
              ),
              child: const Icon(Icons.check_circle,
                  color: _accent, size: 48),
            ),
            const SizedBox(height: 24),
            Text(
              'Payment Successful!',
              style: GoogleFonts.playfairDisplay(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: _fg,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Your listing has been upgraded to Premium for the next month.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _muted, fontSize: 16),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 56,
              width: 240,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _fg,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Return to Dashboard',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Step: Failed ──────────────────────────────────────────────────────────

  Widget _buildFailedStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: _destructive.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                    color: _destructive.withOpacity(0.05), width: 8),
              ),
              child: const Icon(Icons.error_outline,
                  color: _destructive, size: 48),
            ),
            const SizedBox(height: 24),
            Text(
              'Payment Declined',
              style: GoogleFonts.playfairDisplay(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: _fg,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Your bank declined the transaction. No charges were made. Please try a different payment method.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _muted, fontSize: 16),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: _border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                          color: _fg,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () =>
                        setState(() => _step = PremiumStep.payment),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _fg,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Try Again',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── Listings section ──────────────────────────────────────────────────────

  Widget _buildListingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Active Listings',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.black,
            fontFamily: 'Manrope',
          ),
        ),
        const SizedBox(height: 12),
        ..._listings.map((l) => _ListingTile(listing: l)),
      ],
    );
  }
}

// ─── Listing Tile ──────────────────────────────────────────────────────────────

class _ListingTile extends StatelessWidget {
  final Map<String, dynamic> listing;

  const _ListingTile({required this.listing});

  @override
  Widget build(BuildContext context) {
    const brown = Color(0xFF1B1209);
    const muted = Color(0xFF7A746C);
    const cardBg = Color(0xFFEEE9DF);

    final title = listing['title'] ?? 'Untitled';
    final price = listing['rent_price'];
    final type = listing['property_type'] ?? '';
    final imageUrl = listing['image_url']?.toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 60,
              height: 60,
              color: const Color(0xFFD8D0C0),
              child: imageUrl != null
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.home, color: muted),
                    )
                  : const Icon(Icons.home, color: muted),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: brown,
                    fontFamily: 'Manrope',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  type.isNotEmpty
                      ? type.replaceAll('_', ' ')
                      : 'Property',
                  style: const TextStyle(
                    fontSize: 12,
                    color: muted,
                    fontFamily: 'Manrope',
                  ),
                ),
              ],
            ),
          ),
          if (price != null)
            Text(
              'EGP ${price}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: brown,
                fontFamily: 'Manrope',
              ),
            ),
        ],
      ),
    );
  }
}