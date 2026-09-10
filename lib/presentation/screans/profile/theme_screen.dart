// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme_controller.dart';

class ThemeScreen extends StatelessWidget {
  const ThemeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ThemeController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Theme')),
      body: Column(children: [
        RadioListTile<ThemeMode>(
            title: const Text('Light'),
            value: ThemeMode.light,
            groupValue: controller.value,
            onChanged: (m) => controller.setThemeMode(m!)),
        RadioListTile<ThemeMode>(
            title: const Text('Dark'),
            value: ThemeMode.dark,
            groupValue: controller.value,
            onChanged: (m) => controller.setThemeMode(m!)),
        RadioListTile<ThemeMode>(
            title: const Text('System Default'),
            value: ThemeMode.system,
            groupValue: controller.value,
            onChanged: (m) => controller.setThemeMode(m!)),
      ]),
    );
  }
}
