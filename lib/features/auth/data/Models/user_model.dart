// lib/features/auth/data/models/user_model.dart

import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.email,
    required super.name,
    required super.photoUrl,
    required super.isPremium,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
    uid: map['uid'] as String,
    email: map['email'] as String,
    name: map['name'] as String? ?? '',
    photoUrl: map['photoUrl'] as String? ?? '',
    isPremium: map['isPremium'] as bool? ?? false,
  );

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'email': email,
    'name': name,
    'photoUrl': photoUrl,
    'isPremium': isPremium,
  };

  factory UserModel.fromEntity(UserEntity e) => UserModel(
    uid: e.uid,
    email: e.email,
    name: e.name,
    photoUrl: e.photoUrl,
    isPremium: e.isPremium,
  );
}
