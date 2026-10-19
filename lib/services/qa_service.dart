// [B] 기능: 질문·답변 저장·불러오기, Q&A 키워드 검색(앱 안에서 걸러내기) (Firestore questions)
import '../models/question.dart';

class QaService {
  QaService._();

  // 이 앱에서 새로 쓴 질문 (앱을 끄면 사라진다. Firestore 연결 전까지)
  static final List<Question> questions = [];

  static void addQuestion(Question question) {
    questions.insert(0, question);
  }
}
