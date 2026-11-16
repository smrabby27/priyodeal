import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<BusinessItem> _doctors = [];
  List<CategoryItem> _specialties = [];
  int _selectedSpecialtyId = 0;
  bool _isLoading = true;

  // My Appointments list
  List<AppointmentItem> _myAppointments = [];
  bool _isLoadingAppointments = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final cats = await ApiService.getCategories(module: 'booking');
    final docs = await ApiService.getBusinesses(
      type: 'doctor',
      categoryId: _selectedSpecialtyId > 0 ? _selectedSpecialtyId : null,
    );

    if (mounted) {
      setState(() {
        _specialties = cats;
        _doctors = docs;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadAppointments() async {
    setState(() => _isLoadingAppointments = true);
    final list = await ApiService.getUserAppointments();
    if (mounted) {
      setState(() {
        _myAppointments = list;
        _isLoadingAppointments = false;
      });
    }
  }

  void _openDoctorDetail(BusinessItem doctor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DoctorDetailSheet(
        doctor: doctor,
        onBookingComplete: () {
          _tabController.animateTo(1);
          _loadAppointments();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('ডাক্তার অ্যাপয়েন্টমেন্ট'),
        bottom: TabBar(
          controller: _tabController,
          onTap: (index) {
            if (index == 1) _loadAppointments();
          },
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: 'ডাক্তার খুঁজুন'),
            Tab(text: 'আমার বুকিং ও সিরিয়াল'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDoctorBrowseTab(),
          _buildMyAppointmentsTab(),
        ],
      ),
    );
  }

  Widget _buildDoctorBrowseTab() {
    return Column(
      children: [
        // Specialties chips
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('সব স্পেশালিস্ট'),
                  selected: _selectedSpecialtyId == 0,
                  onSelected: (val) {
                    setState(() => _selectedSpecialtyId = 0);
                    _loadData();
                  },
                ),
                const SizedBox(width: 8),
                ..._specialties.map((cat) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(cat.name),
                    selected: _selectedSpecialtyId == cat.id,
                    onSelected: (val) {
                      setState(() => _selectedSpecialtyId = cat.id);
                      _loadData();
                    },
                  ),
                )),
              ],
            ),
          ),
        ),

        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _doctors.isEmpty
                  ? const Center(child: Text('কোনো ডাক্তার পাওয়া যায়নি'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _doctors.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final doc = _doctors[index];
                        return _buildDoctorCard(doc);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildDoctorCard(BusinessItem doc) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  doc.logo ?? 'https://images.unsplash.com/photo-1622253692010-333f2da6031d?w=300',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 80,
                    height: 80,
                    color: AppColors.primaryLight,
                    child: const Icon(Icons.person, color: AppColors.primary, size: 36),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doc.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      doc.specialtyName ?? 'Internal Medicine',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.primary),
                    ),
                    if (doc.degrees != null)
                      Text(
                        doc.degrees!,
                        style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                        const SizedBox(width: 2),
                        Text('${doc.rating}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                        const SizedBox(width: 8),
                        Text(
                          '${doc.reviewsCount} রোগী',
                          style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('পরামর্শ ফি (হাসপাতালে প্রদেয়)', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                  Text(
                    '৳ ${doc.consultationFee}',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _openDoctorDetail(doc),
                icon: const Icon(Icons.calendar_month_rounded, size: 14),
                label: const Text('চেম্বার ও সিরিয়াল নিন', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMyAppointmentsTab() {
    if (_isLoadingAppointments) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_myAppointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.calendar_today_rounded, size: 48, color: AppColors.textMuted),
            const SizedBox(height: 12),
            const Text('আপনার কোনো অ্যাপয়েন্টমেন্ট বুকিং নেই', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text('ডাক্তার তালিকা থেকে আপনার সুবিধাজনক স্লট বুক করুন', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _tabController.animateTo(0),
              child: const Text('ডাক্তার খুঁজুন'),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _myAppointments.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final apt = _myAppointments[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      apt.bookingCode,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.primaryDark),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: apt.status == 'confirmed' ? const Color(0xFFECFDF5) : const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      apt.status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: apt.status == 'confirmed' ? const Color(0xFF065F46) : const Color(0xFF92400E),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                apt.doctorName ?? 'Specialist Doctor',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 2),
              Text(
                apt.chamberName ?? 'Hospital Chamber',
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.event_rounded, size: 14, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(apt.date, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 14),
                  const Icon(Icons.access_time_rounded, size: 14, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(apt.slotTime, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'সিরিয়াল নাম্বার: #${apt.serialNo}',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: AppColors.primary),
                    ),
                    Text(
                      'ভিজিট: ৳${apt.fee} (ক্লিনিকে দিন)',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Bottom Sheet for Doctor Chambers, Slot Selection & Booking
class _DoctorDetailSheet extends StatefulWidget {
  final BusinessItem doctor;
  final VoidCallback onBookingComplete;

  const _DoctorDetailSheet({required this.doctor, required this.onBookingComplete});

  @override
  State<_DoctorDetailSheet> createState() => _DoctorDetailSheetState();
}

class _DoctorDetailSheetState extends State<_DoctorDetailSheet> {
  BusinessItem? _fullDoctor;
  ChamberItem? _selectedChamber;
  List<TimeSlotItem> _slots = [];
  String? _selectedSlot;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  bool _isLoadingSlots = false;

  final _patientNameController = TextEditingController(text: 'Tanvir Ahmed');
  final _patientPhoneController = TextEditingController(text: '01833333333');
  final _patientAgeController = TextEditingController(text: '32');
  final String _patientGender = 'Male';
  final _problemController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    final doc = await ApiService.getBusinessDetail(widget.doctor.id);
    if (mounted) {
      setState(() {
        _fullDoctor = doc ?? widget.doctor;
        if (_fullDoctor!.chambers.isNotEmpty) {
          _selectedChamber = _fullDoctor!.chambers.first;
          _fetchSlots();
        }
      });
    }
  }

  Future<void> _fetchSlots() async {
    if (_selectedChamber == null) return;
    setState(() => _isLoadingSlots = true);
    final dateStr = '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';
    final slots = await ApiService.getDoctorSlots(widget.doctor.id, _selectedChamber!.id, dateStr);
    if (mounted) {
      setState(() {
        _slots = slots;
        _isLoadingSlots = false;
        _selectedSlot = slots.firstWhere((s) => s.available, orElse: () => slots.first).time;
      });
    }
  }

  Future<void> _submitBooking() async {
    if (_selectedChamber == null || _selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select chamber and slot')));
      return;
    }

    setState(() => _isSubmitting = true);
    final dateStr = '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';
    
    final res = await ApiService.bookAppointment(
      businessId: widget.doctor.id,
      chamberId: _selectedChamber!.id,
      date: dateStr,
      slotTime: _selectedSlot!,
      patientName: _patientNameController.text.trim(),
      patientPhone: _patientPhoneController.text.trim(),
      patientAge: int.tryParse(_patientAgeController.text) ?? 30,
      patientGender: _patientGender,
      problem: _problemController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (res['success'] == true) {
      Navigator.pop(context);
      widget.onBookingComplete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.primary,
          content: Text('অ্যাপয়েন্টমেন্ট বুকিং সফল! সিরিয়াল #${res['appointment']['serial_no']} • কোড: ${res['appointment']['booking_code']}'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Booking failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('অ্যাপয়েন্টমেন্ট বুকিং ফরম', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Doctor Info
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          widget.doctor.logo ?? 'https://images.unsplash.com/photo-1622253692010-333f2da6031d?w=200',
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.doctor.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            Text(widget.doctor.specialtyName ?? '', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 11)),
                            Text('ভিজিট: ৳${widget.doctor.consultationFee} (Pay at clinic)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  const Text('চেম্বার নির্বাচন করুন *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  if (_fullDoctor != null && _fullDoctor!.chambers.isNotEmpty)
                    ..._fullDoctor!.chambers.map((ch) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: _selectedChamber?.id == ch.id ? AppColors.primary : AppColors.cardBorder, width: _selectedChamber?.id == ch.id ? 2 : 1),
                        borderRadius: BorderRadius.circular(12),
                        color: _selectedChamber?.id == ch.id ? AppColors.primaryLight.withOpacity(0.3) : Colors.white,
                      ),
                      child: ListTile(
                        onTap: () {
                          setState(() => _selectedChamber = ch);
                          _fetchSlots();
                        },
                        title: Text(ch.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        subtitle: Text('${ch.address} • ${ch.visitingTime}', style: const TextStyle(fontSize: 10)),
                        trailing: _selectedChamber?.id == ch.id ? const Icon(Icons.check_circle, color: AppColors.primary) : null,
                      ),
                    )),

                  const SizedBox(height: 16),
                  const Text('স্লট ও সময় নির্বাচন করুন *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  if (_isLoadingSlots)
                    const Center(child: Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator()))
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _slots.map((s) {
                        final isSelected = _selectedSlot == s.time;
                        return ChoiceChip(
                          label: Text(s.time, style: TextStyle(fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                          selected: isSelected,
                          onSelected: s.available ? (val) => setState(() => _selectedSlot = s.time) : null,
                        );
                      }).toList(),
                    ),

                  const SizedBox(height: 20),
                  const Text('রোগীর তথ্য', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _patientNameController,
                    decoration: const InputDecoration(labelText: 'রোগীর পুরো নাম *'),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _patientPhoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(labelText: 'যোগাযোগের মোবাইল *'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 80,
                        child: TextField(
                          controller: _patientAgeController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'বয়স'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _problemController,
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: 'সমস্যার বিবরণ (ঐচ্ছিক)'),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitBooking,
                child: _isSubmitting ? const CircularProgressIndicator(color: Colors.white) : const Text('সিরিয়াল নিশ্চিত করুন (Pay at Clinic)'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
