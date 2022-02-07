import 'package:chemobile/cubits/auth_cubit.dart';
import 'package:chemobile/helpers/snack_bar.dart';
import 'package:chemobile/models/exception.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _elnUrlController = TextEditingController();

  String? _validateUsername(String? value) {
    return (value == null || value.isEmpty) ? 'Please enter your email or name abbreviation' : null;
  }

  String? _validatePassword(String? value) {
    return (value == null || value.isEmpty) ? 'Please enter your password' : null;
  }

  String? _validateElnUrl(String? value) {
    return (value == null || value.isEmpty) ? 'Please enter the URL of your ELN instance' : null;
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    _elnUrlController.dispose();
    super.dispose();
  }

  bool _formValid() {
    return _formKey.currentState!.validate();
  }

  Future<void> _initiateLogin(context) async {
    try {
      await BlocProvider.of<AuthCubit>(context).loginFromForm(
        _identifierController.text,
        _passwordController.text,
        _elnUrlController.text,
      );
    } on ChemobileException catch (exception) {
      showSnackBar(context, exception.message);
    } on ClientException catch (exception) {
      showSnackBar(context, exception.message);
    }
  }

  InputDecoration _inputDecoration(String label, {String? placeholder}) {
    return InputDecoration(
      border: const OutlineInputBorder(),
      labelText: label,
      hintText: placeholder,
    );
  }

  @override
  Widget build(BuildContext context) {
    AuthState authState = BlocProvider.of<AuthCubit>(context).state;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            key: const Key('elnUrlInput'),
            controller: _elnUrlController,
            decoration: _inputDecoration('ELN Url', placeholder: 'http://chemotion-eln.com'),
            validator: _validateElnUrl,
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 4.0)),
          TextFormField(
            key: const Key('userIdentifierInput'),
            controller: _identifierController,
            decoration: _inputDecoration('Username'),
            validator: _validateUsername,
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 4.0)),
          TextFormField(
            key: const Key('passwordInput'),
            controller: _passwordController,
            decoration: _inputDecoration('Password'),
            obscureText: true,
            validator: _validatePassword,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                OutlinedButton(
                  onPressed: () {
                    // Validate will return true if the form is valid, or false if
                    // the form is invalid.
                    if (_formValid()) {
                      _initiateLogin(context);
                    }
                  },
                  child: const Text('Login'),
                ),
                if (authState.knownElnUsers.isNotEmpty) ...[
                  OutlinedButton(
                    onPressed: () {
                      BlocProvider.of<AuthCubit>(context).logout();
                    },
                    child: const Text('Cancel'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
