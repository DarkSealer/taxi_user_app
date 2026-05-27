import '../errors/app_failure.dart';

class AppResult<T> {
  const AppResult._({
    this.data,
    this.failure,
  });

  factory AppResult.success(T data) => AppResult._(data: data);

  factory AppResult.failure(AppFailure failure) =>
      AppResult._(failure: failure);

  final T? data;
  final AppFailure? failure;

  bool get hasData => data != null;
  bool get hasFailure => failure != null;
}
