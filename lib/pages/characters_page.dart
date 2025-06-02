// lib/pages/characters_page.dart
import 'package:flutter/material.dart'; // Flutter framework for UI components
import 'package:google_fonts/google_fonts.dart'; // For custom Google Fonts
import 'package:http/http.dart' as http; // For making HTTP requests
import 'dart:convert'; // For JSON encoding/decoding
import 'package:firebase_auth/firebase_auth.dart'; // For Firebase Authentication

class CharactersPage extends StatefulWidget {
  const CharactersPage({super.key});

  @override
  State<CharactersPage> createState() => _CharactersPageState();
}

class _CharactersPageState extends State<CharactersPage> {
  // Current page number for pagination
  int _page = 1;

  // List to hold fetched character data
  List _chars = [];

  // Flag to indicate if data is currently loading
  bool _loading = false;

  // Maximum number of pages available from the API
  int _maxPage = 1;

  // Filter parameters (initially empty)
  String _filterName = '';
  String _filterStatus = '';
  String _filterSpecies = '';
  String _filterGender = '';
  String _filterLocation = '';

  // Controllers for text input fields
  final _nameController = TextEditingController();
  final _speciesController = TextEditingController();
  final _locationController = TextEditingController();

  // Possible status filter values (empty string = no filter)
  static const _statuses = ['', 'alive', 'dead', 'unknown'];

  // Possible gender filter values (empty string = no filter)
  static const _genders = ['', 'male', 'female', 'genderless', 'unknown'];

  @override
  void initState() {
    super.initState();
    // Fetch the initial set of characters when the widget is first created
    _fetch();
  }

  /// Fetches character data from the Rick and Morty API with current filters and pagination.
  Future<void> _fetch() async {
    // Indicate that loading has started
    setState(() => _loading = true);

    // Build query parameters for the API request
    final qs = {
      'page': '$_page',
      if (_filterName.isNotEmpty) 'name': _filterName,
      if (_filterStatus.isNotEmpty) 'status': _filterStatus,
      if (_filterSpecies.isNotEmpty) 'species': _filterSpecies,
      if (_filterGender.isNotEmpty) 'gender': _filterGender,
    };

    // Create the URI for the Rick and Morty API endpoint
    final uri = Uri.https('rickandmortyapi.com', '/api/character', qs);

    // Perform the HTTP GET request
    final res = await http.get(uri);

    if (res.statusCode == 200) {
      // Decode the JSON response
      final data = jsonDecode(res.body);
      var results = data['results'] as List;

      // Apply location filter on the client side, since the API does not support it directly
      if (_filterLocation.isNotEmpty) {
        results = results
            .where((c) =>
                (c['location']['name'] as String)
                    .toLowerCase()
                    .contains(_filterLocation.toLowerCase()))
            .toList();
      }

      // Update state with fetched data and max page number
      setState(() {
        _chars = results;
        _maxPage = data['info']['pages'];
      });
    } else {
      // If the request failed, clear the character list
      setState(() => _chars = []);
    }

    // Indicate that loading has finished
    setState(() => _loading = false);
  }

  /// Signs out the currently authenticated Firebase user.
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
  }

  /// Applies filters based on the current text fields and refetches data.
  void _applyFilters() {
    // Update filter variables from controllers
    _filterName = _nameController.text.trim();
    _filterSpecies = _speciesController.text.trim();
    _filterLocation = _locationController.text.trim();

    // Reset to first page whenever filters change
    _page = 1;

    // Fetch data with new filters
    _fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Top app bar with title and logout button
      appBar: AppBar(
        title: Text(
          'Characters', 
          style: GoogleFonts.lato(), // Apply custom Google Font
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _logout, // Call logout method when pressed
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),

      body: Column(
        children: [
          // ===== Filters Section =====
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              children: [
                // Name filter text field
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
                const SizedBox(height: 8),

                // Row containing two dropdowns: Status and Gender
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _filterStatus,
                        items: _statuses
                            .map((s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(s.isEmpty ? 'Status' : s),
                                ))
                            .toList(),
                        onChanged: (v) {
                          _filterStatus = v ?? '';
                        },
                        decoration: const InputDecoration(
                          labelText: 'Status',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _filterGender,
                        items: _genders
                            .map((g) => DropdownMenuItem(
                                  value: g,
                                  child: Text(g.isEmpty ? 'Gender' : g),
                                ))
                            .toList(),
                        onChanged: (v) {
                          _filterGender = v ?? '';
                        },
                        decoration: const InputDecoration(
                          labelText: 'Gender',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Species filter text field
                TextField(
                  controller: _speciesController,
                  decoration: const InputDecoration(
                    labelText: 'Species',
                    prefixIcon: Icon(Icons.pets),
                  ),
                ),
                const SizedBox(height: 8),

                // Location filter text field
                TextField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    prefixIcon: Icon(Icons.place),
                  ),
                ),
                const SizedBox(height: 8),

                // Button to apply all filters
                ElevatedButton(
                  onPressed: _applyFilters,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(40),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Apply Filters'),
                ),
              ],
            ),
          ),

          // Show a linear progress indicator when loading data
          if (_loading) const LinearProgressIndicator(),

          // ===== Characters Grid =====
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Two cards per row
                childAspectRatio: 0.8, // Aspect ratio for each card
                mainAxisSpacing: 8, // Vertical spacing between cards
                crossAxisSpacing: 8, // Horizontal spacing between cards
              ),
              itemCount: _chars.length,
              itemBuilder: (_, index) {
                final character = _chars[index];
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Display character image with rounded corners
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          character['image'],
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Display character name below the image
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          character['name'],
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // ===== Pagination Controls =====
          Container(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Previous page button (disabled on first page)
                TextButton(
                  onPressed: _page > 1
                      ? () {
                          setState(() => _page--);
                          _fetch();
                        }
                      : null,
                  child: const Text('Previous'),
                ),
                // Display current page out of total pages
                Text('Page $_page of $_maxPage'),
                // Next page button (disabled on last page)
                TextButton(
                  onPressed: _page < _maxPage
                      ? () {
                          setState(() => _page++);
                          _fetch();
                        }
                      : null,
                  child: const Text('Next'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
