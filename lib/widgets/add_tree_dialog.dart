import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:treesha/l10n/app_localizations.dart';
import 'package:treesha/models/fruit_model.dart'; // Import fruit_model
import 'package:treesha/services/fruit_service.dart'; // Import fruit_service

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
          print(
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
                    // Check if the entered value is one of the valid fruit types
                    if (_allFruits.any((fruit) => fruit.type == value)) {
                      return null; // Valid fruit selected
                    }
                    return l10n.pleaseSelectValidFruit;
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
                          return ListTile(
                            title: Text(fruit.type),
                            subtitle: Text(fruit.edibleSeason),
                            onTap: () {
                              setState(() {
                                _fruitTypeController.text = fruit.type;
                                _selectedFruitType =
                                    fruit.type; // Confirm selection
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
                  decoration: const InputDecoration(
                    labelText: 'Comment (optional)',
                    hintText: 'Add a comment about this tree...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 20),
                // Photos section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Photos (${_images.length})',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    TextButton.icon(
                      onPressed: _isLoading ? null : _pickImages,
                      icon: const Icon(Icons.add_photo_alternate),
                      label: const Text('Add Photos'),
                    ),
                  ],
                ),
                if (_images.isNotEmpty)
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _images.length,
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  _images[index].path,
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
                                icon: const Icon(
                                  Icons.cancel,
                                  color: Colors.red,
                                ),
                                onPressed: () => _removeImage(index),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
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
                    print('[AddTreeDialog] Cancel button pressed');
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
                      print('[AddTreeDialog] Form validated, starting save...');
                      print(
                        '[AddTreeDialog] Tree name: ${_nameController.text}',
                      );
                      print(
                        '[AddTreeDialog] Fruit type: ${_selectedFruitType ?? _fruitTypeController.text}',
                      );
                      print('[AddTreeDialog] Images: ${_images.length}');
                      print(
                        '[AddTreeDialog] Comment: ${_commentController.text}',
                      );

                      setState(() => _isLoading = true);
                      try {
                        final result = await widget.onAdd(
                          _nameController.text,
                          _selectedFruitType ?? _fruitTypeController.text,
                          _images,
                          _commentController.text,
                        );

                        print(
                          '[AddTreeDialog] onAdd completed with result: $result',
                        );

                        if (result && mounted) {
                          print('[AddTreeDialog] Success, closing dialog');
                          Navigator.of(context).pop();
                        } else if (!result && mounted) {
                          print('[AddTreeDialog] Failed to save tree');
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
                        print('[AddTreeDialog] ERROR: Exception in onAdd: $e');
                        print('[AddTreeDialog] Stack trace: $stackTrace');

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
                          print('[AddTreeDialog] Loading state reset');
                        }
                      }
                    } else {
                      print('[AddTreeDialog] Form validation failed');
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
