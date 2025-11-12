import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/supabase_config.dart';
import '../../../core/errors/exceptions.dart';
import '../../models/user_model.dart';

/// Remote data source for authentication operations with Supabase
abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithEmail(String email, String password);
  Future<UserModel> signUpWithEmail(String email, String password, String? fullName);
  Future<UserModel> signInWithGoogle();
  Future<UserModel> signInWithApple();
  Future<UserModel> signInWithFacebook();
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
  Future<bool> isAuthenticated();
  Future<void> sendPasswordResetEmail(String email);
  Future<void> resetPassword(String token, String newPassword);
  Future<void> updatePassword(String currentPassword, String newPassword);
  Future<UserModel> updateProfile(UserModel user);
  Future<String> uploadAvatar(String filePath);
  Future<void> verifyEmail(String token);
  Future<void> resendVerificationEmail();
  Future<void> deleteAccount(String password);
  Stream<UserModel?> get authStateChanges;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient _client;

  AuthRemoteDataSourceImpl({SupabaseClient? client})
      : _client = client ?? SupabaseConfig.client;

  @override
  Future<UserModel> signInWithEmail(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw AuthException(message: 'Sign in failed');
      }

      // Get user profile from database
      return await _getUserProfile(response.user!.id);
    } on AuthException catch (e) {
      throw AuthException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<UserModel> signUpWithEmail(
    String email,
    String password,
    String? fullName,
  ) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: fullName != null ? {'full_name': fullName} : null,
      );

      if (response.user == null) {
        throw AuthException(message: 'Sign up failed');
      }

      // Create user profile in database
      final userModel = UserModel(
        id: response.user!.id,
        email: email,
        fullName: fullName,
        username: null,
        phoneNumber: null,
        dateOfBirth: null,
        gender: null,
        bio: null,
        avatarUrl: null,
        location: null,
        city: null,
        country: null,
        latitude: null,
        longitude: null,
        preferredLanguage: 'en',
        preferredCurrency: 'USD',
        preferences: {},
        socialLinks: {},
        isEmailVerified: false,
        isPhoneVerified: false,
        karmaPoints: 0,
        totalEventsAttended: 0,
        totalEventsCreated: 0,
        accountStatus: 'active',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      // Insert user profile
      await _client.from('users').insert(userModel.toJson());

      return userModel;
    } on AuthException catch (e) {
      throw AuthException(message: e.message);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      final response = await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'meroevent://auth/callback',
      );

      if (!response) {
        throw AuthException(message: 'Google sign in failed');
      }

      // Get current user after OAuth flow completes
      final user = _client.auth.currentUser;
      if (user == null) {
        throw AuthException(message: 'No user after Google sign in');
      }

      return await _getUserProfile(user.id);
    } on AuthException catch (e) {
      throw AuthException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<UserModel> signInWithApple() async {
    try {
      final response = await _client.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: 'meroevent://auth/callback',
      );

      if (!response) {
        throw AuthException(message: 'Apple sign in failed');
      }

      // Get current user after OAuth flow completes
      final user = _client.auth.currentUser;
      if (user == null) {
        throw AuthException(message: 'No user after Apple sign in');
      }

      return await _getUserProfile(user.id);
    } on AuthException catch (e) {
      throw AuthException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<UserModel> signInWithFacebook() async {
    try {
      final response = await _client.auth.signInWithOAuth(
        OAuthProvider.facebook,
        redirectTo: 'meroevent://auth/callback',
      );

      if (!response) {
        throw AuthException(message: 'Facebook sign in failed');
      }

      // Get current user after OAuth flow completes
      final user = _client.auth.currentUser;
      if (user == null) {
        throw AuthException(message: 'No user after Facebook sign in');
      }

      return await _getUserProfile(user.id);
    } on AuthException catch (e) {
      throw AuthException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } on AuthException catch (e) {
      throw AuthException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;

      return await _getUserProfile(user.id);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        return null;
      }
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    final user = _client.auth.currentUser;
    return user != null;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(
        email,
        redirectTo: 'meroevent://auth/reset-password',
      );
    } on AuthException catch (e) {
      throw AuthException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> resetPassword(String token, String newPassword) async {
    try {
      // Supabase handles password reset via the email link flow
      // This would be called after verifying the token from the email
      await _client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } on AuthException catch (e) {
      throw AuthException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> updatePassword(String currentPassword, String newPassword) async {
    try {
      // Verify current password first
      final user = _client.auth.currentUser;
      if (user == null) {
        throw AuthException(message: 'No authenticated user');
      }

      // Re-authenticate with current password
      await _client.auth.signInWithPassword(
        email: user.email!,
        password: currentPassword,
      );

      // Update to new password
      await _client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } on AuthException catch (e) {
      throw AuthException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<UserModel> updateProfile(UserModel user) async {
    try {
      final response = await _client
          .from('users')
          .update(user.toJson())
          .eq('id', user.id)
          .select()
          .single();

      return UserModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(
        message: e.message,
        code: int.tryParse(e.code ?? ''),
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<String> uploadAvatar(String filePath) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw AuthException(message: 'No authenticated user');
      }

      // Generate unique file name
      final file = File(filePath);
      final fileName = '${user.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Upload to Supabase Storage
      await _client.storage.from('avatars').upload(
            fileName,
            file,
            fileOptions: const FileOptions(upsert: true),
          );

      // Get public URL
      final publicUrl = _client.storage.from('avatars').getPublicUrl(fileName);

      // Update user profile with new avatar URL
      await _client.from('users').update({
        'avatar_url': publicUrl,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', user.id);

      return publicUrl;
    } on StorageException catch (e) {
      throw ServerException(message: e.message);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> verifyEmail(String token) async {
    try {
      // Supabase handles email verification via the email link flow
      // This would be called after verifying the token from the email
      await _client.auth.verifyOTP(
        type: OtpType.email,
        token: token,
        email: _client.auth.currentUser?.email ?? '',
      );

      // Update user profile
      final user = _client.auth.currentUser;
      if (user != null) {
        await _client.from('users').update({
          'is_email_verified': true,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', user.id);
      }
    } on AuthException catch (e) {
      throw AuthException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> resendVerificationEmail() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw AuthException(message: 'No authenticated user');
      }

      // Resend verification email
      await _client.auth.resend(
        type: OtpType.email,
        email: user.email!,
      );
    } on AuthException catch (e) {
      throw AuthException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> deleteAccount(String password) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw AuthException(message: 'No authenticated user');
      }

      // Verify password first
      await _client.auth.signInWithPassword(
        email: user.email!,
        password: password,
      );

      // Delete user profile from database
      await _client.from('users').delete().eq('id', user.id);

      // Delete auth user (this requires admin privileges via RPC)
      await _client.rpc('delete_user', params: {'user_id': user.id});
    } on AuthException catch (e) {
      throw AuthException(message: e.message);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return _client.auth.onAuthStateChange.asyncMap((state) async {
      final user = state.session?.user;
      if (user == null) return null;

      try {
        return await _getUserProfile(user.id);
      } catch (e) {
        return null;
      }
    });
  }

  /// Helper method to get user profile from database
  Future<UserModel> _getUserProfile(String userId) async {
    try {
      final response = await _client
          .from('users')
          .select('*')
          .eq('id', userId)
          .single();

      return UserModel.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        throw NotFoundException(message: 'User profile not found');
      }
      throw ServerException(
        message: e.message,
        code: int.tryParse(e.code ?? ''),
      );
    }
  }
}
