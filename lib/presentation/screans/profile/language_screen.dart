// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/locale/locale_controller.dart';
import '../../../core/theme/app_dimensions.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});
  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  late String _selected = context.read<LocaleController>().value.languageCode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Language')),
      body: Column(children: [
        Expanded(
            child: ListView(children: [
          RadioListTile<String>(
              title: const Text('English'),
              value: 'en',
              groupValue: _selected,
              onChanged: (v) => setState(() => _selected = v!)),
          RadioListTile<String>(
              title: const Text('العربية'),
              value: 'ar',
              groupValue: _selected,
              onChanged: (v) => setState(() => _selected = v!)),
        ])),
        Padding(
          padding: const EdgeInsets.all(AppDimensions.spaceLg),
          child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await context
                      .read<LocaleController>()
                      .setLocale(Locale(_selected));
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Save'),
              )),
        ),
      ]),
    );
  }
}
