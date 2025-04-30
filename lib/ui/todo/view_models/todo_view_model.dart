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

  TodoViewModel({required MemoRepository memoRepository})
      : _memoRepository = memoRepository,
        _isLoading = false,
        _error = null;

  //GETTER
  List<MemoModel> get todoList => _todoList;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get todoCount => _todoList.length;

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

    // 목록으로 변환(기본 최신순으로 정렬)
    _todoList = _todoItems.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    debugPrint('할일 데이터 업데이트 : ${_todoList.length}개');
  }

  // 할일 삭제
  Future<void> deleteTodo(String todoId) async {
    try {
      await _memoRepository.deleteMemo(todoId);
      debugPrint('할일 삭제 완료 : ${todoId}');
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      debugPrint('할일 삭제 오류: $e');
    }
  }

  // 스트림 설정 및 연결
  void _setUpTodoStream() {
    _todoStream = _memoRepository.watchMemoLocal();
    _todoStream.listen((memos) {
      _processTodoData(memos);
      notifyListeners();
    });
  }

  // 정렬 (최신순)
  void sortByLatest() {
    _todoList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    notifyListeners();
  }

  // 정렬 (오래된순)
  void sortByOldest() {
    _todoList.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    notifyListeners();
  }
}
