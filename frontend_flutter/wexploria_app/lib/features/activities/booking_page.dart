import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/models/activite.dart';
import '../../core/services/reservation_service.dart';
import '../../features/auth/auth_service.dart';
import '../../core/models/reservation.dart';
import 'package:uuid/uuid.dart';

class BookingPage extends StatefulWidget {
  final Activite activite;

  const BookingPage({super.key, required this.activite});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final ReservationService _reservationService = ReservationService();
  final AuthService _authService = AuthService();

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String? _selectedTime;
  int _guestCount = 2;
  bool _isLoading = false;

  final List<String> _availableSlots = ['09:00 AM', '02:00 PM', '05:00 PM'];
  final Uuid _uuid = const Uuid();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Confirm Booking',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildActivityHeader(),
            const SizedBox(height: AppSpacing.xl),

            _buildSectionTitle('Select Date'),
            const SizedBox(height: AppSpacing.md),
            _buildDateSelector(),
            const SizedBox(height: AppSpacing.lg),

            _buildSectionTitle('Available Slots'),
            const SizedBox(height: AppSpacing.md),
            _buildTimeSlots(),
            const SizedBox(height: AppSpacing.xl),

            _buildGuestsSection(),
            const SizedBox(height: AppSpacing.xl),

            _buildPromoCode(),
            const SizedBox(height: AppSpacing.xl),

            _buildBookingSummary(),
            const SizedBox(height: AppSpacing.xl),

            _buildPaymentMethod(),
            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildActivityHeader() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        image: DecorationImage(
          image: NetworkImage(
            'https://picsum.photos/seed/${widget.activite.id}/800/400',
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              gradient: LinearGradient(
                colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
          Positioned(
            bottom: AppSpacing.md,
            left: AppSpacing.md,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    widget.activite.typeActivite.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.activite.titre,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Serif',
                  ),
                ),
                Text(
                  widget.activite.localisationPrecise,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        fontFamily: 'Serif',
      ),
    );
  }

  Widget _buildDateSelector() {
    // Simplified horizontal calendar
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 14,
        itemBuilder: (context, index) {
          final date = DateTime.now().add(Duration(days: index));
          final isSelected =
              date.day == _selectedDate.day &&
              date.month == _selectedDate.month;
          return GestureDetector(
            onTap: () => setState(() => _selectedDate = date),
            child: Container(
              width: 60,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? Colors.transparent : Colors.grey.shade200,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _getWeekday(date),
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textLight,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _getWeekday(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  Widget _buildTimeSlots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: _availableSlots.map((slot) {
        final isSelected = _selectedTime == slot;
        return GestureDetector(
          onTap: () => setState(() => _selectedTime = slot),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.success : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? Colors.transparent : Colors.grey.shade300,
              ),
            ),
            child: Text(
              slot,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGuestsSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Guests',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                'Age 12+',
                style: TextStyle(color: AppColors.textLight, fontSize: 12),
              ),
            ],
          ),
          Row(
            children: [
              _buildGuestButton(
                icon: Icons.remove,
                onTap: () {
                  if (_guestCount > 1) {
                    setState(() => _guestCount--);
                  }
                },
              ),
              const SizedBox(width: 16),
              Text(
                _guestCount.toString(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 16),
              _buildGuestButton(
                icon: Icons.add,
                isPrimary: true,
                onTap: () {
                  if (_guestCount < widget.activite.capaciteMax) {
                    setState(() => _guestCount++);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGuestButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.secondary : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isPrimary ? Colors.white : Colors.black,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildPromoCode() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.confirmation_number_outlined,
            color: AppColors.textLight,
          ),
          const SizedBox(width: AppSpacing.md),
          const Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Have a promo code?',
                border: InputBorder.none,
              ),
            ),
          ),
          TextButton(
            onPressed: () {},
            child: const Text(
              'Apply',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingSummary() {
    double subtotal = widget.activite.prixBase * _guestCount;
    double serviceFee = 5.00;
    double discount = 0; // Logic for promo could go here
    double total = subtotal + serviceFee - discount;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Booking Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Serif',
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildSummaryRow('${widget.activite.titre} x $_guestCount', subtotal),
          const SizedBox(height: 8),
          _buildSummaryRow('Service Fee', serviceFee),
          const SizedBox(height: 8),
          _buildSummaryRow('Discount', -discount, isDiscount: true),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Divider(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                '€${total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    double amount, {
    bool isDiscount = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary)),
        Text(
          '${isDiscount ? '-' : ''}€${amount.abs().toStringAsFixed(2)}',
          style: TextStyle(
            color: isDiscount ? AppColors.success : Colors.black,
            fontWeight: isDiscount ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethod() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.payment,
              color: AppColors.primary,
            ), // Placeholder
          ),
          const SizedBox(width: AppSpacing.md),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Apple Pay / Credit Card',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Secured by Stripe',
                style: TextStyle(color: AppColors.textLight, fontSize: 12),
              ),
            ],
          ),
          const Spacer(),
          Radio(
            value: true,
            groupValue: true,
            onChanged: (v) {},
            activeColor: AppColors.secondary,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    double total = widget.activite.prixBase * _guestCount + 5.00;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total Price',
                style: TextStyle(color: AppColors.textLight, fontSize: 12),
              ),
              Text(
                '€${total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: ElevatedButton(
              onPressed: _isLoading ? null : _confirmBooking,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success, // Green color
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Confirm & Pay',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, size: 20),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmBooking() async {
    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a time slot.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = _authService.currentUser;
      if (user == null) {
        throw Exception("You must be logged in to book.");
      }

      // Calculate datetime from selected date + time slot
      // Simplified parsing for "09:00 AM" etc.
      final timeParts = _selectedTime!.split(' '); // ["09:00", "AM"]
      final hourMin = timeParts[0].split(':');
      int hour = int.parse(hourMin[0]);
      int minute = int.parse(hourMin[1]);
      if (timeParts[1] == 'PM' && hour != 12) hour += 12;
      if (timeParts[1] == 'AM' && hour == 12) hour = 0;

      final activityDate = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        hour,
        minute,
      );

      final total = widget.activite.prixBase * _guestCount + 5.00;

      final reservation = Reservation(
        id: _uuid.v4(),
        dateReservation: DateTime.now(),
        dateActivite: activityDate,
        dureeReservation: widget.activite.dureeEstimee,
        nombreParticipants: _guestCount,
        prixTotal: total,
        clientId: user.id,
        activiteId: widget.activite.id,
        piloteId: widget.activite.operateurId, // Should rely on Activite
        createdAt: DateTime.now(),
        statut: 'confirmee', // Assuming immediate confirmation for this demo
      );

      await _reservationService.createReservation(reservation);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking Confirmed!'),
            backgroundColor: AppColors.success,
          ),
        );
        // Navigate back to home or bookings tab
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
