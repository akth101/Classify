import 'package:classify/domain/models/todo/todo_model.dart';
import 'package:flutter/material.dart';
import 'package:classify/ui/todo/view_models/todo_view_model.dart';
import 'package:classify/utils/top_level_setting.dart';

class TodoScreen extends StatefulWidget {
  final TodoViewModel viewModel;

  const TodoScreen({
    super.key,
    required this.viewModel,
  });

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.viewModel.initCachedTodos();
      widget.viewModel.sortByLatest();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.viewModel.initCachedTodos();
    widget.viewModel.sortByLatest();
  }

  @override
  Widget build(BuildContext context) {
    // 매번 빌드할 때 최신 데이터 사용
    final todoList = widget.viewModel.cachedTodoModels.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const TabBar(
            tabs: [
              Tab(text: '진행 중'),
              Tab(text: '완료'),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () {
                _showAddTodoDialog(context);
              },
              icon: const Icon(Icons.sort),
            ),
          ],
        ),
        body: TabBarView(
          children: [
            // 미완료 탭
            _buildTabContent(
                todoList.where((todo) => todo.isDone != true).toList()),

            // 완료 탭
            _buildTabContent(
                todoList.where((todo) => todo.isDone == true).toList()),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddTodoDialog(context),
          child: const Icon(Icons.add_box_outlined),
        ),
      ),
    );
  }

  Widget _buildTabContent(List<TodoModel> filteredList) {
    return filteredList.isEmpty
        ? _buildEmptyState()
        : _buildTodoContent(filteredList);
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              '할 일이 없습니다',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textColor1,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              '새로운 할 일을 추가해주세요 💫',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textColor2,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodoContent(List<TodoModel> todoList) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 8),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.9,
              ),
              itemCount: todoList.length,
              itemBuilder: (context, index) =>
                  _buildTodoGridItem(todoList[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          '${widget.viewModel.cachedTodoModels.length}개',
          style: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 16,
            fontStyle: FontStyle.italic,
            color: AppTheme.textColor2,
          ),
        ),
      ],
    );
  }

  // Widget _buildStatusFilter() {}

  Widget _buildTodoGridItem(TodoModel todoObject) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(
          color: todoObject.isImportant == true
              ? AppTheme.errorColor
              : AppTheme.darkAccentColor,
          width: 1.5,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // todo 상세 보기 등 추가
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Checkbox(
                    value: todoObject.isDone,
                    onChanged: (bool? value) {
                      widget.viewModel.toggleCompleted(todoObject.todoId);
                      // 강제 UI 업데이트
                      setState(() {});
                    },
                  ),
                  IconButton(
                    onPressed: () {
                      _showDeleteConfirmation(todoObject);
                    },
                    icon: const Icon(
                      Icons.delete_outline,
                      size: 20,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              Expanded(
                child: Text(
                  todoObject.todoContent,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      decoration: todoObject.isDone == true
                          ? TextDecoration.lineThrough
                          : null,
                      color: todoObject.isDone == true
                          ? const Color.fromARGB(255, 10, 16, 10)
                          : const Color.fromARGB(255, 7, 15, 14)),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${todoObject.createdAt.year}.${todoObject.createdAt.month}.${todoObject.createdAt.day}',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                    color: AppTheme.textColor1),
              ),
              const SizedBox(height: 1),
              Text(
                '${todoObject.createdAt.hour.toString().padLeft(2, '0')}:${todoObject.createdAt.minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                    color: AppTheme.textColor1),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(TodoModel todo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('할 일 삭제'),
        content: Text('\'${todo.todoContent}\' 항목을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.viewModel.deleteTodo(todo.todoId);
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // 할일 추가 다이얼로그
  void _showAddTodoDialog(BuildContext context) {
    final TextEditingController contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Todo List 추가'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              TextField(
                controller: contentController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Todo',
                  hintText: '상세 내용을 입력하세요',
                  hintStyle: TextStyle(color: Color.fromARGB(255, 97, 95, 95)),
                ),
                maxLines: 5,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              if (contentController.text.trim().isNotEmpty) {
                Navigator.pop(context);
                // 여기에 할일 생성 메서드 호출
                _addNewTodo(contentController.text.trim());
              }
            },
            child: const Text('추가',
                style: TextStyle(color: AppTheme.primaryColor)),
          ),
        ],
      ),
    );
  }

  // 새 할일 추가 메서드
  void _addNewTodo(String content) {
    if (content.isNotEmpty) {
      widget.viewModel.addTodo(content);
      setState(() {
        // ui갱신
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
