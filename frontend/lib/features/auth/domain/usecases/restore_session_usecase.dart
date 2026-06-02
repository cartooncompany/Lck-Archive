import '../../data/models/auth_session.dart';
import '../repository/auth_repository_interface.dart';

class RestoreSessionUseCase {
  const RestoreSessionUseCase(this._repository);

  final IAuthRepository _repository;

  Future<AuthSession?> call() async {
    return _repository.restoreSession();
  }
}
