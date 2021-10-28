import 'package:flutter/material.dart';
import 'package:rick_and_morty_flutter_proj/core/ui/screen/abstract_screen.dart';

class RickMortyDetailScreen extends AbstractScreen {
  static const String route = '/rick_morty_detail';

  const RickMortyDetailScreen({Key? key}) : super(key: key);

  @override
  _RickMortyDetailScreenState createState() => _RickMortyDetailScreenState();
}

class _RickMortyDetailScreenState extends AbstractScreenState<RickMortyDetailScreen> {

  @override
  Widget buildContent(BuildContext context) {
    return Container();
  }

  @override
  PreferredSizeWidget? createAppBar(BuildContext context) => AppBar(title: const Text("Rick and Morty",));
}
