import 'package:chemobile/app_theme.dart';
import 'package:chemobile/cubits/auth_cubit.dart';
import 'package:chemobile/cubits/ocr_result_cubit.dart';
import 'package:chemobile/cubits/archive_cubit.dart';
import 'package:chemobile/cubits/sample_tasks_cubit.dart';
import 'package:chemobile/screens/init_screen.dart';
import 'package:chemobile/screens/login_screen.dart';
import 'package:chemobile/screens/menu_screen.dart';
import 'package:chemobile/screens/user_switcher_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (context) => AuthCubit(),
          lazy: false,
        ),
        BlocProvider<OcrResultCubit>(create: (context) => OcrResultCubit()),
        BlocProvider<ArchiveCubit>(create: (context) => ArchiveCubit()),
        BlocProvider<SampleTasksCubit>(
          create: (context) => SampleTasksCubit(BlocProvider.of<AuthCubit>(context)),
        ),
      ],
      child: MaterialApp(
        title: 'Chemobile',
        theme: AppTheme.defaultTheme,
        home: const HomeScreenManager(),
      ),
    );
  }
}

class HomeScreenManager extends StatefulWidget {
  const HomeScreenManager({Key? key}) : super(key: key);

  @override
  State<HomeScreenManager> createState() => _HomeScreenManagerState();
}

class _HomeScreenManagerState extends State<HomeScreenManager> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        // print(state);
        if (state is AuthInitial) {
          return const InitScreen();
        } else if (state is AuthFromUserListPossible) {
          return const UserSwitcherScreen();
        } else if (state is AuthSuccess) {
          return const MenuScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
