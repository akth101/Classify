import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

//android or ios 인식해서 그에 맞게 UI를 그려줌
class PlatformWidget extends StatelessWidget {
  final WidgetBuilder androidBuilder;
  final WidgetBuilder iosBuilder;

  const PlatformWidget({
    super.key,
    required this.androidBuilder,
    required this.iosBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Theme.of(context).platform == TargetPlatform.iOS
        ? iosBuilder(context)
        : androidBuilder(context);
  }
}

//최상위 앱 테마를 설정
class AppTheme {
  // 메인 컬러
  static const Color primaryColor = Color(0xFF2E7D32); // 깊은 초록색 - 앱의 기본 브랜드 색상
  static const Color secondaryColor1 =
      Color(0xFF388E3C); // 미디엄 초록색 - 메인 컬러보다 약간 밝은 변형
  static const Color secondaryColor2 =
      Color(0xFF00796B); // 티얼 그린 - 푸른 기가 살짝 도는 초록색
  static const Color accentColor = Color(0xFF8BC34A); // 라임 그린 - 강조가 필요한 요소에 사용

  // 배경 및 장식 컬러
  static const Color backgroundColor = Color(0xFFFFFFFF); // 화이트 - 기본 배경 색상
  static const Color subBackgroundColor =
      Color(0xFFF1F8E9); // 연한 연두색 - 구분이 필요한 섹션이나 카드에 사용
  static const Color decorationColor1 =
      Color(0xFFC8E6C9); // 연한 민트색 - 경계선, 분리선 등에 사용
  static const Color decorationColor2 =
      Color(0xFF81C784); // 밝은 초록색 - 진행 바, 활성 아이콘 등에 사용

  // 텍스트 및 기능 컬러
  static const Color textColor1 = Color(0xFF212121); // 거의 검은색 - 주요 텍스트에 사용
  static const Color textColor2 =
      Color(0xFF757575); // 중간 회색 - 부가 설명이나 덜 중요한 텍스트에 사용
  static const Color darkAccentColor =
      Color(0xFF4CAF50); // 표준 초록색 - 다크 모드에서 사용할 밝은 액센트
  static const Color errorColor =
      Color(0xFFFF5722); // 딥 오렌지 - 오류 메시지나 중요 알림에 사용

  // 테마 설정
  static final ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor1,
      error: errorColor,
      surface: subBackgroundColor,
    ),
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: CardTheme(
      color: backgroundColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: subBackgroundColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: decorationColor1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: decorationColor1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: primaryColor),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    textTheme: TextTheme(
      titleLarge: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textColor1,
      ),
      titleMedium: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: textColor1,
      ),
      bodyLarge: const TextStyle(
        fontSize: 16,
        color: textColor1,
      ),
      bodyMedium: const TextStyle(
        fontSize: 14,
        color: textColor1,
      ),
      bodySmall: const TextStyle(
        fontSize: 12,
        color: textColor1,
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryColor;
        }
        return Colors.transparent;
      }),
      side: const BorderSide(color: secondaryColor1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: decorationColor1,
      thickness: 1,
    ),
  );
}

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appTitle': 'My App',
      'hello': 'Hello World!',
    },
    'ko': {
      'appTitle': '내 앱',
      'hello': '안녕하세요!',
    },
  };

  String get appTitle => _localizedValues[locale.languageCode]!['appTitle']!;
  String get hello => _localizedValues[locale.languageCode]!['hello']!;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ko'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
