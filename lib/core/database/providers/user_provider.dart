import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../repositories/user_repository.dart';

/// Provider for UserRepository instance
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

/// Provider for all users
final usersProvider = FutureProvider<List<User>>((ref) async {
  final repository = ref.read(userRepositoryProvider);
  return repository.getAllUsers();
});

/// Provider for a specific user by ID
final userProvider = FutureProvider.family<User?, String>((ref, userId) async {
  final repository = ref.read(userRepositoryProvider);
  return repository.getUserById(userId);
});

/// Provider for active users only
final activeUsersProvider = FutureProvider<List<User>>((ref) async {
  final repository = ref.read(userRepositoryProvider);
  return repository.getAllUsers(status: UserStatus.active);
});

/// Provider for user search results
final userSearchProvider = StateNotifierProvider<UserSearchNotifier, AsyncValue<List<User>>>((ref) {
  final repository = ref.read(userRepositoryProvider);
  return UserSearchNotifier(repository);
});

/// Provider for user statistics
final userStatisticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repository = ref.read(userRepositoryProvider);
  return repository.getUserStatistics();
});

/// State notifier for user search functionality
class UserSearchNotifier extends StateNotifier<AsyncValue<List<User>>> {
  final UserRepository _repository;
  String _lastQuery = '';

  UserSearchNotifier(this._repository) : super(const AsyncValue.data([]));

  Future<void> searchUsers(String query) async {
    if (query.trim().isEmpty) {
      state = const AsyncValue.data([]);
      _lastQuery = '';
      return;
    }

    if (query == _lastQuery) return;

    state = const AsyncValue.loading();
    _lastQuery = query;

    try {
      final results = _repository.searchUsers(query);
      state = AsyncValue.data(results);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void clearSearch() {
    state = const AsyncValue.data([]);
    _lastQuery = '';
  }
}

/// Provider for user operations (create, update, delete)
final userOperationsProvider = StateNotifierProvider<UserOperationsNotifier, AsyncValue<String?>>((ref) {
  final repository = ref.read(userRepositoryProvider);
  return UserOperationsNotifier(repository, ref);
});

/// State notifier for user operations
class UserOperationsNotifier extends StateNotifier<AsyncValue<String?>> {
  final UserRepository _repository;
  final Ref _ref;

  UserOperationsNotifier(this._repository, this._ref) : super(const AsyncValue.data(null));

  Future<String?> createUser({
    required String firstName,
    required String lastName,
    required String email,
    required String username,
    String? phoneNumber,
    String? department,
    String? position,
    UserRole role = UserRole.user,
  }) async {
    state = const AsyncValue.loading();

    try {
      final userId = await _repository.createUser(
        firstName: firstName,
        lastName: lastName,
        email: email,
        username: username,
        phoneNumber: phoneNumber,
        department: department,
        position: position,
        role: role,
      );

      state = AsyncValue.data(userId);
      
      // Refresh users list
      _ref.invalidate(usersProvider);
      _ref.invalidate(activeUsersProvider);
      _ref.invalidate(userStatisticsProvider);

      return userId;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return null;
    }
  }

  Future<bool> updateUser(String id, {
    String? firstName,
    String? lastName,
    String? email,
    String? username,
    String? phoneNumber,
    UserRole? role,
    UserStatus? status,
    String? avatarUrl,
    Map<String, dynamic>? metadata,
  }) async {
    state = const AsyncValue.loading();

    try {
      final success = await _repository.updateUser(
        id,
        firstName: firstName,
        lastName: lastName,
        email: email,
        username: username,
        phoneNumber: phoneNumber,
        department: department,
        position: position,
        role: role,
        status: status,
        preferences: preferences,
      );

      state = AsyncValue.data(success ? id : null);

      if (success) {
        // Refresh related providers
        _ref.invalidate(usersProvider);
        _ref.invalidate(activeUsersProvider);
        _ref.invalidate(userProvider(id));
        _ref.invalidate(userStatisticsProvider);
      }

      return success;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }

  Future<bool> deleteUser(String id) async {
    state = const AsyncValue.loading();

    try {
      final success = await _repository.deleteUser(id);
      state = AsyncValue.data(success ? id : null);

      if (success) {
        // Refresh related providers
        _ref.invalidate(usersProvider);
        _ref.invalidate(activeUsersProvider);
        _ref.invalidate(userStatisticsProvider);
      }

      return success;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }

  Future<bool> changePassword(String id, String currentPassword, String newPassword) async {
    state = const AsyncValue.loading();

    try {
      final success = await _repository.changePassword(id, currentPassword, newPassword);
      state = AsyncValue.data(success ? id : null);
      return success;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }

  Future<bool> activateUser(String id) async {
    return updateUser(id, status: UserStatus.active);
  }

  Future<bool> deactivateUser(String id) async {
    return updateUser(id, status: UserStatus.inactive);
  }

  void resetState() {
    state = const AsyncValue.data(null);
  }
}

/// Provider for user authentication
final userAuthProvider = StateNotifierProvider<UserAuthNotifier, AsyncValue<User?>>((ref) {
  final repository = ref.read(userRepositoryProvider);
  return UserAuthNotifier(repository);
});

/// State notifier for user authentication
class UserAuthNotifier extends StateNotifier<AsyncValue<User?>> {
  final UserRepository _repository;

  UserAuthNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<User?> validateCredentials(String emailOrUsername, String password) async {
    state = const AsyncValue.loading();

    try {
      final user = await _repository.validateCredentials(emailOrUsername, password);
      state = AsyncValue.data(user);
      return user;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return null;
    }
  }

  void logout() {
    state = const AsyncValue.data(null);
  }
}

/// Provider for users by role
final usersByRoleProvider = FutureProvider.family<List<User>, UserRole>((ref, role) async {
  final repository = ref.read(userRepositoryProvider);
  return repository.getUsersByRole(role);
});

/// Provider for checking email availability
final emailAvailabilityProvider = FutureProvider.family<bool, String>((ref, email) async {
  final repository = ref.read(userRepositoryProvider);
  return repository.isEmailAvailable(email);
});

/// Provider for checking username availability
final usernameAvailabilityProvider = FutureProvider.family<bool, String>((ref, username) async {
  final repository = ref.read(userRepositoryProvider);
  return repository.isUsernameAvailable(username);
});