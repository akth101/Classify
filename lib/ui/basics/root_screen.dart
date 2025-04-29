import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:classify/routing/routes.dart';
import 'package:classify/utils/top_level_setting.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key, required this.child});
  final Widget child;
  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _selectedIndex = 0; // 오늘을 기본값으로 설정 (이제 0번 인덱스)

  @override
  void initState() {
    super.initState();
    debugPrint("✅ 루트 스크린 초기화");
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      switch (index) {
        case 0:
          context.go(Routes.today);
          break;
        case 1:
          context.go(Routes.archive);
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: TextButton(
          onPressed: () {
            // 할일 페이지로 이동
            context.push(Routes.archive);
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            "할일",
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              context.push(Routes.search);
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              context.push(Routes.setting);
            },
          ),
        ],
      ),
      body: widget.child,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push(Routes.sendMemo);
        },
        backgroundColor: AppTheme.accentColor,
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: Colors.white,
        elevation: 8,
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: IconButton(
                  icon: Icon(
                    Icons.today,
                    color: _selectedIndex == 0
                        ? AppTheme.primaryColor
                        : AppTheme.textColor2,
                    size: 26,
                  ),
                  tooltip: '오늘',
                  onPressed: () => _onItemTapped(0),
                ),
              ),
              const SizedBox(width: 48), // FAB 공간
              Expanded(
                child: IconButton(
                  icon: Icon(
                    Icons.archive,
                    color: _selectedIndex == 1
                        ? AppTheme.primaryColor
                        : AppTheme.textColor2,
                    size: 26,
                  ),
                  tooltip: '보관함',
                  onPressed: () => _onItemTapped(1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
