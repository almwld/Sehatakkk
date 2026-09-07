import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class SubscriptionPaymentScreen extends StatefulWidget {
  final String planName;
  final String planPrice;
  final String planEmoji;

  const SubscriptionPaymentScreen({
    super.key,
    required this.planName,
    required this.planPrice,
    required this.planEmoji,
  });

  @override
  State<SubscriptionPaymentScreen> createState() => _SubscriptionPaymentScreenState();
}

class _SubscriptionPaymentScreenState extends State<SubscriptionPaymentScreen> {
  int _selectedWallet = 0;
  bool _processing = false;
  bool _success = false;

  static const _currency = 'RYE';

  final List<Map<String, dynamic>> _wallets = [
    {'name': 'فلوسك', 'code': 'FLOSWK', 'emoji': '💳', 'color': const Color(0xFF1A73E8), 'number': '**** 4582'},
    {'name': 'محفظة كاش', 'code': 'CASH', 'emoji': '💰', 'color': const Color(0xFF00A86B), 'number': '**** 7891'},
    {'name': 'محفظة جوالي', 'code': 'JAWALI', 'emoji': '📱', 'color': const Color(0xFFFF6B00), 'number': '**** 3456'},
    {'name': 'محفظة جيب', 'code': 'JEEB', 'emoji': '👛', 'color': const Color(0xFFE91E63), 'number': '**** 9012'},
    {'name': 'محفظة إيزي', 'code': 'EASY', 'emoji': '🏧', 'color': const Color(0xFF0277BD), 'number': '**** 5678'},
  ];

  void _confirmPayment() {
    setState(() => _processing = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _processing = false;
        _success = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_success) return _buildSuccess();

    return Scaffold(
      appBar: AppBar(title: const Text('تأكيد الدفع', style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: AppColors.primary, foregroundColor: Colors.white),
      body: SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _buildPlanSummary(),
        const SizedBox(height: 22),
        const Text('اختر طريقة الدفع', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        const Text('المحافظ الإلكترونية اليمنية المدعومة', style: TextStyle(fontSize: 12, color: AppColors.grey)),
        const SizedBox(height: 12),
        ...List.generate(_wallets.length, (i) => _walletCard(i)),
        const SizedBox(height: 12),
        _buildTotal(),
        const SizedBox(height: 18),
        SizedBox(height: 54, child: ElevatedButton(onPressed: _processing ? null : _confirmPayment, style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))), child: _processing ? const Row(mainAxisAlignment: MainAxisAlignment.center, children: [SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)), SizedBox(width: 10), Text('جاري الدفع...')]) : Text('ادفع ${widget.planPrice} عبر ${_wallets[_selectedWallet]['name']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)))),
        const SizedBox(height: 20),
        const Text('جميع الأسعار والملخصات تستخدم عملة RYE.', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: AppColors.grey)),
      ]))),
    );
  }

  Widget _buildPlanSummary() {
    return Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(18)), child: Column(children: [
      Text(widget.planEmoji, style: const TextStyle(fontSize: 40)),
      const SizedBox(height: 6),
      Text(widget.planName, style: const TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.bold)),
      const SizedBox(height: 10),
      Text(widget.planPrice, style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
      const Text('سعر الاشتراك', style: TextStyle(color: Colors.white70, fontSize: 12)),
    ]));
  }

  Widget _walletCard(int index) {
    final wallet = _wallets[index];
    final selected = _selectedWallet == index;
    final color = wallet['color'] as Color;
    return GestureDetector(onTap: () => setState(() => _selectedWallet = index), child: Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: selected ? color.withOpacity(0.06) : Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: selected ? color : const Color(0xFFE1E6E8), width: selected ? 1.5 : 1)), child: Row(children: [
      Container(width: 48, height: 48, decoration: BoxDecoration(color: color.withOpacity(0.10), borderRadius: BorderRadius.circular(12)), child: Center(child: Text(wallet['emoji'], style: const TextStyle(fontSize: 22)))),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Text(wallet['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), const SizedBox(width: 6), Text(wallet['code'], style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold))]), const SizedBox(height: 3), Text(wallet['number'], style: const TextStyle(fontSize: 10, color: AppColors.grey))])),
      if (selected) Icon(Icons.check_circle_rounded, color: color, size: 25),
    ])));
  }

  Widget _buildTotal() {
    return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFFF4F6F7), borderRadius: BorderRadius.circular(14)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('الإجمالي', style: TextStyle(fontWeight: FontWeight.bold)), Text(widget.planPrice, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppColors.primary))]));
  }

  Widget _buildSuccess() {
    return Scaffold(backgroundColor: Colors.white, body: SafeArea(child: Center(child: Padding(padding: const EdgeInsets.all(28), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(width: 110, height: 110, decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle), child: const Icon(Icons.check_rounded, color: Colors.white, size: 58)),
      const SizedBox(height: 28),
      const Text('تم الدفع بنجاح', style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Text('أنت الآن مشترك في ${widget.planName}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, color: AppColors.grey)),
      const SizedBox(height: 18),
      Container(width: double.infinity, padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: AppColors.success.withOpacity(0.06), borderRadius: BorderRadius.circular(16)), child: Column(children: [Text(widget.planPrice, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.success)), const SizedBox(height: 4), const Text(_currency, style: TextStyle(fontSize: 11, color: AppColors.grey))])),
      const SizedBox(height: 24),
      SizedBox(width: double.infinity, height: 52, child: ElevatedButton(onPressed: () => Navigator.pop(context, true), style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))), child: const Text('متابعة إلى التطبيق', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)))),
    ]))));
  }
}
