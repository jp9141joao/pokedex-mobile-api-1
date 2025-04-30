import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    final res = await http.get(
        Uri.parse('https://rickandmortyapi.com/api/character?page=$_page'));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      setState(() {
        _chars = data['results'];
        _maxPage = data['info']['pages'];
      });
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Personagens', style: GoogleFonts.lato()),
          centerTitle: true),
      body: Column(children: [
        if (_loading) const LinearProgressIndicator(),
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
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network(c['image'], height: 100, fit: BoxFit.cover),
                      const SizedBox(height: 8),
                      Text(c['name'], textAlign: TextAlign.center),
                    ]),
              );
            },
          ),
        ),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
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
        ]),
      ]),
    );
  }
}
