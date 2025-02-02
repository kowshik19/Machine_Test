import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rest_api/Provider/pokemon_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();

    Future.microtask(() =>
        Provider.of<PokemonProvider>(context, listen: false).fetchPokemons());
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    final provider = Provider.of<PokemonProvider>(context, listen: false);
    if (!provider.isFetchingMore &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 50) {
      provider.fetchPokemons();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        minimum: EdgeInsets.all(5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Pokédex",
                style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold)),
            Text("Search for a Pokémon by name or number.",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Expanded(
              child: Consumer<PokemonProvider>(
                builder: (context, provider, child) {
                  return GridView.builder(
                    controller: _scrollController,
                    itemCount: provider.pokemonList.length +
                        (provider.isFetchingMore ? 1 : 0),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2),
                    itemBuilder: (context, index) {
                      if (index >= provider.pokemonList.length) {
                        return Center(child: CircularProgressIndicator());
                      }
                      final pokemon = provider.pokemonList[index];
                      return Card(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(pokemon['name']!.toUpperCase(),
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold)),
                            Image.network(
                              pokemon['url']!,
                              loadingBuilder: (context, child, progress) {
                                return progress == null
                                    ? child
                                    : CircularProgressIndicator();
                              },
                              height: 100,
                            ),
                            Text(
                              (index + 1).toString().padLeft(3, '0'),
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
