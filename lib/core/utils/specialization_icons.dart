import 'package:flutter/material.dart';

/// Maps a specialization name to a representative Material icon.
///
/// This exists because neither the VCare API nor the available Figma
/// export provides individual specialization icon assets (confirmed
/// by direct inspection — see Phase 12 audit). This is a local UI
/// decision, not fabricated data: the specialization name itself is
/// always the real one from the API; only the icon is a visual aid.
/// Falls back to a generic medical icon for any unmapped name.
class SpecializationIcons {
  SpecializationIcons._();

  static IconData iconFor(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('cardio')) return Icons.favorite_rounded;
    if (lower.contains('neuro')) return Icons.psychology_alt_rounded;
    if (lower.contains('pediatric')) return Icons.child_care_rounded;
    if (lower.contains('dermat')) return Icons.face_retouching_natural_rounded;
    if (lower.contains('ortho')) return Icons.accessibility_new_rounded;
    if (lower.contains('gynec')) return Icons.pregnant_woman_rounded;
    if (lower.contains('ophthalmo') || lower.contains('optom')) {
      return Icons.remove_red_eye_rounded;
    }
    if (lower.contains('urol')) return Icons.water_drop_rounded;
    if (lower.contains('gastro')) return Icons.medical_information_rounded;
    if (lower.contains('psychiat')) return Icons.self_improvement_rounded;
    if (lower.contains('dent')) return Icons.medical_services_rounded;
    if (lower.contains('ent') ||
        lower.contains('nose') ||
        lower.contains('throat')) {
      return Icons.hearing_rounded;
    }
    return Icons.medical_services_outlined;
  }
}
