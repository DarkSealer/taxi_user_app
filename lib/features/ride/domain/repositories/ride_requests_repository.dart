import '../../../../core/result/app_result.dart';
import '../entities/ride_request_entity.dart';

abstract class RideRequestsRepository {
  Future<AppResult<RideRequestEntity>> fetchById(String requestId);
}
