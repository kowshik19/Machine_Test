import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PokemonProvider with ChangeNotifier {
  final List<Map<String, String>> _pokemonList = [];
  bool _isFetchingMore = false;
  int _offset = 0;
  final int _limit = 20;

  List<Map<String, String>> get pokemonList => _pokemonList;
  bool get isFetchingMore => _isFetchingMore;

  Future<void> fetchPokemons() async {
    if (_isFetchingMore) return;
    _isFetchingMore = true;
    notifyListeners();

    final url =
        'https://pokeapi.co/api/v2/pokemon?offset=$_offset&limit=$_limit';
    final response = await http.get(Uri.parse(url));
    final json = jsonDecode(response.body);

    List<Future<Map<String, String>>> fetchTasks =
        json['results'].map<Future<Map<String, String>>>((pokemon) async {
      return _fetchPokemonData(pokemon);
    }).toList();

    List<Map<String, String>> tempList = await Future.wait(fetchTasks);

    _pokemonList.addAll(tempList);
    _offset += _limit;
    _isFetchingMore = false;
    notifyListeners();
  }

  Future<Map<String, String>> _fetchPokemonData(dynamic pokemon) async {
    final response = await http.get(Uri.parse(pokemon['url']));
    final json = jsonDecode(response.body);
    return {
      'name': pokemon['name'],
      'url': json['sprites']['other']['official-artwork']['front_default']
    };
  }
}
