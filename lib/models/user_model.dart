class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role; // 'admin' or 'user'
  final String photo;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.photo,
  });

  // Convert to Map for Firestore/SharedPreferences
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      'photo': photo,
    };
  }

  // Create from Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'user',
      photo: map['photo'] ?? 'https://api.dicebear.com/7.x/adventurer/svg?seed=User',
    );
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? role,
    String? photo,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      photo: photo ?? this.photo,
    );
  }
}
