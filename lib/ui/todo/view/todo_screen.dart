import 'package:classify/data/repositories/memo/memo_repository_remote.dart';
import 'package:classify/domain/models/memo/memo_model.dart';
import 'package:classify/ui/todo/view_models/todo_view_model.dart';
import 'package:classify/utils/top_level_setting.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TodoScreen extends StatefulWidget {
  // const TodoScreen({super.key});
  final TodoViewModel todoViewModel;

  const TodoScreen({
    super.key,
    required this.todoViewModel,
  });

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final ValueNotifier<bool> _isLatestSort = ValueNotifier<bool>(true);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.todoViewModel.loadTodoData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('할 일'),
        elevation: 0,
        backgroundColor: AppTheme.primaryColor,
      ),
      body: ListenableBuilder(
          listenable: widget.todoViewModel,
          builder: (context, _) {
            if (widget.todoViewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (widget.todoViewModel.error != null) {
              return Center(
                  child: Text('에러 발생 : ${widget.todoViewModel.error}'));
            }

            final todoList = widget.todoViewModel.todoList;

            if (todoList.isEmpty) {
              return const Center(
                child: Text(
                  '오늘의 할 일을 추가해주세요',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // 정렬 버튼
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _buildSortButton(
                        isLatest: true,
                        icon: Icons.arrow_downward,
                        label: '최신순',
                        onPressed: () {
                          widget.todoViewModel.sortByLatest();
                          _isLatestSort.value = true;
                        },
                      ),
                      const SizedBox(width: 4),
                      _buildSortButton(
                        isLatest: false,
                        icon: Icons.arrow_upward,
                        label: '오래된순',
                        onPressed: () {
                          widget.todoViewModel.sortByOldest();
                          _isLatestSort.value = false;
                        },
                      )
                    ],
                  ),
                  const SizedBox(height: 16),

                  // todoList
                  Expanded(
                      child: ListView.builder(
                    itemCount: todoList.length,
                    itemBuilder: (context, index) => _buildTodoCard(
                      context,
                      todoList[index],
                    ),
                  ))
                ],
              ),
            );
          }),
    );
  }

  Widget _buildSortButton({
    required bool isLatest,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ValueListenableBuilder<bool>(
      valueListenable: _isLatestSort,
      builder: (context, isLatestSortValue, _) {
        final bool isSelected =
            isLatest ? isLatestSortValue : !isLatestSortValue;
        return TextButton.icon(
          onPressed: onPressed,
          label: Text(
            label,
            style: TextStyle(
              color: isSelected ? AppTheme.primaryColor : AppTheme.textColor1,
            ),
          ),
          icon: Icon(
            icon,
            size: 16,
            color: isSelected ? AppTheme.primaryColor : AppTheme.textColor1,
          ),
          style: TextButton.styleFrom(
            backgroundColor: isSelected
                ? AppTheme.primaryColor.withOpacity(0.1)
                : Colors.transparent,
          ),
        );
      },
    );
  }

  Widget _buildTodoCard(BuildContext context, MemoModel todo) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 체크박스
          Transform.scale(
            scale: 1.2,
            child: Checkbox(
              value: todo.isDone,
              activeColor: AppTheme.primaryColor,
              onChanged: (bool? value) {
                if (value == true) {
                  // 체크 시 할일 완료 처리 => 삭제
                  widget.todoViewModel.deleteTodo(todo.memoId);
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
                todo.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                todo.content,
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
