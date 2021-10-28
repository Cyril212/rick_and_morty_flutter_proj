import 'package:flutter/material.dart';
import 'package:rick_and_morty_flutter_proj/core/ui/screen/abstract_screen.dart';

class RickMortyListScreen extends AbstractScreen {
  static const String route = '/';

  const RickMortyListScreen({Key? key}) : super(key: key);

  @override
  _RickMortyListScreenState createState() => _RickMortyListScreenState();
}

class _RickMortyListScreenState extends AbstractScreenState<RickMortyListScreen> {

  @override
  AbstractScreenStateOptions get options => AbstractScreenStateOptions.basic(screenName: RickMortyListScreen.route, title: "Rick and Morty");
  
  @override
  Widget buildContent(BuildContext context) {
    return Container(child: Text("test"));
  }

  @override
  PreferredSizeWidget? createAppBar(BuildContext context) => AppBar(title: Text(options.title));
}
