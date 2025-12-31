import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/user_repository.dart';

/// Authentication state provider
class AuthProvider extends ChangeNotifier {
  final UserRepository _userRepository = UserRepository();
  
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;
  bool get isBuyer => _currentUser?.role == AppConstants.roleBuyer;
  bool get isSeller => _currentUser?.role == AppConstants.roleSeller;
  bool get isInitialized => _isInitialized;

  /// Initialize auth state from shared preferences
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(AppConstants.prefKeyUser);
      
      if (userJson != null) {
        _currentUser = UserModel.fromJson(userJson);
      }
    } catch (e) {
      debugPrint('Error initializing auth: $e');
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Login with email and password
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final user = await _userRepository.authenticate(email, password);
      
      if (user != null) {
        _currentUser = user;
        await _saveUserToPrefs(user);
        notifyListeners();
        return true;
      } else {
        _setError('Email atau password salah');
        return false;
      }
    } catch (e) {
      _setError('Terjadi kesalahan: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Register new user
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String role,
    String? phone,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // Check if email already exists
      final exists = await _userRepository.emailExists(email);
      if (exists) {
        _setError('Email sudah terdaftar');
        return false;
      }

      // Create new user
      final user = await _userRepository.createUser(
        name: name,
        email: email,
        password: password,
        role: role,
        phone: phone,
      );

      _currentUser = user;
      await _saveUserToPrefs(user);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Terjadi kesalahan: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Logout current user
  Future<void> logout() async {
    _setLoading(true);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.prefKeyUser);
      _currentUser = null;
    } catch (e) {
      debugPrint('Error logging out: $e');
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  /// Update user profile
  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? address,
    String? avatar,
  }) async {
    if (_currentUser == null) return false;
    
    _setLoading(true);
    _clearError();

    try {
      final updatedUser = _currentUser!.copyWith(
        name: name ?? _currentUser!.name,
        phone: phone ?? _currentUser!.phone,
        address: address ?? _currentUser!.address,
        avatar: avatar ?? _currentUser!.avatar,
      );

      final success = await _userRepository.updateUser(updatedUser);
      
      if (success) {
        _currentUser = updatedUser;
        await _saveUserToPrefs(updatedUser);
        notifyListeners();
        return true;
      } else {
        _setError('Gagal memperbarui profil');
        return false;
      }
    } catch (e) {
      _setError('Terjadi kesalahan: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Change password
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    if (_currentUser == null) return false;
    
    _setLoading(true);
    _clearError();

    try {
      // Verify current password
      if (_currentUser!.password != currentPassword) {
        _setError('Password saat ini salah');
        return false;
      }

      final success = await _userRepository.updatePassword(
        _currentUser!.id,
        newPassword,
      );
      
      if (success) {
        _currentUser = _currentUser!.copyWith(password: newPassword);
        await _saveUserToPrefs(_currentUser!);
        return true;
      } else {
        _setError('Gagal mengubah password');
        return false;
      }
    } catch (e) {
      _setError('Terjadi kesalahan: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Refresh user data from database
  Future<void> refreshUser() async {
    if (_currentUser == null) return;
    
    try {
      final user = await _userRepository.getUserById(_currentUser!.id);
      if (user != null) {
        _currentUser = user;
        await _saveUserToPrefs(user);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error refreshing user: $e');
    }
  }

  // Private helpers
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  Future<void> _saveUserToPrefs(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.prefKeyUser, user.toJson());
  }
}
