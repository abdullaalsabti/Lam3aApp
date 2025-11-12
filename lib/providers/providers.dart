import 'package:flutter_riverpod/legacy.dart';
//import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamaa/enums/enums.dart';
import 'package:uuid/uuid.dart';

class SignUpData {
  final uuid = Uuid();
  final String email, password, phone, fName, lName, dob, addressBN, addressLandmark, userId;
  final Role role;
  final Gender gender;
  SignUpData({
    String? userId,
    this.role = Role.client,
    this.email = '',
    this.password = '',
    this.phone = '',
    this.fName = '',
    this.lName = '',
    this.dob = '',
    this.addressBN = '',
    this.addressLandmark = '',
    this.gender = Gender.male,
  }) : userId = userId ?? const Uuid().v4();

  SignUpData copyWith({
    Role? role,
    String? email,
    String? password,
    String? phone,
    String? fName,
    String? lName,
    String? dob,
    String? addressBn,
    String? addressLandmark,
    Gender? gender,
  }) {
    return SignUpData(
      role: role ?? this.role,
      email: email ?? this.email,
      password: password ?? this.password,
      phone: phone ?? this.phone,
      fName: fName ?? this.fName,
      lName: lName ?? this.lName,
      dob: dob ?? this.dob,
      addressBN: addressBn ?? addressBN, // Corrected: use local parameter 'addressBn'
      addressLandmark: addressLandmark ?? this.addressLandmark, // Corrected: use local parameter 'addressLandmark'
      gender: gender ?? this.gender, // Corrected: use local parameter 'gender'
    );
  }
}

final signupProvider = StateProvider<SignUpData>((ref) => SignUpData());
