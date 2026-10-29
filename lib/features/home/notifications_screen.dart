// [B] 03 홈·후기 > 알림 화면, 화면만 만들고 실제 알림 기능은 없음 (디자인: Notifications)
import 'package:flutter/material.dart';

import '../../common/theme/app_colors.dart';
import '../../common/theme/app_text_styles.dart';
import '../../services/qa_service.dart';
import '../../services/review_service.dart';
import '../qa/qa_detail_screen.dart';
import '../review/review_detail_screen.dart';

// 실제 알림 기능은 만들지 않으므로 디자인의 예시 알림을 그대로 보여준다.
class _NotificationItem {
  const _NotificationItem({
    required this.icon,
    required this.title,
    required this.body,
    required this.time,
    this.unread = false,
    this.reviewId,
    this.questionId,
  });

  final IconData icon;
  final String title;
  final String body;
  final String time;
  final bool unread;
  final String? reviewId; // 누르면 열 후기
  final String? questionId; // 누르면 열 질문
}

const List<_NotificationItem> _sampleNotifications = [
  _NotificationItem(
    icon: Icons.contact_support_outlined,
    title: '새 답변이 도착했어요',
    body: '박준호 선배가 질문에 답변을 남겼어요.',
    time: '방금',
    unread: true,
    // 예시 알림이라, 답변이 달린 예시 질문(항공사 면접 영어 답변)으로 연결한다.
    questionId: 'q1',
  ),
  _NotificationItem(
    icon: Icons.favorite_border,
    title: '후기가 도움됐어요',
    body: '작성한 후기에 도움돼요가 10개 추가됐어요.',
    time: '2시간 전',
    reviewId: 'r1',
  ),
  _NotificationItem(
    icon: Icons.favorite_border,
    title: '이번 주 인기 후기',
    body: '대림대 선배들의 가장 인기 있는 이야기를 확인해보세요.',
    time: '어제',
  ),
];

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 30),
                children: [
                  for (final item in _sampleNotifications)
                    _buildItem(context, item),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: 36,
                height: 36,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  tooltip: '뒤로가기',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.chevron_left,
                    size: 25,
                    color: AppColors.text,
                  ),
                ),
              ),
            ),
          ),
          const Expanded(
            child: Text(
              '알림',
              textAlign: TextAlign.center,
              style: AppTextStyles.headerTitle,
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, _NotificationItem item) {
    // 후기 알림은 후기 상세로, 답변 알림은 Q&A 상세로 간다.
    // 연결된 글이 지금 목록에 없으면(예시 데이터를 끈 경우) 눌러도 아무것도 하지 않는다.
    final review = item.reviewId == null
        ? null
        : ReviewService.findById(item.reviewId!);
    final question = QaService.findQuestion(item.questionId);
    return InkWell(
      onTap: review != null
          ? () => openReviewDetail(context, review)
          : question != null
          ? () => openQaDetail(context, question)
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.divider)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 42,
              height: 42,
              child: Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: AppColors.iconBackground,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(item.icon, size: 19, color: AppColors.text),
                  ),
                  if (item.unread)
                    Positioned(
                      top: 1,
                      right: 1,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: AppColors.text,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      height: 1.5,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    item.body,
                    style: const TextStyle(
                      fontSize: 11,
                      height: 1.5,
                      color: AppColors.textBody,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.time,
                    style: const TextStyle(
                      fontSize: 9,
                      height: 1.5,
                      color: AppColors.textInactive,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
