import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a post on a tree (photos + comment)
/// Each post can have multiple photos and a comment
class TreePost {
  final String id;
  final String userId; // User who created the post
  final String userName; // Display name of the user
  final List<String> imageUrls; // Multiple photos
  final String comment; // Optional comment text
  final Timestamp createdAt;

  TreePost({
    required this.id,
    required this.userId,
    required this.userName,
    required this.imageUrls,
    required this.comment,
    required this.createdAt,
  });

  /// Create from Firestore document
  factory TreePost.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TreePost(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      userName: data['userName'] as String? ?? 'Anonymous',
      imageUrls: List<String>.from(data['imageUrls'] as List? ?? []),
      comment: data['comment'] as String? ?? '',
      createdAt: data['createdAt'] as Timestamp? ?? Timestamp.now(),
    );
  }

  /// Create from REST API response
  factory TreePost.fromRestApi(Map<String, dynamic> data, String docId) {
    // Parse timestamp
    Timestamp createdAt = Timestamp.now();
    if (data['createdAt'] != null) {
      if (data['createdAt'] is String) {
        final dateTime = DateTime.parse(data['createdAt'] as String);
        createdAt = Timestamp.fromDate(dateTime);
      } else if (data['createdAt'] is Timestamp) {
        createdAt = data['createdAt'] as Timestamp;
      }
    }

    return TreePost(
      id: docId,
      userId: data['userId'] as String? ?? '',
      userName: data['userName'] as String? ?? 'Anonymous',
      imageUrls: List<String>.from(data['imageUrls'] as List? ?? []),
      comment: data['comment'] as String? ?? '',
      createdAt: createdAt,
    );
  }

  /// Convert to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'imageUrls': imageUrls,
      'comment': comment,
      'createdAt': createdAt,
    };
  }
}
