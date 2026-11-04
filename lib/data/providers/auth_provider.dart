import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../models/app_user.dart';

class AuthProvider {
  Future<AppUser?> currentUser() async {
    final storedUser = await _storedParseUser();
    return storedUser == null ? null : _toAppUser(storedUser);
  }

  Future<AppUser> fetchCurrentUser() async {
    final storedUser = await _storedParseUser();
    if (storedUser == null || storedUser.sessionToken == null) {
      throw ParseError(
        code: ParseError.invalidSessionToken,
        message: 'Aucune session enregistrée.',
      );
    }
    return _userFromResponse(await storedUser.getUpdatedUser());
  }

  Future<AppUser> logIn({
    required String username,
    required String password,
  }) async {
    final response = await ParseUser.createUser(username, password).login();
    return _userFromResponse(response);
  }

  Future<AppUser> signUp({
    required String username,
    required String email,
    required String password,
  }) async {
    final response = await ParseUser.createUser(
      username,
      password,
      email,
    ).signUp();
    return _userFromResponse(response);
  }

  Future<void> logOut() async {
    final storedUser = await _storedParseUser();
    if (storedUser == null) {
      return;
    }
    final response = await storedUser.logout();
    if (!response.success) {
      throw response.error ?? ParseError();
    }
  }

  Future<void> clearLocalSession() async {
    final storedUser = await _storedParseUser();
    if (storedUser == null) {
      return;
    }
    storedUser.forgetLocalSession();
    await storedUser.deleteLocalUserData();
  }

  Future<ParseUser?> _storedParseUser() async {
    final storedUser = await ParseUser.currentUser();
    return storedUser is ParseUser ? storedUser : null;
  }

  AppUser _userFromResponse(ParseResponse response) {
    final result = response.result;
    if (!response.success || result is! ParseUser) {
      throw response.error ??
          StateError('La réponse du serveur ne contient pas d’utilisateur.');
    }
    return _toAppUser(result);
  }

  AppUser _toAppUser(ParseUser user) {
    return AppUser(
      id: user.objectId ?? '',
      username: user.username ?? '',
      email: user.emailAddress,
    );
  }
}
