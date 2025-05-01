// lib/pages/characters_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

class CharactersPage extends StatefulWidget {
  const CharactersPage({super.key});
  @override
  State<CharactersPage> createState() => _CharactersPageState();
}

class _CharactersPageState extends State<CharactersPage> {
  int _page = 1;
  List _chars = [];
  bool _loading = false;
  int _maxPage = 1;

  // filtros
  String _filterName = '';
  String _filterStatus = '';
  String _filterSpecies = '';
  String _filterGender = '';
  String _filterLocation = '';

  final _nameController = TextEditingController();
  final _speciesController = TextEditingController();
  final _locationController = TextEditingController();

  static const _statuses = ['', 'alive', 'dead', 'unknown'];
  static const _genders = ['', 'male', 'female', 'genderless', 'unknown'];

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    final qs = {
      'page': '$_page',
      if (_filterName.isNotEmpty) 'name': _filterName,
      if (_filterStatus.isNotEmpty) 'status': _filterStatus,
      if (_filterSpecies.isNotEmpty) 'species': _filterSpecies,
      if (_filterGender.isNotEmpty) 'gender': _filterGender,
    };
    final uri = Uri.https('rickandmortyapi.com', '/api/character', qs);
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      var results = data['results'] as List;
      // filtro de localização client-side
      if (_filterLocation.isNotEmpty) {
        results = results
            .where((c) => (c['location']['name'] as String)
                .toLowerCase()
                .contains(_filterLocation.toLowerCase()))
            .toList();
      }
      setState(() {
        _chars = results;
        _maxPage = data['info']['pages'];
      });
    } else {
      setState(() => _chars = []);
    }
    setState(() => _loading = false);
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
  }

  void _applyFilters() {
    _filterName = _nameController.text.trim();
    _filterSpecies = _speciesController.text.trim();
    _filterLocation = _locationController.text.trim();
    _page = 1;
    _fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Personagens', style: GoogleFonts.lato()),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
          )
        ],
      ),
      body: Column(
        children: [
          // filtros
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
                const SizedBox(height: 8),
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
                                  child: Text(g.isEmpty ? 'Gênero' : g),
                                ))
                            .toList(),
                        onChanged: (v) {
                          _filterGender = v ?? '';
                        },
                        decoration: const InputDecoration(
                          labelText: 'Gênero',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _speciesController,
                  decoration: const InputDecoration(
                    labelText: 'Espécie',
                    prefixIcon: Icon(Icons.pets),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'Localização',
                    prefixIcon: Icon(Icons.place),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _applyFilters,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(40),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Aplicar filtros'),
                ),
              ],
            ),
          ),

          if (_loading) const LinearProgressIndicator(),

          // grid de personagens
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: _chars.length,
              itemBuilder: (_, i) {
                final c = _chars[i];
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          c['image'],
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          c['name'],
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

          // paginação
          Container(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: _page > 1
                      ? () {
                          setState(() => _page--);
                          _fetch();
                        }
                      : null,
                  child: const Text('Anterior'),
                ),
                Text('Página $_page de $_maxPage'),
                TextButton(
                  onPressed: _page < _maxPage
                      ? () {
                          setState(() => _page++);
                          _fetch();
                        }
                      : null,
                  child: const Text('Próxima'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
