import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/screens/auth/login_screen.dart';
import 'package:sehatak/presentation/screens/doctor/doctors_list_screen.dart';
import 'package:sehatak/presentation/screens/doctor/doctor_details_screen.dart';
import 'package:sehatak/presentation/screens/pharmacy/pharmacy_screen.dart';
import 'package:sehatak/presentation/screens/more/more_screen.dart';
import 'package:sehatak/presentation/screens/patient/patient_appointments.dart';
import 'package:sehatak/presentation/screens/patient/patient_dashboard.dart';
import 'package:sehatak/presentation/screens/chat/chat_screen.dart';
import 'package:sehatak/presentation/screens/emergencies/emergency_numbers.dart';
import 'package:sehatak/presentation/screens/nearby_clinics/nearby_clinics_screen.dart';
import 'package:sehatak/presentation/screens/pharmacy/cart_screen.dart';
import 'package:sehatak/presentation/screens/lab/labs_list_screen.dart';
import 'package:sehatak/presentation/screens/insurance/insurance_companies.dart';
import 'package:sehatak/presentation/screens/health/health_dashboard.dart';
import 'package:sehatak/presentation/screens/payment/wallet_screen.dart';
import 'package:sehatak/presentation/bloc/auth_bloc/auth_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool get _isLoggedIn => FirebaseAuth.instance.currentUser != null;
  final List<Widget> _screens = const [_HomeTab(), DoctorsListScreen(), PharmacyScreen(), ChatScreen(), PatientAppointments(), PatientDashboard(), MoreScreen()];

  void _requireAuth(VoidCallback action) {
    if (_isLoggedIn) { action(); }
    else { Navigator.push(context, MaterialPageRoute(builder: (_) => BlocProvider(create: (_) => AuthBloc(), child: const LoginScreen()))); }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(body: _screens[_currentIndex], bottomNavigationBar: _buildBottomNav(isDark));
  }

  Widget _buildBottomNav(bool isDark) {
    return Container(height: 70, decoration: BoxDecoration(color: isDark ? const Color(0xFF111D33) : Colors.white, borderRadius: const BorderRadius.vertical(top: Radius.circular(20))), child: SafeArea(child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      _navItem(0, Icons.home_rounded, 'الرئيسية'), _navItem(1, Icons.person_search_rounded, 'الأطباء'), _navItem(2, Icons.local_pharmacy_rounded, 'الصيدلية'), _centerChatButton(),
      _navItem(4, Icons.calendar_month_rounded, 'المواعيد'), _navItem(5, Icons.folder_rounded, 'صحتي'), _navItem(6, Icons.grid_view_rounded, 'المزيد'),
    ])));
  }

  Widget _navItem(int index, IconData icon, String label) {
    final sel = _currentIndex == index;
    final color = sel ? AppColors.primary : AppColors.grey;
    return GestureDetector(onTap: () { if (index==3||index==4||index==5) { _requireAuth(()=>setState(()=>_currentIndex=index)); } else { setState(()=>_currentIndex=index); } }, child: Column(mainAxisSize:MainAxisSize.min, children: [Icon(icon, color:color, size:22), Text(label, style:TextStyle(fontSize:10, color:color))]));
  }

  Widget _centerChatButton() => GestureDetector(onTap: () => _requireAuth(() => setState(() => _currentIndex = 3)), child: Column(mainAxisSize: MainAxisSize.min, children: [Container(width:48,height:48,decoration:BoxDecoration(gradient:const LinearGradient(colors:[AppColors.primary,AppColors.primaryDark]),shape:BoxShape.circle),child:const Icon(Icons.chat_rounded,color:Colors.white,size:26))]));
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();
  void _go(BuildContext c, Widget p) => Navigator.push(c, MaterialPageRoute(builder: (_) => p));
  @override
  Widget build(BuildContext context) {
    final logged = FirebaseAuth.instance.currentUser != null;
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white, foregroundColor: AppColors.primary, elevation: 0,
        title: Text(logged ? 'مرحباً، ${user?.displayName ?? user?.email?.split('@')[0] ?? "أحمد"}' : 'منصة صحتك', style: const TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.w600)),
        actions: [IconButton(icon: const Icon(Icons.notifications_outlined, color: AppColors.primary), onPressed: () {}), IconButton(icon: const Icon(Icons.shopping_cart_outlined, color: AppColors.primary), onPressed: () {}), if (!logged) TextButton(onPressed: () => _go(context, BlocProvider(create: (_) => AuthBloc(), child: const LoginScreen())), child: const Text('تسجيل', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)))],
      ),
      body: NotificationListener<ScrollNotification>(onNotification: (notification) { if (notification is UserScrollNotification) { if (notification.direction == ScrollDirection.forward) {} else if (notification.direction == ScrollDirection.reverse) {} } return false; }, child: SingleChildScrollView(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 14), const SizedBox(height: 16), const SizedBox(height: 16), const SizedBox(height: 16),
        _sectionTitle('خدمات سريعة'), const SizedBox(height: 10), const SizedBox(height: 8), _quickServicesRow2(context), const SizedBox(height: 22),
        _sectionTitle('عروض وخصومات'), const SizedBox(height: 10), _offersRow(context), const SizedBox(height: 22),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_sectionTitle('أفضل الأطباء'), TextButton(onPressed: () => _go(context, const DoctorsListScreen()), child: const Text('عرض الكل ›'))]), const SizedBox(height: 10),
        _doctorCard('د. علي المولد', 'استشاري باطنية وأطفال', '20+ سنة', 4.9, 328, '1', context), const SizedBox(height: 8), _doctorCard('د. حسن رضا', 'طبيب عام', '8+ سنوات', 4.8, 235, '2', context), const SizedBox(height: 8), _doctorCard('د. فاطمة صديقي', 'طبيبة أطفال', '15+ سنة', 4.9, 412, '3', context), const SizedBox(height: 22),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_sectionTitle('منتجات صيدلية'), TextButton(onPressed: () => _go(context, const PharmacyScreen()), child: const Text('عرض الكل ›'))]), const SizedBox(height: 10), _pharmacyRow(context), const SizedBox(height: 22),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_sectionTitle('تحاليل شائعة'), TextButton(onPressed: () => _go(context, const LabsListScreen()), child: const Text('عرض الكل ›'))]), const SizedBox(height: 10), _labsRow(context), const SizedBox(height: 22),
        _statsRow(), const SizedBox(height: 22), _sectionTitle('نصائح يومية'), const SizedBox(height: 10), _healthTip('شرب الماء', '8 أكواب يومياً للحفاظ على صحة الجسم', Icons.water_drop, AppColors.info), const SizedBox(height: 8), _healthTip('المشي اليومي', '30 دقيقة تقلل من أمراض القلب بنسبة 30%', Icons.directions_walk, AppColors.success), const SizedBox(height: 8), _healthTip('النوم المبكر', '7-8 ساعات نوم تحسن المناعة والتركيز', Icons.bedtime, AppColors.purple), const SizedBox(height: 22), _sectionTitle('تقنيات ذكية'), const SizedBox(height: 10), _aiServicesRow(context), const SizedBox(height: 50),
      ]))),
    );
  }
  Widget _sectionTitle(String t) => Text(t, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
  Widget _quickServicesRow2(BuildContext c) => Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [_qs('تأمين', Icons.shield_moon, AppColors.indigo, () => _go(c, const InsuranceCompanies())), _qs('صحة', Icons.favorite, AppColors.pink, () => _go(c, const HealthDashboard())), _qs('محفظة', Icons.account_balance_wallet, AppColors.amber, () => _go(c, const WalletScreen())), _qs('سلة', Icons.shopping_cart, AppColors.orange, () => _go(c, const CartScreen()))]);
  Widget _qs(String l, IconData i, Color c, VoidCallback t) => GestureDetector(onTap: t, child: Column(children: [Container(width: 52, height: 52, decoration: BoxDecoration(color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(14)), child: Icon(i, color: c, size: 26)), const SizedBox(height: 6), Text(l, style: const TextStyle(fontSize: 10))]));
  Widget _offersRow(BuildContext c) => SizedBox(height: 100, child: ListView(scrollDirection: Axis.horizontal, children: [_offerCard('خصم 30%', 'على جميع الأدوية', 'للطلبات الأولى', AppColors.error), _offerCard('استشارة مجانية', 'مع طبيب مختص', 'للمستخدمين الجدد', AppColors.primary), _offerCard('توصيل مجاني', 'للطلبات فوق 5000', 'طوال الأسبوع', AppColors.success)]));
  Widget _offerCard(String t, String s, String d, Color c) => Container(width: 180, margin: const EdgeInsets.only(right: 10), padding: const EdgeInsets.all(14), decoration: BoxDecoration(gradient: LinearGradient(colors: [c, c.withOpacity(0.7)]), borderRadius: BorderRadius.circular(16)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text(t, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text(s, style: const TextStyle(color: Colors.white70, fontSize: 12)), Text(d, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500))]));
  Widget _doctorCard(String n, String sp, String exp, double r, int rev, String id, BuildContext c) => Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]), child: Row(children: [Container(width: 50, height: 50, decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.person, color: AppColors.primary, size: 30)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(n, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), Text(sp, style: const TextStyle(color: AppColors.grey, fontSize: 11)), Text(exp, style: const TextStyle(color: AppColors.primary, fontSize: 11))])), Column(children: [Row(children: [const Icon(Icons.star, color: AppColors.amber, size: 14), Text(' $r', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))]), Text('$rev تقييم', style: const TextStyle(color: AppColors.grey, fontSize: 9)), const SizedBox(height: 4), GestureDetector(onTap: () => _go(c, DoctorDetailsScreen(doctorId: id)), child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)), child: const Text('حجز', style: TextStyle(color: Colors.white, fontSize: 10))))])]));
  Widget _pharmacyRow(BuildContext c) => SizedBox(height: 160, child: ListView(scrollDirection: Axis.horizontal, children: [_productCard('باراسيتامول', '500mg', '500 ر.ي', Icons.medication, AppColors.info), _productCard('فيتامين د', '1000IU', '1200 ر.ي', Icons.vaccines, AppColors.success), _productCard('خافض حرارة', 'للأطفال', '350 ر.ي', Icons.medical_services, AppColors.warning), _productCard('مضاد حيوي', '500mg', '2200 ر.ي', Icons.biotech, AppColors.error)]));
  Widget _productCard(String n, String d, String p, IconData i, Color c) => Container(width: 130, margin: const EdgeInsets.only(right: 10), padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]), child: Column(children: [Container(width: 50, height: 50, decoration: BoxDecoration(color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(i, color: c, size: 28)), const SizedBox(height: 8), Text(n, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.center), Text(d, style: const TextStyle(color: AppColors.grey, fontSize: 10)), const SizedBox(height: 4), Text(p, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13))]));
  Widget _labsRow(BuildContext c) => SizedBox(height: 100, child: ListView(scrollDirection: Axis.horizontal, children: [_labCard('تحليل دم شامل', 'CBC', '2000 ر.ي', AppColors.info), _labCard('فيتامين د', 'Vit D', '3500 ر.ي', AppColors.success), _labCard('وظائف كبد', 'LFT', '2500 ر.ي', AppColors.warning), _labCard('سكر تراكمي', 'HbA1c', '1800 ر.ي', AppColors.purple)]));
  Widget _labCard(String t, String c, String p, Color co) => Container(width: 140, margin: const EdgeInsets.only(right: 10), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(t, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.center), Text(c, style: const TextStyle(color: AppColors.grey, fontSize: 10)), const SizedBox(height: 5), Text(p, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12))]));
  Widget _statsRow() => Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [_stat('أطباء', '500+', Icons.people, AppColors.primary), _stat('صيدليات', '120+', Icons.local_pharmacy, AppColors.success), _stat('مختبرات', '80+', Icons.biotech, AppColors.info), _stat('مستخدمين', '10K+', Icons.person, AppColors.purple)]);
  Widget _stat(String t, String v, IconData i, Color c) => Column(children: [Icon(i, color: c, size: 24), const SizedBox(height: 3), Text(v, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), Text(t, style: const TextStyle(color: AppColors.grey, fontSize: 9))]);
  Widget _healthTip(String t, String d, IconData i, Color c) => Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)), child: Row(children: [Container(width: 42, height: 42, decoration: BoxDecoration(color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(11)), child: Icon(i, color: c)), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)), Text(d, style: const TextStyle(color: AppColors.grey, fontSize: 10))]))]));
  Widget _aiServicesRow(BuildContext c) => Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [_qs('مساعد ذكي', Icons.smart_toy, AppColors.purple, () {}), _qs('فحص أولي', Icons.health_and_safety, AppColors.primary, () {}), _qs('تذكير', Icons.notifications_active, AppColors.warning, () {})]);
}
