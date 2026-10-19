// [A] 기능: 증명서·프로필 사진을 1MB 이하로 줄여 Firestore에 저장 (Firebase Storage 사용 안 함)
import 'dart:typed_data';

import '../models/app_user.dart';

enum PhotoSource { camera, gallery }

// Firebase 연결 전까지는 FakePhotoService(가짜)가 동작한다.
// 연결할 때 image_picker로 사진을 고르고(1MB 이하로 줄이기),
// Firestore certificates·profilePhotos 컬렉션에 저장하는 구현을 만들어 instance만 바꾸면 된다.
abstract class PhotoService {
  static PhotoService instance = FakePhotoService();

  // 사진을 고르지 않고 닫으면 null
  Future<Uint8List?> pickPhoto(PhotoSource source);

  Future<void> uploadCertificate({
    required String userId,
    required MemberType memberType,
    required Uint8List bytes,
  });

  Future<void> uploadProfilePhoto({
    required String userId,
    required Uint8List bytes,
  });

  // 프로필 사진이 없으면 null
  Future<Uint8List?> getProfilePhoto(String userId);
}

// 사진 대신 빈 데이터를 돌려준다.
// 화면에서는 빈 데이터면 증명서는 디자인의 예시 모양, 프로필은 이름 첫 글자를 보여준다.
class FakePhotoService implements PhotoService {
  final Map<String, Uint8List> _profilePhotos = {};

  @override
  Future<Uint8List?> pickPhoto(PhotoSource source) async => Uint8List(0);

  @override
  Future<void> uploadCertificate({
    required String userId,
    required MemberType memberType,
    required Uint8List bytes,
  }) async {}

  @override
  Future<void> uploadProfilePhoto({
    required String userId,
    required Uint8List bytes,
  }) async {
    _profilePhotos[userId] = bytes;
  }

  @override
  Future<Uint8List?> getProfilePhoto(String userId) async =>
      _profilePhotos[userId];
}
