// [B] 기능: 후기 저장·불러오기, 키워드 검색(앱 안에서 걸러내기)·필터, 좋아요 (Firestore reviews, likes)
import 'package:flutter/foundation.dart';

import '../models/review.dart';

// 로그인 기능(A 담당)이 생기기 전까지 작성자로 쓰는 예시 사용자
class SampleCurrentUser {
  SampleCurrentUser._();

  static const String id = 'u1';
  static const String name = '김민지';
  static const String type = '취업자'; // 취업자 / 재학생
  static const String school = '대림대';
  static const String department = '항공서비스';
  static const String admissionYear = '20';
  static const String graduationYear = '23';
  static const String company = '에어웨이브';
  static const String job = '객실승무원';
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

  // 이 앱에서 새로 쓴 후기 (앱을 끄면 사라진다. Firestore 연결 전까지)
  static final List<Review> _writtenReviews = [];

  static void addReview(Review review) {
    _writtenReviews.insert(0, review);
    sampleReviews.insert(0, review);
    changes.value++;
  }

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
    ..._writtenReviews,
    for (final id in ['r1', 'r2', 'r3', 'r4', 'r5', 'r6'])
      sampleReviews.firstWhere((r) => r.id == id),
  ];

  // 배너 "학과별 선배 노트"에 묶인 후기 (디자인 순서)
  static List<Review> get bannerReviews => [
    for (final id in ['r1', 'r2', 'r3', 'r4', 'r5', 'r7', 'r8', 'r9'])
      sampleReviews.firstWhere((r) => r.id == id),
  ];

  static List<Review> reviewsByAuthor(String authorId) =>
      sampleReviews.where((r) => r.authorId == authorId).toList();

  // 같은 학과 선배 후기 (지금 보고 있는 후기는 뺀다)
  static List<Review> sameDepartmentReviews(Review review) => sampleReviews
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

    return sampleReviews.where((r) {
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
    for (final r in sampleReviews)
      if (r.company.isNotEmpty) r.company,
  }.toList();

  // 학교 이름 비교용: "대림대학교"와 "대림대"를 같은 학교로 본다.
  static String _schoolKey(String school) =>
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
