import 'package:classify/data/repositories/memo/memo_repository.dart';
import 'package:classify/data/services/gemini_service.dart';
import 'package:classify/data/services/firestore_service.dart';
import 'package:classify/data/services/hive_service.dart';
import 'package:classify/domain/models/memo/memo_model.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

/*
  [기본 가이드]
  MemoRepository에서는 [데이터 변환이 빈번하게 발생]하므로 아래 개념을 정확히 이해해야 함:
   - Map: 키-값 쌍을 저장하는 자료구조
   - map(): 데이터를 변환하는 메서드(원본 데이터는 유지되고 새로운 컬렉션 반환)
   - Entry: Map의 각 키-값 쌍을 나타내는 단위
   예: map.entries.map((e) => ...) 
      => Map 자료구조의 각 Entry에 대해 map 메서드가 인자로 받는 변환 함수 적용
*/

/*
  [메모 CURD 시 주의사항]
  - 메모 삭제 시 카테고리가 'AI분류 실패'인 경우 애초에 서버로 동기화를 하지 않음.
  - 따라서 삭제 시 카테고리가 'AI분류 실패'인 경우 서버와의 상호작용은 막아놓았음.
  */


class MemoRepositoryRemote extends MemoRepository {
  final GeminiService _geminiService;
  final FirestoreService _firestoreService;
  final HiveService _hiveService;
  List<String> _categories = [];

  MemoRepositoryRemote({
    required GeminiService geminiService,
    required FirestoreService firestoreService,
    required HiveService hiveService,
  })  : _geminiService = geminiService,
        _firestoreService = firestoreService,
        _hiveService = hiveService {
    _initCategories();
  }

  Future<void> _initCategories() async {
    try {
      _categories = _hiveService.getCategories();

      // 카테고리가 비어있을 경우 기본 카테고리 생성
      if (_categories.isEmpty) {
        debugPrint("⚠️ 카테고리가 비어있어 기본 카테고리를 생성합니다.");
        _hiveService.createCategoryWhenSignup();
        _categories = _hiveService.getCategories();
      }

      debugPrint("📋 현재 카테고리 목록: $_categories");
    } catch (e) {
      debugPrint(
          "❌ 카테고리 초기화 실패 in [_initCategories method] in [memo_repository_remote]: $e");
      // 기본 카테고리 설정
      _categories = ["공부", "아이디어", "참조", "회고"];
    }
  }

  @override
  Future<String?> analyzeAndSaveMemo(String memo) async {
    try {
      String uuid = const Uuid().v4();
      MemoModel analyzedMemo =
          await _geminiService.analyzeMemo(memo, _categories, uuid);
      debugPrint('🔍 분류된 메모: ${analyzedMemo.category}');
      debugPrint('🔍 분류된 메모: ${analyzedMemo.title}');
      debugPrint('🔍 분류된 메모: ${analyzedMemo.content}');

      _hiveService.saveMemo(analyzedMemo, uuid);
      debugPrint('✅ 하이브 저장 완료');
      if (analyzedMemo.category == 'AI분류 실패') {
        return "AI분류 실패";
      }
      _firestoreService.saveMemo(analyzedMemo, uuid);
      debugPrint('✅ 파이어스토어 저장 완료');
      return null;
    } catch (e) {
      debugPrint(
          '❌ 메모 분석 및 저장 중 오류 in [analyzeAndSaveMemo method] in [memo_repository_remote]: $e');
      return e.toString();
    }
  }

  @override
  Future<String?> reAnalyzeAndSaveMemo(String memo, String uuid) async {
    try {
      MemoModel reAnalyzedMemo =
          await _geminiService.analyzeMemo(memo, _categories, uuid);
      debugPrint('🔍 재분류된 메모: ${reAnalyzedMemo.category}');
      debugPrint('🔍 재분류된 메모: ${reAnalyzedMemo.title}');
      debugPrint('🔍 재분류된 메모: ${reAnalyzedMemo.content}');

      _hiveService.saveMemo(reAnalyzedMemo, uuid);
      debugPrint('✅ 하이브 저장 완료');
      if (reAnalyzedMemo.category == 'AI분류 실패') {
        return "AI분류 실패";
      }
      _firestoreService.saveMemo(reAnalyzedMemo, uuid);
      debugPrint('✅ 파이어스토어 저장 완료');
      return null;
    } catch (e) {
      debugPrint(
          '❌ 메모 재분석 및 저장 중 오류 in [reAnalyzeAndSaveMemo method] in [memo_repository_remote]: $e');
      return e.toString();
    }
  }

  @override
  Stream<Map<String, MemoModel>> watchMemoLocal() {
    return _hiveService.watchMemos().map((map) {
      return Map.fromEntries(
        map.entries.map((e) {
          final memo = e.value as MemoModel; // Hive에서 가져온 value를 MemoModel로 캐스팅
          return MapEntry(
            e.key.toString(),
            memo.copyWith(),
          );
        }),
      );
    }).asBroadcastStream();
  }

  @override
  Future<void> deleteMemo(String memoId, String category) async {
    try {
      _hiveService.deleteMemo(memoId, category);
      debugPrint('✅ 하이브에서 삭제 완료');
      if (category == 'AI분류 실패') {
        return;
      }
      await _firestoreService.deleteMemo(memoId);
      debugPrint('✅ firestore에서 삭제 완료');
    } catch (e) {
      debugPrint(
          '❌ 메모 삭제 실패 in [deleteMemo method] in [memo_repository_remote]: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateMemo(MemoModel memo) async {
    try {
      // Hive에 저장
      _hiveService.saveMemo(memo, memo.memoId);
      debugPrint('✅ 하이브 업데이트 완료');

      // Firestore에 저장
      await _firestoreService.saveMemo(memo, memo.memoId);
      debugPrint('✅ 파이어스토어 업데이트 완료');
    } catch (e) {
      debugPrint(
          '❌ 메모 업데이트 실패 in [updateMemo method] in [memo_repository_remote]: $e');
      rethrow; // 에러를 상위로 전달
    }
  }

  @override
  Map<String, MemoModel> getMemos() {
    final rawMemos = _hiveService.getMemos();
    return rawMemos
        .map((key, value) => MapEntry(key.toString(), value as MemoModel));
  }

  @override
  Future<void> syncFromServer() async {
    try {
      // Firestore에서 메모 및 카테고리 가져오기
      final memos = await _firestoreService.getUserMemos();
      final categories = await _firestoreService.getUserCategories();

      // Hive에 데이터 동기화
      _hiveService.syncMemosFromServer(memos);
      _hiveService.syncCategoriesFromServer(categories);
      debugPrint('✅ 서버에서 동기화 완료');
    } catch (e) {
      debugPrint(
          '❌ 서버에서 동기화 실패 in [syncFromServer method] in [memo_repository_remote]: $e');
      rethrow;
    }
  }
}
