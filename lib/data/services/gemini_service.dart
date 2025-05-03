import 'package:flutter/material.dart';
import 'package:classify/domain/models/memo/memo_model.dart';
import 'dart:convert';
import 'package:cloud_functions/cloud_functions.dart';

class GeminiService {
  final FirebaseFunctions _functions;

  GeminiService() : _functions = FirebaseFunctions.instance;

  Future<MemoModel> analyzeMemo(
      String memoText, List<String> categories, String memoId,
      {String? mode}) async {
    try {
      debugPrint('🔍 분류 기준: $categories');
      debugPrint('🟢🔍 모드 : ${mode}🟢');

      // mode가 'todo'인 경우
      bool isTodoMode = mode == 'todo';
      if (isTodoMode) {
        debugPrint('🟢 할일 모드로 감지');
      }

      // Firebase Functions SDK의 httpsCallable 사용
      final callable = _functions.httpsCallable(
        'analyzeMemo',
        options: HttpsCallableOptions(
          timeout: const Duration(seconds: 30),
        ),
      );

      // 함수 호출을 위한 데이터 준비
      final Map<String, dynamic> requestData = {
        'memoText': memoText,
        'categories': categories,
      };

      // mode 값 추가
      if (mode != null) {
        requestData['mode'] = mode;
      }

      // 함수 호출
      final response = await callable(requestData);
      final data = response.data;
      // 응답 파싱
      Map<String, dynamic> parsedResponse;
      try {
        if (data is Map<String, dynamic>) {
          parsedResponse = data;
        } else if (data is String) {
          parsedResponse = jsonDecode(data);
        } else {
          throw Exception('예상치 못한 응답 형식');
        }
      } catch (e) {
        debugPrint('⚠️ JSON 파싱 오류: $e');
        parsedResponse = {
          "category": "할 일",
          "title": "기본 제목",
          "content": memoText,
          "tags": [],
          "question": ""
        };
      }

      // null 체크 및 기본값 설정
      // final String category = parsedResponse['category'] as String? ??
      //     (categories.isNotEmpty ? categories.first : "할 일");
      String category;

      // 할일 모드인 경우, 카테고리를 '할 일'로 강제 설정
      if (isTodoMode) {
        category = '할 일';
        debugPrint('🟢 할일 모드 : 카테고리를 "할 일"로 설정했습니다');
      } else {
        category = parsedResponse['category'] as String? ??
            (categories.isNotEmpty ? categories.first : "할 일");
      }

      final String title = parsedResponse['title'] as String? ?? "기본 제목";
      final String memoContent =
          parsedResponse['content'] as String? ?? memoText;

      // tags가 null이거나 List<dynamic>이 아닌 경우 빈 배열 사용
      List<String> tags = [];
      if (parsedResponse['tags'] != null && parsedResponse['tags'] is List) {
        tags = List<String>.from((parsedResponse['tags'] as List)
            .map((item) => item?.toString() ?? "")
            .toList());
      }

      MemoModel memo = MemoModel(
          memoId: memoId,
          category: category,
          title: title,
          content: memoContent,
          tags: tags,
          isImportant: false,
          lastModified: DateTime.now(),
          createdAt: DateTime.now());

      if (category == '할 일') {
        memo = memo.copyWith(isDone: false);
        debugPrint('🟢할일 메모로 설정됨 : isDone = false');
      }

      if (category == '공부') {
        memo = memo.copyWith(
            question: parsedResponse['question'] as String? ?? "");
      }

      debugPrint('✅ 메모 분류 완료 : ${category}');
      return memo;
    } catch (e) {
      debugPrint('❌ 메모 분류 중 일반 오류 발생: $e');

      // 오류 발생 시 기본 MemoModel 반환
      final defaultCategory = mode == 'todo'
          ? "할 일"
          : (categories.isNotEmpty ? categories.first : "할 일");

      debugPrint('⚠️ 오류 발생으로 기본값 사용: 카테고리 = $defaultCategory');

      return MemoModel(
          memoId: memoId,
          // category: (categories.isNotEmpty ? categories.first : "할 일"),
          category: defaultCategory,
          title: "처리 실패한 메모",
          content: memoText,
          tags: [],
          isImportant: false,
          lastModified: DateTime.now(),
          createdAt: DateTime.now(),
          // isDone: false,
          isDone: defaultCategory == "할 일" ? false : null);
    }
  }
}
