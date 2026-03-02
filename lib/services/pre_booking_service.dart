import 'package:cloud_firestore/cloud_firestore.dart';

import '../app/models/pre_booking.dart';

class PreBookingService {
  final _firestore = FirebaseFirestore.instance;

  Future<void> createPreBooking(PreBooking booking) async {
    await _firestore.collection('pre_bookings').doc(booking.id).set(booking.toMap());
  }

  Stream<List<PreBooking>> getUserPreBookings(String userId) {
    return _firestore
        .collection('pre_bookings')
        .where('userId', isEqualTo: userId)
        .orderBy('scheduledDateTime')
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((d) => PreBooking.fromMap(d.data())).toList());
  }
}
