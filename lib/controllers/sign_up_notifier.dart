import 'package:flutter_riverpod/legacy.dart';
import 'package:lamaa/models/sign_up.dart';
import '../enums/gender.dart';
import '../enums/role.dart';

class SignUpNotifier extends StateNotifier<SignUpData> {
  SignUpNotifier() : super(SignUpData.empty());

  void updateEmail(String email) {
    state = state.copyWith(email: email);
  }

  void updatePassword(String password) {
    state = state.copyWith(password: password);
  }

  void updatePhone(String phone) {
    state = state.copyWith(phone: phone);
  }

  void updateGender(Gender gender) {
    state = state.copyWith(gender: gender);
  }

  void updateRole(Role role) {
    state = state.copyWith(role: role);
  }

  void reset() {
    state = SignUpData.empty();
  }
}
