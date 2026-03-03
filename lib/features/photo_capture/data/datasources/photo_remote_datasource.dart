import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/supabase/supabase_constants.dart';
import '../../domain/entities/face_landmarks.dart';
import '../../domain/entities/photo.dart';

abstract class PhotoRemoteDataSource {
  Future<String> uploadPhoto({
    required File file,
    required String surgeonId,
    required String caseId,
    required String angle,
  });

  Future<String> uploadThumbnail({
    required File file,
    required String surgeonId,
    required String caseId,
    required String angle,
  });

  Future<Photo> savePhotoMetadata({
    required String caseId,
    required String surgeonId,
    required String angle,
    required String storagePath,
    String? thumbnailPath,
    int? width,
    int? height,
    FaceLandmarks? landmarks,
  });

  Future<List<Photo>> getPhotosForCase(String caseId);

  Future<void> deletePhoto(String photoId);

  Future<String> getSignedUrl(String path);
}

class PhotoRemoteDataSourceImpl implements PhotoRemoteDataSource {
  final SupabaseClient client;

  PhotoRemoteDataSourceImpl({required this.client});

  @override
  Future<String> uploadPhoto({
    required File file,
    required String surgeonId,
    required String caseId,
    required String angle,
  }) async {
    try {
      final path = '$surgeonId/$caseId/${angle}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await client.storage
          .from(SupabaseConstants.patientPhotosBucket)
          .upload(path, file);
      return path;
    } catch (e) {
      throw ServerException(message: 'Failed to upload photo: $e');
    }
  }

  @override
  Future<String> uploadThumbnail({
    required File file,
    required String surgeonId,
    required String caseId,
    required String angle,
  }) async {
    try {
      final path = '$surgeonId/$caseId/thumbs/${angle}_thumb.jpg';
      await client.storage
          .from(SupabaseConstants.patientPhotosBucket)
          .upload(path, file, fileOptions: const FileOptions(upsert: true));
      return path;
    } catch (e) {
      throw ServerException(message: 'Failed to upload thumbnail: $e');
    }
  }

  @override
  Future<Photo> savePhotoMetadata({
    required String caseId,
    required String surgeonId,
    required String angle,
    required String storagePath,
    String? thumbnailPath,
    int? width,
    int? height,
    FaceLandmarks? landmarks,
  }) async {
    try {
      final data = await client
          .from(SupabaseConstants.photosTable)
          .insert({
            'case_id': caseId,
            'surgeon_id': surgeonId,
            'angle': angle,
            'storage_path': storagePath,
            'thumbnail_path': ?thumbnailPath,
            'original_width': ?width,
            'original_height': ?height,
            if (landmarks != null) 'landmarks_json': landmarks.toJson(),
          })
          .select()
          .single();

      return _mapToPhoto(data);
    } catch (e) {
      throw ServerException(message: 'Failed to save photo metadata: $e');
    }
  }

  @override
  Future<List<Photo>> getPhotosForCase(String caseId) async {
    try {
      final data = await client
          .from(SupabaseConstants.photosTable)
          .select()
          .eq('case_id', caseId)
          .order('created_at');

      return data.map((json) => _mapToPhoto(json)).toList();
    } catch (e) {
      throw ServerException(message: 'Failed to fetch photos: $e');
    }
  }

  @override
  Future<void> deletePhoto(String photoId) async {
    try {
      await client
          .from(SupabaseConstants.photosTable)
          .delete()
          .eq('id', photoId);
    } catch (e) {
      throw ServerException(message: 'Failed to delete photo: $e');
    }
  }

  @override
  Future<String> getSignedUrl(String path) async {
    try {
      return await client.storage
          .from(SupabaseConstants.patientPhotosBucket)
          .createSignedUrl(path, 3600); // 1 hour
    } catch (e) {
      throw ServerException(message: 'Failed to get signed URL: $e');
    }
  }

  Photo _mapToPhoto(Map<String, dynamic> json) {
    return Photo(
      id: json['id'] as String,
      caseId: json['case_id'] as String,
      surgeonId: json['surgeon_id'] as String,
      angle: json['angle'] as String,
      storagePath: json['storage_path'] as String,
      thumbnailPath: json['thumbnail_path'] as String?,
      originalWidth: json['original_width'] as int?,
      originalHeight: json['original_height'] as int?,
      landmarksJson: json['landmarks_json'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
