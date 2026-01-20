import 'package:firebase_auth/firebase_auth.dart';
import 'package:treesha/services/firebase_auth_service.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';

import 'package:geolocator/geolocator.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:firebase_core/firebase_core.dart';



import 'package:treesha/services/firebase_service.dart';
import 'package:treesha/services/firestore_config.dart';
import 'package:treesha/services/tree_repository.dart';
import 'package:treesha/services/tree_repository_no_confirm.dart';
import 'package:treesha/services/raw_firestore_test.dart';
import 'package:treesha/services/firestore_diagnostic.dart';

import 'package:treesha/models/tree_model.dart';

import 'package:treesha/widgets/add_tree_dialog.dart';
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

  runApp(const MyApp());
}



class MyApp extends StatelessWidget {

  const MyApp({super.key});



  @override

  Widget build(BuildContext context) {

    return MaterialApp(

      title: 'Treesha',

      theme: ThemeData(

        primarySwatch: Colors.green,

        primaryColor: const Color(0xFF2E7D32),

      ),
      home: const MyHomePage(),
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

    _markers = newMarkers;
  }







  Future<void> _determinePosition() async {



    try {



      Position position = await _firebaseService.getCurrentLocation();



      if (!mounted) return; // Add mounted check
      setState(() {



        _currentPosition = position;



      });



      // If map controller is already available, animate camera to current position



      if (_mapController != null) {



        _mapController?.animateCamera(



          CameraUpdate.newCameraPosition(



            CameraPosition(



              target: LatLng(position.latitude, position.longitude),



              zoom: 14.0,



            ),



          ),



        );



      } 



    } catch (e) {



      // Log error if necessary, but remove print for production
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



    final currentPosition = _currentPosition; // Local non-nullable variable

    return Scaffold(



      appBar: AppBar(
        title: const Text('Treesha'),
        backgroundColor: const Color(0xFF2E7D32),
        actions: [
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
              child: const Text('Sign In', style: TextStyle(color: Colors.white)),
            )
          else
            Row(
              children: [
                Text(_user!.displayName ?? 'No name'),
                TextButton(
                  onPressed: () async {
                    await _authService.signOut();
                  },
                  child: const Text('Sign Out', style: TextStyle(color: Colors.white)),
                )
              ],
            )
        ],
      ),



            body: Column(



              children: [



                Padding(



                  padding: const EdgeInsets.all(8.0),



                  child: Column(



                    children: [



                      Text('Minimum Verification Score: ${_minVerificationScore.toInt()}'),



                      Slider(



                        value: _minVerificationScore,



                        min: -10.0,



                        max: 10.0,



                        divisions: 20,



                        label: _minVerificationScore.round().toString(),



                        onChanged: (double value) {



                          setState(() {



                            _minVerificationScore = value;
                            // Re-filter trees with new score
                            _loadTrees();



                          });



                        },



                      ),



                    ],



                  ),



                ),



                Expanded(



                  child: _isLoadingTrees
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
                ),



              ],



            ),



      floatingActionButton: FloatingActionButton(



        onPressed: _isSavingTree ? null : _addTree, // Disable when saving



        backgroundColor: _isSavingTree ? Colors.grey : const Color(0xFF2E7D32),



        child: _isSavingTree ? const CircularProgressIndicator(color: Colors.white) : const Icon(Icons.add),



      ),



    );



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
                  const SnackBar(
                    content: Text('🌳 Tree added successfully!'),
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
    // Check if user is logged in before allowing tree addition
    if (_user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to add a tree'),
          duration: Duration(seconds: 3),
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