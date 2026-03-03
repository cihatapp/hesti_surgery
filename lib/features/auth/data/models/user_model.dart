import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../../../core/cache/cacheable_base_model.dart';
import '../../domain/entities/user.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
abstract class UserModel with _$UserModel implements CacheableModel {
  const UserModel._();

  const factory UserModel({
    required String id,
    required String email,
    String? name,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @JsonKey(name: 'clinic_name') String? clinicName,
    String? specialty,
    @JsonKey(name: 'license_number') String? licenseNumber,
    String? phone,
    @JsonKey(name: 'preferred_ai_model') String? preferredAiModel,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  /// Create from Supabase auth user + optional profile data
  factory UserModel.fromSupabaseUser(
    sb.User user, {
    Map<String, dynamic>? profile,
  }) {
    return UserModel(
      id: user.id,
      email: user.email ?? '',
      name: profile?['full_name'] as String? ??
          user.userMetadata?['full_name'] as String?,
      avatarUrl: profile?['avatar_url'] as String?,
      clinicName: profile?['clinic_name'] as String?,
      specialty: profile?['specialty'] as String?,
      licenseNumber: profile?['license_number'] as String?,
      phone: profile?['phone'] as String?,
      preferredAiModel: profile?['preferred_ai_model'] as String?,
      createdAt: DateTime.parse(user.createdAt),
    );
  }

  User toEntity() => User(
        id: id,
        email: email,
        name: name,
        avatarUrl: avatarUrl,
        clinicName: clinicName,
        specialty: specialty,
        licenseNumber: licenseNumber,
        phone: phone,
        preferredAiModel: preferredAiModel,
        createdAt: createdAt,
      );

  factory UserModel.fromEntity(User entity) => UserModel(
        id: entity.id,
        email: entity.email,
        name: entity.name,
        avatarUrl: entity.avatarUrl,
        clinicName: entity.clinicName,
        specialty: entity.specialty,
        licenseNumber: entity.licenseNumber,
        phone: entity.phone,
        preferredAiModel: entity.preferredAiModel,
        createdAt: entity.createdAt,
      );
}

@freezed
abstract class AuthResponseModel with _$AuthResponseModel {
  const factory AuthResponseModel({
    required UserModel user,
    @JsonKey(name: 'access_token') required String accessToken,
    @JsonKey(name: 'refresh_token') String? refreshToken,
  }) = _AuthResponseModel;

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseModelFromJson(json);
}
