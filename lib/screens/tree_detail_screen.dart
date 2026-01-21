import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:treesha/l10n/app_localizations.dart';
import 'package:treesha/models/tree_model.dart';
import 'package:treesha/models/tree_post.dart';
import 'package:treesha/services/firebase_auth_service.dart';
import 'package:treesha/services/firebase_service.dart';
import 'package:treesha/services/tree_repository_no_confirm.dart';
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
  final TreeRepositoryNoConfirm _treeRepository = TreeRepositoryNoConfirm();
  User? _user;

  // Local state to track votes for immediate UI updates
  late List<String> _upvotes;
  late List<String> _downvotes;

  // Posts state
  List<TreePost> _posts = [];
  bool _isLoadingPosts = false;
  bool _isAddingPost = false;

  @override
  void initState() {
    super.initState();

    // Initialize local vote state from the tree
    _upvotes = List.from(widget.tree.upvotes);
    _downvotes = List.from(widget.tree.downvotes);

    // Debug: Check lastVerifiedAt
    debugPrint('[TreeDetailScreen] Tree: ${widget.tree.name}');
    debugPrint('[TreeDetailScreen] lastVerifiedAt: ${widget.tree.lastVerifiedAt}');
    debugPrint('[TreeDetailScreen] upvotes: ${widget.tree.upvotes.length}');

    _authService.user.listen((user) {
      if (mounted) {
        setState(() {
          _user = user;
        });
      }
    });

    // Load posts
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    if (!mounted) return;
    setState(() {
      _isLoadingPosts = true;
    });

    try {
      final postsData = await _treeRepository.getTreePosts(widget.tree.id);
      if (!mounted) return;

      final posts = postsData.map((data) {
        return TreePost.fromRestApi(data, data['id'] as String);
      }).toList();

      posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      if (mounted) {
        setState(() {
          _posts = posts;
          _isLoadingPosts = false;
        });
      }
    } catch (e) {
      debugPrint('[TreeDetailScreen] Error loading posts: $e');
      if (mounted) {
        setState(() {
          _isLoadingPosts = false;
        });
      }
    }
  }

  /// Open Google Maps with directions to the tree
  Future<void> _navigateToTree() async {
    final lat = widget.tree.position.latitude;
    final lng = widget.tree.position.longitude;

    final url = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');

    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error opening maps: $e')));
    }
  }

  Future<void> _showAddPostDialog() async {
    if (_user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You need to be logged in to add photos or comments'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _AddPostDialog(),
    );

    if (result != null) {
      await _addPost(
        result['images'] as List<XFile>,
        result['comment'] as String,
      );
    }
  }

  Future<void> _addPost(List<XFile> images, String comment) async {
    if (!mounted) return;
    setState(() {
      _isAddingPost = true;
    });

    try {
      List<String> imageUrls = [];
      for (var image in images) {
        final url = await _firebaseService.uploadImage(image);
        if (!mounted) return;
        imageUrls.add(url);
      }

      await _treeRepository.addPostToTree(widget.tree.id, {
        'userId': _user!.uid,
        'userName': _user!.displayName ?? 'Anonymous',
        'imageUrls': imageUrls,
        'comment': comment,
      });
      if (!mounted) return;

      await _loadPosts();
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Post added successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      debugPrint('[TreeDetailScreen] Error adding post: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add post: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAddingPost = false;
        });
      }
    }
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Report Content'),
          content: const Text(
            'Are you sure you want to report this tree? Our team will review it.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Implement actual reporting logic
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Report submitted. Thank you!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Report'),
            ),
          ],
        );
      },
    );
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
        actions: [
          // Report button
          IconButton(
            icon: const Icon(Icons.flag),
            tooltip: 'Report this content',
            onPressed: _showReportDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Tree info header (non-scrollable)
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border(
                bottom: BorderSide(color: Colors.grey[300]!, width: 1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.treeNameLabel(widget.tree.name),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.fruitTypeLabel(widget.tree.fruitType),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                // Voting section
                Row(
                  children: [
                    // Upvote button
                    IconButton(
                      icon: Icon(
                        Icons.thumb_up,
                        color: isUpvoted ? Colors.green : Colors.grey,
                      ),
                      onPressed: () async {
                        if (_user == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'You need to be logged in to verify trees',
                              ),
                              duration: Duration(seconds: 2),
                            ),
                          );
                          return;
                        }

                        setState(() {
                          if (_upvotes.contains(_user!.uid)) {
                            _upvotes.remove(_user!.uid);
                          } else {
                            _upvotes.add(_user!.uid);
                            _downvotes.remove(_user!.uid);
                          }
                        });

                        try {
                          await _firebaseService.upvoteTree(
                            widget.tree.id,
                            _user!.uid,
                          );
                        } catch (e) {
                          setState(() {
                            _upvotes = List.from(widget.tree.upvotes);
                            _downvotes = List.from(widget.tree.downvotes);
                          });
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.errorUpvoting(e.toString())),
                            ),
                          );
                        }
                      },
                    ),
                    Text(
                      '${_upvotes.length}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Downvote button
                    IconButton(
                      icon: Icon(
                        Icons.thumb_down,
                        color: isDownvoted ? Colors.red : Colors.grey,
                      ),
                      onPressed: () async {
                        if (_user == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'You need to be logged in to unverify trees',
                              ),
                              duration: Duration(seconds: 2),
                            ),
                          );
                          return;
                        }

                        setState(() {
                          if (_downvotes.contains(_user!.uid)) {
                            _downvotes.remove(_user!.uid);
                          } else {
                            _downvotes.add(_user!.uid);
                            _upvotes.remove(_user!.uid);
                          }
                        });

                        try {
                          await _firebaseService.downvoteTree(
                            widget.tree.id,
                            _user!.uid,
                          );
                        } catch (e) {
                          setState(() {
                            _upvotes = List.from(widget.tree.upvotes);
                            _downvotes = List.from(widget.tree.downvotes);
                          });
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.errorDownvoting(e.toString())),
                            ),
                          );
                        }
                      },
                    ),
                    Text(
                      '${_downvotes.length}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const Spacer(),
                    // Navigate button
                    ElevatedButton.icon(
                      onPressed: _navigateToTree,
                      icon: const Icon(Icons.directions, size: 18),
                      label: const Text('Navigate'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Added ${widget.tree.createdAt.toDate().toLocal().toString().split(' ')[0]}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (widget.tree.lastVerifiedAt != null)
                  Text(
                    'Last verified: ${widget.tree.lastVerifiedAt!.toDate().toLocal().toString().split(' ')[0]}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.green[700]),
                  ),
              ],
            ),
          ),
          // Posts list (scrollable)
          Expanded(
            child: _isLoadingPosts
                ? const Center(child: CircularProgressIndicator())
                : _posts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No photos or comments yet',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Be the first to share!',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _posts.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 32),
                    itemBuilder: (context, index) {
                      final post = _posts[index];
                      return _buildPostCard(post);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isAddingPost ? null : _showAddPostDialog,
        icon: _isAddingPost
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.add_photo_alternate),
        label: Text(_isAddingPost ? 'Posting...' : 'Add Photos/Comment'),
        backgroundColor: _isAddingPost
            ? Colors.grey
            : Theme.of(context).primaryColor,
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final local = dateTime.toLocal();
    final date =
        '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
    final time =
        '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
    return '$date $time';
  }

  /// Show full-screen image viewer
  void _showFullScreenImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            // Full-screen image with zoom capabilities
            Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                        color: Colors.white,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(
                        Icons.broken_image,
                        size: 100,
                        color: Colors.white54,
                      ),
                    );
                  },
                ),
              ),
            ),
            // Close button
            Positioned(
              top: 40,
              right: 16,
              child: IconButton(
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 32,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostCard(TreePost post) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Post header (user info and date)
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Text(
                    post.userName.isNotEmpty
                        ? post.userName[0].toUpperCase()
                        : 'A',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        _formatDateTime(post.createdAt.toDate()),
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Comment
            if (post.comment.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(post.comment, style: const TextStyle(fontSize: 15)),
            ],
            // Photos
            if (post.imageUrls.isNotEmpty) ...[
              const SizedBox(height: 12),
              post.imageUrls.length == 1
                  ? GestureDetector(
                      onTap: () => _showFullScreenImage(context, post.imageUrls[0]),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          post.imageUrls[0],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 200,
                              color: Colors.grey[300],
                              child: const Icon(Icons.broken_image, size: 50),
                            );
                          },
                        ),
                      ),
                    )
                  : SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: post.imageUrls.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () => _showFullScreenImage(context, post.imageUrls[index]),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  post.imageUrls[index],
                                  fit: BoxFit.cover,
                                  width: 200,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return Container(
                                        width: 200,
                                        color: Colors.grey[300],
                                        child: const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      );
                                    },
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 200,
                                    color: Colors.grey[300],
                                    child: const Icon(
                                      Icons.broken_image,
                                      size: 50,
                                    ),
                                  );
                                },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Simplified dialog widget for adding posts
class _AddPostDialog extends StatefulWidget {
  @override
  State<_AddPostDialog> createState() => _AddPostDialogState();
}

class _AddPostDialogState extends State<_AddPostDialog> {
  final _commentController = TextEditingController();
  final List<XFile> _selectedImages = [];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  bool get _canPost => _selectedImages.isNotEmpty || _commentController.text.trim().isNotEmpty;

  Future<void> _pickImages() async {
    final images = await ImagePicker().pickMultiImage();
    if (images.isNotEmpty) {
      setState(() => _selectedImages.addAll(images));
    }
  }

  void _removeImage(int index) {
    setState(() => _selectedImages.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Photos/Comment'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                labelText: 'Comment (optional)',
                hintText: 'Add a comment...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Photos (${_selectedImages.length})',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                TextButton.icon(
                  onPressed: _pickImages,
                  icon: const Icon(Icons.add_photo_alternate),
                  label: const Text('Add Photos'),
                ),
              ],
            ),
            if (_selectedImages.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _selectedImages.asMap().entries.map((entry) {
                  final index = entry.key;
                  final image = entry.value;
                  return Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: FutureBuilder<Uint8List>(
                            future: image.readAsBytes(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Image.memory(
                                  snapshot.data!,
                                  fit: BoxFit.cover,
                                );
                              }
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                          ),
                        ),
                      ),
                      Positioned(
                        right: -4,
                        top: -4,
                        child: IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.red),
                          onPressed: () => _removeImage(index),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _canPost
              ? () => Navigator.of(context).pop({
                    'images': _selectedImages,
                    'comment': _commentController.text.trim(),
                  })
              : null,
          child: const Text('Post'),
        ),
      ],
    );
  }
}
