import 'package:blog_app/data/models/app_user.dart';
import 'package:blog_app/data/providers/auth_provider.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

const alice = AppUser(id: 'u1', username: 'alice', email: 'alice@example.com');

ParseError parseError(int code) => ParseError(code: code, message: 'serveur');

class FakeAuthProvider implements AuthProvider {
  Future<AppUser?> Function() onCurrentUser = () async => null;
  Future<AppUser> Function() onFetchCurrentUser = () async => alice;
  Future<AppUser> Function(String username, String password) onLogIn =
      (username, password) async => alice;
  Future<AppUser> Function(String username, String email, String password)
  onSignUp = (username, email, password) async =>
      AppUser(id: 'nouveau', username: username, email: email);
  Future<void> Function() onLogOut = () async {};

  final List<(String, String)> logInCalls = [];
  final List<(String, String, String)> signUpCalls = [];
  int logOutCalls = 0;
  int clearLocalSessionCalls = 0;

  @override
  Future<AppUser?> currentUser() => onCurrentUser();

  @override
  Future<AppUser> fetchCurrentUser() => onFetchCurrentUser();

  @override
  Future<AppUser> logIn({required String username, required String password}) {
    logInCalls.add((username, password));
    return onLogIn(username, password);
  }

  @override
  Future<AppUser> signUp({
    required String username,
    required String email,
    required String password,
  }) {
    signUpCalls.add((username, email, password));
    return onSignUp(username, email, password);
  }

  @override
  Future<void> logOut() {
    logOutCalls++;
    return onLogOut();
  }

  @override
  Future<void> clearLocalSession() async {
    clearLocalSessionCalls++;
  }
}
