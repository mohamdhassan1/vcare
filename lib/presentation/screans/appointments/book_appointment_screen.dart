import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/repositories/appointment_repository.dart';
import '../../../logic/blocs/book_appointment/book_appointment_bloc.dart';
import '../../../logic/blocs/book_appointment/book_appointment_event.dart';
import '../../../logic/blocs/book_appointment/book_appointment_state.dart';

/// Booking screen. Time slots are a fixed local list (09:00–17:00) —
/// no availability API exists to query real free slots. The
/// submission itself is a real POST /appointment/store call; if a
/// slot is actually taken, the server's own validation error
/// surfaces honestly.
class BookAppointmentScreen extends StatefulWidget {
  const BookAppointmentScreen(
      {super.key, required this.doctorId, required this.doctorName});

  final int doctorId;
  final String doctorName;

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  late DateTime _selectedDate;
  String? _selectedSlot;
  final _notesController = TextEditingController();

  static const _slots = [
    '09:00',
    '10:00',
    '11:00',
    '12:00',
    '14:00',
    '15:00',
    '16:00',
    '17:00'
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now().add(const Duration(days: 1));
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (_selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a time slot.')));
      return;
    }
    final parts = _selectedSlot!.split(':');
    final dateTime = DateTime(_selectedDate.year, _selectedDate.month,
        _selectedDate.day, int.parse(parts[0]), int.parse(parts[1]));
    context.read<BookAppointmentBloc>().add(BookAppointmentSubmitted(
          doctorId: widget.doctorId,
          dateTime: dateTime,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          BookAppointmentBloc(context.read<AppointmentRepository>()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Book Appointment')),
        body: BlocConsumer<BookAppointmentBloc, BookAppointmentState>(
          listener: (context, state) {
            if (state is BookAppointmentSuccess) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Booking Confirmed'),
                  content: Text(
                    state.appointmentTime != null
                        ? 'Your appointment with ${widget.doctorName} is scheduled for ${state.appointmentTime}.\nStatus: ${state.status ?? "pending"}'
                        : 'Your appointment with ${widget.doctorName} has been requested.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        Navigator.of(context).pop();
                      },
                      child: const Text('Done'),
                    ),
                  ],
                ),
              );
            } else if (state is BookAppointmentFailure) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (context, state) {
            final isSubmitting = state is BookAppointmentSubmitting;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.spaceLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Booking with', style: AppTextStyles.bodySmall),
                  Text(widget.doctorName, style: AppTextStyles.h3),
                  const SizedBox(height: AppDimensions.spaceLg),
                  Text('Select Date', style: AppTextStyles.h3),
                  const SizedBox(height: AppDimensions.spaceSm),
                  SizedBox(
                    height: 72,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: 14,
                      separatorBuilder: (_, __) =>
                          const SizedBox(width: AppDimensions.spaceSm),
                      itemBuilder: (context, i) {
                        final date = DateTime.now().add(Duration(days: i + 1));
                        final selected = date.year == _selectedDate.year &&
                            date.month == _selectedDate.month &&
                            date.day == _selectedDate.day;
                        return InkWell(
                          onTap: () => setState(() => _selectedDate = date),
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusMd),
                          child: Container(
                            width: 56,
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.surface,
                              borderRadius:
                                  BorderRadius.circular(AppDimensions.radiusMd),
                            ),
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(_weekday(date.weekday),
                                    style: AppTextStyles.caption.copyWith(
                                        color: selected
                                            ? Colors.white
                                            : AppColors.textSecondary)),
                                Text('${date.day}',
                                    style: AppTextStyles.bodyLarge.copyWith(
                                        color: selected
                                            ? Colors.white
                                            : AppColors.textPrimary,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spaceLg),
                  Text('Available Time', style: AppTextStyles.h3),
                  const SizedBox(height: AppDimensions.spaceSm),
                  Wrap(
                    spacing: AppDimensions.spaceSm,
                    runSpacing: AppDimensions.spaceSm,
                    children: _slots.map((slot) {
                      final selected = _selectedSlot == slot;
                      return ChoiceChip(
                        label: Text(slot),
                        selected: selected,
                        onSelected: (_) => setState(() => _selectedSlot = slot),
                        selectedColor: AppColors.primary,
                        labelStyle: AppTextStyles.bodySmall.copyWith(
                            color: selected
                                ? Colors.white
                                : AppColors.textPrimary),
                        backgroundColor: AppColors.surface,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppDimensions.spaceLg),
                  Text('Notes (optional)', style: AppTextStyles.h3),
                  const SizedBox(height: AppDimensions.spaceSm),
                  TextField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                        hintText: 'Describe your symptoms or reason for visit'),
                  ),
                  const SizedBox(height: AppDimensions.spaceLg),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isSubmitting ? null : () => _submit(context),
                      child: isSubmitting
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2.5, color: Colors.white))
                          : const Text('Confirm Booking'),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _weekday(int day) =>
      const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][day - 1];
}
