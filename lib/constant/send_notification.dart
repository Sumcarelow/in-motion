import 'package:customer/services/secure_backend_service.dart';

class SendNotification {
  static Future<void> sendOneNotification({
    required String token,
    required String title,
    required String body,
    required String type,
    required Map<String, dynamic> payload,
    String? bookingId,
    String? driverId,
    String? customerId,
    String? senderId,
  }) async {
    // Device tokens and service-account credentials stay on the backend.
    // `token` remains in this signature to preserve existing call sites.
    await SecureBackendService.sendUserNotification(
      type: type,
      payload: payload,
      bookingId: bookingId,
      driverId: driverId,
      customerId: customerId,
      senderId: senderId,
      title: title,
      body: body,
    );
  }
}
