
import 'package:cloud_firestore/cloud_firestore.dart';


class Tree {
  final String id;
  final String userId; // ID of the user who created the tree
  final String name;
  final String fruitType;
  final GeoPoint position;
  final String imageUrl;
  final Timestamp createdAt;
  final List<String> upvotes;
  final List<String> downvotes;
  final Timestamp? lastVerifiedAt; // Timestamp of last upvote

  int get verificationScore => upvotes.length - downvotes.length;

  Tree({
    required this.id,
    required this.userId,
    required this.name,
    required this.fruitType,
    required this.position,
    required this.imageUrl,
    required this.createdAt,
    required this.upvotes,
    required this.downvotes,
    this.lastVerifiedAt,
  });

  factory Tree.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Tree(
      id: doc.id,
      userId: data['userId'] ?? '', // Default to empty string for backward compatibility
      name: data['name'] ?? '',
      fruitType: data['fruitType'] ?? '',
      position: data['position'] ?? const GeoPoint(0, 0),
      imageUrl: data['imageUrl'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      upvotes: List<String>.from(data['upvotes'] ?? []),
      downvotes: List<String>.from(data['downvotes'] ?? []),
      lastVerifiedAt: data['lastVerifiedAt'],
    );
  }
}
