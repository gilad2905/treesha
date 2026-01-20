import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:treesha/l10n/app_localizations.dart';
import 'package:treesha/models/tree_model.dart';
import 'package:treesha/services/firebase_auth_service.dart';
import 'package:treesha/services/firebase_service.dart';
import 'package:url_launcher/url_launcher.dart';

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

  // Local state to track votes for immediate UI updates
  late List<String> _upvotes;
  late List<String> _downvotes;

  @override
  void initState() {
    super.initState();

    // Initialize local vote state from the tree
    _upvotes = List.from(widget.tree.upvotes);
    _downvotes = List.from(widget.tree.downvotes);

    _authService.user.listen((user) {
      if (mounted) {
        setState(() {
          _user = user;
        });
      }
    });
  }

  /// Open Google Maps with directions to the tree
  Future<void> _navigateToTree() async {
    final lat = widget.tree.position.latitude;
    final lng = widget.tree.position.longitude;

    // Google Maps URL for directions
    final url = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');

    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening maps: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    bool isUpvoted = _user != null && _upvotes.contains(_user!.uid);
    bool isDownvoted = _user != null && _downvotes.contains(_user!.uid);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tree.name),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.treeNameLabel(widget.tree.name),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.fruitTypeLabel(widget.tree.fruitType),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              widget.tree.imageUrl.isNotEmpty
                  ? Image.network(
                      widget.tree.imageUrl,
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
              // Voting section with improved layout
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      l10n.verificationScore(_upvotes.length - _downvotes.length),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Upvote button
                        Column(
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.thumb_up,
                                color: isUpvoted ? Colors.green : Colors.grey,
                                size: 32,
                              ),
                              onPressed: () async {
                                // Check if user is logged in
                                if (_user == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('You need to be logged in to verify trees'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                  return;
                                }

                                // Update local state immediately for instant feedback
                                setState(() {
                                  if (_upvotes.contains(_user!.uid)) {
                                    _upvotes.remove(_user!.uid);
                                  } else {
                                    _upvotes.add(_user!.uid);
                                    _downvotes.remove(_user!.uid);
                                  }
                                });

                                // Then update the database
                                try {
                                  await _firebaseService.upvoteTree(widget.tree.id, _user!.uid);
                                } catch (e) {
                                  // Revert on error
                                  setState(() {
                                    _upvotes = List.from(widget.tree.upvotes);
                                    _downvotes = List.from(widget.tree.downvotes);
                                  });
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(l10n.errorUpvoting(e.toString()))),
                                  );
                                }
                              },
                            ),
                            Text(
                              '${_upvotes.length}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        // Downvote button
                        Column(
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.thumb_down,
                                color: isDownvoted ? Colors.red : Colors.grey,
                                size: 32,
                              ),
                              onPressed: () async {
                                // Check if user is logged in
                                if (_user == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('You need to be logged in to unverify trees'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                  return;
                                }

                                // Update local state immediately for instant feedback
                                setState(() {
                                  if (_downvotes.contains(_user!.uid)) {
                                    _downvotes.remove(_user!.uid);
                                  } else {
                                    _downvotes.add(_user!.uid);
                                    _upvotes.remove(_user!.uid);
                                  }
                                });

                                // Then update the database
                                try {
                                  await _firebaseService.downvoteTree(widget.tree.id, _user!.uid);
                                } catch (e) {
                                  // Revert on error
                                  setState(() {
                                    _upvotes = List.from(widget.tree.upvotes);
                                    _downvotes = List.from(widget.tree.downvotes);
                                  });
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(l10n.errorDownvoting(e.toString()))),
                                  );
                                }
                              },
                            ),
                            Text(
                              '${_downvotes.length}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.location(widget.tree.position.latitude, widget.tree.position.longitude),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                l10n.addedOn(widget.tree.createdAt.toDate().toLocal().toString()),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (widget.tree.lastVerifiedAt != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Last verified: ${widget.tree.lastVerifiedAt!.toDate().toLocal().toString().split('.')[0]}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.green[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              // Navigate to tree button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _navigateToTree,
                  icon: const Icon(Icons.directions),
                  label: const Text('Navigate to this tree'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}