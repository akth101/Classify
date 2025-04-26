import 'package:go_router/go_router.dart';
import 'package:classify/routing/routes.dart';
import 'package:classify/ui/basics/root_screen.dart';
import 'package:classify/ui/auth/login/widgets/login_screen.dart';
import 'package:classify/ui/auth/signup/widgets/signup_screen.dart';
import 'package:classify/ui/setting/widgets/setting_screen.dart';
import 'package:classify/ui/auth/login/view_models/login_viewmodel.dart';
import 'package:classify/ui/auth/signup/view_models/signup_viewmodel.dart';
import 'package:classify/data/repositories/auth/auth_repository_remote.dart';
import 'package:provider/provider.dart';
import 'package:classify/data/repositories/memo/memo_repository_remote.dart';
import 'package:classify/ui/archive/archive_view/view_models/archive_view_model.dart';
import 'package:classify/ui/archive/archive_view/widgets/archive_view_screen.dart';
import 'package:classify/ui/send_memo_to_ai/widgets/send_memo_to_ai_screen.dart';
import 'package:classify/global/global.dart';
import 'package:classify/ui/send_memo_to_ai/view_models/send_memo_to_ai_viewmodel.dart';
import 'package:classify/ui/search/view/search_screen.dart';
import 'package:classify/ui/search/view_model/search_view_model.dart';
import 'package:classify/ui/setting/view_models/setting_viewmodel.dart';
import 'package:classify/ui/today_act/view/today_act_screen.dart';
import 'package:classify/ui/today_act/view_models/today_act_view_model.dart';

final router = GoRouter(
  initialLocation: firebaseAuth.currentUser != null ? Routes.today : Routes.login,
  routes: [
    ShellRoute(
        builder: (context, state, child) => MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (context) => SendMemoToAiViewModel(
          memoRepository: context.read<MemoRepositoryRemote>(),
        ),
      ),
      ChangeNotifierProvider(
        create: (context) => ArchiveViewModel(
          memoRepository: context.read<MemoRepositoryRemote>(),
        ),
      ),
      ChangeNotifierProvider(
        create: (context) => TodayActViewModel(
          memoRepository: context.read<MemoRepositoryRemote>(),
        ),
      ),
    ],
    child: RootScreen(child: child),
  ),
      routes: [
        GoRoute(
          path: Routes.today,
          builder: (context, state) => TodayActScreen(
            viewModel: context.read<TodayActViewModel>(),
          ),
        ),
        GoRoute(
          path: Routes.archive,
          builder: (context, state) => ArchiveScreen(
            viewModel: context.read<ArchiveViewModel>(),
          ),
        ),
      ],
    ),
    // 독립적인 전체 화면 라우트들
    GoRoute(
      path: Routes.sendMemo,
      builder: (context, state) => SendMemoToAiScreen(
        sendMemoToAiViewModel: SendMemoToAiViewModel(
          memoRepository: context.read<MemoRepositoryRemote>(),
        ),
      ),
    ),
    GoRoute(
      path: Routes.setting,
      builder: (context, state) => SettingScreen(
        viewModel: SettingViewModel(
          authRepository: context.read<AuthRepositoryRemote>(),
        ),
      ),
    ),
    GoRoute(
      path: Routes.search,
      builder: (context, state) => SearchScreen(
        viewModel: SearchViewModel(
          memoRepository: context.read<MemoRepositoryRemote>(),
        ),
      ),
    ),
    GoRoute(
      path: Routes.login,
      builder: (context, state) => LoginScreen(
        viewModel: LoginViewModel(
          authRepository: context.read<AuthRepositoryRemote>(),
        ),
      ),
    ),
    GoRoute(
      path: Routes.signup,
      builder: (context, state) => SignupScreen(
        viewModel: SignUpViewModel(
          authRepository: context.read<AuthRepositoryRemote>(),
        ),
      ),
    ),
  ],
);