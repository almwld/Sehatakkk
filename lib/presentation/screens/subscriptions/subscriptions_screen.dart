import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../payment/subscription_payment_screen.dart';

/// شاشة الباقات والاشتراكات الموحدة في تطبيق صحتك.
/// جميع الأسعار المعروضة للمستخدم تستخدم عملة RYE.
class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  int _selectedPlan = 0;
  bool _annualBilling = false;

  static const String _currency = 'RYE';

  final List<_Plan> _plans = const [
    _Plan(name: 'الباقة المجانية', shortName: 'مجانية', icon: Icons.volunteer_activism_rounded, monthly: 0, annual: 0, description: 'الأساسيات الصحية اليومية بدون رسوم', features: ['3 استشارات مجانية شهرياً', 'سجل صحي إلكتروني', 'تذكير بالمواعيد', 'تصفح الأدوية والأسعار'], limitations: ['استشارات غير محدودة', 'تحاليل منزلية', 'أولوية في الحجز']),
    _Plan(name: 'الباقة الفضية', shortName: 'فضية', icon: Icons.workspace_premium_rounded, monthly: 3000, annual: 30000, description: 'مناسبة للاستخدام الصحي المنتظم', features: ['10 استشارات شهرياً', 'خصم 20% على الأدوية', 'تحليل منزلي مجاني شهرياً', 'متابعة دورية مع طبيب', 'تقارير صحية شهرية', 'سجل صحي متقدم'], limitations: ['استشارات غير محدودة', 'أولوية قصوى']),
    _Plan(name: 'الباقة البرونزية', shortName: 'برونزية', icon: Icons.shield_rounded, monthly: 3900, annual: 39000, description: 'خطوة متقدمة لرعاية صحية أكثر شمولاً', features: ['20 استشارة شهرياً', 'خصم 25% على الأدوية', 'تحليل منزلي مجاني شهرياً', 'أولوية متوسطة في الحجز', 'تقارير صحية شهرية', 'متابعة صحية أساسية'], limitations: ['استشارات غير محدودة 24/7', 'طبيب شخصي مخصص', 'دعم فني VIP']),
    _Plan(name: 'الباقة الذهبية', shortName: 'ذهبية', icon: Icons.auto_awesome_rounded, monthly: 4900, annual: 35000, description: 'أفضل قيمة للرعاية الصحية المتكاملة', features: ['استشارات غير محدودة 24/7', 'خصم 35% على جميع الأدوية', 'تحاليل منزلية مجانية', 'أولوية في الحجز', 'طبيب شخصي مخصص', 'تقارير صحية أسبوعية', 'محتوى تثقيفي حصري', 'دعم فني VIP'], limitations: const [], popular: true),
    _Plan(name: 'باقة العائلة', shortName: 'عائلة', icon: Icons.family_restroom_rounded, monthly: 7500, annual: 75000, description: 'رعاية متكاملة لك ولعائلتك حتى 5 أفراد', features: ['كل مميزات الباقة الذهبية', 'حتى 5 أفراد من العائلة', 'استشارات أطفال مجانية', 'متابعة الحمل والولادة', 'تطعيمات الأطفال', 'طبيب عائلة مخصص', 'خصم 50% على الأدوية', 'تقارير عائلية شاملة'], limitations: const []),
    _Plan(name: 'الباقة الكريستالية', shortName: 'كريستالية', icon: Icons.diamond_rounded, monthly: 12000, annual: 120000, description: 'تجربة رعاية صحية فائقة ومتكاملة لك ولعائلتك', features: ['كل مميزات باقة العائلة', 'حتى 8 أفراد من العائلة', 'استشارات غير محدودة 24/7', 'طبيب شخصي وكبير أطباء مخصص', 'أولوية قصوى في الحجوزات', 'تحاليل منزلية متقدمة', 'خصم 60% على الأدوية', 'مدير رعاية صحية شخصي', 'دعم VIP على مدار الساعة', 'تقارير صحية متقدمة وتحليلات دورية'], limitations: const []),
  ];

  String _money(int value) => '$value $_currency';

  void _openPayment(_Plan plan) {
    if (plan.monthly == 0) {
      setState(() => _selectedPlan = _plans.indexOf(plan));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('أنت على الباقة المجانية حالياً.')));
      return;
    }
    final price = _annualBilling ? plan.annual : plan.monthly;
    Navigator.push(context, MaterialPageRoute(builder: (_) => SubscriptionPaymentScreen(planName: plan.name, planPrice: _money(price), planEmoji: _iconAsEmoji(plan.icon)))).then((paid) {
      if (!mounted || paid != true) return;
      setState(() => _selectedPlan = _plans.indexOf(plan));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم الاشتراك في ${plan.name} بنجاح.'), backgroundColor: AppColors.success));
    });
  }

  String _iconAsEmoji(IconData icon) {
    if (icon == Icons.family_restroom_rounded) return '👨‍👩‍👧‍👦';
    if (icon == Icons.auto_awesome_rounded) return '⭐';
    if (icon == Icons.diamond_rounded) return '💎';
    if (icon == Icons.shield_rounded) return '🛡️';
    if (icon == Icons.workspace_premium_rounded) return '🏅';
    return '🆓';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F7),
      appBar: AppBar(title: const Text('الباقات والاشتراكات', style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: AppColors.primary, foregroundColor: Colors.white, elevation: 0),
      body: SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(14, 16, 14, 28), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _buildHeader(),
        const SizedBox(height: 14),
        _buildBillingSwitch(),
        const SizedBox(height: 14),
        ...List.generate(_plans.length, (index) => Padding(padding: const EdgeInsets.only(bottom: 12), child: _buildPlanCard(_plans[index], index))),
        _buildTrustNote(),
      ])),),
    );
  }

  Widget _buildHeader() {
    return Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.primary.withOpacity(0.12))), child: Row(children: [
      Container(width: 52, height: 52, decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.10), borderRadius: BorderRadius.circular(15)), child: const Icon(Icons.health_and_safety_rounded, color: AppColors.primary, size: 28)),
      const SizedBox(width: 12),
      const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('اختر باقتك الصحية', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), SizedBox(height: 4), Text('رعاية صحية تناسب احتياجاتك وميزانيتك', style: TextStyle(fontSize: 12, color: AppColors.grey))])),
    ]));
  }

  Widget _buildBillingSwitch() {
    return Container(padding: const EdgeInsets.all(5), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE1E6E8))), child: Row(children: [Expanded(child: _billingChoice('شهري', false)), Expanded(child: _billingChoice('سنوي', true))]));
  }

  Widget _billingChoice(String label, bool annual) {
    final selected = _annualBilling == annual;
    return GestureDetector(onTap: () => setState(() => _annualBilling = annual), child: AnimatedContainer(duration: const Duration(milliseconds: 180), padding: const EdgeInsets.symmetric(vertical: 11), decoration: BoxDecoration(color: selected ? AppColors.primary : Colors.transparent, borderRadius: BorderRadius.circular(10)), child: Text(label, textAlign: TextAlign.center, style: TextStyle(color: selected ? Colors.white : AppColors.darkGrey, fontWeight: FontWeight.bold, fontSize: 13))));
  }

  Widget _buildPlanCard(_Plan plan, int index) {
    final selected = _selectedPlan == index;
    final price = _annualBilling ? plan.annual : plan.monthly;
    return Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: selected || plan.popular ? AppColors.primary.withOpacity(0.55) : const Color(0xFFE1E6E8), width: selected || plan.popular ? 1.5 : 1)), child: Column(children: [
      if (plan.popular) Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 7), decoration: const BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.vertical(top: Radius.circular(17))), child: const Text('الأكثر اختياراً', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
      Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Container(width: 48, height: 48, decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.09), borderRadius: BorderRadius.circular(14)), child: Icon(plan.icon, color: AppColors.primary, size: 25)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(plan.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 3), Text(plan.description, style: const TextStyle(fontSize: 11, color: AppColors.grey))])),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(_money(price), style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: AppColors.primary)), Text(_annualBilling ? 'سنوياً' : 'شهرياً', style: const TextStyle(fontSize: 10, color: AppColors.grey))]),
        ]),
        if (_annualBilling && plan.monthly > 0) Padding(padding: const EdgeInsets.only(top: 8), child: Text('ما يعادل ${_money((plan.annual / 12).round())} شهرياً', style: const TextStyle(fontSize: 10, color: AppColors.success, fontWeight: FontWeight.bold))),
        const Divider(height: 24),
        ...plan.features.map((feature) => _featureRow(feature, true)),
        ...plan.limitations.map((feature) => _featureRow(feature, false)),
        const SizedBox(height: 10),
        SizedBox(height: 46, child: ElevatedButton(onPressed: selected && index == 0 ? null : () => _openPayment(plan), style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, disabledBackgroundColor: AppColors.primary.withOpacity(0.12), disabledForegroundColor: AppColors.primary, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Text(selected ? 'باقتك الحالية' : (price == 0 ? 'ابدأ مجاناً' : 'اشترك الآن'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)))),
      ])),
    ]));
  }

  Widget _featureRow(String text, bool enabled) {
    return Padding(padding: const EdgeInsets.only(bottom: 7), child: Row(children: [Icon(enabled ? Icons.check_circle_rounded : Icons.remove_circle_outline_rounded, size: 18, color: enabled ? AppColors.success : AppColors.grey), const SizedBox(width: 7), Expanded(child: Text(text, style: TextStyle(fontSize: 12, color: enabled ? AppColors.darkGrey : AppColors.grey)))]));
  }

  Widget _buildTrustNote() {
    return Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE1E6E8))), child: const Row(children: [Icon(Icons.lock_outline_rounded, color: AppColors.primary, size: 20), SizedBox(width: 8), Expanded(child: Text('الدفع يتم عبر محافظ إلكترونية يمنية مدعومة. الأسعار الظاهرة في هذه الشاشة بعملة RYE.', style: TextStyle(fontSize: 11, color: AppColors.grey)))]));
  }
}

class _Plan {
  final String name;
  final String shortName;
  final IconData icon;
  final int monthly;
  final int annual;
  final String description;
  final List<String> features;
  final List<String> limitations;
  final bool popular;

  const _Plan({required this.name, required this.shortName, required this.icon, required this.monthly, required this.annual, required this.description, required this.features, required this.limitations, this.popular = false});
}
