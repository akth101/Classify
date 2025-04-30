import 'package:classify/data/repositories/memo/memo_repository_remote.dart';
import 'package:classify/domain/models/memo/memo_model.dart';
import 'package:classify/ui/todo/view_models/todo_view_model.dart';
import 'package:classify/utils/top_level_setting.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TodoScreen extends StatefulWidget {
  final TodoViewModel todoViewModel;

  const TodoScreen({
    super.key,
    required this.todoViewModel,
  });

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen>
    with SingleTickerProviderStateMixin {
  final ValueNotifier<bool> _isLatestSort = ValueNotifier<bool>(true);
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    //탭 컨트롤러 초기화
    _tabController = TabController(
        length: widget.todoViewModel.availableStatuses.length, vsync: this);

    // 탭 변경 시 상태 변경 처리
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        final status =
            widget.todoViewModel.availableStatuses[_tabController.index];
        widget.todoViewModel.changeStatus(status);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.todoViewModel.loadTodoData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('할 일'),
        elevation: 0,
        backgroundColor: AppTheme.primaryColor,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'In Progress'),
            Tab(text: 'Done'),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
        ),
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
              return Center(
                child: Text(
                  widget.todoViewModel.currentStatus == 'In Progress'
                      ? '진행 중인 할 일이 없습니다'
                      : '완료된 할 일이 없습니다',
                  style: const TextStyle(
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
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 체크박스
          Transform.scale(
            scale: 1.2,
            child: Checkbox(
              value: todo.isDone,
              activeColor: AppTheme.primaryColor,
              onChanged: (bool? value) async {
                try {
                  await widget.todoViewModel.toggleTodoStatus(todo);
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('상태 변경 중 오류가 발생했습니다')),
                  );
                }
              },
            ),
          ),
          const SizedBox(width: 12),
          // 메모 내용
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    todo.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      decoration: todo.isDone == true
                          ? TextDecoration.lineThrough
                          : null,
                      color: todo.isDone == true ? Colors.grey : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    todo.content,
                    style: TextStyle(
                      fontSize: 14,
                      decoration: todo.isDone == true
                          ? TextDecoration.lineThrough
                          : null,
                      color: todo.isDone == true ? Colors.grey : Colors.black87,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
