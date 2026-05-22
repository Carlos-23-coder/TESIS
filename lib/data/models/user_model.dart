class User {

  final int? id;

  final String username;
  final String email;
  final String password;
  final String pin;
  final String role;

  User({
    this.id,
    required this.username,
    required this.email,
    required this.password,
    required this.pin,
    required this.role,
  });

  Map<String, dynamic> toMap() {

    return {

      'id': id,
      'username': username,
      'email': email,
      'password': password,
      'pin': pin,
      'role': role,
    };
  }

  factory User.fromMap(
    Map<String, dynamic> map,
  ) {

    return User(

      id: map['id'],

      username: map['username'],

      email: map['email'],

      password: map['password'],

      pin: map['pin'],

      role: map['role'],
    );
  }
}