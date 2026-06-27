import 'package:frontend/features/auth/data/models/auth_session.dart';
import 'package:frontend/features/auth/domain/repository/auth_repository_interface.dart';

class RestoreSessionUseCase {
  const RestoreSessionUseCase(this._repository);

  final IAuthRepository _repository;

  Future<AuthSession?> call() async {
    return _repository.restoreSession();
  }
}
