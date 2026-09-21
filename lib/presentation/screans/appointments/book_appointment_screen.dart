import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/appointment_slots.dart';
import '../../../data/repositories/appointment_repository.dart';
import '../../../l10n/l10n.dart';
import '../../../logic/blocs/book_appointment/book_appointment_bloc.dart';
import '../../../logic/blocs/book_appointment/book_appointment_event.dart';
import '../../../logic/blocs/book_appointment/book_appointment_state.dart';
import '../../../logic/blocs/my_appointments/my_appointments_bloc.dart';
import '../../../logic/blocs/my_appointments/my_appointments_event.dart';
import '../../display_format.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_snack_bar.dart';
import '../../widgets/content_constraint.dart';
import '../../widgets/motion.dart';
import '../../widgets/primary_button.dart';

/// Booking screen. Dates and time slots come from
/// [AppointmentSlots] — a LOCAL FALLBACK, because no availability API
/// exists to query real free slots (see that file). The submission
/// itself is a real POST /appointment/store call; if a slot is
/// actually taken, the server's own validation error surfaces
/// honestly.
class BookAppointmentScreen extends StatefulWidget {
  const BookAppointmentScreen(
      {super.key, required this.doctorId, required this.doctorName});

  final int doctorId;
  final String doctorName;

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  // Computed once when the screen opens (not on every rebuild), so the
  // strip and the selection can't drift apart if midnight passes.
  late final List<DateTime> _dates = AppointmentSlots.fallbackDates();
  late DateTime _selectedDate = _dates.first;
  String? _selectedSlot;
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (_selectedSlot == null) {
      AppSnackBar.show(context, context.l10n.pleaseSelectTimeSlot);
      return;
    }
    final dateTime = AppointmentSlots.combine(_selectedDate, _selectedSlot!);
    context.read<BookAppointmentBloc>().add(BookAppointmentSubmitted(
          doctorId: widget.doctorId,
          dateTime: dateTime,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        ));
  }

  /// The summary grows in once a slot is chosen. Under reduced motion the
  /// child is placed directly (AnimatedSize cannot run a zero-length
  /// animation inside layout).
  Widget _summarySlot(BuildContext context, DateTime? selectedDateTime) {
    final child = selectedDateTime == null
        ? const SizedBox(width: double.infinity)
        : Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.spaceLg),
            child: _BookingSummary(
                doctorName: widget.doctorName, dateTime: selectedDateTime),
          );
    if (context.reduceMotion) return child;
    return AnimatedSize(
      duration: AppDurations.normal,
      curve: Curves.easeOut,
      alignment: Alignment.topCenter,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocProvider(
      create: (context) =>
          BookAppointmentBloc(context.read<AppointmentRepository>()),
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.bookAppointment)),
        body: BlocConsumer<BookAppointmentBloc, BookAppointmentState>(
          listener: (context, state) {
            if (state is BookAppointmentSuccess) {
              // The server confirmed the booking: refresh the shared
              // appointments list from the backend so My Appointments
              // shows it (the tab in the home shell is never rebuilt).
              // If that refresh fails, the list's own error + Retry
              // handles it — nothing is fabricated locally.
              context
                  .read<MyAppointmentsBloc>()
                  .add(const MyAppointmentsStarted());
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (dialogContext) => BookingSuccessDialog(
                  // Doctor name, time and status are backend values
                  // shown as-is inside the localized sentence.
                  message: state.appointmentTime != null
                      ? l10n.bookingScheduledMessage(
                          widget.doctorName,
                          state.appointmentTime!,
                          state.status ?? l10n.statusPending)
                      : l10n.bookingRequestedMessage(widget.doctorName),
                  onDone: () {
                    Navigator.of(dialogContext).pop();
                    Navigator.of(context).pop();
                  },
                  onViewAppointments: () {
                    Navigator.of(dialogContext).pop();
                    Navigator.of(context).pop();
                    // Existing named route — the same list the tab shows.
                    Navigator.of(context).pushNamed(AppRoutes.myAppointments);
                  },
                ),
              );
            } else if (state is BookAppointmentFailure) {
              AppSnackBar.error(context, context.errorText(state.error));
            }
          },
          builder: (context, state) {
            final isSubmitting = state is BookAppointmentSubmitting;
            final selectedDateTime = _selectedSlot == null
                ? null
                : AppointmentSlots.combine(_selectedDate, _selectedSlot!);
            return ContentConstraint(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.spaceLg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.bookingWith, style: context.textTheme.bodySmall),
                    Text(widget.doctorName, style: AppTextStyles.h3),
                    const SizedBox(height: AppDimensions.spaceLg),

                    // Date: section title + month context + day strip.
                    Text(l10n.selectDate, style: AppTextStyles.h3),
                    const SizedBox(height: AppDimensions.spaceXs),
                    AnimatedSwitcher(
                      duration: context.motion(AppDurations.fast),
                      child: Text(
                        formatMonthYear(context, _selectedDate),
                        key: ValueKey(
                            '${_selectedDate.year}-${_selectedDate.month}'),
                        style: context.textTheme.bodySmall,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spaceSm),
                    SizedBox(
                      height: _DateTile.height,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _dates.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: AppDimensions.spaceSm),
                        itemBuilder: (context, i) {
                          final date = _dates[i];
                          return _DateTile(
                            date: date,
                            selected:
                                AppointmentSlots.isSameDay(date, _selectedDate),
                            onTap: () => setState(() => _selectedDate = date),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spaceLg),

                    // Neutral wording on purpose: these slots are a local
                    // fallback, not server-confirmed availability.
                    Text(l10n.selectTime, style: AppTextStyles.h3),
                    const SizedBox(height: AppDimensions.spaceSm),
                    Wrap(
                      spacing: AppDimensions.spaceSm,
                      runSpacing: AppDimensions.spaceSm,
                      children: AppointmentSlots.fallbackTimeSlots.map((slot) {
                        final selected = _selectedSlot == slot;
                        // The checkmark (M3 default) is the non-color cue.
                        return ChoiceChip(
                          label: Text(slot, textDirection: TextDirection.ltr),
                          selected: selected,
                          onSelected: (_) =>
                              setState(() => _selectedSlot = slot),
                          selectedColor: context.palette.primary,
                          checkmarkColor: context.palette.onPrimary,
                          labelStyle: AppTextStyles.bodySmall.copyWith(
                              color: selected
                                  ? context.palette.onPrimary
                                  : context.palette.textPrimary),
                          backgroundColor: context.palette.surface,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppDimensions.spaceSm),
                    // Honest caption: the clinic's real availability is
                    // only checked by the server when the booking is sent.
                    Text(l10n.slotsNotConfirmed,
                        style: context.textTheme.labelSmall),
                    const SizedBox(height: AppDimensions.spaceLg),

                    Text(l10n.notesOptional, style: AppTextStyles.h3),
                    const SizedBox(height: AppDimensions.spaceSm),
                    TextField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: InputDecoration(hintText: l10n.notesHint),
                    ),
                    const SizedBox(height: AppDimensions.spaceLg),

                    // What is about to be requested — only once a slot
                    // is chosen, so the card never shows a half-choice.
                    _summarySlot(context, selectedDateTime),
                    PrimaryButton(
                      label: l10n.confirmBooking,
                      isLoading: isSubmitting,
                      onPressed: () => _submit(context),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// One day in the strip: weekday + day number. Selected = filled tile,
/// bold number and a dot underneath (so it is not color alone), plus
/// semantics `selected` for screen readers.
class _DateTile extends StatelessWidget {
  const _DateTile(
      {required this.date, required this.selected, required this.onTap});

  static const double height = 76;

  final DateTime date;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final locale = Localizations.localeOf(context).toString();
    final onTile = selected ? palette.onPrimary : palette.textPrimary;
    return Semantics(
      button: true,
      selected: selected,
      label: DateFormat.yMMMMEEEEd(locale).format(date),
      child: ExcludeSemantics(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          child: AnimatedContainer(
            duration: context.motion(AppDurations.fast),
            width: 60,
            decoration: BoxDecoration(
              color: selected ? palette.primary : palette.surface,
              border: Border.all(
                  color: selected ? palette.primary : palette.cardBorder),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Abbreviated weekday in the active locale via intl.
                Text(DateFormat.E(locale).format(date),
                    style: AppTextStyles.caption.copyWith(
                        color: selected ? onTile : palette.textSecondary)),
                const SizedBox(height: 2),
                Text('${date.day}',
                    style: AppTextStyles.bodyLarge.copyWith(
                        color: onTile,
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w500)),
                const SizedBox(height: AppDimensions.spaceXs),
                AnimatedContainer(
                  duration: context.motion(AppDurations.fast),
                  width: selected ? 6 : 0,
                  height: 6,
                  decoration:
                      BoxDecoration(color: onTile, shape: BoxShape.circle),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Doctor · date · time of the request about to be sent.
class _BookingSummary extends StatelessWidget {
  const _BookingSummary({required this.doctorName, required this.dateTime});

  final String doctorName;
  final DateTime dateTime;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    Widget row(IconData icon, String label, String value) => Padding(
          padding: const EdgeInsets.only(top: AppDimensions.spaceSm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: AppDimensions.iconMd, color: palette.primary),
              const SizedBox(width: AppDimensions.spaceSm),
              SizedBox(
                width: 64,
                child: Text(label, style: context.textTheme.bodySmall),
              ),
              Expanded(
                child: Text(value,
                    style: AppTextStyles.bodyMedium
                        .copyWith(fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        );
    return FadeIn(
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.bookingSummaryTitle, style: AppTextStyles.h3),
            row(Icons.person_outline_rounded, l10n.doctorLabel, doctorName),
            row(Icons.calendar_today_outlined, l10n.dateLabel,
                formatLongDate(context, dateTime)),
            row(Icons.access_time_rounded, l10n.timeLabel,
                formatTime(context, dateTime)),
          ],
        ),
      ),
    );
  }
}

/// Success dialog: check icon scales/fades in (skipped under reduced
/// motion), the honest server-derived message, and two ways forward.
class BookingSuccessDialog extends StatelessWidget {
  const BookingSuccessDialog({
    super.key,
    required this.message,
    required this.onDone,
    required this.onViewAppointments,
  });

  final String message;
  final VoidCallback onDone;
  final VoidCallback onViewAppointments;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final icon = Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
          color: palette.success.withValues(alpha: 0.12),
          shape: BoxShape.circle),
      child: Icon(Icons.check_rounded,
          size: AppDimensions.iconXl - 12, color: palette.success),
    );
    return AlertDialog(
      icon: context.reduceMotion
          ? icon
          : TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.6, end: 1),
              duration: AppDurations.slow,
              curve: Curves.easeOutBack,
              child: icon,
              builder: (context, t, child) => Opacity(
                opacity: t.clamp(0, 1),
                child: Transform.scale(scale: t, child: child),
              ),
            ),
      title: Text(l10n.bookingConfirmed, textAlign: TextAlign.center),
      content: Text(message, textAlign: TextAlign.center),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          style: TextButton.styleFrom(
              minimumSize: const Size(0, AppDimensions.minTouchTarget)),
          onPressed: onDone,
          child: Text(l10n.done),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
              minimumSize: const Size(0, AppDimensions.minTouchTarget)),
          onPressed: onViewAppointments,
          child: Text(l10n.viewAppointments),
        ),
      ],
    );
  }
}
