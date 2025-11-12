import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/user.dart';

/// Authentication repository interface
/// Defines all auth-related operations
abstract class AuthRepository {
  /// Sign in with email and password
  Future<Either<Failure, User>> signInWithEmail({
    required String email,
    required String password,
  });

  /// Sign up with email and password
  Future<Either<Failure, User>> signUpWithEmail({
    required String email,
    required String password,
    String? fullName,
  });

  /// Sign in with social providers
  Future<Either<Failure, User>> signInWithGoogle();
  Future<Either<Failure, User>> signInWithApple();
  Future<Either<Failure, User>> signInWithFacebook();

  /// Sign out
  Future<Either<Failure, void>> signOut();

  /// Get current user
  Future<Either<Failure, User?>> getCurrentUser();

  /// Check if user is authenticated
  Future<bool> isAuthenticated();

  /// Send password reset email
  Future<Either<Failure, void>> sendPasswordResetEmail(String email);

  /// Reset password with token
  Future<Either<Failure, void>> resetPassword({
    required String token,
    required String newPassword,
  });

  /// Update password
  Future<Either<Failure, void>> updatePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// Update user profile
  Future<Either<Failure, User>> updateProfile(User user);

  /// Upload avatar
  Future<Either<Failure, String>> uploadAvatar(String filePath);

  /// Verify email
  Future<Either<Failure, void>> verifyEmail(String token);

  /// Resend verification email
  Future<Either<Failure, void>> resendVerificationEmail();

  /// Delete account
  Future<Either<Failure, void>> deleteAccount(String password);

  /// Listen to auth state changes
  Stream<User?> get authStateChanges;
}
