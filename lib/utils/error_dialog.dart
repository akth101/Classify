import 'package:flutter/material.dart';

class ErrorDialog extends StatelessWidget {
  final String? message;
  const ErrorDialog({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      key: key,
      content: Text(message!),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Center(
            child: Text("확인", style: TextStyle(color: Colors.white),),
          ),
        ),
      ],
    );
  }
}
