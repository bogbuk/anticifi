import 'package:equatable/equatable.dart';

class UserProfileEntity extends Equatable {
  final String id;
  final String email;
  final String name;
  final String currency;
  final String locale;
  final bool notificationsEnabled;
  final String theme;
  final String plan;
  final DateTime createdAt;

  const UserProfileEntity({
    required this.id,
    required this.email,
    required this.name,
    required this.currency,
    required this.locale,
    required this.notificationsEnabled,
    required this.theme,
    required this.plan,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        currency,
        locale,
        notificationsEnabled,
        theme,
        plan,
        createdAt,
      ];
}
