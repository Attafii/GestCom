import '../models/user_model.dart';
import '../services/hive_service.dart';

/// Repository for User entity operations with business logic
class UserRepository {
  /// Create a new user with validation
  Future<String> createUser({
    required String username,
    required String email,
    required String firstName,
    required String lastName,
    String? phoneNumber,
    String? department,
    String? position,
    UserRole role = UserRole.user,
  }) async {
    // Validate email uniqueness
    final existingUsers = HiveService.getAllUsers();
    final emailExists = existingUsers.any((user) => user.email.toLowerCase() == email.toLowerCase());
    
    if (emailExists) {
      throw Exception('User with this email already exists');
    }

    // Validate username uniqueness
    final usernameExists = existingUsers.any((user) => user.username.toLowerCase() == username.toLowerCase());
    
    if (usernameExists) {
      throw Exception('User with this username already exists');
    }

    final user = User(
      username: username,
      email: email,
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
      department: department,
      position: position,
      role: role,
    );

    return await HiveService.createUser(user);
  }

  /// Get user by ID
  User? getUserById(String id) {
    return HiveService.getUser(id);
  }

  /// Get all users with optional filtering
  List<User> getAllUsers({
    UserRole? role,
    UserStatus? status,
    String? department,
  }) {
    var users = HiveService.getAllUsers();

    if (role != null) {
      users = users.where((user) => user.role == role).toList();
    }

    if (status != null) {
      users = users.where((user) => user.status == status).toList();
    }

    if (department != null) {
      users = users.where((user) => user.department == department).toList();
    }

    return users;
  }

  /// Update user information
  Future<bool> updateUser(String id, {
    String? username,
    String? email,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? department,
    String? position,
    UserRole? role,
    UserStatus? status,
    Map<String, dynamic>? preferences,
  }) async {
    final user = HiveService.getUser(id);
    if (user == null) {
      throw Exception('User not found');
    }

    // Validate email uniqueness if changing email
    if (email != null && email != user.email) {
      final existingUsers = HiveService.getAllUsers();
      final emailExists = existingUsers.any((u) => u.id != id && u.email.toLowerCase() == email.toLowerCase());
      
      if (emailExists) {
        throw Exception('User with this email already exists');
      }
    }

    // Validate username uniqueness if changing username
    if (username != null && username != user.username) {
      final existingUsers = HiveService.getAllUsers();
      final usernameExists = existingUsers.any((u) => u.id != id && u.username.toLowerCase() == username.toLowerCase());
      
      if (usernameExists) {
        throw Exception('User with this username already exists');
      }
    }

    final updatedUser = user.copyWith(
      username: username,
      email: email,
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
      department: department,
      position: position,
      role: role,
      status: status,
      preferences: preferences,
    );

    return await HiveService.updateUser(updatedUser);
  }

  /// Delete user (soft delete by changing status)
  Future<bool> deleteUser(String id, {bool permanent = false}) async {
    if (permanent) {
      return await HiveService.deleteUser(id);
    } else {
      // Soft delete by changing status
      return await updateUser(id, status: UserStatus.deleted);
    }
  }

  /// Search users by query
  List<User> searchUsers(String query) {
    return HiveService.searchUsers(query);
  }

  /// Get users by role
  List<User> getUsersByRole(UserRole role) {
    return HiveService.getUsersByRole(role);
  }

  /// Get active users
  List<User> getActiveUsers() {
    return HiveService.getUsersByStatus(UserStatus.active);
  }

  /// Update user last login
  Future<bool> updateLastLogin(String id) async {
    return await updateUser(id, preferences: {'lastLoginAt': DateTime.now().toIso8601String()});
  }

  /// Get user statistics
  Map<String, dynamic> getUserStatistics() {
    final users = HiveService.getAllUsers();
    
    final stats = <String, dynamic>{
      'total': users.length,
      'active': users.where((u) => u.status == UserStatus.active).length,
      'inactive': users.where((u) => u.status == UserStatus.inactive).length,
      'suspended': users.where((u) => u.status == UserStatus.suspended).length,
      'deleted': users.where((u) => u.status == UserStatus.deleted).length,
      'byRole': <String, int>{},
      'byDepartment': <String, int>{},
    };

    // Count by role
    for (final role in UserRole.values) {
      stats['byRole'][role.toString()] = users.where((u) => u.role == role).length;
    }

    // Count by department
    final departments = users.where((u) => u.department != null).map((u) => u.department!).toSet();
    for (final department in departments) {
      stats['byDepartment'][department] = users.where((u) => u.department == department).length;
    }

    return stats;
  }

  /// Validate user credentials (placeholder for authentication)
  Future<User?> validateCredentials(String emailOrUsername, String password) async {
    // This is a placeholder. In a real app, you'd hash and compare passwords
    final users = HiveService.getAllUsers();
    
    try {
      return users.firstWhere(
        (user) => 
            (user.email.toLowerCase() == emailOrUsername.toLowerCase() ||
             user.username.toLowerCase() == emailOrUsername.toLowerCase()) &&
            user.status == UserStatus.active,
      );
    } catch (e) {
      return null;
    }
  }

  /// Check if email is available
  bool isEmailAvailable(String email) {
    final users = HiveService.getAllUsers();
    return !users.any((user) => user.email.toLowerCase() == email.toLowerCase());
  }

  /// Check if username is available
  bool isUsernameAvailable(String username) {
    final users = HiveService.getAllUsers();
    return !users.any((user) => user.username.toLowerCase() == username.toLowerCase());
  }

  /// Change user password
  Future<bool> changePassword(String id, String currentPassword, String newPassword) async {
    // This is a placeholder. In a real app, you'd hash and compare passwords
    final user = HiveService.getUser(id);
    if (user == null) {
      throw Exception('User not found');
    }

    // In a real implementation, verify current password and hash new password
    // For now, just update metadata
    return await updateUser(id, preferences: {
      'passwordChangedAt': DateTime.now().toIso8601String(),
    });
  }
}