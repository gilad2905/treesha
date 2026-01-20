import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

/// Alternative TreeRepository that uses REST API instead of Firebase SDK
/// This bypasses the WebSocket/streaming issues
class TreeRepositoryNoConfirm {
  static const String projectId = 'applied-primacy-294221';
  static const String databaseId = 'treesha'; // Custom database name
  static const String baseUrl = 'https://firestore.googleapis.com/v1';

  /// Add a tree using REST API
  Future<String> addTree({
    required String userId,
    required String name,
    required String fruitType,
    required Position position,
    String? imageUrl,
  }) async {
    print('[TreeRepo-REST] =====================================');
    print('[TreeRepo-REST] ADDING TREE VIA REST API');
    print('[TreeRepo-REST] =====================================');

    // Get auth token
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final token = await user.getIdToken();
    if (token == null) {
      throw Exception('Could not get auth token');
    }

    // Generate document ID
    final docId = FirebaseFirestore.instance.collection('trees').doc().id;
    print('[TreeRepo-REST] Document ID: $docId');

    // Build Firestore REST API request
    final url = Uri.parse(
      '$baseUrl/projects/$projectId/databases/$databaseId/documents/trees/$docId',
    );

    // Convert data to Firestore format
    final body = {
      'fields': {
        'userId': {'stringValue': userId},
        'name': {'stringValue': name},
        'fruitType': {'stringValue': fruitType},
        'position': {
          'geoPointValue': {
            'latitude': position.latitude,
            'longitude': position.longitude,
          },
        },
        'imageUrl': {'stringValue': imageUrl ?? ''},
        'createdAt': {
          'timestampValue': DateTime.now().toUtc().toIso8601String(),
        },
        'upvotes': {
          'arrayValue': {'values': []},
        },
        'downvotes': {
          'arrayValue': {'values': []},
        },
      },
    };

    print('[TreeRepo-REST] Making HTTP request...');

    try {
      final response = await http
          .patch(
            url,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('HTTP request timed out');
            },
          );

      print('[TreeRepo-REST] Response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('[TreeRepo-REST] ✅ SUCCESS!');
        print('[TreeRepo-REST] =====================================');
        return docId;
      } else {
        print('[TreeRepo-REST] ❌ HTTP error: ${response.statusCode}');
        print('[TreeRepo-REST] Body: ${response.body}');
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e, stack) {
      print('[TreeRepo-REST] ❌ Exception: $e');
      print('[TreeRepo-REST] Stack: $stack');
      print('[TreeRepo-REST] =====================================');
      rethrow;
    }
  }

  /// Get all trees from the treesha database
  Future<List<Map<String, dynamic>>> getAllTrees() async {
    print('[TreeRepo-REST] Fetching all trees...');

    try {
      final user = FirebaseAuth.instance.currentUser;

      final url = Uri.parse(
        '$baseUrl/projects/$projectId/databases/$databaseId/documents/trees',
      );

      // Try with authentication first if user is logged in
      Map<String, String> headers = {};
      if (user != null) {
        final token = await user.getIdToken();
        if (token != null) {
          headers['Authorization'] = 'Bearer $token';
          print('[TreeRepo-REST] Fetching with authentication');
        }
      } else {
        print('[TreeRepo-REST] Fetching without authentication (public read)');
      }

      final response = await http
          .get(url, headers: headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final documents = data['documents'] as List<dynamic>? ?? [];

        print('[TreeRepo-REST] ✅ Fetched ${documents.length} trees');

        // Convert to simplified format
        return documents.map((doc) {
          final fields = doc['fields'] as Map<String, dynamic>;
          final name = doc['name'] as String;
          final docId = name.split('/').last;

          return {
            'id': docId,
            'userId': fields['userId']?['stringValue'] ?? '',
            'name': fields['name']?['stringValue'] ?? '',
            'fruitType': fields['fruitType']?['stringValue'] ?? '',
            'latitude':
                fields['position']?['geoPointValue']?['latitude'] ?? 0.0,
            'longitude':
                fields['position']?['geoPointValue']?['longitude'] ?? 0.0,
            'imageUrl': fields['imageUrl']?['stringValue'] ?? '',
            'createdAt': fields['createdAt']?['timestampValue'] ?? '',
            'lastVerifiedAt': fields['lastVerifiedAt']?['timestampValue'],
            'upvotes':
                (fields['upvotes']?['arrayValue']?['values'] as List<dynamic>?)
                    ?.map((v) => v['stringValue'] as String)
                    .toList() ??
                [],
            'downvotes':
                (fields['downvotes']?['arrayValue']?['values']
                        as List<dynamic>?)
                    ?.map((v) => v['stringValue'] as String)
                    .toList() ??
                [],
          };
        }).toList();
      } else {
        print(
          '[TreeRepo-REST] ❌ HTTP ${response.statusCode}: ${response.body}',
        );
        return [];
      }
    } catch (e, stack) {
      print('[TreeRepo-REST] ❌ Error fetching trees: $e');
      print('[TreeRepo-REST] Stack: $stack');
      return [];
    }
  }

  /// Verify a tree exists (optional check after adding)
  Future<bool> verifyTreeExists(String docId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;

      final token = await user.getIdToken();
      if (token == null) return false;

      final url = Uri.parse(
        '$baseUrl/projects/$projectId/databases/$databaseId/documents/trees/$docId',
      );

      final response = await http
          .get(url, headers: {'Authorization': 'Bearer $token'})
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      print('[TreeRepo-REST] Verification failed: $e');
      return false;
    }
  }

  /// Upvote a tree using REST API
  Future<void> upvoteTree(String treeId, String userId) async {
    print('[TreeRepo-REST] Upvoting tree $treeId for user $userId');

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final token = await user.getIdToken();
      if (token == null) {
        throw Exception('Could not get auth token');
      }

      // First, get the current tree data
      final getUrl = Uri.parse(
        '$baseUrl/projects/$projectId/databases/$databaseId/documents/trees/$treeId',
      );

      final getResponse = await http
          .get(getUrl, headers: {'Authorization': 'Bearer $token'})
          .timeout(const Duration(seconds: 5));

      if (getResponse.statusCode != 200) {
        throw Exception('Failed to fetch tree: ${getResponse.statusCode}');
      }

      final treeData = jsonDecode(getResponse.body);
      final fields = treeData['fields'] as Map<String, dynamic>;

      // Parse current votes
      List<String> upvotes =
          (fields['upvotes']?['arrayValue']?['values'] as List<dynamic>?)
              ?.map((v) => v['stringValue'] as String)
              .toList() ??
          [];
      List<String> downvotes =
          (fields['downvotes']?['arrayValue']?['values'] as List<dynamic>?)
              ?.map((v) => v['stringValue'] as String)
              .toList() ??
          [];

      // Toggle upvote
      bool isAddingUpvote = !upvotes.contains(userId);

      if (upvotes.contains(userId)) {
        upvotes.remove(userId);
      } else {
        upvotes.add(userId);
        downvotes.remove(userId);
      }

      // Build update mask
      String updateMask =
          'updateMask.fieldPaths=upvotes&updateMask.fieldPaths=downvotes';
      if (isAddingUpvote) {
        updateMask += '&updateMask.fieldPaths=lastVerifiedAt';
      }

      // Update the tree
      final updateUrl = Uri.parse(
        '$baseUrl/projects/$projectId/databases/$databaseId/documents/trees/$treeId?$updateMask',
      );

      final updateFields = <String, dynamic>{
        'upvotes': {
          'arrayValue': {
            'values': upvotes.map((id) => {'stringValue': id}).toList(),
          },
        },
        'downvotes': {
          'arrayValue': {
            'values': downvotes.map((id) => {'stringValue': id}).toList(),
          },
        },
      };

      // Add lastVerifiedAt when adding an upvote
      if (isAddingUpvote) {
        updateFields['lastVerifiedAt'] = <String, dynamic>{
          'timestampValue': DateTime.now().toUtc().toIso8601String(),
        };
      }

      final updateBody = {'fields': updateFields};

      final updateResponse = await http
          .patch(
            updateUrl,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(updateBody),
          )
          .timeout(const Duration(seconds: 10));

      if (updateResponse.statusCode == 200) {
        print('[TreeRepo-REST] ✅ Upvote successful');
      } else {
        throw Exception(
          'Failed to update votes: ${updateResponse.statusCode} - ${updateResponse.body}',
        );
      }
    } catch (e, stack) {
      print('[TreeRepo-REST] ❌ Upvote failed: $e');
      print('[TreeRepo-REST] Stack: $stack');
      rethrow;
    }
  }

  /// Downvote a tree using REST API
  Future<void> downvoteTree(String treeId, String userId) async {
    print('[TreeRepo-REST] Downvoting tree $treeId for user $userId');

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final token = await user.getIdToken();
      if (token == null) {
        throw Exception('Could not get auth token');
      }

      // First, get the current tree data
      final getUrl = Uri.parse(
        '$baseUrl/projects/$projectId/databases/$databaseId/documents/trees/$treeId',
      );

      final getResponse = await http
          .get(getUrl, headers: {'Authorization': 'Bearer $token'})
          .timeout(const Duration(seconds: 5));

      if (getResponse.statusCode != 200) {
        throw Exception('Failed to fetch tree: ${getResponse.statusCode}');
      }

      final treeData = jsonDecode(getResponse.body);
      final fields = treeData['fields'] as Map<String, dynamic>;

      // Parse current votes
      List<String> upvotes =
          (fields['upvotes']?['arrayValue']?['values'] as List<dynamic>?)
              ?.map((v) => v['stringValue'] as String)
              .toList() ??
          [];
      List<String> downvotes =
          (fields['downvotes']?['arrayValue']?['values'] as List<dynamic>?)
              ?.map((v) => v['stringValue'] as String)
              .toList() ??
          [];

      // Toggle downvote
      if (downvotes.contains(userId)) {
        downvotes.remove(userId);
      } else {
        downvotes.add(userId);
        upvotes.remove(userId);
      }

      // Update the tree
      final updateUrl = Uri.parse(
        '$baseUrl/projects/$projectId/databases/$databaseId/documents/trees/$treeId?updateMask.fieldPaths=upvotes&updateMask.fieldPaths=downvotes',
      );

      final updateBody = {
        'fields': {
          'upvotes': {
            'arrayValue': {
              'values': upvotes.map((id) => {'stringValue': id}).toList(),
            },
          },
          'downvotes': {
            'arrayValue': {
              'values': downvotes.map((id) => {'stringValue': id}).toList(),
            },
          },
        },
      };

      final updateResponse = await http
          .patch(
            updateUrl,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(updateBody),
          )
          .timeout(const Duration(seconds: 10));

      if (updateResponse.statusCode == 200) {
        print('[TreeRepo-REST] ✅ Downvote successful');
      } else {
        throw Exception(
          'Failed to update votes: ${updateResponse.statusCode} - ${updateResponse.body}',
        );
      }
    } catch (e, stack) {
      print('[TreeRepo-REST] ❌ Downvote failed: $e');
      print('[TreeRepo-REST] Stack: $stack');
      rethrow;
    }
  }
}
