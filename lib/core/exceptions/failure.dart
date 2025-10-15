import 'package:freezed_annotation/freezed_annotation.dart';

part 'failure.freezed.dart';

@freezed
sealed class Failure with _$Failure {
  const Failure._();

  const factory Failure.network({String? message}) = NetworkFailure;
  const factory Failure.bluetooth({String? message}) = BluetoothFailure;
  const factory Failure.subscription({String? message}) = SubscriptionFailure;
  const factory Failure.unexpected({String? message}) = UnexpectedFailure;

  String get displayMessage => message ?? when(
        network: (_) => 'Network error occurred.',
        bluetooth: (_) => 'Bluetooth error occurred.',
        subscription: (_) => 'Subscription error occurred.',
        unexpected: (_) => 'Unexpected error occurred.',
      );
}
