import 'package:flutter_riverpod/legacy.dart';
import '../controllers/sign_up_notifier.dart';
import '../models/sign_up.dart';

final signupProvider =
StateNotifierProvider<SignUpNotifier, SignUpData>(
      (ref) => SignUpNotifier(),
);