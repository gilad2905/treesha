import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:treez/services/firestore_config.dart';
import 'package:treez/services/tree_repository.dart';

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
          userRole: 'user',
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('addTree throws ArgumentError if userId is empty', () async {
      // Arrange - mark as configured
      FirestoreConfig.reset();
      // Manually set configured flag (hack for testing)
      FirestoreConfig.setConfigured(true); // This will fail in tests but set the flag

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
          userRole: 'user',
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('addTree throws ArgumentError if name is empty', () async {
      // Similar test for empty name
      FirestoreConfig.setConfigured(true);
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
          userRole: 'user',
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('addTree throws ArgumentError if fruitType is empty', () async {
      FirestoreConfig.setConfigured(true);
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
          userRole: 'user',
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('reportTree adds user to reported list', () async {
      // Arrange
      final treeRef = await fakeFirestore.collection('trees').add({
        'name': 'Report Test Tree',
        'reported': <String>[],
      });

      // Act
      await repository.reportTree(treeRef.id, 'reporter_1');

      // Assert
      final doc = await treeRef.get();
      final reported = List<String>.from(doc.data()!['reported']);
      expect(reported, contains('reporter_1'));
    });

    test('reportTree does not add same user twice', () async {
      // Arrange
      final treeRef = await fakeFirestore.collection('trees').add({
        'name': 'Report Test Tree',
        'reported': ['reporter_1'],
      });

      // Act
      await repository.reportTree(treeRef.id, 'reporter_1');

      // Assert
      final doc = await treeRef.get();
      final reported = List<String>.from(doc.data()!['reported']);
      expect(reported.length, 1);
    });

    test('deleteTree removes tree and its posts', () async {
      // Arrange
      final treeRef = await fakeFirestore.collection('trees').add({
        'name': 'Delete Test Tree',
      });
      final postRef = await treeRef.collection('posts').add({
        'comment': 'Test Post',
      });

      // Act
      await repository.deleteTree(treeRef.id);

      // Assert
      final treeDoc = await treeRef.get();
      expect(treeDoc.exists, false);
      final postDoc = await postRef.get();
      expect(postDoc.exists, false);
    });

    test('deletePost removes only the specified post', () async {
      // Arrange
      final treeRef = await fakeFirestore.collection('trees').add({
        'name': 'Delete Post Test Tree',
      });
      final post1Ref = await treeRef.collection('posts').add({'comment': 'Post 1'});
      final post2Ref = await treeRef.collection('posts').add({'comment': 'Post 2'});

      // Act
      await repository.deletePost(treeRef.id, post1Ref.id);

      // Assert
      expect((await post1Ref.get()).exists, false);
      expect((await post2Ref.get()).exists, true);
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
