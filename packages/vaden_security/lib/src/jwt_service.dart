import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:vaden/vaden.dart';
import 'package:vaden_security/src/models/tokenization.dart';
import 'package:vaden_security/src/models/user_details.dart';

/// Responsible for generating and verifying JWT tokens.
/// Focuses on two main methods:
/// 1) [generateToken]: Creates a JWT token based on [UserDetails].
/// 2) [verifyToken]: Validates a JWT token and returns the claims if valid.
class JwtService {
  final String secret;
  final Duration tokenValidity;
  final Duration refreshTokenValidity;
  final String issuer;
  final List<String> audiences;

  JwtService({
    required this.secret,
    this.tokenValidity = const Duration(hours: 2),
    this.refreshTokenValidity = const Duration(days: 30),
    this.issuer = 'vaden',
    this.audiences = const [],
  });

  factory JwtService.withSettings(ApplicationSettings settings) {
    return JwtService(
      secret: settings['security']['secret'],
      tokenValidity: Duration(seconds: settings['security']['tokenValidity']),
      refreshTokenValidity:
          Duration(seconds: settings['security']['refreshTokenValidity']),
      issuer: settings['security']['issuer'],
      audiences: settings['security']['audiences'].cast<String>(),
    );
  }

  /// Verifies and decodes the JWT token.
  /// Returns the payload (claims) if valid, or `null` if invalid.
  Tokenization generateToken(
    UserDetails user, {
    Map<String, dynamic> claims = const {},
  }) {
    final accessToken = _generateToken(user, claims: claims);
    final refreshToken = _generateToken(user,
        claims: {
          ...claims,
          'refresh': true,
        },
        isRefreshToken: true);

    return Tokenization(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  String _generateToken(
    UserDetails user, {
    Map<String, dynamic> claims = const {},
    bool isRefreshToken = false,
  }) {
    final jwt = JWT(
      {
        'sub': user.username,
        'roles': user.roles,
        ...claims,
      },
      issuer: issuer,
      audience: Audience(audiences),
    );

    return jwt.sign(SecretKey(secret),
        expiresIn: isRefreshToken ? refreshTokenValidity : tokenValidity);
  }

  /// Verifies the JWT token and returns the claims if valid.
  /// Returns `null` if the token is invalid.
  /// Throws an exception if the token is expired.
  Map<String, dynamic>? verifyToken(String token) {
    try {
      final jwt = JWT.verify(
        token,
        SecretKey(secret),
        issuer: issuer,
        audience: Audience(audiences),
      );
      return jwt.payload;
    } catch (e) {
      return null;
    }
  }

  Map<String, dynamic>? verifyRefreshToken(String token) {
    return verifyToken(token);
  }
}
