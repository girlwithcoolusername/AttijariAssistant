class Utilisateur {
  final String username;
  final int userId;
  final String password;
  final bool isLoggedIn;

  Utilisateur({required this.userId, required this.username, required this.password, this.isLoggedIn = false});

  factory Utilisateur.fromMap(Map<String, dynamic> map) {
    return Utilisateur(
      userId: map['idUser'] as int,
      username: map['username'] as String,
      password: map['password'] as String,
      isLoggedIn: map.containsKey('isLoggedIn') ? map['isLoggedIn'] as bool : false,
    );
  }
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Utilisateur &&
        other.username == username &&
        other.userId == userId &&
        other.password == password &&
        other.isLoggedIn == isLoggedIn;
  }

  @override
  int get hashCode => username.hashCode ^ userId.hashCode ^ password.hashCode ^ isLoggedIn.hashCode;
  Map<String, dynamic> toMap() {
    return {
      'idUser': userId,
      'username': username,
      'password': password,
    };
  }
}
