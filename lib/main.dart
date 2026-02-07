import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:treesha/services/firebase_auth_service.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'package:geolocator/geolocator.dart';
import 'dart:convert'; // Import for JSON decoding

import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:treesha/l10n/app_localizations.dart';

import 'package:treesha/providers/locale_provider.dart';

import 'package:treesha/services/firebase_service.dart';
import 'package:treesha/services/firestore_config.dart';
import 'package:treesha/services/tree_repository.dart';
import 'package:treesha/services/tree_repository_no_confirm.dart';
import 'package:treesha/services/version_check_service.dart';

import 'package:treesha/models/fruit_model.dart';
import 'package:treesha/services/fruit_service.dart';
import 'package:treesha/models/tree_model.dart';

import 'package:treesha/widgets/add_tree_dialog.dart';
import 'package:treesha/widgets/filter_dialog.dart';
import 'package:treesha/screens/tree_detail_screen.dart';
import 'package:treesha/models/tree_filters.dart';
import 'package:treesha/utils/svg_marker_loader.dart'; // Import the new utility

// You must setup firebase CLI and run `flutterfire configure`

// For more info: https://firebase.google.com/docs/flutter/setup

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  debugPrint('[Main] ========================================');
  debugPrint('[Main] Treesha App Starting');
  debugPrint('[Main] ========================================');

  try {
    // Initialize Firebase
    debugPrint('[Main] Step 1: Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('[Main] ✅ Firebase initialized');
    debugPrint('[Main]    Project: ${Firebase.app().options.projectId}');

    // Configure Firestore
    debugPrint('[Main] Step 2: Configuring Firestore...');
    await FirestoreConfig.configure();
    debugPrint('[Main] ✅ Firestore configured');

    // Test connectivity (optional but recommended)
    debugPrint('[Main] Step 3: Testing Firestore connectivity...');
    final connected = await FirestoreConfig.testConnection();
    if (connected) {
      debugPrint('[Main] ✅ Firestore connectivity verified');
    } else {
      debugPrint('[Main] ⚠️  Firestore connectivity test failed');
      debugPrint('[Main]    App will still start, but writes may fail');
    }

    debugPrint('[Main] ========================================');
    debugPrint('[Main] Initialization Complete');
    debugPrint('[Main] ========================================');
  } catch (e, stack) {
    debugPrint('[Main] ========================================');
    debugPrint('[Main] ❌ FATAL ERROR during initialization');
    debugPrint('[Main] Error: $e');
    debugPrint('[Main] Stack: $stack');
    debugPrint('[Main] ========================================');
    // Still run the app, but it will likely fail
  }

  runApp(
    ChangeNotifierProvider(
      create: (context) => LocaleProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        return MaterialApp(
          title: 'Treesha',

          // Localization configuration
          locale: localeProvider.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'), // English
            Locale('he'), // Hebrew
          ],

          theme: ThemeData(
            primarySwatch: Colors.green,

            primaryColor: const Color(0xFF2E7D32),
          ),
          home: const MyHomePage(),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // CRITICAL: Use late initialization to ensure Firebase settings are applied first in main()
  late final FirebaseService _firebaseService;
  late final FirebaseAuthService _authService;
  late final TreeRepository _treeRepository;
  late final TreeRepositoryNoConfirm _treeRepositoryRest; // REST API version
  User? _user;
  List<String> _userRoles = ['user'];

  GoogleMapController? _mapController;

  Set<Marker> _markers = {}; // Changed type from AdvancedMarkerElement
  Set<Circle> _circles = {}; // Circles for user location

  Position? _currentPosition;

  TreeFilters _filters = TreeFilters.empty;

  bool _isDialogShowing = false;
  bool _isSavingTree = false; // Track if tree save is in progress
  List<Tree> _trees = []; // Store trees loaded from REST API
  bool _isLoadingTrees = false; // Track if trees are being loaded
  Map<String, BitmapDescriptor> _fruitIcons = {}; // Store loaded SVG icons
  BitmapDescriptor? _defaultTreeIcon; // Default SVG icon
  List<Fruit> _allFruits = []; // Store official fruit list


  @override
  void initState() {
    super.initState();

    // Initialize Firebase services AFTER main() has configured Firestore settings
    _firebaseService = FirebaseService();
    _authService = FirebaseAuthService();
    _treeRepository = TreeRepository();
    _treeRepositoryRest = TreeRepositoryNoConfirm(); // REST API fallback

    // Check app version first
    _checkAppVersion();

    _determinePosition();
    _loadOfficialFruits().then((_) => _loadTrees()); // Load official list then trees
    _loadFruitIcons(); // Load fruit SVG icons

    _authService.user.listen((user) async {
      if (!mounted) return;
      
      // Detect if the user actually changed (login, logout, or account switch)
      final bool userChanged = _user?.uid != user?.uid;

      List<String> roles = ['user'];
      if (user != null) {
        roles = await _authService.getUserRoles(user.uid);
      }

      if (mounted) {
        setState(() {
          _user = user;
          _userRoles = roles;

          // Clear all filters on login or logout for a clean experience
          if (userChanged) {
            _filters = TreeFilters.empty;
            _loadTrees();
          }
        });
      }
    });
  }

  Future<void> _loadOfficialFruits() async {
    try {
      final fruits = await FruitService.loadFruits();
      if (mounted) {
        setState(() {
          _allFruits = fruits;
        });
      }
    } catch (e) {
      debugPrint('[MyHomePage] Error loading official fruits: $e');
    }
  }

  Future<void> _loadFruitIcons() async {
    try {
      // Load default tree icon
      _defaultTreeIcon = await SvgMarkerLoader.getMarkerFromSvg('assets/tree.svg', size: 80);

      final String response = await rootBundle.loadString('assets/fruits.json');
      final List<dynamic> data = json.decode(response);

      for (var fruitData in data) {
        final String fruitType = fruitData['fruit_type'];
        final String? iconName = fruitData['icon'];

        if (iconName != null && iconName.isNotEmpty) {
          try {
            final String assetPath = 'assets/fruit_icons/$iconName';
            final BitmapDescriptor icon = await SvgMarkerLoader.getMarkerFromSvg(
              assetPath,
              size: 80,
            ); // Adjust size as needed
            _fruitIcons[fruitType.toLowerCase()] = icon;
          } catch (e) {
            debugPrint('[MyHomePage] Warning: Could not load icon for $fruitType ($iconName): $e');
          }
        }
      }
      if (mounted) {
        setState(() {
          _updateMarkers(); // Update markers after icons are loaded
        });
      }
    } catch (e) {
      debugPrint('[MyHomePage] Error loading fruit icons: $e');
    }
  }

  /// Check if app version meets minimum requirements
  Future<void> _checkAppVersion() async {
    try {
      final versionService = VersionCheckService();
      final updateInfo = await versionService.checkVersion();

      if (updateInfo != null && updateInfo['needsUpdate'] == true) {
        if (!mounted) return;
        _showUpdateDialog(updateInfo);
      }
    } catch (e) {
      debugPrint('[Main] Error checking version: $e');
      // Continue anyway - fail-open
    }
  }

  /// Show update dialog if app version is outdated
  void _showUpdateDialog(Map<String, dynamic> updateInfo) {
    final forceUpdate = updateInfo['forceUpdate'] as bool? ?? true;
    final message = updateInfo['message'] as String;

    showDialog(
      context: context,
      barrierDismissible: !forceUpdate,
      builder: (dialogContext) => WillPopScope(
        onWillPop: () async => !forceUpdate,
        child: AlertDialog(
          title: const Text('Update Required'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message),
              const SizedBox(height: 16),
              Text(
                'Current version: ${updateInfo['currentVersion']}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                'Minimum version: ${updateInfo['minVersion']}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          actions: [
            if (!forceUpdate)
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Later'),
              ),
            ElevatedButton(
              onPressed: () async {
                // Open app store
                final url = Uri.parse(
                  defaultTargetPlatform == TargetPlatform.android
                      ? 'https://play.google.com/store/apps/details?id=com.example.treesha'
                      : 'https://apps.apple.com/app/treesha/id123456789',
                );
                try {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                } catch (e) {
                  debugPrint('[Main] Error opening store: $e');
                }
              },
              child: const Text('Update Now'),
            ),
          ],
        ),
      ),
    );
  }

  /// Load trees from Firestore using REST API
  Future<void> _loadTrees() async {
    if (_isLoadingTrees) return;

    setState(() {
      _isLoadingTrees = true;
    });

    try {
      final treesData = await _treeRepositoryRest.getAllTrees();

      // Convert Map data to Tree objects
      final trees = treesData.map((data) {
        // Parse the timestamp string and convert to Timestamp
        final createdAtStr =
            data['createdAt'] as String? ?? DateTime.now().toIso8601String();
        final createdAtDateTime = DateTime.parse(createdAtStr);

        // Parse lastVerifiedAt if it exists
        Timestamp? lastVerifiedAt;
        final lastVerifiedAtStr = data['lastVerifiedAt'] as String?;
        if (lastVerifiedAtStr != null && lastVerifiedAtStr.isNotEmpty) {
          try {
            final lastVerifiedDateTime = DateTime.parse(lastVerifiedAtStr);
            lastVerifiedAt = Timestamp.fromDate(lastVerifiedDateTime);
          } catch (e) {
            // Ignore parsing errors
          }
        }

        return Tree(
          id: data['id'] as String,
          userId: data['userId'] as String,
          name: data['name'] as String,
          fruitType: data['fruitType'] as String,
          position: GeoPoint(
            data['latitude'] as double,
            data['longitude'] as double,
          ),
          imageUrl: data['imageUrl'] as String,
          createdAt: Timestamp.fromDate(createdAtDateTime),
          upvotes: List<String>.from(data['upvotes'] as List),
          downvotes: List<String>.from(data['downvotes'] as List),
          reported: List<String>.from(data['reported'] as List? ?? []),
          lastVerifiedAt: lastVerifiedAt,
          status: data['status'] as String? ?? 'pending',
        );
      }).toList();

      // Apply filters
      final filteredTrees = trees.where((tree) {
        // Filter by tree name
        if (_filters.treeName.isNotEmpty) {
          if (!tree.name.toLowerCase().contains(
            _filters.treeName.toLowerCase(),
          )) {
            return false;
          }
        }

        // Filter by fruit types (if any selected)
        if (_filters.fruitTypes.isNotEmpty) {
          if (!_filters.fruitTypes.contains(tree.fruitType)) {
            return false;
          }
        }

        // Filter by last verified date
        if (_filters.lastVerifiedAfter != null) {
          if (tree.lastVerifiedAt == null) {
            return false; // Tree has never been verified
          }
          final verifiedDate = tree.lastVerifiedAt!.toDate();
          if (verifiedDate.isBefore(_filters.lastVerifiedAfter!)) {
            return false;
          }
        }

        // Filter by added date
        if (_filters.lastAddedAfter != null) {
          final addedDate = tree.createdAt.toDate();
          if (addedDate.isBefore(_filters.lastAddedAfter!)) {
            return false;
          }
        }

        // Filter by status
        if (_filters.statusTypes.isNotEmpty) {
          if (!_filters.statusTypes.contains(tree.status)) {
            return false;
          }
        }

        // Filter by reported (Admins only)
        if (_filters.showReportedOnly) {
          if (tree.reported.isEmpty) {
            return false;
          }
        }

        // Filter by unknown fruits (Admins only)
        if (_filters.showUnknownFruitsOnly) {
          final isKnown = _allFruits.any((f) {
            return f.type.toLowerCase() == tree.fruitType.toLowerCase();
          });
          if (isKnown) {
            return false;
          }
        }

        return true; // Passed all filters
      }).toList();

      if (!mounted) return;
      setState(() {
  _trees = List<Tree>.from(filteredTrees);
        _updateMarkers();
      });
    } catch (e, stack) {
      debugPrint('[MyHomePage] Error loading trees: $e\n$stack');
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoadingTrees = false;
      });
    }
  }

  /// Update map markers from current tree list
  void _updateMarkers() {
    final newMarkers = <Marker>{};

    // Add tree markers
    for (var tree in _trees) {
      // Determine the icon to use
      final BitmapDescriptor icon =
          _fruitIcons[tree.fruitType.toLowerCase()] ??
          _defaultTreeIcon ??
          BitmapDescriptor.defaultMarker;

      newMarkers.add(
        Marker(
          markerId: MarkerId(tree.id),
          position: LatLng(tree.position.latitude, tree.position.longitude),
          icon: icon, // Use custom icon or default
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TreeDetailScreen(tree: tree),
              ),
            );
            if (result == true) {
              _loadTrees(); // Refresh if tree was deleted
            }
          },
        ),
      );
    }

    // No need to add custom user location marker - Google Maps shows it automatically
    // with myLocationEnabled: true

    _markers = newMarkers;
  }

  Future<void> _determinePosition() async {
    try {
      Position position = await _firebaseService.getCurrentLocation();

      if (!mounted) return; // Add mounted check
      setState(() {
        _currentPosition = position;
        _updateMarkers(); // Update markers to include user location
      });

      // If map controller is already available, animate camera to current position
      if (_mapController != null) {
        _mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 15.0,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('[MyHomePage] Error determining position: $e');
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;

    // If _currentPosition was already determined before map created, animate camera again.
    // This handles cases where _determinePosition finishes before _onMapCreated.

    final currentPosition = _currentPosition; // Local non-nullable variable
    // ignore: unnecessary_null_comparison
    if (currentPosition != null) {
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(currentPosition.latitude, currentPosition.longitude),
            zoom: 14.0,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);

    final currentPosition = _currentPosition; // Local non-nullable variable

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        backgroundColor: const Color(0xFF2E7D32),
        actions: [
          // Language selector
          PopupMenuButton<Locale>(
            icon: const Icon(Icons.language),
            tooltip: l10n.language,
            onSelected: (Locale locale) {
              localeProvider.setLocale(locale);
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<Locale>>[
              PopupMenuItem<Locale>(
                value: const Locale('en'),
                child: Text(l10n.english),
              ),
              PopupMenuItem<Locale>(
                value: const Locale('he'),
                child: Text(l10n.hebrew),
              ),
            ],
          ),
          // Filter button with active indicator
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                tooltip: l10n.filters,
                onPressed: () => _showFilterDialog(),
              ),
              // Show indicator badge when filters are active
              if (_filters.hasActiveFilters)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 8,
                      minHeight: 8,
                    ),
                  ),
                ),
            ],
          ),
          if (_user == null)
            TextButton(
              onPressed: () async {
                await _authService.signInWithGoogle();
              },
              child: Text(
                l10n.signIn,
                style: const TextStyle(color: Colors.white),
              ),
            )
          else
            Row(
              children: [
                Text(_user!.displayName ?? 'No name'),
                TextButton(
                  onPressed: () async {
                    await _authService.signOut();
                  },
                  child: Text(
                    l10n.signOut,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
        ],
      ),

      body: _isLoadingTrees
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              onMapCreated: _onMapCreated,

              initialCameraPosition: CameraPosition(
                // ignore: unnecessary_null_comparison
                target: currentPosition != null
                    ? LatLng(
                        currentPosition.latitude,
                        currentPosition.longitude,
                      )
                    : const LatLng(0, 0),

                zoom: 14.0,
              ),

              markers: _markers,

              mapType: MapType.satellite,

              myLocationEnabled: true,

              myLocationButtonEnabled: true,

              // Disable all gestures when saving tree
              scrollGesturesEnabled: !_isSavingTree,
              zoomGesturesEnabled: !_isSavingTree,
              rotateGesturesEnabled: !_isSavingTree,
              tiltGesturesEnabled: !_isSavingTree,

              // Use native onLongPress for accurate coordinates
              onLongPress: _onMapTapped,
            ),

      floatingActionButton: FloatingActionButton(
        onPressed: _isSavingTree ? null : _addTree, // Disable when saving

        backgroundColor: _isSavingTree ? Colors.grey : const Color(0xFF2E7D32),

        child: _isSavingTree
            ? const CircularProgressIndicator(color: Colors.white)
            : const Icon(Icons.add),
      ),
    );
  }

  void _showFilterDialog() async {
    // Get unique fruit types from all trees
    final allTreesData = await _treeRepositoryRest.getAllTrees();
    final availableFruitTypes =
        allTreesData
            .map((data) => data['fruitType'] as String)
            .where((type) => type.isNotEmpty)
            .toSet()
            .toList()
          ..sort();

    if (!mounted) return;

    final result = await showDialog<TreeFilters>(
      context: context,
      builder: (dialogContext) {
        return FilterDialog(
          initialFilters: _filters,
          availableFruitTypes: availableFruitTypes,
          isAdmin: _userRoles.contains('admin'),
        );
      },
    );

    // If user pressed Apply (result is not null), update the filters
    if (result != null) {
      setState(() {
        _filters = result;
      });
      _loadTrees(); // Reload trees with new filters
    }
  }

  void _onMapTapped(LatLng latLng) async {
    if (!mounted) return; // Add mounted check

    if (_mapController == null) return;

    final zoomLevel = await _mapController!.getZoomLevel();
    const double maxZoomThreshold = 19.0;

    if (zoomLevel < maxZoomThreshold) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Zoom closer plz => for better accuracy 🔎'),
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    debugPrint('[MapTap] Tapped at: ${latLng.latitude}, ${latLng.longitude}');

    final l10n = AppLocalizations.of(context)!;

    // Check if user is logged in
    if (_user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.pleaseSignInToAddTree),
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    if (mounted) {
      _showAddTreeDialog(
        Position(
          latitude: latLng.latitude,
          longitude: latLng.longitude,
          timestamp: DateTime.now(),
          accuracy: 0.0,
          altitude: 0.0,
          altitudeAccuracy: 0.0,
          heading: 0.0,
          headingAccuracy: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
        ),
      );
    }
  }

  void _showAddTreeDialog(Position position) {
    if (_isDialogShowing) return; // Prevent multiple dialogs
    _isDialogShowing = true; // Set flag

    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissal by tapping outside
      builder: (dialogContext) {
        return AddTreeDialog(
          onAdd: (name, fruitType, images, comment) async {
            // Set saving state to disable map interactions
            if (mounted) {
              setState(() {
                _isSavingTree = true;
              });
            }

            try {
              // Upload all images
              List<String> imageUrls = [];
              if (images.isNotEmpty) {
                try {
                  for (var image in images) {
                    final imageUrl = await _firebaseService
                        .uploadImage(image)
                        .timeout(
                          const Duration(seconds: 30),
                          onTimeout: () {
                            throw Exception(
                              'Image upload timed out after 30 seconds',
                            );
                          },
                        );
                    imageUrls.add(imageUrl);
                  }
                } catch (e) {
                  debugPrint('[Main] Some images upload failed: $e');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Some images failed to upload: $e'),
                        backgroundColor: Colors.orange,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                }
              }

              // Add tree using new TreeRepository
              debugPrint('[AddTree] Creating tree at: ${position.latitude}, ${position.longitude}');
              
              final docId = await _treeRepository.addTree(
                userId: _user!.uid,
                name: name,
                fruitType: fruitType,
                position: position,
                imageUrl: imageUrls.isNotEmpty ? imageUrls.first : null,
                userRole: _userRoles.contains('admin') ? 'admin' : 'user',
              );

              // Add initial post if needed
              if (imageUrls.isNotEmpty || comment.isNotEmpty) {
                try {
                  await _treeRepository.addPostToTree(docId, {
                    'userId': _user!.uid,
                    'userName': _user!.displayName ?? 'Anonymous',
                    'imageUrls': imageUrls,
                    'comment': comment,
                  });
                } catch (e) {
                  debugPrint('[Main] Failed to add initial post: $e');
                  // Continue, as tree was created
                }
              }

              // Reload trees to show the new tree on map
              _loadTrees();

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.treeAddedSuccessfully),
                    backgroundColor: Colors.green,
                  ),
                );
              }
              return true;
            } on TreeRepositoryException catch (e) {
              debugPrint(
                '[Main] TreeRepositoryException: ${e.code} - ${e.message}',
              );

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to add tree: ${e.code}'),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 5),
                  ),
                );
              }
              return false;
            } catch (e, stackTrace) {
              debugPrint('[Main] Unexpected error: $e\n$stackTrace');

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to add tree: ${e.toString()}'),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 5),
                  ),
                );
              }
              return false;
            } finally {
              // Always reset saving state
              if (mounted) {
                setState(() {
                  _isSavingTree = false;
                });
              }
            }
          },
        );
      },
    ).then((_) {
      if (!mounted) return; // Add mounted check
      _isDialogShowing =
          false; // Reset flag when dialog is dismissed (e.g., cancelled)
    });
  }

  void _addTree() async {
    final l10n = AppLocalizations.of(context)!;
    // Check if user is logged in before allowing tree addition
    if (_user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pleaseSignInToAddTree),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    if (_mapController == null) return;

    final zoomLevel = await _mapController!.getZoomLevel();
    // Usually max zoom is around 20-21 on Google Maps
    const double maxZoomThreshold = 19.0; 

    if (!mounted) return;

    if (zoomLevel < maxZoomThreshold) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Zoom closer plz => for better accuracy 🔎'),
          duration: Duration(seconds: 3),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Now long-click on the exact position of the tree to add it'),
          duration: Duration(seconds: 4),
        ),
      );
    }
  }
}
