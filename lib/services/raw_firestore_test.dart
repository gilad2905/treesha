import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

/// Test if we can write to Firestore using raw HTTP (bypassing SDK)
class RawFirestoreTest {
  static Future<void> testRawWrite() async {
    print('[RawTest] =====================================');
    print('[RawTest] TESTING RAW FIRESTORE HTTP WRITE');
    print('[RawTest] =====================================');

    try {
      // Get auth token
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('[RawTest] ❌ User not logged in');
        return;
      }

      print('[RawTest] Getting auth token...');
      final token = await user.getIdToken();
      print('[RawTest] ✅ Got token: ${token?.substring(0, 20)}...');

      // Prepare document
      final docId = 'test_${DateTime.now().millisecondsSinceEpoch}';
      final url = Uri.parse(
        'https://firestore.googleapis.com/v1/projects/applied-primacy-294221/databases/(default)/documents/trees/$docId',
      );

      final body = {
        'fields': {
          'test': {'booleanValue': true},
          'timestamp': {'timestampValue': DateTime.now().toUtc().toIso8601String()},
          'userId': {'stringValue': user.uid},
        }
      };

      print('[RawTest] Making HTTP POST request...');
      print('[RawTest] URL: $url');

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('HTTP request timed out');
        },
      );

      print('[RawTest] Response status: ${response.statusCode}');
      print('[RawTest] Response body: ${response.body.substring(0, 200)}...');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('[RawTest] ✅ SUCCESS! Raw HTTP write worked!');
        print('[RawTest] This means Firestore is accessible');
        print('[RawTest] The problem is with the Flutter Firebase SDK');

        // Try to delete the test document
        print('[RawTest] Cleaning up test document...');
        await http.delete(
          url,
          headers: {'Authorization': 'Bearer $token'},
        );
        print('[RawTest] Test document deleted');
      } else {
        print('[RawTest] ❌ HTTP error: ${response.statusCode}');
        print('[RawTest] ${response.body}');
      }
    } catch (e, stack) {
      print('[RawTest] ❌ Exception: $e');
      print('[RawTest] Stack: $stack');
    }

    print('[RawTest] =====================================');
  }
}
