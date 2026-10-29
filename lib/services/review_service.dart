// [B] 기능: 후기 저장·불러오기, 키워드 검색(앱 안에서 걸러내기)·필터, 좋아요 (Firestore reviews, likes)
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../models/review.dart';
import 'auth_service.dart';
import 'qa_service.dart';
import 'user_service.dart';

// 디자인 예시 데이터(후기·질문·답변)를 서버 글과 함께 보여줄지.
// 예시는 서버에 올리지 않고 앱 안에만 있다. 실제 서비스를 시작할 때 false로 바꾼다.
const bool showSampleData = false;

// Firebase가 켜져 있고 로그인한 상태인지 (테스트·가짜 로그인에서는 앱 안에만 저장한다)
bool get firebaseReady =>
    AuthService.instance.isSignedIn && Firebase.apps.isNotEmpty;

// 글쓴이(지금 로그인한 회원) 정보.
// 회원 정보는 A의 UserService에서 읽기만 하고, 한 번 불러와 둔다.
class CurrentMember {
  CurrentMember._();

  static AppUser? _user;
  static String? _loadedId;

  // A의 MY 화면과 같은 규칙: 로그인 전(가짜 로그인)에는 'local-user'
  static String get id => AuthService.instance.currentUserId ?? 'local-user';

  static Future<void> load() async {
    final userId = id;
    if (_loadedId == userId) return;
    _loadedId = userId;
    try {
      _user = await UserService.instance.getUser(userId);
    } catch (error) {
      debugPrint('회원 정보를 불러오지 못했어요: $error');
      _user = null;
    }
    ReviewService.changes.value++;
    QaService.changes.value++;
  }

  // 글에 보이는 작성자 이름 = 회원 닉네임. 회원 정보가 없으면 "회원"
  static String get name {
    final name = _user?.nickname?.trim() ?? '';
    return name.isEmpty ? '회원' : name;
  }

  static bool get isEmployee => _user?.isEmployee ?? false;
  static bool get isVerified => _user?.isVerified ?? false;
  static String get type => isEmployee ? '취업자' : '재학생';

  // 후기·답변은 인증된 취업자(인증 선배)만 쓸 수 있다.
  static bool get canWriteSeniorPost => isEmployee && isVerified;

  // 회원 정보의 학교 이름 그대로 (예: 대림대학교)
  static String get schoolFullName => _user?.school ?? '';

  // 글에 보여줄 짧은 학교 이름 (디자인: 대림대)
  static String get school => ReviewService.shortSchoolName(schoolFullName);

  static String get department => _user?.department ?? '';
  static String get company => _user?.company ?? '';
  static String get job => _user?.jobTitle ?? '';

  // 학번·졸업연도는 두 자리로 (2020 → 20)
  static String get admissionYear => _twoDigits(_user?.admissionYear);
  static String get graduationYear => _twoDigits(_user?.graduationYear);

  static String _twoDigits(int? year) =>
      year == null ? '' : (year % 100).toString().padLeft(2, '0');
}

// 좋아요(디자인: 도움돼요) 기록. 후기와 답변이 같이 쓴다.
// Firestore likes 컬렉션: 문서 이름 = "회원id_대상id", 내가 누른 것만 불러온다.
class Likes {
  Likes._();

  static final Set<String> _serverIds = {}; // 서버에 저장된 내 좋아요
  static final Set<String> _localIds = {}; // 예시 글 좋아요 (앱 안에서만)
  static StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;
  static String? _userId;

  static void start() {
    if (!firebaseReady) return;
    final userId = CurrentMember.id;
    if (_sub != null && _userId == userId) return;
    _sub?.cancel();
    _userId = userId;
    _sub = FirebaseFirestore.instance
        .collection('likes')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .listen(
          (snapshot) {
            _serverIds
              ..clear()
              ..addAll(
                snapshot.docs.map((d) => d.data()['targetId'] as String? ?? ''),
              );
            _notify();
          },
          onError: (Object error) {
            debugPrint('좋아요를 불러오지 못했어요: $error');
            _sub = null;
          },
        );
  }

  static bool isLiked(String targetId) =>
      _serverIds.contains(targetId) || _localIds.contains(targetId);

  // collection: 'reviews' 또는 'answers'
  // 서버 글은 좋아요 기록과 글의 likeCount를 한 번에 바꾼다.
  static Future<void> toggle({
    required String collection,
    required String targetId,
    required bool isSample,
  }) async {
    if (isSample || !firebaseReady) {
      if (!_localIds.remove(targetId)) _localIds.add(targetId);
      _notify();
      return;
    }

    final db = FirebaseFirestore.instance;
    final userId = CurrentMember.id;
    final likeRef = db.collection('likes').doc('${userId}_$targetId');
    final targetRef = db.collection(collection).doc(targetId);
    final batch = db.batch();
    if (_serverIds.contains(targetId)) {
      batch.delete(likeRef);
      batch.update(targetRef, {'likeCount': FieldValue.increment(-1)});
    } else {
      batch.set(likeRef, {
        'userId': userId,
        'targetType': collection == 'reviews' ? 'review' : 'answer',
        'targetId': targetId,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      });
      batch.update(targetRef, {'likeCount': FieldValue.increment(1)});
    }
    await batch.commit();
  }

  static void _notify() {
    ReviewService.changes.value++;
    QaService.changes.value++;
  }
}

class ReviewService {
  ReviewService._();

  // 직무 분야 (후기 작성·질문 작성 칩, 홈 직무 탭)
  static const List<String> jobCategories = [
    'IT·개발',
    '디자인',
    '항공·관광',
    '호텔·외식',
    '조리·제과',
    '보건·의료',
    '경영·사무',
  ];

  // 후기 목록이 바뀌면 값이 올라간다. 화면은 이것을 지켜보다가 다시 그린다.
  static final ValueNotifier<int> changes = ValueNotifier(0);

  static CollectionReference<Map<String, dynamic>> get _reviews =>
      FirebaseFirestore.instance.collection('reviews');

  // 서버(Firestore)에 있는 후기, 최신순. 가짜 로그인에서는 새로 쓴 후기가 여기에만 들어간다.
  static final List<Review> _serverReviews = [];
  static StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;

  // 후기를 쓰는 화면들이 켜질 때 부른다. 여러 번 불러도 한 번만 연결한다.
  // 서버 후기를 실시간으로 지켜보다가 바뀌면 화면을 다시 그린다.
  static void start() {
    CurrentMember.load();
    Likes.start();
    if (_sub != null || !firebaseReady) return;
    _sub = _reviews
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
            _serverReviews
              ..clear()
              ..addAll(
                snapshot.docs.map((d) => Review.fromMap(d.id, d.data())),
              );
            changes.value++;
          },
          onError: (Object error) {
            debugPrint('후기를 불러오지 못했어요: $error');
            _sub = null;
          },
        );
  }

  // 새 후기 문서 이름
  static String newId() => firebaseReady
      ? _reviews.doc().id
      : 'w${DateTime.now().millisecondsSinceEpoch}';

  // 저장에 실패하면 오류를 그대로 넘긴다 (화면에서 안내)
  static Future<void> addReview(Review review) async {
    if (!firebaseReady) {
      _serverReviews.insert(0, review);
      changes.value++;
      return;
    }
    await _reviews.doc(review.id).set(review.toMap());
  }

  // 서버 후기 + 예시 후기
  static List<Review> get allReviews => [
    ..._serverReviews,
    if (showSampleData) ...sampleReviews,
  ];

  // 지금 목록에 있는 최신 후기 (상세 화면의 좋아요 수를 새로 고칠 때)
  static Review? findById(String id) {
    for (final r in allReviews) {
      if (r.id == id) return r;
    }
    return null;
  }

  static bool isSample(Review review) =>
      sampleReviews.any((r) => r.id == review.id);

  // 서버 후기는 서버의 likeCount에 내 좋아요가 이미 들어 있다.
  static int likeCountOf(Review review) {
    final latest = findById(review.id) ?? review;
    final mine = isSample(review) && Likes.isLiked(review.id) ? 1 : 0;
    return latest.likeCount + mine;
  }

  static Future<void> toggleLike(Review review) => Likes.toggle(
    collection: 'reviews',
    targetId: review.id,
    isSample: isSample(review),
  );

  // Firestore 연결 전까지 쓰는 예시 후기 (디자인에 적힌 내용)
  // 본문·작성자가 디자인에 없는 후기는 비워 둔다.
  static final List<Review> sampleReviews = [
    Review(
      id: 'r1',
      category: '항공·관광',
      title: '첫 비행 전까지, 항공서비스학과 선배의 준비 기록 ✈️',
      company: '에어웨이브',
      job: '객실승무원',
      authorId: 'u1',
      authorName: '김민지',
      authorSchool: '대림대',
      authorDepartment: '항공서비스',
      authorAdmissionYear: '20',
      authorGraduationYear: '23',
      preparation: '항공사마다 인재상이 달라 제 경험을 안전·서비스·협업 역량으로 나눠 정리했어요. 매일 답변 모습을 촬영하며 표정과 말의 속도를 확인했습니다.',
      difficulty:
          '서류 탈락이 이어질 때 지원 수만 늘리지 않고 항공사별 서비스 가치와 노선을 조사해 자기소개를 다시 만들었어요.',
      trialAndError: '처음에는 빠른 서비스가 중요하다고 생각했지만, 객실에서는 속도보다 안전 절차와 동료 간 정확한 확인이 먼저라는 것을 배웠습니다.',
      tip: '채용 공고가 열리기 전부터 증명사진, 어학 성적, 경험 정리를 준비하고 모의 면접 피드백을 꾸준히 받아보세요.',
      quote: '신입 때의 시행착오도 정리하면 후배에게 가장 현실적인 정보가 돼요.',
      links: const [
        ReviewLink(
          type: 'Notion',
          title: '항공사 면접 답변 정리 노트',
          url: 'https://notion.site/airline-interview',
        ),
        ReviewLink(
          type: 'Drive',
          title: '지원 서류 준비 체크리스트',
          url: 'https://drive.google.com',
        ),
      ],
      hashtags: const ['객실승무원', '항공서비스', '신입취업'],
      photoCaption: '항공서비스 전공을 살린 취업 준비 과정',
      likeCount: 128,
      createdAt: DateTime(2026, 10, 18),
    ),
    Review(
      id: 'r2',
      category: '조리·제과',
      title: '호텔 주방 막내 조리사가 알려주는 취업 준비',
      company: '그랜드리프',
      job: '양식 조리사',
      authorId: 'u1',
      authorName: '김민지',
      authorSchool: '대림대',
      authorDepartment: '호텔조리',
      authorAdmissionYear: '20',
      authorGraduationYear: '23',
      likeCount: 109,
      createdAt: DateTime(2026, 10, 17),
    ),
    Review(
      id: 'r3',
      category: '조리·제과',
      title: '제과제빵 자격증보다 현장에서 중요했던 것 🥐',
      company: '메종브레드',
      job: '파티시에',
      authorId: 'u1',
      authorName: '김민지',
      authorSchool: '대림대',
      authorDepartment: '제과제빵',
      authorAdmissionYear: '20',
      authorGraduationYear: '23',
      likeCount: 96,
      createdAt: DateTime(2026, 10, 16),
    ),
    _withoutAuthor(
      'r4',
      '보건·의료',
      '신규 간호사의 첫 병동 적응기',
      '서림메디컬',
      '간호사',
      84,
      15,
      school: '대림대',
      department: '간호학',
    ),
    _withoutAuthor(
      'r5',
      '호텔·외식',
      '호텔 프런트 면접에서 자주 받은 질문',
      '호텔 마레',
      '프런트 매니저',
      72,
      14,
      school: '대림대',
      department: '호텔관광',
    ),
    _withoutAuthor(
      'r6',
      'IT·개발',
      '프론트엔드 신입의 첫 100일 💻',
      '오브젝트',
      '프론트엔드 개발자',
      68,
      13,
    ),
    _withoutAuthor(
      'r7',
      '디자인',
      '비전공자였던 내가 서비스 디자이너가 되기까지',
      '브릿지랩',
      'UI/UX 디자이너',
      0,
      12,
      school: '대림대',
      department: '시각디자인',
    ),
    _withoutAuthor(
      'r8',
      'IT·개발',
      '코딩테스트보다 더 중요했던 나만의 프로젝트',
      '오브젝트',
      '프론트엔드 개발자',
      0,
      11,
      school: '대림대',
      department: '컴퓨터정보',
    ),
    _withoutAuthor(
      'r9',
      '경영·사무',
      '신입 회계 담당자의 현실적인 하루',
      '하이브릿지',
      '회계 사무원',
      0,
      10,
      school: '대림대',
      department: '경영학',
    ),
  ];

  // 홈 DISCOVER·TODAY에 보여줄 후기 (새로 쓴 후기가 맨 앞, 그다음 디자인 순서)
  static List<Review> get homeReviews => [
    ..._serverReviews,
    if (showSampleData)
      for (final id in ['r1', 'r2', 'r3', 'r4', 'r5', 'r6'])
        sampleReviews.firstWhere((r) => r.id == id),
  ];

  // 배너 "학과별 선배 노트"에 묶인 후기
  // 예시를 켜면 디자인 순서 그대로, 끄면 서버 후기 중 학과마다 좋아요가 가장 많은 후기 (최대 8개)
  static List<Review> get bannerReviews {
    if (showSampleData) {
      return [
        for (final id in ['r1', 'r2', 'r3', 'r4', 'r5', 'r7', 'r8', 'r9'])
          sampleReviews.firstWhere((r) => r.id == id),
      ];
    }
    final best = <String, Review>{};
    for (final r in _serverReviews) {
      final current = best[r.authorDepartment];
      if (current == null || likeCountOf(r) > likeCountOf(current)) {
        best[r.authorDepartment] = r;
      }
    }
    return (best.values.toList()
          ..sort((a, b) => likeCountOf(b).compareTo(likeCountOf(a))))
        .take(8)
        .toList();
  }

  static List<Review> reviewsByAuthor(String authorId) =>
      allReviews.where((r) => r.authorId == authorId).toList();

  // 같은 학과 선배 후기 (지금 보고 있는 후기는 뺀다)
  static List<Review> sameDepartmentReviews(Review review) => allReviews
      .where(
        (r) =>
            r.id != review.id &&
            r.authorDepartment.isNotEmpty &&
            r.authorDepartment == review.authorDepartment,
      )
      .toList();

  // 검색 화면: 검색어와 필터(학교·학과·직무·기업)로 후기를 앱 안에서 걸러낸다.
  // 필터 묶음이 비어 있으면 그 필터는 적용하지 않는다(전체).
  static List<Review> searchReviews({
    String keyword = '',
    Set<String> schools = const {},
    Set<String> departments = const {},
    Set<String> categories = const {},
    Set<String> companies = const {},
  }) {
    final word = keyword.trim().toLowerCase();
    final schoolKeys = schools.map(_schoolKey).toSet();

    return allReviews.where((r) {
      if (schoolKeys.isNotEmpty &&
          !schoolKeys.contains(_schoolKey(r.authorSchool))) {
        return false;
      }
      if (departments.isNotEmpty && !departments.contains(r.authorDepartment)) {
        return false;
      }
      if (categories.isNotEmpty && !categories.contains(r.category)) {
        return false;
      }
      if (companies.isNotEmpty && !companies.contains(r.company)) {
        return false;
      }
      if (word.isEmpty) return true;
      return [
        r.title,
        r.company,
        r.job,
        r.category,
        r.authorDepartment,
        ...r.hashtags,
      ].any((text) => text.toLowerCase().contains(word));
    }).toList();
  }

  // 검색 필터의 기업 목록 (후기에 적힌 회사 이름, 겹치지 않게)
  static List<String> get companyNames => {
    for (final r in allReviews)
      if (r.company.isNotEmpty) r.company,
  }.toList();

  // 학교 이름 비교용: "대림대학교"와 "대림대"를 같은 학교로 본다.
  static String _schoolKey(String school) => shortSchoolName(school);

  // "대림대학교" → "대림대" (디자인의 짧은 학교 이름)
  static String shortSchoolName(String school) =>
      school.endsWith('학교') ? school.substring(0, school.length - 2) : school;

  static Review _withoutAuthor(
    String id,
    String category,
    String title,
    String company,
    String job,
    int likeCount,
    int day, {
    String school = '',
    String department = '',
  }) {
    return Review(
      id: id,
      category: category,
      title: title,
      company: company,
      job: job,
      authorId: '',
      authorName: '',
      authorSchool: school,
      authorDepartment: department,
      authorAdmissionYear: '',
      authorGraduationYear: '',
      likeCount: likeCount,
      createdAt: DateTime(2026, 10, day),
    );
  }
}
