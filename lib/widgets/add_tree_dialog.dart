import 'dart:io';
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
  List<XFile> _images = []; // Multiple images
  final SearchController _searchController = SearchController();

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
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAllFruits() async {
    try {
      final loadedFruits = await FruitService.loadFruits();
      if (mounted) {
        setState(() {
          _allFruits = loadedFruits;
        });
      }
    } catch (e) {
      debugPrint('Error loading fruits: $e');
    }
  }

  String _getFruitDisplayName(Fruit fruit) {
    final languageCode = Localizations.localeOf(context).languageCode;
    if (languageCode == 'he' && fruit.typeHe.isNotEmpty) return fruit.typeHe;
    if (languageCode == 'ru' && fruit.typeRu.isNotEmpty) return fruit.typeRu;
    return fruit.type;
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
    return PopScope(
      canPop: !_isLoading,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _isLoading) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.pleaseWait),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      child: AlertDialog(
        title: Text(l10n.addTree),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: l10n.treeName,
                      prefixIcon: const Icon(Icons.drive_file_rename_outline),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.pleaseEnterTreeName;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  SearchAnchor(
                    searchController: _searchController,
                    builder: (context, controller) {
                      return TextFormField(
                        controller: _fruitTypeController,
                        onTap: () {
                          controller.openView();
                        },
                        onChanged: (value) {
                          controller.openView();
                        },
                        decoration: InputDecoration(
                          labelText: l10n.fruitType,
                          hintText: l10n.searchFruitType,
                          prefixIcon: const Icon(Icons.search),
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.pleaseEnterFruitType;
                          }
                          return null;
                        },
                      );
                    },
                    suggestionsBuilder: (context, controller) {
                      final String pattern = controller.text.toLowerCase();
                      final filtered = _allFruits.where((fruit) {
                        return fruit.type.toLowerCase().contains(pattern) ||
                               fruit.typeHe.toLowerCase().contains(pattern) ||
                               fruit.typeRu.toLowerCase().contains(pattern);
                      }).toList();

                      return filtered.map((fruit) {
                        final displayName = _getFruitDisplayName(fruit);
                        return ListTile(
                          title: Text(displayName),
                          subtitle: Text(fruit.edibleSeason),
                          onTap: () {
                            setState(() {
                              _fruitTypeController.text = displayName;
                              _selectedFruitType = fruit.type;
                            });
                            controller.closeView(displayName);
                          },
                        );
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      labelText: l10n.commentOptional,
                      hintText: l10n.addCommentHint,
                      border: const OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
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
                  if (_images.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 100,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _images.length,
                        separatorBuilder: (context, index) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final image = _images[index];
                          return Stack(
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: kIsWeb
                                      ? Image.network(image.path, fit: BoxFit.cover)
                                      : Image.file(File(image.path), fit: BoxFit.cover),
                                ),
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.7),
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.close, color: Colors.red, size: 20),
                                    onPressed: () => _removeImage(index),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: _isLoading
                ? null
                : () async {
                    if (_formKey.currentState!.validate()) {
                      setState(() => _isLoading = true);
                      try {
                        String finalFruitType = _selectedFruitType ?? _fruitTypeController.text;
                        
                        if (_selectedFruitType == null) {
                          finalFruitType = finalFruitType
                              .replaceAll(RegExp(r'[^a-zA-Z0-6\s\u0590-\u05FF\u0400-\u04FF]'), '')
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

                        if (result && mounted) {
                          Navigator.of(context).pop();
                        } else if (!result && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.failedToSaveTree)),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        }
                      } finally {
                        if (mounted) setState(() => _isLoading = false);
                      }
                    }
                  },
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Text(l10n.add),
          ),
        ],
      ),
    );
  }
}
