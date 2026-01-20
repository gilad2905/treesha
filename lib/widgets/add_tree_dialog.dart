import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:treesha/models/fruit_model.dart'; // Import fruit_model
import 'package:treesha/services/fruit_service.dart'; // Import fruit_service

class AddTreeDialog extends StatefulWidget {
  final Future<bool> Function(String name, String fruitType, XFile? image) onAdd; // Changed signature

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
  String? _selectedFruitType; // Store the final selected fruit type

  List<Fruit> _allFruits = []; // All fruits loaded from asset
  List<Fruit> _filteredFruits = []; // Fruits filtered by user input
  XFile? _image;

  @override
  void initState() {
    super.initState();
    _loadAllFruits();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _fruitTypeController.dispose();
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
                (fruit) => fruit.type.toLowerCase().contains(pattern.toLowerCase()))
            .toList();
      }
      _selectedFruitType = null; // Clear selected fruit type when user types
    });
  }

  Future<void> _pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _image = image;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Prevent back button during loading
        if (_isLoading) {
          print('[AddTreeDialog] Back button pressed during loading - preventing dismissal');
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
      title: const Text('Add a New Tree'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Tree Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a tree name';
                  }
                  return null;
                },
              ),
              // Manual TypeAhead-like functionality
              TextFormField(
                controller: _fruitTypeController,
                decoration: const InputDecoration(
                  labelText: 'Fruit Type',
                  hintText: 'Search for fruit type',
                ),
                onChanged: _onFruitTypeChanged,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a fruit type';
                  }
                  // Check if the entered value is one of the valid fruit types
                  if (_allFruits.any((fruit) => fruit.type == value)) {
                    return null; // Valid fruit selected
                  }
                  return 'Please select a valid fruit type from the list';
                },
              ),
              // Display suggestions
              if (_fruitTypeController.text.isNotEmpty)
                ConstrainedBox(
                  constraints: const BoxConstraints(
                      maxHeight: 200), // Limit height of suggestions
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
              Row(
                children: [
                  TextButton.icon(
                    onPressed: _isLoading ? null : _pickImage,
                    icon: const Icon(Icons.image),
                    label: const Text('Add Image'),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _image?.name ?? 'No image selected',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () {
            print('[AddTreeDialog] Cancel button pressed');
            Navigator.of(context).pop();
          },
          child: Text(
            'Cancel',
            style: TextStyle(color: _isLoading ? Colors.grey : null),
          ),
        ),
        ElevatedButton(
          onPressed: _isLoading
              ? null
              : () async {
                  if (_formKey.currentState!.validate()) {
                    print('[AddTreeDialog] Form validated, starting save...');
                    print('[AddTreeDialog] Tree name: ${_nameController.text}');
                    print('[AddTreeDialog] Fruit type: ${_selectedFruitType ?? _fruitTypeController.text}');
                    print('[AddTreeDialog] Image: ${_image?.name ?? "none"}');

                    setState(() => _isLoading = true);
                    try {
                      final result = await widget.onAdd(
                        _nameController.text,
                        _selectedFruitType ?? _fruitTypeController.text,
                        _image,
                      );

                      print('[AddTreeDialog] onAdd completed with result: $result');

                      if (result && mounted) {
                        print('[AddTreeDialog] Success, closing dialog');
                        Navigator.of(context).pop();
                      } else if (!result && mounted) {
                        print('[AddTreeDialog] Failed to save tree');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Failed to save tree. Please try again.'),
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
              : const Text('Add'),
        ),
      ],
    ),
    );
  }
}