import 'package:equatable/equatable.dart';

class AppUser extends Equatable {
  const AppUser({required this.id, required this.username, this.email});

  final String id;
  final String username;
  final String? email;

  @override
  List<Object?> get props => [id, username, email];
}
