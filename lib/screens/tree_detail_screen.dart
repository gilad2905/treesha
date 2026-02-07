import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:treez/models/tree_model.dart';
import 'package:treez/models/tree_post.dart';
import 'package:treez/services/firebase_auth_service.dart';
import 'package:treez/services/firebase_service.dart';
import 'package:treez/services/tree_repository.dart';
import 'package:treez/services/tree_repository_no_confirm.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:treez/l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';

class TreeDetailScreen extends StatefulWidget {
  final Tree tree;

  const TreeDetailScreen({super.key, required this.tree});

  @override
  State<TreeDetailScreen> createState() => _TreeDetailScreenState();
}

class _TreeDetailScreenState extends State<TreeDetailScreen> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final FirebaseService _firebaseService = FirebaseService();
  final TreeRepository _treeRepository = TreeRepository();
  final TreeRepositoryNoConfirm _treeRepositoryNoConfirm =
      TreeRepositoryNoConfirm();
  User? _user;
  List<String> _userRoles = ['user'];

  // Local state to track votes for immediate UI updates
  late List<String> _upvotes;
  late List<String> _downvotes;
  late List<String> _reported;

  // Posts state
  List<TreePost> _posts = [];
  bool _isLoadingPosts = false;
  bool _isAddingPost = false;
  String? _fruitIconAsset;
  String? _fruitTypeHe;

  @override
  void initState() {
    super.initState();

    // Initialize local state from the tree
    _upvotes = List.from(widget.tree.upvotes);
    _downvotes = List.from(widget.tree.downvotes);
    _reported = List.from(widget.tree.reported);

    // Debug: Check lastVerifiedAt
    debugPrint('[TreeDetailScreen] Tree: ${widget.tree.name}');
    debugPrint(
      '[TreeDetailScreen] lastVerifiedAt: ${widget.tree.lastVerifiedAt}',
    );
    debugPrint('[TreeDetailScreen] upvotes: ${widget.tree.upvotes.length}');

    _authService.user.listen((user) async {
      if (!mounted) return;
      List<String> roles = ['user'];
      if (user != null) {
        roles = await _authService.getUserRoles(user.uid);
      }
      if (mounted) {
        setState(() {
          _user = user;
          _userRoles = roles;
        });
      }
    });

    // Load posts
    _loadPosts();
    _loadFruitIcon();
  }

  Future<void> _loadFruitIcon() async {
    try {
      final String response = await rootBundle.loadString('assets/fruits.json');
      final List<dynamic> data = json.decode(response);

      String? iconName;
      String? hebName;
      for (var item in data) {
        if (item['fruit_type'].toString().toLowerCase() ==
            widget.tree.fruitType.toLowerCase()) {
          iconName = item['icon'];
          hebName = item['fruit_type_he'];
          break;
        }
      }

      if (mounted) {
        setState(() {
          _fruitTypeHe = hebName;
          if (iconName != null) {
            _fruitIconAsset = 'assets/fruit_icons/$iconName';
          } else {
            _fruitIconAsset = 'assets/tree.svg';
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading fruit icon: $e');
      if (mounted) {
        setState(() {
          _fruitIconAsset = 'assets/tree.svg';
        });
      }
    }
  }

  Future<void> _loadPosts() async {
    if (!mounted) return;
    setState(() {
      _isLoadingPosts = true;
    });

    try {
      final postsData = await _treeRepositoryNoConfirm.getTreePosts(
        widget.tree.id,
      );
      if (!mounted) return;

      final posts =
          postsData.map((data) {
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

    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng',
    );

    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error opening maps: $e')));
    }
  }

  Future<void> _showAddPostDialog() async {
    final l10n = AppLocalizations.of(context)!;
    if (_user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.loginToAddPhotos),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _AddPostDialog(),
    );

    if (result != null) {
      await _addPost(
        result['images'] as List<XFile>,
        result['comment'] as String,
      );
    }
  }

  Future<void> _addPost(List<XFile> images, String comment) async {
    final l10n = AppLocalizations.of(context)!;
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

      await _treeRepositoryNoConfirm.addPostToTree(widget.tree.id, {
        'userId': _user!.uid,
        'userName': _user!.displayName ?? l10n.anonymous,
        'imageUrls': imageUrls,
        'comment': comment,
      });
      if (!mounted) return;

      await _loadPosts();
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.postAddedSuccessfully),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      debugPrint('[TreeDetailScreen] Error adding post: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.somethingWentWrong}: $e'),
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
    final l10n = AppLocalizations.of(context)!;
    if (_user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.loginToReport)),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.reportContent),
          content: Text(l10n.reportConfirmation),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                try {
                  await _treeRepository.reportTree(widget.tree.id, _user!.uid);
                  if (mounted) {
                    setState(() {
                      if (!_reported.contains(_user!.uid)) {
                        _reported.add(_user!.uid);
                      }
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.reportSubmitted),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${l10n.somethingWentWrong}: $e')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text(l10n.report),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteTreeDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteTree),
        content: Text(l10n.deleteTreeConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _deleteTree();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.deleteTree),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTree() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await _treeRepository.deleteTree(widget.tree.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.treeDeletedSuccessfully),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); // Return true to indicate deletion
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.somethingWentWrong}: $e')),
        );
      }
    }
  }

  Future<void> _deletePost(String postId) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await _treeRepository.deletePost(widget.tree.id, postId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.postDeletedSuccessfully),
            backgroundColor: Colors.green,
          ),
        );
        _loadPosts(); // Refresh posts list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.somethingWentWrong}: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isUpvoted = _user != null && _upvotes.contains(_user!.uid);
    bool isDownvoted = _user != null && _downvotes.contains(_user!.uid);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tree.name),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          // Share button
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            tooltip: l10n.share,
            onPressed: () {
              final fruit = (Localizations.localeOf(context).languageCode == 'he' && _fruitTypeHe != null)
                  ? _fruitTypeHe!
                  : widget.tree.fruitType;
              final shareText = l10n.shareText(fruit);
              final lat = widget.tree.position.latitude;
              final lng = widget.tree.position.longitude;
              final googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
              
              Share.share('$shareText\n\n$googleMapsUrl');
            },
          ),
          // Delete button for admin or owner
          if (_user != null &&
              (_userRoles.contains('admin') || _user!.uid == widget.tree.userId))
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: l10n.deleteTreeTooltip,
              onPressed: _showDeleteTreeDialog,
            ),
          // Report button
          IconButton(
            icon: const Icon(Icons.flag, color: Colors.white),
            tooltip: l10n.reportTooltip,
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
                Row(
                  children: [
                    if (_fruitIconAsset != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: SvgPicture.asset(
                          _fruitIconAsset!,
                          width: 48,
                          height: 48,
                        ),
                      ),
                    Expanded(
                      child: Text(
                        (Localizations.localeOf(context).languageCode == 'he' &&
                                _fruitTypeHe != null)
                            ? _fruitTypeHe!
                            : widget.tree.fruitType,
                        style: Theme.of(
                          context,
                        ).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: widget.tree.status == 'approved'
                            ? Colors.green
                            : widget.tree.status == 'rejected'
                                ? Colors.red
                                : Colors.orange,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        widget.tree.status == 'approved'
                            ? l10n.statusApproved
                            : widget.tree.status == 'rejected'
                                ? l10n.statusRejected
                                : l10n.statusPending,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
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
                            SnackBar(
                              content: Text(l10n.loginToVerify),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                          return;
                        }

                        // Optimistic update
                        final oldUpvotes = List<String>.from(_upvotes);
                        final oldDownvotes = List<String>.from(_downvotes);

                        setState(() {
                          if (_upvotes.contains(_user!.uid)) {
                            _upvotes.remove(_user!.uid);
                          } else {
                            _upvotes.add(_user!.uid);
                            _downvotes.remove(_user!.uid);
                          }
                        });

                        try {
                          await _treeRepository.upvoteTree(
                            widget.tree.id,
                            _user!.uid,
                          );
                        } catch (e) {
                          // Revert if failed
                          setState(() {
                            _upvotes = oldUpvotes;
                            _downvotes = oldDownvotes;
                          });

                          if (!mounted) return;

                          String errorMessage;
                          if (e is TreeRepositoryException) {
                            errorMessage = e.message;
                          } else {
                            errorMessage = e.toString();
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${l10n.somethingWentWrong}: $errorMessage'),
                              backgroundColor: Colors.red,
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
                            SnackBar(
                              content: Text(l10n.loginToUnverify),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                          return;
                        }

                        // Optimistic update
                        final oldUpvotes = List<String>.from(_upvotes);
                        final oldDownvotes = List<String>.from(_downvotes);

                        setState(() {
                          if (_downvotes.contains(_user!.uid)) {
                            _downvotes.remove(_user!.uid);
                          } else {
                            _downvotes.add(_user!.uid);
                            _upvotes.remove(_user!.uid);
                          }
                        });

                        try {
                          await _treeRepository.downvoteTree(
                            widget.tree.id,
                            _user!.uid,
                          );
                        } catch (e) {
                          // Revert
                          setState(() {
                            _upvotes = oldUpvotes;
                            _downvotes = oldDownvotes;
                          });

                          if (!mounted) return;

                          String errorMessage;
                          if (e is TreeRepositoryException) {
                            errorMessage = e.message;
                          } else {
                            errorMessage = e.toString();
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${l10n.somethingWentWrong}: $errorMessage'),
                              backgroundColor: Colors.red,
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
                      label: Text(l10n.navigate),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.addedDate(widget.tree.createdAt.toDate().toLocal().toString().split(' ')[0]),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (widget.tree.lastVerifiedAt != null)
                  Text(
                    l10n.lastVerifiedDate(widget.tree.lastVerifiedAt!.toDate().toLocal().toString().split(' ')[0]),
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
                          l10n.noPhotosOrComments,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.beTheFirstToShare,
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
        label: Text(_isAddingPost
            ? l10n.posting
            : l10n.addCommentPhotos),
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
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: Center(
            child: InteractiveViewer(
              minScale: 1.0,
              maxScale: 5.0,
              clipBehavior: Clip.none,
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                width: double.infinity,
                height: double.infinity,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value:
                          loadingProgress.expectedTotalBytes != null
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
        ),
      ),
    );
  }

  Widget _buildPostCard(TreePost post) {
    final l10n = AppLocalizations.of(context)!;
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
                // Delete post button for admin or owner
                if (_user != null &&
                    (_userRoles.contains('admin') || _user!.uid == post.userId))
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20, color: Colors.grey),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(l10n.deletePost),
                          content: Text(l10n.deletePostConfirmation),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text(l10n.cancel),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                _deletePost(post.id);
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                              child: Text(l10n.deletePost),
                            ),
                          ],
                        ),
                      );
                    },
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
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.addPhotos),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                labelText: l10n.commentOptional,
                hintText: l10n.addCommentHint,
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.photos(_selectedImages.length),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                TextButton.icon(
                  onPressed: _pickImages,
                  icon: const Icon(Icons.add_photo_alternate),
                  label: Text(l10n.addPhotos),
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
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: _canPost
              ? () => Navigator.of(context).pop({
                    'images': _selectedImages,
                    'comment': _commentController.text.trim(),
                  })
              : null,
          child: Text(l10n.add),
        ),
      ],
    );
  }
}
