import 'package:chemobile/components/user_switcher.dart';
import 'package:chemobile/cubits/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserSwitcherScreen extends StatelessWidget {
  const UserSwitcherScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: const Text('Available Users'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.delete,
              color: Colors.white,
            ),
            onPressed: () {
              _showAlertDialog(context);
            },
          )
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const <Widget>[
            UserSwitcher(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _authenticator(context).openLoginForm();
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  AuthCubit _authenticator(context) {
    return BlocProvider.of<AuthCubit>(context);
  }

  void _showAlertDialog(BuildContext context) {
    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = TextButton(
      child: const Text("Okay"),
      onPressed: () {
        Navigator.of(context).pop();
        _authenticator(context).reset();
      },
    );

    AlertDialog alert = AlertDialog(
      title: const Text("Are you sure?"),
      content: const Text("Would you like to delete all available users?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
