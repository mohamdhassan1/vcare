import 'package:flutter/material.dart';
import '../../../core/theme/app_dimensions.dart';

/// UI-only — device security toggles, local widget state only.
class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});
  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  bool _rememberPassword = true, _faceId = false, _pin = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Security')),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.spaceLg),
        child: Column(
          children: [
            SwitchListTile(
                title: const Text('Remember password'),
                value: _rememberPassword,
                onChanged: (v) => setState(() => _rememberPassword = v)),
            SwitchListTile(
                title: const Text('Face ID'),
                value: _faceId,
                onChanged: (v) => setState(() => _faceId = v)),
            SwitchListTile(
                title: const Text('PIN'),
                value: _pin,
                onChanged: (v) => setState(() => _pin = v)),
          ],
        ),
      ),
    );
  }
}
