import 'package:flutter/material.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../l10n/l10n.dart';
import '../../widgets/app_card.dart';
import '../../widgets/content_constraint.dart';
import '../../widgets/settings_tiles.dart';

/// UI-only — device security toggles, local widget state only; the
/// screen says so.
class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});
  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  bool _rememberPassword = true, _faceId = false, _pin = true;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.security)),
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
                      title: Text(l10n.rememberPassword),
                      value: _rememberPassword,
                      onChanged: (v) => setState(() => _rememberPassword = v)),
                  SwitchListTile(
                      title: Text(l10n.faceId),
                      value: _faceId,
                      onChanged: (v) => setState(() => _faceId = v)),
                  SwitchListTile(
                      title: Text(l10n.pin),
                      value: _pin,
                      onChanged: (v) => setState(() => _pin = v)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
