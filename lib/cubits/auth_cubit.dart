import 'package:chemobile/models/eln_user.dart';
import 'package:chemobile/services/login_service.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class AuthCubit extends HydratedCubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  ElnUser? currentUser() {
    return state.currentElnUser;
  }

  void init() {
    if (state.knownElnUsers.isNotEmpty) {
      emit(AuthFromUserListPossible(knownElnUsers: state.knownElnUsers));
    } else {
      emit(AuthImpossible());
    }
  }

  void openLoginForm() {
    emit(AuthFromFormPossible(knownElnUsers: state.knownElnUsers));
  }

  Future<void> loginFromForm(String identifier, String password, String elnUrl) async {
    emit(AuthInProgress(
      identifier: identifier,
      password: password,
      elnUrl: elnUrl,
      knownElnUsers: state.knownElnUsers,
    ));

    ElnUser authenticatedElnUser = await LoginService().authenticate(identifier, password, elnUrl);

    List<ElnUser> knownElnUsers = List<ElnUser>.from(state.knownElnUsers);
    // TODO: Refactor when remote api is available
    knownElnUsers.removeWhere((u) =>
        u.elnUrl == authenticatedElnUser.elnUrl &&
        u.firstName == authenticatedElnUser.firstName &&
        u.lastName == authenticatedElnUser.lastName);

    knownElnUsers.insert(0, authenticatedElnUser);

    emit(AuthSuccess(
      authenticatedElnUser: authenticatedElnUser,
      knownElnUsers: knownElnUsers,
    ));
  }

  void loginFromUserList(ElnUser authenticatedElnUser) {
    emit(AuthSuccess(
      authenticatedElnUser: authenticatedElnUser,
      knownElnUsers: state.knownElnUsers,
    ));
  }

  void logout() {
    if (state.knownElnUsers.isEmpty) {
      emit(AuthFromFormPossible(knownElnUsers: state.knownElnUsers));
    } else {
      emit(AuthFromUserListPossible(knownElnUsers: state.knownElnUsers));
    }
  }

  void reset() {
    emit(AuthInitial());
  }

  @override
  AuthState fromJson(Map<String, dynamic> json) {
    List<dynamic> usersFromJson = json['knownElnUsers'] as List<dynamic>;
    List<ElnUser> knownElnUsers = usersFromJson.map<ElnUser>((u) => ElnUser.fromJson(u)).toList();
    return AuthInitial(knownElnUsers: knownElnUsers);
  }

  @override
  Map<String, dynamic> toJson(AuthState state) {
    return {
      "knownElnUsers": state.knownElnUsers.map((u) => u.toJson()).toList(),
    };
  }
}

class AuthState {
  final ElnUser? currentElnUser;
  final List<ElnUser> knownElnUsers;

  AuthState({
    required this.currentElnUser,
    this.knownElnUsers = const [],
  });
}

class AuthInitial extends AuthState {
  AuthInitial({
    List<ElnUser> knownElnUsers = const [],
  }) : super(
          currentElnUser: null,
          knownElnUsers: knownElnUsers,
        );
}

class AuthImpossible extends AuthState {
  AuthImpossible() : super(currentElnUser: null, knownElnUsers: []);
}

class AuthFromFormPossible extends AuthState {
  AuthFromFormPossible({
    required List<ElnUser> knownElnUsers,
  }) : super(
          currentElnUser: null,
          knownElnUsers: knownElnUsers,
        );
}

class AuthFromUserListPossible extends AuthState {
  AuthFromUserListPossible({
    required List<ElnUser> knownElnUsers,
  }) : super(
          currentElnUser: null,
          knownElnUsers: knownElnUsers,
        );
}

class AuthInProgress extends AuthState {
  String identifier;
  String password;
  String elnUrl;

  AuthInProgress({
    required this.identifier,
    required this.password,
    required this.elnUrl,
    required List<ElnUser> knownElnUsers,
  }) : super(currentElnUser: null, knownElnUsers: knownElnUsers);
}

class AuthSuccess extends AuthState {
  AuthSuccess({
    required ElnUser authenticatedElnUser,
    required List<ElnUser> knownElnUsers,
  }) : super(currentElnUser: authenticatedElnUser, knownElnUsers: knownElnUsers);
}

class AuthFailure extends AuthState {
  AuthFailure() : super(currentElnUser: null);
}
