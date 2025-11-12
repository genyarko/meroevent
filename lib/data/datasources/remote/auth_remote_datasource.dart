import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException, StorageException;
import 'package:supabase_flutter/supabase_flutter.dart' as supabase show AuthException, StorageException;
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
      print('🔐 Attempting sign in with email: $email');
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        print('❌ Sign in failed: No user returned');
        throw AuthException(message: 'Sign in failed');
      }

      print('✅ Auth successful, userId: ${response.user!.id}');
      print('📋 Fetching user profile from database...');

      // Get user profile from database
      final profile = await _getUserProfile(response.user!.id);
      print('✅ Profile loaded successfully');
      return profile;
    } on supabase.AuthException catch (e) {
      print('❌ Supabase Auth Error: ${e.message}');
      throw AuthException(message: e.message);
    } catch (e) {
      print('❌ Unexpected Error: $e');
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

      // Create user profile in database (merged schema for both dating & events)
      final userModel = UserModel(
        id: response.user!.id,
        email: email,
        fullName: fullName,
        phone: null,
        dateOfBirth: null,
        gender: null,
        bio: null,
        avatarUrl: null,
        city: null,
        country: null,
        latitude: null,
        longitude: null,
        // Dating app fields (set defaults)
        icebreakerPrompts: null,
        relationshipIntent: null,
        educationLevel: null,
        communicationStyle: null,
        lifestyleChoice: null,
        lockdownEnabled: false,
        imageUrls: null,
        lastLoginDate: DateTime.now(),
        consecutiveLoginDays: 0,
        totalLoginDays: 0,
        matchProbabilityBoost: 1.0,
        isPremium: false,
        premiumExpiresAt: null,
        // Event app fields
        interests: null,
        language: 'en',
        timezone: null,
        preferences: {},
        socialLinks: {},
        karmaPoints: 0,
        // Notifications
        fcmToken: null,
        // Verification
        isEmailVerified: false,
        isPhoneVerified: false,
        isProfileComplete: false,
        // Timestamps
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      // Insert user profile into profiles table (shared by both apps)
      await _client.from('profiles').insert(userModel.toJson());

      return userModel;
    } on supabase.AuthException catch (e) {
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
    } on supabase.AuthException catch (e) {
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
    } on supabase.AuthException catch (e) {
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
    } on supabase.AuthException catch (e) {
      throw AuthException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } on supabase.AuthException catch (e) {
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
    } on supabase.AuthException catch (e) {
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
    } on supabase.AuthException catch (e) {
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
    } on supabase.AuthException catch (e) {
      throw AuthException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<UserModel> updateProfile(UserModel user) async {
    try {
      final response = await _client
          .from('profiles')
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
      await _client.from('profiles').update({
        'avatar_url': publicUrl,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', user.id);

      return publicUrl;
    } on supabase.StorageException catch (e) {
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
        await _client.from('profiles').update({
          'is_email_verified': true,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', user.id);
      }
    } on supabase.AuthException catch (e) {
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
    } on supabase.AuthException catch (e) {
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
      await _client.from('profiles').delete().eq('id', user.id);

      // Delete auth user (this requires admin privileges via RPC)
      await _client.rpc('delete_user', params: {'user_id': user.id});
    } on supabase.AuthException catch (e) {
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
      print('🔍 Querying profiles table for userId: $userId');
      final response = await _client
          .from('profiles')
          .select('*')
          .eq('id', userId)
          .single();

      print('📦 Raw profile data received: ${response.toString().substring(0, 200)}...');
      print('🔄 Attempting to deserialize UserModel...');

      final userModel = UserModel.fromJson(response);
      print('✅ UserModel deserialized successfully');
      return userModel;
    } on PostgrestException catch (e) {
      print('❌ Postgrest Error: ${e.code} - ${e.message}');
      if (e.code == 'PGRST116') {
        throw NotFoundException(message: 'User profile not found');
      }
      throw ServerException(
        message: e.message,
        code: int.tryParse(e.code ?? ''),
      );
    } catch (e, stackTrace) {
      print('❌ Error deserializing profile: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }
}
