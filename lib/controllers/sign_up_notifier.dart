import 'package:flutter_riverpod/legacy.dart';
import 'package:lamaa/models/sign_up.dart';
import '../enums/gender.dart';
import '../enums/role.dart';

class SignUpNotifier extends StateNotifier<SignUpData> {
  SignUpNotifier() : super(SignUpData.empty());

  void updateEmail(String email) {
    state = state.copyWith(email: email);
  }

  void updateFname(String name) {
    state = state.copyWith(fName: name);
  }
  void updasteSecondName(String name) {
    state = state.copyWith(lName: name);
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

  void updateUserId(String userId) {
    state = state.copyWith(userId: userId);
  }

  // void updateServices(String newService){
  //   final currentService = state.services;

  //   if (currentService.contains(newService)) return;

  //   final updatedServices = [...currentService, newService];

  //   state = state.copyWith(services: updatedServices);
  // }

  void updateServicePrice(String servicePrice){
    state = state.copyWith(servicePrice: servicePrice);
  }

  void updateEstServiceTime(String estServiceTime){
    state = state.copyWith(estServiceTime: estServiceTime);
  }

  void updateServiceDesc(String serviceDesc){
    state = state.copyWith(serviceDesc: serviceDesc);
  }

  void reset() {
    state = SignUpData.empty();
  }
}
