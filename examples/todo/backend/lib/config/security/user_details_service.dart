import 'package:vaden/vaden.dart';
import 'package:vaden_security/vaden_security.dart';

@Service()
class UserDetailsServiceImpl implements UserDetailsService {
  @override
  Future<User?> loadUserByUsername(String username) async {
    if (username == 'admin') {
      return User(
        id: '1',
        username: 'admin',
        password:
            r'$2a$10$ktlBXHpNp1RfiDJRzg9MZeMrHtrNZmIH/RwNNWB7a88DlpN7s/2SK', // 12345678
        roles: ['ROLE_ADMIN'],
      );
    } else if (username == 'user') {
      return User(
        id: '2',
        username: 'user',
        password:
            r'$2a$10$ktlBXHpNp1RfiDJRzg9MZeMrHtrNZmIH/RwNNWB7a88DlpN7s/2SK', //12345678
        roles: ['ROLE_USER'],
      );
    }

    return null;
  }
}

@DTO()
class User extends UserDetails {
  final String id;

  User({
    required this.id,
    required super.username,
    required super.password,
    required super.roles,
  });
}
