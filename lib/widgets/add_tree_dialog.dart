import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:treez/l10n/app_localizations.dart';
import 'package:treez/models/fruit_model.dart'; // Import fruit_model
import 'package:treez/services/fruit_service.dart'; // Import fruit_service

class AddTreeDialog extends StatefulWidget {
  final Future<bool> Function(
    String name,
    String fruitType,
    List<XFile> images,
    String comment,
  )
  onAdd; // Updated signature for multiple photos and comment

  const AddTreeDialog({super.key, required this.onAdd});

  @override
  // ignore: library_private_types_in_public_api
  _AddTreeDialogState createState() => _AddTreeDialogState();
}

class _AddTreeDialogState extends State<AddTreeDialog> {
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _fruitTypeController =
      TextEditingController(); // Controller for fruit type input
  final _commentController = TextEditingController(); // Controller for comment
  String? _selectedFruitType; // Store the final selected fruit type

  List<Fruit> _allFruits = []; // All fruits loaded from asset
  List<Fruit> _filteredFruits = []; // Fruits filtered by user input
  List<XFile> _images = []; // Multiple images

  @override
  void initState() {
    super.initState();
    _loadAllFruits();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _fruitTypeController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadAllFruits() async {
    try {
      final loadedFruits = await FruitService.loadFruits();
      setState(() {
        _allFruits = loadedFruits;
        _filteredFruits = loadedFruits; // Initially show all fruits
      });
    } catch (e) {
      // Error loading all fruits: $e
    }
  }

  void _onFruitTypeChanged(String pattern) {
    setState(() {
      if (pattern.isEmpty) {
        _filteredFruits = _allFruits;
      } else {
        _filteredFruits = _allFruits
            .where(
              (fruit) =>
                  fruit.type.toLowerCase().contains(pattern.toLowerCase()),
            )
            .toList();
      }
      _selectedFruitType = null; // Clear selected fruit type when user types
    });
  }

  Future<void> _pickImages() async {
    final images = await ImagePicker().pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _images.addAll(images);
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return WillPopScope(
      onWillPop: () async {
        // Prevent back button during loading
        if (_isLoading) {
          debugPrint(
            '[AddTreeDialog] Back button pressed during loading - preventing dismissal',
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please wait for the tree to be saved'),
              duration: Duration(seconds: 2),
            ),
          );
          return false;
        }
        return true;
      },
      child: AlertDialog(
        title: Text(l10n.addTree),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: l10n.treeName),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.pleaseEnterTreeName;
                    }
                    return null;
                  },
                ),
                // Manual TypeAhead-like functionality
                TextFormField(
                  controller: _fruitTypeController,
                  decoration: InputDecoration(
                    labelText: l10n.fruitType,
                    hintText: l10n.searchFruitType,
                  ),
                  onChanged: _onFruitTypeChanged,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.pleaseEnterFruitType;
                    }
                    return null; // Any non-empty string is valid
                  },
                ),
                // Display suggestions
                if (_fruitTypeController.text.isNotEmpty)
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxHeight: 200,
                    ), // Limit height of suggestions
                    child: SingleChildScrollView(
                      child: Column(
                        children: _filteredFruits.map((fruit) {
                          String displayName =
                              (Localizations.localeOf(context).languageCode ==
                                          'he' &&
                                      fruit.typeHe.isNotEmpty)
                                  ? fruit.typeHe
                                  : fruit.type;
                          return ListTile(
                            title: Text(displayName),
                            subtitle: Text(fruit.edibleSeason),
                            onTap: () {
                              setState(() {
                                _fruitTypeController.text = displayName;
                                _selectedFruitType =
                                    fruit.type; // Confirm selection (English)
                                _filteredFruits =
                                    []; // Clear suggestions after selection
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                // Comment field
                TextFormField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    labelText: l10n.commentOptional,
                    hintText: l10n.addCommentHint,
                    border: const OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 20),
                // Photos section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.photos(_images.length),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    TextButton.icon(
                      onPressed: _isLoading ? null : _pickImages,
                      icon: const Icon(Icons.add_photo_alternate),
                      label: Text(l10n.addPhotos),
                    ),
                  ],
                ),
                if (_images.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _images.asMap().entries.map((entry) {
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
                              child: Image.network(
                                image.path,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.image, size: 50);
                                },
                              ),
                            ),
                          ),
                          Positioned(
                            right: 4,
                            top: -4,
                            child: IconButton(
                              icon: const Icon(Icons.cancel, color: Colors.red),
                              onPressed: () => _removeImage(index),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading
                ? null
                : () {
                    debugPrint('[AddTreeDialog] Cancel button pressed');
                    Navigator.of(context).pop();
                  },
            child: Text(
              l10n.cancel,
              style: TextStyle(color: _isLoading ? Colors.grey : null),
            ),
          ),
          ElevatedButton(
            onPressed: _isLoading
                ? null
                : () async {
                    if (_formKey.currentState!.validate()) {
                      debugPrint('[AddTreeDialog] Form validated, starting save...');
                      debugPrint(
                        '[AddTreeDialog] Tree name: ${_nameController.text}',
                      );
                      debugPrint(
                        '[AddTreeDialog] Fruit type: ${_selectedFruitType ?? _fruitTypeController.text}',
                      );
                      debugPrint('[AddTreeDialog] Images: ${_images.length}');
                      debugPrint(
                        '[AddTreeDialog] Comment: ${_commentController.text}',
                      );

                      setState(() => _isLoading = true);
                      try {
                        String finalFruitType = _selectedFruitType ?? _fruitTypeController.text;
                        
                        // If it's a custom fruit type (not selected from list), format it
                        if (_selectedFruitType == null) {
                          // Remove symbols and format to CamelCase
                          finalFruitType = finalFruitType
                              .replaceAll(RegExp(r'[^a-zA-Z0-6\s]'), '') // Remove symbols
                              .split(' ')
                              .where((word) => word.isNotEmpty)
                              .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
                              .join(' ');
                        }

                        final result = await widget.onAdd(
                          _nameController.text,
                          finalFruitType,
                          _images,
                          _commentController.text,
                        );

                        debugPrint(
                          '[AddTreeDialog] onAdd completed with result: $result',
                        );

                        if (result && mounted) {
                          debugPrint('[AddTreeDialog] Success, closing dialog');
                          Navigator.of(context).pop();
                        } else if (!result && mounted) {
                          debugPrint('[AddTreeDialog] Failed to save tree');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Failed to save tree. Please try again.',
                              ),
                              duration: Duration(seconds: 3),
                            ),
                          );
                        }
                      } catch (e, stackTrace) {
                        debugPrint('[AddTreeDialog] ERROR: Exception in onAdd: $e');
                        debugPrint('[AddTreeDialog] Stack trace: $stackTrace');

                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: ${e.toString()}'),
                              duration: const Duration(seconds: 5),
                            ),
                          );
                        }
                      } finally {
                        if (mounted) {
                          setState(() => _isLoading = false);
                          debugPrint('[AddTreeDialog] Loading state reset');
                        }
                      }
                    } else {
                      debugPrint('[AddTreeDialog] Form validation failed');
                    }
                  },
            child: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(l10n.add),
          ),
        ],
      ),
    );
  }
}
