import 'package:lamaa/enums/role.dart';
import 'package:lamaa/enums/gender.dart';
import 'package:lamaa/models/provider_service.dart';
import 'package:uuid/uuid.dart';

class SignUpData {
  final String userId;
  final String email;
  final String password;
  final String phone;
  final String fName;
  final String lName;
  final String dob;
  final String addressBN;
  final String addressLandmark;
  final Role role;
  final Gender gender;
  final List<ProviderService> services;
  final String servicePrice;
  final String estServiceTime;
  final String serviceDesc;

  const SignUpData({
    required this.userId,
    required this.role,
    required this.email,
    required this.password,
    required this.phone,
    required this.fName,
    required this.lName,
    required this.dob,
    required this.addressBN,
    required this.addressLandmark,
    required this.gender,
    required this.services,
    required this.servicePrice,
    required this.estServiceTime,
    required this.serviceDesc,
  });

  factory SignUpData.empty() {
    return SignUpData(
      userId: const Uuid().v4(),
      role: Role.client,
      email: '',
      password: '',
      phone: '',
      fName: '',
      lName: '',
      dob: '',
      addressBN: '',
      addressLandmark: '',
      gender: Gender.male,
      services: [],
      servicePrice: '',
      estServiceTime: '',
      serviceDesc: '',
    );
  }

  SignUpData copyWith({
    String? userId,
    String? email,
    String? password,
    String? phone,
    String? fName,
    String? lName,
    String? dob,
    String? addressBN,
    String? addressLandmark,
    Role? role,
    Gender? gender,
    List<ProviderService>? services,
    String? servicePrice,
    String? estServiceTime,
    String? serviceDesc,
  }) {
    return SignUpData(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      password: password ?? this.password,
      phone: phone ?? this.phone,
      fName: fName ?? this.fName,
      lName: lName ?? this.lName,
      dob: dob ?? this.dob,
      addressBN: addressBN ?? this.addressBN,
      addressLandmark: addressLandmark ?? this.addressLandmark,
      role: role ?? this.role,
      gender: gender ?? this.gender,
      services: services ?? List.from(this.services), // dpep copy now shallow copy
      servicePrice: servicePrice ?? this.servicePrice,
      estServiceTime: estServiceTime ?? this.estServiceTime,
      serviceDesc: serviceDesc ?? this.serviceDesc,
    );
  }
}
