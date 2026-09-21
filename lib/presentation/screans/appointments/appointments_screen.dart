import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/appointment_list_item_model.dart';
import '../../../l10n/l10n.dart';
import '../../../logic/blocs/my_appointments/my_appointments_bloc.dart';
import '../../../logic/blocs/my_appointments/my_appointments_event.dart';
import '../../../logic/blocs/my_appointments/my_appointments_state.dart';
import '../../display_format.dart';
import '../../widgets/app_card.dart';
import '../../widgets/content_constraint.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/error_state_view.dart';
import '../../widgets/motion.dart';
import '../../widgets/skeleton.dart';
import '../../widgets/status_chip.dart';

/// Uses the app-level MyAppointmentsBloc (main.dart). Loads on open;
/// a successful booking refreshes the same bloc, so the tab instance
/// living in the home IndexedStack is never stale.
class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<MyAppointmentsBloc>().add(const MyAppointmentsStarted());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.myAppointment)),
      body: ContentConstraint(
        child: BlocBuilder<MyAppointmentsBloc, MyAppointmentsState>(
          builder: (context, state) =>
              StateSwitcher(child: _body(context, state)),
        ),
      ),
    );
  }

  Widget _body(BuildContext context, MyAppointmentsState state) {
    final l10n = context.l10n;
    if (state is MyAppointmentsLoading) {
      return const SkeletonList(itemCount: 4);
    }
    if (state is MyAppointmentsError) {
      return ErrorStateView(
        error: state.error,
        onRetry: () => context
            .read<MyAppointmentsBloc>()
            .add(const MyAppointmentsStarted()),
      );
    }
    final loaded = state as MyAppointmentsLoaded;
    if (loaded.appointments.isEmpty) {
      // Point at the doctor list: booking starts from a doctor.
      return EmptyStateView(
          message: l10n.noAppointmentsYet,
          icon: Icons.calendar_today_outlined,
          actionLabel: l10n.browseDoctors,
          onAction: () => Navigator.pushNamed(context, AppRoutes.doctorList));
    }
    return RefreshIndicator(
      onRefresh: () async =>
          context.read<MyAppointmentsBloc>().add(const MyAppointmentsStarted()),
      child: ListView.builder(
        padding: const EdgeInsets.all(AppDimensions.spaceLg),
        itemCount: loaded.appointments.length,
        itemBuilder: (context, i) => FadeIn(
          delay: Duration(milliseconds: 40 * (i < 5 ? i : 5)),
          child: _AppointmentCard(appointment: loaded.appointments[i]),
        ),
      ),
    );
  }
}

/// One appointment: doctor first, specialty second, then a clearly
/// readable date/time row; the status pill stays visible but small.
class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({required this.appointment});

  final AppointmentListItemModel appointment;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final a = appointment;
    final status = a.status?.trim();
    final isPending = status != null && status.toLowerCase() == 'pending';
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppDimensions.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                child: a.doctorImageUrl != null
                    ? Image.network(a.doctorImageUrl!,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholder(context))
                    : _placeholder(context),
              ),
              const SizedBox(width: AppDimensions.spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a.doctorName ?? l10n.doctorFallbackName,
                        style: AppTextStyles.bodyLarge
                            .copyWith(fontWeight: FontWeight.w700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    if (a.specialization != null) ...[
                      const SizedBox(height: 2),
                      Text(a.specialization!,
                          style: context.textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ],
                ),
              ),
              if (status != null && status.isNotEmpty) ...[
                const SizedBox(width: AppDimensions.spaceSm),
                // Only "pending" is a known value (localized + tinted);
                // anything else is shown verbatim in a neutral tone.
                // Flexible: a long status ellipsizes instead of pushing
                // the row past the card edge on narrow screens.
                Flexible(
                  child: StatusChip(
                    label: formatAppointmentStatus(l10n, status),
                    icon: isPending ? Icons.schedule_rounded : null,
                    color: isPending ? palette.primary : palette.textSecondary,
                  ),
                ),
              ],
            ],
          ),
          if (a.appointmentTime != null || a.price != null) ...[
            const SizedBox(height: AppDimensions.spaceMd),
            Divider(height: 1, color: palette.divider),
            const SizedBox(height: AppDimensions.spaceSm + 2),
          ],
          if (a.appointmentTime != null)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.calendar_today_outlined,
                    size: AppDimensions.iconMd, color: palette.primary),
                const SizedBox(width: AppDimensions.spaceSm),
                Expanded(
                  // Localized date · time when the server string is
                  // understood; otherwise the raw server value.
                  child: Text(
                      formatAppointmentTime(context, a.appointmentTime!),
                      style: AppTextStyles.bodyMedium
                          .copyWith(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          if (a.price != null) ...[
            const SizedBox(height: AppDimensions.spaceSm),
            Row(
              children: [
                Icon(Icons.payments_outlined,
                    size: AppDimensions.iconMd, color: palette.textSecondary),
                const SizedBox(width: AppDimensions.spaceSm),
                Text(formatPrice(a.price!),
                    style: AppTextStyles.bodySmall.copyWith(
                        color: palette.textPrimary,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _placeholder(BuildContext context) => Container(
        width: 56,
        height: 56,
        color: context.palette.inputFill,
        child: Icon(Icons.person, color: context.palette.textHint, size: 24),
      );
}
