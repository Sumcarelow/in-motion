import 'package:customer/constant/moving_experience.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('moving product structure exposes only moving services', () {
    expect(MovingExperience.brandName, 'In Motione Moving');
    expect(MovingExperience.localMove, 'Local Move');
    expect(MovingExperience.longDistanceMove, 'Long-Distance Move');
    expect(MovingExperience.smallLoadMove, 'Small-Load Move');
    expect(MovingExperience.scheduledMove, 'Schedule a Move');
  });
}
