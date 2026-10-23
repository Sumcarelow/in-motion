import 'package:cloud_functions/cloud_functions.dart';
import 'package:customer/app/models/payment_method_model.dart';

class SecureBackendService {
  static FirebaseFunctions get _functions =>
      FirebaseFunctions.instanceFor(region: 'us-central1');

  static Future<PaymentModel> getPaymentConfiguration() async {
    final HttpsCallableResult<dynamic> result =
        await _functions.httpsCallable('getPaymentConfiguration').call();
    return PaymentModel.fromJson(_map(result.data));
  }

  static Future<Map<String, dynamic>> getPublicAppConfiguration() async {
    final HttpsCallableResult<dynamic> result =
        await _functions.httpsCallable('getPublicAppConfiguration').call();
    return _map(result.data);
  }

  static Future<Map<String, dynamic>> createPayFastWalletTopUp({
    required String amount,
  }) async {
    final HttpsCallableResult<dynamic> result = await _functions
        .httpsCallable('createPayFastWalletTopUp')
        .call(<String, dynamic>{
      'amount': amount,
      'accountType': 'customer',
    });
    return _map(result.data);
  }

  static Future<Map<String, dynamic>> getPayFastWalletTopUpStatus(
    String topUpId,
  ) async {
    final HttpsCallableResult<dynamic> result = await _functions
        .httpsCallable('getPayFastWalletTopUpStatus')
        .call(<String, dynamic>{'topUpId': topUpId});
    return _map(result.data);
  }

  static Future<Map<String, dynamic>> payRideWithWallet({
    required String collection,
    required String rideId,
  }) async {
    final HttpsCallableResult<dynamic> result = await _functions
        .httpsCallable('payRideWithWallet')
        .call(<String, dynamic>{
      'collection': collection,
      'rideId': rideId,
    });
    return _map(result.data);
  }

  static Future<void> updateCustomerRide({
    required String collection,
    required String rideId,
    required String action,
    String? paymentType,
    String? bidId,
  }) async {
    await _functions.httpsCallable('updateCustomerRide').call(
      <String, dynamic>{
        'collection': collection,
        'rideId': rideId,
        'action': action,
        if (paymentType != null) 'paymentType': paymentType,
        if (bidId != null) 'bidId': bidId,
      },
    );
  }

  static Future<Map<String, dynamic>> requestCustomerAccountDeletion() async {
    final HttpsCallableResult<dynamic> result =
        await _functions.httpsCallable('requestCustomerAccountDeletion').call();
    return _map(result.data);
  }

  static Future<void> sendUserNotification({
    required String type,
    required Map<String, dynamic> payload,
    String? bookingId,
    String? driverId,
    String? customerId,
    String? senderId,
    String? title,
    String? body,
  }) async {
    final String targetUserId =
        driverId ?? customerId ?? payload['receiverId']?.toString() ?? '';
    await _functions.httpsCallable('sendUserNotification').call(
      <String, dynamic>{
        'type': type,
        'payload': payload,
        'bookingId': bookingId,
        'driverId': driverId,
        'customerId': customerId,
        'senderId': senderId,
        'targetUserId': targetUserId,
        'title': title,
        'body': body,
      },
    );
  }

  static Map<String, dynamic> _map(dynamic value) {
    if (value is Map) {
      return value.map(
        (dynamic key, dynamic item) => MapEntry(key.toString(), item),
      );
    }
    throw const FormatException('Unexpected response from secure backend.');
  }
}
