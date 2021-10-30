import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';
import 'package:rick_and_morty_flutter_proj/dataSources/responses/character_response.dart';
import 'package:intl/intl.dart';
import 'package:rick_and_morty_flutter_proj/ui/screens/rick_morty_list/vm/rick_morty_list_vm.dart';

class CharacterCardWidget extends StatelessWidget {
  final Character character;
  final bool horizontal;

  const CharacterCardWidget({Key? key, required this.character, this.horizontal = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final planetThumbnail = Container(
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      alignment: horizontal ? FractionalOffset.centerLeft : FractionalOffset.center,
      child: Hero(
        tag: "planet-hero-${character.id}",
        child: CircleAvatar(
          radius: 45,
          backgroundImage: NetworkImage(
            character.image,
          ),
        ),
      ),
    );

    final planetCardContent = Container(
      margin: EdgeInsets.fromLTRB(horizontal ? 76.0 : 16.0, horizontal ? 8.0 : 42.0, 16.0, 16.0),
      constraints: const BoxConstraints.expand(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: horizontal ? MainAxisAlignment.start : MainAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: horizontal ? CrossAxisAlignment.start : CrossAxisAlignment.center,
            children: <Widget>[
              Container(height: 4.0),
              Text(
                "Name: ${character.name}",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
              ),
              Container(height: 10.0),
              Text("Gender: ${character.gender}"),
              Container(height: 10.0),
              Text("Birth: ${DateFormat.yMd().format(character.created).toUpperCase()}"),
              Container(height: 10.0),
              if (!horizontal)
                FavoriteWidget(
                  isChosen: character.isFavourite,
                  characterId: character.id,
                  shouldRefreshList: true,
                )
            ],
          ),
          if (horizontal) Spacer(),
          if (horizontal)
            FavoriteWidget(
              isChosen: character.isFavourite,
              characterId: character.id,
            )
          // Icon(Icons.favorite,color: Colors.amber,)
        ],
      ),
    );

    final planetCard = Container(
      child: planetCardContent,
      height: horizontal ? 124.0 : 164.0,
      margin: horizontal ? const EdgeInsets.only(left: 46.0) : const EdgeInsets.only(top: 72.0),
      decoration: BoxDecoration(
        color: Color(0xFF333366),
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10.0,
            offset: Offset(0.0, 10.0),
          ),
        ],
      ),
    );

    return GestureDetector(
        onTap: horizontal
            ? () {
                context.read<RickMortyListVM>()
                  ..currentCharacterId = character.id
                  ..moveToDetailScreen(context);
              }
            : null,
        child: Container(
          margin: const EdgeInsets.symmetric(
            vertical: 16.0,
            horizontal: 24.0,
          ),
          child: Stack(
            children: <Widget>[
              planetCard,
              planetThumbnail,
            ],
          ),
        ));
  }
}

class FavoriteWidget extends StatefulWidget {
  final int characterId;
  bool isChosen;
  bool shouldRefreshList;

  FavoriteWidget({Key? key, this.isChosen = false, required this.characterId, this.shouldRefreshList = false}) : super(key: key);

  @override
  _FavoriteWidgetState createState() => _FavoriteWidgetState();
}

class _FavoriteWidgetState extends State<FavoriteWidget> {

  void _setFavouriteState(){
    context.read<RickMortyListVM>().setFavouriteCharacterState(widget.characterId, widget.isChosen);
    if (widget.shouldRefreshList) {
      context.read<RickMortyListVM>().updateCharacterList();
    }
  }

  void _updateWidgetState() {
    widget.isChosen = !widget.isChosen;

    _setFavouriteState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          setState(_updateWidgetState);
        },
        child: Icon(
          widget.isChosen ? Icons.favorite : Icons.favorite_border,
          color: Colors.amber,
        ));
  }
}
