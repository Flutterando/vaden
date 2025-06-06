import 'package:vaden_security/src/models/user_details.dart';

/// Defines the contract for loading user information,
/// given an identifier (usually the [username]).
///
/// In many applications, you will perform a database search
/// or use another service to find the [UserDetails].
abstract class UserDetailsService<T extends UserDetails> {
  /// Loads the user based on the [username]. Returns `null` if not found.
  Future<T?> loadUserByUsername(String username);
}
