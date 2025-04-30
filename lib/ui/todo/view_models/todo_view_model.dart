import 'dart:math';

import 'package:classify/data/repositories/memo/memo_repository.dart';
import 'package:classify/domain/models/memo/memo_model.dart';
import 'package:flutter/material.dart';

class TodoViewModel extends ChangeNotifier {
  final MemoRepository _memoRepository;
  late Stream<Map<String, MemoModel>> _todoStream;
  Map<String, MemoModel> _todoItems = {};
  List<MemoModel> _todoList = [];
  bool _isLoading = false;
  String? _error;
  bool _isLatestSort = false;
  String _currentState = 'In Progress';
  final List<String> _availableStatuses = ['In Progress', 'Completed'];

  TodoViewModel({required MemoRepository memoRepository})
      : _memoRepository = memoRepository,
        _isLoading = false,
        _error = null;

  List<MemoModel> get todoList => _todoList;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get todoCount => _todoList.length;
  String get currentStatus => _currentState;
  List<String> get availableStatuses => _availableStatuses;

  // 상태 변경
  void changeStatus(String status) {
    if (_currentState != status && _availableStatuses.contains(status)) {
      _currentState = status;
      _filterTodoList();
      notifyListeners();
    }
  }

  Future<void> loadTodoData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 모든 메모 가져온 후, '할일' 카테고리만 필터링 (추후 분리예정)
      final allMemos = _memoRepository.getMemos();
      _processTodoData(allMemos);

      // 스트림 연결 + 실시간 업데이트
      _setUpTodoStream();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      debugPrint('할일 데이터 로드 오류: $e');
    }
  }

  // 할일 데이터 처리
  void _processTodoData(Map<String, MemoModel> memos) {
    _todoItems = Map.fromEntries(
        memos.entries.where((entry) => entry.value.category == '할 일'));

    // 현재 선택된 상태에 따라 필터링
    _filterTodoList();

    debugPrint('할일 데이터 업데이트: ${_todoList.length}개 (상태: $currentStatus)');
  }

  // 상태에 따른 할일 목록 필터링
  void _filterTodoList() {
    if (_currentState == 'In Progress') {
      // 진행중인 할일
      _todoList =
          _todoItems.values.where((memo) => memo.isDone == false).toList();
    } else {
      _todoList =
          _todoItems.values.where((memo) => memo.isDone == true).toList();
    }

    // 정렬 적용
    if (_isLatestSort) {
      _todoList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else {
      _todoList.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    }
  }

  // 할일 상태 변경
  Future<void> toggleTodoStatus(MemoModel todo) async {
    try {
      // 상태 반전
      final updatedTodo =
          todo.copyWith(isDone: todo.isDone == true ? false : true);

      // 저장소 업데이트
      await _memoRepository.updateMemo(updatedTodo);

      // 로컬 데이터는 스트림 업데이트로 자동 갱신됨
      debugPrint('할일 상태 변경: ${todo.memoId}, isDone: ${updatedTodo.isDone}');
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      debugPrint('할일 상태 변경 오류: $e');

      // 3초 후 에러 메시지 제거
      Future.delayed(const Duration(seconds: 3), () {
        _error = null;
        notifyListeners();
      });
    }
  }

  // 할일 삭제
  Future<void> deleteTodo(String todoId) async {
    try {
      await _memoRepository.deleteMemo(todoId);
      _todoItems.remove(todoId);
      _filterTodoList();
      notifyListeners();
      debugPrint('할일 삭제 완료 : ${todoId}');
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      debugPrint('할일 삭제 오류: $e');

      Future.delayed(const Duration(seconds: 3), () {
        _error = null;
        notifyListeners();
      });
    }
  }

  // 스트림
  void _setUpTodoStream() {
    _todoStream = _memoRepository.watchMemoLocal();
    _todoStream.listen((memos) {
      _processTodoData(memos);
      notifyListeners();
    });
  }

  // 정렬 (최신순)
  void sortByLatest() {
    _isLatestSort = true;
    _todoList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    notifyListeners();
  }

  // 정렬 (오래된순)
  void sortByOldest() {
    _isLatestSort = false;
    _todoList.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    notifyListeners();
  }
}
