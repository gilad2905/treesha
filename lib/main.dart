import 'package:firebase_auth/firebase_auth.dart';
import 'package:treesha/services/firebase_auth_service.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'package:geolocator/geolocator.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:firebase_core/firebase_core.dart';

import 'package:treesha/l10n/app_localizations.dart';

import 'package:treesha/providers/locale_provider.dart';



import 'package:treesha/services/firebase_service.dart';
import 'package:treesha/services/firestore_config.dart';
import 'package:treesha/services/tree_repository.dart';
import 'package:treesha/services/tree_repository_no_confirm.dart';
import 'package:treesha/services/raw_firestore_test.dart';
import 'package:treesha/services/firestore_diagnostic.dart';

import 'package:treesha/models/tree_model.dart';

import 'package:treesha/widgets/add_tree_dialog.dart';
import 'package:treesha/widgets/filter_dialog.dart';
import 'package:treesha/screens/tree_detail_screen.dart';



// You must setup firebase CLI and run `flutterfire configure`

// For more info: https://firebase.google.com/docs/flutter/setup

import 'firebase_options.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('[Main] ========================================');
  print('[Main] Treesha App Starting');
  print('[Main] ========================================');

  try {
    // Initialize Firebase
    print('[Main] Step 1: Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('[Main] ✅ Firebase initialized');
    print('[Main]    Project: ${Firebase.app().options.projectId}');

    // Configure Firestore
    print('[Main] Step 2: Configuring Firestore...');
    await FirestoreConfig.configure();
    print('[Main] ✅ Firestore configured');

    // Test connectivity (optional but recommended)
    print('[Main] Step 3: Testing Firestore connectivity...');
    final connected = await FirestoreConfig.testConnection();
    if (connected) {
      print('[Main] ✅ Firestore connectivity verified');
    } else {
      print('[Main] ⚠️  Firestore connectivity test failed');
      print('[Main]    App will still start, but writes may fail');
    }

    print('[Main] ========================================');
    print('[Main] Initialization Complete');
    print('[Main] ========================================');
  } catch (e, stack) {
    print('[Main] ========================================');
    print('[Main] ❌ FATAL ERROR during initialization');
    print('[Main] Error: $e');
    print('[Main] Stack: $stack');
    print('[Main] ========================================');
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



  GoogleMapController? _mapController;



    Set<Marker> _markers = {}; // Changed type from AdvancedMarkerElement



  



        Position? _currentPosition;



  



        double _minVerificationScore = 0.0;



  



        bool _isDialogShowing = false;
        bool _isSavingTree = false; // Track if tree save is in progress
        List<Tree> _trees = []; // Store trees loaded from REST API
        bool _isLoadingTrees = false; // Track if trees are being loaded







  @override



  void initState() {
    super.initState();

    // Initialize Firebase services AFTER main() has configured Firestore settings
    _firebaseService = FirebaseService();
    _authService = FirebaseAuthService();
    _treeRepository = TreeRepository();
    _treeRepositoryRest = TreeRepositoryNoConfirm(); // REST API fallback

    print('[MyHomePage] Firebase services initialized (including REST fallback)');

    _determinePosition();
    _loadTrees(); // Load trees using REST API
    _authService.user.listen((user) {
      if (!mounted) return; // Add mounted check
      setState(() {
        _user = user;
      });
    });
  }

  /// Load trees from Firestore using REST API
  Future<void> _loadTrees() async {
    if (_isLoadingTrees) return;

    setState(() {
      _isLoadingTrees = true;
    });

    try {
      print('[MyHomePage] Loading trees via REST API...');
      final treesData = await _treeRepositoryRest.getAllTrees();

      print('[MyHomePage] Loaded ${treesData.length} trees');

      // Convert Map data to Tree objects
      final trees = treesData.map((data) {
        // Parse the timestamp string and convert to Timestamp
        final createdAtStr = data['createdAt'] as String? ?? DateTime.now().toIso8601String();
        final createdAtDateTime = DateTime.parse(createdAtStr);

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
        );
      }).toList();

      // Filter by verification score
      final filteredTrees = trees.where((tree) {
        final score = tree.upvotes.length - tree.downvotes.length;
        return score >= _minVerificationScore;
      }).toList();

      if (!mounted) return;
      setState(() {
        _trees = filteredTrees;
        _updateMarkers();
      });

      print('[MyHomePage] ✅ Loaded ${filteredTrees.length} trees (filtered)');
    } catch (e, stack) {
      print('[MyHomePage] ❌ Error loading trees: $e');
      print('[MyHomePage] Stack: $stack');
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

    print('[MyHomePage] Updating markers...');

    // Add tree markers
    for (var tree in _trees) {
      newMarkers.add(
        Marker(
          markerId: MarkerId(tree.id),
          position: LatLng(tree.position.latitude, tree.position.longitude),
          icon: BitmapDescriptor.defaultMarker,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TreeDetailScreen(tree: tree),
              ),
            );
          },
        ),
      );
    }

    print('[MyHomePage] Added ${_trees.length} tree markers');

    // Add user location marker (for web support)
    if (_currentPosition != null) {
      print('[MyHomePage] Adding user location marker at: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}');
      newMarkers.add(
        Marker(
          markerId: const MarkerId('user_location'),
          position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
          infoWindow: const InfoWindow(
            title: '📍 Your Location',
            snippet: 'Tap to center map here',
          ),
          zIndex: 1000, // Show on top of other markers
          onTap: () {
            // Center map on user location when tapped
            _mapController?.animateCamera(
              CameraUpdate.newLatLng(
                LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
              ),
            );
          },
        ),
      );
      print('[MyHomePage] User location marker added successfully');
    } else {
      print('[MyHomePage] No current position available, skipping user location marker');
    }

    _markers = newMarkers;
    print('[MyHomePage] Total markers on map: ${_markers.length}');
  }







  Future<void> _determinePosition() async {

    print('[MyHomePage] Starting location determination...');

    try {



      Position position = await _firebaseService.getCurrentLocation();

      print('[MyHomePage] ✅ Location received: ${position.latitude}, ${position.longitude}');
      print('[MyHomePage] Accuracy: ${position.accuracy}m');

      if (!mounted) return; // Add mounted check
      setState(() {



        _currentPosition = position;
        _updateMarkers(); // Update markers to include user location

        print('[MyHomePage] ✅ User location marker added to map');

      });



      // If map controller is already available, animate camera to current position



      if (_mapController != null) {

        print('[MyHomePage] 🎯 Centering map on user location...');

        _mapController?.animateCamera(



          CameraUpdate.newCameraPosition(



            CameraPosition(



              target: LatLng(position.latitude, position.longitude),



              zoom: 15.0,



            ),



          ),



        );

        print('[MyHomePage] ✅ Map centered on user location');
      } else {
        print('[MyHomePage] ⚠️ Map controller not ready yet, will center when map loads');
      }



    } catch (e) {

      print('[MyHomePage] ❌ Error determining position: $e');
      print('[MyHomePage] Location may not be available or permission denied');

    }



  }







  void _onMapCreated(GoogleMapController controller) {

    print('[MyHomePage] 🗺️ Map created and controller ready');

    _mapController = controller;



    // If _currentPosition was already determined before map created, animate camera again.



    // This handles cases where _determinePosition finishes before _onMapCreated.



    final currentPosition = _currentPosition; // Local non-nullable variable
    // ignore: unnecessary_null_comparison
    if (currentPosition != null) {

      print('[MyHomePage] 🎯 User position already known, centering map on: ${currentPosition.latitude}, ${currentPosition.longitude}');

      _mapController?.animateCamera(



        CameraUpdate.newCameraPosition(



          CameraPosition(



            target: LatLng(currentPosition.latitude, currentPosition.longitude),



            zoom: 14.0,



          ),



        ),



      );

      print('[MyHomePage] ✅ Map should now be centered on user location');
    } else {
      print('[MyHomePage] ℹ️ User position not yet determined, map will stay at initial position');
    }



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
              // Show indicator badge when filter is active (not default value)
              if (_minVerificationScore != 0.0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
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
          // Diagnostic button
          IconButton(
            icon: const Icon(Icons.bug_report),
            tooltip: 'Run Firebase Diagnostic',
            onPressed: () async {
              print('[Main] Running Firebase diagnostic...');
              await FirestoreDiagnostic.runFullDiagnostic();
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Diagnostic complete - check console'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          if (_user == null)
            TextButton(
              onPressed: () async {
                await _authService.signInWithGoogle();
              },
              child: Text(l10n.signIn, style: const TextStyle(color: Colors.white)),
            )
          else
            Row(
              children: [
                Text(_user!.displayName ?? 'No name'),
                TextButton(
                  onPressed: () async {
                    await _authService.signOut();
                  },
                  child: Text(l10n.signOut, style: const TextStyle(color: Colors.white)),
                )
              ],
            )
        ],
      ),



            body: _isLoadingTrees
                ? const Center(child: CircularProgressIndicator())
                : GestureDetector(



                                              onDoubleTapDown: (details) async {



                                                if (_mapController != null) {



                                                  final latLng = await _mapController!.getLatLng(



                                                        ScreenCoordinate(



                                                          x: details.globalPosition.dx.toInt(),



                                                          y: details.globalPosition.dy.toInt(),



                                                        ),



                                                      );



                                                  if (latLng != null) {



                                                    _onMapTapped(latLng);



                                                  }



                                                }



                                              },



                                              onLongPressStart: (details) async {



                                                if (_mapController != null) {



                                                  final latLng = await _mapController!.getLatLng(



                                                        ScreenCoordinate(



                                                          x: details.globalPosition.dx.toInt(),



                                                          y: details.globalPosition.dy.toInt(),



                                                        ),



                                                      );



                                                  if (latLng != null) {



                                                    _onMapTapped(latLng);



                                                  }



                                                }



                                              },



                                              child: GoogleMap(



                                                onMapCreated: _onMapCreated,



                                                initialCameraPosition: CameraPosition(



                                                  // ignore: unnecessary_null_comparison
                                                  target: currentPosition != null



                                                      ? LatLng(currentPosition.latitude, currentPosition.longitude)



                                                      : const LatLng(0, 0),



                                                  zoom: 14.0,



                                                ),



                                                markers: _markers,



                                                myLocationEnabled: true,



                                                myLocationButtonEnabled: true,

                                                // Disable all gestures when saving tree
                                                scrollGesturesEnabled: !_isSavingTree,
                                                zoomGesturesEnabled: !_isSavingTree,
                                                rotateGesturesEnabled: !_isSavingTree,
                                                tiltGesturesEnabled: !_isSavingTree,



                                                // onTap: _onMapTapped, // Removed



                                              ),



                                            ),



      floatingActionButton: FloatingActionButton(



        onPressed: _isSavingTree ? null : _addTree, // Disable when saving



        backgroundColor: _isSavingTree ? Colors.grey : const Color(0xFF2E7D32),



        child: _isSavingTree ? const CircularProgressIndicator(color: Colors.white) : const Icon(Icons.add),



      ),



    );



  }

  void _showFilterDialog() async {
    final result = await showDialog<double>(
      context: context,
      builder: (context) {
        return FilterDialog(
          initialMinVerificationScore: _minVerificationScore,
        );
      },
    );

    // If user pressed Apply (result is not null), update the filter
    if (result != null) {
      setState(() {
        _minVerificationScore = result;
      });
      _loadTrees(); // Reload trees with new filter
    }
  }







  void _onMapTapped(LatLng latLng) {
    if (!mounted) return; // Add mounted check
    _showAddTreeDialog(Position(
        latitude: latLng.latitude,
        longitude: latLng.longitude,
        timestamp: DateTime.now(),
        accuracy: 0.0,
        altitude: 0.0,
        altitudeAccuracy: 0.0,
        heading: 0.0,
        headingAccuracy: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0));
  }

  void _showAddTreeDialog(Position position) {
    if (_isDialogShowing) return; // Prevent multiple dialogs
    _isDialogShowing = true; // Set flag

    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissal by tapping outside
      builder: (context) {
        return AddTreeDialog(
          onAdd: (name, fruitType, image) async {
            print('[Main] ========================================');
            print('[Main] ADD TREE REQUEST');
            print('[Main] ========================================');

            // Set saving state to disable map interactions
            if (mounted) {
              setState(() {
                _isSavingTree = true;
              });
            }

            try {
              // Upload image first if provided
              String? imageUrl;
              if (image != null) {
                print('[Main] Uploading image...');
                try {
                  imageUrl = await _firebaseService.uploadImage(image).timeout(
                    const Duration(seconds: 30),
                    onTimeout: () {
                      throw Exception('Image upload timed out after 30 seconds');
                    },
                  );
                  print('[Main] ✅ Image uploaded successfully: $imageUrl');
                } catch (e) {
                  print('[Main] ❌ Image upload failed: $e');
                  // Continue with tree creation without image
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Image upload failed: $e. Tree will be added without image.'),
                        backgroundColor: Colors.orange,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                  imageUrl = null;
                }
              }

              // Add tree using REST API (bypasses SDK WebSocket issues)
              print('[Main] Adding tree via REST API...');
              final docId = await _treeRepositoryRest.addTree(
                userId: _user!.uid,
                name: name,
                fruitType: fruitType,
                position: position,
                imageUrl: imageUrl,
              );

              print('[Main] ✅ Tree added successfully via REST! ID: $docId');

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
              print('[Main] ❌ TreeRepositoryException: ${e.code} - ${e.message}');

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
              print('[Main] ❌ Unexpected error: $e');
              print('[Main] Stack: $stackTrace');

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
              print('[Main] ========================================');
              print('[Main] ADD TREE COMPLETE');
              print('[Main] ========================================');
            }
          },
        );
      },
    ).then((_) {
      if (!mounted) return; // Add mounted check
      _isDialogShowing = false; // Reset flag when dialog is dismissed (e.g., cancelled)
      print('[Main] Dialog dismissed');
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

    try{
      final position = await _firebaseService.getCurrentLocation();
      if (!mounted) return; // Add mounted check
      _showAddTreeDialog(position);
    } catch (e) {
      // Log error if necessary, but remove print for production
      print('[Main] ERROR: Failed to get location: $e');
    }
  }



}