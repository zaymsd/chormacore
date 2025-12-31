import 'package:uuid/uuid.dart';
import '../../core/constants/db_constants.dart';
import '../database/database_helper.dart';
import '../models/user_model.dart';

/// Repository for user-related database operations
class UserRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final Uuid _uuid = const Uuid();

  /// Create a new user
  Future<UserModel> createUser({
    required String name,
    required String email,
    required String password,
    required String role,
    String? phone,
    String? address,
    String? avatar,
  }) async {
    final user = UserModel(
      id: _uuid.v4(),
      name: name,
      email: email,
      password: password,
      role: role,
      phone: phone,
      address: address,
      avatar: avatar,
      createdAt: DateTime.now(),
    );

    await _db.insert(DbConstants.tableUsers, user.toMap());
    return user;
  }

  /// Get user by ID
  Future<UserModel?> getUserById(String id) async {
    final result = await _db.getById(DbConstants.tableUsers, id);
    if (result != null) {
      return UserModel.fromMap(result);
    }
    return null;
  }

  /// Get user by email
  Future<UserModel?> getUserByEmail(String email) async {
    final results = await _db.query(
      DbConstants.tableUsers,
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    if (results.isNotEmpty) {
      return UserModel.fromMap(results.first);
    }
    return null;
  }

  /// Authenticate user
  Future<UserModel?> authenticate(String email, String password) async {
    final results = await _db.query(
      DbConstants.tableUsers,
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
      limit: 1,
    );
    if (results.isNotEmpty) {
      return UserModel.fromMap(results.first);
    }
    return null;
  }

  /// Update user profile
  Future<bool> updateUser(UserModel user) async {
    final updatedUser = user.copyWith(updatedAt: DateTime.now());
    final result = await _db.update(
      DbConstants.tableUsers,
      updatedUser.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
    return result > 0;
  }

  /// Update user password
  Future<bool> updatePassword(String userId, String newPassword) async {
    final result = await _db.update(
      DbConstants.tableUsers,
      {
        'password': newPassword,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [userId],
    );
    return result > 0;
  }

  /// Check if email exists
  Future<bool> emailExists(String email) async {
    final count = await _db.count(
      DbConstants.tableUsers,
      where: 'email = ?',
      whereArgs: [email],
    );
    return count > 0;
  }

  /// Get all sellers
  Future<List<UserModel>> getAllSellers() async {
    final results = await _db.query(
      DbConstants.tableUsers,
      where: 'role = ?',
      whereArgs: ['seller'],
    );
    return results.map((map) => UserModel.fromMap(map)).toList();
  }

  /// Delete user
  Future<bool> deleteUser(String id) async {
    final result = await _db.delete(
      DbConstants.tableUsers,
      where: 'id = ?',
      whereArgs: [id],
    );
    return result > 0;
  }
}
