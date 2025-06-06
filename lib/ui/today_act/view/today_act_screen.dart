import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:classify/domain/models/memo/memo_model.dart';
import 'package:classify/ui/today_act/view_models/today_act_view_model.dart';
import 'package:classify/ui/today_act/view/memo_detail_page.dart';

class TodayActScreen extends StatefulWidget {
  final TodayActViewModel viewModel;

  const TodayActScreen({
    super.key,
    required this.viewModel,
  });

  @override
  State<TodayActScreen> createState() => _TodayActScreenState();
}

class _TodayActScreenState extends State<TodayActScreen> {
  @override
  void initState() {
    super.initState();

    // 로드 시작 시간 기록
    final startTime = DateTime.now();
    debugPrint("⏱️ 데이터 로드 시작: ${startTime.toIso8601String()}");

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.viewModel.initCachedMemos();
      widget.viewModel.connectStreamToCachedMemos().then((_) {
        //
        final endTime = DateTime.now();
        final duration = endTime.difference(startTime);
        debugPrint("⏱️ 데이터 로드 완료: ${endTime.toIso8601String()}");
        debugPrint("⏱️ 총 소요 시간: ${duration.inMilliseconds}ms");
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: widget.viewModel,
          builder: (context, _) {
            if (widget.viewModel.error != null) {
              return Center(child: Text('에러 발생: ${widget.viewModel.error}'));
            }

            if (widget.viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final todayMemos = widget.viewModel.todayMemos;

            if (todayMemos.isEmpty) {
              return _buildEmptyState();
            }

            // 시간 순으로 정렬된 오늘의 메모 리스트 생성
            final sortedMemos = todayMemos.values.toList()
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

            return _buildTodayContent(sortedMemos);
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(70),
            child: Image.asset(
              'assets/11.png',
              width: 100,
              height: 150,
              fit: BoxFit.fill,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '오늘 작성한 메모가 없습니다',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            '생각을 풀어놓으세요, \n정리는 우리에게 맡기고',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTodayContent(List<MemoModel> memos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 헤더 - 오늘 작성한 메모 수
        Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '오늘',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.blue[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${widget.viewModel.todayMemoCount}개의 메모를 작성했어요',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
            ],
          ),
        ),

        // 메모 리스트
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: memos.length,
            itemBuilder: (context, index) {
              final memo = memos[index];
              return _buildTimelineCard(memo);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineCard(MemoModel memo) {
    // 시간 포맷
    final timeFormat = DateFormat('HH:mm');
    final timeString = timeFormat.format(memo.createdAt);

    return GestureDetector(
      onTap: () => _navigateToDetailScreen(memo),
      onLongPress: () => _showDeleteDialog(memo.memoId, memo.category),
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 시간과 카테고리 표시
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  //시간 표시
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        timeString,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  //카테고리 표시
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(memo.category),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          memo.category,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      if (memo.category == 'AI분류 실패') const SizedBox(width: 6),
                      if (memo.category == 'AI분류 실패')
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () async {
                            // 메모 내용 다시 분석 요청
                            final result =
                                await widget.viewModel.reAnalyzeMemo(memo);
                            if (result == null) {
                              // 성공
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('메모가 다시 분석되었습니다')),
                              );
                            } else {
                              // 실패
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('메모 분석 실패, 잠시 후 다시 시도하세요')),
                              );
                            }
                          },
                          // 아이콘 탭 영역을 넓혀 detailpage로 이동하는 확률을 줄이기 위함
                          child: const Padding(
                            padding: EdgeInsets.all(2.0),
                            child: Icon(
                              Icons.restore_outlined,
                              size: 20,
                              color: Colors.red,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // 제목
              Text(
                memo.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              // 내용
              Text(
                memo.content,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case '공부':
        return Colors.blue;
      case '아이디어':
        return Colors.green;
      case '참조':
        return Colors.orange;
      case '회고':
        return Colors.brown;
      default:
        return Colors.red;
    }
  }

  void _navigateToDetailScreen(MemoModel memo) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => MemoDetailPage(
          memo: memo,
          viewModel: widget.viewModel,
        ),
      ),
    );
  }

  void _showDeleteDialog(String memoId, String category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('메모 삭제'),
        content: const Text('이 메모를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              widget.viewModel.deleteMemo(memoId, category);
              Navigator.of(context).pop();
            },
            child: const Text(
              '삭제',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
