import 'package:flutter/material.dart';
// import 'src/presentation/onboarding/onboarding_storage.dart';

import 'src/presentation/app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // final onboardingCompleted = await const OnboardingStorage().isCompleted();
  final onboardingCompleted = true;
  runApp(HiddenCameraDetectorApp(onboardingCompleted: onboardingCompleted));
}
