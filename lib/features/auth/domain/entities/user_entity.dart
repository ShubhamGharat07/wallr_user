// lib/features/auth/domain/entities/user_entity.dart

import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String uid;
  final String email;
  final String name;
  final String photoUrl;
  final bool isPremium;

  const UserEntity({
    required this.uid,
    required this.email,
    required this.name,
    required this.photoUrl,
    required this.isPremium,
  });

  @override
  List<Object> get props => [uid, email, name, photoUrl, isPremium];
}
