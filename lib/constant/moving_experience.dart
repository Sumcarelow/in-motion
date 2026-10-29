import 'package:customer/app/models/vehicle_type_model.dart';

/// Customer-facing product rules for the moving-only experience.
///
/// Existing Firestore collection names are intentionally left unchanged so
/// current bookings, pricing, and driver dispatch continue to work. This
/// class is the single place that defines which vehicles may be shown to
/// customers and how the product is named in the UI.
abstract final class MovingExperience {
  static const String brandName = 'In Motione Moving';
  static const String brandShortName = 'In Motione';

  static const String localMove = 'Local Move';
  static const String longDistanceMove = 'Long-Distance Move';
  static const String smallLoadMove = 'Small-Load Move';
  static const String scheduledMove = 'Schedule a Move';

  static const List<String> _movingVehicleKeywords = <String>[
    'van',
    'truck',
    'mini truck',
    'mini-truck',
    'bakkie',
    'pickup',
    'pick-up',
    'cargo',
    'panel',
    'goods',
    'mover',
    'moving',
    'utility',
    'lcv',
  ];

  /// Passenger vehicles are excluded even if an administrator accidentally
  /// leaves them active in the shared vehicle collection.
  static const List<String> _passengerVehicleKeywords = <String>[
    'cab',
    'taxi',
    'sedan',
    'hatchback',
    'suv',
    'motorbike',
    'motorcycle',
    'scooter',
    'rickshaw',
  ];

  static bool isMovingVehicle(VehicleTypeModel vehicle) {
    if (vehicle.isActive == false) return false;

    final String title = vehicle.title.trim().toLowerCase();
    if (_passengerVehicleKeywords.any((keyword) => title.contains(keyword))) {
      return false;
    }
    return _movingVehicleKeywords.any((keyword) => title.contains(keyword));
  }

  static List<VehicleTypeModel> movingVehiclesOnly(
    Iterable<VehicleTypeModel> vehicles,
  ) {
    return vehicles.where(isMovingVehicle).toList(growable: false);
  }
}
