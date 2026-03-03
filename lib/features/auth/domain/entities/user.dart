import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String? name;
  final String? avatarUrl;
  final String? clinicName;
  final String? specialty;
  final String? licenseNumber;
  final String? phone;
  final String? preferredAiModel;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.email,
    this.name,
    this.avatarUrl,
    this.clinicName,
    this.specialty,
    this.licenseNumber,
    this.phone,
    this.preferredAiModel,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        avatarUrl,
        clinicName,
        specialty,
        licenseNumber,
        phone,
        preferredAiModel,
        createdAt,
      ];

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? avatarUrl,
    String? clinicName,
    String? specialty,
    String? licenseNumber,
    String? phone,
    String? preferredAiModel,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      clinicName: clinicName ?? this.clinicName,
      specialty: specialty ?? this.specialty,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      phone: phone ?? this.phone,
      preferredAiModel: preferredAiModel ?? this.preferredAiModel,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
