import 'package:flutter/material.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../l10n/l10n.dart';
import '../../widgets/app_card.dart';
import '../../widgets/content_constraint.dart';
import '../../widgets/settings_tiles.dart';

/// UI-only — toggles are local widget state, not persisted (no
/// notification-preferences API exists); the screen says so.
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});
  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _fromDoctor = true,
      _sound = true,
      _vibrate = true,
      _specialOffers = true;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.notifications)),
      body: ContentConstraint(
        child: ListView(
          padding: const EdgeInsets.all(AppDimensions.spaceLg),
          children: [
            const SampleContentNotice(),
            AppCard(
              padding:
                  const EdgeInsets.symmetric(vertical: AppDimensions.spaceXs),
              child: Column(
                children: [
                  SwitchListTile(
                      title: Text(l10n.notificationFromDoctor),
                      value: _fromDoctor,
                      onChanged: (v) => setState(() => _fromDoctor = v)),
                  SwitchListTile(
                      title: Text(l10n.sound),
                      value: _sound,
                      onChanged: (v) => setState(() => _sound = v)),
                  SwitchListTile(
                      title: Text(l10n.vibrate),
                      value: _vibrate,
                      onChanged: (v) => setState(() => _vibrate = v)),
                  SwitchListTile(
                      title: Text(l10n.specialOffers),
                      value: _specialOffers,
                      onChanged: (v) => setState(() => _specialOffers = v)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
