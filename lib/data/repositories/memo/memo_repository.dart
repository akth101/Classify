import 'package:flutter/material.dart';
import 'package:classify/domain/models/memo/memo_model.dart';

abstract class MemoRepository extends ChangeNotifier {
  Future<String?> analyzeAndSaveMemo(String memo, {String? mode});

  Stream<Map<String, MemoModel>> watchMemoLocal();

  Future<void> deleteMemo(String memoId);

  Future<void> updateMemo(MemoModel memo);

  Map<String, MemoModel> getMemos();

  Future<void> syncFromServer();
}
