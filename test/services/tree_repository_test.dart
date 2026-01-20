import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:treesha/services/firestore_config.dart';
import 'package:treesha/services/tree_repository.dart';

void main() {
  group('TreeRepository', () {
    late FakeFirebaseFirestore fakeFirestore;
    late TreeRepository repository;

    setUp(() {
      // Create a fake Firestore instance for testing
      fakeFirestore = FakeFirebaseFirestore();
      repository = TreeRepository(firestore: fakeFirestore);

      // Mark config as done (skip actual Firebase init in tests)
      FirestoreConfig.reset();
    });

    tearDown(() {
      FirestoreConfig.reset();
    });

    test('addTree throws if Firestore not configured', () async {
      // Arrange
      final position = Position(
        latitude: 32.0,
        longitude: 34.0,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      );

      // Act & Assert
      expect(
        () => repository.addTree(
          userId: 'user123',
          name: 'Test Tree',
          fruitType: 'Apple',
          position: position,
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('addTree throws ArgumentError if userId is empty', () async {
      // Arrange - mark as configured
      FirestoreConfig.reset();
      // Manually set configured flag (hack for testing)
      FirestoreConfig.configure(); // This will fail in tests but set the flag

      final position = Position(
        latitude: 32.0,
        longitude: 34.0,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      );

      // Act & Assert
      expect(
        () => repository.addTree(
          userId: '',
          name: 'Test Tree',
          fruitType: 'Apple',
          position: position,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('addTree throws ArgumentError if name is empty', () async {
      // Similar test for empty name
      final position = Position(
        latitude: 32.0,
        longitude: 34.0,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      );

      expect(
        () => repository.addTree(
          userId: 'user123',
          name: '',
          fruitType: 'Apple',
          position: position,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('addTree throws ArgumentError if fruitType is empty', () async {
      final position = Position(
        latitude: 32.0,
        longitude: 34.0,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      );

      expect(
        () => repository.addTree(
          userId: 'user123',
          name: 'Test Tree',
          fruitType: '',
          position: position,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('TreeRepositoryException', () {
    test('toString returns formatted message', () {
      final exception = TreeRepositoryException(
        'Test error message',
        code: 'test-error',
      );

      expect(
        exception.toString(),
        equals('TreeRepositoryException(test-error): Test error message'),
      );
    });
  });

  group('TimeoutException', () {
    test('toString returns formatted message', () {
      final exception = TimeoutException('Operation timed out');

      expect(
        exception.toString(),
        equals('TimeoutException: Operation timed out'),
      );
    });
  });
}
