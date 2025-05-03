import 'package:flutter/material.dart';
import 'package:classify/ui/send_memo_to_ai/view_models/send_memo_to_ai_viewmodel.dart';
import 'package:classify/utils/top_level_setting.dart';

class SendMemoToAiScreen extends StatefulWidget {
  final SendMemoToAiViewModel _sendMemoToAiViewModel;
  final String? mode;

  const SendMemoToAiScreen({
    super.key,
    required SendMemoToAiViewModel sendMemoToAiViewModel,
    this.mode,
  }) : _sendMemoToAiViewModel = sendMemoToAiViewModel;

  @override
  State<SendMemoToAiScreen> createState() => _SendMemoToAiScreenState();
}

class _SendMemoToAiScreenState extends State<SendMemoToAiScreen> {
  final TextEditingController _memoController = TextEditingController();
  final FocusNode _memoFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 자동으로 키보드가 올라오도록 설정
      _memoFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _memoController.dispose();
    _memoFocusNode.dispose();
    super.dispose();
  }

  // 메모 저장 함수 - Optimistic UI 적용
  void _saveMemo() {
    final text = _memoController.text.trim();
    if (text.isEmpty) {
      return;
    }

    // 즉시 화면 닫기 (Optimistic UI)
    Navigator.pop(context);

    // 백그라운드에서 메모 처리 진행
    _processMemoInBackground(text);
  }

  // 백그라운드에서 메모 처리
  Future<void> _processMemoInBackground(String text) async {
    try {
      await widget._sendMemoToAiViewModel.sendMemoToAi(text, mode: widget.mode);

      // 현재 화면은 이미 닫혔으므로 다른 방식으로 피드백 제공 필요
      if (widget._sendMemoToAiViewModel.error != null) {
        // 필요시 에러 처리 로직 추가 (예: 글로벌 스낵바, 로깅 등)
        debugPrint("메모 저장 중 오류: ${widget._sendMemoToAiViewModel.error}");
      }
    } catch (e) {
      debugPrint("메모 저장 중 예외 발생: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('새 메모'),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _saveMemo,
            child: const Text(
              '저장',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.backgroundColor,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: TextField(
                controller: _memoController,
                focusNode: _memoFocusNode,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: const TextStyle(fontSize: 16),
                decoration: const InputDecoration(
                  hintText: '메모를 입력하세요...',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
            // 에러 메시지 표시
            ListenableBuilder(
              listenable: widget._sendMemoToAiViewModel,
              builder: (context, _) {
                final error = widget._sendMemoToAiViewModel.error;
                return error != null
                    ? Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          error,
                          style: const TextStyle(color: Colors.red),
                        ),
                      )
                    : const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}
