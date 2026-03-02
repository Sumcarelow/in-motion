import 'package:cloud_firestore/cloud_firestore.dart';
class PreBooking {
  final String id;
  final String userId;
  final String pickupLocation;
  final String dropoffLocation;
  final DateTime scheduledDateTime;
  final String status;
  final DateTime? cancelledAt;

  PreBooking({
    required this.id,
    required this.userId,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.scheduledDateTime,
    this.status = 'pending',
    this.cancelledAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'pickupLocation': pickupLocation,
    'dropoffLocation': dropoffLocation,
    'scheduledDateTime': scheduledDateTime,
    'status': status,
    'cancelledAt': cancelledAt,
  };

  factory PreBooking.fromMap(Map<String, dynamic> map) => PreBooking(
    id: map['id'],
    userId: map['userId'],
    pickupLocation: map['pickupLocation'],
    dropoffLocation: map['dropoffLocation'],
    scheduledDateTime: (map['scheduledDateTime'] as Timestamp).toDate(),
    status: map['status'] ?? 'pending',
    cancelledAt: map['cancelledAt'] != null
        ? (map['cancelledAt'] as Timestamp).toDate()
        : null,
  );
}
