import 'package:flutter/services.dart';

class HapticService {
  static bool enabled = true;

  static void lightImpact() {
    if (!enabled) return;
    HapticFeedback.lightImpact().catchError((_) {});
  }

  static void mediumImpact() {
    if (!enabled) return;
    HapticFeedback.mediumImpact().catchError((_) {});
  }

  static void heavyImpact() {
    if (!enabled) return;
    HapticFeedback.heavyImpact().catchError((_) {});
  }

  static void selectionClick() {
    if (!enabled) return;
    HapticFeedback.selectionClick().catchError((_) {});
  }
}
