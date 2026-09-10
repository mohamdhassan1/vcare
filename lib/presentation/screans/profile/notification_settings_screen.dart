import 'package:flutter/material.dart';
import '../../../core/theme/app_dimensions.dart';

/// UI-only — toggles are local widget state, not persisted (no
/// notification-preferences API exists).
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
    return Scaffold(
      appBar: AppBar(title: const Text('Notification')),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.spaceLg),
        child: Column(
          children: [
            SwitchListTile(
                title: const Text('Notification from Doctor'),
                value: _fromDoctor,
                onChanged: (v) => setState(() => _fromDoctor = v)),
            SwitchListTile(
                title: const Text('Sound'),
                value: _sound,
                onChanged: (v) => setState(() => _sound = v)),
            SwitchListTile(
                title: const Text('Vibrate'),
                value: _vibrate,
                onChanged: (v) => setState(() => _vibrate = v)),
            SwitchListTile(
                title: const Text('Special Offers'),
                value: _specialOffers,
                onChanged: (v) => setState(() => _specialOffers = v)),
          ],
        ),
      ),
    );
  }
}
