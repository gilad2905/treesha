import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:treesha/models/tree_model.dart';
import 'package:treesha/services/firebase_auth_service.dart';
import 'package:treesha/services/firebase_service.dart';

class TreeDetailScreen extends StatefulWidget {
  final Tree tree;

  const TreeDetailScreen({super.key, required this.tree});

  @override
  State<TreeDetailScreen> createState() => _TreeDetailScreenState();
}

class _TreeDetailScreenState extends State<TreeDetailScreen> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final FirebaseService _firebaseService = FirebaseService();
  User? _user;

  @override
  void initState() {
    super.initState();
    _authService.user.listen((user) {
      if (mounted) {
        setState(() {
          _user = user;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Add real-time updates via REST API if needed
    // For now, just display the tree data passed in
    final updatedTree = widget.tree;
    bool isUpvoted = _user != null && updatedTree.upvotes.contains(_user!.uid);
    bool isDownvoted = _user != null && updatedTree.downvotes.contains(_user!.uid);

    return Scaffold(
      appBar: AppBar(
        title: Text(updatedTree.name),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tree Name: ${updatedTree.name}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Fruit Type: ${updatedTree.fruitType}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              updatedTree.imageUrl.isNotEmpty
                  ? Image.network(
                      updatedTree.imageUrl,
                      fit: BoxFit.contain,
                      loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        }
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                        return const Icon(Icons.broken_image, size: 100);
                      },
                    )
                  : const SizedBox.shrink(),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(Icons.thumb_up, color: isUpvoted ? Colors.green : Colors.grey),
                    onPressed: _user == null ? null : () async {
                      try {
                        await _firebaseService.upvoteTree(updatedTree.id, _user!.uid);
                        // Show success message
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Upvoted! Close and reopen to see changes.')),
                        );
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error upvoting tree: $e')),
                        );
                      }
                    },
                  ),
                  Text('${updatedTree.upvotes.length}'),
                  IconButton(
                    icon: Icon(Icons.thumb_down, color: isDownvoted ? Colors.red : Colors.grey),
                    onPressed: _user == null ? null : () async {
                      try {
                        await _firebaseService.downvoteTree(updatedTree.id, _user!.uid);
                        // Show success message
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Downvoted! Close and reopen to see changes.')),
                        );
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error downvoting tree: $e')),
                        );
                      }
                    },
                  ),
                  Text('${updatedTree.downvotes.length}'),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Location: Lat ${updatedTree.position.latitude}, Lng ${updatedTree.position.longitude}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                'Added on: ${updatedTree.createdAt.toDate().toLocal()}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}