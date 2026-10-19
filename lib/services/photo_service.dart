// [A] 기능: 증명서·프로필 사진을 1MB 이하로 줄여 Firestore에 저장 (Firebase Storage 사용 안 함)
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

import '../models/app_user.dart';

enum PhotoSource { camera, gallery }

// 기본값은 FakePhotoService(가짜, 테스트용)이고, 앱을 켤 때 main.dart에서 FirebasePhotoService로 바꾼다.
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

// 실제 기능: image_picker로 사진을 고르고 줄여서, Firestore 문서에 그대로 저장한다.
// Firestore 문서 하나는 1MB까지라 사진을 가로세로 1024 이하, 화질 60%로 줄인다 (보통 300KB 이하).
class FirebasePhotoService implements PhotoService {
  final _picker = ImagePicker();
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  @override
  Future<Uint8List?> pickPhoto(PhotoSource source) async {
    try {
      final file = await _picker.pickImage(
        source: source == PhotoSource.camera
            ? ImageSource.camera
            : ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 60,
      );
      return await file?.readAsBytes();
    } catch (_) {
      // 카메라가 없는 기기(시뮬레이터 등)이거나 사진 접근을 거절한 경우
      return null;
    }
  }

  // 증명서는 개인정보라 본인과 관리자만 볼 수 있게 보안 규칙으로 막는다 (firestore.rules)
  @override
  Future<void> uploadCertificate({
    required String userId,
    required MemberType memberType,
    required Uint8List bytes,
  }) {
    return _db.collection('certificates').doc(userId).set({
      'image': Blob(bytes),
      'memberType': memberType.name,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> uploadProfilePhoto({
    required String userId,
    required Uint8List bytes,
  }) {
    return _db.collection('profilePhotos').doc(userId).set({
      'image': Blob(bytes),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<Uint8List?> getProfilePhoto(String userId) async {
    final snapshot = await _db.collection('profilePhotos').doc(userId).get();
    final image = snapshot.data()?['image'];
    return image is Blob ? image.bytes : null;
  }
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
