import '../../../../core/result/app_result.dart';
import '../entities/ride_request_entity.dart';
import '../repositories/ride_requests_repository.dart';

class GetRideRequestUseCase {
  const GetRideRequestUseCase(this._repository);

  final RideRequestsRepository _repository;

  Future<AppResult<RideRequestEntity>> call(String requestId) =>
      _repository.fetchById(requestId);
}
