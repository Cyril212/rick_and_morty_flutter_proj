import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/src/provider.dart';
import 'package:rick_and_morty_flutter_proj/dataSources/responses/character.dart';
import 'package:rick_and_morty_flutter_proj/ui/screens/rick_morty_detail/vm/rick_morty_detail_vm.dart';
import 'package:rick_and_morty_flutter_proj/ui/widgets/character_card_widget.dart';

class RickMortyDetailScreen extends StatelessWidget {
  static const String route = '/rick_morty_detail';
  late Character? character;

  RickMortyDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget mainContent;

    character = context.read<RickMortyDetailVM>().getCharacterById(context);
    final isCharacterFound = character != null;


    if(isCharacterFound){
      mainContent = Scaffold(
        body: Container(
          constraints: const BoxConstraints.expand(),
          color: const Color(0xFF736AB7),
          child: Stack(
            children: <Widget>[
              _getBackground(),
              _getGradient(),
              _getContent(),
              _getToolbar(context),
            ],
          ),
        ),
      );
    } else {
      mainContent = Container();
    }

    return mainContent;
  }

  Container _getBackground() {
    return Container(
      child: Image.network(
        character!.image,
        fit: BoxFit.cover,
        height: 300.0,
      ),
      constraints: const BoxConstraints.expand(height: 295.0),
    );
  }

  Container _getGradient() {
    return Container(
      margin: const EdgeInsets.only(top: 190.0),
      height: 110.0,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[Color(0x00736AB7), Color(0xFF736AB7)],
          stops: [0.0, 0.9],
          begin: FractionalOffset(0.0, 0.0),
          end: FractionalOffset(0.0, 1.0),
        ),
      ),
    );
  }

  Container _getContent() {
    final _overviewTitle = "Overview".toUpperCase();
    return Container(
      child: ListView(
        padding: EdgeInsets.fromLTRB(0.0, 72.0, 0.0, 32.0),
        children: <Widget>[
          CharacterCardWidget(
            character: character!,
            horizontal: false,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  _overviewTitle,
                ),
                Text("An animated series on adult-swim about the infinite adventures of Rick, a genius alcoholic and careless scientist, with his grandson Morty, a 14 year-old anxious boy who is not so smart. Together, they explore the infinite universes; causing mayhem and running into trouble."),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Container _getToolbar(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: const BackButton(color: Colors.white),
    );
  }
}