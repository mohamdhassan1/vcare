import 'package:flutter/material.dart';
import '../../../core/theme/app_dimensions.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});
  static const _faqs = [
    (
      'What should I expect during a doctor\'s appointment?',
      'Your doctor will review your symptoms and history, then advise next steps.'
    ),
    (
      'How do I make an appointment with a doctor?',
      'Search or browse doctors, open their profile, and tap Book Appointment.'
    ),
    (
      'How long will my doctor\'s appointment take?',
      'Typical appointments run 20–30 minutes.'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FAQ')),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.spaceLg),
        children: _faqs
            .map((f) => ExpansionTile(title: Text(f.$1), children: [
                  Padding(
                      padding: const EdgeInsets.all(AppDimensions.spaceMd),
                      child: Text(f.$2))
                ]))
            .toList(),
      ),
    );
  }
}
