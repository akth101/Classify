import 'package:classify/data/repositories/memo/memo_repository_remote.dart';
import 'package:classify/domain/models/memo/memo_model.dart';
import 'package:classify/utils/top_level_setting.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  late MemoRepositoryRemote _memoRepository;
  final ValueNotifier<List<MemoModel>> _currentMemos =
      ValueNotifier<List<MemoModel>>([]);
  final ValueNotifier<bool> _isLatestSort = ValueNotifier<bool>(true);
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _memoRepository = Provider.of<MemoRepositoryRemote>(context, listen: false);
    _loadTodoMemos();
  }

  void _loadTodoMemos() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final memos = _memoRepository.getMemos();
      // '할 일' 카테고리만 필터링
      final todoMemos =
          memos.values.where((memo) => memo.category == '할 일').toList();

      todoMemos.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _currentMemos.value = todoMemos;

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  void _sortByLatest() {
    final latestMemos = List<MemoModel>.from(_currentMemos.value)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    _currentMemos.value = latestMemos;
    _isLatestSort.value = true;
  }

  void _sortByOldest() {
    final oldestMemos = List<MemoModel>.from(_currentMemos.value)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    _currentMemos.value = oldestMemos;
    _isLatestSort.value = false;
  }

  void _deleteMemo(String memoId) {
    _memoRepository.deleteMemo(memoId);
    _loadTodoMemos(); // 삭제 후 데이터 새로 불러오기
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('할 일'),
          elevation: 0,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text('에러 발생 : $_error'))
                : Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
                    child: Column(
                      children: [
                        // 정렬 버튼
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            _buildSortButton(
                              isLatest: true,
                              icon: Icons.arrow_downward,
                              label: '최신순~',
                              onPressed: _sortByLatest,
                            ),
                            const SizedBox(width: 4),
                            _buildSortButton(
                                isLatest: false,
                                icon: Icons.arrow_upward,
                                label: '오래된 순임임',
                                onPressed: _sortByOldest),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // 메모 리스트
                        Expanded(
                            child: ValueListenableBuilder<List<MemoModel>>(
                          valueListenable: _currentMemos,
                          builder: (context, memosList, _) {
                            if (memosList.isEmpty) {
                              return const Center(
                                child: Text(
                                  '작성된 할 일 메모 없슈',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            }

                            return ListView.builder(
                              itemCount: memosList.length,
                              itemBuilder: (context, index) => _buildTodoCard(
                                context,
                                memosList[index],
                              ),
                            );
                          },
                        ))
                      ],
                    ),
                  ));
  }

  Widget _buildSortButton({
    required bool isLatest,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ValueListenableBuilder<bool>(
        valueListenable: _isLatestSort,
        builder: (context, isLatestSort, _) {
          final bool isSelected = isLatest ? isLatestSort : !isLatestSort;
          return TextButton.icon(
            onPressed: onPressed,
            icon: Icon(icon,
                size: 16,
                color:
                    isSelected ? AppTheme.primaryColor : AppTheme.textColor1),
            label: Text(label,
                style: TextStyle(
                    color: isSelected
                        ? AppTheme.primaryColor
                        : AppTheme.textColor1)),
            style: TextButton.styleFrom(
              backgroundColor: isSelected
                  ? AppTheme.primaryColor.withOpacity(0.1)
                  : Colors.transparent,
            ),
          );
        });
  }

  Widget _buildTodoCard(BuildContext context, MemoModel memo) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 체크박스
          Transform.scale(
            scale: 1.2,
            child: Checkbox(
              value: memo.isDone,
              activeColor: AppTheme.primaryColor,
              onChanged: (bool? value) {
                if (value == true) {
                  // 체크 시 할일 완료 처리 => 삭제
                  _deleteMemo(memo.memoId);
                }
              },
            ),
          ),
          const SizedBox(width: 12),
          // 메모 내용
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                memo.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                memo.content,
                style: const TextStyle(fontSize: 14),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              )
            ],
          ))
        ],
      ),
    );
  }
}
