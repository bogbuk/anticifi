import 'package:equatable/equatable.dart';

class UserProfileEntity extends Equatable {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String currency;
  final String locale;
  final bool notificationsEnabled;
  final String theme;
  final bool onboardingCompleted;
  final DateTime createdAt;

  const UserProfileEntity({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.currency,
    required this.locale,
    required this.notificationsEnabled,
    required this.theme,
    this.onboardingCompleted = false,
    required this.createdAt,
  });

  String get fullName {
    final name = '$firstName $lastName'.trim();
    return name.isEmpty ? email : name;
  }

  @override
  List<Object?> get props => [
        id,
        email,
        firstName,
        lastName,
        currency,
        locale,
        notificationsEnabled,
        theme,
        onboardingCompleted,
        createdAt,
      ];
}
