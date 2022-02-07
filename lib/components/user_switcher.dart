import 'package:chemobile/cubits/auth_cubit.dart';
import 'package:chemobile/models/eln_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserSwitcher extends StatefulWidget {
  const UserSwitcher({Key? key}) : super(key: key);

  @override
  State<UserSwitcher> createState() => _UserSwitcherState();
}

class _UserSwitcherState extends State<UserSwitcher> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        return Expanded(
          child: ListView.custom(
            childrenDelegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                ElnUser user = state.knownElnUsers[index];

                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.account_circle, size: 48),
                    title: Text(user.fullName, textAlign: TextAlign.left),
                    subtitle: Text(
                      user.elnIdentifier,
                      textAlign: TextAlign.left,
                      textScaleFactor: 0.8,
                    ),
                    onTap: () => BlocProvider.of<AuthCubit>(context).loginFromUserList(user),
                  ),
                );
              },
              childCount: state.knownElnUsers.length,
            ),
          ),
        );
      },
    );
  }
}
