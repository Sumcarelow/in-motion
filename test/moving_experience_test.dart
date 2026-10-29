import 'package:customer/app/models/vehicle_type_model.dart';
import 'package:customer/constant/moving_experience.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  VehicleTypeModel vehicle(String title, {bool isActive = true}) {
    return VehicleTypeModel(
      id: title,
      image: '',
      isActive: isActive,
      title: title,
      charges: Charges(
        fareMinimumChargesWithinKm: '0',
        farMinimumCharges: '0',
        farePerKm: '0',
      ),
      persons: '0',
      timeSlots: const [],
    );
  }

  group('moving vehicle filter', () {
    test('keeps mini trucks, vans, pickups, and cargo vehicles', () {
      final result = MovingExperience.movingVehiclesOnly([
        vehicle('Mini Truck'),
        vehicle('Panel Van'),
        vehicle('1 Ton Pickup'),
        vehicle('Cargo LCV'),
      ]);

      expect(result, hasLength(4));
    });

    test('removes passenger and inactive vehicles', () {
      final result = MovingExperience.movingVehiclesOnly([
        vehicle('Taxi'),
        vehicle('Sedan'),
        vehicle('SUV'),
        vehicle('Mini'),
        vehicle('Cargo Van', isActive: false),
      ]);

      expect(result, isEmpty);
    });

    test('passenger wording wins over a moving keyword', () {
      expect(
        MovingExperience.isMovingVehicle(vehicle('Taxi Van')),
        isFalse,
      );
    });
  });
}
