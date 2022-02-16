
import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';
import 'package:rick_and_morty_flutter_proj/constants/theme_constants.dart';
import 'package:rick_and_morty_flutter_proj/presentation/screens/rick_morty_detail/vm/rick_morty_detail_vm.dart';
import 'package:rick_and_morty_flutter_proj/presentation/widgets/character_card_widget.dart';
import 'package:rick_and_morty_flutter_proj/core/router/router_v1.dart';

class RickMortyDetailArgs {
  int characterId;

  RickMortyDetailArgs(this.characterId);

  Map<String, String> toJson() => <String, String>{'characterId': characterId.toString()};
}

class RickMortyDetailScreen extends StatelessWidget {
  static const String route = '/rick_morty_detail';

  const RickMortyDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.name?.routingArguments;
    final characterId = int.parse(arguments!['characterId']!);

    context.read<RickMortyDetailVM>().getCharacterById(context, characterId);

    return Scaffold(
      body: Container(
        constraints: const BoxConstraints.expand(),
        color: kColorPurple,
        child: Stack(
          children: <Widget>[
            _getBackground(context),
            _getGradient(),
            _getContent(context),
            _getToolbar(context),
          ],
        ),
      ),
    );
  }

  Container _getBackground(BuildContext context) {
    return Container(
      child: Image.network(
        context.read<RickMortyDetailVM>().currentCharacter.image,
        fit: BoxFit.cover,
        height: 300.0,
      ),
      constraints: const BoxConstraints.expand(height: 300.0),
    );
  }

  Container _getGradient() {
    return Container(
      margin: const EdgeInsets.only(top: 190.0),
      height: 110.0,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[kColorPurple, kColorPurple],
          stops: [0.0, 0.9],
          begin: FractionalOffset(0.0, 0.0),
          end: FractionalOffset(0.0, 1.0),
        ),
      ),
    );
  }

  Widget _getContent(BuildContext context) {
    final _overviewTitle = "Overview".toUpperCase();
    return ListView(
      padding: const EdgeInsets.fromLTRB(0.0, 72.0, 0.0, 32.0),
      children: <Widget>[
        CharacterCardWidget(
          character: context.read<RickMortyDetailVM>().currentCharacter,
          horizontal: false,
          onFavoriteClick: (bool isChosen) {
            context.read<RickMortyDetailVM>().setFavouriteCharacterState(isChosen);
          },
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                _overviewTitle,
              ),
              const Text(
                  "An animated series on adult-swim about the infinite adventures of Rick, a genius alcoholic and careless scientist, with his grandson Morty, a 14 year-old anxious boy who is not so smart. Together, they explore the infinite universes; causing mayhem and running into trouble."),
            ],
          ),
        ),
      ],
    );
  }

  Container _getToolbar(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: const BackButton(color: Colors.white),
    );
  }
}
